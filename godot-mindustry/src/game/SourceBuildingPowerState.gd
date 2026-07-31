extends RefCounted
class_name SourceBuildingPowerState

const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_power_graph_state := preload("res://src/game/SourcePowerGraphState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func block_properties(block) -> Dictionary:
	return source_block_metadata_state.block_properties(block)

static func block_power_role_state(block) -> Dictionary:
	var properties := block_properties(block)
	var has_power := bool(properties.get("hasPower", source_block_defaults.HAS_POWER_DEFAULT))
	var outputs_power := bool(properties.get("outputsPower", source_block_defaults.OUTPUTS_POWER_DEFAULT))
	var consumes_power := bool(properties.get("consumesPower", source_block_defaults.CONSUMES_POWER_DEFAULT))
	var power_buffered := bool(properties.get("powerBuffered", source_block_defaults.POWER_BUFFERED_DEFAULT))
	var power_usage := float(properties.get("powerUsage", source_block_defaults.POWER_USAGE_DEFAULT))
	var power_capacity := float(properties.get("powerCapacity", source_block_defaults.POWER_CAPACITY_DEFAULT))
	var has_cons_power := has_power and (consumes_power or power_buffered or power_usage > 0.0 or power_capacity > 0.0)
	return source_power_graph_state.add_role_state(
		true,
		has_power or outputs_power,
		false,
		false,
		false,
		false,
		false,
		outputs_power,
		consumes_power,
		has_cons_power,
		power_buffered
	)

static func block_consumer_state(block, source_delta: float) -> Dictionary:
	var properties := block_properties(block)
	var has_power := bool(properties.get("hasPower", source_block_defaults.HAS_POWER_DEFAULT))
	var consumes_power := bool(properties.get("consumesPower", source_block_defaults.CONSUMES_POWER_DEFAULT))
	var power_buffered := bool(properties.get("powerBuffered", source_block_defaults.POWER_BUFFERED_DEFAULT))
	var power_usage := float(properties.get("powerUsage", source_block_defaults.POWER_USAGE_DEFAULT))
	var power_capacity := float(properties.get("powerCapacity", source_block_defaults.POWER_CAPACITY_DEFAULT))
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_POWER_BLOCK_CONSUMER_STATE,
		"block": block,
		"properties": properties.duplicate(true),
		"buffered": power_buffered,
		"usage": power_usage,
		"capacity": power_capacity,
		"power_status": 0.0,
		"should_consume": has_power and consumes_power,
		"shouldConsumePower": has_power and consumes_power,
		"delta": source_delta,
	}

static func block_producer_state(block, source_delta: float) -> Dictionary:
	var properties := block_properties(block)
	var has_power := bool(properties.get("hasPower", source_block_defaults.HAS_POWER_DEFAULT))
	var outputs_power := bool(properties.get("outputsPower", source_block_defaults.OUTPUTS_POWER_DEFAULT))
	var power_production := float(properties.get("powerProduction", source_block_defaults.POWER_PRODUCTION_DEFAULT))
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_POWER_BLOCK_PRODUCER_STATE,
		"block": block,
		"properties": properties.duplicate(true),
		"power_production": power_production,
		"outputs_power": outputs_power,
		"has_power": has_power or outputs_power,
		"delta": source_delta,
	}

static func block_battery_state(block) -> Dictionary:
	var properties := block_properties(block)
	var has_power := bool(properties.get("hasPower", source_block_defaults.HAS_POWER_DEFAULT))
	var outputs_power := bool(properties.get("outputsPower", source_block_defaults.OUTPUTS_POWER_DEFAULT))
	var consumes_power := bool(properties.get("consumesPower", source_block_defaults.CONSUMES_POWER_DEFAULT))
	var power_buffered := bool(properties.get("powerBuffered", source_block_defaults.POWER_BUFFERED_DEFAULT))
	var power_capacity := float(properties.get("powerCapacity", source_block_defaults.POWER_CAPACITY_DEFAULT))
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_POWER_BLOCK_BATTERY_STATE,
		"block": block,
		"properties": properties.duplicate(true),
		"enabled": has_power or outputs_power or consumes_power or power_buffered,
		"power_status": 0.0,
		"capacity": power_capacity,
		"buffered": true,
	}

static func on_proximity_removed_state(power_present: bool) -> Dictionary:
	return {
		"method": "public void onProximityRemoved(){",
		"power_guard": "if(power != null){",
		"power_graph_removed_call": "powerGraphRemoved();",
		"power_present": power_present,
		"power_graph_removed_called": power_present,
	}

