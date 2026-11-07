extends "res://src/game/SourcePortGameFacadePortBridge.gd"
class_name PortGame

func source_place_schematic_state(schematic: Dictionary, x: int, y: int, team_id: int, overwrite: bool, valid_place_hook: Variant, tile_config_callback: Variant) -> Dictionary:
	return SourceSchematicPlacementState.source_apply_schematic_place_state(self, schematic, x, y, team_id, overwrite, valid_place_hook, tile_config_callback)


func source_place_loadout_state(schematic: Dictionary, x: int, y: int, team_id: int, check: bool, priority_hook: Variant, tile_config_callback: Variant, register_core_hook: Variant) -> Dictionary:
	return SourceSchematicPlacementState.source_apply_loadout_place_state(self, schematic, x, y, team_id, check, priority_hook, tile_config_callback, register_core_hook)


func record_placed_block(sprite: Sprite2D, block, cell: Vector2i, team_id: int = 1) -> void:
	super.record_placed_block(sprite, block, cell, team_id)
	if block != null and block.properties.has("consumeLiquid"):
		SourceConsumeLiquidState.source_bind_liquid_consumers_state(block, content_catalog)
		SourceConsumeLiquidState.source_apply_liquid_consumers_state(block, content_catalog)
	# Resolved consumer apply overrides constructor capability without changing source properties.
	if block != null and (block.properties.has("hasLiquids") or block.has_meta(SourceConsumeLiquidState.SOURCE_BLOCK_LIQUID_APPLY_META_KEY)):
		source_placed_block_state.source_initialize_building_liquids_state(sprite, source_placed_block_state.source_block_has_liquids_state(block)["has_liquids"], content_catalog)
