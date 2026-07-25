extends RefCounted
class_name SourceBuildingLifecycleState

const SOURCE_BUILDING_UPDATE_TILE_GATE_METHOD := "public void update(){"
const SOURCE_BUILDING_UPDATE_TILE_GATE_GUARD := "if(enabled || !block.noUpdateDisabled){"
const SOURCE_BUILDING_UPDATE_TILE_GATE_CALL := "updateTile();"

static func _building_comp_instance():
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
	return script.new()

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"chance_delta_threshold": Callable(game, "source_arc_chance_delta_threshold"),
	}

static func config_default() -> Variant:
	return null

static func is_valid(tile_build_matches_self: bool, dead_state: bool) -> bool:
	return tile_build_matches_self and not dead_state

static func heal_state(_amount: Variant = null) -> Dictionary:
	return {
		"amount": _amount,
		"health_changed": true,
	}

static func kill_state(self_state := {}) -> Dictionary:
	return {
		"method": "public void kill(){",
		"build_destroyed_call": "Call.buildDestroyed(self());",
		"self_state": self_state,
		"call": "buildDestroyed",
		"self": self_state,
	}

static func killed_initial_side_effects_state(tile_value: Variant) -> Dictionary:
	return {
		"method": "public void killed(){",
		"tile_value": tile_value,
		"dead": true,
		"event": {"type": "BlockDestroyEvent", "tile": tile_value},
		"on_destroyed_called": true,
		"next_step": "tile_remove_gate",
	}

static func killed_removal_side_effects_state(tile_not_empty_tile: bool) -> Dictionary:
	return {
		"method": "public void killed(){",
		"tile_not_empty_tile": tile_not_empty_tile,
		"tile_remove_gate": tile_not_empty_tile,
		"tile_remove_called": tile_not_empty_tile,
		"remove_called": true,
		"after_destroyed_called": true,
	}

static func change_team_delegate_state(next_team: Variant) -> Dictionary:
	return {
		"next_team": next_team,
		"delegates_to_change_team": true,
		"update_power": true,
	}

static func change_team_initial_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool) -> Dictionary:
	if current_team == next_team:
		return {
			"team": current_team,
			"last_team": current_team,
			"returned": true,
			"remove_index": false,
			"assign_next": false,
		}
	var team_after_force = force_team if force_team != null else current_team
	var last_team = team_after_force
	if last_team == next_team:
		return {
			"team": team_after_force,
			"last_team": last_team,
			"returned": true,
			"remove_index": false,
			"assign_next": false,
		}
	return {
		"team": next_team,
		"last_team": last_team,
		"returned": false,
		"remove_index": was_valid,
		"assign_next": true,
	}

static func change_team_power_proximity_state(power_present: bool, update_power: bool, old_graph: Variant, team: Variant) -> Dictionary:
	if power_present and update_power:
		return {
			"old_graph": old_graph,
			"team": team,
			"proximity_reflow": true,
		}
	return {
		"old_graph": old_graph,
		"team": team,
		"proximity_reflow": false,
	}

static func change_team_power_links_state(link_count: int, team: Variant, old_graph: Variant) -> Dictionary:
	if link_count <= 0:
		return {
			"link_count": link_count,
			"team": team,
			"old_graph": old_graph,
			"remove_index": false,
			"reflow_self": false,
			"update_power_graph": false,
		}
	return {
		"link_count": link_count,
		"team": team,
		"old_graph": old_graph,
		"remove_index": true,
		"reflow_self": true,
		"update_power_graph": true,
	}

static func change_team_final_state(was: bool, last_team: Variant) -> Dictionary:
	return {
		"was": was,
		"add_index": was,
		"team_change_event": was,
		"event_last": last_team,
		"check_allow_update": true,
	}

static func can_pickup_state(block_can_pickup: bool) -> bool:
	return block_can_pickup

static func picked_up_state(previous_state: Variant) -> Dictionary:
	return {
		"method": "public void pickedUp(){",
		"comment": "Called right before this building is picked up.",
		"no_op": true,
		"previous_state": previous_state,
	}

static func after_picked_up_state(power_present: bool, has_cons_power: bool, cons_power_buffered: bool, current_status: float) -> Dictionary:
	if power_present and has_cons_power and not cons_power_buffered:
		return {
			"power_present": power_present,
			"new_power_graph": power_present,
			"clear_links": power_present,
			"status": 0.0,
		}
	return {
		"power_present": power_present,
		"new_power_graph": power_present,
		"clear_links": power_present,
		"status": current_status,
	}

