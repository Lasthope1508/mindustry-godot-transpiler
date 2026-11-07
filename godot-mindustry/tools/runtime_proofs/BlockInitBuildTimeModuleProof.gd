extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_init_build_time_state := preload("res://src/game/SourceBlockInitBuildTimeState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var requirement_stacks := [{"amount": 3, "cost": 1.5}, {"amount": 2, "cost": 2.0}]
	var requirements_bridge := game.generated_block_init_build_time_requirements_bridge_state(-1.0, requirement_stacks)
	var default_bridge := game.generated_block_init_build_time_default_bridge_state(-1.0)
	var multiplier_bridge := game.generated_block_init_build_time_multiplier_bridge_state(20.0, 1.5)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_INIT_BUILD_TIME_MODULE_PROOF",
		"requirements_bridge": requirements_bridge,
		"default_bridge": default_bridge,
		"multiplier_bridge": multiplier_bridge,
		"requirements_bridge_matches": requirements_bridge == source_block_init_build_time_state.generated_requirements_bridge_state(-1.0, requirement_stacks),
		"default_bridge_matches": default_bridge == source_block_init_build_time_state.generated_default_bridge_state(-1.0),
		"multiplier_bridge_matches": multiplier_bridge == source_block_init_build_time_state.generated_multiplier_bridge_state(20.0, 1.5),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(requirements_bridge.get("matches", false)) and bool(default_bridge.get("matches", false)) and bool(multiplier_bridge.get("matches", false)) and proof["requirements_bridge_matches"] and proof["default_bridge_matches"] and proof["multiplier_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockInitBuildTimeModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

