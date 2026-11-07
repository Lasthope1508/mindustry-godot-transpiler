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

	# --- the battery starts with no stored status (0.0): the live
	# loop's deficit frames never charge it, and the status is not
	# rebuilt from the registry each frame. ---
	var read_empty: Dictionary = placed_power_graph_state.source_battery_power_status_for_cell_state(game, Vector2i(23, 7))
	proof["battery_power_status_read_empty"] = bool(read_empty.get("found", false)) and is_equal_approx(float(read_empty.get("status", -1.0)), 0.0)

	# --- the write stores the status on the battery sprite's meta,
	# and the read returns it. ---
	var written: Dictionary = placed_power_graph_state.source_battery_set_power_status_for_cell_state(game, Vector2i(23, 7), 0.5)
	var read_back: Dictionary = placed_power_graph_state.source_battery_power_status_for_cell_state(game, Vector2i(23, 7))
	proof["battery_power_status_write_read"] = bool(written.get("stored", false)) and is_equal_approx(float(read_back.get("status", -1.0)), 0.5)

	# --- with the battery pre-charged to 0.5 (stored energy 0.5 x
	# 4000 = 2000), the deficit step (needed 0.1, produced 0.002,
	# deficit 0.098) discharges it: power_battery_used is the full
	# deficit, and the stored status drops below 0.5. ---
	var step: Dictionary = factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)
	var distribute: Dictionary = step.get("update", {}).get("battery_distribute_state", {})
	var after_first: Dictionary = placed_power_graph_state.source_battery_power_status_for_cell_state(game, Vector2i(23, 7))
	var status_first := float(after_first.get("status", -1.0))
	proof["battery_power_status_discharge"] = is_equal_approx(float(distribute.get("power_battery_used", -1.0)), 0.098) and status_first < 0.5 and status_first > 0.49

	# --- a second step reads the stored status (it persists across
	# frames, not rebuilt as 0.0) and discharges it a little more. ---
	var _step2: Dictionary = factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)
	var after_second: Dictionary = placed_power_graph_state.source_battery_power_status_for_cell_state(game, Vector2i(23, 7))
	var status_second := float(after_second.get("status", -1.0))
	proof["battery_power_status_persists"] = status_second > 0.49 and status_second < status_first

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("BatteryPowerStatusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
