# Generated from Mindustry upstream.
# Source: mindustry/ai/ControlPathfinder.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ai"
const JAVA_KIND := "class"
const JAVA_NAME := "ControlPathfinder"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Runnable"]
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "wallImpassableCap", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "solidCap", "type": "int"}, {"modifiers": ["private", "static"], "name": "initialized", "type": "boolean"}, {"modifiers": ["public", "static"], "name": "showDebug", "type": "boolean"}, {"modifiers": ["final", "public", "static"], "name": "costGround", "type": "PathCost"}, {"modifiers": ["final", "public", "static"], "name": "costHover", "type": "PathCost"}, {"modifiers": ["final", "public", "static"], "name": "costLegs", "type": "PathCost"}, {"modifiers": ["final", "public", "static"], "name": "costNaval", "type": "PathCost"}, {"modifiers": ["final", "public", "static"], "name": "costIdGround", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "costIdHover", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "costIdLegs", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "costIdNaval", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "costTypes", "type": "Seq"}, {"modifiers": ["final", "private", "static"], "name": "maxUpdate", "type": "long"}, {"modifiers": ["final", "private", "static"], "name": "updateStepInterval", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "updateFPS", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "updateInterval", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "invalidateCheckInterval", "type": "int"}, {"modifiers": ["final", "static"], "name": "clusterSize", "type": "int"}, {"modifiers": ["final", "static"], "name": "offsets", "type": "int"}, {"modifiers": ["final", "static"], "name": "moveDirs", "type": "int"}, {"modifiers": ["final", "static"], "name": "nextOffsets", "type": "int"}, {"modifiers": ["final"], "name": "clusters", "type": "Cluster"}, {"modifiers": ["final"], "name": "cwidth", "type": "int"}, {"modifiers": ["final"], "name": "cheight", "type": "int"}, {"modifiers": ["final"], "name": "usedEdges", "type": "IntSet"}, {"modifiers": ["final"], "name": "queue", "type": "TaskQueue"}, {"modifiers": ["final"], "name": "unitRequests", "type": "ObjectMap"}, {"modifiers": ["final"], "name": "threadPathRequests", "type": "Seq"}, {"modifiers": ["final"], "name": "fields", "type": "LongMap"}, {"modifiers": ["final"], "name": "fieldList", "type": "Seq"}, {"modifiers": ["final"], "name": "innerCosts", "type": "IntFloatMap"}, {"modifiers": ["final"], "name": "innerFrontier", "type": "PathfindQueue"}, {"modifiers": ["final"], "name": "clustersToUpdate", "type": "IntSet"}, {"modifiers": ["final"], "name": "clustersToInnerUpdate", "type": "IntSet"}, {"modifiers": ["final"], "name": "invalidRequests", "type": "ObjectSet"}, {"modifiers": [], "name": "thread", "type": "Thread"}, {"modifiers": ["volatile"], "name": "invalidated", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ControlPathfinder", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["static"], "name": "checkEvents", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateTile", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateSingleTile", "parameters": [{"name": "t", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "queueClusterUpdate", "parameters": [{"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "portalToVec", "parameters": [{"name": "cluster", "type": "Cluster", "varargs": false}, {"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}, {"name": "direction", "type": "int", "varargs": false}, {"name": "portalIndex", "type": "int", "varargs": false}, {"name": "out", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "start", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "stop", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "getCluster", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "pathCost", "type": "int", "varargs": false}, {"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}], "return_type": "Cluster"}, {"modifiers": [], "name": "getCluster", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "pathCost", "type": "int", "varargs": false}, {"name": "clusterIndex", "type": "int", "varargs": false}], "return_type": "Cluster"}, {"modifiers": [], "name": "getCreateCluster", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "pathCost", "type": "int", "varargs": false}, {"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}], "return_type": "Cluster"}, {"modifiers": [], "name": "getCreateCluster", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "pathCost", "type": "int", "varargs": false}, {"name": "clusterIndex", "type": "int", "varargs": false}], "return_type": "Cluster"}, {"modifiers": [], "name": "updateCluster", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "pathCost", "type": "int", "varargs": false}, {"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}], "return_type": "Cluster"}, {"modifiers": [], "name": "updateInnerEdges", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "cost", "type": "int", "varargs": false}, {"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}, {"name": "cluster", "type": "Cluster", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "updateInnerEdges", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "cost", "type": "PathCost", "varargs": false}, {"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}, {"name": "cluster", "type": "Cluster", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "heuristic", "parameters": [{"name": "a", "type": "int", "varargs": false}, {"name": "b", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": ["private", "static"], "name": "tcost", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "cost", "type": "PathCost", "varargs": false}, {"name": "tilePos", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["private", "static"], "name": "tileCost", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "type", "type": "PathCost", "varargs": false}, {"name": "a", "type": "int", "varargs": false}, {"name": "b", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": [], "name": "innerAstar", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "cost", "type": "PathCost", "varargs": false}, {"name": "minX", "type": "int", "varargs": false}, {"name": "minY", "type": "int", "varargs": false}, {"name": "maxX", "type": "int", "varargs": false}, {"name": "maxY", "type": "int", "varargs": false}, {"name": "startPos", "type": "int", "varargs": false}, {"name": "goalPos", "type": "int", "varargs": false}, {"name": "goalX1", "type": "int", "varargs": false}, {"name": "goalY1", "type": "int", "varargs": false}, {"name": "goalX2", "type": "int", "varargs": false}, {"name": "goalY2", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": [], "name": "makeNodeIndex", "parameters": [{"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}, {"name": "dir", "type": "int", "varargs": false}, {"name": "portal", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["private"], "name": "findClosestNode", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "pathCost", "type": "int", "varargs": false}, {"name": "tileX", "type": "int", "varargs": false}, {"name": "tileY", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["private"], "name": "clusterNodeHeuristic", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "pathCost", "type": "int", "varargs": false}, {"name": "nodeA", "type": "int", "varargs": false}, {"name": "nodeB", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": [], "name": "clusterAstar", "parameters": [{"name": "request", "type": "PathRequest", "varargs": false}, {"name": "pathCost", "type": "int", "varargs": false}, {"name": "startNodeIndex", "type": "int", "varargs": false}, {"name": "endNodeIndex", "type": "int", "varargs": false}], "return_type": "IntSeq"}, {"modifiers": ["private"], "name": "checkEdges", "parameters": [{"name": "request", "type": "PathRequest", "varargs": false}, {"name": "team", "type": "int", "varargs": false}, {"name": "pathCost", "type": "int", "varargs": false}, {"name": "current", "type": "int", "varargs": false}, {"name": "goal", "type": "int", "varargs": false}, {"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}, {"name": "connections", "type": "LongSeq", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "updateFields", "parameters": [{"name": "cache", "type": "FieldCache", "varargs": false}, {"name": "nsToRun", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "addFlowCluster", "parameters": [{"name": "cache", "type": "FieldCache", "varargs": false}, {"name": "cluster", "type": "int", "varargs": false}, {"name": "addingFrontier", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "addFlowCluster", "parameters": [{"name": "cache", "type": "FieldCache", "varargs": false}, {"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}, {"name": "addingFrontier", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "initializePathRequest", "parameters": [{"name": "request", "type": "PathRequest", "varargs": false}, {"name": "team", "type": "int", "varargs": false}, {"name": "costId", "type": "int", "varargs": false}, {"name": "unitX", "type": "int", "varargs": false}, {"name": "unitY", "type": "int", "varargs": false}, {"name": "goalX", "type": "int", "varargs": false}, {"name": "goalY", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "idToCost", "parameters": [{"name": "costId", "type": "int", "varargs": false}], "return_type": "PathCost"}, {"modifiers": ["public", "static"], "name": "isNearObstacle", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getPathPosition", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "destination", "type": "Vec2", "varargs": false}, {"name": "out", "type": "Vec2", "varargs": false}, {"name": "noResultFound", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getPathPosition", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "destination", "type": "Vec2", "varargs": false}, {"name": "mainDestination", "type": "Vec2", "varargs": false}, {"name": "out", "type": "Vec2", "varargs": false}, {"name": "noResultFound", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private"], "name": "recalculatePath", "parameters": [{"name": "request", "type": "PathRequest", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "getCost", "parameters": [{"name": "cache", "type": "FieldCache", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "requeue", "type": "boolean", "varargs": false}], "return_type": "int"}, {"modifiers": ["private", "static"], "name": "raycast", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "type", "type": "PathCost", "varargs": false}, {"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "raycastFast", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "type", "type": "PathCost", "varargs": false}, {"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["public", "static"], "name": "raycastFastAvoid", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "type", "type": "PathCost", "varargs": false}, {"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["private", "static"], "name": "overlap", "parameters": [{"name": "initialCost", "type": "int", "varargs": false}, {"name": "team", "type": "int", "varargs": false}, {"name": "type", "type": "PathCost", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "startX", "type": "float", "varargs": false}, {"name": "startY", "type": "float", "varargs": false}, {"name": "endX", "type": "float", "varargs": false}, {"name": "endY", "type": "float", "varargs": false}, {"name": "rectSize", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private", "static"], "name": "raycastRect", "parameters": [{"name": "initialCost", "type": "int", "varargs": false}, {"name": "startX", "type": "float", "varargs": false}, {"name": "startY", "type": "float", "varargs": false}, {"name": "endX", "type": "float", "varargs": false}, {"name": "endY", "type": "float", "varargs": false}, {"name": "team", "type": "int", "varargs": false}, {"name": "type", "type": "PathCost", "varargs": false}, {"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}, {"name": "rectSize", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private", "static"], "name": "avoid", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "type", "type": "PathCost", "varargs": false}, {"name": "tilePos", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private", "static"], "name": "passable", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "cost", "type": "PathCost", "varargs": false}, {"name": "pos", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private", "static"], "name": "nearPassable", "parameters": [{"name": "initialCost", "type": "int", "varargs": false}, {"name": "team", "type": "int", "varargs": false}, {"name": "cost", "type": "PathCost", "varargs": false}, {"name": "pos", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private", "static"], "name": "solid", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "type", "type": "PathCost", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private", "static"], "name": "solid", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "type", "type": "PathCost", "varargs": false}, {"name": "tilePos", "type": "int", "varargs": false}, {"name": "checkWall", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private", "static"], "name": "cost", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "cost", "type": "PathCost", "varargs": false}, {"name": "tilePos", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["private"], "name": "clusterChanged", "parameters": [{"name": "team", "type": "int", "varargs": false}, {"name": "pathCost", "type": "int", "varargs": false}, {"name": "cx", "type": "int", "varargs": false}, {"name": "cy", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "updateClustersComplete", "parameters": [{"name": "clusterIndex", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "updateClustersInner", "parameters": [{"name": "clusterIndex", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "run", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_checkEvents_0(_args: Array = []) -> Variant:
	return null

func java_method_updateTile_1(_args: Array = []) -> Variant:
	return null

func java_method_updateSingleTile_2(_args: Array = []) -> Variant:
	return null

func java_method_queueClusterUpdate_3(_args: Array = []) -> Variant:
	return null

func java_method_portalToVec_4(_args: Array = []) -> Variant:
	return null

func java_method_start_5(_args: Array = []) -> Variant:
	return null

func java_method_stop_6(_args: Array = []) -> Variant:
	return null

func java_method_getCluster_7(_args: Array = []) -> Variant:
	return null

func java_method_getCluster_8(_args: Array = []) -> Variant:
	return null

func java_method_getCreateCluster_9(_args: Array = []) -> Variant:
	return null

func java_method_getCreateCluster_10(_args: Array = []) -> Variant:
	return null

func java_method_updateCluster_11(_args: Array = []) -> Variant:
	return null

func java_method_updateInnerEdges_12(_args: Array = []) -> Variant:
	return null

func java_method_updateInnerEdges_13(_args: Array = []) -> Variant:
	return null

func java_method_heuristic_14(_args: Array = []) -> Variant:
	return null

func java_method_tcost_15(_args: Array = []) -> Variant:
	return null

func java_method_tileCost_16(_args: Array = []) -> Variant:
	return null

func java_method_innerAstar_17(_args: Array = []) -> Variant:
	return null

func java_method_makeNodeIndex_18(_args: Array = []) -> Variant:
	return null

func java_method_findClosestNode_19(_args: Array = []) -> Variant:
	return null

func java_method_clusterNodeHeuristic_20(_args: Array = []) -> Variant:
	return null

func java_method_clusterAstar_21(_args: Array = []) -> Variant:
	return null

func java_method_checkEdges_22(_args: Array = []) -> Variant:
	return null

func java_method_updateFields_23(_args: Array = []) -> Variant:
	return null

func java_method_addFlowCluster_24(_args: Array = []) -> Variant:
	return null

func java_method_addFlowCluster_25(_args: Array = []) -> Variant:
	return null

func java_method_initializePathRequest_26(_args: Array = []) -> Variant:
	return null

func java_method_idToCost_27(_args: Array = []) -> Variant:
	return null

func java_method_isNearObstacle_28(_args: Array = []) -> Variant:
	return null

func java_method_getPathPosition_29(_args: Array = []) -> Variant:
	return null

func java_method_getPathPosition_30(_args: Array = []) -> Variant:
	return null

func java_method_recalculatePath_31(_args: Array = []) -> Variant:
	return null

func java_method_getCost_32(_args: Array = []) -> Variant:
	return null

func java_method_raycast_33(_args: Array = []) -> Variant:
	return null

func java_method_raycastFast_34(_args: Array = []) -> Variant:
	return null

func java_method_raycastFastAvoid_35(_args: Array = []) -> Variant:
	return null

func java_method_overlap_36(_args: Array = []) -> Variant:
	return null

func java_method_raycastRect_37(_args: Array = []) -> Variant:
	return null

func java_method_avoid_38(_args: Array = []) -> Variant:
	return null

func java_method_passable_39(_args: Array = []) -> Variant:
	return null

func java_method_nearPassable_40(_args: Array = []) -> Variant:
	return null

func java_method_solid_41(_args: Array = []) -> Variant:
	return null

func java_method_solid_42(_args: Array = []) -> Variant:
	return null

func java_method_cost_43(_args: Array = []) -> Variant:
	return null

func java_method_clusterChanged_44(_args: Array = []) -> Variant:
	return null

func java_method_updateClustersComplete_45(_args: Array = []) -> Variant:
	return null

func java_method_updateClustersInner_46(_args: Array = []) -> Variant:
	return null

func java_method_run_47(_args: Array = []) -> Variant:
	return null
