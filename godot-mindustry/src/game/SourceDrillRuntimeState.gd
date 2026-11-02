extends RefCounted
class_name SourceDrillRuntimeState

static func source_can_mine_state(tile: Variant, tier: int, blocked_items: Variant) -> Dictionary:
	if tile == null or tile["is_static"]:
		return {"can_mine": false}
	var drops: Variant = tile["drop"]
	return {"can_mine": drops != null and drops["hardness"] <= tier and (blocked_items == null or not blocked_items.has(drops["id"]))}

static func source_count_ore_state(linked_tiles: Array, tier: int, blocked_items: Variant) -> Dictionary:
	var ore_count: Dictionary = {}
	var item_array: Array = []
	for other in linked_tiles:
		if source_can_mine_state(other, tier, blocked_items)["can_mine"]:
			var item: Dictionary = other["drop"]
			if not ore_count.has(item["id"]):
				item_array.append(item)
			ore_count[item["id"]] = ore_count.get(item["id"], 0) + 1
	item_array.sort_custom(func(item1: Dictionary, item2: Dictionary) -> bool:
		if item1["low_priority"] != item2["low_priority"]:
			return item1["low_priority"]
		if ore_count[item1["id"]] != ore_count[item2["id"]]:
			return ore_count[item1["id"]] < ore_count[item2["id"]]
		return item1["id"] < item2["id"]
	)
	var return_item: Variant = null if item_array.is_empty() else item_array.back()
	return {"returnItem": return_item, "returnCount": 0 if return_item == null else ore_count[return_item["id"]], "oreCount": ore_count, "itemArray": item_array}

const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_factory_runtime_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_drill_production_runtime_state_script := preload("res://src/game/SourceDrillProductionRuntimeState.gd")
const source_world_initial_build_runtime_state_script := preload("res://src/game/SourceWorldInitialBuildRuntimeState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")

const SOURCE_DRILL_OCCUPIED_CELLS_CALLBACK_KEY := "occupied_cells"
const SOURCE_DRILL_CELL_KEY_CALLBACK_KEY := "cell_key"
const SOURCE_DRILL_DELAY_CALLBACK_KEY := "delay"
const SOURCE_DRILL_APPROACH_DELTA_CALLBACK_KEY := "approach_delta"
const SOURCE_DRILL_BUILDING_DELTA_CALLBACK_KEY := "building_delta"
const SOURCE_DRILL_WARMUP_SPEED_CALLBACK_KEY := "warmup_speed"
const SOURCE_DRILL_WARMUP_STATE_CALLBACK_KEY := "warmup_state"
const SOURCE_DRILL_INACTIVE_WARMUP_STATE_CALLBACK_KEY := "inactive_warmup_state"
const SOURCE_DRILL_TIME_DRILLED_DELTA_CALLBACK_KEY := "time_drilled_delta"
const SOURCE_DRILL_LAST_SPEED_FOR_CELL_CALLBACK_KEY := "last_speed_for_cell"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_CALLBACK_KEY := "output_delta_for_cell"
const SOURCE_DRILL_PRODUCTION_STATE_CALLBACK_KEY := "production_state"

const SOURCE_DRILL_BLOCK_ITEM_CAPACITY_METHOD_KEY := "block_item_capacity"
const SOURCE_DRILL_BLOCK_TIME_SCALE_AT_CELL_METHOD_KEY := "block_time_scale_at_cell"
const SOURCE_DRILL_WARMUP_SPEED_METHOD_KEY := "drill_warmup_speed"
const SOURCE_DRILL_WARMUP_STATE_METHOD_KEY := "drill_warmup_state"
const SOURCE_DRILL_INACTIVE_WARMUP_STATE_METHOD_KEY := "drill_inactive_warmup_state"
const SOURCE_DRILL_TIME_DRILLED_DELTA_METHOD_KEY := "drill_time_drilled_delta"
const SOURCE_DRILL_LAST_SPEED_FOR_CELL_METHOD_KEY := "drill_last_speed_for_cell"
const SOURCE_DRILL_DELAY_METHOD_KEY := "drill_delay"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_METHOD_KEY := "drill_output_delta_for_cell"
const SOURCE_DRILL_PRODUCTION_RUNTIME_STATE_METHOD_KEY := "drill_production_runtime_state"

