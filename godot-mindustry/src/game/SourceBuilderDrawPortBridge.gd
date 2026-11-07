extends "res://src/game/SourceAbilityPortBridge.gd"

const source_builder_draw_state := preload("res://src/game/SourceBuilderDrawState.gd")

func source_builder_draw_plan_state(plan: Variant, all_plans: Array, plan_breaking: bool, alpha: float, build_valid_place: bool, control_input_plan_matches: bool) -> Dictionary:
	return source_builder_draw_state.draw_plan_state(plan, all_plans, plan_breaking, alpha, build_valid_place, control_input_plan_matches)

func generated_builder_comp_draw_plan_bridge_state(plan: Variant, all_plans: Array, plan_breaking: bool, alpha: float, build_valid_place: bool, control_input_plan_matches: bool) -> Dictionary:
	return source_builder_draw_state.generated_builder_comp_draw_plan_bridge_state(plan, all_plans, plan_breaking, alpha, build_valid_place, control_input_plan_matches)

func source_builder_draw_building_state(active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, core_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, is_local: bool, tile_block_is_construct_block: bool, state_is_paused: bool, type_draw_build_beam: bool, type_build_beam_offset: float, mathf_absin_time_3_0_6: float, x: float, y: float, rotation_value: float, angles_trnsx_rotation_focus_len: float, angles_trnsy_rotation_focus_len: float) -> Dictionary:
	return source_builder_draw_state.draw_building_state(active, last_active, build_plan, tile_exists, core_exists, within_plan, state_rules_infinite_resources, type_build_range, is_local, tile_block_is_construct_block, state_is_paused, type_draw_build_beam, type_build_beam_offset, mathf_absin_time_3_0_6, x, y, rotation_value, angles_trnsx_rotation_focus_len, angles_trnsy_rotation_focus_len)

func generated_builder_comp_draw_building_bridge_state(active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, core_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, is_local: bool, tile_block_is_construct_block: bool, state_is_paused: bool, type_draw_build_beam: bool, type_build_beam_offset: float, mathf_absin_time_3_0_6: float, x: float, y: float, rotation_value: float, angles_trnsx_rotation_focus_len: float, angles_trnsy_rotation_focus_len: float) -> Dictionary:
	return source_builder_draw_state.generated_builder_comp_draw_building_bridge_state(active, last_active, build_plan, tile_exists, core_exists, within_plan, state_rules_infinite_resources, type_build_range, is_local, tile_block_is_construct_block, state_is_paused, type_draw_build_beam, type_build_beam_offset, mathf_absin_time_3_0_6, x, y, rotation_value, angles_trnsx_rotation_focus_len, angles_trnsy_rotation_focus_len)

func source_builder_draw_building_beam_state(px: float, py: float, active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, plan_breaking: bool, tile_block_size: int, last_size: int, plan_block_size: int, plan_drawx: float, plan_drawy: float, build_alpha: float, tile_build_is_construct_build: bool, source_tilesize: float, mathf_absin_time_2_2_1_1: float, rotation_value: float) -> Dictionary:
	return source_builder_draw_state.draw_building_beam_state(px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build, source_tilesize, mathf_absin_time_2_2_1_1, rotation_value)

func generated_builder_comp_draw_building_beam_bridge_state(px: float, py: float, active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, plan_breaking: bool, tile_block_size: int, last_size: int, plan_block_size: int, plan_drawx: float, plan_drawy: float, build_alpha: float, tile_build_is_construct_build: bool, source_tilesize: float, mathf_absin_time_2_2_1_1: float, rotation_value: float) -> Dictionary:
	return source_builder_draw_state.generated_builder_comp_draw_building_beam_bridge_state(px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build, source_tilesize, mathf_absin_time_2_2_1_1, rotation_value)

func generated_builder_comp_draw_building_beam_source_tilesize_default_bridge_state(px: float, py: float, active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, plan_breaking: bool, tile_block_size: int, last_size: int, plan_block_size: int, plan_drawx: float, plan_drawy: float, build_alpha: float, tile_build_is_construct_build: bool) -> Dictionary:
	return source_builder_draw_state.generated_builder_comp_draw_building_beam_source_tilesize_default_bridge_state(px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build)

func source_builder_draw_plan_top_state(plan: Variant, plans: Array, plan_breaking: bool, alpha: float, mathf_absin_time_global_6_0_28: float) -> Dictionary:
	return source_builder_draw_state.draw_plan_top_state(plan, plans, plan_breaking, alpha, mathf_absin_time_global_6_0_28)

func generated_builder_comp_draw_plan_top_bridge_state(plan: Variant, plans: Array, plan_breaking: bool, alpha: float, mathf_absin_time_global_6_0_28: float) -> Dictionary:
	return source_builder_draw_state.generated_builder_comp_draw_plan_top_bridge_state(plan, plans, plan_breaking, alpha, mathf_absin_time_global_6_0_28)
