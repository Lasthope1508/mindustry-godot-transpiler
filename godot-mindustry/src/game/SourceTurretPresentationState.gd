extends RefCounted
class_name SourceTurretPresentationState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const SOURCE_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_TURRET_GENERATED_CLASS
const SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR := source_turret_source_text_state.SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR
const SOURCE_TURRET_LOAD_METHOD := source_turret_source_text_state.SOURCE_TURRET_LOAD_METHOD
const SOURCE_TURRET_LOAD_JAVA_METHOD := source_turret_source_text_state.SOURCE_TURRET_LOAD_JAVA_METHOD
const SOURCE_TURRET_LOAD_GENERATED_OWNER := source_turret_source_text_state.SOURCE_TURRET_LOAD_GENERATED_OWNER
const SOURCE_TURRET_LOAD_SUPER_EXPR := source_turret_source_text_state.SOURCE_TURRET_LOAD_SUPER_EXPR
const SOURCE_TURRET_LOAD_DRAWER_EXPR := source_turret_source_text_state.SOURCE_TURRET_LOAD_DRAWER_EXPR
const SOURCE_TURRET_DRAW_PLAN_REGION_METHOD := source_turret_source_text_state.SOURCE_TURRET_DRAW_PLAN_REGION_METHOD
const SOURCE_TURRET_DRAW_PLAN_REGION_JAVA_METHOD := source_turret_source_text_state.SOURCE_TURRET_DRAW_PLAN_REGION_JAVA_METHOD
const SOURCE_TURRET_DRAW_PLAN_REGION_GENERATED_OWNER := source_turret_source_text_state.SOURCE_TURRET_DRAW_PLAN_REGION_GENERATED_OWNER
const SOURCE_TURRET_DRAW_PLAN_REGION_EXPR := source_turret_source_text_state.SOURCE_TURRET_DRAW_PLAN_REGION_EXPR
const SOURCE_TURRET_ICONS_METHOD := source_turret_source_text_state.SOURCE_TURRET_ICONS_METHOD
const SOURCE_TURRET_ICONS_JAVA_METHOD := source_turret_source_text_state.SOURCE_TURRET_ICONS_JAVA_METHOD
const SOURCE_TURRET_ICONS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_TURRET_ICONS_GENERATED_OWNER
const SOURCE_TURRET_ICONS_EXPR := source_turret_source_text_state.SOURCE_TURRET_ICONS_EXPR
const SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_METHOD := source_turret_source_text_state.SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_METHOD
const SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_JAVA_METHOD := source_turret_source_text_state.SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_JAVA_METHOD
const SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_GENERATED_OWNER := source_turret_source_text_state.SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_GENERATED_OWNER
const SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_EXPR := source_turret_source_text_state.SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_EXPR

static func _turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func load_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_LOAD_STATE,
		"method": SOURCE_TURRET_LOAD_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"super_load_expr": SOURCE_TURRET_LOAD_SUPER_EXPR,
		"drawer_load_expr": SOURCE_TURRET_LOAD_DRAWER_EXPR,
		"super_load_called": true,
		"drawer_load_called": true,
	}

static func generated_turret_load_bridge_state() -> Dictionary:
	var result = _turret_call(SOURCE_TURRET_LOAD_JAVA_METHOD, [])
	var canonical = load_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_LOAD_STATE,
		"generated_owner": SOURCE_TURRET_LOAD_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("drawer_load_called", null) == canonical.get("drawer_load_called", null),
	}

static func draw_plan_region_state(plan: Variant, list: Variant) -> Dictionary:
	var drawer_draw_plan_call: Dictionary = {"call": SOURCE_TURRET_DRAW_PLAN_REGION_EXPR, "plan": plan, "list": list}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_DRAW_PLAN_REGION_STATE,
		"method": SOURCE_TURRET_DRAW_PLAN_REGION_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"drawer_draw_plan_expr": SOURCE_TURRET_DRAW_PLAN_REGION_EXPR,
		"plan": plan,
		"list": list,
		"drawer_draw_plan_call": drawer_draw_plan_call,
		"drawer_draw_plan_called": true,
	}

static func generated_turret_draw_plan_region_bridge_state(plan: Variant, list: Variant) -> Dictionary:
	var result = _turret_call(SOURCE_TURRET_DRAW_PLAN_REGION_JAVA_METHOD, [plan, list])
	var canonical = draw_plan_region_state(plan, list)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_DRAW_PLAN_REGION_STATE,
		"generated_owner": SOURCE_TURRET_DRAW_PLAN_REGION_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("drawer_draw_plan_called", null) == canonical.get("drawer_draw_plan_called", null) and result.get("plan", null) == canonical.get("plan", null) and result.get("list", null) == canonical.get("list", null),
	}

static func icons_state() -> Dictionary:
	var drawer_final_icons_return: Array = ["drawer.finalIcons(this)"]
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_ICONS_STATE,
		"method": SOURCE_TURRET_ICONS_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"drawer_final_icons_expr": SOURCE_TURRET_ICONS_EXPR,
		"drawer_final_icons_called": true,
		"icons": drawer_final_icons_return,
	}

static func generated_turret_icons_bridge_state() -> Dictionary:
	var result = _turret_call(SOURCE_TURRET_ICONS_JAVA_METHOD, [])
	var canonical = icons_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_ICONS_STATE,
		"generated_owner": SOURCE_TURRET_ICONS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("drawer_final_icons_called", null) == canonical.get("drawer_final_icons_called", null) and result.get("icons", null) == canonical.get("icons", null),
	}

static func get_regions_to_outline_state(out: Variant) -> Dictionary:
	var drawer_get_regions_to_outline_call: Dictionary = {"call": SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_EXPR, "out": out}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_STATE,
		"method": SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"drawer_get_regions_to_outline_expr": SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_EXPR,
		"out": out,
		"drawer_get_regions_to_outline_call": drawer_get_regions_to_outline_call,
		"drawer_get_regions_to_outline_called": true,
	}

static func generated_get_regions_to_outline_bridge_state(out: Variant) -> Dictionary:
	var result = _turret_call(SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_JAVA_METHOD, [out])
	var canonical = get_regions_to_outline_state(out)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_STATE,
		"generated_owner": SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("drawer_get_regions_to_outline_called", null) == canonical.get("drawer_get_regions_to_outline_called", null) and result.get("out", null) == canonical.get("out", null),
	}
