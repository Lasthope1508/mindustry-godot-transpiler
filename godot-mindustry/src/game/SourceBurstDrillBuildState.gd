extends RefCounted
class_name SourceBurstDrillBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_drill_dump_runtime_state := preload("res://src/game/SourceDrillDumpRuntimeState.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")

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
	return {}

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
	# Documented limits: (1) power-only first pass -- eruption's
	# hydrogen/cyanogen and impact's water/ozone liquid rows wait
	# for their own slices, so the folded efficiency is the min
	# over the *modeled* consumers (power only). (2)
	# shouldConsume gate -- BurstDrillBuild overrides
	# shouldConsume (BurstDrill.java:129, `return items.total()
	# <= itemCapacity - dominantItems && enabled;`); N2257 wires
	# the gate through
	# source_burst_drill_should_consume_state(frame,
	# item_capacity), so the machinery runs with
	# should_consume=false (efficiency 0) when the item store
	# is full. (3) No updateTile advance
	# -- progress/timeDrilled/offload/invertTime/speedCurve
	# (BurstDrill.java:70-125) waits for its own slice; the proof
	# carries no progress keys, the speed fold (BurstDrill.java:94)
	# is what the efficiency keys prove.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_burst_drill_should_consume_state(frame: Dictionary, item_capacity: float) -> Dictionary:
	# BurstDrillBuild overrides shouldConsume
	# (BurstDrill.java:128, `public boolean shouldConsume(){`)
	# with the gate `return items.total() <= itemCapacity - dominantItems && enabled;`
	# (BurstDrill.java:129) over the items total
	# (ItemModule.java:174, `public int total(){` with `return total;`,
	# ItemModule.java:175 -- the cached total a fresh ItemModule
	# starts at 0), the per-def item capacity
	# (`public int itemCapacity = 10;`, Block.java:75, with
	# `itemCapacity = 40;`, Blocks.java:3078, for impact-drill
	# and `itemCapacity = 60;`, Blocks.java:3107, for
	# eruption-drill), the dominant count
	# (`public int dominantItems;`, Drill.java:243, with
	# `public Item dominantItem;`, Drill.java:244) and the
	# enabled flag (`transient boolean enabled = true;`,
	# BuildingComp.java:77), and updateConsumption forces
	# efficiency to zero when the gate is false
	# (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();`)
	# (BuildingComp.java:1992, `if(!update){` with
	# `efficiency = optionalEfficiency = 0f;`, BuildingComp.java:1993).
	# The BuildingComp default (`public boolean shouldConsume(){`
	# with `return enabled;`, BuildingComp.java:755-756) is what
	# the override replaces. The gate matters because with a full
	# item store Java efficiency is 0 while the port folds
	# power-only and reports 1.0 -- the N2149 gap this slice
	# closes once the frame carries the stamped totals. A
	# missing power stamp folds to 1.0 before the first graph
	# update, the assembler fold (UnitAssembler.java:469,
	# `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`)
	# and the power consumer counts toward hasConsumers
	# (Block.java:1449, `hasConsumers = consumers.length > 0;`);
	# edelta() is efficiency * delta (BuildingComp.java:1928,
	# `return efficiency * delta();`). The burst drill's power
	# draw is STATIC: impact-drill consumePower 160f/60f and
	# eruption-drill consumePower 6f, so the row read is the
	# plain one (ConsumePower.java:39, `return build.power.status;`)
	# -- no RepairTurret-style ConsumePowerCondition adaptation.
	# The frame carries the live items observation as
	# `items_total` (float, absent defaults to 0.0 -- a fresh
	# ItemModule totals 0, the N2207 LaunchPad precedent) and
	# `dominant_items` (int, absent defaults to 0 --
	# Drill.java:243), and `enabled` (bool, absent defaults to
	# true -- BuildingComp.java:77); the per-def item_capacity
	# is an explicit param (the N2212 / N2248 per-def-param
	# precedent). Absent keys mean "no observation yet", not
	# "full": the defaults make the bound read `0 <=
	# itemCapacity - 0`, so should_consume = enabled, the N2149
	# behavior preserved (the N2188 / N2191 absent-preserves
	# precedent) -- no placed-building frame carries live
	# items/dominant state until the ore/dominant binding slice
	# stamps it, and defaulting absent to false would zero
	# efficiency for every live burst drill. The gate activates
	# when that binding slice stamps `items_total` /
	# `dominant_items`. Two defs share the implementation
	# (`public class BurstDrill extends Drill{`, BurstDrill.java:17,
	# with `public class BurstDrillBuild extends DrillBuild{`,
	# BurstDrill.java:70, and `public class DrillBuild extends Building{`,
	# Drill.java:237).
	var items_total: float = float(frame.get("items_total", 0.0))
	var dominant_items: int = int(frame.get("dominant_items", 0))
	var enabled: bool = bool(frame.get("enabled", true))
	return {"should_consume": items_total <= item_capacity - float(dominant_items) and enabled}

