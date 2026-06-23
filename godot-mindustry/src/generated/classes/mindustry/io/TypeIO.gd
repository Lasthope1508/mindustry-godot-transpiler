# Generated from Mindustry upstream.
# Source: mindustry/io/TypeIO.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.io"
const JAVA_KIND := "class"
const JAVA_NAME := "TypeIO"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "maxArraySize", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "maxByteArraySize", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "maxSyncedPlans", "type": "int"}, {"modifiers": ["final", "static"], "name": "noMounts", "type": "WeaponMount"}, {"modifiers": ["final", "static"], "name": "noAbilities", "type": "Ability"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "writeObject", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "object", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readObject", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public", "static"], "name": "readObjectBoxed", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "box", "type": "boolean", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public", "static"], "name": "readObject", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "box", "type": "boolean", "varargs": false}, {"name": "mapper", "type": "ContentMapper", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public", "static"], "name": "readObjectSafe", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public", "static"], "name": "readObject", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "box", "type": "boolean", "varargs": false}, {"name": "mapper", "type": "ContentMapper", "varargs": false}, {"name": "safe", "type": "boolean", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public", "static"], "name": "readObject", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "box", "type": "boolean", "varargs": false}, {"name": "mapper", "type": "ContentMapper", "varargs": false}, {"name": "safe", "type": "boolean", "varargs": false}, {"name": "allowArrays", "type": "boolean", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public", "static"], "name": "writePayload", "parameters": [{"name": "writes", "type": "Writes", "varargs": false}, {"name": "payload", "type": "Payload", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readPayload", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Payload"}, {"modifiers": ["public", "static"], "name": "writeMounts", "parameters": [{"name": "writes", "type": "Writes", "varargs": false}, {"name": "mounts", "type": "WeaponMount", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readMounts", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "mounts", "type": "WeaponMount", "varargs": false}], "return_type": "WeaponMount"}, {"modifiers": ["public", "static"], "name": "readMounts", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "WeaponMount"}, {"modifiers": ["public", "static"], "name": "readAbilities", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "abilities", "type": "Ability", "varargs": false}], "return_type": "Ability"}, {"modifiers": ["public", "static"], "name": "writeAbilities", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "abilities", "type": "Ability", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readAbilities", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Ability"}, {"modifiers": ["public", "static"], "name": "writeUnitContainer", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "cont", "type": "UnitSyncContainer", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readUnitContainer", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "UnitSyncContainer"}, {"modifiers": ["public", "static"], "name": "writeUnit", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readUnit", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public", "static"], "name": "writeCommand", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "command", "type": "UnitCommand", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readCommand", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "UnitCommand"}, {"modifiers": ["public", "static"], "name": "writeStance", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "stance", "type": "UnitStance", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readStance", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "UnitStance"}, {"modifiers": ["public", "static"], "name": "writePosEntity", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "entity", "type": "Posc", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readPosEntity", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Posc"}, {"modifiers": ["public", "static"], "name": "writeEntity", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "entity", "type": "Entityc", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readEntity", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "T"}, {"modifiers": ["public", "static"], "name": "writeBuilding", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "tile", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readBuilding", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public", "static"], "name": "writeTile", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readTile", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public", "static"], "name": "writeBlock", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readBlock", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Block"}, {"modifiers": ["public", "static"], "name": "getMaxPlans", "parameters": [{"name": "plans", "type": "Queue", "varargs": false}], "return_type": "int"}, {"modifiers": ["public", "static"], "name": "writePlansQueueNet", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "plans", "type": "Queue", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readPlansQueueNet", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Queue"}, {"modifiers": ["public", "static"], "name": "readPlansQueue", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Queue"}, {"modifiers": ["public", "static"], "name": "writePlan", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "plan", "type": "BuildPlan", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readPlan", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "BuildPlan"}, {"modifiers": ["public", "static"], "name": "writePlans", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "plans", "type": "BuildPlan", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readPlans", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "BuildPlan"}, {"modifiers": ["public", "static"], "name": "writeClientPlans", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "plans", "type": "ClientBuildPlans", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readClientPlans", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "ClientBuildPlans"}, {"modifiers": ["static"], "name": "readClientPlanConfig", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Object"}, {"modifiers": ["static"], "name": "validClientPlanConfig", "parameters": [{"name": "o", "type": "Object", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "writeController", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "control", "type": "UnitController", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readController", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "prev", "type": "UnitController", "varargs": false}], "return_type": "UnitController"}, {"modifiers": ["public", "static"], "name": "writeKick", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "reason", "type": "KickReason", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readKick", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "KickReason"}, {"modifiers": ["public", "static"], "name": "writeMarkerControl", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "reason", "type": "LMarkerControl", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readMarkerControl", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "LMarkerControl"}, {"modifiers": ["public", "static"], "name": "writeRules", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "rules", "type": "Rules", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readRules", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Rules"}, {"modifiers": ["public", "static"], "name": "writeObjectives", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "executor", "type": "MapObjectives", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readObjectives", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "MapObjectives"}, {"modifiers": ["public", "static"], "name": "writeObjectiveMarker", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "marker", "type": "ObjectiveMarker", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readObjectiveMarker", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "ObjectiveMarker"}, {"modifiers": ["public", "static"], "name": "writeVecNullable", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "v", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readVecNullable", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Vec2"}, {"modifiers": ["public", "static"], "name": "writeVec2", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "v", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readVec2", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "base", "type": "Vec2", "varargs": false}], "return_type": "Vec2"}, {"modifiers": ["public", "static"], "name": "readVec2", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Vec2"}, {"modifiers": ["public", "static"], "name": "writeStatus", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "entry", "type": "StatusEntry", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readStatus", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "StatusEntry"}, {"modifiers": ["public", "static"], "name": "writeItems", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "stack", "type": "ItemStack", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readItems", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "stack", "type": "ItemStack", "varargs": false}], "return_type": "ItemStack"}, {"modifiers": ["public", "static"], "name": "readItems", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "ItemStack"}, {"modifiers": ["public", "static"], "name": "writeItemStacks", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "stacks", "type": "ItemStack", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readItemStacks", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "ItemStack"}, {"modifiers": ["public", "static"], "name": "writeLiquidStacks", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "stacks", "type": "LiquidStack", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readLiquidStacks", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "LiquidStack"}, {"modifiers": ["public", "static"], "name": "writeTeam", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readTeam", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Team"}, {"modifiers": ["public", "static"], "name": "writeAction", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "reason", "type": "AdminAction", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readAction", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "AdminAction"}, {"modifiers": ["public", "static"], "name": "writeUnitType", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "effect", "type": "UnitType", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readUnitType", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "UnitType"}, {"modifiers": ["public", "static"], "name": "writeEffect", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "effect", "type": "Effect", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readEffect", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Effect"}, {"modifiers": ["public", "static"], "name": "writeColor", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readColor", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Color"}, {"modifiers": ["public", "static"], "name": "readColor", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": "Color"}, {"modifiers": ["public", "static"], "name": "writeIntSeq", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "seq", "type": "IntSeq", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readIntSeq", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "IntSeq"}, {"modifiers": ["public", "static"], "name": "writeContent", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "cont", "type": "Content", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readContent", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Content"}, {"modifiers": ["public", "static"], "name": "writeLiquid", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readLiquid", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Liquid"}, {"modifiers": ["public", "static"], "name": "writeBulletType", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "type", "type": "BulletType", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readBulletType", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "BulletType"}, {"modifiers": ["public", "static"], "name": "writeItem", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "item", "type": "Item", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readItem", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Item"}, {"modifiers": ["public", "static"], "name": "writeSound", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "sound", "type": "Sound", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readSound", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Sound"}, {"modifiers": ["public", "static"], "name": "writeWeather", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "item", "type": "Weather", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readWeather", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "Weather"}, {"modifiers": ["public", "static"], "name": "writeString", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "string", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readString", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "writeString", "parameters": [{"name": "write", "type": "ByteBuffer", "varargs": false}, {"name": "string", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readString", "parameters": [{"name": "read", "type": "ByteBuffer", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "writeBytes", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "bytes", "type": "byte", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readBytes", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "byte"}, {"modifiers": ["public", "static"], "name": "writeInts", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "ints", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readInts", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "int"}, {"modifiers": ["public", "static"], "name": "writeShorts", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "ints", "type": "short", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readShorts", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "short"}, {"modifiers": ["public", "static"], "name": "writeTraceInfo", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "trace", "type": "TraceInfo", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readTraceInfo", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "TraceInfo"}, {"modifiers": ["public", "static"], "name": "writeStrings", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "strings", "type": "String", "varargs": false}, {"name": "maxLen", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "writeStrings", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "strings", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readStrings", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "writeStringArray", "parameters": [{"name": "write", "type": "Writes", "varargs": false}, {"name": "strings", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readStringArray", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "writeStringData", "parameters": [{"name": "buffer", "type": "DataOutput", "varargs": false}, {"name": "string", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readStringData", "parameters": [{"name": "buffer", "type": "DataInput", "varargs": false}], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_writeObject_0(_args: Array = []) -> Variant:
	return null

func java_method_readObject_1(_args: Array = []) -> Variant:
	return null

func java_method_readObjectBoxed_2(_args: Array = []) -> Variant:
	return null

func java_method_readObject_3(_args: Array = []) -> Variant:
	return null

func java_method_readObjectSafe_4(_args: Array = []) -> Variant:
	return null

func java_method_readObject_5(_args: Array = []) -> Variant:
	return null

func java_method_readObject_6(_args: Array = []) -> Variant:
	return null

func java_method_writePayload_7(_args: Array = []) -> Variant:
	return null

func java_method_readPayload_8(_args: Array = []) -> Variant:
	return null

func java_method_writeMounts_9(_args: Array = []) -> Variant:
	return null

func java_method_readMounts_10(_args: Array = []) -> Variant:
	return null

func java_method_readMounts_11(_args: Array = []) -> Variant:
	return null

func java_method_readAbilities_12(_args: Array = []) -> Variant:
	return null

func java_method_writeAbilities_13(_args: Array = []) -> Variant:
	return null

func java_method_readAbilities_14(_args: Array = []) -> Variant:
	return null

func java_method_writeUnitContainer_15(_args: Array = []) -> Variant:
	return null

func java_method_readUnitContainer_16(_args: Array = []) -> Variant:
	return null

func java_method_writeUnit_17(_args: Array = []) -> Variant:
	return null

func java_method_readUnit_18(_args: Array = []) -> Variant:
	return null

func java_method_writeCommand_19(_args: Array = []) -> Variant:
	return null

func java_method_readCommand_20(_args: Array = []) -> Variant:
	return null

func java_method_writeStance_21(_args: Array = []) -> Variant:
	return null

func java_method_readStance_22(_args: Array = []) -> Variant:
	return null

func java_method_writePosEntity_23(_args: Array = []) -> Variant:
	return null

func java_method_readPosEntity_24(_args: Array = []) -> Variant:
	return null

func java_method_writeEntity_25(_args: Array = []) -> Variant:
	return null

func java_method_readEntity_26(_args: Array = []) -> Variant:
	return null

func java_method_writeBuilding_27(_args: Array = []) -> Variant:
	return null

func java_method_readBuilding_28(_args: Array = []) -> Variant:
	return null

func java_method_writeTile_29(_args: Array = []) -> Variant:
	return null

func java_method_readTile_30(_args: Array = []) -> Variant:
	return null

func java_method_writeBlock_31(_args: Array = []) -> Variant:
	return null

func java_method_readBlock_32(_args: Array = []) -> Variant:
	return null

func java_method_getMaxPlans_33(_args: Array = []) -> Variant:
	return null

func java_method_writePlansQueueNet_34(_args: Array = []) -> Variant:
	return null

func java_method_readPlansQueueNet_35(_args: Array = []) -> Variant:
	return null

func java_method_readPlansQueue_36(_args: Array = []) -> Variant:
	return null

func java_method_writePlan_37(_args: Array = []) -> Variant:
	return null

func java_method_readPlan_38(_args: Array = []) -> Variant:
	return null

func java_method_writePlans_39(_args: Array = []) -> Variant:
	return null

func java_method_readPlans_40(_args: Array = []) -> Variant:
	return null

func java_method_writeClientPlans_41(_args: Array = []) -> Variant:
	return null

func java_method_readClientPlans_42(_args: Array = []) -> Variant:
	return null

func java_method_readClientPlanConfig_43(_args: Array = []) -> Variant:
	return null

func java_method_validClientPlanConfig_44(_args: Array = []) -> Variant:
	return null

func java_method_writeController_45(_args: Array = []) -> Variant:
	return null

func java_method_readController_46(_args: Array = []) -> Variant:
	return null

func java_method_writeKick_47(_args: Array = []) -> Variant:
	return null

func java_method_readKick_48(_args: Array = []) -> Variant:
	return null

func java_method_writeMarkerControl_49(_args: Array = []) -> Variant:
	return null

func java_method_readMarkerControl_50(_args: Array = []) -> Variant:
	return null

func java_method_writeRules_51(_args: Array = []) -> Variant:
	return null

func java_method_readRules_52(_args: Array = []) -> Variant:
	return null

func java_method_writeObjectives_53(_args: Array = []) -> Variant:
	return null

func java_method_readObjectives_54(_args: Array = []) -> Variant:
	return null

func java_method_writeObjectiveMarker_55(_args: Array = []) -> Variant:
	return null

func java_method_readObjectiveMarker_56(_args: Array = []) -> Variant:
	return null

func java_method_writeVecNullable_57(_args: Array = []) -> Variant:
	return null

func java_method_readVecNullable_58(_args: Array = []) -> Variant:
	return null

func java_method_writeVec2_59(_args: Array = []) -> Variant:
	return null

func java_method_readVec2_60(_args: Array = []) -> Variant:
	return null

func java_method_readVec2_61(_args: Array = []) -> Variant:
	return null

func java_method_writeStatus_62(_args: Array = []) -> Variant:
	return null

func java_method_readStatus_63(_args: Array = []) -> Variant:
	return null

func java_method_writeItems_64(_args: Array = []) -> Variant:
	return null

func java_method_readItems_65(_args: Array = []) -> Variant:
	return null

func java_method_readItems_66(_args: Array = []) -> Variant:
	return null

func java_method_writeItemStacks_67(_args: Array = []) -> Variant:
	return null

func java_method_readItemStacks_68(_args: Array = []) -> Variant:
	return null

func java_method_writeLiquidStacks_69(_args: Array = []) -> Variant:
	return null

func java_method_readLiquidStacks_70(_args: Array = []) -> Variant:
	return null

func java_method_writeTeam_71(_args: Array = []) -> Variant:
	return null

func java_method_readTeam_72(_args: Array = []) -> Variant:
	return null

func java_method_writeAction_73(_args: Array = []) -> Variant:
	return null

func java_method_readAction_74(_args: Array = []) -> Variant:
	return null

func java_method_writeUnitType_75(_args: Array = []) -> Variant:
	return null

func java_method_readUnitType_76(_args: Array = []) -> Variant:
	return null

func java_method_writeEffect_77(_args: Array = []) -> Variant:
	return null

func java_method_readEffect_78(_args: Array = []) -> Variant:
	return null

func java_method_writeColor_79(_args: Array = []) -> Variant:
	return null

func java_method_readColor_80(_args: Array = []) -> Variant:
	return null

func java_method_readColor_81(_args: Array = []) -> Variant:
	return null

func java_method_writeIntSeq_82(_args: Array = []) -> Variant:
	return null

func java_method_readIntSeq_83(_args: Array = []) -> Variant:
	return null

func java_method_writeContent_84(_args: Array = []) -> Variant:
	return null

func java_method_readContent_85(_args: Array = []) -> Variant:
	return null

func java_method_writeLiquid_86(_args: Array = []) -> Variant:
	return null

func java_method_readLiquid_87(_args: Array = []) -> Variant:
	return null

func java_method_writeBulletType_88(_args: Array = []) -> Variant:
	return null

func java_method_readBulletType_89(_args: Array = []) -> Variant:
	return null

func java_method_writeItem_90(_args: Array = []) -> Variant:
	return null

func java_method_readItem_91(_args: Array = []) -> Variant:
	return null

func java_method_writeSound_92(_args: Array = []) -> Variant:
	return null

func java_method_readSound_93(_args: Array = []) -> Variant:
	return null

func java_method_writeWeather_94(_args: Array = []) -> Variant:
	return null

func java_method_readWeather_95(_args: Array = []) -> Variant:
	return null

func java_method_writeString_96(_args: Array = []) -> Variant:
	return null

func java_method_readString_97(_args: Array = []) -> Variant:
	return null

func java_method_writeString_98(_args: Array = []) -> Variant:
	return null

func java_method_readString_99(_args: Array = []) -> Variant:
	return null

func java_method_writeBytes_100(_args: Array = []) -> Variant:
	return null

func java_method_readBytes_101(_args: Array = []) -> Variant:
	return null

func java_method_writeInts_102(_args: Array = []) -> Variant:
	return null

func java_method_readInts_103(_args: Array = []) -> Variant:
	return null

func java_method_writeShorts_104(_args: Array = []) -> Variant:
	return null

func java_method_readShorts_105(_args: Array = []) -> Variant:
	return null

func java_method_writeTraceInfo_106(_args: Array = []) -> Variant:
	return null

func java_method_readTraceInfo_107(_args: Array = []) -> Variant:
	return null

func java_method_writeStrings_108(_args: Array = []) -> Variant:
	return null

func java_method_writeStrings_109(_args: Array = []) -> Variant:
	return null

func java_method_readStrings_110(_args: Array = []) -> Variant:
	return null

func java_method_writeStringArray_111(_args: Array = []) -> Variant:
	return null

func java_method_readStringArray_112(_args: Array = []) -> Variant:
	return null

func java_method_writeStringData_113(_args: Array = []) -> Variant:
	return null

func java_method_readStringData_114(_args: Array = []) -> Variant:
	return null
