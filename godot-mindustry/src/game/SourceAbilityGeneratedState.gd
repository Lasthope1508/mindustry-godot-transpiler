extends RefCounted
class_name SourceAbilityGeneratedState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_ability_source_text_state := preload("res://src/game/SourceAbilitySourceTextState.gd")
const source_ability_state := preload("res://src/game/SourceAbilityState.gd")
const SOURCE_ABILITY_GENERATED_CLASS := source_ability_source_text_state.SOURCE_ABILITY_GENERATED_CLASS
const SOURCE_ABILITY_UPDATE_JAVA_METHOD := source_ability_source_text_state.SOURCE_ABILITY_UPDATE_JAVA_METHOD
const SOURCE_ABILITY_DRAW_JAVA_METHOD := source_ability_source_text_state.SOURCE_ABILITY_DRAW_JAVA_METHOD
const SOURCE_ABILITY_DEATH_JAVA_METHOD := source_ability_source_text_state.SOURCE_ABILITY_DEATH_JAVA_METHOD
const SOURCE_ABILITY_CREATED_JAVA_METHOD := source_ability_source_text_state.SOURCE_ABILITY_CREATED_JAVA_METHOD
const SOURCE_ABILITY_INIT_JAVA_METHOD := source_ability_source_text_state.SOURCE_ABILITY_INIT_JAVA_METHOD
const SOURCE_ABILITY_DISPLAY_BARS_JAVA_METHOD := source_ability_source_text_state.SOURCE_ABILITY_DISPLAY_BARS_JAVA_METHOD
const SOURCE_ABILITY_DISPLAY_JAVA_METHOD := source_ability_source_text_state.SOURCE_ABILITY_DISPLAY_JAVA_METHOD
const SOURCE_ABILITY_ADD_STATS_JAVA_METHOD := source_ability_source_text_state.SOURCE_ABILITY_ADD_STATS_JAVA_METHOD
const SOURCE_ABILITY_ABILITY_STAT_JAVA_METHOD := source_ability_source_text_state.SOURCE_ABILITY_ABILITY_STAT_JAVA_METHOD
const SOURCE_ABILITY_COPY_JAVA_METHOD := source_ability_source_text_state.SOURCE_ABILITY_COPY_JAVA_METHOD
const SOURCE_ABILITY_LOCALIZED_JAVA_METHOD := source_ability_source_text_state.SOURCE_ABILITY_LOCALIZED_JAVA_METHOD
const SOURCE_ABILITY_GET_BUNDLE_JAVA_METHOD := source_ability_source_text_state.SOURCE_ABILITY_GET_BUNDLE_JAVA_METHOD
const SOURCE_ABILITY_UPDATE_GENERATED_OWNER := source_ability_source_text_state.SOURCE_ABILITY_UPDATE_GENERATED_OWNER
const SOURCE_ABILITY_DRAW_GENERATED_OWNER := source_ability_source_text_state.SOURCE_ABILITY_DRAW_GENERATED_OWNER
const SOURCE_ABILITY_DEATH_GENERATED_OWNER := source_ability_source_text_state.SOURCE_ABILITY_DEATH_GENERATED_OWNER
const SOURCE_ABILITY_CREATED_GENERATED_OWNER := source_ability_source_text_state.SOURCE_ABILITY_CREATED_GENERATED_OWNER
const SOURCE_ABILITY_INIT_GENERATED_OWNER := source_ability_source_text_state.SOURCE_ABILITY_INIT_GENERATED_OWNER
const SOURCE_ABILITY_DISPLAY_BARS_GENERATED_OWNER := source_ability_source_text_state.SOURCE_ABILITY_DISPLAY_BARS_GENERATED_OWNER
const SOURCE_ABILITY_DISPLAY_GENERATED_OWNER := source_ability_source_text_state.SOURCE_ABILITY_DISPLAY_GENERATED_OWNER
const SOURCE_ABILITY_ADD_STATS_GENERATED_OWNER := source_ability_source_text_state.SOURCE_ABILITY_ADD_STATS_GENERATED_OWNER
const SOURCE_ABILITY_ABILITY_STAT_GENERATED_OWNER := source_ability_source_text_state.SOURCE_ABILITY_ABILITY_STAT_GENERATED_OWNER
const SOURCE_ABILITY_COPY_GENERATED_OWNER := source_ability_source_text_state.SOURCE_ABILITY_COPY_GENERATED_OWNER
const SOURCE_ABILITY_LOCALIZED_GENERATED_OWNER := source_ability_source_text_state.SOURCE_ABILITY_LOCALIZED_GENERATED_OWNER
const SOURCE_ABILITY_GET_BUNDLE_GENERATED_OWNER := source_ability_source_text_state.SOURCE_ABILITY_GET_BUNDLE_GENERATED_OWNER

static func _ability_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_ABILITY_GENERATED_CLASS, generated_method, generated_args, null)

