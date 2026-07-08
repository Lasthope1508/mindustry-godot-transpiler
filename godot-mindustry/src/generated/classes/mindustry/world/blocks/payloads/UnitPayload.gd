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
	var unit_type: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_unit_payload_content_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public UnlockableContent content(){", "return_expr": "return unit.type;", "unit_type": unit_type, "content": unit_type}

func java_method_requirements_5(_args: Array = []) -> Variant:
	var unit_type: Variant = _args[0] if _args.size() > 0 else null
	var total_requirements: Variant = _args[1] if _args.size() > 1 else []
	var get_total_requirements_call: Dictionary = {"call": "unit.type.getTotalRequirements();", "unit_type": unit_type, "requirements": total_requirements}
	return {"source_owner": "PortGame.source_unit_payload_requirements_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public ItemStack[] requirements(){", "return_expr": "return unit.type.getTotalRequirements();", "unit_type": unit_type, "requirements": total_requirements, "get_total_requirements_call": get_total_requirements_call}

func java_method_buildTime_6(_args: Array = []) -> Variant:
	var unit_type: Variant = _args[0] if _args.size() > 0 else null
	var build_time: float = float(_args[1] if _args.size() > 1 else 0.0)
	var get_build_time_call: Dictionary = {"call": "unit.type.getBuildTime();", "unit_type": unit_type, "buildTime": build_time}
	return {"source_owner": "PortGame.source_unit_payload_build_time_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public float buildTime(){", "return_expr": "return unit.type.getBuildTime();", "unit_type": unit_type, "buildTime": build_time, "get_build_time_call": get_build_time_call}

func java_method_write_7(_args: Array = []) -> Variant:
	var payload_unit: int = int(_args[0] if _args.size() > 0 else 0)
	var unit_class_id: int = int(_args[1] if _args.size() > 1 else 0)
	var write_calls: Array = [{"call": "write.b(payloadUnit);", "method": "write.b", "value": payload_unit}, {"call": "write.b(unit.classId());", "method": "write.b", "value": unit_class_id}, {"call": "unit.write(write);", "method": "unit.write", "called": true}]
	return {"source_owner": "PortGame.source_unit_payload_write_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public void write(Writes write){", "payload_unit_write_expr": "write.b(payloadUnit);", "unit_class_id_write_expr": "write.b(unit.classId());", "unit_write_expr": "unit.write(write);", "payload_unit": payload_unit, "unit_class_id": unit_class_id, "unit_write_called": true, "write_calls": write_calls}

func java_method_set_8(_args: Array = []) -> Variant:
	var x: float = float(_args[0] if _args.size() > 0 else 0.0)
	var y: float = float(_args[1] if _args.size() > 1 else 0.0)
	var rotation_value: float = float(_args[2] if _args.size() > 2 else 0.0)
	var set_call: Dictionary = {"call": "unit.set(x, y);", "x": x, "y": y}
	return {"source_owner": "PortGame.source_unit_payload_set_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public void set(float x, float y, float rotation){", "set_expr": "unit.set(x, y);", "rotation_assign_expr": "unit.rotation = rotation;", "x": x, "y": y, "rotation": rotation_value, "set_called": true, "set_call": set_call}

func java_method_x_9(_args: Array = []) -> Variant:
	var unit_x: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "PortGame.source_unit_payload_x_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public float x(){", "return_expr": "return unit.x;", "unit_x": unit_x, "x": unit_x}

func java_method_y_10(_args: Array = []) -> Variant:
	var unit_y: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "PortGame.source_unit_payload_y_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public float y(){", "return_expr": "return unit.y;", "unit_y": unit_y, "y": unit_y}

func java_method_rotation_11(_args: Array = []) -> Variant:
	var unit_rotation: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "PortGame.source_unit_payload_rotation_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public float rotation(){", "return_expr": "return unit.rotation;", "unit_rotation": unit_rotation, "rotation": unit_rotation}