const SOURCE_DRILL_BLOCK_ITEM_CAPACITY_METHOD_FALLBACK := "source_block_item_capacity"
const SOURCE_DRILL_BLOCK_TIME_SCALE_AT_CELL_METHOD_FALLBACK := "source_block_time_scale_at_cell"
const SOURCE_DRILL_WARMUP_SPEED_METHOD_FALLBACK := "source_drill_warmup_speed"
const SOURCE_DRILL_WARMUP_STATE_METHOD_FALLBACK := "source_drill_warmup_state"
const SOURCE_DRILL_INACTIVE_WARMUP_STATE_METHOD_FALLBACK := "source_drill_inactive_warmup_state"
const SOURCE_DRILL_TIME_DRILLED_DELTA_METHOD_FALLBACK := "source_drill_time_drilled_delta"
const SOURCE_DRILL_LAST_SPEED_FOR_CELL_METHOD_FALLBACK := "source_drill_last_speed_for_cell"
const SOURCE_DRILL_DELAY_METHOD_FALLBACK := "source_drill_delay"
const SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_METHOD_FALLBACK := "source_drill_output_delta_for_cell"
const SOURCE_DRILL_PRODUCTION_RUNTIME_STATE_METHOD_FALLBACK := "source_drill_production_runtime_state"
const SOURCE_DRILL_APPROACH_DELTA_METHOD := "source_approach_delta"
const SOURCE_DRILL_BUILDING_DELTA_METHOD := "source_building_delta"
const SOURCE_DRILL_LAST_SPEED_METHOD := "source_drill_last_speed"
const SOURCE_DRILL_OUTPUT_DELTA_METHOD := "source_drill_output_delta"
const SOURCE_DRILL_ITEMS_TOTAL_METHOD := "drill_items_total"
const SOURCE_DRILL_WARMUP_AT_CELL_METHOD := "drill_warmup_at_cell"
const SOURCE_DRILL_TIME_DRILLED_AT_CELL_METHOD := "drill_time_drilled_at_cell"
const SOURCE_DRILL_LAST_SPEED_AT_CELL_METHOD := "drill_last_speed_at_cell"

const SOURCE_DRILL_CONTEXT_ACTIVE_KEY := "active"
const SOURCE_DRILL_CONTEXT_CELL_X_KEY := "cell_x"
const SOURCE_DRILL_CONTEXT_CELL_Y_KEY := "cell_y"
const SOURCE_DRILL_CONTEXT_BLOCK_ID_KEY := "block_id"
const SOURCE_DRILL_CONTEXT_ITEM_ID_KEY := "item_id"
const SOURCE_DRILL_CONTEXT_DOMINANT_ITEMS_KEY := "dominant_items"
const SOURCE_DRILL_CONTEXT_ITEMS_TOTAL_KEY := "items_total"
const SOURCE_DRILL_CONTEXT_ITEM_CAPACITY_KEY := "item_capacity"
const SOURCE_DRILL_CONTEXT_CURRENT_WARMUP_KEY := "current_warmup"
const SOURCE_DRILL_CONTEXT_CURRENT_TIME_DRILLED_KEY := "current_time_drilled"
const SOURCE_DRILL_CONTEXT_CURRENT_LAST_SPEED_KEY := "current_last_speed"
const SOURCE_DRILL_CONTEXT_CURRENT_PROGRESS_FRACTION_KEY := "current_progress_fraction"
const SOURCE_DRILL_CONTEXT_SECONDS_KEY := "seconds"
const SOURCE_DRILL_CONTEXT_SOURCE_DELTA_KEY := "source_delta"
const SOURCE_DRILL_CONTEXT_TIME_SCALE_KEY := "time_scale"
const SOURCE_DRILL_CONTEXT_SPEED_KEY := "speed"

