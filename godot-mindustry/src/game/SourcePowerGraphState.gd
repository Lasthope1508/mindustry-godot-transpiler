extends RefCounted
class_name SourcePowerGraphState

const SourceMathDefaultsScript = preload("res://src/game/SourceMathDefaults.gd")
const SOURCE_FLOAT_ROUNDING_ERROR := SourceMathDefaultsScript.FLOAT_ROUNDING_ERROR

static func check_add_state(entity_present: bool) -> Dictionary:
	return {
		"method": "public void checkAdd(){",
		"entity_add_guard": "if(entity != null) entity.add();",
		"entity_add_called": entity_present,
	}

static func clear_state(all: Array, producers: Array, consumers: Array, batteries: Array, entity_present: bool) -> Dictionary:
	var source_all := all.duplicate(true)
	var source_producers := producers.duplicate(true)
	var source_consumers := consumers.duplicate(true)
	var source_batteries := batteries.duplicate(true)
	source_all.clear()
	source_producers.clear()
	source_consumers.clear()
	source_batteries.clear()
	return {
		"method": "public void clear(){",
		"all_clear": "all.clear();",
		"producers_clear": "producers.clear();",
		"consumers_clear": "consumers.clear();",
		"batteries_clear": "batteries.clear();",
		"nothing_left_comment": "//nothing left",
		"entity_remove_guard": "if(entity != null) entity.remove();",
		"all": source_all,
		"producers": source_producers,
		"consumers": source_consumers,
		"batteries": source_batteries,
		"entity_removed": entity_present,
	}

static func add_role_state(build_present: bool, power_present: bool, graph_matches: bool, power_init: bool, old_graph_present: bool, old_graph_is_self: bool, old_graph_has_entity: bool, outputs_power: bool, consumes_power: bool, has_cons_power: bool, cons_power_buffered: bool) -> Dictionary:
	var result := {
		"returned": false,
		"remove_old_graph_entity": false,
		"assign_graph": false,
		"init_power": false,
		"add_all": false,
		"role": "none",
		"add_producer": false,
		"add_consumer": false,
		"add_battery": false,
		"has_cons_power": has_cons_power,
		"power_guard": "if(build == null || build.power == null) return;",
		"add_gate": "if(build.power.graph != this || !build.power.init){",
		"graph_assign": "build.power.graph = this;",
		"init_assign": "build.power.init = true;",
		"all_add": "all.add(build);",
		"producer_consumer_branch": "if(build.block.outputsPower && build.block.consumesPower && !build.block.consPower.buffered){",
		"battery_branch": "}else if(build.block.outputsPower && build.block.consumesPower){",
		"producer_branch": "}else if(build.block.outputsPower){",
		"consumer_branch": "}else if(build.block.consumesPower && build.block.consPower != null){",
	}
	if not build_present or not power_present:
		result["returned"] = true
		return result
	if not graph_matches or not power_init:
		result["remove_old_graph_entity"] = old_graph_present and not old_graph_is_self and old_graph_has_entity
		result["assign_graph"] = true
		result["init_power"] = true
		result["add_all"] = true
		if outputs_power and consumes_power and has_cons_power and not cons_power_buffered:
			result["role"] = "producer_consumer"
			result["add_producer"] = true
			result["add_consumer"] = true
		elif outputs_power and consumes_power:
			result["role"] = "battery"
			result["add_battery"] = true
		elif outputs_power:
			result["role"] = "producer"
			result["add_producer"] = true
		elif consumes_power and has_cons_power:
			result["role"] = "consumer"
			result["add_consumer"] = true
	return result

