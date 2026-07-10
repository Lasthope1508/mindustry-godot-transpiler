# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/Consume.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "Consume"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "optional", "type": "boolean"}, {"modifiers": ["public"], "name": "booster", "type": "boolean"}, {"modifiers": ["public"], "name": "update", "type": "boolean"}, {"modifiers": ["public"], "name": "multiplier", "type": "Floatf"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "optional", "parameters": [{"name": "optional", "type": "boolean", "varargs": false}, {"name": "boost", "type": "boolean", "varargs": false}], "return_type": "Consume"}, {"modifiers": ["public"], "name": "boost", "parameters": [], "return_type": "Consume"}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "update", "type": "boolean", "varargs": false}], "return_type": "Consume"}, {"modifiers": ["public"], "name": "ignore", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "trigger", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "efficiency", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "efficiencyMultiplier", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "display", "parameters": [{"name": "stats", "type": "Stats", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_apply_0(_args: Array = []) -> Variant:
	return null

func java_method_optional_1(_args: Array = []) -> Variant:
	var optional_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var boost_value: bool = bool(_args[1] if _args.size() > 1 else false)
	var optional_after: bool = optional_value
	var booster_after: bool = boost_value
	var return_self: bool = true
	return {"source_owner": "PortGame.source_consume_optional_state", "source": "core/src/mindustry/world/consumers/Consume.java", "method": "public Consume optional(boolean optional, boolean boost){", "optional_field": "public boolean optional;", "booster_field": "public boolean booster;", "optional_assignment_expr": "this.optional = optional;", "booster_assignment_expr": "this.booster = boost;", "return_expr": "return this;", "optional_value": optional_value, "boost_value": boost_value, "optional_after": optional_after, "booster_after": booster_after, "return_self": return_self}

func java_method_boost_2(_args: Array = []) -> Variant:
	var optional_value: bool = true
	var boost_value: bool = true
	var optional_after: bool = optional_value
	var booster_after: bool = boost_value
	var return_self: bool = true
	return {"source_owner": "PortGame.source_consume_boost_state", "source": "core/src/mindustry/world/consumers/Consume.java", "method": "public Consume boost(){", "optional_call_expr": "return optional(true, true);", "optional_method_expr": "public Consume optional(boolean optional, boolean boost){", "optional_assignment_expr": "this.optional = optional;", "booster_assignment_expr": "this.booster = boost;", "return_expr": "return this;", "optional_value": optional_value, "boost_value": boost_value, "optional_after": optional_after, "booster_after": booster_after, "return_self": return_self}

func java_method_update_3(_args: Array = []) -> Variant:
	var update_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var update_after: bool = update_value
	var return_self: bool = true
	return {"source_owner": "PortGame.source_consume_update_flag_state", "source": "core/src/mindustry/world/consumers/Consume.java", "method": "public Consume update(boolean update){", "update_field": "public boolean update = true;", "update_assignment_expr": "this.update = update;", "return_expr": "return this;", "update_value": update_value, "update_after": update_after, "return_self": return_self}

func java_method_ignore_4(_args: Array = []) -> Variant:
	var ignored: bool = false
	return {"source_owner": "PortGame.source_consume_ignore_state", "source": "core/src/mindustry/world/consumers/Consume.java", "method": "public boolean ignore(){", "return_expr": "return false;", "ignored": ignored}

func java_method_build_5(_args: Array = []) -> Variant:
	var build_arg: Variant = _args[0] if _args.size() > 0 else null
	var table_arg: Variant = _args[1] if _args.size() > 1 else null
	var empty_body: bool = true
	return {"source_owner": "PortGame.source_consume_build_state", "source": "core/src/mindustry/world/consumers/Consume.java", "method": "public void build(Building build, Table table){}", "empty_body": empty_body, "build": build_arg, "table": table_arg}

func java_method_trigger_6(_args: Array = []) -> Variant:
	return null

func java_method_update_7(_args: Array = []) -> Variant:
	return null

func java_method_efficiency_8(_args: Array = []) -> Variant:
	var efficiency: float = 1.0
	return {"source_owner": "PortGame.source_consume_efficiency_state", "source": "core/src/mindustry/world/consumers/Consume.java", "method": "public float efficiency(Building build){", "return_expr": "return 1f;", "efficiency": efficiency}

func java_method_efficiencyMultiplier_9(_args: Array = []) -> Variant:
	var efficiency_multiplier: float = 1.0
	return {"source_owner": "PortGame.source_consume_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/Consume.java", "method": "public float efficiencyMultiplier(Building build){", "return_expr": "return 1f;", "efficiency_multiplier": efficiency_multiplier}

func java_method_display_10(_args: Array = []) -> Variant:
	return null
