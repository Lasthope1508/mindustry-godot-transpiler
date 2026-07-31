extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_unit_tether_state := preload("res://src/game/SourceUnitTetherState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var after_read_bridge := game.generated_unit_tether_comp_after_read_bridge_state(77, {"unit": 77})
	var after_sync_bridge := game.generated_unit_tether_comp_after_sync_bridge_state(77, {"unit": 77})
	var update_bridge := game.generated_unit_tether_comp_update_bridge_state(true, true, "blue", "blue", 9, 77)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "UNIT_TETHER_STATE_MODULE_PROOF",
		"after_read_bridge": after_read_bridge,
		"after_sync_bridge": after_sync_bridge,
		"update_bridge": update_bridge,
		"after_read_bridge_matches": after_read_bridge == source_unit_tether_state.generated_unit_tether_comp_after_read_bridge_state(77, {"unit": 77}),
		"after_sync_bridge_matches": after_sync_bridge == source_unit_tether_state.generated_unit_tether_comp_after_sync_bridge_state(77, {"unit": 77}),
		"update_bridge_matches": update_bridge == source_unit_tether_state.generated_unit_tether_comp_update_bridge_state(true, true, "blue", "blue", 9, 77),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["after_read_bridge_matches"] and proof["after_sync_bridge_matches"] and proof["update_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("UNIT_TETHER_STATE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/UnitTetherStateModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
