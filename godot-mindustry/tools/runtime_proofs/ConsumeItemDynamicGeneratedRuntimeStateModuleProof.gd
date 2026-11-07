extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_consume_item_dynamic_generated_state := preload("res://src/game/SourceConsumeItemDynamicGeneratedState.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")
const source_consume_port_bridge_ui_defaults := preload("res://src/game/SourceUiDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var items := {"current": [1, 2], "next": [2, 3]}
	var current_item_ids := [1, 2]
	var next_item_ids := [2, 3]
	var item_ids := [1, 2]
	var item_stack_amounts := [2.0, 3.0]
	var item_amounts := [0.0, 8.0, 9.0]
	var multiplier_get_build := 2.0

	var constructor_wrapper := game.generated_consume_item_dynamic_constructor_bridge_state(items)
	var constructor_module := source_consume_item_dynamic_generated_state.generated_constructor_bridge_state(items)
	var apply_wrapper := game.generated_consume_item_dynamic_apply_bridge_state(false, false)
	var apply_module := source_consume_item_dynamic_generated_state.generated_apply_bridge_state(false, false)
	var build_wrapper := game.generated_consume_item_dynamic_build_bridge_state(current_item_ids, next_item_ids)
	var build_module := source_consume_item_dynamic_generated_state.generated_build_bridge_state(current_item_ids, next_item_ids)
	var rebuild_wrapper := game.generated_consume_item_dynamic_rebuild_bridge_state(item_ids, item_stack_amounts, item_amounts, true, multiplier_get_build)
	var rebuild_module := source_consume_item_dynamic_generated_state.generated_rebuild_bridge_state(item_ids, item_stack_amounts, item_amounts, true, multiplier_get_build, source_consume_port_bridge_ui_defaults.PAD_RIGHT)
	var trigger_wrapper := game.generated_consume_item_dynamic_trigger_bridge_state(item_ids, item_stack_amounts, multiplier_get_build)
	var trigger_module := source_consume_item_dynamic_generated_state.generated_trigger_bridge_state(item_ids, item_stack_amounts, multiplier_get_build)
	var efficiency_wrapper := game.generated_consume_item_dynamic_efficiency_bridge_state(false, item_ids, item_stack_amounts, item_amounts, multiplier_get_build)
	var efficiency_module := source_consume_item_dynamic_generated_state.generated_efficiency_bridge_state(false, item_ids, item_stack_amounts, item_amounts, multiplier_get_build)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeItemDynamicGeneratedState",
		"constructor_bridge_matches": constructor_wrapper == constructor_module and bool(constructor_module.get("matches", false)),
		"apply_bridge_matches": apply_wrapper == apply_module and bool(apply_module.get("matches", false)),
		"build_bridge_matches": build_wrapper == build_module and bool(build_module.get("matches", false)),
		"rebuild_bridge_matches": rebuild_wrapper == rebuild_module and bool(rebuild_module.get("matches", false)),
		"trigger_bridge_matches": trigger_wrapper == trigger_module and bool(trigger_module.get("matches", false)),
		"efficiency_bridge_matches": efficiency_wrapper == efficiency_module and bool(efficiency_module.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["constructor_bridge_matches"] and proof["apply_bridge_matches"] and proof["build_bridge_matches"] and proof["rebuild_bridge_matches"] and proof["trigger_bridge_matches"] and proof["efficiency_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONSUME_ITEM_DYNAMIC_GENERATED_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ConsumeItemDynamicGeneratedRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

