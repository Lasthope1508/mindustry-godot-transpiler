# Generated from Mindustry upstream.
# Source: mindustry/entities/EntityGroup.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities"
const JAVA_KIND := "class"
const JAVA_NAME := "EntityGroup"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Iterable"]
const JAVA_FIELDS := [{"modifiers": ["private", "static"], "name": "lastId", "type": "int"}, {"modifiers": ["final", "private"], "name": "array", "type": "Seq"}, {"modifiers": ["final", "private"], "name": "intersectArray", "type": "Seq"}, {"modifiers": ["final", "private"], "name": "viewport", "type": "Rect"}, {"modifiers": ["final", "private"], "name": "intersectRect", "type": "Rect"}, {"modifiers": ["final", "private"], "name": "indexer", "type": "EntityIndexer"}, {"modifiers": ["private"], "name": "map", "type": "IntMap"}, {"modifiers": ["private"], "name": "tree", "type": "QuadTree"}, {"modifiers": ["private"], "name": "clearing", "type": "boolean"}, {"modifiers": ["private"], "name": "index", "type": "int"}, {"modifiers": ["private"], "name": "fixedCounter", "type": "double"}, {"modifiers": ["private"], "name": "timeCounter", "type": "double"}, {"modifiers": ["private"], "name": "lastTimeAccess", "type": "long"}, {"modifiers": ["private"], "name": "timeRuns", "type": "Seq"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "EntityGroup", "parameters": [{"name": "type", "type": "Class", "varargs": false}, {"name": "spatial", "type": "boolean", "varargs": false}, {"name": "mapping", "type": "boolean", "varargs": false}]}, {"modifiers": ["public"], "name": "EntityGroup", "parameters": [{"name": "type", "type": "Class", "varargs": false}, {"name": "spatial", "type": "boolean", "varargs": false}, {"name": "mapping", "type": "boolean", "varargs": false}, {"name": "indexer", "type": "EntityIndexer", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "nextId", "parameters": [], "return_type": "int"}, {"modifiers": ["public", "static"], "name": "checkNextId", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "checkIDCollisions", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "sort", "parameters": [{"name": "comp", "type": "Comparator", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "collide", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updatePhysics", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "fixedUpdate", "parameters": [{"name": "targetFps", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "fixedUpdate", "parameters": [{"name": "targetUps", "type": "int", "varargs": false}, {"name": "maxUpdatesPerFrame", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "copy", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "copy", "parameters": [{"name": "arr", "type": "Seq", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "each", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "each", "parameters": [{"name": "filter", "type": "Boolf", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "useTree", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "mappingEnabled", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getByID", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": "T"}, {"modifiers": ["public"], "name": "removeByID", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "intersect", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}, {"name": "out", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "intersect", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}, {"name": "out", "type": "Boolf", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "intersect", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "tree", "parameters": [], "return_type": "QuadTree"}, {"modifiers": ["public"], "name": "resize", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "w", "type": "float", "varargs": false}, {"name": "h", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isEmpty", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "index", "parameters": [{"name": "i", "type": "int", "varargs": false}], "return_type": "T"}, {"modifiers": ["public"], "name": "size", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "contains", "parameters": [{"name": "pred", "type": "Boolf", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "count", "parameters": [{"name": "pred", "type": "Boolf", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "type", "type": "T", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addIndex", "parameters": [{"name": "type", "type": "T", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "type", "type": "T", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "removeIndex", "parameters": [{"name": "type", "type": "T", "varargs": false}, {"name": "position", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "clear", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "find", "parameters": [{"name": "pred", "type": "Boolf", "varargs": false}], "return_type": "T"}, {"modifiers": ["public"], "name": "first", "parameters": [], "return_type": "T"}, {"modifiers": ["public"], "name": "iterator", "parameters": [], "return_type": "Iterator"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_nextId_0(_args: Array = []) -> Variant:
	return null

func java_method_checkNextId_1(_args: Array = []) -> Variant:
	return null

func java_method_checkIDCollisions_2(_args: Array = []) -> Variant:
	return null

func java_method_sort_3(_args: Array = []) -> Variant:
	return null

func java_method_collide_4(_args: Array = []) -> Variant:
	return null

func java_method_updatePhysics_5(_args: Array = []) -> Variant:
	return null

func java_method_update_6(_args: Array = []) -> Variant:
	return null

func java_method_fixedUpdate_7(_args: Array = []) -> Variant:
	return null

func java_method_fixedUpdate_8(_args: Array = []) -> Variant:
	return null

func java_method_copy_9(_args: Array = []) -> Variant:
	return null

func java_method_copy_10(_args: Array = []) -> Variant:
	return null

func java_method_each_11(_args: Array = []) -> Variant:
	return null

func java_method_each_12(_args: Array = []) -> Variant:
	return null

func java_method_draw_13(_args: Array = []) -> Variant:
	return null

func java_method_useTree_14(_args: Array = []) -> Variant:
	return null

func java_method_mappingEnabled_15(_args: Array = []) -> Variant:
	return null

func java_method_getByID_16(_args: Array = []) -> Variant:
	return null

func java_method_removeByID_17(_args: Array = []) -> Variant:
	return null

func java_method_intersect_18(_args: Array = []) -> Variant:
	return null

func java_method_intersect_19(_args: Array = []) -> Variant:
	return null

func java_method_intersect_20(_args: Array = []) -> Variant:
	return null

func java_method_tree_21(_args: Array = []) -> Variant:
	return null

func java_method_resize_22(_args: Array = []) -> Variant:
	return null

func java_method_isEmpty_23(_args: Array = []) -> Variant:
	return null

func java_method_index_24(_args: Array = []) -> Variant:
	return null

func java_method_size_25(_args: Array = []) -> Variant:
	return null

func java_method_contains_26(_args: Array = []) -> Variant:
	return null

func java_method_count_27(_args: Array = []) -> Variant:
	return null

func java_method_add_28(_args: Array = []) -> Variant:
	return null

func java_method_addIndex_29(_args: Array = []) -> Variant:
	return null

func java_method_remove_30(_args: Array = []) -> Variant:
	return null

func java_method_removeIndex_31(_args: Array = []) -> Variant:
	return null

func java_method_clear_32(_args: Array = []) -> Variant:
	return null

func java_method_find_33(_args: Array = []) -> Variant:
	return null

func java_method_first_34(_args: Array = []) -> Variant:
	return null

func java_method_iterator_35(_args: Array = []) -> Variant:
	return null
