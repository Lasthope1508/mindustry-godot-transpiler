extends RefCounted
class_name SourcePumpRuntimeState

const source_world_terrain_runtime_state := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")

const SOURCE_PUMP_BUILDING_META_KEY := "source_pump_building"


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
