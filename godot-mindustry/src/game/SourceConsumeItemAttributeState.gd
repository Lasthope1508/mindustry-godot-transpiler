extends RefCounted
class_name SourceConsumeItemAttributeState

const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func flammable_item_efficiency_multiplier_state(item_flammability: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FLAMMABLE_ITEM_EFFICIENCY_MULTIPLIER_STATE, "source": "core/src/mindustry/world/consumers/ConsumeItemFlammable.java", "method": "public float itemEfficiencyMultiplier(Item item){", "return_expr": "return item.flammability;", "item_flammability_field": "public float flammability = 0f;", "item_flammability": item_flammability, "efficiency_multiplier": item_flammability}

static func generated_flammable_item_efficiency_multiplier_bridge_state(item_flammability: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemFlammable.gd")
	var instance = script.new()
	var result = instance.java_method_itemEfficiencyMultiplier_0([item_flammability])
	var canonical = flammable_item_efficiency_multiplier_state(item_flammability)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_ATTRIBUTE_STATE_FLAMMABLE_ITEM_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": "consume_item_flammable.itemEfficiencyMultiplier", "result": result, "canonical": canonical, "matches": result.get("efficiency_multiplier", null) == canonical.get("efficiency_multiplier", null)}

static func flammable_constructor_state(min_flammability: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FLAMMABLE_CONSTRUCTOR_STATE, "source": "core/src/mindustry/world/consumers/ConsumeItemFlammable.java", "constructor": "public ConsumeItemFlammable(float minFlammability){", "min_flammability_field": "public float minFlammability;", "assignment_expr": "this.minFlammability = minFlammability;", "filter_expr": "item -> item.flammability >= this.minFlammability", "item_flammability_field": "public float flammability = 0f;", "min_flammability_after": min_flammability}

static func generated_flammable_constructor_bridge_state(min_flammability: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemFlammable.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeItemFlammable_0([min_flammability])
	var canonical = flammable_constructor_state(min_flammability)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_ATTRIBUTE_STATE_FLAMMABLE_CONSTRUCTOR_STATE, "generated_owner": "consume_item_flammable.constructor", "result": result, "canonical": canonical, "matches": result.get("min_flammability_after", null) == canonical.get("min_flammability_after", null)}

static func flammable_default_constructor_state(default_min_flammability: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_FLAMMABLE_DEFAULT_CONSTRUCTOR_STATE, "source": "core/src/mindustry/world/consumers/ConsumeItemFlammable.java", "constructor": "public ConsumeItemFlammable(){", "default_call_expr": "this(0.2f);", "default_min_flammability": default_min_flammability, "min_flammability_after": default_min_flammability}

static func generated_flammable_default_constructor_bridge_state(default_min_flammability: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemFlammable.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeItemFlammable_1([])
	var canonical = flammable_default_constructor_state(default_min_flammability)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_ATTRIBUTE_STATE_FLAMMABLE_DEFAULT_CONSTRUCTOR_STATE, "generated_owner": "consume_item_flammable.default_constructor", "result": result, "canonical": canonical, "matches": result.get("min_flammability_after", null) == canonical.get("min_flammability_after", null)}
static func explosive_item_efficiency_multiplier_state(item_explosiveness: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EXPLOSIVE_ITEM_EFFICIENCY_MULTIPLIER_STATE, "source": "core/src/mindustry/world/consumers/ConsumeItemExplosive.java", "method": "public float itemEfficiencyMultiplier(Item item){", "return_expr": "return item.explosiveness;", "item_explosiveness_field": "public float explosiveness = 0f;", "item_explosiveness": item_explosiveness, "efficiency_multiplier": item_explosiveness}

static func generated_explosive_item_efficiency_multiplier_bridge_state(item_explosiveness: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemExplosive.gd")
	var instance = script.new()
	var result = instance.java_method_itemEfficiencyMultiplier_0([item_explosiveness])
	var canonical = explosive_item_efficiency_multiplier_state(item_explosiveness)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_ATTRIBUTE_STATE_EXPLOSIVE_ITEM_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": "consume_item_explosive.itemEfficiencyMultiplier", "result": result, "canonical": canonical, "matches": result.get("efficiency_multiplier", null) == canonical.get("efficiency_multiplier", null)}
static func explosive_constructor_state(min_charge: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EXPLOSIVE_CONSTRUCTOR_STATE, "source": "core/src/mindustry/world/consumers/ConsumeItemExplosive.java", "constructor": "public ConsumeItemExplosive(float minCharge){", "min_explosiveness_field": "public float minExplosiveness;", "assignment_expr": "this.minExplosiveness = minCharge;", "filter_expr": "item -> item.explosiveness >= this.minExplosiveness", "item_explosiveness_field": "public float explosiveness = 0f;", "min_explosiveness_after": min_charge}

static func generated_explosive_constructor_bridge_state(min_charge: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemExplosive.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeItemExplosive_0([min_charge])
	var canonical = explosive_constructor_state(min_charge)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_ATTRIBUTE_STATE_EXPLOSIVE_CONSTRUCTOR_STATE, "generated_owner": "consume_item_explosive.constructor", "result": result, "canonical": canonical, "matches": result.get("min_explosiveness_after", null) == canonical.get("min_explosiveness_after", null)}

static func explosive_default_constructor_state(default_min_charge: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EXPLOSIVE_DEFAULT_CONSTRUCTOR_STATE, "source": "core/src/mindustry/world/consumers/ConsumeItemExplosive.java", "constructor": "public ConsumeItemExplosive(){", "default_call_expr": "this(0.2f);", "typed_constructor_expr": "public ConsumeItemExplosive(float minCharge){", "default_min_charge": default_min_charge, "min_explosiveness_after": default_min_charge}

static func generated_explosive_default_constructor_bridge_state(default_min_charge: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemExplosive.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeItemExplosive_1([])
	var canonical = explosive_default_constructor_state(default_min_charge)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_ATTRIBUTE_STATE_EXPLOSIVE_DEFAULT_CONSTRUCTOR_STATE, "generated_owner": "consume_item_explosive.default_constructor", "result": result, "canonical": canonical, "matches": result.get("min_explosiveness_after", null) == canonical.get("min_explosiveness_after", null)}
static func radioactive_item_efficiency_multiplier_state(item_radioactivity: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_RADIOACTIVE_ITEM_EFFICIENCY_MULTIPLIER_STATE, "source": "core/src/mindustry/world/consumers/ConsumeItemRadioactive.java", "method": "public float itemEfficiencyMultiplier(Item item){", "return_expr": "return item.radioactivity;", "item_radioactivity_field": "public float radioactivity;", "item_radioactivity": item_radioactivity, "efficiency_multiplier": item_radioactivity}

static func generated_radioactive_item_efficiency_multiplier_bridge_state(item_radioactivity: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemRadioactive.gd")
	var instance = script.new()
	var result = instance.java_method_itemEfficiencyMultiplier_0([item_radioactivity])
	var canonical = radioactive_item_efficiency_multiplier_state(item_radioactivity)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_ATTRIBUTE_STATE_RADIOACTIVE_ITEM_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": "consume_item_radioactive.itemEfficiencyMultiplier", "result": result, "canonical": canonical, "matches": result.get("efficiency_multiplier", null) == canonical.get("efficiency_multiplier", null)}

static func radioactive_constructor_state(min_radioactivity: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_RADIOACTIVE_CONSTRUCTOR_STATE, "source": "core/src/mindustry/world/consumers/ConsumeItemRadioactive.java", "constructor": "public ConsumeItemRadioactive(float minRadioactivity){", "min_radioactivity_field": "public float minRadioactivity;", "assignment_expr": "this.minRadioactivity = minRadioactivity;", "filter_expr": "item -> item.radioactivity >= this.minRadioactivity", "item_radioactivity_field": "public float radioactivity;", "min_radioactivity_after": min_radioactivity}

static func generated_radioactive_constructor_bridge_state(min_radioactivity: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemRadioactive.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeItemRadioactive_0([min_radioactivity])
	var canonical = radioactive_constructor_state(min_radioactivity)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_ATTRIBUTE_STATE_RADIOACTIVE_CONSTRUCTOR_STATE, "generated_owner": "consume_item_radioactive.constructor", "result": result, "canonical": canonical, "matches": result.get("min_radioactivity_after", null) == canonical.get("min_radioactivity_after", null)}

static func radioactive_default_constructor_state(default_min_radioactivity: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_RADIOACTIVE_DEFAULT_CONSTRUCTOR_STATE, "source": "core/src/mindustry/world/consumers/ConsumeItemRadioactive.java", "constructor": "public ConsumeItemRadioactive(){", "default_call_expr": "this(0.2f);", "typed_constructor_expr": "public ConsumeItemRadioactive(float minRadioactivity){", "default_min_radioactivity": default_min_radioactivity, "min_radioactivity_after": default_min_radioactivity}

static func generated_radioactive_default_constructor_bridge_state(default_min_radioactivity: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemRadioactive.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeItemRadioactive_1([])
	var canonical = radioactive_default_constructor_state(default_min_radioactivity)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_ATTRIBUTE_STATE_RADIOACTIVE_DEFAULT_CONSTRUCTOR_STATE, "generated_owner": "consume_item_radioactive.default_constructor", "result": result, "canonical": canonical, "matches": result.get("min_radioactivity_after", null) == canonical.get("min_radioactivity_after", null)}
static func charged_item_efficiency_multiplier_state(item_charge: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_CHARGED_ITEM_EFFICIENCY_MULTIPLIER_STATE, "source": "core/src/mindustry/world/consumers/ConsumeItemCharged.java", "method": "public float itemEfficiencyMultiplier(Item item){", "return_expr": "return item.charge;", "item_charge_field": "public float charge = 0f;", "item_charge": item_charge, "efficiency_multiplier": item_charge}

static func generated_charged_item_efficiency_multiplier_bridge_state(item_charge: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemCharged.gd")
	var instance = script.new()
	var result = instance.java_method_itemEfficiencyMultiplier_0([item_charge])
	var canonical = charged_item_efficiency_multiplier_state(item_charge)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_ATTRIBUTE_STATE_CHARGED_ITEM_EFFICIENCY_MULTIPLIER_STATE, "generated_owner": "consume_item_charged.itemEfficiencyMultiplier", "result": result, "canonical": canonical, "matches": result.get("efficiency_multiplier", null) == canonical.get("efficiency_multiplier", null)}
static func charged_constructor_state(min_charge: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_CHARGED_CONSTRUCTOR_STATE, "source": "core/src/mindustry/world/consumers/ConsumeItemCharged.java", "constructor": "public ConsumeItemCharged(float minCharge){", "min_charge_field": "public float minCharge;", "assignment_expr": "this.minCharge = minCharge;", "filter_expr": "item -> item.charge >= this.minCharge", "item_charge_field": "public float charge = 0f;", "min_charge_after": min_charge}

static func generated_charged_constructor_bridge_state(min_charge: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemCharged.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeItemCharged_0([min_charge])
	var canonical = charged_constructor_state(min_charge)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_ATTRIBUTE_STATE_CHARGED_CONSTRUCTOR_STATE, "generated_owner": "consume_item_charged.constructor", "result": result, "canonical": canonical, "matches": result.get("min_charge_after", null) == canonical.get("min_charge_after", null)}

static func charged_default_constructor_state(default_min_charge: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_CHARGED_DEFAULT_CONSTRUCTOR_STATE, "source": "core/src/mindustry/world/consumers/ConsumeItemCharged.java", "constructor": "public ConsumeItemCharged(){", "default_call_expr": "this(0.2f);", "typed_constructor_expr": "public ConsumeItemCharged(float minCharge){", "default_min_charge": default_min_charge, "min_charge_after": default_min_charge}

static func generated_charged_default_constructor_bridge_state(default_min_charge: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemCharged.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeItemCharged_1([])
	var canonical = charged_default_constructor_state(default_min_charge)
	return {"source_owner": source_runtime_owner_registry.SOURCE_CONSUME_ITEM_ATTRIBUTE_STATE_CHARGED_DEFAULT_CONSTRUCTOR_STATE, "generated_owner": "consume_item_charged.default_constructor", "result": result, "canonical": canonical, "matches": result.get("min_charge_after", null) == canonical.get("min_charge_after", null)}
