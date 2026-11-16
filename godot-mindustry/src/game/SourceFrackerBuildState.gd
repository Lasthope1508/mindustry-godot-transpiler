extends RefCounted
class_name SourceFrackerBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_solid_pump_state := preload("res://src/game/SourceSolidPumpBuildState.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")

# The Fracker implementation (Fracker.java:7, `public class
# Fracker extends SolidPump{`): oil-extractor (consumePower 3f,
# pumpAmount 0.25f, size 3, liquidCapacity 40f, attribute oil,
# itemUseTime 60f, result oil, consumeItem sand, consumeLiquid
# water 0.15f). The only Fracker block in the game
# (Blocks.java:2964-2979). FrackerBuild extends SolidPumpBuild,
# but the N2150 solid-pump driver only ticks the SolidPump
# implementation (SOURCE_SOLID_PUMP_BUILD_IMPLEMENTATIONS is
# ["SolidPump"]), so this driver is the fracker tick. The driver
# uses its own family frame key ("source_fracker_building", the
# turret precedent); the solid-pump per-family frame
# ("source_solid_pump_building") stays untouched, and this slice
# adds the fracker key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it.
const SOURCE_FRACKER_BUILD_IMPLEMENTATIONS := ["Fracker"]
const SOURCE_FRACKER_BUILDING_META_KEY := "source_fracker_building"
# Def constants for the only Fracker def (oil-extractor,
# Blocks.java:2964-2978): the result liquid is oil
# (`result = Liquids.oil;`, Blocks.java:2966 -- the class
# default is water, `public Liquid result =
# Liquids.water;`, SolidPump.java:22) and the liquid
# capacity is 40f (`liquidCapacity = 40f;`,
# Blocks.java:2971 -- the class default is -1f, `public
# float liquidCapacity = -1f;`, Block.java:77). The catalog
# carries neither property for the oil-extractor, so both
# are def constants (the N2190 fogRadius / N2199
# transportTime precedent).
const SOURCE_FRACKER_RESULT_LIQUID := "oil"
const SOURCE_FRACKER_LIQUID_CAPACITY := 40.0
# The oil-extractor def pump amount (Blocks.java:2969,
# `pumpAmount = 0.25f;`, overriding the Pump class default
# 0.2f, Pump.java:20, `public float pumpAmount = 0.2f;`):
# the driver passes it to the reused N2220 SolidPump pure
# function for super.updateTile() (Fracker.java:37).
const SOURCE_FRACKER_PUMP_AMOUNT := 0.25
# The oil-extractor def size (Blocks.java:2970, `size =
# 3;`): both proximity sums divide by size * size
# (SolidPump.java:153, 157), so the fracker divides by 9.
const SOURCE_FRACKER_SIZE := 3
# The oil-extractor def base efficiency
# (Blocks.java:2973, `baseEfficiency = 0f;`, overriding the
# SolidPump class default 1f, SolidPump.java:26, `public
# float baseEfficiency = 1f;`): each pumpable linked tile
# contributes baseEfficiency / (size * size) to validTiles
# (SolidPump.java:157), so for the oil-extractor validTiles
# is ALWAYS 0 -- the fraction comes from the oil-attribute
# boost + env alone.
const SOURCE_FRACKER_BASE_EFFICIENCY := 0.0
# The oil-extractor def item use time (Blocks.java:2974,
# `itemUseTime = 60f;`, overriding the Fracker class default
# 100f, Fracker.java:8, `public float itemUseTime = 100f;`):
# the accumulator threshold at which updateTile consumes
# one sand (Fracker.java:32-35).
const SOURCE_FRACKER_ITEM_USE_TIME := 60.0
# The sand consume item (Blocks.java:2976, `consumeItem(
# Items.sand);`): consume() removes one sand via
# ConsumeItems.trigger (ConsumeItems.java:44-48).
const SOURCE_FRACKER_CONSUME_ITEM := "sand"
# The water consume liquid (Blocks.java:2978,
# `consumeLiquid(Liquids.water, 0.15f);`): 0.15f PER FRAME
# (= 9/s), not /60f -- the def writes the bare number,
# unlike the /60f defs (e.g. nitrogen 10f/60f). The def
# sets no multiplier (Block.java:1127-1129, `return consume(
# new ConsumeLiquid(liquid, amount));`), so the default
# multiplier 1f (Consume.java:18, `public Floatf<Building>
# multiplier = b -> 1f;`) applies.
const SOURCE_FRACKER_CONSUME_LIQUID := "water"
const SOURCE_FRACKER_CONSUME_LIQUID_AMOUNT := 0.15
# Fracker.java:41, the warmup lerpDelta rate `0.02f` (the
# same rate as SolidPump.java:130/134).
const SOURCE_FRACKER_WARMUP_RATE := 0.02

static func _is_fracker_build_implementation(implementation: String) -> bool:
	return SOURCE_FRACKER_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_fracker_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The fracker tick wires the frame keys the consumption
	# path reads (the N2148 turret pattern): block_implementation
	# is the block's implementation (Fracker.java:7, `public
	# class Fracker extends SolidPump{`), team_id and rules_state
	# are what Java reads as b.team and state.rules, and cheating
	# is the team's live TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's fracker
	# skips consumption like Java's updateConsumption
	# (BuildingComp.java:1944-1945, "everything is valid when
	# cheating"). A team with no rule keeps the false default
	# (Rules.java:328 TeamRule.cheat, default false).
	frame["block_implementation"] = block_implementation
	frame["team_id"] = team_id
	frame["rules_state"] = rules_state
	frame["cheating"] = bool(source_rules_state.source_team_cheating_state(rules_state, team_id).get("cheating", false))
	# Building.enabled (BuildingComp.java:77, `transient boolean
	# enabled = true;`) is what shouldConsume() returns
	# (BuildingComp.java:755-757), so the power graph reads it live
	# for this fracker (N2125); the tick preserves a disabled
	# fracker instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	# The frame carries the Building.items ItemModule
	# (frame["items"], Dictionary keyed by item name, the factory
	# precedent SourceFactoryBuildState.gd:89-101, the Separator
	# N2222 precedent); the tick preserves the held items instead
	# of resetting them -- no live intake fills them yet, so the
	# consume() in the updateTile advance (N2224) reads the frame
	# as-is.
	if not frame.has("items"):
		frame["items"] = {}
	return frame

static func _initial_frame() -> Dictionary:
	# The frame carries the Building.liquids LiquidModule
	# (frame["liquids"], a Dictionary in the
	# SourceLiquidModuleState shape, default {}): the
	# shouldConsume gate reads the result amount from it
	# (SolidPump.java:118, `return liquids.get(result) <
	# liquidCapacity - 0.01f;`). The driver syncs the live
	# sprite-meta store into the frame each tick; the pump
	# advance (N2224) fills it each tick from the updateTile
	# advance (Fracker.java:30-44 / SolidPump.java:121-141);
	# the gate reads the store as-is. The frame also carries
	# the Building.items ItemModule (frame["items"], Dictionary
	# keyed by item name, default {}): the fracker has items
	# (`hasItems = true;`, Fracker.java:11) and consume()
	# removes one sand from it (Fracker.java:33); no live
	# intake fills the items yet, so the advance reads the
	# frame as-is. The frame also carries the dump cursor
	# (frame["cdump"], `transient int cdump;`,
	# BuildingComp.java:68, default 0): the N2284 dump
	# advances it once per proximity iteration
	# (incrementDump, BuildingComp.java:1116-1121).
	return {"liquids": {}, "items": {}, "cdump": 0}

