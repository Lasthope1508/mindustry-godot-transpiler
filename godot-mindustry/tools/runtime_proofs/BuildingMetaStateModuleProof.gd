extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_meta_state := preload("res://src/game/SourceBuildingMetaState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var cursor_state := source_building_meta_state.cursor_state(true, true)
	var health_changed_state := source_building_meta_state.health_changed_state(true, {"health": 10})
	var to_string_state := source_building_meta_state.to_string_state(5, 7, 9, "block")
	var to_string_bridge := game.generated_building_comp_to_string_bridge_state(5, 7, 9, "block")
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_META_STATE_MODULE_PROOF",
		"cursor_state": cursor_state,
		"health_changed_state": health_changed_state,
		"to_string_state": to_string_state,
		"to_string_bridge": to_string_bridge,
		"to_string_bridge_matches": to_string_bridge == source_building_meta_state.generated_to_string_bridge_state(5, 7, 9, "block"),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["to_string_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BUILDING_META_STATE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BuildingMetaStateModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
