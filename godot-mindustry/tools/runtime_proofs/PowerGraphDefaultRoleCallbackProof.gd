extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourcePowerGraphState := preload("res://src/game/SourcePowerGraphState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()

	var graph_tiles: Array = [
		{
			"build_present": true,
			"power_present": true,
			"graph_matches": false,
			"power_init": false,
			"old_graph_present": false,
			"old_graph_is_self": false,
			"old_graph_has_entity": false,
			"outputs_power": true,
			"consumes_power": false,
			"has_cons_power": false,
			"cons_power_buffered": false,
		}
	]
	var reflow_tile := {
		"pos": Vector2i(4, 5),
		"build_present": true,
		"power_present": true,
		"graph_matches": false,
		"power_init": false,
		"old_graph_present": false,
		"old_graph_is_self": false,
		"old_graph_has_entity": false,
		"outputs_power": false,
		"consumes_power": true,
		"has_cons_power": true,
		"cons_power_buffered": true,
		"connections": [
			{
				"pos": Vector2i(6, 5),
				"build_present": true,
				"power_present": true,
				"graph_matches": false,
				"power_init": false,
				"old_graph_present": false,
				"old_graph_is_self": false,
				"old_graph_has_entity": false,
				"outputs_power": true,
				"consumes_power": true,
				"has_cons_power": true,
				"cons_power_buffered": false,
			}
		],
	}
	var remove_tile := {
		"connections": [],
	}

	var module_add := SourcePowerGraphState.add_graph_state(false, 1, 3, true, graph_tiles)
	var source_add := game.source_power_graph_add_graph_state(false, 1, 3, true, graph_tiles)
	var module_reflow := SourcePowerGraphState.reflow_state(reflow_tile)
	var source_reflow := game.source_power_graph_reflow_state(reflow_tile)
	var module_remove := SourcePowerGraphState.remove_empty_entity_state(remove_tile, true)
	var source_remove := game.source_power_graph_remove_empty_entity_state(remove_tile, true)
	var registry := SourceSsotCatalog.canonical_headquarter_registry_state()

	var proof := {
		"module": "SourcePowerGraphState",
		"add_graph_matches": source_add == module_add,
		"reflow_matches": source_reflow == module_reflow,
		"remove_empty_matches": source_remove == module_remove,
		"add_graph_role": str(module_add.get("tile_add_states", [])),
		"reflow_branch_count": int(module_reflow.get("check_add_count", 0)),
		"remove_empty_returned": bool(module_remove.get("entity_removed", false)),
		"one_headquarter_per_ssot": bool(registry.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry.get("errors", []).is_empty()),
	}
	print("POWER_GRAPH_DEFAULT_ROLE_CALLBACK_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(10.0).timeout
	get_tree().quit(0)
