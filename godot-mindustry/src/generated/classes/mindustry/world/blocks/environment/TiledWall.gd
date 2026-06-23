# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/environment/TiledWall.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.environment"
const JAVA_KIND := "class"
const JAVA_NAME := "TiledWall"
const JAVA_EXTENDS := "StaticWall"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "sizedRegions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "maxSize", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "TiledWall", "parameters": [{"name": "name", "type": "String", "varargs": false}]}, {"modifiers": ["public"], "name": "TiledWall", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "variants", "type": "int", "varargs": false}, {"name": "maxSize", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "state", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "long"}, {"modifiers": ["public"], "name": "blockChanged", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "scan", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBase", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
