extends RefCounted
class_name SourcePumpRuntimeState

const source_world_terrain_runtime_state := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")

const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")

const SOURCE_PUMP_BUILDING_META_KEY := "source_pump_building"

# Blocks.java:2298-2302: mechanicalPump = new Pump("mechanical-pump")
# with pumpAmount = 7f / 60f and liquidCapacity = 20f.
# Pump.java:23: warmupSpeed = 0.019f.
# Blocks.java:2322-2327: conduit liquidCapacity = 20f.
const PUMP_AMOUNT := 7.0 / 60.0
const PUMP_WARMUP_SPEED := 0.019
const PUMP_LIQUID_CAPACITY := 20.0
const CONDUIT_LIQUID_CAPACITY := 20.0


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


static func _liquid_capacity_for_block_id(block_id: String) -> float:
	# The pump's liquid neighbors in the bootstrap world are conduits
	# (Blocks.java:2322-2327, liquidCapacity = 20f). Other blocks have
	# no liquid capacity here, so they are not dump destinations.
	if block_id == "conduit":
		return CONDUIT_LIQUID_CAPACITY
	return 0.0


static func source_pump_dump_liquid_state(game: Object, cell: Vector2i) -> Dictionary:
	# Pump.java:180-182 PumpBuild.updateTile: if(liquidDrop != null)
	# dumpLiquid(liquidDrop). BuildingComp.java:877-878: dumpLiquid
	# (liquid) calls dumpLiquid(liquid, 2f) — scaling 2, any output
	# direction (-1) — which routes the pump's water to its liquid
	# neighbors through the bound dump_liquid_state (routing gate +
	# fraction transfer), then writes the pump's and each neighbor's
	# liquids back. The pump's proximity is its neighboring buildings
	# (the 4 adjacent cells that hold a block with a liquids module).
	# The neighbor accept check is the conduit's acceptLiquid
	# (Conduit.java:241-244): its current liquid matches, or its
	# current amount is under 0.2, and the pump is not on the side
	# the conduit outputs to ((relativeTo + 2) % 4 != rotation).
	var sprite: Variant = game.call("block_sprite_at_cell", cell)
	if sprite == null:
		return {"liquid_drop": null, "amount_dumped": 0.0, "liquid_amount": 0.0, "dump_cursor": 0}
	var frame: Dictionary = sprite.get_meta(SOURCE_PUMP_BUILDING_META_KEY, {})
	if frame.is_empty():
		source_pump_proximity_state(game, cell)
		frame = sprite.get_meta(SOURCE_PUMP_BUILDING_META_KEY, {})
	var liquid_drop: Variant = frame.get("liquid_drop", null)
	var dump_cursor: int = int(frame.get("dump_cursor", 0))
	var liquids: Variant = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, null)
	if liquid_drop == null or liquids == null:
		return {"liquid_drop": liquid_drop, "amount_dumped": 0.0, "liquid_amount": 0.0, "dump_cursor": dump_cursor}
	var catalog: Dictionary = source_content_registry_runtime_state.source_liquid_catalog_state(game.get("content_catalog"))
	var water_id: int = int(catalog["liquid_id_by_name"].get(str(liquid_drop), -1))
	if water_id < 0:
		return {"liquid_drop": liquid_drop, "amount_dumped": 0.0, "liquid_amount": 0.0, "dump_cursor": dump_cursor}
	var current: float = float(source_liquid_module_state.source_get_state(liquids, water_id).get("amount", 0.0))
	if current <= 0.0001:
		return {"liquid_drop": liquid_drop, "amount_dumped": 0.0, "liquid_amount": current, "dump_cursor": dump_cursor}
	# The 4 adjacent cells, east/north/west/south (relativeTo 0/1/2/3).
	var neighbor_offsets: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 1)]
	var relative_to: Array = []
	var destination_present: Array = []
	var other_has_liquids: Array = []
	var can_dump_liquid: Array = []
	var other_liquids_present: Array = []
	var other_amounts: Array = []
	var other_capacities: Array = []
	var other_accepts: Array = []
	var neighbor_liquids: Array = []
	for i in range(neighbor_offsets.size()):
		var ncell: Vector2i = cell + neighbor_offsets[i]
		var nsprite: Variant = game.call("block_sprite_at_cell", ncell)
		if nsprite == null:
			continue
		var nliquids: Variant = nsprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, null)
		if nliquids == null:
			continue
		var nblock_id: String = str(nsprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		var ncapacity: float = _liquid_capacity_for_block_id(nblock_id)
		if ncapacity <= 0.0:
			continue
		var ncurrent: Variant = nliquids.get("current", null)
		var ncurrent_amount := 0.0
		if ncurrent != null:
			ncurrent_amount = float(source_liquid_module_state.source_get_state(nliquids, int(ncurrent)).get("amount", 0.0))
		var nrotation: int = int(nsprite.get_meta("rotation", 0))
		relative_to.append(i)
		destination_present.append(true)
		other_has_liquids.append(true)
		can_dump_liquid.append(true)
		other_liquids_present.append(true)
		other_amounts.append(float(source_liquid_module_state.source_get_state(nliquids, water_id).get("amount", 0.0)))
		other_capacities.append(ncapacity)
		other_accepts.append((ncurrent == water_id or ncurrent_amount < 0.2) and (i + 2) % 4 != nrotation)
		neighbor_liquids.append(nliquids)
	var dump: Dictionary = source_building_liquid_state.dump_liquid_state(liquid_drop, 2.0, -1, current, false, true, true, relative_to.size(), dump_cursor, 0, relative_to, destination_present, other_has_liquids, can_dump_liquid, other_liquids_present, other_amounts, other_capacities, other_accepts, PUMP_LIQUID_CAPACITY, Callable(source_building_item_dump_state, "increment_dump_cursor_state"))
	var amount_after: float = float(dump.get("current_liquid_amount_after", current))
	var other_after: Array = dump.get("other_liquid_amount_by_index_after", [])
	for j in range(neighbor_liquids.size()):
		source_liquid_module_state.source_set_state(neighbor_liquids[j], water_id, float(other_after[j]))
	source_liquid_module_state.source_set_state(liquids, water_id, amount_after)
	var final_cdump: int = int(dump.get("final_cdump", dump_cursor))
	frame["dump_cursor"] = final_cdump
	sprite.set_meta(SOURCE_PUMP_BUILDING_META_KEY, frame)
	return {"liquid_drop": liquid_drop, "amount_dumped": current - amount_after, "liquid_amount": amount_after, "dump_cursor": final_cdump}