const SOURCE_DRILL_RESULT_ACTIVE_KEY := "drill_active"
const SOURCE_DRILL_RESULT_WARMUP_BEFORE_KEY := "drill_warmup_before"
const SOURCE_DRILL_RESULT_WARMUP_KEY := "drill_warmup"
const SOURCE_DRILL_RESULT_LAST_SPEED_BEFORE_KEY := "drill_last_speed_before"
const SOURCE_DRILL_RESULT_LAST_SPEED_KEY := "drill_last_speed"
const SOURCE_DRILL_RESULT_TIME_DRILLED_BEFORE_KEY := "drill_time_drilled_before"
const SOURCE_DRILL_RESULT_TIME_DRILLED_DELTA_KEY := "drill_time_drilled_delta"
const SOURCE_DRILL_RESULT_TIME_DRILLED_KEY := "drill_time_drilled"
const SOURCE_DRILL_RESULT_DELAY_KEY := "drill_delay"
const SOURCE_DRILL_RESULT_OUTPUT_DELTA_KEY := "drill_output_delta"
const SOURCE_DRILL_RESULT_PRODUCTION_STATE_KEY := "production_state"
const SOURCE_DRILL_RESULT_SOURCE_OWNER_KEY := "source_owner"

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
	var delay_state := source_block_metadata_state.block_drill_delay_state(block_id, item_id, content_catalog)
	return (float(delay_state.get("drill_time", source_block_metadata_state.SOURCE_DRILL_DELAY_DRILL_TIME_DEFAULT)) + hardness_multiplier * float(delay_state.get("item_hardness", source_block_metadata_state.SOURCE_DRILL_DELAY_ITEM_HARDNESS_DEFAULT))) / float(delay_state.get("drill_multiplier", 1.0))

static func generated_get_drill_time_bridge_state(block_id: String, item_id: String, content_catalog, hardness_multiplier: float) -> Dictionary:
	var block = content_catalog.get_by_id(block_id) if content_catalog != null else null
	var item = content_catalog.get_by_id(item_id) if content_catalog != null else null
	if block == null or item == null:
		return {
			"source_owner": source_runtime_owner_registry.SOURCE_DRILL_RUNTIME_STATE_DRILL_DELAY,
			"generated_owner": "drill.java_method_getDrillTime_6",
			"result": {},
			"canonical": drill_delay(block_id, item_id, content_catalog, hardness_multiplier),
			"matches": false,
		}
	var delay_state := source_block_metadata_state.block_drill_delay_state(block_id, item_id, content_catalog)
	var drill_time := float(delay_state.get("drill_time", source_block_metadata_state.SOURCE_DRILL_DELAY_DRILL_TIME_DEFAULT))
	var item_hardness := float(delay_state.get("item_hardness", source_block_metadata_state.SOURCE_DRILL_DELAY_ITEM_HARDNESS_DEFAULT))
	var drill_multiplier := float(delay_state.get("drill_multiplier", 1.0))
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/production/Drill.gd", "java_method_getDrillTime_6", [drill_time, hardness_multiplier, item_hardness, drill_multiplier], null)
	var canonical := drill_delay(block_id, item_id, content_catalog, hardness_multiplier)
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_DRILL_RUNTIME_STATE_DRILL_DELAY,
		"generated_owner": "drill.java_method_getDrillTime_6",
		"result": result,
		"canonical": canonical,
		"matches": is_equal_approx(float(result.get("drillTime", 0.0)), canonical),
	}

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		SOURCE_DRILL_OCCUPIED_CELLS_CALLBACK_KEY: Callable(game, SOURCE_DRILL_OCCUPIED_CELLS_CALLBACK_KEY),
		SOURCE_DRILL_CELL_KEY_CALLBACK_KEY: Callable(game, SOURCE_DRILL_CELL_KEY_CALLBACK_KEY),
		SOURCE_DRILL_DELAY_CALLBACK_KEY: Callable(game, SOURCE_DRILL_DELAY_METHOD_FALLBACK),
		SOURCE_DRILL_APPROACH_DELTA_CALLBACK_KEY: Callable(game, SOURCE_DRILL_APPROACH_DELTA_METHOD),
		SOURCE_DRILL_BUILDING_DELTA_CALLBACK_KEY: Callable(game, SOURCE_DRILL_BUILDING_DELTA_METHOD),
	}

