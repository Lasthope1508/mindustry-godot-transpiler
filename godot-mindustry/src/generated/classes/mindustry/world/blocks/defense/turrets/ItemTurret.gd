# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/ItemTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "ItemTurret"
const JAVA_EXTENDS := "Turret"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "ammoTypes", "type": "ObjectMap"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ItemTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "ammo", "parameters": [{"name": "objects", "type": "Object", "varargs": true}], "return_type": ""}, {"modifiers": ["public"], "name": "limitRange", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "limitRange", "parameters": [{"name": "margin", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_ammo_0(_args: Array = []) -> Variant:
	return null

func java_method_limitRange_1(_args: Array = []) -> Variant:
	var margin: float = 9.0
	var limit_range_call: Dictionary = {"call": "limitRange(9f);", "margin": margin}
	return {"source_owner": "PortGame.source_item_turret_limit_range_default_state", "method": "public void limitRange(){", "comment": "/** Limits bullet range to this turret's range value. */", "dispatch_expr": "limitRange(9f);", "margin": margin, "limit_range_called": true, "limit_range_call": limit_range_call}

func java_method_limitRange_2(_args: Array = []) -> Variant:
	var margin: float = float(_args[0] if _args.size() > 0 else 0.0)
	var ammo_entries: Array = _args[1] if _args.size() > 1 else []
	var limit_range_calls: Array = []
	for entry in ammo_entries:
		var entry_value: Variant = entry.get("value", null) if entry is Dictionary else entry
		limit_range_calls.append({"call": "limitRange(entry.value, margin);", "entry_value": entry_value, "margin": margin})
	return {"source_owner": "PortGame.source_item_turret_limit_range_entries_state", "method": "public void limitRange(float margin){", "comment": "/** Limits bullet range to this turret's range value. */", "loop_expr": "for(var entry : ammoTypes.entries()){", "dispatch_expr": "limitRange(entry.value, margin);", "margin": margin, "ammo_entries": ammo_entries, "limit_range_calls": limit_range_calls, "limit_range_call_count": limit_range_calls.size()}

func java_method_setStats_3(_args: Array = []) -> Variant:
	return null

func java_method_setBars_4(_args: Array = []) -> Variant:
	return null

func java_method_init_5(_args: Array = []) -> Variant:
	return null