static func add_graph_state(graph_is_self: bool, graph_all_size: int, all_size: int, graph_has_entity: bool, graph_tiles: Array, role_state_callable: Callable = Callable(SourcePowerGraphState, "add_role_state")) -> Dictionary:
	var tile_add_states: Array = []
	var returned := false
	var delegate_to_other_graph := false
	var remove_graph_entity := false
	var check_add := false
	if graph_is_self:
		returned = true
	elif graph_all_size > all_size:
		returned = true
		delegate_to_other_graph = true
	else:
		remove_graph_entity = graph_has_entity
		for tile in graph_tiles:
			if typeof(tile) != TYPE_DICTIONARY:
				continue
			var add_state: Dictionary = role_state_callable.call(
				bool(tile.get("build_present", true)),
				bool(tile.get("power_present", true)),
				bool(tile.get("graph_matches", false)),
				bool(tile.get("power_init", false)),
				bool(tile.get("old_graph_present", false)),
				bool(tile.get("old_graph_is_self", false)),
				bool(tile.get("old_graph_has_entity", false)),
				bool(tile.get("outputs_power", false)),
				bool(tile.get("consumes_power", false)),
				bool(tile.get("has_cons_power", false)),
				bool(tile.get("cons_power_buffered", false))
			)
			tile_add_states.append(add_state)
		check_add = true
	return {
		"method": "public void addGraph(PowerGraph graph){",
		"self_guard": "if(graph == this) return;",
		"merge_comment": "//merge into other graph instead.",
		"delegate_guard_expr": "if(graph.all.size > all.size){",
		"delegate_call_expr": "graph.addGraph(this);",
		"delegate_return_expr": "return;",
		"remove_comment": "//other entity should be removed as the graph was merged",
		"remove_graph_entity_expr": "if(graph.entity != null) graph.entity.remove();",
		"graph_all_loop_expr": "for(Building tile : graph.all){",
		"add_tile_expr": "add(tile);",
		"check_add_expr": "checkAdd();",
		"graph_is_self": graph_is_self,
		"graph_all_size": graph_all_size,
		"all_size": all_size,
		"graph_has_entity": graph_has_entity,
		"graph_tiles": graph_tiles.duplicate(true),
		"returned": returned,
		"delegate_to_other_graph": delegate_to_other_graph,
		"remove_graph_entity": remove_graph_entity,
		"add_call_count": tile_add_states.size(),
		"tile_add_states": tile_add_states,
		"check_add": check_add,
	}

static func reflow_state(tile: Dictionary, role_state_callable: Callable = Callable(SourcePowerGraphState, "add_role_state")) -> Dictionary:
	var queue: Array = []
	var closed_lookup: Dictionary = {}
	var closed_positions: Array = []
	var queued_positions: Array = []
	var visited_positions: Array = []
	var tile_add_states: Array = []
	var check_add_count := 0
	queue.clear()
	queue.append(tile.duplicate(true))
	closed_lookup.clear()
	while queue.size() > 0:
		var child_variant = queue.pop_front()
		if typeof(child_variant) != TYPE_DICTIONARY:
			continue
		var child: Dictionary = child_variant
		visited_positions.append(child.get("pos", null))
		var add_state: Dictionary = role_state_callable.call(
			bool(child.get("build_present", true)),
			bool(child.get("power_present", true)),
			bool(child.get("graph_matches", false)),
			bool(child.get("power_init", false)),
			bool(child.get("old_graph_present", false)),
			bool(child.get("old_graph_is_self", false)),
			bool(child.get("old_graph_has_entity", false)),
			bool(child.get("outputs_power", false)),
			bool(child.get("consumes_power", false)),
			bool(child.get("has_cons_power", false)),
			bool(child.get("cons_power_buffered", false))
		)
		tile_add_states.append(add_state)
		check_add_count += 1
		var connections: Array = child.get("connections", [])
		for next in connections:
			if typeof(next) != TYPE_DICTIONARY:
				continue
			var next_pos = next.get("pos", null)
			var next_pos_key := var_to_str(next_pos)
			if not closed_lookup.has(next_pos_key):
				closed_lookup[next_pos_key] = true
				closed_positions.append(next_pos)
				queued_positions.append(next_pos)
				queue.append(next.duplicate(true))
	return {
		"method": "public void reflow(Building tile){",
		"queue_clear": "queue.clear();",
		"queue_add_tile": "queue.addLast(tile);",
		"closed_set_clear": "closedSet.clear();",
		"while_queue": "while(queue.size > 0){",
		"remove_first": "Building child = queue.removeFirst();",
		"add_child": "add(child);",
		"check_add": "checkAdd();",
		"connections_loop": "for(Building next : child.getPowerConnections(outArray2)){",
		"closed_set_add": "if(closedSet.add(next.pos())){",
		"queue_add_next": "queue.addLast(next);",
		"tile": tile.duplicate(true),
		"visited_positions": visited_positions,
		"queued_positions": queued_positions,
		"closed_positions": closed_positions,
		"tile_add_states": tile_add_states,
		"check_add_count": check_add_count,
	}

