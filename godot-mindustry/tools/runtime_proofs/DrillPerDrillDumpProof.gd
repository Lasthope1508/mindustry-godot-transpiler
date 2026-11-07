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
	var second_cell := Vector2i(28, 20)
	var belt_cell := Vector2i(30, 20)
	for cell in game.call("occupied_cells", second_cell, drill_block):
		terrain.source_set_world_overlay_state(game, cell.x, cell.y, lead, false)
	var second := Sprite2D.new()
	game.add_child(second)
	game.call("record_placed_block", second, drill_block, second_cell)
	var second_frame: Dictionary = second.get_meta(drill_consumption.SOURCE_DRILL_BUILDING_META_KEY)
	proof["per_drill_dump_second_dominant"] = is_same(second_frame["dominant_item"], facts["lead"])
	var belt := Sprite2D.new()
	game.add_child(belt)
	game.call("record_placed_block", belt, conveyor_block, belt_cell)
	proof["per_drill_dump_belt_rot"] = int(belt.get_meta("rotation", -1)) == 0

	# --- the second drill dumps from its own frame, not the primary's inventory. ---
	second_frame["items"] = {"lead": 2}
	game.set("drill_items", {"copper": 5})
	var dump_second: Dictionary = factory_state.source_factory_dump_drill_output_for_cell_state(game, second_cell, "lead")
	var belt_after: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, belt_cell)
	proof["per_drill_dump_second"] = dump_second.get("dumped") == true and dump_second.get("item_id") == "lead" and dump_second.get("receiver_cell") == belt_cell and dump_second.get("cdump_before") == 0 and dump_second.get("cdump_after") == 3 and dump_second.get("items_after") == {"lead": 1} and dump_second.get("destination") == "conveyor" and dump_second.get("reason") == "dumped" and belt_after.get("ids") == ["lead"] and belt_after.get("len") == 1
	proof["per_drill_dump_second_frame"] = second_frame["items"] == {"lead": 1}
	proof["per_drill_dump_primary_untouched"] = game.get("drill_items") == {"copper": 5}

	# --- the primary still dumps from the game-global, through the old entry. ---
	var primary_cell := Vector2i(7, 8)
	var primary_belt := Vector2i(9, 8)
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, primary_belt, {"ids": [], "xs": [], "ys": [], "len": 0})
	game.set("drill_items", {"copper": 5})
	var dump_primary: Dictionary = factory_state.source_factory_dump_drill_output_state(game, primary_cell, "copper")
	var primary_belt_after: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, primary_belt)
	proof["per_drill_dump_primary"] = dump_primary.get("dumped") == true and dump_primary.get("item_id") == "copper" and dump_primary.get("receiver_cell") == primary_belt and dump_primary.get("items_after") == {"copper": 4} and primary_belt_after.get("ids") == ["copper"] and primary_belt_after.get("len") == 1 and game.get("drill_items") == {"copper": 4}

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("DrillPerDrillDumpProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
