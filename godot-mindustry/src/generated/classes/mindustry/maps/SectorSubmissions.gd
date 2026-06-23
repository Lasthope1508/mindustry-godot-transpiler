# Generated from Mindustry upstream.
# Source: mindustry/maps/SectorSubmissions.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.maps"
const JAVA_KIND := "class"
const JAVA_NAME := "SectorSubmissions"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private", "static"], "name": "threadMap", "type": "ObjectMap"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "getSectorThread", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "registerSectors", "parameters": [], "return_type": ""}, {"modifiers": ["static"], "name": "registerSerpuloSector", "parameters": [{"name": "id", "type": "int", "varargs": false}, {"name": "author", "type": "String", "varargs": false}, {"name": "mapFileLink", "type": "String", "varargs": false}], "return_type": "SectorPreset"}, {"modifiers": ["static"], "name": "registerSerpuloSector", "parameters": [{"name": "id", "type": "int", "varargs": false}, {"name": "author", "type": "String", "varargs": false}, {"name": "mapFileLink", "type": "String", "varargs": false}, {"name": "captureWave", "type": "int", "varargs": false}, {"name": "difficulty", "type": "float", "varargs": false}], "return_type": "SectorPreset"}, {"modifiers": ["static"], "name": "registerThread", "parameters": [{"name": "id", "type": "int", "varargs": false}, {"name": "link", "type": "String", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getSectorThread_0(_args: Array = []) -> Variant:
	return null

func java_method_registerSectors_1(_args: Array = []) -> Variant:
	return null

func java_method_registerSerpuloSector_2(_args: Array = []) -> Variant:
	return null

func java_method_registerSerpuloSector_3(_args: Array = []) -> Variant:
	return null

func java_method_registerThread_4(_args: Array = []) -> Variant:
	return null
