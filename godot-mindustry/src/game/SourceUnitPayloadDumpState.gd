extends RefCounted
class_name SourceUnitPayloadDumpState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const SourceMathState := preload("res://src/game/SourceMathState.gd")
const SourceUnitPayloadBasicState := preload("res://src/game/SourceUnitPayloadBasicState.gd")
const SourceWorldDefaults := preload("res://src/game/SourceWorldDefaults.gd")

const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_LOOKAHEAD := SourceWorldDefaults.UNIT_PAYLOAD_DUMP_SOLID_LOOKAHEAD
const SOURCE_UNIT_PAYLOAD_OVERLAP_RADIUS_MULTIPLIER := SourceWorldDefaults.UNIT_PAYLOAD_OVERLAP_RADIUS_MULTIPLIER
const SOURCE_UNIT_PAYLOAD_DUMP_SPAWN_VELOCITY_RANGE := SourceWorldDefaults.UNIT_PAYLOAD_DUMP_SPAWN_VELOCITY_RANGE
const SOURCE_UNIT_PAYLOAD_DUMP_METHOD := "public boolean dump(){"
const SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_EXPR := "if(unit.type == null) return true;"
const SOURCE_UNIT_PAYLOAD_DUMP_RETURN_TRUE_EXPR := "return true"
const SOURCE_UNIT_PAYLOAD_DUMP_CAN_CREATE_GUARD_EXPR := "if(!Units.canCreate(unit.team, unit.type)){"
const SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_TIME_ASSIGN_EXPR := "overlayTime = 1f;"
const SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_REGION_ASSIGN_EXPR := "overlayRegion = null;"
const SOURCE_UNIT_PAYLOAD_DUMP_RETURN_FALSE_EXPR := "return false;"
const SOURCE_UNIT_PAYLOAD_DUMP_ARC_VEC2_SOURCE := "arc-core/src/arc/math/geom/Vec2.java"
const SOURCE_UNIT_PAYLOAD_DUMP_ARC_MATHF_SOURCE := "arc-core/src/arc/math/Mathf.java"
const SOURCE_UNIT_PAYLOAD_DUMP_WORLD_SOURCE := "core/src/mindustry/core/World.java"
const SOURCE_UNIT_PAYLOAD_DUMP_VARS_SOURCE := "core/src/mindustry/Vars.java"
const SOURCE_UNIT_PAYLOAD_DUMP_UNITS_SOURCE := "core/src/mindustry/entities/Units.java"
const SOURCE_UNIT_PAYLOAD_DUMP_EVENT_TYPE_SOURCE := "core/src/mindustry/game/EventType.java"
const SOURCE_UNIT_PAYLOAD_DUMP_SOLIDITY_COMMENT_EXPR := "//check if unit can be dumped here"
const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_ASSIGN_EXPR := "SolidPred solid = unit.solidity();"
const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_GUARD_EXPR := "if(solid != null){"
const SOURCE_UNIT_PAYLOAD_DUMP_TRNS_EXPR := "Tmp.v1.trns(unit.rotation, 1f);"
const SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_EXPR := "public Vec2 trns(float angle, float amount){"
const SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_RETURN_EXPR := "return set(amount, 0).rotate(angle);"
const SOURCE_UNIT_PAYLOAD_DUMP_VEC2_ROTATE_RAD_EXPR := "float newX = this.x * cos - this.y * sin;\n        float newY = this.x * sin + this.y * cos;"
const SOURCE_UNIT_PAYLOAD_DUMP_TILE_ASSIGN_EXPR := "int tx = World.toTile(unit.x + Tmp.v1.x), ty = World.toTile(unit.y + Tmp.v1.y);"
const SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_METHOD := "public static int toTile(float coord){"
const SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_RETURN := "return Math.round(coord / tilesize);"
const SOURCE_UNIT_PAYLOAD_DUMP_VARS_TILESIZE_FIELD := "public static final int tilesize = 8;"
const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_BLOCK_COMMENT_EXPR := "//cannot dump on solid blocks"
const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_GUARD_EXPR := "if(solid.solid(tx, ty)) return false;"
const SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_CALL_EXPR := "solid.solid(tx, ty)"
const SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_COMMENT_EXPR := "//cannot dump when there's a lot of overlap going on"
const SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_EXPR := "if(!unit.type.flying && Units.count(unit.x, unit.y, unit.physicSize() * 1.05f, o -> o.isGrounded() && (o.type.allowLegStep == unit.type.allowLegStep)) > 0){"
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_TYPE_FLYING_EXPR := "unit.type.flying"
const SOURCE_UNIT_PAYLOAD_DUMP_UNITS_COUNT_EXPR := "Units.count(unit.x, unit.y, unit.physicSize() * 1.05f, o -> o.isGrounded() && (o.type.allowLegStep == unit.type.allowLegStep))"
const SOURCE_UNIT_PAYLOAD_DUMP_PHYSIC_SIZE_EXPR := "unit.physicSize()"
const SOURCE_UNIT_PAYLOAD_DUMP_RADIUS_MULTIPLIER_EXPR := "1.05f"
const SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_IS_GROUNDED_EXPR := "o.isGrounded()"
const SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_ALLOW_LEG_STEP_EXPR := "o.type.allowLegStep == unit.type.allowLegStep"
const SOURCE_UNIT_PAYLOAD_DUMP_CLIENT_DUMPING_COMMENT_EXPR := "//no client dumping"
const SOURCE_UNIT_PAYLOAD_DUMP_NET_CLIENT_GUARD_EXPR := "if(Vars.net.client()) return true;"
const SOURCE_UNIT_PAYLOAD_DUMP_VARS_NET_FIELD := "public static Net net;"
const SOURCE_UNIT_PAYLOAD_DUMP_RETURN_TRUE_STATEMENT_EXPR := "return true;"
const SOURCE_UNIT_PAYLOAD_DUMP_PREVENTS_STACKING_COMMENT_EXPR := "//prevents stacking"
const SOURCE_UNIT_PAYLOAD_DUMP_VELOCITY_ADD_EXPR := "unit.vel.add(Mathf.range(0.5f), Mathf.range(0.5f));"
const SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_METHOD := "public static float range(float range){"
const SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_RETURN := "return random(-range, range);"
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_ADD_EXPR := "unit.add();"
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOADED_EXPR := "unit.unloaded();"
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_EXPR := "new UnitUnloadEvent(unit)"
const SOURCE_UNIT_PAYLOAD_DUMP_EVENT_FIRE_EXPR := "Events.fire(new UnitUnloadEvent(unit));"
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_COMMENT := "/** Called when a unit is dumped from any payload block. */"
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CLASS := "public static class UnitUnloadEvent{"
const SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CONSTRUCTOR := "public UnitUnloadEvent(Unit unit){"
const SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_EXPR := "Units.notifyUnitSpawn(unit);"
const SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_METHOD := "public static void notifyUnitSpawn(Unit unit){"
const SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_GUARD := "if(net.server()){"
const SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_BRIDGE_IGNORED_KEYS := ["guard_expr", "return_expr"]
const SOURCE_UNIT_PAYLOAD_DUMP_SOLIDITY_GUARD_BRIDGE_IGNORED_KEYS := ["source_owner", "returned", "dump", "deferred_remaining_dump", "trns_vec"]
const SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_BRIDGE_IGNORED_KEYS := ["source_owner", "returned", "dump", "deferred_remaining_dump", "trns_vec"]
const SOURCE_UNIT_PAYLOAD_DUMP_NO_CLIENT_GUARD_BRIDGE_IGNORED_KEYS := ["source_owner", "returned", "dump", "deferred_remaining_dump", "trns_vec"]
const SOURCE_UNIT_PAYLOAD_DUMP_SPAWN_SIDE_EFFECTS_BRIDGE_IGNORED_KEYS := ["source_owner", "returned", "dump", "deferred_remaining_dump", "trns_vec"]

