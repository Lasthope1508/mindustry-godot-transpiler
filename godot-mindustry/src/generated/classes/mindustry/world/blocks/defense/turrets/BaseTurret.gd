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
	var coolant_present: bool = bool(_args[0] if _args.size() > 0 else false)
	var found_consume_coolant: bool = bool(_args[1] if _args.size() > 1 else false)
	var disable_overlap_check: bool = bool(_args[2] if _args.size() > 2 else false)
	var place_overlap_range: float = float(_args[3] if _args.size() > 3 else 0.0)
	var range_value: float = float(_args[4] if _args.size() > 4 else 80.0)
	var place_overlap_margin: float = float(_args[5] if _args.size() > 5 else 56.0)
	var source_tilesize: float = float(_args[6] if _args.size() > 6 else 8.0)
	var fog_radius_multiplier: float = float(_args[7] if _args.size() > 7 else 1.0)
	var fog_radius: int = int(_args[8] if _args.size() > 8 else 0)
	var find_consumer_called: bool = not coolant_present
	var coolant_present_after: bool = coolant_present or found_consume_coolant
	var place_overlap_range_after: float = place_overlap_range
	if not disable_overlap_check:
		place_overlap_range_after = max(place_overlap_range, range_value + place_overlap_margin)
	var computed_fog_radius: int = int(round(range_value / source_tilesize * fog_radius_multiplier))
	var fog_radius_after: int = max(computed_fog_radius, fog_radius)
	return {"source_owner": "PortGame.source_base_turret_init_state", "method": "public void init(){", "override_expr": "@Override", "coolant_null_guard_expr": "if(coolant == null){", "find_consumer_expr": "coolant = findConsumer(c -> c instanceof ConsumeCoolant);", "check_init_coolant_expr": "checkInitCoolant();", "overlap_guard_expr": "if(!disableOverlapCheck){", "place_overlap_range_expr": "placeOverlapRange = Math.max(placeOverlapRange, range + placeOverlapMargin);", "fog_radius_expr": "fogRadius = Math.max(Mathf.round(range / tilesize * fogRadiusMultiplier), fogRadius);", "super_init_expr": "super.init();", "coolant_present": coolant_present, "found_consume_coolant": found_consume_coolant, "find_consumer_called": find_consumer_called, "coolant_present_after": coolant_present_after, "check_init_coolant_called": true, "disable_overlap_check": disable_overlap_check, "place_overlap_range": place_overlap_range, "range": range_value, "place_overlap_margin": place_overlap_margin, "place_overlap_range_after": place_overlap_range_after, "tilesize": source_tilesize, "fog_radius_multiplier": fog_radius_multiplier, "fog_radius": fog_radius, "computed_fog_radius": computed_fog_radius, "fog_radius_after": fog_radius_after, "super_init_called": true}

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
