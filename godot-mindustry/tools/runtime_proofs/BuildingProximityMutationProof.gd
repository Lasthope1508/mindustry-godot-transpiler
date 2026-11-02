extends Node

const proximity_owner := preload("res://src/game/SourceBuildingLifecycleProximityState.gd")
const geometry := preload("res://src/game/SourceBlockGeometry.gd")
const terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const main_scene := preload("res://scenes/Main.tscn")

class Building extends RefCounted:
	var team: Object
	var proximity: Array = []
	func _init(value: Object) -> void:
		team = value

func _ready() -> void:
	var proof: Dictionary = {}
	var team := RefCounted.new()
	var enemy_team := RefCounted.new()
	var subject := Building.new(team)
	var neighbor := Building.new(team)
	var twin := Building.new(team)
	var enemy := Building.new(enemy_team)
	var stale := Building.new(team)
	var lookup: Dictionary = {Vector2i(4, 3): neighbor, Vector2i(5, 3): neighbor, Vector2i(6, 4): enemy, Vector2i(3, 4): twin}
	var world_build := func(x: int, y: int) -> Variant: return lookup.get(Vector2i(x, y))
	var proximity_for := func(building: Object) -> Array: return building.proximity
	var team_for := func(building: Object) -> Object: return building.team
	var events: Array = []
	var recaches: Array = []
	var added := func(building: Object) -> void: events.append(["added", building, building.proximity.duplicate()])
	var updated := func(building: Object) -> void: events.append(["updated", building, building.proximity.duplicate()])
	var recache := func(building: Object) -> void: recaches.append(building)
	subject.proximity.append(stale)
	proximity_owner.source_apply_update_proximity(subject, 2, 4, 4, world_build, proximity_for, team_for, added, updated, recache, false, true)
	proof["update_replaces_stale_actual_array"] = subject.proximity.size() == 2 and subject.proximity.has(neighbor) and subject.proximity.has(twin) and not subject.proximity.has(stale)
	proof["same_team_links_both_directions"] = neighbor.proximity == [subject] and twin.proximity == [subject]
	proof["enemy_team_excluded_by_identity"] = enemy.proximity.is_empty() and not subject.proximity.has(enemy)
	proof["distinct_equal_field_buildings_retained"] = not is_same(neighbor, twin) and subject.proximity.size() == 2
	proof["hooks_see_complete_graph_in_source_order"] = events.size() == 4 and events[0][0] == "added" and is_same(events[0][1], subject) and events[0][2].size() == 2 and events[1][0] == "updated" and is_same(events[1][1], subject)
	proof["duplicate_edge_reference_notifies_once"] = events.filter(func(event): return event[0] == "updated" and is_same(event[1], neighbor)).size() == 1
	proof["recache_after_updates"] = recaches == [subject]
	for flags in [[true, true], [false, false], [true, false]]:
		proximity_owner.source_apply_update_proximity(subject, 2, 4, 4, world_build, proximity_for, team_for, added, updated, recache, flags[0], flags[1])
	proof["repeat_update_is_unique_and_recache_guarded"] = neighbor.proximity == [subject] and twin.proximity == [subject] and recaches == [subject]
	enemy.proximity.append(subject)
	var remove_events: Array = []
	var removed := func(building: Object) -> void: remove_events.append(["removed", building, neighbor.proximity.has(subject), building.proximity.size()])
	var on_removed_update := func(building: Object) -> void: remove_events.append(["updated", building, building.proximity.has(subject), subject.proximity.size()])
	proximity_owner.source_apply_remove_from_proximity(subject, 2, 4, 4, world_build, proximity_for, removed, on_removed_update)
	proof["removed_hook_precedes_unlink"] = remove_events[0] == ["removed", subject, true, 2]
	proof["remove_includes_other_teams_and_deduplicates"] = remove_events.size() == 4 and neighbor.proximity.is_empty() and twin.proximity.is_empty() and enemy.proximity.is_empty()
	proof["neighbor_updates_follow_unlink_before_self_clear"] = remove_events.slice(1).all(func(event): return event[0] == "updated" and not event[2] and event[3] == 2) and subject.proximity.is_empty()
	# Empty/bounded lookup still executes the source self hooks and clears stale data.
	lookup.clear()
	subject.proximity.append(stale)
	events.clear()
	proximity_owner.source_apply_update_proximity(subject, 1, 0, 0, world_build, proximity_for, team_for, added, updated, recache, true, false)
	proof["empty_world_still_calls_self_hooks"] = subject.proximity.is_empty() and events.size() == 2 and events[0][0] == "added" and events[1][0] == "updated"
	var air := RefCounted.new()
	var old_block := RefCounted.new()
	var tiles: Dictionary = {}
	for x in range(4):
		for y in range(3):
			tiles[Vector2i(x, y)] = {"x": x, "y": y, "build": subject, "block": old_block}
	var self_tile: Dictionary = tiles[Vector2i(2, 1)]
	var tile_lookup := func(x: int, y: int) -> Variant: return tiles.get(Vector2i(x, y))
	var tile_events: Array = []
	var pre := func(tile: Dictionary) -> void: tile_events.append(["pre", tile, tile["build"], tile["block"]])
	var changed := func(tile: Dictionary) -> void: tile_events.append(["changed", tile, tile["build"], tile["block"]])
	var on_removed := func(building: Object) -> void: tile_events.append(["removed", building])
	var remove_proximity := func(building: Object) -> void: tile_events.append(["remove_proximity", building])
	geometry.source_apply_tile_pre_changed(self_tile, subject, true, 3, -1, Vector2i(1, 1), tile_lookup, air, false, on_removed, remove_proximity, pre, changed)
	proof["proxy_mutation_uses_old_building_center"] = tiles.values().filter(func(tile): return tile["build"] == null).size() == 8 and is_same(tiles[Vector2i(0, 0)]["block"], air) and is_same(tiles[Vector2i(3, 1)]["build"], subject)
	proof["prechange_preserves_mutation_tile_for_changebuild"] = is_same(self_tile["build"], subject) and is_same(self_tile["block"], old_block)
	proof["prechange_hooks_once_before_proxy_reset"] = tile_events.size() == 19 and tile_events[0][0] == "pre" and is_same(tile_events[0][1], self_tile) and tile_events[1] == ["removed", subject] and tile_events[2] == ["remove_proximity", subject]
	proof["proxy_events_bracket_actual_assignment"] = tile_events.slice(3).filter(func(event): return event[0] == "pre").all(func(event): return is_same(event[2], subject) and is_same(event[3], old_block)) and tile_events.slice(3).filter(func(event): return event[0] == "changed").all(func(event): return event[2] == null and is_same(event[3], air))
	for tile in tiles.values():
		tile["build"] = subject
		tile["block"] = old_block
	tile_events.clear()
	geometry.source_apply_tile_pre_changed(tiles[Vector2i.ZERO], subject, true, 3, -1, Vector2i.ZERO, tile_lookup, air, true, on_removed, remove_proximity, pre, changed)
	proof["generation_suppresses_events_but_removes_and_resets"] = tile_events == [["removed", subject], ["remove_proximity", subject]] and tiles.values().filter(func(tile): return tile["build"] == null).size() == 3
	tile_events.clear()
	self_tile["build"] = null
	geometry.source_apply_tile_pre_changed(self_tile, null, false, 1, 0, Vector2i(2, 1), tile_lookup, air, false, on_removed, remove_proximity, pre, changed)
	proof["absent_building_only_fires_self_pre_event"] = tile_events.size() == 1 and tile_events[0][0] == "pre"
	# Lookups must happen after removal hooks and as each loop cell is visited.
	# A snapshot of the footprint before callbacks would reset stale Tile objects.
	for tile in tiles.values():
		tile["build"] = subject
		tile["block"] = old_block
	var previous_first: Dictionary = tiles[Vector2i.ZERO]
	var previous_second: Dictionary = tiles[Vector2i(0, 1)]
	var swap_first := func(_building: Object) -> void: tiles[Vector2i.ZERO] = {"x": 0, "y": 0, "build": subject, "block": old_block}
	var swap_second := func(tile: Dictionary) -> void:
		if tile["x"] == 0 and tile["y"] == 0:
			tiles[Vector2i(0, 1)] = {"x": 0, "y": 1, "build": subject, "block": old_block}
	geometry.source_apply_tile_pre_changed(self_tile, subject, true, 3, -1, Vector2i(1, 1), tile_lookup, air, false, swap_first, remove_proximity, pre, swap_second)
	proof["tile_lookups_follow_removal_and_each_proxy_event"] = is_same(previous_first["build"], subject) and is_same(previous_second["build"], subject) and tiles[Vector2i.ZERO]["build"] == null and tiles[Vector2i(0, 1)]["build"] == null
	# Apply the primitive to the actual Main scene Tile store and existing Drill Sprite.
	# Lifecycle callbacks are explicit probes; complete setBlock/removal wiring is deferred.
	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)
	var cell: Vector2i = game.get("drill_pos")
	var sprite: Sprite2D = game.call("block_sprite_at_cell", cell)
	var block: Object = game.get("content_catalog").get_by_id("mechanical-drill")
	var actual_air: Object = terrain.source_world_block_by_field(game.get("content_catalog"), terrain.SOURCE_WORLD_AIR_FIELD)
	var actual_tiles: Dictionary = game.get("source_world_tiles")
	var actual_lookup := func(x: int, y: int) -> Variant: return terrain.source_world_tile(actual_tiles, x, y)
	var footprint: Array = game.call("occupied_cells", cell, block)
	for occupied in footprint:
		actual_lookup.call(occupied.x, occupied.y)["build"] = sprite
	var actual_geometry := terrain.source_block_geometry_state(block, float(game.get("tile_size")))
	var actual_self: Dictionary = actual_lookup.call(cell.x + 1, cell.y + 1)
	var actual_hooks: Array = []
	geometry.source_apply_tile_pre_changed(actual_self, sprite, actual_geometry["is_multiblock"], actual_geometry["size"], actual_geometry["size_offset"], cell, actual_lookup, actual_air, true, func(building): actual_hooks.append(building), func(building): actual_hooks.append(building), pre, changed)
	proof["actual_main_tiles_reset_by_old_drill_footprint"] = footprint.filter(func(occupied): return actual_lookup.call(occupied.x, occupied.y)["build"] == null and is_same(actual_lookup.call(occupied.x, occupied.y)["block"], actual_air)).size() == footprint.size() - 1 and is_same(actual_self["build"], sprite)
	proof["actual_main_old_identity_retained_for_next_phase"] = actual_hooks.size() == 2 and is_same(actual_hooks[0], sprite) and is_same(actual_hooks[1], sprite) and is_instance_valid(sprite)
	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	game.queue_free()
	await get_tree().process_frame
	# Break fixture cycles after assertions; no reference graph leaks into another world.
	for building in [subject, neighbor, twin, enemy, stale]:
		building.proximity.clear()
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("BuildingProximityMutationProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
