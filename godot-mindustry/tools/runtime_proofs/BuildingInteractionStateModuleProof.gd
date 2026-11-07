extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_interaction_state := preload("res://src/game/SourceBuildingInteractionState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var is_commandable_wrapper := game.generated_building_comp_is_commandable_bridge_state(true)
	var is_commandable_module := source_building_interaction_state.generated_is_commandable_bridge_state(true)
	var is_payload_wrapper := game.generated_building_comp_is_payload_bridge_state(false)
	var is_payload_module := source_building_interaction_state.generated_is_payload_bridge_state(false)
	var overwrote_wrapper := game.generated_building_comp_overwrote_bridge_state(["tile-1"])
	var overwrote_module := source_building_interaction_state.generated_overwrote_bridge_state(["tile-1"])
	var on_removed_wrapper := game.generated_building_comp_on_removed_bridge_state({"state": "removed"})
	var on_removed_module := source_building_interaction_state.generated_on_removed_bridge_state({"state": "removed"})
	var unit_on_wrapper := game.generated_building_comp_unit_on_bridge_state({"unit": "alpha"})
	var unit_on_module := source_building_interaction_state.generated_unit_on_bridge_state({"unit": "alpha"})
	var unit_on_any_wrapper := game.generated_building_comp_unit_on_any_bridge_state({"unit": "beta"})
	var unit_on_any_module := source_building_interaction_state.generated_unit_on_any_bridge_state({"unit": "beta"})
	var unit_removed_wrapper := game.generated_building_comp_unit_removed_bridge_state({"unit": "gamma"})
	var unit_removed_module := source_building_interaction_state.generated_unit_removed_bridge_state({"unit": "gamma"})
	var puddle_on_wrapper := game.generated_building_comp_puddle_on_bridge_state({"puddle": "delta"})
	var puddle_on_module := source_building_interaction_state.generated_puddle_on_bridge_state({"puddle": "delta"})
	var tapped_wrapper := game.generated_building_comp_tapped_bridge_state({"current": "epsilon"})
	var tapped_module := source_building_interaction_state.generated_tapped_bridge_state({"current": "epsilon"})
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var generated_bridge_matches := (
		bool(is_commandable_module.get("matches", false))
		and bool(is_payload_module.get("matches", false))
		and bool(overwrote_module.get("matches", false))
		and bool(on_removed_module.get("matches", false))
		and bool(unit_on_module.get("matches", false))
		and bool(unit_on_any_module.get("matches", false))
		and bool(unit_removed_module.get("matches", false))
		and bool(puddle_on_module.get("matches", false))
		and bool(tapped_module.get("matches", false))
	)
	var proof := {
		"module": "BUILDING_INTERACTION_STATE_MODULE_PROOF",
		"is_commandable_matches": is_commandable_wrapper == is_commandable_module,
		"is_payload_matches": is_payload_wrapper == is_payload_module,
		"overwrote_matches": overwrote_wrapper == overwrote_module,
		"on_removed_matches": on_removed_wrapper == on_removed_module,
		"unit_on_matches": unit_on_wrapper == unit_on_module,
		"unit_on_any_matches": unit_on_any_wrapper == unit_on_any_module,
		"unit_removed_matches": unit_removed_wrapper == unit_removed_module,
		"puddle_on_matches": puddle_on_wrapper == puddle_on_module,
		"tapped_matches": tapped_wrapper == tapped_module,
		"is_commandable_bridge_matches": bool(is_commandable_module.get("matches", false)),
		"is_payload_bridge_matches": bool(is_payload_module.get("matches", false)),
		"overwrote_bridge_matches": bool(overwrote_module.get("matches", false)),
		"on_removed_bridge_matches": bool(on_removed_module.get("matches", false)),
		"unit_on_bridge_matches": bool(unit_on_module.get("matches", false)),
		"unit_on_any_bridge_matches": bool(unit_on_any_module.get("matches", false)),
		"unit_removed_bridge_matches": bool(unit_removed_module.get("matches", false)),
		"puddle_on_bridge_matches": bool(puddle_on_module.get("matches", false)),
		"tapped_bridge_matches": bool(tapped_module.get("matches", false)),
		"generated_bridge_matches": generated_bridge_matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = bool(proof.get("is_commandable_matches", false)) and bool(proof.get("is_payload_matches", false)) and bool(proof.get("overwrote_matches", false)) and bool(proof.get("on_removed_matches", false)) and bool(proof.get("unit_on_matches", false)) and bool(proof.get("unit_on_any_matches", false)) and bool(proof.get("unit_removed_matches", false)) and bool(proof.get("puddle_on_matches", false)) and bool(proof.get("tapped_matches", false)) and generated_bridge_matches and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_INTERACTION_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingInteractionStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