static func output_rate(block_id: String, item_id: String, return_count: int, source_tick_rate: float, drill_delay_fn: Callable) -> float:
	if return_count <= 0:
		return 0.0
	var delay := float(drill_delay_fn.call(block_id, item_id))
	if delay <= 0.0:
		return 0.0
	return source_tick_rate * float(return_count) / delay

static func game_output_rate(game: Object, block_id: String, item_id: String, return_count: int) -> float:
	var callbacks := default_callbacks_state(game)
	return output_rate(block_id, item_id, return_count, source_time_defaults.TICK_RATE, callbacks.get(SOURCE_DRILL_DELAY_CALLBACK_KEY, Callable()))

static func output_delta(dominant_items: int, seconds: float, time_scale: float, warmup: float, speed: float, source_tick_rate: float, building_delta_fn: Callable) -> float:
	var scaled_source_delta := float(building_delta_fn.call(seconds * source_tick_rate, time_scale))
	return scaled_source_delta * float(dominant_items) * speed * warmup

static func game_output_delta(game: Object, dominant_items: int, seconds: float, time_scale := 1.0, warmup := 1.0, speed := 1.0) -> float:
	var callbacks := default_callbacks_state(game)
	return output_delta(dominant_items, seconds, time_scale, warmup, speed, source_time_defaults.TICK_RATE, callbacks.get(SOURCE_DRILL_BUILDING_DELTA_CALLBACK_KEY, Callable()))

static func warmup_state(current_warmup: float, speed: float, warmup_speed: float, source_delta: float, approach_delta_fn: Callable) -> float:
	return float(approach_delta_fn.call(current_warmup, speed, warmup_speed, source_delta))

static func game_warmup_state(game: Object, current_warmup: float, speed: float, warmup_speed: float, source_delta: float) -> float:
	var callbacks := default_callbacks_state(game)
	return warmup_state(current_warmup, speed, warmup_speed, source_delta, callbacks.get(SOURCE_DRILL_APPROACH_DELTA_CALLBACK_KEY, Callable()))

static func inactive_warmup_state(current_warmup: float, warmup_speed: float, source_delta: float, approach_delta_fn: Callable) -> float:
	return float(approach_delta_fn.call(current_warmup, 0.0, warmup_speed, source_delta))

static func game_inactive_warmup_state(game: Object, current_warmup: float, warmup_speed: float, source_delta: float) -> float:
	var callbacks := default_callbacks_state(game)
	return inactive_warmup_state(current_warmup, warmup_speed, source_delta, callbacks.get(SOURCE_DRILL_APPROACH_DELTA_CALLBACK_KEY, Callable()))

static func time_drilled_delta(warmup: float, seconds: float, time_scale: float, source_tick_rate: float, building_delta_fn: Callable) -> float:
	return warmup * float(building_delta_fn.call(seconds * source_tick_rate, time_scale))

static func game_time_drilled_delta(game: Object, warmup: float, seconds: float, time_scale := 1.0) -> float:
	var callbacks := default_callbacks_state(game)
	return time_drilled_delta(warmup, seconds, time_scale, source_time_defaults.TICK_RATE, callbacks.get(SOURCE_DRILL_BUILDING_DELTA_CALLBACK_KEY, Callable()))

static func game_sprite_at_cell(game: Object, x: int, y: int):
	return source_texture_runtime_state.game_sprite_at_cell(game, x, y)

