extends RefCounted
class_name SourceBuildingSetPropState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func health_state(prop: String, current_health: float, max_health_value: float, value: float, dead_state: bool, self_state: Variant) -> Dictionary:
	var source_exprs := {
		"method": "public void setProp(LAccess prop, double value){",
		"switch_prop": "switch(prop){",
		"health_case": "case health -> {",
		"clamp_assign": "health = (float)Mathf.clamp(value, 0, maxHealth);",
		"destroy_gate": "if(health <= 0f && !dead()){",
		"build_destroyed_call": "Call.buildDestroyed(self());",
		"else_branch": "}else{",
		"health_changed_call": "healthChanged();",
	}
	if prop != "health":
		var ignored_result := {"updated": false, "health": current_health}
		ignored_result.merge(source_exprs)
		return ignored_result
	var next_health := clampf(value, 0.0, max_health_value)
	if next_health <= 0.0 and not dead_state:
		var destroyed_result := {"health": next_health, "build_destroyed_called": true, "build_destroyed": self_state, "health_changed": false}
		destroyed_result.merge(source_exprs)
		return destroyed_result
	var changed_result := {"health": next_health, "build_destroyed_called": false, "build_destroyed": null, "health_changed": true}
	changed_result.merge(source_exprs)
	return changed_result

