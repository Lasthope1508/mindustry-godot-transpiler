extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_init_sound_state := preload("res://src/game/SourceBlockInitSoundState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var destroy_bridge := game.generated_block_init_destroy_sound_bridge_state("Sounds.unset", 3)
	var place_bridge := game.generated_block_init_place_sound_bridge_state("Sounds.unset", 2)
	var break_bridge := game.generated_block_init_break_sound_bridge_state("Sounds.unset", 1)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_INIT_SOUND_MODULE_PROOF",
		"destroy_bridge": destroy_bridge,
		"place_bridge": place_bridge,
		"break_bridge": break_bridge,
		"destroy_bridge_matches": destroy_bridge == source_block_init_sound_state.generated_block_init_destroy_sound_bridge_state("Sounds.unset", 3),
		"place_bridge_matches": place_bridge == source_block_init_sound_state.generated_block_init_place_sound_bridge_state("Sounds.unset", 2),
		"break_bridge_matches": break_bridge == source_block_init_sound_state.generated_block_init_break_sound_bridge_state("Sounds.unset", 1),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(destroy_bridge.get("matches", false)) and bool(place_bridge.get("matches", false)) and bool(break_bridge.get("matches", false)) and proof["destroy_bridge_matches"] and proof["place_bridge_matches"] and proof["break_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockInitSoundModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

