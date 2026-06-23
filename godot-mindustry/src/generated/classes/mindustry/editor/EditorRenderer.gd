# Generated from Mindustry upstream.
# Source: mindustry/editor/EditorRenderer.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "class"
const JAVA_NAME := "EditorRenderer"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Disposable"]
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "packPad", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "chunkSize", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "tmpTiles", "type": "Seq"}, {"modifiers": ["private"], "name": "chunks", "type": "EditorSpriteCache"}, {"modifiers": ["private"], "name": "recacheChunks", "type": "IntSet"}, {"modifiers": ["private"], "name": "width", "type": "int"}, {"modifiers": ["private"], "name": "height", "type": "int"}, {"modifiers": ["private"], "name": "packWidth", "type": "float"}, {"modifiers": ["private"], "name": "packHeight", "type": "float"}, {"modifiers": ["private"], "name": "shader", "type": "Shader"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "resize", "parameters": [{"name": "width", "type": "int", "varargs": false}, {"name": "height", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "tx", "type": "float", "varargs": false}, {"name": "ty", "type": "float", "varargs": false}, {"name": "tw", "type": "float", "varargs": false}, {"name": "th", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "updateStatic", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "updateBlock", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "updateBlock", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "recache", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "recacheTerrain", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "recacheShadows", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "recacheChunk", "parameters": [{"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "dispose", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
