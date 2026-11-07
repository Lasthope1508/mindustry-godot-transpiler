# Generated from Mindustry upstream.
# Source: annotations/src/main/java/mindustry/annotations/util/AnnotationProxyMaker.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.annotations.util"
const JAVA_KIND := "class"
const JAVA_NAME := "AnnotationProxyMaker"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private"], "name": "anno", "type": "Compound"}, {"modifiers": ["final", "private"], "name": "annoType", "type": "Class"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["private"], "name": "AnnotationProxyMaker", "parameters": [{"name": "var1", "type": "Compound", "varargs": false}, {"name": "var2", "type": "Class", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "generateAnnotation", "parameters": [{"name": "var0", "type": "Compound", "varargs": false}, {"name": "var1", "type": "Class", "varargs": false}], "return_type": "A"}, {"modifiers": ["private"], "name": "generateAnnotation", "parameters": [], "return_type": "Annotation"}, {"modifiers": ["private"], "name": "getAllReflectedValues", "parameters": [], "return_type": "Map"}, {"modifiers": ["private"], "name": "getAllValues", "parameters": [], "return_type": "Map"}, {"modifiers": ["private"], "name": "generateValue", "parameters": [{"name": "var1", "type": "MethodSymbol", "varargs": false}, {"name": "var2", "type": "Attribute", "varargs": false}], "return_type": "Object"}, {"modifiers": ["private", "static"], "name": "mirrorProxy", "parameters": [{"name": "t", "type": "Type", "varargs": false}], "return_type": "Object"}, {"modifiers": ["private", "static"], "name": "mirrorProxy", "parameters": [{"name": "t", "type": "List", "varargs": false}], "return_type": "Object"}, {"modifiers": ["private", "static"], "name": "proxify", "parameters": [{"name": "prov", "type": "Prov", "varargs": false}], "return_type": "Object"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_generateAnnotation_0(_args: Array = []) -> Variant:
	return null

func java_method_generateAnnotation_1(_args: Array = []) -> Variant:
	return null

func java_method_getAllReflectedValues_2(_args: Array = []) -> Variant:
	return null

func java_method_getAllValues_3(_args: Array = []) -> Variant:
	return null

func java_method_generateValue_4(_args: Array = []) -> Variant:
	return null

func java_method_mirrorProxy_5(_args: Array = []) -> Variant:
	return null

func java_method_mirrorProxy_6(_args: Array = []) -> Variant:
	return null

func java_method_proxify_7(_args: Array = []) -> Variant:
	return null
