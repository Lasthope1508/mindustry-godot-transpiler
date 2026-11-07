extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_weapons_state := preload("res://src/game/SourceWeaponsState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var default_bridge := game.generated_shoot_pattern_default_events_bridge_state(3, 0.25, 0.5)
	var compat_bridge := game.generated_shoot_pattern_compat_dispatch_bridge_state(7, 3, 0.25, 0.5, true)
	var flip_bridge := game.generated_shoot_pattern_flip_bridge_state()
	var copy_bridge := game.generated_shoot_pattern_copy_bridge_state(3, 0.25, 0.5)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SHOOT_PATTERN_MODULE_PROOF",
		"default_bridge": default_bridge,
		"compat_bridge": compat_bridge,
		"flip_bridge": flip_bridge,
		"copy_bridge": copy_bridge,
		"default_bridge_matches": default_bridge == source_weapons_state.generated_shoot_pattern_default_events_bridge_state(3, 0.25, 0.5),
		"compat_bridge_matches": compat_bridge == source_weapons_state.generated_shoot_pattern_compat_dispatch_bridge_state(7, 3, 0.25, 0.5, true),
		"flip_bridge_matches": flip_bridge == source_weapons_state.generated_shoot_pattern_flip_bridge_state(),
		"copy_bridge_matches": copy_bridge == source_weapons_state.generated_shoot_pattern_copy_bridge_state(3, 0.25, 0.5),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["default_bridge_matches"] and proof["compat_bridge_matches"] and proof["flip_bridge_matches"] and proof["copy_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("SHOOT_PATTERN_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ShootPatternModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

