extends "res://src/game/SourceBuildingLiquidPortBridge.gd"

const source_block_producer_state := preload("res://src/game/SourceBlockProducerState.gd")
const source_block_producer_build_update_state := preload("res://src/game/SourceBlockProducerBuildUpdateState.gd")
const source_block_producer_move_out_payload_state := preload("res://src/game/SourceBlockProducerMoveOutPayloadState.gd")

func source_block_producer_icons_state(region: Variant, out_region: Variant, top_region: Variant) -> Dictionary:
	return source_block_producer_state.icons_state(region, out_region, top_region)

func generated_block_producer_icons_bridge_state(region: Variant, out_region: Variant, top_region: Variant) -> Dictionary:
	return source_block_producer_state.generated_block_producer_icons_bridge_state(region, out_region, top_region)

func source_block_producer_draw_plan_region_state(region: Variant, out_region: Variant, top_region: Variant, plan_drawx: float, plan_drawy: float, plan_rotation: float) -> Dictionary:
	return source_block_producer_state.draw_plan_region_state(region, out_region, top_region, plan_drawx, plan_drawy, plan_rotation)

func generated_block_producer_draw_plan_region_bridge_state(region: Variant, out_region: Variant, top_region: Variant, plan_drawx: float, plan_drawy: float, plan_rotation: float) -> Dictionary:
	return source_block_producer_state.generated_block_producer_draw_plan_region_bridge_state(region, out_region, top_region, plan_drawx, plan_drawy, plan_rotation)

func source_block_producer_set_bars_state(recipe_null: bool, entity_progress: float, recipe_build_time: float) -> Dictionary:
	return source_block_producer_state.set_bars_state(recipe_null, entity_progress, recipe_build_time)

func generated_block_producer_set_bars_bridge_state(recipe_null: bool, entity_progress: float, recipe_build_time: float) -> Dictionary:
	return source_block_producer_state.generated_block_producer_set_bars_bridge_state(recipe_null, entity_progress, recipe_build_time)

func source_block_producer_build_accept_item_state(source_building: Variant, item: Variant, item_count: int, maximum_accepted: int) -> Dictionary:
	return source_block_producer_state.build_accept_item_state(source_building, item, item_count, maximum_accepted)

func generated_block_producer_build_accept_item_bridge_state(source_building: Variant, item: Variant, item_count: int, maximum_accepted: int) -> Dictionary:
	return source_block_producer_state.generated_block_producer_build_accept_item_bridge_state(source_building, item, item_count, maximum_accepted)

func source_block_producer_build_get_maximum_accepted_state(item: Variant, recipe_null: bool, requirements: Array) -> Dictionary:
	return source_block_producer_state.build_get_maximum_accepted_state(item, recipe_null, requirements)

func generated_block_producer_build_get_maximum_accepted_bridge_state(item: Variant, recipe_null: bool, requirements: Array) -> Dictionary:
	return source_block_producer_state.generated_block_producer_build_get_maximum_accepted_bridge_state(item, recipe_null, requirements)

func source_block_producer_build_accept_payload_state(source_building: Variant, payload: Variant) -> Dictionary:
	return source_block_producer_state.build_accept_payload_state(source_building, payload)

func generated_block_producer_build_accept_payload_bridge_state(source_building: Variant, payload: Variant) -> Dictionary:
	return source_block_producer_state.generated_block_producer_build_accept_payload_bridge_state(source_building, payload)

func source_block_producer_build_should_consume_state(super_should_consume: bool, recipe_null: bool) -> Dictionary:
	return source_block_producer_state.build_should_consume_state(super_should_consume, recipe_null)

func generated_block_producer_build_should_consume_bridge_state(super_should_consume: bool, recipe_null: bool) -> Dictionary:
	return source_block_producer_state.generated_block_producer_build_should_consume_bridge_state(super_should_consume, recipe_null)

func source_block_producer_build_update_tile_produce_gate_state(recipe_null: bool, efficiency: float, payload_null: bool) -> Dictionary:
	return source_block_producer_build_update_state.produce_gate_state(recipe_null, efficiency, payload_null)

func generated_block_producer_build_update_tile_produce_gate_bridge_state(recipe_null: bool, efficiency: float, payload_null: bool) -> Dictionary:
	return source_block_producer_build_update_state.generated_block_producer_build_update_tile_produce_gate_bridge_state(recipe_null, efficiency, payload_null)

