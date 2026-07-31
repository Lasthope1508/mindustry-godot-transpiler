extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_reinitialize_consumers_state := preload("res://src/game/SourceBlockReinitializeConsumersState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var consume_builder := [
		{"type": "ConsumePower", "is_consume_power": true, "optional": false, "update": true},
		{"type": "ConsumeItems", "optional": true, "update": true},
		{"type": "ConsumeLiquid", "optional": false, "update": false},
		{"type": "IgnoredConsumer", "optional": true, "update": true, "ignored": true},
	]
	var consumers := [
		{"type": "ConsumePower", "id": "power"},
		{"type": "ConsumeItems", "id": "items"},
	]
	var arrays_bridge := game.generated_block_reinitialize_consumers_arrays_bridge_state(consume_builder)
	var item_liquid_filters_bridge := game.generated_block_reinitialize_consumers_item_liquid_filters_bridge_state(3, 2)
	var outputs_power_bridge := game.generated_block_reinitialize_consumers_outputs_power_bridge_state(true, false)
	var apply_loop_bridge := game.generated_block_reinitialize_consumers_apply_loop_bridge_state(consumers)
	var proof := {
		"module": "BLOCK_REINITIALIZE_CONSUMERS_MODULE_PROOF",
		"arrays_bridge": arrays_bridge,
		"item_liquid_filters_bridge": item_liquid_filters_bridge,
		"outputs_power_bridge": outputs_power_bridge,
		"apply_loop_bridge": apply_loop_bridge,
		"arrays_bridge_matches": arrays_bridge == source_block_reinitialize_consumers_state.generated_block_reinitialize_consumers_arrays_bridge_state(consume_builder),
		"item_liquid_filters_bridge_matches": item_liquid_filters_bridge == source_block_reinitialize_consumers_state.generated_block_reinitialize_consumers_item_liquid_filters_bridge_state(3, 2),
		"outputs_power_bridge_matches": outputs_power_bridge == source_block_reinitialize_consumers_state.generated_block_reinitialize_consumers_outputs_power_bridge_state(true, false),
		"apply_loop_bridge_matches": apply_loop_bridge == source_block_reinitialize_consumers_state.generated_block_reinitialize_consumers_apply_loop_bridge_state(consumers),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(arrays_bridge.get("matches", false)) and bool(item_liquid_filters_bridge.get("matches", false)) and bool(outputs_power_bridge.get("matches", false)) and bool(apply_loop_bridge.get("matches", false)) and proof["arrays_bridge_matches"] and proof["item_liquid_filters_bridge_matches"] and proof["outputs_power_bridge_matches"] and proof["apply_loop_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_REINITIALIZE_CONSUMERS_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockReinitializeConsumersModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