static func generated_health_bridge_state(prop: String, current_health: float, max_health_value: float, value: float, dead_state: bool, self_state: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_setProp_211", [prop, current_health, max_health_value, value, dead_state, self_state], null)
	var canonical = health_state(prop, current_health, max_health_value, value, dead_state, self_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SET_PROP_HEALTH_STATE,
		"generated_owner": "building_comp.java_method_setProp_211",
		"result": result,
		"canonical": canonical,
	}

static func team_double_state(prop: String, current_team_id: int, value: float) -> Dictionary:
	var source_exprs := {
		"method": "public void setProp(LAccess prop, double value){",
		"team_case": "case team -> {",
		"team_lookup": "Team team = Team.get((int)value);",
		"change_gate": "if(this.team != team){",
		"change_team_call": "changeTeam(team);",
	}
	if prop != "team":
		var ignored_result := {"change_team_called": false, "team": current_team_id}
		ignored_result.merge(source_exprs)
		return ignored_result
	var next_team_id := int(value)
	if current_team_id != next_team_id:
		var changed_result := {"change_team_called": true, "change_team": next_team_id, "team": next_team_id}
		changed_result.merge(source_exprs)
		return changed_result
	var same_result := {"change_team_called": false, "team": current_team_id}
	same_result.merge(source_exprs)
	return same_result

static func generated_team_double_bridge_state(prop: String, current_team_id: int, value: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_setProp_211", [prop, current_team_id, value], null)
	var canonical = team_double_state(prop, current_team_id, value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SET_PROP_TEAM_DOUBLE_STATE,
		"generated_owner": "building_comp.java_method_setProp_211",
		"result": result,
		"canonical": canonical,
	}

static func total_power_state(prop: String, current_power_status: float, has_power: bool, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, value: float) -> Dictionary:
	var source_exprs := {
		"method": "public void setProp(LAccess prop, double value){",
		"total_power_case": "case totalPower -> {",
		"total_power_guard": "if(power != null && block.consPower != null && block.consPower.buffered){",
		"status_assign": "power.status = Mathf.clamp((float)(value / block.consPower.capacity));",
	}
	if prop == "totalPower" and has_power and has_cons_power and cons_power_buffered:
		var next_status := clampf(value / cons_power_capacity, 0.0, 1.0)
		var updated_result := {"power_status": next_status, "updated": true}
		updated_result.merge(source_exprs)
		return updated_result
	var unchanged_result := {"power_status": current_power_status, "updated": false}
	unchanged_result.merge(source_exprs)
	return unchanged_result

static func generated_total_power_bridge_state(prop: String, current_power_status: float, has_power: bool, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, value: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_setProp_211", [prop, current_power_status, has_power, has_cons_power, cons_power_buffered, cons_power_capacity, value], null)
	var canonical = total_power_state(prop, current_power_status, has_power, has_cons_power, cons_power_buffered, cons_power_capacity, value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SET_PROP_TOTAL_POWER_STATE,
		"generated_owner": "building_comp.java_method_setProp_211",
		"result": result,
		"canonical": canonical,
	}

static func team_object_state(prop: String, current_team_value: Variant, value_is_team: bool, team_value: Variant) -> Dictionary:
	var source_exprs := {
		"method": "public void setProp(LAccess prop, Object value){",
		"switch_prop": "switch(prop){",
		"team_case": "case team -> {",
		"team_gate": "if(value instanceof Team team && this.team != team){",
		"change_team_call": "changeTeam(team);",
	}
	if prop == "team" and value_is_team and current_team_value != team_value:
		var changed_result := {"team": team_value, "change_team_called": true, "change_team": team_value}
		changed_result.merge(source_exprs)
		return changed_result
	var same_result := {"team": current_team_value, "change_team_called": false}
	same_result.merge(source_exprs)
	return same_result

static func generated_team_object_bridge_state(prop: String, current_team_value: Variant, value_is_team: bool, team_value: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_setProp_212", [prop, current_team_value, value_is_team, team_value], null)
	var canonical = team_object_state(prop, current_team_value, value_is_team, team_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SET_PROP_TEAM_OBJECT_STATE,
		"generated_owner": "building_comp.java_method_setProp_212",
		"result": result,
		"canonical": canonical,
	}

static func item_content_state(content_type: String, has_items_module: bool, item_value: Variant, current_amount: int, value: float, accepted_stack: int) -> Dictionary:
	var source_exprs := {
		"method": "public void setProp(UnlockableContent content, double value){",
		"item_gate": "if(content instanceof Item item && items != null){",
		"amount_assign": "int amount = (int)value;",
		"amount_diff_gate": "if(items.get(item) != amount){",
		"increase_gate": "if(items.get(item) < amount){",
		"handle_stack_call": "handleStack(item, acceptStack(item, amount - items.get(item), null), null);",
		"remove_gate": "}else if(amount >= 0){",
		"remove_stack_call": "removeStack(item, items.get(item) - amount);",
	}
	if content_type != "item" or not has_items_module:
		var ignored_result := {"action": "ignored", "item": item_value, "amount": current_amount}
		ignored_result.merge(source_exprs)
		return ignored_result
	var amount := int(value)
	if current_amount == amount:
		var same_result := {"action": "same", "item": item_value, "amount": amount}
		same_result.merge(source_exprs)
		return same_result
	if current_amount < amount:
		var handle_result := {"action": "handle_stack", "item": item_value, "amount": amount, "accepted": accepted_stack}
		handle_result.merge(source_exprs)
		return handle_result
	if amount >= 0:
		var remove_result := {"action": "remove_stack", "item": item_value, "amount": amount, "removed": current_amount - amount}
		remove_result.merge(source_exprs)
		return remove_result
	var invalid_result := {"action": "invalid", "item": item_value, "amount": current_amount}
	invalid_result.merge(source_exprs)
	return invalid_result

static func generated_item_content_bridge_state(content_type: String, has_items_module: bool, item_value: Variant, current_amount: int, value: float, accepted_stack: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_setProp_213", [content_type, has_items_module, item_value, current_amount, value, accepted_stack], null)
	var canonical = item_content_state(content_type, has_items_module, item_value, current_amount, value, accepted_stack)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SET_PROP_ITEM_CONTENT_STATE,
		"generated_owner": "building_comp.java_method_setProp_213",
		"result": result,
		"canonical": canonical,
	}

static func liquid_content_state(content_type: String, has_liquids_module: bool, liquid_value: Variant, current_amount: float, value: float, block_liquid_capacity: float, accept_liquid_result: bool, current_liquid_matches: bool, current_liquid_amount: float, block_consumes_liquid: bool) -> Dictionary:
	var source_exprs := {
		"method": "public void setProp(UnlockableContent content, double value){",
		"liquid_gate": "}else if(content instanceof Liquid liquid && liquids != null){",
		"clamp_assign": "float amount = Mathf.clamp((float)value, 0f, block.liquidCapacity);",
		"decreasing_comment": "//decreasing amount is always allowed",
		"set_gate": "if(amount < liquids.get(liquid) || (acceptLiquid(self(), liquid) && (liquids.current() == liquid || liquids.currentAmount() <= 0.1f || block.consumesLiquid(liquid)))){",
		"liquids_set_call": "liquids.set(liquid, amount);",
	}
	if content_type != "liquid" or not has_liquids_module:
		var ignored_result := {"action": "ignored", "liquid": liquid_value, "amount": current_amount}
		ignored_result.merge(source_exprs)
		return ignored_result
	var amount := clampf(value, 0.0, block_liquid_capacity)
	var can_set := amount < current_amount
	if not can_set:
		can_set = accept_liquid_result and (current_liquid_matches or current_liquid_amount <= 0.1 or block_consumes_liquid)
	if can_set:
		var set_result := {"action": "set_liquid", "liquid": liquid_value, "amount": amount}
		set_result.merge(source_exprs)
		return set_result
	var unchanged_result := {"action": "unchanged", "liquid": liquid_value, "amount": current_amount}
	unchanged_result.merge(source_exprs)
	return unchanged_result

static func generated_liquid_content_bridge_state(content_type: String, has_liquids_module: bool, liquid_value: Variant, current_amount: float, value: float, block_liquid_capacity: float, accept_liquid_result: bool, current_liquid_matches: bool, current_liquid_amount: float, block_consumes_liquid: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_setProp_213", [content_type, has_liquids_module, liquid_value, current_amount, value, block_liquid_capacity, accept_liquid_result, current_liquid_matches, current_liquid_amount, block_consumes_liquid], null)
	var canonical = liquid_content_state(content_type, has_liquids_module, liquid_value, current_amount, value, block_liquid_capacity, accept_liquid_result, current_liquid_matches, current_liquid_amount, block_consumes_liquid)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SET_PROP_LIQUID_CONTENT_STATE,
		"generated_owner": "building_comp.java_method_setProp_213",
		"result": result,
		"canonical": canonical,
	}
