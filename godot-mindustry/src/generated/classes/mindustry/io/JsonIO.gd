# Generated from Mindustry upstream.
# Source: mindustry/io/JsonIO.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.io"
const JAVA_KIND := "class"
const JAVA_NAME := "JsonIO"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "jsonBase", "type": "CustomJson"}, {"modifiers": ["final", "public", "static"], "name": "json", "type": "Json"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "writeBytes", "parameters": [{"name": "value", "type": "Object", "varargs": false}, {"name": "elementType", "type": "Class", "varargs": false}, {"name": "output", "type": "DataOutputStream", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readBytes", "parameters": [{"name": "type", "type": "Class", "varargs": false}, {"name": "elementType", "type": "Class", "varargs": false}, {"name": "input", "type": "DataInputStream", "varargs": false}], "return_type": "T"}, {"modifiers": ["public", "static"], "name": "write", "parameters": [{"name": "object", "type": "Object", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "copy", "parameters": [{"name": "object", "type": "T", "varargs": false}, {"name": "dest", "type": "T", "varargs": false}], "return_type": "T"}, {"modifiers": ["public", "static"], "name": "copy", "parameters": [{"name": "object", "type": "T", "varargs": false}], "return_type": "T"}, {"modifiers": ["public", "static"], "name": "read", "parameters": [{"name": "type", "type": "Class", "varargs": false}, {"name": "string", "type": "String", "varargs": false}], "return_type": "T"}, {"modifiers": ["public", "static"], "name": "read", "parameters": [{"name": "type", "type": "Class", "varargs": false}, {"name": "base", "type": "T", "varargs": false}, {"name": "string", "type": "String", "varargs": false}], "return_type": "T"}, {"modifiers": ["public", "static"], "name": "print", "parameters": [{"name": "in", "type": "String", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "classTag", "parameters": [{"name": "tag", "type": "String", "varargs": false}, {"name": "type", "type": "Class", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "apply", "parameters": [{"name": "json", "type": "Json", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_writeBytes_0(_args: Array = []) -> Variant:
	return null

func java_method_readBytes_1(_args: Array = []) -> Variant:
	return null

func java_method_write_2(_args: Array = []) -> Variant:
	return null

func java_method_copy_3(_args: Array = []) -> Variant:
	return null

func java_method_copy_4(_args: Array = []) -> Variant:
	return null

func java_method_read_5(_args: Array = []) -> Variant:
	return null

func java_method_read_6(_args: Array = []) -> Variant:
	return null

func java_method_print_7(_args: Array = []) -> Variant:
	return null

func java_method_classTag_8(_args: Array = []) -> Variant:
	return null

func java_method_apply_9(_args: Array = []) -> Variant:
	return null
