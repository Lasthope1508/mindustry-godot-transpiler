extends Node

const main_scene := preload("res://scenes/Main.tscn")
const drill := preload("res://src/game/SourceDrillRuntimeState.gd")
const live := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const placed := preload("res://src/game/SourcePlacedBlockState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func set_overlay(game: Object, cell: Vector2i, block: Object, generating: bool = false) -> Dictionary:
	return terrain.source_set_world_overlay_state(game, cell.x, cell.y, block, generating)

func _ready() -> void:
	var proof: Dictionary = {}
	var drop := {"id": 7, "hardness": 1, "low_priority": false}
	proof["get_drop_retains_reference"] = is_same(drill.source_get_drop_state({"is_static": false, "drop": drop})["drop"], drop)
	var result := drill.source_on_proximity_update_state([{"is_static": false, "drop": drop}], 2, null)
	proof["source_assignments_retain_item"] = is_same(result["dominant_item"], drop) and result["dominant_items"] == 1
	var picked := drill.source_picked_up_state({"dominant_item": drop, "dominant_items": 9, "progress": 12.0})
	proof["pickup_changes_only_item"] = picked["dominant_item"] == null and picked["dominant_items"] == 9 and picked["progress"] == 12.0
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
	var air: Object = catalog.get_by_id("air")
	var lead: Object = catalog.get_by_id("ore-lead")
	var copper: Object = catalog.get_by_id("ore-copper")
	var block: Object = catalog.get_by_id("mechanical-drill")
	var primary: Vector2i = game.get("drill_pos")
	var first: Sprite2D = game.call("block_sprite_at_cell", primary)
	var frame: Dictionary = first.get_meta(live.SOURCE_DRILL_BUILDING_META_KEY)
	proof["actual_bootstrap_proximity_assignment"] = is_same(frame["dominant_item"], facts["copper"]) and frame["dominant_items"] == 2
	var second_cell := Vector2i(28, 20)
	for cell in game.call("occupied_cells", second_cell, block):
		set_overlay(game, cell, lead)
	var second := Sprite2D.new()
	game.add_child(second)
	game.call("record_placed_block", second, block, second_cell)
	var second_frame: Dictionary = second.get_meta(live.SOURCE_DRILL_BUILDING_META_KEY)
	proof["real_second_placement_selects_lead"] = is_same(second_frame["dominant_item"], facts["lead"]) and second_frame["dominant_items"] == 4 and is_same(frame["dominant_item"], facts["copper"])
	var unchanged := set_overlay(game, second_cell, lead)
	proof["overlay_identity_guard"] = not unchanged["changed"] and not unchanged["proximity_updated"]
	var mutation := set_overlay(game, second_cell, copper)
	proof["proxy_cell_notifies_same_building"] = mutation["changed"] and mutation["proximity_updated"] and second_frame["dominant_items"] == 3 and is_same(second_frame["dominant_item"], facts["lead"])
	set_overlay(game, second_cell + Vector2i(0, 1), copper)
	proof["numeric_id_breaks_tie_after_mutation"] = is_same(second_frame["dominant_item"], facts["lead"]) and second_frame["dominant_items"] == 2
	set_overlay(game, second_cell + Vector2i(1, 0), copper)
	proof["count_beats_numeric_id"] = is_same(second_frame["dominant_item"], facts["copper"]) and second_frame["dominant_items"] == 3
	var generated := set_overlay(game, second_cell + Vector2i(1, 0), lead, true)
	proof["generating_defers_proximity"] = generated["changed"] and not generated["proximity_updated"] and second_frame["dominant_items"] == 3
	live.source_on_proximity_update_state(game, second, block)
	proof["explicit_map_end_recompute"] = is_same(second_frame["dominant_item"], facts["lead"]) and second_frame["dominant_items"] == 2
	for cell in game.call("occupied_cells", primary, block):
		set_overlay(game, cell, lead)
	proof["primary_reselects_without_global_output_change"] = is_same(frame["dominant_item"], facts["lead"]) and frame["dominant_items"] == 4 and game.get("drill_output_item_id") == "copper"
	game.get("ore_items_by_cell").clear()
	game.set("offload_neighbors", [])
	game.set("drill_items", {})
	game.set("item_progress", 2.0)
	game.call("set_drill_warmup_at_cell", primary.x, primary.y, 1.0)
	game.set("drill_dump_timer", 0.0)
	second_frame["item_progress"] = 2.0
	second_frame["warmup"] = 1.0
	game.call("_process", 1.0 / 60.0)
	proof["primary_produces_actual_dominant_item"] = game.get("drill_items").get("lead", 0) == 2 and game.get("drill_items").get("copper", 0) == 0
	proof["secondary_produces_own_dominant_item"] = second_frame["items"].get("lead", 0) == 2 and second_frame["items"].get("copper", 0) == 0
	proof["legacy_ore_map_does_not_override_proximity"] = is_same(frame["dominant_item"], facts["lead"]) and frame["dominant_items"] == 4
	var raw_tile: Dictionary = game.call("source_world_tile", primary.x, primary.y)
	raw_tile["overlay"] = copper
	game.call("_process", 1.0 / 60.0)
	proof["tick_does_not_rescan_world"] = is_same(frame["dominant_item"], facts["lead"]) and frame["dominant_items"] == 4
	for cell in game.call("occupied_cells", primary, block):
		set_overlay(game, cell, air)
	proof["empty_terrain_resets_item_and_count"] = frame["dominant_item"] == null and frame["dominant_items"] == 0
	var progress_before: float = game.get("item_progress")
	game.call("_process", 1.0 / 60.0)
	proof["empty_terrain_stops_production"] = game.get("item_progress") == progress_before and frame["efficiency"] == 0.0
	var retained_count: int = second_frame["dominant_items"]
	live.source_picked_up_state(second)
	game.call("_process", 1.0 / 60.0)
	proof["pickup_remains_null_across_ticks"] = second_frame["dominant_item"] == null and second_frame["dominant_items"] == retained_count and second_frame["efficiency"] == 0.0
	proof["shared_item_catalog_and_distinct_frames"] = is_same(game.get("source_item_catalog"), items) and not is_same(frame, second_frame)
	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	game.queue_free()
	await get_tree().process_frame
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("DrillProximityLifecycleProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
