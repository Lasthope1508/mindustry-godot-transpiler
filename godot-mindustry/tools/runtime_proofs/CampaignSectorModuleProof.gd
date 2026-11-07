extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const PortGameScript := preload("res://src/game/PortGame.gd")
const source_campaign_sector_state := preload("res://src/game/SourceCampaignSectorState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var bridge_state := game.source_campaign_sector_list_state()
	var module_state := source_campaign_sector_state.serpulo_sector_list_state()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceCampaignSectorState",
		"bridge_state": bridge_state,
		"module_state": module_state,
		"sector_count": int(bridge_state.get("sector_count", 0)),
		"visible_sector_count": int(bridge_state.get("visible_sector_count", 0)),
		"hidden_sector_count": int(bridge_state.get("hidden_sector_count", 0)),
		"source_owner": bridge_state.get("source_owner", ""),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bridge_state == module_state and proof["sector_count"] > 0 and proof["visible_sector_count"] > 0 and proof["hidden_sector_count"] > 0 and proof["sector_count"] == proof["visible_sector_count"] + proof["hidden_sector_count"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CAMPAIGN_SECTOR_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("CampaignSectorModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