static func game_step_drill_warmup_cell(game: Object, x: int, y: int, seconds: float, speed := 1.0) -> float:
	var sprite = game_sprite_at_cell(game, x, y)
	if not is_instance_valid(sprite):
		return 0.0
	var key: String = str(game.cell_key(Vector2i(x, y)))
	var source_delta: float = seconds * game.source_time_defaults.TICK_RATE
	var warmup: float = game.source_drill_warmup_state(float(game.drill_warmups.get(key, 0.0)), speed, game.source_drill_warmup_speed(str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))), source_delta)
	game.drill_warmups[key] = warmup
	return warmup

static func game_step_drill_time_drilled_cell(game: Object, x: int, y: int, seconds: float, warmup: float) -> float:
	var sprite = game_sprite_at_cell(game, x, y)
	if not is_instance_valid(sprite):
		return 0.0
	var key: String = str(game.cell_key(Vector2i(x, y)))
	var value: float = float(game.drill_time_drilled.get(key, 0.0)) + game.source_drill_time_drilled_delta(warmup, seconds, float(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_TIME_SCALE_META_KEY, source_block_defaults.TIME_SCALE_DEFAULT)))
	game.drill_time_drilled[key] = value
	return value

static func game_last_speed_for_cell(game: Object, x: int, y: int, item_id: String, dominant_items: int, warmup: float, speed := 1.0) -> float:
	var sprite = game_sprite_at_cell(game, x, y)
	if not is_instance_valid(sprite):
		return 0.0
	return game.call(SOURCE_DRILL_LAST_SPEED_METHOD, str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, "")), item_id, dominant_items, warmup, speed)

static func game_output_delta_for_cell(game: Object, x: int, y: int, dominant_items: int, seconds: float, warmup := 1.0, speed := 1.0) -> float:
	var sprite = game_sprite_at_cell(game, x, y)
	if not is_instance_valid(sprite):
		return 0.0
	return game.call(SOURCE_DRILL_OUTPUT_DELTA_METHOD, dominant_items, seconds, float(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_TIME_SCALE_META_KEY, source_block_defaults.TIME_SCALE_DEFAULT)), warmup, speed)

@warning_ignore("shadowed_variable")
static func last_speed(block_id: String, item_id: String, ore_count: int, warmup: float, speed: float, drill_delay_fn: Callable) -> float:
	if ore_count <= 0:
		return 0.0
	var delay := float(drill_delay_fn.call(block_id, item_id))
	if delay <= 0.0:
		return 0.0
	return speed * float(ore_count) * warmup / delay

static func game_last_speed(game: Object, block_id: String, item_id: String, ore_count_value: int, warmup: float, speed := 1.0) -> float:
	var callbacks := default_callbacks_state(game)
	return last_speed(block_id, item_id, ore_count_value, warmup, speed, callbacks.get(SOURCE_DRILL_DELAY_CALLBACK_KEY, Callable()))

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

static func game_ore_count(game: Object, block_id: String, cell: Vector2i, item_id: String) -> int:
	var callbacks := default_callbacks_state(game)
	var content_catalog = game.get("content_catalog")
	var ore_items_value = game.get("ore_items_by_cell")
	var ore_items_by_cell: Dictionary = ore_items_value if ore_items_value is Dictionary else {}
	return ore_count(block_id, cell, item_id, content_catalog, ore_items_by_cell, callbacks.get(SOURCE_DRILL_OCCUPIED_CELLS_CALLBACK_KEY, Callable()), callbacks.get(SOURCE_DRILL_CELL_KEY_CALLBACK_KEY, Callable()))

