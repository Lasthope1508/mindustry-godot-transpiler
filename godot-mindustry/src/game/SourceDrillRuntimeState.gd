extends RefCounted
class_name SourceDrillRuntimeState

const SourceBlockMetadataState := preload("res://src/game/SourceBlockMetadataState.gd")
const SourceFactoryRuntimeState := preload("res://src/game/SourceFactoryRuntimeState.gd")

const SOURCE_DRILL_ORE_COUNT_METHOD := "protected void countOre(Tile tile){"
const SOURCE_DRILL_ORE_COUNT_RETURN_ITEM_RESET := "returnItem = null;"
const SOURCE_DRILL_ORE_COUNT_RETURN_COUNT_RESET := "returnCount = 0;"
const SOURCE_DRILL_ORE_COUNT_LINKED_TILES_LOOP := "for(Tile other : tile.getLinkedTilesAs(this, tempTiles)){"
const SOURCE_DRILL_ORE_COUNT_CAN_MINE_GATE := "if(canMine(other)){"
const SOURCE_DRILL_ORE_COUNT_INCREMENT := "oreCount.increment(getDrop(other), 0, 1);"
const SOURCE_DRILL_ORE_COUNT_RETURN_ITEM := "returnItem = itemArray.peek();"
const SOURCE_DRILL_ORE_COUNT_RETURN_COUNT := "returnCount = oreCount.get(itemArray.peek(), 0);"

const SOURCE_DRILL_DELAY_METHOD := "public float getDrillTime(Item item){"
const SOURCE_DRILL_DELAY_RESULT := "return (drillTime + hardnessDrillMultiplier * item.hardness) / drillMultipliers.get(item, 1f);"
const SOURCE_DRILL_DELAY_HARDNESS_MULTIPLIER_FIELD := "public float hardnessDrillMultiplier = 50f;"
const SOURCE_DRILL_DELAY_DRILL_TIME_COMMENT := "Base time to drill one ore, in frames."
const SOURCE_DRILL_DELAY_DRILL_TIME_FIELD := "public float drillTime = 300;"
const SOURCE_DRILL_DELAY_DRILL_MULTIPLIERS_COMMENT := "Multipliers of drill speed for each item. Defaults to 1."
const SOURCE_DRILL_DELAY_DRILL_MULTIPLIERS_FIELD := "public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();"
const SOURCE_DRILL_DELAY_ITEM_HARDNESS_COMMENT := "drill hardness of the item"
const SOURCE_DRILL_DELAY_ITEM_HARDNESS_FIELD := "public int hardness = 0;"

const SOURCE_DRILL_OUTPUT_RATE_DRAW_PLACE := "float width = drawPlaceText(Core.bundle.formatFloat(\"bar.drillspeed\", 60f / getDrillTime(returnItem) * returnCount, 2), x, y, valid);"
const SOURCE_DRILL_OUTPUT_RATE_RATE_EXPR := "60f / getDrillTime(returnItem) * returnCount"
const SOURCE_DRILL_OUTPUT_RATE_RETURN_ITEM := "returnItem"
const SOURCE_DRILL_OUTPUT_RATE_RETURN_COUNT := "returnCount"

const SOURCE_DRILL_OUTPUT_DELTA_PROGRESS_INCREMENT := "progress += delta() * dominantItems * speed * warmup;"
const SOURCE_DRILL_OUTPUT_DELTA_SOURCE_DELTA := "delta()"
const SOURCE_DRILL_OUTPUT_DELTA_DOMINANT_ITEMS := "dominantItems"
const SOURCE_DRILL_OUTPUT_DELTA_SPEED := "speed"
const SOURCE_DRILL_OUTPUT_DELTA_WARMUP := "warmup"

const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_TILE_FIELD := "transient Tile tile;"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_BLOCK_FIELD := "transient Block block;"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_TILE_X := "return tile.x;"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_TILE_Y := "return tile.y;"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_TIME_SCALE_FIELD := "private transient float timeScale = 1f, timeScaleDuration;"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_TIME_SCALE_METHOD := "public float timeScale(){"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_TIME_SCALE_RETURN := "return timeScale;"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_DELEGATE := "progress += delta() * dominantItems * speed * warmup;"

