extends "res://src/game/SourcePortGameFacadePortBridge.gd"
class_name PortGame

func record_placed_block(sprite: Sprite2D, block, cell: Vector2i) -> void:
	super.record_placed_block(sprite, block, cell)
	if block != null and block.properties.has("consumeLiquid"):
		SourceConsumeLiquidState.source_bind_liquid_consumers_state(block, content_catalog)
		SourceConsumeLiquidState.source_apply_liquid_consumers_state(block, content_catalog)
	# Resolved consumer apply overrides constructor capability without changing source properties.
	if block != null and (block.properties.has("hasLiquids") or block.has_meta(SourceConsumeLiquidState.SOURCE_BLOCK_LIQUID_APPLY_META_KEY)):
		source_placed_block_state.source_initialize_building_liquids_state(sprite, source_placed_block_state.source_block_has_liquids_state(block)["has_liquids"], content_catalog)
