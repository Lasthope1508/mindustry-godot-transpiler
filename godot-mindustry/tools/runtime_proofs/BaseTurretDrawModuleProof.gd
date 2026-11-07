extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_base_turret_draw_state := preload("res://src/game/SourceBaseTurretDrawState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var source := game.source_base_turret_draw_place_state(4, 7, 1, true, 8.0, 0.0, 80.0, 1.0, false)
	var generated := game.generated_base_turret_draw_place_bridge_state(4, 7, 1, true, 8.0, 0.0, 80.0, 1.0, false)
	var defaulted := game.generated_base_turret_draw_place_source_tilesize_default_bridge_state(4, 7, 1, true)
	var proof := {
		"module": "SourceBaseTurretDrawState",
		"source": source,
		"generated": generated,
		"defaulted": defaulted,
		"module_generated": source_base_turret_draw_state.generated_base_turret_draw_place_bridge_state(4, 7, 1, true, 8.0, 0.0, 80.0, 1.0, false),
		"module_defaulted": source_base_turret_draw_state.generated_base_turret_draw_place_source_tilesize_default_bridge_state(4, 7, 1, true),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["generated"] == proof["module_generated"] and proof["defaulted"] == proof["module_defaulted"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BASE_TURRET_DRAW_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BaseTurretDrawModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

