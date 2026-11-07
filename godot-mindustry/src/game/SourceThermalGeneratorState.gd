extends RefCounted
class_name SourceThermalGeneratorState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_power_defaults := preload("res://src/game/SourcePowerDefaults.gd")
const source_projector_defaults := preload("res://src/game/SourceProjectorDefaults.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_thermal_generator_source_text_state := preload("res://src/game/SourceThermalGeneratorSourceTextState.gd")

const SOURCE_THERMAL_GENERATOR_DRAW_LIGHT_METHOD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_DRAW_LIGHT_METHOD
const SOURCE_THERMAL_GENERATOR_SET_STATS_METHOD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_SET_STATS_METHOD
const SOURCE_THERMAL_GENERATOR_CLASS := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_CLASS
const SOURCE_THERMAL_GENERATOR_DISPLAY_EFFICIENCY_SCALE_FIELD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_DISPLAY_EFFICIENCY_SCALE_FIELD
const SOURCE_THERMAL_GENERATOR_DISPLAY_EFFICIENCY_FIELD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_DISPLAY_EFFICIENCY_FIELD
const SOURCE_THERMAL_GENERATOR_ATTRIBUTE_FIELD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_ATTRIBUTE_FIELD
const SOURCE_THERMAL_GENERATOR_DRAW_PLACE_METHOD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_DRAW_PLACE_METHOD
const SOURCE_THERMAL_GENERATOR_SUPER_DRAW_PLACE := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_SUPER_DRAW_PLACE
const SOURCE_THERMAL_GENERATOR_DISPLAY_EFFICIENCY_GUARD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_DISPLAY_EFFICIENCY_GUARD
const SOURCE_THERMAL_GENERATOR_DRAW_PLACE_TEXT_CALL := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_DRAW_PLACE_TEXT_CALL
const SOURCE_BLOCK_DRAW_PLACE_METHOD := source_thermal_generator_source_text_state.SOURCE_BLOCK_DRAW_PLACE_METHOD
const SOURCE_BLOCK_DRAW_PLACE_TEXT_METHOD := source_thermal_generator_source_text_state.SOURCE_BLOCK_DRAW_PLACE_TEXT_METHOD
const SOURCE_THERMAL_GENERATOR_BUNDLE_EFFICIENCY := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_BUNDLE_EFFICIENCY
const SOURCE_THERMAL_GENERATOR_BUNDLE_KEY := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_BUNDLE_KEY
const SOURCE_THERMAL_GENERATOR_DECIMALS := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_DECIMALS
const SOURCE_THERMAL_GENERATOR_BUILD_CLASS := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_BUILD_CLASS
const SOURCE_THERMAL_GENERATOR_OVERRIDE := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_OVERRIDE
const SOURCE_THERMAL_GENERATOR_DRAWF_LIGHT_METHOD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_DRAWF_LIGHT_METHOD
const SOURCE_THERMAL_GENERATOR_DRAWF_RENDERER_GUARD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_DRAWF_RENDERER_GUARD
const SOURCE_THERMAL_GENERATOR_DRAWF_LIGHTS_ADD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_DRAWF_LIGHTS_ADD
const SOURCE_THERMAL_GENERATOR_ABSIN_TIME_OVERLOAD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_ABSIN_TIME_OVERLOAD
const SOURCE_THERMAL_GENERATOR_ABSIN_TIME_RETURN := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_ABSIN_TIME_RETURN
const SOURCE_THERMAL_GENERATOR_ABSIN_FORMULA := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_ABSIN_FORMULA
const SOURCE_THERMAL_GENERATOR_SCARLET := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_SCARLET
const SOURCE_THERMAL_GENERATOR_SCARLET_RGBA8888 := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_SCARLET_RGBA8888
const SOURCE_THERMAL_GENERATOR_DRAWF_LIGHT_CALL := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_DRAWF_LIGHT_CALL
const SOURCE_THERMAL_GENERATOR_LIGHT_COLOR := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_LIGHT_COLOR
const SOURCE_THERMAL_GENERATOR_LIGHT_OPACITY := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_LIGHT_OPACITY
const SOURCE_THERMAL_GENERATOR_TILES_STAT_ADD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_TILES_STAT_ADD
const SOURCE_THERMAL_GENERATOR_MIN_EFFICIENCY_FIELD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_MIN_EFFICIENCY_FIELD
const SOURCE_THERMAL_GENERATOR_CAN_PLACE_ON_METHOD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_CAN_PLACE_ON_METHOD
const SOURCE_THERMAL_GENERATOR_HEAT_COMMENT := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_HEAT_COMMENT
const SOURCE_THERMAL_GENERATOR_CAN_PLACE_ON_RETURN := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_CAN_PLACE_ON_RETURN
const SOURCE_BLOCK_CAN_PLACE_ON_METHOD := source_thermal_generator_source_text_state.SOURCE_BLOCK_CAN_PLACE_ON_METHOD
const SOURCE_BLOCK_CAN_PLACE_ON_RETURN := source_thermal_generator_source_text_state.SOURCE_BLOCK_CAN_PLACE_ON_RETURN
const SOURCE_THERMAL_GENERATOR_SUM_FIELD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_SUM_FIELD
const SOURCE_THERMAL_GENERATOR_ON_PROXIMITY_ADDED_METHOD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_ON_PROXIMITY_ADDED_METHOD
const SOURCE_THERMAL_GENERATOR_SUM_ASSIGNMENT := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_SUM_ASSIGNMENT
const SOURCE_THERMAL_GENERATOR_SUPER_ON_PROXIMITY_ADDED := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_SUPER_ON_PROXIMITY_ADDED
const SOURCE_BUILDING_ON_PROXIMITY_ADDED_COMMENT := source_thermal_generator_source_text_state.SOURCE_BUILDING_ON_PROXIMITY_ADDED_COMMENT
const SOURCE_BUILDING_ON_PROXIMITY_ADDED_METHOD := source_thermal_generator_source_text_state.SOURCE_BUILDING_ON_PROXIMITY_ADDED_METHOD
const SOURCE_BUILDING_ON_PROXIMITY_ADDED_POWER_GUARD := source_thermal_generator_source_text_state.SOURCE_BUILDING_ON_PROXIMITY_ADDED_POWER_GUARD
const SOURCE_BUILDING_UPDATE_POWER_GRAPH := source_thermal_generator_source_text_state.SOURCE_BUILDING_UPDATE_POWER_GRAPH
const SOURCE_BLOCK_SUM_ATTRIBUTE_METHOD := source_thermal_generator_source_text_state.SOURCE_BLOCK_SUM_ATTRIBUTE_METHOD
const SOURCE_BLOCK_SUM_ATTRIBUTE_NULL_ATTR := source_thermal_generator_source_text_state.SOURCE_BLOCK_SUM_ATTRIBUTE_NULL_ATTR
const SOURCE_BLOCK_SUM_ATTRIBUTE_NULL_TILE := source_thermal_generator_source_text_state.SOURCE_BLOCK_SUM_ATTRIBUTE_NULL_TILE
const SOURCE_THERMAL_GENERATOR_UPDATE_TILE_METHOD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_UPDATE_TILE_METHOD
const SOURCE_THERMAL_GENERATOR_OUTPUT_LIQUID_FIELD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_OUTPUT_LIQUID_FIELD
const SOURCE_THERMAL_GENERATOR_OUTPUT_LIQUID_GUARD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_OUTPUT_LIQUID_GUARD
const SOURCE_THERMAL_GENERATOR_ADDED_ASSIGNMENT := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_ADDED_ASSIGNMENT
const SOURCE_THERMAL_GENERATOR_LIQUIDS_ADD_CALL := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_LIQUIDS_ADD_CALL
const SOURCE_THERMAL_GENERATOR_DUMP_LIQUID_CALL := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_DUMP_LIQUID_CALL
const SOURCE_THERMAL_GENERATOR_SET_STATS_OUTPUT_LIQUID_STAT_ADD := source_thermal_generator_source_text_state.SOURCE_THERMAL_GENERATOR_SET_STATS_OUTPUT_LIQUID_STAT_ADD
const SOURCE_LIQUID_STACK_CLASS := source_thermal_generator_source_text_state.SOURCE_LIQUID_STACK_CLASS
const SOURCE_LIQUID_STACK_LIQUID_FIELD := source_thermal_generator_source_text_state.SOURCE_LIQUID_STACK_LIQUID_FIELD
const SOURCE_LIQUID_STACK_AMOUNT_FIELD := source_thermal_generator_source_text_state.SOURCE_LIQUID_STACK_AMOUNT_FIELD
const SOURCE_STAT_OUTPUT := source_thermal_generator_source_text_state.SOURCE_STAT_OUTPUT
const SOURCE_STAT_VALUES_LIQUID_METHOD := source_thermal_generator_source_text_state.SOURCE_STAT_VALUES_LIQUID_METHOD
const SOURCE_STAT_VALUES_LIQUID_RETURN := source_thermal_generator_source_text_state.SOURCE_STAT_VALUES_LIQUID_RETURN


static func update_tile_state(sum: float, attribute_env: float) -> Dictionary:
	var production_efficiency: float = sum + attribute_env
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_UPDATE_TILE_STATE,
		"method": "public void updateTile(){",
		"assignment": "productionEfficiency = sum + attribute.env();",
		"attribute_env_null_guard": "if(Vars.state == null) return 0;",
		"sum": sum,
		"attribute_env": attribute_env,
		"production_efficiency": production_efficiency,
	}