static func source_fracker_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the fracker frame meta key
	# ("source_fracker_building"). A Fracker sprite gets a
	# frame bound with the liquids + items keys ({} by default);
	# the live-loop tick fills its other keys every tick. Any other
	# block, or an already-bound sprite, binds nothing.
	if block == null or not _is_fracker_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_FRACKER_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_FRACKER_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_FRACKER_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_fracker_should_consume_state(frame: Dictionary, result_liquid: int, liquid_capacity: float) -> Dictionary:
	# FrackerBuild does NOT override shouldConsume (Fracker.java has no shouldConsume at all; Fracker extends SolidPump, Fracker.java:7, `public class Fracker extends SolidPump{`, and FrackerBuild extends SolidPumpBuild, Fracker.java:26, `public class FrackerBuild extends SolidPumpBuild{`), so it inherits SolidPumpBuild.shouldConsume verbatim (SolidPump.java:117, `public boolean shouldConsume(){` with `return liquids.get(result) < liquidCapacity - 0.01f;`, SolidPump.java:118): the fracker consumes only while its held result amount is below the liquid capacity minus 0.01f. The default (BuildingComp.java:755, `public boolean shouldConsume(){` with `return enabled;`) does NOT apply here. Unlike the Separator/Drill gates this one has NO `&& enabled` -- Java returns the bare capacity comparison, so the pure gate does NOT read frame["enabled"] at all (the driver already runs the machinery only when enabled). The result liquid arrives as its catalog id (resolved by the driver from liquid_id_by_name with the def constant "oil", `result = Liquids.oil;`, Blocks.java:2966; the class default is water, `public Liquid result = Liquids.water;`, SolidPump.java:22) and the capacity as the def constant 40f (`liquidCapacity = 40f;`, Blocks.java:2971; the class default is -1f, `public float liquidCapacity = -1f;`, Block.java:77) -- the catalog carries neither property for the oil-extractor. The amount comes from the shared liquid module helper (SourceLiquidModuleState.source_get_state, reused through a preload, NOT re-implemented) over the frame liquids key (the Building.liquids LiquidModule dict, default {} for a frame bound before this slice, amount 0.0 when the store has no entry for the result -- Java's liquids.get returns 0.0 for a liquid never added). When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`).
	var liquids: Dictionary = frame.get("liquids", {})
	var result_amount: float = 0.0
	if liquids.has("liquids") and result_liquid >= 0 and result_liquid < int(liquids["liquids"].size()):
		result_amount = float(source_liquid_module_state.source_get_state(liquids, result_liquid).get("amount", 0.0))
	return {"should_consume": result_amount < liquid_capacity - 0.01, "result_amount": result_amount}

static func source_fracker_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40,
	# `return build.power.status;`): the power consumer's
	# efficiency is the building's live power.status, and the
	# first pass folds it into the min efficiency
	# (BuildingComp.java:1969-1976, `for(var cons : block.
	# nonOptionalConsumers){` / `minEfficiency = Math.min(
	# minEfficiency, result);`). The graph update stamps
	# frame["power_status"] each tick (N2142); a missing stamp
	# folds to 1.0 before the first graph update, the assembler
	# fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`).
	# A block with no power consumer contributes no row. The
	# power consumer counts toward hasConsumers
	# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
	# so a fracker does not take the early return. The fracker
	# accumulator follows the folded efficiency
	# (Fracker.java:38, `accumulator += delta() * efficiency;`),
	# and its super.updateTile() runs the solid-pump speed fold
	# (SolidPump.java:121, `float maxPump = Math.min(liquidCapacity - typeLiquid(), pumpAmount * delta() * fraction * efficiency);`).
	# Documented limits: (1) power + liquid + item first
	# pass -- the liquid row live (N2255): the water
	# consumer (0.15f per frame, Blocks.java:2978) folds
	# into the min efficiency with the power row, and the
	# second pass removes amount * edelta * multiplier each
	# tick (ConsumeLiquid.java:37-39).
	# The item row live (N2268): the sand consumer
	# (consumeItem sand, Blocks.java:2976) folds its binary row
	# (ConsumeItems.efficiency, ConsumeItems.java:51-53,
	# 1 when >= 1 sand held, 0 otherwise) into the min
	# efficiency with the power + water rows; no live
	# intake fills frame["items"] yet (the "Fracker item
	# intake" DEFERRED entry stays), and the advance
	# removal is live since N2224 (one sand when the
	# accumulator reaches itemUseTime, Fracker.java:32-35).
	# The water-attribute / validTiles / boost fraction fill
	# is live (N2305, item (5) below); the folded
	# efficiency is the min over the *modeled* consumers
	# (power + water + sand). (2) shouldConsume gate live (N2207)
	# -- FrackerBuild inherits
	# SolidPumpBuild.shouldConsume() (SolidPump.java:117-119,
	# `return liquids.get(result) < liquidCapacity - 0.01f;`);
	# the pure gate (source_fracker_should_consume_state)
	# feeds should_consume to the machinery from the frame
	# liquids amount for the def result (oil) and the def
	# capacity (40f). The pump advance (N2224) fills the oil
	# store each tick (the updateTile advance,
	# Fracker.java:30-44 / SolidPump.java:121-141). (3)
	# updateTile advance live (N2224) -- accumulator /
	# itemUseTime consume / super.updateTile()
	# (Fracker.java:30-44) and warmup / pumpTime / lastPump /
	# maxPump / fraction (SolidPump.java:121-141, via the
	# reused N2220 pure function) advance each tick from
	# explicit fraction inputs (frame valid_tiles / boost /
	# attribute_env, default 0f); still deferred: the
	# sand intake (nothing fills frame["items"] live yet);
	# the live onProximityUpdate fill is live since N2305
	# (item (5) below). (4) dumpLiquid live (N2284)
	# -- dumpLiquid(result) runs after the advance in BOTH
	# updateTile branches: the if-branch dump (the
	# super.updateTile() dump, SolidPump.java:140, after the
	# pump add) and the else-branch dump (Fracker.java:42,
	# after the warmup decay + lastPump = 0), both at the
	# default scaling 2f (BuildingComp.java:877-878) through
	# the shared dump_liquid_state routing; the neighbour
	# entries are live-filled since N2408 (the tick scans the
	# live proximity before the dump), neighbour write-back live since N2371
	# (the shared helper lands the dumped oil in the handled
	# neighbour's store -- first handled index only, the
	# multi-recipient split defers), and the campaign unlock
	# waits for its own slice. The pure
	# N2220 itself still does not dump -- the SolidPump-driver
	# dump is N2286. (5) Fraction fill live (N2305) --
	# onProximityUpdate (SolidPump.java:150-159, inherited:
	# Fracker does NOT override it) recomputed each enabled
	# tick from frame proximity inputs
	# (frame["proximity_linked_tiles"], default [] -- no
	# tiles) and the N2224 attribute_env frame input
	# (default 0.0): the oil-extractor def sets
	# baseEfficiency 0f (Blocks.java:2973), so validTiles
	# stays 0; boost = sumAttribute(oil) / 9 with 0 for deep
	# floors (!floating && !placeableLiquid -- the def
	# leaves both at the Block class defaults false);
	# fraction = max(validTiles + boost + env, 0). The fill
	# delegates to the N2292 SolidPump pure through the
	# Fracker wrapper
	# (source_fracker_proximity_fraction_state) and stamps
	# valid_tiles / boost onto the frame BEFORE the advance
	# (Java order); the advance recomputes the fraction
	# from the stamped keys. Still deferred: the live
	# linked-tile scan, the live envAttrs read, and a
	# proximity-change trigger (Java runs onProximityUpdate
	# only when placement/proximity changes).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_fracker_liquid_consumer_row_state(frame: Dictionary, has_liquid_consumer: bool, liquid_id: int, amount: float, source_delta: float, time_scale: float, efficiency_scale: float, multiplier: float = 1.0) -> Dictionary:
	# ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47):
	# `float ed = build.edelta() * build.efficiencyScale();`
	# `if(ed <= 0.00000001f) return 0f;`
	# `return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);`
	# The first pass assumes efficiency 1f (BuildingComp.java:1965, `efficiency = optionalEfficiency = 1f;`), so edelta() = delta() = Time.delta * timeScale (`return Time.delta * timeScale;`, BuildingComp.java:1922-1924; `return efficiency * delta();`, BuildingComp.java:1927-1929 -- with efficiency 1f the two coincide). The def sets no multiplier (Block.java:1127-1129, `return consume(new ConsumeLiquid(liquid, amount));`), so the default multiplier 1f applies (`public Floatf<Building> multiplier = b -> 1f;`, Consume.java:18); the multiplier stays an explicit parameter (default 1.0) so the formula stays Java-exact. The liquid amount comes from the shared liquid module helper (SourceLiquidModuleState.source_get_state, reused through a preload, NOT re-implemented) over the frame liquids key, with the N2207 gate guard (frame has "liquids", id in bounds; amount 0.0 when the store has no entry for the liquid -- Java's liquids.get returns 0.0 for a liquid never added). The row shape mirrors the power row: {"has_liquid_row": bool, "row": {"result": float, "is_power": false}} -- is_power false, so the shared fold sets shouldConsumePower=false when the row is <= 1e-7 (BuildingComp.java:1972-1973, `if(cons != block.consPower && result <= 0.0000001f){` / `shouldConsumePower = false;`). A block with no liquid consumer contributes no row (the N2253 launch-pad precedent: launch-pad has no liquid consumer, advanced-launch-pad has oil).
	if not has_liquid_consumer:
		return {"has_liquid_row": false, "row": {}}
	var liquids: Dictionary = frame.get("liquids", {})
	var liquid_amount: float = 0.0
	if liquids.has("liquids") and liquid_id >= 0 and liquid_id < int(liquids["liquids"].size()):
		liquid_amount = float(source_liquid_module_state.source_get_state(liquids, liquid_id).get("amount", 0.0))
	var edelta: float = source_delta * time_scale
	var ed: float = edelta * efficiency_scale
	var result: float = 0.0
	if ed > 0.00000001:
		result = minf(liquid_amount / (amount * ed * multiplier), 1.0)
	return {"has_liquid_row": true, "row": {"result": result, "is_power": false}}

