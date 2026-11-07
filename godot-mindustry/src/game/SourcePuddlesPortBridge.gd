extends RefCounted
class_name SourcePuddlesPortBridge

const source_puddles_deposit_state := preload("res://src/game/SourcePuddlesDepositState.gd")

static func deposit_tile_liquid_state(tile: Variant, liquid: Variant, amount: float, existing_puddle: Variant = null, floor_solid: bool = false, net_client: bool = false, max_liquid: float = source_puddles_deposit_state.MAX_LIQUID_DEFAULT, context: Dictionary = {}) -> Dictionary:
	return source_puddles_deposit_state.deposit_tile_liquid_state(tile, liquid, amount, existing_puddle, floor_solid, net_client, max_liquid, context)
