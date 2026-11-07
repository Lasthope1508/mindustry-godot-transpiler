extends RefCounted
class_name SourcePowerGeneratorGeneratedState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_power_generator_state := preload("res://src/game/SourcePowerGeneratorState.gd")
const source_power_source_text_state := preload("res://src/game/SourcePowerSourceTextState.gd")

const SOURCE_POWER_GENERATOR_GENERATED_CLASS := source_power_source_text_state.SOURCE_POWER_GENERATOR_GENERATED_CLASS
const SOURCE_POWER_GENERATOR_DISPLAYED_POWER_PRODUCTION_JAVA_METHOD_GET_DISPLAYED_POWER_PRODUCTION_0 := source_power_source_text_state.SOURCE_POWER_GENERATOR_DISPLAYED_POWER_PRODUCTION_JAVA_METHOD_GET_DISPLAYED_POWER_PRODUCTION_0
const SOURCE_POWER_GENERATOR_DISPLAYED_POWER_PRODUCTION_GENERATED_OWNER := source_power_source_text_state.SOURCE_POWER_GENERATOR_DISPLAYED_POWER_PRODUCTION_GENERATED_OWNER
const SOURCE_POWER_GENERATOR_ICONS_GENERATED_METHOD := source_power_source_text_state.SOURCE_POWER_GENERATOR_ICONS_GENERATED_METHOD
const SOURCE_POWER_GENERATOR_ICONS_GENERATED_OWNER := source_power_source_text_state.SOURCE_POWER_GENERATOR_ICONS_GENERATED_OWNER
const SOURCE_POWER_GENERATOR_SET_BARS_GENERATED_METHOD := source_power_source_text_state.SOURCE_POWER_GENERATOR_SET_BARS_GENERATED_METHOD
const SOURCE_POWER_GENERATOR_SET_BARS_GENERATED_OWNER := source_power_source_text_state.SOURCE_POWER_GENERATOR_SET_BARS_GENERATED_OWNER

static func _generated_bridge_state(source_owner: String, generated_owner: String, result: Variant, canonical: Variant, matches: bool) -> Dictionary:
	return {
		"source_owner": source_owner,
		"generated_owner": generated_owner,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_displayed_power_production_bridge_state(power_production: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_POWER_GENERATOR_GENERATED_CLASS, SOURCE_POWER_GENERATOR_DISPLAYED_POWER_PRODUCTION_JAVA_METHOD_GET_DISPLAYED_POWER_PRODUCTION_0, [power_production], null)
	var canonical = source_power_generator_state.displayed_power_production_state(power_production)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return _generated_bridge_state(source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_DISPLAYED_POWER_PRODUCTION_STATE, SOURCE_POWER_GENERATOR_DISPLAYED_POWER_PRODUCTION_GENERATED_OWNER, result, canonical, matches)

static func generated_icons_bridge_state(drawer_icons: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_POWER_GENERATOR_GENERATED_CLASS, SOURCE_POWER_GENERATOR_ICONS_GENERATED_METHOD, [drawer_icons], null)
	var canonical = source_power_generator_state.icons_state(drawer_icons)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return _generated_bridge_state(source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_ICONS_STATE, SOURCE_POWER_GENERATOR_ICONS_GENERATED_OWNER, result, canonical, matches)

static func generated_set_bars_bridge_state(has_power: bool, outputs_power: bool, super_set_bars_state: Dictionary, power_production: float, time_scale: float, production_efficiency: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_POWER_GENERATOR_GENERATED_CLASS, SOURCE_POWER_GENERATOR_SET_BARS_GENERATED_METHOD, [has_power, outputs_power, super_set_bars_state, power_production, time_scale, production_efficiency], null)
	var canonical = source_power_generator_state.set_bars_state(has_power, outputs_power, super_set_bars_state, power_production, time_scale, production_efficiency)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return _generated_bridge_state(source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_SET_BARS_STATE, SOURCE_POWER_GENERATOR_SET_BARS_GENERATED_OWNER, result, canonical, matches)
