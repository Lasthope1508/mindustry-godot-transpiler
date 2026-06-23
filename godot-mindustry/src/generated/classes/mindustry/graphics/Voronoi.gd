# Generated from Mindustry upstream.
# Source: mindustry/graphics/Voronoi.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.graphics"
const JAVA_KIND := "class"
const JAVA_NAME := "Voronoi"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "LE", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "RE", "type": "int"}, {"modifiers": [], "name": "siteidx", "type": "int"}, {"modifiers": [], "name": "sites", "type": "Site"}, {"modifiers": [], "name": "nsites", "type": "int"}, {"modifiers": [], "name": "borderMinX", "type": "float"}, {"modifiers": [], "name": "borderMaxX", "type": "float"}, {"modifiers": [], "name": "borderMinY", "type": "float"}, {"modifiers": [], "name": "borderMaxY", "type": "float"}, {"modifiers": [], "name": "ymin", "type": "float"}, {"modifiers": [], "name": "deltay", "type": "float"}, {"modifiers": [], "name": "nvertices", "type": "int"}, {"modifiers": [], "name": "nedges", "type": "int"}, {"modifiers": [], "name": "bottomsite", "type": "Site"}, {"modifiers": [], "name": "PQcount", "type": "int"}, {"modifiers": [], "name": "PQmin", "type": "int"}, {"modifiers": [], "name": "PQhashsize", "type": "int"}, {"modifiers": [], "name": "PQhash", "type": "Halfedge"}, {"modifiers": [], "name": "ELhashsize", "type": "int"}, {"modifiers": [], "name": "ELhash", "type": "Halfedge"}, {"modifiers": [], "name": "allEdges", "type": "Seq"}, {"modifiers": [], "name": "minDistanceBetweenSites", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "generate", "parameters": [{"name": "values", "type": "Vec2", "varargs": false}, {"name": "minX", "type": "float", "varargs": false}, {"name": "maxX", "type": "float", "varargs": false}, {"name": "minY", "type": "float", "varargs": false}, {"name": "maxY", "type": "float", "varargs": false}], "return_type": "Seq"}, {"modifiers": [], "name": "generateVoronoi", "parameters": [{"name": "values", "type": "Vec2", "varargs": false}, {"name": "minX", "type": "float", "varargs": false}, {"name": "maxX", "type": "float", "varargs": false}, {"name": "minY", "type": "float", "varargs": false}, {"name": "maxY", "type": "float", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["private"], "name": "next", "parameters": [], "return_type": "Site"}, {"modifiers": ["private"], "name": "bisect", "parameters": [{"name": "s1", "type": "Site", "varargs": false}, {"name": "s2", "type": "Site", "varargs": false}], "return_type": "Edge"}, {"modifiers": ["private"], "name": "pqbucket", "parameters": [{"name": "he", "type": "Halfedge", "varargs": false}], "return_type": "int"}, {"modifiers": ["private"], "name": "pqinsert", "parameters": [{"name": "he", "type": "Halfedge", "varargs": false}, {"name": "v", "type": "Site", "varargs": false}, {"name": "offset", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "pqdelete", "parameters": [{"name": "he", "type": "Halfedge", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "newHe", "parameters": [{"name": "e", "type": "Edge", "varargs": false}, {"name": "pm", "type": "int", "varargs": false}], "return_type": "Halfedge"}, {"modifiers": ["private"], "name": "leftReg", "parameters": [{"name": "he", "type": "Halfedge", "varargs": false}], "return_type": "Site"}, {"modifiers": ["private"], "name": "insert", "parameters": [{"name": "lb", "type": "Halfedge", "varargs": false}, {"name": "newHe", "type": "Halfedge", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "delete", "parameters": [{"name": "he", "type": "Halfedge", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "getHash", "parameters": [{"name": "b", "type": "int", "varargs": false}], "return_type": "Halfedge"}, {"modifiers": ["private"], "name": "clipLine", "parameters": [{"name": "e", "type": "Edge", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "endpoint", "parameters": [{"name": "e", "type": "Edge", "varargs": false}, {"name": "lr", "type": "int", "varargs": false}, {"name": "s", "type": "Site", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "right", "parameters": [{"name": "el", "type": "Halfedge", "varargs": false}, {"name": "p", "type": "Vec2", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private"], "name": "rightreg", "parameters": [{"name": "he", "type": "Halfedge", "varargs": false}], "return_type": "Site"}, {"modifiers": ["private"], "name": "intersect", "parameters": [{"name": "el1", "type": "Halfedge", "varargs": false}, {"name": "el2", "type": "Halfedge", "varargs": false}], "return_type": "Site"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_generate_0(_args: Array = []) -> Variant:
	return null

func java_method_generateVoronoi_1(_args: Array = []) -> Variant:
	return null

func java_method_next_2(_args: Array = []) -> Variant:
	return null

func java_method_bisect_3(_args: Array = []) -> Variant:
	return null

func java_method_pqbucket_4(_args: Array = []) -> Variant:
	return null

func java_method_pqinsert_5(_args: Array = []) -> Variant:
	return null

func java_method_pqdelete_6(_args: Array = []) -> Variant:
	return null

func java_method_newHe_7(_args: Array = []) -> Variant:
	return null

func java_method_leftReg_8(_args: Array = []) -> Variant:
	return null

func java_method_insert_9(_args: Array = []) -> Variant:
	return null

func java_method_delete_10(_args: Array = []) -> Variant:
	return null

func java_method_getHash_11(_args: Array = []) -> Variant:
	return null

func java_method_clipLine_12(_args: Array = []) -> Variant:
	return null

func java_method_endpoint_13(_args: Array = []) -> Variant:
	return null

func java_method_right_14(_args: Array = []) -> Variant:
	return null

func java_method_rightreg_15(_args: Array = []) -> Variant:
	return null

func java_method_intersect_16(_args: Array = []) -> Variant:
	return null
