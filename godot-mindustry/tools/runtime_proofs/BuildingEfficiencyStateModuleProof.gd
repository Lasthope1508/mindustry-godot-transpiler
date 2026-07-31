extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var update_consumption_call_bridge := game.generated_building_comp_update_consumption_call_bridge_state()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_EFFICIENCY_STATE_MODULE_PROOF",
		"update_consumption_call_bridge": update_consumption_call_bridge,
		"update_consumption_call_bridge_matches": update_consumption_call_bridge == source_building_efficiency_state.generated_update_consumption_call_bridge_state(),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["update_consumption_call_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BUILDING_EFFICIENCY_STATE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BuildingEfficiencyStateModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
