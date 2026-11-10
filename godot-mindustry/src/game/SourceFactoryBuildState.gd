extends RefCounted
class_name SourceFactoryBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_item_state := preload("res://src/game/SourceConsumeItemsState.gd")
const source_consume_liquid_state := preload("res://src/game/SourceConsumeLiquidState.gd")
const source_consume_state := preload("res://src/game/SourceConsumeState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
const source_conveyor_runtime_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
const source_content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

# Every block whose build is a GenericCrafterBuild: the class itself
# (GenericCrafter.java:23 `public class GenericCrafter extends
# Block{`) and the three that extend it (AttributeCrafter extends
# GenericCrafter, AttributeCrafter.java:11; HeatCrafter extends
# GenericCrafter, HeatCrafter.java:11; HeatProducer extends
# GenericCrafter, HeatProducer.java:12). AttributeCrafterBuild does
# not override updateTile, and HeatCrafterBuild/HeatProducerBuild call
# super.updateTile() first (HeatCrafter.java:48-51,
# HeatProducer.java:46-47), so GenericCrafterBuild.updateTile()
# (GenericCrafter.java:235) is the tick for all of them. The other
# production blocks are NOT here: Separator, Incinerator and
# WallCrafter extend Block directly, SingleBlockProducer extends
# BlockProducer, and the drills/pumps have their own drivers.
const SOURCE_FACTORY_BUILD_IMPLEMENTATIONS := ["GenericCrafter", "AttributeCrafter", "HeatCrafter", "HeatProducer"]
const SOURCE_FACTORY_BUILDING_META_KEY := "source_factory_building"

static func _is_factory_build_implementation(implementation: String) -> bool:
	return SOURCE_FACTORY_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_factory_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The factory tick wires the frame keys the consumption path reads
	# (the N2108 turret pattern): block_implementation is the block's
	# implementation (GenericCrafter.java:23, `public class
	# GenericCrafter extends Block{`), team_id and rules_state are what
	# Java reads as b.team and state.rules, and cheating is the team's
	# live TeamRule value (TeamComp.cheating(), TeamComp.java:17-19
	# `return team.rules().cheat;`, read through N2099's helper), so a
	# cheating team's factory counts everything as valid like Java's
	# updateConsumption (BuildingComp.java:1944-1945, "everything is
	# valid when cheating", `if(!block.hasConsumers || cheating()){`).
	# A team with no rule keeps the false default (Rules.java:328
	# TeamRule.cheat, default false).
	frame["block_implementation"] = block_implementation
	frame["team_id"] = team_id
	frame["rules_state"] = rules_state
	frame["cheating"] = bool(source_rules_state.source_team_cheating_state(rules_state, team_id).get("cheating", false))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_factory_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement through the Tile.setBlock proximity path (the same
	# path that binds the drill, ContinuousLiquidTurret and turret
	# frames). A factory-family sprite gets an empty frame bound; the
	# live-loop tick fills its keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_factory_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_FACTORY_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_FACTORY_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_FACTORY_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_bind_consumer_state(frame: Dictionary, block: Object, catalog: Object, amounts: Dictionary) -> Dictionary:
	# The block's consumeBuilder carries one ConsumeItems row per
	# consumeItem stack and one ConsumeLiquid row per consumeLiquid
	# call (Block.java:1127-1131, 1167-1177); the port binds one
	# RuntimeConsumer actor per row (the drill model, N2097/N2100),
	# item rows through SourceConsumeItemsState and liquid rows
	# through SourceConsumeLiquidState, each paying through the N2097
	# cost-multiplier callback (1.0 for a GenericCrafter-family
	# block). Actors are bound once — a frame that already carries
	# them binds nothing — and a block without consume rows binds
	# none. amounts is the building's liquid module (the turret's
	# shape); the item actors read the frame's item module
	# (frame["items"], the Building.items ItemModule), created empty
	# when the frame has none yet. A bound frame records the block
	# its actors belong to (frame["block_id"]), so the live-loop
	# tick can tell a replaced building from the one its actors
	# were bound for (N2116, Tile.changeBuild).
	var rows: Array = []
	if block != null and block.properties.has("consumeItem"):
		rows.append_array(source_consume_item_state.source_bind_item_consumers_state(block, catalog).get("consumers", []))
	if block != null and block.properties.has("consumeLiquid"):
		rows.append_array(source_consume_liquid_state.source_bind_liquid_consumers_state(block, catalog).get("consumers", []))
	if not frame.has("items"):
		frame["items"] = {}
	var items: Dictionary = frame["items"]
	var consumers: Array = frame.get("consumers", [])
	var bound := false
	# The bound rows live on the frame with the actors (the craft
	# slice reads them back at craft() time, N2117): a frame that
	# already carries actors still gets its rows refreshed from
	# the block, so the craft trigger always runs the block's own
	# rows.
	frame["rows"] = rows
	if consumers.is_empty() and not rows.is_empty():
		for row in rows:
			if row.has("liquid"):
				consumers.append(source_consume_liquid_state.source_runtime_consumer_state(row, amounts, [], source_consume_state.source_cost_multiplier_for_block_state).get("consumer"))
			else:
				consumers.append(source_consume_item_state.source_runtime_consumer_state(row, items, source_consume_state.source_cost_multiplier_for_block_state).get("consumer"))
		frame["consumers"] = consumers
		frame["block_id"] = str(block.id)
		bound = true
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_BIND_CONSUMER_STATE, "bound": bound, "consumers": consumers, "rows": rows}

static func source_factory_reinitialize_consumers_state(frame: Dictionary, block: Object, catalog: Object, amounts: Dictionary) -> Dictionary:
	# Tile.changeBuild (Tile.java:636-657) removes the old Building
	# (`build.remove()`) and inits a brand-new one
	# (`entityprov.get().init(...)`, Block.newBuilding(),
	# Block.java:1002), so a replaced building gets fresh consumers
	# from Block.reinitializeConsumers() (Block.java:1481-1497: the
	# consumeBuilder is re-read, the optional / non-optional /
	# update arrays are rebuilt, and each consumer is applied
	# again). The port reuses the sprite node when the same sprite
	# is re-recorded with a different block (initialize_sprite
	# overwrites the block-id meta but keeps the family frame), so
	# without this the tick keeps running the old block's actors
	# against the new block's rows — and indexes past the end of
	# the actor list when the new block has more rows. The tick
	# therefore reinitializes through here instead of binding
	# directly: a frame already on this block takes the normal
	# once-only bind path; a frame stamped for another block drops
	# its old RuntimeConsumer actors (N2100's invalidate, the
	# cache-invalidation half of reinitializeConsumers), clears its
	# item and liquid stores for the fresh Building's own empty
	# ItemModule/LiquidModule (BuildingComp.java:145-146, init
	# creates a fresh ItemModule/LiquidModule per Building), and
	# rebinds from the new
	# block's consumeBuilder, stamping the new block id. A null
	# block reinitializes nothing.
	if block == null:
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_REINITIALIZE_CONSUMERS_STATE, "reinitialized": false, "bound": false, "consumers": frame.get("consumers", []), "rows": []}
	var block_id: String = str(block.id)
	var stamped: String = str(frame.get("block_id", ""))
	if stamped == block_id:
		var bound: Dictionary = source_bind_consumer_state(frame, block, catalog, amounts)
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_REINITIALIZE_CONSUMERS_STATE, "reinitialized": false, "bound": bool(bound.get("bound", false)), "consumers": bound.get("consumers", []), "rows": bound.get("rows", [])}
	if stamped != "":
		source_consume_liquid_state.source_invalidate_consumer_cache_state(block, frame)
		frame["items"] = {}
		amounts.clear()
	var rebound: Dictionary = source_bind_consumer_state(frame, block, catalog, amounts)
	frame["block_id"] = block_id
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_REINITIALIZE_CONSUMERS_STATE, "reinitialized": stamped != "", "bound": bool(rebound.get("bound", false)), "consumers": rebound.get("consumers", []), "rows": rebound.get("rows", [])}

