extends RefCounted
class_name SourceThermalGeneratorState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_power_defaults := preload("res://src/game/SourcePowerDefaults.gd")
const source_projector_defaults := preload("res://src/game/SourceProjectorDefaults.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")


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
	var added: float = minf(production_efficiency * delta_value * output_liquid_amount, liquid_capacity - current_liquid_amount) if output_liquid_present else 0.0
	var liquid_amount_after: float = current_liquid_amount + added
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_UPDATE_TILE_OUTPUT_LIQUID_STATE,
		"method": "public void updateTile(){",
		"output_liquid_guard": "if(outputLiquid != null){",
		"added_assignment": "float added = Math.min(productionEfficiency * delta() * outputLiquid.amount, liquidCapacity - liquids.get(outputLiquid.liquid));",
		"liquids_add_call": "liquids.add(outputLiquid.liquid, added);",
		"dump_liquid_call": "dumpLiquid(outputLiquid.liquid);",
		"output_liquid_present": output_liquid_present,
		"output_liquid_liquid": output_liquid_liquid,
		"output_liquid_amount": output_liquid_amount,
		"production_efficiency": production_efficiency,
		"delta_value": delta_value,
		"liquid_capacity": liquid_capacity,
		"current_liquid_amount": current_liquid_amount,
		"added": added,
		"liquid_amount_after": liquid_amount_after,
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
		"method": "public void onProximityAdded(){",
		"super_call": "super.onProximityAdded();",
		"sum_assignment": "sum = sumAttribute(attribute, tile.x, tile.y);",
		"sum": sum_attribute,
		"super_on_proximity_added_state": super_on_proximity_added_state,
	}


static func can_place_on_state(linked_attribute_sum: float, min_efficiency: float) -> Dictionary:
	var can_place_on: bool = linked_attribute_sum > min_efficiency
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_CAN_PLACE_ON_STATE,
		"method": "public boolean canPlaceOn(Tile tile, Team team, int rotation){",
		"return_can_place_on": "return tile.getLinkedTilesAs(this, tempTiles).sumf(other -> other.floor().attributes.get(attribute)) > minEfficiency;",
		"linked_attribute_sum": linked_attribute_sum,
		"min_efficiency": min_efficiency,
		"can_place_on": can_place_on,
	}


static func draw_light_state(source_x: float, source_y: float, source_time: float, production_efficiency: float, size: float) -> Dictionary:
	var light_radius: float = (40.0 + source_math_state.source_absin(source_time, 10.0, 5.0)) * minf(production_efficiency, 2.0) * size
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_DRAW_LIGHT_STATE,
		"method": "public void drawLight(){",
		"drawf_light_call": "Drawf.light(x, y, (40f + Mathf.absin(10f, 5f)) * Math.min(productionEfficiency, 2f) * size, Color.scarlet, 0.4f);",
		"light_radius": light_radius,
		"light_color": "Color.scarlet",
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
		"method": "public void setStats(){",
		"tiles_stat_add": "stats.add(Stat.tiles, attribute, floating, size * size * displayEfficiencyScale, !displayEfficiency);",
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
		"method": "public void setStats(){",
		"output_liquid_guard": "if(outputLiquid != null){",
		"output_liquid_stat_add": "stats.add(Stat.output, StatValues.liquid(outputLiquid.liquid, outputLiquid.amount * size * size * 60f, true));",
		"output_liquid_present": output_liquid_present,
		"output_liquid_liquid": output_liquid_liquid,
		"output_liquid_amount": output_liquid_amount,
		"size": size,
		"output_stat_amount": output_stat_amount,
		"output_stat_added": output_liquid_present,
	}


static func draw_place_state(x: int, y: int, rotation_value: int, valid: bool, display_efficiency: bool, sum_attribute: float, display_efficiency_scale: float) -> Dictionary:
	var efficiency_value: float = sum_attribute * display_efficiency_scale
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_THERMAL_GENERATOR_DRAW_PLACE_STATE,
		"method": "public void drawPlace(int x, int y, int rotation, boolean valid){",
		"super_draw_place": "super.drawPlace(x, y, rotation, valid);",
		"display_efficiency_guard": "if(displayEfficiency){",
		"draw_place_text_call": "drawPlaceText(Core.bundle.formatFloat(\"bar.efficiency\", sumAttribute(attribute, x, y) * 100 * displayEfficiencyScale, 1), x, y, valid);",
		"efficiency_value": efficiency_value,
		"draw_place_text_added": display_efficiency,
		"x": x,
		"y": y,
		"rotation_value": rotation_value,
		"valid": valid,
		"display_efficiency": display_efficiency,
		"sum_attribute": sum_attribute,
		"display_efficiency_scale": display_efficiency_scale,
	}
