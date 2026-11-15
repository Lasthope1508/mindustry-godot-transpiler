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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# --- Pure advance (N2247): ShockwaveTowerBuild.updateTile()
	# (ShockwaveTower.java:72-105). The fire gate
	# (ShockwaveTower.java:73, `if(potentialEfficiency > 0 &&
	# (reloadCounter += edelta()) >= reload && timer(timerCheck,
	# checkInterval)){`) reads the reload counter N2187 ALREADY
	# charged in the driver -- the advance does NOT add edelta
	# again. potentialEfficiency comes from the frame (stamped
	# by apply_update_consumption_state); the timer outcome is
	# the explicit check_ready input (no timer infra in the
	# port, the N2193 precedent; checkInterval 8f,
	# ShockwaveTower.java:31). The scan is a RECTANGLE
	# intersect (Groups.bullet.intersect over the range*2 box,
	# ShockwaveTower.java:75); the explicit candidate list IS
	# the intersect result (the N2229 precedent), and the pure
	# filter keeps enemy + hittable bullets only
	# (`if(b.team != team && b.type.hittable){`,
	# ShockwaveTower.java:76 -- hittable lives on the bullet
	# TYPE, BulletType.java:143, `public boolean hittable =
	# true;`). The wave damage is `float waveDamage =
	# Math.min(bulletDamage, bulletDamage * falloffCount /
	# targets.size);` (ShockwaveTower.java:87, bulletDamage 160
	# :27, falloffCount 20f :28); each target with damage
	# strictly above waveDamage loses waveDamage
	# (`target.damage -= waveDamage;`, :91), the rest are
	# removed (`target.remove();`, :93 -- the boundary is
	# strict: damage == waveDamage removes). Heat is set to 1f
	# on fire (`heat = 1f;`, :82), the counter resets
	# (`reloadCounter = 0f;`, :83), then the unconditional
	# decay runs (`heat = Mathf.clamp(heat - Time.delta /
	# reload * cooldownMultiplier);`, :104 -- Arc's single-arg
	# clamp is [0, 1], Mathf.java:402-404), so a fired tick
	# ends below 1f. DEF BEATS CLASS: the shockwave-tower def
	# (Blocks.java:2038-2044) sets range 170f and reload 80f
	# over the class defaults (range 110f, reload 60f * 1.5f =
	# 90f); bulletDamage 160 / falloffCount 20f /
	# cooldownMultiplier 1f have no def override. The wave
	# effect / sound / shake (:84-86), the hit effect (:95)
	# and the team event (Trigger.shockwaveTowerUse, :98-99)
	# defer -- the advance fires silently.
	var reload_def := 80.0
	var bullet_damage := 160.0
	var falloff_count := 20.0
	var cooldown_multiplier := 1.0
	var own_team := 1
	var enemy_team := 2

	# --- Fire gate: needs a charged counter AND the timer.
	# Uncharged (counter 40 < reload 80) with the timer ready:
	# no fire, the counter is untouched, heat only decays.
	var uncharged: Dictionary = shockwave_tower_build_state.source_shockwave_tower_update_tile_advance_state({"team_id": own_team, "potential_efficiency": 1.0, "reload_counter": 40.0, "heat": 0.5}, 1.0, reload_def, bullet_damage, falloff_count, cooldown_multiplier, [{"team": enemy_team, "hittable": true, "damage": 500.0, "x": 0.0, "y": 0.0}], true)
	# Charged (counter 80) but the timer not ready: no fire.
	var no_timer: Dictionary = shockwave_tower_build_state.source_shockwave_tower_update_tile_advance_state({"team_id": own_team, "potential_efficiency": 1.0, "reload_counter": 80.0, "heat": 0.5}, 1.0, reload_def, bullet_damage, falloff_count, cooldown_multiplier, [{"team": enemy_team, "hittable": true, "damage": 500.0, "x": 0.0, "y": 0.0}], false)
	# Charged with the timer ready but no potentialEfficiency:
	# no fire (the gate needs potentialEfficiency > 0).
	var no_power: Dictionary = shockwave_tower_build_state.source_shockwave_tower_update_tile_advance_state({"team_id": own_team, "potential_efficiency": 0.0, "reload_counter": 80.0, "heat": 0.5}, 1.0, reload_def, bullet_damage, falloff_count, cooldown_multiplier, [{"team": enemy_team, "hittable": true, "damage": 500.0, "x": 0.0, "y": 0.0}], true)
	# Charged with the timer ready and power, but no targets
	# in the box: the gate passes but nothing fires (the
	# `if(targets.size > 0){` guard, :81) and the counter is
	# NOT reset.
	var no_targets: Dictionary = shockwave_tower_build_state.source_shockwave_tower_update_tile_advance_state({"team_id": own_team, "potential_efficiency": 1.0, "reload_counter": 80.0, "heat": 0.5}, 1.0, reload_def, bullet_damage, falloff_count, cooldown_multiplier, [], true)
	# Charged with the timer ready, power, and a target:
	# fires, and the counter resets to 0.
	var fired_gate: Dictionary = shockwave_tower_build_state.source_shockwave_tower_update_tile_advance_state({"team_id": own_team, "potential_efficiency": 1.0, "reload_counter": 80.0, "heat": 0.5}, 1.0, reload_def, bullet_damage, falloff_count, cooldown_multiplier, [{"team": enemy_team, "hittable": true, "damage": 500.0, "x": 0.0, "y": 0.0}], true)
	proof["fire_gate_needs_charge_and_timer"] = bool(uncharged.get("fired", true)) == false and is_equal_approx(float(uncharged.get("reload_counter", -1.0)), 40.0) and bool(no_timer.get("fired", true)) == false and is_equal_approx(float(no_timer.get("reload_counter", -1.0)), 80.0) and bool(no_power.get("fired", true)) == false and bool(no_targets.get("fired", true)) == false and is_equal_approx(float(no_targets.get("reload_counter", -1.0)), 80.0) and bool(fired_gate.get("fired", false)) and is_equal_approx(float(fired_gate.get("reload_counter", -1.0)), 0.0)

	# --- Scan: only enemy hittable bullets become targets.
	# One enemy hittable (kept), one enemy non-hittable
	# (dropped), one friendly hittable (dropped).
	var scanned: Dictionary = shockwave_tower_build_state.source_shockwave_tower_update_tile_advance_state({"team_id": own_team, "potential_efficiency": 1.0, "reload_counter": 80.0, "heat": 0.0}, 1.0, reload_def, bullet_damage, falloff_count, cooldown_multiplier, [{"team": enemy_team, "hittable": true, "damage": 500.0, "x": 10.0, "y": 0.0}, {"team": enemy_team, "hittable": false, "damage": 500.0, "x": 20.0, "y": 0.0}, {"team": own_team, "hittable": true, "damage": 500.0, "x": 30.0, "y": 0.0}], true)
	var scanned_targets: Array = scanned.get("targets", [])
	proof["scan_filters_enemy_hittable"] = bool(scanned.get("fired", false)) and scanned_targets.size() == 1 and int(scanned_targets[0].get("team", -1)) == enemy_team and is_equal_approx(float(scanned_targets[0].get("x", -1.0)), 10.0)

	# --- Wave damage falloff: min(bulletDamage,
	# bulletDamage * falloffCount / targets.size). With 25
	# targets the wave is 160 * 20 / 25 = 128; with 2 targets
	# the falloff term is 1600, so the min caps at 160.
	var many_bullets: Array = []
	for index in range(25):
		many_bullets.append({"team": enemy_team, "hittable": true, "damage": 500.0, "x": float(index), "y": 0.0})
	var many: Dictionary = shockwave_tower_build_state.source_shockwave_tower_update_tile_advance_state({"team_id": own_team, "potential_efficiency": 1.0, "reload_counter": 80.0, "heat": 0.0}, 1.0, reload_def, bullet_damage, falloff_count, cooldown_multiplier, many_bullets, true)
	var few: Dictionary = shockwave_tower_build_state.source_shockwave_tower_update_tile_advance_state({"team_id": own_team, "potential_efficiency": 1.0, "reload_counter": 80.0, "heat": 0.0}, 1.0, reload_def, bullet_damage, falloff_count, cooldown_multiplier, [{"team": enemy_team, "hittable": true, "damage": 500.0, "x": 0.0, "y": 0.0}, {"team": enemy_team, "hittable": true, "damage": 500.0, "x": 1.0, "y": 0.0}], true)
	proof["wave_damage_falloff_formula"] = is_equal_approx(float(many.get("wave_damage", -1.0)), 128.0) and is_equal_approx(float(few.get("wave_damage", -1.0)), 160.0)

	# --- Remove boundary: with 25 targets the wave damage is
	# 128, so a 100-damage bullet is removed (100 < 128), a
	# 128-damage bullet is removed too (the strict > boundary),
	# and a 200-damage bullet survives with 200 - 128 = 72.
	var boundary_bullets: Array = []
	for index in range(22):
		boundary_bullets.append({"team": enemy_team, "hittable": true, "damage": 500.0, "x": float(index), "y": 0.0})
	boundary_bullets.append({"team": enemy_team, "hittable": true, "damage": 100.0, "x": 100.0, "y": 0.0})
	boundary_bullets.append({"team": enemy_team, "hittable": true, "damage": 128.0, "x": 101.0, "y": 0.0})
	boundary_bullets.append({"team": enemy_team, "hittable": true, "damage": 200.0, "x": 102.0, "y": 0.0})
	var boundary: Dictionary = shockwave_tower_build_state.source_shockwave_tower_update_tile_advance_state({"team_id": own_team, "potential_efficiency": 1.0, "reload_counter": 80.0, "heat": 0.0}, 1.0, reload_def, bullet_damage, falloff_count, cooldown_multiplier, boundary_bullets, true)
	var boundary_targets: Array = boundary.get("targets", [])
	var weak: Dictionary = boundary_targets[22]
	var exact: Dictionary = boundary_targets[23]
	var strong: Dictionary = boundary_targets[24]
	proof["target_removed_below_wave_damage"] = is_equal_approx(float(boundary.get("wave_damage", -1.0)), 128.0) and bool(weak.get("removed", false)) and bool(exact.get("removed", false)) and bool(strong.get("removed", true)) == false and is_equal_approx(float(strong.get("damage", -1.0)), 72.0)

	# --- Heat set on fire: heat starts 0.3, the fire sets it
	# to 1f, then the unconditional decay subtracts
	# Time.delta / reload * cooldownMultiplier = 1 / 80, so
	# the tick ends at 1 - 0.0125 = 0.9875.
	var fired_heat: Dictionary = shockwave_tower_build_state.source_shockwave_tower_update_tile_advance_state({"team_id": own_team, "potential_efficiency": 1.0, "reload_counter": 80.0, "heat": 0.3}, 1.0, reload_def, bullet_damage, falloff_count, cooldown_multiplier, [{"team": enemy_team, "hittable": true, "damage": 500.0, "x": 0.0, "y": 0.0}], true)
	proof["heat_set_on_fire"] = bool(fired_heat.get("fired", false)) and is_equal_approx(float(fired_heat.get("heat", -1.0)), 0.9875)

	# --- Heat decays every tick, unconditionally: with no
	# fire (uncharged counter, timer not ready), heat 0.5
	# decays by 1 / 80 to 0.4875; heat 0.001 clamps at 0
	# instead of going negative. The live tick decays too:
	# a placed tower's frame heat drops by the same 1 / 80
	# per 1/60s tick (the driver wires the advance after the
	# N2187 charge, with check_ready false and no candidates
	# until the timer / bullet-query slices land).
	var decayed: Dictionary = shockwave_tower_build_state.source_shockwave_tower_update_tile_advance_state({"team_id": own_team, "potential_efficiency": 1.0, "reload_counter": 0.0, "heat": 0.5}, 1.0, reload_def, bullet_damage, falloff_count, cooldown_multiplier, [], false)
	var clamped: Dictionary = shockwave_tower_build_state.source_shockwave_tower_update_tile_advance_state({"team_id": own_team, "potential_efficiency": 1.0, "reload_counter": 0.0, "heat": 0.001}, 1.0, reload_def, bullet_damage, falloff_count, cooldown_multiplier, [], false)
	var shockwave_tower_cell := Vector2i(28, 21)
	var shockwave_tower := Sprite2D.new()
	game.add_child(shockwave_tower)
	game.call("record_placed_block", shockwave_tower, blocks_by_id["shockwave-tower"], shockwave_tower_cell)
	shockwave_tower_build_state.source_shockwave_tower_bind_frame_state(shockwave_tower, blocks_by_id["shockwave-tower"])
	var shockwave_tower_frame: Dictionary = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	shockwave_tower_frame["reload_counter"] = 0.0
	shockwave_tower_frame["heat"] = 0.5
	shockwave_tower_frame["power_status"] = 1.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	proof["heat_decays_every_tick"] = bool(decayed.get("fired", true)) == false and is_equal_approx(float(decayed.get("heat", -1.0)), 0.4875) and is_equal_approx(float(clamped.get("heat", -1.0)), 0.0) and is_equal_approx(float(shockwave_tower_frame.get("heat", -1.0)), 0.4875)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
