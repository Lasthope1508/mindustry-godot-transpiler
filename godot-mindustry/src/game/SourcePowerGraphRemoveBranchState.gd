extends RefCounted
class_name SourcePowerGraphRemoveBranchState

static func remove_branch_seed_state(tile: Dictionary, role_state_callable: Callable) -> Dictionary:
	var branch_seeds: Array = []
	var skipped_others: Array = []
	var queued_positions: Array = []
	var connections: Array = tile.get("connections", [])
	for other_variant in connections:
		if typeof(other_variant) != TYPE_DICTIONARY:
			continue
		var other: Dictionary = other_variant
		var other_pos = other.get("pos", null)
		if not bool(other.get("power_graph_is_self", false)):
			skipped_others.append(other_pos)
			continue
		var add_state: Dictionary = role_state_callable.call(
			bool(other.get("build_present", true)),
			bool(other.get("power_present", true)),
			bool(other.get("graph_matches", false)),
			bool(other.get("power_init", false)),
			bool(other.get("old_graph_present", false)),
			bool(other.get("old_graph_is_self", false)),
			bool(other.get("old_graph_has_entity", false)),
			bool(other.get("outputs_power", false)),
			bool(other.get("consumes_power", false)),
			bool(other.get("has_cons_power", false)),
			bool(other.get("cons_power_buffered", false))
		)
		queued_positions.append(other_pos)
		branch_seeds.append({
			"other": other.duplicate(true),
			"other_pos": other_pos,
			"graph_created": true,
			"check_add_count": 1,
			"add_state": add_state,
			"queued_other": other_pos,
		})
	return {
		"remove_comment": "Note that this does not actually remove the building from the graph;",
		"method": "public void remove(Building tile){",
		"connections_comment": "//go through all the connections of this tile",
		"connections_loop": "for(Building other : tile.getPowerConnections(outArray1)){",
		"skip_comment": "//a graph has already been assigned to this tile from a previous call, skip it",
		"skip_guard": "if(other.power.graph != this) continue;",
		"create_comment": "//create graph for this branch",
		"graph_create": "PowerGraph graph = new PowerGraph();",
		"graph_check_add": "graph.checkAdd();",
		"graph_add_other": "graph.add(other);",
		"queue_comment": "//add to queue for BFS",
		"queue_clear": "queue.clear();",
		"queue_add_other": "queue.addLast(other);",
		"tile": tile.duplicate(true),
		"branch_seeds": branch_seeds,
		"skipped_others": skipped_others,
		"queued_positions": queued_positions,
	}

