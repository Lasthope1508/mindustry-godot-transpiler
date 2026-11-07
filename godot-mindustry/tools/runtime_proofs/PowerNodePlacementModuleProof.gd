extends SceneTree

const generated_script := preload("res://src/generated/classes/mindustry/world/blocks/power/PowerNode.gd")
const source_power_node_state := preload("res://src/game/SourcePowerNodeState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _init() -> void:
	var game = preload("res://src/game/PortGame.gd").new()
	var generated = generated_script.new()
	var draw_input := {
		"tile_present": true,
		"autolink": true,
		"tilesize": 8.0,
		"offset": 0.0,
		"laser_range": 6.0,
		"size": 1.0,
		"potential_links": [{"x": 32.0, "y": 16.0, "size": 2.0}],
	}
	var draw_result: Dictionary = game.source_power_node_draw_place_state(4, 2, 0, true, draw_input)
	var placement_result: Dictionary = {"points": [{"x": 4, "y": 2}, {"x": 5, "y": 2}]}
	var placement: Dictionary = game.source_power_node_change_placement_path_state([{"x": 4, "y": 2}], 0, placement_result)
	var link_input := {
		"autolink": true,
		"initial_graph_ids": ["occupied"],
		"tile_graph_present": false,
		"max_nodes": 2,
		"candidates": [
			{"present": true, "same_tile": false, "connected_power": true, "power_present": true, "outputs_power": true, "consumes_power": false, "is_power_node": false, "overlaps": true, "same_team": true, "graph_id": "g1", "insulated": false, "max_nodes_reached": false, "adjacent": false, "distance": 3.0},
			{"present": true, "same_tile": false, "connected_power": true, "power_present": true, "outputs_power": false, "consumes_power": false, "is_power_node": true, "overlaps": true, "same_team": true, "graph_id": "g2", "insulated": false, "max_nodes_reached": false, "adjacent": false, "distance": 8.0},
			{"present": true, "same_tile": false, "connected_power": true, "power_present": true, "outputs_power": true, "consumes_power": false, "is_power_node": false, "overlaps": true, "same_team": true, "graph_id": "occupied", "insulated": false, "max_nodes_reached": false, "adjacent": false, "distance": 1.0},
		],
	}
	var potential_links: Dictionary = game.source_power_node_get_potential_links_state(link_input)
	var node_links: Dictionary = game.source_power_node_get_node_links_state({
		"initial_graph_ids": [],
		"candidates": [
			{"present": true, "same_tile": false, "is_power_node": true, "autolink": true, "capacity_available": true, "overlaps": true, "same_team": true, "graph_id": "n1", "insulated": false, "adjacent": false, "distance": 2.0},
			{"present": true, "same_tile": false, "is_power_node": true, "autolink": true, "capacity_available": true, "overlaps": true, "same_team": true, "graph_id": "n1", "insulated": false, "adjacent": false, "distance": 1.0},
		],
	})
	var plan_input := {"config_present": true, "size": 1.0, "resolved_links": [{"other_present": true, "plan_position": Vector2(32.0, 16.0), "other_position": Vector2(48.0, 16.0), "other_size": 2.0}]}
	var plan_draw: Dictionary = game.source_power_node_draw_plan_config_top_state(plan_input)
	var balance_input := {"power_balance": 2.5, "last_power_produced": 80.0, "last_power_needed": 100.0, "formatted_label": "+150"}
	var battery_input := {"last_power_stored": 40.0, "last_capacity": 80.0, "formatted_label": "40/80"}
	var power_balance: Dictionary = game.source_power_node_make_power_balance_state(balance_input)
	var battery_balance: Dictionary = game.source_power_node_make_battery_balance_state(battery_input)
	var bars_input := {"graph_input": balance_input, "links": 1.0, "max_nodes": 2.0, "super_set_bars_state": {"called": true}}
	var bars: Dictionary = game.source_power_node_set_bars_state(bars_input)
	var draw_expected: Dictionary = source_power_node_state.draw_place_state(4, 2, 0, true, draw_input)
	var placement_expected: Dictionary = source_power_node_state.change_placement_path_state([{"x": 4, "y": 2}], 0, placement_result)
	var generated_draw: Dictionary = generated.java_method_drawPlace_5([4, 2, 0, true, draw_input])
	var generated_placement: Dictionary = generated.java_method_changePlacementPath_6([[{"x": 4, "y": 2}], 0, placement_result])
	var generated_potential: Dictionary = generated.java_method_getPotentialLinks_15([link_input])
	var generated_nodes: Dictionary = generated.java_method_getNodeLinks_16([{"initial_graph_ids": [], "candidates": [{"present": true, "same_tile": false, "is_power_node": true, "autolink": true, "capacity_available": true, "overlaps": true, "same_team": true, "graph_id": "n1", "insulated": false, "adjacent": false, "distance": 2.0}, {"present": true, "same_tile": false, "is_power_node": true, "autolink": true, "capacity_available": true, "overlaps": true, "same_team": true, "graph_id": "n1", "insulated": false, "adjacent": false, "distance": 1.0}] }])
	var generated_plan: Dictionary = generated.java_method_drawPlanConfigTop_17([plan_input])
	var generated_power_balance: Dictionary = generated.java_method_makePowerBalance_1([balance_input])
	var generated_battery_balance: Dictionary = generated.java_method_makeBatteryBalance_2([battery_input])
	var generated_bars: Dictionary = generated.java_method_setBars_0([bars_input])
	var expected_potential: Dictionary = source_power_node_state.get_potential_links_state(link_input)
	var expected_nodes: Dictionary = source_power_node_state.get_node_links_state({"initial_graph_ids": [], "candidates": [{"present": true, "same_tile": false, "is_power_node": true, "autolink": true, "capacity_available": true, "overlaps": true, "same_team": true, "graph_id": "n1", "insulated": false, "adjacent": false, "distance": 2.0}, {"present": true, "same_tile": false, "is_power_node": true, "autolink": true, "capacity_available": true, "overlaps": true, "same_team": true, "graph_id": "n1", "insulated": false, "adjacent": false, "distance": 1.0}]})
	var expected_plan: Dictionary = source_power_node_state.draw_plan_config_top_state(plan_input)
	var expected_power_balance: Dictionary = source_power_node_state.make_power_balance_state(balance_input)
	var expected_battery_balance: Dictionary = source_power_node_state.make_battery_balance_state(battery_input)
	var expected_bars: Dictionary = source_power_node_state.set_bars_state(bars_input)
	var registry_state: Dictionary = source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var source_matches: bool = draw_result == draw_expected and placement == placement_expected \
		and not draw_result.get("skipped", true) and draw_result.get("commands", []).size() == 7 \
		and placement.get("calculated_points", []).size() == 2 \
		and potential_links == expected_potential and node_links == expected_nodes \
		and potential_links.get("returned_count", 0) == 2 and node_links.get("returned_count", 0) == 1 \
		and plan_draw == expected_plan and plan_draw.get("commands", []).size() == 3 \
		and power_balance == expected_power_balance and battery_balance == expected_battery_balance \
		and is_equal_approx(float(power_balance.get("fill", 0.0)), 0.8) and is_equal_approx(float(battery_balance.get("fill", 0.0)), 0.5) \
		and bars == expected_bars and is_equal_approx(float(bars.get("connections", {}).get("fill", 0.0)), 0.5)
	var generated_matches: bool = generated_draw == draw_expected and generated_placement == placement_expected \
		and generated_potential == expected_potential and generated_nodes == expected_nodes and generated_plan == expected_plan \
		and generated_power_balance == expected_power_balance and generated_battery_balance == expected_battery_balance \
		and generated_bars == expected_bars
	var registry_valid: bool = bool(registry_state.get("errors", []).is_empty())
	var one_headquarter_per_ssot: bool = bool(registry_state.get("one_headquarter_per_ssot", false))
	var valid: bool = source_matches and generated_matches and registry_valid and one_headquarter_per_ssot
	print(JSON.stringify({
		"proof": "PowerNodePlacementModuleProof",
		"matches": valid,
		"source_matches": source_matches,
		"generated_matches": generated_matches,
		"draw_commands": draw_result.get("commands", []).size(),
		"placement_points": placement.get("calculated_points", []).size(),
		"potential_links": potential_links.get("returned_count", 0),
		"node_links": node_links.get("returned_count", 0),
		"plan_commands": plan_draw.get("commands", []).size(),
		"power_balance_fill": power_balance.get("fill", 0.0),
		"battery_balance_fill": battery_balance.get("fill", 0.0),
		"connections_fill": bars.get("connections", {}).get("fill", 0.0),
		"registry_valid": registry_valid,
		"one_headquarter_per_ssot": one_headquarter_per_ssot,
	}))
	quit(0 if valid else 1)
