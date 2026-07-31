extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_time_state := preload("res://src/game/SourceBuildingTimeState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var write_base_bridge := game.generated_building_comp_write_base_timescale_bridge_state(1.0, 0.0)
	var read_base_bridge := game.generated_building_comp_read_base_timescale_bridge_state(4, 1.0, 0.5)
	var module_bitmask_bridge := game.generated_building_comp_module_bitmask_bridge_state(true, true, false, 1.0, true)
	var update_timescale_bridge := game.generated_building_comp_update_timescale_decay_bridge_state(1.0, 0.0, 1.0)
	var update_ambient_bridge := game.generated_building_comp_update_ambient_sound_gate_bridge_state(false, "sound", null, true, 2.0, 3.0)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_TIME_STATE_MODULE_PROOF",
		"write_base_bridge": write_base_bridge,
		"read_base_bridge": read_base_bridge,
		"module_bitmask_bridge": module_bitmask_bridge,
		"update_timescale_bridge": update_timescale_bridge,
		"update_ambient_bridge": update_ambient_bridge,
		"write_base_bridge_matches": write_base_bridge == source_building_time_state.generated_write_base_timescale_bridge_state(1.0, 0.0),
		"read_base_bridge_matches": read_base_bridge == source_building_time_state.generated_read_base_timescale_bridge_state(4, 1.0, 0.5),
		"module_bitmask_bridge_matches": module_bitmask_bridge == source_building_time_state.generated_module_bitmask_bridge_state(true, true, false, 1.0, true),
		"update_timescale_bridge_matches": update_timescale_bridge == source_building_time_state.generated_update_timescale_decay_bridge_state(1.0, 0.0, 1.0),
		"update_ambient_bridge_matches": update_ambient_bridge == source_building_time_state.generated_update_ambient_sound_gate_bridge_state(false, "sound", null, true, 2.0, 3.0),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["write_base_bridge_matches"] and proof["read_base_bridge_matches"] and proof["module_bitmask_bridge_matches"] and proof["update_timescale_bridge_matches"] and proof["update_ambient_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BUILDING_TIME_STATE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BuildingTimeStateModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