static func remove_list_state(all: Array, producers: Array, consumers: Array, batteries: Array, build) -> Dictionary:
	var source_all := all.duplicate(true)
	var source_producers := producers.duplicate(true)
	var source_consumers := consumers.duplicate(true)
	var source_batteries := batteries.duplicate(true)
	source_all.erase(build)
	source_producers.erase(build)
	source_consumers.erase(build)
	source_batteries.erase(build)
	return {
		"comment": "Used for unit tests only.",
		"method": "public void removeList(Building build){",
		"all_remove": "all.remove(build);",
		"producers_remove": "producers.remove(build);",
		"consumers_remove": "consumers.remove(build);",
		"batteries_remove": "batteries.remove(build);",
		"build": build,
		"all": source_all,
		"producers": source_producers,
		"consumers": source_consumers,
		"batteries": source_batteries,
	}

static func remove_branch_seed_state(tile: Dictionary, role_state_callable: Callable = Callable(SourcePowerGraphState, "add_role_state")) -> Dictionary:
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

static func remove_branch_bfs_state(tile: Dictionary, role_state_callable: Callable = Callable(SourcePowerGraphState, "add_role_state")) -> Dictionary:
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

static func remove_branch_update_state(tile: Dictionary, role_state_callable: Callable = Callable(SourcePowerGraphState, "add_role_state")) -> Dictionary:
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

static func remove_empty_entity_state(tile: Dictionary, entity_present: bool, role_state_callable: Callable = Callable(SourcePowerGraphState, "add_role_state")) -> Dictionary:
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

static func power_needed_state(consumers: Array, requested_power_state: Callable = Callable(SourceConsumePowerState, "requested_power_state")) -> Dictionary:
	var power_needed := 0.0
	var counted_consumers := 0
	var active_consumers := 0
	for consumer in consumers:
		if typeof(consumer) != TYPE_DICTIONARY:
			continue
		counted_consumers += 1
		if bool(consumer.get("shouldConsumePower", false)):
			var requested_state: Dictionary = requested_power_state.call(
				bool(consumer.get("buffered", false)),
				float(consumer.get("usage", 0.0)),
				float(consumer.get("capacity", 0.0)),
				float(consumer.get("power_status", 0.0)),
				bool(consumer.get("should_consume", false))
			)
			power_needed += float(requested_state.get("requested_power", 0.0)) * float(consumer.get("delta", 0.0))
			active_consumers += 1
	return {
		"method": "public float getPowerNeeded(){",
		"initial": "float powerNeeded = 0f;",
		"items": "var items = consumers.items;",
		"loop": "for(int i = 0; i < consumers.size; i++){",
		"consume_power": "var consumePower = consumer.block.consPower;",
		"guard": "if(consumer.shouldConsumePower){",
		"add_expr": "powerNeeded += consumePower.requestedPower(consumer) * consumer.delta();",
		"return_expr": "return powerNeeded;",
		"power_needed": power_needed,
		"consumer_count": counted_consumers,
		"active_consumer_count": active_consumers,
	}

