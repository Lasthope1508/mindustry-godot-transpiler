# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeItemRadioactive.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeItemRadioactive"
const JAVA_EXTENDS := "ConsumeItemEfficiency"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "minRadioactivity", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeItemRadioactive", "parameters": [{"name": "minRadioactivity", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeItemRadioactive", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "itemEfficiencyMultiplier", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const SOURCE_CONSUME_ITEM_RADIOACTIVE_MIN_RADIOACTIVITY_DEFAULT := source_consumer_defaults.CONSUME_ITEM_RADIOACTIVE_MIN_RADIOACTIVITY_DEFAULT

func java_method_itemEfficiencyMultiplier_0(_args: Array = []) -> Variant:
	var item_radioactivity: float = float(_args[0] if _args.size() > 0 else 0.0)
	var efficiency_multiplier: float = item_radioactivity
	return {"source_owner": "port_game.source_consume_item_radioactive_item_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeItemRadioactive.java", "method": "public float itemEfficiencyMultiplier(Item item){", "item_radioactivity_field": "public float radioactivity;", "item_radioactivity": item_radioactivity, "efficiency_multiplier": efficiency_multiplier, "return_expr": "return item.radioactivity;"}

func java_constructor_ConsumeItemRadioactive_0(_args: Array = []) -> Variant:
	var min_radioactivity: float = float(_args[0] if _args.size() > 0 else 0.0)
	var min_radioactivity_after: float = min_radioactivity
	var filter_expr: String = "item -> item.radioactivity >= this.minRadioactivity"
	return {"source_owner": "port_game.source_consume_item_radioactive_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemRadioactive.java", "constructor": "public ConsumeItemRadioactive(float minRadioactivity){", "min_radioactivity_field": "public float minRadioactivity;", "assignment_expr": "this.minRadioactivity = minRadioactivity;", "filter_assignment_expr": "filter = item -> item.radioactivity >= this.minRadioactivity;", "filter_expr": filter_expr, "item_radioactivity_field": "public float radioactivity;", "min_radioactivity": min_radioactivity, "min_radioactivity_after": min_radioactivity_after}

func java_constructor_ConsumeItemRadioactive_1(_args: Array = []) -> Variant:
	var min_radioactivity: float = SOURCE_CONSUME_ITEM_RADIOACTIVE_MIN_RADIOACTIVITY_DEFAULT
	var min_radioactivity_after: float = min_radioactivity
	var filter_expr: String = "item -> item.radioactivity >= this.minRadioactivity"
	return {"source_owner": "port_game.source_consume_item_radioactive_default_constructor_state", "source": "core/src/mindustry/world/consumers/ConsumeItemRadioactive.java", "constructor": "public ConsumeItemRadioactive(){", "default_call_expr": "this(0.2f);", "typed_constructor_expr": "public ConsumeItemRadioactive(float minRadioactivity){", "assignment_expr": "this.minRadioactivity = minRadioactivity;", "filter_assignment_expr": "filter = item -> item.radioactivity >= this.minRadioactivity;", "filter_expr": filter_expr, "default_min_radioactivity": SOURCE_CONSUME_ITEM_RADIOACTIVE_MIN_RADIOACTIVITY_DEFAULT, "min_radioactivity_after": min_radioactivity_after}