static func update_tile_effect_state(source_x: float, source_y: float, production_efficiency: float, effect_chance: float, chance_delta_result: bool, range_x: float, range_y: float, generate_effect_name: String) -> Dictionary:
	var effect_triggered: bool = production_efficiency > 0.1 and chance_delta_result
	var effect_x: float = source_x + range_x
	var effect_y: float = source_y + range_y
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_UPDATE_TILE_EFFECT_STATE,
		"method": "public void updateTile(){",
		"effect_gate": "if(productionEfficiency > 0.1f && Mathf.chanceDelta(effectChance)){",
		"generate_effect_call": "generateEffect.at(x + Mathf.range(3f), y + Mathf.range(3f));",
		"effect_triggered": effect_triggered,
		"effect_x": effect_x,
		"effect_y": effect_y,
		"source_x": source_x,
		"source_y": source_y,
		"production_efficiency": production_efficiency,
		"effect_chance": effect_chance,
		"chance_delta_result": chance_delta_result,
		"range_x": range_x,
		"range_y": range_y,
		"generate_effect_name": generate_effect_name,
	}


static func update_tile_output_liquid_state(output_liquid_present: bool, output_liquid_liquid: String, output_liquid_amount: float, production_efficiency: float, delta_value: float, liquid_capacity: float, current_liquid_amount: float) -> Dictionary:
	var production_liquid_amount: float = production_efficiency * delta_value * output_liquid_amount if output_liquid_present else 0.0
	var remaining_capacity: float = liquid_capacity - current_liquid_amount if output_liquid_present else 0.0
	var added: float = minf(production_liquid_amount, remaining_capacity)
	var liquid_amount_after: float = current_liquid_amount + added
	var dump_liquid_called: bool = output_liquid_present
	var dump_liquid_state: Dictionary = {"liquid": output_liquid_liquid} if dump_liquid_called else {}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_UPDATE_TILE_OUTPUT_LIQUID_STATE,
		"class": SOURCE_THERMAL_GENERATOR_CLASS,
		"method": SOURCE_THERMAL_GENERATOR_UPDATE_TILE_METHOD,
		"output_liquid_field": SOURCE_THERMAL_GENERATOR_OUTPUT_LIQUID_FIELD,
		"build_class": SOURCE_THERMAL_GENERATOR_BUILD_CLASS,
		"output_liquid_guard": SOURCE_THERMAL_GENERATOR_OUTPUT_LIQUID_GUARD,
		"added_assignment": SOURCE_THERMAL_GENERATOR_ADDED_ASSIGNMENT,
		"liquids_add_call": SOURCE_THERMAL_GENERATOR_LIQUIDS_ADD_CALL,
		"dump_liquid_call": SOURCE_THERMAL_GENERATOR_DUMP_LIQUID_CALL,
		"output_liquid_present": output_liquid_present,
		"output_liquid_liquid": output_liquid_liquid,
		"output_liquid_amount": output_liquid_amount,
		"production_efficiency": production_efficiency,
		"delta_value": delta_value,
		"liquid_capacity": liquid_capacity,
		"current_liquid_amount": current_liquid_amount,
		"production_liquid_amount": production_liquid_amount,
		"remaining_capacity": remaining_capacity,
		"added": added,
		"liquid_amount_after": liquid_amount_after,
		"dump_liquid_called": dump_liquid_called,
		"dump_liquid_state": dump_liquid_state,
	}