static func source_fracker_item_consumer_row_state(frame: Dictionary, has_item_consumer: bool, stacks: Array, multiplier: float = 1.0) -> Dictionary:
	# ConsumeItems.efficiency (ConsumeItems.java:51-53, `return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;`): BINARY 1/0, not a ratio -- 1 when the building is burning a trigger consumer or its item module holds every stack, 0 otherwise. consumeTriggerValid() is false at the base (BuildingComp.java:764-766, `public boolean consumeTriggerValid(){` with `return false;`) and no Fracker build overrides it (Fracker.java has no consumeTriggerValid; only ConsumeGeneratorBuild overrides it, ConsumeGenerator.java:152), so the trigger term is always false here. items.has (ItemModule.java:153-156, `if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;`) requires EVERY stack to hold round(amount * multiplier), with has(item, amount) = get(item) >= amount (ItemModule.java:126-128, `return get(item) >= amount;`); the port's item module is a Dictionary keyed by item name, so an unknown item reads 0 through the shared inventory helper (SourceDrillInventoryRuntimeState.item_count, reused through a preload, NOT re-implemented), the same outcome as the id-out-of-range branch. The multiplier defaults to 1f (Consume.java:18, `public Floatf<Building> multiplier = b -> 1f;`); the oil-extractor def sets none (`consumeItem(Items.sand);`, Blocks.java:2976, is one stack of 1: consumeItem(item) returns consumeItem(item, 1), Block.java:1167-1168). The row is REQUIRED (non-optional) -- the def never calls .boost() -- so it folds the FIRST pass (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`) and the shared fold sets shouldConsumePower=false when the row is <= 1e-7 (BuildingComp.java:1972-1973, `if(cons != block.consPower && result <= 0.0000001f){` / `shouldConsumePower = false;`). The stacks arrive explicit from the driver (the catalog consumeItem rows, [{"item": "sand", "amount": 1}] for the oil-extractor). No removal here: Consume.update is empty (Consume.java:52, `public void update(Building build){}`), so the second pass never removes items -- the sand is only removed by consume() in the updateTile advance (Fracker.java:32-35, live since N2224, `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));`, ConsumeItems.java:44-48). No live intake fills frame["items"] yet (the "Fracker item intake" DEFERRED entry stays), so a live fracker reads the frame as-is.
	if not has_item_consumer:
		return {"has_item_row": false, "row": {}}
	var items: Dictionary = frame.get("items", {})
	var result := 1.0
	for stack in stacks:
		var item_name: String = str(stack.get("item", ""))
		var needed: int = int(round(float(stack.get("amount", 0)) * multiplier))
		if inventory.item_count(items, item_name) < needed:
			result = 0.0
	if result <= 0.0:
		return {"has_item_row": true, "row": {"result": 0.0, "is_power": false}}
	return {"has_item_row": true, "row": {"result": 1.0, "is_power": false}}

