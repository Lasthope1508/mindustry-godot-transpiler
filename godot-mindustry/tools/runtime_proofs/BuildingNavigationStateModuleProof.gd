extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_navigation_state := preload("res://src/game/SourceBuildingNavigationState.gd")
const source_block_plan_geometry_state := preload("res://src/game/SourceBlockPlanGeometryState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var builds := {Vector2i(11, 20): "east", Vector2i(12, 20): "front-edge", Vector2i(8, 20): "back-edge", Vector2i(10, 22): "left-edge", Vector2i(10, 18): "right-edge"}
	var world_build_lookup := func(x: int, y: int) -> Variant: return builds.get(Vector2i(x, y), null)
	var nearby_delta: Variant = game.source_building_nearby_delta_state(10, 20, 1, 0, world_build_lookup)
	var nearby_rotation: Variant = game.source_building_nearby_rotation_state(10, 20, 0, world_build_lookup)
	var relative_tile := game.source_building_relative_to_tile_state(10, 20, 2, 12, 20)
	var relative_building := game.source_building_relative_to_building_state(10.0, 20.0, 8.0, 20.0)
	var relative_edge := game.source_building_relative_to_edge_state(10, 20, 1, 14, 20, 4)
	var relative_coordinates := game.source_building_relative_to_coordinates_state(10, 20, 2, 10, 23)
	var front: Variant = game.source_building_front_state(10, 20, 3, 0, world_build_lookup)
	var back: Variant = game.source_building_back_state(10, 20, 3, 0, world_build_lookup)
	var left: Variant = game.source_building_left_state(10, 20, 3, 0, world_build_lookup)
	var right: Variant = game.source_building_right_state(10, 20, 3, 0, world_build_lookup)
	var generated_nearby_delta := game.generated_building_comp_nearby_delta_bridge_state(10, 20, 1, 0, world_build_lookup)
	var generated_nearby_rotation := game.generated_building_comp_nearby_rotation_bridge_state(10, 20, 0, world_build_lookup)
	var generated_relative_tile := game.generated_building_comp_relative_to_tile_bridge_state(10, 20, 2, 12, 20)
	var generated_relative_building := game.generated_building_comp_relative_to_building_bridge_state(10.0, 20.0, 8.0, 20.0)
	var generated_relative_edge := game.generated_building_comp_relative_to_edge_bridge_state(10, 20, 1, 14, 20, 4)
	var generated_relative_coordinates := game.generated_building_comp_relative_to_coordinates_bridge_state(10, 20, 2, 10, 23)
	var generated_front := game.generated_building_comp_front_bridge_state(10, 20, 3, 0, world_build_lookup)
	var generated_back := game.generated_building_comp_back_bridge_state(10, 20, 3, 0, world_build_lookup)
	var generated_left := game.generated_building_comp_left_bridge_state(10, 20, 3, 0, world_build_lookup)
	var generated_right := game.generated_building_comp_right_bridge_state(10, 20, 3, 0, world_build_lookup)
	var edge_tiles := {
		Vector2i(9, 18): {"id": "solid", "x": 9, "y": 18},
		Vector2i(10, 18): {"id": "nearest", "x": 10, "y": 18},
		Vector2i(11, 18): {"id": "far", "x": 11, "y": 18},
	}
	var world_tile_lookup := func(x: int, y: int) -> Variant: return edge_tiles.get(Vector2i(x, y), null)
	var solid_lookup := func(tile_value: Variant) -> bool: return tile_value is Dictionary and tile_value.get("id", "") == "solid"
	var find_closest_edge_null: Variant = game.source_building_find_closest_edge_state(null, 10, 20, 3, world_tile_lookup, solid_lookup)
	var find_closest_edge: Variant = game.source_building_find_closest_edge_state(Vector2(10, 18), 10, 20, 3, world_tile_lookup, solid_lookup)
	var generated_find_closest_edge := game.generated_building_comp_find_closest_edge_bridge_state(Vector2(10, 18), 10, 20, 3, world_tile_lookup, solid_lookup)
	var edge_offsets := func(_size: int) -> Array: return [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]
	var each_edge_tiles := {Vector2i(11, 20): {"id": "east"}, Vector2i(10, 21): {"id": "south"}, Vector2i(9, 20): {"id": "west"}}
	var each_edge_lookup := func(x: int, y: int) -> Variant: return each_edge_tiles.get(Vector2i(x, y), null)
	var callback_tiles: Array = []
	var each_edge_callback := func(tile: Variant) -> void: callback_tiles.append(tile)
	var each_edge: Dictionary = game.source_building_each_edge_state(10, 20, 2, edge_offsets, each_edge_lookup, each_edge_callback)
	var generated_callback_tiles: Array = []
	var generated_each_edge_callback := func(tile: Variant) -> void: generated_callback_tiles.append(tile)
	var generated_each_edge := game.generated_building_comp_each_edge_bridge_state(10, 20, 2, edge_offsets, each_edge_lookup, generated_each_edge_callback)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var single_edges := source_block_plan_geometry_state.edge_points_state(1)
	var even_edges := source_block_plan_geometry_state.edge_points_state(2)
	var expected_single_edges := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]
	var expected_even_edges := [Vector2i(2, 0), Vector2i(2, 1), Vector2i(1, 2), Vector2i(0, 2), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, -1)]
	var tied_lookup := func(x: int, y: int) -> Variant: return {"x": x, "y": y}
	var never_solid := func(_tile: Variant) -> bool: return false
	var tied_edge: Variant = game.source_building_find_closest_edge_state(Vector2.ZERO, 0, 0, 1, tied_lookup, never_solid)
	var generated_tied_edge := game.generated_building_comp_find_closest_edge_bridge_state(Vector2.ZERO, 0, 0, 1, tied_lookup, never_solid)
	var proof := {
		"module": "SourceBuildingNavigationState",
		"edge_order_odd": single_edges == expected_single_edges,
		"edge_order_even": even_edges == expected_even_edges,
		"closest_edge_tie": tied_edge == {"x": 1, "y": 0},
		"generated_closest_edge_tie": generated_tied_edge.get("result") == {"x": 1, "y": 0},
		"nearby_delta": nearby_delta == "east",
		"nearby_rotation": nearby_rotation == "east",
		"relative_to_tile": relative_tile == 0,
		"relative_to_building": relative_building == 2,
		"relative_to_edge": relative_edge == 0,
		"relative_to_coordinates": relative_coordinates == 1,
		"front_back": front == "front-edge" and back == "back-edge",
		"left_right": left == "left-edge" and right == "right-edge",
		"find_closest_edge_null": find_closest_edge_null == null,
		"find_closest_edge": find_closest_edge is Dictionary and find_closest_edge.get("id", "") == "nearest",
		"generated_find_closest_edge": bool(generated_find_closest_edge.get("matches", false)),
		"each_edge": each_edge.get("visited_tiles", []).size() == 3 and each_edge.get("callback_count", 0) == 3 and callback_tiles.size() == 3,
		"generated_each_edge": bool(generated_each_edge.get("matches", false)) and generated_each_edge.get("result", {}).get("callback_count", 0) == 3,
		"generated_nearby": bool(generated_nearby_delta.get("matches", false)) and bool(generated_nearby_rotation.get("matches", false)),
		"generated_relative": bool(generated_relative_tile.get("matches", false)) and bool(generated_relative_building.get("matches", false)) and bool(generated_relative_edge.get("matches", false)) and bool(generated_relative_coordinates.get("matches", false)),
		"generated_multiblock": bool(generated_front.get("matches", false)) and bool(generated_back.get("matches", false)) and bool(generated_left.get("matches", false)) and bool(generated_right.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["nearby_delta"] and proof["nearby_rotation"] and proof["relative_to_tile"] and proof["relative_to_building"] and proof["relative_to_edge"] and proof["relative_to_coordinates"] and proof["front_back"] and proof["left_right"] and proof["find_closest_edge_null"] and proof["find_closest_edge"] and proof["generated_find_closest_edge"] and proof["each_edge"] and proof["generated_each_edge"] and proof["generated_nearby"] and proof["generated_relative"] and proof["generated_multiblock"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	proof["matches"] = proof["matches"] and proof["edge_order_odd"] and proof["edge_order_even"] and proof["closest_edge_tie"] and proof["generated_closest_edge_tie"]
	print("BUILDING_NAVIGATION_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingNavigationStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
