extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_builder_draw_state := preload("res://src/game/SourceBuilderDrawState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var draw_plan_top_bridge := game.generated_builder_comp_draw_plan_top_bridge_state({"id": "top"}, [], false, 0.5, 0.2)
	var draw_plan_bridge := game.generated_builder_comp_draw_plan_bridge_state({"id": "plan"}, [], false, 0.5, true, false)
	var draw_building_bridge := game.generated_builder_comp_draw_building_bridge_state(true, null, {"id": "build"}, true, true, true, false, 8.0, true, false, false, true, 1.0, 0.3, 10.0, 20.0, 30.0, 0.0, 0.0)
	var draw_building_beam_bridge := game.generated_builder_comp_draw_building_beam_bridge_state(1.0, 2.0, true, null, {"id": "beam"}, true, true, false, 8.0, false, 2, 3, 4, 5.0, 6.0, 0.7, true, 8.0, 0.1, 45.0)
	var draw_building_beam_default_bridge := game.generated_builder_comp_draw_building_beam_source_tilesize_default_bridge_state(1.0, 2.0, true, null, {"id": "beam"}, true, true, false, 8.0, false, 2, 3, 4, 5.0, 6.0, 0.7, true)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDER_DRAW_STATE_MODULE_PROOF",
		"draw_plan_top_bridge": draw_plan_top_bridge,
		"draw_plan_bridge": draw_plan_bridge,
		"draw_building_bridge": draw_building_bridge,
		"draw_building_beam_bridge": draw_building_beam_bridge,
		"draw_building_beam_default_bridge": draw_building_beam_default_bridge,
		"draw_plan_top_bridge_matches": draw_plan_top_bridge == source_builder_draw_state.generated_builder_comp_draw_plan_top_bridge_state({"id": "top"}, [], false, 0.5, 0.2),
		"draw_plan_bridge_matches": draw_plan_bridge == source_builder_draw_state.generated_builder_comp_draw_plan_bridge_state({"id": "plan"}, [], false, 0.5, true, false),
		"draw_building_bridge_matches": draw_building_bridge == source_builder_draw_state.generated_builder_comp_draw_building_bridge_state(true, null, {"id": "build"}, true, true, true, false, 8.0, true, false, false, true, 1.0, 0.3, 10.0, 20.0, 30.0, 0.0, 0.0),
		"draw_building_beam_bridge_matches": draw_building_beam_bridge == source_builder_draw_state.generated_builder_comp_draw_building_beam_bridge_state(1.0, 2.0, true, null, {"id": "beam"}, true, true, false, 8.0, false, 2, 3, 4, 5.0, 6.0, 0.7, true, 8.0, 0.1, 45.0),
		"draw_building_beam_default_bridge_matches": draw_building_beam_default_bridge == source_builder_draw_state.generated_builder_comp_draw_building_beam_source_tilesize_default_bridge_state(1.0, 2.0, true, null, {"id": "beam"}, true, true, false, 8.0, false, 2, 3, 4, 5.0, 6.0, 0.7, true),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["draw_plan_top_bridge_matches"] and proof["draw_plan_bridge_matches"] and proof["draw_building_bridge_matches"] and proof["draw_building_beam_bridge_matches"] and proof["draw_building_beam_default_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BUILDER_DRAW_STATE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BuilderDrawStateModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
