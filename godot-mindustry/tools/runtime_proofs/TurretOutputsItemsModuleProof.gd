extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_turret_outputs_items_state := preload("res://src/game/SourceTurretOutputsItemsState.gd")
const source_turret_runtime_state := preload("res://src/game/SourceTurretRuntimeState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var bridge := game.generated_turret_outputs_items_bridge_state()
	var module_bridge := source_turret_runtime_state.generated_outputs_items_bridge_state()
	var canonical_bridge := source_turret_outputs_items_state.generated_outputs_items_bridge_state()
	var outputs_items_module_matches := module_bridge == canonical_bridge \
		and source_turret_runtime_state.outputs_items_state() == source_turret_outputs_items_state.outputs_items_state()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "TURRET_OUTPUTS_ITEMS_MODULE_PROOF",
		"bridge": bridge,
		"module_bridge": module_bridge,
		"canonical_bridge": canonical_bridge,
		"bridge_matches_module": bridge == module_bridge,
		"outputs_items_module_matches": outputs_items_module_matches,
		"bridge_matches_canonical": bool(bridge.get("matches", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["bridge_matches_module"] and proof["outputs_items_module_matches"] and proof["bridge_matches_canonical"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("TURRET_OUTPUTS_ITEMS_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("TurretOutputsItemsModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

