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
const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")
const source_unit_payload_basic_state := preload("res://src/game/SourceUnitPayloadBasicState.gd")
const source_unit_payload_content_state := preload("res://src/game/SourceUnitPayloadContentState.gd")
const source_unit_payload_requirements_state := preload("res://src/game/SourceUnitPayloadRequirementsState.gd")
const source_unit_payload_io_state := preload("res://src/game/SourceUnitPayloadIoState.gd")
const source_unit_payload_draw_state := preload("res://src/game/SourceUnitPayloadDrawState.gd")
const source_unit_payload_dump_state := preload("res://src/game/SourceUnitPayloadDumpState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const SOURCE_UNIT_PAYLOAD_OVERLAY_DURATION := source_unit_defaults.PAYLOAD_OVERLAY_DURATION
const SOURCE_UNIT_PAYLOAD_OVERLAY_ALPHA := source_unit_defaults.PAYLOAD_OVERLAY_ALPHA
const SOURCE_UNIT_PAYLOAD_WARNING_SIZE := source_unit_defaults.PAYLOAD_WARNING_SIZE
const SOURCE_TILESIZE := source_world_defaults.TILESIZE
const SOURCE_UNIT_PAYLOAD_OVERLAP_RADIUS_MULTIPLIER := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_OVERLAP_RADIUS_MULTIPLIER
const SOURCE_UNIT_PAYLOAD_DUMP_SPAWN_VELOCITY_RANGE := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_SPAWN_VELOCITY_RANGE
const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_LOOKAHEAD := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLID_LOOKAHEAD
const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_CALL_EXPR := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_CALL_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_UNITS_COUNT_EXPR := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_UNITS_COUNT_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_VELOCITY_ADD_EXPR := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_VELOCITY_ADD_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_METHOD := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_METHOD
const SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_RETURN := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_RETURN
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_ADD_EXPR := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_UNIT_ADD_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOADED_EXPR := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOADED_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_EXPR := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_EVENT_FIRE_EXPR := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_EVENT_FIRE_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_COMMENT := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_COMMENT
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CLASS := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CLASS
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CONSTRUCTOR := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CONSTRUCTOR
const SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_EXPR := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_EXPR
const SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_METHOD := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_METHOD
const SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_GUARD := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_GUARD
const SOURCE_UNIT_PAYLOAD_DUMP_RETURN_TRUE_STATEMENT_EXPR := source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_RETURN_TRUE_STATEMENT_EXPR

func java_method_showOverlay_0(_args: Array = []) -> Variant:
	var icon: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "port_game.source_unit_payload_show_overlay_texture_region_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "overlay_time_field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERLAY_TIME_FIELD_EXPR, "overlay_region_field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERLAY_REGION_FIELD_EXPR, "method": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_TEXTURE_REGION_METHOD, "overlay_region_assign_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_REGION_ASSIGN_EXPR, "overlay_time_assign_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_TIME_ASSIGN_EXPR, "icon": icon, "overlayRegion_after": icon, "overlayTime_after": 1.0}

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
		delegate_call = {"call": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_DELEGATE_EXPR, "region": region}
	return {"source_owner": "port_game.source_unit_payload_show_overlay_drawable_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "import_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_IMPORT_STATIC_VARS_EXPR, "method": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_METHOD, "guard_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_GUARD_EXPR, "delegate_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SHOW_OVERLAY_DRAWABLE_DELEGATE_EXPR, "icon_null": icon_null, "headless": headless, "region": region, "returned": returned, "get_region_called": not returned, "show_overlay_called": not returned, "delegate_call": delegate_call, "overlayRegion_after": overlay_region_after, "overlayTime_after": overlay_time_after}

func java_method_contentEquals_2(_args: Array = []) -> Variant:
	var other_is_unit_payload: bool = bool(_args[0] if _args.size() > 0 else false)
	var other_unit_type: Variant = _args[1] if _args.size() > 1 else null
	var unit_type: Variant = _args[2] if _args.size() > 2 else null
	var content_equals: bool = other_is_unit_payload and other_unit_type == unit_type
	return {"source_owner": "port_game.source_unit_payload_content_equals_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR, "override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR, "method": source_unit_payload_content_state.SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_METHOD, "return_expr": source_unit_payload_content_state.SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_RETURN_EXPR, "other_is_unit_payload": other_is_unit_payload, "other_unit_type": other_unit_type, "unit_type": unit_type, "content_equals": content_equals}

func java_method_update_3(_args: Array = []) -> Variant:
	var unit_type: Variant = _args[0] if _args.size() > 0 else null
	var unit: Variant = _args[1] if _args.size() > 1 else null
	var unit_holder: Variant = _args[2] if _args.size() > 2 else null
	var building_holder: Variant = _args[3] if _args.size() > 3 else null
	var update_payload_called: bool = true
	var update_payload_call: Dictionary = {"call": source_unit_payload_content_state.SOURCE_UNIT_PAYLOAD_UPDATE_PAYLOAD_EXPR, "unit_type": unit_type, "unit": unit, "unitHolder": unit_holder, "buildingHolder": building_holder}
	return {"source_owner": "port_game.source_unit_payload_update_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR, "override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR, "method": source_unit_payload_content_state.SOURCE_UNIT_PAYLOAD_UPDATE_METHOD, "update_payload_expr": source_unit_payload_content_state.SOURCE_UNIT_PAYLOAD_UPDATE_PAYLOAD_EXPR, "unit_type": unit_type, "unit": unit, "unitHolder": unit_holder, "buildingHolder": building_holder, "update_payload_called": update_payload_called, "update_payload_call": update_payload_call}

func java_method_content_4(_args: Array = []) -> Variant:
	var unit_type: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "port_game.source_unit_payload_content_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR, "override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR, "method": source_unit_payload_content_state.SOURCE_UNIT_PAYLOAD_CONTENT_METHOD, "return_expr": source_unit_payload_content_state.SOURCE_UNIT_PAYLOAD_CONTENT_RETURN_EXPR, "unit_type": unit_type, "content": unit_type}

