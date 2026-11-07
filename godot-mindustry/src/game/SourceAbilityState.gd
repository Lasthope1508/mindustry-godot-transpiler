extends RefCounted
class_name SourceAbilityState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_ability_source_text_state := preload("res://src/game/SourceAbilitySourceTextState.gd")

const SOURCE_ABILITY_SOURCE := source_ability_source_text_state.SOURCE_ABILITY_SOURCE
const SOURCE_ABILITY_UPDATE_METHOD := source_ability_source_text_state.SOURCE_ABILITY_UPDATE_METHOD
const SOURCE_ABILITY_DRAW_METHOD := source_ability_source_text_state.SOURCE_ABILITY_DRAW_METHOD
const SOURCE_ABILITY_DEATH_METHOD := source_ability_source_text_state.SOURCE_ABILITY_DEATH_METHOD
const SOURCE_ABILITY_CREATED_METHOD := source_ability_source_text_state.SOURCE_ABILITY_CREATED_METHOD
const SOURCE_ABILITY_INIT_METHOD := source_ability_source_text_state.SOURCE_ABILITY_INIT_METHOD
const SOURCE_ABILITY_DISPLAY_BARS_METHOD := source_ability_source_text_state.SOURCE_ABILITY_DISPLAY_BARS_METHOD
const SOURCE_ABILITY_DISPLAY_METHOD := source_ability_source_text_state.SOURCE_ABILITY_DISPLAY_METHOD
const SOURCE_ABILITY_ADD_STATS_METHOD := source_ability_source_text_state.SOURCE_ABILITY_ADD_STATS_METHOD
const SOURCE_ABILITY_FIELD_EXPR := source_ability_source_text_state.SOURCE_ABILITY_FIELD_EXPR
const SOURCE_ABILITY_DISPLAY_STYLE_EXPR := source_ability_source_text_state.SOURCE_ABILITY_DISPLAY_STYLE_EXPR
const SOURCE_ABILITY_DISPLAY_LOCALIZED_CALL := source_ability_source_text_state.SOURCE_ABILITY_DISPLAY_LOCALIZED_CALL
const SOURCE_ABILITY_DISPLAY_ADD_STATS_CALL := source_ability_source_text_state.SOURCE_ABILITY_DISPLAY_ADD_STATS_CALL
const SOURCE_ABILITY_ADD_STATS_GUARD_EXPR := source_ability_source_text_state.SOURCE_ABILITY_ADD_STATS_GUARD_EXPR
const SOURCE_ABILITY_ADD_STATS_ADD_DESCRIPTION_CALL := source_ability_source_text_state.SOURCE_ABILITY_ADD_STATS_ADD_DESCRIPTION_CALL
const SOURCE_ABILITY_ABILITY_STAT_METHOD := source_ability_source_text_state.SOURCE_ABILITY_ABILITY_STAT_METHOD
const SOURCE_ABILITY_ABILITY_STAT_BUNDLE_KEY_PREFIX := source_ability_source_text_state.SOURCE_ABILITY_ABILITY_STAT_BUNDLE_KEY_PREFIX
const SOURCE_ABILITY_ABILITY_STAT_BUNDLE_KEY_EXPR := source_ability_source_text_state.SOURCE_ABILITY_ABILITY_STAT_BUNDLE_KEY_EXPR
const SOURCE_ABILITY_ABILITY_STAT_FORMAT_CALL := source_ability_source_text_state.SOURCE_ABILITY_ABILITY_STAT_FORMAT_CALL
const SOURCE_ABILITY_COPY_METHOD := source_ability_source_text_state.SOURCE_ABILITY_COPY_METHOD
const SOURCE_ABILITY_COPY_TRY_EXPR := source_ability_source_text_state.SOURCE_ABILITY_COPY_TRY_EXPR
const SOURCE_ABILITY_COPY_RETURN_EXPR := source_ability_source_text_state.SOURCE_ABILITY_COPY_RETURN_EXPR
const SOURCE_ABILITY_COPY_CATCH_EXPR := source_ability_source_text_state.SOURCE_ABILITY_COPY_CATCH_EXPR
const SOURCE_ABILITY_COPY_RUNTIME_EXCEPTION_EXPR := source_ability_source_text_state.SOURCE_ABILITY_COPY_RUNTIME_EXCEPTION_EXPR
const SOURCE_ABILITY_LOCALIZED_COMMENT := source_ability_source_text_state.SOURCE_ABILITY_LOCALIZED_COMMENT
const SOURCE_ABILITY_LOCALIZED_METHOD := source_ability_source_text_state.SOURCE_ABILITY_LOCALIZED_METHOD
const SOURCE_ABILITY_LOCALIZED_GET_BUNDLE_CALL := source_ability_source_text_state.SOURCE_ABILITY_LOCALIZED_GET_BUNDLE_CALL
const SOURCE_ABILITY_LOCALIZED_BUNDLE_GET_CALL := source_ability_source_text_state.SOURCE_ABILITY_LOCALIZED_BUNDLE_GET_CALL
const SOURCE_ABILITY_LOCALIZED_RETURN_EXPR := source_ability_source_text_state.SOURCE_ABILITY_LOCALIZED_RETURN_EXPR
const SOURCE_ABILITY_GET_BUNDLE_METHOD := source_ability_source_text_state.SOURCE_ABILITY_GET_BUNDLE_METHOD
const SOURCE_ABILITY_GET_BUNDLE_TYPE_ASSIGNMENT := source_ability_source_text_state.SOURCE_ABILITY_GET_BUNDLE_TYPE_ASSIGNMENT

