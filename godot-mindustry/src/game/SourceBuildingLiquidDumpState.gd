extends RefCounted
class_name SourceBuildingLiquidDumpState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_KEY := "increment_dump_cursor"
const SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK := "source_increment_dump_cursor"

static func runtime_method_names(game: Object) -> Dictionary:
	if game == null:
		return {}
	if game.has_method("_building_liquid_state_method_names"):
		var names = game.call("_building_liquid_state_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	return str(method_names.get(key, fallback_name))

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	var increment_dump_cursor_method := runtime_method_name(method_names, SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_KEY, SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK)
	return {
		SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_KEY: Callable(game, increment_dump_cursor_method),
	}

static func game_dump_liquid_routing_gate_state(game: Object, liquid: Variant, proximity_size: int, dump_cursor: int, output_dir: int, rotation_value: int, relative_to_by_index: Array, destination_present_by_index: Array, other_has_liquids_by_index: Array, can_dump_liquid_by_index: Array, other_liquids_present_by_index: Array) -> Dictionary:
	return dump_liquid_routing_gate_state(
		liquid,
		proximity_size,
		dump_cursor,
		output_dir,
		rotation_value,
		relative_to_by_index,
		destination_present_by_index,
		other_has_liquids_by_index,
		can_dump_liquid_by_index,
		other_liquids_present_by_index,
		default_callbacks_state(game).get(SOURCE_BUILDING_LIQUID_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable())
	)

static func dump_liquid_default_scaling_state(liquid: Variant, current_liquid_amount: float) -> Dictionary:
	var default_scaling := 2.0
	var output_dir := -1
	var routing_enabled := current_liquid_amount > 0.0001
	return {
		"method_default": "public void dumpLiquid(Liquid liquid){",
		"default_scaling_call": "dumpLiquid(liquid, 2f);",
		"method_scaling": "public void dumpLiquid(Liquid liquid, float scaling){",
		"output_dir_call": "dumpLiquid(liquid, scaling, -1);",
		"method_output_dir": "public void dumpLiquid(Liquid liquid, float scaling, int outputDir){",
		"dump_cursor_assignment": "int dump = this.cdump;",
		"empty_liquid_return": "if(liquids.get(liquid) <= 0.0001f) return;",
		"liquid": liquid,
		"current_liquid_amount": current_liquid_amount,
		"default_scaling": default_scaling,
		"output_dir": output_dir,
		"routing_enabled": routing_enabled,
	}

static func dump_liquid_campaign_unlock_state(liquid: Variant, current_liquid_amount: float, net_client: bool, state_is_campaign: bool, team_is_default_team: bool) -> Dictionary:
	var routing_enabled := current_liquid_amount > 0.0001
	var unlock_called := routing_enabled and not net_client and state_is_campaign and team_is_default_team
	return {
		"method_output_dir": "public void dumpLiquid(Liquid liquid, float scaling, int outputDir){",
		"empty_liquid_return": "if(liquids.get(liquid) <= 0.0001f) return;",
		"campaign_unlock_guard": "if(!net.client() && state.isCampaign() && team == state.rules.defaultTeam) liquid.unlock();",
		"liquid": liquid,
		"current_liquid_amount": current_liquid_amount,
		"net_client": net_client,
		"state_is_campaign": state_is_campaign,
		"team_is_default_team": team_is_default_team,
		"routing_enabled": routing_enabled,
		"unlock_called": unlock_called,
	}

static func dump_liquid_routing_gate_state(liquid: Variant, proximity_size: int, dump_cursor: int, output_dir: int, rotation_value: int, relative_to_by_index: Array, destination_present_by_index: Array, other_has_liquids_by_index: Array, can_dump_liquid_by_index: Array, other_liquids_present_by_index: Array, increment_dump_cursor: Callable) -> Dictionary:
	var attempted_indices := []
	var output_dir_passes := []
	var destination_indices := []
	var eligible_indices := []
	var final_cdump := dump_cursor
	if proximity_size > 0:
		for i in range(proximity_size):
			final_cdump = int(increment_dump_cursor.call(final_cdump, proximity_size))
			var other_index := (i + dump_cursor) % proximity_size
			attempted_indices.append(other_index)
			var output_dir_passed := output_dir == -1 or (output_dir + rotation_value) % 4 == int(relative_to_by_index[other_index])
			output_dir_passes.append(output_dir_passed)
			if not output_dir_passed:
				continue
			if bool(destination_present_by_index[other_index]):
				destination_indices.append(other_index)
			if bool(destination_present_by_index[other_index]) and bool(other_has_liquids_by_index[other_index]) and bool(can_dump_liquid_by_index[other_index]) and bool(other_liquids_present_by_index[other_index]):
				eligible_indices.append(other_index)
	return {
		"loop": "for(int i = 0; i < proximity.size; i++){",
		"increment_dump_call": "incrementDump(proximity.size);",
		"proximity_get": "Building other = proximity.get((i + dump) % proximity.size);",
		"output_dir_filter": "if(outputDir != -1 && (outputDir + rotation) % 4 != relativeTo(other)) continue;",
		"destination_call": "other = other.getLiquidDestination(self(), liquid);",
		"eligibility_guard": "if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){",
		"liquid": liquid,
		"proximity_size": proximity_size,
		"dump_cursor": dump_cursor,
		"output_dir": output_dir,
		"rotation_value": rotation_value,
		"relative_to_by_index": relative_to_by_index,
		"destination_present_by_index": destination_present_by_index,
		"other_has_liquids_by_index": other_has_liquids_by_index,
		"can_dump_liquid_by_index": can_dump_liquid_by_index,
		"other_liquids_present_by_index": other_liquids_present_by_index,
		"attempted_indices": attempted_indices,
		"output_dir_passes": output_dir_passes,
		"destination_indices": destination_indices,
		"eligible_indices": eligible_indices,
		"final_cdump": final_cdump,
	}

static func dump_liquid_fraction_transfer_state(liquid: Variant, scaling: float, eligible_indices: Array, current_liquid_amount: float, block_liquid_capacity: float, other_liquid_amount_by_index: Array, other_block_liquid_capacity_by_index: Array) -> Dictionary:
	var ofract_by_index := {}
	var fract := current_liquid_amount / block_liquid_capacity
	var transfer_guard_by_index := {}
	var transfer_amount_by_index := {}
	var transfer_indices := []
	var transfer_liquid_call := "transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid)"
	for raw_index in eligible_indices:
		var other_index := int(raw_index)
		var ofract := float(other_liquid_amount_by_index[other_index]) / float(other_block_liquid_capacity_by_index[other_index])
		ofract_by_index[other_index] = ofract
		var transfer_guard_passed := ofract < fract
		transfer_guard_by_index[other_index] = transfer_guard_passed
		if transfer_guard_passed:
			transfer_amount_by_index[other_index] = (fract - ofract) * block_liquid_capacity / scaling
			transfer_indices.append(other_index)
	return {
		"ofract": "float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;",
		"fract": "float fract = liquids.get(liquid) / block.liquidCapacity;",
		"transfer_guard": "if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);",
		"transfer_liquid_call": transfer_liquid_call,
		"liquid": liquid,
		"scaling": scaling,
		"eligible_indices": eligible_indices,
		"current_liquid_amount": current_liquid_amount,
		"block_liquid_capacity": block_liquid_capacity,
		"other_liquid_amount_by_index": other_liquid_amount_by_index,
		"other_block_liquid_capacity_by_index": other_block_liquid_capacity_by_index,
		"ofract_by_index": ofract_by_index,
		"fract_value": fract,
		"transfer_guard_by_index": transfer_guard_by_index,
		"transfer_amount_by_index": transfer_amount_by_index,
		"transfer_indices": transfer_indices,
	}

static func dump_liquid_state(liquid: Variant, scaling: float, output_dir: int, current_liquid_amount: float, net_client: bool, state_is_campaign: bool, team_is_default_team: bool, proximity_size: int, dump_cursor: int, rotation_value: int, relative_to_by_index: Array, destination_present_by_index: Array, other_has_liquids_by_index: Array, can_dump_liquid_by_index: Array, other_liquids_present_by_index: Array, other_liquid_amount_by_index: Array, other_block_liquid_capacity_by_index: Array, other_accepts_liquid_by_index: Array, block_liquid_capacity: float, transfer_liquid: Callable, increment_dump_cursor: Callable) -> Dictionary:
	var overload_state := dump_liquid_default_scaling_state(liquid, current_liquid_amount)
	var campaign_state := dump_liquid_campaign_unlock_state(liquid, current_liquid_amount, net_client, state_is_campaign, team_is_default_team)
	var routing_state := {
		"eligible_indices": [],
		"final_cdump": dump_cursor,
	}
	var current_amount_after := current_liquid_amount
	var other_amounts_after := other_liquid_amount_by_index.duplicate()
	var transfer_states_by_index := {}
	if bool(overload_state.get("routing_enabled", false)):
		routing_state = dump_liquid_routing_gate_state(liquid, proximity_size, dump_cursor, output_dir, rotation_value, relative_to_by_index, destination_present_by_index, other_has_liquids_by_index, can_dump_liquid_by_index, other_liquids_present_by_index, increment_dump_cursor)
		for raw_index in routing_state.get("eligible_indices", []):
			var other_index := int(raw_index)
			var fraction_state := dump_liquid_fraction_transfer_state(liquid, scaling, [other_index], current_amount_after, block_liquid_capacity, other_amounts_after, other_block_liquid_capacity_by_index)
			var transfer_amount := float(fraction_state.get("transfer_amount_by_index", {}).get(other_index, 0.0))
			var transfer_state: Dictionary = transfer_liquid.call(liquid, transfer_amount, float(other_block_liquid_capacity_by_index[other_index]), float(other_amounts_after[other_index]), bool(other_accepts_liquid_by_index[other_index]), current_amount_after)
			transfer_state["fraction_state"] = fraction_state
			transfer_states_by_index[other_index] = transfer_state
			current_amount_after = float(transfer_state.get("current_liquid_amount_after", current_amount_after))
			other_amounts_after[other_index] = float(transfer_state.get("next_liquid_amount_after", other_amounts_after[other_index]))
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DUMP_LIQUID_STATE,
		"method_default": overload_state.get("method_default", ""),
		"method_scaling": overload_state.get("method_scaling", ""),
		"method_output_dir": overload_state.get("method_output_dir", ""),
		"liquid": liquid,
		"scaling": scaling,
		"output_dir": output_dir,
		"overload_state": overload_state,
		"campaign_state": campaign_state,
		"routing_state": routing_state,
		"transfer_states_by_index": transfer_states_by_index,
		"current_liquid_amount_after": current_amount_after,
		"other_liquid_amount_by_index_after": other_amounts_after,
		"unlock_called": bool(campaign_state.get("unlock_called", false)),
		"final_cdump": int(routing_state.get("final_cdump", dump_cursor)),
	}