const SOURCE_DRILL_INACTIVE_WARMUP_LAST_SPEED_RESET := "lastDrillSpeed = 0f;"
const SOURCE_DRILL_INACTIVE_WARMUP_WARMUP_DECAY := "warmup = Mathf.approachDelta(warmup, 0f, warmupSpeed);"
const SOURCE_DRILL_INACTIVE_WARMUP_WARMUP_SPEED_COMMENT := "Speed at which the drill speeds up."
const SOURCE_DRILL_INACTIVE_WARMUP_WARMUP_SPEED_FIELD := "public float warmupSpeed = 0.015f;"

const SOURCE_DRILL_WARMUP_STATE_ACTIVE_WARMUP := "warmup = Mathf.approachDelta(warmup, speed, warmupSpeed);"
const SOURCE_DRILL_WARMUP_STATE_CURRENT_WARMUP := "warmup"
const SOURCE_DRILL_WARMUP_STATE_SPEED := "speed"
const SOURCE_DRILL_WARMUP_STATE_WARMUP_SPEED := "warmupSpeed"
const SOURCE_DRILL_WARMUP_STATE_SOURCE_DELTA := "Time.delta"

const SOURCE_DRILL_TIME_DRILLED_FIELD := "public float timeDrilled;"
const SOURCE_DRILL_TIME_DRILLED_INCREMENT := "timeDrilled += warmup * delta();"
const SOURCE_DRILL_TIME_DRILLED_WARMUP := "warmup"
const SOURCE_DRILL_TIME_DRILLED_SOURCE_DELTA := "delta()"
const SOURCE_DRILL_TIME_DRILLED_DELTA_RETURN := "return Time.delta * timeScale;"

const SOURCE_DRILL_LAST_SPEED_DELAY := "float delay = getDrillTime(dominantItem);"
const SOURCE_DRILL_LAST_SPEED_SPEED_EXPR := "float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;"
const SOURCE_DRILL_LAST_SPEED_ASSIGNMENT := "lastDrillSpeed = (speed * dominantItems * warmup) / delay;"
const SOURCE_DRILL_LAST_SPEED_LIQUID_BOOST_FIELD := "public float liquidBoostIntensity = 1.6f;"
const SOURCE_DRILL_LAST_SPEED_FOR_CELL_TILE_FIELD := "transient Tile tile;"
const SOURCE_DRILL_LAST_SPEED_FOR_CELL_BLOCK_FIELD := "transient Block block;"
const SOURCE_DRILL_LAST_SPEED_FOR_CELL_TILE_X := "return tile.x;"
const SOURCE_DRILL_LAST_SPEED_FOR_CELL_TILE_Y := "return tile.y;"
const SOURCE_DRILL_LAST_SPEED_FOR_CELL_DELEGATE := "lastDrillSpeed = (speed * dominantItems * warmup) / delay;"

static func drill_delay(block_id: String, item_id: String, content_catalog, hardness_multiplier: float) -> float:
	if content_catalog == null:
		return 0.0
	var block = content_catalog.get_by_id(block_id)
	var item = content_catalog.get_by_id(item_id)
	if block == null or item == null:
		return 0.0
	var delay_state := SourceBlockMetadataState.block_drill_delay_state(block_id, item_id, content_catalog)
	return (float(delay_state.get("drill_time", SourceBlockMetadataState.SOURCE_DRILL_DELAY_DRILL_TIME_DEFAULT)) + hardness_multiplier * float(delay_state.get("item_hardness", SourceBlockMetadataState.SOURCE_DRILL_DELAY_ITEM_HARDNESS_DEFAULT))) / float(delay_state.get("drill_multiplier", 1.0))

