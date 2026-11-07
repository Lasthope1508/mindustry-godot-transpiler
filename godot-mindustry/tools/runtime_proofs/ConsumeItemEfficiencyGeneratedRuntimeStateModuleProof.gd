extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_consume_item_efficiency_generated_state := preload("res://src/game/SourceConsumeItemEfficiencyGeneratedState.gd")
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var item := {"id": "coal"}
	var stats_time_period := 60.0
	var filtered_item_ids := [1, 2]
	var item_efficiency_multipliers := [1.25, 0.75]
	var item_duration_multipliers := [1.0, 2.0]
	var table_has_cells := true

	var constructor_wrapper := game.generated_consume_item_efficiency_constructor_bridge_state(item)
	var constructor_module := source_consume_item_efficiency_generated_state.generated_constructor_bridge_state(item)
	var default_constructor_wrapper := game.generated_consume_item_efficiency_default_constructor_bridge_state()
	var default_constructor_module := source_consume_item_efficiency_generated_state.generated_default_constructor_bridge_state(source_consumer_defaults.CONSUME_ITEM_FILTER_DEFAULT_EXPR)
	var display_wrapper := game.generated_consume_item_efficiency_display_bridge_state(false, stats_time_period, filtered_item_ids, item_efficiency_multipliers, item_duration_multipliers, table_has_cells)
	var display_module := source_consume_item_efficiency_generated_state.generated_display_bridge_state(false, stats_time_period, filtered_item_ids, item_efficiency_multipliers, item_duration_multipliers, table_has_cells, source_time_defaults.TICK_RATE)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeItemEfficiencyGeneratedState",
		"constructor_bridge_matches": constructor_wrapper == constructor_module and bool(constructor_module.get("matches", false)),
		"default_constructor_bridge_matches": default_constructor_wrapper == default_constructor_module and bool(default_constructor_module.get("matches", false)),
		"display_bridge_matches": display_wrapper == display_module and bool(display_module.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["constructor_bridge_matches"] and proof["default_constructor_bridge_matches"] and proof["display_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONSUME_ITEM_EFFICIENCY_GENERATED_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ConsumeItemEfficiencyGeneratedRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

