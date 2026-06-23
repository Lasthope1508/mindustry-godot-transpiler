# Generated from Mindustry upstream.
# Source: mindustry/editor/MapObjectivesDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "class"
const JAVA_NAME := "MapObjectivesDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "canvas", "type": "MapObjectivesCanvas"}, {"modifiers": ["protected"], "name": "out", "type": "Cons"}, {"modifiers": ["final", "private", "static"], "name": "providers", "type": "ObjectMap"}, {"modifiers": ["final", "private", "static"], "name": "interpreters", "type": "ObjectMap"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "MapObjectivesDialog", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "defaultInterpreter", "parameters": [], "return_type": "FieldInterpreter"}, {"modifiers": ["public", "static"], "name": "name", "parameters": [{"name": "cont", "type": "Table", "varargs": false}, {"name": "name", "type": "CharSequence", "varargs": false}, {"name": "remover", "type": "Runnable", "varargs": false}, {"name": "indexer", "type": "Boolc", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "show", "parameters": [{"name": "objectives", "type": "Seq", "varargs": false}, {"name": "out", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "rebuildObjectives", "parameters": [{"name": "objectives", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "showContentSelect", "parameters": [{"name": "type", "type": "ContentType", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}, {"name": "check", "type": "Boolf", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "showTeamSelect", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "showTeamSelect", "parameters": [{"name": "allowNull", "type": "boolean", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "unbox", "parameters": [{"name": "boxed", "type": "Class", "varargs": false}], "return_type": "Class"}, {"modifiers": ["public", "static"], "name": "setInterpreter", "parameters": [{"name": "type", "type": "Class", "varargs": false}, {"name": "interpreter", "type": "FieldInterpreter", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setInterpreter", "parameters": [{"name": "anno", "type": "Class", "varargs": false}, {"name": "type", "type": "Class", "varargs": false}, {"name": "interpreter", "type": "FieldInterpreter", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "hasInterpreter", "parameters": [{"name": "type", "type": "Class", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "hasInterpreter", "parameters": [{"name": "anno", "type": "Class", "varargs": false}, {"name": "type", "type": "Class", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "getInterpreter", "parameters": [{"name": "type", "type": "Class", "varargs": false}], "return_type": "FieldInterpreter"}, {"modifiers": ["public", "static"], "name": "getInterpreter", "parameters": [{"name": "anno", "type": "Class", "varargs": false}, {"name": "type", "type": "Class", "varargs": false}], "return_type": "FieldInterpreter"}, {"modifiers": ["public", "static"], "name": "setProvider", "parameters": [{"name": "type", "type": "Class", "varargs": false}, {"name": "provider", "type": "FieldProvider", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "hasProvider", "parameters": [{"name": "type", "type": "Class", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "getProvider", "parameters": [{"name": "type", "type": "Class", "varargs": false}], "return_type": "FieldProvider"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_defaultInterpreter_0(_args: Array = []) -> Variant:
	return null

func java_method_name_1(_args: Array = []) -> Variant:
	return null

func java_method_show_2(_args: Array = []) -> Variant:
	return null

func java_method_rebuildObjectives_3(_args: Array = []) -> Variant:
	return null

func java_method_showContentSelect_4(_args: Array = []) -> Variant:
	return null

func java_method_showTeamSelect_5(_args: Array = []) -> Variant:
	return null

func java_method_showTeamSelect_6(_args: Array = []) -> Variant:
	return null

func java_method_unbox_7(_args: Array = []) -> Variant:
	return null

func java_method_setInterpreter_8(_args: Array = []) -> Variant:
	return null

func java_method_setInterpreter_9(_args: Array = []) -> Variant:
	return null

func java_method_hasInterpreter_10(_args: Array = []) -> Variant:
	return null

func java_method_hasInterpreter_11(_args: Array = []) -> Variant:
	return null

func java_method_getInterpreter_12(_args: Array = []) -> Variant:
	return null

func java_method_getInterpreter_13(_args: Array = []) -> Variant:
	return null

func java_method_setProvider_14(_args: Array = []) -> Variant:
	return null

func java_method_hasProvider_15(_args: Array = []) -> Variant:
	return null

func java_method_getProvider_16(_args: Array = []) -> Variant:
	return null
