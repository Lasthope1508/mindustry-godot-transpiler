extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_core_state := preload("res://src/game/SourceBuildingCoreState.gd")
const generated_building_comp_script := preload("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var generated_building_comp := generated_building_comp_script.new()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var collide_other := {"type": "proof_bullet"}
	var check_solid_bridge := game.generated_building_comp_check_solid_bridge_state()
	var absorb_lasers_bridge := game.generated_building_comp_absorb_lasers_bridge_state(true)
	var is_insulated_bridge := game.generated_building_comp_is_insulated_bridge_state(true)
	var collide_bridge := game.generated_building_comp_collide_bridge_state(collide_other)
	var power_production_bridge := game.generated_building_comp_power_production_bridge_state()
	var generated_can_be_replaced: Variant = generated_building_comp.java_method_canBeReplaced_86([{}, true])
	var proof := {
		"module": "BUILDING_CORE_STATE_MODULE_PROOF",
		"check_solid_bridge": check_solid_bridge,
		"absorb_lasers_bridge": absorb_lasers_bridge,
		"is_insulated_bridge": is_insulated_bridge,
		"collide_bridge": collide_bridge,
		"power_production_bridge": power_production_bridge,
		"check_solid_bridge_matches": check_solid_bridge == source_building_core_state.generated_check_solid_bridge_state(),
		"absorb_lasers_bridge_matches": absorb_lasers_bridge == source_building_core_state.generated_absorb_lasers_bridge_state(true),
		"is_insulated_bridge_matches": is_insulated_bridge == source_building_core_state.generated_is_insulated_bridge_state(true),
		"collide_bridge_matches": collide_bridge == source_building_core_state.generated_collide_bridge_state(collide_other),
		"power_production_bridge_matches": power_production_bridge == source_building_core_state.generated_power_production_bridge_state(),
		"generated_can_be_replaced_matches": generated_can_be_replaced == source_building_core_state.building_can_be_replaced_state(true),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["check_solid_bridge_matches"] and proof["absorb_lasers_bridge_matches"] and proof["is_insulated_bridge_matches"] and proof["collide_bridge_matches"] and proof["power_production_bridge_matches"] and proof["generated_can_be_replaced_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_CORE_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingCoreStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
