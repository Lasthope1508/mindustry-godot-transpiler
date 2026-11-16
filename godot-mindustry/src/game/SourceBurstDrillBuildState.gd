extends RefCounted
class_name SourceBurstDrillBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_drill_inventory_runtime_state := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
const source_building_item_state := preload("res://src/game/SourceBuildingItemState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")

# The BurstDrill implementation (BurstDrill.java:17, `public class
# BurstDrill extends Drill{`): eruption-drill (consumePower 6f,
# hydrogen 4f/60f + cyanogen 0.75f/60f booster, liquidBoostIntensity
# 2f, drillTime 281.25f, tier 7, size 5, itemCapacity 60) and
# impact-drill (consumePower 160f/60f, water 10f/60f + ozone 3f/60f
# booster, liquidBoostIntensity 1.75f, drillTime 720f, tier 6, size
# 4, itemCapacity 40). Both havePower=true. BurstDrillBuild extends
# DrillBuild, so a burst drill reuses the drill frame meta key
# ("source_drill_building", bound by the drill proximity path); the
# base-Drill tick driver never ticks it (SourceDrillConsumption-
# RuntimeState.gd gates on the base Drill generated class), so this
# driver is the burst-drill tick.
const SOURCE_BURST_DRILL_BUILD_IMPLEMENTATIONS := ["BurstDrill"]
const SOURCE_BURST_DRILL_BUILDING_META_KEY := "source_drill_building"
# BurstDrill.java:26, `public float invertedTime = 200f;` -- the
# invert-time decay divisor (BurstDrill.java:81, `if(invertTime > 0f) invertTime -= delta() / invertedTime;`).
const SOURCE_BURST_DRILL_INVERTED_TIME := 200.0
# BurstDrill.java:89, the smoothProgress lerpDelta rate 0.1f
# (`smoothProgress = Mathf.lerpDelta(smoothProgress, progress / (drillTime - 20f), 0.1f);`), and
# BurstDrill.java:92/:101, the warmup approachDelta rate 0.01f
# (`warmup = Mathf.approachDelta(warmup, progress / drillTime, 0.01f);` /
# `warmup = Mathf.approachDelta(warmup, 0f, 0.01f);`).
const SOURCE_BURST_DRILL_SMOOTH_PROGRESS_RATE := 0.1
const SOURCE_BURST_DRILL_WARMUP_RATE := 0.01
# BurstDrill.java:89, `progress / (drillTime - 20f)` -- the
# smoothProgress target subtracts 20 ticks from the drill time.
const SOURCE_BURST_DRILL_SMOOTH_PROGRESS_OFFSET := 20.0
# The per-def drillTime / liquidBoostIntensity (Blocks.java):
# eruption-drill `drillTime = 281.25f;` (:3095) /
# `liquidBoostIntensity = 2f;` (:3115), impact-drill `drillTime = 60f * 12f;` (:3072, 720f) /
# `liquidBoostIntensity = 1.75f;` (:3084). The catalog carries
# eruption's drillTime but NOT impact's (the `60f * 12f`
# expression is unevaluated) and neither def's
# liquidBoostIntensity, so the driver reads these tables,
# falling back to the catalog drillTime and the Drill class
# defaults (`public float drillTime = 300;`, Drill.java:36;
# `public float liquidBoostIntensity = 1.6f;`, Drill.java:38).
const SOURCE_BURST_DRILL_DRILL_TIME := {"eruption-drill": 281.25, "impact-drill": 720.0}
const SOURCE_BURST_DRILL_LIQUID_BOOST_INTENSITY := {"eruption-drill": 2.0, "impact-drill": 1.75}
# BurstDrill.java:83, `if(timer(timerDump, dumpTime / timeScale)){` -- the
# dump interval is dumpTime / timeScale with `public int dumpTime = 5;`
# (Block.java:438) and `protected final int timerDump = timers++;`
# (Block.java:436). NO def overrides dumpTime anywhere in upstream
# (grep: the only definition is Block.java:438), so the driver reads
# one constant for both defs. The threshold DIVIDES by timeScale
# (unlike the RepairTurret literal-20 timer, N2280).
const SOURCE_BURST_DRILL_DUMP_TIME := 5.0
# Both defs `drillMultipliers.put(Items.beryllium, 2f);`
# (Blocks.java:3083/:3114): beryllium drills twice as fast,
# every other item drills at 1f (ObjectFloatMap.get(item, 1f),
# BurstDrill.java:54, `return drillTime / drillMultipliers.get(item, 1f);`).
const SOURCE_BURST_DRILL_BERYLLIUM_MULTIPLIER := 2.0

static func _is_burst_drill_build_implementation(implementation: String) -> bool:
	return SOURCE_BURST_DRILL_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_burst_drill_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The burst-drill tick wires the frame keys the consumption
	# path reads (the N2148 turret pattern): block_implementation
	# is the block's implementation (BurstDrill.java:17, `public
	# class BurstDrill extends Drill{`), team_id and rules_state
	# are what Java reads as b.team and state.rules, and cheating
	# is the team's live TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's burst drill
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
	# for this burst drill (N2125); the tick preserves a disabled
	# burst drill instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {"liquids": {}, "timer_dump_elapsed": 0.0, "cdump": 0}

