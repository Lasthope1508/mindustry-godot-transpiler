extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_consume_item_filter_generated_state := preload("res://src/game/SourceConsumeItemFilterGeneratedState.gd")
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_ui_defaults := preload("res://src/game/SourceUiDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var item := {"id": 7, "name": "copper"}
	var item_filter_before := [false, false, false]
	var filtered_item_ids := [1, 2]
	var build_items_has_item_flags := [false, true]
	var build_state := {"items": {"copper": 2}}
	var content_items := ["lead", "copper", "coal"]
	var content_has_flags := [false, true, true]
	var filter_get_flags := [false, true, false]
	var consumed_item := "copper"
	var item_efficiency_multiplier := 1.5

	var constructor_wrapper := game.generated_consume_item_filter_constructor_bridge_state(item)
	var constructor_module := source_consume_item_filter_generated_state.generated_constructor_bridge_state(item)
	var default_constructor_wrapper := game.generated_consume_item_filter_default_constructor_bridge_state()
	var default_constructor_module := source_consume_item_filter_generated_state.generated_default_constructor_bridge_state(source_consumer_defaults.CONSUME_ITEM_FILTER_DEFAULT_EXPR)
	var item_efficiency_wrapper := game.generated_consume_item_filter_item_efficiency_multiplier_bridge_state()
	var item_efficiency_module := source_consume_item_filter_generated_state.generated_item_efficiency_multiplier_bridge_state()
	var apply_wrapper := game.generated_consume_item_filter_apply_bridge_state(false, false, item_filter_before, filtered_item_ids)
	var apply_module := source_consume_item_filter_generated_state.generated_apply_bridge_state(false, false, item_filter_before, filtered_item_ids)
	var build_wrapper := game.generated_consume_item_filter_build_bridge_state(filtered_item_ids, build_items_has_item_flags)
	var build_module := source_consume_item_filter_generated_state.generated_build_bridge_state(filtered_item_ids, build_items_has_item_flags, source_ui_defaults.ICON_MED)
	var update_wrapper := game.generated_consume_item_filter_update_bridge_state(build_state)
	var update_module := source_consume_item_filter_generated_state.generated_update_bridge_state(build_state)
	var trigger_wrapper := game.generated_consume_item_filter_trigger_bridge_state(build_state, consumed_item)
	var trigger_module := source_consume_item_filter_generated_state.generated_trigger_bridge_state(build_state, consumed_item)
	var efficiency_wrapper := game.generated_consume_item_filter_efficiency_bridge_state(false, consumed_item)
	var efficiency_module := source_consume_item_filter_generated_state.generated_efficiency_bridge_state(false, consumed_item)
	var get_consumed_wrapper := game.generated_consume_item_filter_get_consumed_bridge_state(content_items, content_has_flags, filter_get_flags)
	var get_consumed_module := source_consume_item_filter_generated_state.generated_get_consumed_bridge_state(content_items, content_has_flags, filter_get_flags)
	var display_wrapper := game.generated_consume_item_filter_display_bridge_state(false, -1.0, filtered_item_ids)
	var display_module := source_consume_item_filter_generated_state.generated_display_bridge_state(false, -1.0, filtered_item_ids)
	var efficiency_multiplier_wrapper := game.generated_consume_item_filter_efficiency_multiplier_bridge_state(consumed_item, item_efficiency_multiplier)
	var efficiency_multiplier_module := source_consume_item_filter_generated_state.generated_efficiency_multiplier_bridge_state(consumed_item, item_efficiency_multiplier)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeItemFilterGeneratedState",
		"constructor_bridge_matches": constructor_wrapper == constructor_module and bool(constructor_module.get("matches", false)),
		"default_constructor_bridge_matches": default_constructor_wrapper == default_constructor_module and bool(default_constructor_module.get("matches", false)),
		"item_efficiency_bridge_matches": item_efficiency_wrapper == item_efficiency_module and bool(item_efficiency_module.get("matches", false)),
		"apply_bridge_matches": apply_wrapper == apply_module and bool(apply_module.get("matches", false)),
		"build_bridge_matches": build_wrapper == build_module and bool(build_module.get("matches", false)),
		"update_bridge_matches": update_wrapper == update_module and bool(update_module.get("matches", false)),
		"trigger_bridge_matches": trigger_wrapper == trigger_module and bool(trigger_module.get("matches", false)),
		"efficiency_bridge_matches": efficiency_wrapper == efficiency_module and bool(efficiency_module.get("matches", false)),
		"get_consumed_bridge_matches": get_consumed_wrapper == get_consumed_module and bool(get_consumed_module.get("matches", false)),
		"display_bridge_matches": display_wrapper == display_module and bool(display_module.get("matches", false)),
		"efficiency_multiplier_bridge_matches": efficiency_multiplier_wrapper == efficiency_multiplier_module and bool(efficiency_multiplier_module.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["constructor_bridge_matches"] and proof["default_constructor_bridge_matches"] and proof["item_efficiency_bridge_matches"] and proof["apply_bridge_matches"] and proof["build_bridge_matches"] and proof["update_bridge_matches"] and proof["trigger_bridge_matches"] and proof["efficiency_bridge_matches"] and proof["get_consumed_bridge_matches"] and proof["display_bridge_matches"] and proof["efficiency_multiplier_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONSUME_ITEM_FILTER_GENERATED_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ConsumeItemFilterGeneratedRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

