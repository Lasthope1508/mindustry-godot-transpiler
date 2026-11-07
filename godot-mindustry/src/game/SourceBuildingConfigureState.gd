extends RefCounted
class_name SourceBuildingConfigureState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_CONFIGURE_CONFIGURED_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_CONFIGURED_JAVA_METHOD
const SOURCE_BUILDING_CONFIGURE_CONFIGURED_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_CONFIGURED_GENERATED_OWNER
const SOURCE_BUILDING_CONFIGURE_UPDATE_LAST_ACCESS_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_UPDATE_LAST_ACCESS_JAVA_METHOD
const SOURCE_BUILDING_CONFIGURE_UPDATE_LAST_ACCESS_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_UPDATE_LAST_ACCESS_GENERATED_OWNER
const SOURCE_BUILDING_CONFIGURE_LOCAL_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_LOCAL_JAVA_METHOD
const SOURCE_BUILDING_CONFIGURE_LOCAL_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_LOCAL_GENERATED_OWNER
const SOURCE_BUILDING_CONFIGURE_ANY_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_ANY_JAVA_METHOD
const SOURCE_BUILDING_CONFIGURE_ANY_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_ANY_GENERATED_OWNER
const SOURCE_BUILDING_DESELECT_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_DESELECT_JAVA_METHOD
const SOURCE_BUILDING_DESELECT_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_DESELECT_GENERATED_OWNER
const SOURCE_BUILDING_CONFIG_TAPPED_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CONFIG_TAPPED_JAVA_METHOD
const SOURCE_BUILDING_CONFIG_TAPPED_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CONFIG_TAPPED_GENERATED_OWNER
const SOURCE_BUILDING_CONFIGURE_ON_CONFIGURE_TAPPED_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_ON_CONFIGURE_TAPPED_JAVA_METHOD
const SOURCE_BUILDING_CONFIGURE_ON_CONFIGURE_TAPPED_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_ON_CONFIGURE_TAPPED_GENERATED_OWNER
const SOURCE_BUILDING_CONFIGURE_ON_CONFIGURE_CLOSED_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_ON_CONFIGURE_CLOSED_JAVA_METHOD
const SOURCE_BUILDING_CONFIGURE_ON_CONFIGURE_CLOSED_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_ON_CONFIGURE_CLOSED_GENERATED_OWNER
const SOURCE_BUILDING_CONFIGURE_SHOULD_SHOW_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_SHOULD_SHOW_JAVA_METHOD
const SOURCE_BUILDING_CONFIGURE_SHOULD_SHOW_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_SHOULD_SHOW_GENERATED_OWNER
const SOURCE_BUILDING_CONFIGURE_SHOULD_HIDE_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_SHOULD_HIDE_JAVA_METHOD
const SOURCE_BUILDING_CONFIGURE_SHOULD_HIDE_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CONFIGURE_SHOULD_HIDE_GENERATED_OWNER

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func configure_state(block_state: Dictionary, player_state: Variant, self_state: Variant, value: Variant, tile_config_callback: Variant) -> Dictionary:
	var updated_block_state := block_state.duplicate(true)
	updated_block_state["lastConfig"] = value
	if tile_config_callback is Callable and tile_config_callback.is_valid():
		tile_config_callback.call(player_state, self_state, value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONFIGURE_STATE,
		"block_state": updated_block_state,
		"player": player_state,
		"self": self_state,
		"value": value,
		"tile_config_called": true,
	}

static func configure_any_state(self_state: Variant, value: Variant, tile_config_callback: Variant) -> Dictionary:
	if tile_config_callback is Callable and tile_config_callback.is_valid():
		tile_config_callback.call(null, self_state, value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONFIGURE_ANY_STATE,
		"player": null,
		"self": self_state,
		"value": value,
		"tile_config_called": true,
	}

static func deselect_state(headless: bool, selected_building: Variant, self_state: Variant, hide_config_callback: Variant) -> Dictionary:
	var hide_config: bool = not headless and selected_building == self_state
	if hide_config and hide_config_callback is Callable and hide_config_callback.is_valid():
		hide_config_callback.call()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DESELECT_STATE,
		"headless": headless,
		"selected_building": selected_building,
		"self": self_state,
		"hide_config": hide_config,
	}

