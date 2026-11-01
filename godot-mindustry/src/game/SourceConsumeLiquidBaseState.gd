extends RefCounted
class_name SourceConsumeLiquidBaseState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func constructor_state(amount: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_BASE_CONSTRUCTOR_STATE, "amount": amount, "amount_after": amount}

static func apply_state(block_has_liquids_before: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE, "block_has_liquids_before": block_has_liquids_before, "block_has_liquids_after": source_apply_capability_state()["block_has_liquids_after"]}

static func source_apply_capability_state() -> Dictionary:
	return {"block_has_liquids_after": true}

static func abstract_consumes_state(liquid: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_BASE_ABSTRACT_CONSUMES_STATE, "abstract_method": true, "liquid": liquid}

static func generated_constructor_bridge_state(amount: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidBase.gd")
	var instance = script.new()
	var result = instance.java_constructor_ConsumeLiquidBase_0([amount])
	var canonical = constructor_state(amount)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_BASE_CONSTRUCTOR_STATE, "generated_owner": "consume_liquid_base.constructor", "result": result, "canonical": canonical, "matches": result.get("amount_after", null) == canonical.get("amount_after", null)}

static func generated_apply_bridge_state(block_has_liquids_before: bool) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidBase.gd")
	var instance = script.new()
	var result = instance.java_method_apply_0([block_has_liquids_before])
	var canonical = apply_state(block_has_liquids_before)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE, "generated_owner": "consume_liquid_base.apply", "result": result, "canonical": canonical, "matches": result.get("block_has_liquids_after", null) == canonical.get("block_has_liquids_after", null)}

static func generated_abstract_consumes_bridge_state(liquid: Variant) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeLiquidBase.gd")
	var instance = script.new()
	var result = instance.java_method_consumes_1([liquid])
	var canonical = abstract_consumes_state(liquid)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_LIQUID_BASE_ABSTRACT_CONSUMES_STATE, "generated_owner": "consume_liquid_base.consumes", "result": result, "canonical": canonical, "matches": result.get("abstract_method", null) == canonical.get("abstract_method", null) and result.get("liquid", null) == canonical.get("liquid", null)}