static func source_fracker_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, result_liquid_id: int, liquid_capacity: float, pump_amount: float, item_use_time: float) -> Dictionary:
	# The updateTile advance (FrackerBuild.updateTile(),
	# Fracker.java:30-44). Fracker extends SolidPump
	# (Fracker.java:7, `public class Fracker extends SolidPump{`)
	# and FrackerBuild extends SolidPumpBuild (Fracker.java:26,
	# `public class FrackerBuild extends SolidPumpBuild{`), so
	# the frame shares the SolidPumpBuild keys (warmup /
	# pumpTime / lastPump / validTiles / boost,
	# SolidPump.java:90-94) plus the Fracker accumulator
	# (`public float accumulator;`, Fracker.java:27). The
	# fracker has items (`hasItems = true;`, Fracker.java:11).
	# The item use time is the def constant 60f
	# (`itemUseTime = 60f;`, Blocks.java:2974), overriding the
	# class default 100f (`public float itemUseTime = 100f;`,
	# Fracker.java:8). The result liquid is oil (`result =
	# Liquids.oil;`, Blocks.java:2966) and the capacity the
	# def constant 40f (`liquidCapacity = 40f;`,
	# Blocks.java:2971; the class default is -1f, `public
	# float liquidCapacity = -1f;`, Block.java:77).
	# pumpAmount arrives as a parameter (the driver passes the
	# def constant 0.25f, `pumpAmount = 0.25f;`,
	# Blocks.java:2969, overriding the Pump class default,
	# `public float pumpAmount = 0.2f;`, Pump.java:20)
	# because the advance REUSES the N2220 SolidPump pure
	# function for super.updateTile() (Fracker.java:37) -- it
	# does NOT copy the SolidPump logic (the N2221
	# cross-driver preload precedent). Each Java expr below
	# stays on ONE comment line (the N2148 lesson):
	# `if(efficiency > 0){` (Fracker.java:31).
	# `if(accumulator >= itemUseTime){` (Fracker.java:32 -- an `if`, not a `while`: at most one consume per tick).
	# `consume();` (Fracker.java:33 -- `public void consume(){` with `for(Consume cons : block.consumers){` / `cons.trigger(self());`, BuildingComp.java:1911-1915: only ConsumeItems overrides trigger, `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));`, ConsumeItems.java:44-48; the oil-extractor consumes one sand, `consumeItem(Items.sand);`, Blocks.java:2976, via `consumeItem(item)` -> `return consumeItem(item, 1);`, Block.java:1167-1168, and `return consume(new ConsumeItems(new ItemStack[]{new ItemStack(item, amount)}));`, Block.java:1171-1172, with the default multiplier `public Floatf<Building> multiplier = b -> 1f;`, Consume.java:18; ConsumePower and ConsumeLiquid keep the base no-op `public void trigger(Building build){}`, Consume.java:50. The removal clamps like Java, `amount = Math.min(amount, items[item.id]);`, ItemModule.java:258-263, through the shared inventory helper, the N2222 Separator precedent).
	# `accumulator -= itemUseTime;` (Fracker.java:34).
	# `super.updateTile();` (Fracker.java:37 -- the N2220 pure function: `float fraction = Math.max(validTiles + boost + (attribute == null ? 0 : attribute.env()), 0);` (SolidPump.java:124), `if(efficiency > 0 && typeLiquid() < liquidCapacity - 0.001f){` (SolidPump.java:126), `float maxPump = Math.min(liquidCapacity - typeLiquid(), pumpAmount * delta() * fraction * efficiency);` (SolidPump.java:127), `liquids.add(result, maxPump);` (SolidPump.java:128), `lastPump = maxPump / Time.delta;` (SolidPump.java:129), `warmup = Mathf.lerpDelta(warmup, 1f, 0.02f);` (SolidPump.java:130), `warmup = Mathf.lerpDelta(warmup, 0f, 0.02f);` (SolidPump.java:134), `lastPump = 0f;` (SolidPump.java:135), `pumpTime += warmup * edelta();` (SolidPump.java:138), `dumpLiquid(result);` (SolidPump.java:140 -- DEFERRED, covered by the N2220 entry)).
	# `accumulator += delta() * efficiency;` (Fracker.java:38 -- AFTER super.updateTile(), so the consume check above reads last tick's accumulator).
	# `warmup = Mathf.lerpDelta(warmup, 0f, 0.02f);` (Fracker.java:41 -- the else branch decays warmup ITSELF; it does NOT call super.updateTile(), so pumpTime also stands still).
	# `lastPump = 0f;` (Fracker.java:42).
	# `dumpLiquid(result);` (Fracker.java:42 -- live since N2284: the tick dumps after the advance in both branches; the brief/SCOPE/DEFERRED cite :43 is one line off, verified by grep).
	# The Arc formula, not a guess: lerpDelta(from, to,
	# progress) = lerp(from, to, clamp(progress * Time.delta))
	# with lerp = from + (to - from) * progress and clamp(value)
	# = clamp(value, 0, 1) (Mathf.java:401-404, 425-432); it
	# scales by RAW Time.delta, so timeScale touches neither
	# the warmup lerp nor lastPump. delta() = Time.delta *
	# timeScale (`return Time.delta * timeScale;`,
	# BuildingComp.java:1922-1924) and edelta() = efficiency *
	# delta() (`return efficiency * delta();`,
	# BuildingComp.java:1927-1929). source_delta is Time.delta
	# in ticks (seconds * 60 through game_source_delta, arc
	# Time.java:26), never raw seconds (the N2186/N2187/N2191
	# lesson: raw seconds run 60x slow). efficiency defaults
	# 0.0, the Java field default (BuildingComp.java:85
	# `transient float efficiency;`); accumulator / warmup /
	# pumpTime default 0.0, the Java build-field defaults
	# (Fracker.java:27, SolidPump.java:90-91). The fraction
	# inputs are explicit frame keys (valid_tiles / boost /
	# attribute_env, default 0f), read by the reused super
	# advance: the live onProximityUpdate fill
	# (SolidPump.java:150-159) is live since N2305 -- the
	# driver stamps valid_tiles / boost each enabled tick
	# before the advance.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var accumulator: float = float(frame.get("accumulator", 0.0))
	var warmup: float = float(frame.get("warmup", 0.0))
	var pump_time: float = float(frame.get("pump_time", 0.0))
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var delta: float = source_delta * time_scale
	var max_pump: float = 0.0
	var last_pump: float = 0.0
	var fraction: float = 0.0
	var next_warmup: float = warmup
	var next_pump_time: float = pump_time
	if efficiency > 0.0:
		if accumulator >= item_use_time:
			var removed: Dictionary = inventory.remove_item_state(items, SOURCE_FRACKER_CONSUME_ITEM, 1)
			items = removed.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
			accumulator -= item_use_time
		var advanced: Dictionary = source_solid_pump_state.source_solid_pump_update_tile_advance_state(frame, source_delta, time_scale, result_liquid_id, liquid_capacity, pump_amount)
		next_warmup = float(advanced["warmup"])
		next_pump_time = float(advanced["pump_time"])
		last_pump = float(advanced["last_pump"])
		max_pump = float(advanced["max_pump"])
		fraction = float(advanced["fraction"])
		accumulator += delta * efficiency
	else:
		next_warmup = lerpf(warmup, 0.0, clampf(SOURCE_FRACKER_WARMUP_RATE * source_delta, 0.0, 1.0))
		last_pump = 0.0
	return {"accumulator": accumulator, "warmup": next_warmup, "pump_time": next_pump_time, "last_pump": last_pump, "max_pump": max_pump, "fraction": fraction, "items": items}

static func source_fracker_proximity_fraction_state(linked_tiles: Array, attribute_env: float) -> Dictionary:
	# The live fraction fill for Fracker (SolidPumpBuild.
	# onProximityUpdate(), SolidPump.java:150-159, INHERITED:
	# Fracker does NOT override onProximityUpdate --
	# Fracker.java has no onProximityUpdate at all; Fracker
	# extends SolidPump (Fracker.java:7, `public class
	# Fracker extends SolidPump{`) and FrackerBuild extends
	# SolidPumpBuild (Fracker.java:26, `public class
	# FrackerBuild extends SolidPumpBuild{`), so the
	# oil-extractor runs the SolidPump proximity fill
	# verbatim. The pure DELEGATES to the N2292 SolidPump
	# pure (the N2221 cross-driver preload precedent -- the
	# N2224 advance already reuses the N2220 pure the same
	# way) with the oil-extractor def constants bound here,
	# so the driver calls the Fracker pure only and the
	# per-family pure boundary stays clean: size 3
	# (Blocks.java:2970, `size = 3;`), baseEfficiency 0f
	# (Blocks.java:2973, `baseEfficiency = 0f;`,
	# overriding the class default 1f, SolidPump.java:26,
	# `public float baseEfficiency = 1f;`), attribute
	# Attribute.oil (Blocks.java:2972, `attribute =
	# Attribute.oil;` -- the Fracker CLASS sets no attribute,
	# `public @Nullable Attribute attribute;`,
	# SolidPump.java:28, but the oil-extractor DEF does, so
	# has_attribute is true and the env adds), floating /
	# placeableLiquid at the Block class defaults false
	# (`public boolean floating = false;`, Block.java:212;
	# `public boolean placeableLiquid = false;`,
	# Block.java:152; the def overrides neither).
	# Because baseEfficiency is 0f, validTiles is ALWAYS 0
	# for the oil-extractor (`validTiles += baseEfficiency
	# / (size * size);`, SolidPump.java:157, adds 0 per
	# pumpable tile) -- the fraction is boost + env only.
	# Java runs onProximityUpdate only when placement /
	# proximity changes; the port recomputes the fill every
	# enabled tick from the frame inputs (the N2205 pump
	# re-scan precedent). Each Java expr below stays on ONE
	# comment line (the N2148 lesson):
	# `public void onProximityUpdate(){` (SolidPump.java:150).
	# `super.onProximityAdded();` (SolidPump.java:151 -- the parent hook, not a second updateTile).
	# `boost = sumAttribute(attribute, tile.x, tile.y) / size / size;` (SolidPump.java:153).
	# `validTiles = 0f;` (SolidPump.java:154).
	# `for(Tile other : tile.getLinkedTiles(tempTiles)){` (SolidPump.java:155).
	# `if(canPump(other)){` (SolidPump.java:156).
	# `validTiles += baseEfficiency / (size * size);` (SolidPump.java:157).
	# `protected boolean canPump(Tile tile){` (SolidPump.java:80).
	# `return tile != null && !tile.floor().isLiquid;` (SolidPump.java:81).
	# `float fraction = Math.max(validTiles + boost + (attribute == null ? 0 : attribute.env()), 0);` (SolidPump.java:124).
	# `public float sumAttribute(@Nullable Attribute attr, int x, int y){` (Block.java:575).
	# `if(attr == null) return 0;` (Block.java:576).
	# `if(tile == null) return 0;` (Block.java:578).
	# `return tile.getLinkedTilesAs(this, tempTiles)` (Block.java:579).
	# `.sumf(other -> !floating && !placeableLiquid && other.floor().isDeep() ? 0 : other.floor().attributes.get(attr));` (Block.java:580).
	# `public float env(){` (Attribute.java:31).
	# `if(Vars.state == null) return 0;` (Attribute.java:32).
	# `return Vars.state.envAttrs.get(this);` (Attribute.java:33).
	# `attribute = Attribute.oil;` (Blocks.java:2972).
	# `size = 3;` (Blocks.java:2970).
	# `baseEfficiency = 0f;` (Blocks.java:2973).
	# The two linked-tile scans use the same tile set
	# (Tile.java:474-525), so one linked_tiles input serves
	# both sums exactly (the N2292 note). Each entry is a
	# Dict {can_pump, attribute_value, is_deep}: the canPump
	# answer, the floor OIL attribute value, and the
	# deep-floor flag. The fill returns the fraction as a
	# pure result, but the driver stamps only valid_tiles /
	# boost onto the frame: the N2224 advance recomputes
	# the fraction from the stamped keys (Java order).
	return source_solid_pump_state.source_solid_pump_proximity_fraction_state(linked_tiles, SOURCE_FRACKER_SIZE, SOURCE_FRACKER_BASE_EFFICIENCY, attribute_env, false, false, true)

