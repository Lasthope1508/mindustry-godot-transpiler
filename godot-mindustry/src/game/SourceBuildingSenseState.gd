extends RefCounted
class_name SourceBuildingSenseState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")

const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_SENSE_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_SENSE_JAVA_METHOD
const SOURCE_BUILDING_SENSE_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_SENSE_GENERATED_OWNER
const SOURCE_BUILDING_SENSE_OBJECT_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_SENSE_OBJECT_JAVA_METHOD
const SOURCE_BUILDING_SENSE_OBJECT_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_SENSE_OBJECT_GENERATED_OWNER
const SOURCE_BUILDING_SENSE_CONTENT_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_SENSE_CONTENT_JAVA_METHOD
const SOURCE_BUILDING_SENSE_CONTENT_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_SENSE_CONTENT_GENERATED_OWNER

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func _sense_method_state() -> Dictionary:
	return {
		"method": "public double sense(LAccess sensor){",
	}

static func sense_position_state(world_x: float, world_y: float, source_tilesize: float) -> Dictionary:
	return {
		"method": "public double sense(LAccess sensor){",
		"switch_case": "return switch(sensor){",
		"x_case": "case x -> World.conv(x);",
		"y_case": "case y -> World.conv(y);",
		"world_conv_method": "public static float conv(float coord){",
		"world_conv_return": "return coord / tilesize;",
		"world_x": world_x,
		"world_y": world_y,
		"source_tilesize": source_tilesize,
		"x": world_x / source_tilesize,
		"y": world_y / source_tilesize,
	}

static func sense_health_process_state(health: float, max_health: float, efficiency: float, time_scale: float, ranged_range: float, source_tilesize: float, has_range: bool, rotation_value: float) -> Dictionary:
	var source_state := {
		"method": "public double sense(LAccess sensor){",
		"health_case": "case health -> health;",
		"max_health_case": "case maxHealth -> maxHealth;",
		"efficiency_case": "case efficiency -> efficiency;",
		"timescale_case": "case timescale -> timeScale;",
		"range_case": "case range -> this instanceof Ranged r ? r.range() / tilesize : 0;",
		"rotation_case": "case rotation -> rotation;",
	}
	source_state["health"] = health
	source_state["max_health"] = max_health
	source_state["efficiency"] = efficiency
	source_state["timescale"] = time_scale
	source_state["range"] = ranged_range / source_tilesize if has_range else 0.0
	source_state["rotation"] = rotation_value
	return source_state

static func sense_totals_state(total_items: float, total_liquids: float, total_power: float) -> Dictionary:
	return {
		"method": "public double sense(LAccess sensor){",
		"total_items_case": "case totalItems -> items == null ? 0 : items.total();",
		"total_liquids_comment": "//totalLiquids is inherently bad design, but unfortunately it is useful for conduits/tanks",
		"total_liquids_case": "case totalLiquids -> liquids == null ? 0 : liquids.currentAmount();",
		"total_power_case": "case totalPower -> power == null || block.consPower == null ? 0 : power.status * (block.consPower.buffered ? block.consPower.capacity : 1f);",
		"total_items": total_items,
		"total_liquids": total_liquids,
		"total_power": total_power,
	}