static func update_state(unit: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_UPDATE_STATE,
		"source": SOURCE_ABILITY_SOURCE,
		"method": SOURCE_ABILITY_UPDATE_METHOD,
		"unit": unit,
		"no_op": true,
	}

static func draw_state(unit: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DRAW_STATE,
		"source": SOURCE_ABILITY_SOURCE,
		"method": SOURCE_ABILITY_DRAW_METHOD,
		"unit": unit,
		"no_op": true,
	}

static func death_state(unit: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DEATH_STATE,
		"source": SOURCE_ABILITY_SOURCE,
		"method": SOURCE_ABILITY_DEATH_METHOD,
		"unit": unit,
		"no_op": true,
	}

static func created_state(unit: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_CREATED_STATE,
		"source": SOURCE_ABILITY_SOURCE,
		"method": SOURCE_ABILITY_CREATED_METHOD,
		"unit": unit,
		"no_op": true,
	}

static func init_state(type_value: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_INIT_STATE,
		"source": SOURCE_ABILITY_SOURCE,
		"method": SOURCE_ABILITY_INIT_METHOD,
		"type": type_value,
		"no_op": true,
	}

static func display_bars_state(unit: Variant, bars: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DISPLAY_BARS_STATE,
		"source": SOURCE_ABILITY_SOURCE,
		"method": SOURCE_ABILITY_DISPLAY_BARS_METHOD,
		"unit": unit,
		"bars": bars,
		"no_op": true,
	}

static func display_state(table_state: Variant, localized_value: String) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_DISPLAY_STATE,
		"source": SOURCE_ABILITY_SOURCE,
		"method": SOURCE_ABILITY_DISPLAY_METHOD,
		"table": table_state,
		"localized_value": localized_value,
		"style_expr": SOURCE_ABILITY_DISPLAY_STYLE_EXPR,
		"localized_call": SOURCE_ABILITY_DISPLAY_LOCALIZED_CALL,
		"title_text": "[accent]" + localized_value,
		"add_stats_call": SOURCE_ABILITY_DISPLAY_ADD_STATS_CALL,
		"table_mutation": true,
	}