static func source_fracker_dump_liquid_state(frame: Dictionary, result_liquid_id: int, liquid_capacity: float, dump_neighbours: Array) -> Dictionary:
	# The dumpLiquid rows (FrackerBuild.updateTile(),
	# Fracker.java:30-44): BOTH branches end in
	# `dumpLiquid(result);` -- the if-branch through
	# `super.updateTile();` (Fracker.java:37), whose
	# SolidPump.updateTile ends in `dumpLiquid(result);`
	# (SolidPump.java:140, unconditional, after
	# `pumpTime += warmup * edelta();`, SolidPump.java:138),
	# and the else-branch directly (Fracker.java:42, after
	# `warmup = Mathf.lerpDelta(warmup, 0f, 0.02f);`
	# (Fracker.java:40) and `lastPump = 0f;`
	# (Fracker.java:41)). The brief/SCOPE/DEFERRED cite
	# line :43 for the else-branch dump -- one line off,
	# verified by grep (the method closes at :44).
	# dumpLiquid(Liquid) is the 2f overload
	# (`public void dumpLiquid(Liquid liquid){`,
	# BuildingComp.java:877, with `dumpLiquid(liquid, 2f);`,
	# BuildingComp.java:878), which delegates to the scaling
	# overload (`public void dumpLiquid(Liquid liquid, float scaling){`, BuildingComp.java:881, with `dumpLiquid(liquid, scaling, -1);`, BuildingComp.java:882) and then the output-dir impl (`public void dumpLiquid(Liquid liquid, float scaling, int outputDir){`, BuildingComp.java:886-908):
	# `int dump = this.cdump;` (BuildingComp.java:887).
	# `if(liquids.get(liquid) <= 0.0001f) return;` (BuildingComp.java:889 -- the early return runs BEFORE the loop, so an empty store leaves cdump untouched).
	# `if(!net.client() && state.isCampaign() && team == state.rules.defaultTeam) liquid.unlock();` (BuildingComp.java:891 -- the campaign unlock is NOT modeled: the frame carries no net/campaign state, so the pure passes false/false/false and the unlock waits for its own slice).
	# `for(int i = 0; i < proximity.size; i++){` (BuildingComp.java:893).
	# `incrementDump(proximity.size);` (BuildingComp.java:894 -- EVERY iteration, before the output-dir filter, so the cursor advances even when no neighbour takes anything).
	# `Building other = proximity.get((i + dump) % proximity.size);` (BuildingComp.java:896).
	# `if(outputDir != -1 && (outputDir + rotation) % 4 != relativeTo(other)) continue;` (BuildingComp.java:897 -- outputDir is -1 here, so the filter never skips).
	# `other = other.getLiquidDestination(self(), liquid);` (BuildingComp.java:899 -- the default returns self(), `public Building getLiquidDestination(Building from, Liquid liquid){` with `return self();`, BuildingComp.java:980-982, so a neighbour entry with no destination flag defaults to present).
	# `if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){` (BuildingComp.java:901).
	# `float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;` (BuildingComp.java:902).
	# `float fract = liquids.get(liquid) / block.liquidCapacity;` (BuildingComp.java:903 -- recomputed per neighbour from the RUNNING amount, after earlier transfers).
	# `if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);` (BuildingComp.java:905 -- scaling 2f, so the transfer is HALF the fraction gap times the capacity).
	# canDumpLiquid defaults to true
	# (`public boolean canDumpLiquid(Building to, Liquid liquid){` with `return true;`, BuildingComp.java:910-912).
	# transferLiquid (`public void transferLiquid(Building next, float amount, Liquid liquid){`, BuildingComp.java:914-921):
	# `float flow = Math.min(next.block.liquidCapacity - next.liquids.get(liquid), amount);` (BuildingComp.java:915).
	# `if(next.acceptLiquid(self(), liquid)){` (BuildingComp.java:917 -- the default acceptLiquid is `public boolean acceptLiquid(Building source, Liquid liquid){` with `return block.hasLiquids && block.consumesLiquid(liquid);`, BuildingComp.java:868-870, so a neighbour entry with no accepts flag defaults to NOT accepting).
	# `next.handleLiquid(self(), liquid, flow);` (BuildingComp.java:918).
	# `liquids.remove(liquid, flow);` (BuildingComp.java:919).
	# incrementDump (`public void incrementDump(int prox){`, BuildingComp.java:1116-1121):
	# `if(prox != 0){` (BuildingComp.java:1118).
	# `cdump = ((cdump + 1) % prox);` (BuildingComp.java:1119).
	# The dump cursor is the Building field
	# (`transient int cdump;`, BuildingComp.java:68, default
	# 0), carried on the frame ("cdump", default 0 for a
	# frame bound before this slice). The result liquid is
	# oil (`result = Liquids.oil;`, Blocks.java:2966) and the
	# capacity the def constant 40f (`liquidCapacity = 40f;`,
	# Blocks.java:2971). The dump itself runs through the
	# shared liquid-dump port
	# (SourceBuildingLiquidState.dump_liquid_state, which
	# supplies the transfer_liquid_state callable to
	# SourceBuildingLiquidDumpState.dump_liquid_state -- the
	# factory / scenario-pump precedent), with the cursor
	# callback from SourceBuildingItemDumpState.
	# increment_dump_cursor_state -- the pure does NOT
	# re-implement the routing, the fraction transfer, or the
	# accept gate. The pure N2220 is untouched: the Fracker
	# tick dumps AFTER the advance (one call site covers both
	# branches -- the advance already ran exactly one of them,
	# and the dump depends only on the post-advance store; in
	# the if-branch Java dumps before `accumulator += delta()
	# * efficiency;` (Fracker.java:38), which cannot affect
	# the dump). The neighbours arrive as frame inputs
	# (default [] -- no neighbours, the Java proximity.size
	# == 0 outcome, no transfer, cursor untouched): each
	# entry is a Dictionary with amount / capacity / accepts /
	# has_liquids / can_dump / liquids_present /
	# destination_present / relative_to; the live proximity
	# scan is live since N2408. The neighbour write-back
	# is live since N2371: the pure exposes the handled
	# neighbour index (dump_neighbour_index, from the shared
	# routing's handled_index -- the FIRST eligible neighbour
	# whose transfer actually moved liquid, -1 when nothing
	# moved) + the dumped liquid name (dumped_liquid, the def
	# constant "oil"), and the tick wires the shared
	# source_neighbour_liquid_write_back_state helper after
	# the dump when dumped_amount > 0. A dump that reaches
	# several neighbours reports only the first handled index,
	# so the write-back lands the total there -- the
	# per-neighbour split waits for its own slice. The store
	# write-back removes the dumped amount from a DUPLICATE
	# of the module dict (the pure never mutates its inputs)
	# through the shared liquid module helper
	# (source_remove_state, which clamps exactly like Java's
	# LiquidModule.remove); the driver persists the duplicate
	# to the frame + the sprite meta (the N2275 liquid-bridge
	# precedent). When nothing dumps the duplicate goes back
	# untouched -- the helper's add would flip the store's
	# "current" key even for a zero amount, so the removal
	# runs only when the dumped amount is non-zero.
	var cursor: int = int(frame.get("cdump", 0))
	var store: Dictionary = (frame.get("liquids", {}) as Dictionary).duplicate(true)
	if not store.has("liquids") or result_liquid_id < 0 or result_liquid_id >= int(store["liquids"].size()):
		return {"liquids_after": store, "dumped_amount": 0.0, "cursor_after": cursor, "dump_neighbour_index": -1, "dumped_liquid": SOURCE_FRACKER_RESULT_LIQUID}
	var current_amount: float = float(source_liquid_module_state.source_get_state(store, result_liquid_id).get("amount", 0.0))
	var relative_to: Array = []
	var destination_present: Array = []
	var other_has_liquids: Array = []
	var can_dump_liquid: Array = []
	var other_liquids_present: Array = []
	var other_amounts: Array = []
	var other_capacities: Array = []
	var other_accepts: Array = []
	for neighbour in dump_neighbours:
		var entry: Dictionary = neighbour if neighbour is Dictionary else {}
		relative_to.append(int(entry.get("relative_to", 0)))
		destination_present.append(bool(entry.get("destination_present", true)))
		other_has_liquids.append(bool(entry.get("has_liquids", false)))
		can_dump_liquid.append(bool(entry.get("can_dump", true)))
		other_liquids_present.append(bool(entry.get("liquids_present", false)))
		other_amounts.append(float(entry.get("amount", 0.0)))
		other_capacities.append(float(entry.get("capacity", 0.0)))
		other_accepts.append(bool(entry.get("accepts", false)))
	var dumped: Dictionary = source_building_liquid_state.dump_liquid_state(SOURCE_FRACKER_RESULT_LIQUID, 2.0, -1, current_amount, false, false, false, dump_neighbours.size(), cursor, 0, relative_to, destination_present, other_has_liquids, can_dump_liquid, other_liquids_present, other_amounts, other_capacities, other_accepts, liquid_capacity, Callable(source_building_item_dump_state, "increment_dump_cursor_state"))
	var amount_after: float = float(dumped.get("current_liquid_amount_after", current_amount))
	var dumped_amount: float = current_amount - amount_after
	if dumped_amount != 0.0:
		var cache_sums: Array = []
		if store.get("flow") != null:
			cache_sums.resize(int(store["liquids"].size()))
			cache_sums.fill(0.0)
		source_liquid_module_state.source_remove_state(store, result_liquid_id, dumped_amount, cache_sums)
	return {"liquids_after": store, "dumped_amount": dumped_amount, "cursor_after": int(dumped.get("final_cdump", cursor)), "dump_neighbour_index": int(dumped.get("handled_index", -1)), "dumped_liquid": SOURCE_FRACKER_RESULT_LIQUID}