func java_method_requirements_5(_args: Array = []) -> Variant:
	var unit_type: Variant = _args[0] if _args.size() > 0 else null
	var total_requirements: Variant = _args[1] if _args.size() > 1 else []
	var get_total_requirements_call: Dictionary = {"call": source_unit_payload_requirements_state.SOURCE_UNIT_PAYLOAD_REQUIREMENTS_CALL_EXPR, "unit_type": unit_type, "requirements": total_requirements}
	return {"source_owner": "port_game.source_unit_payload_requirements_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR, "override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR, "method": source_unit_payload_requirements_state.SOURCE_UNIT_PAYLOAD_REQUIREMENTS_METHOD, "return_expr": source_unit_payload_requirements_state.SOURCE_UNIT_PAYLOAD_REQUIREMENTS_RETURN_EXPR, "unit_type": unit_type, "requirements": total_requirements, "get_total_requirements_call": get_total_requirements_call}

func java_method_buildTime_6(_args: Array = []) -> Variant:
	var unit_type: Variant = _args[0] if _args.size() > 0 else null
	var build_time: float = float(_args[1] if _args.size() > 1 else 0.0)
	var get_build_time_call: Dictionary = {"call": source_unit_payload_requirements_state.SOURCE_UNIT_PAYLOAD_BUILD_TIME_CALL_EXPR, "unit_type": unit_type, "buildTime": build_time}
	return {"source_owner": "port_game.source_unit_payload_build_time_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR, "override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR, "method": source_unit_payload_requirements_state.SOURCE_UNIT_PAYLOAD_BUILD_TIME_METHOD, "return_expr": source_unit_payload_requirements_state.SOURCE_UNIT_PAYLOAD_BUILD_TIME_RETURN_EXPR, "unit_type": unit_type, "buildTime": build_time, "get_build_time_call": get_build_time_call}