static func sense_capacity_power_net_state(block_has_items: bool, block_item_capacity: float, block_has_liquids: bool, block_liquid_capacity: float, has_cons_power: bool, cons_power_capacity: float, has_power_module: bool, last_scaled_power_in: float, last_scaled_power_out: float, last_power_stored: float, last_power_capacity: float, source_tick_rate: float) -> Dictionary:
	var power_net_in := 0.0
	var power_net_out := 0.0
	var power_net_stored := 0.0
	var power_net_capacity := 0.0
	if has_power_module:
		power_net_in = last_scaled_power_in * source_tick_rate
		power_net_out = last_scaled_power_out * source_tick_rate
		power_net_stored = last_power_stored
		power_net_capacity = last_power_capacity
	return {
		"method": "public double sense(LAccess sensor){",
		"item_capacity_case": "case itemCapacity -> block.hasItems ? block.itemCapacity : 0;",
		"liquid_capacity_case": "case liquidCapacity -> block.hasLiquids ? block.liquidCapacity : 0;",
		"power_capacity_case": "case powerCapacity -> block.consPower != null ? block.consPower.capacity : 0f;",
		"power_net_in_case": "case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;",
		"power_net_out_case": "case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;",
		"power_net_stored_case": "case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();",
		"power_net_capacity_case": "case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();",
		"item_capacity": block_item_capacity if block_has_items else 0.0,
		"liquid_capacity": block_liquid_capacity if block_has_liquids else 0.0,
		"power_capacity": cons_power_capacity if has_cons_power else 0.0,
		"power_net_in": power_net_in,
		"power_net_out": power_net_out,
		"power_net_stored": power_net_stored,
		"power_net_capacity": power_net_capacity,
	}

static func sense_enabled_controlled_state(enabled_state: bool, is_control_block: bool, is_controlled: bool, ctrl_player_value: float) -> Dictionary:
	var source_state := {
		"method": "public double sense(LAccess sensor){",
		"enabled_case": "case enabled -> enabled ? 1 : 0;",
		"controlled_case": "case controlled -> this instanceof ControlBlock c && c.isControlled() ? GlobalVars.ctrlPlayer : 0;",
	}
	source_state["enabled"] = 1.0 if enabled_state else 0.0
	source_state["controlled"] = ctrl_player_value if is_control_block and is_controlled else 0.0
	return source_state

static func sense_payload_size_state(has_payload_seq: bool, payload_seq_total: float, has_single_payload: bool, block_size_value: float) -> Dictionary:
	var payload_count := 0.0
	if has_payload_seq:
		payload_count += payload_seq_total
	if has_single_payload:
		payload_count += 1.0
	return {
		"method": "public double sense(LAccess sensor){",
		"payload_count_case": "case payloadCount -> (getPayloads() != null ? getPayloads().total() : 0) + (getPayload() != null ? 1 : 0);",
		"size_case": "case size -> block.size;",
		"payload_count": payload_count,
		"size": block_size_value,
	}

static func sense_camera_default_state(is_control_block: bool, unit_camera_x: float, unit_camera_y: float, unit_camera_width: float, unit_camera_height: float) -> Dictionary:
	return {
		"method": "public double sense(LAccess sensor){",
		"camera_case": "case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;",
		"default_case": "default -> Float.NaN; //gets converted to null in logic",
		"is_control_block": is_control_block,
		"camera_x": unit_camera_x if is_control_block else 0.0,
		"camera_y": unit_camera_y if is_control_block else 0.0,
		"camera_width": unit_camera_width if is_control_block else 0.0,
		"camera_height": unit_camera_height if is_control_block else 0.0,
		"invalid_sensor": null,
	}

static func sense_object_state(sensor: String, block_value: Variant, has_items_module: bool, first_item_value: Variant, config_senseable: bool, config_value: Variant, single_payload_kind: String, single_payload_content: Variant) -> Dictionary:
	var source_state := {
		"method": "public Object senseObject(LAccess sensor){",
		"type_case": "case type -> block;",
		"first_item_case": "case firstItem -> items == null ? null : items.first();",
		"config_case": "case config -> block.configSenseable() ? config() : null;",
		"payload_type_case": "case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;",
		"default_case": "default -> noSensed;",
		"no_sensed": false,
	}
	if sensor == "type":
		source_state["value"] = block_value
	elif sensor == "firstItem":
		source_state["value"] = first_item_value if has_items_module else null
	elif sensor == "config":
		source_state["value"] = config_value if config_senseable else null
	elif sensor == "payloadType":
		if single_payload_kind == "unit" or single_payload_kind == "block":
			source_state["value"] = single_payload_content
		else:
			source_state["value"] = null
	else:
		source_state["value"] = null
		source_state["no_sensed"] = true
	return source_state

