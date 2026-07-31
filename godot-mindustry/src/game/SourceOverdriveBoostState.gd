extends RefCounted
class_name SourceOverdriveBoostState

const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")

static func boost_input(sprite, target_block, default_time_scale: float, default_can_overdrive: bool) -> Dictionary:
	var cell: Vector2i = Vector2i.ZERO
	if is_instance_valid(sprite):
		cell = sprite.get_meta("origin_cell", Vector2i.ZERO)
	return {
		"block_id": str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, "")) if is_instance_valid(sprite) else "",
		"cell": cell,
		"time_scale": source_placed_block_state.time_scale(sprite, default_time_scale),
		"time_scale_duration": source_placed_block_state.time_scale_duration(sprite),
		"can_overdrive": source_block_metadata_state.block_can_overdrive(target_block, default_can_overdrive),
	}

static func apply_boost_result(sprite, boost_state: Dictionary, default_time_scale: float) -> Dictionary:
	if is_instance_valid(sprite):
		sprite.set_meta(source_placed_block_state.SOURCE_BLOCK_TIME_SCALE_META_KEY, float(boost_state.get("time_scale", default_time_scale)))
		sprite.set_meta(source_placed_block_state.SOURCE_BLOCK_TIME_SCALE_DURATION_META_KEY, float(boost_state.get("time_scale_duration", 0.0)))
	var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO) if is_instance_valid(sprite) else Vector2i.ZERO
	return {
		"block_id": str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, "")) if is_instance_valid(sprite) else "",
		"cell": cell,
		"time_scale": source_placed_block_state.time_scale(sprite, default_time_scale),
		"time_scale_duration": source_placed_block_state.time_scale_duration(sprite),
	}
