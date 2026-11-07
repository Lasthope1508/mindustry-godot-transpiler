extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_world_initial_build_runtime_state := preload("res://src/game/SourceWorldInitialBuildRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.select_campaign_sector("biomassFacility")
	game.enter_campaign_playable_slice()
	var map_file_state := game.source_campaign_map_file_state()
	var initial_build := game.source_world_initial_build_runtime_state()
	var initial_build_map_file: Dictionary = initial_build.get(source_world_initial_build_runtime_state.KEY_CAMPAIGN_MAP_FILE, {})
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceCampaignMapFileState",
		"map_file_state": map_file_state,
		"header_matches": map_file_state.get("header", "") == "MSAV",
		"version_matches": int(map_file_state.get("version", -1)) == 11,
		"size_matches": int(map_file_state.get("width", 0)) == 250 and int(map_file_state.get("height", 0)) == 250,
		"meta_region_consumed": bool(map_file_state.get("meta_region_consumed", false)),
		"rules_loaded": str(map_file_state.get("rules", "")).contains("spawns"),
		"initial_build_carries_map_file": initial_build_map_file == map_file_state,
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["header_matches"] and proof["version_matches"] and proof["size_matches"] and proof["meta_region_consumed"] and proof["rules_loaded"] and proof["initial_build_carries_map_file"] and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	print("CAMPAIGN_MAP_FILE_RUNTIME_PROOF " + JSON.stringify(proof))
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/CampaignMapFileRuntimeProof.json")
	var file := FileAccess.open(proof_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(proof))
		file.flush()
		file.close()
	game.free()
	await get_tree().process_frame
	get_tree().quit(0 if proof["matches"] else 1)

