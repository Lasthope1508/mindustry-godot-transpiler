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

	# --- Pure wave damage (N2196): ShockwaveTowerBuild.updateTile
	# fires its wave when the reload counter reaches reload with
	# targets observed (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){` with :81, `if(targets.size > 0){`), then applies `float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);` (ShockwaveTower.java:87, bulletDamage 160, ShockwaveTower.java:27, falloffCount 20f, ShockwaveTower.java:28) and loops the targets (ShockwaveTower.java:89, `for(var target : targets){`): a target whose damage exceeds the wave damage loses exactly waveDamage (`if(target.damage > waveDamage){` / `target.damage -= waveDamage;`, ShockwaveTower.java:90-91 -- the STRICT comparison, so a target at exactly waveDamage is removed, not left at 0), any other target is removed (`target.remove();`, ShockwaveTower.java:93, over `@Import float x, y, damage, lastX, lastY, time, lifetime;`, BulletComp.java:31), and every target gets its hit effect at its own position (`hitEffect.at(target.x, target.y, waveColor);`, ShockwaveTower.java:95). The port has no live bullets to mutate, so the pure function consumes the same observed bullet list as the N2195 scan (`observed_bullets`, an array of dicts with team/hittable/x/y/damage, world coords) and returns one outcome per target bullet instead of mutating it: `{"damage": remaining or null, "removed": bool, "hit_x": x, "hit_y": y}`. The target filter is the N2195 scan filter verbatim (enemy, hittable, point inside the range box x +/- 170, y +/- 170, range 170f per-def, Blocks.java:2043). Absent `observed_bullets` (or absent `x`/`y`/`team_id`) or zero targets in range means "no wave": wave_damage null, an empty outcome list, has_wave_damage false, and the driver stamps nothing (the N2190 / N2195 precedent). The driver calls the wave damage AFTER the N2194 fire and ONLY when the fire fired. No randomness is involved, so the scene seeds no RNG.
	# The pure keys share one tower (world 0, 0, team 1) and one
	# base bullet set: enemy hittable at (100, 0), (-170, 0) and
	# (0, 170) -- the last two on the box edge, still inside --
	# plus enemy hittable at (150, 150), inside the 170 box but
	# OUTSIDE the 170 circle (sqrt(150^2 + 150^2) ~= 212), each
	# with damage 500.0.
	var base_bullets: Array = [
		{"team": 2, "hittable": true, "x": 100.0, "y": 0.0, "damage": 500.0},
		{"team": 2, "hittable": true, "x": -170.0, "y": 0.0, "damage": 500.0},
		{"team": 2, "hittable": true, "x": 0.0, "y": 170.0, "damage": 500.0},
		{"team": 2, "hittable": true, "x": 150.0, "y": 150.0, "damage": 500.0},
	]

	# Wave damage caps at bulletDamage for few targets: 4
	# targets -> waveDamage min(160, 160 * 20 / 4 = 800) = 160;
	# every outcome keeps damage 500 - 160 = 340, removed false.
	var capped: Dictionary = shockwave_tower_build_state.source_shockwave_tower_wave_damage_state({"x": 0.0, "y": 0.0, "team_id": 1, "observed_bullets": base_bullets})
	var capped_outcomes: Array = capped.get("bullet_outcomes", [])
	proof["wave_damage_caps_at_bullet_damage"] = bool(capped.get("has_wave_damage", false)) == true and float(capped.get("wave_damage", -1.0)) == 160.0 and capped_outcomes.size() == 4 and capped_outcomes.all(func(outcome): return bool(outcome.get("removed", true)) == false and float(outcome.get("damage", -1.0)) == 340.0)

	# Wave damage falls off with many targets: 40 enemy hittable
	# bullets in range, damage 500 each -> waveDamage min(160,
	# 160 * 20 / 40 = 80) = 80; every outcome keeps 420.
	var many_bullets: Array = []
	for i in range(40):
		many_bullets.append({"team": 2, "hittable": true, "x": -160.0 + float(i) * 8.0, "y": 0.0, "damage": 500.0})
	var falloff: Dictionary = shockwave_tower_build_state.source_shockwave_tower_wave_damage_state({"x": 0.0, "y": 0.0, "team_id": 1, "observed_bullets": many_bullets})
	var falloff_outcomes: Array = falloff.get("bullet_outcomes", [])
	proof["wave_damage_falls_off_with_many_targets"] = bool(falloff.get("has_wave_damage", false)) == true and float(falloff.get("wave_damage", -1.0)) == 80.0 and falloff_outcomes.size() == 40 and falloff_outcomes.all(func(outcome): return bool(outcome.get("removed", true)) == false and float(outcome.get("damage", -1.0)) == 420.0)

	# Low-damage bullets are removed, not left at zero: 4
	# targets with damages 100, 160, 161 and 500, wave 160 --
	# the 100 and the 160 (exactly waveDamage, the strict `>`
	# comparison) are removed with damage null, the 161 keeps
	# 1.0, the 500 keeps 340.0.
	var low_bullets: Array = [
		{"team": 2, "hittable": true, "x": 100.0, "y": 0.0, "damage": 100.0},
		{"team": 2, "hittable": true, "x": -100.0, "y": 0.0, "damage": 160.0},
		{"team": 2, "hittable": true, "x": 0.0, "y": 100.0, "damage": 161.0},
		{"team": 2, "hittable": true, "x": 0.0, "y": -100.0, "damage": 500.0},
	]
	var low: Dictionary = shockwave_tower_build_state.source_shockwave_tower_wave_damage_state({"x": 0.0, "y": 0.0, "team_id": 1, "observed_bullets": low_bullets})
	var low_outcomes: Array = low.get("bullet_outcomes", [])
	proof["low_damage_bullets_removed"] = bool(low.get("has_wave_damage", false)) == true and float(low.get("wave_damage", -1.0)) == 160.0 and low_outcomes.size() == 4 and bool(low_outcomes[0].get("removed", false)) == true and low_outcomes[0].get("damage", -1.0) == null and bool(low_outcomes[1].get("removed", false)) == true and low_outcomes[1].get("damage", -1.0) == null and bool(low_outcomes[2].get("removed", true)) == false and float(low_outcomes[2].get("damage", -1.0)) == 1.0 and bool(low_outcomes[3].get("removed", true)) == false and float(low_outcomes[3].get("damage", -1.0)) == 340.0

	# Hit-effect positions follow the targets: the capped
	# wave's four outcomes carry hit_x / hit_y equal to each
	# target bullet's own x / y, in scan order.
	proof["hit_effect_positions_follow_targets"] = capped_outcomes.size() == 4 and float(capped_outcomes[0].get("hit_x", -999.0)) == 100.0 and float(capped_outcomes[0].get("hit_y", -999.0)) == 0.0 and float(capped_outcomes[1].get("hit_x", -999.0)) == -170.0 and float(capped_outcomes[1].get("hit_y", -999.0)) == 0.0 and float(capped_outcomes[2].get("hit_x", -999.0)) == 0.0 and float(capped_outcomes[2].get("hit_y", -999.0)) == 170.0 and float(capped_outcomes[3].get("hit_x", -999.0)) == 150.0 and float(capped_outcomes[3].get("hit_y", -999.0)) == 150.0

	# Absent observed_bullets stamps nothing: the frame carries
	# x/y/team_id but NO observed_bullets key at all -- wave_damage
	# is null, the outcome list is empty, has_wave_damage is
	# false, so the driver stamps nothing. A present-but-empty
	# list is the same: zero targets means no wave.
	var absent: Dictionary = shockwave_tower_build_state.source_shockwave_tower_wave_damage_state({"x": 0.0, "y": 0.0, "team_id": 1})
	var empty: Dictionary = shockwave_tower_build_state.source_shockwave_tower_wave_damage_state({"x": 0.0, "y": 0.0, "team_id": 1, "observed_bullets": []})
	proof["absent_observed_bullets_stamps_nothing"] = bool(absent.get("has_wave_damage", true)) == false and absent.get("wave_damage", -1.0) == null and (absent.get("bullet_outcomes", [1]) as Array).is_empty() and bool(empty.get("has_wave_damage", true)) == false and empty.get("wave_damage", -1.0) == null and (empty.get("bullet_outcomes", [1]) as Array).is_empty()

	# --- Live tick: the shockwave tower is a ShockwaveTower build
	# with a static power consumer (shockwave-tower,
	# consumePower 100f / 60f, Blocks.java:2042), placed live; the tick
	# driver is called directly (as the N2177/N2191/N2192/N2193/N2194/
	# N2195 proofs do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back itself
	# is already proven by N2142. The driver calls the wave
	# damage AFTER the N2194 fire and ONLY when the fire fired
	# (the Java order, the wave :87-96 runs inside the fire gate
	# after the targets.size check :81), deriving the tower world
	# position from the placement cell (cell (28, 21), size 3,
	# tilesize 8, offset 0 -- world (224, 168)) and stamping
	# frame["wave_damage"] / frame["bullet_outcomes"] only when
	# the wave reports one. The tower team is 1
	# (record_placed_block default, SOURCE_TEAM_SHARDED_ID).
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

	# Live driver stamps wave damage only on fire:
	# observed_bullets stamped on the frame before the tick (the
	# observed-only input, like N2195's targets_count) -- two
	# enemy hittable bullets in range with damage 500 at
	# (324, 168) (tower world (224, 168) + 100) and (224, 68)
	# (tower - 100 y), one same-team hittable bullet at the
	# tower, one enemy non-hittable bullet at the tower, one
	# enemy hittable bullet out of range at (395, 168) (+171).
	# The reload counter is preset to 80.0 (per-def reload) so
	# the N2194 fire runs this tick: the N2193 shouldConsume
	# gate reads the preset counter as fully charged and zeroes
	# efficiency, but the fire reads potential_efficiency (1.0
	# from the stamped power_status), exactly like Java, so the
	# fire still fires and the wave applies: waveDamage
	# min(160, 160 * 20 / 2) = 160, both outcomes keep 340.
	shockwave_tower_frame["observed_bullets"] = [
		{"team": 2, "hittable": true, "x": 324.0, "y": 168.0, "damage": 500.0},
		{"team": 2, "hittable": true, "x": 224.0, "y": 68.0, "damage": 500.0},
		{"team": 1, "hittable": true, "x": 224.0, "y": 168.0, "damage": 500.0},
		{"team": 2, "hittable": false, "x": 224.0, "y": 168.0, "damage": 500.0},
		{"team": 2, "hittable": true, "x": 395.0, "y": 168.0, "damage": 500.0},
	]
	shockwave_tower_frame["power_status"] = 1.0
	shockwave_tower_frame["enabled"] = true
	shockwave_tower_frame["reload_counter"] = 80.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	var live_outcomes: Array = shockwave_tower_frame.get("bullet_outcomes", [])
	proof["live_driver_stamps_wave_damage_on_fire"] = float(shockwave_tower_frame.get("wave_damage", -1.0)) == 160.0 and live_outcomes.size() == 2 and live_outcomes.all(func(outcome): return bool(outcome.get("removed", true)) == false and float(outcome.get("damage", -1.0)) == 340.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerWaveDamageProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
