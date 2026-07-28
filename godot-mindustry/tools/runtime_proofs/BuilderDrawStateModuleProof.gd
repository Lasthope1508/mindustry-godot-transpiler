extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBuilderDrawState := preload("res://src/game/SourceBuilderDrawState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var draw_plan_top_bridge := game.generated_builder_comp_draw_plan_top_bridge_state({"id": "top"}, [], false, 0.5, 0.2)
	var draw_plan_bridge := game.generated_builder_comp_draw_plan_bridge_state({"id": "plan"}, [], false, 0.5, true, false)
	var draw_building_bridge := game.generated_builder_comp_draw_building_bridge_state(true, null, {"id": "build"}, true, true, true, false, 8.0, true, false, false, true, 1.0, 0.3, 10.0, 20.0, 30.0, 0.0, 0.0)
	var draw_building_beam_bridge := game.generated_builder_comp_draw_building_beam_bridge_state(1.0, 2.0, true, null, {"id": "beam"}, true, true, false, 8.0, false, 2, 3, 4, 5.0, 6.0, 0.7, true, 8.0, 0.1, 45.0)
	var draw_building_beam_default_bridge := game.generated_builder_comp_draw_building_beam_source_tilesize_default_bridge_state(1.0, 2.0, true, null, {"id": "beam"}, true, true, false, 8.0, false, 2, 3, 4, 5.0, 6.0, 0.7, true)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDER_DRAW_STATE_MODULE_PROOF",
		"draw_plan_top_bridge": draw_plan_top_bridge,
		"draw_plan_bridge": draw_plan_bridge,
		"draw_building_bridge": draw_building_bridge,
		"draw_building_beam_bridge": draw_building_beam_bridge,
		"draw_building_beam_default_bridge": draw_building_beam_default_bridge,
		"draw_plan_top_bridge_matches": draw_plan_top_bridge == SourceBuilderDrawState.generated_builder_comp_draw_plan_top_bridge_state({"id": "top"}, [], false, 0.5, 0.2),
		"draw_plan_bridge_matches": draw_plan_bridge == SourceBuilderDrawState.generated_builder_comp_draw_plan_bridge_state({"id": "plan"}, [], false, 0.5, true, false),
		"draw_building_bridge_matches": draw_building_bridge == SourceBuilderDrawState.generated_builder_comp_draw_building_bridge_state(true, null, {"id": "build"}, true, true, true, false, 8.0, true, false, false, true, 1.0, 0.3, 10.0, 20.0, 30.0, 0.0, 0.0),
		"draw_building_beam_bridge_matches": draw_building_beam_bridge == SourceBuilderDrawState.generated_builder_comp_draw_building_beam_bridge_state(1.0, 2.0, true, null, {"id": "beam"}, true, true, false, 8.0, false, 2, 3, 4, 5.0, 6.0, 0.7, true, 8.0, 0.1, 45.0),
		"draw_building_beam_default_bridge_matches": draw_building_beam_default_bridge == SourceBuilderDrawState.generated_builder_comp_draw_building_beam_source_tilesize_default_bridge_state(1.0, 2.0, true, null, {"id": "beam"}, true, true, false, 8.0, false, 2, 3, 4, 5.0, 6.0, 0.7, true),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["draw_plan_top_bridge_matches"] and proof["draw_plan_bridge_matches"] and proof["draw_building_bridge_matches"] and proof["draw_building_beam_bridge_matches"] and proof["draw_building_beam_default_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BUILDER_DRAW_STATE_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BuilderDrawStateModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
