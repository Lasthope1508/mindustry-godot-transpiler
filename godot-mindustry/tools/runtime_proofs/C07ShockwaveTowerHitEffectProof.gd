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

	# --- Pure hit effect (N2198): ShockwaveTowerBuild.updateTile
	# fires its wave when the reload counter reaches reload with
	# targets observed (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){` with :81, `if(targets.size > 0){`), then applies the wave damage (`float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);`, ShockwaveTower.java:87) and loops the targets (`for(var target : targets){`, ShockwaveTower.java:89): a target whose damage exceeds the wave damage loses exactly waveDamage (`if(target.damage > waveDamage){` / `target.damage -= waveDamage;`, ShockwaveTower.java:90-91 -- the STRICT comparison, so a target at exactly waveDamage is removed, not left at 0), any other target is removed (`target.remove();`, ShockwaveTower.java:93), and EVERY target gets its hit effect at its own position (`hitEffect.at(target.x, target.y, waveColor);`, ShockwaveTower.java:95, over `public Effect hitEffect = Fx.hitSquaresColor;`, ShockwaveTower.java:35 -- Fx.hitSquaresColor takes e.color from the at() color argument, `color(Color.white, e.color, e.fin());`, Fx.java:891, and waveColor is Pal.accent, ShockwaveTower.java:29, `public Color waveColor = Pal.accent, heatColor = Pal.turretHeat, shapeColor = Color.valueOf("f29c83");`, Pal.accent = Color.valueOf("ffd37f"), Pal.java:79). The port spawns no real Fx (no Godot equivalents are wired), so the pure function stamps one descriptor per Java call instead of spawning it. The function consumes the N2196 `bullet_outcomes` stamped on the frame (one outcome per target, in the same order as Java's targets loop, each with hit_x/hit_y) -- never re-filtering the observed bullets, so the hit effects cover exactly the targets the wave damage just processed. The driver calls the hit effect AFTER the N2196 wave damage and ONLY when the fire fired (the Java order :87 before :89-95).
	# The pure keys share one outcomes list (two damaged targets).
	var two_damaged: Dictionary = shockwave_tower_build_state.source_shockwave_tower_hit_effect_state({"bullet_outcomes": [{"damage": 340.0, "removed": false, "hit_x": 324.0, "hit_y": 168.0}, {"damage": 340.0, "removed": false, "hit_x": 224.0, "hit_y": 68.0}]})
	var hit_effects: Array = two_damaged.get("hit_effects", [])

	# Hit effects spawn at the target positions: one
	# Fx.hitSquaresColor descriptor per outcome, at the target's
	# own position, color Pal.accent, in Java targets order.
	var first: Dictionary = hit_effects[0] if hit_effects.size() > 0 else {}
	var second: Dictionary = hit_effects[1] if hit_effects.size() > 1 else {}
	proof["hit_effects_spawn_at_target_positions"] = bool(two_damaged.get("has_hit_effects", false)) == true and hit_effects.size() == 2 and String(first.get("effect", "")) == "hitSquaresColor" and float(first.get("x", -999.0)) == 324.0 and float(first.get("y", -999.0)) == 168.0 and String(first.get("color", "")) == "Pal.accent" and String(second.get("effect", "")) == "hitSquaresColor" and float(second.get("x", -999.0)) == 224.0 and float(second.get("y", -999.0)) == 68.0 and String(second.get("color", "")) == "Pal.accent"

	# Removed and damaged bullets both get effects: the effect
	# sits after the damage / remove branch (:90-94), not inside
	# either arm -- one damaged outcome (damage 340, removed
	# false) and one removed outcome (damage null, removed true)
	# both produce a descriptor at their own position.
	var mixed: Dictionary = shockwave_tower_build_state.source_shockwave_tower_hit_effect_state({"bullet_outcomes": [{"damage": 340.0, "removed": false, "hit_x": 324.0, "hit_y": 168.0}, {"damage": null, "removed": true, "hit_x": 224.0, "hit_y": 68.0}]})
	var mixed_effects: Array = mixed.get("hit_effects", [])
	var mixed_first: Dictionary = mixed_effects[0] if mixed_effects.size() > 0 else {}
	var mixed_second: Dictionary = mixed_effects[1] if mixed_effects.size() > 1 else {}
	proof["removed_and_damaged_bullets_both_get_effects"] = bool(mixed.get("has_hit_effects", false)) == true and mixed_effects.size() == 2 and String(mixed_first.get("effect", "")) == "hitSquaresColor" and float(mixed_first.get("x", -999.0)) == 324.0 and float(mixed_first.get("y", -999.0)) == 168.0 and String(mixed_second.get("effect", "")) == "hitSquaresColor" and float(mixed_second.get("x", -999.0)) == 224.0 and float(mixed_second.get("y", -999.0)) == 68.0

	# Absent outcomes spawn nothing: the frame carries NO
	# bullet_outcomes key at all -- hit_effects is empty,
	# has_hit_effects is false, so the driver stamps nothing.
	var absent: Dictionary = shockwave_tower_build_state.source_shockwave_tower_hit_effect_state({})
	proof["absent_outcomes_spawn_nothing"] = bool(absent.get("has_hit_effects", true)) == false and (absent.get("hit_effects", [1]) as Array).is_empty()

	# Empty outcomes spawn nothing: a present-but-empty
	# bullet_outcomes list IS an observation of zero targets --
	# still no descriptors, has_hit_effects false.
	var empty: Dictionary = shockwave_tower_build_state.source_shockwave_tower_hit_effect_state({"bullet_outcomes": []})
	proof["empty_outcomes_spawn_nothing"] = bool(empty.get("has_hit_effects", true)) == false and (empty.get("hit_effects", [1]) as Array).is_empty()

	# --- Live tick: the shockwave tower is a ShockwaveTower build
	# with a static power consumer (shockwave-tower,
	# consumePower 100f / 60f, Blocks.java:2042), placed live; the tick
	# driver is called directly (as the N2177/N2191/N2192/N2193/N2194/
	# N2195/N2196/N2197 proofs do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back itself
	# is already proven by N2142. The driver calls the hit effect
	# AFTER the N2196 wave damage and ONLY when the fire fired
	# (the Java order :87 before :89-95), deriving the tower world
	# position from the placement cell (cell (28, 21), size 3,
	# tilesize 8, offset 0 -- world (224, 168)) and stamping
	# frame["hit_effects"] only when the hit effect reports one.
	# The tower team is 1 (record_placed_block default,
	# SOURCE_TEAM_SHARDED_ID).
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

	# Live driver stamps hit effects only on fire:
	# observed_bullets stamped on the frame before the tick (the
	# observed-only input, like N2195's targets_count) -- two
	# enemy hittable bullets in range with damage 500 at
	# (324, 168) (tower world (224, 168) + 100) and (224, 68)
	# (tower - 100 y). The reload counter is preset to 80.0
	# (per-def reload) so the N2194 fire runs this tick: the
	# N2193 shouldConsume gate reads the preset counter as fully
	# charged and zeroes efficiency, but the fire reads
	# potential_efficiency (1.0 from the stamped power_status),
	# exactly like Java, so the fire still fires, the wave damage
	# is min(160, 160 * 20 / 2) = 160 (both bullets damaged, 500
	# > 160, remaining 340), and the hit effects stamp one
	# Fx.hitSquaresColor descriptor per bullet at (324, 168) and
	# (224, 68), color Pal.accent.
	shockwave_tower_frame["observed_bullets"] = [
		{"team": 2, "hittable": true, "x": 324.0, "y": 168.0, "damage": 500.0},
		{"team": 2, "hittable": true, "x": 224.0, "y": 68.0, "damage": 500.0},
	]
	shockwave_tower_frame["power_status"] = 1.0
	shockwave_tower_frame["enabled"] = true
	shockwave_tower_frame["reload_counter"] = 80.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	var live_effects: Array = shockwave_tower_frame.get("hit_effects", [])
	var live_first: Dictionary = live_effects[0] if live_effects.size() > 0 else {}
	var live_second: Dictionary = live_effects[1] if live_effects.size() > 1 else {}
	proof["live_driver_stamps_hit_effects_on_fire"] = live_effects.size() == 2 and String(live_first.get("effect", "")) == "hitSquaresColor" and float(live_first.get("x", -999.0)) == 324.0 and float(live_first.get("y", -999.0)) == 168.0 and String(live_first.get("color", "")) == "Pal.accent" and String(live_second.get("effect", "")) == "hitSquaresColor" and float(live_second.get("x", -999.0)) == 224.0 and float(live_second.get("y", -999.0)) == 68.0 and String(live_second.get("color", "")) == "Pal.accent"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerHitEffectProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
