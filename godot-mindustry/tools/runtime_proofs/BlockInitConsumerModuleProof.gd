extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_init_consumer_state := preload("res://src/game/SourceBlockInitConsumerState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var consumer_builder_entries := [
		{"id": "ore", "optional": true, "update": true, "ignored": false},
		{"id": "power", "optional": false, "update": false, "ignored": false},
		{"id": "skip", "optional": true, "update": true, "ignored": true},
	]
	var consumer_entries := [
		{"id": "ore", "optional": true, "update": true, "ignored": false},
		{"id": "power", "optional": false, "update": false, "ignored": false},
		{"id": "skip", "optional": true, "update": true, "ignored": true},
	]
	var arrays_bridge := game.generated_block_init_consumer_arrays_bridge_state(consumer_builder_entries)
	var apply_loop_bridge := game.generated_block_init_consumer_apply_loop_bridge_state(consumer_entries)
	var module_arrays_bridge := source_block_init_consumer_state.generated_consumer_arrays_bridge_state(consumer_builder_entries)
	var module_apply_loop_bridge := source_block_init_consumer_state.generated_consumer_apply_loop_bridge_state(consumer_entries)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_INIT_CONSUMER_MODULE_PROOF",
		"arrays_bridge": arrays_bridge,
		"apply_loop_bridge": apply_loop_bridge,
		"module_arrays_bridge": module_arrays_bridge,
		"module_apply_loop_bridge": module_apply_loop_bridge,
		"arrays_bridge_matches": arrays_bridge == module_arrays_bridge,
		"apply_loop_bridge_matches": apply_loop_bridge == module_apply_loop_bridge,
		"arrays_bridge_subset_matches": bool(arrays_bridge.get("matches", false)),
		"apply_loop_bridge_subset_matches": bool(apply_loop_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["arrays_bridge_matches"] and proof["apply_loop_bridge_matches"] and proof["arrays_bridge_subset_matches"] and proof["apply_loop_bridge_subset_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockInitConsumerModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
