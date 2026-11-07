extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
const conveyor_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")


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

	var drill_cell := Vector2i(7, 8)
	var belt_cell := Vector2i(9, 8)

	# --- the wrapper dumps the dominant item to the belt, not the core. ---
	game.set("drill_items", {"lead": 3})
	var core_before: int = int(game.get("core_inventory"))
	var dump_lead: Dictionary = factory_state.source_factory_dump_drill_output_state(game, drill_cell, "lead")
	var belt_after_lead: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, belt_cell)
	proof["factory_dump_swap_lead"] = dump_lead.get("dumped") == true and dump_lead.get("item_id") == "lead" and dump_lead.get("receiver_cell") == belt_cell and dump_lead.get("cdump_before") == 0 and dump_lead.get("cdump_after") == 3 and dump_lead.get("items_after") == {"lead": 2} and dump_lead.get("destination") == "conveyor" and dump_lead.get("reason") == "dumped" and belt_after_lead.get("ids") == ["lead"] and belt_after_lead.get("len") == 1 and int(game.get("core_inventory")) == core_before

	# --- the wrapper falls back to the any branch when the dominant is not held. ---
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, belt_cell, {"ids": ["lead"], "xs": [0.0], "ys": [0.8], "len": 1})
	game.set("drill_items", {"copper": 2})
	var dump_any: Dictionary = factory_state.source_factory_dump_drill_output_state(game, drill_cell, "lead")
	var belt_after_any: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, belt_cell)
	proof["factory_dump_swap_any"] = dump_any.get("dumped") == true and dump_any.get("item_id") == "copper" and dump_any.get("receiver_cell") == belt_cell and dump_any.get("items_after") == {"copper": 1} and belt_after_any.get("ids") == ["copper", "lead"] and belt_after_any.get("len") == 2

	# --- a full belt refuses, and the item stays: no core fallback. ---
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, belt_cell, {"ids": ["copper", "lead", "silicon"], "xs": [0.0, 0.5, -0.5], "ys": [0.2, 0.8, 0.9], "len": 3})
	game.set("drill_items", {"lead": 2})
	var core_before_full: int = int(game.get("core_inventory"))
	var dump_full: Dictionary = factory_state.source_factory_dump_drill_output_state(game, drill_cell, "lead")
	proof["factory_dump_swap_full"] = dump_full.get("dumped") == false and dump_full.get("reason") == "no_receiver" and dump_full.get("items_after") == {"lead": 2} and int(game.get("core_inventory")) == core_before_full

	# --- the live loop itself: simulate_factory with a fired dump timer. ---
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, belt_cell, {"ids": [], "xs": [], "ys": [], "len": 0})
	game.set("drill_items", {"lead": 5})
	game.set("drill_dump_timer", 9999.0)
	var core_before_live: int = int(game.get("core_inventory"))
	factory_state.simulate_factory(game, 1.0 / 60.0)
	var belt_after_live: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, belt_cell)
	var live_items: Dictionary = game.get("drill_items")
	proof["factory_dump_swap_live_loop"] = belt_after_live.get("ids") == ["lead"] and belt_after_live.get("len") == 1 and int(live_items.get("lead", 0)) == 4 and int(game.get("core_inventory")) == core_before_live

	# --- no sprite, no dump. ---
	var dump_missing: Dictionary = factory_state.source_factory_dump_drill_output_state(game, Vector2i(30, 30), "lead")
	proof["factory_dump_swap_no_sprite"] = dump_missing.get("dumped") == false and dump_missing.get("reason") == "no_sprite"

	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("FactoryDumpSwapProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
