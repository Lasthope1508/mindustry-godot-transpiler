extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_draw_state := preload("res://src/game/SourceBlockDrawState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var power_links := [{"x": 140.0, "y": 220.0, "size": 2}]
	var beam_links := [{"x": 80.0, "y": 180.0, "size": 1}]
	var wrapper := game.generated_block_draw_potential_links_bridge_state(true, false, true, true, true, 10, 20, 8.0, 4.0, 2.0, power_links, beam_links)
	var module := source_block_draw_state.generated_block_draw_potential_links_bridge_state(true, false, true, true, true, 10, 20, 8.0, 4.0, 2.0, power_links, beam_links)
	var disabled := game.generated_block_draw_potential_links_bridge_state(false, false, true, true, true, 10, 20, 8.0, 4.0, 2.0, power_links, beam_links)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_DRAW_POTENTIAL_LINKS_MODULE_PROOF",
		"wrapper_matches_module": wrapper == module,
		"generated_subset_matches": bool(wrapper.get("matches", false)),
		"disabled_is_inactive": not bool(disabled.get("result", {}).get("active", true)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["wrapper_matches_module"] and proof["generated_subset_matches"] and proof["disabled_is_inactive"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockDrawPotentialLinksModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
