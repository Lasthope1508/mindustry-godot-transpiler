extends "res://src/game/SourceTurretStatsBarsPortBridge.gd"

const source_block_consume_state := preload("res://src/game/SourceBlockConsumeState.gd")

func source_block_consume_liquid_state(liquid: Variant, amount: float) -> Dictionary:
	return source_block_consume_state.consume_liquid_state(liquid, amount)

func generated_block_consume_liquid_bridge_state(liquid: Variant, amount: float) -> Dictionary:
	return source_block_consume_state.generated_block_consume_liquid_bridge_state(liquid, amount)

func source_block_consume_liquids_state(stacks: Variant) -> Dictionary:
	return source_block_consume_state.consume_liquids_state(stacks)

func generated_block_consume_liquids_bridge_state(stacks: Variant) -> Dictionary:
	return source_block_consume_state.generated_block_consume_liquids_bridge_state(stacks)

func source_block_consume_power_state(power_per_tick: float) -> Dictionary:
	return source_block_consume_state.consume_power_state(power_per_tick)

func generated_block_consume_power_bridge_state(power_per_tick: float) -> Dictionary:
	return source_block_consume_state.generated_block_consume_power_bridge_state(power_per_tick)

func source_block_consume_power_cond_state(usage: float, cons: Variant) -> Dictionary:
	return source_block_consume_state.consume_power_cond_state(usage, cons)

func generated_block_consume_power_cond_bridge_state(usage: float, cons: Variant) -> Dictionary:
	return source_block_consume_state.generated_block_consume_power_cond_bridge_state(usage, cons)

func source_block_consume_power_dynamic_state(usage: Variant) -> Dictionary:
	return source_block_consume_state.consume_power_dynamic_state(usage)

func generated_block_consume_power_dynamic_bridge_state(usage: Variant) -> Dictionary:
	return source_block_consume_state.generated_block_consume_power_dynamic_bridge_state(usage)

func source_block_consume_power_dynamic_displayed_state(displayed: float, usage: Variant) -> Dictionary:
	return source_block_consume_state.consume_power_dynamic_displayed_state(displayed, usage)

func generated_block_consume_power_dynamic_displayed_bridge_state(displayed: float, usage: Variant) -> Dictionary:
	return source_block_consume_state.generated_block_consume_power_dynamic_displayed_bridge_state(displayed, usage)

func source_block_consume_power_buffered_state(power_capacity: float) -> Dictionary:
	return source_block_consume_state.consume_power_buffered_state(power_capacity)

func generated_block_consume_power_buffered_bridge_state(power_capacity: float) -> Dictionary:
	return source_block_consume_state.generated_block_consume_power_buffered_bridge_state(power_capacity)

func source_block_consume_item_single_state(item: Variant) -> Dictionary:
	return source_block_consume_state.consume_item_single_state(item)

func generated_block_consume_item_single_bridge_state(item: Variant) -> Dictionary:
	return source_block_consume_state.generated_block_consume_item_single_bridge_state(item)

func source_block_consume_item_amount_state(item: Variant, amount: int) -> Dictionary:
	return source_block_consume_state.consume_item_amount_state(item, amount)

func generated_block_consume_item_amount_bridge_state(item: Variant, amount: int) -> Dictionary:
	return source_block_consume_state.generated_block_consume_item_amount_bridge_state(item, amount)

func source_block_consume_items_varargs_state(items: Array) -> Dictionary:
	return source_block_consume_state.consume_items_varargs_state(items)

func generated_block_consume_items_varargs_bridge_state(items: Array) -> Dictionary:
	return source_block_consume_state.generated_block_consume_items_varargs_bridge_state(items)

func source_block_consume_coolant_single_state(amount: float) -> Dictionary:
	return source_block_consume_state.consume_coolant_single_state(amount)

func generated_block_consume_coolant_single_bridge_state(amount: float) -> Dictionary:
	return source_block_consume_state.generated_block_consume_coolant_single_bridge_state(amount)

func source_block_consume_coolant_filtered_state(amount: float, allow_liquid: bool, allow_gas: bool) -> Dictionary:
	return source_block_consume_state.consume_coolant_filtered_state(amount, allow_liquid, allow_gas)

func generated_block_consume_coolant_filtered_bridge_state(amount: float, allow_liquid: bool, allow_gas: bool) -> Dictionary:
	return source_block_consume_state.generated_block_consume_coolant_filtered_bridge_state(amount, allow_liquid, allow_gas)

func source_block_consume_generic_state(consume: Variant, consume_is_power: bool, consume_builder_before: Array, consume_builder_without_power: Array, cons_power_before: Variant) -> Dictionary:
	return source_block_consume_state.consume_generic_state(consume, consume_is_power, consume_builder_before, consume_builder_without_power, cons_power_before)

func generated_block_consume_generic_bridge_state(consume: Variant, consume_is_power: bool, consume_builder_before: Array, consume_builder_without_power: Array, cons_power_before: Variant) -> Dictionary:
	return source_block_consume_state.generated_block_consume_generic_bridge_state(consume, consume_is_power, consume_builder_before, consume_builder_without_power, cons_power_before)
