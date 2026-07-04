# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/BaseTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "BaseTurret"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "range", "type": "float"}, {"modifiers": ["public"], "name": "placeOverlapMargin", "type": "float"}, {"modifiers": ["public"], "name": "rotateSpeed", "type": "float"}, {"modifiers": ["public"], "name": "fogRadiusMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "disableOverlapCheck", "type": "boolean"}, {"modifiers": ["public"], "name": "activationTime", "type": "float"}, {"modifiers": ["public"], "name": "coolEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "coolantMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "coolant", "type": "ConsumeLiquidBase"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BaseTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "reinitializeConsumers", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "checkInitCoolant", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_init_0(_args: Array = []) -> Variant:
	return null

func java_method_reinitializeConsumers_1(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_base_turret_reinitialize_consumers_state", "method": "public void reinitializeConsumers(){", "override_expr": "@Override", "check_init_coolant_expr": "checkInitCoolant();", "super_reinitialize_consumers_expr": "super.reinitializeConsumers();", "check_init_coolant_called": true, "super_reinitialize_consumers_called": true}

func java_method_checkInitCoolant_2(_args: Array = []) -> Variant:
	var coolant_present: bool = bool(_args[0] if _args.size() > 0 else false)
	var has_consumer: bool = bool(_args[1] if _args.size() > 1 else false)
	var update_after: Variant = null
	var booster_after: Variant = null
	var optional_after: Variant = null
	if coolant_present:
		update_after = false
		booster_after = true
		optional_after = true
	var consume_called: bool = coolant_present and not has_consumer
	return {"source_owner": "PortGame.source_base_turret_check_init_coolant_state", "method": "void checkInitCoolant(){", "coolant_guard_expr": "if(coolant != null){", "update_assign_expr": "coolant.update = false;", "booster_assign_expr": "coolant.booster = true;", "optional_assign_expr": "coolant.optional = true;", "json_comment": "//json parsing does not add to consumes", "consume_guard_expr": "if(!hasConsumer(coolant)) consume(coolant);", "coolant_present": coolant_present, "has_consumer": has_consumer, "update_after": update_after, "booster_after": booster_after, "optional_after": optional_after, "consume_called": consume_called}

func java_method_drawPlace_3(_args: Array = []) -> Variant:
	return null

func java_method_setStats_4(_args: Array = []) -> Variant:
	return null

func java_method_setBars_5(_args: Array = []) -> Variant:
	return null