static func add_stats_state(table_state: Variant, get_bundle_value: String, bundle_has_description: bool, bundle_description: String) -> Dictionary:
	var add_description_call := SOURCE_ABILITY_ADD_STATS_ADD_DESCRIPTION_CALL
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_ADD_STATS_STATE,
		"source": SOURCE_ABILITY_SOURCE,
		"method": SOURCE_ABILITY_ADD_STATS_METHOD,
		"table": table_state,
		"get_bundle_value": get_bundle_value,
		"bundle_has_description": bundle_has_description,
		"bundle_description": bundle_description,
		"field_expr": SOURCE_ABILITY_FIELD_EXPR,
		"description_width": 350.0,
		"guard_expr": SOURCE_ABILITY_ADD_STATS_GUARD_EXPR,
		"guard_passed": bundle_has_description,
		"add_description_call": add_description_call,
	}

static func ability_stat_state(stat_value: String, values: Array, formatted_value: String) -> Dictionary:
	var bundle_key := SOURCE_ABILITY_ABILITY_STAT_BUNDLE_KEY_PREFIX + stat_value
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_ABILITY_STAT_STATE,
		"source": SOURCE_ABILITY_SOURCE,
		"method": SOURCE_ABILITY_ABILITY_STAT_METHOD,
		"stat_value": stat_value,
		"values": values.duplicate(),
		"formatted_value": formatted_value,
		"bundle_key_expr": SOURCE_ABILITY_ABILITY_STAT_BUNDLE_KEY_EXPR,
		"bundle_key": bundle_key,
		"format_call": SOURCE_ABILITY_ABILITY_STAT_FORMAT_CALL,
		"return_value": formatted_value,
	}

static func copy_state(clone_supported: bool, clone_value: Variant, exception_value: Variant) -> Dictionary:
	var return_value = clone_value if clone_supported else null
	var thrown_exception = null if clone_supported else exception_value
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_COPY_STATE,
		"source": SOURCE_ABILITY_SOURCE,
		"method": SOURCE_ABILITY_COPY_METHOD,
		"clone_supported": clone_supported,
		"clone_value": clone_value,
		"exception_value": exception_value,
		"try_expr": SOURCE_ABILITY_COPY_TRY_EXPR,
		"clone_return_expr": SOURCE_ABILITY_COPY_RETURN_EXPR,
		"catch_expr": SOURCE_ABILITY_COPY_CATCH_EXPR,
		"runtime_exception_expr": SOURCE_ABILITY_COPY_RUNTIME_EXCEPTION_EXPR,
		"return_value": return_value,
		"thrown_exception": thrown_exception,
	}

static func localized_state(get_bundle_value: String, bundle_value: String) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_LOCALIZED_STATE,
		"source": SOURCE_ABILITY_SOURCE,
		"comment": SOURCE_ABILITY_LOCALIZED_COMMENT,
		"method": SOURCE_ABILITY_LOCALIZED_METHOD,
		"get_bundle_call": SOURCE_ABILITY_LOCALIZED_GET_BUNDLE_CALL,
		"get_bundle_value": get_bundle_value,
		"bundle_get_call": SOURCE_ABILITY_LOCALIZED_BUNDLE_GET_CALL,
		"return_expr": SOURCE_ABILITY_LOCALIZED_RETURN_EXPR,
		"bundle_value": bundle_value,
		"return_value": bundle_value,
	}

static func get_bundle_state(class_simple_name: String, is_anonymous_class: bool, superclass_simple_name: String) -> Dictionary:
	var selected_simple_name := superclass_simple_name if is_anonymous_class else class_simple_name
	var stripped_name := class_simple_name if is_anonymous_class else class_simple_name.replace(superclass_simple_name, "")
	var return_value := selected_simple_name if selected_simple_name != "" else stripped_name
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ABILITY_GET_BUNDLE_STATE,
		"source": SOURCE_ABILITY_SOURCE,
		"method": SOURCE_ABILITY_GET_BUNDLE_METHOD,
		"class_simple_name": class_simple_name,
		"is_anonymous_class": is_anonymous_class,
		"superclass_simple_name": superclass_simple_name,
		"selected_simple_name": selected_simple_name,
		"stripped_name": stripped_name,
		"type_assignment": SOURCE_ABILITY_GET_BUNDLE_TYPE_ASSIGNMENT,
		"return_value": return_value,
	}
