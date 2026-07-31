extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_sense_state := preload("res://src/game/SourceBlockSenseState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var laccess_bridge := game.generated_block_sense_laccess_bridge_state("health", 1.5, 80.0, true, 4, 12, 5.5, true, true, 9.0, 7)
	var content_item := {"id": 11, "name": "copper"}
	var requirements := [{"item": content_item, "amount": 6}]
	var content_bridge := game.generated_block_sense_content_bridge_state("Item", content_item, false, requirements, 1.25)
	var object_bridge := game.generated_block_sense_object_bridge_state("name", "block-name", "no-sensed")
	var proof := {
		"module": "BLOCK_SENSE_MODULE_PROOF",
		"laccess_bridge": laccess_bridge,
		"content_bridge": content_bridge,
		"object_bridge": object_bridge,
		"laccess_bridge_matches": laccess_bridge == source_block_sense_state.generated_block_sense_laccess_bridge_state("health", 1.5, 80.0, true, 4, 12, 5.5, true, true, 9.0, 7),
		"content_bridge_matches": content_bridge == source_block_sense_state.generated_block_sense_content_bridge_state("Item", content_item, false, requirements, 1.25),
		"object_bridge_matches": object_bridge == source_block_sense_state.generated_block_sense_object_bridge_state("name", "block-name", "no-sensed"),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(laccess_bridge.get("matches", false)) and bool(content_bridge.get("matches", false)) and bool(object_bridge.get("matches", false)) and proof["laccess_bridge_matches"] and proof["content_bridge_matches"] and proof["object_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_SENSE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockSenseModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