func java_method_write_7(_args: Array = []) -> Variant:
	var payload_unit: int = int(_args[0] if _args.size() > 0 else 0)
	var unit_class_id: int = int(_args[1] if _args.size() > 1 else 0)
	var write_calls: Array = [{"call": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_WRITE_PAYLOAD_UNIT_EXPR, "method": "write.b", "value": payload_unit}, {"call": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_WRITE_CLASS_ID_EXPR, "method": "write.b", "value": unit_class_id}, {"call": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_WRITE_UNIT_EXPR, "method": "unit.write", "called": true}]
	return {"source_owner": "port_game.source_unit_payload_write_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR, "override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR, "method": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_WRITE_METHOD, "payload_unit_write_expr": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_WRITE_PAYLOAD_UNIT_EXPR, "unit_class_id_write_expr": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_WRITE_CLASS_ID_EXPR, "unit_write_expr": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_WRITE_UNIT_EXPR, "payload_unit": payload_unit, "unit_class_id": unit_class_id, "unit_write_called": true, "write_calls": write_calls}

func java_method_set_8(_args: Array = []) -> Variant:
	var x: float = float(_args[0] if _args.size() > 0 else 0.0)
	var y: float = float(_args[1] if _args.size() > 1 else 0.0)
	var rotation_value: float = float(_args[2] if _args.size() > 2 else 0.0)
	var set_call: Dictionary = {"call": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_SET_EXPR, "x": x, "y": y}
	return {"source_owner": "port_game.source_unit_payload_set_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR, "override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR, "method": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_SET_METHOD, "set_expr": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_SET_EXPR, "rotation_assign_expr": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_SET_ROTATION_ASSIGN_EXPR, "x": x, "y": y, "rotation": rotation_value, "set_called": true, "set_call": set_call}

func java_method_x_9(_args: Array = []) -> Variant:
	var unit_x: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "port_game.source_unit_payload_x_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR, "override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR, "method": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_X_METHOD, "return_expr": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_X_RETURN_EXPR, "unit_x": unit_x, "x": unit_x}

func java_method_y_10(_args: Array = []) -> Variant:
	var unit_y: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "port_game.source_unit_payload_y_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR, "override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR, "method": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_Y_METHOD, "return_expr": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_Y_RETURN_EXPR, "unit_y": unit_y, "y": unit_y}

func java_method_rotation_11(_args: Array = []) -> Variant:
	var unit_rotation: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "port_game.source_unit_payload_rotation_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR, "override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR, "method": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_ROTATION_METHOD, "return_expr": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_ROTATION_RETURN_EXPR, "unit_rotation": unit_rotation, "rotation": unit_rotation}

