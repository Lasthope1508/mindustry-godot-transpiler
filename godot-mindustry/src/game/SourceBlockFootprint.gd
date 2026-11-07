extends RefCounted
class_name SourceBlockFootprint

const source_block_footprint_source_text_state := preload("res://src/game/SourceBlockFootprintSourceTextState.gd")

const SOURCE_BLOCK_SIZE_OFFSET_EXPR := source_block_footprint_source_text_state.SOURCE_BLOCK_SIZE_OFFSET_EXPR
const SOURCE_BLOCK_ITERATE_TAKEN_OFFSET_EXPR := source_block_footprint_source_text_state.SOURCE_BLOCK_ITERATE_TAKEN_OFFSET_EXPR
const SOURCE_BLOCK_ITERATE_TAKEN_LOOP_EXPR := source_block_footprint_source_text_state.SOURCE_BLOCK_ITERATE_TAKEN_LOOP_EXPR

static func occupied_cell_count(block_size: int) -> int:
	return max(block_size, 0) * max(block_size, 0)

static func footprint_offset(block_size: int) -> int:
	var safe_block_size: int = max(block_size, 0)
	return -floori(float(safe_block_size - 1) / 2.0)

static func occupied_cells(cell: Vector2i, block_size: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var safe_block_size: int = max(block_size, 0)
	if safe_block_size <= 0:
		return cells
	var offset := footprint_offset(safe_block_size)
	for y in range(safe_block_size):
		for x in range(safe_block_size):
			cells.append(cell + Vector2i(x + offset, y + offset))
	return cells