static func power_produced_state(producers: Array) -> Dictionary:
	var power_produced := 0.0
	var counted_producers := 0
	for producer in producers:
		if typeof(producer) != TYPE_DICTIONARY:
			continue
		counted_producers += 1
		power_produced += float(producer.get("power_production", 0.0)) * float(producer.get("delta", 0.0))
	return {
		"method": "public float getPowerProduced(){",
		"initial": "float powerProduced = 0f;",
		"items": "var items = producers.items;",
		"loop": "for(int i = 0; i < producers.size; i++){",
		"producer": "var producer = items[i];",
		"add_expr": "powerProduced += producer.getPowerProduction() * producer.delta();",
		"return_expr": "return powerProduced;",
		"power_produced": power_produced,
		"producer_count": counted_producers,
	}

static func battery_state(batteries: Array) -> Dictionary:
	var stored := 0.0
	var capacity := 0.0
	var total_capacity := 0.0
	var battery_count := 0
	var enabled_count := 0
	for battery in batteries:
		if typeof(battery) != TYPE_DICTIONARY:
			continue
		battery_count += 1
		if bool(battery.get("enabled", false)):
			var power_status := float(battery.get("power_status", 0.0))
			var source_capacity := float(battery.get("capacity", 0.0))
			stored += power_status * source_capacity
			capacity += (1.0 - power_status) * source_capacity
			total_capacity += source_capacity
			enabled_count += 1
	return {
		"stored_method": "public float getBatteryStored(){",
		"stored_initial": "float totalAccumulator = 0f;",
		"capacity_method": "public float getBatteryCapacity(){",
		"capacity_initial": "float totalCapacity = 0f;",
		"total_capacity_method": "public float getTotalBatteryCapacity(){",
		"items": "var items = batteries.items;",
		"loop": "for(int i = 0; i < batteries.size; i++){",
		"battery": "var battery = items[i];",
		"guard": "if(battery.enabled){",
		"stored_add": "totalAccumulator += battery.power.status * battery.block.consPower.capacity;",
		"capacity_add": "totalCapacity += (1f - battery.power.status) * battery.block.consPower.capacity;",
		"total_capacity_add": "totalCapacity += battery.block.consPower.capacity;",
		"stored_return": "return totalAccumulator;",
		"capacity_return": "return totalCapacity;",
		"stored": stored,
		"capacity": capacity,
		"total_capacity": total_capacity,
		"battery_count": battery_count,
		"enabled_count": enabled_count,
	}

static func use_batteries_state(batteries: Array, needed: float) -> Dictionary:
	var source_batteries: Array = []
	for battery in batteries:
		if typeof(battery) != TYPE_DICTIONARY:
			continue
		source_batteries.append(battery.duplicate(true))
	var stored_state := battery_state(source_batteries)
	var stored := float(stored_state.get("stored", 0.0))
	var used := 0.0
	var consumed_power_percentage := 0.0
	var zero_guard_returned: bool = abs(stored - 0.0) <= SOURCE_FLOAT_ROUNDING_ERROR
	if not zero_guard_returned:
		used = min(stored, needed)
		consumed_power_percentage = min(1.0, needed / stored)
		for source_battery_state in source_batteries:
			if bool(source_battery_state.get("enabled", false)):
				var power_status := float(source_battery_state.get("power_status", 0.0))
				source_battery_state["power_status"] = power_status * (1.0 - consumed_power_percentage)
	return {
		"method": "public float useBatteries(float needed){",
		"stored_expr": "float stored = getBatteryStored();",
		"zero_guard": "if(Mathf.equal(stored, 0f)) return 0f;",
		"used_expr": "float used = Math.min(stored, needed);",
		"consumed_percent_expr": "float consumedPowerPercentage = Math.min(1.0f, needed / stored);",
		"items": "var items = batteries.items;",
		"loop": "for(int i = 0; i < batteries.size; i++){",
		"battery": "var battery = items[i];",
		"status_mul": "battery.power.status *= (1f-consumedPowerPercentage);",
		"return_expr": "return used;",
		"mathf_equal": "return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;",
		"needed": needed,
		"stored": stored,
		"used": used,
		"consumed_power_percentage": consumed_power_percentage,
		"zero_guard_returned": zero_guard_returned,
		"batteries": source_batteries,
	}