static func source_burst_drill_update_tile_state(frame: Dictionary, delta: float, drill_time_base: float, drill_multiplier: float, inverted_time: float, liquid_boost_intensity: float, item_capacity: float, dump_interval: float) -> Dictionary:
	# BurstDrillBuild.updateTile advances the burst drill's
	# drilling state every tick (BurstDrill.java:76,
	# `public void updateTile(){`): it returns early with no
	# dominant item (BurstDrill.java:77,
	# `if(dominantItem == null){`); decays invertTime
	# (BurstDrill.java:81,
	# `if(invertTime > 0f) invertTime -= delta() / invertedTime;`
	# with `public float invertedTime = 200f;`,
	# BurstDrill.java:26); dumps on the dump timer
	# (BurstDrill.java:83,
	# `if(timer(timerDump, dumpTime / timeScale)){` with
	# `dump(items.has(dominantItem) ? dominantItem : null);`,
	# BurstDrill.java:84 -- the dump timer is
	# `protected final int timerDump = timers++;`,
	# Block.java:436, with `public int dumpTime = 5;`,
	# Block.java:438, and the actual dump call
	# (`public boolean dump(Item todump){`,
	# BuildingComp.java:1072) waits for the driver slice; the
	# `dump_due` flag is the observable signal); reads the
	# effective drill time (BurstDrill.java:87,
	# `float drillTime = getDrillTime(dominantItem);` with
	# `public float getDrillTime(Item item){` /
	# `return drillTime / drillMultipliers.get(item, 1f);`,
	# BurstDrill.java:53-54); lerps the smooth progress
	# (BurstDrill.java:89,
	# `smoothProgress = Mathf.lerpDelta(smoothProgress, progress / (drillTime - 20f), 0.1f);`
	# with `public float smoothProgress = 0f;`,
	# BurstDrill.java:72); when producing (BurstDrill.java:91,
	# `if(items.total() <= itemCapacity - dominantItems && dominantItems > 0 && efficiency > 0){`)
	# approaches warmup toward progress / drillTime
	# (BurstDrill.java:92,
	# `warmup = Mathf.approachDelta(warmup, progress / drillTime, 0.01f);`),
	# folds the speed from the liquid boost and the folded
	# efficiency (BurstDrill.java:94,
	# `float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;`),
	# advances timeDrilled through the pow2In speed curve
	# (BurstDrill.java:96,
	# `timeDrilled += speedCurve.apply(progress / drillTime) * speed;`
	# with `public Interp speedCurve = Interp.pow2In;`,
	# BurstDrill.java:19, `PowIn pow2In = new PowIn(2);`,
	# Interp.java:29, with
	# `return (float)Math.pow(a, power);`, Interp.java:116 --
	# pow2In(a) is a squared), records the drill speed
	# (BurstDrill.java:98,
	# `lastDrillSpeed = 1f / drillTime * speed * dominantItems;`)
	# and advances progress (BurstDrill.java:99,
	# `progress += delta() * speed;`); when not producing it
	# decays warmup (BurstDrill.java:101,
	# `warmup = Mathf.approachDelta(warmup, 0f, 0.01f);`) and
	# zeroes the drill speed (BurstDrill.java:102,
	# `lastDrillSpeed = 0f;`) and returns; and when the progress
	# crosses the drill time (BurstDrill.java:106,
	# `if(dominantItems > 0 && progress >= drillTime && items.total() < itemCapacity){`)
	# it offloads one item per dominant item
	# (BurstDrill.java:107-108,
	# `for(int i = 0; i < dominantItems; i++){` /
	# `offload(dominantItem);`), inverts (BurstDrill.java:111,
	# `invertTime = 1f;`) and wraps progress
	# (BurstDrill.java:112, `progress %= drillTime;`). The
	# completion effects (BurstDrill.java:114-117,
	# `if(wasVisible){` with
	# `Effect.shake(shake, shake, this);`,
	# `drillSound.at(x, y, 1f + Mathf.range(drillSoundPitchRand), drillSoundVolume);`
	# and
	# `drillEffect.at(x + Mathf.range(drillEffectRnd), y + Mathf.range(drillEffectRnd), dominantItem.color);`)
	# wait for their own slice; the `invert_fired` flag is the
	# observable signal that slice will consume. The offload
	# application (`offload(dominantItem);`) waits for the driver
	# slice that owns the items module; the `offloaded_count`
	# result is the observable. The frame carries `dominant_item`
	# (Variant, absent defaults to null --
	# `public Item dominantItem;`, Drill.java:244),
	# `dominant_items` (int, absent defaults to 0 --
	# `public int dominantItems;`, Drill.java:243),
	# `invert_time` (float, absent defaults to 0.0 --
	# `public float invertTime = 0f;`, BurstDrill.java:73),
	# `smooth_progress` (float, absent defaults to 0.0 --
	# `public float smoothProgress = 0f;`, BurstDrill.java:72),
	# `progress` / `warmup` / `time_drilled` /
	# `last_drill_speed` (floats, absent default to 0.0 --
	# `public float progress;` / `public float warmup;` /
	# `public float timeDrilled;` / `public float lastDrillSpeed;`,
	# Drill.java:238-241), `efficiency` /
	# `optional_efficiency` (floats, absent default to 0.0 --
	# `transient float efficiency;` /
	# `transient float optionalEfficiency;`,
	# BuildingComp.java:85/87), `items_total` (float, absent
	# defaults to 0.0 -- a fresh ItemModule totals 0, the N2207
	# LaunchPad precedent) and `dump_timer` (float, absent
	# defaults to 0.0 -- the Interval accumulator for
	# `protected final int timerDump = timers++;`,
	# Block.java:436). delta() is `public float delta(){` with
	# `return Time.delta * timeScale;`,
	# BuildingComp.java:1922-1923 -- timeScale is 1 by default
	# and the port passes the raw tick seconds, the N2190 driver
	# convention. Two defs share the implementation
	# (`public class BurstDrill extends Drill{`,
	# BurstDrill.java:17, with
	# `public class BurstDrillBuild extends DrillBuild{`,
	# BurstDrill.java:70, and
	# `public class DrillBuild extends Building{`,
	# Drill.java:237): impact-drill drillTime 720f
	# (`drillTime = 60f * 12f;`, Blocks.java:3072),
	# itemCapacity 40 (`itemCapacity = 40;`, Blocks.java:3078),
	# liquidBoostIntensity 1.75f
	# (`liquidBoostIntensity = 1.75f;`, Blocks.java:3084);
	# eruption-drill drillTime 281.25f
	# (`drillTime = 281.25f;`, Blocks.java:3095), itemCapacity 60
	# (`itemCapacity = 60;`, Blocks.java:3107),
	# liquidBoostIntensity 2f (`liquidBoostIntensity = 2f;`,
	# Blocks.java:3115); both defs multiply beryllium by 2f
	# (`drillMultipliers.put(Items.beryllium, 2f);`,
	# Blocks.java:3083/3114). There is NO driver tick line yet:
	# the burst-drill frame carries no dominant_item /
	# dominant_items / items_total / dump_timer (the ore/dominant
	# binding and items-module slices own those frame keys), so
	# the advance is pure-function-only, the N2251 / N2252
	# precedent -- no field is invented. The per-def values are
	# explicit params (the N2212 / N2248 per-def-param precedent).
	# The effective drill time is derived from the params before
	# the early return, so every return carries the same eleven
	# keys; the frame values themselves are untouched when there
	# is no dominant item.
	var dominant_item: Variant = frame.get("dominant_item", null)
	var dominant_items: int = int(frame.get("dominant_items", 0))
	var invert_time: float = float(frame.get("invert_time", 0.0))
	var smooth_progress: float = float(frame.get("smooth_progress", 0.0))
	var progress: float = float(frame.get("progress", 0.0))
	var warmup: float = float(frame.get("warmup", 0.0))
	var time_drilled: float = float(frame.get("time_drilled", 0.0))
	var last_drill_speed: float = float(frame.get("last_drill_speed", 0.0))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var optional_efficiency: float = float(frame.get("optional_efficiency", 0.0))
	var items_total: float = float(frame.get("items_total", 0.0))
	var dump_timer: float = float(frame.get("dump_timer", 0.0))
	var dump_due := false
	var offloaded_count := 0
	var invert_fired := false
	var drill_time: float = drill_time_base / drill_multiplier
	if dominant_item == null:
		return {"drill_time": drill_time, "invert_time": invert_time, "smooth_progress": smooth_progress, "warmup": warmup, "time_drilled": time_drilled, "last_drill_speed": last_drill_speed, "progress": progress, "dump_timer": dump_timer, "dump_due": dump_due, "offloaded_count": offloaded_count, "invert_fired": invert_fired}
	if invert_time > 0.0:
		invert_time -= delta / inverted_time
	var timed: Dictionary = source_drill_dump_runtime_state.dump_timer_state(dump_timer, delta, dump_interval)
	dump_timer = float(timed.get(source_drill_dump_runtime_state.SOURCE_DRILL_DUMP_TIMER_KEY, dump_timer))
	dump_due = bool(timed.get(source_drill_dump_runtime_state.SOURCE_DRILL_DUMP_SHOULD_DUMP_KEY, false))
	smooth_progress = source_math_state.source_lerp_delta(smooth_progress, progress / (drill_time - 20.0), 0.1, delta)
	if items_total <= item_capacity - float(dominant_items) and dominant_items > 0 and efficiency > 0.0:
		warmup = source_math_state.source_approach_delta(warmup, progress / drill_time, 0.01, delta)
		var speed: float = lerpf(1.0, liquid_boost_intensity, optional_efficiency) * efficiency
		var ratio: float = progress / drill_time
		time_drilled += ratio * ratio * speed
		last_drill_speed = 1.0 / drill_time * speed * float(dominant_items)
		progress += delta * speed
	else:
		warmup = source_math_state.source_approach_delta(warmup, 0.0, 0.01, delta)
		last_drill_speed = 0.0
		return {"drill_time": drill_time, "invert_time": invert_time, "smooth_progress": smooth_progress, "warmup": warmup, "time_drilled": time_drilled, "last_drill_speed": last_drill_speed, "progress": progress, "dump_timer": dump_timer, "dump_due": dump_due, "offloaded_count": offloaded_count, "invert_fired": invert_fired}
	if dominant_items > 0 and progress >= drill_time and items_total < item_capacity:
		offloaded_count = dominant_items
		invert_time = 1.0
		invert_fired = true
		progress = fposmod(progress, drill_time)
	return {"drill_time": drill_time, "invert_time": invert_time, "smooth_progress": smooth_progress, "warmup": warmup, "time_drilled": time_drilled, "last_drill_speed": last_drill_speed, "progress": progress, "dump_timer": dump_timer, "dump_due": dump_due, "offloaded_count": offloaded_count, "invert_fired": invert_fired}