static func generated_get_drill_time_bridge_state(block_id: String, item_id: String, content_catalog, hardness_multiplier: float) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/production/Drill.gd")
	var instance = script.new()
	var block = content_catalog.get_by_id(block_id) if content_catalog != null else null
	var item = content_catalog.get_by_id(item_id) if content_catalog != null else null
	if block == null or item == null:
		return {
			"source_owner": "SourceDrillRuntimeState.drill_delay",
			"generated_owner": "Drill.java_method_getDrillTime_6",
			"result": {},
			"canonical": drill_delay(block_id, item_id, content_catalog, hardness_multiplier),
			"matches": false,
		}
	var delay_state := SourceBlockMetadataState.block_drill_delay_state(block_id, item_id, content_catalog)
	var drill_time := float(delay_state.get("drill_time", SourceBlockMetadataState.SOURCE_DRILL_DELAY_DRILL_TIME_DEFAULT))
	var item_hardness := float(delay_state.get("item_hardness", SourceBlockMetadataState.SOURCE_DRILL_DELAY_ITEM_HARDNESS_DEFAULT))
	var drill_multiplier := float(delay_state.get("drill_multiplier", 1.0))
	var result = instance.java_method_getDrillTime_6([drill_time, hardness_multiplier, item_hardness, drill_multiplier])
	var canonical := drill_delay(block_id, item_id, content_catalog, hardness_multiplier)
	return {
		"source_owner": "SourceDrillRuntimeState.drill_delay",
		"generated_owner": "Drill.java_method_getDrillTime_6",
		"result": result,
		"canonical": canonical,
		"matches": is_equal_approx(float(result.get("drillTime", 0.0)), canonical),
	}

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"occupied_cells": Callable(game, "occupied_cells"),
		"cell_key": Callable(game, "cell_key"),
		"delay": Callable(game, "source_drill_delay"),
		"approach_delta": Callable(game, "source_approach_delta"),
		"building_delta": Callable(game, "source_building_delta"),
	}

static func output_rate(block_id: String, item_id: String, return_count: int, source_tick_rate: float, drill_delay_fn: Callable) -> float:
	if return_count <= 0:
		return 0.0
	var delay := float(drill_delay_fn.call(block_id, item_id))
	if delay <= 0.0:
		return 0.0
	return source_tick_rate * float(return_count) / delay

static func output_delta(dominant_items: int, seconds: float, time_scale: float, warmup: float, speed: float, source_tick_rate: float, building_delta_fn: Callable) -> float:
	var scaled_source_delta := float(building_delta_fn.call(seconds * source_tick_rate, time_scale))
	return scaled_source_delta * float(dominant_items) * speed * warmup

static func warmup_state(current_warmup: float, speed: float, warmup_speed: float, source_delta: float, approach_delta_fn: Callable) -> float:
	return float(approach_delta_fn.call(current_warmup, speed, warmup_speed, source_delta))

static func inactive_warmup_state(current_warmup: float, warmup_speed: float, source_delta: float, approach_delta_fn: Callable) -> float:
	return float(approach_delta_fn.call(current_warmup, 0.0, warmup_speed, source_delta))

static func time_drilled_delta(warmup: float, seconds: float, time_scale: float, source_tick_rate: float, building_delta_fn: Callable) -> float:
	return warmup * float(building_delta_fn.call(seconds * source_tick_rate, time_scale))

static func last_speed(block_id: String, item_id: String, ore_count: int, warmup: float, speed: float, drill_delay_fn: Callable) -> float:
	if ore_count <= 0:
		return 0.0
	var delay := float(drill_delay_fn.call(block_id, item_id))
	if delay <= 0.0:
		return 0.0
	return speed * float(ore_count) * warmup / delay

static func ore_count(block_id: String, cell: Vector2i, item_id: String, content_catalog, ore_items_by_cell: Dictionary, occupied_cells_fn: Callable, cell_key_fn: Callable) -> int:
	if content_catalog == null:
		return 0
	var block = content_catalog.get_by_id(block_id)
	if block == null:
		return 0
	var count := 0
	for occupied_cell in occupied_cells_fn.call(cell, block):
		if str(ore_items_by_cell.get(str(cell_key_fn.call(occupied_cell)), "")) == item_id:
			count += 1
	return count