static func check_allow_update_state(current_enabled: bool, allow_update_result: bool) -> Dictionary:
	if not allow_update_result:
		return {"enabled": false, "changed": current_enabled}
	return {"enabled": current_enabled, "changed": false}

static func update_tile_gate_state(enabled_state: bool, block_no_update_disabled: bool) -> Dictionary:
	var update_tile_called: bool = enabled_state or not block_no_update_disabled
	return {"update_tile_called": update_tile_called}

static func is_heal_suppressed_state(block_suppressable: bool, source_time: float, heal_suppression_time: float) -> bool:
	return block_suppressable and source_time <= heal_suppression_time

static func check_suppression_state(block_suppressable: bool, source_time: float, heal_suppression_time: float, source_delta: float, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, suppress_color: String, chance_delta_threshold: Callable) -> Dictionary:
	var suppressed := is_heal_suppressed_state(block_suppressable, source_time, heal_suppression_time)
	if not suppressed:
		return {"suppressed": false, "particle_visible": false}
	var particle_range := block_size_value * source_tilesize / 2.0 - 1.0
	var chance_threshold := float(chance_delta_threshold.call(0.03, source_delta))
	return {"suppressed": true, "particle_visible": "chanceDelta", "chance_threshold": chance_threshold, "effect": "regenSuppressParticle", "color": suppress_color, "particle_range": particle_range, "x_min": source_x - particle_range, "x_max": source_x + particle_range, "y_min": source_y - particle_range, "y_max": source_y + particle_range}

static func generated_check_suppression_bridge_state(block_suppressable: bool, source_time: float, heal_suppression_time: float, source_delta: float, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, suppress_color: String) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_checkSuppression_136([block_suppressable, source_time, heal_suppression_time, source_delta, source_x, source_y, block_size_value, source_tilesize, suppress_color])
	return {
		"source_owner": "PortGame.source_building_check_suppression_state",
		"generated_owner": "BuildingComp.java_method_checkSuppression_136",
		"result": result,
	}

static func player_placed_state(config_state: Variant) -> Dictionary:
	return {
		"method": "public void playerPlaced(Object config){",
		"comment": "Called after the block is placed by this client.",
		"call_super": "@CallSuper",
		"no_op": true,
		"config_state": config_state,
	}

static func generated_player_placed_bridge_state(config_state: Variant) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_playerPlaced_137([config_state])
	return {
		"source_owner": "PortGame.source_building_player_placed_state",
		"generated_owner": "BuildingComp.java_method_playerPlaced_137",
		"result": result,
	}

static func placed_state(net_client: bool, consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, linked_to_self: bool, source_pos: int) -> Dictionary:
	var should_link_power := (consumes_power or outputs_power) and has_power and connected_power
	if net_client:
		return {"method": "public void placed(){", "comment": "Called after the block is placed by anyone.", "call_super": "@CallSuper", "client_guard": "if(net.client()) return;" if net_client else "", "power_gate": "", "power_node_scan": "", "link_guard": "", "configure_call": "", "returned": true, "power_link_scan": false, "configure": false, "configure_pos": -1}
	if not should_link_power:
		return {"method": "public void placed(){", "comment": "Called after the block is placed by anyone.", "call_super": "@CallSuper", "client_guard": "if(net.client()) return;" if net_client else "", "power_gate": "if((block.consumesPower || block.outputsPower) && block.hasPower && block.connectedPower){" if should_link_power else "", "power_node_scan": "PowerNode.getNodeLinks(tile, block, team, other -> {" if should_link_power else "", "link_guard": "if(!other.power.links.contains(pos())){" if should_link_power else "", "configure_call": "", "returned": false, "power_link_scan": false, "configure": false, "configure_pos": -1}
	var configure := not linked_to_self
	return {"method": "public void placed(){", "comment": "Called after the block is placed by anyone.", "call_super": "@CallSuper", "client_guard": "if(net.client()) return;" if net_client else "", "power_gate": "if((block.consumesPower || block.outputsPower) && block.hasPower && block.connectedPower){" if should_link_power else "", "power_node_scan": "PowerNode.getNodeLinks(tile, block, team, other -> {" if should_link_power else "", "link_guard": "if(!other.power.links.contains(pos())){" if should_link_power else "", "configure_call": "other.configureAny(pos());" if configure else "", "returned": false, "power_link_scan": true, "configure": configure, "configure_pos": source_pos if configure else -1}