static func charge_batteries_state(batteries: Array, excess: float) -> Dictionary:
	var source_batteries: Array = []
	for battery in batteries:
		if typeof(battery) != TYPE_DICTIONARY:
			continue
		source_batteries.append(battery.duplicate(true))
	var capacity_state := battery_state(source_batteries)
	var capacity := float(capacity_state.get("capacity", 0.0))
	var charged_percent := 0.0
	var charged := 0.0
	var zero_guard_returned: bool = abs(capacity - 0.0) <= SOURCE_FLOAT_ROUNDING_ERROR
	if not zero_guard_returned:
		charged_percent = min(excess / capacity, 1.0)
		charged = min(excess, capacity)
		for source_battery_state in source_batteries:
			var source_capacity := float(source_battery_state.get("capacity", 0.0))
			if bool(source_battery_state.get("enabled", false)) and source_capacity > 0.0:
				var power_status := float(source_battery_state.get("power_status", 0.0))
				source_battery_state["power_status"] = power_status + (1.0 - power_status) * charged_percent
	return {
		"method": "public float chargeBatteries(float excess){",
		"capacity_expr": "float capacity = getBatteryCapacity();",
		"charged_percent_comment": "//how much of the missing in each battery % is charged",
		"charged_percent_expr": "float chargedPercent = Math.min(excess/capacity, 1f);",
		"zero_guard": "if(Mathf.equal(capacity, 0f)) return 0f;",
		"items": "var items = batteries.items;",
		"loop": "for(int i = 0; i < batteries.size; i++){",
		"battery": "var battery = items[i];",
		"todo": "//TODO why would it be 0",
		"guard": "if(battery.enabled && battery.block.consPower.capacity > 0f){",
		"status_add": "battery.power.status += (1f - battery.power.status) * chargedPercent;",
		"return_expr": "return Math.min(excess, capacity);",
		"mathf_equal": "return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;",
		"excess": excess,
		"capacity": capacity,
		"charged_percent": charged_percent,
		"charged": charged,
		"zero_guard_returned": zero_guard_returned,
		"batteries": source_batteries,
	}

