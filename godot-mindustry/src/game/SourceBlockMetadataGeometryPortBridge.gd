extends "res://src/game/SourceBlockInitPortBridge.gd"

const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")

func block_size(block) -> int:
	return source_block_metadata_state.block_size(block)

func source_block_health(block_id: String) -> float:
	return source_block_metadata_state.block_health(block_id, get("content_catalog"))

func source_block_item_capacity(block_id: String) -> int:
	return source_block_metadata_state.block_item_capacity(block_id, get("content_catalog"))

func source_block_dump_time(block_id: String) -> float:
	return source_block_metadata_state.block_dump_time(block_id, get("content_catalog"))

func block_world_size(block) -> float:
	return source_block_geometry.block_world_size(block_size(block), int(get("tile_size")))

func source_block_sprite_base_position(block, cell: Vector2i) -> Vector2:
	return source_block_geometry.block_base_position(call("grid_to_world", cell), block_size(block), int(get("tile_size")))

func generated_building_comp_hit_size_bridge_state(block_size_value: int, source_tilesize: float) -> Dictionary:
	return source_block_geometry.generated_building_hit_size_bridge_state(block_size_value, source_tilesize)

func source_building_hit_size(block_size_value: int, source_tilesize: float) -> float:
	return source_block_geometry.building_hit_size(block_size_value, source_tilesize)

func source_building_hitbox_state(world_x: float, world_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return source_block_geometry.building_hitbox_state(world_x, world_y, block_size_value, source_tilesize)

func generated_building_comp_hitbox_bridge_state(world_x: float, world_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return source_block_geometry.generated_building_hitbox_bridge_state(world_x, world_y, block_size_value, source_tilesize)

func source_block_get_content_type_state() -> Dictionary:
	return source_block_metadata_state.content_type_state()

func generated_block_get_content_type_bridge_state() -> Dictionary:
	return source_block_metadata_state.generated_content_type_bridge_state()

func source_block_logic_visible_state(build_visibility_value: String) -> Dictionary:
	return source_block_metadata_state.logic_visible_state(build_visibility_value)

func generated_block_logic_visible_bridge_state(build_visibility_value: String) -> Dictionary:
	return source_block_metadata_state.generated_logic_visible_bridge_state(build_visibility_value)
