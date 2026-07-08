# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeItemFlammable.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeItemFlammable"
const JAVA_EXTENDS := "ConsumeItemEfficiency"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "minFlammability", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeItemFlammable", "parameters": [{"name": "minFlammability", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeItemFlammable", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "itemEfficiencyMultiplier", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_itemEfficiencyMultiplier_0(_args: Array = []) -> Variant:
	var item_flammability: float = float(_args[0] if _args.size() > 0 else 0.0)
	var efficiency_multiplier: float = item_flammability
	return {"source_owner": "PortGame.source_consume_item_flammable_item_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeItemFlammable.java", "method": "public float itemEfficiencyMultiplier(Item item){", "item_flammability": item_flammability, "efficiency_multiplier": efficiency_multiplier, "return_expr": "return item.flammability;"}
