# Generated from Mindustry upstream.
# Source: mindustry/ai/BlockIndexer.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ai"
const JAVA_KIND := "class"
const JAVA_NAME := "BlockIndexer"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "quadrantSize", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "rect", "type": "Rect"}, {"modifiers": ["private", "static"], "name": "returnBool", "type": "boolean"}, {"modifiers": ["private"], "name": "quadWidth", "type": "int"}, {"modifiers": ["private"], "name": "quadHeight", "type": "int"}, {"modifiers": ["private"], "name": "ores", "type": "IntSeq"}, {"modifiers": ["private"], "name": "wallOres", "type": "IntSeq"}, {"modifiers": ["private"], "name": "damagedTiles", "type": "Seq"}, {"modifiers": ["private"], "name": "allPresentOres", "type": "Seq"}, {"modifiers": ["private"], "name": "allOres", "type": "ObjectIntMap"}, {"modifiers": ["private"], "name": "allWallOres", "type": "ObjectIntMap"}, {"modifiers": ["private"], "name": "activeTeams", "type": "Seq"}, {"modifiers": ["private"], "name": "flagMap", "type": "Seq"}, {"modifiers": ["private"], "name": "blocksPresent", "type": "boolean"}, {"modifiers": ["private"], "name": "breturnArray", "type": "Seq"}, {"modifiers": ["private"], "name": "floorMap", "type": "Seq"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BlockIndexer", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getAllPresentOres", "parameters": [], "return_type": "Seq"}, {"modifiers": ["private"], "name": "updatePresentOres", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "removeFloorIndex", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "floor", "type": "Floor", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "addFloorIndex", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "floor", "type": "Floor", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getFlaggedFloors", "parameters": [{"name": "flag", "type": "BlockFlag", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "removeIndex", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addIndex", "parameters": [{"name": "base", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isBlockPresent", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private"], "name": "clearFlags", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "getFlagged", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "hasOre", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "hasWallOre", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getDamaged", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getFlagged", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "type", "type": "BlockFlag", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "findClosestFlag", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "flag", "type": "BlockFlag", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public"], "name": "eachBlock", "parameters": [{"name": "team", "type": "Teamc", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "pred", "type": "Boolf", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "eachBlock", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "wx", "type": "float", "varargs": false}, {"name": "wy", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "pred", "type": "Boolf", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "eachBlock", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "rect", "type": "Rect", "varargs": false}, {"name": "pred", "type": "Boolf", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getEnemy", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "type", "type": "BlockFlag", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "notifyHealthChanged", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "allBuildings", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "findEnemyTile", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "priority", "type": "BuildingPriorityf", "varargs": false}, {"name": "pred", "type": "Boolf", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public"], "name": "findEnemyTile", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "priority", "type": "BuildingPriorityf", "varargs": false}, {"name": "pred", "type": "Boolf", "varargs": false}, {"name": "source", "type": "Team", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public"], "name": "findEnemyTile", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "pred", "type": "Boolf", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public"], "name": "findTile", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "pred", "type": "Boolf", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public"], "name": "findTile", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "pred", "type": "Boolf", "varargs": false}, {"name": "usePriority", "type": "boolean", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public"], "name": "findTile", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "pred", "type": "Boolf", "varargs": false}, {"name": "usePriority", "type": "boolean", "varargs": false}, {"name": "source", "type": "Team", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public"], "name": "findClosestOre", "parameters": [{"name": "xp", "type": "float", "varargs": false}, {"name": "yp", "type": "float", "varargs": false}, {"name": "item", "type": "Item", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "findClosestWallOre", "parameters": [{"name": "xp", "type": "float", "varargs": false}, {"name": "yp", "type": "float", "varargs": false}, {"name": "item", "type": "Item", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "findClosestOre", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "item", "type": "Item", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "findClosestWallOre", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "item", "type": "Item", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["private"], "name": "process", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getAllPresentOres_0(_args: Array = []) -> Variant:
	return null

func java_method_updatePresentOres_1(_args: Array = []) -> Variant:
	return null

func java_method_removeFloorIndex_2(_args: Array = []) -> Variant:
	return null

func java_method_addFloorIndex_3(_args: Array = []) -> Variant:
	return null

func java_method_getFlaggedFloors_4(_args: Array = []) -> Variant:
	return null

func java_method_removeIndex_5(_args: Array = []) -> Variant:
	return null

func java_method_addIndex_6(_args: Array = []) -> Variant:
	return null

func java_method_isBlockPresent_7(_args: Array = []) -> Variant:
	return null

func java_method_clearFlags_8(_args: Array = []) -> Variant:
	return null

func java_method_getFlagged_9(_args: Array = []) -> Variant:
	return null

func java_method_hasOre_10(_args: Array = []) -> Variant:
	return null

func java_method_hasWallOre_11(_args: Array = []) -> Variant:
	return null

func java_method_getDamaged_12(_args: Array = []) -> Variant:
	return null

func java_method_getFlagged_13(_args: Array = []) -> Variant:
	return null

func java_method_findClosestFlag_14(_args: Array = []) -> Variant:
	return null

func java_method_eachBlock_15(_args: Array = []) -> Variant:
	return null

func java_method_eachBlock_16(_args: Array = []) -> Variant:
	return null

func java_method_eachBlock_17(_args: Array = []) -> Variant:
	return null

func java_method_getEnemy_18(_args: Array = []) -> Variant:
	return null

func java_method_notifyHealthChanged_19(_args: Array = []) -> Variant:
	return null

func java_method_allBuildings_20(_args: Array = []) -> Variant:
	return null

func java_method_findEnemyTile_21(_args: Array = []) -> Variant:
	return null

func java_method_findEnemyTile_22(_args: Array = []) -> Variant:
	return null

func java_method_findEnemyTile_23(_args: Array = []) -> Variant:
	return null

func java_method_findTile_24(_args: Array = []) -> Variant:
	return null

func java_method_findTile_25(_args: Array = []) -> Variant:
	return null

func java_method_findTile_26(_args: Array = []) -> Variant:
	return null

func java_method_findClosestOre_27(_args: Array = []) -> Variant:
	return null

func java_method_findClosestWallOre_28(_args: Array = []) -> Variant:
	return null

func java_method_findClosestOre_29(_args: Array = []) -> Variant:
	return null

func java_method_findClosestWallOre_30(_args: Array = []) -> Variant:
	return null

func java_method_process_31(_args: Array = []) -> Variant:
	return null
