extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_consume_item_explode_generated_state := preload("res://src/game/SourceConsumeItemExplodeGeneratedState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var build := {"id": "proof-build"}
	var table := {"id": "proof-table"}

	var build_wrapper := game.generated_consume_item_explode_build_bridge_state(build, table)
	var build_module := source_consume_item_explode_generated_state.generated_build_bridge_state(build, table)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeItemExplodeGeneratedState",
		"build_bridge_matches": build_wrapper == build_module and bool(build_module.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["build_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONSUME_ITEM_EXPLODE_GENERATED_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ConsumeItemExplodeGeneratedRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