static func _liquid_amount_state(liquids: Dictionary, liquid_id: int) -> float:
	# LiquidModule.get(Liquid) (LiquidModule.java:102) over the
	# port's liquid module: amounts live in the id-indexed array
	# under "liquids" (LiquidModule.java:23 `private float[]
	# liquids = new float[content.liquids().size];`); a bare
	# id->amount map (the direct-call shape) reads straight
	# through. An unknown id holds nothing.
	if liquids.has("liquids") and liquids["liquids"] is Array:
		var amounts: Array = liquids["liquids"]
		if liquid_id >= 0 and liquid_id < amounts.size():
			return float(amounts[liquid_id])
		return 0.0
	return float(liquids.get(liquid_id, 0.0))

static func source_factory_should_consume_state(frame: Dictionary, block: Object, liquids: Dictionary, liquid_ids: Dictionary) -> Dictionary:
	# GenericCrafterBuild.shouldConsume() (GenericCrafter.java:203-231):
	# an output item blocks when the held stack plus one output would
	# exceed itemCapacity (`if(items.get(output.item) + output.amount
	# > itemCapacity){`, GenericCrafter.java:205); an output liquid
	# blocks when the held amount reaches liquidCapacity - 0.001f
	# and the block does not dump the extra (`if(liquids.get(
	# output.liquid) >= liquidCapacity - 0.001f){`,
	# GenericCrafter.java:216, `if(!dumpExtraLiquid){`,
	# GenericCrafter.java:217), unless ignoreLiquidFullness skips
	# the liquid check entirely (GenericCrafter.java:212); when
	# every output liquid is full the block cannot reproduce
	# either (`if(allFull){`, GenericCrafter.java:226). Otherwise
	# the build consumes when enabled (`return enabled;`,
	# GenericCrafter.java:230). The registry captures the block's
	# outputItems/outputLiquids (the singular outputItem/
	# outputLiquid written to the plural arrays by
	# GenericCrafter.init(), GenericCrafter.java:120-124) and its
	# liquidCapacity (the initializer's own assignment, else
	# Block.init()'s round(10 * consumeAmount) default,
	# Block.java:1407-1418 — 10.0 when the block consumes no
	# liquid); itemCapacity is the block's own (Block.java:75,
	# default 10); dumpExtraLiquid defaults true and
	# ignoreLiquidFullness false (GenericCrafter.java:37-38).
	# Owner: PORT_GAME_SOURCE_FACTORY_BUILD_SHOULD_CONSUME_STATE.
	var enabled: bool = bool(frame.get("enabled", true))
	var item_blocked := false
	var liquid_blocked := false
	var all_liquids_full := false
	if block == null:
		return {"should_consume": enabled, "item_blocked": item_blocked, "liquid_blocked": liquid_blocked, "all_liquids_full": all_liquids_full}
	var properties: Dictionary = block.properties
	var items: Dictionary = frame.get("items", {})
	var item_capacity: int = int(properties.get("itemCapacity", 10))
	for output in properties.get("outputItems", []):
		if int(items.get(str(output.get("item", "")), 0)) + int(output.get("amount", 0)) > item_capacity:
			item_blocked = true
			break
	var liquid_capacity: float = float(properties.get("liquidCapacity", 10.0))
	var ignore_liquid_fullness: bool = bool(properties.get("ignoreLiquidFullness", false))
	var dump_extra_liquid: bool = bool(properties.get("dumpExtraLiquid", true))
	var output_liquids: Array = properties.get("outputLiquids", [])
	if not output_liquids.is_empty() and not ignore_liquid_fullness:
		var all_full := true
		for output in output_liquids:
			var liquid_id: int = int(liquid_ids.get(str(output.get("liquid", "")), -1))
			var held: float = _liquid_amount_state(liquids, liquid_id)
			if held >= liquid_capacity - 0.001:
				if not dump_extra_liquid:
					liquid_blocked = true
			else:
				all_full = false
		all_liquids_full = all_full
		if all_liquids_full:
			liquid_blocked = true
	return {
		"should_consume": enabled and not item_blocked and not liquid_blocked,
		"item_blocked": item_blocked,
		"liquid_blocked": liquid_blocked,
		"all_liquids_full": all_liquids_full,
	}

