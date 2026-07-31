# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumePowerCondition.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumePowerCondition"
const JAVA_EXTENDS := "ConsumePower"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private"], "name": "consume", "type": "Boolf"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumePowerCondition", "parameters": [{"name": "usage", "type": "float", "varargs": false}, {"name": "consume", "type": "Boolf", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "requestedPower", "parameters": [{"name": "entity", "type": "Building", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_requestedPower_0(_args: Array = []) -> Variant:
	var usage: float = float(_args[0] if _args.size() > 0 else 0.0)
	var consume_get: bool = bool(_args[1] if _args.size() > 1 else false)
	var requested_power: float = usage if consume_get else 0.0
	return {"source_owner": "port_game.source_consume_power_condition_requested_power_state", "source": "core/src/mindustry/world/consumers/ConsumePowerCondition.java", "method": "public float requestedPower(Building entity){", "usage": usage, "consume_get": consume_get, "requested_power": requested_power, "return_expr": "return consume.get(entity) ? usage : 0f;"}