static func config_tapped_state() -> bool:
	return true

static func build_configuration_state(table: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_BUILD_CONFIGURATION_STATE,
		"method": source_building_source_text_state.SOURCE_BUILDING_BUILD_CONFIGURATION_METHOD,
		"comment": source_building_source_text_state.SOURCE_BUILDING_BUILD_CONFIGURATION_COMMENT,
		"table": table,
		"no_op": true,
	}

static func generated_build_configuration_bridge_state(table: Variant) -> Dictionary:
	var result := build_configuration_state(table)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_BUILD_CONFIGURATION_STATE,
		"generated_owner": source_building_source_text_state.SOURCE_BUILDING_BUILD_CONFIGURATION_GENERATED_OWNER,
		"result": result,
		"canonical": result,
		"matches": true,
	}

static func update_table_align_state(table: Variant, x: float, y: float, block_size: int, tilesize: float, mouse_screen_position: Variant) -> Dictionary:
	var mouse_y_input := y - block_size * tilesize / 2.0 - 1.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_TABLE_ALIGN_STATE,
		"method": source_building_source_text_state.SOURCE_BUILDING_UPDATE_TABLE_ALIGN_METHOD,
		"mouse_screen_expr": source_building_source_text_state.SOURCE_BUILDING_UPDATE_TABLE_ALIGN_MOUSE_EXPR,
		"set_position_expr": source_building_source_text_state.SOURCE_BUILDING_UPDATE_TABLE_ALIGN_SET_POSITION_EXPR,
		"table": table,
		"x": x,
		"y": y,
		"block_size": block_size,
		"tilesize": tilesize,
		"mouse_screen_x": mouse_screen_position.get("x", 0.0) if mouse_screen_position is Dictionary else null,
		"mouse_screen_y": mouse_screen_position.get("y", 0.0) if mouse_screen_position is Dictionary else null,
		"mouse_screen_input": mouse_screen_position,
		"mouse_screen_y_input": mouse_y_input,
		"alignment": "top",
		"updated": true,
	}

static func generated_update_table_align_bridge_state(table: Variant, x: float, y: float, block_size: int, tilesize: float, mouse_screen_position: Variant) -> Dictionary:
	var result := update_table_align_state(table, x, y, block_size, tilesize, mouse_screen_position)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_TABLE_ALIGN_STATE,
		"generated_owner": source_building_source_text_state.SOURCE_BUILDING_UPDATE_TABLE_ALIGN_GENERATED_OWNER,
		"result": result,
		"canonical": result,
		"matches": true,
	}

static func generated_configure_bridge_state(block_state: Dictionary, player_state: Variant, self_state: Variant, value: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CONFIGURE_LOCAL_JAVA_METHOD, [value, block_state, player_state, self_state, null])
	var canonical = configure_state(block_state, player_state, self_state, value, null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONFIGURE_STATE,
		"generated_owner": SOURCE_BUILDING_CONFIGURE_LOCAL_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_configure_any_bridge_state(self_state: Variant, value: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CONFIGURE_ANY_JAVA_METHOD, [value, self_state, null])
	var canonical = configure_any_state(self_state, value, null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONFIGURE_ANY_STATE,
		"generated_owner": SOURCE_BUILDING_CONFIGURE_ANY_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_deselect_bridge_state(headless: bool, selected_building: Variant, self_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_DESELECT_JAVA_METHOD, [headless, selected_building, self_state, null])
	var canonical = deselect_state(headless, selected_building, self_state, null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DESELECT_STATE,
		"generated_owner": SOURCE_BUILDING_DESELECT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_config_tapped_bridge_state() -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CONFIG_TAPPED_JAVA_METHOD, [])
	var canonical = config_tapped_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONFIG_TAPPED_STATE,
		"generated_owner": SOURCE_BUILDING_CONFIG_TAPPED_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

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
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONFIGURED_LAST_ACCESS_STATE,
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
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONFIGURED_DIRECT_HANDLER_STATE,
		"handled": has_configuration,
		"handler_type": configured_type,
		"value": value_state,
	}

static func configured_copy_config_state(value_is_building: bool, copied_config: Variant, copied_config_is_building: bool) -> Dictionary:
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONFIGURED_COPY_CONFIG_STATE,
		"copy_branch": value_is_building,
		"recurse": false,
		"config": null,
	}
	if value_is_building and copied_config != null and not copied_config_is_building:
		result["config"] = copied_config
	return result