func java_method_size_12(_args: Array = []) -> Variant:
	var unit_hit_size: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "PortGame.source_unit_payload_size_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "override_expr": "@Override", "method": "public float size(){", "return_expr": "return unit.hitSize;", "unit_hit_size": unit_hit_size, "size": unit_hit_size}

func java_method_dump_13(_args: Array = []) -> Variant:
	var unit_type_null: bool = bool(_args[0] if _args.size() > 0 else false)
	var units_can_create: bool = bool(_args[1] if _args.size() > 1 else true)
	var solid_present: bool = bool(_args[2] if _args.size() > 2 else false)
	var unit_rotation: float = float(_args[3] if _args.size() > 3 else 0.0)
	var unit_x: float = float(_args[4] if _args.size() > 4 else 0.0)
	var unit_y: float = float(_args[5] if _args.size() > 5 else 0.0)
	var solid_solid: bool = bool(_args[6] if _args.size() > 6 else false)
	var unit_type_flying: bool = bool(_args[7] if _args.size() > 7 else false)
	var unit_physic_size: float = float(_args[8] if _args.size() > 8 else 0.0)
	var units_count: int = int(_args[9] if _args.size() > 9 else 0)
	var net_client: bool = bool(_args[10] if _args.size() > 10 else false)
	var can_create_evaluated: bool = not unit_type_null
	var can_create_guard: bool = can_create_evaluated and not units_can_create
	var before_solid_returned: bool = unit_type_null or can_create_guard
	var solid_evaluated: bool = not before_solid_returned
	var solid_present_guard: bool = solid_evaluated and solid_present
	var _source_arc_angles_trns_vec := func(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:
		var radians := deg_to_rad(angle_degrees)
		var cos_value := cos(radians)
		var sin_value := sin(radians)
		return {"x": x_value * cos_value - y_value * sin_value, "y": x_value * sin_value + y_value * cos_value, "angle": angle_degrees, "source": "rv.set(x, y).rotate(angle)", "vec2RotateSource": "newX = this.x * cos - this.y * sin; newY = this.x * sin + this.y * cos"}
	var source_tilesize: float = 8.0
	var trns_vec: Dictionary = _source_arc_angles_trns_vec.call(unit_rotation, 1.0, 0.0) if solid_present_guard else {"x": 0.0, "y": 0.0}
	var tx: int = int(round((unit_x + float(trns_vec.get("x", 0.0))) / source_tilesize)) if solid_present_guard else 0
	var ty: int = int(round((unit_y + float(trns_vec.get("y", 0.0))) / source_tilesize)) if solid_present_guard else 0
	var solid_solid_evaluated: bool = solid_present_guard
	var solid_guard: bool = solid_solid_evaluated and solid_solid
	var before_overlap_returned: bool = before_solid_returned or solid_guard
	var overlap_evaluated: bool = not before_overlap_returned
	var units_count_evaluated: bool = overlap_evaluated and not unit_type_flying
	var overlap_radius: float = unit_physic_size * 1.05 if units_count_evaluated else 0.0
	var overlap_guard: bool = units_count_evaluated and units_count > 0
	var before_client_returned: bool = before_overlap_returned or overlap_guard
	var net_client_evaluated: bool = not before_client_returned
	var client_guard: bool = net_client_evaluated and net_client
	var returned: bool = before_client_returned or client_guard
	var dump_result: Variant = null
	if unit_type_null:
		dump_result = true
	elif can_create_guard:
		dump_result = false
	elif solid_guard:
		dump_result = false
	elif overlap_guard:
		dump_result = false
	elif client_guard:
		dump_result = true
	var overlayTime_after: float = 1.0 if can_create_guard else 0.0
	var overlayRegion_after: Variant = null
	var solid_call: Dictionary = {}
	if solid_solid_evaluated:
		solid_call = {"call": "solid.solid(tx, ty)", "tx": tx, "ty": ty, "result": solid_solid}
	var units_count_call: Dictionary = {}
	if units_count_evaluated:
		units_count_call = {"call": "Units.count(unit.x, unit.y, unit.physicSize() * 1.05f, o -> o.isGrounded() && (o.type.allowLegStep == unit.type.allowLegStep))", "x": unit_x, "y": unit_y, "radius": overlap_radius, "result": units_count}
	var deferred_remaining_dump: bool = not returned
	return {"source_owner": "PortGame.source_unit_payload_dump_no_client_guard_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "arc_vec2_source": "arc-core/src/arc/math/geom/Vec2.java", "world_source": "core/src/mindustry/core/World.java", "vars_source": "core/src/mindustry/Vars.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "field_overlay_time_expr": "public float overlayTime = 0f;", "field_overlay_region_expr": "public @Nullable TextureRegion overlayRegion;", "override_expr": "@Override", "method": "public boolean dump(){", "todo_comment_expr": "//TODO should not happen", "type_null_guard_expr": "if(unit.type == null) return true;", "can_create_guard_expr": "if(!Units.canCreate(unit.team, unit.type)){", "overlay_time_assign_expr": "overlayTime = 1f;", "overlay_region_assign_expr": "overlayRegion = null;", "solidity_comment_expr": "//check if unit can be dumped here", "solid_assign_expr": "SolidPred solid = unit.solidity();", "solid_guard_expr": "if(solid != null){", "trns_expr": "Tmp.v1.trns(unit.rotation, 1f);", "vec2_trns_amount_expr": "public Vec2 trns(float angle, float amount){", "vec2_trns_amount_return_expr": "return set(amount, 0).rotate(angle);", "tile_assign_expr": "int tx = World.toTile(unit.x + Tmp.v1.x), ty = World.toTile(unit.y + Tmp.v1.y);", "world_to_tile_method": "public static int toTile(float coord){", "world_to_tile_return": "return Math.round(coord / tilesize);", "vars_tilesize_field": "public static final int tilesize = 8;", "solid_block_comment_expr": "//cannot dump on solid blocks", "solid_solid_guard_expr": "if(solid.solid(tx, ty)) return false;", "overlap_comment_expr": "//cannot dump when there's a lot of overlap going on", "overlap_guard_expr": "if(!unit.type.flying && Units.count(unit.x, unit.y, unit.physicSize() * 1.05f, o -> o.isGrounded() && (o.type.allowLegStep == unit.type.allowLegStep)) > 0){", "unit_type_flying_expr": "unit.type.flying", "units_count_expr": "Units.count(unit.x, unit.y, unit.physicSize() * 1.05f, o -> o.isGrounded() && (o.type.allowLegStep == unit.type.allowLegStep))", "physic_size_expr": "unit.physicSize()", "radius_multiplier_expr": "1.05f", "predicate_is_grounded_expr": "o.isGrounded()", "predicate_allow_leg_step_expr": "o.type.allowLegStep == unit.type.allowLegStep", "return_false_expr": "return false;", "client_dumping_comment_expr": "//no client dumping", "net_client_guard_expr": "if(Vars.net.client()) return true;", "vars_net_field": "public static Net net;", "return_true_expr": "return true;", "prevents_stacking_comment_expr": "//prevents stacking", "unit_type_null": unit_type_null, "units_can_create": units_can_create, "solid_present": solid_present, "unit_rotation": unit_rotation, "unit_x": unit_x, "unit_y": unit_y, "solid_solid": solid_solid, "unit_type_flying": unit_type_flying, "unit_physic_size": unit_physic_size, "units_count": units_count, "net_client": net_client, "can_create_evaluated": can_create_evaluated, "can_create_guard": can_create_guard, "before_solid_returned": before_solid_returned, "solid_evaluated": solid_evaluated, "solid_present_guard": solid_present_guard, "trns_vec": trns_vec, "tx": tx, "ty": ty, "solid_solid_evaluated": solid_solid_evaluated, "solid_call": solid_call, "solid_guard": solid_guard, "before_overlap_returned": before_overlap_returned, "overlap_evaluated": overlap_evaluated, "units_count_evaluated": units_count_evaluated, "units_count_call": units_count_call, "overlap_radius": overlap_radius, "overlap_guard": overlap_guard, "before_client_returned": before_client_returned, "net_client_evaluated": net_client_evaluated, "client_guard": client_guard, "returned": returned, "dump": dump_result, "overlayTime_after": overlayTime_after, "overlayRegion_after": overlayRegion_after, "deferred_remaining_dump": deferred_remaining_dump}

func java_method_drawShadow_14(_args: Array = []) -> Variant:
	return null

func java_method_draw_15(_args: Array = []) -> Variant:
	return null

func java_method_icon_16(_args: Array = []) -> Variant:
	return null

func java_constructor_UnitPayload_0(_args: Array = []) -> Variant:
	var unit: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_unit_payload_constructor_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "constructor": "public UnitPayload(Unit unit){", "unit_assign_expr": "this.unit = unit;", "unit": unit, "unit_after": unit}
