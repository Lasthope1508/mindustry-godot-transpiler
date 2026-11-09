extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
const placed_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const drill_consumption_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
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

	# --- the bootstrap world has one power producer (the solar panel at
	# (21, 7), N2078), one battery (at (23, 7), N2079) and one real
	# consumer (the lancer at (25, 7), N2080), so the update produces
	# 0.12/delta and needs 6.0/delta (the lancer's usage counted once
	# per building, N2081). The 19 consumers are the placed buildings
	# (drill, core, 7 conveyors, duo, lancer, pump, 7 conduits); the other blocks'
	# usage is 0. ---
	var step: Dictionary = factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)
	proof["power_graph_live_update_grouped_by_building"] = is_equal_approx(float(step.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(step.get("power_produced", -1.0)), 0.12 / 60.0) and int(step.get("consumer_count", -1)) == 19 and int(step.get("producer_count", -1)) == 1 and int(step.get("battery_count", -1)) == 1
	var update: Dictionary = step.get("update", {})
	proof["power_graph_live_update_states"] = update.has("cheat_state") and update.has("balance_state") and update.has("battery_distribute_state") and is_equal_approx(float(update.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(update.get("power_produced", -1.0)), 0.12 / 60.0)

	# --- the live loop runs the step each frame without error. ---
	factory_state.simulate_factory(game, 1.0 / 60.0)
	var after_live: Dictionary = factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)
	proof["power_graph_live_update_live_loop"] = is_equal_approx(float(after_live.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(after_live.get("power_produced", -1.0)), 0.12 / 60.0) and int(after_live.get("consumer_count", -1)) == 19 and int(after_live.get("producer_count", -1)) == 1

	# --- the live cheating value reaches the graph (N2107): the drill's
	# team cheats (TeamComp.cheating(), N2099), so the first consumer
	# (the drill, placed first) carries cheating=true and
	# PowerGraph.update() takes its cheat branch (PowerGraph.java:217
	# -224): every consumer's power.status is 1 and lastPowerNeeded /
	# lastPowerProduced are 1. The helper reads the value live from the
	# building's team and the game rules, so a cell with no building
	# keeps the false default. ---
	for iteration in range(4):
		factory_state.simulate_factory(game, 1.0 / 60.0)
	var drill_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(7, 8))
	var drill_frame: Dictionary = drill_sprite.get_meta(drill_consumption_state.SOURCE_DRILL_BUILDING_META_KEY, {})
	var drill_team: int = int(drill_frame.get("team_id", -1))
	var drill_origin: Vector2i = drill_sprite.get_meta("origin_cell", Vector2i.ZERO)
	proof["power_graph_cheat_helper_no_sprite_false"] = placed_state.source_consumer_cheating_for_cell_state(game, Vector2i(99, 99)).get("cheating", true) == false and placed_state.source_consumer_cheating_for_cell_state(game, Vector2i(99, 99)).get("found", true) == false
	proof["power_graph_cheat_drill_team_known"] = drill_team >= 0
	var game_rules: Dictionary = game.get("rules_state")
	var teams: Dictionary = game_rules.get("teams", {})
	teams[drill_team] = {"cheat": true}
	for iteration in range(4):
		factory_state.simulate_factory(game, 1.0 / 60.0)
	var cheat_step: Dictionary = factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)
	var cheat_update: Dictionary = cheat_step.get("update", {})
	var cheat_consumers: Array = cheat_update.get("consumers", [])
	proof["power_graph_cheat_helper_drill_team_true"] = placed_state.source_consumer_cheating_for_cell_state(game, Vector2i(7, 8)).get("cheating", false) == true and int(placed_state.source_consumer_cheating_for_cell_state(game, Vector2i(7, 8)).get("team_id", -1)) == drill_team
	proof["power_graph_cheat_first_consumer_carries_live_cheating"] = not cheat_consumers.is_empty() and bool(cheat_consumers[0].get("cheating", false)) == true and cheat_consumers[0].get("origin_cell", null) == drill_origin
	proof["power_graph_cheat_gate_fires"] = is_equal_approx(float(cheat_step.get("power_needed", -1.0)), 1.0) and is_equal_approx(float(cheat_step.get("power_produced", -1.0)), 1.0) and bool(cheat_update.get("cheat_state", {}).get("returned", false)) == true and is_equal_approx(float(cheat_update.get("last_power_needed", -1.0)), 1.0) and is_equal_approx(float(cheat_update.get("last_power_produced", -1.0)), 1.0)
	var all_status_one := not cheat_consumers.is_empty()
	for consumer in cheat_consumers:
		if not (consumer is Dictionary) or not is_equal_approx(float(consumer.get("power_status", -1.0)), 1.0):
			all_status_one = false
	proof["power_graph_cheat_sets_all_consumer_status"] = all_status_one
	teams[drill_team] = {"cheat": false}
	for iteration in range(4):
		factory_state.simulate_factory(game, 1.0 / 60.0)
	var uncheat_step: Dictionary = factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)
	proof["power_graph_uncheat_restores_balance"] = is_equal_approx(float(uncheat_step.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(uncheat_step.get("power_produced", -1.0)), 0.12 / 60.0) and bool(uncheat_step.get("update", {}).get("cheat_state", {}).get("returned", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("PowerGraphLiveUpdateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