static func displayed_power_production_state(power_production: float, display_efficiency_scale: float) -> Dictionary:
	var displayed_power_production: float = power_production / display_efficiency_scale if display_efficiency_scale != 0.0 else power_production
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_DISPLAYED_POWER_PRODUCTION_STATE,
		"method": "public float getDisplayedPowerProduction(){",
		"return_displayed_power": "return powerProduction / displayEfficiencyScale;",
		"power_production": power_production,
		"display_efficiency_scale": display_efficiency_scale,
		"displayed_power_production": displayed_power_production,
	}


static func init_state(output_liquid_present: bool, light_clip_size: float, size: float) -> Dictionary:
	var computed_light_clip_size: float = maxf(light_clip_size, 45.0 * size * 2.0 * 2.0)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_INIT_STATE,
		"method": "public void init(){",
		"output_liquid_guard": "if(outputLiquid != null){",
		"outputs_liquid_source": "outputsLiquid = true;",
		"light_clip_assignment": "lightClipSize = Math.max(lightClipSize, 45f * size * 2f * 2f);",
		"output_liquid_present": output_liquid_present,
		"light_clip_size": computed_light_clip_size,
		"size": size,
	}


static func total_progress_state(enabled: bool, sum: float, super_total_progress: float) -> Dictionary:
	var total_progress: float = super_total_progress if enabled and sum > 0.0 else 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_TOTAL_PROGRESS_STATE,
		"method": "public float totalProgress(){",
		"return_total_progress": "return enabled && sum > 0 ? super.totalProgress() : 0f;",
		"enabled": enabled,
		"sum": sum,
		"super_total_progress": super_total_progress,
		"total_progress": total_progress,
	}