static func generated_state_matches_generated_subset(result: Variant, canonical: Dictionary, ignored_keys: Array = []) -> bool:
	if not result is Dictionary:
		return false
	for key in canonical.keys():
		if key == "source_owner" or ignored_keys.has(key):
			continue
		if not result.has(key) or result.get(key) != canonical.get(key):
			return false
	return true

static func type_null_guard_state(unit_type_null: bool) -> Dictionary:
	var returned: bool = unit_type_null
	var dump_result: Variant = null
	if returned:
		dump_result = true
	var deferred_remaining_dump: bool = not returned
	return {
		"source_owner": "PortGame.source_unit_payload_dump_type_null_guard_state",
		"source": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_DUMP_METHOD,
		"todo_comment_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR,
		"guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_EXPR,
		"return_expr": SOURCE_UNIT_PAYLOAD_DUMP_RETURN_TRUE_EXPR,
		"unit_type_null": unit_type_null,
		"returned": returned,
		"dump": dump_result,
		"deferred_remaining_dump": deferred_remaining_dump,
	}

static func can_create_guard_state(unit_type_null: bool, units_can_create: bool) -> Dictionary:
	var can_create_evaluated: bool = not unit_type_null
	var can_create_guard: bool = can_create_evaluated and not units_can_create
	var returned: bool = unit_type_null or can_create_guard
	var dump_result: Variant = null
	if unit_type_null:
		dump_result = true
	elif can_create_guard:
		dump_result = false
	var overlayTime_after: float = 1.0 if can_create_guard else 0.0
	var overlayRegion_after: Variant = null
	var deferred_remaining_dump: bool = not returned
	return {
		"source_owner": "PortGame.source_unit_payload_dump_can_create_guard_state",
		"source": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"field_overlay_time_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERLAY_TIME_FIELD_EXPR,
		"field_overlay_region_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERLAY_REGION_FIELD_EXPR,
		"override_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_DUMP_METHOD,
		"todo_comment_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR,
		"type_null_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_EXPR,
		"can_create_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_CAN_CREATE_GUARD_EXPR,
		"overlay_time_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_TIME_ASSIGN_EXPR,
		"overlay_region_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_REGION_ASSIGN_EXPR,
		"return_false_expr": SOURCE_UNIT_PAYLOAD_DUMP_RETURN_FALSE_EXPR,
		"unit_type_null": unit_type_null,
		"units_can_create": units_can_create,
		"can_create_evaluated": can_create_evaluated,
		"can_create_guard": can_create_guard,
		"returned": returned,
		"dump": dump_result,
		"overlayTime_after": overlayTime_after,
		"overlayRegion_after": overlayRegion_after,
		"deferred_remaining_dump": deferred_remaining_dump,
	}

