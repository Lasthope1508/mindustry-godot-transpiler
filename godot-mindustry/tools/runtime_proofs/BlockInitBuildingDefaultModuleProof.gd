extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_init_building_default_state := preload("res://src/game/SourceBlockInitBuildingDefaultState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var default_bridge := game.generated_block_init_building_default_bridge_state(null)
	var existing_bridge := game.generated_block_init_building_default_bridge_state("CustomBuildingFactory")
	var proof := {
		"module": "BLOCK_INIT_BUILDING_DEFAULT_MODULE_PROOF",
		"default_bridge": default_bridge,
		"existing_bridge": existing_bridge,
		"default_bridge_matches": default_bridge == source_block_init_building_default_state.generated_block_init_building_default_bridge_state(null),
		"existing_bridge_matches": existing_bridge == source_block_init_building_default_state.generated_block_init_building_default_bridge_state("CustomBuildingFactory"),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(default_bridge.get("matches", false)) and bool(existing_bridge.get("matches", false)) and proof["default_bridge_matches"] and proof["existing_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockInitBuildingDefaultModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