static func distribute_power_state(consumers: Array, needed: float, produced: float, charged: bool, last_power_stored: float) -> Dictionary:
	var source_consumers: Array = []
	for consumer in consumers:
		if typeof(consumer) != TYPE_DICTIONARY:
			continue
		source_consumers.append(consumer.duplicate(true))
	var needed_zero: bool = abs(needed) <= SOURCE_FLOAT_ROUNDING_ERROR
	var produced_zero: bool = abs(produced) <= SOURCE_FLOAT_ROUNDING_ERROR
	var last_power_stored_zero: bool = abs(last_power_stored) <= SOURCE_FLOAT_ROUNDING_ERROR
	var coverage := 0.0
	if needed_zero and produced_zero and not charged and last_power_stored_zero:
		coverage = 0.0
	elif needed_zero:
		coverage = 1.0
	else:
		coverage = min(1.0, produced / needed)
	var buffered_count := 0
	var unbuffered_count := 0
	var nan_guard_count := 0
	for consumer_state in source_consumers:
		var buffered := bool(consumer_state.get("buffered", false))
		var capacity := float(consumer_state.get("capacity", 0.0))
		var delta := float(consumer_state.get("delta", 0.0))
		var power_status := float(consumer_state.get("power_status", 0.0))
		if buffered:
			buffered_count += 1
			if abs(capacity) > SOURCE_FLOAT_ROUNDING_ERROR:
				var requested_power := float(consumer_state.get("requested_power", 0.0))
				var maximum_rate := requested_power * coverage * delta
				consumer_state["maximum_rate"] = maximum_rate
				consumer_state["power_status"] = clamp(power_status + maximum_rate / capacity, 0.0, 1.0)
			continue
		unbuffered_count += 1
		if bool(consumer_state.get("shouldConsumePower", false)):
			consumer_state["power_status"] = coverage
		else:
			var usage := float(consumer_state.get("usage", 0.0))
			var denominator := needed + usage * delta
			var estimated_status := 0.0
			var estimate_nan := false
			if abs(denominator) <= SOURCE_FLOAT_ROUNDING_ERROR:
				if abs(produced) <= SOURCE_FLOAT_ROUNDING_ERROR:
					estimate_nan = true
				elif produced > 0.0:
					estimated_status = 1.0
				else:
					estimated_status = -INF
			else:
				estimated_status = min(1.0, produced / denominator)
			if estimate_nan or is_nan(estimated_status):
				estimated_status = 0.0
				nan_guard_count += 1
			consumer_state["power_status"] = estimated_status
	return {
		"method": "public void distributePower(float needed, float produced, boolean charged){",
		"coverage_expr": "float coverage = Mathf.zero(needed) && Mathf.zero(produced) && !charged && Mathf.zero(lastPowerStored) ? 0f : Mathf.zero(needed) ? 1f : Math.min(1, produced / needed);",
		"items": "var items = consumers.items;",
		"loop": "for(int i = 0; i < consumers.size; i++){",
		"consumer": "var consumer = items[i];",
		"cons": "var cons = consumer.block.consPower;",
		"buffered_gate": "if(cons.buffered){",
		"capacity_zero_guard": "if(!Mathf.zero(cons.capacity)){",
		"maximum_rate_expr": "float maximumRate = cons.requestedPower(consumer) * coverage * consumer.delta();",
		"buffered_status_clamp": "consumer.power.status = Mathf.clamp(consumer.power.status + maximumRate / cons.capacity);",
		"unbuffered_gate": "if(consumer.shouldConsumePower){",
		"unbuffered_coverage_status": "consumer.power.status = coverage;",
		"unbuffered_estimate_status": "consumer.power.status = Math.min(1, produced / (needed + cons.usage * consumer.delta()));",
		"nan_guard": "if(Float.isNaN(consumer.power.status)){",
		"nan_status_zero": "consumer.power.status = 0f;",
		"mathf_zero": "return Math.abs(value) <= FLOAT_ROUNDING_ERROR;",
		"mathf_clamp": "return Math.max(Math.min(value, 1f), 0f);",
		"needed": needed,
		"produced": produced,
		"charged": charged,
		"last_power_stored": last_power_stored,
		"coverage": coverage,
		"consumers": source_consumers,
		"buffered_count": buffered_count,
		"unbuffered_count": unbuffered_count,
		"nan_guard_count": nan_guard_count,
	}

static func update_cheat_state(consumers: Array) -> Dictionary:
	var source_consumers: Array = []
	for consumer in consumers:
		if typeof(consumer) != TYPE_DICTIONARY:
			continue
		source_consumers.append(consumer.duplicate(true))
	var consumers_empty := source_consumers.is_empty()
	var first_cheating := false
	if not consumers_empty:
		first_cheating = bool(source_consumers[0].get("cheating", false))
	var returned := false
	var last_power_needed := 0.0
	var last_power_produced := 0.0
	if not consumers_empty and first_cheating:
		for consumer_state in source_consumers:
			consumer_state["power_status"] = 1.0
		last_power_needed = 1.0
		last_power_produced = 1.0
		returned = true
	return {
		"method": "public void update(){",
		"cheat_gate": "if(!consumers.isEmpty() && consumers.first().cheating()){",
		"cheat_comment": "//when cheating, just set status to 1",
		"loop": "for(Building tile : consumers){",
		"status_assign": "tile.power.status = 1f;",
		"last_power_assign": "lastPowerNeeded = lastPowerProduced = 1f;",
		"return_expr": "return;",
		"consumers_empty": consumers_empty,
		"first_cheating": first_cheating,
		"consumers": source_consumers,
		"returned": returned,
		"last_power_needed": last_power_needed,
		"last_power_produced": last_power_produced,
	}

