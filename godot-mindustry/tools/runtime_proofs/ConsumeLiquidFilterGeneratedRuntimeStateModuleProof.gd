extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_consume_liquid_filter_generated_state := preload("res://src/game/SourceConsumeLiquidFilterGeneratedState.gd")
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_ui_defaults := preload("res://src/game/SourceUiDefaults.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var filter_handle := {"id": "coolant-filter"}
	var amount := 0.25
	var liquid_filter_before := [false, false, false]
	var filtered_liquid_ids := [1, 2]
	var consumed_liquid := 1
	var current_liquid := 2
	var current_filter_get_liquid := false
	var current_amount := 0.0
	var content_liquids := [0, 1, 2]
	var filter_get_liquid_flags := [false, true, false]
	var build_liquid_amounts := [0.0, 8.0, 0.0]
	var build_edelta := 0.5
	var multiplier_get_build := 2.0
	var build_liquids_get := 3.0
	var liquid_efficiency_multiplier := 1.25

	var constructor_wrapper := game.generated_consume_liquid_filter_constructor_bridge_state(filter_handle, amount)
	var constructor_module := source_consume_liquid_filter_generated_state.generated_constructor_bridge_state(filter_handle, amount)
	var default_constructor_wrapper := game.generated_consume_liquid_filter_default_constructor_bridge_state()
	var default_constructor_module := source_consume_liquid_filter_generated_state.generated_default_constructor_bridge_state(source_consumer_defaults.CONSUME_LIQUID_FILTER_DEFAULT_EXPR)
	var apply_wrapper := game.generated_consume_liquid_filter_apply_bridge_state(false, liquid_filter_before, filtered_liquid_ids)
	var apply_module := source_consume_liquid_filter_generated_state.generated_apply_bridge_state(false, liquid_filter_before, filtered_liquid_ids)
	var build_wrapper := game.generated_consume_liquid_filter_build_bridge_state(filtered_liquid_ids, consumed_liquid)
	var build_module := source_consume_liquid_filter_generated_state.generated_build_bridge_state(filtered_liquid_ids, consumed_liquid, source_ui_defaults.ICON_MED)
	var get_consumed_wrapper := game.generated_consume_liquid_filter_get_consumed_bridge_state(current_liquid, current_filter_get_liquid, current_amount, content_liquids, filter_get_liquid_flags, build_liquid_amounts)
	var get_consumed_module := source_consume_liquid_filter_generated_state.generated_get_consumed_bridge_state(current_liquid, current_filter_get_liquid, current_amount, content_liquids, filter_get_liquid_flags, build_liquid_amounts)
	var update_wrapper := game.generated_consume_liquid_filter_update_bridge_state(consumed_liquid, amount, build_edelta, multiplier_get_build)
	var update_module := source_consume_liquid_filter_generated_state.generated_update_bridge_state(consumed_liquid, amount, build_edelta, multiplier_get_build)
	var efficiency_wrapper := game.generated_consume_liquid_filter_efficiency_bridge_state(consumed_liquid, build_liquids_get, amount, build_edelta, multiplier_get_build)
	var efficiency_module := source_consume_liquid_filter_generated_state.generated_efficiency_bridge_state(consumed_liquid, build_liquids_get, amount, build_edelta, multiplier_get_build, source_consumer_defaults.CONSUME_EFFICIENCY_EPSILON)
	var efficiency_multiplier_wrapper := game.generated_consume_liquid_filter_efficiency_multiplier_bridge_state(consumed_liquid, liquid_efficiency_multiplier)
	var efficiency_multiplier_module := source_consume_liquid_filter_generated_state.generated_efficiency_multiplier_bridge_state(consumed_liquid, liquid_efficiency_multiplier)
	var liquid_efficiency_wrapper := game.generated_consume_liquid_filter_liquid_efficiency_multiplier_bridge_state()
	var liquid_efficiency_module := source_consume_liquid_filter_generated_state.generated_liquid_efficiency_multiplier_bridge_state()
	var display_wrapper := game.generated_consume_liquid_filter_display_bridge_state(false, amount, filtered_liquid_ids)
	var display_module := source_consume_liquid_filter_generated_state.generated_display_bridge_state(false, amount, filtered_liquid_ids, source_time_defaults.TICK_RATE)
	var consumes_wrapper := game.generated_consume_liquid_filter_consumes_bridge_state(true)
	var consumes_module := source_consume_liquid_filter_generated_state.generated_consumes_bridge_state(true)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeLiquidFilterGeneratedState",
		"constructor_bridge_matches": constructor_wrapper == constructor_module and bool(constructor_module.get("matches", false)),
		"default_constructor_bridge_matches": default_constructor_wrapper == default_constructor_module and bool(default_constructor_module.get("matches", false)),
		"apply_bridge_matches": apply_wrapper == apply_module and bool(apply_module.get("matches", false)),
		"build_bridge_matches": build_wrapper == build_module and bool(build_module.get("matches", false)),
		"get_consumed_bridge_matches": get_consumed_wrapper == get_consumed_module and bool(get_consumed_module.get("matches", false)),
		"update_bridge_matches": update_wrapper == update_module and bool(update_module.get("matches", false)),
		"efficiency_bridge_matches": efficiency_wrapper == efficiency_module and bool(efficiency_module.get("matches", false)),
		"efficiency_multiplier_bridge_matches": efficiency_multiplier_wrapper == efficiency_multiplier_module and bool(efficiency_multiplier_module.get("matches", false)),
		"liquid_efficiency_bridge_matches": liquid_efficiency_wrapper == liquid_efficiency_module and bool(liquid_efficiency_module.get("matches", false)),
		"display_bridge_matches": display_wrapper == display_module and bool(display_module.get("matches", false)),
		"consumes_bridge_matches": consumes_wrapper == consumes_module and bool(consumes_module.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["constructor_bridge_matches"] and proof["default_constructor_bridge_matches"] and proof["apply_bridge_matches"] and proof["build_bridge_matches"] and proof["get_consumed_bridge_matches"] and proof["update_bridge_matches"] and proof["efficiency_bridge_matches"] and proof["efficiency_multiplier_bridge_matches"] and proof["liquid_efficiency_bridge_matches"] and proof["display_bridge_matches"] and proof["consumes_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONSUME_LIQUID_FILTER_GENERATED_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ConsumeLiquidFilterGeneratedRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