static func runtime_context(game: Object, seconds: float, drill_cell: Vector2i, block_id: String, item_id: String, dominant_items: int, source_tick_rate: float, speed := 1.0) -> Dictionary:
	var method_names := SourceFactoryRuntimeState.runtime_method_names(game)
	var block_item_capacity_method := SourceFactoryRuntimeState.runtime_method_name(method_names, "block_item_capacity", "source_block_item_capacity")
	var block_time_scale_method := SourceFactoryRuntimeState.runtime_method_name(method_names, "block_time_scale_at_cell", "source_block_time_scale_at_cell")
	var items_total_value: int = game.call("drill_items_total")
	var item_capacity_value: int = game.call(block_item_capacity_method, block_id)
	var current_warmup_value: float = game.call("drill_warmup_at_cell", drill_cell.x, drill_cell.y)
	var current_time_drilled_value: float = game.call("drill_time_drilled_at_cell", drill_cell.x, drill_cell.y)
	var current_last_speed_value: float = game.call("drill_last_speed_at_cell", drill_cell.x, drill_cell.y)
	var time_scale_value: float = game.call(block_time_scale_method, drill_cell.x, drill_cell.y)
	return {
		"active": float(game.get("drill_output_rate")) > 0.0,
		"cell_x": drill_cell.x,
		"cell_y": drill_cell.y,
		"block_id": block_id,
		"item_id": item_id,
		"dominant_items": dominant_items,
		"items_total": items_total_value,
		"item_capacity": item_capacity_value,
		"current_warmup": current_warmup_value,
		"current_time_drilled": current_time_drilled_value,
		"current_last_speed": current_last_speed_value,
		"current_progress_fraction": float(game.get("item_progress")),
		"seconds": seconds,
		"source_delta": seconds * source_tick_rate,
		"time_scale": time_scale_value,
		"speed": speed,
	}

static func runtime_callbacks(game: Object) -> Dictionary:
	var method_names := SourceFactoryRuntimeState.runtime_method_names(game)
	var warmup_speed_method := SourceFactoryRuntimeState.runtime_method_name(method_names, "drill_warmup_speed", "source_drill_warmup_speed")
	var warmup_state_method := SourceFactoryRuntimeState.runtime_method_name(method_names, "drill_warmup_state", "source_drill_warmup_state")
	var inactive_warmup_state_method := SourceFactoryRuntimeState.runtime_method_name(method_names, "drill_inactive_warmup_state", "source_drill_inactive_warmup_state")
	var time_drilled_delta_method := SourceFactoryRuntimeState.runtime_method_name(method_names, "drill_time_drilled_delta", "source_drill_time_drilled_delta")
	var last_speed_for_cell_method := SourceFactoryRuntimeState.runtime_method_name(method_names, "drill_last_speed_for_cell", "source_drill_last_speed_for_cell")
	var delay_method := SourceFactoryRuntimeState.runtime_method_name(method_names, "drill_delay", "source_drill_delay")
	var output_delta_for_cell_method := SourceFactoryRuntimeState.runtime_method_name(method_names, "drill_output_delta_for_cell", "source_drill_output_delta_for_cell")
	var production_state_method := SourceFactoryRuntimeState.runtime_method_name(method_names, "drill_production_runtime_state", "source_drill_production_runtime_state")
	return {
		"warmup_speed": Callable(game, warmup_speed_method),
		"warmup_state": Callable(game, warmup_state_method),
		"inactive_warmup_state": Callable(game, inactive_warmup_state_method),
		"time_drilled_delta": Callable(game, time_drilled_delta_method),
		"last_speed_for_cell": Callable(game, last_speed_for_cell_method),
		"delay": Callable(game, delay_method),
		"output_delta_for_cell": Callable(game, output_delta_for_cell_method),
		"production_state": Callable(game, production_state_method),
	}