static func update_balance_state(consumers: Array, producers: Array, batteries: Array, energy_delta: float, source_delta: float, power_balance_samples: Array = [], requested_power_state: Callable = Callable(SourceConsumePowerState, "requested_power_state")) -> Dictionary:
	var source_power_needed_state: Dictionary = {}
	if requested_power_state.is_valid():
		source_power_needed_state = power_needed_state(consumers, requested_power_state)
	var source_power_produced_state := power_produced_state(producers)
	var source_battery_state := battery_state(batteries)
	var power_needed := float(source_power_needed_state.get("power_needed", 0.0))
	var power_produced := float(source_power_produced_state.get("power_produced", 0.0))
	var last_power_needed := power_needed
	var last_power_produced := power_produced
	var last_scaled_power_in := (power_produced + energy_delta) / source_delta
	var last_scaled_power_out := power_needed / source_delta
	var last_capacity := float(source_battery_state.get("total_capacity", 0.0))
	var last_power_stored := float(source_battery_state.get("stored", 0.0))
	var power_balance_value := (last_power_produced - last_power_needed + energy_delta) / source_delta
	var source_power_balance_samples: Array = power_balance_samples.duplicate(true)
	source_power_balance_samples.append(power_balance_value)
	var next_energy_delta := 0.0
	return {
		"method": "public void update(){",
		"power_needed_expr": "float powerNeeded = getPowerNeeded();",
		"power_produced_expr": "float powerProduced = getPowerProduced();",
		"last_power_needed_expr": "lastPowerNeeded = powerNeeded;",
		"last_power_produced_expr": "lastPowerProduced = powerProduced;",
		"last_scaled_power_in_expr": "lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta;",
		"last_scaled_power_out_expr": "lastScaledPowerOut = powerNeeded / Time.delta;",
		"last_capacity_expr": "lastCapacity = getTotalBatteryCapacity();",
		"last_power_stored_expr": "lastPowerStored = getBatteryStored();",
		"power_balance_expr": "powerBalance.add((lastPowerProduced - lastPowerNeeded + energyDelta) / Time.delta);",
		"energy_delta_zero_expr": "energyDelta = 0f;",
		"power_needed": power_needed,
		"power_produced": power_produced,
		"last_power_needed": last_power_needed,
		"last_power_produced": last_power_produced,
		"last_scaled_power_in": last_scaled_power_in,
		"last_scaled_power_out": last_scaled_power_out,
		"last_capacity": last_capacity,
		"last_power_stored": last_power_stored,
		"power_balance_value": power_balance_value,
		"power_balance_samples": source_power_balance_samples,
		"energy_delta": next_energy_delta,
		"source_delta": source_delta,
	}

