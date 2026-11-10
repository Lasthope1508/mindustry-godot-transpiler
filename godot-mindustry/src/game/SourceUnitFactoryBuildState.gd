extends RefCounted
class_name SourceUnitFactoryBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerUnitBuildingRegistry.gd")
const source_consume_item_state := preload("res://src/game/SourceConsumeItemsState.gd")
const source_consume_liquid_state := preload("res://src/game/SourceConsumeLiquidState.gd")
const source_consume_state := preload("res://src/game/SourceConsumeState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

# Every block whose build is a unit-factory build: the three classes
# that set each consumer's multiplier to Rules.unitCost
# (UnitFactory.java:109, Reconstructor.java:149,
# UnitAssembler.java:175). Their builds run updateTile() every tick
# (UnitFactoryBuild.updateTile(), UnitFactory.java:392;
# ReconstructorBuild.updateTile(), Reconstructor.java:317;
# UnitAssemblerBuild.updateTile(), UnitAssembler.java:429), and each
# of them runs updateConsumption() through the Building update, so
# the live cheating value decides whether the factory consumes.
const SOURCE_UNIT_FACTORY_BUILD_IMPLEMENTATIONS := ["UnitFactory", "Reconstructor", "UnitAssembler"]
const SOURCE_UNIT_FACTORY_BUILDING_META_KEY := "source_unit_factory_building"

static func _is_unit_factory_build_implementation(implementation: String) -> bool:
	return SOURCE_UNIT_FACTORY_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_unit_factory_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The factory tick wires the frame keys the consumption path
	# reads (the N2108 turret pattern): block_implementation is the
	# block's implementation, team_id and rules_state are what Java
	# reads as b.team and state.rules, and cheating is the team's
	# live TeamRule value (TeamComp.cheating(), TeamComp.java:17-19
	# `return team.rules().cheat;`, read through N2099's helper), so
	# a cheating team's factory skips consumption like Java's
	# updateConsumption (BuildingComp.java:1944-1945, "everything is
	# valid when cheating"). A team with no rule keeps the false
	# default (Rules.java:328 TeamRule.cheat, default false).
	frame["block_implementation"] = block_implementation
	frame["team_id"] = team_id
	frame["rules_state"] = rules_state
	frame["cheating"] = bool(source_rules_state.source_team_cheating_state(rules_state, team_id).get("cheating", false))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_unit_factory_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement through the Tile.setBlock proximity path (the same
	# path that binds the drill, ContinuousLiquidTurret and turret
	# frames). A factory-family sprite gets an empty frame bound;
	# the live-loop tick fills its keys every tick. Any other block,
	# or an already-bound sprite, binds nothing.
	if block == null or not _is_unit_factory_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_UNIT_FACTORY_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_UNIT_FACTORY_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_UNIT_FACTORY_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_unit_factory_update_consumption_state(frame: Dictionary, has_consumers: bool, enabled: bool, production_valid: bool, should_consume: bool, efficiency_scale: float) -> Dictionary:
	# BuildingComp.updateConsumption() (BuildingComp.java:1943-1951):
	# when cheating, everything is valid and consumption is skipped
	# (`if(!block.hasConsumers || cheating()){`, the early return
	# sets potentialEfficiency from enabled and productionValid and
	# efficiency from shouldConsume, with no consumer updated). The
	# shared efficiency machinery already implements that method, so
	# this adapter runs it with the frame's live cheating flag and
	# no bound consumer actors: the live-loop tick driver (N2120)
	# binds the actors and runs the first and second passes itself,
	# so this adapter stays the direct N2109/N2111 wrapper over an
	# empty actor list. A cheating factory takes the early return
	# and pays nothing, while a non-cheating one runs the machinery
	# over its (still empty here) actor list. skipped_consumption is the
	# Java early-return condition itself.
	var cheating := bool(frame.get("cheating", false))
	var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(has_consumers, cheating, enabled, production_valid, should_consume, efficiency_scale, [], [], [], frame)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_UPDATE_CONSUMPTION_STATE,
		"cheating": cheating,
		"skipped_consumption": bool(not has_consumers or cheating),
		"potential_efficiency": float(consumption.get("potential_efficiency", 0.0)),
		"efficiency": float(consumption.get("efficiency", 0.0)),
		"optional_efficiency": float(consumption.get("optional_efficiency", 0.0)),
		"should_consume_power": bool(consumption.get("should_consume_power", false)),
	}

static func source_unit_factory_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the factory tick wiring every tick
	# (UnitFactoryBuild.updateTile(), UnitFactory.java:392;
	# ReconstructorBuild.updateTile(), Reconstructor.java:317;
	# UnitAssemblerBuild.updateTile(), UnitAssembler.java:429 — each
	# runs updateConsumption through the Building update): each
	# placed factory-family build gets its frame keys refreshed from
	# the live rules, so the frame's cheating flag tracks
	# team.rules().cheat and updateConsumption skips consumption for
	# a cheating team. The frame is bound at placement
	# (source_unit_factory_bind_frame_state); a sprite that somehow
	# lacks one gets it bound here instead of crashing the loop. The
	# consumption half of updateTile runs here: the bound
	# RuntimeConsumer actors (N2120, one per consumeItem/consumeLiquid
	# row and per current-plan requirement) run through
	# updateConsumption's first and second passes every tick, so a
	# placed unit factory actually consumes — the liquid rows drain
	# per tick and the item rows gate efficiency on the stacks held.
	# The frame delta is not consumed by the wiring itself beyond
	# that; a later slice that ticks production reads it.
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
		if not _is_unit_factory_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_unit_factory_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_unit_factory_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The bound RuntimeConsumer actors (N2120) run through
		# updateConsumption's first pass (minimum efficiency of the
		# non-optional consumers) and second pass (update every
		# update consumer when update, i.e. shouldConsume() &&
		# productionValid(), and efficiency > 0) every tick, so a
		# placed unit factory actually consumes. The binding goes
		# through the reinitialize path, so a sprite re-recorded with
		# a different block (Tile.changeBuild) or a factory whose
		# current plan changed (UnitFactory config) drops the old
		# block's actors and rebinds from the new rows instead of
		# running stale actors against new rows. shouldConsume is the
		# frame's enabled flag until the families' own shouldConsume()
		# bodies land (UnitFactory.java:446, Reconstructor.java:368,
		# UnitAssembler.java:389); the power consumer stays the power
		# graph's domain (N2080/N2107) and is not bound here.
		frame["enabled"] = bool(frame.get("enabled", true))
		var liquids: Dictionary = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		var consumer_bound: Dictionary = source_unit_factory_reinitialize_consumers_state(frame, block, catalog, liquids)
		var rows: Array = consumer_bound.get("rows", [])
		var consumers: Array = consumer_bound.get("consumers", [])
		var should_consume: bool = bool(frame.get("enabled", true))
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

static func source_unit_factory_plan_requirements_state(block: Object, plan_index: int) -> Dictionary:
	# The current plan's requirements (UnitFactory.java:207-218,
	# UnitPlan holds the unit, the build time and the ItemStack[]
	# requirements; UnitFactoryBuild.unit(), UnitFactory.java:264-266,
	# reads plans.get(currentPlan)). The registry captures the
	# block's plans as unitPlans (N2120, Blocks.java: the
	# ground-factory's dagger plan is silicon 10 + lead 10 over
	# 900 ticks). A null block, a block without plans, or an index
	# outside the plans (currentPlan -1 — the config handler clamps
	# an out-of-range index to -1, UnitFactory.java:60-62 — or past
	# the end; updateTile forces plan 0 when the block is not
	# configurable, UnitFactory.java:392-394) has no requirements:
	# the ConsumeItemDynamic then reads ItemStack.empty
	# (UnitFactory.java:84), so no item actor binds.
	if block == null:
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_PLAN_REQUIREMENTS_STATE}
	var plans: Array = block.properties.get("unitPlans", [])
	if plan_index < 0 or plan_index >= plans.size():
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_PLAN_REQUIREMENTS_STATE}
	var plan: Dictionary = plans[plan_index]
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_PLAN_REQUIREMENTS_STATE,
		"unit": str(plan.get("unit", "")),
		"time": float(plan.get("time", 0.0)),
		"items": Array(plan.get("requirements", [])),
	}