static func source_factory_update_consumption_state(frame: Dictionary, has_consumers: bool, enabled: bool, production_valid: bool, should_consume: bool, efficiency_scale: float) -> Dictionary:
	# BuildingComp.updateConsumption() (BuildingComp.java:1943-1951):
	# when cheating, everything is valid and consumption is skipped
	# (`if(!block.hasConsumers || cheating()){`, the early return
	# sets potentialEfficiency from enabled and productionValid and
	# efficiency from shouldConsume, with no consumer updated). The
	# shared efficiency machinery already implements that method, so
	# this adapter runs it with the frame's live cheating flag and
	# the bound actors (N2112 binds them; a block with no consume
	# rows still runs the empty list): a cheating factory takes the
	# early return and pays nothing, while a non-cheating one runs
	# the machinery over its bound actors. skipped_consumption is the
	# Java early-return condition itself. The frame's cheating flag
	# is wired live by the N2110 tick, and the tick itself runs after
	# updateConsumption through Building.update()
	# (BuildingComp.java:2262-2274), so this adapter is the
	# consumption half of GenericCrafterBuild.updateTile()
	# (GenericCrafter.java:235).
	var cheating := bool(frame.get("cheating", false))
	var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(has_consumers, cheating, enabled, production_valid, should_consume, efficiency_scale, [], [], [], frame)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_UPDATE_CONSUMPTION_STATE,
		"cheating": cheating,
		"skipped_consumption": bool(not has_consumers or cheating),
		"potential_efficiency": float(consumption.get("potential_efficiency", 0.0)),
		"efficiency": float(consumption.get("efficiency", 0.0)),
		"optional_efficiency": float(consumption.get("optional_efficiency", 0.0)),
		"should_consume_power": bool(consumption.get("should_consume_power", false)),
	}

