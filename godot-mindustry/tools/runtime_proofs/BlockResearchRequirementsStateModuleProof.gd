extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_research_requirements_state := preload("res://src/game/SourceBlockResearchRequirementsState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var research_cost := [{"item": "copper", "amount": 30}]
	var requirements := [
		{"item": "copper", "amount": 2},
		{"item": "lead", "amount": 4},
	]
	var research_cost_multipliers := {"copper": 1.0, "lead": 1.5}
	var research_cost_bridge := game.generated_block_research_requirements_research_cost_bridge_state(research_cost)
	var empty_bridge := game.generated_block_research_requirements_empty_bridge_state(null, 0.0)
	var loop_shape_bridge := game.generated_block_research_requirements_loop_shape_bridge_state(null, 1.25, requirements)
	var quantity_formula_bridge := game.generated_block_research_requirements_quantity_formula_bridge_state(null, 1.25, requirements, research_cost_multipliers)
	var round_amount_bridge := game.generated_block_research_requirements_round_amount_bridge_state(null, 1.25, requirements, research_cost_multipliers)
	var output_fill_bridge := game.generated_block_research_requirements_output_fill_bridge_state(null, 1.25, requirements, research_cost_multipliers)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var generated_bridge_matches := (
		bool(research_cost_bridge.get("matches", false))
		and bool(empty_bridge.get("matches", false))
		and bool(loop_shape_bridge.get("matches", false))
		and bool(quantity_formula_bridge.get("matches", false))
		and bool(round_amount_bridge.get("matches", false))
		and bool(output_fill_bridge.get("matches", false))
	)
	var proof := {
		"module": "BLOCK_RESEARCH_REQUIREMENTS_STATE_MODULE_PROOF",
		"research_cost_bridge_matches": research_cost_bridge == source_block_research_requirements_state.generated_block_research_requirements_research_cost_bridge_state(research_cost),
		"empty_bridge_matches": empty_bridge == source_block_research_requirements_state.generated_block_research_requirements_empty_bridge_state(null, 0.0),
		"loop_shape_bridge_matches": loop_shape_bridge == source_block_research_requirements_state.generated_block_research_requirements_loop_shape_bridge_state(null, 1.25, requirements),
		"quantity_formula_bridge_matches": quantity_formula_bridge == source_block_research_requirements_state.generated_block_research_requirements_quantity_formula_bridge_state(null, 1.25, requirements, research_cost_multipliers),
		"round_amount_bridge_matches": round_amount_bridge == source_block_research_requirements_state.generated_block_research_requirements_round_amount_bridge_state(null, 1.25, requirements, research_cost_multipliers),
		"output_fill_bridge_matches": output_fill_bridge == source_block_research_requirements_state.generated_block_research_requirements_output_fill_bridge_state(null, 1.25, requirements, research_cost_multipliers),
		"generated_bridge_matches": generated_bridge_matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = bool(proof.get("research_cost_bridge_matches", false)) and bool(proof.get("empty_bridge_matches", false)) and bool(proof.get("loop_shape_bridge_matches", false)) and bool(proof.get("quantity_formula_bridge_matches", false)) and bool(proof.get("round_amount_bridge_matches", false)) and bool(proof.get("output_fill_bridge_matches", false)) and generated_bridge_matches and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_RESEARCH_REQUIREMENTS_STATE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockResearchRequirementsStateModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
