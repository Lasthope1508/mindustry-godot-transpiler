extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_turret_simulation_state := preload("res://src/game/SourceTurretSimulationState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _turret_simulation_method_names() -> Dictionary:
	return {
		source_turret_simulation_state.SOURCE_TURRET_SIMULATION_RANGE_FOR_AMMO_KEY: "_proof_range_for_ammo",
	}

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_turret_simulation_state.simulation_callbacks(game)
	var override_callbacks := source_turret_simulation_state.simulation_callbacks(self)
	var override_callbacks_match: bool = override_callbacks.get(source_turret_simulation_state.SOURCE_TURRET_SIMULATION_RANGE_FOR_AMMO_KEY, Callable()) == Callable(self, "_proof_range_for_ammo")
	var context := {
		"game": game,
		"cell": Vector2i.ZERO,
		"key": "0,0",
		"turret": {"properties": {}},
		"seconds": 0.1,
		"callbacks": callbacks,
		"data": {},
		"current_rotation": 0.0,
		"cooldown": 0.0,
	}
	var fire_from_context := source_turret_simulation_state.turret_fire_from_context(context)
	var fire_state := source_turret_simulation_state.turret_fire_state(Vector2i.ZERO, 0.1, {"properties": {}}, 0.0, 0.0, {}, callbacks, 60.0)
	var shot_context := source_turret_simulation_state.turret_shot_context(Vector2i.ZERO, {"properties": {}}, {}, null, 0.0, 0.0, callbacks)
	var shot_application := source_turret_simulation_state.turret_shot_application_state(shot_context, fire_from_context, 0.0, 0.0)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "TURRET_SIMULATION_MODULE_PROOF",
		"summary_matches": game != null,
		"callbacks_match": callbacks.has(source_turret_simulation_state.SOURCE_TURRET_SIMULATION_FIND_ENEMY_TARGET_KEY),
		"override_callbacks_match": override_callbacks_match,
		"fire_from_context_matches": fire_from_context.has("range_pixels"),
		"fire_state_matches": fire_state.has("range_pixels"),
		"shot_context_matches": shot_context.has("shoot_angle_degrees"),
		"shot_application_matches": shot_application.has("cooldown_after_fire"),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["summary_matches"] and proof["callbacks_match"] and proof["override_callbacks_match"] and proof["fire_from_context_matches"] and proof["fire_state_matches"] and proof["shot_context_matches"] and proof["shot_application_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("TURRET_SIMULATION_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("TurretSimulationModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

func _proof_range_for_ammo(turret, data: Dictionary) -> float:
	return source_turret_simulation_state.turret_fire_state(Vector2i.ZERO, 0.0, turret, 0.0, 0.0, data, {}, 60.0).size()

