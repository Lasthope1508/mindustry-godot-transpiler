# Generated from Mindustry upstream.
# Source: mindustry/graphics/g3d/MeshBuilder.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.graphics.g3d"
const JAVA_KIND := "class"
const JAVA_NAME := "MeshBuilder"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "packNormals", "type": "boolean"}, {"modifiers": ["private", "static", "volatile"], "name": "tmpHeights", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "buildIcosphere", "parameters": [{"name": "divisions", "type": "int", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}], "return_type": "Mesh"}, {"modifiers": ["public", "static"], "name": "buildPlanetGrid", "parameters": [{"name": "grid", "type": "PlanetGrid", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "scale", "type": "float", "varargs": false}], "return_type": "Mesh"}, {"modifiers": ["public", "static"], "name": "buildHex", "parameters": [{"name": "color", "type": "Color", "varargs": false}, {"name": "divisions", "type": "int", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}], "return_type": "Mesh"}, {"modifiers": ["public", "static", "synchronized"], "name": "buildHex", "parameters": [{"name": "mesher", "type": "HexMesher", "varargs": false}, {"name": "divisions", "type": "int", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "intensity", "type": "float", "varargs": false}], "return_type": "Mesh"}, {"modifiers": ["private", "static"], "name": "begin", "parameters": [{"name": "vertices", "type": "int", "varargs": false}, {"name": "indices", "type": "int", "varargs": false}, {"name": "normal", "type": "boolean", "varargs": false}, {"name": "emissive", "type": "boolean", "varargs": false}], "return_type": "Mesh"}, {"modifiers": ["private", "static"], "name": "begin", "parameters": [{"name": "vertices", "type": "int", "varargs": false}, {"name": "indices", "type": "int", "varargs": false}, {"name": "normal", "type": "boolean", "varargs": false}, {"name": "emissive", "type": "boolean", "varargs": false}, {"name": "color", "type": "boolean", "varargs": false}], "return_type": "Mesh"}, {"modifiers": ["private", "static"], "name": "end", "parameters": [{"name": "mesh", "type": "Mesh", "varargs": false}], "return_type": "Mesh"}, {"modifiers": ["private", "static"], "name": "normal", "parameters": [{"name": "v1", "type": "Vec3", "varargs": false}, {"name": "v2", "type": "Vec3", "varargs": false}, {"name": "v3", "type": "Vec3", "varargs": false}, {"name": "out", "type": "Vec3", "varargs": false}], "return_type": "Vec3"}, {"modifiers": ["private", "static"], "name": "normal", "parameters": [{"name": "v1x", "type": "float", "varargs": false}, {"name": "v1y", "type": "float", "varargs": false}, {"name": "v1z", "type": "float", "varargs": false}, {"name": "v2x", "type": "float", "varargs": false}, {"name": "v2y", "type": "float", "varargs": false}, {"name": "v2z", "type": "float", "varargs": false}, {"name": "v3x", "type": "float", "varargs": false}, {"name": "v3y", "type": "float", "varargs": false}, {"name": "v3z", "type": "float", "varargs": false}, {"name": "out", "type": "Vec3", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "verts", "parameters": [{"name": "mesh", "type": "Mesh", "varargs": false}, {"name": "floats", "type": "float", "varargs": false}, {"name": "a", "type": "Vec3", "varargs": false}, {"name": "h1", "type": "float", "varargs": false}, {"name": "b", "type": "Vec3", "varargs": false}, {"name": "h2", "type": "float", "varargs": false}, {"name": "c", "type": "Vec3", "varargs": false}, {"name": "h3", "type": "float", "varargs": false}, {"name": "normal", "type": "Vec3", "varargs": false}, {"name": "color", "type": "float", "varargs": false}, {"name": "emissive", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "vert", "parameters": [{"name": "mesh", "type": "Mesh", "varargs": false}, {"name": "floats", "type": "float", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "z", "type": "float", "varargs": false}, {"name": "normal", "type": "Vec3", "varargs": false}, {"name": "color", "type": "float", "varargs": false}, {"name": "emissive", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "packNormals", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "z", "type": "float", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_buildIcosphere_0(_args: Array = []) -> Variant:
	return null

func java_method_buildPlanetGrid_1(_args: Array = []) -> Variant:
	return null

func java_method_buildHex_2(_args: Array = []) -> Variant:
	return null

func java_method_buildHex_3(_args: Array = []) -> Variant:
	return null

func java_method_begin_4(_args: Array = []) -> Variant:
	return null

func java_method_begin_5(_args: Array = []) -> Variant:
	return null

func java_method_end_6(_args: Array = []) -> Variant:
	return null

func java_method_normal_7(_args: Array = []) -> Variant:
	return null

func java_method_normal_8(_args: Array = []) -> Variant:
	return null

func java_method_verts_9(_args: Array = []) -> Variant:
	return null

func java_method_vert_10(_args: Array = []) -> Variant:
	return null

func java_method_packNormals_11(_args: Array = []) -> Variant:
	return null
