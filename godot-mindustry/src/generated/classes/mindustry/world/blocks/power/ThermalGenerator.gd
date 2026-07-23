# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/power/ThermalGenerator.java
# Do not edit by hand.
extends RefCounted

const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")
const SourceTimeDefaults := preload("res://src/game/SourceTimeDefaults.gd")
const JAVA_PACKAGE := "mindustry.world.blocks.power"
const JAVA_KIND := "class"
const JAVA_NAME := "ThermalGenerator"
const JAVA_EXTENDS := "PowerGenerator"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "generateEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "effectChance", "type": "float"}, {"modifiers": ["public"], "name": "minEfficiency", "type": "float"}, {"modifiers": ["public"], "name": "displayEfficiencyScale", "type": "float"}, {"modifiers": ["public"], "name": "displayEfficiency", "type": "boolean"}, {"modifiers": ["public"], "name": "outputLiquid", "type": "LiquidStack"}, {"modifiers": ["public"], "name": "attribute", "type": "Attribute"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ThermalGenerator", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getDisplayedPowerProduction", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "canPlaceOn", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getDisplayedPowerProduction_0(_args: Array = []) -> Variant:
	return null

func java_method_init_1(_args: Array = []) -> Variant:
	return null

func java_method_setStats_2(_args: Array = []) -> Variant:
	var power_production: float = float(_args[0] if _args.size() > 0 else 0.0)
	var display_efficiency_scale: float = float(_args[1] if _args.size() > 1 else 1.0)
	var display_efficiency: bool = bool(_args[2] if _args.size() > 2 else true)
	var size: float = float(_args[3] if _args.size() > 3 else 1.0)
	var floating: bool = bool(_args[4] if _args.size() > 4 else false)
	var super_set_stats_state: Dictionary = _args[5] if _args.size() > 5 and _args[5] is Dictionary else {}
	var parent_state: Dictionary = super_set_stats_state.duplicate(true)
	var tile_stat_scale: float = size * size * display_efficiency_scale
	var tile_stat_start_zero: bool = not display_efficiency
	var source_tick_rate: float = SourceTimeDefaults.new(SourceSsotCatalog).tick_rate()
	var generation_stat_value: float = power_production * source_tick_rate / display_efficiency_scale
	var generation_stat_add: Dictionary = {"call": "stats.add(generationType, powerProduction * 60.0f / displayEfficiencyScale, StatUnit.powerSecond);", "stat": "generationType", "value": generation_stat_value, "unit": "StatUnit.powerSecond"}
	var output_liquid_present: bool = bool(_args[6] if _args.size() > 6 else false)
	var output_liquid_liquid: String = str(_args[7] if _args.size() > 7 else "")
	var output_liquid_amount: float = float(_args[8] if _args.size() > 8 else 0.0)
	var output_stat_amount: float = output_liquid_amount * size * size * source_tick_rate
	if not output_liquid_present:
		output_stat_amount = 0.0
	var output_stat_call: Dictionary = {}
	if output_liquid_present:
		output_stat_call = {"stat": "Stat.output", "liquid": output_liquid_liquid, "amount": output_stat_amount, "perSecond": true, "statValue": "StatValues.liquid"}
	return {"source_owner": "PortGame.source_thermal_generator_set_stats_state", "source": "core/src/mindustry/world/blocks/power/ThermalGenerator.java", "class": "public class ThermalGenerator extends PowerGenerator{", "attribute_field": "public Attribute attribute = Attribute.heat;", "display_efficiency_scale_field": "public float displayEfficiencyScale = 1f;", "display_efficiency_field": "public boolean displayEfficiency = true;", "override": "@Override", "method": "public void setStats(){", "super_call": "super.setStats();", "tiles_stat_add": "stats.add(Stat.tiles, attribute, floating, size * size * displayEfficiencyScale, !displayEfficiency);", "generation_type_remove": "stats.remove(generationType);", "generation_type_add": "stats.add(generationType, powerProduction * 60.0f / displayEfficiencyScale, StatUnit.powerSecond);", "power_production_field": "public float powerProduction;", "generation_type_field": "public Stat generationType = Stat.basePowerGeneration;", "floating_field": "public boolean floating = false;", "stats_add_attribute": "public void add(Stat stat, Attribute attr, boolean floating, float scale, boolean startZero){", "stats_remove": "public void remove(Stat stat){", "stat_base_power_generation": "basePowerGeneration = new Stat(\"basePowerGeneration\", StatCat.power),", "stat_tiles": "tiles = new Stat(\"tiles\", StatCat.crafting),", "stat_unit_power_second": "powerSecond = new StatUnit(\"powerSecond\", \"[accent]\" + Iconc.power + \"[]\"),", "output_liquid_field": "public @Nullable LiquidStack outputLiquid;", "output_liquid_guard": "if(outputLiquid != null){", "output_liquid_stat_add": "stats.add(Stat.output, StatValues.liquid(outputLiquid.liquid, outputLiquid.amount * size * size * 60f, true));", "power_production": power_production, "display_efficiency_scale": display_efficiency_scale, "display_efficiency": display_efficiency, "size": size, "floating": floating, "super_set_stats_state": parent_state, "tile_stat_scale": tile_stat_scale, "tile_stat_start_zero": tile_stat_start_zero, "generation_stat_removed": true, "generation_stat_value": generation_stat_value, "generation_stat_unit": "StatUnit.powerSecond", "generation_stat_add": generation_stat_add, "output_liquid_present": output_liquid_present, "output_liquid_liquid": output_liquid_liquid, "output_liquid_amount": output_liquid_amount, "output_stat_amount": output_stat_amount, "output_stat_added": output_liquid_present, "output_stat_call": output_stat_call}

func java_method_drawPlace_3(_args: Array = []) -> Variant:
	return null

func java_method_canPlaceOn_4(_args: Array = []) -> Variant:
	return null
