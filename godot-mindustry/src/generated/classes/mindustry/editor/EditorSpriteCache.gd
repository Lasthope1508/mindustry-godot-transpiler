# Generated from Mindustry upstream.
# Source: mindustry/editor/EditorSpriteCache.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "class"
const JAVA_NAME := "EditorSpriteCache"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Disposable"]
const JAVA_FIELDS := [{"modifiers": ["final", "static"], "name": "vertexSize", "type": "int"}, {"modifiers": ["private"], "name": "mesh", "type": "Mesh"}, {"modifiers": ["final", "private"], "name": "textures", "type": "Seq"}, {"modifiers": ["final", "private"], "name": "counts", "type": "IntSeq"}, {"modifiers": ["final", "private"], "name": "packX", "type": "float"}, {"modifiers": ["final", "private"], "name": "packY", "type": "float"}, {"modifiers": ["final", "private"], "name": "packW", "type": "float"}, {"modifiers": ["final", "private"], "name": "packH", "type": "float"}, {"modifiers": ["private"], "name": "tmpVertices", "type": "float"}, {"modifiers": ["private"], "name": "index", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "EditorSpriteCache", "parameters": [{"name": "tmpVertices", "type": "float", "varargs": false}, {"name": "packX", "type": "float", "varargs": false}, {"name": "packY", "type": "float", "varargs": false}, {"name": "packW", "type": "float", "varargs": false}, {"name": "packH", "type": "float", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "isEmpty", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "indices", "type": "IndexData", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "originX", "type": "float", "varargs": false}, {"name": "originY", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "colorPacked", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "pack", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "render", "parameters": [{"name": "shader", "type": "Shader", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "dispose", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
