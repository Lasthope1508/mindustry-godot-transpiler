# Generated from Mindustry upstream.
# Source: mindustry/world/Edges.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world"
const JAVA_KIND := "class"
const JAVA_NAME := "Edges"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "maxRadius", "type": "int"}, {"modifiers": ["private", "static"], "name": "edges", "type": "Point2"}, {"modifiers": ["private", "static"], "name": "edgeInside", "type": "Point2"}, {"modifiers": ["private", "static"], "name": "polygons", "type": "Vec2"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "getFacingEdge", "parameters": [{"name": "tile", "type": "Building", "varargs": false}, {"name": "other", "type": "Building", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public", "static"], "name": "getFacingEdge", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "other", "type": "Tile", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public", "static"], "name": "getFacingEdge", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "tilex", "type": "int", "varargs": false}, {"name": "tiley", "type": "int", "varargs": false}, {"name": "other", "type": "Tile", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public", "static"], "name": "getPixelPolygon", "parameters": [{"name": "radius", "type": "float", "varargs": false}], "return_type": "Vec2"}, {"modifiers": ["public", "static"], "name": "getEdges", "parameters": [{"name": "size", "type": "int", "varargs": false}], "return_type": "Point2"}, {"modifiers": ["public", "static"], "name": "getInsideEdges", "parameters": [{"name": "size", "type": "int", "varargs": false}], "return_type": "Point2"}]
const JAVA_ENUM_CONSTANTS := []
