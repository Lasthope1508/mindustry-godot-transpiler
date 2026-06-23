# Generated from Mindustry upstream.
# Source: mindustry/graphics/ParticleRenderer.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.graphics"
const JAVA_KIND := "class"
const JAVA_NAME := "ParticleRenderer"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "static"], "name": "useAsync", "type": "boolean"}, {"modifiers": ["final", "static"], "name": "maxParticles", "type": "int"}, {"modifiers": ["final", "static"], "name": "maxParticlesPerFrame", "type": "int"}, {"modifiers": ["final", "static"], "name": "particleSize", "type": "int"}, {"modifiers": ["final", "static"], "name": "particleVertexSize", "type": "int"}, {"modifiers": ["final", "static"], "name": "globalDrag", "type": "float"}, {"modifiers": ["final", "static"], "name": "cullPadding", "type": "float"}, {"modifiers": ["final", "static"], "name": "attributes", "type": "VertexAttribute"}, {"modifiers": ["static"], "name": "shader", "type": "Shader"}, {"modifiers": [], "name": "data", "type": "float"}, {"modifiers": ["volatile"], "name": "count", "type": "int"}, {"modifiers": [], "name": "addBuffer", "type": "float"}, {"modifiers": [], "name": "addCount", "type": "int"}, {"modifiers": [], "name": "mesh", "type": "Mesh"}, {"modifiers": [], "name": "vertexBuffer", "type": "float"}, {"modifiers": ["volatile"], "name": "vertexBufferLength", "type": "int"}, {"modifiers": [], "name": "asyncTask", "type": "Future"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "count", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "updateAndRender", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "updateAsync", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "render", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "lifetime", "type": "float", "varargs": false}, {"name": "vx", "type": "float", "varargs": false}, {"name": "vy", "type": "float", "varargs": false}, {"name": "sizeFrom", "type": "float", "varargs": false}, {"name": "sizeTo", "type": "float", "varargs": false}, {"name": "color", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "buildVertices", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "uploadMeshData", "parameters": [{"name": "mesh", "type": "Mesh", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "update", "parameters": [{"name": "data", "type": "float", "varargs": false}, {"name": "count", "type": "int", "varargs": false}, {"name": "delta", "type": "float", "varargs": false}], "return_type": "int"}, {"modifiers": ["static"], "name": "makeShader", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_count_0(_args: Array = []) -> Variant:
	return null

func java_method_updateAndRender_1(_args: Array = []) -> Variant:
	return null

func java_method_update_2(_args: Array = []) -> Variant:
	return null

func java_method_updateAsync_3(_args: Array = []) -> Variant:
	return null

func java_method_render_4(_args: Array = []) -> Variant:
	return null

func java_method_add_5(_args: Array = []) -> Variant:
	return null

func java_method_buildVertices_6(_args: Array = []) -> Variant:
	return null

func java_method_uploadMeshData_7(_args: Array = []) -> Variant:
	return null

func java_method_update_8(_args: Array = []) -> Variant:
	return null

func java_method_makeShader_9(_args: Array = []) -> Variant:
	return null