static func sense_content_state(content_type: String, has_items_module: bool, item_amount: float, has_liquids_module: bool, liquid_amount: float, has_payloads: bool, payload_amount: float) -> Dictionary:
	var source_state := {
		"method": "public double sense(Content content){",
		"item_case": "if(content instanceof Item i && items != null) return items.get(i);",
		"liquid_case": "if(content instanceof Liquid l && liquids != null) return liquids.get(l);",
		"payloads_guard": "if(getPayloads() != null){",
		"unit_payload_case": "if(content instanceof UnitType u) return getPayloads().get(u);",
		"block_payload_case": "if(content instanceof Block b) return getPayloads().get(b);",
		"invalid_return": "return Float.NaN; //invalid sense",
	}
	if content_type == "item" and has_items_module:
		source_state["sensed"] = true
		source_state["value"] = item_amount
		return source_state
	if content_type == "liquid" and has_liquids_module:
		source_state["sensed"] = true
		source_state["value"] = liquid_amount
		return source_state
	if (content_type == "unit" or content_type == "block") and has_payloads:
		source_state["sensed"] = true
		source_state["value"] = payload_amount
		return source_state
	source_state["sensed"] = false
	source_state["value"] = null
	return source_state

static func generated_building_comp_sense_position_bridge_state(world_x: float, world_y: float, source_tilesize: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_SENSE_JAVA_METHOD, [world_x, world_y, source_tilesize])
	var canonical = sense_position_state(world_x, world_y, source_tilesize)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SENSE_POSITION_STATE,
		"generated_owner": SOURCE_BUILDING_SENSE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_building_comp_sense_health_process_bridge_state(world_x: float, world_y: float, health: float, max_health: float, efficiency: float, time_scale: float, ranged_range: float, source_tilesize: float, has_range: bool, rotation_value: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_SENSE_JAVA_METHOD, [world_x, world_y, source_tilesize, health, max_health, efficiency, time_scale, ranged_range, has_range, rotation_value])
	var canonical = sense_health_process_state(health, max_health, efficiency, time_scale, ranged_range, source_tilesize, has_range, rotation_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SENSE_HEALTH_PROCESS_STATE,
		"generated_owner": SOURCE_BUILDING_SENSE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_building_comp_sense_totals_bridge_state(world_x: float, world_y: float, total_items: float, total_liquids: float, total_power: float, source_tilesize: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_SENSE_JAVA_METHOD, [world_x, world_y, source_tilesize, 0.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, total_items, total_liquids, total_power])
	var canonical = sense_totals_state(total_items, total_liquids, total_power)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SENSE_TOTALS_STATE,
		"generated_owner": SOURCE_BUILDING_SENSE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_building_comp_sense_capacity_power_net_bridge_state(world_x: float, world_y: float, block_has_items: bool, block_item_capacity: float, block_has_liquids: bool, block_liquid_capacity: float, has_cons_power: bool, cons_power_capacity: float, has_power_module: bool, last_scaled_power_in: float, last_scaled_power_out: float, last_power_stored: float, last_power_capacity: float, source_tilesize: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_SENSE_JAVA_METHOD, [world_x, world_y, source_tilesize, 0.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 0.0, 0.0, 0.0, block_has_items, block_item_capacity, block_has_liquids, block_liquid_capacity, has_cons_power, cons_power_capacity, has_power_module, last_scaled_power_in, last_scaled_power_out, last_power_stored, last_power_capacity, false, false, false, 0.0, false, 0.0, false, 0.0, false, 0.0, 0.0, 0.0, 0.0, source_time_defaults.TICK_RATE])
	var canonical = sense_capacity_power_net_state(block_has_items, block_item_capacity, block_has_liquids, block_liquid_capacity, has_cons_power, cons_power_capacity, has_power_module, last_scaled_power_in, last_scaled_power_out, last_power_stored, last_power_capacity, source_time_defaults.TICK_RATE)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SENSE_CAPACITY_POWER_NET_STATE,
		"generated_owner": SOURCE_BUILDING_SENSE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_building_comp_sense_enabled_controlled_bridge_state(world_x: float, world_y: float, enabled_state: bool, is_control_block: bool, is_controlled: bool, ctrl_player_value: float, source_tilesize: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_SENSE_JAVA_METHOD, [world_x, world_y, source_tilesize, 0.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 0.0, 0.0, 0.0, false, 0.0, false, 0.0, false, 0.0, false, 0.0, 0.0, 0.0, 0.0, enabled_state, is_control_block, is_controlled, ctrl_player_value])
	var canonical = sense_enabled_controlled_state(enabled_state, is_control_block, is_controlled, ctrl_player_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SENSE_ENABLED_CONTROLLED_STATE,
		"generated_owner": SOURCE_BUILDING_SENSE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_building_comp_sense_payload_size_bridge_state(world_x: float, world_y: float, has_payload_seq: bool, payload_seq_total: float, has_single_payload: bool, block_size_value: float, source_tilesize: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_SENSE_JAVA_METHOD, [world_x, world_y, source_tilesize, 0.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 0.0, 0.0, 0.0, false, 0.0, false, 0.0, false, 0.0, false, 0.0, 0.0, 0.0, 0.0, false, false, false, 0.0, has_payload_seq, payload_seq_total, has_single_payload, block_size_value])
	var canonical = sense_payload_size_state(has_payload_seq, payload_seq_total, has_single_payload, block_size_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SENSE_PAYLOAD_SIZE_STATE,
		"generated_owner": SOURCE_BUILDING_SENSE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_building_comp_sense_camera_default_bridge_state(world_x: float, world_y: float, is_control_block: bool, unit_camera_x: float, unit_camera_y: float, unit_camera_width: float, unit_camera_height: float, source_tilesize: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_SENSE_JAVA_METHOD, [world_x, world_y, source_tilesize, 0.0, 0.0, 0.0, 0.0, 0.0, false, 0.0, 0.0, 0.0, 0.0, false, 0.0, false, 0.0, false, 0.0, false, 0.0, 0.0, 0.0, 0.0, false, false, false, 0.0, false, 0.0, false, 0.0, is_control_block, unit_camera_x, unit_camera_y, unit_camera_width, unit_camera_height])
	var canonical = sense_camera_default_state(is_control_block, unit_camera_x, unit_camera_y, unit_camera_width, unit_camera_height)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SENSE_CAMERA_DEFAULT_STATE,
		"generated_owner": SOURCE_BUILDING_SENSE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_building_comp_sense_object_bridge_state(sensor: String, block_value: Variant, has_items_module: bool, first_item_value: Variant, config_senseable: bool, config_value: Variant, single_payload_kind: String, single_payload_content: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_SENSE_OBJECT_JAVA_METHOD, [sensor, block_value, has_items_module, first_item_value, config_senseable, config_value, single_payload_kind, single_payload_content])
	var canonical = sense_object_state(sensor, block_value, has_items_module, first_item_value, config_senseable, config_value, single_payload_kind, single_payload_content)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SENSE_OBJECT_STATE,
		"generated_owner": SOURCE_BUILDING_SENSE_OBJECT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_building_comp_sense_content_bridge_state(content_type: String, has_items_module: bool, item_amount: float, has_liquids_module: bool, liquid_amount: float, has_payloads: bool, payload_amount: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_SENSE_CONTENT_JAVA_METHOD, [content_type, has_items_module, item_amount, has_liquids_module, liquid_amount, has_payloads, payload_amount])
	var canonical = sense_content_state(content_type, has_items_module, item_amount, has_liquids_module, liquid_amount, has_payloads, payload_amount)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SENSE_CONTENT_STATE,
		"generated_owner": SOURCE_BUILDING_SENSE_CONTENT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}
