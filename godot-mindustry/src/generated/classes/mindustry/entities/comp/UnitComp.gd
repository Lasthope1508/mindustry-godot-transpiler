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

func java_method_checkTarget_0(_args: Array = []) -> Variant:
	return null

func java_method_isGrounded_1(_args: Array = []) -> Variant:
	return null

func java_method_isFlying_2(_args: Array = []) -> Variant:
	return null

func java_method_canDrown_3(_args: Array = []) -> Variant:
	return null

func java_method_drownFloor_4(_args: Array = []) -> Variant:
	return null

func java_method_wobble_5(_args: Array = []) -> Variant:
	return null

func java_method_moveAt_6(_args: Array = []) -> Variant:
	return null

func java_method_floorSpeedMultiplier_7(_args: Array = []) -> Variant:
	return null

func java_method_unloaded_8(_args: Array = []) -> Variant:
	return null

func java_method_updateBoosting_9(_args: Array = []) -> Variant:
	return null

func java_method_updateBoosting_10(_args: Array = []) -> Variant:
	return null

func java_method_movePref_11(_args: Array = []) -> Variant:
	return null

func java_method_moveAt_12(_args: Array = []) -> Variant:
	return null

func java_method_approach_13(_args: Array = []) -> Variant:
	return null

func java_method_rotateMove_14(_args: Array = []) -> Variant:
	return null

func java_method_aimLook_15(_args: Array = []) -> Variant:
	return null

func java_method_aimLook_16(_args: Array = []) -> Variant:
	return null

func java_method_isPathImpassable_17(_args: Array = []) -> Variant:
	return null

func java_method_physicSize_18(_args: Array = []) -> Variant:
	return null

func java_method_canLand_19(_args: Array = []) -> Variant:
	return null

func java_method_inRange_20(_args: Array = []) -> Variant:
	return null

func java_method_hasWeapons_21(_args: Array = []) -> Variant:
	return null

func java_method_speed_22(_args: Array = []) -> Variant:
	return null

func java_method_prefRotation_23(_args: Array = []) -> Variant:
	return null

func java_method_ammof_24(_args: Array = []) -> Variant:
	return null

func java_method_displayable_25(_args: Array = []) -> Variant:
	return null

func java_method_isSyncHidden_26(_args: Array = []) -> Variant:
	return null

func java_method_handleSyncHidden_27(_args: Array = []) -> Variant:
	return null

func java_method_inFogTo_28(_args: Array = []) -> Variant:
	return null

func java_method_range_29(_args: Array = []) -> Variant:
	return null

func java_method_clipSize_30(_args: Array = []) -> Variant:
	return null

func java_method_sense_31(_args: Array = []) -> Variant:
	return null

func java_method_senseObject_32(_args: Array = []) -> Variant:
	return null

func java_method_sense_33(_args: Array = []) -> Variant:
	return null

func java_method_setProp_34(_args: Array = []) -> Variant:
	return null

func java_method_setProp_35(_args: Array = []) -> Variant:
	return null

func java_method_setProp_36(_args: Array = []) -> Variant:
	return null

func java_method_canShoot_37(_args: Array = []) -> Variant:
	return null

func java_method_isEnemy_38(_args: Array = []) -> Variant:
	return null

func java_method_collides_39(_args: Array = []) -> Variant:
	return null

func java_method_collision_40(_args: Array = []) -> Variant:
	return null

func java_method_itemCapacity_41(_args: Array = []) -> Variant:
	return null

func java_method_bounds_42(_args: Array = []) -> Variant:
	return null

func java_method_controller_43(_args: Array = []) -> Variant:
	return null

func java_method_controller_44(_args: Array = []) -> Variant:
	return null

func java_method_resetController_45(_args: Array = []) -> Variant:
	return null

func java_method_set_46(_args: Array = []) -> Variant:
	return null

func java_method_collisionLayer_47(_args: Array = []) -> Variant:
	return null

func java_method_lookAt_48(_args: Array = []) -> Variant:
	return null

func java_method_lookAt_49(_args: Array = []) -> Variant:
	return null

func java_method_lookAt_50(_args: Array = []) -> Variant:
	return null

func java_method_isAI_51(_args: Array = []) -> Variant:
	return null

func java_method_allowCommand_52(_args: Array = []) -> Variant:
	return null

func java_method_isCommandable_53(_args: Array = []) -> Variant:
	return null

func java_method_canTarget_54(_args: Array = []) -> Variant:
	return null

func java_method_command_55(_args: Array = []) -> Variant:
	return null

func java_method_isMissile_56(_args: Array = []) -> Variant:
	return null

func java_method_count_57(_args: Array = []) -> Variant:
	return null

func java_method_cap_58(_args: Array = []) -> Variant:
	return null

func java_method_setType_59(_args: Array = []) -> Variant:
	return null

func java_method_playerControllable_60(_args: Array = []) -> Variant:
	return null

func java_method_targetable_61(_args: Array = []) -> Variant:
	return null

func java_method_killable_62(_args: Array = []) -> Variant:
	return null

func java_method_hittable_63(_args: Array = []) -> Variant:
	return null

func java_method_afterSync_64(_args: Array = []) -> Variant:
	return null

func java_method_afterRead_65(_args: Array = []) -> Variant:
	return null

func java_method_afterReadAll_66(_args: Array = []) -> Variant:
	return null

func java_method_add_67(_args: Array = []) -> Variant:
	return null

func java_method_remove_68(_args: Array = []) -> Variant:
	return null

func java_method_landed_69(_args: Array = []) -> Variant:
	return null

func java_method_heal_70(_args: Array = []) -> Variant:
	return null

func java_method_updateDrowning_71(_args: Array = []) -> Variant:
	return null

func java_method_update_72(_args: Array = []) -> Variant:
	return null

func java_method_shouldUpdateController_73(_args: Array = []) -> Variant:
	return null

func java_method_icon_74(_args: Array = []) -> Variant:
	return null

func java_method_destroy_75(_args: Array = []) -> Variant:
	return null

func java_method_getControllerName_76(_args: Array = []) -> Variant:
	return null

func java_method_display_77(_args: Array = []) -> Variant:
	return null

func java_method_draw_78(_args: Array = []) -> Variant:
	return null

func java_method_isPlayer_79(_args: Array = []) -> Variant:
	return null

func java_method_getPlayer_80(_args: Array = []) -> Variant:
	return null

func java_method_killed_81(_args: Array = []) -> Variant:
	return null

func java_method_kill_82(_args: Array = []) -> Variant:
	return null

func java_method_toString_83(_args: Array = []) -> Variant:
	return null