static func runtime_state(drill_context: Dictionary, drill_callbacks: Dictionary) -> Dictionary:
	var active := bool(drill_context.get("active", false))
	var cell_x := int(drill_context.get("cell_x", 0))
	var cell_y := int(drill_context.get("cell_y", 0))
	var block_id := str(drill_context.get("block_id", ""))
	var item_id := str(drill_context.get("item_id", ""))
	var dominant_items := int(drill_context.get("dominant_items", 0))
	var items_total := int(drill_context.get("items_total", 0))
	var item_capacity := int(drill_context.get("item_capacity", 0))
	var current_warmup := float(drill_context.get("current_warmup", 0.0))
	var current_time_drilled := float(drill_context.get("current_time_drilled", 0.0))
	var current_last_speed := float(drill_context.get("current_last_speed", 0.0))
	var current_progress_fraction := float(drill_context.get("current_progress_fraction", 0.0))
	var seconds := float(drill_context.get("seconds", 0.0))
	var source_delta := float(drill_context.get("source_delta", 0.0))
	var time_scale := float(drill_context.get("time_scale", 1.0))
	var speed := float(drill_context.get("speed", 1.0))
	var warmup_speed_fn: Callable = drill_callbacks.get("warmup_speed", Callable())
	var warmup_state_fn: Callable = drill_callbacks.get("warmup_state", Callable())
	var inactive_warmup_state_fn: Callable = drill_callbacks.get("inactive_warmup_state", Callable())
	var time_drilled_delta_fn: Callable = drill_callbacks.get("time_drilled_delta", Callable())
	var last_speed_for_cell_fn: Callable = drill_callbacks.get("last_speed_for_cell", Callable())
	var delay_fn: Callable = drill_callbacks.get("delay", Callable())
	var output_delta_for_cell_fn: Callable = drill_callbacks.get("output_delta_for_cell", Callable())
	var production_state_fn: Callable = drill_callbacks.get("production_state", Callable())
	var warmup_speed := float(warmup_speed_fn.call(block_id))
	var time_drilled_delta := 0.0
	var drill_time_drilled := current_time_drilled
	var drill_last_speed := current_last_speed
	var drill_warmup := current_warmup
	var drill_delay := 0.0
	var output_delta := 0.0
	var production_state: Dictionary = {}
	var offload_amount := 0
	var produced_delta := 0
	var item_progress := current_progress_fraction
	if active:
		time_drilled_delta = float(time_drilled_delta_fn.call(current_warmup, seconds, time_scale))
		drill_time_drilled = current_time_drilled + time_drilled_delta
		drill_last_speed = float(last_speed_for_cell_fn.call(cell_x, cell_y, item_id, dominant_items, current_warmup, speed))
		drill_warmup = float(warmup_state_fn.call(current_warmup, speed, warmup_speed, source_delta))
		drill_delay = float(delay_fn.call(block_id, item_id))
		output_delta = float(output_delta_for_cell_fn.call(cell_x, cell_y, dominant_items, seconds, drill_warmup, speed))
		production_state = production_state_fn.call(current_progress_fraction, drill_delay, output_delta, dominant_items, items_total, item_capacity)
		offload_amount = int(production_state.get("offload_amount", 0))
		produced_delta = int(production_state.get("produced_delta", offload_amount))
		item_progress = float(production_state.get("item_progress", current_progress_fraction))
	else:
		var inactive_warmup := float(inactive_warmup_state_fn.call(current_warmup, warmup_speed, source_delta))
		drill_last_speed = 0.0
		drill_warmup = inactive_warmup
	return {
		"drill_active": active,
		"drill_warmup_before": current_warmup,
		"drill_warmup": drill_warmup,
		"drill_last_speed_before": current_last_speed,
		"drill_last_speed": drill_last_speed,
		"drill_time_drilled_before": current_time_drilled,
		"drill_time_drilled_delta": time_drilled_delta,
		"drill_time_drilled": drill_time_drilled,
		"drill_delay": drill_delay,
		"drill_output_delta": output_delta,
		"production_state": production_state,
		"offload_amount": offload_amount,
		"produced_delta": produced_delta,
		"item_progress": item_progress,
		"source_owner": "PortGame.source_drill_runtime_state",
	}
