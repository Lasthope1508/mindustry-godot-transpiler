# Generated from Mindustry upstream.
# Source: annotations/src/main/java/mindustry/annotations/entity/EntityIO.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.annotations.entity"
const JAVA_KIND := "class"
const JAVA_NAME := "EntityIO"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "static"], "name": "json", "type": "Json"}, {"modifiers": ["final", "static"], "name": "targetSuf", "type": "String"}, {"modifiers": ["final", "static"], "name": "lastSuf", "type": "String"}, {"modifiers": ["final", "static"], "name": "replacements", "type": "StringMap"}, {"modifiers": ["final"], "name": "serializer", "type": "ClassSerializer"}, {"modifiers": ["final"], "name": "name", "type": "String"}, {"modifiers": ["final"], "name": "type", "type": "TypeSpec"}, {"modifiers": ["final"], "name": "directory", "type": "Fi"}, {"modifiers": ["final"], "name": "revisions", "type": "Seq"}, {"modifiers": [], "name": "write", "type": "boolean"}, {"modifiers": [], "name": "method", "type": "MethodSpec"}, {"modifiers": [], "name": "presentFields", "type": "ObjectSet"}]
const JAVA_CONSTRUCTORS := [{"modifiers": [], "name": "EntityIO", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "type", "type": "TypeSpec", "varargs": false}, {"name": "typeFields", "type": "Seq", "varargs": false}, {"name": "serializer", "type": "ClassSerializer", "varargs": false}, {"name": "directory", "type": "Fi", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": [], "name": "write", "parameters": [{"name": "method", "type": "MethodSpec", "varargs": false}, {"name": "write", "type": "boolean", "varargs": false}, {"name": "allFields", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "fieldHasAnno", "parameters": [{"name": "field", "type": "RevisionField", "varargs": false}, {"name": "allFields", "type": "Seq", "varargs": false}, {"name": "type", "type": "Class", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "writeSync", "parameters": [{"name": "method", "type": "MethodSpec", "varargs": false}, {"name": "write", "type": "boolean", "varargs": false}, {"name": "allFields", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "writeSyncManual", "parameters": [{"name": "method", "type": "MethodSpec", "varargs": false}, {"name": "write", "type": "boolean", "varargs": false}, {"name": "syncFields", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "writeInterpolate", "parameters": [{"name": "method", "type": "MethodSpec", "varargs": false}, {"name": "fields", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "io", "parameters": [{"name": "type", "type": "String", "varargs": false}, {"name": "field", "type": "String", "varargs": false}, {"name": "network", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "cont", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "fmt", "type": "Object", "varargs": true}], "return_type": ""}, {"modifiers": ["private"], "name": "econt", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "ncont", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "fmt", "type": "Object", "varargs": true}], "return_type": ""}, {"modifiers": ["private"], "name": "st", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "args", "type": "Object", "varargs": true}], "return_type": ""}, {"modifiers": ["private"], "name": "s", "parameters": [{"name": "type", "type": "String", "varargs": false}, {"name": "field", "type": "String", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_write_0(_args: Array = []) -> Variant:
	return null

func java_method_fieldHasAnno_1(_args: Array = []) -> Variant:
	return null

func java_method_writeSync_2(_args: Array = []) -> Variant:
	return null

func java_method_writeSyncManual_3(_args: Array = []) -> Variant:
	return null

func java_method_writeInterpolate_4(_args: Array = []) -> Variant:
	return null

func java_method_io_5(_args: Array = []) -> Variant:
	return null

func java_method_cont_6(_args: Array = []) -> Variant:
	return null

func java_method_econt_7(_args: Array = []) -> Variant:
	return null

func java_method_ncont_8(_args: Array = []) -> Variant:
	return null

func java_method_st_9(_args: Array = []) -> Variant:
	return null

func java_method_s_10(_args: Array = []) -> Variant:
	return null