static func remove_branch_bfs_state(tile: Dictionary, role_state_callable: Callable) -> Dictionary:
	var seed_state := remove_branch_seed_state(tile, role_state_callable)
	var branch_traversals: Array = []
	var visited_positions: Array = []
	var queued_positions: Array = []
	var child_add_states: Array = []
	var next_add_states: Array = []
	var branch_graph_positions: Array = []
	var skipped_next_positions: Array = []
	var tile_pos = tile.get("pos", null)
	for seed_variant in seed_state.get("branch_seeds", []):
		if typeof(seed_variant) != TYPE_DICTIONARY:
			continue
		var seed_entry: Dictionary = seed_variant
		var other: Dictionary = seed_entry.get("other", {})
		var queue: Array = []
		var branch_lookup: Dictionary = {}
		var branch_positions: Array = []
		var other_pos = other.get("pos", seed_entry.get("other_pos", null))
		var other_pos_key := var_to_str(other_pos)
		branch_lookup[other_pos_key] = true
		branch_positions.append(other_pos)
		branch_graph_positions.append(other_pos)
		queue.append(other.duplicate(true))
		queued_positions.append(other_pos)
		var traversal := {
			"other_pos": other_pos,
			"visited_positions": [],
			"queued_positions": [other_pos],
			"branch_graph_positions": [other_pos],
			"skipped_next_positions": [],
		}
		while queue.size() > 0:
			var child_variant = queue.pop_front()
			if typeof(child_variant) != TYPE_DICTIONARY:
				continue
			var child: Dictionary = child_variant
			var child_pos = child.get("pos", null)
			visited_positions.append(child_pos)
			traversal["visited_positions"].append(child_pos)
			child_add_states.append(role_state_callable.call(
				bool(child.get("build_present", true)),
				bool(child.get("power_present", true)),
				true,
				true,
				bool(child.get("old_graph_present", false)),
				bool(child.get("old_graph_is_self", false)),
				bool(child.get("old_graph_has_entity", false)),
				bool(child.get("outputs_power", false)),
				bool(child.get("consumes_power", false)),
				bool(child.get("has_cons_power", false)),
				bool(child.get("cons_power_buffered", false))
			))
			var connections: Array = child.get("connections", [])
			for next_variant in connections:
				if typeof(next_variant) != TYPE_DICTIONARY:
					continue
				var next: Dictionary = next_variant
				var next_pos = next.get("pos", null)
				var next_pos_key := var_to_str(next_pos)
				if next_pos != tile_pos and not branch_lookup.has(next_pos_key):
					var next_add_state: Dictionary = role_state_callable.call(
						bool(next.get("build_present", true)),
						bool(next.get("power_present", true)),
						bool(next.get("graph_matches", false)),
						bool(next.get("power_init", false)),
						bool(next.get("old_graph_present", false)),
						bool(next.get("old_graph_is_self", false)),
						bool(next.get("old_graph_has_entity", false)),
						bool(next.get("outputs_power", false)),
						bool(next.get("consumes_power", false)),
						bool(next.get("has_cons_power", false)),
						bool(next.get("cons_power_buffered", false))
					)
					next_add_states.append(next_add_state)
					branch_lookup[next_pos_key] = true
					branch_positions.append(next_pos)
					branch_graph_positions.append(next_pos)
					traversal["branch_graph_positions"].append(next_pos)
					queued_positions.append(next_pos)
					traversal["queued_positions"].append(next_pos)
					queue.append(next.duplicate(true))
				else:
					skipped_next_positions.append(next_pos)
					traversal["skipped_next_positions"].append(next_pos)
		traversal["branch_positions"] = branch_positions
		branch_traversals.append(traversal)
	return {
		"method": "public void remove(Building tile){",
		"while_queue": "while(queue.size > 0){",
		"get_child_comment": "//get child from queue",
		"remove_first": "Building child = queue.removeFirst();",
		"add_child_comment": "//add it to the new branch graph",
		"graph_add_child": "graph.add(child);",
		"connections_comment": "//go through connections",
		"connections_loop": "for(Building next : child.getPowerConnections(outArray2)){",
		"branch_guard_comment": "//make sure it hasn't looped back, and that the new graph being assigned hasn't already been assigned",
		"skip_closed_comment": "//also skip closed tiles",
		"branch_guard": "if(next != tile && next.power.graph != graph){",
		"graph_add_next": "graph.add(next);",
		"queue_add_next": "queue.addLast(next);",
		"tile": tile.duplicate(true),
		"branch_traversals": branch_traversals,
		"visited_positions": visited_positions,
		"queued_positions": queued_positions,
		"child_add_states": child_add_states,
		"next_add_states": next_add_states,
		"branch_graph_positions": branch_graph_positions,
		"skipped_next_positions": skipped_next_positions,
	}

static func remove_branch_update_state(tile: Dictionary, role_state_callable: Callable) -> Dictionary:
	var bfs_state: Dictionary = remove_branch_bfs_state(tile, role_state_callable)
	var branch_updates: Array = []
	var updated_branch_positions: Array = []
	for traversal_variant in bfs_state.get("branch_traversals", []):
		if typeof(traversal_variant) != TYPE_DICTIONARY:
			continue
		var traversal: Dictionary = traversal_variant
		var branch_positions: Array = traversal.get("branch_positions", [])
		branch_updates.append({
			"other_pos": traversal.get("other_pos", null),
			"branch_positions": branch_positions.duplicate(true),
			"branch_graph_positions": traversal.get("branch_graph_positions", []).duplicate(true),
			"update_dispatched": true,
		})
		updated_branch_positions.append(branch_positions.duplicate(true))
	return {
		"method": "public void remove(Building tile){",
		"update_comment": "//update the graph once so direct consumers without any connected producer lose their power",
		"graph_update": "graph.update();",
		"tile": tile.duplicate(true),
		"branch_updates": branch_updates,
		"branch_update_count": branch_updates.size(),
		"updated_branch_positions": updated_branch_positions,
		"branch_traversals": bfs_state.get("branch_traversals", []),
	}

static func remove_empty_entity_state(tile: Dictionary, entity_present: bool, role_state_callable: Callable) -> Dictionary:
	var update_state := remove_branch_update_state(tile, role_state_callable)
	return {
		"method": "public void remove(Building tile){",
		"empty_graph_comment": "//implied empty graph here",
		"entity_remove_guard": "if(entity != null) entity.remove();",
		"tile": tile.duplicate(true),
		"branch_updates": update_state.get("branch_updates", []),
		"branch_update_count": update_state.get("branch_update_count", 0),
		"updated_branch_positions": update_state.get("updated_branch_positions", []),
		"branch_traversals": update_state.get("branch_traversals", []),
		"entity_removed": entity_present,
	}
