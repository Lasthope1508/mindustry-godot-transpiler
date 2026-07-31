# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumePowerDynamic.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumePowerDynamic"
const JAVA_EXTENDS := "ConsumePower"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private"], "name": "usage", "type": "Floatf"}, {"modifiers": ["private"], "name": "displayedPowerUsage", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumePowerDynamic", "parameters": [{"name": "usage", "type": "Floatf", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumePowerDynamic", "parameters": [{"name": "displayed", "type": "float", "varargs": false}, {"name": "usage", "type": "Floatf", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "requestedPower", "parameters": [{"name": "entity", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const SOURCE_TICK_RATE := source_time_defaults.TICK_RATE

func java_method_requestedPower_0(_args: Array = []) -> Variant:
	var usage_get: float = float(_args[0] if _args.size() > 0 else 0.0)
	var requested_power: float = usage_get
	return {"source_owner": "port_game.source_consume_power_dynamic_requested_power_state", "source": "core/src/mindustry/world/consumers/ConsumePowerDynamic.java", "method": "public float requestedPower(Building entity){", "usage_get": usage_get, "requested_power": requested_power, "return_expr": "return usage.get(entity);"}

func java_method_display_1(_args: Array = []) -> Variant:
	var displayed_power_usage: float = float(_args[0] if _args.size() > 0 else 0.0)
	var source_tick_rate: float = float(_args[1] if _args.size() > 1 else SOURCE_TICK_RATE)
	var display_guard: bool = displayed_power_usage != 0.0
	var power_use_value: float = displayed_power_usage * source_tick_rate
	var stats_add_call: Dictionary = {}
	if display_guard:
		stats_add_call = {"call": "stats.add(Stat.powerUse, displayedPowerUsage * 60f, StatUnit.powerSecond);", "stat": "Stat.powerUse", "value": power_use_value, "unit": "StatUnit.powerSecond"}
	return {"source_owner": "port_game.source_consume_power_dynamic_display_state", "source": "core/src/mindustry/world/consumers/ConsumePowerDynamic.java", "method": "public void display(Stats stats){", "displayed_power_usage": displayed_power_usage, "display_guard": display_guard, "stats_add_called": display_guard, "power_use_value": power_use_value, "stats_add_call": stats_add_call, "guard_expr": "if(displayedPowerUsage != 0f){", "stats_add_expr": "stats.add(Stat.powerUse, displayedPowerUsage * 60f, StatUnit.powerSecond);"}
