extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBlockInitFlagsState := preload("res://src/game/SourceBlockInitFlagsState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var custom_shadow_bridge := game.generated_block_init_custom_shadow_bridge_state(true, true)
	var under_bullets_bridge := game.generated_block_init_under_bullets_bridge_state(true, "TargetPriority.base")
	var fog_radius_bridge := game.generated_block_init_fog_radius_flag_bridge_state(4, [])
	var sync_bridge := game.generated_block_init_sync_flag_bridge_state(true, [])
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_INIT_FLAGS_MODULE_PROOF",
		"custom_shadow_bridge": custom_shadow_bridge,
		"under_bullets_bridge": under_bullets_bridge,
		"fog_radius_bridge": fog_radius_bridge,
		"sync_bridge": sync_bridge,
		"custom_shadow_bridge_matches": custom_shadow_bridge == SourceBlockInitFlagsState.generated_custom_shadow_bridge_state(true, true),
		"under_bullets_bridge_matches": under_bullets_bridge == SourceBlockInitFlagsState.generated_under_bullets_bridge_state(true, "TargetPriority.base"),
		"fog_radius_bridge_matches": fog_radius_bridge == SourceBlockInitFlagsState.generated_fog_radius_flag_bridge_state(4, []),
		"sync_bridge_matches": sync_bridge == SourceBlockInitFlagsState.generated_sync_flag_bridge_state(true, []),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(custom_shadow_bridge.get("matches", false)) and bool(under_bullets_bridge.get("matches", false)) and bool(fog_radius_bridge.get("matches", false)) and bool(sync_bridge.get("matches", false)) and proof["custom_shadow_bridge_matches"] and proof["under_bullets_bridge_matches"] and proof["fog_radius_bridge_matches"] and proof["sync_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_INIT_FLAGS_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BlockInitFlagsModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
