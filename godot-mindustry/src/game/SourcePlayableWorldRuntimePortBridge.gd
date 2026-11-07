extends "res://src/game/SourcePlacedPowerRuntimePortBridge.gd"

const source_world_terrain_runtime_state_script := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const source_world_initial_build_runtime_state_script := preload("res://src/game/SourceWorldInitialBuildRuntimeState.gd")
const source_item_transport_runtime_state_script := preload("res://src/game/SourceItemTransportRuntimeState.gd")

var source_world_tiles: Dictionary = {}
var source_item_catalog: Dictionary = {}

func source_world_tile(x: int, y: int) -> Variant:
	return source_world_terrain_runtime_state_script.source_world_tile(source_world_tiles, x, y)

func source_world_linked_ore_tiles_state(block: Object, x: int, y: int, item_catalog: Dictionary) -> Dictionary:
	var self_tile: Variant = source_world_tile(x, y)
	if self_tile == null:
		return {"ore_tiles": []}
	var geometry: Dictionary = source_world_terrain_runtime_state_script.source_block_geometry_state(block, float(get("tile_size")))
	var air: Object = source_world_terrain_runtime_state_script.source_world_block_by_field(get("content_catalog"), source_world_terrain_runtime_state_script.SOURCE_WORLD_AIR_FIELD)
	return source_world_terrain_runtime_state_script.source_linked_ore_tiles_state(geometry["is_multiblock"], geometry["size"], geometry["size_offset"], x, y, Callable(self, "source_world_tile"), self_tile, item_catalog, air)

func build_world() -> void:
	source_world_initial_build_runtime_state_script.build_world(self)

func source_world_terrain_runtime_state() -> Dictionary:
	return source_world_terrain_runtime_state_script.game_terrain_plan_state(self)

func source_world_initial_build_runtime_state() -> Dictionary:
	return source_world_initial_build_runtime_state_script.game_initial_build_plan_state(self)

func source_item_transport_bootstrap_state() -> Dictionary:
	return source_item_transport_runtime_state_script.game_bootstrap_state(self)

func source_item_transport_runtime_state(progress_before: float, progress_delta: float) -> Dictionary:
	return source_item_transport_runtime_state_script.game_transport_positions_state(self, progress_before, progress_delta)
