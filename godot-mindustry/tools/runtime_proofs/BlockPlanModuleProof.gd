extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_plan_state := preload("res://src/game/SourceBlockPlanState.gd")
const source_building_core_state := preload("res://src/game/SourceBuildingCoreState.gd")
const source_block_query_consumer_state := preload("res://src/game/SourceBlockQueryConsumerState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_block_plan_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_block_plan_state.SOURCE_BLOCK_PLAN_MOD_FLOAT_KEY: Callable(game, source_block_plan_state.SOURCE_BLOCK_PLAN_MOD_FLOAT_FALLBACK),
		source_block_plan_state.SOURCE_BLOCK_PLAN_ROTATION_KEY: Callable(game, source_block_plan_state.SOURCE_BLOCK_PLAN_ROTATION_FALLBACK),
	}
	var override_callbacks := source_block_plan_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_block_plan_state.SOURCE_BLOCK_PLAN_MOD_FLOAT_KEY, Callable()) == Callable(self, "proof_mod_float") \
		and override_callbacks.get(source_block_plan_state.SOURCE_BLOCK_PLAN_ROTATION_KEY, Callable()) == Callable(self, "proof_plan_rotation_state")
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var is_hidden_bridge := game.generated_block_is_hidden_bridge_state(false, false)
	var is_visible_bridge := game.generated_block_is_visible_bridge_state(false, false, true, false)
	var is_placeable_bridge := game.generated_block_is_placeable_bridge_state(true, false, false, true)
	var plan_rotation_bridge := game.generated_block_plan_rotation_bridge_state(true, false, 3)
	var flip_rotation_bridge := game.generated_block_flip_rotation_bridge_state(1, true, false, true, false)
	var game_flip_rotation := game.source_block_flip_rotation_state(1, true, false, true, false)
	var module_flip_rotation := source_block_plan_state.game_flip_rotation_state(game, 1, true, false, true, false)
	var override_flip_rotation := source_block_plan_state.game_flip_rotation_state(self, 1, true, false, true, false)
	var primitive_override_flip_rotation := source_block_plan_state.flip_rotation_state(1, true, false, true, false, Callable(self, "proof_mod_float"), Callable(self, "proof_plan_rotation_state"))
	var options_before := [{"id": "config-a"}]
	var content_items := [{"id": "copper"}]
	var content_liquids := [{"id": "water"}]
	var plan_configs_bridge := game.generated_block_get_plan_configs_bridge_state(options_before, true, true, content_items, content_liquids)
	var get_replacement_bridge := game.generated_block_get_replacement_bridge_state({"x": 4, "y": 5}, [{"id": "plan-a"}], "duo")
	var change_path_diagonal_bridge := game.generated_block_change_placement_path_diagonal_bridge_state([{"x": 1, "y": 1}], 2, true)
	var change_path_bridge := game.generated_block_change_placement_path_bridge_state([{"x": 2, "y": 3}], 1)
	var handle_line_bridge := game.generated_block_handle_placement_line_bridge_state([{"id": "line-plan"}])
	var config_senseable_bridge := game.generated_block_config_senseable_bridge_state(true, false, false, false, true)
	var next_config_bridge := game.generated_block_next_config_bridge_state(true, {"kind": "saved-config"})
	var on_new_plan_bridge := game.generated_block_on_new_plan_bridge_state({"id": "new-plan"})
	var draw_plan_default_alpha_bridge := game.generated_block_draw_plan_default_alpha_bridge_state({"id": "draw-plan"}, [{"id": "list"}], true)
	var draw_plan_bridge := game.generated_block_draw_plan_bridge_state({"id": "draw-plan"}, [{"id": "list"}], false, 0.75, 0.12)
	var draw_other_player_plan_bridge := game.generated_block_draw_other_player_plan_bridge_state({"id": "other-plan"}, [{"id": "list"}], 0.5)
	var draw_plan_region_bridge := game.generated_block_draw_plan_region_bridge_state({"id": "region-plan"}, [{"id": "list"}])
	var draw_default_plan_region_bridge := game.generated_block_draw_default_plan_region_bridge_state({"id": "default-region-plan"}, [{"id": "list"}], true, true, 2.0)
	var find_plan_default_size_bridge := game.generated_block_find_plan_default_size_bridge_state([{"id": "candidate"}], 5, 6, "predicate")
	var find_plan_bridge := game.generated_block_find_plan_bridge_state([{"id": "candidate"}], 5, 6, 2, "predicate", true, {"id": "found"})
	var get_plan_region_bridge := game.generated_block_get_plan_region_bridge_state({"id": "plan-region"}, [{"id": "list"}], "full-icon")
	var draw_plan_config_bridge := game.generated_block_draw_plan_config_bridge_state({"id": "config-plan"}, [{"id": "list"}])
	var draw_plan_config_center_bridge := game.generated_block_draw_plan_config_center_bridge_state({"id": "center-plan"}, "content", "region", false, "color")
	var draw_plan_config_center_default_cross_bridge := game.generated_block_draw_plan_config_center_default_cross_bridge_state({"id": "center-plan"}, "content", "region")
	var draw_plan_config_top_bridge := game.generated_block_draw_plan_config_top_bridge_state({"id": "top-plan"}, [{"id": "list"}])
	var plan_config_clip_size_bridge := game.generated_block_plan_config_clip_size_bridge_state(42.0)
	var point_config_bridge := game.generated_block_point_config_bridge_state({"x": 1, "y": 2}, "transformer")
	var direct_source_facades_match: bool = \
		game.source_block_can_replace_result_state(true, false, true, false, true, false, false, true, 2, 1, true, false) == source_building_core_state.block_can_replace_result_state(true, false, true, false, true, false, false, true, 2, 1, true, false) \
		and game.source_block_config_clear_state("clear-consumer") == source_block_plan_state.config_clear_state("clear-consumer") \
		and game.source_block_config_handler_state("Item.class", "config-handler") == source_block_plan_state.config_handler_state("Item.class", "config-handler") \
		and game.source_block_find_consumer_state(2, "builder", "consumer", "filter") == source_block_query_consumer_state.find_consumer_state(2, "builder", "consumer", "filter") \
		and game.source_block_find_plan_default_size_state([{"id": "candidate"}], 5, 6, "predicate") == source_block_plan_state.find_plan_default_size_state([{"id": "candidate"}], 5, 6, "predicate") \
		and game.source_block_find_plan_state([{"id": "candidate"}], 5, 6, 2, "predicate", true, {"id": "found"}) == source_block_plan_state.find_plan_state([{"id": "candidate"}], 5, 6, 2, "predicate", true, {"id": "found"}) \
		and game.source_block_get_edges_state(3) == source_block_plan_state.get_edges_state(3) \
		and game.source_block_get_inside_edges_state(3) == source_block_plan_state.get_inside_edges_state(3) \
		and game.source_block_get_plan_region_state({"id": "plan-region"}, [{"id": "list"}], "full-icon") == source_block_plan_state.get_plan_region_state({"id": "plan-region"}, [{"id": "list"}], "full-icon") \
		and game.source_block_get_replacement_state({"x": 4, "y": 5}, [{"id": "plan-a"}], "duo") == source_block_plan_state.get_replacement_state({"x": 4, "y": 5}, [{"id": "plan-a"}], "duo") \
		and game.source_block_is_accessible_state(true, 10) == source_block_plan_state.is_accessible_state(true, 10) \
		and game.source_block_iterate_taken_state(10, 20, 3, "placer") == source_block_plan_state.iterate_taken_state(10, 20, 3, "placer") \
		and game.source_block_nearby_side_state(10, 20, 2, 1, 3, "out") == source_block_plan_state.nearby_side_state(10, 20, 2, 1, 3, "out") \
		and game.source_block_change_placement_path_diagonal_state([{"x": 1, "y": 1}], 2, true) == source_block_plan_state.change_placement_path_diagonal_state([{"x": 1, "y": 1}], 2, true) \
		and game.source_block_change_placement_path_state([{"x": 2, "y": 3}], 1) == source_block_plan_state.change_placement_path_state([{"x": 2, "y": 3}], 1) \
		and game.source_block_handle_placement_line_state([{"id": "line-plan"}]) == source_block_plan_state.handle_placement_line_state([{"id": "line-plan"}]) \
		and game.source_block_config_senseable_state(true, false, false, false, true) == source_block_plan_state.config_senseable_state(true, false, false, false, true) \
		and game.source_block_next_config_state(true, {"kind": "saved-config"}) == source_block_plan_state.next_config_state(true, {"kind": "saved-config"}) \
		and game.source_block_on_new_plan_state({"id": "new-plan"}) == source_block_plan_state.on_new_plan_state({"id": "new-plan"}) \
		and game.source_block_draw_plan_default_alpha_state({"id": "draw-plan"}, [{"id": "list"}], true) == source_block_plan_state.draw_plan_default_alpha_state({"id": "draw-plan"}, [{"id": "list"}], true) \
		and game.source_block_draw_plan_state({"id": "draw-plan"}, [{"id": "list"}], false, 0.75, 0.12) == source_block_plan_state.draw_plan_state({"id": "draw-plan"}, [{"id": "list"}], false, 0.75, 0.12) \
		and game.source_block_draw_other_player_plan_state({"id": "other-plan"}, [{"id": "list"}], 0.5) == source_block_plan_state.draw_other_player_plan_state({"id": "other-plan"}, [{"id": "list"}], 0.5) \
		and game.source_block_draw_plan_region_state({"id": "region-plan"}, [{"id": "list"}]) == source_block_plan_state.draw_plan_region_state({"id": "region-plan"}, [{"id": "list"}]) \
		and game.source_block_draw_default_plan_region_state({"id": "default-region-plan"}, [{"id": "list"}], true, true, 2.0) == source_block_plan_state.draw_default_plan_region_state({"id": "default-region-plan"}, [{"id": "list"}], true, true, 2.0) \
		and game.source_block_draw_plan_config_state({"id": "config-plan"}, [{"id": "list"}]) == source_block_plan_state.draw_plan_config_state({"id": "config-plan"}, [{"id": "list"}]) \
		and game.source_block_draw_plan_config_center_state({"id": "center-plan"}, "content", "region", false, "color") == source_block_plan_state.draw_plan_config_center_state({"id": "center-plan"}, "content", "region", false, "color") \
		and game.source_block_draw_plan_config_center_default_cross_state({"id": "center-plan"}, "content", "region") == source_block_plan_state.draw_plan_config_center_default_cross_state({"id": "center-plan"}, "content", "region") \
		and game.source_block_draw_plan_config_top_state({"id": "top-plan"}, [{"id": "list"}]) == source_block_plan_state.draw_plan_config_top_state({"id": "top-plan"}, [{"id": "list"}]) \
		and game.source_block_plan_config_clip_size_state(42.0) == source_block_plan_state.plan_config_clip_size_state(42.0) \
		and game.source_block_point_config_state({"x": 1, "y": 2}, "transformer") == source_block_plan_state.point_config_state({"x": 1, "y": 2}, "transformer")
	var config_clear_bridge := game.generated_block_config_clear_bridge_state("clear-consumer")
	var config_handler_bridge := game.generated_block_config_handler_bridge_state("Item.class", "config-handler")
	var is_accessible_bridge := game.generated_block_is_accessible_bridge_state(true, 10)
	var nearby_side_bridge := game.generated_block_nearby_side_bridge_state(10, 20, 2, 1, 3, "out")
	var get_edges_bridge := game.generated_block_get_edges_bridge_state(3)
	var get_inside_edges_bridge := game.generated_block_get_inside_edges_bridge_state(3)
	var iterate_taken_bridge := game.generated_block_iterate_taken_bridge_state(10, 20, 3, "placer")
	var proof := {
		"module": "BLOCK_PLAN_MODULE_PROOF",
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"is_hidden_bridge": is_hidden_bridge,
		"is_visible_bridge": is_visible_bridge,
		"is_placeable_bridge": is_placeable_bridge,
		"plan_rotation_bridge": plan_rotation_bridge,
		"flip_rotation_bridge": flip_rotation_bridge,
		"plan_configs_bridge": plan_configs_bridge,
		"get_replacement_bridge": get_replacement_bridge,
		"change_path_diagonal_bridge": change_path_diagonal_bridge,
		"change_path_bridge": change_path_bridge,
		"handle_line_bridge": handle_line_bridge,
		"config_senseable_bridge": config_senseable_bridge,
		"next_config_bridge": next_config_bridge,
		"on_new_plan_bridge": on_new_plan_bridge,
		"draw_plan_default_alpha_bridge": draw_plan_default_alpha_bridge,
		"draw_plan_bridge": draw_plan_bridge,
		"draw_other_player_plan_bridge": draw_other_player_plan_bridge,
		"draw_plan_region_bridge": draw_plan_region_bridge,
		"draw_default_plan_region_bridge": draw_default_plan_region_bridge,
		"find_plan_default_size_bridge": find_plan_default_size_bridge,
		"find_plan_bridge": find_plan_bridge,
		"get_plan_region_bridge": get_plan_region_bridge,
		"draw_plan_config_bridge": draw_plan_config_bridge,
		"draw_plan_config_center_bridge": draw_plan_config_center_bridge,
		"draw_plan_config_center_default_cross_bridge": draw_plan_config_center_default_cross_bridge,
		"draw_plan_config_top_bridge": draw_plan_config_top_bridge,
		"plan_config_clip_size_bridge": plan_config_clip_size_bridge,
		"point_config_bridge": point_config_bridge,
		"direct_source_facades_match": direct_source_facades_match,
		"config_clear_bridge": config_clear_bridge,
		"config_handler_bridge": config_handler_bridge,
		"is_accessible_bridge": is_accessible_bridge,
		"nearby_side_bridge": nearby_side_bridge,
		"get_edges_bridge": get_edges_bridge,
		"get_inside_edges_bridge": get_inside_edges_bridge,
		"iterate_taken_bridge": iterate_taken_bridge,
		"is_hidden_bridge_matches": is_hidden_bridge == source_block_plan_state.generated_block_is_hidden_bridge_state(false, false),
		"is_visible_bridge_matches": is_visible_bridge == source_block_plan_state.generated_block_is_visible_bridge_state(false, false, true, false),
		"is_placeable_bridge_matches": is_placeable_bridge == source_block_plan_state.generated_block_is_placeable_bridge_state(true, false, false, true),
		"plan_rotation_bridge_matches": plan_rotation_bridge == source_block_plan_state.generated_block_plan_rotation_bridge_state(true, false, 3),
		"flip_rotation_bridge_matches": flip_rotation_bridge == source_block_plan_state.generated_block_flip_rotation_bridge_state(1, true, false, true, false),
		"game_flip_rotation_matches": game_flip_rotation == module_flip_rotation,
		"override_flip_rotation_matches": override_flip_rotation == primitive_override_flip_rotation,
		"plan_configs_bridge_matches": plan_configs_bridge == source_block_plan_state.generated_block_get_plan_configs_bridge_state(options_before, true, true, content_items, content_liquids),
		"get_replacement_bridge_matches": get_replacement_bridge == source_block_plan_state.generated_block_get_replacement_bridge_state({"x": 4, "y": 5}, [{"id": "plan-a"}], "duo"),
		"change_path_diagonal_bridge_matches": change_path_diagonal_bridge == source_block_plan_state.generated_block_change_placement_path_diagonal_bridge_state([{"x": 1, "y": 1}], 2, true),
		"change_path_bridge_matches": change_path_bridge == source_block_plan_state.generated_block_change_placement_path_bridge_state([{"x": 2, "y": 3}], 1),
		"handle_line_bridge_matches": handle_line_bridge == source_block_plan_state.generated_block_handle_placement_line_bridge_state([{"id": "line-plan"}]),
		"config_senseable_bridge_matches": config_senseable_bridge == source_block_plan_state.generated_block_config_senseable_bridge_state(true, false, false, false, true),
		"next_config_bridge_matches": next_config_bridge == source_block_plan_state.generated_block_next_config_bridge_state(true, {"kind": "saved-config"}),
		"on_new_plan_bridge_matches": on_new_plan_bridge == source_block_plan_state.generated_block_on_new_plan_bridge_state({"id": "new-plan"}),
		"draw_plan_default_alpha_bridge_matches": draw_plan_default_alpha_bridge == source_block_plan_state.generated_block_draw_plan_default_alpha_bridge_state({"id": "draw-plan"}, [{"id": "list"}], true),
		"draw_plan_bridge_matches": draw_plan_bridge == source_block_plan_state.generated_block_draw_plan_bridge_state({"id": "draw-plan"}, [{"id": "list"}], false, 0.75, 0.12),
		"draw_other_player_plan_bridge_matches": draw_other_player_plan_bridge == source_block_plan_state.generated_block_draw_other_player_plan_bridge_state({"id": "other-plan"}, [{"id": "list"}], 0.5),
		"draw_plan_region_bridge_matches": draw_plan_region_bridge == source_block_plan_state.generated_block_draw_plan_region_bridge_state({"id": "region-plan"}, [{"id": "list"}]),
		"draw_default_plan_region_bridge_matches": draw_default_plan_region_bridge == source_block_plan_state.generated_block_draw_default_plan_region_bridge_state({"id": "default-region-plan"}, [{"id": "list"}], true, true, 2.0),
		"find_plan_default_size_bridge_matches": find_plan_default_size_bridge == source_block_plan_state.generated_block_find_plan_default_size_bridge_state([{"id": "candidate"}], 5, 6, "predicate"),
		"find_plan_bridge_matches": find_plan_bridge == source_block_plan_state.generated_block_find_plan_bridge_state([{"id": "candidate"}], 5, 6, 2, "predicate", true, {"id": "found"}),
		"get_plan_region_bridge_matches": get_plan_region_bridge == source_block_plan_state.generated_block_get_plan_region_bridge_state({"id": "plan-region"}, [{"id": "list"}], "full-icon"),
		"draw_plan_config_bridge_matches": draw_plan_config_bridge == source_block_plan_state.generated_block_draw_plan_config_bridge_state({"id": "config-plan"}, [{"id": "list"}]),
		"draw_plan_config_center_bridge_matches": draw_plan_config_center_bridge == source_block_plan_state.generated_block_draw_plan_config_center_bridge_state({"id": "center-plan"}, "content", "region", false, "color"),
		"draw_plan_config_center_default_cross_bridge_matches": draw_plan_config_center_default_cross_bridge == source_block_plan_state.generated_block_draw_plan_config_center_default_cross_bridge_state({"id": "center-plan"}, "content", "region"),
		"draw_plan_config_top_bridge_matches": draw_plan_config_top_bridge == source_block_plan_state.generated_block_draw_plan_config_top_bridge_state({"id": "top-plan"}, [{"id": "list"}]),
		"plan_config_clip_size_bridge_matches": plan_config_clip_size_bridge == source_block_plan_state.generated_block_plan_config_clip_size_bridge_state(42.0),
		"point_config_bridge_matches": point_config_bridge == source_block_plan_state.generated_block_point_config_bridge_state({"x": 1, "y": 2}, "transformer"),
		"config_clear_bridge_matches": config_clear_bridge == source_block_plan_state.generated_block_config_clear_bridge_state("clear-consumer"),
		"config_handler_bridge_matches": config_handler_bridge == source_block_plan_state.generated_block_config_handler_bridge_state("Item.class", "config-handler"),
		"is_accessible_bridge_matches": is_accessible_bridge == source_block_plan_state.generated_block_is_accessible_bridge_state(true, 10),
		"nearby_side_bridge_matches": nearby_side_bridge == source_block_plan_state.generated_block_nearby_side_bridge_state(10, 20, 2, 1, 3, "out"),
		"get_edges_bridge_matches": get_edges_bridge == source_block_plan_state.generated_block_get_edges_bridge_state(3),
		"get_inside_edges_bridge_matches": get_inside_edges_bridge == source_block_plan_state.generated_block_get_inside_edges_bridge_state(3),
		"iterate_taken_bridge_matches": iterate_taken_bridge == source_block_plan_state.generated_block_iterate_taken_bridge_state(10, 20, 3, "placer"),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["direct_source_facades_match"] and bool(is_hidden_bridge.get("matches", false)) and bool(is_visible_bridge.get("matches", false)) and bool(is_placeable_bridge.get("matches", false)) and bool(plan_rotation_bridge.get("matches", false)) and bool(flip_rotation_bridge.get("matches", false)) and bool(plan_configs_bridge.get("matches", false)) and bool(get_replacement_bridge.get("matches", false)) and bool(change_path_diagonal_bridge.get("matches", false)) and bool(change_path_bridge.get("matches", false)) and bool(handle_line_bridge.get("matches", false)) and bool(config_senseable_bridge.get("matches", false)) and bool(next_config_bridge.get("matches", false)) and bool(on_new_plan_bridge.get("matches", false)) and bool(draw_plan_default_alpha_bridge.get("matches", false)) and bool(draw_plan_bridge.get("matches", false)) and bool(draw_other_player_plan_bridge.get("matches", false)) and bool(draw_plan_region_bridge.get("matches", false)) and bool(draw_default_plan_region_bridge.get("matches", false)) and bool(find_plan_default_size_bridge.get("matches", false)) and bool(find_plan_bridge.get("matches", false)) and bool(get_plan_region_bridge.get("matches", false)) and bool(draw_plan_config_bridge.get("matches", false)) and bool(draw_plan_config_center_bridge.get("matches", false)) and bool(draw_plan_config_center_default_cross_bridge.get("matches", false)) and bool(draw_plan_config_top_bridge.get("matches", false)) and bool(plan_config_clip_size_bridge.get("matches", false)) and bool(point_config_bridge.get("matches", false)) and bool(config_clear_bridge.get("matches", false)) and bool(config_handler_bridge.get("matches", false)) and bool(is_accessible_bridge.get("matches", false)) and bool(nearby_side_bridge.get("matches", false)) and bool(get_edges_bridge.get("matches", false)) and bool(get_inside_edges_bridge.get("matches", false)) and bool(iterate_taken_bridge.get("matches", false)) and proof["is_hidden_bridge_matches"] and proof["is_visible_bridge_matches"] and proof["is_placeable_bridge_matches"] and proof["plan_rotation_bridge_matches"] and proof["flip_rotation_bridge_matches"] and proof["game_flip_rotation_matches"] and proof["override_flip_rotation_matches"] and proof["plan_configs_bridge_matches"] and proof["get_replacement_bridge_matches"] and proof["change_path_diagonal_bridge_matches"] and proof["change_path_bridge_matches"] and proof["handle_line_bridge_matches"] and proof["config_senseable_bridge_matches"] and proof["next_config_bridge_matches"] and proof["on_new_plan_bridge_matches"] and proof["draw_plan_default_alpha_bridge_matches"] and proof["draw_plan_bridge_matches"] and proof["draw_other_player_plan_bridge_matches"] and proof["draw_plan_region_bridge_matches"] and proof["draw_default_plan_region_bridge_matches"] and proof["find_plan_default_size_bridge_matches"] and proof["find_plan_bridge_matches"] and proof["get_plan_region_bridge_matches"] and proof["draw_plan_config_bridge_matches"] and proof["draw_plan_config_center_bridge_matches"] and proof["draw_plan_config_center_default_cross_bridge_matches"] and proof["draw_plan_config_top_bridge_matches"] and proof["plan_config_clip_size_bridge_matches"] and proof["point_config_bridge_matches"] and proof["config_clear_bridge_matches"] and proof["config_handler_bridge_matches"] and proof["is_accessible_bridge_matches"] and proof["nearby_side_bridge_matches"] and proof["get_edges_bridge_matches"] and proof["get_inside_edges_bridge_matches"] and proof["iterate_taken_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BLOCK_PLAN_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BlockPlanModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

func proof_mod_float(value: float, divisor: float) -> float:
	return fmod(fmod(value, divisor) + divisor, divisor)

func proof_plan_rotation_state(rotate_value: bool, lock_rotation: bool, rot: int) -> Dictionary:
	return source_block_plan_state.plan_rotation_state(rotate_value, lock_rotation, rot)

func _block_plan_method_names() -> Dictionary:
	return {
		source_block_plan_state.SOURCE_BLOCK_PLAN_MOD_FLOAT_KEY: "proof_mod_float",
		source_block_plan_state.SOURCE_BLOCK_PLAN_ROTATION_KEY: "proof_plan_rotation_state",
	}
