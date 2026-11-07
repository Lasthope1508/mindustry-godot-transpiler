extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_liquid_turret_init_state := preload("res://src/game/SourceLiquidTurretInitState.gd")
const source_continuous_liquid_turret_init_state := preload("res://src/game/SourceContinuousLiquidTurretInitState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var ammo_entries := [{"item": "copper", "type": {"rangeChange": 12.0}}, {"item": "lead", "type": {"rangeChange": 6.0}}]
	var liquid_ammo_entries := [{"liquid": "water", "type": {"rangeChange": 18.0}}, {"liquid": "slag", "bullet": {"rangeChange": 9.0}}]
	var liquid_init := game.source_liquid_turret_init_state(ammo_entries, true, 40.0, 30.0, 3.0)
	var liquid_default_bridge := game.generated_liquid_turret_init_range_margin_default_bridge_state(ammo_entries, true, 40.0)
	var continuous_init := game.source_continuous_liquid_turret_init_state(liquid_ammo_entries, true, 28.0, 24.0, 2.0, 1.25, "water", 2.0)
	var continuous_bridge := game.generated_continuous_liquid_turret_init_bridge_state(liquid_ammo_entries, true, 28.0, 24.0, 2.0, 1.25, "water", 2.0)
	var continuous_default_bridge := game.generated_continuous_liquid_turret_init_range_margin_default_bridge_state(liquid_ammo_entries, true, 28.0)
	var module_liquid_init := source_liquid_turret_init_state.init_state(ammo_entries, true, 40.0, 30.0, 3.0)
	var module_liquid_default_bridge := source_liquid_turret_init_state.generated_init_range_margin_default_bridge_state(ammo_entries, true, 40.0)
	var module_continuous_init := source_continuous_liquid_turret_init_state.init_state(liquid_ammo_entries, true, 28.0, 24.0, 2.0, 1.25, "water", 2.0)
	var module_continuous_bridge := source_continuous_liquid_turret_init_state.generated_init_bridge_state(liquid_ammo_entries, true, 28.0, 24.0, 2.0, 1.25, "water", 2.0)
	var module_continuous_default_bridge := source_continuous_liquid_turret_init_state.generated_init_range_margin_default_bridge_state(liquid_ammo_entries, true, 28.0)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "TurretLiquidInitModule",
		"liquid_init_matches": liquid_init == module_liquid_init,
		"liquid_default_bridge_matches": bool(liquid_default_bridge.get("matches", false)),
		"continuous_init_matches": continuous_init == module_continuous_init,
		"continuous_bridge_matches": bool(continuous_bridge.get("matches", false)),
		"continuous_default_bridge_matches": bool(continuous_default_bridge.get("matches", false)),
		"module_liquid_default_bridge_matches": bool(module_liquid_default_bridge.get("matches", false)),
		"module_continuous_bridge_matches": bool(module_continuous_bridge.get("matches", false)),
		"module_continuous_default_bridge_matches": bool(module_continuous_default_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["liquid_init_matches"] and proof["liquid_default_bridge_matches"] and proof["continuous_init_matches"] and proof["continuous_bridge_matches"] and proof["continuous_default_bridge_matches"] and proof["module_liquid_default_bridge_matches"] and proof["module_continuous_bridge_matches"] and proof["module_continuous_default_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("TURRET_LIQUID_INIT_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("TurretLiquidInitModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

