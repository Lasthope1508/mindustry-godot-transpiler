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
