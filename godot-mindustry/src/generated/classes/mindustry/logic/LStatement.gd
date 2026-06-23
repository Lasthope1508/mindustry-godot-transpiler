# Generated from Mindustry upstream.
# Source: mindustry/logic/LStatement.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.logic"
const JAVA_KIND := "class"
const JAVA_NAME := "LStatement"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "aligns", "type": "String"}, {"modifiers": ["final", "public", "static"], "name": "nameToAlign", "type": "ObjectMap"}, {"modifiers": ["final", "public", "static"], "name": "alignToName", "type": "IntMap"}, {"modifiers": ["public", "transient"], "name": "elem", "type": "StatementElem"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["abstract", "public"], "name": "build", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["abstract", "public"], "name": "build", "parameters": [{"name": "builder", "type": "LAssembler", "varargs": false}], "return_type": "LInstruction"}, {"modifiers": ["public"], "name": "category", "parameters": [], "return_type": "LCategory"}, {"modifiers": ["public"], "name": "copy", "parameters": [], "return_type": "LStatement"}, {"modifiers": ["public"], "name": "hidden", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "privileged", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "nonPrivileged", "parameters": [], "return_type": "boolean"}, {"modifiers": ["protected"], "name": "param", "parameters": [{"name": "label", "type": "Cell", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "sanitize", "parameters": [{"name": "value", "type": "String", "varargs": false}], "return_type": "String"}, {"modifiers": ["protected"], "name": "field", "parameters": [{"name": "table", "type": "Table", "varargs": false}, {"name": "value", "type": "String", "varargs": false}, {"name": "setter", "type": "Cons", "varargs": false}], "return_type": "Cell"}, {"modifiers": ["protected"], "name": "fields", "parameters": [{"name": "table", "type": "Table", "varargs": false}, {"name": "desc", "type": "String", "varargs": false}, {"name": "value", "type": "String", "varargs": false}, {"name": "setter", "type": "Cons", "varargs": false}], "return_type": "Cell"}, {"modifiers": ["protected"], "name": "fieldst", "parameters": [{"name": "table", "type": "Table", "varargs": false}, {"name": "desc", "type": "String", "varargs": false}, {"name": "value", "type": "String", "varargs": false}, {"name": "setter", "type": "Cons", "varargs": false}], "return_type": "Cell"}, {"modifiers": ["protected"], "name": "col", "parameters": [{"name": "table", "type": "Table", "varargs": false}, {"name": "value", "type": "String", "varargs": false}, {"name": "setter", "type": "Cons", "varargs": false}], "return_type": "Cell"}, {"modifiers": ["protected"], "name": "fields", "parameters": [{"name": "table", "type": "Table", "varargs": false}, {"name": "value", "type": "String", "varargs": false}, {"name": "setter", "type": "Cons", "varargs": false}], "return_type": "Cell"}, {"modifiers": ["protected"], "name": "row", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "showSelect", "parameters": [{"name": "b", "type": "Button", "varargs": false}, {"name": "values", "type": "T", "varargs": false}, {"name": "current", "type": "T", "varargs": false}, {"name": "getter", "type": "Cons", "varargs": false}, {"name": "cols", "type": "int", "varargs": false}, {"name": "sizer", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "showSelect", "parameters": [{"name": "b", "type": "Button", "varargs": false}, {"name": "values", "type": "T", "varargs": false}, {"name": "current", "type": "T", "varargs": false}, {"name": "getter", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "fieldAlignSelect", "parameters": [{"name": "t", "type": "Table", "varargs": false}, {"name": "get", "type": "Prov", "varargs": false}, {"name": "set", "type": "Cons", "varargs": false}, {"name": "hor", "type": "boolean", "varargs": false}, {"name": "ver", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "showAlignSelect", "parameters": [{"name": "b", "type": "Button", "varargs": false}, {"name": "current", "type": "int", "varargs": false}, {"name": "setter", "type": "Intc", "varargs": false}, {"name": "hor", "type": "boolean", "varargs": false}, {"name": "ver", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["protected", "static"], "name": "showSelectTable", "parameters": [{"name": "b", "type": "Button", "varargs": false}, {"name": "hideCons", "type": "Cons2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "afterRead", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "builder", "type": "StringBuilder", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setupUI", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "saveUI", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "typeName", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "name", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_build_0(_args: Array = []) -> Variant:
	return null

func java_method_build_1(_args: Array = []) -> Variant:
	return null

func java_method_category_2(_args: Array = []) -> Variant:
	return null

func java_method_copy_3(_args: Array = []) -> Variant:
	return null

func java_method_hidden_4(_args: Array = []) -> Variant:
	return null

func java_method_privileged_5(_args: Array = []) -> Variant:
	return null

func java_method_nonPrivileged_6(_args: Array = []) -> Variant:
	return null

func java_method_param_7(_args: Array = []) -> Variant:
	return null

func java_method_sanitize_8(_args: Array = []) -> Variant:
	return null

func java_method_field_9(_args: Array = []) -> Variant:
	return null

func java_method_fields_10(_args: Array = []) -> Variant:
	return null

func java_method_fieldst_11(_args: Array = []) -> Variant:
	return null

func java_method_col_12(_args: Array = []) -> Variant:
	return null

func java_method_fields_13(_args: Array = []) -> Variant:
	return null

func java_method_row_14(_args: Array = []) -> Variant:
	return null

func java_method_showSelect_15(_args: Array = []) -> Variant:
	return null

func java_method_showSelect_16(_args: Array = []) -> Variant:
	return null

func java_method_fieldAlignSelect_17(_args: Array = []) -> Variant:
	return null

func java_method_showAlignSelect_18(_args: Array = []) -> Variant:
	return null

func java_method_showSelectTable_19(_args: Array = []) -> Variant:
	return null

func java_method_afterRead_20(_args: Array = []) -> Variant:
	return null

func java_method_write_21(_args: Array = []) -> Variant:
	return null

func java_method_setupUI_22(_args: Array = []) -> Variant:
	return null

func java_method_saveUI_23(_args: Array = []) -> Variant:
	return null

func java_method_typeName_24(_args: Array = []) -> Variant:
	return null

func java_method_name_25(_args: Array = []) -> Variant:
	return null