static func source_fracker_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the fracker tick wiring every tick
	# (FrackerBuild.updateTile(), Fracker.java:30, gates on
	# `if(efficiency > 0){` and runs super.updateTile(), so the
	# accumulator and the solid-pump speed read the folded
	# efficiency; the solid-pump driver never ticks Fracker
	# implementations, so this driver is the fracker tick):
	# each placed Fracker build gets its frame keys refreshed
	# from the live rules, so the frame's cheating flag tracks
	# team.rules().cheat and the consumption machinery skips
	# consumption for a cheating team. The frame is bound at
	# placement; a sprite that somehow lacks one gets it bound
	# here instead of crashing the loop.
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
	var liquid_id_by_name: Dictionary = source_content_registry_runtime_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {})
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if not _is_fracker_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_fracker_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_fracker_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids, initialized
		# at placement), so the driver syncs the reference
		# into the frame each tick BEFORE the fold, and the
		# pure gate reads the result amount from it while the
		# pure liquid row (N2255) reads the water amount.
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a fracker with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the accumulator fold (Fracker.java:38)
		# and the super.updateTile() speed fold
		# (SolidPump.java:121) follow it. The power consumer
		# counts toward hasConsumers (Block.java:1449,
		# `hasConsumers = consumers.length > 0;`), so a fracker
		# does not take the early return. A fracker with no power
		# consumer is untouched: the tick models the power +
		# water + sand consumers (N2255 folds the liquid row
		# into the first pass, N2268 folds the sand item row);
		# the water-attribute / validTiles / boost fraction
		# fill is live since N2305 (the fill runs before the
		# advance each enabled tick, item (5) in the
		# power-row limits), and FrackerBuild inherits
		# SolidPumpBuild.shouldConsume() (`return
		# liquids.get(result) < liquidCapacity - 0.01f;`,
		# SolidPump.java:117-119) -- N2207 feeds the live gate
		# to the machinery (the pure gate is
		# source_fracker_should_consume_state, fed the frame
		# plus the resolved result id and the def capacity);
		# the N2153 RED decision is resolved. The gate has no
		# enabled term (Java returns the bare capacity
		# comparison); the outer guard below already runs the
		# machinery only when enabled.
		# productionValid is the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		# The source delta is Time.delta in ticks and timeScale
		# reads live from the sprite meta (see the N2224 advance
		# comment below); both are computed once here because
		# the liquid row's first pass needs them too, and the
		# advance below reuses them.
		var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var result_liquid_id: int = int(liquid_id_by_name.get(SOURCE_FRACKER_RESULT_LIQUID, -1))
			var gate: Dictionary = source_fracker_should_consume_state(frame, result_liquid_id, SOURCE_FRACKER_LIQUID_CAPACITY)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_fracker_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			# The liquid consumer reads live since N2255: a
			# fracker with a liquid consumer folds the pure
			# liquid row into the first pass (ConsumeLiquid.
			# efficiency, ConsumeLiquid.java:42-47), so the
			# folded efficiency is the min over power + water
			# and the shared fold stops power draw when the
			# liquid row is <= 1e-7. The water id resolves
			# from the catalog with the def constant "water"
			# (`consumeLiquid(Liquids.water, 0.15f);`,
			# Blocks.java:2978 -- 0.15f per frame, = 9/s).
			var water_liquid_id: int = int(liquid_id_by_name.get(SOURCE_FRACKER_CONSUME_LIQUID, -1))
			var has_liquid_consumer: bool = bool(block.properties.has("consumeLiquid"))
			var liquid_row: Dictionary = source_fracker_liquid_consumer_row_state(frame, has_liquid_consumer, water_liquid_id, SOURCE_FRACKER_CONSUME_LIQUID_AMOUNT, source_delta, time_scale, float(frame.get("efficiency_scale", 1.0)))
			if bool(liquid_row.get("has_liquid_row", false)):
				required_results.append(liquid_row.get("row", {}))
			# The item consumer reads live since N2268: a
			# fracker with an item consumer folds the pure
			# item row into the first pass (ConsumeItems.
			# efficiency, ConsumeItems.java:51-53, binary
			# 1/0), so the folded efficiency is the min over
			# power + water + sand and the shared fold stops
			# power draw when the item row is <= 1e-7. The
			# stacks come from the catalog consumeItem rows
			# ([{"item": "sand", "amount": 1}] for the
			# oil-extractor, `consumeItem(Items.sand);`,
			# Blocks.java:2976 -- consumeItem(item) is one
			# stack of 1, Block.java:1167-1168). No removal
			# here: Consume.update is empty (Consume.java:52),
			# so the second pass never removes items -- the
			# sand is only removed by consume() in the
			# updateTile advance (Fracker.java:32-35, live
			# since N2224).
			var has_item_consumer: bool = bool(block.properties.has("consumeItem"))
			var item_stacks: Array = block.properties.get("consumeItem", [])
			var item_row: Dictionary = source_fracker_item_consumer_row_state(frame, has_item_consumer, item_stacks)
			if bool(item_row.get("has_item_row", false)):
				required_results.append(item_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# Second pass (N2255): ConsumeLiquid.update removes
			# `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));`
			# (ConsumeLiquid.java:37-39), only when update &&
			# efficiency > 0 (`if(update && efficiency > 0){`,
			# BuildingComp.java:1999, with `for(var cons : block.updateConsumers){` / `cons.update(self());` at :2000-2001), and edelta comes from the FOLDED efficiency (`return efficiency * delta();`, BuildingComp.java:1927-1929 -- NOT the first-pass 1f assumption). The AdjacentFactory updates-array precedent (SourceAdjacentFactoryBuildState.gd:382) does not fit: it passes bound RuntimeConsumer actors with update(self_state) methods (N2115/N2116), and this driver is pure-function based with no consumer actors -- so the removal is direct, through the shared liquid module helper (the PayloadLoader source_remove_state precedent), which clamps exactly like Java's LiquidModule.remove (`add(liquid, Math.max(-amount, -liquids[liquid.id]));`, LiquidModule.java:125-128). The multiplier is the default 1f (Consume.java:18), so the removal is amount * folded edelta.
			if should_consume and valid and float(frame.get("efficiency", 0.0)) > 0.0 and has_liquid_consumer and water_liquid_id >= 0:
				var liquids_store: Dictionary = frame.get("liquids", {})
				if liquids_store.has("liquids") and water_liquid_id < int(liquids_store["liquids"].size()):
					var folded_edelta: float = float(frame.get("efficiency", 0.0)) * source_delta * time_scale
					var remove_amount: float = SOURCE_FRACKER_CONSUME_LIQUID_AMOUNT * folded_edelta
					var cache_sums: Array = []
					if liquids_store.get("flow") != null:
						cache_sums.resize(int(liquids_store["liquids"].size()))
						cache_sums.fill(0.0)
					source_liquid_module_state.source_remove_state(liquids_store, water_liquid_id, remove_amount, cache_sums)
		# N2224: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274,
		# `updateConsumption();`, then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2278; noUpdateDisabled defaults
		# false, Block.java:170, `public boolean noUpdateDisabled = false;`),
		# so a disabled fracker freezes its accumulator /
		# warmup / pumpTime. The source delta is Time.delta in
		# ticks: game_source_delta(game, seconds) is seconds * 60
		# (arc Time.java:26), never raw seconds -- computed once
		# above the consumption block (the liquid row's first
		# pass needs it too) and reused here. timeScale reads
		# live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float timeScale = 1f, timeScaleDuration;`).
		# The advance reuses the N2220 SolidPump pure function
		# for super.updateTile() (Fracker.java:37) with the
		# oil-extractor pump amount 0.25f (Blocks.java:2969),
		# and removes one sand through the shared inventory
		# helper when the accumulator reaches the def item use
		# time 60f (Blocks.java:2974). The advance mutates the
		# frame liquids store in place (the module dict is a
		# reference to the sprite meta store) and returns the
		# advanced scalars + items, which the driver writes back
		# to the frame.
		if bool(frame.get("enabled", true)):
			# N2305: the live fraction fill runs BEFORE the
			# advance (Java order: onProximityUpdate stamps
			# validTiles / boost, SolidPump.java:150-159, and
			# updateTile reads them at :124 -- Fracker
			# inherits onProximityUpdate from SolidPumpBuild,
			# Fracker.java has no override). Java runs it only
			# when placement/proximity changes; the port
			# recomputes the fill every enabled tick from the
			# frame inputs (the N2205 pump re-scan precedent).
			# The linked tiles are frame inputs (default [] --
			# no tiles, the Java empty-proximity outcome)
			# until a live tile scan lands; the attribute env
			# is the N2224 frame input (default 0.0). The fill
			# delegates to the N2292 SolidPump pure through
			# the Fracker wrapper, which binds the
			# oil-extractor def constants (size 3,
			# baseEfficiency 0f, attribute oil); the driver
			# never calls the SolidPump pure directly. The
			# fill stamps valid_tiles / boost onto the frame;
			# the fraction is recomputed by the N2224 advance
			# from the stamped keys.
			var proximity_tiles: Array = frame.get("proximity_linked_tiles", [])
			var fraction_filled: Dictionary = source_fracker_proximity_fraction_state(proximity_tiles, float(frame.get("attribute_env", 0.0)))
			frame["valid_tiles"] = fraction_filled["valid_tiles"]
			frame["boost"] = fraction_filled["boost"]
			var advance_result_id: int = int(liquid_id_by_name.get(SOURCE_FRACKER_RESULT_LIQUID, -1))
			var advanced: Dictionary = source_fracker_update_tile_advance_state(frame, source_delta, time_scale, advance_result_id, SOURCE_FRACKER_LIQUID_CAPACITY, SOURCE_FRACKER_PUMP_AMOUNT, SOURCE_FRACKER_ITEM_USE_TIME)
			frame["accumulator"] = advanced["accumulator"]
			frame["warmup"] = advanced["warmup"]
			frame["pump_time"] = advanced["pump_time"]
			frame["last_pump"] = advanced["last_pump"]
			frame["max_pump"] = advanced["max_pump"]
			frame["fraction"] = advanced["fraction"]
			frame["items"] = advanced["items"]
			# N2284: dumpLiquid(result) runs after the advance
			# in BOTH updateTile branches (the if-branch dump
			# is the super.updateTile() dump,
			# SolidPump.java:140, after the pump add; the
			# else-branch dump is Fracker.java:42, after the
			# warmup decay + lastPump = 0) -- one call site,
			# because the advance above already ran exactly
			# one branch and the dump depends only on the
			# post-advance store (the accumulator advance in
			# between cannot affect it). The pure returns a
			# fresh liquids dict, so the driver persists it to
			# the frame AND the sprite meta (the N2275
			# liquid-bridge precedent -- the frame syncs from
			# the meta each tick, so a frame-only write-back
			# would be lost next tick) plus the advanced
			# cdump. The neighbour entries are live-filled since
			# N2408 (the tick scans the live proximity BEFORE the
			# dump pure reads them; a frame with no fill still
			# reads the frame input as-is, default [] -- no
			# neighbours, the Java proximity.size == 0 outcome).
			# Supplied entries WIN (the N2381 precedent): the
			# fill runs only when the frame carries no
			# dump_liquid_neighbours key -- the N2284 proof seeds
			# the array by hand, so a fill there would overwrite
			# the seed. A frame the fill already stamped
			# (dump_liquid_neighbours_live -- port bookkeeping,
			# not Java state) refreshes every tick, so a
			# later-placed neighbour joins the array and a
			# removed one leaves it. The tick reads the
			# origin_cell meta inline as fill_cell (cell is
			# bound after the enabled block, the N2363 note)
			# and the catalog size.
			var has_supplied_dump_liquid_neighbours: bool = frame.has("dump_liquid_neighbours")
			if not has_supplied_dump_liquid_neighbours or bool(frame.get("dump_liquid_neighbours_live", false)):
				var fill_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
				var dump_filled: Dictionary = source_fracker_dump_liquid_neighbour_live_fill_state(game, fill_cell, int(block.properties.get("size", 1)), advance_result_id)
				frame["dump_liquid_neighbours"] = dump_filled.get("dump_liquid_neighbours", [])
				frame["dump_liquid_neighbours_live"] = true
			var dump_neighbours: Array = frame.get("dump_liquid_neighbours", [])
			var dumped: Dictionary = source_fracker_dump_liquid_state(frame, advance_result_id, SOURCE_FRACKER_LIQUID_CAPACITY, dump_neighbours)
			frame["liquids"] = dumped["liquids_after"]
			sprite.set_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, dumped["liquids_after"])
			frame["cdump"] = dumped["cursor_after"]
			# N2371: neighbour write-back -- the shared
			# source_neighbour_liquid_write_back_state helper
			# lands the dumped oil in the handled neighbour's
			# store (dumpLiquid's next.handleLiquid,
			# BuildingComp.java:918) after the dump write-back
			# above, when something dumped. The handled index
			# is a ring index (index i is ring cell i, the
			# N2353 convention), so the live fill must fill
			# frame["dump_liquid_neighbours"] in ring order;
			# the tick reads the origin_cell meta inline as
			# dump_cell (cell is bound after the enabled block,
			# the N2363 note) and the catalog size. A failed
			# write-back (no sprite / no frame / no liquids
			# store) drops the oil -- the routing already
			# decided, so there is no fallback to the fracker's
			# own store (the N2353 precedent). A dump that
			# reaches several neighbours lands the total in
			# the first handled one -- the per-neighbour split
			# waits for its own slice.
			if float(dumped.get("dumped_amount", 0.0)) > 0.0:
				var dump_index: int = int(dumped.get("dump_neighbour_index", -1))
				if dump_index >= 0:
					var dump_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
					source_building_liquid_state.source_neighbour_liquid_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid", SOURCE_FRACKER_RESULT_LIQUID)), float(dumped.get("dumped_amount", 0.0)))
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}

