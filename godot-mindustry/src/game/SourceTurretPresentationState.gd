extends RefCounted
class_name SourceTurretPresentationState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const SOURCE_TURRET_GENERATED_CLASS := "res://src/generated/classes/mindustry/world/blocks/defense/turrets/Turret.gd"

static func _turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func load_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_LOAD_STATE,
		"method": "public void load(){",
		"override_expr": "@Override",
		"super_load_expr": "super.load();",
		"drawer_load_expr": "drawer.load(this);",
		"super_load_called": true,
		"drawer_load_called": true,
	}

static func generated_turret_load_bridge_state() -> Dictionary:
	var result = _turret_call("java_method_load_4", [])
	var canonical = load_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_LOAD_STATE,
		"generated_owner": "turret.java_method_load_4",
		"result": result,
		"canonical": canonical,
		"matches": result.get("drawer_load_called", null) == canonical.get("drawer_load_called", null),
	}

static func draw_plan_region_state(plan: Variant, list: Variant) -> Dictionary:
	var drawer_draw_plan_call: Dictionary = {"call": "drawer.drawPlan(this, plan, list);", "plan": plan, "list": list}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_DRAW_PLAN_REGION_STATE,
		"method": "public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){",
		"override_expr": "@Override",
		"drawer_draw_plan_expr": "drawer.drawPlan(this, plan, list);",
		"plan": plan,
		"list": list,
		"drawer_draw_plan_call": drawer_draw_plan_call,
		"drawer_draw_plan_called": true,
	}

static func generated_turret_draw_plan_region_bridge_state(plan: Variant, list: Variant) -> Dictionary:
	var result = _turret_call("java_method_drawPlanRegion_5", [plan, list])
	var canonical = draw_plan_region_state(plan, list)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_DRAW_PLAN_REGION_STATE,
		"generated_owner": "turret.java_method_drawPlanRegion_5",
		"result": result,
		"canonical": canonical,
		"matches": result.get("drawer_draw_plan_called", null) == canonical.get("drawer_draw_plan_called", null) and result.get("plan", null) == canonical.get("plan", null) and result.get("list", null) == canonical.get("list", null),
	}

static func icons_state() -> Dictionary:
	var drawer_final_icons_return: Array = ["drawer.finalIcons(this)"]
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_ICONS_STATE,
		"method": "public TextureRegion[] icons(){",
		"override_expr": "@Override",
		"drawer_final_icons_expr": "return drawer.finalIcons(this);",
		"drawer_final_icons_called": true,
		"icons": drawer_final_icons_return,
	}

static func generated_turret_icons_bridge_state() -> Dictionary:
	var result = _turret_call("java_method_icons_6", [])
	var canonical = icons_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_ICONS_STATE,
		"generated_owner": "turret.java_method_icons_6",
		"result": result,
		"canonical": canonical,
		"matches": result.get("drawer_final_icons_called", null) == canonical.get("drawer_final_icons_called", null) and result.get("icons", null) == canonical.get("icons", null),
	}

static func get_regions_to_outline_state(out: Variant) -> Dictionary:
	var drawer_get_regions_to_outline_call: Dictionary = {"call": "drawer.getRegionsToOutline(this, out);", "out": out}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_STATE,
		"method": "public void getRegionsToOutline(Seq<TextureRegion> out){",
		"override_expr": "@Override",
		"drawer_get_regions_to_outline_expr": "drawer.getRegionsToOutline(this, out);",
		"out": out,
		"drawer_get_regions_to_outline_call": drawer_get_regions_to_outline_call,
		"drawer_get_regions_to_outline_called": true,
	}

static func generated_get_regions_to_outline_bridge_state(out: Variant) -> Dictionary:
	var result = _turret_call("java_method_getRegionsToOutline_7", [out])
	var canonical = get_regions_to_outline_state(out)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_GET_REGIONS_TO_OUTLINE_STATE,
		"generated_owner": "turret.java_method_getRegionsToOutline_7",
		"result": result,
		"canonical": canonical,
		"matches": result.get("drawer_get_regions_to_outline_called", null) == canonical.get("drawer_get_regions_to_outline_called", null) and result.get("out", null) == canonical.get("out", null),
	}
