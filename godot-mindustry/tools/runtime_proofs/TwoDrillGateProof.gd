extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
const conveyor_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
const drill_consumption := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
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
	var catalog: Object = game.get("content_catalog")
	var items: Dictionary = game.get("source_item_catalog")
	var facts: Dictionary = items["item_facts_by_field"]
	var lead: Object = catalog.get_by_id("ore-lead")
	var drill_block: Object = catalog.get_by_id("mechanical-drill")
	var conveyor_block: Object = catalog.get_by_id("conveyor")

	# --- a second drill on lead ore, with its own belt beside it. ---
	var primary_cell := Vector2i(7, 8)
	var primary_belt := Vector2i(9, 8)
	var second_cell := Vector2i(28, 20)
	var second_belt := Vector2i(30, 20)
	for cell in game.call("occupied_cells", second_cell, drill_block):
		terrain.source_set_world_overlay_state(game, cell.x, cell.y, lead, false)
	var second := Sprite2D.new()
	game.add_child(second)
	game.call("record_placed_block", second, drill_block, second_cell)
	var second_frame: Dictionary = second.get_meta(drill_consumption.SOURCE_DRILL_BUILDING_META_KEY)
	proof["two_drill_gate_second_dominant"] = is_same(second_frame["dominant_item"], facts["lead"])
	var belt := Sprite2D.new()
	game.add_child(belt)
	game.call("record_placed_block", belt, conveyor_block, second_belt)

	# --- the step itself dumps both drills. ---
	second_frame["items"] = {"lead": 2}
	game.set("drill_items", {"copper": 5})
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, primary_belt, {"ids": [], "xs": [], "ys": [], "len": 0})
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, second_belt, {"ids": [], "xs": [], "ys": [], "len": 0})
	var step: Dictionary = factory_state.source_factory_dump_all_drill_outputs_state(game, true)
	var step_results: Dictionary = step.get("results_by_cell", {})
	var primary_belt_after: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, primary_belt)
	var second_belt_after: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, second_belt)
	proof["two_drill_gate_step"] = step.get("dumped_count") == 2 and step.get("reason") == "dumped" and step_results.has(primary_cell) and step_results.has(second_cell) and bool(step_results[primary_cell].get("dumped", false)) and bool(step_results[second_cell].get("dumped", false)) and step_results[second_cell].get("item_id") == "lead" and step_results[primary_cell].get("item_id") == "copper" and primary_belt_after.get("ids") == ["copper"] and second_belt_after.get("ids") == ["lead"] and second_frame["items"] == {"lead": 1} and game.get("drill_items") == {"copper": 4}

	# --- the timer gate refuses, and nothing moves. ---
	second_frame["items"] = {"lead": 2}
	game.set("drill_items", {"copper": 5})
	var gated: Dictionary = factory_state.source_factory_dump_all_drill_outputs_state(game, false)
	proof["two_drill_gate_timer"] = gated.get("dumped_count") == 0 and gated.get("reason") == "timer_not_fired" and gated.get("results_by_cell", {}) == {} and second_frame["items"] == {"lead": 2} and game.get("drill_items") == {"copper": 5}

	# --- the live loop itself dumps both drills when the timer fires. ---
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, primary_belt, {"ids": [], "xs": [], "ys": [], "len": 0})
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, second_belt, {"ids": [], "xs": [], "ys": [], "len": 0})
	game.set("drill_dump_timer", 9999.0)
	var core_before: int = int(game.get("core_inventory"))
	factory_state.simulate_factory(game, 1.0 / 60.0)
	var live_primary_belt: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, primary_belt)
	var live_second_belt: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, second_belt)
	proof["two_drill_gate_live_loop"] = live_primary_belt.get("ids") == ["copper"] and live_primary_belt.get("len") == 1 and live_second_belt.get("ids") == ["lead"] and live_second_belt.get("len") == 1 and second_frame["items"] == {"lead": 1} and game.get("drill_items") == {"copper": 4} and int(game.get("core_inventory")) == core_before

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("TwoDrillGateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