static func source_factory_progress_increase_state(craft_time: float, efficiency: float, seconds: float, time_scale: float) -> Dictionary:
	# BuildingComp.getProgressIncrease (BuildingComp.java:1203-1205):
	# `return 1f / baseTime * edelta();` with edelta() = efficiency *
	# delta() (BuildingComp.java:1927-1929) and delta() = Time.delta *
	# timeScale (BuildingComp.java:1922-1924). The port's frame delta
	# is in seconds and the port's edelta convention (the bound
	# actors' source_delta, N2112) is seconds * TICK_RATE, so edelta
	# here is seconds * TICK_RATE * time_scale * efficiency. A zero
	# or negative craft time never advances (no GenericCrafter sets
	# one; the class default is 80, GenericCrafter.java:40).
	var edelta := float(seconds) * float(source_time_defaults.TICK_RATE) * float(time_scale) * float(efficiency)
	var increase := 0.0
	if craft_time > 0.0:
		increase = edelta / float(craft_time)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_PROGRESS_INCREASE_STATE,
		"progress_increase": increase,
		"edelta": edelta,
	}

static func _crafter_progress_increase_with_base_time(block: Object, liquids: Dictionary, liquid_ids: Dictionary, efficiency: float, seconds: float, time_scale: float, base_time: float) -> Dictionary:
	# The GenericCrafterBuild.getProgressIncrease override
	# (GenericCrafter.java:266-285) over an explicit base time: the
	# public form passes craftTime (GenericCrafter.java:237
	# `progress += getProgressIncrease(craftTime);`), the liquid
	# output half passes 1f (GenericCrafter.java:242 `float inc =
	# getProgressIncrease(1f);`). ignoreLiquidFullness returns the
	# base increase; otherwise each output liquid scales by
	# (liquidCapacity - held) / (amount * edelta()), taking the
	# minimum as `scaling` and the maximum as `max`, and the base
	# increase is then multiplied by min(max, 1f) when
	# dumpExtraLiquid, else by scaling. A block with no output
	# liquids takes the base increase unchanged. The tick only calls
	# this while efficiency > 0, so edelta is positive here; a zero
	# edelta still yields no progress rather than dividing by zero.
	var base: Dictionary = source_factory_progress_increase_state(base_time, efficiency, seconds, time_scale)
	var edelta := float(base.get("edelta", 0.0))
	var scaling := 1.0
	if block != null and not bool(block.properties.get("ignoreLiquidFullness", false)):
		var output_liquids: Array = block.properties.get("outputLiquids", [])
		if not output_liquids.is_empty():
			var liquid_capacity := float(block.properties.get("liquidCapacity", 10.0))
			var min_scaling := 1.0
			var max_value := 0.0
			for output in output_liquids:
				var liquid_id: int = int(liquid_ids.get(str(output.get("liquid", "")), -1))
				var held: float = _liquid_amount_state(liquids, liquid_id)
				var value := 0.0
				if edelta > 0.0:
					value = (liquid_capacity - held) / (float(output.get("amount", 0.0)) * edelta)
				min_scaling = minf(min_scaling, value)
				max_value = maxf(max_value, value)
			if bool(block.properties.get("dumpExtraLiquid", true)):
				scaling = minf(max_value, 1.0)
			else:
				scaling = min_scaling
	return {
		"progress_increase": float(base.get("progress_increase", 0.0)) * scaling,
		"scaling": scaling,
		"edelta": edelta,
	}

static func source_factory_crafter_progress_increase_state(block: Object, liquids: Dictionary, liquid_ids: Dictionary, efficiency: float, seconds: float, time_scale: float) -> Dictionary:
	# GenericCrafterBuild.getProgressIncrease override
	# (GenericCrafter.java:266-285) at the block's craftTime: the
	# tick's progress step (GenericCrafter.java:237). craftTime is
	# the registry value, else the class default 80
	# (GenericCrafter.java:40).
	var craft_time := 80.0
	if block != null:
		craft_time = float(block.properties.get("craftTime", 80.0))
	var increased: Dictionary = _crafter_progress_increase_with_base_time(block, liquids, liquid_ids, efficiency, seconds, time_scale, craft_time)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_CRAFTER_PROGRESS_INCREASE_STATE,
		"progress_increase": float(increased.get("progress_increase", 0.0)),
		"scaling": float(increased.get("scaling", 1.0)),
		"edelta": float(increased.get("edelta", 0.0)),
	}

