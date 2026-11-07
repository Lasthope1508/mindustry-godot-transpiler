extends Node

const geometry := preload("res://src/game/SourceBlockGeometry.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

class Building extends RefCounted:
	var name: String
	var team: Object
	var proximity: Array = []
	var changing: bool = false
	func _init(value: String, team_value: Object) -> void:
		name = value
		team = team_value


func _tile(x: int, y: int, build: Variant, block: Variant) -> Dictionary:
	return {"x": x, "y": y, "build": build, "block": block, "changing": false}


func _ready() -> void:
	var proof: Dictionary = {}
	var team := RefCounted.new()
	var force_team := RefCounted.new()
	var air := RefCounted.new()
	var old_block := RefCounted.new()
	var new_block := RefCounted.new()
	var d4: Array = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]

	# --- N2029 changeBuild ---
	var old_build := Building.new("old", team)
	var edge_a := Building.new("edge_a", team)
	var edge_b := Building.new("edge_b", team)
	var build_lookup: Dictionary = {Vector2i(12, 10): edge_a, Vector2i(11, 9): edge_a, Vector2i(12, 11): edge_b}
	var world_build := func(x: int, y: int) -> Variant: return build_lookup.get(Vector2i(x, y))
	var events: Array = []
	var removed := func(building: Object) -> void: events.append(["remove", building.name])
	var updated := func(building: Object) -> void: events.append(["update", building.name])
	var created := Building.new("created", team)
	var init_calls: Array = []
	var provider := func() -> Variant: return created
	var entity_init := func(building: Variant, tile: Dictionary, init_team: Variant, init_update: bool, init_rotation: int) -> Variant:
		init_calls.append([building.name, init_team, init_update, init_rotation])
		return building
	var self_tile := _tile(10, 10, old_build, old_block)
	geometry.source_apply_tile_change_build(self_tile, old_build, 2, true, true, team, 3, false, world_build, removed, updated, provider, entity_init)
	proof["change_build_removes_old_and_updates_unique_edges"] = events == [["remove", "old"], ["update", "edge_a"], ["update", "edge_b"]] and self_tile["build"] == created
	proof["change_build_init_flag_true_outside_editor"] = init_calls == [["created", team, true, 3]]
	events.clear()
	init_calls.clear()
	var second_tile := _tile(20, 20, old_build, old_block)
	geometry.source_apply_tile_change_build(second_tile, old_build, 1, true, true, team, 0, true, world_build, removed, updated, provider, entity_init)
	proof["change_build_init_flag_false_in_editor"] = init_calls == [["created", team, false, 0]]
	events.clear()
	init_calls.clear()
	var absent_tile := _tile(30, 30, null, old_block)
	geometry.source_apply_tile_change_build(absent_tile, null, 1, true, false, team, 1, false, world_build, removed, updated, provider, entity_init)
	proof["change_build_absent_old_still_inits"] = events.is_empty() and init_calls == [["created", team, false, 1]] and absent_tile["build"] == created
	events.clear()
	init_calls.clear()
	var plain_tile := _tile(40, 40, old_build, old_block)
	geometry.source_apply_tile_change_build(plain_tile, old_build, 1, false, true, team, 0, false, world_build, removed, updated, provider, entity_init)
	proof["change_build_no_building_leaves_null"] = init_calls.is_empty() and plain_tile["build"] == null and events == [["remove", "old"]]

	# --- N2030 changed ---
	events.clear()
	var changed_tile := _tile(10, 10, old_build, old_block)
	var fire_changed := func(tile: Dictionary) -> void: events.append(["fire_changed", tile["x"], tile["y"]])
	var recache := func(tile: Dictionary) -> void: events.append(["recache", tile["x"], tile["y"]])
	var neighbour_lookup: Dictionary = {Vector2i(11, 10): edge_a, Vector2i(10, 11): edge_b, Vector2i(9, 10): null}
	var neighbour_build := func(x: int, y: int) -> Variant: return neighbour_lookup.get(Vector2i(x, y))
	edge_a.changing = false
	edge_b.changing = false
	var on_update := func(building: Object) -> void: events.append(["on_update", building.name])
	var neighbour_changing := func(building: Object) -> bool: return building.changing
	geometry.source_apply_tile_changed(changed_tile, false, true, neighbour_build, d4, neighbour_changing, updated, on_update, fire_changed, recache)
	proof["changed_build_updates_proximity_fires_and_recaches"] = events == [["update", "old"], ["fire_changed", 10, 10], ["recache", 10, 10]]
	events.clear()
	var empty_tile := _tile(10, 10, null, old_block)
	edge_a.changing = false
	edge_b.changing = true
	geometry.source_apply_tile_changed(empty_tile, false, false, neighbour_build, d4, neighbour_changing, updated, on_update, fire_changed, recache)
	proof["changed_absent_build_updates_only_non_changing_neighbours"] = events == [["on_update", "edge_a"], ["fire_changed", 10, 10]]
	events.clear()
	geometry.source_apply_tile_changed(changed_tile, true, true, neighbour_build, d4, neighbour_changing, updated, on_update, fire_changed, recache)
	proof["changed_generating_suppresses_proximity_and_event_but_recaches"] = events == [["recache", 10, 10]]

	# --- N2031 setBlock, full two-pass composition ---
	var proxy_a := Building.new("proxy_a", team)
	var proxy_b := Building.new("proxy_b", team)
	var proxy_c := Building.new("proxy_c", team)
	var tiles: Dictionary = {}
	for x in range(4, 8):
		for y in range(4, 8):
			tiles[Vector2i(x, y)] = _tile(x, y, null, old_block)
	tiles[Vector2i(5, 5)] = _tile(5, 5, old_build, old_block)
	tiles[Vector2i(5, 6)] = _tile(5, 6, proxy_a, old_block)
	tiles[Vector2i(6, 5)] = _tile(6, 5, proxy_b, old_block)
	tiles[Vector2i(6, 6)] = _tile(6, 6, proxy_c, old_block)
	var tile_lookup := func(x: int, y: int) -> Variant: return tiles.get(Vector2i(x, y))
	var set_block_build_lookup: Dictionary = {Vector2i(6, 5): proxy_b}
	var set_block_world_build := func(x: int, y: int) -> Variant: return set_block_build_lookup.get(Vector2i(x, y))
	events.clear()
	init_calls.clear()
	var set_events: Array = []
	var on_removed := func(building: Object) -> void: set_events.append("removed")
	var remove_proximity := func(building: Object) -> void: set_events.append("remove_proximity")
	var pre := func(tile: Dictionary) -> void: set_events.append("pre")
	var changed_event := func(tile: Dictionary) -> void: set_events.append("changed_event")
	var remove_call := func(building: Object) -> void: set_events.append("remove")
	var update_call := func(building: Object) -> void: set_events.append("update:" + building.name)
	var on_update_call := func(building: Object) -> void: set_events.append("on_update:" + building.name)
	var provide_call := func() -> Variant: set_events.append("provide"); return created
	var init_call := func(building: Variant, tile: Dictionary, init_team: Variant, init_update: bool, init_rotation: int) -> Variant:
		set_events.append("init")
		init_calls.append([init_team, init_update, init_rotation])
		return building
	var team_call := func(building: Object, assigned_team: Variant) -> void: set_events.append("team")
	var recache_call := func(tile: Dictionary) -> void: set_events.append("recache")
	var recache_wall_call := func(tile: Dictionary) -> void: set_events.append("recache_wall")
	var air_call := func(tile: Dictionary) -> void:
		set_events.append("air:%d,%d" % [tile["x"], tile["y"]])
		tile["build"] = null
		tile["block"] = air
	var block_changed_call := func(block: Variant, tile: Dictionary) -> void: set_events.append("block_changed")
	var set_tile: Dictionary = tiles[Vector2i(5, 5)]
	geometry.source_apply_tile_set_block(set_tile, new_block, team, 5, false, false, true, force_team, false, old_build, false, 1, 0, Vector2i(5, 5), tile_lookup, set_block_world_build, air, on_removed, remove_proximity, remove_call, pre, changed_event, true, true, false, update_call, on_update_call, provide_call, init_call, team_call, d4, neighbour_changing, recache_call, recache_wall_call, air_call, true, 2, block_changed_call)
	proof["set_block_full_order_and_multiblock_two_pass"] = set_events == ["pre", "removed", "remove_proximity", "remove", "update:proxy_b", "provide", "init", "team", "air:5,6", "air:6,5", "air:6,6", "update:created", "changed_event", "block_changed"] and set_tile["block"] == new_block and set_tile["build"] == created and set_tile["changing"] == false
	proof["set_block_proxies_assigned_new_entity_and_block"] = tiles[Vector2i(5, 6)]["build"] == created and tiles[Vector2i(5, 6)]["block"] == new_block and tiles[Vector2i(6, 5)]["build"] == created and tiles[Vector2i(6, 6)]["block"] == new_block
	proof["set_block_rotation_normalized_and_force_team_used"] = init_calls == [[force_team, true, 1]]
	# Static guard + single-block case.
	set_events.clear()
	init_calls.clear()
	var single_tile := _tile(10, 10, old_build, old_block)
	geometry.source_apply_tile_set_block(single_tile, new_block, team, 0, false, true, false, null, false, old_build, false, 1, 0, Vector2i(10, 10), tile_lookup, set_block_world_build, air, on_removed, remove_proximity, remove_call, pre, changed_event, false, false, false, update_call, on_update_call, provide_call, init_call, team_call, d4, neighbour_changing, recache_call, recache_wall_call, air_call, false, 1, block_changed_call)
	proof["set_block_static_guard_recaches_once_and_single_block_skips_passes"] = set_events[0] == "recache" and set_events[1] == "recache_wall" and not set_events.any(func(event): return str(event).begins_with("air:")) and single_tile["build"] == null and single_tile["block"] == new_block
	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("TileChangeBuildSetBlockProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
