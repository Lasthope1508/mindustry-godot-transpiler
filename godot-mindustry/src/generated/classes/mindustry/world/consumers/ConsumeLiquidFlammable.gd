# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeLiquidFlammable.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeLiquidFlammable"
const JAVA_EXTENDS := "ConsumeLiquidFilter"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "minFlammability", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeLiquidFlammable", "parameters": [{"name": "minFlammability", "type": "float", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeLiquidFlammable", "parameters": [{"name": "amount", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeLiquidFlammable", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "liquidEfficiencyMultiplier", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_display_0(_args: Array = []) -> Variant:
	return null

func java_method_liquidEfficiencyMultiplier_1(_args: Array = []) -> Variant:
	var liquid_flammability: float = float(_args[0] if _args.size() > 0 else 0.0)
	var efficiency_multiplier: float = liquid_flammability
	return {"source_owner": "PortGame.source_consume_liquid_flammable_liquid_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeLiquidFlammable.java", "method": "public float liquidEfficiencyMultiplier(Liquid liquid){", "liquid_flammability": liquid_flammability, "efficiency_multiplier": efficiency_multiplier, "return_expr": "return liquid.flammability;"}
