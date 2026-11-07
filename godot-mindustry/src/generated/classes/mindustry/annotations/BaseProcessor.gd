# Generated from Mindustry upstream.
# Source: annotations/src/main/java/mindustry/annotations/BaseProcessor.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.annotations"
const JAVA_KIND := "class"
const JAVA_NAME := "BaseProcessor"
const JAVA_EXTENDS := "AbstractProcessor"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "packageName", "type": "String"}, {"modifiers": ["public", "static"], "name": "typeu", "type": "Types"}, {"modifiers": ["public", "static"], "name": "elementu", "type": "Elements"}, {"modifiers": ["public", "static"], "name": "filer", "type": "Filer"}, {"modifiers": ["public", "static"], "name": "messager", "type": "Messager"}, {"modifiers": ["public", "static"], "name": "trees", "type": "Trees"}, {"modifiers": ["protected"], "name": "round", "type": "int"}, {"modifiers": ["protected"], "name": "rounds", "type": "int"}, {"modifiers": ["protected"], "name": "env", "type": "RoundEnvironment"}, {"modifiers": ["protected"], "name": "rootDirectory", "type": "Fi"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "getMethodName", "parameters": [{"name": "element", "type": "Element", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "isPrimitive", "parameters": [{"name": "type", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "instanceOf", "parameters": [{"name": "type", "type": "String", "varargs": false}, {"name": "other", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "getDefault", "parameters": [{"name": "value", "type": "String", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "typeSize", "parameters": [{"name": "kind", "type": "String", "varargs": false}], "return_type": "int"}, {"modifiers": ["public", "static"], "name": "simpleName", "parameters": [{"name": "str", "type": "String", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "tname", "parameters": [{"name": "pack", "type": "String", "varargs": false}, {"name": "simple", "type": "String", "varargs": false}], "return_type": "TypeName"}, {"modifiers": ["public", "static"], "name": "tname", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "TypeName"}, {"modifiers": ["public", "static"], "name": "tname", "parameters": [{"name": "c", "type": "Class", "varargs": false}], "return_type": "TypeName"}, {"modifiers": ["public", "static"], "name": "getTVN", "parameters": [{"name": "element", "type": "TypeParameterElement", "varargs": false}], "return_type": "TypeVariableName"}, {"modifiers": ["public", "static"], "name": "write", "parameters": [{"name": "builder", "type": "TypeSpec", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "write", "parameters": [{"name": "builder", "type": "TypeSpec", "varargs": false}, {"name": "imports", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "elements", "parameters": [{"name": "type", "type": "Class", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "types", "parameters": [{"name": "type", "type": "Class", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "fields", "parameters": [{"name": "type", "type": "Class", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "methods", "parameters": [{"name": "type", "type": "Class", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public", "static"], "name": "err", "parameters": [{"name": "message", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "err", "parameters": [{"name": "message", "type": "String", "varargs": false}, {"name": "elem", "type": "Element", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "err", "parameters": [{"name": "message", "type": "String", "varargs": false}, {"name": "elem", "type": "Selement", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "synchronized"], "name": "init", "parameters": [{"name": "env", "type": "ProcessingEnvironment", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "process", "parameters": [{"name": "annotations", "type": "Set", "varargs": false}, {"name": "roundEnv", "type": "RoundEnvironment", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getSupportedSourceVersion", "parameters": [], "return_type": "SourceVersion"}, {"modifiers": ["public"], "name": "process", "parameters": [{"name": "env", "type": "RoundEnvironment", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getMethodName_0(_args: Array = []) -> Variant:
	return null

func java_method_isPrimitive_1(_args: Array = []) -> Variant:
	return null

func java_method_instanceOf_2(_args: Array = []) -> Variant:
	return null

func java_method_getDefault_3(_args: Array = []) -> Variant:
	return null

func java_method_typeSize_4(_args: Array = []) -> Variant:
	return null

func java_method_simpleName_5(_args: Array = []) -> Variant:
	return null

func java_method_tname_6(_args: Array = []) -> Variant:
	return null

func java_method_tname_7(_args: Array = []) -> Variant:
	return null

func java_method_tname_8(_args: Array = []) -> Variant:
	return null

func java_method_getTVN_9(_args: Array = []) -> Variant:
	return null

func java_method_write_10(_args: Array = []) -> Variant:
	return null

func java_method_write_11(_args: Array = []) -> Variant:
	return null

func java_method_elements_12(_args: Array = []) -> Variant:
	return null

func java_method_types_13(_args: Array = []) -> Variant:
	return null

func java_method_fields_14(_args: Array = []) -> Variant:
	return null

func java_method_methods_15(_args: Array = []) -> Variant:
	return null

func java_method_err_16(_args: Array = []) -> Variant:
	return null

func java_method_err_17(_args: Array = []) -> Variant:
	return null

func java_method_err_18(_args: Array = []) -> Variant:
	return null

func java_method_init_19(_args: Array = []) -> Variant:
	return null

func java_method_process_20(_args: Array = []) -> Variant:
	return null

func java_method_getSupportedSourceVersion_21(_args: Array = []) -> Variant:
	return null

func java_method_process_22(_args: Array = []) -> Variant:
	return null
