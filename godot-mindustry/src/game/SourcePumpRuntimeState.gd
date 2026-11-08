extends RefCounted
class_name SourcePumpRuntimeState

const source_world_terrain_runtime_state := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")

const SOURCE_PUMP_BUILDING_META_KEY := "source_pump_building"

# Blocks.java:2298-2302: mechanicalPump = new Pump("mechanical-pump")
# with pumpAmount = 7f / 60f and liquidCapacity = 20f.
# Pump.java:23: warmupSpeed = 0.019f.
const PUMP_AMOUNT := 7.0 / 60.0
const PUMP_WARMUP_SPEED := 0.019
const PUMP_LIQUID_CAPACITY := 20.0


static func source_pump_proximity_state(game: Object, cell: Vector2i) -> Dictionary:
	# Pump.java:141-152 PumpBuild.onProximityUpdate: scan the linked
	# tiles; for each tile whose floor has a liquidDrop (canPump:
	# tile != null && tile.floor().liquidDrop != null, Pump.java:
	# 106-108) set liquidDrop and add the floor's liquidMultiplier
	# to amount. The result is stored on the pump sprite's meta
	# frame (like the drill frame), so the live-loop update
	# (updateTile) can use it.
	var sprite: Variant = game.call("block_sprite_at_cell", cell)
	if sprite == null:
		return {"liquid_drop": null, "amount": 0.0, "stored": false}
	var block: Variant = source_texture_runtime_state.block_from_sprite(game, sprite)
	if block == null:
		return {"liquid_drop": null, "amount": 0.0, "stored": false}
	var liquid_drop: Variant = null
	var amount := 0.0
	for linked_cell in game.call("occupied_cells", cell, block):
		var tile: Variant = game.call("source_world_tile", linked_cell.x, linked_cell.y)
		if tile == null:
			continue
		var floor_drop: Dictionary = source_world_terrain_runtime_state.source_floor_liquid_drop_state(str(tile.get("floor").id))
		if bool(floor_drop.get("is_liquid", false)):
			liquid_drop = floor_drop.get("liquid_drop")
			amount += float(floor_drop.get("liquid_multiplier", 0.0))
	sprite.set_meta(SOURCE_PUMP_BUILDING_META_KEY, {"liquid_drop": liquid_drop, "amount": amount})
	return {"liquid_drop": liquid_drop, "amount": amount, "stored": true}


static func source_pump_update_state(game: Object, cell: Vector2i, delta: float) -> Dictionary:
	# Pump.java:160-176 PumpBuild.updateTile (production part): each
	# frame it pumps maxPump = min(liquidCapacity - liquids.get(liquidDrop),
	# amount * pumpAmount * edelta()) into its liquids, warms up toward 1
	# when it pumped, and advances totalProgress. The dumpLiquid step
	# (Pump.java:180-182) is a later slice. The pump is enabled and
	# consumes no power, so efficiency is 1.0 and edelta() is delta.
	# The warmup/totalProgress live on the pump building frame (like
	# liquidDrop/amount), so they persist across frames.
	var sprite: Variant = game.call("block_sprite_at_cell", cell)
	if sprite == null:
		return {"liquid_drop": null, "amount_pumped": 0.0, "warmup": 0.0, "total_progress": 0.0, "liquid_amount": 0.0}
	var frame: Dictionary = sprite.get_meta(SOURCE_PUMP_BUILDING_META_KEY, {})
	if frame.is_empty():
		source_pump_proximity_state(game, cell)
		frame = sprite.get_meta(SOURCE_PUMP_BUILDING_META_KEY, {})
	var liquid_drop: Variant = frame.get("liquid_drop", null)
	var warmup: float = float(frame.get("warmup", 0.0))
	var total_progress: float = float(frame.get("total_progress", 0.0))
	if liquid_drop == null:
		return {"liquid_drop": null, "amount_pumped": 0.0, "warmup": warmup, "total_progress": total_progress, "liquid_amount": 0.0}
	var liquids: Variant = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, null)
	if liquids == null:
		return {"liquid_drop": liquid_drop, "amount_pumped": 0.0, "warmup": warmup, "total_progress": total_progress, "liquid_amount": 0.0}
	var catalog: Dictionary = source_content_registry_runtime_state.source_liquid_catalog_state(game.get("content_catalog"))
	var water_id: int = int(catalog["liquid_id_by_name"].get(str(liquid_drop), -1))
	if water_id < 0:
		return {"liquid_drop": liquid_drop, "amount_pumped": 0.0, "warmup": warmup, "total_progress": total_progress, "liquid_amount": 0.0}
	var current: float = float(source_liquid_module_state.source_get_state(liquids, water_id).get("amount", 0.0))
	var max_pump: float = minf(PUMP_LIQUID_CAPACITY - current, float(frame.get("amount", 0.0)) * PUMP_AMOUNT * delta)
	var cache_sums: Array = []
	cache_sums.resize(catalog["content_liquid_ids"].size())
	cache_sums.fill(0.0)
	source_liquid_module_state.source_add_state(liquids, water_id, max_pump, cache_sums)
	warmup = move_toward(warmup, 1.0 if max_pump > 0.001 else 0.0, PUMP_WARMUP_SPEED * delta)
	total_progress += warmup * delta
	frame["warmup"] = warmup
	frame["total_progress"] = total_progress
	sprite.set_meta(SOURCE_PUMP_BUILDING_META_KEY, frame)
	var liquid_amount: float = float(source_liquid_module_state.source_get_state(liquids, water_id).get("amount", 0.0))
	return {"liquid_drop": liquid_drop, "amount_pumped": max_pump, "warmup": warmup, "total_progress": total_progress, "liquid_amount": liquid_amount}
