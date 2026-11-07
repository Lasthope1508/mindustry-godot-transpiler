# Generated from Mindustry upstream.
# Source: annotations/src/main/java/mindustry/annotations/entity/EntityProcess.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.annotations.entity"
const JAVA_KIND := "class"
const JAVA_NAME := "EntityProcess"
const JAVA_EXTENDS := "BaseProcessor"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": [], "name": "definitions", "type": "Seq"}, {"modifiers": [], "name": "groupDefs", "type": "Seq"}, {"modifiers": [], "name": "baseComponents", "type": "Seq"}, {"modifiers": [], "name": "componentNames", "type": "ObjectMap"}, {"modifiers": [], "name": "componentDependencies", "type": "ObjectMap"}, {"modifiers": [], "name": "defComponents", "type": "ObjectMap"}, {"modifiers": [], "name": "varInitializers", "type": "ObjectMap"}, {"modifiers": [], "name": "methodBlocks", "type": "ObjectMap"}, {"modifiers": [], "name": "baseClassDeps", "type": "ObjectMap"}, {"modifiers": [], "name": "imports", "type": "ObjectSet"}, {"modifiers": [], "name": "allGroups", "type": "Seq"}, {"modifiers": [], "name": "allDefs", "type": "Seq"}, {"modifiers": [], "name": "allInterfaces", "type": "Seq"}, {"modifiers": [], "name": "baseClasses", "type": "Seq"}, {"modifiers": [], "name": "baseClassIndexers", "type": "ObjectSet"}, {"modifiers": [], "name": "serializer", "type": "ClassSerializer"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "process", "parameters": [{"name": "env", "type": "RoundEnvironment", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "getImports", "parameters": [{"name": "elem", "type": "Element", "varargs": false}], "return_type": "Seq"}, {"modifiers": [], "name": "interfaceName", "parameters": [{"name": "comp", "type": "Stype", "varargs": false}], "return_type": "String"}, {"modifiers": [], "name": "baseName", "parameters": [{"name": "comp", "type": "Stype", "varargs": false}], "return_type": "String"}, {"modifiers": [], "name": "interfaceToComp", "parameters": [{"name": "type", "type": "Stype", "varargs": false}], "return_type": "Stype"}, {"modifiers": [], "name": "allComponents", "parameters": [{"name": "type", "type": "Selement", "varargs": false}], "return_type": "Seq"}, {"modifiers": [], "name": "getDependencies", "parameters": [{"name": "component", "type": "Stype", "varargs": false}], "return_type": "Seq"}, {"modifiers": [], "name": "isCompInterface", "parameters": [{"name": "type", "type": "Stype", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "createName", "parameters": [{"name": "elem", "type": "Selement", "varargs": false}], "return_type": "String"}, {"modifiers": [], "name": "types", "parameters": [{"name": "t", "type": "T", "varargs": false}, {"name": "consumer", "type": "Cons", "varargs": false}], "return_type": "Seq"}, {"modifiers": [], "name": "skipDeprecated", "parameters": [{"name": "builder", "type": "TypeSpec", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_process_0(_args: Array = []) -> Variant:
	return null

func java_method_getImports_1(_args: Array = []) -> Variant:
	return null

func java_method_interfaceName_2(_args: Array = []) -> Variant:
	return null

func java_method_baseName_3(_args: Array = []) -> Variant:
	return null

func java_method_interfaceToComp_4(_args: Array = []) -> Variant:
	return null

func java_method_allComponents_5(_args: Array = []) -> Variant:
	return null

func java_method_getDependencies_6(_args: Array = []) -> Variant:
	return null

func java_method_isCompInterface_7(_args: Array = []) -> Variant:
	return null

func java_method_createName_8(_args: Array = []) -> Variant:
	return null

func java_method_types_9(_args: Array = []) -> Variant:
	return null

func java_method_skipDeprecated_10(_args: Array = []) -> Variant:
	return null