static func source_bind_consumer_state(frame: Dictionary, block: Object, catalog: Object, amounts: Dictionary) -> Dictionary:
	# The block's consumeBuilder carries one ConsumeItems row per
	# consumeItem stack and one ConsumeLiquid row per consumeLiquid
	# call (Block.java:1127-1131, 1167-1177); the port binds one
	# RuntimeConsumer actor per row (the drill model, N2097/N2100),
	# item rows through SourceConsumeItemsState and liquid rows
	# through SourceConsumeLiquidState, each paying through the N2097
	# cost-multiplier callback — Rules.unitCost for this family
	# (UnitFactory.java:109, Reconstructor.java:149,
	# UnitAssembler.java:175). The UnitFactory class itself carries
	# no static rows: its items come from the ConsumeItemDynamic
	# over the current plan's requirements (UnitFactory.java:84), so
	# one more item actor binds per requirement of the frame's
	# current plan (frame["current_plan"], -1 when no plan is set).
	# Actors are bound once — a frame that already carries them binds
	# nothing — and a block without consume rows binds none. amounts
	# is the building's liquid module (the turret's shape); the item
	# actors read the frame's item module (frame["items"], the
	# Building.items ItemModule), created empty when the frame has
	# none yet. The vanilla rows: the additive-reconstructor consumes
	# silicon 40 + graphite 40 (Blocks.java:6302-6321) and the
	# exponential/tetrative add cryofluid 1/3 per tick
	# (Blocks.java:6342-6385); the assemblers consume cyanogen
	# 0.15/0.2 per tick (Blocks.java:6521-6565) and their plan
	# itemReq/liquidReq are null in vanilla, so no dynamic rows bind
	# for them — the ConsumePayloadDynamic over the plan's payload
	# stacks (UnitAssembler.java:158) is a later slice, like the
	# SingleBlockProducer dynamic consumer deferred in N2115. The
	# power consumer stays the power graph's domain (N2080/N2107).
	# A bound frame records the block and the plan its actors belong
	# to (frame["block_id"], frame["bound_plan"]), so the live-loop
	# tick can tell a replaced building — or a changed plan — from
	# the one its actors were bound for (N2116, Tile.changeBuild).
	var rows: Array = []
	if block != null and block.properties.has("consumeItem"):
		rows.append_array(source_consume_item_state.source_bind_item_consumers_state(block, catalog).get("consumers", []))
	var plan: Dictionary = source_unit_factory_plan_requirements_state(block, int(frame.get("current_plan", -1)))
	var plan_items: Array = plan.get("items", [])
	if not plan_items.is_empty():
		var catalog_items: Array = catalog.call("get_many", "item")
		for stack in plan_items:
			var matches: Array = catalog_items.filter(func(item): return item.id == stack["item"])
			assert(matches.size() == 1, "ConsumeItemDynamic Java field must resolve uniquely in the typed item catalog")
			var row: Dictionary = (stack as Dictionary).duplicate()
			row["ignored"] = source_consume_state.ignore_state()["ignored"]
			rows.append(row)
	if block != null and block.properties.has("consumeLiquid"):
		rows.append_array(source_consume_liquid_state.source_bind_liquid_consumers_state(block, catalog).get("consumers", []))
	if not frame.has("items"):
		frame["items"] = {}
	var items: Dictionary = frame["items"]
	var consumers: Array = frame.get("consumers", [])
	var bound := false
	# The bound rows live on the frame with the actors (the craft
	# slice reads them back at craft() time, N2117): a frame that
	# already carries actors still gets its rows refreshed from the
	# block, so the craft trigger always runs the block's own rows.
	frame["rows"] = rows
	if consumers.is_empty() and not rows.is_empty():
		for row in rows:
			if row.has("liquid"):
				consumers.append(source_consume_liquid_state.source_runtime_consumer_state(row, amounts, [], source_consume_state.source_cost_multiplier_for_block_state).get("consumer"))
			else:
				consumers.append(source_consume_item_state.source_runtime_consumer_state(row, items, source_consume_state.source_cost_multiplier_for_block_state).get("consumer"))
		frame["consumers"] = consumers
		frame["block_id"] = str(block.id)
		frame["bound_plan"] = int(frame.get("current_plan", -1))
		bound = true
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_BIND_CONSUMER_STATE, "bound": bound, "consumers": consumers, "rows": rows}

