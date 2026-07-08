# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/payloads/UnitPayload.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.payloads"
const JAVA_KIND := "class"
const JAVA_NAME := "UnitPayload"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Payload"]
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "overlayDuration", "type": "float"}, {"modifiers": ["public"], "name": "unit", "type": "Unit"}, {"modifiers": ["public"], "name": "overlayTime", "type": "float"}, {"modifiers": ["public"], "name": "overlayRegion", "type": "TextureRegion"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "UnitPayload", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "showOverlay", "parameters": [{"name": "icon", "type": "TextureRegion", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "showOverlay", "parameters": [{"name": "icon", "type": "TextureRegionDrawable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "contentEquals", "parameters": [{"name": "other", "type": "Payload", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "unitHolder", "type": "Unit", "varargs": false}, {"name": "buildingHolder", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "content", "parameters": [], "return_type": "UnlockableContent"}, {"modifiers": ["public"], "name": "requirements", "parameters": [], "return_type": "ItemStack"}, {"modifiers": ["public"], "name": "buildTime", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "write", "type": "Writes", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "set", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "x", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "y", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "rotation", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "size", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "dump", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "drawShadow", "parameters": [{"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "icon", "parameters": [], "return_type": "TextureRegion"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_showOverlay_0(_args: Array = []) -> Variant:
	var icon: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_unit_payload_show_overlay_texture_region_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "overlay_time_field_expr": "public float overlayTime = 0f;", "overlay_region_field_expr": "public @Nullable TextureRegion overlayRegion;", "method": "public void showOverlay(TextureRegion icon){", "overlay_region_assign_expr": "overlayRegion = icon;", "overlay_time_assign_expr": "overlayTime = 1f;", "icon": icon, "overlayRegion_after": icon, "overlayTime_after": 1.0}

func java_method_showOverlay_1(_args: Array = []) -> Variant:
	var icon_null: bool = bool(_args[0] if _args.size() > 0 else false)
	var headless: bool = bool(_args[1] if _args.size() > 1 else false)
	var region: Variant = _args[2] if _args.size() > 2 else null
	var returned: bool = icon_null or headless
	var overlay_region_after: Variant = null
	var overlay_time_after: Variant = null
	var delegate_call: Variant = null
	if not returned:
		overlay_region_after = region
		overlay_time_after = 1.0
		delegate_call = {"call": "showOverlay(icon.getRegion());", "region": region}
	return {"source_owner": "PortGame.source_unit_payload_show_overlay_drawable_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "import_expr": "import static mindustry.Vars.*;", "method": "public void showOverlay(TextureRegionDrawable icon){", "guard_expr": "if(icon == null || headless) return;", "delegate_expr": "showOverlay(icon.getRegion());", "icon_null": icon_null, "headless": headless, "region": region, "returned": returned, "get_region_called": not returned, "show_overlay_called": not returned, "delegate_call": delegate_call, "overlayRegion_after": overlay_region_after, "overlayTime_after": overlay_time_after}

func java_method_contentEquals_2(_args: Array = []) -> Variant:
	var other_is_unit_payload: bool = bool(_args[0] if _args.size() > 0 else false)
	var other_unit_type: Variant = _args[1] if _args.size() > 1 else null
	var unit_type: Variant = _args[2] if _args.size() > 2 else null
	var content_equals: bool = other_is_unit_payload and other_unit_type == unit_type
	return {"source_owner": "PortGame.source_unit_payload_content_equals_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public boolean contentEquals(Payload other){", "return_expr": "return other instanceof UnitPayload up && up.unit.type == unit.type;", "other_is_unit_payload": other_is_unit_payload, "other_unit_type": other_unit_type, "unit_type": unit_type, "content_equals": content_equals}

func java_method_update_3(_args: Array = []) -> Variant:
	var unit_type: Variant = _args[0] if _args.size() > 0 else null
	var unit: Variant = _args[1] if _args.size() > 1 else null
	var unit_holder: Variant = _args[2] if _args.size() > 2 else null
	var building_holder: Variant = _args[3] if _args.size() > 3 else null
	var update_payload_called: bool = true
	var update_payload_call: Dictionary = {"call": "unit.type.updatePayload(unit, unitHolder, buildingHolder);", "unit_type": unit_type, "unit": unit, "unitHolder": unit_holder, "buildingHolder": building_holder}
	return {"source_owner": "PortGame.source_unit_payload_update_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public void update(@Nullable Unit unitHolder, @Nullable Building buildingHolder){", "update_payload_expr": "unit.type.updatePayload(unit, unitHolder, buildingHolder);", "unit_type": unit_type, "unit": unit, "unitHolder": unit_holder, "buildingHolder": building_holder, "update_payload_called": update_payload_called, "update_payload_call": update_payload_call}

func java_method_content_4(_args: Array = []) -> Variant:
	return null

func java_method_requirements_5(_args: Array = []) -> Variant:
	return null

func java_method_buildTime_6(_args: Array = []) -> Variant:
	return null

func java_method_write_7(_args: Array = []) -> Variant:
	return null

func java_method_set_8(_args: Array = []) -> Variant:
	return null

func java_method_x_9(_args: Array = []) -> Variant:
	return null

func java_method_y_10(_args: Array = []) -> Variant:
	return null

func java_method_rotation_11(_args: Array = []) -> Variant:
	return null

func java_method_size_12(_args: Array = []) -> Variant:
	return null

func java_method_dump_13(_args: Array = []) -> Variant:
	return null

func java_method_drawShadow_14(_args: Array = []) -> Variant:
	return null

func java_method_draw_15(_args: Array = []) -> Variant:
	return null

func java_method_icon_16(_args: Array = []) -> Variant:
	return null

func java_constructor_UnitPayload_0(_args: Array = []) -> Variant:
	var unit: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_unit_payload_constructor_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "constructor": "public UnitPayload(Unit unit){", "unit_assign_expr": "this.unit = unit;", "unit": unit, "unit_after": unit}