static func trns_vec_state(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:
	var result := SourceMathState.source_angles_trns_vec(angle_degrees, x_value, y_value)
	result["source"] = SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_RETURN_EXPR
	result["vec2RotateSource"] = SOURCE_UNIT_PAYLOAD_DUMP_VEC2_ROTATE_RAD_EXPR
	return result

static func solidity_guard_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool) -> Dictionary:
	var can_create_evaluated: bool = not unit_type_null
	var can_create_guard: bool = can_create_evaluated and not units_can_create
	var before_solid_returned: bool = unit_type_null or can_create_guard
	var solid_evaluated: bool = not before_solid_returned
	var solid_present_guard: bool = solid_evaluated and solid_present
	var solid_lookahead: float = SOURCE_UNIT_PAYLOAD_DUMP_SOLID_LOOKAHEAD
	var trns_vec: Dictionary = trns_vec_state(unit_rotation, solid_lookahead, 0.0) if solid_present_guard else {"x": 0.0, "y": 0.0}
	var tx: int = int(round((unit_x + float(trns_vec.get("x", 0.0))) / SourceWorldDefaults.TILESIZE)) if solid_present_guard else 0
	var ty: int = int(round((unit_y + float(trns_vec.get("y", 0.0))) / SourceWorldDefaults.TILESIZE)) if solid_present_guard else 0
	var solid_solid_evaluated: bool = solid_present_guard
	var solid_guard: bool = solid_solid_evaluated and solid_solid
	var returned: bool = before_solid_returned or solid_guard
	var dump_result: Variant = null
	if unit_type_null:
		dump_result = true
	elif can_create_guard:
		dump_result = false
	elif solid_guard:
		dump_result = false
	var overlayTime_after: float = 1.0 if can_create_guard else 0.0
	var overlayRegion_after: Variant = null
	var solid_call: Dictionary = {}
	if solid_solid_evaluated:
		solid_call = {"call": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_CALL_EXPR, "tx": tx, "ty": ty, "result": solid_solid}
	var deferred_remaining_dump: bool = not returned
	return {
		"source_owner": "PortGame.source_unit_payload_dump_solidity_guard_state",
		"source": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_SOURCE,
		"arc_vec2_source": SOURCE_UNIT_PAYLOAD_DUMP_ARC_VEC2_SOURCE,
		"world_source": SOURCE_UNIT_PAYLOAD_DUMP_WORLD_SOURCE,
		"vars_source": SOURCE_UNIT_PAYLOAD_DUMP_VARS_SOURCE,
		"class_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"field_overlay_time_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERLAY_TIME_FIELD_EXPR,
		"field_overlay_region_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERLAY_REGION_FIELD_EXPR,
		"override_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_DUMP_METHOD,
		"todo_comment_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR,
		"type_null_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_EXPR,
		"can_create_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_CAN_CREATE_GUARD_EXPR,
		"overlay_time_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_TIME_ASSIGN_EXPR,
		"overlay_region_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_REGION_ASSIGN_EXPR,
		"solidity_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLIDITY_COMMENT_EXPR,
		"solid_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_ASSIGN_EXPR,
		"solid_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_GUARD_EXPR,
		"trns_expr": SOURCE_UNIT_PAYLOAD_DUMP_TRNS_EXPR,
		"vec2_trns_amount_expr": SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_EXPR,
		"vec2_trns_amount_return_expr": SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_RETURN_EXPR,
		"tile_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_TILE_ASSIGN_EXPR,
		"world_to_tile_method": SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_METHOD,
		"world_to_tile_return": SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_RETURN,
		"vars_tilesize_field": SOURCE_UNIT_PAYLOAD_DUMP_VARS_TILESIZE_FIELD,
		"solid_block_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_BLOCK_COMMENT_EXPR,
		"solid_solid_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_GUARD_EXPR,
		"return_false_expr": SOURCE_UNIT_PAYLOAD_DUMP_RETURN_FALSE_EXPR,
		"unit_type_null": unit_type_null,
		"units_can_create": units_can_create,
		"solid_present": solid_present,
		"unit_rotation": unit_rotation,
		"unit_x": unit_x,
		"unit_y": unit_y,
		"solid_solid": solid_solid,
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
		"returned": returned,
		"dump": dump_result,
		"overlayTime_after": overlayTime_after,
		"overlayRegion_after": overlayRegion_after,
		"deferred_remaining_dump": deferred_remaining_dump,
	}

