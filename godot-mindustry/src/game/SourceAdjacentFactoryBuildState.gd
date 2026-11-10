extends RefCounted
class_name SourceAdjacentFactoryBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_consume_item_state := preload("res://src/game/SourceConsumeItemsState.gd")
const source_consume_liquid_state := preload("res://src/game/SourceConsumeLiquidState.gd")
const source_consume_state := preload("res://src/game/SourceConsumeState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

# Every block whose build is one of the factory-adjacent families: the
# class itself (Separator extends Block, Separator.java:18; Incinerator
# extends Block, Incinerator.java:16; WallCrafter extends Block,
# WallCrafter.java:29) and SingleBlockProducer, which extends
# BlockProducer (SingleBlockProducer.java:7, `public class
# SingleBlockProducer extends BlockProducer{`), itself a PayloadBlock
# (BlockProducer.java:19). None of them is a GenericCrafterBuild, so
# the N2110 factory tick never touched them; they are wired here with
# the same tick/bind/driver pattern. The other production blocks are
# NOT here: the drills/pumps have their own drivers, and
# ItemIncinerator (slag-incinerator) is a separate class, not an
# Incinerator.
const SOURCE_ADJACENT_FACTORY_BUILD_IMPLEMENTATIONS := ["Separator", "Incinerator", "WallCrafter", "SingleBlockProducer"]
const SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY := "source_adjacent_factory_building"

static func _is_adjacent_factory_build_implementation(implementation: String) -> bool:
	return SOURCE_ADJACENT_FACTORY_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_adjacent_factory_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The adjacent-factory tick wires the frame keys the consumption
	# path reads (the N2110 factory pattern): block_implementation is
	# the block's implementation (Separator.java:18, `public class
	# Separator extends Block{`; Incinerator.java:16; WallCrafter.
	# java:29; SingleBlockProducer.java:7), team_id and rules_state
	# are what Java reads as b.team and state.rules, and cheating is
	# the team's live TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read through
	# N2099's helper), so a cheating team's adjacent factory counts
	# everything as valid like Java's updateConsumption
	# (BuildingComp.java:1944-1945, "everything is valid when
	# cheating", `if(!block.hasConsumers || cheating()){`). A team
	# with no rule keeps the false default (Rules.java:328
	# TeamRule.cheat, default false).
	frame["block_implementation"] = block_implementation
	frame["team_id"] = team_id
	frame["rules_state"] = rules_state
	frame["cheating"] = bool(source_rules_state.source_team_cheating_state(rules_state, team_id).get("cheating", false))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_adjacent_factory_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement through the Tile.setBlock proximity path (the same
	# path that binds the drill, ContinuousLiquidTurret, turret and
	# factory frames). An adjacent-family sprite gets an empty frame
	# bound; the live-loop tick fills its keys every tick. Any other
	# block, or an already-bound sprite, binds nothing.
	if block == null or not _is_adjacent_factory_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_bind_consumer_state(frame: Dictionary, block: Object, catalog: Object, amounts: Dictionary) -> Dictionary:
	# The block's consumeBuilder carries one ConsumeItems row per
	# consumeItem stack and one ConsumeLiquid row per consumeLiquid
	# call (Block.java:1127-1131, 1167-1177); the port binds one
	# RuntimeConsumer actor per row (the drill model, N2097/N2100),
	# item rows through SourceConsumeItemsState and liquid rows
	# through SourceConsumeLiquidState, each paying through the N2097
	# cost-multiplier callback (1.0 for an adjacent-family block).
	# Actors are bound once — a frame that already carries them binds
	# nothing — and a block without consume rows binds none. amounts
	# is the building's liquid module (the turret's shape); the item
	# actors read the frame's item module (frame["items"], the
	# Building.items ItemModule), created empty when the frame has
	# none yet. The vanilla rows: the separator consumes slag 4/60
	# per tick (Blocks.java:1244), the disassembler scrap 1 plus slag
	# 0.12 (Blocks.java:1263-1264), the large-cliff-crusher hydrogen
	# 1/60 (Blocks.java:3028) — its graphite booster is an assigned
	# consumeItem(...).boost() row (Blocks.java:3030), captured as
	# boosterItem, not a consumeItem row, so it binds no item actor —
	# while the incinerator and the cliff-crusher consume power only
	# (Blocks.java:1328, 3004) and bind none; the power consumer
	# stays the power graph's domain (N2080/N2107). No vanilla block
	# uses SingleBlockProducer, whose dynamic item consumer
	# (BlockProducer.java:39-45, ConsumeItemDynamic) is not a
	# consumeItem row either.
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
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ADJACENT_FACTORY_BUILD_BIND_CONSUMER_STATE, "bound": bound, "consumers": consumers, "rows": rows}

static func _has_consumers_state(block: Object) -> bool:
	# Block.hasConsumers is set from the consumeBuilder size
	# (Block.java); the registry captures the block's consume rows,
	# so a block with any consumeItem, consumeLiquid or consumePower
	# row has consumers. Every vanilla adjacent block does (the
	# separator and disassembler consume slag and power, the
	# incinerator consumes power, the cliff-crushers consume power
	# plus a booster row).
	if block == null:
		return false
	var properties: Dictionary = block.properties
	return properties.has("consumeItem") or properties.has("consumeLiquid") or properties.has("consumePower")

static func source_adjacent_factory_should_consume_state(frame: Dictionary, block: Object) -> Dictionary:
	# Each family's own shouldConsume() body, read per tick by the
	# driver: SeparatorBuild.shouldConsume() (Separator.java:99-108)
	# counts the held items minus the consumeItem inputs (consItems,
	# Separator.java:101-105, found by init(), Separator.java:56-59)
	# and consumes while the remainder fits itemCapacity
	# (`return total < itemCapacity && enabled;`,
	# Separator.java:107); WallCrafterBuild.shouldConsume()
	# (WallCrafter.java:246-248) consumes while the held output
	# stack fits itemCapacity (`return items.get(output) <
	# itemCapacity;`, with no enabled check — Building.
	# updateConsumption handles enabled separately); IncineratorBuild
	# does not override shouldConsume, so the Building default
	# applies (`return enabled;`, BuildingComp.java:755-757);
	# BlockProducerBuild.shouldConsume()
	# (BlockProducer.java:108-110) is the Building default plus a
	# recipe (`return super.shouldConsume() && recipe() != null;`),
	# and SingleBlockProducerBuild.recipe() returns the block's
	# result (SingleBlockProducer.java:13-16, default Blocks.router,
	# SingleBlockProducer.java:8), so a producer with a result
	# consumes when enabled. A null block has no outputs and
	# consumes when enabled. Owner:
	# PORT_GAME_SOURCE_ADJACENT_FACTORY_BUILD_SHOULD_CONSUME_STATE.
	var enabled: bool = bool(frame.get("enabled", true))
	var output_blocked := false
	var buffer_full := false
	if block == null:
		return {"should_consume": enabled, "output_blocked": output_blocked, "buffer_full": buffer_full}
	var properties: Dictionary = block.properties
	var items: Dictionary = frame.get("items", {})
	var item_capacity: int = int(properties.get("itemCapacity", 10))
	var implementation: String = str(block.implementation)
	if implementation == "Separator":
		var total := 0
		for item_name in items:
			total += int(items[item_name])
		for row in properties.get("consumeItem", []):
			total -= int(items.get(str(row.get("item", "")), 0))
		buffer_full = total >= item_capacity
		return {"should_consume": enabled and not buffer_full, "output_blocked": output_blocked, "buffer_full": buffer_full}
	if implementation == "WallCrafter":
		var output: String = str(properties.get("output", ""))
		output_blocked = int(items.get(output, 0)) >= item_capacity
		return {"should_consume": not output_blocked, "output_blocked": output_blocked, "buffer_full": buffer_full}
	if implementation == "SingleBlockProducer":
		var recipe: String = str(properties.get("result", "router"))
		return {"should_consume": enabled and recipe != "", "output_blocked": output_blocked, "buffer_full": buffer_full}
	return {"should_consume": enabled, "output_blocked": output_blocked, "buffer_full": buffer_full}

static func source_adjacent_factory_update_consumption_state(frame: Dictionary, has_consumers: bool, enabled: bool, production_valid: bool, should_consume: bool, efficiency_scale: float) -> Dictionary:
	# BuildingComp.updateConsumption() (BuildingComp.java:1943-1951):
	# when cheating, everything is valid and consumption is skipped
	# (`if(!block.hasConsumers || cheating()){`, the early return
	# sets potentialEfficiency from enabled and productionValid and
	# efficiency from shouldConsume, with no consumer updated). The
	# shared efficiency machinery already implements that method, so
	# this adapter runs it with the frame's live cheating flag and
	# the bound actors (N2115 binds them, one RuntimeConsumer per
	# consumeItem/consumeLiquid row; the driver runs them through the
	# second pass): a cheating adjacent factory takes the early
	# return and pays nothing, while a non-cheating one runs the
	# machinery. skipped_consumption is
	# the Java early-return condition itself. The frame's cheating
	# flag is wired live by the tick, and the tick itself runs after
	# updateConsumption through Building.update()
	# (BuildingComp.java:2262-2274), so this adapter is the
	# consumption half of each family's updateTile()
	# (Separator.java:131, Incinerator.java:27, WallCrafter.java:191,
	# BlockProducer.java:113).
	var cheating := bool(frame.get("cheating", false))
	var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(has_consumers, cheating, enabled, production_valid, should_consume, efficiency_scale, [], [], [], frame)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ADJACENT_FACTORY_BUILD_UPDATE_CONSUMPTION_STATE,
		"cheating": cheating,
		"skipped_consumption": bool(not has_consumers or cheating),
		"potential_efficiency": float(consumption.get("potential_efficiency", 0.0)),
		"efficiency": float(consumption.get("efficiency", 0.0)),
		"optional_efficiency": float(consumption.get("optional_efficiency", 0.0)),
		"should_consume_power": bool(consumption.get("should_consume_power", false)),
	}

