extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_get_dependencies_state := preload("res://src/game/SourceBlockGetDependenciesState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var copper := {"id": 1, "name": "copper"}
	var lead := {"id": 2, "name": "lead"}
	var silicon := {"id": 3, "name": "silicon"}
	var requirements := [{"item": copper, "amount": 10}, {"item": lead, "amount": 5}]
	var consume_builder := [
		{"type": "ConsumePower", "optional": true},
		{"type": "ConsumeItems", "optional": false, "items": [{"item": silicon, "amount": 2}]},
	]
	var requirements_bridge := game.generated_block_get_dependencies_requirements_bridge_state(requirements)
	var optional_bridge := game.generated_block_get_dependencies_consume_builder_optional_bridge_state(requirements, consume_builder)
	var consume_items_bridge := game.generated_block_get_dependencies_consume_items_bridge_state(requirements, consume_builder)
	var proof := {
		"module": "SourceBlockGetDependenciesState",
		"requirements_bridge_matches": requirements_bridge == source_block_get_dependencies_state.generated_block_get_dependencies_requirements_bridge_state(requirements) and bool(requirements_bridge.get("matches", false)),
		"optional_bridge_matches": optional_bridge == source_block_get_dependencies_state.generated_block_get_dependencies_consume_builder_optional_bridge_state(requirements, consume_builder) and bool(optional_bridge.get("matches", false)),
		"consume_items_bridge_matches": consume_items_bridge == source_block_get_dependencies_state.generated_block_get_dependencies_consume_items_bridge_state(requirements, consume_builder) and bool(consume_items_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["requirements_bridge_matches"] and proof["optional_bridge_matches"] and proof["consume_items_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_GET_DEPENDENCIES_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockGetDependenciesModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
