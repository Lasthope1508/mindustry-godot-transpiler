# Generated from Mindustry upstream.
# Source: mindustry/io/versions/LegacySaveVersion.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.io.versions"
const JAVA_KIND := "class"
const JAVA_NAME := "LegacySaveVersion"
const JAVA_EXTENDS := "LegacyRegionSaveVersion"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := []
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "LegacySaveVersion", "parameters": [{"name": "version", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "readMap", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}, {"name": "context", "type": "WorldContext", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "readLegacyEntities", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_readMap_0(_args: Array = []) -> Variant:
	return null

func java_method_readLegacyEntities_1(_args: Array = []) -> Variant:
	return null
