extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_init_building_default_state := preload("res://src/game/SourceBlockInitBuildingDefaultState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var default_bridge := game.generated_block_init_building_default_bridge_state(null)
	var existing_bridge := game.generated_block_init_building_default_bridge_state("CustomBuildingFactory")
	var proof := {
		"module": "BLOCK_INIT_BUILDING_DEFAULT_MODULE_PROOF",
		"default_bridge": default_bridge,
		"existing_bridge": existing_bridge,
		"default_bridge_matches": default_bridge == source_block_init_building_default_state.generated_block_init_building_default_bridge_state(null),
		"existing_bridge_matches": existing_bridge == source_block_init_building_default_state.generated_block_init_building_default_bridge_state("CustomBuildingFactory"),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(default_bridge.get("matches", false)) and bool(existing_bridge.get("matches", false)) and proof["default_bridge_matches"] and proof["existing_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_INIT_BUILDING_DEFAULT_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockInitBuildingDefaultModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.flush()
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
