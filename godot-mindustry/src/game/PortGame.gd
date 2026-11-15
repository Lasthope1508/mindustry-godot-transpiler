extends "res://src/game/SourcePortGameFacadePortBridge.gd"
class_name PortGame

func source_place_schematic_state(schematic: Dictionary, x: int, y: int, team_id: int, overwrite: bool, valid_place_hook: Variant, tile_config_callback: Variant) -> Dictionary:
	return SourceSchematicPlacementState.source_apply_schematic_place_state(self, schematic, x, y, team_id, overwrite, valid_place_hook, tile_config_callback)


func source_place_loadout_state(schematic: Dictionary, x: int, y: int, team_id: int, check: bool, priority_hook: Variant, tile_config_callback: Variant, register_core_hook: Variant) -> Dictionary:
	return SourceSchematicPlacementState.source_apply_loadout_place_state(self, schematic, x, y, team_id, check, priority_hook, tile_config_callback, register_core_hook)


# Build.validPlace: validPlaceIgnoreUnits plus the unit-overlap check. With
# no unit system in the runtime, a null unit_overlap_hook means no overlap;
# a solid or solidifes block with a hook reporting an overlap is rejected.
func source_valid_place_state(block: Object, block_flags: Dictionary, floor_flags: Dictionary, team_id: int, x: int, y: int, rotation: int, check_visible: bool, check_core_radius: bool, rules_state: Dictionary, cores_state: Dictionary, can_place_on_hook: Variant, darkness_hook: Variant, fog_discovered_hook: Variant, enemy_overlap_hook: Variant, unit_overlap_hook: Variant) -> Dictionary:
	var ignore_units: Dictionary = SourceBlockGeometry.source_valid_place_ignore_units_state(self, block, block_flags, floor_flags, team_id, x, y, rotation, check_visible, check_core_radius, rules_state, cores_state, can_place_on_hook, darkness_hook, fog_discovered_hook, enemy_overlap_hook)
	if not bool(ignore_units.get("valid", false)):
		return ignore_units
	var flags: Dictionary = block_flags.get(block.id, {})
	if bool(flags.get("solid", false)) or bool(flags.get("solidifes", false)):
		if unit_overlap_hook is Callable and unit_overlap_hook.is_valid():
			if bool(unit_overlap_hook.call(block, x, y)):
				return {"valid": false, "reason": "unit_overlap", "cell": Vector2i(x, y)}
	return {"valid": true, "reason": "", "cell": null}


func record_placed_block(sprite: Sprite2D, block, cell: Vector2i, team_id: int = 1) -> void:
	super.record_placed_block(sprite, block, cell, team_id)
	if block != null and block.properties.has("consumeLiquid"):
		SourceConsumeLiquidState.source_bind_liquid_consumers_state(block, content_catalog)
		SourceConsumeLiquidState.source_apply_liquid_consumers_state(block, content_catalog)
	# Resolved consumer apply overrides constructor capability without changing source properties.
	if block != null and (block.properties.has("hasLiquids") or block.has_meta(SourceConsumeLiquidState.SOURCE_BLOCK_LIQUID_APPLY_META_KEY)):
		source_placed_block_state.source_initialize_building_liquids_state(sprite, source_placed_block_state.source_block_has_liquids_state(block)["has_liquids"], content_catalog)


# N2199 placement auto-link dispatch: runs ItemBridgeBuild.playerPlaced (ItemBridge.java:210-219) for a newly placed bridge. Called from place_selected_block_at_world only -- Java calls playerPlaced only when the builder is the local player unit (ConstructBlock.java:106-109, `if(!headless && builder == player.unit()){` / `tile.build.playerPlaced(config);`), so scenario/schematic placement (source_place_schematic_state / source_place_loadout_state above) never reaches this method. LiquidBridgeBuild inherits playerPlaced with no override (LiquidBridge.java:19, `public class LiquidBridgeBuild extends ItemBridgeBuild{`), so the liquid defs dispatch to the liquid twin driver, which reuses the item-bridge pures. The implementation check goes through the SourceSelectedBuildState predicates (the PortGame convention -- PortGame.gd never reads the implementation field off the block directly, test_port_game_uses_selected_build_implementation_predicates); BufferedItemBridge routes to the item driver (it extends ItemBridge, BufferedItemBridge.java:9). Any other implementation is a no-op. The method is named `..._dispatch_state`, NOT `..._player_placed_state`: the catalog validator derives each contract's result schema from the function name (`_contract_result_schema_name`), so a dispatch sharing the pure function's name would resolve both contracts to one result schema and fail the pure contract's `config_value` key (gate lesson, N2199 full gate run 1: 9 failures).
func source_item_bridge_player_placed_dispatch_state(sprite: Sprite2D, block, cell: Vector2i) -> Dictionary:
	if block == null:
		return {"applied": false, "configure_other": false, "other_cell": Vector2i.ZERO, "new_last_build_cell": cell}
	if SourceSelectedBuildState.is_item_bridge(block):
		return SourceItemBridgeBuildState.source_item_bridge_auto_link_placement_state(self, sprite, block, cell)
	if SourceSelectedBuildState.is_liquid_bridge(block):
		return SourceLiquidBridgeBuildState.source_liquid_bridge_auto_link_placement_state(self, sprite, block, cell)
	return {"applied": false, "configure_other": false, "other_cell": Vector2i.ZERO, "new_last_build_cell": cell}
