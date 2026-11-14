extends RefCounted
class_name SourcePlacedPowerGraphState

const source_building_power_state := preload("res://src/game/SourceBuildingPowerState.gd")
const source_power_graph_state := preload("res://src/game/SourcePowerGraphState.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const source_adjacent_factory_build_state := preload("res://src/game/SourceAdjacentFactoryBuildState.gd")
const source_unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")

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

const SOURCE_BATTERY_POWER_STATUS_META_KEY := "source_battery_power_status"

static func source_battery_power_status_for_cell_state(game: Object, cell: Vector2i) -> Dictionary:
	# PowerGraph.java:124 getBatteryStored reads battery.power.status
	# * capacity: the status is a field on the building that persists
	# across frames. The Godot port stores it on the battery sprite's
	# meta (the per-building persistent state, as the conveyor queue
	# is stored on the conveyor sprite). A sprite with no stored
	# status reads 0.0.
	var sprite: Variant = game.call("block_sprite_at_cell", cell)
	if sprite == null:
		return {"status": 0.0, "found": false, "reason": "no_sprite"}
	return {"status": float(sprite.get_meta(SOURCE_BATTERY_POWER_STATUS_META_KEY, 0.0)), "found": true, "reason": "stored"}

static func source_battery_set_power_status_for_cell_state(game: Object, cell: Vector2i, status: float) -> Dictionary:
	# PowerGraph.java:164 useBatteries multiplies battery.power.status;
	# :181 chargeBatteries adds to it. The live-loop step writes the
	# result back here so the next frame reads it.
	var sprite: Variant = game.call("block_sprite_at_cell", cell)
	if sprite == null:
		return {"stored": false, "reason": "no_sprite"}
	sprite.set_meta(SOURCE_BATTERY_POWER_STATUS_META_KEY, status)
	return {"stored": true, "reason": "stored"}

static func source_consumer_power_status_for_cell_state(game: Object, cell: Vector2i) -> Dictionary:
	# ConsumePower.java:39 `return build.power.status;` — the
	# canonical power.status read: the status is a field on the
	# building that persists across frames. The Godot port stores it
	# on the placed building's family frame (the battery pattern,
	# N2082/N2083: one frame per sprite, first of
	# SOURCE_CONSUMER_FRAME_META_KEYS present). A building with no
	# tick frame (conduit, core) and a cell with no sprite read the
	# field default (PowerModule.java:13, `public float status = 0.0f;`).
	var sprite: Variant = game.call("block_sprite_at_cell", cell)
	if sprite == null:
		return {"status": 0.0, "found": false, "reason": "no_sprite"}
	for meta_key in SOURCE_CONSUMER_FRAME_META_KEYS:
		if not sprite.has_meta(meta_key):
			continue
		var frame: Variant = sprite.get_meta(meta_key)
		if frame is Dictionary:
			return {"status": float(frame.get("power_status", 0.0)), "found": true, "reason": "live_frame"}
	return {"status": 0.0, "found": false, "reason": "no_frame"}

static func source_consumer_set_power_status_for_cell_state(game: Object, cell: Vector2i, status: float) -> Dictionary:
	# PowerGraph.java:203 `consumer.power.status = coverage;` — the
	# distributePower write-back: every tick the graph assigns each
	# consumer its computed status. The port stores it on the placed
	# building's family frame (first of
	# SOURCE_CONSUMER_FRAME_META_KEYS present; set_meta back after
	# mutating, the battery-write pattern), so the next frame — and
	# the factory driver running later in the same tick — reads the
	# live value instead of the null fold.
	var sprite: Variant = game.call("block_sprite_at_cell", cell)
	if sprite == null:
		return {"stored": false, "reason": "no_sprite"}
	for meta_key in SOURCE_CONSUMER_FRAME_META_KEYS:
		if not sprite.has_meta(meta_key):
			continue
		var frame: Variant = sprite.get_meta(meta_key)
		if frame is Dictionary:
			frame["power_status"] = status
			sprite.set_meta(meta_key, frame)
			return {"stored": true, "reason": "live_frame"}
	return {"stored": false, "reason": "no_frame"}

static func source_consumer_cheating_for_cell_state(game: Object, cell: Vector2i) -> Dictionary:
	# PowerGraph.java:217 update(): the cheat gate reads the first
	# consumer's cheating() — TeamComp.java:17-19 returns
	# team.rules().cheat — so a consumer dict only gates the graph
	# when it carries the building's live team value. The drill and
	# ContinuousLiquidTurret ticks refresh their frames from the live
	# rules (N2099/N2106), but the graph's consumer dicts are rebuilt
	# from the catalog every frame and never saw that value; this reads
	# it live from the placed building's team and the game's rules
	# (the same live-rules read the ticks use, through
	# source_game_rules_state + source_team_cheating_state), so every
	# power consumer — drill, lancer, duo, core, conduit — carries its
	# team's current cheat flag. A cell with no sprite has no building
	# and keeps the false default.
	var sprite: Variant = game.call("block_sprite_at_cell", cell)
	if sprite == null:
		return {"cheating": false, "team_id": source_block_geometry.SOURCE_TEAM_DERELICT_ID, "found": false, "reason": "no_sprite"}
	var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
	var rules: Dictionary = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
	var cheating: bool = bool(source_rules_state.source_team_cheating_state(rules, team_id).get("cheating", false))
	return {"cheating": cheating, "team_id": team_id, "found": true, "reason": "live_rules"}

# The per-family building-frame meta keys, in the order the
# should-consume read tries them (one frame per sprite: drill
# SourceDrillConsumptionRuntimeState.gd:15, turret
# SourceTurretBuildState.gd:30, factory SourceFactoryBuildState.gd:34,
# adjacent factory SourceAdjacentFactoryBuildState.gd:28, unit factory
# SourceUnitFactoryBuildState.gd:28, ContinuousLiquidTurret
# SourceContinuousLiquidTurretBuildState.gd:55).
const SOURCE_CONSUMER_FRAME_META_KEYS := ["source_drill_building", "source_turret_building", "source_factory_building", "source_adjacent_factory_building", "source_unit_factory_building", "source_continuous_liquid_turret_building", "source_solid_pump_building", "source_point_defense_turret_building", "source_tractor_beam_turret_building", "source_fracker_building", "source_mechanical_pump_building", "source_beam_drill_building", "source_mend_projector_building", "source_overdrive_projector_building", "source_force_projector_building", "source_base_shield_building", "source_regen_projector_building", "source_constructor_building", "source_payload_loader_building", "source_payload_unloader_building", "source_payload_mass_driver_building", "source_unit_cargo_loader_building", "source_payload_deconstructor_building", "source_unit_assembler_module_building", "source_separator_building", "source_wall_crafter_building"]

static func source_consumer_should_consume_for_cell_state(game: Object, cell: Vector2i) -> Dictionary:
	# ConsumePower.requestedPower (ConsumePower.java:60-63) charges an
	# unbuffered consumer `usage * (entity.shouldConsume() ? 1f : 0f)`,
	# and BuildingComp.shouldConsume() (BuildingComp.java:755-757) is
	# just `return enabled;` — while updateConsumption's disabled
	# branch (BuildingComp.java:1952-1956) clears shouldConsumePower
	# outright. The graph's consumer dicts are rebuilt from the
	# catalog every frame (SourceBuildingPowerState.block_consumer_state
	# sets both keys from static has_power/consumes_power), so a
	# disabled lancer kept charging its full 6.0/60; this reads the
	# placed building's live frame `enabled` flag instead, so both
	# keys follow the frame. A building with no tick frame (conduit,
	# core) and a cell with no sprite keep the true default — the
	# static behavior, since their usage is 0 either way.
	# The factory families read further than `enabled`: a
	# GenericCrafter's shouldConsume() is the output-full gate
	# (GenericCrafter.java:203-231, an output item whose held stack
	# plus one output would exceed itemCapacity, or every output
	# liquid full at liquidCapacity - 0.001f, stops consumption),
	# and the adjacent family's is its own body
	# (Separator.java:99-108 counts held items minus consume inputs
	# against itemCapacity, WallCrafter.java:246-248, BlockProducer.
	# java:108-110, else the Building default), so the stamp calls
	# the family's per-class shouldConsume for `should_consume` —
	# that is the `entity.shouldConsume()` factor
	# ConsumePower.requestedPower reads. `shouldConsumePower` is the
	# live updateConsumption first-pass flag the tick stamps on the
	# frame (BuildingComp.java:1971-1974: a non-power consumer whose
	# efficiency is at most 0.0000001f clears it — a starved factory
	# stops drawing power even while its outputs have room); before
	# the first tick the frame carries no such key and the flag falls
	# back to `enabled`. The unit-factory family reads its per-class
	# shouldConsume live (N2136, the branch below): a plan-less
	# ground factory, a payload-less reconstructor, or a blocks-less
	# assembler reads `should_consume == false` from the graph. The
	# other families keep the enabled-only read because their
	# shouldConsume IS the Building default (`return enabled;`,
	# BuildingComp.java:755-757).
	if game == null:
		return {"should_consume": true, "shouldConsumePower": true, "found": false, "reason": "no_game"}
	var sprite: Variant = game.call("block_sprite_at_cell", cell)
	if sprite == null:
		return {"should_consume": true, "shouldConsumePower": true, "found": false, "reason": "no_sprite"}
	for meta_key in SOURCE_CONSUMER_FRAME_META_KEYS:
		if not sprite.has_meta(meta_key):
			continue
		var frame: Variant = sprite.get_meta(meta_key)
		if frame is Dictionary:
			var enabled: bool = bool(frame.get("enabled", true))
			if meta_key == source_factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY:
				var block: Variant = default_callbacks_state(game).get("block_from_sprite", Callable()).call(sprite)
				var liquids: Dictionary = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
				var liquid_ids: Dictionary = {}
				var catalog: Variant = game.get("content_catalog")
				if catalog != null:
					liquid_ids = source_content_registry_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {})
				var should: Dictionary = source_factory_build_state.source_factory_should_consume_state(frame, block, liquids, liquid_ids)
				return {"should_consume": bool(should.get("should_consume", enabled)), "shouldConsumePower": bool(frame.get("should_consume_power", enabled)), "found": true, "reason": "live_frame"}
			if meta_key == source_adjacent_factory_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY:
				var block: Variant = default_callbacks_state(game).get("block_from_sprite", Callable()).call(sprite)
				var should: Dictionary = source_adjacent_factory_build_state.source_adjacent_factory_should_consume_state(frame, block)
				return {"should_consume": bool(should.get("should_consume", enabled)), "shouldConsumePower": bool(frame.get("should_consume_power", enabled)), "found": true, "reason": "live_frame"}
			if meta_key == source_unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY:
				var block: Variant = default_callbacks_state(game).get("block_from_sprite", Callable()).call(sprite)
				var should: Dictionary = source_unit_factory_build_state.source_unit_factory_should_consume_state(frame, block, game)
				return {"should_consume": bool(should.get("should_consume", enabled)), "shouldConsumePower": bool(frame.get("should_consume_power", enabled)), "found": true, "reason": "live_frame"}
			return {"should_consume": enabled, "shouldConsumePower": enabled, "found": true, "reason": "live_frame"}
	return {"should_consume": true, "shouldConsumePower": true, "found": false, "reason": "no_frame"}

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
			var consumer_state := source_building_power_state.block_consumer_state(block, source_delta)
			consumer_state["origin_cell"] = origin
			consumers.append(consumer_state)
			counts["consumers"] += 1
		if bool(role_state.get("add_producer", false)):
			producers.append(source_building_power_state.block_producer_state(block, source_delta))
			counts["producers"] += 1
		if bool(role_state.get("add_battery", false)):
			var battery_state := source_building_power_state.block_battery_state(block)
			battery_state["origin_cell"] = origin
			batteries.append(battery_state)
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
	# N2134: stamp the grouped batteries with the live
	# Building.enabled before the graph reads them, so a disabled
	# battery drops out of stored/capacity/use/charge on this tick
	# (PowerGraph.java:123, 135, 147, 163, 180).
	var stamped: Dictionary = source_building_power_state.source_building_power_battery_enabled_stamp_state({"batteries": grouped.get("batteries", [])})
	var battery: Dictionary = source_power_graph_state.battery_state(stamped.get("batteries", []))
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