static func overlap_guard_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int) -> Dictionary:
	var result := solidity_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)
	var canonical_overlap_fields := {
		"source_owner": "PortGame.source_unit_payload_dump_overlap_guard_state",
		"source": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_SOURCE,
		"arc_vec2_source": SOURCE_UNIT_PAYLOAD_DUMP_ARC_VEC2_SOURCE,
		"world_source": SOURCE_UNIT_PAYLOAD_DUMP_WORLD_SOURCE,
		"vars_source": SOURCE_UNIT_PAYLOAD_DUMP_VARS_SOURCE,
		"class_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"field_overlay_time_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERLAY_TIME_FIELD_EXPR,
		"field_overlay_region_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERLAY_REGION_FIELD_EXPR,
		"override_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_DUMP_METHOD,
		"todo_comment_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR,
		"type_null_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_EXPR,
		"can_create_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_CAN_CREATE_GUARD_EXPR,
		"overlay_time_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_TIME_ASSIGN_EXPR,
		"overlay_region_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_REGION_ASSIGN_EXPR,
		"solidity_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLIDITY_COMMENT_EXPR,
		"solid_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_ASSIGN_EXPR,
		"solid_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_GUARD_EXPR,
		"trns_expr": SOURCE_UNIT_PAYLOAD_DUMP_TRNS_EXPR,
		"vec2_trns_amount_expr": SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_EXPR,
		"vec2_trns_amount_return_expr": SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_RETURN_EXPR,
		"tile_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_TILE_ASSIGN_EXPR,
		"world_to_tile_method": SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_METHOD,
		"world_to_tile_return": SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_RETURN,
		"vars_tilesize_field": SOURCE_UNIT_PAYLOAD_DUMP_VARS_TILESIZE_FIELD,
		"solid_block_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_BLOCK_COMMENT_EXPR,
		"solid_solid_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_GUARD_EXPR,
		"overlap_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_COMMENT_EXPR,
		"overlap_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_EXPR,
		"unit_type_flying_expr": SOURCE_UNIT_PAYLOAD_DUMP_UNIT_TYPE_FLYING_EXPR,
		"units_count_expr": SOURCE_UNIT_PAYLOAD_DUMP_UNITS_COUNT_EXPR,
		"physic_size_expr": SOURCE_UNIT_PAYLOAD_DUMP_PHYSIC_SIZE_EXPR,
		"radius_multiplier_expr": SOURCE_UNIT_PAYLOAD_DUMP_RADIUS_MULTIPLIER_EXPR,
		"predicate_is_grounded_expr": SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_IS_GROUNDED_EXPR,
		"predicate_allow_leg_step_expr": SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_ALLOW_LEG_STEP_EXPR,
		"return_false_expr": SOURCE_UNIT_PAYLOAD_DUMP_RETURN_FALSE_EXPR,
		"client_dumping_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_CLIENT_DUMPING_COMMENT_EXPR
	}
	var before_solid_returned: bool = bool(result.get("before_solid_returned", false))
	var solid_guard: bool = bool(result.get("solid_guard", false))
	var before_overlap_returned: bool = before_solid_returned or solid_guard
	var overlap_evaluated: bool = not before_overlap_returned
	var units_count_evaluated: bool = overlap_evaluated and not unit_type_flying
	var overlap_radius: float = unit_physic_size * SOURCE_UNIT_PAYLOAD_OVERLAP_RADIUS_MULTIPLIER if units_count_evaluated else 0.0
	var overlap_guard: bool = units_count_evaluated and units_count > 0
	var dump_result: Variant = result.get("dump", null)
	if overlap_guard:
		dump_result = false
	var units_count_call: Dictionary = {}
	if units_count_evaluated:
		units_count_call = {"call": SOURCE_UNIT_PAYLOAD_DUMP_UNITS_COUNT_EXPR, "x": unit_x, "y": unit_y, "radius": overlap_radius, "result": units_count}
	var returned: bool = before_overlap_returned or overlap_guard
	var deferred_remaining_dump: bool = not returned
	var overlap_runtime_fields := {
		"unit_type_flying": unit_type_flying,
		"unit_physic_size": unit_physic_size,
		"units_count": units_count,
		"before_overlap_returned": before_overlap_returned,
		"overlap_evaluated": overlap_evaluated,
		"units_count_evaluated": units_count_evaluated,
		"units_count_call": units_count_call,
		"overlap_radius": overlap_radius,
		"overlap_guard": overlap_guard,
		"returned": returned,
		"dump": dump_result,
		"deferred_remaining_dump": deferred_remaining_dump,
	}
	for key in canonical_overlap_fields.keys():
		result[key] = canonical_overlap_fields[key]
	for key in overlap_runtime_fields.keys():
		result[key] = overlap_runtime_fields[key]
	return result

