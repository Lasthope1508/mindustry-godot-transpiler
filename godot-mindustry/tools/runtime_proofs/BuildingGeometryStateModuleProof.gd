extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var hitbox_bridge := game.generated_building_comp_hitbox_bridge_state(10.0, 20.0, 2, 8.0)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_GEOMETRY_STATE_MODULE_PROOF",
		"hitbox_bridge": hitbox_bridge,
		"hitbox_bridge_matches": hitbox_bridge == source_block_geometry.generated_building_hitbox_bridge_state(10.0, 20.0, 2, 8.0),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["hitbox_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BUILDING_GEOMETRY_STATE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BuildingGeometryStateModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
