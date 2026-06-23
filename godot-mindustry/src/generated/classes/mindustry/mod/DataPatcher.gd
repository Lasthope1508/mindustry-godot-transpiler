# Generated from Mindustry upstream.
# Source: mindustry/mod/DataPatcher.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.mod"
const JAVA_KIND := "class"
const JAVA_NAME := "DataPatcher"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "maxImageSize", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "patchFormatVersion", "type": "int"}, {"modifiers": ["private", "static"], "name": "needsArrayFix", "type": "boolean"}, {"modifiers": ["final", "private", "static"], "name": "root", "type": "Object"}, {"modifiers": ["final", "private", "static"], "name": "nameToType", "type": "ObjectMap"}, {"modifiers": ["private", "static"], "name": "currentDataPatcher", "type": "DataPatcher"}, {"modifiers": ["private", "static"], "name": "parser", "type": "ContentParser"}, {"modifiers": ["private", "static"], "name": "dpModMeta", "type": "ModMeta"}, {"modifiers": ["private", "static"], "name": "dpMod", "type": "LoadedMod"}, {"modifiers": ["private"], "name": "applied", "type": "boolean"}, {"modifiers": ["private"], "name": "contentLoader", "type": "ContentLoader"}, {"modifiers": ["private"], "name": "usedpatches", "type": "ObjectSet"}, {"modifiers": ["private"], "name": "resetters", "type": "Seq"}, {"modifiers": ["private"], "name": "afterCallbacks", "type": "Seq"}, {"modifiers": ["private"], "name": "visitStack", "type": "Seq"}, {"modifiers": ["private"], "name": "addedContent", "type": "Seq"}, {"modifiers": ["private"], "name": "currentlyApplyingPatch", "type": "PatchAsset"}, {"modifiers": ["private"], "name": "currentlyApplyingContent", "type": "ContentAsset"}, {"modifiers": ["private"], "name": "addedVars", "type": "Seq"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["static"], "name": "createParser", "parameters": [], "return_type": "ContentParser"}, {"modifiers": ["public"], "name": "isPatched", "parameters": [{"name": "object", "type": "Object", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "apply", "parameters": [{"name": "patches", "type": "Seq", "varargs": false}, {"name": "content", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "apply", "parameters": [{"name": "patches", "type": "Seq", "varargs": false}, {"name": "content", "type": "Seq", "varargs": false}, {"name": "reloadContentWorld", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "unapply", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "unapply", "parameters": [{"name": "reloadContentWorld", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getAddedContent", "parameters": [], "return_type": "Seq"}, {"modifiers": [], "name": "callContentRemove", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "fixContentArrays", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "visit", "parameters": [{"name": "object", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "created", "parameters": [{"name": "object", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "assign", "parameters": [{"name": "object", "type": "Object", "varargs": false}, {"name": "field", "type": "String", "varargs": false}, {"name": "value", "type": "Object", "varargs": false}, {"name": "metadata", "type": "FieldData", "varargs": false}, {"name": "parentObject", "type": "Object", "varargs": false}, {"name": "parentField", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "assignValue", "parameters": [{"name": "object", "type": "Object", "varargs": false}, {"name": "field", "type": "String", "varargs": false}, {"name": "metadata", "type": "FieldData", "varargs": false}, {"name": "getter", "type": "Prov", "varargs": false}, {"name": "setter", "type": "Cons", "varargs": false}, {"name": "value", "type": "Object", "varargs": false}, {"name": "modify", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "resolve", "parameters": [{"name": "object", "type": "Object", "varargs": false}, {"name": "field", "type": "String", "varargs": false}, {"name": "metadata", "type": "FieldData", "varargs": false}], "return_type": "Object"}, {"modifiers": [], "name": "checkField", "parameters": [{"name": "field", "type": "Field", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "modifiedField", "parameters": [{"name": "target", "type": "Object", "varargs": false}, {"name": "field", "type": "String", "varargs": false}, {"name": "value", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "reset", "parameters": [{"name": "run", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "convertKeyType", "parameters": [{"name": "string", "type": "String", "varargs": false}, {"name": "type", "type": "Class", "varargs": false}], "return_type": "Object"}, {"modifiers": [], "name": "warn", "parameters": [{"name": "error", "type": "String", "varargs": false}, {"name": "fmt", "type": "Object", "varargs": true}], "return_type": ""}, {"modifiers": [], "name": "warnContext", "parameters": [{"name": "currentContent", "type": "Content", "varargs": false}, {"name": "currentFile", "type": "Fi", "varargs": false}, {"name": "error", "type": "String", "varargs": false}, {"name": "fmt", "type": "Object", "varargs": true}], "return_type": ""}, {"modifiers": [], "name": "after", "parameters": [{"name": "run", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "copyArray", "parameters": [{"name": "object", "type": "Object", "varargs": false}], "return_type": "Object"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_createParser_0(_args: Array = []) -> Variant:
	return null

func java_method_isPatched_1(_args: Array = []) -> Variant:
	return null

func java_method_apply_2(_args: Array = []) -> Variant:
	return null

func java_method_apply_3(_args: Array = []) -> Variant:
	return null

func java_method_unapply_4(_args: Array = []) -> Variant:
	return null

func java_method_unapply_5(_args: Array = []) -> Variant:
	return null

func java_method_getAddedContent_6(_args: Array = []) -> Variant:
	return null

func java_method_callContentRemove_7(_args: Array = []) -> Variant:
	return null

func java_method_fixContentArrays_8(_args: Array = []) -> Variant:
	return null

func java_method_visit_9(_args: Array = []) -> Variant:
	return null

func java_method_created_10(_args: Array = []) -> Variant:
	return null

func java_method_assign_11(_args: Array = []) -> Variant:
	return null

func java_method_assignValue_12(_args: Array = []) -> Variant:
	return null

func java_method_resolve_13(_args: Array = []) -> Variant:
	return null

func java_method_checkField_14(_args: Array = []) -> Variant:
	return null

func java_method_modifiedField_15(_args: Array = []) -> Variant:
	return null

func java_method_reset_16(_args: Array = []) -> Variant:
	return null

func java_method_convertKeyType_17(_args: Array = []) -> Variant:
	return null

func java_method_warn_18(_args: Array = []) -> Variant:
	return null

func java_method_warnContext_19(_args: Array = []) -> Variant:
	return null

func java_method_after_20(_args: Array = []) -> Variant:
	return null

func java_method_copyArray_21(_args: Array = []) -> Variant:
	return null