static func source_factory_consume_state(frame: Dictionary, consumers: Array, rows: Array) -> Dictionary:
	# BuildingComp.consume() (BuildingComp.java:1911-1915): triggers
	# every consumer (`for(Consume cons : block.consumers){
	# cons.trigger(self()); }`). Consume.trigger is empty by default
	# (Consume.java:50 `public void trigger(Building build){}`),
	# ConsumeLiquid has no trigger override (its update drains per
	# tick, N2112) and ConsumePower has none either, so only the item
	# rows remove anything, through the RuntimeConsumer trigger
	# (ConsumeItems.java:45-48, Math.round removal clamped at what
	# the module holds). Liquid rows are skipped, not triggered:
	# triggering a liquid actor would invent a removal Java never
	# performs. The frame is the build dict the actors read (their
	# items reference is the frame's own item module).
	var triggered := 0
	var removed := {}
	var items: Dictionary = frame.get("items", {})
	for index in range(rows.size()):
		if index >= consumers.size():
			continue
		var row = rows[index]
		if row is Dictionary and row.has("liquid"):
			continue
		var actor = consumers[index]
		if actor == null or not actor.has_method("trigger"):
			continue
		var item_name := ""
		if row is Dictionary:
			item_name = str(row.get("item", ""))
		var before := int(items.get(item_name, 0))
		actor.trigger(frame)
		removed[item_name] = before - int(items.get(item_name, 0))
		triggered += 1
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_CONSUME_STATE,
		"triggered": triggered,
		"removed": removed,
	}

static func source_factory_offload_state(game: Object, frame: Dictionary, cell: Vector2i, block: Object, item: String) -> Dictionary:
	# BuildingComp.offload (BuildingComp.java:1000-1016):
	# produced(item, 1) is sector accounting only
	# (Vars.state.rules.sector, null in the port's scenario, so
	# nothing is recorded); the item is then offered to each
	# proximity building in cdump order — acceptItem(self(), item)
	# && canDump(other, item) -> handleItem — and kept in the
	# building's own inventory when no neighbor takes it
	# (handleItem(self(), item)). The port reuses the accepted drill
	# dump composition
	# (SourceBuildingItemDumpState.source_drill_dump_step_state, the
	# dump(todump) body, BuildingComp.java:1071+): the produced item
	# is a synthetic one-item inventory, so a dump is the offload
	# and a refusal leaves the one item, which this step then adds
	# to the frame's own items. Only the receiving belt's queue is
	# written back (the N2068 rule); a core neighbor is not a dump
	# receiver in this composition — the belt carries the item to
	# the core (N2070) — so a factory with no belt neighbor keeps
	# its output until the dumpOutputs slice lands.
	var empty := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_OFFLOAD_STATE,
		"placed": false,
		"destination": "none",
		"receiver_cell": null,
		"cdump_after": int(frame.get("cdump", 0)),
		"items_after": frame.get("items", {}),
	}
	if game == null or block == null:
		return empty
	var size := int(block.properties.get("size", 1))
	var cdump := int(frame.get("cdump", 0))
	var ring := source_block_geometry.source_block_proximity_cells_state(size, cell.x, cell.y)
	var ring_cells: Array = ring.get("cells", [])
	var queues := source_conveyor_runtime_state.source_conveyor_queues_for_cells_state(game, ring_cells)
	var queues_by_cell: Dictionary = queues.get("queues_by_cell", {})
	var rotations := {}
	for ring_cell in queues_by_cell.keys():
		var conveyor_sprite: Variant = game.call("block_sprite_at_cell", ring_cell)
		if conveyor_sprite != null:
			rotations[ring_cell] = int(conveyor_sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))
	var produced := {item: 1}
	var result: Dictionary = source_building_item_dump_state.source_drill_dump_step_state(produced, ring_cells, item, cdump, true, queues_by_cell, 3, 0.4, rotations, false, false, cell, size)
	var queues_after: Dictionary = result.get("queues_after", {})
	if bool(result.get("dumped", false)):
		var receiver_cell: Variant = result.get("receiver_cell")
		if receiver_cell is Vector2i and queues_after.has(receiver_cell):
			source_conveyor_runtime_state.source_conveyor_set_queue_for_cell_state(game, receiver_cell, queues_after[receiver_cell])
	var items_after: Dictionary = frame.get("items", {})
	if not bool(result.get("dumped", false)):
		items_after[item] = int(items_after.get(item, 0)) + 1
	frame["items"] = items_after
	frame["cdump"] = int(result.get("cdump_after", cdump))
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_OFFLOAD_STATE,
		"placed": bool(result.get("dumped", false)),
		"destination": str(result.get("destination", "none")),
		"receiver_cell": result.get("receiver_cell"),
		"cdump_after": int(result.get("cdump_after", cdump)),
		"items_after": items_after,
	}

