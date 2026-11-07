extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_destruction_state := preload("res://src/game/SourceBuildingDestructionState.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_construct_block_state := preload("res://src/game/SourceConstructBlockState.gd")
const source_construct_block_generated_state := preload("res://src/game/SourceConstructBlockGeneratedState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_building_destruction_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_building_destruction_state.SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_KEY: Callable(game, source_building_destruction_state.SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_FALLBACK),
	}
	var override_callbacks := source_building_destruction_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_building_destruction_state.SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_KEY, Callable()) == Callable(self, "proof_random_seed_float_max")
	var destroyed_wrapper := game.source_building_after_destroyed_state(true, true, "sharded", 16.0, 24.0, 9)
	var destroyed_module := source_building_destruction_state.game_after_destroyed_state(game, true, true, "sharded", 16.0, 24.0, 9)
	var override_destroyed := source_building_destruction_state.game_after_destroyed_state(self, true, true, "sharded", 16.0, 24.0, 9)
	var primitive_override_destroyed := source_building_destruction_state.after_destroyed_state(true, true, "sharded", 16.0, 24.0, 9, Callable(self, "proof_random_seed_float_max"))
	var no_bullet_wrapper := game.source_building_after_destroyed_state(false, true, "sharded", 16.0, 24.0, 9)
	var no_bullet_module := source_building_destruction_state.game_after_destroyed_state(game, false, true, "sharded", 16.0, 24.0, 9)
	var begin_break_wrapper := game.generated_build_begin_break_bridge_state(true, true, 0.75, 2, false, 4, true, "builder")
	var begin_break_module := source_building_destruction_state.generated_build_begin_break_bridge_state(true, true, 0.75, 2, false, 4, true, "builder")
	var deconstruct_wrapper := game.generated_construct_block_deconstruct_finish_bridge_state(true, false, true, true, true, 0.9, 3, {"color": "crimson"})
	var deconstruct_module := source_construct_block_generated_state.generated_construct_block_deconstruct_finish_bridge_state(true, false, true, true, true, 0.9, 3, {"color": "crimson"})
	var construct_finish_wrapper := game.generated_construct_block_construct_finish_bridge_state(true, "floor", true, true, 0.8, 2, false, false, true, true, "builder", false, false, true, true, false, 1.1, 3, 125.0, 0, {"rotation": 1})
	var construct_finish_module := source_construct_block_generated_state.generated_construct_block_construct_finish_bridge_state(true, "floor", true, true, 0.8, 2, false, false, true, true, "builder", false, false, true, true, false, 1.1, 3, 125.0, 0, {"rotation": 1})
	var constructed_wrapper := game.generated_construct_block_constructed_bridge_state(true, "floor", true, true, 0.8, 2, false, false, true, true, "builder", false, false, true, true, false, 1.1, 3, 125.0, 0, {"rotation": 1}, true)
	var constructed_module := source_construct_block_generated_state.generated_construct_block_constructed_bridge_state(true, "floor", true, true, 0.8, 2, false, false, true, true, "builder", false, false, true, true, false, 1.1, 3, 125.0, 0, {"rotation": 1}, true)
	var static_helpers_wrapper := game.generated_construct_block_static_helpers_bridge_state(3, 6, 64, 96, true, 20, 1, 0.9, false, true)
	var static_helpers_module := source_construct_block_generated_state.generated_construct_block_static_helpers_bridge_state(3, 6, 64, 96, true, 20, 1, 0.9, false, true)
	var destroyed_rotation := float(destroyed_module.get("rotation", -1.0))
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingDestructionState",
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"rotation_matches": destroyed_rotation >= 0.0 and destroyed_rotation < source_math_defaults.FULL_CIRCLE_DEGREES,
		"after_destroyed_matches": destroyed_wrapper == destroyed_module,
		"override_after_destroyed_matches": override_destroyed == primitive_override_destroyed,
		"after_destroyed_no_bullet_matches": no_bullet_wrapper == no_bullet_module,
		"generated_build_begin_break_matches": begin_break_wrapper == begin_break_module,
		"generated_construct_block_deconstruct_finish_matches": deconstruct_wrapper == deconstruct_module,
		"generated_construct_block_construct_finish_matches": construct_finish_wrapper == construct_finish_module,
		"generated_construct_block_constructed_matches": constructed_wrapper == constructed_module,
		"generated_construct_block_static_helpers_matches": static_helpers_wrapper == static_helpers_module,
		"module_matches": destroyed_wrapper == destroyed_module and no_bullet_wrapper == no_bullet_module and begin_break_wrapper == begin_break_module and deconstruct_wrapper == deconstruct_module and construct_finish_wrapper == construct_finish_module and constructed_wrapper == constructed_module and static_helpers_wrapper == static_helpers_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["module_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["override_after_destroyed_matches"] and proof["rotation_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_DESTRUCTION_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingDestructionStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

func proof_random_seed_float_max(source_seed: int, max_value: float) -> float:
	return float(source_seed % int(max_value))

func _building_destruction_method_names() -> Dictionary:
	return {
		source_building_destruction_state.SOURCE_BUILDING_DESTRUCTION_RANDOM_SEED_FLOAT_MAX_KEY: "proof_random_seed_float_max",
	}

