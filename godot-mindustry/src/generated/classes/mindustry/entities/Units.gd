# Generated from Mindustry upstream.
# Source: mindustry/entities/Units.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities"
const JAVA_KIND := "class"
const JAVA_NAME := "Units"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "hitrect", "type": "Rect"}, {"modifiers": ["private", "static"], "name": "result", "type": "Unit"}, {"modifiers": ["private", "static"], "name": "cdist", "type": "float"}, {"modifiers": ["private", "static"], "name": "cpriority", "type": "float"}, {"modifiers": ["private", "static"], "name": "intResult", "type": "int"}, {"modifiers": ["private", "static"], "name": "buildResult", "type": "Building"}, {"modifiers": ["private", "static"], "name": "anyEntityGround", "type": "boolean"}, {"modifiers": ["private", "static"], "name": "aeX", "type": "float"}, {"modifiers": ["private", "static"], "name": "aeY", "type": "float"}, {"modifiers": ["private", "static"], "name": "aeW", "type": "float"}, {"modifiers": ["private", "static"], "name": "aeH", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "anyEntityLambda", "type": "Boolf"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "notifyUnitSpawn", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "unitSpawn", "parameters": [{"name": "container", "type": "UnitSyncContainer", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "unitCapDeath", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "unitEnvDeath", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "unitDeath", "parameters": [{"name": "uid", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "unitDestroy", "parameters": [{"name": "uid", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "unitDespawn", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "unitSafeDeath", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "canCreate", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "type", "type": "UnitType", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "getCap", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "int"}, {"modifiers": ["public", "static"], "name": "getStringCap", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "canInteract", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "tile", "type": "Building", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "isHittable", "parameters": [{"name": "target", "type": "Posc", "varargs": false}, {"name": "air", "type": "boolean", "varargs": false}, {"name": "ground", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "invalidateTarget", "parameters": [{"name": "target", "type": "Posc", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "invalidateTarget", "parameters": [{"name": "target", "type": "Posc", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "invalidateTarget", "parameters": [{"name": "target", "type": "Teamc", "varargs": false}, {"name": "targeter", "type": "Unit", "varargs": false}, {"name": "range", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "anyEntities", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "ground", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "anyEntities", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "anyEntities", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "size", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "anyEntities", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "anyEntities", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}, {"name": "ground", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "anyEntities", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}, {"name": "check", "type": "Boolf", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "findDamagedTile", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public", "static"], "name": "findAllyTile", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "pred", "type": "Boolf", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public", "static"], "name": "findEnemyTile", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "pred", "type": "Boolf", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public", "static"], "name": "closestBuilding", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "wx", "type": "float", "varargs": false}, {"name": "wy", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "pred", "type": "Boolf", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public", "static"], "name": "nearbyBuildings", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "closestTarget", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}], "return_type": "Teamc"}, {"modifiers": ["public", "static"], "name": "closestTarget", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "unitPred", "type": "Boolf", "varargs": false}], "return_type": "Teamc"}, {"modifiers": ["public", "static"], "name": "closestTarget", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "unitPred", "type": "Boolf", "varargs": false}, {"name": "tilePred", "type": "Boolf", "varargs": false}], "return_type": "Teamc"}, {"modifiers": ["public", "static"], "name": "closestTarget", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "sourceTeam", "type": "Team", "varargs": false}, {"name": "unitPred", "type": "Boolf", "varargs": false}, {"name": "tilePred", "type": "Boolf", "varargs": false}], "return_type": "Teamc"}, {"modifiers": ["public", "static"], "name": "bestTarget", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "unitPred", "type": "Boolf", "varargs": false}, {"name": "tilePred", "type": "Boolf", "varargs": false}, {"name": "sort", "type": "Sortf", "varargs": false}], "return_type": "Teamc"}, {"modifiers": ["public", "static"], "name": "closestEnemy", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "predicate", "type": "Boolf", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public", "static"], "name": "bestEnemy", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "predicate", "type": "Boolf", "varargs": false}, {"name": "sort", "type": "Sortf", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public", "static"], "name": "closest", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "predicate", "type": "Boolf", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public", "static"], "name": "closest", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "predicate", "type": "Boolf", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public", "static"], "name": "closest", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "predicate", "type": "Boolf", "varargs": false}, {"name": "sort", "type": "Sortf", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public", "static"], "name": "closestOverlap", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "predicate", "type": "Boolf", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public", "static"], "name": "count", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "size", "type": "float", "varargs": false}, {"name": "filter", "type": "Boolf", "varargs": false}], "return_type": "int"}, {"modifiers": ["public", "static"], "name": "count", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}, {"name": "filter", "type": "Boolf", "varargs": false}], "return_type": "int"}, {"modifiers": ["public", "static"], "name": "any", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}, {"name": "filter", "type": "Boolf", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "nearby", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "nearby", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "nearby", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "nearbyCheck", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}, {"name": "cons", "type": "Boolf", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "nearby", "parameters": [{"name": "rect", "type": "Rect", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "nearbyEnemies", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "nearbyEnemies", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "nearbyEnemies", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "rect", "type": "Rect", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "nearEnemy", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_notifyUnitSpawn_0(_args: Array = []) -> Variant:
	return null

func java_method_unitSpawn_1(_args: Array = []) -> Variant:
	return null

func java_method_unitCapDeath_2(_args: Array = []) -> Variant:
	return null

func java_method_unitEnvDeath_3(_args: Array = []) -> Variant:
	return null

func java_method_unitDeath_4(_args: Array = []) -> Variant:
	return null

func java_method_unitDestroy_5(_args: Array = []) -> Variant:
	return null

func java_method_unitDespawn_6(_args: Array = []) -> Variant:
	return null

func java_method_unitSafeDeath_7(_args: Array = []) -> Variant:
	return null

func java_method_canCreate_8(_args: Array = []) -> Variant:
	return null

func java_method_getCap_9(_args: Array = []) -> Variant:
	return null

func java_method_getStringCap_10(_args: Array = []) -> Variant:
	return null

func java_method_canInteract_11(_args: Array = []) -> Variant:
	return null

func java_method_isHittable_12(_args: Array = []) -> Variant:
	return null

func java_method_invalidateTarget_13(_args: Array = []) -> Variant:
	return null

func java_method_invalidateTarget_14(_args: Array = []) -> Variant:
	return null

func java_method_invalidateTarget_15(_args: Array = []) -> Variant:
	return null

func java_method_anyEntities_16(_args: Array = []) -> Variant:
	return null

func java_method_anyEntities_17(_args: Array = []) -> Variant:
	return null

func java_method_anyEntities_18(_args: Array = []) -> Variant:
	return null

func java_method_anyEntities_19(_args: Array = []) -> Variant:
	return null

func java_method_anyEntities_20(_args: Array = []) -> Variant:
	return null

func java_method_anyEntities_21(_args: Array = []) -> Variant:
	return null

func java_method_findDamagedTile_22(_args: Array = []) -> Variant:
	return null

func java_method_findAllyTile_23(_args: Array = []) -> Variant:
	return null

func java_method_findEnemyTile_24(_args: Array = []) -> Variant:
	return null

func java_method_closestBuilding_25(_args: Array = []) -> Variant:
	return null

func java_method_nearbyBuildings_26(_args: Array = []) -> Variant:
	return null

func java_method_closestTarget_27(_args: Array = []) -> Variant:
	return null

func java_method_closestTarget_28(_args: Array = []) -> Variant:
	return null

func java_method_closestTarget_29(_args: Array = []) -> Variant:
	return null

func java_method_closestTarget_30(_args: Array = []) -> Variant:
	return null

func java_method_bestTarget_31(_args: Array = []) -> Variant:
	return null

func java_method_closestEnemy_32(_args: Array = []) -> Variant:
	return null

func java_method_bestEnemy_33(_args: Array = []) -> Variant:
	return null

func java_method_closest_34(_args: Array = []) -> Variant:
	return null

func java_method_closest_35(_args: Array = []) -> Variant:
	return null

func java_method_closest_36(_args: Array = []) -> Variant:
	return null

func java_method_closestOverlap_37(_args: Array = []) -> Variant:
	return null

func java_method_count_38(_args: Array = []) -> Variant:
	return null

func java_method_count_39(_args: Array = []) -> Variant:
	return null

func java_method_any_40(_args: Array = []) -> Variant:
	return null

func java_method_nearby_41(_args: Array = []) -> Variant:
	return null

func java_method_nearby_42(_args: Array = []) -> Variant:
	return null

func java_method_nearby_43(_args: Array = []) -> Variant:
	return null

func java_method_nearbyCheck_44(_args: Array = []) -> Variant:
	return null

func java_method_nearby_45(_args: Array = []) -> Variant:
	return null

func java_method_nearbyEnemies_46(_args: Array = []) -> Variant:
	return null

func java_method_nearbyEnemies_47(_args: Array = []) -> Variant:
	return null

func java_method_nearbyEnemies_48(_args: Array = []) -> Variant:
	return null

func java_method_nearEnemy_49(_args: Array = []) -> Variant:
	return null
