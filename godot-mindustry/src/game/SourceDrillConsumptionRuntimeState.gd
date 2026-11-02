extends RefCounted
class_name SourceDrillConsumptionRuntimeState

const placed := preload("res://src/game/SourcePlacedBlockState.gd")
const liquid := preload("res://src/game/SourceConsumeLiquidState.gd")
const consume := preload("res://src/game/SourceConsumeState.gd")
const efficiency := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const access := preload("res://src/game/SourceBuildingAccessState.gd")
const drill := preload("res://src/game/SourceDrillRuntimeState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const defaults := preload("res://src/game/SourceFactoryDefaults.gd")
const time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const SOURCE_DRILL_BUILDING_META_KEY := "source_drill_building"

static func _initial_frame() -> Dictionary:
	return {"enabled": true, "cheating": false, "items": {}, "item_progress": 0.0, "warmup": 0.0, "time_drilled": 0.0, "last_drill_speed": 0.0, "dominant_item": null, "dominant_items": 0, "consumers": []}

static func _ore_state(game: Object, block: Object, cell: Vector2i) -> Dictionary:
	var ores: Dictionary = game.get("ore_items_by_cell")
	var found: Dictionary = {}
	for occupied in game.call("occupied_cells", cell, block):
		var key: String = game.call("cell_key", occupied)
		if ores.has(key):
			found[ores[key]] = true
	# Current flat-ore gameplay has one item kind per drill. Mixed-ore selection is unresolved.
	if found.size() > 1:
		return {"resolved": false}
	var item: Variant = null
	var count := 0
	if found.size() == 1:
		var item_id: String = found.keys()[0]
		var catalog = game.get("content_catalog")
		var candidates: Array = catalog.get_many("item").filter(func(value): return value.id == item_id)
		assert(candidates.size() == 1)
		if int(candidates[0].properties.get("hardness", defaults.DRILL_DELAY_ITEM_HARDNESS_DEFAULT)) <= int(block.properties["tier"]):
			item = item_id
			count = drill.game_ore_count(game, block.id, cell, item_id)
	return {"resolved": true, "dominant_item": item, "dominant_items": count}

static func _context(game: Object, seconds: float, cell: Vector2i, block: Object, frame: Dictionary) -> Dictionary:
	var context := drill.runtime_context(game, seconds, cell, block.id, str(frame["dominant_item"]), frame["dominant_items"], time_defaults.TICK_RATE, frame["speed"])
	context[drill.SOURCE_DRILL_CONTEXT_ACTIVE_KEY] = frame["dominant_item"] != null and frame["dominant_items"] > 0 and frame["efficiency"] > 0 and inventory.items_total(frame["items"]) < block.properties["itemCapacity"]
	context[drill.SOURCE_DRILL_CONTEXT_ITEMS_TOTAL_KEY] = inventory.items_total(frame["items"])
	context[drill.SOURCE_DRILL_CONTEXT_CURRENT_WARMUP_KEY] = frame["warmup"]
	context[drill.SOURCE_DRILL_CONTEXT_CURRENT_TIME_DRILLED_KEY] = frame["time_drilled"]
	context[drill.SOURCE_DRILL_CONTEXT_CURRENT_LAST_SPEED_KEY] = frame["last_drill_speed"]
	context[drill.SOURCE_DRILL_CONTEXT_CURRENT_PROGRESS_FRACTION_KEY] = frame["item_progress"]
	# Java advances timeDrilled before the active/full-output branch, but not on null ore.
	if not context[drill.SOURCE_DRILL_CONTEXT_ACTIVE_KEY] and frame["dominant_item"] != null:
		context[drill.SOURCE_DRILL_CONTEXT_CURRENT_TIME_DRILLED_KEY] += drill.game_time_drilled_delta(game, frame["warmup"], seconds, context[drill.SOURCE_DRILL_CONTEXT_TIME_SCALE_KEY])
	return context

static func source_tick_state(game: Object, seconds: float) -> Dictionary:
	var results: Dictionary = {}
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var primary: Vector2i = game.get("drill_pos")
	for sprite in placed.source_unique_buildings_state(game)["buildings"]:
		var block_id: String = sprite.get_meta(placed.SOURCE_BLOCK_ID_META_KEY)
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		# Current source base-Drill definitions with power consumers require the power domain.
		if block.implementation != drill.SOURCE_DRILL_GENERATED_CLASS.get_file().get_basename() or not block.properties.has("consumeLiquid") or block.properties.has("consumePower"):
			continue
		var cell: Vector2i = sprite.get_meta("origin_cell")
		var ore := _ore_state(game, block, cell)
		if not ore["resolved"]:
			continue
		if not sprite.has_meta(SOURCE_DRILL_BUILDING_META_KEY):
			sprite.set_meta(SOURCE_DRILL_BUILDING_META_KEY, _initial_frame())
		var frame: Dictionary = sprite.get_meta(SOURCE_DRILL_BUILDING_META_KEY)
		var rows: Array = liquid.source_bind_liquid_consumers_state(block, catalog)["consumers"]
		var amounts: Dictionary = sprite.get_meta(placed.SOURCE_BUILDING_LIQUIDS_META_KEY)
		assert(amounts["flow"] == null, "Live flow cache binding requires its own lifecycle slice")
		if frame["consumers"].is_empty():
			for row in rows:
				frame["consumers"].append(liquid.source_runtime_consumer_state(row, amounts, [], consume.source_cost_multiplier_state)["consumer"])
		if cell == primary:
			frame["items"] = game.get("drill_items")
			frame["item_progress"] = game.get("item_progress")
			frame["warmup"] = game.call("drill_warmup_at_cell", cell.x, cell.y)
			frame["time_drilled"] = game.call("drill_time_drilled_at_cell", cell.x, cell.y)
			frame["last_drill_speed"] = game.call("drill_last_speed_at_cell", cell.x, cell.y)
		frame["dominant_item"] = ore["dominant_item"]
		frame["dominant_items"] = ore["dominant_items"]
		var should_consume: bool = inventory.items_total(frame["items"]) < block.properties["itemCapacity"] and frame["enabled"] and frame["dominant_item"] != null
		var valid := access.production_valid_state()
		var setup := efficiency.update_consumption_setup_state(should_consume, valid)
		frame["efficiency"] = setup["efficiency"]
		frame["efficiency_scale"] = efficiency.efficiency_scale_state()
		var groups := consume.classify_consumer_arrays(rows, "ignored", "optional", "update")
		var required_results: Array = []
		var optional_results: Array = []
		var updates: Array = []
		for index in range(rows.size()):
			var actor = frame["consumers"][index]
			actor.source_delta = seconds * time_defaults.TICK_RATE
			actor.time_scale = placed.time_scale(sprite, placed.game_default_time_scale(game))
			if frame["enabled"] and not frame["cheating"]:
				if groups["non_optional_consumers"].has(rows[index]):
					required_results.append({"result": actor.efficiency(frame), "is_power": false})
				if groups["optional_consumers"].has(rows[index]):
					optional_results.append({"result": actor.efficiency(frame)})
			if groups["update_consumers"].has(rows[index]):
				updates.append(actor)
		var consumption := efficiency.update_consumption_state(groups["has_consumers"], frame["cheating"], frame["enabled"], valid, should_consume, frame["efficiency_scale"], required_results, optional_results, updates, frame)
		efficiency.apply_update_consumption_state(consumption, frame)
		frame["speed"] = lerpf(defaults.DRILL_UNBOOSTED_SPEED, defaults.DRILL_LIQUID_BOOST_INTENSITY, frame["optional_efficiency"]) * frame["efficiency"]
		var event: Dictionary
		if frame["dominant_item"] == null:
			event = {"drill_warmup": frame["warmup"], "drill_last_speed": frame["last_drill_speed"], "drill_time_drilled": frame["time_drilled"], "item_progress": frame["item_progress"], "offload_amount": 0, "produced_delta": 0}
		else:
			event = drill.runtime_state(_context(game, seconds, cell, block, frame), drill.runtime_callbacks(game))
		frame["item_progress"] = event["item_progress"]
		frame["warmup"] = event["drill_warmup"]
		frame["time_drilled"] = event["drill_time_drilled"]
		frame["last_drill_speed"] = event["drill_last_speed"]
		if cell != primary:
			if event["offload_amount"] > 0:
				frame["items"] = inventory.add_item_state(frame["items"], frame["dominant_item"], event["offload_amount"])["drill_items"]
			game.call("set_drill_warmup_at_cell", cell.x, cell.y, frame["warmup"])
			game.call("set_drill_time_drilled_at_cell", cell.x, cell.y, frame["time_drilled"])
			game.call("set_drill_last_speed_at_cell", cell.x, cell.y, frame["last_drill_speed"])
		results[game.call("cell_key", cell)] = event
	return {"drill_states": results}

static func source_factory_state(game: Object, seconds: float) -> Dictionary:
	var events: Dictionary = source_tick_state(game, seconds)["drill_states"]
	var factory = load("res://src/game/SourceFactoryRuntimeState.gd")
	var simulation = load("res://src/game/SourceFactorySimulationRuntimeState.gd")
	var context: Dictionary = factory.simulation_context(seconds, game.get("transport_progress"), factory.game_factory_cell_context(game), game.get("drill_pos"))
	var callbacks: Dictionary = factory.simulation_callbacks(game)
	var primary_key: String = game.call("cell_key", game.get("drill_pos"))
	if events.has(primary_key):
		callbacks["drill_runtime_state"] = func(_seconds): return events[primary_key]
	return simulation.simulation_state(context, callbacks)
