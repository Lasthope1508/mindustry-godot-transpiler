extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_consume_liquids_generated_state := preload("res://src/game/SourceConsumeLiquidsGeneratedState.gd")
const source_consume_liquids_state := preload("res://src/game/SourceConsumeLiquidsState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var liquid_stacks := [
		{"liquid_id": 1, "amount": 2.0},
		{"liquid_id": 2, "amount": 3.0},
	]
	var liquid_ids := [1, 2]
	var liquid_stack_amounts := [2.0, 3.0]
	var liquid_amounts := [8.0, 9.0]
	var liquid_filter_before := [false, false, false]
	var build_edelta := 0.5
	var build_efficiency_scale := 1.25
	var multiplier_get_build := 2.0

	var constructor_wrapper := game.generated_consume_liquids_constructor_bridge_state(liquid_stacks)
	var constructor_module := source_consume_liquids_generated_state.generated_constructor_bridge_state(liquid_stacks)
	var default_constructor_wrapper := game.generated_consume_liquids_default_constructor_bridge_state()
	var default_constructor_module := source_consume_liquids_generated_state.generated_default_constructor_bridge_state(source_consume_liquids_state.SOURCE_CONSUME_LIQUIDS_EMPTY_STACKS)
	var apply_wrapper := game.generated_consume_liquids_apply_bridge_state(false, liquid_filter_before, liquid_ids)
	var apply_module := source_consume_liquids_generated_state.generated_apply_bridge_state(false, liquid_filter_before, liquid_ids)
	var build_wrapper := game.generated_consume_liquids_build_bridge_state(liquid_ids, liquid_stack_amounts)
	var build_module := source_consume_liquids_generated_state.generated_build_bridge_state(liquid_ids, liquid_stack_amounts)
	var update_wrapper := game.generated_consume_liquids_update_bridge_state(liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build)
	var update_module := source_consume_liquids_generated_state.generated_update_bridge_state(liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build)
	var efficiency_wrapper := game.generated_consume_liquids_efficiency_bridge_state(liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, build_efficiency_scale, multiplier_get_build)
	var efficiency_module := source_consume_liquids_generated_state.generated_efficiency_bridge_state(liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, build_efficiency_scale, multiplier_get_build)
	var display_wrapper := game.generated_consume_liquids_display_bridge_state(false, liquid_ids, liquid_stack_amounts)
	var display_module := source_consume_liquids_generated_state.generated_display_bridge_state(false, liquid_ids, liquid_stack_amounts, source_time_defaults.TICK_RATE)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeLiquidsGeneratedState",
		"constructor_bridge_matches": constructor_wrapper == constructor_module and bool(constructor_module.get("matches", false)),
		"default_constructor_bridge_matches": default_constructor_wrapper == default_constructor_module and bool(default_constructor_module.get("matches", false)),
		"apply_bridge_matches": apply_wrapper == apply_module and bool(apply_module.get("matches", false)),
		"build_bridge_matches": build_wrapper == build_module and bool(build_module.get("matches", false)),
		"update_bridge_matches": update_wrapper == update_module and bool(update_module.get("matches", false)),
		"efficiency_bridge_matches": efficiency_wrapper == efficiency_module and bool(efficiency_module.get("matches", false)),
		"display_bridge_matches": display_wrapper == display_module and bool(display_module.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["constructor_bridge_matches"] and proof["default_constructor_bridge_matches"] and proof["apply_bridge_matches"] and proof["build_bridge_matches"] and proof["update_bridge_matches"] and proof["efficiency_bridge_matches"] and proof["display_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONSUME_LIQUIDS_GENERATED_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ConsumeLiquidsGeneratedRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
