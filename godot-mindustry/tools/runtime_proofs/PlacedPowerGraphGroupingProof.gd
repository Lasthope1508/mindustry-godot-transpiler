extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
const placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}
	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- the placed-block origins map holds one key per footprint
	# cell (30 keys), but the graph groups one entry per building:
	# 14 buildings (drill, core, 7 conveyors, duo, panel, battery,
	# lancer, pump), each origin appearing once. ---
	var grouped: Dictionary = placed_power_graph_state.source_group_buildings_by_origin_state(game.get("placed_block_origins"))
	var origins: Array = grouped.get("origins", [])
	proof["placed_power_graph_grouping_origins"] = int(grouped.get("count", -1)) == 14 and origins.size() == 14 and origins.has(Vector2i(7, 8)) and origins.has(Vector2i(25, 7))

	# --- the graph now counts each building once: 12 consumers
	# (drill, core, 7 conveyors, duo, lancer, pump), 1 producer (panel),
	# 1 battery. The lancer's usage is counted once, so the graph
	# needs 6.0/60 = 0.1 against 0.12/60 produced — coverage 0.02,
	# the Java value (PowerGraph.add adds each building once). ---
	var step: Dictionary = factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)
	var update: Dictionary = step.get("update", {})
	var distribute: Dictionary = update.get("battery_distribute_state", {})
	proof["placed_power_graph_grouping_live_graph"] = int(step.get("consumer_count", -1)) == 12 and int(step.get("producer_count", -1)) == 1 and int(step.get("battery_count", -1)) == 1 and is_equal_approx(float(step.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(step.get("power_produced", -1.0)), 0.12 / 60.0) and is_equal_approx(float(distribute.get("coverage", -1.0)), 0.02)

	# --- the live loop runs the grouped step each frame. ---
	factory_state.simulate_factory(game, 1.0 / 60.0)
	var after_live: Dictionary = factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)
	proof["placed_power_graph_grouping_live_loop"] = int(after_live.get("consumer_count", -1)) == 12 and int(after_live.get("producer_count", -1)) == 1 and is_equal_approx(float(after_live.get("power_needed", -1.0)), 6.0 / 60.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("PlacedPowerGraphGroupingProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
