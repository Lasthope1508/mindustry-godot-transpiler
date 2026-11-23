extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- TurretBuild.findTarget() / findEnemy() / validateTarget() / canHeal() (N2316):
	# TurretBuild.findTarget() / findEnemy() / validateTarget() /
	# canHeal() (Turret.java:631-663): validateTarget returns
	# `!Units.invalidateTarget(target, canHeal() ? Team.derelict :
	# team, x, y) || controlled() || logicControlled();` (:632);
	# canHeal returns `targetHealing && hasAmmo() &&
	# peekAmmo().collidesTeam && peekAmmo().heals();` (:636);
	# findEnemy picks the air-only Units.bestEnemy branch when
	# `targetAir && !targetGround` (:640-641) and otherwise
	# Units.bestTarget with the buildings / missiles flags (:644-647);
	# findTarget tries findEnemy(range), then findEnemy(trackRange)
	# only when `!Mathf.equal(trackRange, range)` and no target yet,
	# then Units.findAllyTile when still null and canHeal() (:651-663).
	# All selection runs on observed dicts (the N2242 precedent):
	# the live Units queries stay on the driver side, so the proof
	# checks the pure selection only -- no live Units query is proven
	# here. There is no driver tick line: updateTile calls
	# findTarget() at :570 and validateTarget() at :491/:573 -- the
	# driver is its own later slice.

	# A valid target validates even uncontrolled: the invalidation
	# is false, so the `!invalidateTarget` leg holds.
	var valid_target: Dictionary = turret_build_state.source_turret_validate_target_state({}, false, false, false)
	proof["validate_target_valid"] = bool(valid_target.get("validate_target", false)) == true

	# An invalid target fails when neither a player nor logic
	# controls the turret.
	var invalid_uncontrolled: Dictionary = turret_build_state.source_turret_validate_target_state({}, true, false, false)
	proof["validate_target_invalid_uncontrolled"] = bool(invalid_uncontrolled.get("validate_target", true)) == false

	# An invalid target still validates while a player controls
	# the turret (the controlled() leg of :632).
	var invalid_controlled: Dictionary = turret_build_state.source_turret_validate_target_state({}, true, true, false)
	proof["validate_target_invalid_controlled"] = bool(invalid_controlled.get("validate_target", false)) == true

	# invalidateTarget with range Float.MAX_VALUE drops the
	# within-range branch (Units.java:160-162): a null target and a
	# same-team target are both invalid.
	var invalid_null: Dictionary = turret_build_state.source_turret_invalidate_target_state({}, true, false, false, false)
	var invalid_same_team: Dictionary = turret_build_state.source_turret_invalidate_target_state({}, false, true, false, false)
	proof["invalidate_target_null_and_same_team"] = bool(invalid_null.get("target_invalid", false)) == true and bool(invalid_same_team.get("target_invalid", false)) == true

	# canHeal is false when targetHealing is off, even with ammo
	# and a healing peeked bullet.
	var heal_off: Dictionary = turret_build_state.source_turret_can_heal_state({}, false, true, true, true)
	proof["can_heal_false_target_healing_off"] = bool(heal_off.get("can_heal", true)) == false

	# canHeal is true only with every gate on: targetHealing,
	# hasAmmo, collidesTeam and heals.
	var heal_on: Dictionary = turret_build_state.source_turret_can_heal_state({}, true, true, true, true)
	proof["can_heal_true_all_gates"] = bool(heal_on.get("can_heal", false)) == true

	# Air-only branch (targetAir, not targetGround): a grounded
	# unit is skipped even though it is closer; the flying unit
	# farther out wins.
	var grounded_unit: Dictionary = {"id": "grounded", "dead": false, "team_is_derelict": false, "within_range": true, "targetable": true, "in_fog": false, "unit_filter": true, "is_grounded": true, "is_timed_kill": false, "dst2": 100.0, "target_priority": 0.0, "hit_size": 16.0}
	var flyer_unit: Dictionary = {"id": "flyer", "dead": false, "team_is_derelict": false, "within_range": true, "targetable": true, "in_fog": false, "unit_filter": true, "is_grounded": false, "is_timed_kill": false, "dst2": 400.0, "target_priority": 0.0, "hit_size": 16.0}
	var air_only_found: Variant = turret_build_state.source_turret_find_enemy_state({}, false, 200.0, true, false, true, true, true, true, [grounded_unit, flyer_unit], []).get("target", null)
	proof["find_enemy_air_only_skips_grounded"] = air_only_found is Dictionary and str(air_only_found.get("id", "")) == "flyer"

	# General branch with a non-missile ammo: a timed-kill unit is
	# skipped (missiles is false), so the farther normal unit wins
	# over the nearer building -- units are checked before buildings
	# (Units.bestTarget, Units.java:284-294).
	var missile_unit: Dictionary = {"id": "missile", "dead": false, "team_is_derelict": false, "within_range": true, "targetable": true, "in_fog": false, "unit_filter": true, "is_grounded": true, "is_timed_kill": true, "dst2": 100.0, "target_priority": 0.0, "hit_size": 16.0}
	var grunt_unit: Dictionary = {"id": "grunt", "dead": false, "team_is_derelict": false, "within_range": true, "targetable": true, "in_fog": false, "unit_filter": true, "is_grounded": true, "is_timed_kill": false, "dst2": 900.0, "target_priority": 0.0, "hit_size": 16.0}
	var wall_building: Dictionary = {"id": "wall", "building_filter": true, "dst2": 400.0, "hit_size": 16.0, "priority": 1.0}
	var units_first_found: Variant = turret_build_state.source_turret_find_enemy_state({}, false, 200.0, true, true, true, false, true, false, [missile_unit, grunt_unit], [wall_building]).get("target", null)
	proof["find_enemy_units_before_buildings"] = units_first_found is Dictionary and str(units_first_found.get("id", "")) == "grunt"

	# The targetPriority tie-break (Units.java:329-334): a farther
	# higher-priority unit beats a closer lower-priority one -- the
	# `>=` gate keeps the lower-priority unit from displacing it
	# even at a shorter cost.
	var close_unit: Dictionary = {"id": "close", "dead": false, "team_is_derelict": false, "within_range": true, "targetable": true, "in_fog": false, "unit_filter": true, "is_grounded": true, "is_timed_kill": false, "dst2": 100.0, "target_priority": 0.0, "hit_size": 16.0}
	var far_priority_unit: Dictionary = {"id": "priority", "dead": false, "team_is_derelict": false, "within_range": true, "targetable": true, "in_fog": false, "unit_filter": true, "is_grounded": true, "is_timed_kill": false, "dst2": 10000.0, "target_priority": 5.0, "hit_size": 16.0}
	var priority_found: Variant = turret_build_state.source_turret_find_enemy_state({}, false, 200.0, true, true, true, true, true, true, [close_unit, far_priority_unit], []).get("target", null)
	proof["find_enemy_priority_beats_distance"] = priority_found is Dictionary and str(priority_found.get("id", "")) == "priority"

	# findTarget falls back to the tracking range when the standard
	# range found nothing and the ranges differ.
	var tracked: Dictionary = {"id": "tracked"}
	var track_fallback: Variant = turret_build_state.source_turret_find_target_state({}, 100.0, 200.0, null, tracked, false, null).get("target", null)
	proof["find_target_falls_back_to_track_range"] = track_fallback is Dictionary and str(track_fallback.get("id", "")) == "tracked"

	# findTarget falls back to an ally tile when both ranges found
	# nothing, the ranges are equal (so the track leg is skipped)
	# and canHeal holds; a standard target is kept when present.
	var ally: Dictionary = {"id": "ally"}
	var standard: Dictionary = {"id": "standard"}
	var ally_fallback: Variant = turret_build_state.source_turret_find_target_state({}, 100.0, 100.0, null, null, true, ally).get("target", null)
	var standard_kept: Variant = turret_build_state.source_turret_find_target_state({}, 100.0, 100.0, standard, null, true, ally).get("target", null)
	proof["find_target_falls_back_to_ally_tile"] = ally_fallback is Dictionary and str(ally_fallback.get("id", "")) == "ally" and standard_kept is Dictionary and str(standard_kept.get("id", "")) == "standard"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretFindTargetProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
