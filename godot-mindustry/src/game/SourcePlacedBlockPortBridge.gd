extends "res://src/game/SourceBlockMetadataGeometryPortBridge.gd"

const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_placed_block_port_bridge_block_placement := preload("res://src/game/SourceBlockPlacement.gd")

func record_placed_block(sprite: Sprite2D, block, cell: Vector2i) -> void:
	var occupied: Array[Vector2i] = []
	for occupied_cell in call("occupied_cells", cell, block):
		occupied.append(occupied_cell)
	var placed_block_origins: Dictionary = get("placed_block_origins")
	var placed_blocks: Dictionary = get("placed_blocks")
	var cell_keys: Array[String] = source_placed_block_port_bridge_block_placement.record_cells(placed_block_origins, placed_blocks, cell, occupied, sprite)
	set("placed_block_origins", placed_block_origins)
	set("placed_blocks", placed_blocks)
	source_placed_block_state.game_initialize_sprite(self, sprite, block, cell, cell_keys)
	var world_tiles: Dictionary = get("source_world_tiles")
	if not world_tiles.is_empty():
		SourceWorldTerrainRuntimeState.source_record_world_block(world_tiles, block, cell.x, cell.y, float(get("tile_size")))

		SourceDrillConsumptionRuntimeState.source_on_proximity_update_state(self, sprite, block)

func block_sprite_at_cell(cell: Vector2i):
	var placed_blocks: Dictionary = get("placed_blocks")
	return placed_blocks.get(call("cell_key", cell))

func source_block_health_at_cell(x: int, y: int) -> float:
	return source_placed_block_state.game_health_at_cell(self, x, y)

func source_block_time_scale_at_cell(x: int, y: int) -> float:
	return source_placed_block_state.game_time_scale_at_cell(self, x, y)

func source_block_time_scale_duration_at_cell(x: int, y: int) -> float:
	return source_placed_block_state.game_time_scale_duration_at_cell(self, x, y)

func decay_block_time_scale_sprite(sprite, source_delta: float) -> void:
	source_placed_block_state.game_decay_time_scale_sprite(self, sprite, source_delta)

func step_block_time_scales(seconds: float) -> Dictionary:
	return source_placed_block_state.game_step_time_scales(self, seconds)

func damage_block_at_cell(x: int, y: int, amount: float) -> float:
	return source_placed_block_state.game_damage_at_cell(self, x, y, amount)

func repair_block_sprite(sprite, amount: float) -> float:
	return source_placed_block_state.repair_sprite(sprite, amount)
