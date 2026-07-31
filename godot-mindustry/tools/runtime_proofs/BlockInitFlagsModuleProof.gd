extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_init_flags_state := preload("res://src/game/SourceBlockInitFlagsState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var custom_shadow_bridge := game.generated_block_init_custom_shadow_bridge_state(true, true)
	var under_bullets_bridge := game.generated_block_init_under_bullets_bridge_state(true, "TargetPriority.base")
	var fog_radius_bridge := game.generated_block_init_fog_radius_flag_bridge_state(4, [])
	var sync_bridge := game.generated_block_init_sync_flag_bridge_state(true, [])
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_INIT_FLAGS_MODULE_PROOF",
		"custom_shadow_bridge": custom_shadow_bridge,
		"under_bullets_bridge": under_bullets_bridge,
		"fog_radius_bridge": fog_radius_bridge,
		"sync_bridge": sync_bridge,
		"custom_shadow_bridge_matches": custom_shadow_bridge == source_block_init_flags_state.generated_custom_shadow_bridge_state(true, true),
		"under_bullets_bridge_matches": under_bullets_bridge == source_block_init_flags_state.generated_under_bullets_bridge_state(true, "TargetPriority.base"),
		"fog_radius_bridge_matches": fog_radius_bridge == source_block_init_flags_state.generated_fog_radius_flag_bridge_state(4, []),
		"sync_bridge_matches": sync_bridge == source_block_init_flags_state.generated_sync_flag_bridge_state(true, []),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(custom_shadow_bridge.get("matches", false)) and bool(under_bullets_bridge.get("matches", false)) and bool(fog_radius_bridge.get("matches", false)) and bool(sync_bridge.get("matches", false)) and proof["custom_shadow_bridge_matches"] and proof["under_bullets_bridge_matches"] and proof["fog_radius_bridge_matches"] and proof["sync_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_INIT_FLAGS_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockInitFlagsModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.flush()
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
