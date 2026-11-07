extends "res://src/game/SourceConsumeItemFilterPortBridge.gd"

func source_consume_item_list_set_multipliers_state(objects: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_list_state.set_multipliers_state(objects)

func generated_consume_item_list_set_multipliers_bridge_state(objects: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_list_generated_state.generated_set_multipliers_bridge_state(objects)

func source_consume_item_list_efficiency_multiplier_state(consumed_item: Variant, item_multiplier_value: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_list_state.efficiency_multiplier_state(consumed_item, item_multiplier_value)

func generated_consume_item_list_efficiency_multiplier_bridge_state(consumed_item: Variant, item_multiplier_value: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_list_generated_state.generated_efficiency_multiplier_bridge_state(consumed_item, item_multiplier_value)

func source_consume_item_explode_build_state(build: Variant, table: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_explode_state.build_state(build, table)

func generated_consume_item_explode_build_bridge_state(build: Variant, table: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_explode_generated_state.generated_build_bridge_state(build, table)
