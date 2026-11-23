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

	# --- TurretBuild.findEnemy() ammo binding + bestTarget opener (N2425):
	# TurretBuild.findEnemy() (Turret.java:639-649): the else branch
	# binds the peeked ammo and calls Units.bestTarget:
	# `var ammo = peekAmmo();` (:643) and
	# `return Units.bestTarget(team, x, y, range,` (:645, opener of
	# the multi-line call). The binding arrives as the three ammo
	# flags (ammo_is_null / ammo_target_blocks /
	# ammo_target_missiles), which the driver derives from the
	# peekAmmo() result (N2329 owns peekAmmo); the call itself is
	# the unit loop (units first, bestEnemy) plus the building
	# fallback (findEnemyTile) that source_turret_find_enemy_state
	# (N2316) already implements. This proof checks only the two
	# newly-owned behaviours: a null ammo makes both missiles and
	# buildings true, and bestTarget checks units before buildings
	# (Units.java:284-294). No live Units query is proven here.

	# A null ammo makes missiles true (Turret.java:644, `missiles =
	# ammo == null || ammo.targetMissiles`): a timed-kill unit is
	# eligible and chosen even though it would be skipped with a
	# non-missile ammo.
	var timed_unit: Dictionary = {"id": "timed", "dead": false, "team_is_derelict": false, "within_range": true, "targetable": true, "in_fog": false, "unit_filter": true, "is_grounded": true, "is_timed_kill": true, "dst2": 100.0, "target_priority": 0.0, "hit_size": 16.0}
	var timed_found: Variant = turret_build_state.source_turret_find_enemy_state({}, false, 200.0, true, true, true, true, true, true, [timed_unit], []).get("target", null)
	proof["ammo_null_missiles_true"] = timed_found is Dictionary and str(timed_found.get("id", "")) == "timed"

	# A null ammo makes buildings true (Turret.java:644, `buildings
	# = targetGround && targetBlocks && (ammo == null ||
	# ammo.targetBlocks)`): with no passing unit, the building
	# fallback finds the building.
	var wall_building: Dictionary = {"id": "wall", "building_filter": true, "dst2": 400.0, "hit_size": 16.0, "priority": 1.0}
	var wall_found: Variant = turret_build_state.source_turret_find_enemy_state({}, false, 200.0, true, true, true, true, true, true, [], [wall_building]).get("target", null)
	proof["ammo_null_buildings_true"] = wall_found is Dictionary and str(wall_found.get("id", "")) == "wall"

	# A non-null ammo with targetBlocks false closes the building
	# fallback (buildings is false): with no passing unit, the
	# target stays null.
	var no_building: Variant = turret_build_state.source_turret_find_enemy_state({}, false, 200.0, true, true, true, false, false, true, [], [wall_building]).get("target", null)
	proof["ammo_target_blocks_false_no_building"] = no_building == null

	# bestTarget checks units first (Units.java:287-289): with a
	# passing unit and a building candidate, the unit wins even
	# though the building is closer.
	var grunt_unit: Dictionary = {"id": "grunt", "dead": false, "team_is_derelict": false, "within_range": true, "targetable": true, "in_fog": false, "unit_filter": true, "is_grounded": true, "is_timed_kill": false, "dst2": 900.0, "target_priority": 0.0, "hit_size": 16.0}
	var unit_first: Variant = turret_build_state.source_turret_find_enemy_state({}, false, 200.0, true, true, true, false, true, true, [grunt_unit], [wall_building]).get("target", null)
	proof["best_target_unit_before_building"] = unit_first is Dictionary and str(unit_first.get("id", "")) == "grunt"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretFindEnemyProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