@warning_ignore("unused_parameter")
static func after_picked_up_state(sum: float, super_after_picked_up_state: Dictionary) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_AFTER_PICKED_UP_STATE,
		"method": "public void afterPickedUp(){",
		"super_call": "super.afterPickedUp();",
		"sum_reset": "sum = 0f;",
		"sum": 0.0,
		"super_after_picked_up_state": super_after_picked_up_state,
	}


static func on_proximity_added_state(sum_attribute: float, super_on_proximity_added_state: Dictionary) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_ON_PROXIMITY_ADDED_STATE,
		"build_class": SOURCE_THERMAL_GENERATOR_BUILD_CLASS,
		"sum_field": SOURCE_THERMAL_GENERATOR_SUM_FIELD,
		"override": SOURCE_THERMAL_GENERATOR_OVERRIDE,
		"method": SOURCE_THERMAL_GENERATOR_ON_PROXIMITY_ADDED_METHOD,
		"super_call": SOURCE_THERMAL_GENERATOR_SUPER_ON_PROXIMITY_ADDED,
		"sum_assignment": SOURCE_THERMAL_GENERATOR_SUM_ASSIGNMENT,
		"parent_comment": SOURCE_BUILDING_ON_PROXIMITY_ADDED_COMMENT,
		"parent_method": SOURCE_BUILDING_ON_PROXIMITY_ADDED_METHOD,
		"parent_power_guard": SOURCE_BUILDING_ON_PROXIMITY_ADDED_POWER_GUARD,
		"parent_update_power_graph": SOURCE_BUILDING_UPDATE_POWER_GRAPH,
		"sum_attribute_method": SOURCE_BLOCK_SUM_ATTRIBUTE_METHOD,
		"sum_attribute_null_attr": SOURCE_BLOCK_SUM_ATTRIBUTE_NULL_ATTR,
		"sum_attribute_null_tile": SOURCE_BLOCK_SUM_ATTRIBUTE_NULL_TILE,
		"sum_attribute": sum_attribute,
		"sum": sum_attribute,
		"super_on_proximity_added_state": super_on_proximity_added_state,
	}