static func source_burst_drill_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement through the drill proximity path (the same path
	# that binds the base-Drill frames) under the drill frame meta
	# key ("source_drill_building", BurstDrillBuild extends
	# DrillBuild, BurstDrill.java:17). A BurstDrill sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_burst_drill_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_BURST_DRILL_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_BURST_DRILL_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_BURST_DRILL_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_burst_drill_should_consume_state(frame: Dictionary, item_capacity: int) -> Dictionary:
	# BurstDrillBuild.shouldConsume() (BurstDrill.java:128, `public boolean shouldConsume(){` with
	# `return items.total() <= itemCapacity - dominantItems && enabled;`, BurstDrill.java:129): the burst
	# drill consumes only while its items total fits the remaining capacity AFTER reserving the
	# dominant-items burst AND it is enabled. The `<=` (not `<`) and the `- dominantItems` are the
	# override's whole point -- the base-Drill gate (Drill.java:247-249,
	# `return items.total() < itemCapacity && enabled && dominantItem != null;`) does NOT apply to
	# BurstDrill: `public class BurstDrill extends Drill{` (BurstDrill.java:17) and
	# `public class BurstDrillBuild extends DrillBuild{` (BurstDrill.java:70), so the override wins.
	# The gate reads the SHARED drill frame ("source_drill_building"): the drill proximity path binds
	# it at placement (SourceWorldTerrainRuntimeState calls SourceDrillConsumptionRuntimeState.
	# source_on_proximity_update_state, which binds the full _initial_frame with items/dominant_item/
	# dominant_items/enabled) and sets dominant_items from the ore count (`public int dominantItems;`,
	# Drill.java:243, set at :277, `dominantItems = returnCount;`, via onProximityUpdate -> countOre),
	# so the burst-drill bind in the tick returns applied=false and the gate reads the shared keys.
	# itemCapacity is the block property (eruption `itemCapacity = 60;`, impact `itemCapacity = 40;`,
	# Blocks.java; Block.java:75 default `public int itemCapacity = 10;`), passed in by the driver.
	# The items total reuses the shared inventory helper (SourceDrillInventoryRuntimeState.items_total),
	# not a second summation. A missing items map reads empty, a missing dominant_items reads 0, a
	# missing enabled reads true (the Java field defaults). When the gate is false, updateConsumption
	# folds efficiency to 0 (BuildingComp.java:1960,
	# `boolean update = shouldConsume() && productionValid();`, with BuildingComp.java:1992-1994,
	# `if(!update){` / `efficiency = optionalEfficiency = 0f;`).
	var items_total: int = source_drill_inventory_runtime_state.items_total(frame.get("items", {}))
	var dominant_items: int = int(frame.get("dominant_items", 0))
	var enabled: bool = bool(frame.get("enabled", true))
	return {"should_consume": items_total <= item_capacity - dominant_items and enabled, "items_total": items_total}

static func source_burst_drill_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
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
	# so a burst drill does not take the early return. The
	# burst-drill speed follows the folded efficiency
	# (BurstDrill.java:94, `float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;`).
	# Documented limits: (1) liquid rows LIVE (N2257) -- the
	# required + booster ConsumeLiquid rows fold through the
	# pure liquid row (source_burst_drill_liquid_consumer_row_state,
	# ConsumeLiquid.efficiency, ConsumeLiquid.java:42-47) with
	# the second-pass removal (ConsumeLiquid.update,
	# ConsumeLiquid.java:37-39): impact-drill water 10f/60f
	# REQUIRED (Blocks.java:3089) + ozone 3f/60f booster
	# (Blocks.java:3090), eruption-drill hydrogen 4f/60f
	# REQUIRED (Blocks.java:3119) + cyanogen 0.75f/60f booster
	# (Blocks.java:3120), so the folded efficiency is the min
	# over the *modeled* consumers (power + required liquid)
	# and the optional efficiency folds the booster row, capped
	# by the min (BuildingComp.java:1986). No other consumers
	# remain unmodeled for either def. (2) shouldConsume
	# gate LIVE (N2203) -- BurstDrillBuild.shouldConsume()
	# (BurstDrill.java:129) is the pure
	# source_burst_drill_should_consume_state gate over the shared
	# drill frame (items/dominant_items/enabled, bound by the
	# drill proximity path) and the block itemCapacity; the driver
	# reads should_consume through it and the machinery folds
	# efficiency to 0 when the gate is false (BuildingComp.java:
	# 1960/:1992-1994). (3) updateTile advance LIVE (N2219) --
	# progress / warmup / timeDrilled / lastDrillSpeed /
	# smoothProgress / invertTime advance each tick and the
	# offload branch fills the live items
	# (BurstDrill.java:76-125, the pure
	# source_burst_drill_update_tile_advance_state); the
	# timerDump dump LIVE (N2282) -- the pure
	# source_burst_drill_timer_dump_state (frame-local
	# Interval-equivalent, 5f/time_scale,
	# BurstDrill.java:83-84) runs before the advance each tick
	# and dumps the dominant item (or dump(null) when the store
	# lacks it) through the shared dump_item_state routing;
	# the timerDump neighbour write-back live since N2360 (the
	# advance exposes dump_neighbour_index / dumped_item and
	# the tick lands the dumped item in the neighbour store
	# through the shared helper); first-fire deviation
	# documented (Java fires nearly immediately after
	# placement, the frame clock waits a full interval); still
	# deferred: the offload
	# shake/sound/drillEffect presentation
	# (BurstDrill.java:114-118), and the offload neighbor
	# routing -- offload takes the no-neighbor fallback branch
	# (BuildingComp.java:1017, `handleItem(self(), item);`).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_burst_drill_liquid_consumer_row_state(frame: Dictionary, has_liquid_consumer: bool, liquid_id: int, amount: float, source_delta: float, time_scale: float, efficiency_scale: float, multiplier: float = 1.0) -> Dictionary:
	# ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47,
	# `float ed = build.edelta() * build.efficiencyScale();` /
	# `if(ed <= 0.00000001f) return 0f;` / `return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);`):
	# the liquid consumer's efficiency is the held liquid over
	# the per-frame demand, capped at 1, and the first pass
	# folds it into the min efficiency when the row is required
	# (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`).
	# A starved non-power required row also stops power draw
	# (`if(cons != block.consPower && result <= 0.0000001f){`,
	# BuildingComp.java:1972, folded by the shared machinery).
	# A booster row folds into the optional pass instead
	# (`for(var cons : block.optionalConsumers){`,
	# BuildingComp.java:1980-1981, `optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));`),
	# and the optional efficiency is capped by the min
	# (`optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);`, BuildingComp.java:1986).
	# ONE function serves both row kinds -- Java's
	# ConsumeLiquid.efficiency does not branch on the booster
	# flag; the required/booster split is routing, not formula:
	# Block.java:1446-1447 selects the consumer lists on
	# `optional` (`optionalConsumers = consumeBuilder.select(consume -> consume.optional && !consume.ignore())`,
	# `nonOptionalConsumers = consumeBuilder.select(consume -> !consume.optional && !consume.ignore())`),
	# and boost() is optional(true, true) (Consume.java:33-35,
	# `return optional(true, true);`), so the tick routes on the
	# catalog row's optional flag. In the first pass efficiency
	# is assumed 1f (BuildingComp.java:1965, `efficiency =
	# optionalEfficiency = 1f;`), so edelta() is delta() =
	# source_delta * time_scale (BuildingComp.java:1922-1929,
	# `return Time.delta * timeScale;` / `return efficiency *
	# delta();`). The multiplier defaults to 1f (Consume.java:18,
	# `public Floatf<Building> multiplier = b -> 1f;`); neither
	# def sets one (Blocks.java:3089-3090/3119-3120 are bare
	# consumeLiquid calls, the booster rows only adding
	# .boost()). The amount is per def, from the catalog
	# consumeLiquid row: impact-drill `consumeLiquid(Liquids.water, 10f/60f);`
	# (Blocks.java:3089, REQUIRED) + `consumeLiquid(Liquids.ozone, 3f / 60f).boost();`
	# (Blocks.java:3090); eruption-drill `consumeLiquid(Liquids.hydrogen, 4f / 60f);`
	# (Blocks.java:3119, REQUIRED) + `consumeLiquid(Liquids.cyanogen, 0.75f / 60f).boost();`
	# (Blocks.java:3120). The held amount comes from the shared
	# liquid module helper (SourceLiquidModuleState.source_get_state,
	# reused through a preload, NOT re-implemented) over the
	# frame liquids key (the Building.liquids LiquidModule dict,
	# default {} for a frame bound before this slice, amount 0.0
	# when the store has no entry for the liquid -- Java's
	# liquids.get returns 0.0 for a liquid never added), with
	# the Fracker guard (SourceFrackerBuildState.gd:151,
	# `liquids.has("liquids")` + bounds check). A block with no
	# liquid consumer contributes no row (the LaunchPad
	# precedent: launch-pad has no liquid consumer, so its
	# has_liquid_row is false). The second pass removes the
	# consumed liquid for BOTH row kinds (ConsumeLiquid.update,
	# ConsumeLiquid.java:37-39, `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));`,
	# only when `if(update && efficiency > 0){`,
	# BuildingComp.java:1999) -- both have update=true by
	# default (Consume.java:16), so both are updateConsumers;
	# the tick does that after the fold, with edelta from the
	# folded efficiency.
	if not has_liquid_consumer:
		return {"has_liquid_row": false, "row": {}}
	var liquids: Dictionary = frame.get("liquids", {})
	var liquid_amount := 0.0
	if liquids.has("liquids") and liquid_id >= 0 and liquid_id < int(liquids["liquids"].size()):
		liquid_amount = float(source_liquid_module_state.source_get_state(liquids, liquid_id).get("amount", 0.0))
	var edelta: float = source_delta * time_scale
	var ed: float = edelta * efficiency_scale
	if ed <= 0.00000001:
		return {"has_liquid_row": true, "row": {"result": 0.0, "is_power": false}}
	var result: float = min(liquid_amount / (amount * ed * multiplier), 1.0)
	return {"has_liquid_row": true, "row": {"result": result, "is_power": false}}

static func source_burst_drill_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, drill_time: float, liquid_boost_intensity: float, drill_multiplier: float, dominant_item_name: String, item_capacity: int) -> Dictionary:
	# The updateTile advance (BurstDrillBuild.updateTile(),
	# BurstDrill.java:76-125), in Java order. `if(dominantItem == null){` (BurstDrill.java:77-79) returns
	# before anything moves, so a drill with no dominant item
	# freezes every key. `if(invertTime > 0f) invertTime -= delta() / invertedTime;` (BurstDrill.java:81)
	# decays the invert time with NO clamp at 0, exactly like
	# Java. `if(timer(timerDump, dumpTime / timeScale)){` (BurstDrill.java:83-85) is LIVE since N2282 -- the pure
	# source_burst_drill_timer_dump_state runs before this advance in the tick (Java order :83-84 before :87+),
	# so the dump drains the store this advance filled LAST tick. `float drillTime = getDrillTime(dominantItem);`
	# (BurstDrill.java:87) uses the BurstDrill getDrillTime OVERRIDE (BurstDrill.java:53-55,
	# `return drillTime / drillMultipliers.get(item, 1f);`, NO hardness term), NOT the base-Drill formula
	# (Drill.java:170-172, `return (drillTime + hardnessDrillMultiplier * item.hardness) / drillMultipliers.get(item, 1f);`).
	# `smoothProgress = Mathf.lerpDelta(smoothProgress, progress / (drillTime - 20f), 0.1f);` (BurstDrill.java:89)
	# runs before the gate branch, from the pre-advance progress.
	# `if(items.total() <= itemCapacity - dominantItems && dominantItems > 0 && efficiency > 0){` (BurstDrill.java:91)
	# is the gate branch: `warmup = Mathf.approachDelta(warmup, progress / drillTime, 0.01f);` (BurstDrill.java:92)
	# `float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;` (BurstDrill.java:94)
	# `timeDrilled += speedCurve.apply(progress / drillTime) * speed;` (BurstDrill.java:96)
	# `lastDrillSpeed = 1f / drillTime * speed * dominantItems;` (BurstDrill.java:98)
	# `progress += delta() * speed;` (BurstDrill.java:99). The blocked branch (BurstDrill.java:100-104):
	# `warmup = Mathf.approachDelta(warmup, 0f, 0.01f);` and `lastDrillSpeed = 0f;`, then return -- the
	# offload branch never runs when blocked. `if(dominantItems > 0 && progress >= drillTime && items.total() < itemCapacity){` (BurstDrill.java:106)
	# is the offload branch: `offload(dominantItem);` x dominantItems (BurstDrill.java:107-109),
	# `invertTime = 1f;` (BurstDrill.java:111), `progress %= drillTime;` (BurstDrill.java:112); the
	# shake/sound/drillEffect presentation (BurstDrill.java:114-118) DEFERS. The Arc formulas, not
	# guesses: approachDelta(from, to, speed) = approach(from, to, Time.delta * speed) with approach =
	# from + clamp(to - from, -speed, speed), lerpDelta(from, to, progress) = lerp(from, to, clamp(progress
	# * Time.delta)), lerp = from + (to - from) * progress (Mathf.java:402, 415-432); speedCurve is
	# `public Interp speedCurve = Interp.pow2In;` (BurstDrill.java:19), and pow2In(a) = a * a
	# (Interp.java:29 `PowIn pow2In = new PowIn(2);` with PowIn.apply :119-121 `return (float)Math.pow(a, power);`).
	# source_delta is Time.delta in ticks (seconds * 60 through game_source_delta, arc Time.java:26),
	# never raw seconds; delta() = Time.delta * timeScale (BuildingComp.java:1922-1924) while
	# approachDelta / lerpDelta scale by Time.delta ALONE (Mathf.java:420 / :430-432) -- the invertTime
	# decay and the progress advance use the scaled delta, the warmup / smoothProgress moves use the raw
	# one. timeDrilled takes NO delta factor at all: Java adds curve * speed per tick. efficiency and
	# optionalEfficiency default 0.0, the Java field defaults (BuildingComp.java:85 `transient float efficiency;`
	# / :87 `transient float optionalEfficiency;`); progress / warmup / timeDrilled / lastDrillSpeed /
	# smoothProgress / invertTime default 0.0, the Java build-field defaults (Drill.java:238-241,
	# BurstDrill.java:72-73, `public float smoothProgress = 0f;` / `public float invertTime = 0f;`).
	# optionalEfficiency is folded by the shared machinery before this runs
	# (apply_update_consumption_state stamps frame["optional_efficiency"]; the booster liquid rows
	# fold live since N2257, capped by the min efficiency, BuildingComp.java:1965/1986). dominant_item_name is the
	# dominant item resolved to its catalog name by the driver (the frame dominant_item is the item dict,
	# Drill.java:244 `public Item dominantItem;`); the offload adds it through the shared inventory helper
	# (add_item_state), the no-neighbor fallback branch of offload (BuildingComp.java:1017,
	# `handleItem(self(), item);`), the base-Drill driver precedent -- the neighbor routing waits for its
	# own slice. `public class BurstDrill extends Drill{` (BurstDrill.java:17) and
	# `public class BurstDrillBuild extends DrillBuild{` (BurstDrill.java:70), so the override wins over
	# the base-Drill updateTile, which the BurstDrill override never calls.
	var stored_items: Variant = frame.get("items", {})
	var items: Dictionary = stored_items if stored_items is Dictionary else {}
	var dominant_item: Variant = frame.get("dominant_item", null)
	var dominant_items: int = int(frame.get("dominant_items", 0))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var optional_efficiency: float = float(frame.get("optional_efficiency", 0.0))
	var progress: float = float(frame.get("progress", 0.0))
	var warmup: float = float(frame.get("warmup", 0.0))
	var time_drilled: float = float(frame.get("time_drilled", 0.0))
	var last_drill_speed: float = float(frame.get("last_drill_speed", 0.0))
	var smooth_progress: float = float(frame.get("smooth_progress", 0.0))
	var invert_time: float = float(frame.get("invert_time", 0.0))
	var items_total: int = source_drill_inventory_runtime_state.items_total(items)
	var next_items: Dictionary = items.duplicate(true)
	var offloaded := 0
	var speed := 0.0
	var effective_drill_time := 0.0
	if dominant_item == null:
		return {"progress": progress, "warmup": warmup, "time_drilled": time_drilled, "last_drill_speed": last_drill_speed, "smooth_progress": smooth_progress, "invert_time": invert_time, "items": next_items, "offloaded": offloaded, "drill_time": effective_drill_time, "speed": speed}
	var scaled_delta: float = source_delta * time_scale
	if invert_time > 0.0:
		invert_time -= scaled_delta / SOURCE_BURST_DRILL_INVERTED_TIME
	effective_drill_time = drill_time / drill_multiplier
	smooth_progress = lerpf(smooth_progress, progress / (effective_drill_time - SOURCE_BURST_DRILL_SMOOTH_PROGRESS_OFFSET), clampf(SOURCE_BURST_DRILL_SMOOTH_PROGRESS_RATE * source_delta, 0.0, 1.0))
	if items_total <= item_capacity - dominant_items and dominant_items > 0 and efficiency > 0.0:
		var warmup_step: float = source_delta * SOURCE_BURST_DRILL_WARMUP_RATE
		warmup = warmup + clampf(progress / effective_drill_time - warmup, -warmup_step, warmup_step)
		speed = lerpf(1.0, liquid_boost_intensity, optional_efficiency) * efficiency
		var progress_ratio: float = progress / effective_drill_time
		time_drilled += progress_ratio * progress_ratio * speed
		last_drill_speed = 1.0 / effective_drill_time * speed * dominant_items
		progress += scaled_delta * speed
	else:
		var decay_step: float = source_delta * SOURCE_BURST_DRILL_WARMUP_RATE
		warmup = warmup + clampf(0.0 - warmup, -decay_step, decay_step)
		last_drill_speed = 0.0
		return {"progress": progress, "warmup": warmup, "time_drilled": time_drilled, "last_drill_speed": last_drill_speed, "smooth_progress": smooth_progress, "invert_time": invert_time, "items": next_items, "offloaded": offloaded, "drill_time": effective_drill_time, "speed": speed}
	if dominant_items > 0 and progress >= effective_drill_time and items_total < item_capacity:
		var offloaded_state: Dictionary = source_drill_inventory_runtime_state.add_item_state(next_items, dominant_item_name, dominant_items)
		next_items = offloaded_state.get("drill_items", next_items)
		offloaded = dominant_items
		invert_time = 1.0
		progress = fmod(progress, effective_drill_time)
	return {"progress": progress, "warmup": warmup, "time_drilled": time_drilled, "last_drill_speed": last_drill_speed, "smooth_progress": smooth_progress, "invert_time": invert_time, "items": next_items, "offloaded": offloaded, "drill_time": effective_drill_time, "speed": speed}

