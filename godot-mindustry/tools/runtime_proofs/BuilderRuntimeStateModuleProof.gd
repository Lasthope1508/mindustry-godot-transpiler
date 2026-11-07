extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_builder_runtime_state := preload("res://src/game/SourceBuilderRuntimeState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var can_build_bridge := game.generated_builder_comp_can_build_bridge_state(12.5, 1.5)
	var add_build_bridge := game.generated_builder_comp_add_build_bridge_state([], {"x": 9, "y": 5}, true, true, true, true, 0.75)
	var update_build_logic_bridge := game.generated_builder_comp_update_build_logic_bridge_state(30.0, 1.25, 1.1, 0.9, false, true)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDER_RUNTIME_STATE_MODULE_PROOF",
		"can_build_bridge": can_build_bridge,
		"add_build_bridge": add_build_bridge,
		"update_build_logic_bridge": update_build_logic_bridge,
		"can_build_bridge_matches": can_build_bridge == source_builder_runtime_state.generated_builder_comp_can_build_bridge_state(12.5, 1.5),
		"add_build_bridge_matches": add_build_bridge == source_builder_runtime_state.generated_builder_comp_add_build_bridge_state([], {"x": 9, "y": 5}, true, true, true, true, 0.75),
		"update_build_logic_bridge_matches": update_build_logic_bridge == source_builder_runtime_state.generated_builder_comp_update_build_logic_bridge_state(30.0, 1.25, 1.1, 0.9, false, true),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["can_build_bridge_matches"] and proof["add_build_bridge_matches"] and proof["update_build_logic_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDER_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuilderRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