static func generated_update_bridge_state(unit: Variant) -> Dictionary:
	var result = _ability_call(SOURCE_ABILITY_UPDATE_JAVA_METHOD, [unit])
	var canonical = source_ability_state.update_state(unit)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var matches: bool = result.get("no_op", null) == canonical.get("no_op", null) and result.get("unit", null) == canonical.get("unit", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_UPDATE_STATE,
		"generated_owner": SOURCE_ABILITY_UPDATE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_draw_bridge_state(unit: Variant) -> Dictionary:
	var result = _ability_call(SOURCE_ABILITY_DRAW_JAVA_METHOD, [unit])
	var ability_draw_result = result
	var canonical = source_ability_state.draw_state(unit)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var matches: bool = ability_draw_result.get("no_op", null) == canonical.get("no_op", null) and ability_draw_result.get("unit", null) == canonical.get("unit", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DRAW_STATE,
		"generated_owner": SOURCE_ABILITY_DRAW_GENERATED_OWNER,
		"result": ability_draw_result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_death_bridge_state(unit: Variant) -> Dictionary:
	var result = _ability_call(SOURCE_ABILITY_DEATH_JAVA_METHOD, [unit])
	var ability_death_result = result
	var canonical = source_ability_state.death_state(unit)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var matches: bool = ability_death_result.get("no_op", null) == canonical.get("no_op", null) and ability_death_result.get("unit", null) == canonical.get("unit", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DEATH_STATE,
		"generated_owner": SOURCE_ABILITY_DEATH_GENERATED_OWNER,
		"result": ability_death_result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_created_bridge_state(unit: Variant) -> Dictionary:
	var result = _ability_call(SOURCE_ABILITY_CREATED_JAVA_METHOD, [unit])
	var ability_created_result = result
	var canonical = source_ability_state.created_state(unit)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var matches: bool = ability_created_result.get("no_op", null) == canonical.get("no_op", null) and ability_created_result.get("unit", null) == canonical.get("unit", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_CREATED_STATE,
		"generated_owner": SOURCE_ABILITY_CREATED_GENERATED_OWNER,
		"result": ability_created_result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_init_bridge_state(type_value: Variant) -> Dictionary:
	var result = _ability_call(SOURCE_ABILITY_INIT_JAVA_METHOD, [type_value])
	var ability_init_result = result
	var canonical = source_ability_state.init_state(type_value)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var matches: bool = ability_init_result.get("no_op", null) == canonical.get("no_op", null) and ability_init_result.get("type", null) == canonical.get("type", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_INIT_STATE,
		"generated_owner": SOURCE_ABILITY_INIT_GENERATED_OWNER,
		"result": ability_init_result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_display_bars_bridge_state(unit: Variant, bars: Variant) -> Dictionary:
	var result = _ability_call(SOURCE_ABILITY_DISPLAY_BARS_JAVA_METHOD, [unit, bars])
	var ability_display_bars_result = result
	var canonical = source_ability_state.display_bars_state(unit, bars)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var matches: bool = ability_display_bars_result.get("no_op", null) == canonical.get("no_op", null) and ability_display_bars_result.get("unit", null) == canonical.get("unit", null) and ability_display_bars_result.get("bars", null) == canonical.get("bars", null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DISPLAY_BARS_STATE,
		"generated_owner": SOURCE_ABILITY_DISPLAY_BARS_GENERATED_OWNER,
		"result": ability_display_bars_result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_display_bridge_state(table_state: Variant, localized_value: String) -> Dictionary:
	var result = _ability_call(SOURCE_ABILITY_DISPLAY_JAVA_METHOD, [table_state, localized_value])
	var canonical = source_ability_state.display_state(table_state, localized_value)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DISPLAY_STATE,
		"generated_owner": SOURCE_ABILITY_DISPLAY_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_add_stats_bridge_state(table_state: Variant, get_bundle_value: String, bundle_has_description: bool, bundle_description: String) -> Dictionary:
	var result = _ability_call(SOURCE_ABILITY_ADD_STATS_JAVA_METHOD, [table_state, get_bundle_value, bundle_has_description, bundle_description])
	var canonical = source_ability_state.add_stats_state(table_state, get_bundle_value, bundle_has_description, bundle_description)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_ADD_STATS_STATE,
		"generated_owner": SOURCE_ABILITY_ADD_STATS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_ability_stat_bridge_state(stat_value: String, values: Array, formatted_value: String) -> Dictionary:
	var result = _ability_call(SOURCE_ABILITY_ABILITY_STAT_JAVA_METHOD, [stat_value, values, formatted_value])
	var canonical = source_ability_state.ability_stat_state(stat_value, values, formatted_value)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_ABILITY_STAT_STATE,
		"generated_owner": SOURCE_ABILITY_ABILITY_STAT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_copy_bridge_state(clone_supported: bool, clone_value: Variant, exception_value: Variant) -> Dictionary:
	var result = _ability_call(SOURCE_ABILITY_COPY_JAVA_METHOD, [clone_supported, clone_value, exception_value])
	var canonical = source_ability_state.copy_state(clone_supported, clone_value, exception_value)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_COPY_STATE,
		"generated_owner": SOURCE_ABILITY_COPY_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_localized_bridge_state(get_bundle_value: String, bundle_value: String) -> Dictionary:
	var result = _ability_call(SOURCE_ABILITY_LOCALIZED_JAVA_METHOD, [get_bundle_value, bundle_value])
	var canonical = source_ability_state.localized_state(get_bundle_value, bundle_value)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_LOCALIZED_STATE,
		"generated_owner": SOURCE_ABILITY_LOCALIZED_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}

static func generated_get_bundle_bridge_state(class_simple_name: String, is_anonymous_class: bool, superclass_simple_name: String) -> Dictionary:
	var result = _ability_call(SOURCE_ABILITY_GET_BUNDLE_JAVA_METHOD, [class_simple_name, is_anonymous_class, superclass_simple_name])
	var canonical = source_ability_state.get_bundle_state(class_simple_name, is_anonymous_class, superclass_simple_name)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_GET_BUNDLE_STATE,
		"generated_owner": SOURCE_ABILITY_GET_BUNDLE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
