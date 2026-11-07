# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/UnitComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "UnitComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Healthc", "Physicsc", "Hitboxc", "Statusc", "Teamc", "Itemsc", "Rotc", "Unitc", "Weaponsc", "Drawc", "Syncc", "Shieldc", "Displayable", "Ranged", "Minerc", "Builderc", "Senseable", "Settable"]
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "tmp1", "type": "Vec2"}, {"modifiers": ["final", "private", "static"], "name": "tmp2", "type": "Vec2"}, {"modifiers": ["final", "static"], "name": "warpDst", "type": "float"}, {"modifiers": [], "name": "dead", "type": "boolean"}, {"modifiers": [], "name": "disarmed", "type": "boolean"}, {"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "rotation", "type": "float"}, {"modifiers": [], "name": "maxHealth", "type": "float"}, {"modifiers": [], "name": "drag", "type": "float"}, {"modifiers": [], "name": "armor", "type": "float"}, {"modifiers": [], "name": "hitSize", "type": "float"}, {"modifiers": [], "name": "health", "type": "float"}, {"modifiers": [], "name": "shield", "type": "float"}, {"modifiers": [], "name": "dragMultiplier", "type": "float"}, {"modifiers": [], "name": "armorOverride", "type": "float"}, {"modifiers": [], "name": "speedMultiplier", "type": "float"}, {"modifiers": [], "name": "team", "type": "Team"}, {"modifiers": [], "name": "id", "type": "int"}, {"modifiers": [], "name": "mineTile", "type": "Tile"}, {"modifiers": [], "name": "vel", "type": "Vec2"}, {"modifiers": [], "name": "mounts", "type": "WeaponMount"}, {"modifiers": [], "name": "stack", "type": "ItemStack"}, {"modifiers": ["private"], "name": "controller", "type": "UnitController"}, {"modifiers": [], "name": "abilities", "type": "Ability"}, {"modifiers": [], "name": "type", "type": "UnitType"}, {"modifiers": [], "name": "spawnedByCore", "type": "boolean"}, {"modifiers": [], "name": "flag", "type": "double"}, {"modifiers": ["transient"], "name": "trail", "type": "Trail"}, {"modifiers": ["transient"], "name": "dockedType", "type": "UnitType"}, {"modifiers": ["transient"], "name": "lastCommanded", "type": "String"}, {"modifiers": ["transient"], "name": "shadowAlpha", "type": "float"}, {"modifiers": ["transient"], "name": "healTime", "type": "float"}, {"modifiers": ["transient"], "name": "lastFogPos", "type": "int"}, {"modifiers": ["transient"], "name": "hasTarget", "type": "boolean"}, {"modifiers": ["private", "transient"], "name": "resupplyTime", "type": "float"}, {"modifiers": ["private", "transient"], "name": "wasPlayer", "type": "boolean"}, {"modifiers": ["private", "transient"], "name": "wasHealed", "type": "boolean"}, {"modifiers": [], "name": "elevation", "type": "float"}, {"modifiers": ["private", "transient"], "name": "wasFlying", "type": "boolean"}, {"modifiers": ["transient"], "name": "drownTime", "type": "float"}, {"modifiers": ["transient"], "name": "splashTimer", "type": "float"}, {"modifiers": ["transient"], "name": "lastDrownFloor", "type": "Floor"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "checkTarget", "parameters": [{"name": "targetAir", "type": "boolean", "varargs": false}, {"name": "targetGround", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isGrounded", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isFlying", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canDrown", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "drownFloor", "parameters": [], "return_type": "Floor"}, {"modifiers": ["public"], "name": "wobble", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "moveAt", "parameters": [{"name": "vector", "type": "Vec2", "varargs": false}, {"name": "acceleration", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "floorSpeedMultiplier", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "unloaded", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateBoosting", "parameters": [{"name": "boost", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateBoosting", "parameters": [{"name": "boost", "type": "boolean", "varargs": false}, {"name": "event", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "movePref", "parameters": [{"name": "movement", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "moveAt", "parameters": [{"name": "vector", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "approach", "parameters": [{"name": "vector", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "rotateMove", "parameters": [{"name": "vec", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "aimLook", "parameters": [{"name": "pos", "type": "Position", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "aimLook", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isPathImpassable", "parameters": [{"name": "tileX", "type": "int", "varargs": false}, {"name": "tileY", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "physicSize", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "canLand", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "inRange", "parameters": [{"name": "other", "type": "Position", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "hasWeapons", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "speed", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "prefRotation", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "ammof", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "displayable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isSyncHidden", "parameters": [{"name": "player", "type": "Player", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "handleSyncHidden", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "inFogTo", "parameters": [{"name": "viewer", "type": "Team", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "range", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "clipSize", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "sense", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "double"}, {"modifiers": ["public"], "name": "senseObject", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public"], "name": "sense", "parameters": [{"name": "content", "type": "Content", "varargs": false}], "return_type": "double"}, {"modifiers": ["public"], "name": "setProp", "parameters": [{"name": "prop", "type": "LAccess", "varargs": false}, {"name": "value", "type": "double", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setProp", "parameters": [{"name": "prop", "type": "LAccess", "varargs": false}, {"name": "value", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setProp", "parameters": [{"name": "content", "type": "UnlockableContent", "varargs": false}, {"name": "value", "type": "double", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "canShoot", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isEnemy", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "collides", "parameters": [{"name": "other", "type": "Hitboxc", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "collision", "parameters": [{"name": "other", "type": "Hitboxc", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "itemCapacity", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "bounds", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "controller", "parameters": [{"name": "next", "type": "UnitController", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "controller", "parameters": [], "return_type": "UnitController"}, {"modifiers": ["public"], "name": "resetController", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "set", "parameters": [{"name": "def", "type": "UnitType", "varargs": false}, {"name": "controller", "type": "UnitController", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "collisionLayer", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "lookAt", "parameters": [{"name": "angle", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "lookAt", "parameters": [{"name": "pos", "type": "Position", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "lookAt", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isAI", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "allowCommand", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isCommandable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canTarget", "parameters": [{"name": "other", "type": "Teamc", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "command", "parameters": [], "return_type": "CommandAI"}, {"modifiers": ["public"], "name": "isMissile", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "count", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "cap", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "setType", "parameters": [{"name": "type", "type": "UnitType", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "playerControllable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "targetable", "parameters": [{"name": "targeter", "type": "Team", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "killable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "hittable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "afterSync", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterRead", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterReadAll", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "landed", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "heal", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateDrowning", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "shouldUpdateController", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "icon", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "destroy", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getControllerName", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isPlayer", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getPlayer", "parameters": [], "return_type": "Player"}, {"modifiers": ["public"], "name": "killed", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "kill", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []
const source_unit_update_state := preload("res://src/game/SourceUnitUpdateState.gd")
const source_unit_metadata_state := preload("res://src/game/SourceUnitMetadataState.gd")
const source_unit_destroy_state := preload("res://src/game/SourceUnitDestroyState.gd")
const source_unit_destroy_source_text_state := preload("res://src/game/SourceUnitDestroySourceTextState.gd")
const source_unit_update_source_text_state := preload("res://src/game/SourceUnitUpdateSourceTextState.gd")
const source_unit_sensor_source_text_state := preload("res://src/game/SourceUnitSensorSourceTextState.gd")
const source_unit_set_prop_source_text_state := preload("res://src/game/SourceUnitSetPropSourceTextState.gd")
const source_unit_combat_metadata_source_text_state := preload("res://src/game/SourceUnitCombatMetadataSourceTextState.gd")
const source_unit_controller_source_text_state := preload("res://src/game/SourceUnitControllerSourceTextState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const SOURCE_TILESIZE := source_world_defaults.TILESIZE

func java_method_checkTarget_0(_args: Array = []) -> Variant:
	var elevation_value := float(_args[0] if _args.size() > 0 else 0.0)
	var target_air := bool(_args[1] if _args.size() > 1 else false)
	var target_ground := bool(_args[2] if _args.size() > 2 else false)
	var result := source_unit_update_state.check_target_state(elevation_value, target_air, target_ground)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_CHECK_TARGET_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_CHECK_TARGET_GENERATED_METHOD
	return result

func java_method_isGrounded_1(_args: Array = []) -> Variant:
	var elevation_value := float(_args[0] if _args.size() > 0 else 0.0)
	var grounded := source_unit_update_state.is_grounded(elevation_value)
	return {"source_owner": source_unit_update_source_text_state.SOURCE_UNIT_IS_GROUNDED_GENERATED_OWNER, "generated_method": source_unit_update_source_text_state.SOURCE_UNIT_IS_GROUNDED_GENERATED_METHOD, "grounded": grounded}

func java_method_isFlying_2(_args: Array = []) -> Variant:
	var elevation_value := float(_args[0] if _args.size() > 0 else 0.0)
	var flying := source_unit_update_state.is_flying(elevation_value)
	return {"source_owner": source_unit_update_source_text_state.SOURCE_UNIT_IS_FLYING_GENERATED_OWNER, "generated_method": source_unit_update_source_text_state.SOURCE_UNIT_IS_FLYING_GENERATED_METHOD, "flying": flying}

func java_method_canDrown_3(_args: Array = []) -> Variant:
	var elevation_value := float(_args[0] if _args.size() > 0 else 0.0)
	var type_can_drown := bool(_args[1] if _args.size() > 1 else false)
	var result := source_unit_update_state.can_drown_state(elevation_value, type_can_drown)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_CAN_DROWN_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_CAN_DROWN_GENERATED_METHOD
	return result

func java_method_drownFloor_4(_args: Array = []) -> Variant:
	var floor_on_value: Variant = _args[0] if _args.size() > 0 else null
	var floor_value: Variant = source_unit_update_state.drown_floor_state(floor_on_value)
	return {"source_owner": source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_GENERATED_OWNER, "generated_method": source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_GENERATED_METHOD, "floor": floor_value}

func java_method_wobble_5(_args: Array = []) -> Variant:
	var current_x := float(_args[0] if _args.size() > 0 else 0.0)
	var current_y := float(_args[1] if _args.size() > 1 else 0.0)
	var source_time := float(_args[2] if _args.size() > 2 else 0.0)
	var source_delta := float(_args[3] if _args.size() > 3 else 0.0)
	var elevation_value := float(_args[4] if _args.size() > 4 else 0.0)
	var unit_id := int(_args[5] if _args.size() > 5 else 0)
	var game: Object = _args[6] if _args.size() > 6 else null
	var result := source_unit_update_state.game_wobble_state(game, current_x, current_y, source_time, source_delta, elevation_value, unit_id)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_WOBBLE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_WOBBLE_GENERATED_METHOD
	return result

func java_method_moveAt_6(_args: Array = []) -> Variant:
	var vel_x := float(_args[0] if _args.size() > 0 else 0.0)
	var vel_y := float(_args[1] if _args.size() > 1 else 0.0)
	var vector_x := float(_args[2] if _args.size() > 2 else 0.0)
	var vector_y := float(_args[3] if _args.size() > 3 else 0.0)
	var acceleration := float(_args[4] if _args.size() > 4 else 0.0)
	var source_delta := float(_args[5] if _args.size() > 5 else 0.0)
	var game: Object = _args[6] if _args.size() > 6 else self
	var result := source_unit_update_state.game_move_at_state(game, vel_x, vel_y, vector_x, vector_y, acceleration, source_delta)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_GENERATED_METHOD
	return result

func java_method_floorSpeedMultiplier_7(_args: Array = []) -> Variant:
	var elevation_value := float(_args[0] if _args.size() > 0 else 0.0)
	var type_hovering := bool(_args[1] if _args.size() > 1 else false)
	var floor_on_speed_multiplier := float(_args[2] if _args.size() > 2 else 1.0)
	var type_floor_multiplier := float(_args[3] if _args.size() > 3 else 1.0)
	var speed_multiplier_value := float(_args[4] if _args.size() > 4 else 1.0)
	var result := source_unit_update_state.floor_speed_multiplier_state(elevation_value, type_hovering, floor_on_speed_multiplier, type_floor_multiplier, speed_multiplier_value)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_GENERATED_METHOD
	return result

func java_method_unloaded_8(_args: Array = []) -> Variant:
	var unit_state: Variant = _args[0] if _args.size() > 0 else null
	var result: Variant = source_unit_update_state.unloaded_state(unit_state)
	return {"source_owner": source_unit_update_source_text_state.SOURCE_UNIT_UNLOADED_GENERATED_OWNER, "generated_method": source_unit_update_source_text_state.SOURCE_UNIT_UNLOADED_GENERATED_METHOD, "result": result}

func java_method_updateBoosting_9(_args: Array = []) -> Variant:
	var boost := bool(_args[0] if _args.size() > 0 else false)
	var result := source_unit_update_state.boosting_default_event_state(boost)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_DEFAULT_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_DEFAULT_GENERATED_METHOD
	return result

func java_method_updateBoosting_10(_args: Array = []) -> Variant:
	var boost := bool(_args[0] if _args.size() > 0 else false)
	var event := bool(_args[1] if _args.size() > 1 else false)
	var type_can_boost := bool(_args[2] if _args.size() > 2 else false)
	var dead_state := bool(_args[3] if _args.size() > 3 else false)
	var elevation_value := float(_args[4] if _args.size() > 4 else 0.0)
	var on_solid_result := bool(_args[5] if _args.size() > 5 else false)
	var can_land_result := bool(_args[6] if _args.size() > 6 else false)
	var type_rise_speed := float(_args[7] if _args.size() > 7 else 0.0)
	var type_descent_speed := float(_args[8] if _args.size() > 8 else 0.0)
	var source_delta := float(_args[9] if _args.size() > 9 else 0.0)
	var guard_result := source_unit_update_state.boosting_guard_state(type_can_boost, dead_state, elevation_value)
	if bool(guard_result.get("returned", false)):
		guard_result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_GENERATED_OWNER
		guard_result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_GENERATED_METHOD
		return guard_result
	var should_result := source_unit_update_state.boosting_should_boost_state(boost, on_solid_result, elevation_value, can_land_result)
	var elevation_result := source_unit_update_state.boosting_elevation_state(elevation_value, type_can_boost, bool(should_result.get("should_boost", false)), type_rise_speed, type_descent_speed, source_delta)
	var event_result := source_unit_update_state.boosting_event_state(event)
	guard_result.merge(should_result)
	guard_result.merge(elevation_result)
	guard_result.merge(event_result)
	guard_result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_GENERATED_OWNER
	guard_result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_GENERATED_METHOD
	return guard_result

func java_method_movePref_11(_args: Array = []) -> Variant:
	var type_omni_movement := bool(_args[0] if _args.size() > 0 else false)
	var movement_x := float(_args[1] if _args.size() > 1 else 0.0)
	var movement_y := float(_args[2] if _args.size() > 2 else 0.0)
	var result := source_unit_update_state.move_pref_state(type_omni_movement, movement_x, movement_y)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_MOVE_PREF_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_MOVE_PREF_GENERATED_METHOD
	return result

func java_method_moveAt_12(_args: Array = []) -> Variant:
	var vector_x := float(_args[0] if _args.size() > 0 else 0.0)
	var vector_y := float(_args[1] if _args.size() > 1 else 0.0)
	var type_accel := float(_args[2] if _args.size() > 2 else 0.0)
	var result := source_unit_update_state.move_at_default_accel_state(vector_x, vector_y, type_accel)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_GENERATED_METHOD
	return result

func java_method_approach_13(_args: Array = []) -> Variant:
	var vel_x := float(_args[0] if _args.size() > 0 else 0.0)
	var vel_y := float(_args[1] if _args.size() > 1 else 0.0)
	var vector_x := float(_args[2] if _args.size() > 2 else 0.0)
	var vector_y := float(_args[3] if _args.size() > 3 else 0.0)
	var type_accel := float(_args[4] if _args.size() > 4 else 0.0)
	var speed_value := float(_args[5] if _args.size() > 5 else 0.0)
	var source_delta := float(_args[6] if _args.size() > 6 else 0.0)
	var result := source_unit_update_state.approach_state(vel_x, vel_y, vector_x, vector_y, type_accel, speed_value, source_delta)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_GENERATED_METHOD
	return result

func java_method_rotateMove_14(_args: Array = []) -> Variant:
	var current_rotation := float(_args[0] if _args.size() > 0 else 0.0)
	var vec_x := float(_args[1] if _args.size() > 1 else 0.0)
	var vec_y := float(_args[2] if _args.size() > 2 else 0.0)
	var type_rotate_speed := float(_args[3] if _args.size() > 3 else 0.0)
	var speed_multiplier_value := float(_args[4] if _args.size() > 4 else 1.0)
	var source_delta := float(_args[5] if _args.size() > 5 else 0.0)
	var game: Object = _args[6] if _args.size() > 6 else self
	var result := source_unit_update_state.rotate_move_motion_state(current_rotation, vec_x, vec_y)
	var rotation_result := source_unit_update_state.game_rotate_move_rotation_state(game, current_rotation, vec_x, vec_y, type_rotate_speed, speed_multiplier_value, source_delta)
	result.merge(rotation_result)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_GENERATED_METHOD
	return result

func java_method_aimLook_15(_args: Array = []) -> Variant:
	var pos_x := float(_args[0] if _args.size() > 0 else 0.0)
	var pos_y := float(_args[1] if _args.size() > 1 else 0.0)
	var result := source_unit_update_state.aim_look_position_state(pos_x, pos_y)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_POSITION_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_POSITION_GENERATED_METHOD
	return result

func java_method_aimLook_16(_args: Array = []) -> Variant:
	var target_x := float(_args[0] if _args.size() > 0 else 0.0)
	var target_y := float(_args[1] if _args.size() > 1 else 0.0)
	var result := source_unit_update_state.aim_look_xy_state(target_x, target_y)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_XY_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_XY_GENERATED_METHOD
	return result

func java_method_isPathImpassable_17(_args: Array = []) -> Variant:
	var type_flying := bool(_args[0] if _args.size() > 0 else false)
	var tile_x := int(_args[1] if _args.size() > 1 else 0)
	var tile_y := int(_args[2] if _args.size() > 2 else 0)
	var tile_in_bounds := bool(_args[3] if _args.size() > 3 else false)
	var path_cost := int(_args[4] if _args.size() > 4 else 0)
	var result := source_unit_update_state.is_path_impassable_state(type_flying, tile_x, tile_y, tile_in_bounds, path_cost)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_IS_PATH_IMPASSABLE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_IS_PATH_IMPASSABLE_GENERATED_METHOD
	return result

func java_method_physicSize_18(_args: Array = []) -> Variant:
	var hit_size := float(_args[0] if _args.size() > 0 else 0.0)
	var size := source_unit_update_state.physic_size(hit_size)
	return {"source_owner": source_unit_update_source_text_state.SOURCE_UNIT_PHYSIC_SIZE_GENERATED_OWNER, "generated_method": source_unit_update_source_text_state.SOURCE_UNIT_PHYSIC_SIZE_GENERATED_METHOD, "size": size}

func java_method_canLand_19(_args: Array = []) -> Variant:
	var unit_x := float(_args[0] if _args.size() > 0 else 0.0)
	var unit_y := float(_args[1] if _args.size() > 1 else 0.0)
	var physic_size := float(_args[2] if _args.size() > 2 else 0.0)
	var on_solid_result := bool(_args[3] if _args.size() > 3 else false)
	var nearby_grounded_units_count := int(_args[4] if _args.size() > 4 else 0)
	var result := source_unit_update_state.can_land_state(unit_x, unit_y, physic_size, on_solid_result, nearby_grounded_units_count)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_CAN_LAND_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_CAN_LAND_GENERATED_METHOD
	return result

func java_method_inRange_20(_args: Array = []) -> Variant:
	var unit_x := float(_args[0] if _args.size() > 0 else 0.0)
	var unit_y := float(_args[1] if _args.size() > 1 else 0.0)
	var other_x := float(_args[2] if _args.size() > 2 else 0.0)
	var other_y := float(_args[3] if _args.size() > 3 else 0.0)
	var type_range := float(_args[4] if _args.size() > 4 else 0.0)
	var in_range := source_unit_update_state.in_range(unit_x, unit_y, other_x, other_y, type_range)
	return {"source_owner": source_unit_update_source_text_state.SOURCE_UNIT_IN_RANGE_GENERATED_OWNER, "generated_method": source_unit_update_source_text_state.SOURCE_UNIT_IN_RANGE_GENERATED_METHOD, "in_range": in_range}

func java_method_hasWeapons_21(_args: Array = []) -> Variant:
	var weapons: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var has_weapons := source_unit_update_state.has_weapons(weapons)
	return {"source_owner": source_unit_update_source_text_state.SOURCE_UNIT_HAS_WEAPONS_GENERATED_OWNER, "generated_method": source_unit_update_source_text_state.SOURCE_UNIT_HAS_WEAPONS_GENERATED_METHOD, "has_weapons": has_weapons}

func java_method_speed_22(_args: Array = []) -> Variant:
	var elevation_value := float(_args[0] if _args.size() > 0 else 0.0)
	var grounded_value := bool(_args[1] if _args.size() > 1 else false)
	var player_value := bool(_args[2] if _args.size() > 2 else false)
	var velocity_angle := float(_args[3] if _args.size() > 3 else 0.0)
	var rotation_value := float(_args[4] if _args.size() > 4 else 0.0)
	var strafe_penalty_value := float(_args[5] if _args.size() > 5 else 1.0)
	var can_boost_value := bool(_args[6] if _args.size() > 6 else false)
	var boost_multiplier_value := float(_args[7] if _args.size() > 7 else 1.0)
	var type_speed_value := float(_args[8] if _args.size() > 8 else 0.0)
	var floor_speed_multiplier_value := float(_args[9] if _args.size() > 9 else 1.0)
	var speed_value := source_unit_update_state.speed(elevation_value, grounded_value, player_value, velocity_angle, rotation_value, strafe_penalty_value, can_boost_value, boost_multiplier_value, type_speed_value, floor_speed_multiplier_value)
	return {"source_owner": source_unit_update_source_text_state.SOURCE_UNIT_SPEED_GENERATED_OWNER, "generated_method": source_unit_update_source_text_state.SOURCE_UNIT_SPEED_GENERATED_METHOD, "speed": speed_value}

func java_method_prefRotation_23(_args: Array = []) -> Variant:
	var actively_building := bool(_args[0] if _args.size() > 0 else false)
	var rotate_to_building := bool(_args[1] if _args.size() > 1 else false)
	var build_plan_angle := float(_args[2] if _args.size() > 2 else 0.0)
	var mine_tile_exists := bool(_args[3] if _args.size() > 3 else false)
	var mine_tile_angle := float(_args[4] if _args.size() > 4 else 0.0)
	var moving := bool(_args[5] if _args.size() > 5 else false)
	var omni_movement := bool(_args[6] if _args.size() > 6 else false)
	var velocity_angle := float(_args[7] if _args.size() > 7 else 0.0)
	var current_rotation := float(_args[8] if _args.size() > 8 else 0.0)
	var result := source_unit_update_state.pref_rotation_state(actively_building, rotate_to_building, build_plan_angle, mine_tile_exists, mine_tile_angle, moving, omni_movement, velocity_angle, current_rotation)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_PREF_ROTATION_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_PREF_ROTATION_GENERATED_METHOD
	return result

func java_method_ammof_24(_args: Array = []) -> Variant:
	var result := source_unit_update_state.ammof_state()
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_AMMOF_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_AMMOF_GENERATED_METHOD
	return result

func java_method_displayable_25(_args: Array = []) -> Variant:
	var type_hoverable := bool(_args[0] if _args.size() > 0 else false)
	var result := source_unit_update_state.displayable_state(type_hoverable)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_DISPLAYABLE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_DISPLAYABLE_GENERATED_METHOD
	return result

func java_method_isSyncHidden_26(_args: Array = []) -> Variant:
	var is_shooting_value := bool(_args[0] if _args.size() > 0 else false)
	var in_fog_to_value := bool(_args[1] if _args.size() > 1 else false)
	var result := source_unit_update_state.is_sync_hidden_state(is_shooting_value, in_fog_to_value)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_IS_SYNC_HIDDEN_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_IS_SYNC_HIDDEN_GENERATED_METHOD
	return result

func java_method_handleSyncHidden_27(_args: Array = []) -> Variant:
	var unit_id := int(_args[0] if _args.size() > 0 else 0)
	var result := source_unit_update_state.handle_sync_hidden_state(unit_id)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_HANDLE_SYNC_HIDDEN_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_HANDLE_SYNC_HIDDEN_GENERATED_METHOD
	return result

func java_method_inFogTo_28(_args: Array = []) -> Variant:
	var same_team := bool(_args[0] if _args.size() > 0 else false)
	var rules_fog := bool(_args[1] if _args.size() > 1 else false)
	var hit_size := float(_args[2] if _args.size() > 2 else 0.0)
	var unit_x := float(_args[3] if _args.size() > 3 else 0.0)
	var unit_y := float(_args[4] if _args.size() > 4 else 0.0)
	var center_visible := bool(_args[5] if _args.size() > 5 else false)
	var d8_visible: Array = _args[6] if _args.size() > 6 and _args[6] is Array else []
	var result := source_unit_update_state.in_fog_to_state(same_team, rules_fog, hit_size, unit_x, unit_y, center_visible, d8_visible)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_IN_FOG_TO_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_IN_FOG_TO_GENERATED_METHOD
	return result

func java_method_range_29(_args: Array = []) -> Variant:
	var type_max_range := float(_args[0] if _args.size() > 0 else 0.0)
	var result := source_unit_update_state.range_state(type_max_range)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_RANGE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_RANGE_GENERATED_METHOD
	return result

func java_method_clipSize_30(_args: Array = []) -> Variant:
	var is_building := bool(_args[0] if _args.size() > 0 else false)
	var infinite_resources := bool(_args[1] if _args.size() > 1 else false)
	var type_clip_size := float(_args[2] if _args.size() > 2 else 0.0)
	var type_region_width := float(_args[3] if _args.size() > 3 else 0.0)
	var type_build_range := float(_args[4] if _args.size() > 4 else 0.0)
	var source_tilesize := float(_args[5] if _args.size() > 5 else SOURCE_TILESIZE)
	var is_mining := bool(_args[6] if _args.size() > 6 else false)
	var type_mine_range := float(_args[7] if _args.size() > 7 else 0.0)
	var result := source_unit_update_state.clip_size_state(is_building, infinite_resources, type_clip_size, type_region_width, type_build_range, source_tilesize, is_mining, type_mine_range)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_CLIP_SIZE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_CLIP_SIZE_GENERATED_METHOD
	return result

func java_method_sense_31(_args: Array = []) -> Variant:
	var sensor := str(_args[0] if _args.size() > 0 else "")
	var unit_state: Dictionary = _args[1] if _args.size() > 1 and _args[1] is Dictionary else {}
	var source_tilesize := float(_args[2] if _args.size() > 2 else SOURCE_TILESIZE)
	var result := source_unit_update_state.laccess_state(sensor, unit_state, source_tilesize)
	result["source_owner"] = source_unit_sensor_source_text_state.SOURCE_UNIT_SENSE_LACCESS_GENERATED_OWNER
	result["generated_method"] = source_unit_sensor_source_text_state.SOURCE_UNIT_SENSE_LACCESS_GENERATED_METHOD
	return result

func java_method_senseObject_32(_args: Array = []) -> Variant:
	var sensor := str(_args[0] if _args.size() > 0 else "")
	var unit_state: Dictionary = _args[1] if _args.size() > 1 and _args[1] is Dictionary else {}
	var no_sensed: Variant = _args[2] if _args.size() > 2 else null
	var result := source_unit_update_state.sense_object_state(sensor, unit_state, no_sensed)
	result["source_owner"] = source_unit_sensor_source_text_state.SOURCE_UNIT_SENSE_OBJECT_GENERATED_OWNER
	result["generated_method"] = source_unit_sensor_source_text_state.SOURCE_UNIT_SENSE_OBJECT_GENERATED_METHOD
	return result

func java_method_sense_33(_args: Array = []) -> Variant:
	var content: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	var unit_state: Dictionary = _args[1] if _args.size() > 1 and _args[1] is Dictionary else {}
	var source_tilesize := float(_args[2] if _args.size() > 2 else SOURCE_TILESIZE)
	var result := source_unit_update_state.sense_content_state(content, unit_state, source_tilesize)
	result["source_owner"] = source_unit_sensor_source_text_state.SOURCE_UNIT_SENSE_CONTENT_GENERATED_OWNER
	result["generated_method"] = source_unit_sensor_source_text_state.SOURCE_UNIT_SENSE_CONTENT_GENERATED_METHOD
	return result

func java_method_setProp_34(_args: Array = []) -> Variant:
	var prop := str(_args[0] if _args.size() > 0 else "")
	var value := float(_args[1] if _args.size() > 1 else 0.0)
	var unit_state: Dictionary = _args[2] if _args.size() > 2 and _args[2] is Dictionary else {}
	var source_tilesize := float(_args[3] if _args.size() > 3 else SOURCE_TILESIZE)
	var result := source_unit_update_state.set_prop_laccess_double_state(prop, value, unit_state, source_tilesize)
	result["source_owner"] = source_unit_set_prop_source_text_state.SOURCE_UNIT_SET_PROP_LACCESS_DOUBLE_GENERATED_OWNER
	result["generated_method"] = source_unit_set_prop_source_text_state.SOURCE_UNIT_SET_PROP_LACCESS_DOUBLE_GENERATED_METHOD
	return result

func java_method_setProp_35(_args: Array = []) -> Variant:
	var prop := str(_args[0] if _args.size() > 0 else "")
	var value: Variant = _args[1] if _args.size() > 1 else null
	var unit_state: Dictionary = _args[2] if _args.size() > 2 and _args[2] is Dictionary else {}
	var result := source_unit_update_state.set_prop_laccess_object_state(prop, value, unit_state)
	result["source_owner"] = source_unit_set_prop_source_text_state.SOURCE_UNIT_SET_PROP_LACCESS_OBJECT_GENERATED_OWNER
	result["generated_method"] = source_unit_set_prop_source_text_state.SOURCE_UNIT_SET_PROP_LACCESS_OBJECT_GENERATED_METHOD
	return result

func java_method_setProp_36(_args: Array = []) -> Variant:
	var content: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	var value := float(_args[1] if _args.size() > 1 else 0.0)
	var unit_state: Dictionary = _args[2] if _args.size() > 2 and _args[2] is Dictionary else {}
	var result := source_unit_update_state.set_prop_content_state(content, value, unit_state)
	result["source_owner"] = source_unit_set_prop_source_text_state.SOURCE_UNIT_SET_PROP_CONTENT_GENERATED_OWNER
	result["generated_method"] = source_unit_set_prop_source_text_state.SOURCE_UNIT_SET_PROP_CONTENT_GENERATED_METHOD
	return result

func java_method_canShoot_37(_args: Array = []) -> Variant:
	var unit_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	var result := source_unit_update_state.can_shoot_state(unit_state)
	result["source_owner"] = source_unit_combat_metadata_source_text_state.SOURCE_UNIT_CAN_SHOOT_GENERATED_OWNER
	result["generated_method"] = source_unit_combat_metadata_source_text_state.SOURCE_UNIT_CAN_SHOOT_GENERATED_METHOD
	return result

func java_method_isEnemy_38(_args: Array = []) -> Variant:
	var unit_is_enemy := bool(_args[0] if _args.size() > 0 else false)
	var result := source_unit_update_state.is_enemy_state(unit_is_enemy)
	result["source_owner"] = source_unit_combat_metadata_source_text_state.SOURCE_UNIT_IS_ENEMY_GENERATED_OWNER
	result["generated_method"] = source_unit_combat_metadata_source_text_state.SOURCE_UNIT_IS_ENEMY_GENERATED_METHOD
	return result

func java_method_collides_39(_args: Array = []) -> Variant:
	var hittable := bool(_args[0] if _args.size() > 0 else false)
	var result := source_unit_update_state.collides_state(hittable)
	result["source_owner"] = source_unit_combat_metadata_source_text_state.SOURCE_UNIT_COLLIDES_GENERATED_OWNER
	result["generated_method"] = source_unit_combat_metadata_source_text_state.SOURCE_UNIT_COLLIDES_GENERATED_METHOD
	return result

func java_method_collision_40(_args: Array = []) -> Variant:
	var other_is_bullet := bool(_args[0] if _args.size() > 0 else false)
	var bullet: Variant = _args[1] if _args.size() > 1 else null
	var result := source_unit_update_state.collision_state(other_is_bullet, bullet)
	result["source_owner"] = source_unit_controller_source_text_state.SOURCE_UNIT_COLLISION_GENERATED_OWNER
	result["generated_method"] = source_unit_controller_source_text_state.SOURCE_UNIT_COLLISION_GENERATED_METHOD
	return result

func java_method_itemCapacity_41(_args: Array = []) -> Variant:
	var type_item_capacity := int(_args[0] if _args.size() > 0 else 0)
	var result := source_unit_update_state.item_capacity_state(type_item_capacity)
	result["source_owner"] = source_unit_combat_metadata_source_text_state.SOURCE_UNIT_ITEM_CAPACITY_GENERATED_OWNER
	result["generated_method"] = source_unit_combat_metadata_source_text_state.SOURCE_UNIT_ITEM_CAPACITY_GENERATED_METHOD
	return result

func java_method_bounds_42(_args: Array = []) -> Variant:
	var hit_size := float(_args[0] if _args.size() > 0 else 0.0)
	var result := source_unit_update_state.unit_bounds_metric_state(hit_size)
	result["source_owner"] = source_unit_combat_metadata_source_text_state.SOURCE_UNIT_BOUNDS_GENERATED_OWNER
	result["generated_method"] = source_unit_combat_metadata_source_text_state.SOURCE_UNIT_BOUNDS_GENERATED_METHOD
	return result

func java_method_controller_43(_args: Array = []) -> Variant:
	var next_controller: Variant = _args[0] if _args.size() > 0 else null
	var controller_unit: Variant = _args[1] if _args.size() > 1 else null
	var self_unit: Variant = _args[2] if _args.size() > 2 else null
	var result := source_unit_update_state.controller_set_state(next_controller, controller_unit, self_unit)
	result["source_owner"] = source_unit_controller_source_text_state.SOURCE_UNIT_CONTROLLER_SET_GENERATED_OWNER
	result["generated_method"] = source_unit_controller_source_text_state.SOURCE_UNIT_CONTROLLER_SET_GENERATED_METHOD
	return result

func java_method_controller_44(_args: Array = []) -> Variant:
	var controller: Variant = _args[0] if _args.size() > 0 else null
	var result := source_unit_update_state.controller_get_state(controller)
	result["source_owner"] = source_unit_controller_source_text_state.SOURCE_UNIT_CONTROLLER_GET_GENERATED_OWNER
	result["generated_method"] = source_unit_controller_source_text_state.SOURCE_UNIT_CONTROLLER_GET_GENERATED_METHOD
	return result

func java_method_resetController_45(_args: Array = []) -> Variant:
	var created_controller: Variant = _args[0] if _args.size() > 0 else null
	var result := source_unit_update_state.reset_controller_state(created_controller)
	result["source_owner"] = source_unit_controller_source_text_state.SOURCE_UNIT_RESET_CONTROLLER_GENERATED_OWNER
	result["generated_method"] = source_unit_controller_source_text_state.SOURCE_UNIT_RESET_CONTROLLER_GENERATED_METHOD
	return result

func java_method_set_46(_args: Array = []) -> Variant:
	var current_type: Variant = _args[0] if _args.size() > 0 else null
	var definition: Variant = _args[1] if _args.size() > 1 else null
	var controller: Variant = _args[2] if _args.size() > 2 else null
	var controller_unit: Variant = _args[3] if _args.size() > 3 else null
	var self_unit: Variant = _args[4] if _args.size() > 4 else null
	var result := source_unit_update_state.set_controller_state(current_type, definition, controller, controller_unit, self_unit)
	result["source_owner"] = source_unit_controller_source_text_state.SOURCE_UNIT_SET_GENERATED_OWNER
	result["generated_method"] = source_unit_controller_source_text_state.SOURCE_UNIT_SET_GENERATED_METHOD
	return result

func java_method_collisionLayer_47(_args: Array = []) -> Variant:
	var type_allow_leg_step := bool(_args[0] if _args.size() > 0 else false)
	var type_leg_physics_layer := bool(_args[1] if _args.size() > 1 else false)
	var is_grounded := bool(_args[2] if _args.size() > 2 else false)
	var layer_legs := int(_args[3] if _args.size() > 3 else source_unit_controller_source_text_state.SOURCE_UNIT_COLLISION_LAYER_LEGS_VALUE)
	var layer_ground := int(_args[4] if _args.size() > 4 else source_unit_controller_source_text_state.SOURCE_UNIT_COLLISION_LAYER_GROUND_VALUE)
	var layer_flying := int(_args[5] if _args.size() > 5 else source_unit_controller_source_text_state.SOURCE_UNIT_COLLISION_LAYER_FLYING_VALUE)
	var result := source_unit_update_state.collision_layer_state(type_allow_leg_step, type_leg_physics_layer, is_grounded, layer_legs, layer_ground, layer_flying)
	result["source_owner"] = source_unit_controller_source_text_state.SOURCE_UNIT_COLLISION_LAYER_GENERATED_OWNER
	result["generated_method"] = source_unit_controller_source_text_state.SOURCE_UNIT_COLLISION_LAYER_GENERATED_METHOD
	return result

func java_method_lookAt_48(_args: Array = []) -> Variant:
	var current_rotation := float(_args[0] if _args.size() > 0 else 0.0)
	var target_angle := float(_args[1] if _args.size() > 1 else 0.0)
	var type_rotate_speed := float(_args[2] if _args.size() > 2 else 0.0)
	var speed_multiplier_value := float(_args[3] if _args.size() > 3 else 1.0)
	var source_delta := float(_args[4] if _args.size() > 4 else 0.0)
	var game: Object = _args[5] if _args.size() > 5 else self
	var result := source_unit_update_state.game_look_at_angle_state(game, current_rotation, target_angle, type_rotate_speed, speed_multiplier_value, source_delta)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_LOOK_AT_ANGLE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_LOOK_AT_ANGLE_GENERATED_METHOD
	return result

func java_method_lookAt_49(_args: Array = []) -> Variant:
	var current_rotation := float(_args[0] if _args.size() > 0 else 0.0)
	var unit_x := float(_args[1] if _args.size() > 1 else 0.0)
	var unit_y := float(_args[2] if _args.size() > 2 else 0.0)
	var target_x := float(_args[3] if _args.size() > 3 else 0.0)
	var target_y := float(_args[4] if _args.size() > 4 else 0.0)
	var type_rotate_speed := float(_args[5] if _args.size() > 5 else 0.0)
	var speed_multiplier_value := float(_args[6] if _args.size() > 6 else 1.0)
	var source_delta := float(_args[7] if _args.size() > 7 else 0.0)
	var game: Object = _args[8] if _args.size() > 8 else self
	var result := source_unit_update_state.game_look_at_position_state(game, current_rotation, unit_x, unit_y, target_x, target_y, type_rotate_speed, speed_multiplier_value, source_delta)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_LOOK_AT_POSITION_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_LOOK_AT_POSITION_GENERATED_METHOD
	return result

func java_method_lookAt_50(_args: Array = []) -> Variant:
	var current_rotation := float(_args[0] if _args.size() > 0 else 0.0)
	var unit_x := float(_args[1] if _args.size() > 1 else 0.0)
	var unit_y := float(_args[2] if _args.size() > 2 else 0.0)
	var target_x := float(_args[3] if _args.size() > 3 else 0.0)
	var target_y := float(_args[4] if _args.size() > 4 else 0.0)
	var type_rotate_speed := float(_args[5] if _args.size() > 5 else 0.0)
	var speed_multiplier_value := float(_args[6] if _args.size() > 6 else 1.0)
	var source_delta := float(_args[7] if _args.size() > 7 else 0.0)
	var game: Object = _args[8] if _args.size() > 8 else self
	var result := source_unit_update_state.game_look_at_xy_state(game, current_rotation, unit_x, unit_y, target_x, target_y, type_rotate_speed, speed_multiplier_value, source_delta)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_LOOK_AT_XY_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_LOOK_AT_XY_GENERATED_METHOD
	return result

func java_method_isAI_51(_args: Array = []) -> Variant:
	var controller_is_ai_controller := bool(_args[0] if _args.size() > 0 else false)
	var result := source_unit_update_state.controller_predicates_state(controller_is_ai_controller, false)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_IS_AI_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_IS_AI_GENERATED_METHOD
	return result

func java_method_allowCommand_52(_args: Array = []) -> Variant:
	var controller_is_command_ai := bool(_args[0] if _args.size() > 0 else false)
	var result := source_unit_update_state.controller_predicates_state(false, controller_is_command_ai)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_ALLOW_COMMAND_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_ALLOW_COMMAND_GENERATED_METHOD
	return result

func java_method_isCommandable_53(_args: Array = []) -> Variant:
	var controller_is_command_ai := bool(_args[0] if _args.size() > 0 else false)
	var result := source_unit_update_state.controller_predicates_state(controller_is_command_ai, controller_is_command_ai)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_IS_COMMANDABLE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_IS_COMMANDABLE_GENERATED_METHOD
	return result

func java_method_canTarget_54(_args: Array = []) -> Variant:
	var other_exists := bool(_args[0] if _args.size() > 0 else false)
	var other_is_unit := bool(_args[1] if _args.size() > 1 else false)
	var other_unit_check_target_result := bool(_args[2] if _args.size() > 2 else false)
	var other_is_building := bool(_args[3] if _args.size() > 3 else false)
	var type_target_air := bool(_args[4] if _args.size() > 4 else false)
	var type_target_ground := bool(_args[5] if _args.size() > 5 else false)
	var result := source_unit_update_state.can_target_state(other_exists, other_is_unit, other_unit_check_target_result, other_is_building, type_target_air, type_target_ground)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_CAN_TARGET_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_CAN_TARGET_GENERATED_METHOD
	return result

func java_method_command_55(_args: Array = []) -> Variant:
	var controller_is_command_ai := bool(_args[0] if _args.size() > 0 else false)
	var result := source_unit_update_state.command_state(controller_is_command_ai)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_COMMAND_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_COMMAND_GENERATED_METHOD
	return result

func java_method_isMissile_56(_args: Array = []) -> Variant:
	var unit_is_timed_killc := bool(_args[0] if _args.size() > 0 else false)
	var result := source_unit_update_state.is_missile_state(unit_is_timed_killc)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_IS_MISSILE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_IS_MISSILE_GENERATED_METHOD
	return result

func java_method_count_57(_args: Array = []) -> Variant:
	var team_data_count_type_result := int(_args[0] if _args.size() > 0 else 0)
	var type_id := int(_args[1] if _args.size() > 1 else 0)
	var result := source_unit_update_state.count_state(team_data_count_type_result, type_id)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_COUNT_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_COUNT_GENERATED_METHOD
	return result

func java_method_cap_58(_args: Array = []) -> Variant:
	var team_is_wave_team := bool(_args[0] if _args.size() > 0 else false)
	var rules_pvp := bool(_args[1] if _args.size() > 1 else false)
	var state_is_campaign := bool(_args[2] if _args.size() > 2 else false)
	var rules_disable_unit_cap := bool(_args[3] if _args.size() > 3 else false)
	var team_ignore_unit_cap := bool(_args[4] if _args.size() > 4 else false)
	var rules_unit_cap_variable := bool(_args[5] if _args.size() > 5 else false)
	var rules_unit_cap := int(_args[6] if _args.size() > 6 else 0)
	var team_data_unit_cap := int(_args[7] if _args.size() > 7 else 0)
	var result := source_unit_update_state.cap_state(team_is_wave_team, rules_pvp, state_is_campaign, rules_disable_unit_cap, team_ignore_unit_cap, rules_unit_cap_variable, rules_unit_cap, team_data_unit_cap)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_CAP_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_CAP_GENERATED_METHOD
	return result

func java_method_setType_59(_args: Array = []) -> Variant:
	var type_id := int(_args[0] if _args.size() > 0 else 0)
	var type_health := float(_args[1] if _args.size() > 1 else 0.0)
	var type_drag := float(_args[2] if _args.size() > 2 else 0.0)
	var type_armor := float(_args[3] if _args.size() > 3 else 0.0)
	var type_hit_size := float(_args[4] if _args.size() > 4 else 0.0)
	var mounts_length := int(_args[5] if _args.size() > 5 else 0)
	var type_weapons_size := int(_args[6] if _args.size() > 6 else 0)
	var abilities_length := int(_args[7] if _args.size() > 7 else 0)
	var type_abilities_size := int(_args[8] if _args.size() > 8 else 0)
	var first_ability_is_empty_data_ability := bool(_args[9] if _args.size() > 9 else false)
	var controller_is_null := bool(_args[10] if _args.size() > 10 else false)
	var result := source_unit_update_state.set_type_state(type_id, type_health, type_drag, type_armor, type_hit_size, mounts_length, type_weapons_size, abilities_length, type_abilities_size, first_ability_is_empty_data_ability, controller_is_null)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_GENERATED_METHOD
	return result

func java_method_playerControllable_60(_args: Array = []) -> Variant:
	var type_player_controllable := bool(_args[0] if _args.size() > 0 else false)
	var controller_is_logic_ai := bool(_args[1] if _args.size() > 1 else false)
	var logic_controller_exists := bool(_args[2] if _args.size() > 2 else false)
	var logic_controller_block_privileged := bool(_args[3] if _args.size() > 3 else false)
	var result := source_unit_update_state.player_controllable_state(type_player_controllable, controller_is_logic_ai, logic_controller_exists, logic_controller_block_privileged)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_PLAYER_CONTROLLABLE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_PLAYER_CONTROLLABLE_GENERATED_METHOD
	return result

func java_method_targetable_61(_args: Array = []) -> Variant:
	var type_targetable := bool(_args[0] if _args.size() > 0 else false)
	var type_vulnerable_with_payloads := bool(_args[1] if _args.size() > 1 else false)
	var unit_is_payloadc := bool(_args[2] if _args.size() > 2 else false)
	var unit_has_payload := bool(_args[3] if _args.size() > 3 else false)
	var targeter_id := int(_args[4] if _args.size() > 4 else 0)
	var result := source_unit_update_state.targetable_state(type_targetable, type_vulnerable_with_payloads, unit_is_payloadc, unit_has_payload, targeter_id)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_TARGETABLE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_TARGETABLE_GENERATED_METHOD
	return result

func java_method_killable_62(_args: Array = []) -> Variant:
	var type_killable := bool(_args[0] if _args.size() > 0 else false)
	var result := source_unit_update_state.killable_state(type_killable)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_KILLABLE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_KILLABLE_GENERATED_METHOD
	return result

func java_method_hittable_63(_args: Array = []) -> Variant:
	var type_hittable := bool(_args[0] if _args.size() > 0 else false)
	var type_vulnerable_with_payloads := bool(_args[1] if _args.size() > 1 else false)
	var unit_is_payloadc := bool(_args[2] if _args.size() > 2 else false)
	var unit_has_payload := bool(_args[3] if _args.size() > 3 else false)
	var result := source_unit_update_state.hittable_state(type_hittable, type_vulnerable_with_payloads, unit_is_payloadc, unit_has_payload)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_HITTABLE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_HITTABLE_GENERATED_METHOD
	return result

func java_method_afterSync_64(_args: Array = []) -> Variant:
	var type_id := int(_args[0] if _args.size() > 0 else 0)
	var controller_exists := bool(_args[1] if _args.size() > 1 else false)
	var result := source_unit_update_state.after_sync_state(type_id, controller_exists)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_AFTER_SYNC_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_AFTER_SYNC_GENERATED_METHOD
	return result

func java_method_afterRead_65(_args: Array = []) -> Variant:
	var type_id := int(_args[0] if _args.size() > 0 else 0)
	var controller_is_ai_controller := bool(_args[1] if _args.size() > 1 else false)
	var ai_keep_state := bool(_args[2] if _args.size() > 2 else false)
	var controller_exists := bool(_args[3] if _args.size() > 3 else false)
	var result := source_unit_update_state.after_read_state(type_id, controller_is_ai_controller, ai_keep_state, controller_exists)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_AFTER_READ_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_AFTER_READ_GENERATED_METHOD
	return result

func java_method_afterReadAll_66(_args: Array = []) -> Variant:
	var controller_exists := bool(_args[0] if _args.size() > 0 else false)
	var result := source_unit_update_state.after_read_all_state(controller_exists)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_AFTER_READ_ALL_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_AFTER_READ_ALL_GENERATED_METHOD
	return result

func java_method_add_67(_args: Array = []) -> Variant:
	var type_use_unit_cap := bool(_args[0] if _args.size() > 0 else false)
	var count_after_add := int(_args[1] if _args.size() > 1 else 0)
	var cap_value := int(_args[2] if _args.size() > 2 else 0)
	var spawned_by_core := bool(_args[3] if _args.size() > 3 else false)
	var dead := bool(_args[4] if _args.size() > 4 else false)
	var rules_editor := bool(_args[5] if _args.size() > 5 else false)
	var result := source_unit_update_state.add_state(type_use_unit_cap, count_after_add, cap_value, spawned_by_core, dead, rules_editor)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_ADD_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_ADD_GENERATED_METHOD
	return result

func java_method_remove_68(_args: Array = []) -> Variant:
	var trail_exists := bool(_args[0] if _args.size() > 0 else false)
	var trail_size := int(_args[1] if _args.size() > 1 else 0)
	var trail_width := float(_args[2] if _args.size() > 2 else 0.0)
	var type_trail_color_exists := bool(_args[3] if _args.size() > 3 else false)
	var team_color := str(_args[4] if _args.size() > 4 else "")
	var type_trail_color := str(_args[5] if _args.size() > 5 else "")
	var result := source_unit_destroy_state.remove_state(trail_exists, trail_size, trail_width, type_trail_color_exists, team_color, type_trail_color)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_REMOVE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_REMOVE_GENERATED_METHOD
	return result

func java_method_landed_69(_args: Array = []) -> Variant:
	var type_mech_land_shake := float(_args[0] if _args.size() > 0 else 0.0)
	var result := source_unit_update_state.landed_state(type_mech_land_shake)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_LANDED_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_LANDED_GENERATED_METHOD
	return result

func java_method_heal_70(_args: Array = []) -> Variant:
	var current_health := float(_args[0] if _args.size() > 0 else 0.0)
	var max_health := float(_args[1] if _args.size() > 1 else 0.0)
	var amount := float(_args[2] if _args.size() > 2 else 0.0)
	var current_was_healed := bool(_args[3] if _args.size() > 3 else false)
	var result := source_unit_update_state.heal_state(current_health, max_health, amount, current_was_healed)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_HEAL_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_HEAL_GENERATED_METHOD
	return result

func java_method_updateDrowning_71(_args: Array = []) -> Variant:
	var floor_exists := bool(_args[0] if _args.size() > 0 else false)
	var floor_is_liquid := bool(_args[1] if _args.size() > 1 else false)
	var floor_drown_time := float(_args[2] if _args.size() > 2 else 0.0)
	var can_drown_value := bool(_args[3] if _args.size() > 3 else false)
	var current_drown_time := float(_args[4] if _args.size() > 4 else 0.0)
	var source_delta := float(_args[5] if _args.size() > 5 else 0.0)
	var hit_size := float(_args[6] if _args.size() > 6 else 0.0)
	var type_drown_time_multiplier := float(_args[7] if _args.size() > 7 else 1.0)
	var chance_delta_result := bool(_args[8] if _args.size() > 8 else false)
	var net_client := bool(_args[9] if _args.size() > 9 else false)
	var result := source_unit_update_state.drowning_state(floor_exists, floor_is_liquid, floor_drown_time, can_drown_value, current_drown_time, source_delta, hit_size, type_drown_time_multiplier, chance_delta_result, net_client)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_DROWNING_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_DROWNING_GENERATED_METHOD
	return result

func java_method_update_72(_args: Array = []) -> Variant:
	var context: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	var result := source_unit_update_state.update_state(context)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_GENERATED_METHOD
	return result

func java_method_shouldUpdateController_73(_args: Array = []) -> Variant:
	var result := source_unit_update_state.ai_controller_server_gate_state(false, false, true, 0)
	result["source_owner"] = source_unit_update_source_text_state.SOURCE_UNIT_SHOULD_UPDATE_CONTROLLER_GENERATED_OWNER
	result["generated_method"] = source_unit_update_source_text_state.SOURCE_UNIT_SHOULD_UPDATE_CONTROLLER_GENERATED_METHOD
	return result

func java_method_icon_74(_args: Array = []) -> Variant:
	var type_ui_icon: String = str(_args[0] if _args.size() > 0 else "")
	var result := source_unit_metadata_state.unit_icon_state(type_ui_icon)
	result["source_owner"] = source_unit_metadata_state.SOURCE_UNIT_ICON_GENERATED_OWNER
	result["generated_method"] = source_unit_metadata_state.SOURCE_UNIT_ICON_GENERATED_METHOD
	return result

func java_method_destroy_75(_args: Array = []) -> Variant:
	var input_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	return source_unit_destroy_state.destroy_state(input_state)

func java_method_getControllerName_76(_args: Array = []) -> Variant:
	var is_player := bool(_args[0] if _args.size() > 0 else false)
	var player_colored_name := str(_args[1] if _args.size() > 1 else "")
	var controller_is_logic_ai := bool(_args[2] if _args.size() > 2 else false)
	var logic_controller_exists := bool(_args[3] if _args.size() > 3 else false)
	var logic_controller_last_accessed := str(_args[4] if _args.size() > 4 else "")
	var result := source_unit_update_state.get_controller_name_state(is_player, player_colored_name, controller_is_logic_ai, logic_controller_exists, logic_controller_last_accessed)
	result["source_owner"] = source_unit_controller_source_text_state.SOURCE_UNIT_GET_CONTROLLER_NAME_GENERATED_OWNER
	result["generated_method"] = source_unit_controller_source_text_state.SOURCE_UNIT_GET_CONTROLLER_NAME_GENERATED_METHOD
	return result

func java_method_display_77(_args: Array = []) -> Variant:
	var table: Variant = _args[0] if _args.size() > 0 else null
	var result := source_unit_update_state.display_state(table)
	result["source_owner"] = source_unit_controller_source_text_state.SOURCE_UNIT_DISPLAY_GENERATED_OWNER
	result["generated_method"] = source_unit_controller_source_text_state.SOURCE_UNIT_DISPLAY_GENERATED_METHOD
	return result

func java_method_draw_78(_args: Array = []) -> Variant:
	var result := source_unit_update_state.draw_state()
	result["source_owner"] = source_unit_controller_source_text_state.SOURCE_UNIT_DRAW_GENERATED_OWNER
	result["generated_method"] = source_unit_controller_source_text_state.SOURCE_UNIT_DRAW_GENERATED_METHOD
	return result

func java_method_isPlayer_79(_args: Array = []) -> Variant:
	var controller_is_player := bool(_args[0] if _args.size() > 0 else false)
	var result := source_unit_update_state.is_player_state(controller_is_player)
	result["source_owner"] = source_unit_controller_source_text_state.SOURCE_UNIT_IS_PLAYER_GENERATED_OWNER
	result["generated_method"] = source_unit_controller_source_text_state.SOURCE_UNIT_IS_PLAYER_GENERATED_METHOD
	return result

func java_method_getPlayer_80(_args: Array = []) -> Variant:
	var controller_is_player := bool(_args[0] if _args.size() > 0 else false)
	var controller: Variant = _args[1] if _args.size() > 1 else null
	var result := source_unit_update_state.get_player_state(controller_is_player, controller)
	result["source_owner"] = source_unit_controller_source_text_state.SOURCE_UNIT_GET_PLAYER_GENERATED_OWNER
	result["generated_method"] = source_unit_controller_source_text_state.SOURCE_UNIT_GET_PLAYER_GENERATED_METHOD
	return result

func java_method_killed_81(_args: Array = []) -> Variant:
	var is_local_value := bool(_args[0] if _args.size() > 0 else false)
	var current_health := float(_args[1] if _args.size() > 1 else 0.0)
	var type_flying := bool(_args[2] if _args.size() > 2 else false)
	var type_create_wreck := bool(_args[3] if _args.size() > 3 else false)
	var wreck_sound := str(_args[4] if _args.size() > 4 else "")
	var wreck_sound_volume := float(_args[5] if _args.size() > 5 else 1.0)
	var unit_id := int(_args[6] if _args.size() > 6 else 0)
	var result := source_unit_destroy_state.killed_state(is_local_value, current_health, type_flying, type_create_wreck, wreck_sound, wreck_sound_volume, unit_id)
	result["source_owner"] = source_unit_destroy_source_text_state.SOURCE_UNIT_KILLED_GENERATED_OWNER
	result["generated_method"] = source_unit_destroy_source_text_state.SOURCE_UNIT_KILLED_GENERATED_METHOD
	return result

func java_method_kill_82(_args: Array = []) -> Variant:
	var dead_value := bool(_args[0] if _args.size() > 0 else false)
	var net_client := bool(_args[1] if _args.size() > 1 else false)
	var killable_value := bool(_args[2] if _args.size() > 2 else false)
	var unit_id := int(_args[3] if _args.size() > 3 else 0)
	var result := source_unit_destroy_state.kill_sync_state(dead_value, net_client, killable_value, unit_id)
	result["source_owner"] = source_unit_destroy_source_text_state.SOURCE_UNIT_KILL_SYNC_GENERATED_OWNER
	result["generated_method"] = source_unit_destroy_source_text_state.SOURCE_UNIT_KILL_SYNC_GENERATED_METHOD
	return result

func java_method_toString_83(_args: Array = []) -> Variant:
	var unit_id := int(_args[0] if _args.size() > 0 else 0)
	var unit_type: Variant = _args[1] if _args.size() > 1 else null
	var unit_x := float(_args[2] if _args.size() > 2 else 0.0)
	var unit_y := float(_args[3] if _args.size() > 3 else 0.0)
	var result := source_unit_update_state.to_string_state(unit_id, unit_type, unit_x, unit_y)
	result["source_owner"] = source_unit_controller_source_text_state.SOURCE_UNIT_TO_STRING_GENERATED_OWNER
	result["generated_method"] = source_unit_controller_source_text_state.SOURCE_UNIT_TO_STRING_GENERATED_METHOD
	return result
