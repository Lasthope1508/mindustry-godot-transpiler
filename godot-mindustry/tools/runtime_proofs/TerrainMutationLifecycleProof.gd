extends Node

const main_scene := preload("res://scenes/Main.tscn")
const terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const live := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
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
	var air: Object = catalog.get_by_id("air")
	var sand: Object = catalog.get_by_id("sand-floor")
	var stone: Object = catalog.get_by_id("stone")
	var copper: Object = catalog.get_by_id("ore-copper")
	var block: Object = catalog.get_by_id("mechanical-drill")
	var cell: Vector2i = game.get("drill_pos")
	var sprite: Sprite2D = game.call("block_sprite_at_cell", cell)
	var frame: Dictionary = sprite.get_meta(live.SOURCE_DRILL_BUILDING_META_KEY)
	var facts: Dictionary = game.get("source_item_catalog")["item_facts_by_field"]
	for occupied in game.call("occupied_cells", cell, block):
		terrain.source_clear_world_overlay_state(game, occupied.x, occupied.y, false)
	var proof: Dictionary = {}
	proof["cleared_footprint_has_no_item"] = frame["dominant_item"] == null and frame["dominant_items"] == 0
	var changed := terrain.source_set_world_floor_state(game, cell.x, cell.y, sand)
	var tile: Dictionary = game.call("source_world_tile", cell.x, cell.y)
	proof["floor_assigns_and_notifies"] = changed["changed"] and changed["proximity_updated"] and is_same(frame["dominant_item"], facts["sand"]) and frame["dominant_items"] == 1
	proof["floor_retains_actual_tile_and_definition"] = is_same(tile, game.call("source_world_tile", cell.x, cell.y)) and is_same(tile["floor"], sand) and is_same(tile["overlay"], air)
	var unchanged := terrain.source_set_world_floor_state(game, cell.x, cell.y, sand)
	proof["floor_identity_guard"] = not unchanged["changed"] and not unchanged["proximity_updated"]
	var proxy := cell + Vector2i(1, 1)
	terrain.source_set_world_floor_state(game, proxy.x, proxy.y, sand)
	proof["proxy_floor_updates_one_existing_frame"] = frame["dominant_items"] == 2 and is_same(frame, sprite.get_meta(live.SOURCE_DRILL_BUILDING_META_KEY))
	terrain.source_set_world_overlay_quiet_state(game, proxy.x, proxy.y, copper)
	proof["quiet_assigns_without_notification"] = is_same(game.call("source_world_tile", proxy.x, proxy.y)["overlay"], copper) and is_same(frame["dominant_item"], facts["sand"]) and frame["dominant_items"] == 2
	game.call("_process", 1.0 / 60.0)
	proof["quiet_is_not_implicitly_rescanned"] = is_same(frame["dominant_item"], facts["sand"]) and frame["dominant_items"] == 2
	live.source_on_proximity_update_state(game, sprite, block)
	proof["explicit_proximity_resolves_quiet_overlay"] = is_same(frame["dominant_item"], facts["copper"]) and frame["dominant_items"] == 1
	var cleared := terrain.source_clear_world_overlay_state(game, proxy.x, proxy.y, false)
	proof["clear_delegates_canonical_air_and_notifies"] = cleared["changed"] and cleared["proximity_updated"] and is_same(game.call("source_world_tile", proxy.x, proxy.y)["overlay"], air) and is_same(frame["dominant_item"], facts["sand"]) and frame["dominant_items"] == 2
	var clear_noop := terrain.source_clear_world_overlay_state(game, proxy.x, proxy.y, false)
	proof["clear_inherits_identity_guard"] = not clear_noop["changed"] and not clear_noop["proximity_updated"]
	for occupied in game.call("occupied_cells", cell, block):
		terrain.source_set_world_floor_state(game, occupied.x, occupied.y, sand)
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, copper, false)
	var ordered := terrain.source_set_world_floor_overlay_state(game, cell.x, cell.y, stone, air, true)
	proof["ordered_receiver_executes_both_assignments"] = ordered["floor_state"]["changed"] and ordered["floor_state"]["proximity_updated"] and ordered["overlay_state"]["changed"] and not ordered["overlay_state"]["proximity_updated"] and is_same(tile["floor"], stone) and is_same(tile["overlay"], air)
	proof["source_floor_before_overlay_order_is_observable"] = is_same(frame["dominant_item"], facts["copper"]) and frame["dominant_items"] == 4
	live.source_on_proximity_update_state(game, sprite, block)
	proof["end_generation_resolves_ordered_receiver"] = frame["dominant_items"] == 3 and is_same(frame["dominant_item"], facts["copper"])
	var defaulted := terrain.source_set_world_floor_default_state(game, proxy.x, proxy.y, stone, false)
	proof["floor_default_clears_overlay_after_floor"] = defaulted["floor_state"]["changed"] and defaulted["overlay_state"]["changed"] and defaulted["overlay_state"]["proximity_updated"] and is_same(game.call("source_world_tile", proxy.x, proxy.y)["overlay"], air) and frame["dominant_items"] == 2
	var outside := Vector2i(35, 25)
	var empty := terrain.source_set_world_floor_state(game, outside.x, outside.y, sand)
	proof["unoccupied_floor_does_not_create_building"] = empty["changed"] and not empty["proximity_updated"] and game.call("block_sprite_at_cell", outside) == null
	# End with sand-only actual terrain, then let the real game loop produce it.
	for occupied in game.call("occupied_cells", cell, block):
		terrain.source_set_world_floor_default_state(game, occupied.x, occupied.y, sand, false)
	game.get("ore_items_by_cell").clear()
	game.set("offload_neighbors", [])
	game.set("drill_items", {})
	game.set("item_progress", 2.0)
	game.call("set_drill_warmup_at_cell", cell.x, cell.y, 1.0)
	game.set("drill_dump_timer", 0.0)
	game.call("_process", 1.0 / 60.0)
	proof["actual_process_produces_floor_item"] = is_same(frame["dominant_item"], facts["sand"]) and frame["dominant_items"] == 4 and game.get("drill_items").get("sand", 0) == 2 and game.get("drill_items").get("copper", 0) == 0
	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	game.queue_free()
	await get_tree().process_frame
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("TerrainMutationLifecycleProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
