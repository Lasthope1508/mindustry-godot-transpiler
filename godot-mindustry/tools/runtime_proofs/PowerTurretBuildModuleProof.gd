extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var game := PortGameScript.new()
	var ammo_fraction := game.source_power_turret_build_get_ammo_fraction_state(false, 0.75)
	var sense := game.source_power_turret_build_sense_state("ammo", false, 0.75, 0.2)
	var use_ammo := game.source_power_turret_build_use_ammo_state({"id": "lancer"})
	var has_ammo := game.source_power_turret_build_has_ammo_state()
	var peek_ammo := game.source_power_turret_build_peek_ammo_state({"id": "lancer"})
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourcePowerTurretBuildState",
		"ammo_fraction_matches": ammo_fraction.get("ammo_fraction", null) == 0.75,
		"sense_matches": sense.get("sense_value", null) == 0.75,
		"use_ammo_matches": use_ammo.get("shoot_type", {}).get("id", "") == "lancer",
		"has_ammo_matches": bool(has_ammo.get("has_ammo", false)),
		"peek_ammo_matches": peek_ammo.get("shoot_type", {}).get("id", "") == "lancer",
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["module_matches"] = proof["ammo_fraction_matches"] and proof["sense_matches"] and proof["use_ammo_matches"] and proof["has_ammo_matches"] and proof["peek_ammo_matches"]
	proof["matches"] = proof["module_matches"] and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	print("POWER_TURRET_BUILD_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("PowerTurretBuildModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