static func on_proximity_added_state(power_present: bool) -> Dictionary:
	return {
		"comment": "/** Called after this building is created in the world. May be called multiple times, or when adjacent buildings change. */",
		"todo": "//TODO ??? this is just onProximityUpdate ?",
		"method": "public void onProximityAdded(){",
		"power_guard": "if(power != null){",
		"update_power_graph_call": "updatePowerGraph();",
		"power_present": power_present,
		"update_power_graph_called": power_present,
	}

static func on_proximity_update_state() -> Dictionary:
	return {
		"method": "public void onProximityUpdate(){",
		"no_sleep_call": "noSleep();",
		"no_sleep_called": true,
	}

static func update_power_graph_state(other_power_present_by_index: Array) -> Dictionary:
	var add_graph_called_indices: Array = []
	for index in range(other_power_present_by_index.size()):
		if bool(other_power_present_by_index[index]):
			add_graph_called_indices.append(index)
	return {
		"method": "public void updatePowerGraph(){",
		"connection_loop": "for(Building other : getPowerConnections(tempBuilds)){",
		"power_guard": "if(other.power != null){",
		"add_graph_call": "other.power.graph.addGraph(power.graph);",
		"other_power_present_by_index": other_power_present_by_index.duplicate(true),
		"connection_count": other_power_present_by_index.size(),
		"add_graph_called_indices": add_graph_called_indices,
		"add_graph_call_count": add_graph_called_indices.size(),
	}

static func conducts_to_state(block_insulated: bool) -> Dictionary:
	return {
		"method": "public boolean conductsTo(Building other){",
		"return_not_insulated": "return !block.insulated;",
		"conducts_to": not block_insulated,
		"block_insulated": block_insulated,
	}

static func get_power_connections_empty_guard_state(power_present: bool, previous_out_count: int) -> Dictionary:
	return {
		"method": "public Seq<Building> getPowerConnections(Seq<Building> out){",
		"clear_out": "out.clear();",
		"power_null_guard": "if(power == null) return out;",
		"power_present": power_present,
		"previous_out_count": previous_out_count,
		"out_count_after_clear": 0,
		"returned_out": not power_present,
	}

static func get_power_connections_proximity_guard_state(other_present_by_index: Array, other_power_present_by_index: Array, other_same_team_by_index: Array) -> Dictionary:
	var proximity_guard_pass_indices: Array = []
	for index in range(other_present_by_index.size()):
		var other_present := bool(other_present_by_index[index])
		var other_power_present := index < other_power_present_by_index.size() and bool(other_power_present_by_index[index])
		var other_same_team := index < other_same_team_by_index.size() and bool(other_same_team_by_index[index])
		if other_present and other_power_present and other_same_team:
			proximity_guard_pass_indices.append(index)
	return {
		"method": "public Seq<Building> getPowerConnections(Seq<Building> out){",
		"proximity_loop": "for(Building other : proximity){",
		"other_power_guard": "if(other != null && other.power != null",
		"same_team_guard": "&& other.team == team",
		"other_present_by_index": other_present_by_index.duplicate(true),
		"other_power_present_by_index": other_power_present_by_index.duplicate(true),
		"other_same_team_by_index": other_same_team_by_index.duplicate(true),
		"proximity_guard_pass_indices": proximity_guard_pass_indices,
		"proximity_guard_pass_count": proximity_guard_pass_indices.size(),
		"connection_count": other_present_by_index.size(),
		"deferred_manual_links_loop": true,
	}

static func get_power_connections_power_compatibility_guard_state(block_consumes_power: bool, block_outputs_power: bool, block_conductive_power: bool, other_block_consumes_power_by_index: Array, other_block_outputs_power_by_index: Array, other_block_conductive_power_by_index: Array) -> Dictionary:
	var power_compatibility_pass_indices: Array = []
	for index in range(other_block_consumes_power_by_index.size()):
		var other_consumes := index < other_block_consumes_power_by_index.size() and bool(other_block_consumes_power_by_index[index])
		var other_outputs := index < other_block_outputs_power_by_index.size() and bool(other_block_outputs_power_by_index[index])
		var other_conductive := index < other_block_conductive_power_by_index.size() and bool(other_block_conductive_power_by_index[index])
		var compatible := not (block_consumes_power and other_consumes and not block_outputs_power and not other_outputs and not block_conductive_power and not other_conductive)
		if compatible:
			power_compatibility_pass_indices.append(index)
	return {
		"method": "public Seq<Building> getPowerConnections(Seq<Building> out){",
		"power_compatibility_guard": "&& !(block.consumesPower && other.block.consumesPower && !block.outputsPower && !other.block.outputsPower && !block.conductivePower && !other.block.conductivePower)",
		"block_consumes_power": block_consumes_power,
		"block_outputs_power": block_outputs_power,
		"block_conductive_power": block_conductive_power,
		"other_block_consumes_power_by_index": other_block_consumes_power_by_index.duplicate(true),
		"other_block_outputs_power_by_index": other_block_outputs_power_by_index.duplicate(true),
		"other_block_conductive_power_by_index": other_block_conductive_power_by_index.duplicate(true),
		"power_compatibility_pass_indices": power_compatibility_pass_indices,
		"power_compatibility_pass_count": power_compatibility_pass_indices.size(),
		"connection_count": other_block_consumes_power_by_index.size(),
		"deferred_manual_links_loop": true,
	}

