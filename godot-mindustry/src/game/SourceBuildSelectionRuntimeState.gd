extends RefCounted
class_name SourceBuildSelectionRuntimeState

const source_input_defaults := preload("res://src/game/SourceInputDefaults.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_selected_build_state := preload("res://src/game/SourceSelectedBuildState.gd")
const source_projector_defaults := preload("res://src/game/SourceProjectorDefaults.gd")
const source_mend_projector_state := preload("res://src/game/SourceMendProjectorState.gd")

static func build_block_palette(game: Object) -> void:
	var content_catalog = game.get("content_catalog")
	var build_palette_value = game.get("build_palette")
	if not (build_palette_value is Array):
		return
	var build_palette: Array = build_palette_value
	build_palette.clear()
	if content_catalog == null:
		return
	for block_id in source_playable_scenario_defaults.pinned_build_block_ids():
		var block = content_catalog.get_by_id(block_id)
		if block != null and block.has_texture():
			build_palette.append(block)
	for block in content_catalog.get_many("block"):
		if block.has_texture() and not build_palette.has(block):
			build_palette.append(block)

static func select_build_slot_action(game: Object, canonical_action: String) -> void:
	var control: RefCounted = source_input_defaults.control_input()
	if control.is_previous_slot_action(canonical_action):
		select_previous_build_slot(game)
		return
	if control.is_next_slot_action(canonical_action):
		select_next_build_slot(game)
		return
	var index: int = control.build_slot_for_action(canonical_action)
	if index < 0:
		return
	var build_palette_value = game.get("build_palette")
	if not (build_palette_value is Array):
		return
	var build_palette: Array = build_palette_value
	if index < build_palette.size():
		game.set("selected_build_index", index)

static func select_next_build_slot(game: Object) -> void:
	var build_palette_value = game.get("build_palette")
	if not (build_palette_value is Array):
		return
	var build_palette: Array = build_palette_value
	if build_palette.is_empty():
		return
	game.set("selected_build_index", (int(game.get("selected_build_index")) + 1) % build_palette.size())

static func select_previous_build_slot(game: Object) -> void:
	var build_palette_value = game.get("build_palette")
	if not (build_palette_value is Array):
		return
	var build_palette: Array = build_palette_value
	if build_palette.is_empty():
		return
	game.set("selected_build_index", (int(game.get("selected_build_index")) - 1 + build_palette.size()) % build_palette.size())

static func block_by_id(game: Object, block_id: String) -> Variant:
	var content_catalog = game.get("content_catalog")
	if content_catalog == null:
		return null
	return content_catalog.get_by_id(block_id)

static func selected_build_for_game(game: Object) -> Variant:
	var build_palette_value = game.get("build_palette")
	if not (build_palette_value is Array):
		return null
	var build_palette: Array = build_palette_value
	return source_selected_build_state.selected_build(build_palette, int(game.get("selected_build_index")))

static func selected_build_health(game: Object) -> float:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.health(selected)

static func selected_build_scaled_health(game: Object) -> float:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.scaled_health(selected)

static func selected_build_heal_percent(game: Object) -> float:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.heal_percent(selected)

static func selected_build_phase_boost(game: Object) -> float:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.phase_boost(selected)

static func selected_build_phase_range_boost(game: Object) -> float:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.phase_range_boost(selected)

static func selected_build_can_overdrive(game: Object) -> bool:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.can_overdrive(selected)

static func selected_build_has_power(game: Object) -> bool:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.has_power(selected)

static func selected_build_consumes_power(game: Object) -> bool:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.consumes_power(selected)

static func selected_build_outputs_power(game: Object) -> bool:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.outputs_power(selected)

static func selected_build_power_usage(game: Object) -> float:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.power_usage(selected)

static func selected_build_power_capacity(game: Object) -> float:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.power_capacity(selected)

static func selected_build_power_buffered(game: Object) -> bool:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.power_buffered(selected)

static func selected_build_power_production(game: Object) -> float:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.power_production(selected)

static func selected_build_item_duration(game: Object) -> float:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.item_duration(selected)

static func selected_build_max_nodes(game: Object) -> int:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.max_nodes(selected)

static func selected_build_laser_range(game: Object) -> float:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.laser_range(selected)

static func selected_build_overdrive_real_boost(game: Object) -> float:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.overdrive_real_boost(selected)

static func selected_build_overdrive_phase_real_boost(game: Object) -> float:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.overdrive_phase_real_boost(selected)

static func selected_build_overdrive_boost_bar_fraction(game: Object) -> float:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.overdrive_boost_bar_fraction(selected)

static func selected_build_overdrive_phase_boost_bar_fraction(game: Object) -> float:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.overdrive_phase_boost_bar_fraction(selected)

static func selected_build_overdrive_place_state(game: Object) -> Dictionary:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.overdrive_place_state(selected)

static func selected_build_overdrive_phase_select_state(game: Object) -> Dictionary:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.overdrive_phase_select_state(selected)

static func selected_build_overdrive_light_state_for_smooth_efficiency(game: Object, smooth_efficiency: float) -> Dictionary:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.overdrive_light_state_for_smooth_efficiency(selected, smooth_efficiency)

static func selected_build_overdrive_draw_state_for_inputs(game: Object, heat: float, phase_heat: float, source_time_ticks := 0.0, tile_size := 0.0) -> Dictionary:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.overdrive_draw_state_for_inputs(selected, heat, phase_heat, tile_size, source_time_ticks)

static func selected_build_booster_item(game: Object) -> String:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.booster_item(selected)

static func selected_build_booster_use_time(game: Object) -> float:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.booster_use_time(selected)

static func selected_build_place_state(game: Object) -> Dictionary:
	var selected: Variant = selected_build_for_game(game)
	return source_selected_build_state.place_state(selected)

static func selected_build_repair_amount(game: Object, content_catalog) -> float:
	if content_catalog == null:
		return 0.0
	var selected: Variant = selected_build_for_game(game)
	if selected == null:
		return 0.0
	var mend_projector: Variant = content_catalog.get_by_id(source_projector_defaults.MEND_PROJECTOR_BLOCK_ID)
	return source_mend_projector_state.repair_amount(mend_projector, selected)

static func selected_build_overdrive_target_filter_state_for_block_id(game: Object, target_block_id: String, distance: float, phase_heat := 0.0) -> Dictionary:
	var build_palette_value = game.get("build_palette")
	if not (build_palette_value is Array) or build_palette_value.is_empty():
		return {"real_range": 0.0, "distance": distance, "can_overdrive": false, "in_range": false, "eligible": false}
	var selected = source_selected_build_state.selected_build(build_palette_value, int(game.get("selected_build_index")))
	var target = block_by_id(game, target_block_id)
	return source_selected_build_state.overdrive_target_filter_state(selected, target, distance, phase_heat)

static func select_build_block_by_id(game: Object, block_id: String) -> bool:
	var build_palette_value = game.get("build_palette")
	if not (build_palette_value is Array):
		return false
	var build_palette: Array = build_palette_value
	for index in build_palette.size():
		if build_palette[index].id == block_id:
			game.set("selected_build_index", index)
			return true
	return false