static func source_factory_craft_state(game: Object, frame: Dictionary, cell: Vector2i, block: Object) -> Dictionary:
	# GenericCrafterBuild.craft() (GenericCrafter.java:301-315):
	# consume(); each output item is offloaded once per amount
	# (`for(var output : outputItems){ for(int i = 0; i <
	# output.amount; i++){ offload(output.item); } }`); craftEffect
	# is visual and deferred; progress %= 1f. A null block crafts
	# nothing. The consumers and rows are the frame's own bound
	# actors and rows (N2112 binds them, N2116 reinitializes them),
	# so craft needs no separate actor list. The continuous liquid
	# output half of updateTile (GenericCrafter.java:241-246,
	# handleLiquid per tick) is wired by N2118's
	# source_factory_liquid_output_state, called from the tick
	# driver before the craft check.
	if block == null:
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_CRAFT_STATE,
			"crafted": false,
			"consumed": {"triggered": 0, "removed": {}},
			"offloaded": [],
			"progress_after": float(frame.get("progress", 0.0)),
		}
	var consumed: Dictionary = source_factory_consume_state(frame, frame.get("consumers", []), frame.get("rows", []))
	var offloaded: Array = []
	for output in block.properties.get("outputItems", []):
		var output_item := str(output.get("item", ""))
		for _index in range(int(output.get("amount", 0))):
			offloaded.append(source_factory_offload_state(game, frame, cell, block, output_item))
	frame["progress"] = fmod(float(frame.get("progress", 0.0)), 1.0)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_CRAFT_STATE,
		"crafted": true,
		"consumed": consumed,
		"offloaded": offloaded,
		"progress_after": float(frame.get("progress", 0.0)),
	}

static func source_factory_warmup_target_state(block: Object) -> Dictionary:
	# GenericCrafterBuild.warmupTarget() (GenericCrafter.java:287-289)
	# returns 1f. HeatCrafterBuild overrides it with
	# Mathf.clamp(heat / heatRequirement) (HeatCrafter.java:70-72) —
	# deferred: the frame carries no heat state yet, so a heat
	# crafter takes the GenericCrafter default until the heat slice
	# lands. A null block has no target.
	var target := 1.0
	if block == null:
		target = 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_WARMUP_TARGET_STATE,
		"warmup_target": target,
	}

static func source_factory_warmup_state(warmup: float, target: float, warmup_speed: float, seconds: float) -> Dictionary:
	# Mathf.approachDelta(warmup, warmupTarget(), warmupSpeed)
	# (GenericCrafter.java:239, efficiency above zero) and
	# Mathf.approachDelta(warmup, 0f, warmupSpeed)
	# (GenericCrafter.java:253, efficiency zero): approachDelta(from,
	# to, speed) is approach(from, to, Time.delta * speed)
	# (Mathf.java:420-422), approach(from, to, speed) is from +
	# clamp(to - from, -speed, speed) (Mathf.java:415-417), and
	# Time.delta is the frame delta in seconds. warmupSpeed is the
	# block's own, else the class default 0.019f
	# (GenericCrafter.java:45); no GenericCrafter-family block
	# initializer overrides it.
	var step := float(seconds) * float(warmup_speed)
	var moved := float(warmup) + clampf(float(target) - float(warmup), -step, step)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_WARMUP_STATE,
		"warmup": moved,
		"target": float(target),
	}

static func _liquid_add_amount_state(liquids: Dictionary, liquid_id: int, amount: float) -> void:
	# LiquidModule.add (LiquidModule.java:110-112): liquids[liquid.id]
	# += amount, current = liquid. The port's liquid module is the
	# id-indexed array under "liquids" (LiquidModule.java:23); a bare
	# id->amount map (the direct-call shape) adds straight through.
	# An unknown id holds nothing and takes nothing.
	if liquid_id < 0:
		return
	if liquids.has("liquids") and liquids["liquids"] is Array:
		var amounts: Array = liquids["liquids"]
		while amounts.size() <= liquid_id:
			amounts.append(0.0)
		amounts[liquid_id] = float(amounts[liquid_id]) + amount
		liquids["current"] = liquid_id
		return
	liquids[liquid_id] = float(liquids.get(liquid_id, 0.0)) + amount

