extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_basic_comp_state := preload("res://src/game/SourceBasicCompState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var pos_set_state := source_basic_comp_state.pos_set_state(12.0, 34.0)
	var shielder_absorb_state := source_basic_comp_state.shielder_absorb_state()
	var pos_set_bridge := game.generated_pos_comp_set_bridge_state(12.0, 34.0)
	var shielder_absorb_bridge := game.generated_shielder_comp_absorb_bridge_state()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BASIC_COMP_STATE_MODULE_PROOF",
		"pos_set_state": pos_set_state,
		"shielder_absorb_state": shielder_absorb_state,
		"pos_set_bridge": pos_set_bridge,
		"shielder_absorb_bridge": shielder_absorb_bridge,
		"pos_set_bridge_matches": pos_set_bridge == source_basic_comp_state.generated_pos_set_bridge_state(12.0, 34.0),
		"shielder_absorb_bridge_matches": shielder_absorb_bridge == source_basic_comp_state.generated_shielder_absorb_bridge_state(),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["pos_set_bridge_matches"] and proof["shielder_absorb_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BASIC_COMP_STATE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BasicCompStateModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
