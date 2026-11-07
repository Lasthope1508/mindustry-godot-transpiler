extends "res://src/game/SourceBuilderDrawPortBridge.gd"

const source_builder_runtime_state := preload("res://src/game/SourceBuilderRuntimeState.gd")

func source_builder_can_build_state(type_build_speed: float, build_speed_multiplier: float) -> Dictionary:
	return source_builder_runtime_state.can_build_state(type_build_speed, build_speed_multiplier)

func generated_builder_comp_can_build_bridge_state(type_build_speed: float, build_speed_multiplier: float) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_can_build_bridge_state(type_build_speed, build_speed_multiplier)

func source_builder_update_state() -> Dictionary:
	return source_builder_runtime_state.update_state()

func generated_builder_comp_update_bridge_state() -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_update_bridge_state()

func source_builder_after_read_state(plans_null: bool) -> Dictionary:
	return source_builder_runtime_state.after_read_state(plans_null)

func generated_builder_comp_after_read_bridge_state(plans_null: bool) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_after_read_bridge_state(plans_null)

func source_builder_is_building_state(plans_size: int) -> Dictionary:
	return source_builder_runtime_state.is_building_state(plans_size)

func generated_builder_comp_is_building_bridge_state(plans_size: int) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_is_building_bridge_state(plans_size)

func source_builder_clear_building_state() -> Dictionary:
	return source_builder_runtime_state.clear_building_state()

func generated_builder_comp_clear_building_bridge_state() -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_clear_building_bridge_state()

func source_builder_should_skip_state(state_rules_infinite_resources: bool, team_rules_infinite_resources: bool, plan_breaking: bool, core_null: bool, plan_is_rotation: bool, plan_is_derelict_repair: bool, plan_stuck: bool, core_items_has_plan_block_requirements: bool, structs_contains_missing_requirement: bool) -> Dictionary:
	return source_builder_runtime_state.should_skip_state(state_rules_infinite_resources, team_rules_infinite_resources, plan_breaking, core_null, plan_is_rotation, plan_is_derelict_repair, plan_stuck, core_items_has_plan_block_requirements, structs_contains_missing_requirement)

func generated_builder_comp_should_skip_bridge_state(state_rules_infinite_resources: bool, team_rules_infinite_resources: bool, plan_breaking: bool, core_null: bool, plan_is_rotation: bool, plan_is_derelict_repair: bool, plan_stuck: bool, core_items_has_plan_block_requirements: bool, structs_contains_missing_requirement: bool) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_should_skip_bridge_state(state_rules_infinite_resources, team_rules_infinite_resources, plan_breaking, core_null, plan_is_rotation, plan_is_derelict_repair, plan_stuck, core_items_has_plan_block_requirements, structs_contains_missing_requirement)

func source_builder_remove_build_state(plans: Array, x: int, y: int, breaking: bool) -> Dictionary:
	return source_builder_runtime_state.remove_build_state(plans, x, y, breaking)

func generated_builder_comp_remove_build_bridge_state(plans: Array, x: int, y: int, breaking: bool) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_remove_build_bridge_state(plans, x, y, breaking)

func source_builder_add_build_tail_state(place: Variant) -> Dictionary:
	return source_builder_runtime_state.add_build_tail_state(place)

func generated_builder_comp_add_build_tail_bridge_state(place: Variant) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_add_build_tail_bridge_state(place)

func source_builder_add_build_state(plans: Array, place: Variant, tail: bool, can_build: bool, world_tile_exists: bool, tile_build_is_construct_build: bool, construct_progress: float) -> Dictionary:
	return source_builder_runtime_state.add_build_state(plans, place, tail, can_build, world_tile_exists, tile_build_is_construct_build, construct_progress)

func generated_builder_comp_add_build_bridge_state(plans: Array, place: Variant, tail: bool, can_build: bool, world_tile_exists: bool, tile_build_is_construct_build: bool, construct_progress: float) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_add_build_bridge_state(plans, place, tail, can_build, world_tile_exists, tile_build_is_construct_build, construct_progress)

func source_builder_build_plan_state(plans_size: int, plans_first: Variant) -> Dictionary:
	return source_builder_runtime_state.build_plan_state(plans_size, plans_first)

func generated_builder_comp_build_plan_bridge_state(plans_size: int, plans_first: Variant) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_build_plan_bridge_state(plans_size, plans_first)

func source_builder_actively_building_state(plans_size: int, plans_first: Variant, state_is_editor: bool, state_rules_infinite_resources: bool, type_build_range: float, within_plan: bool, update_building: bool) -> Dictionary:
	return source_builder_runtime_state.actively_building_state(plans_size, plans_first, state_is_editor, state_rules_infinite_resources, type_build_range, within_plan, update_building)

func source_builder_build_step_state(entity_build_cost: float, type_build_speed: float, build_speed_multiplier: float, team_build_speed: float, current_breaking: bool, allow_build_current: bool) -> Dictionary:
	return source_builder_runtime_state.build_step_state(entity_build_cost, type_build_speed, build_speed_multiplier, team_build_speed, current_breaking, allow_build_current)

func generated_builder_comp_update_build_logic_bridge_state(entity_build_cost: float, type_build_speed: float, build_speed_multiplier: float, team_build_speed: float, current_breaking: bool, allow_build_current: bool) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_update_build_logic_bridge_state(entity_build_cost, type_build_speed, build_speed_multiplier, team_build_speed, current_breaking, allow_build_current)

func generated_builder_comp_actively_building_bridge_state(plans_size: int, plans_first: Variant, state_is_editor: bool, state_rules_infinite_resources: bool, type_build_range: float, within_plan: bool, update_building: bool) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_actively_building_bridge_state(plans_size, plans_first, state_is_editor, state_rules_infinite_resources, type_build_range, within_plan, update_building)
