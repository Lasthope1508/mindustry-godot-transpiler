extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_draw_state := preload("res://src/game/SourceBlockDrawState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var draw_base_bridge := game.generated_block_draw_base_bridge_state(false, 0, "region", "variant", 10.0, 12.0)
	var draw_base_cached_bridge := game.generated_block_draw_base_cached_bridge_state(true, 2, "region", "variant", 10.0, 12.0)
	var draw_shadow_bridge := game.generated_block_draw_shadow_bridge_state("tile", 1, "custom-shadow", "variant-shadow", 10.0, 12.0, 0.5)
	var draw_environment_light_bridge := game.generated_block_draw_environment_light_bridge_state(10.0, 12.0, 24.0, "light-color", 0.75)
	var draw_place_bridge := game.generated_block_draw_place_bridge_state(2, 3, 1, true, 8.0, 4.0)
	var draw_overlay_bridge := game.generated_block_draw_overlay_bridge_state(20.0, 28.0, 1)
	var display_shadow_bridge := game.generated_block_display_shadow_bridge_state(true, "tile")
	var draw_base_source := game.source_block_draw_base_state(false, 0, "region", "variant", 10.0, 12.0)
	var draw_base_cached_source := game.source_block_draw_base_cached_state(true, 2, "region", "variant", 10.0, 12.0)
	var draw_shadow_source := game.source_block_draw_shadow_state("tile", 1, "custom-shadow", "variant-shadow", 10.0, 12.0, 0.5)
	var draw_environment_light_source := game.source_block_draw_environment_light_state(10.0, 12.0, 24.0, "light-color", 0.75)
	var draw_place_source := game.source_block_draw_place_state(2, 3, 1, true, 8.0, 4.0)
	var draw_overlay_source := game.source_block_draw_overlay_state(20.0, 28.0, 1)
	var display_shadow_source := game.source_block_display_shadow_state(true, "tile")
	var proof := {
		"module": "SourceBlockDrawState",
		"draw_base_bridge_matches": draw_base_bridge == source_block_draw_state.generated_block_draw_base_bridge_state(false, 0, "region", "variant", 10.0, 12.0) and bool(draw_base_bridge.get("matches", false)),
		"draw_base_cached_bridge_matches": draw_base_cached_bridge == source_block_draw_state.generated_block_draw_base_cached_bridge_state(true, 2, "region", "variant", 10.0, 12.0) and bool(draw_base_cached_bridge.get("matches", false)),
		"draw_shadow_bridge_matches": draw_shadow_bridge == source_block_draw_state.generated_block_draw_shadow_bridge_state("tile", 1, "custom-shadow", "variant-shadow", 10.0, 12.0, 0.5) and bool(draw_shadow_bridge.get("matches", false)),
		"draw_environment_light_bridge_matches": draw_environment_light_bridge == source_block_draw_state.generated_block_draw_environment_light_bridge_state(10.0, 12.0, 24.0, "light-color", 0.75) and bool(draw_environment_light_bridge.get("matches", false)),
		"draw_place_bridge_matches": draw_place_bridge == source_block_draw_state.generated_block_draw_place_bridge_state(2, 3, 1, true, 8.0, 4.0) and bool(draw_place_bridge.get("matches", false)),
		"draw_overlay_bridge_matches": draw_overlay_bridge == source_block_draw_state.generated_block_draw_overlay_bridge_state(20.0, 28.0, 1) and bool(draw_overlay_bridge.get("matches", false)),
		"display_shadow_bridge_matches": display_shadow_bridge == source_block_draw_state.generated_block_display_shadow_bridge_state(true, "tile") and bool(display_shadow_bridge.get("matches", false)),
		"draw_base_source_matches": draw_base_source == source_block_draw_state.draw_base_state(false, 0, "region", "variant", 10.0, 12.0),
		"draw_base_cached_source_matches": draw_base_cached_source == source_block_draw_state.draw_base_cached_state(true, 2, "region", "variant", 10.0, 12.0),
		"draw_shadow_source_matches": draw_shadow_source == source_block_draw_state.draw_shadow_state("tile", 1, "custom-shadow", "variant-shadow", 10.0, 12.0, 0.5),
		"draw_environment_light_source_matches": draw_environment_light_source == source_block_draw_state.draw_environment_light_state(10.0, 12.0, 24.0, "light-color", 0.75),
		"draw_place_source_matches": draw_place_source == source_block_draw_state.draw_place_state(2, 3, 1, true, 8.0, 4.0),
		"draw_overlay_source_matches": draw_overlay_source == source_block_draw_state.draw_overlay_state(20.0, 28.0, 1),
		"display_shadow_source_matches": display_shadow_source == source_block_draw_state.display_shadow_state(true, "tile"),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["draw_base_bridge_matches"] and proof["draw_base_cached_bridge_matches"] and proof["draw_shadow_bridge_matches"] and proof["draw_environment_light_bridge_matches"] and proof["draw_place_bridge_matches"] and proof["draw_overlay_bridge_matches"] and proof["display_shadow_bridge_matches"] and proof["draw_base_source_matches"] and proof["draw_base_cached_source_matches"] and proof["draw_shadow_source_matches"] and proof["draw_environment_light_source_matches"] and proof["draw_place_source_matches"] and proof["draw_overlay_source_matches"] and proof["display_shadow_source_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockDrawModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
