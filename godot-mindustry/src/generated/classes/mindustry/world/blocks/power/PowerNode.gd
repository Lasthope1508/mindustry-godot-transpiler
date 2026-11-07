# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/power/PowerNode.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.power"
const JAVA_KIND := "class"
const JAVA_NAME := "PowerNode"
const JAVA_EXTENDS := "PowerBlock"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["protected", "static"], "name": "returnInt", "type": "int"}, {"modifiers": ["final", "protected", "static"], "name": "graphs", "type": "ObjectSet"}, {"modifiers": ["protected", "static"], "name": "maxRange", "type": "float"}, {"modifiers": ["public"], "name": "laser", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserEnd", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserRange", "type": "float"}, {"modifiers": ["public"], "name": "maxNodes", "type": "int"}, {"modifiers": ["public"], "name": "autolink", "type": "boolean"}, {"modifiers": ["public"], "name": "drawRange", "type": "boolean"}, {"modifiers": ["public"], "name": "sameBlockConnection", "type": "boolean"}, {"modifiers": ["public"], "name": "laserScale", "type": "float"}, {"modifiers": ["public"], "name": "powerLayer", "type": "float"}, {"modifiers": ["public"], "name": "laserColor1", "type": "Color"}, {"modifiers": ["public"], "name": "laserColor2", "type": "Color"}, {"modifiers": ["private", "static"], "name": "currentFindX", "type": "int"}, {"modifiers": ["private", "static"], "name": "currentFindY", "type": "int"}, {"modifiers": ["private", "static"], "name": "currentPlan", "type": "BuildPlan"}, {"modifiers": ["final", "private", "static"], "name": "planFinder", "type": "Boolf"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PowerNode", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "makePowerBalance", "parameters": [], "return_type": "Func"}, {"modifiers": ["public", "static"], "name": "makeBatteryBalance", "parameters": [], "return_type": "Func"}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "changePlacementPath", "parameters": [{"name": "points", "type": "Seq", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "setupColor", "parameters": [{"name": "satisfaction", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawLaser", "parameters": [{"name": "x1", "type": "float", "varargs": false}, {"name": "y1", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}, {"name": "size1", "type": "int", "varargs": false}, {"name": "size2", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawLaser", "parameters": [{"name": "x1", "type": "float", "varargs": false}, {"name": "y1", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}, {"name": "size1", "type": "int", "varargs": false}, {"name": "size2", "type": "int", "varargs": false}, {"name": "light", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "overlaps", "parameters": [{"name": "srcx", "type": "float", "varargs": false}, {"name": "srcy", "type": "float", "varargs": false}, {"name": "other", "type": "Tile", "varargs": false}, {"name": "otherBlock", "type": "Block", "varargs": false}, {"name": "range", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["protected"], "name": "overlaps", "parameters": [{"name": "srcx", "type": "float", "varargs": false}, {"name": "srcy", "type": "float", "varargs": false}, {"name": "other", "type": "Tile", "varargs": false}, {"name": "range", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["protected"], "name": "overlaps", "parameters": [{"name": "src", "type": "Building", "varargs": false}, {"name": "other", "type": "Building", "varargs": false}, {"name": "range", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["protected"], "name": "overlaps", "parameters": [{"name": "src", "type": "Tile", "varargs": false}, {"name": "other", "type": "Tile", "varargs": false}, {"name": "range", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "overlaps", "parameters": [{"name": "src", "type": "Tile", "varargs": false}, {"name": "other", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["protected"], "name": "getPotentialLinks", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "others", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "getNodeLinks", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "others", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanConfigTop", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "planConfigClipSize", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "linkValid", "parameters": [{"name": "tile", "type": "Building", "varargs": false}, {"name": "link", "type": "Building", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "linkValid", "parameters": [{"name": "tile", "type": "Building", "varargs": false}, {"name": "link", "type": "Building", "varargs": false}, {"name": "checkMaxNodes", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "insulated", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "other", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "insulated", "parameters": [{"name": "tile", "type": "Building", "varargs": false}, {"name": "other", "type": "Building", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "insulated", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []
const source_power_node_state := preload("res://src/game/SourcePowerNodeState.gd")

func java_method_setBars_0(_args: Array = []) -> Variant:
	var bars_input: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	return source_power_node_state.set_bars_state(bars_input)

func java_method_makePowerBalance_1(_args: Array = []) -> Variant:
	var graph_input: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	return source_power_node_state.make_power_balance_state(graph_input)

func java_method_makeBatteryBalance_2(_args: Array = []) -> Variant:
	var graph_input: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	return source_power_node_state.make_battery_balance_state(graph_input)

func java_method_setStats_3(_args: Array = []) -> Variant:
	var laser_range: float = float(_args[0] if _args.size() > 0 else 0.0)
	var max_nodes: int = int(_args[1] if _args.size() > 1 else 0)
	var super_set_stats_state: Dictionary = _args[2] if _args.size() > 2 and _args[2] is Dictionary else {}
	return source_power_node_state.set_stats_state(laser_range, max_nodes, super_set_stats_state)

func java_method_init_4(_args: Array = []) -> Variant:
	var clip_size: float = float(_args[0] if _args.size() > 0 else 0.0)
	var laser_range: float = float(_args[1] if _args.size() > 1 else 0.0)
	var tilesize: float = float(_args[2] if _args.size() > 2 else 0.0)
	var super_init_state: Dictionary = _args[3] if _args.size() > 3 and _args[3] is Dictionary else {}
	return source_power_node_state.init_state(clip_size, laser_range, tilesize, super_init_state)

func java_method_drawPlace_5(_args: Array = []) -> Variant:
	var x: int = int(_args[0] if _args.size() > 0 else 0)
	var y: int = int(_args[1] if _args.size() > 1 else 0)
	var rotation: int = int(_args[2] if _args.size() > 2 else 0)
	var valid: bool = bool(_args[3] if _args.size() > 3 else false)
	var draw_input: Dictionary = _args[4] if _args.size() > 4 and _args[4] is Dictionary else {}
	return source_power_node_state.draw_place_state(x, y, rotation, valid, draw_input)

func java_method_changePlacementPath_6(_args: Array = []) -> Variant:
	var points: Variant = _args[0] if _args.size() > 0 else []
	var rotation: int = int(_args[1] if _args.size() > 1 else 0)
	var placement_result: Dictionary = _args[2] if _args.size() > 2 and _args[2] is Dictionary else {}
	return source_power_node_state.change_placement_path_state(points, rotation, placement_result)

func java_method_setupColor_7(_args: Array = []) -> Variant:
	var satisfaction: float = float(_args[0] if _args.size() > 0 else 0.0)
	var laser_opacity: float = float(_args[1] if _args.size() > 1 else 0.0)
	var lod_alpha2: float = float(_args[2] if _args.size() > 2 else 0.0)
	var absin_value: float = float(_args[3] if _args.size() > 3 else 0.0)
	return source_power_node_state.setup_color_state(satisfaction, laser_opacity, lod_alpha2, absin_value)

func java_method_drawLaser_8(_args: Array = []) -> Variant:
	var laser_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	return source_power_node_state.draw_laser_state(laser_state, true)

func java_method_drawLaser_9(_args: Array = []) -> Variant:
	var laser_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	var light: bool = bool(_args[1] if _args.size() > 1 else true)
	return source_power_node_state.draw_laser_state(laser_state, light)

func java_method_overlaps_10(_args: Array = []) -> Variant:
	var overlap_result: bool = bool(_args[0] if _args.size() > 0 else false)
	return source_power_node_state.overlaps_state(overlap_result, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_BLOCK_METHOD, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_BLOCK_EXPR)

func java_method_overlaps_11(_args: Array = []) -> Variant:
	var overlap_result: bool = bool(_args[0] if _args.size() > 0 else false)
	return source_power_node_state.overlaps_state(overlap_result, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_TILE_METHOD, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_TILE_EXPR)

func java_method_overlaps_12(_args: Array = []) -> Variant:
	var overlap_result: bool = bool(_args[0] if _args.size() > 0 else false)
	return source_power_node_state.overlaps_state(overlap_result, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_BUILDING_METHOD, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_BUILDING_EXPR)

func java_method_overlaps_13(_args: Array = []) -> Variant:
	var overlap_result: bool = bool(_args[0] if _args.size() > 0 else false)
	return source_power_node_state.overlaps_state(overlap_result, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_TILE_RANGE_METHOD, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_TILE_RANGE_EXPR)

func java_method_overlaps_14(_args: Array = []) -> Variant:
	var src_present: bool = bool(_args[0] if _args.size() > 0 else false)
	var other_present: bool = bool(_args[1] if _args.size() > 1 else false)
	var overlap_result: bool = bool(_args[2] if _args.size() > 2 else false)
	return source_power_node_state.overlaps_nullable_state(src_present, other_present, overlap_result)

func java_method_getPotentialLinks_15(_args: Array = []) -> Variant:
	var link_input: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	return source_power_node_state.get_potential_links_state(link_input)

func java_method_getNodeLinks_16(_args: Array = []) -> Variant:
	var link_input: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	return source_power_node_state.get_node_links_state(link_input)

func java_method_drawPlanConfigTop_17(_args: Array = []) -> Variant:
	var plan_input: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	return source_power_node_state.draw_plan_config_top_state(plan_input)

func java_method_planConfigClipSize_18(_args: Array = []) -> Variant:
	var laser_range: float = float(_args[0] if _args.size() > 0 else 0.0)
	var tilesize: float = float(_args[1] if _args.size() > 1 else 0.0)
	var size: float = float(_args[2] if _args.size() > 2 else 0.0)
	return source_power_node_state.plan_config_clip_size_state(laser_range, tilesize, size)

func java_method_linkValid_19(_args: Array = []) -> Variant:
	var link_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	var check_max_nodes: bool = true
	return source_power_node_state.link_valid_state(link_state, check_max_nodes)

func java_method_linkValid_20(_args: Array = []) -> Variant:
	var link_state: Dictionary = _args[0] if _args.size() > 0 and _args[0] is Dictionary else {}
	var check_max_nodes: bool = bool(_args[1] if _args.size() > 1 else true)
	return source_power_node_state.link_valid_state(link_state, check_max_nodes)

func java_method_insulated_21(_args: Array = []) -> Variant:
	var raycast_insulated: bool = bool(_args[0] if _args.size() > 0 else false)
	return source_power_node_state.insulated_state(raycast_insulated)

func java_method_insulated_22(_args: Array = []) -> Variant:
	var raycast_insulated: bool = bool(_args[0] if _args.size() > 0 else false)
	return source_power_node_state.insulated_state(raycast_insulated)

func java_method_insulated_23(_args: Array = []) -> Variant:
	var raycast_insulated: bool = bool(_args[0] if _args.size() > 0 else false)
	return source_power_node_state.insulated_state(raycast_insulated)
