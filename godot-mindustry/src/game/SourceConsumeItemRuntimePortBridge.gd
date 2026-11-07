extends "res://src/game/SourceConsumePortBridge.gd"

func source_consume_item_dynamic_constructor_state(items: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.constructor_state(items)

func generated_consume_item_dynamic_constructor_bridge_state(items: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_generated_state.generated_constructor_bridge_state(items)

func source_consume_item_efficiency_constructor_state(item: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_efficiency_state.constructor_state(item)

func generated_consume_item_efficiency_constructor_bridge_state(item: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_efficiency_generated_state.generated_constructor_bridge_state(item)

func source_consume_item_efficiency_default_constructor_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_efficiency_state.default_constructor_state(source_consumer_defaults.CONSUME_ITEM_FILTER_DEFAULT_EXPR)

func generated_consume_item_efficiency_default_constructor_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_efficiency_generated_state.generated_default_constructor_bridge_state(source_consumer_defaults.CONSUME_ITEM_FILTER_DEFAULT_EXPR)

func source_consume_item_dynamic_apply_state(block_has_items_before: bool, block_accepts_items_before: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.apply_state(block_has_items_before, block_accepts_items_before)

func generated_consume_item_dynamic_apply_bridge_state(block_has_items_before: bool, block_accepts_items_before: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_generated_state.generated_apply_bridge_state(block_has_items_before, block_accepts_items_before)

func source_consume_item_dynamic_build_state(current_item_ids: Array, next_item_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.build_state(current_item_ids, next_item_ids)

func generated_consume_item_dynamic_build_bridge_state(current_item_ids: Array, next_item_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_generated_state.generated_build_bridge_state(current_item_ids, next_item_ids)

func source_consume_item_dynamic_rebuild_state(item_ids: Array, item_stack_amounts: Array, item_amounts: Array, building_has_items: bool, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.rebuild_state(item_ids, item_stack_amounts, item_amounts, building_has_items, multiplier_get_build, source_consume_port_bridge_ui_defaults.PAD_RIGHT)

func generated_consume_item_dynamic_rebuild_bridge_state(item_ids: Array, item_stack_amounts: Array, item_amounts: Array, building_has_items: bool, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_generated_state.generated_rebuild_bridge_state(item_ids, item_stack_amounts, item_amounts, building_has_items, multiplier_get_build, source_consume_port_bridge_ui_defaults.PAD_RIGHT)

func source_consume_item_dynamic_trigger_state(item_ids: Array, item_stack_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.trigger_state(item_ids, item_stack_amounts, multiplier_get_build)

func generated_consume_item_dynamic_trigger_bridge_state(item_ids: Array, item_stack_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_generated_state.generated_trigger_bridge_state(item_ids, item_stack_amounts, multiplier_get_build)

func source_consume_item_dynamic_efficiency_state(consume_trigger_valid: bool, item_ids: Array, item_stack_amounts: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.efficiency_state(consume_trigger_valid, item_ids, item_stack_amounts, item_amounts, multiplier_get_build)

func generated_consume_item_dynamic_efficiency_bridge_state(consume_trigger_valid: bool, item_ids: Array, item_stack_amounts: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_generated_state.generated_efficiency_bridge_state(consume_trigger_valid, item_ids, item_stack_amounts, item_amounts, multiplier_get_build)

func source_consume_item_efficiency_display_state(booster: bool, stats_time_period: float, filtered_item_ids: Array, item_efficiency_multipliers: Array, item_duration_multipliers: Array, table_has_cells: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_item_efficiency_state.display_state(booster, stats_time_period, filtered_item_ids, item_efficiency_multipliers, item_duration_multipliers, table_has_cells, source_time_defaults.TICK_RATE)

func generated_consume_item_efficiency_display_bridge_state(booster: bool, stats_time_period: float, filtered_item_ids: Array, item_efficiency_multipliers: Array, item_duration_multipliers: Array, table_has_cells: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_item_efficiency_generated_state.generated_display_bridge_state(booster, stats_time_period, filtered_item_ids, item_efficiency_multipliers, item_duration_multipliers, table_has_cells, source_time_defaults.TICK_RATE)