static func source_unit_factory_reinitialize_consumers_state(frame: Dictionary, block: Object, catalog: Object, amounts: Dictionary) -> Dictionary:
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
	# the actor list when the new block has more rows. A UnitFactory
	# config change is the same shape without a new Building: the
	# plan changes (UnitFactory.java:60-62 resets progress, not the
	# ItemModule), so the old plan's actors go stale while the held
	# items stay. The tick therefore reinitializes through here
	# instead of binding directly: a frame already on this block and
	# plan takes the normal once-only bind path; a frame stamped for
	# another block drops its old RuntimeConsumer actors (N2100's
	# invalidate, the cache-invalidation half of
	# reinitializeConsumers), clears its item and liquid stores for
	# the fresh Building's own empty ItemModule/LiquidModule
	# (BuildingComp.java:145-146, init creates a fresh
	# ItemModule/LiquidModule per Building), and rebinds from the
	# new block's consumeBuilder; a frame stamped for another plan
	# drops its old actors and rebinds from the new plan's
	# requirements, keeping the held items and liquids. A null
	# block reinitializes nothing.
	if block == null:
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_REINITIALIZE_CONSUMERS_STATE, "reinitialized": false, "bound": false, "consumers": frame.get("consumers", []), "rows": []}
	var block_id: String = str(block.id)
	var stamped: String = str(frame.get("block_id", ""))
	var current_plan: int = int(frame.get("current_plan", -1))
	var stamped_plan: int = int(frame.get("bound_plan", -1))
	if stamped == block_id and stamped_plan == current_plan:
		var bound: Dictionary = source_bind_consumer_state(frame, block, catalog, amounts)
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_REINITIALIZE_CONSUMERS_STATE, "reinitialized": false, "bound": bool(bound.get("bound", false)), "consumers": bound.get("consumers", []), "rows": bound.get("rows", [])}
	var reinitialized := stamped != "" or (stamped_plan != current_plan and not Array(frame.get("consumers", [])).is_empty())
	if stamped != "":
		source_consume_liquid_state.source_invalidate_consumer_cache_state(block, frame)
		if stamped != block_id:
			frame["items"] = {}
			amounts.clear()
	var rebound: Dictionary = source_bind_consumer_state(frame, block, catalog, amounts)
	frame["block_id"] = block_id
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_REINITIALIZE_CONSUMERS_STATE, "reinitialized": reinitialized, "bound": bool(rebound.get("bound", false)), "consumers": rebound.get("consumers", []), "rows": rebound.get("rows", [])}

static func _has_consumers_state(block: Object) -> bool:
	# Block.hasConsumers is set from the consumeBuilder size
	# (Block.java); the registry captures the block's consume rows,
	# so a block with any consumeItem, consumeLiquid or consumePower
	# row has consumers. Every vanilla unit-factory block does (the
	# factories consume power 1.2, the reconstructors 3-25, the
	# assemblers 2.5-3, Blocks.java), and the UnitFactory class
	# additionally carries its plan's ConsumeItemDynamic.
	if block == null:
		return false
	var properties: Dictionary = block.properties
	return properties.has("consumeItem") or properties.has("consumeLiquid") or properties.has("consumePower") or properties.has("unitPlans")