static func update_battery_distribute_state(consumers: Array, producers: Array, batteries: Array, power_needed: float, power_produced: float, last_power_produced: float, last_power_stored: float) -> Dictionary:
	var source_consumers: Array = []
	for consumer in consumers:
		if typeof(consumer) != TYPE_DICTIONARY:
			continue
		source_consumers.append(consumer.duplicate(true))
	var source_producers: Array = []
	for producer in producers:
		if typeof(producer) != TYPE_DICTIONARY:
			continue
		source_producers.append(producer.duplicate(true))
	var source_batteries: Array = []
	for battery in batteries:
		if typeof(battery) != TYPE_DICTIONARY:
			continue
		source_batteries.append(battery.duplicate(true))
	var branch_entered: bool = not (source_consumers.is_empty() and source_producers.is_empty() and source_batteries.is_empty())
	var charged := false
	var power_battery_used := 0.0
	var power_battery_charged := 0.0
	var next_power_produced := power_produced
	var next_last_power_produced := last_power_produced
	var coverage := 0.0
	if branch_entered:
		if abs(power_needed - next_power_produced) > SOURCE_FLOAT_ROUNDING_ERROR:
			if power_needed > next_power_produced:
				var use_state := use_batteries_state(source_batteries, power_needed - next_power_produced)
				power_battery_used = float(use_state.get("used", 0.0))
				source_batteries = use_state.get("batteries", source_batteries)
				next_power_produced += power_battery_used
				next_last_power_produced += power_battery_used
			elif next_power_produced > power_needed:
				charged = true
				var charge_state := charge_batteries_state(source_batteries, next_power_produced - power_needed)
				power_battery_charged = float(charge_state.get("charged", 0.0))
				source_batteries = charge_state.get("batteries", source_batteries)
				next_power_produced -= power_battery_charged
		var distribute_state := distribute_power_state(source_consumers, power_needed, next_power_produced, charged, last_power_stored)
		source_consumers = distribute_state.get("consumers", source_consumers)
		coverage = float(distribute_state.get("coverage", 0.0))
	return {
		"method": "public void update(){",
		"nonempty_guard": "if(!(consumers.size == 0 && producers.size == 0 && batteries.size == 0)){",
		"charged_init": "boolean charged = false;",
		"unequal_guard_expr": "if(!Mathf.equal(powerNeeded, powerProduced)){",
		"deficit_gate": "if(powerNeeded > powerProduced){",
		"power_battery_used_expr": "float powerBatteryUsed = useBatteries(powerNeeded - powerProduced);",
		"power_produced_battery_add_expr": "powerProduced += powerBatteryUsed;",
		"last_power_produced_battery_add_expr": "lastPowerProduced += powerBatteryUsed;",
		"surplus_gate": "}else if(powerProduced > powerNeeded){",
		"charged_true_expr": "charged = true;",
		"power_produced_charge_sub_expr": "powerProduced -= chargeBatteries(powerProduced - powerNeeded);",
		"distribute_power_expr": "distributePower(powerNeeded, powerProduced, charged);",
		"mathf_equal": "return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;",
		"branch_entered": branch_entered,
		"charged": charged,
		"power_battery_used": power_battery_used,
		"power_battery_charged": power_battery_charged,
		"power_needed": power_needed,
		"power_produced": next_power_produced,
		"last_power_produced": next_last_power_produced,
		"last_power_stored": last_power_stored,
		"coverage": coverage,
		"consumers": source_consumers,
		"producers": source_producers,
		"batteries": source_batteries,
	}

static func get_id_state(graph_id: int) -> Dictionary:
	return {
		"method": "public int getId(){",
		"return_graph_id": "return graphID;",
		"graph_id": graph_id,
	}

static func generated_get_id_bridge_state(graph_id: int) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/blocks/power/PowerGraph.gd")
	var instance = script.new()
	var result = instance.java_method_getId_27([graph_id])
	var canonical = get_id_state(graph_id)
	return {
		"source_owner": "SourcePowerGraphState.get_id_state",
		"generated_owner": "PowerGraph.getId",
		"result": result,
		"canonical": canonical,
		"matches": result.get("graph_id", null) == canonical.get("graph_id", null) and result.get("return_graph_id", null) == canonical.get("return_graph_id", null),
	}

static func to_string_state(producers: String, consumers: String, batteries: String, all: String, graph_id: int) -> String:
	return "PowerGraph{producers=" + producers + ", consumers=" + consumers + ", batteries=" + batteries + ", all=" + all + ", graphID=" + str(graph_id) + "}"
