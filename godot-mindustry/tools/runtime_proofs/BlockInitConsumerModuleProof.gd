extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_init_consumer_state := preload("res://src/game/SourceBlockInitConsumerState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

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
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
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
	var proof_json := JSON.stringify(proof)
	print("BLOCK_INIT_CONSUMER_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockInitConsumerModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.flush()
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