static func get_power_connections_conducts_link_guard_state(conducts_to_other_by_index: Array, other_conducts_to_self_by_index: Array, power_link_contains_other_pos_by_index: Array) -> Dictionary:
	var conducts_link_guard_pass_indices: Array = []
	for index in range(conducts_to_other_by_index.size()):
		var conducts_to_other := index < conducts_to_other_by_index.size() and bool(conducts_to_other_by_index[index])
		var other_conducts_to_self := index < other_conducts_to_self_by_index.size() and bool(other_conducts_to_self_by_index[index])
		var link_contains_other := index < power_link_contains_other_pos_by_index.size() and bool(power_link_contains_other_pos_by_index[index])
		if conducts_to_other and other_conducts_to_self and not link_contains_other:
			conducts_link_guard_pass_indices.append(index)
	return {
		"method": "public Seq<Building> getPowerConnections(Seq<Building> out){",
		"conducts_to_other_guard": "&& conductsTo(other)",
		"other_conducts_to_self_guard": "&& other.conductsTo(self())",
		"duplicate_link_guard": "&& !power.links.contains(other.pos())){",
		"conducts_to_other_by_index": conducts_to_other_by_index.duplicate(true),
		"other_conducts_to_self_by_index": other_conducts_to_self_by_index.duplicate(true),
		"power_link_contains_other_pos_by_index": power_link_contains_other_pos_by_index.duplicate(true),
		"conducts_link_guard_pass_indices": conducts_link_guard_pass_indices,
		"conducts_link_guard_pass_count": conducts_link_guard_pass_indices.size(),
		"connection_count": conducts_to_other_by_index.size(),
		"deferred_manual_links_loop": true,
	}

static func get_power_connections_automatic_add_state(conducts_link_guard_pass_indices: Array, previous_out_count: int) -> Dictionary:
	return {
		"method": "public Seq<Building> getPowerConnections(Seq<Building> out){",
		"out_add_other": "out.add(other);",
		"conducts_link_guard_pass_indices": conducts_link_guard_pass_indices.duplicate(),
		"added_indices": conducts_link_guard_pass_indices.duplicate(),
		"added_count": conducts_link_guard_pass_indices.size(),
		"previous_out_count": previous_out_count,
		"out_count_after_adds": previous_out_count + conducts_link_guard_pass_indices.size(),
		"deferred_manual_links_loop": true,
	}

static func get_power_connections_manual_links_loop_state(link_present_by_index: Array, link_build_present_by_index: Array, link_build_power_present_by_index: Array, link_build_same_team_by_index: Array, previous_out_count: int) -> Dictionary:
	var manual_link_added_indices: Array = []
	for index in range(link_present_by_index.size()):
		var link_present := bool(link_present_by_index[index])
		var link_build_present := index < link_build_present_by_index.size() and bool(link_build_present_by_index[index])
		var link_build_power_present := index < link_build_power_present_by_index.size() and bool(link_build_power_present_by_index[index])
		var link_build_same_team := index < link_build_same_team_by_index.size() and bool(link_build_same_team_by_index[index])
		if link_present and link_build_present and link_build_power_present and link_build_same_team:
			manual_link_added_indices.append(index)
	return {
		"method": "public Seq<Building> getPowerConnections(Seq<Building> out){",
		"manual_links_loop": "for(int i = 0; i < power.links.size; i++){",
		"manual_link_tile_lookup": "Tile link = world.tile(power.links.get(i));",
		"manual_link_add_guard": "if(link != null && link.build != null && link.build.power != null && link.build.team == team) out.add(link.build);",
		"return_out": "return out;",
		"link_present_by_index": link_present_by_index.duplicate(true),
		"link_build_present_by_index": link_build_present_by_index.duplicate(true),
		"link_build_power_present_by_index": link_build_power_present_by_index.duplicate(true),
		"link_build_same_team_by_index": link_build_same_team_by_index.duplicate(true),
		"previous_out_count": previous_out_count,
		"manual_link_added_indices": manual_link_added_indices,
		"manual_link_added_count": manual_link_added_indices.size(),
		"manual_link_count": link_present_by_index.size(),
		"out_count_after_manual_links": previous_out_count + manual_link_added_indices.size(),
	}
