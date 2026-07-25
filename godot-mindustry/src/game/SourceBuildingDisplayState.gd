extends RefCounted
class_name SourceBuildingDisplayState

static func _with_source_owner(source_exprs: Dictionary, state: Dictionary) -> Dictionary:
	var result := source_exprs.duplicate()
	result.merge(state)
	return result

static func display_name_state(localized_name: String, team_is_derelict: bool, team_is_player: bool, team_emoji: String, derelict_label: String) -> String:
	if team_is_derelict:
		return localized_name + "\n" + derelict_label
	if team_is_player or team_emoji.is_empty():
		return localized_name
	return localized_name + " " + team_emoji

static func display_icon_state(block_ui_icon: Variant) -> Variant:
	return block_ui_icon

static func flow_items_state(items_module: Variant) -> Variant:
	return items_module

static func display_consumption_state(consumers: Array, self_state: Variant) -> Dictionary:
	var source_exprs := {"source_owner": "PortGame.source_building_display_consumption_state"}
	var built_consumers: Array = []
	var skipped_consumers: Array = []
	for cons in consumers:
		var optional_value := bool(cons.get("optional", false))
		var booster_value := bool(cons.get("booster", false))
		if optional_value and booster_value:
			skipped_consumers.append(cons)
			continue
		built_consumers.append({"consumer": cons, "self_state": self_state})
	return _with_source_owner(source_exprs, {
		"method": "public void displayConsumption(Table table){",
		"table_left_call": "table.left();",
		"consumers_loop": "for(Consume cons : block.consumers){",
		"optional_booster_skip": "if(cons.optional && cons.booster) continue;",
		"build_call": "cons.build(self(), table);",
		"consumers": consumers,
		"self_state": self_state,
		"built_consumers": built_consumers,
		"skipped_consumers": skipped_consumers,
	})

static func display_bars_state(bar_results: Array) -> Dictionary:
	var source_exprs := {"source_owner": "PortGame.source_building_display_bars_state"}
	var added_bars: Array = []
	var skipped_bars: Array = []
	for result in bar_results:
		if result == null:
			skipped_bars.append(result)
			continue
		added_bars.append(result)
	return _with_source_owner(source_exprs, {
		"method": "public void displayBars(Table table){",
		"bars_loop": "for(Func<Building, Bar> bar : block.listBars()){",
		"get_result": "var result = bar.get(self());",
		"null_skip": "if(result == null) continue;",
		"add_call": "table.add(result).growX();",
		"row_call": "table.row();",
		"bar_results": bar_results,
		"added_bars": added_bars,
		"skipped_bars": skipped_bars,
		"row_calls": added_bars.size(),
	})

static func display_ui_gates_state(team_is_player: bool, block_category: String, block_display_flow: bool, net_active: bool, has_last_accessed: bool) -> Dictionary:
	var display_flow := (block_category == "distribution" or block_category == "liquid") and block_display_flow
	return {
		"display_header": true,
		"display_same_team_details": team_is_player,
		"display_bars": team_is_player,
		"display_consumption": team_is_player,
		"display_flow": team_is_player and display_flow,
		"display_last_accessed": team_is_player and net_active and has_last_accessed,
	}

static func display_flow_rate_label(flow_rate: float, per_second_label: String, fixed_one_decimal: Callable) -> String:
	if flow_rate < 0.0:
		return "..."
	return str(fixed_one_decimal.call(flow_rate)) + " " + per_second_label

static func generated_building_comp_get_display_name_bridge_state(localized_name: String, team_is_derelict: bool, team_is_player: bool, team_emoji: String, derelict_label: String) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
	var instance = script.new()
	var result = instance.java_method_getDisplayName_157([localized_name, team_is_derelict, team_is_player, team_emoji, derelict_label])
	var canonical = display_name_state(localized_name, team_is_derelict, team_is_player, team_emoji, derelict_label)
	return {
		"source_owner": "PortGame.source_building_display_name_state",
		"generated_owner": "BuildingComp.java_method_getDisplayName_157",
		"result": result,
		"canonical": canonical,
	}

static func generated_building_comp_flow_items_bridge_state(items_module: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
	var instance = script.new()
	var result = instance.java_method_flowItems_159([items_module])
	var canonical = flow_items_state(items_module)
	return {
		"source_owner": "PortGame.source_building_flow_items_state",
		"generated_owner": "BuildingComp.java_method_flowItems_159",
		"result": result,
		"canonical": canonical,
	}

static func generated_building_comp_display_consumption_bridge_state(consumers: Array, self_state: Variant) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
	var instance = script.new()
	var result = instance.java_method_displayConsumption_161([consumers, self_state])
	var canonical = display_consumption_state(consumers, self_state)
	return {
		"source_owner": "PortGame.source_building_display_consumption_state",
		"generated_owner": "BuildingComp.java_method_displayConsumption_161",
		"result": result,
		"canonical": canonical,
	}

static func generated_building_comp_display_bars_bridge_state(bar_results: Array) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
	var instance = script.new()
	var result = instance.java_method_displayBars_162([bar_results])
	var canonical = display_bars_state(bar_results)
	return {
		"source_owner": "PortGame.source_building_display_bars_state",
		"generated_owner": "BuildingComp.java_method_displayBars_162",
		"result": result,
		"canonical": canonical,
	}
