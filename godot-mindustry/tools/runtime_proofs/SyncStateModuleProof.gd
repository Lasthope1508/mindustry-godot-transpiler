extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_sync_state := preload("res://src/game/SourceSyncState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var snap_sync_bridge := game.generated_sync_comp_snap_sync_bridge_state()
	var update_interpolate_bridge := game.generated_sync_comp_update_interpolate_bridge_state(true, false, false)
	var remove_bridge := game.generated_sync_comp_remove_client_removed_entity_bridge_state(true, 77)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SYNC_STATE_MODULE_PROOF",
		"snap_sync_bridge": snap_sync_bridge,
		"update_interpolate_bridge": update_interpolate_bridge,
		"remove_bridge": remove_bridge,
		"snap_sync_bridge_matches": snap_sync_bridge == source_sync_state.generated_snap_sync_bridge_state(),
		"update_interpolate_bridge_matches": update_interpolate_bridge == source_sync_state.generated_update_interpolate_bridge_state(true, false, false),
		"remove_bridge_matches": remove_bridge == source_sync_state.generated_remove_client_removed_entity_bridge_state(true, 77),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["snap_sync_bridge_matches"] and proof["update_interpolate_bridge_matches"] and proof["remove_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("SYNC_STATE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/SyncStateModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

