# Generated from Mindustry upstream.
# Source: mindustry/world/consumers/ConsumeItemExplosive.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.consumers"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsumeItemExplosive"
const JAVA_EXTENDS := "ConsumeItemEfficiency"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "minExplosiveness", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsumeItemExplosive", "parameters": [{"name": "minCharge", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "ConsumeItemExplosive", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "itemEfficiencyMultiplier", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_itemEfficiencyMultiplier_0(_args: Array = []) -> Variant:
	var item_explosiveness: float = float(_args[0] if _args.size() > 0 else 0.0)
	var efficiency_multiplier: float = item_explosiveness
	return {"source_owner": "PortGame.source_consume_item_explosive_item_efficiency_multiplier_state", "source": "core/src/mindustry/world/consumers/ConsumeItemExplosive.java", "method": "public float itemEfficiencyMultiplier(Item item){", "item_explosiveness": item_explosiveness, "efficiency_multiplier": efficiency_multiplier, "return_expr": "return item.explosiveness;"}
