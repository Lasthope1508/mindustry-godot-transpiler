extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
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
	# per building, N2081). The 11 consumers are the placed buildings
	# (drill, core, 7 conveyors, duo, lancer); the other blocks'
	# usage is 0. ---
	var step: Dictionary = factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)
	proof["power_graph_live_update_grouped_by_building"] = is_equal_approx(float(step.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(step.get("power_produced", -1.0)), 0.12 / 60.0) and int(step.get("consumer_count", -1)) == 11 and int(step.get("producer_count", -1)) == 1 and int(step.get("battery_count", -1)) == 1
	var update: Dictionary = step.get("update", {})
	proof["power_graph_live_update_states"] = update.has("cheat_state") and update.has("balance_state") and update.has("battery_distribute_state") and is_equal_approx(float(update.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(update.get("power_produced", -1.0)), 0.12 / 60.0)

	# --- the live loop runs the step each frame without error. ---
	factory_state.simulate_factory(game, 1.0 / 60.0)
	var after_live: Dictionary = factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)
	proof["power_graph_live_update_live_loop"] = is_equal_approx(float(after_live.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(after_live.get("power_produced", -1.0)), 0.12 / 60.0) and int(after_live.get("consumer_count", -1)) == 11 and int(after_live.get("producer_count", -1)) == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("PowerGraphLiveUpdateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