static func source_adjacent_factory_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the adjacent-factory tick wiring every tick
	# (SeparatorBuild.updateTile(), Separator.java:131;
	# IncineratorBuild.updateTile(), Incinerator.java:27;
	# WallCrafterBuild.updateTile(), WallCrafter.java:191, which calls
	# super.updateTile() first; SingleBlockProducerBuild inherits
	# BlockProducerBuild.updateTile(), BlockProducer.java:113, which
	# calls super.updateTile() first; each runs after
	# updateConsumption through Building.update(),
	# BuildingComp.java:2262-2274): each placed adjacent-family build
	# gets its frame keys refreshed from the live rules, so the
	# frame's cheating flag tracks team.rules().cheat and the
	# updateConsumption cheat branch can fire for a cheating team.
	# The frame is bound at placement
	# (source_adjacent_factory_bind_frame_state); a sprite that
	# somehow lacks one gets it bound here instead of crashing the
	# loop. The consumption half of updateTile runs here: the
	# family's shouldConsume body gates the shared updateConsumption
	# machinery, and the bound actors (N2115, one RuntimeConsumer
	# per consumeItem/consumeLiquid row) run through its first and
	# second passes, and the result is applied to the frame, so a
	# placed adjacent factory's efficiency tracks the live cheating
	# flag every tick and a placed adjacent factory actually
	# consumes.
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
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if not _is_adjacent_factory_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_adjacent_factory_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_adjacent_factory_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The bound RuntimeConsumer actors (N2115) run through
		# updateConsumption's first pass (minimum efficiency of the
		# non-optional consumers) and second pass (update every
		# update consumer when update, i.e. shouldConsume() &&
		# productionValid(), and efficiency > 0) every tick, so a
		# placed adjacent factory actually consumes. shouldConsume
		# is the family's own body (N2114, Separator.java:99,
		# WallCrafter.java:246, BlockProducer.java:108,
		# BuildingComp.java:755); the power consumer stays the power
		# graph's domain (N2080/N2107) and is not bound here.
		frame["enabled"] = bool(frame.get("enabled", true))
		var liquids: Dictionary = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		var consumer_bound: Dictionary = source_bind_consumer_state(frame, block, catalog, liquids)
		var rows: Array = consumer_bound.get("rows", [])
		var consumers: Array = consumer_bound.get("consumers", [])
		var should_consume: bool = bool(source_adjacent_factory_should_consume_state(frame, block).get("should_consume", false))
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
		var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(_has_consumers_state(block), bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, optional_results, updates, frame)
		source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