func java_method_size_12(_args: Array = []) -> Variant:
	var unit_hit_size: float = float(_args[0] if _args.size() > 0 else 0.0)
	return {"source_owner": "port_game.source_unit_payload_size_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR, "override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR, "method": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_SIZE_METHOD, "return_expr": source_unit_payload_io_state.SOURCE_UNIT_PAYLOAD_SIZE_RETURN_EXPR, "unit_hit_size": unit_hit_size, "size": unit_hit_size}

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
	var range_x: float = float(_args[11] if _args.size() > 11 else 0.0)
	var range_y: float = float(_args[12] if _args.size() > 12 else 0.0)
	var unit_id: Variant = _args[13] if _args.size() > 13 else null
	var can_create_evaluated: bool = not unit_type_null
	var can_create_guard: bool = can_create_evaluated and not units_can_create
	var before_solid_returned: bool = unit_type_null or can_create_guard
	var solid_evaluated: bool = not before_solid_returned
	var solid_present_guard: bool = solid_evaluated and solid_present
	var _source_arc_angles_trns_vec := func(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:
		var radians := deg_to_rad(angle_degrees)
		var cos_value := cos(radians)
		var sin_value := sin(radians)
		return {"x": x_value * cos_value - y_value * sin_value, "y": x_value * sin_value + y_value * cos_value, "angle": angle_degrees, "source": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_RETURN_EXPR, "vec2RotateSource": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_VEC2_ROTATE_RAD_EXPR}
	var source_tilesize: float = SOURCE_TILESIZE
	var solid_lookahead: float = SOURCE_UNIT_PAYLOAD_DUMP_SOLID_LOOKAHEAD
	var trns_vec: Dictionary = _source_arc_angles_trns_vec.call(unit_rotation, solid_lookahead, 0.0) if solid_present_guard else {"x": 0.0, "y": 0.0}
	var tx: int = int(round((unit_x + float(trns_vec.get("x", 0.0))) / source_tilesize)) if solid_present_guard else 0
	var ty: int = int(round((unit_y + float(trns_vec.get("y", 0.0))) / source_tilesize)) if solid_present_guard else 0
	var solid_solid_evaluated: bool = solid_present_guard
	var solid_guard: bool = solid_solid_evaluated and solid_solid
	var before_overlap_returned: bool = before_solid_returned or solid_guard
	var overlap_evaluated: bool = not before_overlap_returned
	var units_count_evaluated: bool = overlap_evaluated and not unit_type_flying
	var overlap_radius: float = unit_physic_size * SOURCE_UNIT_PAYLOAD_OVERLAP_RADIUS_MULTIPLIER if units_count_evaluated else 0.0
	var overlap_guard: bool = units_count_evaluated and units_count > 0
	var before_client_returned: bool = before_overlap_returned or overlap_guard
	var net_client_evaluated: bool = not before_client_returned
	var client_guard: bool = net_client_evaluated and net_client
	var before_spawn_returned: bool = before_client_returned or client_guard
	var spawn_evaluated: bool = not before_spawn_returned
	var returned: bool = before_spawn_returned or spawn_evaluated
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
	if spawn_evaluated:
		dump_result = true
	var overlayTime_after: float = 1.0 if can_create_guard else 0.0
	var overlayRegion_after: Variant = null
	var solid_call: Dictionary = {}
	if solid_solid_evaluated:
		solid_call = {"call": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_CALL_EXPR, "tx": tx, "ty": ty, "result": solid_solid}
	var units_count_call: Dictionary = {}
	if units_count_evaluated:
		units_count_call = {"call": SOURCE_UNIT_PAYLOAD_DUMP_UNITS_COUNT_EXPR, "x": unit_x, "y": unit_y, "radius": overlap_radius, "result": units_count}
	var velocity_add_call: Dictionary = {}
	var unit_add_called: bool = false
	var unit_unloaded_called: bool = false
	var event_fire_call: Dictionary = {}
	var notify_unit_spawn_call: Dictionary = {}
	var velocity_range: float = SOURCE_UNIT_PAYLOAD_DUMP_SPAWN_VELOCITY_RANGE
	if spawn_evaluated:
		velocity_add_call = {"call": SOURCE_UNIT_PAYLOAD_DUMP_VELOCITY_ADD_EXPR, "range": velocity_range, "x": range_x, "y": range_y, "unit": unit_id}
		unit_add_called = true
		unit_unloaded_called = true
		event_fire_call = {"call": SOURCE_UNIT_PAYLOAD_DUMP_EVENT_FIRE_EXPR, "event": SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_EXPR, "unit": unit_id}
		notify_unit_spawn_call = {"call": SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_EXPR, "unit": unit_id}
	var deferred_remaining_dump: bool = false
	var state: Dictionary = {
		"source_owner": "port_game.source_unit_payload_dump_spawn_side_effects_state",
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"arc_vec2_source": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_ARC_VEC2_SOURCE,
		"arc_mathf_source": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_ARC_MATHF_SOURCE,
		"world_source": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_WORLD_SOURCE,
		"vars_source": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_VARS_SOURCE,
		"units_source": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_UNITS_SOURCE,
		"event_type_source": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_EVENT_TYPE_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"field_overlay_time_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERLAY_TIME_FIELD_EXPR,
		"field_overlay_region_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERLAY_REGION_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_METHOD,
		"todo_comment_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR,
		"type_null_guard_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_EXPR,
		"can_create_guard_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_CAN_CREATE_GUARD_EXPR,
		"overlay_time_assign_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_TIME_ASSIGN_EXPR,
		"overlay_region_assign_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_REGION_ASSIGN_EXPR,
		"solidity_comment_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLIDITY_COMMENT_EXPR,
		"solid_assign_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLID_ASSIGN_EXPR,
		"solid_guard_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLID_GUARD_EXPR,
		"trns_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_TRNS_EXPR,
		"vec2_trns_amount_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_EXPR,
		"vec2_trns_amount_return_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_RETURN_EXPR,
		"tile_assign_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_TILE_ASSIGN_EXPR,
		"world_to_tile_method": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_METHOD,
		"world_to_tile_return": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_RETURN,
		"vars_tilesize_field": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_VARS_TILESIZE_FIELD,
		"solid_block_comment_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLID_BLOCK_COMMENT_EXPR,
		"solid_solid_guard_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_GUARD_EXPR,
		"overlap_comment_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_COMMENT_EXPR,
		"overlap_guard_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_EXPR,
		"unit_type_flying_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_UNIT_TYPE_FLYING_EXPR,
		"units_count_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_UNITS_COUNT_EXPR,
		"physic_size_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_PHYSIC_SIZE_EXPR,
		"radius_multiplier_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_RADIUS_MULTIPLIER_EXPR,
		"predicate_is_grounded_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_IS_GROUNDED_EXPR,
		"predicate_allow_leg_step_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_ALLOW_LEG_STEP_EXPR,
		"return_false_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_RETURN_FALSE_EXPR,
		"client_dumping_comment_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_CLIENT_DUMPING_COMMENT_EXPR,
		"net_client_guard_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_NET_CLIENT_GUARD_EXPR,
		"vars_net_field": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_VARS_NET_FIELD,
		"return_true_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_RETURN_TRUE_STATEMENT_EXPR,
		"prevents_stacking_comment_expr": source_unit_payload_dump_state.SOURCE_UNIT_PAYLOAD_DUMP_PREVENTS_STACKING_COMMENT_EXPR,
		"unit_type_null": unit_type_null,
		"units_can_create": units_can_create,
		"solid_present": solid_present,
		"unit_rotation": unit_rotation,
		"unit_x": unit_x,
		"unit_y": unit_y,
		"solid_solid": solid_solid,
		"unit_type_flying": unit_type_flying,
		"unit_physic_size": unit_physic_size,
		"units_count": units_count,
		"net_client": net_client,
		"range_x": range_x,
		"range_y": range_y,
		"unit_id": unit_id,
		"can_create_evaluated": can_create_evaluated,
		"can_create_guard": can_create_guard,
		"before_solid_returned": before_solid_returned,
		"solid_evaluated": solid_evaluated,
		"solid_present_guard": solid_present_guard,
		"trns_vec": trns_vec,
		"tx": tx,
		"ty": ty,
		"solid_solid_evaluated": solid_solid_evaluated,
		"solid_call": solid_call,
		"solid_guard": solid_guard,
		"before_overlap_returned": before_overlap_returned,
		"overlap_evaluated": overlap_evaluated,
		"units_count_evaluated": units_count_evaluated,
		"units_count_call": units_count_call,
		"overlap_radius": overlap_radius,
		"overlap_guard": overlap_guard,
		"before_client_returned": before_client_returned,
		"net_client_evaluated": net_client_evaluated,
		"client_guard": client_guard,
		"before_spawn_returned": before_spawn_returned,
		"spawn_evaluated": spawn_evaluated,
		"velocity_add_call": velocity_add_call,
		"unit_add_called": unit_add_called,
		"unit_unloaded_called": unit_unloaded_called,
		"event_fire_call": event_fire_call,
		"notify_unit_spawn_call": notify_unit_spawn_call,
		"returned": returned,
		"dump": dump_result,
		"overlayTime_after": overlayTime_after,
		"overlayRegion_after": overlayRegion_after,
		"deferred_remaining_dump": deferred_remaining_dump
	}
	state["velocity_range"] = velocity_range
	state["velocity_add_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_VELOCITY_ADD_EXPR
	state["mathf_range_float_method"] = SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_METHOD
	state["mathf_range_float_return"] = SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_RETURN
	state["unit_add_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_UNIT_ADD_EXPR
	state["unit_unloaded_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOADED_EXPR
	state["event_fire_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_EVENT_FIRE_EXPR
	state["unit_unload_event_comment"] = SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_COMMENT
	state["unit_unload_event_class"] = SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CLASS
	state["unit_unload_event_constructor"] = SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CONSTRUCTOR
	state["notify_unit_spawn_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_EXPR
	state["notify_unit_spawn_method"] = SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_METHOD
	state["notify_unit_spawn_guard"] = SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_GUARD
	state["final_return_true_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_RETURN_TRUE_STATEMENT_EXPR
	return state

func java_method_drawShadow_14(_args: Array = []) -> Variant:
	var unit_type_null: bool = bool(_args[0] if _args.size() > 0 else false)
	var alpha: float = float(_args[1] if _args.size() > 1 else 0.0)
	var unit_id: Variant = _args[2] if _args.size() > 2 else null
	var returned_early: bool = unit_type_null
	var draw_soft_shadow_called: bool = not returned_early
	var draw_soft_shadow_call: Dictionary = {}
	if draw_soft_shadow_called:
		draw_soft_shadow_call = {"call": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_SOFT_SHADOW_EXPR, "unit": unit_id, "alpha": alpha}
	return {"source_owner": "port_game.source_unit_payload_draw_shadow_type_null_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR, "override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR, "method": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_SHADOW_METHOD, "todo_comment_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR, "type_null_guard_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_TYPE_NULL_GUARD_EXPR, "draw_soft_shadow_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_SOFT_SHADOW_EXPR, "unit_type_null": unit_type_null, "alpha": alpha, "unit_id": unit_id, "returned_early": returned_early, "draw_soft_shadow_called": draw_soft_shadow_called, "draw_soft_shadow_call": draw_soft_shadow_call}

func java_method_draw_15(_args: Array = []) -> Variant:
	var unit_type_null: bool = bool(_args[0] if _args.size() > 0 else false)
	var unit_elevation: float = float(_args[1] if _args.size() > 1 else 0.0)
	var unit_id: Variant = _args[2] if _args.size() > 2 else null
	var overlay_time: float = float(_args[3] if _args.size() > 3 else 0.0)
	var overlay_region: Variant = _args[4] if _args.size() > 4 else null
	var unit_x: float = float(_args[5] if _args.size() > 5 else 0.0)
	var unit_y: float = float(_args[6] if _args.size() > 6 else 0.0)
	var time_delta: float = float(_args[7] if _args.size() > 7 else 0.0)
	var draw_z_before: float = float(_args[8] if _args.size() > 8 else 0.0)
	var interp_exp5_out_overlay_time: float = float(_args[9] if _args.size() > 9 else 0.0)
	var returned_early: bool = unit_type_null
	var elevation_snapshot: float = unit_elevation
	var elevation_after_zero: float = 0.0 if not returned_early else unit_elevation
	var draw_scl_call: Dictionary = {"sx": 1.0, "sy": 1.0}
	var unit_type_draw_call: Dictionary = {"unit": unit_id}
	var draw_scl_called: bool = not returned_early
	var unit_type_draw_called: bool = not returned_early
	if returned_early:
		draw_scl_call = {}
		unit_type_draw_call = {}
	var elevation_after_restore: float = elevation_snapshot if not returned_early else unit_elevation
	var deferred_remaining_draw: bool = not returned_early
	if _args.size() <= 1:
		return {"source_owner": "port_game.source_unit_payload_draw_type_null_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR, "override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR, "method": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_DRAW_METHOD, "todo_comment_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR, "type_null_guard_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_TYPE_NULL_GUARD_EXPR, "next_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_SNAPSHOT_EXPR, "unit_type_null": unit_type_null, "returned_early": returned_early, "deferred_remaining_draw": deferred_remaining_draw}
	if _args.size() <= 3:
		return {"source_owner": "port_game.source_unit_payload_draw_elevation_setup_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR, "override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR, "method": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_DRAW_METHOD, "todo_comment_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR, "type_null_guard_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_TYPE_NULL_GUARD_EXPR, "elevation_snapshot_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_SNAPSHOT_EXPR, "elevation_zero_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_ZERO_EXPR, "draw_scl_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_SCL_EXPR, "unit_type_draw_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_UNIT_TYPE_EXPR, "elevation_restore_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_ELEVATION_RESTORE_EXPR, "next_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_WARNING_COMMENT_EXPR, "unit_type_null": unit_type_null, "unit_elevation": unit_elevation, "unit_id": unit_id, "returned_early": returned_early, "elevation_snapshot": elevation_snapshot, "elevation_after_zero": elevation_after_zero, "draw_scl_called": draw_scl_called, "draw_scl_call": draw_scl_call, "unit_type_draw_called": unit_type_draw_called, "unit_type_draw_call": unit_type_draw_call, "elevation_after_restore": elevation_after_restore, "deferred_remaining_draw": deferred_remaining_draw}
	var overlay_duration: float = SOURCE_UNIT_PAYLOAD_OVERLAY_DURATION
	var overlay_guard: bool = (not returned_early) and overlay_time > 0.0
	var draw_z_snapshot: float = draw_z_before
	var draw_z_warning_call: Dictionary = {"z": "Layer.groundUnit + 1f"} if overlay_guard else {}
	var overlay_region_resolved: Variant = overlay_region if overlay_region != null else "Icon.warning.getRegion()"
	var draw_color_call: Dictionary = {"color": "Color.scarlet"} if overlay_guard else {}
	var draw_alpha_value: float = SOURCE_UNIT_PAYLOAD_OVERLAY_ALPHA * interp_exp5_out_overlay_time if overlay_guard else 0.0
	var draw_alpha_call: Dictionary = {"alpha": draw_alpha_value} if overlay_guard else {}
	var warning_size: float = SOURCE_UNIT_PAYLOAD_WARNING_SIZE
	var draw_rect_call: Dictionary = {"region": overlay_region_resolved, "x": unit_x, "y": unit_y, "width": warning_size, "height": warning_size} if overlay_guard else {}
	var draw_reset_called: bool = overlay_guard
	var overlay_time_after: float = maxf(overlay_time - time_delta / overlay_duration, 0.0) if overlay_guard else overlay_time
	var draw_z_restore_call: Dictionary = {"z": draw_z_snapshot} if overlay_guard else {}
	return {"source_owner": "port_game.source_unit_payload_draw_overlay_warning_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "overlay_duration_field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERLAY_DURATION_FIELD_EXPR, "overlay_time_field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERLAY_TIME_FIELD_EXPR, "overlay_region_field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERLAY_REGION_FIELD_EXPR, "method": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_DRAW_METHOD, "draw_warning_comment_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_WARNING_COMMENT_EXPR, "overlay_guard_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_OVERLAY_GUARD_EXPR, "draw_z_snapshot_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_Z_SNAPSHOT_EXPR, "draw_z_warning_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_Z_WARNING_EXPR, "region_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_REGION_EXPR, "draw_color_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_COLOR_EXPR, "draw_alpha_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_ALPHA_EXPR, "size_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_SIZE_EXPR, "draw_rect_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_RECT_EXPR, "draw_reset_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_RESET_EXPR, "overlay_time_update_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_OVERLAY_TIME_UPDATE_EXPR, "draw_z_restore_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_DRAW_Z_RESTORE_EXPR, "unit_type_null": unit_type_null, "unit_elevation": unit_elevation, "unit_id": unit_id, "overlay_time": overlay_time, "overlay_region": overlay_region, "unit_x": unit_x, "unit_y": unit_y, "time_delta": time_delta, "draw_z_before": draw_z_before, "interp_exp5_out_overlay_time": interp_exp5_out_overlay_time, "returned_early": returned_early, "overlay_duration": overlay_duration, "overlay_guard": overlay_guard, "draw_z_snapshot": draw_z_snapshot, "draw_z_warning_call": draw_z_warning_call, "overlay_region_resolved": overlay_region_resolved, "draw_color_call": draw_color_call, "draw_alpha_value": draw_alpha_value, "draw_alpha_call": draw_alpha_call, "warning_size": warning_size, "draw_rect_call": draw_rect_call, "draw_reset_called": draw_reset_called, "overlay_time_after": overlay_time_after, "draw_z_restore_call": draw_z_restore_call, "deferred_remaining_draw": false}

func java_method_icon_16(_args: Array = []) -> Variant:
	var unit_type_full_icon: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "port_game.source_unit_payload_icon_state", "source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE, "class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR, "field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR, "override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR, "method": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_ICON_METHOD, "return_expr": source_unit_payload_draw_state.SOURCE_UNIT_PAYLOAD_ICON_RETURN_EXPR, "unit_type_full_icon": unit_type_full_icon, "icon": unit_type_full_icon}

func java_constructor_UnitPayload_0(_args: Array = []) -> Variant:
	var unit: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "port_game.source_unit_payload_constructor_state", "source": "core/src/mindustry/world/blocks/payloads/UnitPayload.java", "class_expr": "public class UnitPayload implements Payload{", "field_expr": "public Unit unit;", "constructor": "public UnitPayload(Unit unit){", "unit_assign_expr": "this.unit = unit;", "unit": unit, "unit_after": unit}
