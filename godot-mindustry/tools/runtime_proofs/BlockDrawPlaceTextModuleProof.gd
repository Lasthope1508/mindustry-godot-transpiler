extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_draw_state := preload("res://src/game/SourceBlockDrawState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var wrapper_simple := game.generated_block_draw_place_text_simple_bridge_state(false, "Build", 10, 20, true, 8.0, 4.0, 2.0, 36.0, 12.0)
	var module_simple := source_block_draw_state.generated_block_draw_place_text_simple_bridge_state(false, "Build", 10, 20, true, 8.0, 4.0, 2.0, 36.0, 12.0)
	var invalid := game.generated_block_draw_place_text_simple_bridge_state(false, "Build", 10, 20, false, 8.0, 4.0, 2.0, 36.0, 12.0)
	var wrapper_full := game.generated_block_draw_place_text_bridge_state(false, "Build", 10, 20, "Pal.place", false, 8.0, 4.0, 2.0, 36.0, 12.0)
	var module_full := source_block_draw_state.generated_block_draw_place_text_bridge_state(false, "Build", 10, 20, "Pal.place", false, 8.0, 4.0, 2.0, 36.0, 12.0)
	var pixelated := game.generated_block_draw_place_text_bridge_state(true, "Build", 10, 20, "Pal.place", true, 8.0, 4.0, 2.0, 36.0, 12.0)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_DRAW_PLACE_TEXT_MODULE_PROOF",
		"wrapper_simple_matches_module": wrapper_simple == module_simple,
		"wrapper_full_matches_module": wrapper_full == module_full,
		"generated_simple_matches": bool(wrapper_simple.get("matches", false)),
		"generated_full_matches": bool(wrapper_full.get("matches", false)),
		"valid_uses_accent": invalid.get("result", {}).get("color", "") == "Pal.remove" and wrapper_simple.get("result", {}).get("color", "") == "Pal.accent",
		"simple_has_distinct_owner": wrapper_simple.get("result", {}).get("source_owner", "") == "port_game.source_block_draw_place_text_simple_state",
		"full_respects_draw_line": not bool(wrapper_full.get("result", {}).get("draw_line", true)),
		"pixelate_is_hidden": not bool(pixelated.get("result", {}).get("visible", true)) and float(pixelated.get("result", {}).get("returned_width", -1.0)) == 0.0,
		"coordinates_match": float(wrapper_full.get("result", {}).get("dx", -1.0)) == 84.0 and float(wrapper_full.get("result", {}).get("dy", -1.0)) == 175.0,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["wrapper_simple_matches_module"] and proof["wrapper_full_matches_module"] and proof["generated_simple_matches"] and proof["generated_full_matches"] and proof["valid_uses_accent"] and proof["simple_has_distinct_owner"] and proof["full_respects_draw_line"] and proof["pixelate_is_hidden"] and proof["coordinates_match"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockDrawPlaceTextModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
