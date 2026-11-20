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

	# --- Turret shouldTurn() turn gate (N2337): TurretBuild.shouldTurn()
	# (Turret.java:669-671) returns true unless the turret is charging
	# a shot while its def forbids turning during charge:
	# `public boolean shouldTurn(){`
	# `return moveWhileCharging || !charging();`
	# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
	# (Turret.java:277). moveWhileCharging is the Turret def field
	# (`public boolean moveWhileCharging = true;`, Turret.java:80)
	# and arrives as the explicit bool move_while_charging; charging()
	# (Turret.java:715-717, `public boolean charging(){` /
	# `return queuedBullets > 0 && shoot.firstShotDelay > 0;`) is NOT
	# re-ported here -- the caller passes its result as the explicit
	# bool charging (remote N2269 owns charging(), dedup at merge).
	# The frame carries no tracked key for this predicate. NO driver
	# tick line: shouldTurn() is a predicate the updateTile() tick
	# driver reads (:595 `if(shouldTurn()){` before
	# turnToTarget(targetRot)). The proof calls the pure function with
	# synthetic frames (no live tick: shouldTurn is a pure predicate
	# over two bools).

	# Turns while charging when the def allows it: moveWhileCharging
	# true, charging true -> true.
	var charging_allowed: Dictionary = turret_build_state.source_turret_should_turn_state({}, true, true)
	proof["turns_while_charging_when_move_while_charging"] = bool(charging_allowed.get("should_turn", false))

	# Turns while not charging when the def allows it:
	# moveWhileCharging true, charging false -> true.
	var idle_allowed: Dictionary = turret_build_state.source_turret_should_turn_state({}, true, false)
	proof["turns_while_not_charging_when_move_while_charging"] = bool(idle_allowed.get("should_turn", false))

	# Turns while not charging even when the def forbids turning
	# during charge: moveWhileCharging false, charging false -> true
	# (the `!charging()` leg).
	var idle_forbidden: Dictionary = turret_build_state.source_turret_should_turn_state({}, false, false)
	proof["turns_while_not_charging_when_not_move_while_charging"] = bool(idle_forbidden.get("should_turn", false))

	# Does NOT turn while charging when the def forbids it:
	# moveWhileCharging false, charging true -> false (the only
	# false leg of the truth table).
	var charging_forbidden: Dictionary = turret_build_state.source_turret_should_turn_state({}, false, true)
	proof["does_not_turn_while_charging_when_not_move_while_charging"] = not bool(charging_forbidden.get("should_turn", true))

	# The result carries ONLY the one should_turn key: no frame echo,
	# no extra state.
	proof["returns_only_one_key"] = charging_allowed.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretShouldTurnProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