static func source_factory_liquid_output_state(block: Object, liquids: Dictionary, liquid_ids: Dictionary, efficiency: float, seconds: float, time_scale: float) -> Dictionary:
	# The continuous liquid output half of
	# GenericCrafterBuild.updateTile() (GenericCrafter.java:241-246):
	# `float inc = getProgressIncrease(1f);` — the GenericCrafter
	# override at base time 1f, so a full output liquid scales inc
	# to zero through the same headroom scaling N2117 registered —
	# then each output liquid is handled once per tick,
	# `handleLiquid(this, output.liquid, Math.min(output.amount *
	# inc, liquidCapacity - liquids.get(output.liquid)))`, capped at
	# the remaining capacity so the module never overfills.
	# handleLiquid is liquids.add (BuildingComp.java:872-874).
	# A block with no output liquids outputs nothing (inc 0); a null
	# block outputs nothing. The tick only calls this while
	# efficiency is above zero. The port edelta convention is the
	# N2117 one (seconds * TICK_RATE), so one tick at efficiency 1.0
	# is inc 1.0 for an empty mixer and it gains 0.2 cryofluid.
	var added := {}
	if block == null:
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_LIQUID_OUTPUT_STATE,
			"inc": 0.0,
			"added": added,
			"liquids_after": liquids,
		}
	var output_liquids: Array = block.properties.get("outputLiquids", [])
	if output_liquids.is_empty():
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_LIQUID_OUTPUT_STATE,
			"inc": 0.0,
			"added": added,
			"liquids_after": liquids,
		}
	var inc := float(_crafter_progress_increase_with_base_time(block, liquids, liquid_ids, efficiency, seconds, time_scale, 1.0).get("progress_increase", 0.0))
	var liquid_capacity := float(block.properties.get("liquidCapacity", 10.0))
	for output in output_liquids:
		var liquid_name := str(output.get("liquid", ""))
		var liquid_id: int = int(liquid_ids.get(liquid_name, -1))
		if liquid_id < 0:
			continue
		var held: float = _liquid_amount_state(liquids, liquid_id)
		var amount := minf(float(output.get("amount", 0.0)) * inc, liquid_capacity - held)
		_liquid_add_amount_state(liquids, liquid_id, amount)
		added[liquid_name] = amount
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_LIQUID_OUTPUT_STATE,
		"inc": inc,
		"added": added,
		"liquids_after": liquids,
	}

static func source_factory_total_progress_state(total_progress: float, warmup: float, seconds: float) -> Dictionary:
	# totalProgress += warmup * Time.delta (GenericCrafter.java:259-260;
	# the TODO notes it may look bad and revert to edelta()). This
	# runs every tick, outside the efficiency branch — a factory at
	# efficiency zero still banks the warmup it has left as it cools.
	# Time.delta is the frame delta in seconds.
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_TOTAL_PROGRESS_STATE,
		"total_progress": float(total_progress) + float(warmup) * float(seconds),
	}

