# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumePower.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumePower"
const JAVA_EXTENDS := "Consume"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "usage", "type": "float"}, {"modifiers": ["public"], "name": "capacity", "type": "float"}, {"modifiers": ["public"], "name": "buffered", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumePower", "parameters": [{"name": "usage", "type": "float", "varargs": false}, {"name": "capacity", "type": "float", "varargs": false}, {"name": "buffered", "type": "boolean", "varargs": false}]}, {"modifiers": ["protected"], "name": "ConsumePower", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "ignore", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "requestedPower", "parameters": [{"name": "entity", "type": "Building", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_apply_0(_args: Array = []) -> Variant:
	return null

func java_method_ignore_1(_args: Array = []) -> Variant:
	var buffered: bool = bool(_args[0] if _args.size() > 0 else false)
	var ignore_consume: bool = buffered
	return {"source_owner": "PortGame.source_consume_power_ignore_state", "source": "core/src/mindustry/world/consumers/ConsumePower.java", "method": "public boolean ignore(){", "buffered": buffered, "ignore": ignore_consume, "return_expr": "return buffered;"}

func java_method_efficiency_2(_args: Array = []) -> Variant:
	var power_status: float = float(_args[0] if _args.size() > 0 else 0.0)
	var efficiency: float = power_status
	return {"source_owner": "PortGame.source_consume_power_efficiency_state", "source": "core/src/mindustry/world/consumers/ConsumePower.java", "method": "public float efficiency(Building build){", "power_status": power_status, "efficiency": efficiency, "return_expr": "return build.power.status;"}

func java_method_display_3(_args: Array = []) -> Variant:
	return null

func java_method_requestedPower_4(_args: Array = []) -> Variant:
	var buffered: bool = bool(_args[0] if _args.size() > 0 else false)
	var usage: float = float(_args[1] if _args.size() > 1 else 0.0)
	var capacity: float = float(_args[2] if _args.size() > 2 else 0.0)
	var power_status: float = float(_args[3] if _args.size() > 3 else 0.0)
	var should_consume: bool = bool(_args[4] if _args.size() > 4 else false)
	var requested_power: float = (1.0 - power_status) * capacity if buffered else usage * (1.0 if should_consume else 0.0)
	return {"source_owner": "PortGame.source_consume_power_requested_power_state", "source": "core/src/mindustry/world/consumers/ConsumePower.java", "method": "public float requestedPower(Building entity){", "buffered": buffered, "usage": usage, "capacity": capacity, "power_status": power_status, "should_consume": should_consume, "requested_power": requested_power, "buffered_expr": "(1f - entity.power.status) * capacity", "unbuffered_expr": "usage * (entity.shouldConsume() ? 1f : 0f)"}