static func source_burst_drill_timer_dump_state(frame: Dictionary, source_delta: float, time_scale: float, dominant_item_name: String, content_item_ids: Array, neighbour_accepts_item: Array, neighbour_can_dump: Array) -> Dictionary:
	# The timerDump dump (BurstDrillBuild.updateTile(),
	# BurstDrill.java:76-125), in Java order. `public class BurstDrill extends Drill{` (BurstDrill.java:17) and
	# `public class BurstDrillBuild extends DrillBuild{` (BurstDrill.java:70), so the override wins over the
	# base-Drill updateTile, which the BurstDrill override never calls. `if(dominantItem == null){`
	# (BurstDrill.java:77-79) returns before anything moves -- so with NO dominant item the timer check never
	# runs at all: no fire, no dump (NOT dump(null) -- dump(null) is only the branch when a dominant item
	# EXISTS but the store lacks it). The check itself (BurstDrill.java:83-84):
	# `if(timer(timerDump, dumpTime / timeScale)){`
	# `dump(items.has(dominantItem) ? dominantItem : null);`
	# -- it runs after the invertTime decay (:81) and BEFORE the drillTime / smoothProgress / gate / offload
	# advance (:87+), so the dump drains the store the advance filled LAST tick. dumpTime is
	# `public int dumpTime = 5;` (Block.java:438, NO override in upstream) and the timer id is
	# `protected final int timerDump = timers++;` (Block.java:436). The timer is TimerComp.timer
	# (TimerComp.java:10-13, each exact expr on ONE comment line, the N2148 lesson):
	# `if(Float.isInfinite(time)) return false;`
	# `return timer.get(index, time);`
	# Interval.get resets times[id] = Time.time on fire (arc Interval.java:20-26):
	# `boolean got = check(id, time);`
	# `if(got) times[id] = Time.time;`
	# and check compares Time.time - times[id] >= time (arc Interval.java:28-30):
	# `return Time.time - times[id] >= time || Time.time < times[id];`
	# Time.time counts TICKS (arc Time.java:69-80):
	# `timeRaw += delta;`
	# The port has no global tick clock at the driver layer, so the elapsed clock is frame-local
	# (frame["timer_dump_elapsed"], the N2266/N2269/N2273/N2280 frame-local Interval-equivalent precedent):
	# elapsed += source_delta unconditionally -- mirroring Time.time, which grows even while the
	# dominant-item gate is closed, so a drill whose dominant item appears late fires immediately, like Java
	# (the Interval times[id] stays 0 while updateTile returns early); fired = elapsed >= 5f / time_scale;
	# elapsed_after RESETS to 0.0 on fire (a reset, not a subtraction); a non-positive time_scale is the
	# infinite-time branch (never fires). The threshold DIVIDES by timeScale -- Java passes
	# dumpTime / timeScale, unlike the RepairTurret literal-20 timer (N2280). source_delta is Time.delta in
	# ticks (seconds * 60 through game_source_delta, arc Time.java:26), never raw seconds; delta() is
	# `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) and timeScale defaults to 1f
	# (`private transient float timeScale = 1f, timeScaleDuration;`, BuildingComp.java:98). Documented
	# deviation (first fire): Java fires (nearly) immediately after placement (the global Time.time is
	# already large vs a fresh Interval times[id] = 0); the frame-local clock delays the first fire by a full
	# interval (5 ticks / time_scale). It cannot be fixed without a global clock -- it waits for a
	# timer-infra slice if exact first-fire timing is ever needed. `items.has(dominantItem)` means the store
	# holds a POSITIVE amount (`return values[item.id] > 0;`, ItemSeq.java:79-81), not mere key presence, so
	# a zero-count entry still takes the dump(null) branch. dump() (BuildingComp.java:1064-1066):
	# `public boolean dump(){`
	# `return dump(null);`
	# delegates to dump(Item todump) (BuildingComp.java:1072-1113):
	# `public boolean dump(Item todump){`
	# `if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;`
	# `int dump = this.cdump;`
	# `var allItems = content.items();`
	# `int itemSize = allItems.size;`
	# `if(todump == null){`
	# `Building other = proximity.get((i + dump) % proximity.size);`
	# `if(!items.has(ii)) continue;`
	# `Item item = (Item)itemArray[ii];`
	# `if(other.acceptItem(self(), item) && canDump(other, item)){`
	# `other.handleItem(self(), item);`
	# `items.remove(item, 1);`
	# `incrementDump(proximity.size);`
	# -- neighbours outer, content items inner for the null branch; the specific branch scans the same way
	# for the one item:
	# `if(other.acceptItem(self(), todump) && canDump(other, todump)){`
	# `other.handleItem(self(), todump);`
	# `items.remove(todump, 1);`
	# -- and the cursor advances once per neighbour checked (incrementDump, BuildingComp.java:1116-1120):
	# `public void incrementDump(int prox){`
	# `if(prox != 0){`
	# `cdump = ((cdump + 1) % prox);`
	# The dump fields are Building fields at their Java defaults: `transient int cdump;`
	# (BuildingComp.java:68, 0). canDump defaults to true
	# (`public boolean canDump(Building to, Item item){`, BuildingComp.java:1124-1126); the neighbour arrays
	# carry the live per-neighbour answers as frame inputs. The drill has items (`hasItems = true;`,
	# Drill.java:82, inherited by BurstDrill), so the hasItems guard always passes. The dominant item is
	# `public Item dominantItem;` (Drill.java:244, `public int dominantItems;` :243, set by the drill
	# proximity path); the driver resolves its catalog name (the N2219 advance precedent) and passes it in --
	# "" when dominantItem is null, which takes the no-fire branch above. The dump itself runs through the
	# shared dump(Item) port (SourceBuildingItemDumpState.dump_item_state), which covers BOTH branches -- NOT
	# the putItem gate game_put_item_state / put_item_state, which dumps one SPECIFIC item through
	# game-bound increment callbacks and cannot express dump(null) (the N2276 lesson). The shared port
	# reports the handled neighbour index + the dumped item, and the advance exposes both
	# (dump_neighbour_index / dumped_item, N2360) so the tick can land the item in the neighbour store
	# through the shared neighbour write-back helper (other.handleItem(self(), item),
	# BuildingComp.java:1089, and other.handleItem(self(), todump), BuildingComp.java:1103) -- the
	# write-back is live since N2360. The handled index is the port's "handled_index" result key
	# (SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY); the dumped item is the port's handled_item -- the
	# dominant item (todump) on the specific branch, the first held item in content order on the
	# dump(null) branch. A no-fire tick reports index -1 and an empty dumped item. The 2 new keys are
	# registered as registry symbols only (N2360): the schema-sync slice folds them into
	# source_burst_drill_timer_dump_state_result + the contract return_keys.
	var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
	var elapsed: float = float(frame.get("timer_dump_elapsed", 0.0))
	var cursor: int = int(frame.get("cdump", 0))
	var accumulated: float = elapsed + source_delta
	var threshold: float = INF if time_scale <= 0.0 else SOURCE_BURST_DRILL_DUMP_TIME / time_scale
	if dominant_item_name == "" or accumulated < threshold:
		return {"fired": false, "elapsed_after": accumulated, "dumped": false, "items_after": items, "cursor_after": cursor, "dump_neighbour_index": -1, "dumped_item": ""}
	var todump: Variant = dominant_item_name if int(items.get(dominant_item_name, 0)) > 0 else null
	var amounts: Array = []
	for item_id in content_item_ids:
		amounts.append(int(items.get(str(item_id), 0)))
	var result: Dictionary = source_building_item_dump_state.dump_item_state(true, source_drill_inventory_runtime_state.items_total(items), neighbour_accepts_item.size(), todump, todump != null, content_item_ids, amounts, neighbour_accepts_item, neighbour_can_dump, cursor)
	var dumped := bool(result.get("dumped", false))
	var dump_neighbour_index: int = int(result.get(source_drill_inventory_runtime_state.SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY, -1))
	var handled_item: Variant = result.get("handled_item", null)
	var dumped_item: String = "" if handled_item == null else str(handled_item)
	if dumped:
		var amounts_after: Array = result.get("item_amounts_by_index", amounts)
		for j in range(content_item_ids.size()):
			if j < amounts_after.size():
				items[str(content_item_ids[j])] = int(amounts_after[j])
	return {"fired": true, "elapsed_after": 0.0, "dumped": dumped, "items_after": items, "cursor_after": int(result.get("cdump", cursor)), "dump_neighbour_index": dump_neighbour_index, "dumped_item": dumped_item}