static func no_client_guard_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool) -> Dictionary:
	var result := overlap_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)
	var canonical_no_client_fields := {
		"source_owner": "PortGame.source_unit_payload_dump_no_client_guard_state",
		"source": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_SOURCE,
		"arc_vec2_source": SOURCE_UNIT_PAYLOAD_DUMP_ARC_VEC2_SOURCE,
		"world_source": SOURCE_UNIT_PAYLOAD_DUMP_WORLD_SOURCE,
		"vars_source": SOURCE_UNIT_PAYLOAD_DUMP_VARS_SOURCE,
		"class_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"field_overlay_time_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERLAY_TIME_FIELD_EXPR,
		"field_overlay_region_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERLAY_REGION_FIELD_EXPR,
		"override_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_DUMP_METHOD,
		"todo_comment_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_TODO_COMMENT_EXPR,
		"type_null_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_EXPR,
		"can_create_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_CAN_CREATE_GUARD_EXPR,
		"overlay_time_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_TIME_ASSIGN_EXPR,
		"overlay_region_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAY_REGION_ASSIGN_EXPR,
		"solidity_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLIDITY_COMMENT_EXPR,
		"solid_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_ASSIGN_EXPR,
		"solid_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_GUARD_EXPR,
		"trns_expr": SOURCE_UNIT_PAYLOAD_DUMP_TRNS_EXPR,
		"vec2_trns_amount_expr": SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_EXPR,
		"vec2_trns_amount_return_expr": SOURCE_UNIT_PAYLOAD_DUMP_VEC2_TRNS_AMOUNT_RETURN_EXPR,
		"tile_assign_expr": SOURCE_UNIT_PAYLOAD_DUMP_TILE_ASSIGN_EXPR,
		"world_to_tile_method": SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_METHOD,
		"world_to_tile_return": SOURCE_UNIT_PAYLOAD_DUMP_WORLD_TO_TILE_RETURN,
		"vars_tilesize_field": SOURCE_UNIT_PAYLOAD_DUMP_VARS_TILESIZE_FIELD,
		"solid_block_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_BLOCK_COMMENT_EXPR,
		"solid_solid_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_SOLID_SOLID_GUARD_EXPR,
		"overlap_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_COMMENT_EXPR,
		"overlap_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_EXPR,
		"unit_type_flying_expr": SOURCE_UNIT_PAYLOAD_DUMP_UNIT_TYPE_FLYING_EXPR,
		"units_count_expr": SOURCE_UNIT_PAYLOAD_DUMP_UNITS_COUNT_EXPR,
		"physic_size_expr": SOURCE_UNIT_PAYLOAD_DUMP_PHYSIC_SIZE_EXPR,
		"radius_multiplier_expr": SOURCE_UNIT_PAYLOAD_DUMP_RADIUS_MULTIPLIER_EXPR,
		"predicate_is_grounded_expr": SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_IS_GROUNDED_EXPR,
		"predicate_allow_leg_step_expr": SOURCE_UNIT_PAYLOAD_DUMP_PREDICATE_ALLOW_LEG_STEP_EXPR,
		"return_false_expr": SOURCE_UNIT_PAYLOAD_DUMP_RETURN_FALSE_EXPR,
		"client_dumping_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_CLIENT_DUMPING_COMMENT_EXPR,
		"net_client_guard_expr": SOURCE_UNIT_PAYLOAD_DUMP_NET_CLIENT_GUARD_EXPR,
		"vars_net_field": SOURCE_UNIT_PAYLOAD_DUMP_VARS_NET_FIELD,
		"return_true_expr": SOURCE_UNIT_PAYLOAD_DUMP_RETURN_TRUE_STATEMENT_EXPR,
		"prevents_stacking_comment_expr": SOURCE_UNIT_PAYLOAD_DUMP_PREVENTS_STACKING_COMMENT_EXPR
	}
	var before_overlap_returned: bool = bool(result.get("before_overlap_returned", false))
	var overlap_guard: bool = bool(result.get("overlap_guard", false))
	var before_client_returned: bool = before_overlap_returned or overlap_guard
	var net_client_evaluated: bool = not before_client_returned
	var client_guard: bool = net_client_evaluated and net_client
	var dump_result: Variant = result.get("dump", null)
	if false:
		pass
	elif client_guard:
		dump_result = true
	var returned: bool = before_client_returned or client_guard
	var deferred_remaining_dump: bool = not returned
	var client_runtime_fields := {
		"net_client": net_client,
		"before_client_returned": before_client_returned,
		"net_client_evaluated": net_client_evaluated,
		"client_guard": client_guard,
		"returned": returned,
		"dump": dump_result,
		"deferred_remaining_dump": deferred_remaining_dump,
	}
	for key in canonical_no_client_fields.keys():
		result[key] = canonical_no_client_fields[key]
	for key in client_runtime_fields.keys():
		result[key] = client_runtime_fields[key]
	return result

