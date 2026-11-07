extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_consume_liquid_generated_state := preload("res://src/game/SourceConsumeLiquidGeneratedState.gd")
const source_consume_liquid_state := preload("res://src/game/SourceConsumeLiquidState.gd")
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_ui_defaults := preload("res://src/game/SourceUiDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var liquid := {"id": 1, "name": "water"}
	var liquid_id := 1
	var amount := 0.75
	var build_liquids_get := 2.0
	var block_has_liquids_before := false
	var liquid_filter_before := [false, false, false]
	var build_edelta := 0.5
	var build_efficiency_scale := 1.25
	var multiplier_get_build := 2.0
	var liquid_matches_self_liquid := true
	var base_apply_state_provider: Callable = source_consume_liquid_state.default_callbacks_state(game).get(source_consume_liquid_state.SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE_KEY, Callable())

	var constructor_wrapper := game.generated_consume_liquid_constructor_bridge_state(liquid, amount)
	var constructor_module := source_consume_liquid_generated_state.generated_constructor_bridge_state(liquid, amount)
	var default_constructor_wrapper := game.generated_consume_liquid_default_constructor_bridge_state()
	var default_constructor_module := source_consume_liquid_generated_state.generated_default_constructor_bridge_state(source_consumer_defaults.CONSUME_LIQUID_DEFAULT_LIQUID, source_consumer_defaults.CONSUME_LIQUID_DEFAULT_AMOUNT)
	var apply_wrapper := game.generated_consume_liquid_apply_bridge_state(block_has_liquids_before, liquid_filter_before, liquid_id)
	var apply_module := source_consume_liquid_generated_state.generated_apply_bridge_state(block_has_liquids_before, liquid_filter_before, liquid_id, base_apply_state_provider)
	var build_wrapper := game.generated_consume_liquid_build_bridge_state(liquid_id, build_liquids_get)
	var build_module := source_consume_liquid_generated_state.generated_build_bridge_state(liquid_id, build_liquids_get, source_ui_defaults.ICON_MED)
	var display_wrapper := game.generated_consume_liquid_display_bridge_state(false, liquid_id, amount)
	var display_module := source_consume_liquid_generated_state.generated_display_bridge_state(false, liquid_id, amount, source_time_defaults.TICK_RATE)
	var update_wrapper := game.generated_consume_liquid_update_bridge_state(liquid_id, amount, build_edelta, multiplier_get_build)
	var update_module := source_consume_liquid_generated_state.generated_update_bridge_state(liquid_id, amount, build_edelta, multiplier_get_build)
	var efficiency_wrapper := game.generated_consume_liquid_efficiency_bridge_state(build_liquids_get, amount, build_edelta, build_efficiency_scale, multiplier_get_build)
	var efficiency_module := source_consume_liquid_generated_state.generated_efficiency_bridge_state(build_liquids_get, amount, build_edelta, build_efficiency_scale, multiplier_get_build)
	var consumes_wrapper := game.generated_consume_liquid_consumes_bridge_state(liquid_matches_self_liquid)
	var consumes_module := source_consume_liquid_generated_state.generated_consumes_bridge_state(liquid_matches_self_liquid)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeLiquidGeneratedState",
		"constructor_bridge_matches": constructor_wrapper == constructor_module and bool(constructor_module.get("matches", false)),
		"default_constructor_bridge_matches": default_constructor_wrapper == default_constructor_module and bool(default_constructor_module.get("matches", false)),
		"apply_bridge_matches": apply_wrapper == apply_module and bool(apply_module.get("matches", false)),
		"build_bridge_matches": build_wrapper == build_module and bool(build_module.get("matches", false)),
		"display_bridge_matches": display_wrapper == display_module and bool(display_module.get("matches", false)),
		"update_bridge_matches": update_wrapper == update_module and bool(update_module.get("matches", false)),
		"efficiency_bridge_matches": efficiency_wrapper == efficiency_module and bool(efficiency_module.get("matches", false)),
		"consumes_bridge_matches": consumes_wrapper == consumes_module and bool(consumes_module.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["constructor_bridge_matches"] and proof["default_constructor_bridge_matches"] and proof["apply_bridge_matches"] and proof["build_bridge_matches"] and proof["display_bridge_matches"] and proof["update_bridge_matches"] and proof["efficiency_bridge_matches"] and proof["consumes_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONSUME_LIQUID_GENERATED_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ConsumeLiquidGeneratedRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
