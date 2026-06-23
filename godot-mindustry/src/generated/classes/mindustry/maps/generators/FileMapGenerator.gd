# Generated from Mindustry upstream.
# Source: mindustry/maps/generators/FileMapGenerator.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.maps.generators"
const JAVA_KIND := "class"
const JAVA_NAME := "FileMapGenerator"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["WorldGenerator"]
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "map", "type": "Map"}, {"modifiers": ["final", "public"], "name": "preset", "type": "SectorPreset"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "FileMapGenerator", "parameters": [{"name": "mapName", "type": "String", "varargs": false}, {"name": "preset", "type": "SectorPreset", "varargs": false}]}, {"modifiers": ["public"], "name": "FileMapGenerator", "parameters": [{"name": "map", "type": "Map", "varargs": false}, {"name": "preset", "type": "SectorPreset", "varargs": false}]}, {"modifiers": ["public"], "name": "FileMapGenerator", "parameters": [{"name": "preset", "type": "SectorPreset", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "generate", "parameters": [{"name": "tiles", "type": "Tiles", "varargs": false}, {"name": "params", "type": "WorldParams", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_generate_0(_args: Array = []) -> Variant:
	return null