static func runtime_context(game: Object, seconds: float, drill_cell: Vector2i, block_id: String, item_id: String, dominant_items: int, source_tick_rate: float, speed := 1.0) -> Dictionary:
	var method_names := source_factory_runtime_state.runtime_method_names(game)
	var block_item_capacity_method := source_factory_runtime_state.runtime_method_name(method_names, SOURCE_DRILL_BLOCK_ITEM_CAPACITY_METHOD_KEY, SOURCE_DRILL_BLOCK_ITEM_CAPACITY_METHOD_FALLBACK)
	var block_time_scale_method := source_factory_runtime_state.runtime_method_name(method_names, SOURCE_DRILL_BLOCK_TIME_SCALE_AT_CELL_METHOD_KEY, SOURCE_DRILL_BLOCK_TIME_SCALE_AT_CELL_METHOD_FALLBACK)
	var items_total_value: int = game.call(SOURCE_DRILL_ITEMS_TOTAL_METHOD)
	var item_capacity_value: int = game.call(block_item_capacity_method, block_id)
	var current_warmup_value: float = game.call(SOURCE_DRILL_WARMUP_AT_CELL_METHOD, drill_cell.x, drill_cell.y)
	var current_time_drilled_value: float = game.call(SOURCE_DRILL_TIME_DRILLED_AT_CELL_METHOD, drill_cell.x, drill_cell.y)
	var current_last_speed_value: float = game.call(SOURCE_DRILL_LAST_SPEED_AT_CELL_METHOD, drill_cell.x, drill_cell.y)
	var time_scale_value: float = game.call(block_time_scale_method, drill_cell.x, drill_cell.y)
	return {
		SOURCE_DRILL_CONTEXT_ACTIVE_KEY: float(game.get(source_world_initial_build_runtime_state_script.PROP_DRILL_OUTPUT_RATE)) > 0.0,
		SOURCE_DRILL_CONTEXT_CELL_X_KEY: drill_cell.x,
		SOURCE_DRILL_CONTEXT_CELL_Y_KEY: drill_cell.y,
		SOURCE_DRILL_CONTEXT_BLOCK_ID_KEY: block_id,
		SOURCE_DRILL_CONTEXT_ITEM_ID_KEY: item_id,
		SOURCE_DRILL_CONTEXT_DOMINANT_ITEMS_KEY: dominant_items,
		SOURCE_DRILL_CONTEXT_ITEMS_TOTAL_KEY: items_total_value,
		SOURCE_DRILL_CONTEXT_ITEM_CAPACITY_KEY: item_capacity_value,
		SOURCE_DRILL_CONTEXT_CURRENT_WARMUP_KEY: current_warmup_value,
		SOURCE_DRILL_CONTEXT_CURRENT_TIME_DRILLED_KEY: current_time_drilled_value,
		SOURCE_DRILL_CONTEXT_CURRENT_LAST_SPEED_KEY: current_last_speed_value,
		SOURCE_DRILL_CONTEXT_CURRENT_PROGRESS_FRACTION_KEY: float(game.get(source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_ITEM_PROGRESS_KEY)),
		SOURCE_DRILL_CONTEXT_SECONDS_KEY: seconds,
		SOURCE_DRILL_CONTEXT_SOURCE_DELTA_KEY: seconds * source_tick_rate,
		SOURCE_DRILL_CONTEXT_TIME_SCALE_KEY: time_scale_value,
		SOURCE_DRILL_CONTEXT_SPEED_KEY: speed,
	}

