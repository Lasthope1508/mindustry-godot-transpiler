extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_consume_items_generated_state := preload("res://src/game/SourceConsumeItemsGeneratedState.gd")
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_ui_defaults := preload("res://src/game/SourceUiDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var item_stacks := [
		{"item_id": 1, "amount": 2.0},
		{"item_id": 2, "amount": 3.0},
	]
	var item_amounts := [0.0, 8.0, 9.0]
	var item_filter_before := [false, false, false]
	var multiplier_get_build := 2.0

	var constructor_wrapper := game.generated_consume_items_constructor_bridge_state(item_stacks)
	var constructor_module := source_consume_items_generated_state.generated_constructor_bridge_state(item_stacks)
	var default_constructor_wrapper := game.generated_consume_items_default_constructor_bridge_state()
	var default_constructor_module := source_consume_items_generated_state.generated_default_constructor_bridge_state(source_consumer_defaults.CONSUME_ITEMS_EMPTY_STACKS)
	var apply_wrapper := game.generated_consume_items_apply_bridge_state(false, false, item_filter_before, item_stacks)
	var apply_module := source_consume_items_generated_state.generated_apply_bridge_state(false, false, item_filter_before, item_stacks)
	var build_wrapper := game.generated_consume_items_build_bridge_state(item_stacks, item_amounts, multiplier_get_build)
	var build_module := source_consume_items_generated_state.generated_build_bridge_state(item_stacks, item_amounts, multiplier_get_build, source_ui_defaults.PAD_RIGHT)
	var trigger_wrapper := game.generated_consume_items_trigger_bridge_state(item_stacks, multiplier_get_build)
	var trigger_module := source_consume_items_generated_state.generated_trigger_bridge_state(item_stacks, multiplier_get_build)
	var efficiency_wrapper := game.generated_consume_items_efficiency_bridge_state(false, item_stacks, item_amounts, multiplier_get_build)
	var efficiency_module := source_consume_items_generated_state.generated_efficiency_bridge_state(false, item_stacks, item_amounts, multiplier_get_build)
	var display_wrapper := game.generated_consume_items_display_bridge_state(false, -1.0, item_stacks)
	var display_module := source_consume_items_generated_state.generated_display_bridge_state(false, -1.0, item_stacks)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeItemsGeneratedState",
		"constructor_bridge_matches": constructor_wrapper == constructor_module and bool(constructor_module.get("matches", false)),
		"default_constructor_bridge_matches": default_constructor_wrapper == default_constructor_module and bool(default_constructor_module.get("matches", false)),
		"apply_bridge_matches": apply_wrapper == apply_module and bool(apply_module.get("matches", false)),
		"build_bridge_matches": build_wrapper == build_module and bool(build_module.get("matches", false)),
		"trigger_bridge_matches": trigger_wrapper == trigger_module and bool(trigger_module.get("matches", false)),
		"efficiency_bridge_matches": efficiency_wrapper == efficiency_module and bool(efficiency_module.get("matches", false)),
		"display_bridge_matches": display_wrapper == display_module and bool(display_module.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["constructor_bridge_matches"] and proof["default_constructor_bridge_matches"] and proof["apply_bridge_matches"] and proof["build_bridge_matches"] and proof["trigger_bridge_matches"] and proof["efficiency_bridge_matches"] and proof["display_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONSUME_ITEMS_GENERATED_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ConsumeItemsGeneratedRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

