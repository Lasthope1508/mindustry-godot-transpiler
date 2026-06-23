# Generated from Mindustry upstream.
# Source: mindustry/game/FogControl.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.game"
const JAVA_KIND := "class"
const JAVA_NAME := "FogControl"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["CustomChunk"]
const JAVA_FIELDS := [{"modifiers": ["private", "static", "volatile"], "name": "ww", "type": "int"}, {"modifiers": ["private", "static", "volatile"], "name": "wh", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "dynamicUpdateInterval", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "notifyStatic", "type": "Object"}, {"modifiers": ["final", "private", "static"], "name": "notifyDynamic", "type": "Object"}, {"modifiers": ["private", "volatile"], "name": "fog", "type": "FogData"}, {"modifiers": ["final", "private"], "name": "staticEvents", "type": "LongSeq"}, {"modifiers": ["final", "private"], "name": "dynamicEventQueue", "type": "LongSeq"}, {"modifiers": ["final", "private"], "name": "unitEventQueue", "type": "LongSeq"}, {"modifiers": ["final", "private"], "name": "dynamicEvents", "type": "LongSeq"}, {"modifiers": ["private"], "name": "staticFogThread", "type": "Thread"}, {"modifiers": ["private"], "name": "dynamicFogThread", "type": "Thread"}, {"modifiers": ["private"], "name": "justLoaded", "type": "boolean"}, {"modifiers": ["private"], "name": "loadedStatic", "type": "boolean"}, {"modifiers": ["private"], "name": "lastEntityUpdateIndex", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "FogControl", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getDiscovered", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "Bits"}, {"modifiers": ["public"], "name": "isDiscovered", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isVisible", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isVisibleTile", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "resetFog", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "data", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "FogData"}, {"modifiers": [], "name": "stop", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "pushStaticBlocks", "parameters": [{"name": "initial", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "pushEvent", "parameters": [{"name": "event", "type": "long", "varargs": false}, {"name": "skipRender", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "forceUpdate", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "updateStatic", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "updateDynamic", "parameters": [{"name": "cleared", "type": "Bits", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "stream", "type": "DataOutput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "shouldWrite", "parameters": [], "return_type": "boolean"}, {"modifiers": ["static"], "name": "circle", "parameters": [{"name": "arr", "type": "Bits", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "radius", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "hline", "parameters": [{"name": "arr", "type": "Bits", "varargs": false}, {"name": "x1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getDiscovered_0(_args: Array = []) -> Variant:
	return null

func java_method_isDiscovered_1(_args: Array = []) -> Variant:
	return null

func java_method_isVisible_2(_args: Array = []) -> Variant:
	return null

func java_method_isVisibleTile_3(_args: Array = []) -> Variant:
	return null

func java_method_resetFog_4(_args: Array = []) -> Variant:
	return null

func java_method_data_5(_args: Array = []) -> Variant:
	return null

func java_method_stop_6(_args: Array = []) -> Variant:
	return null

func java_method_pushStaticBlocks_7(_args: Array = []) -> Variant:
	return null

func java_method_pushEvent_8(_args: Array = []) -> Variant:
	return null

func java_method_forceUpdate_9(_args: Array = []) -> Variant:
	return null

func java_method_update_10(_args: Array = []) -> Variant:
	return null

func java_method_updateStatic_11(_args: Array = []) -> Variant:
	return null

func java_method_updateDynamic_12(_args: Array = []) -> Variant:
	return null

func java_method_write_13(_args: Array = []) -> Variant:
	return null

func java_method_read_14(_args: Array = []) -> Variant:
	return null

func java_method_shouldWrite_15(_args: Array = []) -> Variant:
	return null

func java_method_circle_16(_args: Array = []) -> Variant:
	return null

func java_method_hline_17(_args: Array = []) -> Variant:
	return null
