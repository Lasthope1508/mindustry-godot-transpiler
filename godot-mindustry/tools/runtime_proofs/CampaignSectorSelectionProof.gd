extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var default_selection := game.source_campaign_sector_selection_state()
	var visible_sectors: Array = game.source_campaign_sector_list_state().get("visible_sectors", [])
	var second_visible: Dictionary = visible_sectors[1] if visible_sectors.size() > 1 else {}
	var selected_after := game.select_campaign_sector(str(second_visible.get("id", "")))
	game.enter_campaign_playable_slice()
	var launched_sector: Dictionary = game.get("campaign_launched_sector")
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceCampaignSectorSelectionState",
		"default_selection": default_selection,
		"selected_after": selected_after,
		"launched_sector": launched_sector,
		"default_is_always_unlocked": default_selection.get("selected_sector_id", "") in default_selection.get("always_unlocked_sector_ids", []),
		"selection_changed": selected_after.get("selected_sector_id", "") == second_visible.get("id", ""),
		"launch_sector_matches_selection": launched_sector.get("id", "") == selected_after.get("selected_sector_id", ""),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["default_is_always_unlocked"] and proof["selection_changed"] and proof["launch_sector_matches_selection"] and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/CampaignSectorSelectionProof.json")
	var file := FileAccess.open(proof_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(proof, "  "))
	file.flush()
	file.close()
	print("CAMPAIGN_SECTOR_SELECTION_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().process_frame
	get_tree().quit(0 if proof["matches"] else 1)

