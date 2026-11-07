extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_building_interaction_state := preload("res://src/game/SourceBuildingInteractionState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game: PortGame = PortGameScript.new()
	var previous_state: Dictionary = {"previous": "copper-wall"}
	var current_state: Dictionary = {"id": 42}
	var unit_state: Dictionary = {"unit": "dagger"}
	var puddle_state: Dictionary = {"liquid": "water"}
	var tapped_state: Dictionary = {"tap": true}
	var is_commandable: bool = game.source_building_is_commandable_state(true)
	var is_payload: bool = game.source_building_is_payload_state(false)
	var overwrote: Dictionary = game.source_building_overwrote_state(previous_state)
	var on_removed: Dictionary = game.source_building_on_removed_state(current_state)
	var unit_on: Variant = game.source_building_unit_on_state(unit_state)
	var unit_on_any: Variant = game.source_building_unit_on_any_state(unit_state)
	var unit_removed: Variant = game.source_building_unit_removed_state(unit_state)
	var puddle_on: Dictionary = game.source_building_puddle_on_state(puddle_state)
	var tapped: Dictionary = game.source_building_tapped_state(tapped_state)
	var generated_is_commandable: Dictionary = game.generated_building_comp_is_commandable_bridge_state(true)
	var generated_is_payload: Dictionary = game.generated_building_comp_is_payload_bridge_state(false)
	var generated_overwrote: Dictionary = game.generated_building_comp_overwrote_bridge_state(previous_state)
	var generated_on_removed: Dictionary = game.generated_building_comp_on_removed_bridge_state(current_state)
	var generated_unit_on: Dictionary = game.generated_building_comp_unit_on_bridge_state(unit_state)
	var generated_unit_on_any: Dictionary = game.generated_building_comp_unit_on_any_bridge_state(unit_state)
	var generated_unit_removed: Dictionary = game.generated_building_comp_unit_removed_bridge_state(unit_state)
	var generated_puddle_on: Dictionary = game.generated_building_comp_puddle_on_bridge_state(puddle_state)
	var generated_tapped: Dictionary = game.generated_building_comp_tapped_bridge_state(tapped_state)
	var registry_state: Dictionary = source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var generated_bridge_matches: Array[bool] = [
		bool(generated_is_commandable.get("matches", false)),
		bool(generated_is_payload.get("matches", false)),
		bool(generated_overwrote.get("matches", false)),
		bool(generated_on_removed.get("matches", false)),
		bool(generated_unit_on.get("matches", false)),
		bool(generated_unit_on_any.get("matches", false)),
		bool(generated_unit_removed.get("matches", false)),
		bool(generated_puddle_on.get("matches", false)),
		bool(generated_tapped.get("matches", false)),
	]
	var proof: Dictionary = {
		"module": "BUILDING_INTERACTION_MODULE_PROOF",
		"is_commandable": is_commandable,
		"is_payload": is_payload,
		"overwrote": overwrote,
		"on_removed": on_removed,
		"unit_on": unit_on,
		"unit_on_any": unit_on_any,
		"unit_removed": unit_removed,
		"puddle_on": puddle_on,
		"tapped": tapped,
		"generated_bridge_matches": generated_bridge_matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	var proof_matches: bool = is_commandable == source_building_interaction_state.is_commandable_state(true) and is_payload == source_building_interaction_state.is_payload_state(false) and overwrote == source_building_interaction_state.overwrote_state(previous_state) and on_removed == source_building_interaction_state.on_removed_state(current_state) and unit_on == source_building_interaction_state.unit_on_state(unit_state) and unit_on_any == source_building_interaction_state.unit_on_any_state(unit_state) and unit_removed == source_building_interaction_state.unit_removed_state(unit_state) and puddle_on == source_building_interaction_state.puddle_on_state(puddle_state) and tapped == source_building_interaction_state.tapped_state(tapped_state) and not generated_bridge_matches.has(false) and bool(proof["one_headquarter_per_ssot"]) and bool(proof["registry_valid"])
	proof["matches"] = proof_matches
	var proof_label := get_node_or_null("ProofCanvas/ProofLabel") as Label
	if proof_label != null:
		proof_label.text = "BUILDING_INTERACTION_MODULE_PROOF matches=%s registry_valid=%s" % [str(proof["matches"]), str(proof["registry_valid"])]
	print("BUILDING_INTERACTION_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingInteractionModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

