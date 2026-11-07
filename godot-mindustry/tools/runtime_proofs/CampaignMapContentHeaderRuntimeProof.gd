extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_world_initial_build_runtime_state := preload("res://src/game/SourceWorldInitialBuildRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.select_campaign_sector("biomassFacility")
	game.enter_campaign_playable_slice()
	var content_header_state := game.source_campaign_map_content_header_state()
	var content_type_counts: Dictionary = content_header_state.get("content_type_counts", {})
	var content_id_names_by_type: Dictionary = content_header_state.get("content_id_names_by_type", {})
	var sector_names: Dictionary = content_id_names_by_type.get("sector", {})
	var block_names: Dictionary = content_id_names_by_type.get("block", {})
	var initial_build := game.source_world_initial_build_runtime_state()
	var initial_build_content_header: Dictionary = initial_build.get(source_world_initial_build_runtime_state.KEY_CAMPAIGN_MAP_CONTENT_HEADER, {})
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceCampaignMapContentHeaderState",
		"content_header_state": content_header_state,
		"mapped_count_matches": int(content_header_state.get("mapped_count", 0)) == 10,
		"block_count_matches": int(content_type_counts.get("block", 0)) == 446,
		"item_count_matches": int(content_type_counts.get("item", 0)) == 22,
		"sector_name_matches": str(sector_names.get("4", "")) == "biomassFacility",
		"block_zero_matches": str(block_names.get("0", "")) == "air",
		"content_header_consumed": bool(content_header_state.get("content_header_consumed", false)),
		"initial_build_carries_content_header": initial_build_content_header == content_header_state,
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["mapped_count_matches"] and proof["block_count_matches"] and proof["item_count_matches"] and proof["sector_name_matches"] and proof["block_zero_matches"] and proof["content_header_consumed"] and proof["initial_build_carries_content_header"] and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	print("CAMPAIGN_MAP_CONTENT_HEADER_RUNTIME_PROOF " + JSON.stringify(proof))
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/CampaignMapContentHeaderRuntimeProof.json")
	var file := FileAccess.open(proof_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(proof))
		file.flush()
		file.close()
	game.free()
	await get_tree().process_frame
	get_tree().quit(0 if proof["matches"] else 1)