static func source_fracker_dump_liquid_neighbour_live_fill_state(game: Object, cell: Vector2i, size: int, result_liquid_id: int) -> Dictionary:
	# The dumpLiquid neighbour live fill (N2408, DEFERRED
	# #230): the N2284 dump rows read the neighbour entries
	# as frame inputs (default [] -- no neighbours, the Java
	# proximity.size == 0 outcome), so a live fracker with
	# no fill never dumped. This fill scans the live
	# proximity BEFORE the dump pure and fills the neighbour
	# dict array from the live neighbour frames, in ring
	# order (index i is ring cell i, the N2353 convention --
	# the ring comes from source_block_proximity_cells_state,
	# the sprite from block_sprite_at_cell, the frame from
	# the first SOURCE_CONSUMER_FRAME_META_KEYS meta on the
	# sprite, the N2353/N2371 resolution path):
	# `Building other = proximity.get((i + dump) % proximity.size);`
	# The dumped liquid is the fixed def result oil -- the
	# Fracker always dumps its def result (Blocks.java:2966),
	# not liquids.current() (the N2394 unloader case) -- so
	# the fill takes the result liquid id as a param, like
	# the N2284 dump pure, and matches the consumeLiquid
	# rows against the def constant name. The frame carries
	# nothing the fill needs, so it is not a param. The
	# amount is the neighbour frame liquids module's amount
	# for the result id, the capacity is the neighbour def's
	# liquidCapacity (the ofract denominator):
	# `float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;`
	# A neighbour frame with no liquids store reports
	# capacity 0.0 (the N2371 no_liquids_store precedent);
	# the :901 gate needs the store too:
	# `if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){`
	# The accepts/canDump verdicts come from the DEFAULT
	# BuildingComp gates -- acceptLiquid is hasLiquids AND
	# consumesLiquid:
	# `public boolean acceptLiquid(Building source, Liquid liquid){`
	# `return block.hasLiquids && block.consumesLiquid(liquid);`
	# and canDumpLiquid defaults to true:
	# `public boolean canDumpLiquid(Building to, Liquid liquid){`
	# The consumes read is the liquidFilter:
	# `public boolean consumesLiquid(Liquid liq){`
	# `return liquidFilter[liq.id];`
	# which the port represents as the catalog consumeLiquid
	# rows. The destination defaults to present (the default
	# getLiquidDestination returns self()):
	# `public Building getLiquidDestination(Building from, Liquid liquid){`
	# and relative_to is 0 (outputDir is -1, so the filter
	# never reads it). The liquid capacity default is the
	# 10.0 port precedent (SourceFactoryBuildState) when the
	# catalog carries no liquidCapacity key -- Java computes
	# it in Block.init:
	# `liquidCapacity = Mathf.round(10f * consumeAmount);`
	# (min 10f, since consumeAmount starts at 1f). Per-block
	# overrides are OUT of scope: a neighbour with a modeled
	# override is evaluated with the DEFAULT gate here (the
	# override dispatch is a follow-through note). A
	# neighbour with no frame (no sprite / unknown def /
	# conduit / no meta-key frame) reports the no-frame
	# outcome -- 0.0 / 0.0 / false / false / false / false /
	# false / 0 -- the N2353/N2371 no-frame precedent (a
	# routed liquid to a frameless neighbour drops, so the
	# fill closes the gates and nothing routes there). A
	# conduit is no-frame because its acceptLiquid is a
	# per-block override (Conduit.java:242-244, out of
	# scope) and the DEFAULT gate would reject it anyway (a
	# conduit consumes no liquid). Catalog gap (NOT fixed):
	# 30 defs carry consumeLiquid rows but lack the
	# hasLiquids key (e.g. electrolyzer, advanced-launch-pad)
	# -- the fill reads the catalog key with the Java field
	# default false (the N2394 precedent). Two ring-model
	# notes: Java updateProximity dedupes multi-cell
	# neighbours (`//using a set to prevent duplicates`,
	# BuildingComp.java:1879-1900) and keeps same-team
	# buildings only (`other.team != team` skips), while the
	# ring reports a multi-cell neighbour at each of its
	# ring cells with no team filter -- the N2353 / N2371
	# ring convention this fill mirrors (a delivery to
	# either index lands in the same frame). Dedup + the
	# team filter wait for a shared ring-geometry slice.
	# The frame-key list comes from a runtime load (the
	# N2371/BeamDrill precedent), NOT a preload: a preload
	# line above the tick would shift the :633 frame-sync
	# pin (test_c07_fracker_cite_sweep), and this pure lives
	# after the tick function for the same reason. (The
	# direct preload is also cycle-free -- the 105-file
	# power-graph transitive closure does not contain this
	# file -- but the pin rules it out.)
	var ring: Array = source_block_geometry.source_block_proximity_cells_state(size, cell.x, cell.y).get("cells", [])
	var power_graph_state = load("res://src/game/SourcePlacedPowerGraphState.gd")
	var blocks_by_id: Dictionary = {}
	if game != null:
		var catalog: Variant = game.get("content_catalog")
		if catalog != null:
			for registered_block in catalog.get_many("block"):
				blocks_by_id[registered_block.id] = registered_block
	var neighbours: Array = []
	for neighbour_cell in ring:
		var amount := 0.0
		var capacity := 0.0
		var accepts := false
		var has_liquids := false
		var can_dump := false
		var liquids_present := false
		var destination_present := false
		var relative_to := 0
		var sprite: Variant = null
		if game != null:
			sprite = game.call("block_sprite_at_cell", neighbour_cell)
		if sprite != null:
			var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
			var is_conduit: bool = sprite.has_meta(source_building_liquid_state.SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY) or source_building_liquid_state.SOURCE_NEIGHBOUR_CONDUIT_BLOCK_IDS.has(block_id)
			if not is_conduit and blocks_by_id.has(block_id):
				var neighbour_block = blocks_by_id[block_id]
				var neighbour_frame: Dictionary = {}
				var has_neighbour_frame := false
				for meta_key in power_graph_state.SOURCE_CONSUMER_FRAME_META_KEYS:
					if not sprite.has_meta(meta_key):
						continue
					var candidate: Variant = sprite.get_meta(meta_key)
					if candidate is Dictionary:
						neighbour_frame = candidate
						has_neighbour_frame = true
						break
				if has_neighbour_frame:
					var neighbour_properties = neighbour_block.properties
					can_dump = true
					destination_present = true
					has_liquids = bool(neighbour_properties.get("hasLiquids", false))
					var neighbour_liquids: Variant = neighbour_frame.get("liquids", null)
					var neighbour_amounts: Variant = null
					if neighbour_liquids is Dictionary:
						neighbour_amounts = (neighbour_liquids as Dictionary).get("liquids", null)
					if neighbour_amounts is Array:
						liquids_present = true
						capacity = float(neighbour_properties.get("liquidCapacity", 10.0))
						if result_liquid_id >= 0 and result_liquid_id < (neighbour_amounts as Array).size():
							amount = float(source_liquid_module_state.source_get_state(neighbour_liquids, result_liquid_id).get("amount", 0.0))
					var consumes_liquid := false
					for row in neighbour_properties.get("consumeLiquid", []):
						if not (row is Dictionary):
							continue
						if str(row.get("liquid", "")) == SOURCE_FRACKER_RESULT_LIQUID:
							consumes_liquid = true
							break
					accepts = has_liquids and consumes_liquid
		neighbours.append({"amount": amount, "capacity": capacity, "accepts": accepts, "has_liquids": has_liquids, "can_dump": can_dump, "liquids_present": liquids_present, "destination_present": destination_present, "relative_to": relative_to})
	return {"dump_liquid_neighbours": neighbours}
