extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_init_health_state := preload("res://src/game/SourceBlockInitHealthState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var health_scaled_bridge := game.generated_block_init_health_scaled_bridge_state(-1, 3, 2.0)
	var health_requirements_bridge := game.generated_block_init_health_requirements_scaling_bridge_state(-1, 3, -1.0, [0.25, 0.75])
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_INIT_HEALTH_MODULE_PROOF",
		"health_scaled_bridge": health_scaled_bridge,
		"health_requirements_bridge": health_requirements_bridge,
		"health_scaled_bridge_matches": health_scaled_bridge == source_block_init_health_state.generated_health_scaled_bridge_state(-1, 3, 2.0),
		"health_requirements_bridge_matches": health_requirements_bridge == source_block_init_health_state.generated_health_requirements_scaling_bridge_state(-1, 3, -1.0, [0.25, 0.75]),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(health_scaled_bridge.get("matches", false)) and bool(health_requirements_bridge.get("matches", false)) and proof["health_scaled_bridge_matches"] and proof["health_requirements_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockInitHealthModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

