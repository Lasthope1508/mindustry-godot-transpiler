extends "res://src/game/SourcePowerGeneratorPortBridge.gd"

const source_power_node_state := preload("res://src/game/SourcePowerNodeState.gd")

func source_power_node_set_stats_state(laser_range: float, max_nodes: int, super_set_stats_state: Dictionary = {}) -> Dictionary:
	return source_power_node_state.set_stats_state(laser_range, max_nodes, super_set_stats_state)

func source_power_node_init_state(clip_size: float, laser_range: float, tilesize: float, super_init_state: Dictionary = {}) -> Dictionary:
	return source_power_node_state.init_state(clip_size, laser_range, tilesize, super_init_state)

func source_power_node_plan_config_clip_size_state(laser_range: float, tilesize: float, size: float) -> Dictionary:
	return source_power_node_state.plan_config_clip_size_state(laser_range, tilesize, size)

func source_power_node_link_valid_state(link_state: Dictionary, check_max_nodes: bool = true) -> Dictionary:
	return source_power_node_state.link_valid_state(link_state, check_max_nodes)

func source_power_node_insulated_state(raycast_insulated: bool) -> Dictionary:
	return source_power_node_state.insulated_state(raycast_insulated)

func source_power_node_overlaps_state(overlap_result: bool, method: String, expression: String) -> Dictionary:
	return source_power_node_state.overlaps_state(overlap_result, method, expression)

func source_power_node_overlaps_nullable_state(src_present: bool, other_present: bool, overlap_result: bool) -> Dictionary:
	return source_power_node_state.overlaps_nullable_state(src_present, other_present, overlap_result)

func source_power_node_setup_color_state(satisfaction: float, laser_opacity: float, lod_alpha2: float, absin_value: float) -> Dictionary:
	return source_power_node_state.setup_color_state(satisfaction, laser_opacity, lod_alpha2, absin_value)

func source_power_node_draw_laser_state(laser_state: Dictionary, light: bool = true) -> Dictionary:
	return source_power_node_state.draw_laser_state(laser_state, light)

func source_power_node_change_placement_path_state(points: Variant, rotation: int, placement_result: Dictionary = {}) -> Dictionary:
	return source_power_node_state.change_placement_path_state(points, rotation, placement_result)

func source_power_node_draw_place_state(x: int, y: int, rotation: int, valid: bool, draw_input: Dictionary = {}) -> Dictionary:
	return source_power_node_state.draw_place_state(x, y, rotation, valid, draw_input)

func source_power_node_get_potential_links_state(link_input: Dictionary) -> Dictionary:
	return source_power_node_state.get_potential_links_state(link_input)

func source_power_node_get_node_links_state(link_input: Dictionary) -> Dictionary:
	return source_power_node_state.get_node_links_state(link_input)

func source_power_node_draw_plan_config_top_state(plan_input: Dictionary) -> Dictionary:
	return source_power_node_state.draw_plan_config_top_state(plan_input)

func source_power_node_make_power_balance_state(graph_input: Dictionary) -> Dictionary:
	return source_power_node_state.make_power_balance_state(graph_input)

func source_power_node_make_battery_balance_state(graph_input: Dictionary) -> Dictionary:
	return source_power_node_state.make_battery_balance_state(graph_input)

func source_power_node_set_bars_state(bars_input: Dictionary) -> Dictionary:
	return source_power_node_state.set_bars_state(bars_input)