static func can_place_on_state(linked_attribute_sum: float, min_efficiency: float) -> Dictionary:
	var can_place_on: bool = linked_attribute_sum > min_efficiency
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_CAN_PLACE_ON_STATE,
		"class": SOURCE_THERMAL_GENERATOR_CLASS,
		"attribute_field": SOURCE_THERMAL_GENERATOR_ATTRIBUTE_FIELD,
		"min_efficiency_field": SOURCE_THERMAL_GENERATOR_MIN_EFFICIENCY_FIELD,
		"override": SOURCE_THERMAL_GENERATOR_OVERRIDE,
		"method": SOURCE_THERMAL_GENERATOR_CAN_PLACE_ON_METHOD,
		"heat_comment": SOURCE_THERMAL_GENERATOR_HEAT_COMMENT,
		"return_can_place_on": SOURCE_THERMAL_GENERATOR_CAN_PLACE_ON_RETURN,
		"parent_method": SOURCE_BLOCK_CAN_PLACE_ON_METHOD,
		"parent_return": SOURCE_BLOCK_CAN_PLACE_ON_RETURN,
		"linked_attribute_sum": linked_attribute_sum,
		"min_efficiency": min_efficiency,
		"can_place_on": can_place_on,
	}


static func draw_light_state(source_x: float, source_y: float, source_time: float, production_efficiency: float, size: float) -> Dictionary:
	var absin_value: float = source_math_state.source_absin(source_time, 10.0, 5.0)
	var capped_production_efficiency: float = minf(production_efficiency, 2.0)
	var light_radius: float = (40.0 + absin_value) * capped_production_efficiency * size
	var light_call: Dictionary = {"x": source_x, "y": source_y, "radius": light_radius, "color": SOURCE_THERMAL_GENERATOR_LIGHT_COLOR, "opacity": SOURCE_THERMAL_GENERATOR_LIGHT_OPACITY}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_DRAW_LIGHT_STATE,
		"build_class": SOURCE_THERMAL_GENERATOR_BUILD_CLASS,
		"override": SOURCE_THERMAL_GENERATOR_OVERRIDE,
		"method": SOURCE_THERMAL_GENERATOR_DRAW_LIGHT_METHOD,
		"drawf_light_call": SOURCE_THERMAL_GENERATOR_DRAWF_LIGHT_CALL,
		"drawf_light_method": SOURCE_THERMAL_GENERATOR_DRAWF_LIGHT_METHOD,
		"drawf_renderer_guard": SOURCE_THERMAL_GENERATOR_DRAWF_RENDERER_GUARD,
		"drawf_lights_add": SOURCE_THERMAL_GENERATOR_DRAWF_LIGHTS_ADD,
		"absin_time_overload": SOURCE_THERMAL_GENERATOR_ABSIN_TIME_OVERLOAD,
		"absin_time_return": SOURCE_THERMAL_GENERATOR_ABSIN_TIME_RETURN,
		"absin_formula": SOURCE_THERMAL_GENERATOR_ABSIN_FORMULA,
		"absin": absin_value,
		"capped_production_efficiency": capped_production_efficiency,
		"light_radius": light_radius,
		"light_color": SOURCE_THERMAL_GENERATOR_LIGHT_COLOR,
		"light_color_rgba8888": SOURCE_THERMAL_GENERATOR_SCARLET_RGBA8888,
		"opacity": SOURCE_THERMAL_GENERATOR_LIGHT_OPACITY,
		"light_call": light_call,
		"source_x": source_x,
		"source_y": source_y,
		"source_time": source_time,
		"production_efficiency": production_efficiency,
		"size": size,
	}


static func set_stats_state(power_production: float, display_efficiency_scale: float, display_efficiency: bool, size: float, floating: bool, super_set_stats_state: Dictionary) -> Dictionary:
	var tile_stat_scale: float = size * size * display_efficiency_scale
	var generation_stat_value := power_production * source_time_defaults.TICK_RATE / display_efficiency_scale
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_SET_STATS_STATE,
		"method": SOURCE_THERMAL_GENERATOR_SET_STATS_METHOD,
		"tiles_stat_add": SOURCE_THERMAL_GENERATOR_TILES_STAT_ADD,
		"tile_stat_scale": tile_stat_scale,
		"power_production": power_production,
		"display_efficiency_scale": display_efficiency_scale,
		"display_efficiency": display_efficiency,
		"size": size,
		"floating": floating,
		"super_set_stats_state": super_set_stats_state,
		"generation_stat_value": generation_stat_value,
	}