@warning_ignore("unused_parameter")
static func source_burst_drill_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the burst-drill tick wiring every tick
	# (Building.update() runs updateConsumption() then
	# updateTile(), BuildingComp.java:2274-2278; the base-Drill
	# driver never ticks BurstDrill implementations, so this
	# driver is the burst-drill tick): each placed BurstDrill
	# build gets its frame keys refreshed from the live rules, so
	# the frame's cheating flag tracks team.rules().cheat and the
	# consumption machinery skips consumption for a cheating team.
	# The frame is bound at placement (the drill proximity path);
	# a sprite that somehow lacks one gets it bound here instead
	# of crashing the loop.
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
		if not _is_burst_drill_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_burst_drill_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_burst_drill_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids, initialized
		# at placement), so the driver syncs the reference
		# into the frame each tick BEFORE the fold, and the
		# pure liquid row reads the held liquid from it (the
		# Fracker precedent, SourceFrackerBuildState.gd:623).
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# The power consumer reads live since N2149 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a burst drill with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the speed fold (BurstDrill.java:94)
		# follows it. The power consumer counts toward hasConsumers
		# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
		# so a burst drill does not take the early return. A burst
		# drill with no power consumer is untouched: the liquid
		# rows (N2257) fold in the same block -- the required
		# row (impact water, eruption hydrogen) into the min
		# efficiency and the booster row (impact ozone,
		# eruption cyanogen) into the optional pass. The
		# shouldConsume gate is LIVE
		# (N2203): the pure source_burst_drill_should_consume_state
		# gate (BurstDrill.java:129) reads the shared drill frame
		# and the block itemCapacity, and the machinery folds
		# efficiency to 0 when the gate is false. productionValid
		# is the canonical true default (SourceBuildingAccessState.
		# production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_burst_drill_should_consume_state(frame, int(block.properties.get("itemCapacity", 10)))
			var should_consume: bool = bool(gate.get("should_consume", false))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_burst_drill_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			# N2257: the liquid rows fold in the same first
			# pass (ConsumeLiquid.efficiency,
			# ConsumeLiquid.java:42-47). The rows are per def,
			# read from the catalog consumeLiquid rows
			# (impact-drill water 10f/60f REQUIRED,
			# Blocks.java:3089, + ozone 3f/60f booster,
			# Blocks.java:3090; eruption-drill hydrogen 4f/60f
			# REQUIRED, Blocks.java:3119, + cyanogen 0.75f/60f
			# booster, Blocks.java:3120) -- the catalog carries
			# the booster flag (`booster: true, optional: true`
			# on the booster rows). The routing follows Java:
			# Block.java:1446-1447 splits the consumers on
			# `optional`, so a row with the optional flag folds
			# into the optional pass (`for(var cons : block.optionalConsumers){`,
			# BuildingComp.java:1980-1981, capped by the min,
			# `optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);`,
			# BuildingComp.java:1986) and a row without it folds
			# into the min efficiency. The liquid ids resolve
			# through the catalog liquid_id_by_name (the
			# Fracker precedent). In the first pass efficiency
			# is assumed 1f (BuildingComp.java:1965), so the
			# rows' edelta is source_delta * time_scale. The
			# same pure row function serves both kinds -- the
			# formula does not branch on the booster flag.
			var tick_source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var tick_time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var optional_consumer_results: Array = []
			var liquid_removals: Array = []
			for liquid_row_def in block.properties.get("consumeLiquid", []):
				var liquid_name: String = str(liquid_row_def.get("liquid", ""))
				var liquid_amount_per_frame: float = float(liquid_row_def.get("amount", 0.0))
				var liquid_id: int = int(liquid_id_by_name.get(liquid_name, -1))
				var liquid_row: Dictionary = source_burst_drill_liquid_consumer_row_state(frame, true, liquid_id, liquid_amount_per_frame, tick_source_delta, tick_time_scale, float(frame.get("efficiency_scale", 1.0)))
				if not bool(liquid_row.get("has_liquid_row", false)):
					continue
				if bool(liquid_row_def.get("optional", false)):
					optional_consumer_results.append(liquid_row.get("row", {}))
				else:
					required_results.append(liquid_row.get("row", {}))
				liquid_removals.append({"liquid_id": liquid_id, "amount": liquid_amount_per_frame})
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, optional_consumer_results, [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# N2257 second pass (ConsumeLiquid.update,
			# ConsumeLiquid.java:37-39, `build.liquids.
			# remove(liquid, amount * build.edelta() *
			# multiplier.get(build));`): only when update &&
			# efficiency > 0 (BuildingComp.java:1999,
			# `if(update && efficiency > 0){`), with edelta
			# from the FOLDED efficiency (frame["efficiency"]
			# after the apply), not the assumed 1f. BOTH row
			# kinds remove here -- the required row and the
			# booster row both have update=true by default
			# (Consume.java:16), so both are updateConsumers.
			# The multiplier is the 1f default (Consume.java:18),
			# so it drops out of the removal amount. The
			# AdjacentFactory updates-array precedent
			# (SourceAdjacentFactoryBuildState.gd:382) needs
			# consumer actor objects with an update(self_state)
			# method built by reinitialize_consumers_state --
			# the burst-drill driver has no such actor
			# infrastructure, so the removal is direct here,
			# through the shared liquid module helper
			# (SourceLiquidModuleState.source_remove_state,
			# clamped at the held amount like Java's
			# LiquidModule.remove, with a fresh cache_sums
			# sized to the store, the PayloadLoader
			# precedent). frame["liquids"] is the live sprite
			# store by reference, so the removal lands on it.
			if not liquid_removals.is_empty() and bool(setup.get("update", false)) and float(frame.get("efficiency", 0.0)) > 0.0:
				var folded_edelta: float = float(frame.get("efficiency", 0.0)) * tick_source_delta * tick_time_scale
				var liquid_store: Dictionary = frame.get("liquids", {})
				if liquid_store.has("liquids"):
					var cache_sums: Array = []
					cache_sums.resize(int(liquid_store["liquids"].size()))
					cache_sums.fill(0.0)
					for removal in liquid_removals:
						var removal_id: int = int(removal.get("liquid_id", -1))
						if removal_id >= 0 and removal_id < int(liquid_store["liquids"].size()):
							source_liquid_module_state.source_remove_state(liquid_store, removal_id, float(removal.get("amount", 0.0)) * folded_edelta, cache_sums)
			# N2219: the updateTile advance runs after consumption,
			# like Java's Building.update() (BuildingComp.java:2274
			# updateConsumption(), then the updateTile gate
			# `if(enabled || !block.noUpdateDisabled){` at
			# BuildingComp.java:2276-2278; noUpdateDisabled defaults
			# false, Block.java:170), so a disabled burst drill
			# freezes its progress / warmup / timeDrilled. The
			# source delta is Time.delta in ticks:
			# game_source_delta(game, seconds) is seconds * 60 (arc
			# Time.java:26), never raw seconds. timeScale reads live
			# from the sprite meta, default 1.0
			# (BuildingComp.java:98 `private transient float
			# timeScale = 1f, timeScaleDuration;`). The def
			# drillTime / liquidBoostIntensity come from the per-def
			# tables (the catalog lacks impact's drillTime and both
			# defs' liquidBoostIntensity); the drill multiplier is
			# 2f for beryllium, 1f otherwise (Blocks.java:3083/
			# :3114 `drillMultipliers.put(Items.beryllium, 2f);`);
			# the dominant item name resolves through the shared
			# drill helper (the base-Drill driver precedent,
			# SourceDrillConsumptionRuntimeState.gd:290), loaded
			# with load() instead of preload() -- a preload would
			# cycle (SourceFactoryRuntimeState preloads this file
			# and SourceDrillRuntimeState preloads Factory). The
			# advance writes the frame keys back, including the
			# offloaded items (the live items fill).
			if bool(frame.get("enabled", true)):
				var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
				var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
				var block_drill_time: float = float(SOURCE_BURST_DRILL_DRILL_TIME.get(block_id, block.properties.get("drillTime", 300.0)))
				var block_boost: float = float(SOURCE_BURST_DRILL_LIQUID_BOOST_INTENSITY.get(block_id, block.properties.get("liquidBoostIntensity", 1.6)))
				var dominant_item_name := ""
				if frame.get("dominant_item", null) != null:
					var drill_consumption_state = load("res://src/game/SourceDrillConsumptionRuntimeState.gd")
					dominant_item_name = str(drill_consumption_state.source_dominant_item_name_state(game, sprite).get("item_id", ""))
				var drill_multiplier: float = SOURCE_BURST_DRILL_BERYLLIUM_MULTIPLIER if dominant_item_name == "beryllium" else 1.0
				# N2282: the timerDump dump runs BEFORE the advance
				# (Java order: the timerDump check,
				# BurstDrill.java:83-84, runs before the drillTime /
				# smoothProgress / gate / offload advance, :87+), so
				# the dump drains the store the advance filled LAST
				# tick. The content item ids are the catalog order
				# Java iterates (content.items()), through the
				# N2276 precedent (SourceContentRegistryRuntimeState.
				# source_item_catalog_state); the neighbour
				# acceptItem / canDump arrays are frame inputs
				# (default [] -- no neighbours, the Java
				# proximity.size == 0 outcome) until a live
				# proximity fill lands. The dump is
				# efficiency-independent (a timer, not edelta), so
				# it runs even when the folded efficiency is 0.
				var content_item_ids: Array = source_content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])
				var neighbour_accepts: Array = frame.get("dump_neighbour_accepts", [])
				var neighbour_can_dump: Array = frame.get("dump_neighbour_can_dump", [])
				var dumped: Dictionary = source_burst_drill_timer_dump_state(frame, source_delta, time_scale, dominant_item_name, content_item_ids, neighbour_accepts, neighbour_can_dump)
				frame["timer_dump_elapsed"] = dumped["elapsed_after"]
				frame["items"] = dumped["items_after"]
				frame["cdump"] = dumped["cursor_after"]
				# N2360: the timerDump neighbour write-back --
				# the advance exposed the routed neighbour
				# index (dump_neighbour_index, -1 when nothing
				# dumped) + the dumped item (dumped_item), so
				# the tick lands the item in the neighbour
				# store through the shared helper
				# (other.handleItem(self(), item),
				# BuildingComp.java:1089, and
				# other.handleItem(self(), todump), :1103),
				# right after the dump and before the advance
				# (Java order: handleItem happens INSIDE
				# dump(), BurstDrill.java:83-84, before the
				# :87+ advance). Index i is ring cell i (the
				# N2353 convention), so the frame neighbour
				# inputs must be filled in ring order and the
				# helper takes the catalog size (the ring
				# shape depends on it). A failed write-back
				# (no sprite / no frame / no items store /
				# full belt) drops the item -- the routing
				# already decided, so there is no fallback to
				# the drill's own store.
				if bool(dumped.get("dumped", false)):
					var dump_index: int = int(dumped.get("dump_neighbour_index", -1))
					if dump_index >= 0:
						source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_item", "")), 1)
				var advanced: Dictionary = source_burst_drill_update_tile_advance_state(frame, source_delta, time_scale, block_drill_time, block_boost, drill_multiplier, dominant_item_name, int(block.properties.get("itemCapacity", 10)))
				frame["progress"] = advanced["progress"]
				frame["warmup"] = advanced["warmup"]
				frame["time_drilled"] = advanced["time_drilled"]
				frame["last_drill_speed"] = advanced["last_drill_speed"]
				frame["smooth_progress"] = advanced["smooth_progress"]
				frame["invert_time"] = advanced["invert_time"]
				frame["items"] = advanced["items"]
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