static func spawn_side_effects_state(state: Dictionary, range_x: float, range_y: float, unit_id: Variant) -> Dictionary:
	var result := state.duplicate(true)
	result["source_owner"] = "PortGame.source_unit_payload_dump_spawn_side_effects_state"
	result["arc_mathf_source"] = SOURCE_UNIT_PAYLOAD_DUMP_ARC_MATHF_SOURCE
	result["units_source"] = SOURCE_UNIT_PAYLOAD_DUMP_UNITS_SOURCE
	result["event_type_source"] = SOURCE_UNIT_PAYLOAD_DUMP_EVENT_TYPE_SOURCE
	result["prevents_stacking_comment_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_PREVENTS_STACKING_COMMENT_EXPR
	var before_spawn_returned: bool = bool(result.get("before_client_returned", false)) or bool(result.get("client_guard", false))
	var spawn_evaluated: bool = not before_spawn_returned
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
	result["velocity_add_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_VELOCITY_ADD_EXPR
	result["mathf_range_float_method"] = SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_METHOD
	result["mathf_range_float_return"] = SOURCE_UNIT_PAYLOAD_DUMP_MATHF_RANGE_FLOAT_RETURN
	result["unit_add_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_UNIT_ADD_EXPR
	result["unit_unloaded_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOADED_EXPR
	result["event_fire_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_EVENT_FIRE_EXPR
	result["unit_unload_event_comment"] = SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_COMMENT
	result["unit_unload_event_class"] = SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CLASS
	result["unit_unload_event_constructor"] = SOURCE_UNIT_PAYLOAD_DUMP_UNIT_UNLOAD_EVENT_CONSTRUCTOR
	result["notify_unit_spawn_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_EXPR
	result["notify_unit_spawn_method"] = SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_METHOD
	result["notify_unit_spawn_guard"] = SOURCE_UNIT_PAYLOAD_DUMP_NOTIFY_UNIT_SPAWN_GUARD
	result["final_return_true_expr"] = SOURCE_UNIT_PAYLOAD_DUMP_RETURN_TRUE_STATEMENT_EXPR
	result["before_spawn_returned"] = before_spawn_returned
	result["spawn_evaluated"] = spawn_evaluated
	result["velocity_add_call"] = velocity_add_call
	result["unit_add_called"] = unit_add_called
	result["unit_unloaded_called"] = unit_unloaded_called
	result["event_fire_call"] = event_fire_call
	result["notify_unit_spawn_call"] = notify_unit_spawn_call
	result["deferred_remaining_dump"] = false
	return result

static func generated_type_null_guard_bridge_state(unit_type_null: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_dump_13", [unit_type_null], null)
	var canonical = type_null_guard_state(unit_type_null)
	var matches: bool = generated_state_matches_generated_subset(result, canonical, SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_BRIDGE_IGNORED_KEYS)
	return {
		"source_owner": "PortGame.source_unit_payload_dump_type_null_guard_state",
		"generated_owner": "UnitPayload.java_method_dump_13",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_can_create_guard_bridge_state(unit_type_null: bool, units_can_create: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_dump_13", [unit_type_null, units_can_create], null)
	var canonical = can_create_guard_state(unit_type_null, units_can_create)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_dump_can_create_guard_state",
		"generated_owner": "UnitPayload.java_method_dump_13",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_solidity_guard_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_dump_13", [unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid], null)
	var canonical = solidity_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)
	var matches: bool = generated_state_matches_generated_subset(result, canonical, SOURCE_UNIT_PAYLOAD_DUMP_SOLIDITY_GUARD_BRIDGE_IGNORED_KEYS)
	return {
		"source_owner": "PortGame.source_unit_payload_dump_solidity_guard_state",
		"generated_owner": "UnitPayload.java_method_dump_13",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_overlap_guard_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_dump_13", [unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count], null)
	var canonical = overlap_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)
	var matches: bool = generated_state_matches_generated_subset(result, canonical, SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_BRIDGE_IGNORED_KEYS)
	return {
		"source_owner": "PortGame.source_unit_payload_dump_overlap_guard_state",
		"generated_owner": "UnitPayload.java_method_dump_13",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_no_client_guard_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_dump_13", [unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client], null)
	var canonical = no_client_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)
	var matches: bool = generated_state_matches_generated_subset(result, canonical, SOURCE_UNIT_PAYLOAD_DUMP_NO_CLIENT_GUARD_BRIDGE_IGNORED_KEYS)
	return {
		"source_owner": "PortGame.source_unit_payload_dump_no_client_guard_state",
		"generated_owner": "UnitPayload.java_method_dump_13",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_spawn_side_effects_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool, range_x: float, range_y: float, unit_id: Variant) -> Dictionary:
	var state := no_client_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_dump_13", [unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client, range_x, range_y, unit_id], null)
	var canonical = spawn_side_effects_state(state, range_x, range_y, unit_id)
	var matches: bool = generated_state_matches_generated_subset(result, canonical, SOURCE_UNIT_PAYLOAD_DUMP_SPAWN_SIDE_EFFECTS_BRIDGE_IGNORED_KEYS)
	return {
		"source_owner": "PortGame.source_unit_payload_dump_spawn_side_effects_state",
		"generated_owner": "UnitPayload.java_method_dump_13",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
