extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_consume_item_list_generated_state := preload("res://src/game/SourceConsumeItemListGeneratedState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var objects := [1, 1.5, 2, 0.75]
	var consumed_item := 2
	var item_multiplier_value := 0.75

	var set_multipliers_wrapper := game.generated_consume_item_list_set_multipliers_bridge_state(objects)
	var set_multipliers_module := source_consume_item_list_generated_state.generated_set_multipliers_bridge_state(objects)
	var efficiency_wrapper := game.generated_consume_item_list_efficiency_multiplier_bridge_state(consumed_item, item_multiplier_value)
	var efficiency_module := source_consume_item_list_generated_state.generated_efficiency_multiplier_bridge_state(consumed_item, item_multiplier_value)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeItemListGeneratedState",
		"set_multipliers_bridge_matches": set_multipliers_wrapper == set_multipliers_module and bool(set_multipliers_module.get("matches", false)),
		"efficiency_multiplier_bridge_matches": efficiency_wrapper == efficiency_module and bool(efficiency_module.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["set_multipliers_bridge_matches"] and proof["efficiency_multiplier_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONSUME_ITEM_LIST_GENERATED_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ConsumeItemListGeneratedRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

