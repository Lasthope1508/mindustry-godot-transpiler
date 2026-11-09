extends RefCounted
class_name SourceDrillConsumptionRuntimeState

const placed := preload("res://src/game/SourcePlacedBlockState.gd")
const liquid := preload("res://src/game/SourceConsumeLiquidState.gd")
const consume := preload("res://src/game/SourceConsumeState.gd")
const efficiency := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const access := preload("res://src/game/SourceBuildingAccessState.gd")
const drill := preload("res://src/game/SourceDrillRuntimeState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const defaults := preload("res://src/game/SourceFactoryDefaults.gd")
const time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const SOURCE_DRILL_BUILDING_META_KEY := "source_drill_building"

static func _initial_frame() -> Dictionary:
	return {"enabled": true, "cheating": false, "items": {}, "item_progress": 0.0, "warmup": 0.0, "time_drilled": 0.0, "last_drill_speed": 0.0, "dominant_item": null, "dominant_items": 0, "consumers": []}

static func source_drill_booster_state(game: Object, cell: Vector2i) -> Dictionary:
	# Drill.java:38 liquidBoostIntensity = 1.6f; Drill.java:301 the
	# drill's updateTile speed is lerp(1f, liquidBoostIntensity,
	# optionalEfficiency) * efficiency. The mechanical drill consumes
	# water 0.05f as an optional booster (Blocks.java:2873,
	# consumeLiquid(Liquids.water, 0.05f).boost()), and the tick
	# state (source_tick_state) already computes frame["speed"] from
	# frame["optional_efficiency"] — this slice reads that booster
	# state back, so the C04 gate can prove the drill runs 1.6x
	# faster when water reaches it.
	var sprite: Variant = game.call("block_sprite_at_cell", cell)
	if sprite == null:
		return {"water": 0.0, "optional_efficiency": 0.0, "speed": 1.0, "boosted": false}
	var liquids: Variant = sprite.get_meta(placed.SOURCE_BUILDING_LIQUIDS_META_KEY, null)
	var water := 0.0
	if liquids != null:
		var content_registry_state := load("res://src/game/SourceContentRegistryRuntimeState.gd")
		var catalog: Dictionary = content_registry_state.source_liquid_catalog_state(game.get("content_catalog"))
		var water_id: int = int(catalog["liquid_id_by_name"].get("water", -1))
		if water_id >= 0:
			water = float(liquid.source_runtime_storage.source_get_state(liquids, water_id).get("amount", 0.0))
	var frame: Dictionary = sprite.get_meta(SOURCE_DRILL_BUILDING_META_KEY, {})
	var optional_efficiency: float = float(frame.get("optional_efficiency", 0.0))
	var speed: float = float(frame.get("speed", defaults.DRILL_UNBOOSTED_SPEED))
	return {"water": water, "optional_efficiency": optional_efficiency, "speed": speed, "boosted": optional_efficiency > 0.0}


static func source_on_proximity_update_state(game: Object, sprite: Sprite2D, block: Object) -> Dictionary:
	# These fields are exported through Drill ancestry. Separate implementations retain their own lifecycle.
	if not block.properties.has("blockedItems"):
		return {"applied": false}
	var items: Dictionary = game.get("source_item_catalog")
	var blocked: Dictionary = drill.source_bind_ore_items_state(block, items)
	var cell: Vector2i = sprite.get_meta("origin_cell")
	var linked: Dictionary = game.call("source_world_linked_ore_tiles_state", block, cell.x, cell.y, items)
	var selected := drill.source_on_proximity_update_state(linked["ore_tiles"], int(block.properties["tier"]), blocked["blocked_items"])
	if not sprite.has_meta(SOURCE_DRILL_BUILDING_META_KEY):
		sprite.set_meta(SOURCE_DRILL_BUILDING_META_KEY, _initial_frame())
	var frame: Dictionary = sprite.get_meta(SOURCE_DRILL_BUILDING_META_KEY)
	frame["dominant_item"] = selected["dominant_item"]
	frame["dominant_items"] = selected["dominant_items"]
	return {"applied": true}

static func source_picked_up_state(sprite: Sprite2D) -> void:
	var frame: Dictionary = sprite.get_meta(SOURCE_DRILL_BUILDING_META_KEY)
	frame["dominant_item"] = drill.source_picked_up_state(frame)["dominant_item"]

static func source_dominant_item_name_state(game: Object, sprite: Variant) -> Dictionary:
	if sprite == null or not sprite.has_meta(SOURCE_DRILL_BUILDING_META_KEY):
		return {"item_id": null}
	var frame: Dictionary = sprite.get_meta(SOURCE_DRILL_BUILDING_META_KEY)
	if frame["dominant_item"] == null:
		return {"item_id": null}
	var items: Dictionary = game.get("source_item_catalog")
	return {"item_id": items["item_names_by_id"][frame["dominant_item"]["id"]]}

static func _context(game: Object, seconds: float, cell: Vector2i, block: Object, frame: Dictionary) -> Dictionary:
	var context := drill.runtime_context(game, seconds, cell, block.id, source_dominant_item_name_state(game, game.call("block_sprite_at_cell", cell))["item_id"], frame["dominant_items"], time_defaults.TICK_RATE, frame["speed"])
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
		assert(sprite.has_meta(SOURCE_DRILL_BUILDING_META_KEY), "Drill proximity must bind the frame before ticking")
		var frame: Dictionary = sprite.get_meta(SOURCE_DRILL_BUILDING_META_KEY)
		var rows: Array = liquid.source_bind_liquid_consumers_state(block, catalog)["consumers"]
		var amounts: Dictionary = sprite.get_meta(placed.SOURCE_BUILDING_LIQUIDS_META_KEY)
		assert(amounts["flow"] == null, "Live flow cache binding requires its own lifecycle slice")
		# The cost multiplier is a per-block callback (N2097): the
		# frame carries the block implementation, the building team
		# (from the sprite's team meta) and the live rules state, so
		# the multiplier reads them like Java's b -> state.rules
		# .unitCost(b.team). The drill is not a unit factory, so it
		# keeps the 1.0 default; the keys are set before the consumers
		# are created and persist on the frame.
		frame["block_implementation"] = block.implementation
		frame["team_id"] = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		frame["rules_state"] = source_rules_state.source_game_rules_state(game.get("rules_state"))["rules"]
		if frame["consumers"].is_empty():
			for row in rows:
				frame["consumers"].append(liquid.source_runtime_consumer_state(row, amounts, [], consume.source_cost_multiplier_for_block_state)["consumer"])
		if cell == primary:
			frame["items"] = game.get("drill_items")
			frame["item_progress"] = game.get("item_progress")
			frame["warmup"] = game.call("drill_warmup_at_cell", cell.x, cell.y)
			frame["time_drilled"] = game.call("drill_time_drilled_at_cell", cell.x, cell.y)
			frame["last_drill_speed"] = game.call("drill_last_speed_at_cell", cell.x, cell.y)
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
				frame["items"] = inventory.add_item_state(frame["items"], source_dominant_item_name_state(game, sprite)["item_id"], event["offload_amount"])["drill_items"]
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