static func runtime_callbacks(game: Object) -> Dictionary:
	var method_names := source_factory_runtime_state.runtime_method_names(game)
	var warmup_speed_method := source_factory_runtime_state.runtime_method_name(method_names, SOURCE_DRILL_WARMUP_SPEED_METHOD_KEY, SOURCE_DRILL_WARMUP_SPEED_METHOD_FALLBACK)
	var warmup_state_method := source_factory_runtime_state.runtime_method_name(method_names, SOURCE_DRILL_WARMUP_STATE_METHOD_KEY, SOURCE_DRILL_WARMUP_STATE_METHOD_FALLBACK)
	var inactive_warmup_state_method := source_factory_runtime_state.runtime_method_name(method_names, SOURCE_DRILL_INACTIVE_WARMUP_STATE_METHOD_KEY, SOURCE_DRILL_INACTIVE_WARMUP_STATE_METHOD_FALLBACK)
	var time_drilled_delta_method := source_factory_runtime_state.runtime_method_name(method_names, SOURCE_DRILL_TIME_DRILLED_DELTA_METHOD_KEY, SOURCE_DRILL_TIME_DRILLED_DELTA_METHOD_FALLBACK)
	var last_speed_for_cell_method := source_factory_runtime_state.runtime_method_name(method_names, SOURCE_DRILL_LAST_SPEED_FOR_CELL_METHOD_KEY, SOURCE_DRILL_LAST_SPEED_FOR_CELL_METHOD_FALLBACK)
	var delay_method := source_factory_runtime_state.runtime_method_name(method_names, SOURCE_DRILL_DELAY_METHOD_KEY, SOURCE_DRILL_DELAY_METHOD_FALLBACK)
	var output_delta_for_cell_method := source_factory_runtime_state.runtime_method_name(method_names, SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_METHOD_KEY, SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_METHOD_FALLBACK)
	var production_state_method := source_factory_runtime_state.runtime_method_name(method_names, SOURCE_DRILL_PRODUCTION_RUNTIME_STATE_METHOD_KEY, SOURCE_DRILL_PRODUCTION_RUNTIME_STATE_METHOD_FALLBACK)
	return {
		SOURCE_DRILL_WARMUP_SPEED_CALLBACK_KEY: Callable(game, warmup_speed_method),
		SOURCE_DRILL_WARMUP_STATE_CALLBACK_KEY: Callable(game, warmup_state_method),
		SOURCE_DRILL_INACTIVE_WARMUP_STATE_CALLBACK_KEY: Callable(game, inactive_warmup_state_method),
		SOURCE_DRILL_TIME_DRILLED_DELTA_CALLBACK_KEY: Callable(game, time_drilled_delta_method),
		SOURCE_DRILL_LAST_SPEED_FOR_CELL_CALLBACK_KEY: Callable(game, last_speed_for_cell_method),
		SOURCE_DRILL_DELAY_CALLBACK_KEY: Callable(game, delay_method),
		SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_CALLBACK_KEY: Callable(game, output_delta_for_cell_method),
		SOURCE_DRILL_PRODUCTION_STATE_CALLBACK_KEY: Callable(game, production_state_method),
	}

