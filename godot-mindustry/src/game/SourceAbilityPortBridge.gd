extends "res://src/game/SourceItemTurretBuildPortBridge.gd"

const source_ability_state := preload("res://src/game/SourceAbilityState.gd")
const source_ability_generated_state := preload("res://src/game/SourceAbilityGeneratedState.gd")

func source_ability_update_state(unit: Variant) -> Dictionary:
	return source_ability_state.update_state(unit)

func generated_ability_update_bridge_state(unit: Variant) -> Dictionary:
	return source_ability_generated_state.generated_update_bridge_state(unit)

func source_ability_draw_state(unit: Variant) -> Dictionary:
	return source_ability_state.draw_state(unit)

func generated_ability_draw_bridge_state(unit: Variant) -> Dictionary:
	return source_ability_generated_state.generated_draw_bridge_state(unit)

func source_ability_death_state(unit: Variant) -> Dictionary:
	return source_ability_state.death_state(unit)

func generated_ability_death_bridge_state(unit: Variant) -> Dictionary:
	return source_ability_generated_state.generated_death_bridge_state(unit)

func source_ability_created_state(unit: Variant) -> Dictionary:
	return source_ability_state.created_state(unit)

func generated_ability_created_bridge_state(unit: Variant) -> Dictionary:
	return source_ability_generated_state.generated_created_bridge_state(unit)

func source_ability_init_state(type_value: Variant) -> Dictionary:
	return source_ability_state.init_state(type_value)

func generated_ability_init_bridge_state(type_value: Variant) -> Dictionary:
	return source_ability_generated_state.generated_init_bridge_state(type_value)

func source_ability_display_bars_state(unit: Variant, bars: Variant) -> Dictionary:
	return source_ability_state.display_bars_state(unit, bars)

func generated_ability_display_bars_bridge_state(unit: Variant, bars: Variant) -> Dictionary:
	return source_ability_generated_state.generated_display_bars_bridge_state(unit, bars)

func source_ability_display_state(table_state: Variant, localized_value: String) -> Dictionary:
	return source_ability_state.display_state(table_state, localized_value)

func generated_ability_display_bridge_state(table_state: Variant, localized_value: String) -> Dictionary:
	return source_ability_generated_state.generated_display_bridge_state(table_state, localized_value)

func source_ability_add_stats_state(table_state: Variant, get_bundle_value: String, bundle_has_description: bool, bundle_description: String) -> Dictionary:
	return source_ability_state.add_stats_state(table_state, get_bundle_value, bundle_has_description, bundle_description)

func generated_ability_add_stats_bridge_state(table_state: Variant, get_bundle_value: String, bundle_has_description: bool, bundle_description: String) -> Dictionary:
	return source_ability_generated_state.generated_add_stats_bridge_state(table_state, get_bundle_value, bundle_has_description, bundle_description)

func source_ability_ability_stat_state(stat_value: String, values: Array, formatted_value: String) -> Dictionary:
	return source_ability_state.ability_stat_state(stat_value, values, formatted_value)

func generated_ability_ability_stat_bridge_state(stat_value: String, values: Array, formatted_value: String) -> Dictionary:
	return source_ability_generated_state.generated_ability_stat_bridge_state(stat_value, values, formatted_value)

func source_ability_copy_state(clone_supported: bool, clone_value: Variant, exception_value: Variant) -> Dictionary:
	return source_ability_state.copy_state(clone_supported, clone_value, exception_value)

func generated_ability_copy_bridge_state(clone_supported: bool, clone_value: Variant, exception_value: Variant) -> Dictionary:
	return source_ability_generated_state.generated_copy_bridge_state(clone_supported, clone_value, exception_value)

func source_ability_localized_state(get_bundle_value: String, bundle_value: String) -> Dictionary:
	return source_ability_state.localized_state(get_bundle_value, bundle_value)

func generated_ability_localized_bridge_state(get_bundle_value: String, bundle_value: String) -> Dictionary:
	return source_ability_generated_state.generated_localized_bridge_state(get_bundle_value, bundle_value)

func source_ability_get_bundle_state(class_simple_name: String, is_anonymous_class: bool, superclass_simple_name: String) -> Dictionary:
	return source_ability_state.get_bundle_state(class_simple_name, is_anonymous_class, superclass_simple_name)

func generated_ability_get_bundle_bridge_state(class_simple_name: String, is_anonymous_class: bool, superclass_simple_name: String) -> Dictionary:
	return source_ability_generated_state.generated_get_bundle_bridge_state(class_simple_name, is_anonymous_class, superclass_simple_name)
