extends RefCounted
class_name SourceUnitPayloadBasicState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_payload_source_text_state := preload("res://src/game/SourcePayloadSourceTextState.gd")
const SOURCE_UNIT_PAYLOAD_GENERATED_CLASS := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_GENERATED_CLASS

static func _unit_payload_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_UNIT_PAYLOAD_GENERATED_CLASS, generated_method, generated_args, null)

const SOURCE_UNIT_PAYLOAD_SOURCE := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_SOURCE
const SOURCE_UNIT_PAYLOAD_CLASS_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR
const SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR
const SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR
const SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR
const SOURCE_UNIT_PAYLOAD_TYPE_NULL_GUARD_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_TYPE_NULL_GUARD_EXPR
const SOURCE_UNIT_PAYLOAD_OVERLAY_DURATION_FIELD_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_OVERLAY_DURATION_FIELD_EXPR
const SOURCE_UNIT_PAYLOAD_OVERLAY_TIME_FIELD_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_OVERLAY_TIME_FIELD_EXPR
const SOURCE_UNIT_PAYLOAD_OVERLAY_REGION_FIELD_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_OVERLAY_REGION_FIELD_EXPR
const SOURCE_UNIT_PAYLOAD_DRAW_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_DRAW_METHOD

const SOURCE_UNIT_PAYLOAD_IMPORT_STATIC_VARS_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_IMPORT_STATIC_VARS_EXPR
const SOURCE_UNIT_PAYLOAD_CONSTRUCTOR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_CONSTRUCTOR
const SOURCE_UNIT_PAYLOAD_UNIT_ASSIGN_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_UNIT_ASSIGN_EXPR
const SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_TEXTURE_REGION_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_TEXTURE_REGION_METHOD
const SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_REGION_ASSIGN_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_REGION_ASSIGN_EXPR
const SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_TIME_ASSIGN_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_TIME_ASSIGN_EXPR
const SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_METHOD
const SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_GUARD_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_GUARD_EXPR
const SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_DELEGATE_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_DELEGATE_EXPR

static func constructor_state(unit: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_CONSTRUCTOR_STATE,
		"source": SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"constructor": SOURCE_UNIT_PAYLOAD_CONSTRUCTOR,
		"unit_assign_expr": SOURCE_UNIT_PAYLOAD_UNIT_ASSIGN_EXPR,
		"unit": unit,
		"unit_after": unit,
	}

static func generated_constructor_bridge_state(unit: Variant) -> Dictionary:
	var result = _unit_payload_call("java_constructor_UnitPayload_0", [unit])
	var canonical = constructor_state(unit)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_CONSTRUCTOR_STATE,
		"generated_owner": "unit_payload.java_constructor_UnitPayload_0",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func show_overlay_texture_region_state(icon: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_TEXTURE_REGION_STATE,
		"source": SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"overlay_time_field_expr": SOURCE_UNIT_PAYLOAD_OVERLAY_TIME_FIELD_EXPR,
		"overlay_region_field_expr": SOURCE_UNIT_PAYLOAD_OVERLAY_REGION_FIELD_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_TEXTURE_REGION_METHOD,
		"overlay_region_assign_expr": SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_REGION_ASSIGN_EXPR,
		"overlay_time_assign_expr": SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_TIME_ASSIGN_EXPR,
		"icon": icon,
		"overlayRegion_after": icon,
		"overlayTime_after": 1.0,
	}

static func generated_show_overlay_texture_region_bridge_state(icon: Variant) -> Dictionary:
	var result = _unit_payload_call("java_method_showOverlay_0", [icon])
	var canonical = show_overlay_texture_region_state(icon)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_TEXTURE_REGION_STATE,
		"generated_owner": "unit_payload.java_method_showOverlay_0",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func show_overlay_drawable_state(icon_null: bool, headless: bool, region: Variant) -> Dictionary:
	var returned: bool = icon_null or headless
	var overlay_region_after: Variant = null
	var overlay_time_after: Variant = null
	var delegate_call: Variant = null
	if not returned:
		overlay_region_after = region
		overlay_time_after = 1.0
		delegate_call = {"call": SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_DELEGATE_EXPR, "region": region}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_STATE,
		"source": SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"import_expr": SOURCE_UNIT_PAYLOAD_IMPORT_STATIC_VARS_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_METHOD,
		"guard_expr": SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_GUARD_EXPR,
		"delegate_expr": SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_DELEGATE_EXPR,
		"icon_null": icon_null,
		"headless": headless,
		"region": region,
		"returned": returned,
		"get_region_called": not returned,
		"show_overlay_called": not returned,
		"delegate_call": delegate_call,
		"overlayRegion_after": overlay_region_after,
		"overlayTime_after": overlay_time_after,
	}

static func generated_show_overlay_drawable_bridge_state(icon_null: bool, headless: bool, region: Variant) -> Dictionary:
	var result = _unit_payload_call("java_method_showOverlay_1", [icon_null, headless, region])
	var canonical = show_overlay_drawable_state(icon_null, headless, region)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_STATE,
		"generated_owner": "unit_payload.java_method_showOverlay_1",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