static func runtime_state(drill_context: Dictionary, drill_callbacks: Dictionary) -> Dictionary:
	var active := bool(drill_context.get(SOURCE_DRILL_CONTEXT_ACTIVE_KEY, false))
	var cell_x := int(drill_context.get(SOURCE_DRILL_CONTEXT_CELL_X_KEY, 0))
	var cell_y := int(drill_context.get(SOURCE_DRILL_CONTEXT_CELL_Y_KEY, 0))
	var block_id := str(drill_context.get(SOURCE_DRILL_CONTEXT_BLOCK_ID_KEY, ""))
	var item_id := str(drill_context.get(SOURCE_DRILL_CONTEXT_ITEM_ID_KEY, ""))
	var dominant_items := int(drill_context.get(SOURCE_DRILL_CONTEXT_DOMINANT_ITEMS_KEY, 0))
	var items_total := int(drill_context.get(SOURCE_DRILL_CONTEXT_ITEMS_TOTAL_KEY, 0))
	var item_capacity := int(drill_context.get(SOURCE_DRILL_CONTEXT_ITEM_CAPACITY_KEY, 0))
	var current_warmup := float(drill_context.get(SOURCE_DRILL_CONTEXT_CURRENT_WARMUP_KEY, 0.0))
	var current_time_drilled := float(drill_context.get(SOURCE_DRILL_CONTEXT_CURRENT_TIME_DRILLED_KEY, 0.0))
	var current_last_speed := float(drill_context.get(SOURCE_DRILL_CONTEXT_CURRENT_LAST_SPEED_KEY, 0.0))
	var current_progress_fraction := float(drill_context.get(SOURCE_DRILL_CONTEXT_CURRENT_PROGRESS_FRACTION_KEY, 0.0))
	var seconds := float(drill_context.get(SOURCE_DRILL_CONTEXT_SECONDS_KEY, 0.0))
	var source_delta := float(drill_context.get(SOURCE_DRILL_CONTEXT_SOURCE_DELTA_KEY, 0.0))
	var time_scale := float(drill_context.get(SOURCE_DRILL_CONTEXT_TIME_SCALE_KEY, 1.0))
	var speed := float(drill_context.get(SOURCE_DRILL_CONTEXT_SPEED_KEY, 1.0))
	var warmup_speed_fn: Callable = drill_callbacks.get(SOURCE_DRILL_WARMUP_SPEED_CALLBACK_KEY, Callable())
	var warmup_state_fn: Callable = drill_callbacks.get(SOURCE_DRILL_WARMUP_STATE_CALLBACK_KEY, Callable())
	var inactive_warmup_state_fn: Callable = drill_callbacks.get(SOURCE_DRILL_INACTIVE_WARMUP_STATE_CALLBACK_KEY, Callable())
	var time_drilled_delta_fn: Callable = drill_callbacks.get(SOURCE_DRILL_TIME_DRILLED_DELTA_CALLBACK_KEY, Callable())
	var last_speed_for_cell_fn: Callable = drill_callbacks.get(SOURCE_DRILL_LAST_SPEED_FOR_CELL_CALLBACK_KEY, Callable())
	var delay_fn: Callable = drill_callbacks.get(SOURCE_DRILL_DELAY_CALLBACK_KEY, Callable())
	var output_delta_for_cell_fn: Callable = drill_callbacks.get(SOURCE_DRILL_OUTPUT_DELTA_FOR_CELL_CALLBACK_KEY, Callable())
	var production_state_fn: Callable = drill_callbacks.get(SOURCE_DRILL_PRODUCTION_STATE_CALLBACK_KEY, Callable())
	var warmup_speed := float(warmup_speed_fn.call(block_id))
	@warning_ignore("shadowed_variable")
	var time_drilled_delta := 0.0
	var drill_time_drilled := current_time_drilled
	var drill_last_speed := current_last_speed
	var drill_warmup := current_warmup
	@warning_ignore("shadowed_variable")
	var drill_delay := 0.0
	@warning_ignore("shadowed_variable")
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
		offload_amount = int(production_state.get(source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_OFFLOAD_AMOUNT_KEY, 0))
		produced_delta = int(production_state.get(source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_PRODUCED_DELTA_KEY, offload_amount))
		item_progress = float(production_state.get(source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_ITEM_PROGRESS_KEY, current_progress_fraction))
	else:
		var inactive_warmup := float(inactive_warmup_state_fn.call(current_warmup, warmup_speed, source_delta))
		drill_last_speed = 0.0
		drill_warmup = inactive_warmup
	return {
		SOURCE_DRILL_RESULT_ACTIVE_KEY: active,
		SOURCE_DRILL_RESULT_WARMUP_BEFORE_KEY: current_warmup,
		SOURCE_DRILL_RESULT_WARMUP_KEY: drill_warmup,
		SOURCE_DRILL_RESULT_LAST_SPEED_BEFORE_KEY: current_last_speed,
		SOURCE_DRILL_RESULT_LAST_SPEED_KEY: drill_last_speed,
		SOURCE_DRILL_RESULT_TIME_DRILLED_BEFORE_KEY: current_time_drilled,
		SOURCE_DRILL_RESULT_TIME_DRILLED_DELTA_KEY: time_drilled_delta,
		SOURCE_DRILL_RESULT_TIME_DRILLED_KEY: drill_time_drilled,
		SOURCE_DRILL_RESULT_DELAY_KEY: drill_delay,
		SOURCE_DRILL_RESULT_OUTPUT_DELTA_KEY: output_delta,
		SOURCE_DRILL_RESULT_PRODUCTION_STATE_KEY: production_state,
		source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_OFFLOAD_AMOUNT_KEY: offload_amount,
		source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_PRODUCED_DELTA_KEY: produced_delta,
		source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_ITEM_PROGRESS_KEY: item_progress,
		SOURCE_DRILL_RESULT_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_DRILL_RUNTIME_STATE,
	}
