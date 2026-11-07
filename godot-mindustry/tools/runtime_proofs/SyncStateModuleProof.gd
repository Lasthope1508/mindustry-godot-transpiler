extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_sync_state := preload("res://src/game/SourceSyncState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var snap_sync_bridge := game.generated_sync_comp_snap_sync_bridge_state()
	var update_interpolate_bridge := game.generated_sync_comp_update_interpolate_bridge_state(true, false, false)
	var remove_bridge := game.generated_sync_comp_remove_client_removed_entity_bridge_state(true, 77)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
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
	print("SYNC_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("SyncStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

