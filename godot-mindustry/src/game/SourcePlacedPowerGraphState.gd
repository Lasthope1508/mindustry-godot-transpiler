extends RefCounted
class_name SourcePlacedPowerGraphState

const source_building_power_state := preload("res://src/game/SourceBuildingPowerState.gd")
const source_power_graph_state := preload("res://src/game/SourcePowerGraphState.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"block_from_sprite": source_texture_runtime_state.block_from_sprite_callback(game),
		"role_for_block": Callable(game, "power_graph_role_for_block"),
	}

static func game_role_counts_state(game: Object) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return role_counts_state(game.get("placed_block_origins"), callbacks.get("block_from_sprite", Callable()), callbacks.get("role_for_block", Callable()))

static func game_source_delta(_game: Object) -> float:
	return source_time_defaults.TICK_RATE

static func game_needed_state(game: Object) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return needed_state(game.get("placed_block_origins"), callbacks.get("block_from_sprite", Callable()), callbacks.get("role_for_block", Callable()), game_source_delta(game))

static func game_produced_state(game: Object) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return produced_state(game.get("placed_block_origins"), callbacks.get("block_from_sprite", Callable()), callbacks.get("role_for_block", Callable()), game_source_delta(game))

static func game_battery_state(game: Object) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return battery_state(game.get("placed_block_origins"), callbacks.get("block_from_sprite", Callable()), callbacks.get("role_for_block", Callable()))

static func game_runtime_state(game: Object) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return runtime_state(game.get("placed_block_origins"), callbacks.get("block_from_sprite", Callable()), callbacks.get("role_for_block", Callable()), game_source_delta(game))

static func source_group_buildings_by_origin_state(placed_block_origins: Dictionary) -> Dictionary:
	# PowerGraph.java:277-301 add(Building): each building is added
	# once to the graph (guarded by build.power.graph != this ||
	# !build.power.init), and to exactly one role list. The
	# placed-block origins map holds one key per footprint cell,
	# so a size-2 building has 4 keys for 1 building; grouping over
	# the unique origins (one per building) matches Java. The
	# origins are kept as Variants: the real game stores Vector2i
	# origins, and callers with sprite values (the module proof's
	# fake game) keep one entry per distinct sprite.
	var seen: Dictionary = {}
	var origins: Array = []
	for key in placed_block_origins.keys():
		var origin: Variant = placed_block_origins.get(key)
		if seen.has(origin):
			continue
		seen[origin] = true
		origins.append(origin)
	return {
		"origins": origins,
		"count": origins.size(),
	}

static func _group_state(placed_block_origins: Dictionary, block_from_sprite_fn: Callable, power_graph_role_for_block_fn: Callable, source_delta: float) -> Dictionary:
	var counts := {"all": 0, "producers": 0, "consumers": 0, "batteries": 0}
	var consumers: Array = []
	var producers: Array = []
	var batteries: Array = []
	for origin in source_group_buildings_by_origin_state(placed_block_origins).get("origins", []):
		var block = block_from_sprite_fn.call(origin)
		var role_state: Dictionary = power_graph_role_for_block_fn.call(block)
		if bool(role_state.get("add_all", false)):
			counts["all"] += 1
		if block == null:
			continue
		if bool(role_state.get("add_consumer", false)):
			consumers.append(source_building_power_state.block_consumer_state(block, source_delta))
			counts["consumers"] += 1
		if bool(role_state.get("add_producer", false)):
			producers.append(source_building_power_state.block_producer_state(block, source_delta))
			counts["producers"] += 1
		if bool(role_state.get("add_battery", false)):
			batteries.append(source_building_power_state.block_battery_state(block))
			counts["batteries"] += 1
	return {
		"counts": counts,
		"consumers": consumers,
		"producers": producers,
		"batteries": batteries,
	}

static func role_counts_state(placed_block_origins: Dictionary, block_from_sprite_fn: Callable, power_graph_role_for_block_fn: Callable) -> Dictionary:
	var grouped := _group_state(placed_block_origins, block_from_sprite_fn, power_graph_role_for_block_fn, 0.0)
	return grouped.get("counts", {"all": 0, "producers": 0, "consumers": 0, "batteries": 0})

static func needed_state(placed_block_origins: Dictionary, block_from_sprite_fn: Callable, power_graph_role_for_block_fn: Callable, source_delta: float) -> Dictionary:
	var grouped := _group_state(placed_block_origins, block_from_sprite_fn, power_graph_role_for_block_fn, source_delta)
	return source_power_graph_state.power_needed_state(grouped.get("consumers", []))

static func produced_state(placed_block_origins: Dictionary, block_from_sprite_fn: Callable, power_graph_role_for_block_fn: Callable, source_delta: float) -> Dictionary:
	var grouped := _group_state(placed_block_origins, block_from_sprite_fn, power_graph_role_for_block_fn, source_delta)
	return source_power_graph_state.power_produced_state(grouped.get("producers", []))

static func battery_state(placed_block_origins: Dictionary, block_from_sprite_fn: Callable, power_graph_role_for_block_fn: Callable) -> Dictionary:
	var grouped := _group_state(placed_block_origins, block_from_sprite_fn, power_graph_role_for_block_fn, 0.0)
	return source_power_graph_state.battery_state(grouped.get("batteries", []))

static func runtime_state(placed_block_origins: Dictionary, block_from_sprite_fn: Callable, power_graph_role_for_block_fn: Callable, source_delta: float) -> Dictionary:
	var grouped := _group_state(placed_block_origins, block_from_sprite_fn, power_graph_role_for_block_fn, source_delta)
	var roles: Dictionary = grouped.get("counts", {"all": 0, "producers": 0, "consumers": 0, "batteries": 0})
	var needed: Dictionary = source_power_graph_state.power_needed_state(grouped.get("consumers", []))
	var produced: Dictionary = source_power_graph_state.power_produced_state(grouped.get("producers", []))
	var battery: Dictionary = source_power_graph_state.battery_state(grouped.get("batteries", []))
	return {
		"roles": roles,
		"needed": needed,
		"produced": produced,
		"battery": battery,
		"producer_count": int(roles.get("producers", 0)),
		"consumer_count": int(roles.get("consumers", 0)),
		"battery_count": int(roles.get("batteries", 0)),
		"power_needed": float(needed.get("power_needed", 0.0)),
		"power_produced": float(produced.get("power_produced", 0.0)),
		"battery_stored": float(battery.get("stored", 0.0)),
		"battery_capacity": float(battery.get("capacity", 0.0)),
	}
