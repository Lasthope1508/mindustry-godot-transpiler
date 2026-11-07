extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_init_set_bars_call_state := preload("res://src/game/SourceBlockInitSetBarsCallState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var bridge := game.generated_block_init_set_bars_call_bridge_state()
	var proof := {
		"module": "BLOCK_INIT_SET_BARS_CALL_MODULE_PROOF",
		"bridge": bridge,
		"bridge_matches": bridge == source_block_init_set_bars_call_state.generated_block_init_set_bars_call_bridge_state(),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(bridge.get("matches", false)) and proof["bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockInitSetBarsCallModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