static func source_factory_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the factory tick wiring every tick
	# (GenericCrafterBuild.updateTile(), GenericCrafter.java:235, runs
	# after updateConsumption through Building.update(),
	# BuildingComp.java:2262-2274; AttributeCrafterBuild does not
	# override updateTile, and HeatCrafterBuild/HeatProducerBuild call
	# super.updateTile() first): each placed factory-family build
	# gets its frame keys refreshed from the live rules, so the
	# frame's cheating flag tracks team.rules().cheat and the
	# updateConsumption cheat branch can fire for a cheating team.
	# The frame is bound at placement (source_factory_bind_frame_state);
	# a sprite that somehow lacks one gets it bound here instead of
	# crashing the loop. The frame delta drives the bound consumers'
	# edelta (N2112): the consumption half of updateTile runs here,
	# so a placed factory actually consumes through the live loop.
	var results_by_cell := {}
	var ticked_count := 0
	if game == null:
		return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
	var catalog = game.get("content_catalog")
	if catalog == null:
		return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var liquid_id_by_name: Dictionary = source_content_registry_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {})
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if not _is_factory_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_factory_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_factory_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The bound RuntimeConsumer actors (N2112) run through
		# updateConsumption's first pass (minimum efficiency of the
		# non-optional consumers) and second pass (update every
		# update consumer when update, i.e. shouldConsume() &&
		# productionValid(), and efficiency > 0) every tick, so a
		# placed factory actually consumes. The binding goes through
		# the N2116 reinitialize path, so a sprite re-recorded with
		# a different block (Tile.changeBuild) drops the old block's
		# actors and rebinds from the new block's consumeBuilder
		# instead of running stale actors against new rows.
		# shouldConsume is the GenericCrafterBuild.shouldConsume() body (N2113,
		# GenericCrafter.java:203, output-space checks against the
		# frame's held items and the building's liquid module); the
		# power consumer stays the power graph's domain (N2080/N2107)
		# and is not bound here.
		frame["enabled"] = bool(frame.get("enabled", true))
		var liquids: Dictionary = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		var consumer_bound: Dictionary = source_factory_reinitialize_consumers_state(frame, block, catalog, liquids)
		var rows: Array = consumer_bound.get("rows", [])
		var consumers: Array = consumer_bound.get("consumers", [])
		var should_consume: bool = bool(source_factory_should_consume_state(frame, block, liquids, liquid_id_by_name).get("should_consume", false))
		var valid: bool = source_building_access_state.production_valid_state()
		var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
		frame["efficiency"] = setup.get("efficiency", 1.0)
		frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
		var groups: Dictionary = source_consume_state.classify_consumer_arrays(rows, "ignored", "optional", "update")
		var required_results: Array = []
		var optional_results: Array = []
		var updates: Array = []
		for index in range(rows.size()):
			var actor = consumers[index]
			actor.source_delta = seconds * source_time_defaults.TICK_RATE
			actor.time_scale = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			if bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
				if groups["non_optional_consumers"].has(rows[index]):
					required_results.append({"result": actor.efficiency(frame), "is_power": false})
				if groups["optional_consumers"].has(rows[index]):
					optional_results.append({"result": actor.efficiency(frame)})
			if groups["update_consumers"].has(rows[index]):
				updates.append(actor)
		var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(groups["has_consumers"], bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, optional_results, updates, frame)
		source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		# The production half of GenericCrafterBuild.updateTile()
		# (GenericCrafter.java:235-266): with efficiency above zero
		# the progress climbs by getProgressIncrease(craftTime) — the
		# GenericCrafter override scales it when the block outputs
		# liquids — warmup approaches warmupTarget() at warmupSpeed
		# (GenericCrafter.java:239) and each output liquid is handled
		# once per tick (GenericCrafter.java:241-246); at efficiency
		# zero warmup decays toward 0 (GenericCrafter.java:253).
		# totalProgress banks warmup * Time.delta every tick
		# (GenericCrafter.java:259-260), and a completed progress
		# crafts (consume + offload, N2117). updateConsumption already
		# ran through Building.update() (BuildingComp.java:2262-2274),
		# so the frame's efficiency is the live one; dumpOutputs()
		# (GenericCrafter.java:317+) is the next slice.
		var time_scale := source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		var efficiency := float(frame.get("efficiency", 0.0))
		var warmup_speed := float(block.properties.get("warmupSpeed", 0.019))
		if efficiency > 0.0:
			var increase: Dictionary = source_factory_crafter_progress_increase_state(block, liquids, liquid_id_by_name, efficiency, seconds, time_scale)
			frame["progress"] = float(frame.get("progress", 0.0)) + float(increase.get("progress_increase", 0.0))
			var target: Dictionary = source_factory_warmup_target_state(block)
			var warmed: Dictionary = source_factory_warmup_state(float(frame.get("warmup", 0.0)), float(target.get("warmup_target", 1.0)), warmup_speed, seconds)
			frame["warmup"] = float(warmed.get("warmup", 0.0))
			source_factory_liquid_output_state(block, liquids, liquid_id_by_name, efficiency, seconds, time_scale)
		else:
			var cooled: Dictionary = source_factory_warmup_state(float(frame.get("warmup", 0.0)), 0.0, warmup_speed, seconds)
			frame["warmup"] = float(cooled.get("warmup", 0.0))
		var totalled: Dictionary = source_factory_total_progress_state(float(frame.get("totalProgress", 0.0)), float(frame.get("warmup", 0.0)), seconds)
		frame["totalProgress"] = float(totalled.get("total_progress", 0.0))
		if efficiency > 0.0 and float(frame.get("progress", 0.0)) >= 1.0:
			source_factory_craft_state(game, frame, cell, block)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