static func on_configure_build_tapped_state(clear_on_double_tap: bool, same_building: bool) -> Dictionary:
	var base := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_CONFIGURE_BUILD_TAPPED_STATE,
		"method": source_building_source_text_state.SOURCE_BUILDING_ON_CONFIGURE_BUILD_TAPPED_METHOD,
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

static func generated_on_configure_build_tapped_bridge_state(clear_on_double_tap: bool, same_building: bool) -> Dictionary:
	var result = _building_comp_call(source_building_source_text_state.SOURCE_BUILDING_ON_CONFIGURE_BUILD_TAPPED_JAVA_METHOD, [clear_on_double_tap, same_building])
	var canonical := on_configure_build_tapped_state(clear_on_double_tap, same_building)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_CONFIGURE_BUILD_TAPPED_STATE,
		"generated_owner": source_building_source_text_state.SOURCE_BUILDING_ON_CONFIGURE_BUILD_TAPPED_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result is Dictionary and result == canonical,
	}

static func on_configure_tapped_state(x: float, y: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_CONFIGURE_TAPPED_STATE,
		"method": "public boolean onConfigureTapped(float x, float y){",
		"return_false": "return false;",
		"x": x,
		"y": y,
		"consumed": false,
	}

static func on_configure_closed_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_CONFIGURE_CLOSED_STATE,
		"method": "public void onConfigureClosed(){}",
		"no_op": true,
	}

static func configure_menu_visibility_state(_player: Variant) -> Dictionary:
	return {"should_show": true, "should_hide": false}

static func should_show_configure_state(_player: Variant) -> Dictionary:
	var source_exprs := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SHOULD_SHOW_CONFIGURE_STATE,
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
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SHOULD_HIDE_CONFIGURE_STATE,
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
	var result = _building_comp_call(SOURCE_BUILDING_CONFIGURE_CONFIGURED_JAVA_METHOD, [{}, value_state])
	var canonical = configured_type_state(value_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONFIGURED_TYPE_STATE,
		"generated_owner": SOURCE_BUILDING_CONFIGURE_CONFIGURED_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_update_last_access_bridge_state(builder_state: Dictionary, current_last_accessed: String) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CONFIGURE_UPDATE_LAST_ACCESS_JAVA_METHOD, [builder_state, current_last_accessed])
	var canonical = configured_last_access_state(builder_state, current_last_accessed)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONFIGURED_LAST_ACCESS_STATE,
		"generated_owner": SOURCE_BUILDING_CONFIGURE_UPDATE_LAST_ACCESS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_on_configure_tapped_bridge_state(x: float, y: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CONFIGURE_ON_CONFIGURE_TAPPED_JAVA_METHOD, [x, y])
	var canonical = on_configure_tapped_state(x, y)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_CONFIGURE_TAPPED_STATE,
		"generated_owner": SOURCE_BUILDING_CONFIGURE_ON_CONFIGURE_TAPPED_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_on_configure_closed_bridge_state() -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CONFIGURE_ON_CONFIGURE_CLOSED_JAVA_METHOD, [])
	var canonical = on_configure_closed_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_CONFIGURE_CLOSED_STATE,
		"generated_owner": SOURCE_BUILDING_CONFIGURE_ON_CONFIGURE_CLOSED_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_should_show_configure_bridge_state(player: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CONFIGURE_SHOULD_SHOW_JAVA_METHOD, [player])
	var canonical = should_show_configure_state(player)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SHOULD_SHOW_CONFIGURE_STATE,
		"generated_owner": SOURCE_BUILDING_CONFIGURE_SHOULD_SHOW_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_should_hide_configure_bridge_state(player: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CONFIGURE_SHOULD_HIDE_JAVA_METHOD, [player])
	var canonical = should_hide_configure_state(player)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SHOULD_HIDE_CONFIGURE_STATE,
		"generated_owner": SOURCE_BUILDING_CONFIGURE_SHOULD_HIDE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}
