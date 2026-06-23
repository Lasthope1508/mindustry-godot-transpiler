# Generated from Mindustry upstream.
# Source: mindustry/game/Schematics.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.game"
const JAVA_KIND := "class"
const JAVA_NAME := "Schematics"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Loadable"]
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "tmpSchem", "type": "Schematic"}, {"modifiers": ["final", "private", "static"], "name": "tmpSchem2", "type": "Schematic"}, {"modifiers": ["final", "private", "static"], "name": "header", "type": "byte"}, {"modifiers": ["final", "private", "static"], "name": "version", "type": "byte"}, {"modifiers": ["final", "private", "static"], "name": "limitSchematicSize", "type": "boolean"}, {"modifiers": ["final", "private", "static"], "name": "padding", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "maxPreviewsMobile", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "resolution", "type": "int"}, {"modifiers": ["private"], "name": "out", "type": "OptimizedByteArrayOutputStream"}, {"modifiers": ["private"], "name": "all", "type": "Seq"}, {"modifiers": ["private"], "name": "previews", "type": "OrderedMap"}, {"modifiers": ["private"], "name": "errored", "type": "ObjectSet"}, {"modifiers": ["private"], "name": "loadouts", "type": "ObjectMap"}, {"modifiers": ["private"], "name": "defaultLoadouts", "type": "ObjectMap"}, {"modifiers": ["private"], "name": "shadowBuffer", "type": "FrameBuffer"}, {"modifiers": ["private"], "name": "errorTexture", "type": "Texture"}, {"modifiers": ["private"], "name": "lastClearTime", "type": "long"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Schematics", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "loadSync", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "loadLoadouts", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "overwrite", "parameters": [{"name": "target", "type": "Schematic", "varargs": false}, {"name": "newSchematic", "type": "Schematic", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "loadFile", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": "Schematic"}, {"modifiers": ["public"], "name": "all", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "saveChanges", "parameters": [{"name": "s", "type": "Schematic", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "savePreview", "parameters": [{"name": "schematic", "type": "Schematic", "varargs": false}, {"name": "file", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getPreview", "parameters": [{"name": "schematic", "type": "Schematic", "varargs": false}], "return_type": "Texture"}, {"modifiers": ["public"], "name": "hasPreview", "parameters": [{"name": "schematic", "type": "Schematic", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getBuffer", "parameters": [{"name": "schematic", "type": "Schematic", "varargs": false}], "return_type": "FrameBuffer"}, {"modifiers": ["public"], "name": "toPlans", "parameters": [{"name": "schem", "type": "Schematic", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "toPlans", "parameters": [{"name": "schem", "type": "Schematic", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "checkHidden", "type": "boolean", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getLoadouts", "parameters": [{"name": "block", "type": "CoreBlock", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getLoadouts", "parameters": [], "return_type": "ObjectMap"}, {"modifiers": ["public"], "name": "getDefaultLoadout", "parameters": [{"name": "block", "type": "CoreBlock", "varargs": false}], "return_type": "Schematic"}, {"modifiers": ["public"], "name": "isDefaultLoadout", "parameters": [{"name": "schem", "type": "Schematic", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private"], "name": "checkLoadout", "parameters": [{"name": "s", "type": "Schematic", "varargs": false}, {"name": "customSchem", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getMaxLaunchSize", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": "int"}, {"modifiers": [], "name": "findFile", "parameters": [{"name": "schematicName", "type": "String", "varargs": false}], "return_type": "Fi"}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "schematic", "type": "Schematic", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "s", "type": "Schematic", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "create", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}], "return_type": "Schematic"}, {"modifiers": ["public"], "name": "writeBase64", "parameters": [{"name": "schematic", "type": "Schematic", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "placeLaunchLoadout", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "placeLoadout", "parameters": [{"name": "schem", "type": "Schematic", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "placeLoadout", "parameters": [{"name": "schem", "type": "Schematic", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "placeLoadout", "parameters": [{"name": "schem", "type": "Schematic", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "check", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "place", "parameters": [{"name": "schem", "type": "Schematic", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "place", "parameters": [{"name": "schem", "type": "Schematic", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "overwrite", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readBase64", "parameters": [{"name": "schematic", "type": "String", "varargs": false}], "return_type": "Schematic"}, {"modifiers": ["public", "static"], "name": "read", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": "Schematic"}, {"modifiers": ["public", "static"], "name": "read", "parameters": [{"name": "input", "type": "InputStream", "varargs": false}], "return_type": "Schematic"}, {"modifiers": ["public", "static"], "name": "write", "parameters": [{"name": "schematic", "type": "Schematic", "varargs": false}, {"name": "file", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "write", "parameters": [{"name": "schematic", "type": "Schematic", "varargs": false}, {"name": "output", "type": "OutputStream", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "mapConfig", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "value", "type": "int", "varargs": false}, {"name": "position", "type": "int", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public", "static"], "name": "rotate", "parameters": [{"name": "input", "type": "Schematic", "varargs": false}, {"name": "times", "type": "int", "varargs": false}], "return_type": "Schematic"}, {"modifiers": ["private", "static"], "name": "rotated", "parameters": [{"name": "input", "type": "Schematic", "varargs": false}, {"name": "counter", "type": "boolean", "varargs": false}], "return_type": "Schematic"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_loadSync_0(_args: Array = []) -> Variant:
	return null

func java_method_load_1(_args: Array = []) -> Variant:
	return null

func java_method_loadLoadouts_2(_args: Array = []) -> Variant:
	return null

func java_method_overwrite_3(_args: Array = []) -> Variant:
	return null

func java_method_loadFile_4(_args: Array = []) -> Variant:
	return null

func java_method_all_5(_args: Array = []) -> Variant:
	return null

func java_method_saveChanges_6(_args: Array = []) -> Variant:
	return null

func java_method_savePreview_7(_args: Array = []) -> Variant:
	return null

func java_method_getPreview_8(_args: Array = []) -> Variant:
	return null

func java_method_hasPreview_9(_args: Array = []) -> Variant:
	return null

func java_method_getBuffer_10(_args: Array = []) -> Variant:
	return null

func java_method_toPlans_11(_args: Array = []) -> Variant:
	return null

func java_method_toPlans_12(_args: Array = []) -> Variant:
	return null

func java_method_getLoadouts_13(_args: Array = []) -> Variant:
	return null

func java_method_getLoadouts_14(_args: Array = []) -> Variant:
	return null

func java_method_getDefaultLoadout_15(_args: Array = []) -> Variant:
	return null

func java_method_isDefaultLoadout_16(_args: Array = []) -> Variant:
	return null

func java_method_checkLoadout_17(_args: Array = []) -> Variant:
	return null

func java_method_getMaxLaunchSize_18(_args: Array = []) -> Variant:
	return null

func java_method_findFile_19(_args: Array = []) -> Variant:
	return null

func java_method_add_20(_args: Array = []) -> Variant:
	return null

func java_method_remove_21(_args: Array = []) -> Variant:
	return null

func java_method_create_22(_args: Array = []) -> Variant:
	return null

func java_method_writeBase64_23(_args: Array = []) -> Variant:
	return null

func java_method_placeLaunchLoadout_24(_args: Array = []) -> Variant:
	return null

func java_method_placeLoadout_25(_args: Array = []) -> Variant:
	return null

func java_method_placeLoadout_26(_args: Array = []) -> Variant:
	return null

func java_method_placeLoadout_27(_args: Array = []) -> Variant:
	return null

func java_method_place_28(_args: Array = []) -> Variant:
	return null

func java_method_place_29(_args: Array = []) -> Variant:
	return null

func java_method_readBase64_30(_args: Array = []) -> Variant:
	return null

func java_method_read_31(_args: Array = []) -> Variant:
	return null

func java_method_read_32(_args: Array = []) -> Variant:
	return null

func java_method_write_33(_args: Array = []) -> Variant:
	return null

func java_method_write_34(_args: Array = []) -> Variant:
	return null

func java_method_mapConfig_35(_args: Array = []) -> Variant:
	return null

func java_method_rotate_36(_args: Array = []) -> Variant:
	return null

func java_method_rotated_37(_args: Array = []) -> Variant:
	return null
