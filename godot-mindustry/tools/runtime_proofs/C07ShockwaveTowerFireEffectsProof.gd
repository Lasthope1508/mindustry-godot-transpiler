extends Node

const main_scene := preload("res://scenes/Main.tscn")
const shockwave_tower_build_state := preload("res://src/game/SourceShockwaveTowerBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- Pure fire effects (N2197): ShockwaveTowerBuild.updateTile
	# fires its wave when the reload counter reaches reload with
	# targets observed (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){` with :81, `if(targets.size > 0){`), then, after heat = 1f and reloadCounter = 0f (:82-83), spawns the wave effect (`waveEffect.at(x, y, range, waveColor);`, ShockwaveTower.java:84, over `public Effect waveEffect = Fx.pointShockwave;`, ShockwaveTower.java:35 -- Fx.pointShockwave draws `Lines.circle(e.x, e.y, e.finpow() * e.rotation)`, Fx.java:223-228, so the `range` argument is the effect rotation and the final circle radius is range 170f per-def, Blocks.java:2043, in waveColor Pal.accent, ShockwaveTower.java:29, `public Color waveColor = Pal.accent, heatColor = Pal.turretHeat, shapeColor = Color.valueOf("f29c83");`, Pal.accent = Color.valueOf("ffd37f"), Pal.java:79), plays the shoot sound (`shootSound.at(x, y, 1f + Mathf.range(0.15f), 1f);`, ShockwaveTower.java:85, over `public Sound shootSound = Sounds.shockwaveTower;`, ShockwaveTower.java:30 -- pitch 1f +/- 0.15f random, volume 1f), and shakes the screen (`Effect.shake(shake, shake, this);`, ShockwaveTower.java:86, over `public float shake = 2f;`, ShockwaveTower.java:27, and `public static void shake(float intensity, float duration, Position loc){`, Effect.java:210-211 -- intensity 2f, duration 2f, at the tower). The port spawns no real Fx / sound / shake (no Godot equivalents are wired), so the pure function stamps one descriptor per Java call instead of spawning it. The pitch is the DETERMINISTIC range of `1f + Mathf.range(0.15f)`, never a sampled pitch -- the pure function takes no RNG, so the scene seeds none. The driver calls the effects AFTER the N2194 fire and ONLY when the fire fired, and BEFORE the N2196 wave damage (the Java order :84-86 before :87).
	# The pure keys share one tower (world 0, 0).
	var at_origin: Dictionary = shockwave_tower_build_state.source_shockwave_tower_fire_effects_state({"x": 0.0, "y": 0.0})
	var wave_effect: Dictionary = at_origin.get("wave_effect", {})
	var shoot_sound: Dictionary = at_origin.get("shoot_sound", {})
	var shake: Dictionary = at_origin.get("shake", {})

	# Wave effect spawns at the tower: Fx.pointShockwave at
	# (0, 0), rotation = range 170f per-def, color Pal.accent.
	proof["wave_effect_spawns_at_tower"] = bool(at_origin.get("has_fire_effects", false)) == true and String(wave_effect.get("effect", "")) == "pointShockwave" and float(wave_effect.get("x", -999.0)) == 0.0 and float(wave_effect.get("y", -999.0)) == 0.0 and float(wave_effect.get("rotation", -1.0)) == 170.0 and String(wave_effect.get("color", "")) == "Pal.accent"

	# Shoot sound carries the deterministic pitch range:
	# Sounds.shockwaveTower at (0, 0), pitch [0.85, 1.15]
	# (1f + Mathf.range(0.15f)), volume 1.0.
	proof["shoot_sound_pitch_range"] = String(shoot_sound.get("sound", "")) == "shockwaveTower" and float(shoot_sound.get("x", -999.0)) == 0.0 and float(shoot_sound.get("y", -999.0)) == 0.0 and float(shoot_sound.get("pitch_min", -1.0)) == 0.85 and float(shoot_sound.get("pitch_max", -1.0)) == 1.15 and float(shoot_sound.get("volume", -1.0)) == 1.0

	# Shake carries intensity and duration 2.0 at the tower.
	proof["shake_intensity_and_duration"] = float(shake.get("intensity", -1.0)) == 2.0 and float(shake.get("duration", -1.0)) == 2.0 and float(shake.get("x", -999.0)) == 0.0 and float(shake.get("y", -999.0)) == 0.0

	# Absent position stamps nothing: the frame carries NO x/y
	# keys at all -- wave_effect / shoot_sound / shake are null,
	# has_fire_effects is false, so the driver stamps nothing.
	# A frame with x but no y is the same: no effects.
	var absent: Dictionary = shockwave_tower_build_state.source_shockwave_tower_fire_effects_state({})
	var half: Dictionary = shockwave_tower_build_state.source_shockwave_tower_fire_effects_state({"x": 0.0})
	proof["absent_position_stamps_nothing"] = bool(absent.get("has_fire_effects", true)) == false and absent.get("wave_effect", 1) == null and absent.get("shoot_sound", 1) == null and absent.get("shake", 1) == null and bool(half.get("has_fire_effects", true)) == false and half.get("wave_effect", 1) == null and half.get("shoot_sound", 1) == null and half.get("shake", 1) == null

	# --- Live tick: the shockwave tower is a ShockwaveTower build
	# with a static power consumer (shockwave-tower,
	# consumePower 100f / 60f, Blocks.java:2042), placed live; the tick
	# driver is called directly (as the N2177/N2191/N2192/N2193/N2194/
	# N2195/N2196 proofs do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back itself
	# is already proven by N2142. The driver calls the effects
	# AFTER the N2194 fire and ONLY when the fire fired, BEFORE
	# the N2196 wave damage (the Java order :84-86 before :87),
	# deriving the tower world position from the placement cell
	# (cell (28, 21), size 3, tilesize 8, offset 0 -- world
	# (224, 168)) and stamping frame["wave_effect"] /
	# frame["shoot_sound"] / frame["shake"] only when the effects
	# report one. The tower team is 1 (record_placed_block
	# default, SOURCE_TEAM_SHARDED_ID).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var shockwave_tower_cell := Vector2i(28, 21)
	var shockwave_tower := Sprite2D.new()
	game.add_child(shockwave_tower)
	game.call("record_placed_block", shockwave_tower, blocks_by_id["shockwave-tower"], shockwave_tower_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	shockwave_tower_build_state.source_shockwave_tower_bind_frame_state(shockwave_tower, blocks_by_id["shockwave-tower"])
	var shockwave_tower_frame: Dictionary = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})

	# Live driver stamps fire effects only on fire:
	# observed_bullets stamped on the frame before the tick (the
	# observed-only input, like N2195's targets_count) -- two
	# enemy hittable bullets in range with damage 500 at
	# (324, 168) (tower world (224, 168) + 100) and (224, 68)
	# (tower - 100 y). The reload counter is preset to 80.0
	# (per-def reload) so the N2194 fire runs this tick: the
	# N2193 shouldConsume gate reads the preset counter as fully
	# charged and zeroes efficiency, but the fire reads
	# potential_efficiency (1.0 from the stamped power_status),
	# exactly like Java, so the fire still fires and the effects
	# stamp: wave effect pointShockwave at (224, 168) rotation
	# 170.0 color Pal.accent, shoot sound shockwaveTower at
	# (224, 168) pitch [0.85, 1.15] volume 1.0, shake intensity
	# 2.0 duration 2.0 at (224, 168).
	shockwave_tower_frame["observed_bullets"] = [
		{"team": 2, "hittable": true, "x": 324.0, "y": 168.0, "damage": 500.0},
		{"team": 2, "hittable": true, "x": 224.0, "y": 68.0, "damage": 500.0},
	]
	shockwave_tower_frame["power_status"] = 1.0
	shockwave_tower_frame["enabled"] = true
	shockwave_tower_frame["reload_counter"] = 80.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	var live_wave: Dictionary = shockwave_tower_frame.get("wave_effect", {})
	var live_sound: Dictionary = shockwave_tower_frame.get("shoot_sound", {})
	var live_shake: Dictionary = shockwave_tower_frame.get("shake", {})
	proof["live_driver_stamps_fire_effects_on_fire"] = String(live_wave.get("effect", "")) == "pointShockwave" and float(live_wave.get("x", -999.0)) == 224.0 and float(live_wave.get("y", -999.0)) == 168.0 and float(live_wave.get("rotation", -1.0)) == 170.0 and String(live_wave.get("color", "")) == "Pal.accent" and String(live_sound.get("sound", "")) == "shockwaveTower" and float(live_sound.get("pitch_min", -1.0)) == 0.85 and float(live_sound.get("pitch_max", -1.0)) == 1.15 and float(live_sound.get("volume", -1.0)) == 1.0 and float(live_shake.get("intensity", -1.0)) == 2.0 and float(live_shake.get("duration", -1.0)) == 2.0 and float(live_shake.get("x", -999.0)) == 224.0 and float(live_shake.get("y", -999.0)) == 168.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerFireEffectsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
