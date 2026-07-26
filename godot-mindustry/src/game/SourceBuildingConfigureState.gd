extends RefCounted
class_name SourceBuildingConfigureState

static func _building_comp_instance() -> Object:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
	return script.new()

static func configured_type_state(value_state: Dictionary) -> String:
	if bool(value_state.get("is_null", false)):
		return "void"
	var type_name := str(value_state.get("superclass", "")) if bool(value_state.get("is_anonymous_class", false)) else str(value_state.get("class", ""))
	var value_kind := str(value_state.get("kind", ""))
	if value_kind == "Item":
		type_name = "Item"
	if value_kind == "Block":
		type_name = "Block"
	if value_kind == "Liquid":
		type_name = "Liquid"
	if value_kind == "UnitType":
		type_name = "UnitType"
	return type_name

static func configured_last_access_state(builder_state: Dictionary, current_last_accessed: String) -> Dictionary:
	var result := {
		"source_owner": "PortGame.source_building_configured_last_access_state",
		"method": "public void configured(Unit builder, Object value){",
		"last_accessed": current_last_accessed,
		"builder_state": builder_state,
		"updated": false,
	}
	if bool(builder_state.get("exists", false)) and bool(builder_state.get("is_player", false)):
		result["last_accessed"] = str(builder_state.get("colored_name", ""))
		result["updated"] = true
	return result

static func configured_direct_handler_state(has_configuration: bool, configured_type: String, value_state: Variant) -> Dictionary:
	return {
		"source_owner": "PortGame.source_building_configured_direct_handler_state",
		"handled": has_configuration,
		"handler_type": configured_type,
		"value": value_state,
	}

static func configured_copy_config_state(value_is_building: bool, copied_config: Variant, copied_config_is_building: bool) -> Dictionary:
	var result := {
		"source_owner": "PortGame.source_building_configured_copy_config_state",
		"copy_branch": value_is_building,
		"recurse": false,
		"config": null,
	}
	if value_is_building and copied_config != null and not copied_config_is_building:
		result["config"] = copied_config
	return result

static func on_configure_build_tapped_state(clear_on_double_tap: bool, same_building: bool) -> Dictionary:
	var base := {
		"source_owner": "PortGame.source_building_on_configure_build_tapped_state",
		"method": "public boolean onConfigureBuildTapped(Building other){",
		"clear_on_double_tap": clear_on_double_tap,
		"same_building": same_building,
		"clear_on_double_tap_gate": clear_on_double_tap,
		"same_building_gate": clear_on_double_tap and same_building,
		"deselect": true,
		"configure_null": true,
		"consumed": false,
	}
	if clear_on_double_tap:
		if same_building:
			return base
	base.merge({"deselect": false, "configure_null": false, "consumed": not same_building}, true)
	return base

static func on_configure_tapped_state(x: float, y: float) -> Dictionary:
	return {
		"source_owner": "PortGame.source_building_on_configure_tapped_state",
		"method": "public boolean onConfigureTapped(float x, float y){",
		"return_false": "return false;",
		"x": x,
		"y": y,
		"consumed": false,
	}

static func on_configure_closed_state() -> Dictionary:
	return {
		"source_owner": "PortGame.source_building_on_configure_closed_state",
		"method": "public void onConfigureClosed(){}",
		"no_op": true,
	}

static func configure_menu_visibility_state(_player: Variant) -> Dictionary:
	return {"should_show": true, "should_hide": false}

static func should_show_configure_state(_player: Variant) -> Dictionary:
	var source_exprs := {
		"source_owner": "PortGame.source_building_should_show_configure_state",
	}
	var result := {
		"comment": "/** Returns whether this config menu should show when the specified player taps it. */",
		"method": "public boolean shouldShowConfigure(Player player){",
		"return_true": "return true;",
		"player": _player,
		"should_show": true,
	}
	result.merge(source_exprs)
	return result

static func should_hide_configure_state(_player: Variant) -> Dictionary:
	var source_exprs := {
		"source_owner": "PortGame.source_building_should_hide_configure_state",
	}
	var result := {
		"comment": "/** Whether this configuration should be hidden now. Called every frame the config is open. */",
		"method": "public boolean shouldHideConfigure(Player player){",
		"return_false": "return false;",
		"player": _player,
		"should_hide": false,
	}
	result.merge(source_exprs)
	return result

static func generated_configured_type_bridge_state(value_state: Dictionary) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_configured_148([{}, value_state])
	var canonical = configured_type_state(value_state)
	return {
		"source_owner": "PortGame.source_building_configured_type_state",
		"generated_owner": "BuildingComp.java_method_configured_148",
		"result": result,
		"canonical": canonical,
	}

static func generated_update_last_access_bridge_state(builder_state: Dictionary, current_last_accessed: String) -> Dictionary:
	var instance = _building_comp_instance()
	var result = instance.java_method_updateLastAccess_149([builder_state, current_last_accessed])
	var canonical = configured_last_access_state(builder_state, current_last_accessed)
	return {
		"source_owner": "PortGame.source_building_configured_last_access_state",
		"generated_owner": "BuildingComp.java_method_updateLastAccess_149",
		"result": result,
		"canonical": canonical,
	}