static func set_stats_output_liquid_state(output_liquid_present: bool, output_liquid_liquid: String, output_liquid_amount: float, size: float) -> Dictionary:
	var output_stat_amount := output_liquid_amount * size * size * source_time_defaults.TICK_RATE if output_liquid_present else 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_SET_STATS_OUTPUT_LIQUID_STATE,
		"class": SOURCE_THERMAL_GENERATOR_CLASS,
		"output_liquid_field": SOURCE_THERMAL_GENERATOR_OUTPUT_LIQUID_FIELD,
		"method": SOURCE_THERMAL_GENERATOR_SET_STATS_METHOD,
		"output_liquid_guard": SOURCE_THERMAL_GENERATOR_OUTPUT_LIQUID_GUARD,
		"output_liquid_stat_add": SOURCE_THERMAL_GENERATOR_SET_STATS_OUTPUT_LIQUID_STAT_ADD,
		"liquid_stack_class": SOURCE_LIQUID_STACK_CLASS,
		"liquid_stack_liquid": SOURCE_LIQUID_STACK_LIQUID_FIELD,
		"liquid_stack_amount": SOURCE_LIQUID_STACK_AMOUNT_FIELD,
		"stat_output": SOURCE_STAT_OUTPUT,
		"stat_values_liquid": SOURCE_STAT_VALUES_LIQUID_METHOD,
		"stat_values_liquid_return": SOURCE_STAT_VALUES_LIQUID_RETURN,
		"output_liquid_present": output_liquid_present,
		"output_liquid_liquid": output_liquid_liquid,
		"output_liquid_amount": output_liquid_amount,
		"size": size,
		"output_stat_amount": output_stat_amount,
		"output_stat_added": output_liquid_present,
	}


static func draw_place_state(x: int, y: int, rotation_value: int, valid: bool, display_efficiency: bool, sum_attribute: float, display_efficiency_scale: float) -> Dictionary:
	var efficiency_value: float = sum_attribute * 100.0 * display_efficiency_scale
	var draw_place_text_state: Dictionary = {}
	if display_efficiency:
		draw_place_text_state = {
			"bundle_key": SOURCE_THERMAL_GENERATOR_BUNDLE_KEY,
			"decimals": SOURCE_THERMAL_GENERATOR_DECIMALS,
			"text_value": efficiency_value,
			"x": x,
			"y": y,
			"valid": valid,
		}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_DRAW_PLACE_STATE,
		"class": SOURCE_THERMAL_GENERATOR_CLASS,
		"display_efficiency_scale_field": SOURCE_THERMAL_GENERATOR_DISPLAY_EFFICIENCY_SCALE_FIELD,
		"display_efficiency_field": SOURCE_THERMAL_GENERATOR_DISPLAY_EFFICIENCY_FIELD,
		"attribute_field": SOURCE_THERMAL_GENERATOR_ATTRIBUTE_FIELD,
		"method": SOURCE_THERMAL_GENERATOR_DRAW_PLACE_METHOD,
		"super_draw_place": SOURCE_THERMAL_GENERATOR_SUPER_DRAW_PLACE,
		"display_efficiency_guard": SOURCE_THERMAL_GENERATOR_DISPLAY_EFFICIENCY_GUARD,
		"draw_place_text_call": SOURCE_THERMAL_GENERATOR_DRAW_PLACE_TEXT_CALL,
		"block_draw_place": SOURCE_BLOCK_DRAW_PLACE_METHOD,
		"block_draw_place_text": SOURCE_BLOCK_DRAW_PLACE_TEXT_METHOD,
		"bundle_efficiency": SOURCE_THERMAL_GENERATOR_BUNDLE_EFFICIENCY,
		"bundle_key": SOURCE_THERMAL_GENERATOR_BUNDLE_KEY,
		"decimals": SOURCE_THERMAL_GENERATOR_DECIMALS,
		"efficiency_value": efficiency_value,
		"draw_place_text_added": display_efficiency,
		"draw_place_text_state": draw_place_text_state,
		"x": x,
		"y": y,
		"rotation": rotation_value,
		"rotation_value": rotation_value,
		"valid": valid,
		"display_efficiency": display_efficiency,
		"sum_attribute": sum_attribute,
		"display_efficiency_scale": display_efficiency_scale,
	}
