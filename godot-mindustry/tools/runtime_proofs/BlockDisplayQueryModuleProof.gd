extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_display_query_state := preload("res://src/game/SourceBlockDisplayQueryState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var percent_solid_bridge := game.generated_block_percent_solid_bridge_state(true, 2, 3, 3.0, 2.0)
	var display_icon_bridge := game.generated_block_get_display_icon_bridge_state(false, "ui-icon", "build-icon")
	var display_name_bridge := game.generated_block_get_display_name_bridge_state(true, "localized", "build name")
	var minimap_color_bridge := game.generated_block_minimap_color_bridge_state("tile")
	var get_color_bridge := game.generated_block_get_color_bridge_state(7, "map-color", "tmp-color")
	var proof := {
		"module": "SourceBlockDisplayQueryState",
		"percent_solid_bridge_matches": percent_solid_bridge == source_block_display_query_state.generated_block_percent_solid_bridge_state(true, 2, 3, 3.0, 2.0) and bool(percent_solid_bridge.get("matches", false)),
		"display_icon_bridge_matches": display_icon_bridge == source_block_display_query_state.generated_block_get_display_icon_bridge_state(false, "ui-icon", "build-icon") and bool(display_icon_bridge.get("matches", false)),
		"display_name_bridge_matches": display_name_bridge == source_block_display_query_state.generated_block_get_display_name_bridge_state(true, "localized", "build name") and bool(display_name_bridge.get("matches", false)),
		"minimap_color_bridge_matches": minimap_color_bridge == source_block_display_query_state.generated_block_minimap_color_bridge_state("tile") and bool(minimap_color_bridge.get("matches", false)),
		"get_color_bridge_matches": get_color_bridge == source_block_display_query_state.generated_block_get_color_bridge_state(7, "map-color", "tmp-color") and bool(get_color_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["percent_solid_bridge_matches"] and proof["display_icon_bridge_matches"] and proof["display_name_bridge_matches"] and proof["minimap_color_bridge_matches"] and proof["get_color_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockDisplayQueryModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
