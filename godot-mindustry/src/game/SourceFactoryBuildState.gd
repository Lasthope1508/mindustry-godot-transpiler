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
	# when the frame has none yet.
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
	if consumers.is_empty() and not rows.is_empty():
		for row in rows:
			if row.has("liquid"):
				consumers.append(source_consume_liquid_state.source_runtime_consumer_state(row, amounts, [], source_consume_state.source_cost_multiplier_for_block_state).get("consumer"))
			else:
				consumers.append(source_consume_item_state.source_runtime_consumer_state(row, items, source_consume_state.source_cost_multiplier_for_block_state).get("consumer"))
		frame["consumers"] = consumers
		bound = true
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_BUILD_BIND_CONSUMER_STATE, "bound": bound, "consumers": consumers, "rows": rows}

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
		# placed factory actually consumes. shouldConsume is the
		# GenericCrafterBuild.shouldConsume() body (N2113,
		# GenericCrafter.java:203, output-space checks against the
		# frame's held items and the building's liquid module); the
		# power consumer stays the power graph's domain (N2080/N2107)
		# and is not bound here.
		frame["enabled"] = bool(frame.get("enabled", true))
		var liquids: Dictionary = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		var consumer_bound: Dictionary = source_bind_consumer_state(frame, block, catalog, liquids)
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
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
