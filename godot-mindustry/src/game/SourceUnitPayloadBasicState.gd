extends RefCounted
class_name SourceUnitPayloadBasicState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

const SOURCE_UNIT_PAYLOAD_SOURCE := "core/src/mindustry/world/blocks/payloads/UnitPayload.java"
const SOURCE_UNIT_PAYLOAD_CLASS_EXPR := "public class UnitPayload implements Payload{"
const SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR := "public Unit unit;"
const SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR := "@Override"
const SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR := "//TODO should not happen"
const SOURCE_UNIT_PAYLOAD_TYPE_NULL_GUARD_EXPR := "if(unit.type == null) return;"
const SOURCE_UNIT_PAYLOAD_OVERLAY_DURATION_FIELD_EXPR := "public static final float overlayDuration = 40f;"
const SOURCE_UNIT_PAYLOAD_OVERLAY_TIME_FIELD_EXPR := "public float overlayTime = 0f;"
const SOURCE_UNIT_PAYLOAD_OVERLAY_REGION_FIELD_EXPR := "public @Nullable TextureRegion overlayRegion;"
const SOURCE_UNIT_PAYLOAD_DRAW_METHOD := "public void draw(){"

const SOURCE_UNIT_PAYLOAD_IMPORT_STATIC_VARS_EXPR := "import static mindustry.Vars.*;"
const SOURCE_UNIT_PAYLOAD_CONSTRUCTOR := "public UnitPayload(Unit unit){"
const SOURCE_UNIT_PAYLOAD_UNIT_ASSIGN_EXPR := "this.unit = unit;"
const SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_TEXTURE_REGION_METHOD := "public void showOverlay(TextureRegion icon){"
const SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_REGION_ASSIGN_EXPR := "overlayRegion = icon;"
const SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_TIME_ASSIGN_EXPR := "overlayTime = 1f;"
const SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_METHOD := "public void showOverlay(TextureRegionDrawable icon){"
const SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_GUARD_EXPR := "if(icon == null || headless) return;"
const SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_DELEGATE_EXPR := "showOverlay(icon.getRegion());"

static func constructor_state(unit: Variant) -> Dictionary:
	return {
		"source_owner": "PortGame.source_unit_payload_constructor_state",
		"source": SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"constructor": SOURCE_UNIT_PAYLOAD_CONSTRUCTOR,
		"unit_assign_expr": SOURCE_UNIT_PAYLOAD_UNIT_ASSIGN_EXPR,
		"unit": unit,
		"unit_after": unit,
	}

static func generated_constructor_bridge_state(unit: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_constructor_UnitPayload_0", [unit], null)
	var canonical = constructor_state(unit)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_constructor_state",
		"generated_owner": "UnitPayload.java_constructor_UnitPayload_0",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func show_overlay_texture_region_state(icon: Variant) -> Dictionary:
	return {
		"source_owner": "PortGame.source_unit_payload_show_overlay_texture_region_state",
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
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_showOverlay_0", [icon], null)
	var canonical = show_overlay_texture_region_state(icon)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_show_overlay_texture_region_state",
		"generated_owner": "UnitPayload.java_method_showOverlay_0",
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
		"source_owner": "PortGame.source_unit_payload_show_overlay_drawable_state",
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
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_showOverlay_1", [icon_null, headless, region], null)
	var canonical = show_overlay_drawable_state(icon_null, headless, region)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_show_overlay_drawable_state",
		"generated_owner": "UnitPayload.java_method_showOverlay_1",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