func source_block_producer_build_update_tile_progress_accumulation_state(produce: bool, progress_before: float, build_speed: float, edelta: float) -> Dictionary:
	return source_block_producer_build_update_state.progress_accumulation_state(produce, progress_before, build_speed, edelta)

func generated_block_producer_build_update_tile_progress_accumulation_bridge_state(produce: bool, progress_before: float, build_speed: float, edelta: float) -> Dictionary:
	return source_block_producer_build_update_state.generated_block_producer_build_update_tile_progress_accumulation_bridge_state(produce, progress_before, build_speed, edelta)

func source_block_producer_build_update_tile_completion_guard_state(progress: float, recipe_build_time: float) -> Dictionary:
	return source_block_producer_build_update_state.completion_guard_state(progress, recipe_build_time)

func generated_block_producer_build_update_tile_completion_guard_bridge_state(progress: float, recipe_build_time: float) -> Dictionary:
	return source_block_producer_build_update_state.generated_block_producer_build_update_tile_completion_guard_bridge_state(progress, recipe_build_time)

func source_block_producer_build_update_tile_payload_creation_state(completion_guard: bool, recipe: Variant, team: Variant, x: float, y: float, payload_size: float, tilesize: float) -> Dictionary:
	return source_block_producer_build_update_state.payload_creation_state(completion_guard, recipe, team, x, y, payload_size, tilesize)

func generated_block_producer_build_update_tile_payload_creation_bridge_state(completion_guard: bool, recipe: Variant, team: Variant, x: float, y: float, payload_size: float, tilesize: float) -> Dictionary:
	return source_block_producer_build_update_state.generated_block_producer_build_update_tile_payload_creation_bridge_state(completion_guard, recipe, team, x, y, payload_size, tilesize)

func source_block_producer_build_update_tile_pay_vector_progress_reset_state(completion_guard: bool, pay_vector_x: float, pay_vector_y: float, progress_before: float) -> Dictionary:
	return source_block_producer_build_update_state.pay_vector_progress_reset_state(completion_guard, pay_vector_x, pay_vector_y, progress_before)

func generated_block_producer_build_update_tile_pay_vector_progress_reset_bridge_state(completion_guard: bool, pay_vector_x: float, pay_vector_y: float, progress_before: float) -> Dictionary:
	return source_block_producer_build_update_state.generated_block_producer_build_update_tile_pay_vector_progress_reset_bridge_state(completion_guard, pay_vector_x, pay_vector_y, progress_before)

func source_block_producer_build_update_tile_heat_time_state(produce: bool, heat_before: float, time_before: float, time_delta: float) -> Dictionary:
	return source_block_producer_build_update_state.heat_time_state(produce, heat_before, time_before, time_delta)

func generated_block_producer_build_update_tile_heat_time_bridge_state(produce: bool, heat_before: float, time_before: float, time_delta: float) -> Dictionary:
	return source_block_producer_build_update_state.generated_block_producer_build_update_tile_heat_time_bridge_state(produce, heat_before, time_before, time_delta)

func source_block_producer_build_update_tile_move_out_payload_state(payload_present: bool, pay_vector_x: float, pay_vector_y: float, pay_rotation_before: float, rotdeg_value: float, size_value: float, tilesize: float, payload_rotate_speed: float, payload_speed: float, time_delta: float, front_present: bool, front_solid: bool, front_outputs_payload: bool, front_accepts_payload: bool, move_payload_result: bool) -> Dictionary:
	return source_block_producer_move_out_payload_state.move_out_payload_state(payload_present, pay_vector_x, pay_vector_y, pay_rotation_before, rotdeg_value, size_value, tilesize, payload_rotate_speed, payload_speed, time_delta, front_present, front_solid, front_outputs_payload, front_accepts_payload, move_payload_result)

func generated_block_producer_build_update_tile_move_out_payload_bridge_state(payload_present: bool, pay_vector_x: float, pay_vector_y: float, pay_rotation_before: float, rotdeg_value: float, size_value: float, tilesize: float, payload_rotate_speed: float, payload_speed: float, time_delta: float, front_present: bool, front_solid: bool, front_outputs_payload: bool, front_accepts_payload: bool, move_payload_result: bool) -> Dictionary:
	return source_block_producer_move_out_payload_state.generated_block_producer_build_update_tile_move_out_payload_bridge_state(payload_present, pay_vector_x, pay_vector_y, pay_rotation_before, rotdeg_value, size_value, tilesize, payload_rotate_speed, payload_speed, time_delta, front_present, front_solid, front_outputs_payload, front_accepts_payload, move_payload_result)
