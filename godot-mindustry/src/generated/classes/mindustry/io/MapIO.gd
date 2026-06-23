# Generated from Mindustry upstream.
# Source: mindustry/io/MapIO.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.io"
const JAVA_KIND := "class"
const JAVA_NAME := "MapIO"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "pngHeader", "type": "int"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "isImage", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "createMap", "parameters": [{"name": "file", "type": "Fi", "varargs": false}, {"name": "custom", "type": "boolean", "varargs": false}], "return_type": "Map"}, {"modifiers": ["public", "static"], "name": "writeMap", "parameters": [{"name": "file", "type": "Fi", "varargs": false}, {"name": "map", "type": "Map", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "writeMap", "parameters": [{"name": "file", "type": "Fi", "varargs": false}, {"name": "map", "type": "Map", "varargs": false}, {"name": "embed", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "loadMap", "parameters": [{"name": "map", "type": "Map", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "loadMap", "parameters": [{"name": "map", "type": "Map", "varargs": false}, {"name": "cons", "type": "WorldContext", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "generatePreview", "parameters": [{"name": "map", "type": "Map", "varargs": false}], "return_type": "Pixmap"}, {"modifiers": ["public", "static"], "name": "generatePreview", "parameters": [{"name": "tiles", "type": "Tiles", "varargs": false}], "return_type": "Pixmap"}, {"modifiers": ["public", "static"], "name": "colorFor", "parameters": [{"name": "wall", "type": "Block", "varargs": false}, {"name": "floor", "type": "Block", "varargs": false}, {"name": "overlay", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}], "return_type": "int"}, {"modifiers": ["public", "static"], "name": "writeImage", "parameters": [{"name": "tiles", "type": "Tiles", "varargs": false}], "return_type": "Pixmap"}, {"modifiers": ["public", "static"], "name": "readImage", "parameters": [{"name": "pixmap", "type": "Pixmap", "varargs": false}, {"name": "tiles", "type": "Tiles", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
