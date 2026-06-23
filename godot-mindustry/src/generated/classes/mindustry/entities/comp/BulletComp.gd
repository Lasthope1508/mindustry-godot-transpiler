# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/BulletComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "BulletComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Timedc", "Damagec", "Hitboxc", "Teamc", "Posc", "Drawc", "Shielderc", "Ownerc", "Bulletc", "Timerc", "Senseable", "Settable"]
const JAVA_FIELDS := [{"modifiers": [], "name": "team", "type": "Team"}, {"modifiers": [], "name": "owner", "type": "Entityc"}, {"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "damage", "type": "float"}, {"modifiers": [], "name": "lastX", "type": "float"}, {"modifiers": [], "name": "lastY", "type": "float"}, {"modifiers": [], "name": "time", "type": "float"}, {"modifiers": [], "name": "lifetime", "type": "float"}, {"modifiers": [], "name": "collided", "type": "IntSeq"}, {"modifiers": [], "name": "type", "type": "BulletType"}, {"modifiers": [], "name": "vel", "type": "Vec2"}, {"modifiers": [], "name": "data", "type": "Object"}, {"modifiers": [], "name": "fdata", "type": "float"}, {"modifiers": ["private"], "name": "rotation", "type": "float"}, {"modifiers": ["transient"], "name": "keepAlive", "type": "boolean"}, {"modifiers": ["transient"], "name": "justSpawned", "type": "boolean"}, {"modifiers": ["transient"], "name": "shooter", "type": "Entityc"}, {"modifiers": ["transient"], "name": "aimTile", "type": "Tile"}, {"modifiers": ["transient"], "name": "aimX", "type": "float"}, {"modifiers": ["transient"], "name": "aimY", "type": "float"}, {"modifiers": ["transient"], "name": "originX", "type": "float"}, {"modifiers": ["transient"], "name": "originY", "type": "float"}, {"modifiers": ["transient"], "name": "buildingDamageMultiplier", "type": "float"}, {"modifiers": ["transient"], "name": "mover", "type": "Mover"}, {"modifiers": ["transient"], "name": "absorbed", "type": "boolean"}, {"modifiers": ["transient"], "name": "hit", "type": "boolean"}, {"modifiers": ["transient"], "name": "trail", "type": "Trail"}, {"modifiers": ["transient"], "name": "frags", "type": "int"}, {"modifiers": ["transient"], "name": "stickyTarget", "type": "Posc"}, {"modifiers": ["transient"], "name": "stickyX", "type": "float"}, {"modifiers": ["transient"], "name": "stickyY", "type": "float"}, {"modifiers": ["transient"], "name": "stickyRotation", "type": "float"}, {"modifiers": ["transient"], "name": "stickyRotationOffset", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getCollisions", "parameters": [{"name": "consumer", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isLocal", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "add", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "damageMultiplier", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "absorb", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "hasCollided", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "clipSize", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "collides", "parameters": [{"name": "other", "type": "Hitboxc", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "collision", "parameters": [{"name": "other", "type": "Hitboxc", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "stickTo", "parameters": [{"name": "other", "type": "Posc", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "moveRelative", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "turn", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "checkUnderBuild", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "tileRaycast", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "initVel", "parameters": [{"name": "angle", "type": "float", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "rotation", "parameters": [{"name": "angle", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "rotation", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "sense", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "double"}, {"modifiers": ["public"], "name": "setProp", "parameters": [{"name": "prop", "type": "LAccess", "varargs": false}, {"name": "value", "type": "double", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setProp", "parameters": [{"name": "content", "type": "UnlockableContent", "varargs": false}, {"name": "value", "type": "double", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setProp", "parameters": [{"name": "prop", "type": "LAccess", "varargs": false}, {"name": "value", "type": "Object", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getCollisions_0(_args: Array = []) -> Variant:
	return null

func java_method_isLocal_1(_args: Array = []) -> Variant:
	return null

func java_method_add_2(_args: Array = []) -> Variant:
	return null

func java_method_remove_3(_args: Array = []) -> Variant:
	return null

func java_method_damageMultiplier_4(_args: Array = []) -> Variant:
	return null

func java_method_absorb_5(_args: Array = []) -> Variant:
	return null

func java_method_hasCollided_6(_args: Array = []) -> Variant:
	return null

func java_method_clipSize_7(_args: Array = []) -> Variant:
	return null

func java_method_collides_8(_args: Array = []) -> Variant:
	return null

func java_method_collision_9(_args: Array = []) -> Variant:
	return null

func java_method_stickTo_10(_args: Array = []) -> Variant:
	return null

func java_method_update_11(_args: Array = []) -> Variant:
	return null

func java_method_moveRelative_12(_args: Array = []) -> Variant:
	return null

func java_method_turn_13(_args: Array = []) -> Variant:
	return null

func java_method_checkUnderBuild_14(_args: Array = []) -> Variant:
	return null

func java_method_tileRaycast_15(_args: Array = []) -> Variant:
	return null

func java_method_draw_16(_args: Array = []) -> Variant:
	return null

func java_method_initVel_17(_args: Array = []) -> Variant:
	return null

func java_method_rotation_18(_args: Array = []) -> Variant:
	return null

func java_method_rotation_19(_args: Array = []) -> Variant:
	return null

func java_method_sense_20(_args: Array = []) -> Variant:
	return null

func java_method_setProp_21(_args: Array = []) -> Variant:
	return null

func java_method_setProp_22(_args: Array = []) -> Variant:
	return null

func java_method_setProp_23(_args: Array = []) -> Variant:
	return null