static func generated_placed_bridge_state(net_client: bool, consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, linked_to_self: bool, source_pos: int) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_placed_138([net_client, consumes_power, outputs_power, has_power, connected_power, linked_to_self, source_pos])
	return {
		"source_owner": "PortGame.source_building_placed_state",
		"generated_owner": "BuildingComp.java_method_placed_138",
		"result": result,
	}

static func on_repaired_state(has_fog_radius: bool) -> Dictionary:
	return {
		"method": "public void onRepaired(){",
		"call_super": "@CallSuper",
		"placed_call": "placed();",
		"fog_gate": "if(block.flags.contains(BlockFlag.hasFogRadius)){" if has_fog_radius else "",
		"fog_call": "fogControl.forceUpdate(team, self());" if has_fog_radius else "",
		"has_fog_radius": has_fog_radius,
		"placed": true,
		"fog_force_update": has_fog_radius,
	}

static func generated_on_repaired_bridge_state(has_fog_radius: bool) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_onRepaired_139([has_fog_radius])
	return {
		"source_owner": "PortGame.source_building_on_repaired_state",
		"generated_owner": "BuildingComp.java_method_onRepaired_139",
		"result": result,
	}

const SOURCE_BUILDING_UPDATE_PROXIMITY_METHOD := "public void updateProximity(){"
const SOURCE_BUILDING_UPDATE_PROXIMITY_TMP_CLEAR := "tmpTiles.clear();"
const SOURCE_BUILDING_UPDATE_PROXIMITY_PROXIMITY_CLEAR := "proximity.clear();"
const SOURCE_BUILDING_UPDATE_PROXIMITY_EDGES := "Point2[] nearby = Edges.getEdges(block.size);"
const SOURCE_BUILDING_UPDATE_PROXIMITY_WORLD_BUILD := "Building other = world.build(tile.x + point.x, tile.y + point.y);"
const SOURCE_BUILDING_UPDATE_PROXIMITY_TEAM_GUARD := "if(other == null || other.team != team) continue;"
const SOURCE_BUILDING_UPDATE_PROXIMITY_ADD_UNIQUE := "other.proximity.addUnique(self());"
const SOURCE_BUILDING_UPDATE_PROXIMITY_TMP_ADD := "tmpTiles.add(other);"
const SOURCE_BUILDING_UPDATE_PROXIMITY_ADD_SELF := "proximity.add(tile);"
const SOURCE_BUILDING_UPDATE_PROXIMITY_ADDED := "onProximityAdded();"
const SOURCE_BUILDING_UPDATE_PROXIMITY_UPDATE := "onProximityUpdate();"
const SOURCE_BUILDING_UPDATE_PROXIMITY_OTHER_UPDATE := "other.onProximityUpdate();"
const SOURCE_BUILDING_UPDATE_PROXIMITY_RECACHE := "if(!headless && block.drawCached) recache();"

static func remove_from_proximity_state(nearby_count: int, removable_count: int) -> Dictionary:
	return {
		"method": "public void removeFromProximity(){",
		"on_proximity_removed_call": "onProximityRemoved();",
		"tmp_tiles_clear_call": "tmpTiles.clear();",
		"edges_get_call": "Point2[] nearby = Edges.getEdges(block.size);",
		"world_build_call": "Building other = world.build(tile.x + point.x, tile.y + point.y);",
		"tmp_tiles_add_call": "tmpTiles.add(other);",
		"remove_self_call": "other.proximity.remove(self(), true);",
		"other_update_call": "other.onProximityUpdate();",
		"proximity_clear_call": "proximity.clear();",
		"on_proximity_removed": true,
		"tmp_tiles_cleared": true,
		"nearby_count": nearby_count,
		"queued_removals": clampi(removable_count, 0, nearby_count),
		"proximity_updates": clampi(removable_count, 0, nearby_count),
		"proximity_cleared": true,
	}

static func update_proximity_state(nearby_count: int, same_team_count: int, headless: bool, draw_cached: bool) -> Dictionary:
	return {
		"tmp_tiles_cleared": true,
		"proximity_cleared": true,
		"nearby_count": nearby_count,
		"same_team_count": clampi(same_team_count, 0, nearby_count),
		"add_unique_calls": clampi(same_team_count, 0, nearby_count),
		"on_proximity_added": true,
		"self_proximity_update": true,
		"other_proximity_updates": clampi(same_team_count, 0, nearby_count),
		"recache": (not headless) and draw_cached,
	}

static func on_nearby_build_added_state(other_state: Variant) -> Dictionary:
	return {
		"method": "public void onNearbyBuildAdded(Building other){}",
		"no_op": true,
		"other_state": other_state,
	}
