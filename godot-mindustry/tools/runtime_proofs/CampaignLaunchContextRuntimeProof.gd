extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_world_initial_build_runtime_state := preload("res://src/game/SourceWorldInitialBuildRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.select_campaign_sector("biomassFacility")
	game.enter_campaign_playable_slice()
	var context := game.source_campaign_launch_context_state()
	var initial_build := game.source_world_initial_build_runtime_state()
	var initial_build_context: Dictionary = initial_build.get(source_world_initial_build_runtime_state.KEY_CAMPAIGN_LAUNCH_CONTEXT, {})
	var stored_context: Dictionary = game.get("campaign_launch_context")
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceCampaignLaunchContextState",
		"context": context,
		"stored_context": stored_context,
		"initial_build_context": initial_build_context,
		"context_matches_sector": context.get("sector_id", "") == "biomassFacility",
		"context_has_map_path": str(context.get("sector_path", "")).ends_with("/biomassFacility.msav") and bool(context.get("sector_path_exists", false)),
		"context_has_source_text": not str(context.get("sector_name", "")).is_empty() and not str(context.get("sector_description", "")).is_empty(),
		"stored_context_matches": stored_context == context,
		"initial_build_carries_context": initial_build_context == context,
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["context_matches_sector"] and proof["context_has_map_path"] and proof["context_has_source_text"] and proof["stored_context_matches"] and proof["initial_build_carries_context"] and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	print("CAMPAIGN_LAUNCH_CONTEXT_RUNTIME_PROOF " + JSON.stringify(proof))
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/CampaignLaunchContextRuntimeProof.json")
	var file := FileAccess.open(proof_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(proof))
		file.flush()
		file.close()
	game.free()
	await get_tree().process_frame
	get_tree().quit(0 if proof["matches"] else 1)