@warning_ignore("unused_parameter")
static func source_burst_drill_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the burst-drill tick wiring every tick
	# (BurstDrillBuild.updateTile(), BurstDrill.java:70, runs
	# updateConsumption through super.updateTile(); the base-Drill
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
		# The power consumer reads live since N2149 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a burst drill with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the speed fold (BurstDrill.java:94)
		# follows it. The power consumer counts toward hasConsumers
		# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
		# so a burst drill does not take the early return. A burst
		# drill with no power consumer is untouched: the tick
		# models no other consumers yet (eruption's hydrogen/
		# cyanogen and impact's water/ozone liquid rows wait for
		# their own slices), and BurstDrillBuild overrides
		# shouldConsume (BurstDrill.java:129, `return
		# items.total() <= itemCapacity - dominantItems &&
		# enabled;`) -- N2257 wires the gate through
		# source_burst_drill_should_consume_state(frame,
		# item_capacity): items_total <= item_capacity -
		# dominant_items and enabled when the frame carries the
		# stamped totals, enabled when the frame carries no
		# items_total / dominant_items keys (the N2149 behavior
		# preserved; no live items/dominant state is stamped on
		# any placed-building frame yet). The per-def
		# itemCapacity comes from the catalog block properties
		# (the AdjacentFactory precedent). productionValid is the
		# canonical true default (SourceBuildingAccessState.
		# production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var item_capacity: float = float(block.properties.get("itemCapacity", source_block_defaults.ITEM_CAPACITY_DEFAULT))
			var should_consume: bool = bool(source_burst_drill_should_consume_state(frame, item_capacity).get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_burst_drill_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
