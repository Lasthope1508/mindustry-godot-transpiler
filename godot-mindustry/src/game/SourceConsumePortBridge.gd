extends "res://src/game/SourceDrillRuntimePortBridge.gd"

const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_consume_port_bridge_ui_defaults := preload("res://src/game/SourceUiDefaults.gd")
const source_consume_module_registry := preload("res://src/game/SourceConsumeModuleRegistry.gd")

func source_consume_power_ignore_state(buffered: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.ignore_state(buffered)

func generated_consume_power_ignore_bridge_state(buffered: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_ignore_bridge_state(buffered)

func source_consume_power_apply_state(block_has_power_before: bool, block_cons_power_before: Variant, consume_power_state: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.apply_state(block_has_power_before, block_cons_power_before, consume_power_state)

func generated_consume_power_apply_bridge_state(block_has_power_before: bool, block_cons_power_before: Variant, consume_power_state: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_apply_bridge_state(block_has_power_before, block_cons_power_before, consume_power_state)

func source_consume_power_efficiency_state(power_status: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.efficiency_state(power_status)

func generated_consume_power_efficiency_bridge_state(power_status: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_efficiency_bridge_state(power_status)

func source_consume_power_display_state(buffered: bool, usage: float, capacity: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.display_state(buffered, usage, capacity, source_time_defaults.TICK_RATE)

func generated_consume_power_display_bridge_state(buffered: bool, usage: float, capacity: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_display_bridge_state(buffered, usage, capacity, source_time_defaults.TICK_RATE)

func source_consume_power_condition_requested_power_state(usage: float, consume_get: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.condition_requested_power_state(usage, consume_get)

func generated_consume_power_condition_requested_power_bridge_state(usage: float, consume_get: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_condition_requested_power_bridge_state(usage, consume_get)

func source_consume_power_dynamic_requested_power_state(usage_get: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.dynamic_requested_power_state(usage_get)

func generated_consume_power_dynamic_requested_power_bridge_state(usage_get: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_dynamic_requested_power_bridge_state(usage_get)

func source_consume_power_dynamic_display_state(displayed_power_usage: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.dynamic_display_state(displayed_power_usage, source_time_defaults.TICK_RATE)

func generated_consume_power_dynamic_display_bridge_state(displayed_power_usage: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_dynamic_display_bridge_state(displayed_power_usage, source_time_defaults.TICK_RATE)

func source_consume_optional_state(optional_value: bool, boost_value: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_state.optional_state(optional_value, boost_value)

func generated_consume_optional_bridge_state(optional_value: bool, boost_value: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_generated_state.generated_optional_bridge_state(optional_value, boost_value)

func source_consume_boost_state() -> Dictionary:
	return source_consume_module_registry.source_consume_state.boost_state()

func generated_consume_boost_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_generated_state.generated_boost_bridge_state()

func source_consume_update_flag_state(update_value: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_state.update_flag_state(update_value)

func generated_consume_update_flag_bridge_state(update_value: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_generated_state.generated_update_flag_bridge_state(update_value)

func source_consume_ignore_state() -> Dictionary:
	return source_consume_module_registry.source_consume_state.ignore_state()

func generated_consume_ignore_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_generated_state.generated_ignore_bridge_state()

func source_consume_build_state(build: Variant, table: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_state.build_state(build, table)

func generated_consume_build_bridge_state(build: Variant, table: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_generated_state.generated_build_bridge_state(build, table)

func source_consume_apply_state(block: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_state.apply_state(block)

func generated_consume_apply_bridge_state(block: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_generated_state.generated_apply_bridge_state(block)

func source_consume_trigger_state(build: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_state.trigger_state(build)

func generated_consume_trigger_bridge_state(build: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_generated_state.generated_trigger_bridge_state(build)

func source_consume_update_build_state(build: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_state.update_build_state(build)

func generated_consume_update_build_bridge_state(build: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_generated_state.generated_update_build_bridge_state(build)

func source_consume_display_state(stats: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_state.display_state(stats)

func generated_consume_display_bridge_state(stats: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_generated_state.generated_display_bridge_state(stats)

func source_consume_efficiency_state() -> Dictionary:
	return source_consume_module_registry.source_consume_state.efficiency_state()

func generated_consume_efficiency_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_generated_state.generated_efficiency_bridge_state()

func source_consume_efficiency_multiplier_state() -> Dictionary:
	return source_consume_module_registry.source_consume_state.efficiency_multiplier_state()

func generated_consume_efficiency_multiplier_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_generated_state.generated_efficiency_multiplier_bridge_state()

func source_consume_power_requested_power_state(buffered: bool, usage: float, capacity: float, power_status: float, should_consume: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.requested_power_state(buffered, usage, capacity, power_status, should_consume)

func generated_consume_power_requested_power_bridge_state(buffered: bool, usage: float, capacity: float, power_status: float, should_consume: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_requested_power_bridge_state(buffered, usage, capacity, power_status, should_consume)
