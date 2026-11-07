extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_init_buffered_power_state := preload("res://src/game/SourceBlockInitBufferedPowerState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var buffered_power_bridge := game.generated_block_init_buffered_power_bridge_state(false, true, true)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_INIT_BUFFERED_POWER_MODULE_PROOF",
		"buffered_power_bridge": buffered_power_bridge,
		"buffered_power_bridge_matches": buffered_power_bridge == source_block_init_buffered_power_state.generated_block_init_buffered_power_bridge_state(false, true, true),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(buffered_power_bridge.get("matches", false)) and proof["buffered_power_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockInitBufferedPowerModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

