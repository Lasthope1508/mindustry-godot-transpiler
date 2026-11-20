extends RefCounted
class_name SourceBurstDrillBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_drill_dump_runtime_state := preload("res://src/game/SourceDrillDumpRuntimeState.gd")
const source_drill_runtime_state := preload("res://src/game/SourceDrillRuntimeState.gd")
const source_consume_liquid_state := preload("res://src/game/SourceConsumeLiquidState.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_building_draw_state := preload("res://src/game/SourceBuildingDrawState.gd")

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
	# Documented limits: (1) power row only -- the liquid rows
	# fold in the driver when the frame carries liquid
	# observations (N2296); without observations the folded
	# efficiency is the min over the *modeled* consumers
	# (power only). (2)
	# shouldConsume gate -- BurstDrillBuild overrides
	# shouldConsume (BurstDrill.java:129, `return items.total()
	# <= itemCapacity - dominantItems && enabled;`); N2295 wires
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

static func source_burst_drill_liquid_rows_state(frame: Dictionary, delta: float, required_amount: float, booster_amount: float) -> Dictionary:
	# The BurstDrill liquid rows are the two ConsumeLiquid rows
	# each def carries (Blocks.java:3089-3090 impact, :3119-3120
	# eruption): one required liquid and one booster liquid
	# (.boost() makes it optional, Consume.java:33-35, `public Consume boost(){`
	# with `return optional(true, true);`).
	# BuildingComp.updateConsumption (BuildingComp.java:1943-2004)
	# folds the required row into the first pass
	# (BuildingComp.java:1969-1977, `for(var cons : block.nonOptionalConsumers){`
	# / `minEfficiency = Math.min(minEfficiency, result);`) and the booster row
	# into the optional pass (BuildingComp.java:1980-1982,
	# `for(var cons : block.optionalConsumers){` /
	# `optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));`),
	# then assigns `efficiency = minEfficiency;` /
	# `optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);`
	# (BuildingComp.java:1985-1986, `potentialEfficiency = efficiency;`
	# BuildingComp.java:1989) and runs
	# the second pass (`if(update && efficiency > 0){` /
	# `for(var cons : block.updateConsumers){`,
	# BuildingComp.java:1999-2000). Each row's efficiency is
	# ConsumeLiquid.efficiency (ConsumeLiquid.java:42-46,
	# `float ed = build.edelta() * build.efficiencyScale();` /
	# `if(ed <= 0.00000001f) return 0f;` /
	# `return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);`
	# -- there can be more liquid than necessary, so the row caps at 1) with edelta()
	# (BuildingComp.java:1927-1928, `public float edelta(){` with
	# `return efficiency * delta();`) and the default cost multiplier
	# (Consume.java:18, `public Floatf<Building> multiplier = b -> 1f;` --
	# nothing overrides it for burst drills), and each row's
	# removal is ConsumeLiquid.update (ConsumeLiquid.java:37-38,
	# `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));`).
	# The booster row is what feeds the speed fold (BurstDrill.java:94, `float speed =
	# Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) *
	# efficiency;`): without the booster liquid the drill runs
	# at base speed. The default boost intensity is
	# `public float liquidBoostIntensity = 1.6f;` (Drill.java:38);
	# the per-row amount is `public float amount;`
	# (ConsumeLiquidBase.java:8, `/** amount used per frame */`),
	# the flags are `public boolean optional;` and
	# `public boolean booster;` (Consume.java:12, :14), and the
	# block flag is `public @NoPatch boolean hasLiquids;`
	# (Block.java:47). ConsumeLiquidBase.apply sets
	# block.hasLiquids (ConsumeLiquidBase.java:17-19,
	# `block.hasLiquids = true;`), and ConsumeLiquid.apply
	# sets the liquid filter (ConsumeLiquid.java:26-28,
	# `block.liquidFilter[liquid.id] = true;`) -- both are
	# block-level and already true in the registry
	# ("hasLiquids": true); the filter itself is set by the
	# generic apply path, not here. The frame carries
	# `efficiency` (float, absent defaults to 0.0 --
	# `transient float efficiency;`, BuildingComp.java:85),
	# `efficiency_scale` (float, absent defaults to 1.0 --
	# `public float efficiencyScale(){` with `return 1f;`,
	# BuildingComp.java:1939-1941), `required_liquid_stored`
	# and `booster_liquid_stored` (floats, absent default to
	# 0.0 -- a fresh LiquidModule holds 0 of every liquid).
	# delta() is `public float delta(){` with `return
	# Time.delta * timeScale;`, BuildingComp.java:1922-1923 --
	# timeScale is 1 by default and the port passes the raw
	# tick seconds, the N2190 driver convention. The per-def
	# amounts are explicit params (the N2212 / N2248
	# per-def-param precedent): impact-drill water 10f/60f
	# (`consumeLiquid(Liquids.water, 10f/60f);`,
	# Blocks.java:3089) + ozone 3f/60f booster
	# (`consumeLiquid(Liquids.ozone, 3f / 60f).boost();`,
	# Blocks.java:3090); eruption-drill hydrogen 4f/60f
	# (`consumeLiquid(Liquids.hydrogen, 4f / 60f);`,
	# Blocks.java:3119) + cyanogen 0.75f/60f booster
	# (`consumeLiquid(Liquids.cyanogen, 0.75f / 60f).boost();`,
	# Blocks.java:3120). The removal application
	# (`build.liquids.remove(...)`) waits for the driver slice
	# that owns the liquids module; the remove_amount results
	# are the observable signal that slice will consume. The
	# setStats booster display row (Drill.java:183-189,
	# `if(liquidBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){`)
	# is stats display, not tick state, and waits for its own
	# slice. The row's display is ConsumeLiquid.display
	# (ConsumeLiquid.java:51,
	# `stats.add(booster ? Stat.booster : Stat.input, liquid, amount * 60f, true);`)
	# and its match is ConsumeLiquid.consumes
	# (ConsumeLiquid.java:56, `return liquid == this.liquid;`).
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var efficiency_scale: float = float(frame.get("efficiency_scale", 1.0))
	var required_liquid_stored: float = float(frame.get("required_liquid_stored", 0.0))
	var booster_liquid_stored: float = float(frame.get("booster_liquid_stored", 0.0))
	var edelta: float = efficiency * delta
	var ed: float = edelta * efficiency_scale
	var cost_multiplier := 1.0
	var required_efficiency: float = float(source_consume_liquid_state.efficiency_state(required_liquid_stored, required_amount, edelta, efficiency_scale, cost_multiplier).get("efficiency", 0.0))
	var booster_efficiency: float = float(source_consume_liquid_state.efficiency_state(booster_liquid_stored, booster_amount, edelta, efficiency_scale, cost_multiplier).get("efficiency", 0.0))
	var required_remove_amount: float = required_amount * edelta * cost_multiplier
	var booster_remove_amount: float = booster_amount * edelta * cost_multiplier
	# The removal only runs in the second pass, which
	# BuildingComp runs only when the folded efficiency is
	# positive (BuildingComp.java:1999-2000, `if(update &&
	# efficiency > 0){` / `for(var cons : block.
	# updateConsumers){`): with no required liquid the fold is
	# zero and nothing is removed, even though edelta itself
	# is positive. The fold here is the frame efficiency
	# (power fold so far) against the required row -- the
	# booster row is optional and never drags the fold down.
	var folded_efficiency: float = minf(efficiency, required_efficiency)
	if folded_efficiency <= 0.0:
		required_remove_amount = 0.0
		booster_remove_amount = 0.0
	var required_row := {"result": required_efficiency, "is_power": false}
	var optional_row := {"result": booster_efficiency}
	var has_liquids := true
	return {"edelta": edelta, "ed": ed, "required_efficiency": required_efficiency, "booster_efficiency": booster_efficiency, "required_remove_amount": required_remove_amount, "booster_remove_amount": booster_remove_amount, "required_row": required_row, "optional_row": optional_row, "has_liquids": has_liquids}

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

static func source_burst_drill_icons_state(region: Variant, top_region: Variant) -> Dictionary:
	# BurstDrill.icons() (BurstDrill.java:48-50):
	# @Override
	# public TextureRegion[] icons(){
	# return new TextureRegion[]{region, topRegion};
	# }
	# This slice pins ONLY the override's two-element return array, region first. region is the inherited block region (Block.java:427): `public TextureRegion region;` -- the block's own region, the block name. topRegion is the Drill base field (Drill.java:73): `public @Load("@-top") TextureRegion topRegion;` -- loaded as name + "-top". The Block.icons() base (`protected TextureRegion[] icons(){`, Block.java:976-980, the variants/teamRegion fold) is NOT this slice: BurstDrill overrides it. The getGeneratedIcons cache (`public TextureRegion[] getGeneratedIcons(){`, Block.java:986, `return generatedIcons == null ? (generatedIcons = icons()) : generatedIcons;`, Block.java:987) is likewise deferred -- only the override's return array is pinned (the N2250 Radar.icons() precedent, itself following the N2227 RepairTurret.icons() precedent: "TextureRegion internals and inherited region loading remain deferred; explicit inputs carry region and topRegion field values", pinned as the identity pure function source_tractor_beam_turret_icons_state).
	# The classes (BurstDrill.java:17): `public class BurstDrill extends Drill{`; (Drill.java:27): `public class Drill extends Block{`.
	# Per-def region ids: impact-drill ("impact-drill", Blocks.java:3070) -> ["impact-drill", "impact-drill-top"]; eruption-drill ("eruption-drill", Blocks.java:3093) -> ["eruption-drill", "eruption-drill-top"].
	# There is no driver tick line: icons() is a load-time region accessor, not a per-tick write (the N2217 read/write + N2224 setStats lifecycle precedent).
	var icons: Array = [region, top_region]
	return {"icons": icons}

static func source_burst_drill_ambient_volume_state(super_ambient_volume: float, progress: float) -> Dictionary:
	# BurstDrill.ambientVolume() (BurstDrill.java:123-125):
	# @Override
	# public float ambientVolume(){
	# return super.ambientVolume() * Mathf.pow(progress(), 4f);
	# }
	# `super.ambientVolume()` is DrillBuild.ambientVolume (Drill.java:257-259, `return efficiency * (size * size) / 4f;`) -- NOT this slice: the Drill super formula waits for its own slice; the caller passes the already-computed super result (the N2316 explicit-param precedent). `progress()` is DrillBuild.progress (`public float progress(){`, Drill.java:327-329, `return dominantItem == null ? 0f : Mathf.clamp(progress / getDrillTime(dominantItem));`) -- NOT this slice for DrillBuild either (N700 / N1627 are PortGame game-level progress): the caller passes the already-computed progress (same precedent). `progress` is the DrillBuild field (`public float progress;`, Drill.java:238). The classes are `public class BurstDrill extends Drill{` (BurstDrill.java:17) and `public class Drill extends Block{` (Drill.java:27). Per-def supers at efficiency 1 (size 4 impact-drill, Blocks.java:3073; size 5 eruption-drill, Blocks.java:3096): 4.0 vs 6.25. There is NO driver tick line: ambientVolume is read per tick by the ambient-sound live loop (`control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());`, BuildingComp.java:2271); the driver side waits for the ambient C mixer slice (N2264).
	var ambient_volume: float = super_ambient_volume * pow(progress, 4.0)
	return {"ambient_volume": ambient_volume}

static func source_drill_ambient_volume_state(frame: Dictionary, size: int) -> Dictionary:
	# DrillBuild.ambientVolume() (Drill.java:257-259):
	# @Override
	# public float ambientVolume(){
	# return efficiency * (size * size) / 4f;
	# }
	# `efficiency` is the live Building efficiency (`transient float efficiency;`, BuildingComp.java:85), carried on the frame (absent defaults to 0.0 -- the N2296 liquid-rows frame-key precedent). `size` is the block size in tiles (`public int size = 1;`, Block.java:215) -- a per-def param passed explicitly (the N2212 per-def-param precedent): impact-drill size 4 (Blocks.java:3073), eruption-drill size 5 (Blocks.java:3096). At efficiency 1 the super is 4.0 vs 6.25 -- the exact values N2317 takes as its explicit super input (the N2317 pure function takes the super result as an explicit input; this slice closes that super-leg deferred entry). The classes are `public class Drill extends Block{` (Drill.java:27) and `public class DrillBuild extends Building{` (Drill.java:237). The defs are `impactDrill = new BurstDrill("impact-drill"){{` (Blocks.java:3070) and `eruptionDrill = new BurstDrill("eruption-drill"){{` (Blocks.java:3093). There is NO driver tick line: ambientVolume is read per tick by the ambient-sound live loop (`control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());`, BuildingComp.java:2271); the driver side waits for the ambient C mixer slice (N2264).
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var ambient_volume: float = efficiency * (size * size) / 4.0
	return {"ambient_volume": ambient_volume}

@warning_ignore("unused_parameter")
static func source_drill_should_ambient_sound_state(frame: Dictionary, efficiency: float, items_total: int, item_capacity: int) -> Dictionary:
	# DrillBuild.shouldAmbientSound() (Drill.java:252-254):
	# @Override
	# public boolean shouldAmbientSound(){
	# return efficiency > 0.01f && items.total() < itemCapacity;
	# }
	# `efficiency` is the live Building efficiency (`transient float efficiency;`, BuildingComp.java:85). `items.total()` is the cached ItemModule total (`public int total(){` with `return total;`, ItemModule.java:174-175). `itemCapacity` is the per-def capacity (`public int itemCapacity = 10;`, Block.java:75, with `itemCapacity = 40;`, Blocks.java:3078, for impact-drill and `itemCapacity = 60;`, Blocks.java:3107, for eruption-drill). The BuildingComp default delegates to shouldConsume (`public boolean shouldAmbientSound(){` with `return shouldConsume();`, BuildingComp.java:1212-1214) -- the Drill override replaces it with the efficiency gate. The gate is read per tick by the ambient-sound live loop (`if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){` with `control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());`, BuildingComp.java:2270-2271). The three inputs are explicit params (the N2317/N2277 super-as-param precedent): the caller passes the already-folded efficiency and the live items total; frame is the canonical first param of this family file. This is a Drill-local boolean predicate -- NOT part of the ambient B/C chain (B = RepairTurret driver tick, Windows line; C = SoundControl.updateLoops mixer, N2304 held): it gates the loop call, it is not the loop itself. It is distinct from the ambient volume (N2277, `efficiency * (size * size) / 4f`) and from shouldConsume (N2295, which also requires `enabled && dominantItem != null`). The classes are `public class Drill extends Block{` (Drill.java:27) and `public class DrillBuild extends Building{` (Drill.java:237); BurstDrillBuild inherits DrillBuild (`public class BurstDrill extends Drill{`, BurstDrill.java:17, with `public class BurstDrillBuild extends DrillBuild{`, BurstDrill.java:70). There is NO driver tick line: the gate is a pure predicate the loop reads; the driver side waits for ambient C (N2304).
	return {"should_ambient_sound": efficiency > 0.01 and items_total < item_capacity}

static func source_burst_drill_set_stats_state(frame: Dictionary, liquid_boost_intensity: float, booster_consumer_found: bool, booster_amount: float, booster_consumes: bool) -> Dictionary:
	# BurstDrill.setStats() (BurstDrill.java:58-68):
	# public void setStats(){
	# super.setStats();
	# if(liquidBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){
	# stats.remove(Stat.booster);
	# stats.add(Stat.booster,
	# StatValues.speedBoosters("{0}" + StatUnit.timesSpeed.localized(),
	# consBase.amount, liquidBoostIntensity, false, consBase::consumes)
	# );
	# }
	# }
	# `super.setStats();` (BurstDrill.java:59) is Drill.setStats, NOT this slice: Drill.setStats (Drill.java:177-191) adds the drillSpeed row and its own booster row with the SQUARED intensity (`liquidBoostIntensity * liquidBoostIntensity, false, consBase::consumes)`, Drill.java:188). The BurstDrill override removes that row first (`stats.remove(Stat.booster);`, BurstDrill.java:62) and re-adds it with the PLAIN intensity (`consBase.amount, liquidBoostIntensity, false, consBase::consumes)`, BurstDrill.java:65) -- the remove-then-add is what pins the displayed speed to the plain intensity, not the square. The guard is `liquidBoostIntensity != 1` AND a booster consumer found (`if(liquidBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){`, BurstDrill.java:61). findConsumer (`public <T extends Consume> T findConsumer(Boolf<Consume> filter){`, Block.java:1104) is NOT ported here: the caller passes the already-found result (booster_consumer_found / booster_amount / booster_consumes) -- the N1688/N1753 findConsumer precedent. `consBase.amount` is the per-frame liquid amount (`public float amount;`, ConsumeLiquidBase.java:8); `consBase::consumes` is the liquid filter (`public abstract boolean consumes(Liquid liquid);`, ConsumeLiquidBase.java:21). The `false` strength arg (BurstDrill.java:65) means the displayed speed is the plain intensity, not heatCapacity-scaled (StatValues.java:522, `public static StatValue speedBoosters(String unit, float amount, float speed, boolean strength, Boolf<Liquid> filter){`, StatValues.java:506). The speedBoosters unit is `"{0}" + StatUnit.timesSpeed.localized()` (BurstDrill.java:64): `timesSpeed = new StatUnit("timesSpeed", false),` (StatUnit.java:34) and localized() reads bundle key "unit.timesspeed" (StatUnit.java:61-62), English value "x speed" (bundle.properties:1364), so the format is "{0} x speed". The classes are `public class BurstDrill extends Drill{` (BurstDrill.java:17). Per-def values: the class default is `public float liquidBoostIntensity = 1.6f;` (Drill.java:38); impact-drill `liquidBoostIntensity = 1.75f;` (Blocks.java:3084) with booster `consumeLiquid(Liquids.ozone, 3f / 60f).boost();` (Blocks.java:3090); eruption-drill `liquidBoostIntensity = 2f;` (Blocks.java:3115) with booster `consumeLiquid(Liquids.cyanogen, 0.75f / 60f).boost();` (Blocks.java:3120). The booster filter flag comes from `public boolean booster;` (Consume.java:14). frame carries no live keys for this block-level stat read -- liquidBoostIntensity and the booster consumer are per-def static state, not live frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file. There is NO driver tick line: setStats is a stat-display read, not a per-tick write (the N2224 / N2246 setStats lifecycle precedent).
	var booster_present: bool = liquid_boost_intensity != 1.0 and booster_consumer_found
	var booster_row_removed: bool = booster_present
	var booster_row: Variant = null
	if booster_present:
		booster_row = {"format": "{0} x speed", "amount": booster_amount, "intensity": liquid_boost_intensity, "strength": false, "consumes": booster_consumes}
	return {"booster_row_removed": booster_row_removed, "booster_row": booster_row}

static func source_drill_set_stats_state(frame: Dictionary, drill_time: float, hardness_drill_multiplier: float, size: int, tier: int, drill_multipliers: Dictionary, blocked_items: Variant, liquid_boost_intensity: float, booster_consumer_found: bool, booster_amount: float, booster_consumes: bool) -> Dictionary:
	# Drill.setStats() (Drill.java:175-191):
	# public void setStats(){
	# super.setStats();
	#
	# stats.add(Stat.drillTier, StatValues.drillables(drillTime, hardnessDrillMultiplier, size * size, drillMultipliers, b -> b instanceof Floor f && !f.wallOre && f.itemDrop != null &&
	# f.itemDrop.hardness <= tier && (blockedItems == null || !blockedItems.contains(f.itemDrop)) && (indexer.isBlockPresent(f) || state.isMenu())));
	#
	# stats.add(Stat.drillSpeed, 60f / drillTime * size * size, StatUnit.itemsSecond);
	#
	# if(liquidBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){
	# stats.remove(Stat.booster);
	# stats.add(Stat.booster,
	# StatValues.speedBoosters("{0}" + StatUnit.timesSpeed.localized(),
	# consBase.amount,
	# liquidBoostIntensity * liquidBoostIntensity, false, consBase::consumes)
	# );
	# }
	# }
	# `super.setStats();` (Drill.java:176) is Block.setStats, owned by N1696 at PortGame (`PortGame.source_block_set_stats_state`), NOT this slice. The drillTier row pins the StatValues.drillables call args (StatValues.java:413, `public static StatValue drillables(float drillTime, float drillMultiplier, float size, ObjectFloatMap<Item> multipliers, Boolf<Block> filter){`): drillTime, hardnessDrillMultiplier, size * size (the drillables `size` param is the block area), drillMultipliers, tier (the filter's `f.itemDrop.hardness <= tier`) and blockedItems (the filter's `blockedItems == null || !blockedItems.contains(f.itemDrop)`). The filter's per-floor evaluation (`indexer.isBlockPresent(f) || state.isMenu()`, Drill.java:179) and the displayed per-ore table (StatValues.java:413-437, `content.blocks()` iteration; per-ore rate `60f / (Math.max(drillTime + drillMultiplier * block.itemDrop.hardness, drillTime) / multipliers.get(block.itemDrop, 1f)) * size`) are display-time, NOT this slice: this function pins the args setStats captures, the table renders them. The drillSpeed row is the computed value `60f / drillTime * size * size` with unit StatUnit.itemsSecond (`itemsSecond = new StatUnit("itemsSecond"),`, StatUnit.java:20; localized "items/second", bundle.properties:1354, `unit.itemssecond = items/second`). The booster row uses the SQUARED intensity (`liquidBoostIntensity * liquidBoostIntensity, false, consBase::consumes)`, Drill.java:188) -- the TRAP vs N2309, whose BurstDrill override row uses the PLAIN intensity (`consBase.amount, liquidBoostIntensity, false, consBase::consumes)`, BurstDrill.java:65): the override removes this row first (BurstDrill.java:62) and re-adds it plain, so the displayed speed is the plain intensity, not the square. The guard is `liquidBoostIntensity != 1` AND a booster consumer found (`if(liquidBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){`, Drill.java:183). findConsumer (`public <T extends Consume> T findConsumer(Boolf<Consume> filter){`, Block.java:1104) is NOT ported here: the caller passes the already-found result (booster_consumer_found / booster_amount / booster_consumes) -- the N1688/N1753 findConsumer precedent. `consBase.amount` is the per-frame liquid amount (`public float amount;`, ConsumeLiquidBase.java:8); `consBase::consumes` is the liquid filter (`public abstract boolean consumes(Liquid liquid);`, ConsumeLiquidBase.java:21). The `false` strength arg (Drill.java:188) means the displayed speed is the squared intensity, not heatCapacity-scaled (StatValues.java:522). The speedBoosters unit is `"{0}" + StatUnit.timesSpeed.localized()` (Drill.java:187): `timesSpeed = new StatUnit("timesSpeed", false),` (StatUnit.java:34) and localized() reads bundle key "unit.timesspeed" (StatUnit.java:61-62), English value "x speed" (bundle.properties:1364), so the format is "{0} x speed". The stats are `drillTier = new Stat("drillTier", StatCat.crafting),` and `drillSpeed = new Stat("drillSpeed", StatCat.crafting),` (Stat.java:71-72). The classes are `public class Drill extends Block{` (Drill.java:27). Per-def values: the class defaults are `public float hardnessDrillMultiplier = 50f;` (Drill.java:28), `public int tier;` (Drill.java:34, no default -- Java int default 0), `public float drillTime = 300;` (Drill.java:36), `public float liquidBoostIntensity = 1.6f;` (Drill.java:38); `size` is the block size in tiles (`public int size = 1;`, Block.java:215); `drillMultipliers` is `public ObjectFloatMap<Item> drillMultipliers = new ObjectFloatMap<>();` (Drill.java:66); `blockedItems` is `public @Nullable Seq<Item> blockedItems;` (Drill.java:44, set from `blockedItem` at :93-94). Impact-drill (Blocks.java:3070): `drillTime = 60f * 12f;` (720f), `size = 4;`, `tier = 6;`, `drillMultipliers.put(Items.beryllium, 2f);`, `liquidBoostIntensity = 1.75f;` with booster `consumeLiquid(Liquids.ozone, 3f / 60f).boost();`; eruption-drill (Blocks.java:3093): `drillTime = 281.25f;`, `size = 5;`, `tier = 7;`, `drillMultipliers.put(Items.beryllium, 2f);`, `liquidBoostIntensity = 2f;` with booster `consumeLiquid(Liquids.cyanogen, 0.75f / 60f).boost();`. This slice CLOSES the super-leg deferred entry N2309 carried ("BurstDrill setStats() super leg (Drill.setStats, Drill.java:177-191...)"). frame carries no live keys for this block-level stat read -- drillTime, tier, size, drillMultipliers, blockedItems, liquidBoostIntensity and the booster consumer are per-def static state, not live frame keys (the N2212 / N2224 per-def-param precedent); frame is the canonical first param of this family file. There is NO driver tick line: setStats is a stat-display read, not a per-tick write (the N2224 / N2246 setStats lifecycle precedent).
	var drill_tier_row: Dictionary = {"drill_time": drill_time, "hardness_drill_multiplier": hardness_drill_multiplier, "size_squared": size * size, "drill_multipliers": drill_multipliers, "tier": tier, "blocked_items": blocked_items}
	var drill_speed_row: Dictionary = {"value": 60.0 / drill_time * size * size, "unit": "items/second"}
	var booster_present: bool = liquid_boost_intensity != 1.0 and booster_consumer_found
	var booster_row_removed: bool = booster_present
	var booster_row: Variant = null
	if booster_present:
		booster_row = {"format": "{0} x speed", "amount": booster_amount, "intensity": liquid_boost_intensity * liquid_boost_intensity, "strength": false, "consumes": booster_consumes}
	return {"drill_tier_row": drill_tier_row, "drill_speed_row": drill_speed_row, "booster_row_removed": booster_row_removed, "booster_row": booster_row}

static func source_drill_draw_select_state(x: float, y: float, block_size: int, tilesize: float, icon_small: float, has_dominant_item: bool, dominant_item_icon_ratio: float) -> Dictionary:
	# DrillBuild.drawSelect() (Drill.java:262-264):
	# public void drawSelect(){
	# drawItemSelection(dominantItem);
	# }
	# draws the dominant item's icon above the building through BuildingComp.drawItemSelection (BuildingComp.java:1249-1257):
	# public void drawItemSelection(@Nullable UnlockableContent selection){
	# if(selection != null){
	# float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;
	# Draw.mixcol(Color.darkGray, 1f);
	# Draw.rect(selection.fullIcon, dx, dy - 1, s, h);
	# Draw.reset();
	# Draw.rect(selection.fullIcon, dx, dy, s, h);
	# }
	# }
	# The dominant item is `public Item dominantItem;` (Drill.java:244), set by the N2262 ore/dominant binding; the caller passes it as explicit params (has_dominant_item, dominant_item_icon_ratio) -- the N2311/N2321/N2281 explicit-param precedent. The helper is ALREADY LIVE at PortGame N570 (SourceBuildingDrawState.draw_item_selection_state, `source_building_draw_state.draw_item_selection_state`), so this function delegates to it and does NOT re-port the helper: the helper owns the guard, the geometry (dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * ratio, h = iconSmall / 4f), the darkGray shadow rect at dy - 1 and the foreground rect at dy, returning the nine result keys visible, dx, dy, shadow_color, shadow_alpha, shadow_y, foreground_y, selection_width, selection_height (hidden -- only visible -- when there is no dominant item). tilesize is 8 (`public static final int tilesize = 8;`, Vars.java:135) and iconSmall is 24 (`iconSmall = 8*3f;`, Vars.java:139), both passed explicitly. Per-def sizes: impact-drill `size = 4;` (Blocks.java:3073), eruption-drill `size = 5;` (Blocks.java:3096). The classes are `public class Drill extends Block{` (Drill.java:27) and `public class DrillBuild extends Building{` (Drill.java:237); BurstDrillBuild inherits DrillBuild (`public class BurstDrill extends Drill{`, BurstDrill.java:17). This is a different method from RepairTurret drawSelect N2220 (different class) -- no overlap. There is NO driver tick line: drawSelect is selection UI, not per-tick state (the accessor precedent N2311/N2321/N2281).
	return source_building_draw_state.draw_item_selection_state(has_dominant_item, x, y, block_size, tilesize, icon_small, dominant_item_icon_ratio)

@warning_ignore("unused_parameter")
static func source_burst_drill_draw_state(x: float, y: float, region: Variant, top_region: Variant, item_region: Variant, arrow_region: Variant, arrow_blur_region: Variant, glow_region: Variant, top_invert_region: Variant, invert_time: float, smooth_progress: float, has_dominant_item: bool, dominant_item_color: Variant, draw_mine_item: bool, arrows: int, arrow_spacing: float, arrow_offset: float, arrow_color: Variant, base_arrow_color: Variant, glow_color: Variant, top_invert_region_found: bool, arrow_blur_region_found: bool, glow_region_found: bool, draw_default_cracks: Dictionary) -> Dictionary:
	# N2314 -- BurstDrillBuild.draw() (BurstDrill.java:133-180)
	# public void draw(){
	#     Draw.rect(region, x, y);
	#     drawDefaultCracks();
	#
	#     Draw.rect(topRegion, x, y);
	#
	#     if(invertTime > 0 && topInvertRegion.found()){
	#         Draw.alpha(Interp.pow3Out.apply(invertTime));
	#         Draw.rect(topInvertRegion, x, y);
	#         Draw.color();
	#     }
	#
	#     if(dominantItem != null && drawMineItem){
	#         Draw.color(dominantItem.color);
	#         Draw.rect(itemRegion, x, y);
	#         Draw.color();
	#     }
	#
	#     float fract = smoothProgress;
	#
	#     Draw.color(arrowColor);
	#     for(int i = 0; i < 4; i++){
	#         for(int j = 0; j < arrows; j++){
	#             float arrowFract = (arrows - 1 - j);
	#             float a = Mathf.clamp(fract * arrows - arrowFract);
	#             Tmp.v1.trns(i * 90 + 45, j * arrowSpacing + arrowOffset);
	#
	#             //TODO maybe just use arrow alpha and draw gray on the base?
	#             Draw.z(Layer.block);
	#             Draw.color(baseArrowColor, arrowColor, a);
	#             Draw.rect(arrowRegion, x + Tmp.v1.x, y + Tmp.v1.y, i * 90);
	#
	#             Draw.color(arrowColor);
	#
	#             if(arrowBlurRegion.found()){
	#                 Draw.z(Layer.blockAdditive);
	#                 Draw.blend(Blending.additive);
	#                 Draw.alpha(Mathf.pow(a, 10f));
	#                 Draw.rect(arrowBlurRegion, x + Tmp.v1.x, y + Tmp.v1.y, i * 90);
	#                 Draw.blend();
	#             }
	#         }
	#     }
	#
	#     Draw.color();
	#
	#     if(glowRegion.found()){
	#         Drawf.additive(glowRegion, Tmp.c2.set(glowColor).a(Mathf.pow(fract, 3f) * glowColor.a), x, y);
	#     }
	# }
	# This is the BurstDrillBuild OVERRIDE: public class BurstDrill extends Drill{
	# (BurstDrill.java:17), public class BurstDrillBuild extends DrillBuild{ (BurstDrill.java:70).
	# The DrillBuild.draw() BASE (Drill.java:346-379, public class Drill extends Block{
	# (Drill.java:27), public class DrillBuild extends Building{ (Drill.java:237)) is a LATER
	# slice (N2317), NOT this one. drawDefaultCracks() -- public void drawDefaultCracks(){
	# (Drill.java:341-343) -- is a callee (D5): its already-computed result rides in as
	# draw_default_cracks, NOT re-ported. Fields: public float smoothProgress = 0f;
	# public float invertTime = 0f; public float arrowSpacing = 4f, arrowOffset = 0f;
	# public int arrows = 3;
	# public Color arrowColor = Color.valueOf("feb380"), baseArrowColor = Color.valueOf("6e7080");
	# public Color glowColor = arrowColor.cpy();
	# public @Load("@-top-invert") TextureRegion topInvertRegion;
	# public @Load("@-glow") TextureRegion glowRegion;
	# public @Load("@-arrow") TextureRegion arrowRegion;
	# public @Load("@-arrow-blur") TextureRegion arrowBlurRegion;
	# public boolean drawMineItem = true; public Item dominantItem;
	# public @Load("@-top") TextureRegion topRegion;
	# public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;
	# public TextureRegion region; (Block.java:427)
	# Per-def: impact-drill (Blocks.java:3070-3092) uses class defaults, size = 4;;
	# eruption-drill (Blocks.java:3093-3120) overrides size = 5;, arrowOffset = 2f;,
	# arrowSpacing = 5f;, arrows = 2;, glowColor.a = 0.6f;.
	# Pure function: returns the computed draw state (rects, colors, alpha, z, blend, glow)
	# and does NOT touch real Draw/Drawf playback. Formulas: Interp.pow3Out.apply(t) =
	# 1 - (1 - t)^3 (arc Interp.java PowOut, power 3); Mathf.clamp(x) clamps to [0, 1]
	# (arc Mathf.java:402-404); Tmp.v1.trns(angle, len) rotates (len, 0) by the angle in
	# degrees (arc Vec2.java:40-42); Draw.color(a, b, s) lerps a toward b by s (arc
	# Draw.java:234-236); Layer.block = 30, Layer.blockAdditive = 31 (Layer.java:27,36).
	var arrow_col: Color = arrow_color
	var base_arrow_col: Color = base_arrow_color
	var glow_col: Color = glow_color
	var invert_visible: bool = invert_time > 0.0 and top_invert_region_found
	var invert_alpha: float = 1.0 - pow(1.0 - invert_time, 3.0) if invert_visible else 0.0
	var invert_rect: Variant = {"region": top_invert_region, "x": x, "y": y, "alpha": invert_alpha} if invert_visible else null
	var mine_item_visible: bool = has_dominant_item and draw_mine_item
	var mine_item_rect: Variant = {"region": item_region, "x": x, "y": y, "color": dominant_item_color} if mine_item_visible else null
	var fract: float = smooth_progress
	var arrow_list: Array = []
	for i in range(4):
		for j in range(arrows):
			var arrow_fract: float = float(arrows - 1 - j)
			var a: float = clampf(fract * float(arrows) - arrow_fract, 0.0, 1.0)
			var angle_deg: float = float(i * 90 + 45)
			var distance: float = float(j) * arrow_spacing + arrow_offset
			var offset: Vector2 = Vector2(cos(deg_to_rad(angle_deg)), sin(deg_to_rad(angle_deg))) * distance
			var arrow_color_lerp: Color = base_arrow_col.lerp(arrow_col, a)
			var blur_visible: bool = arrow_blur_region_found
			var blur_alpha: float = pow(a, 10.0) if blur_visible else 0.0
			arrow_list.append({
				"region": arrow_region,
				"x": x + offset.x,
				"y": y + offset.y,
				"alpha": a,
				"color": arrow_color_lerp,
				"rotation_deg": float(i * 90),
				"blur_visible": blur_visible,
				"blur_alpha": blur_alpha,
				"blur_region": arrow_blur_region,
				"z": 30,
				"blur_z": 31,
				"blur_blend": "additive",
			})
	var glow_visible: bool = glow_region_found
	var glow_alpha: float = pow(fract, 3.0) * glow_col.a if glow_visible else 0.0
	var glow_result: Color = glow_col
	glow_result.a = glow_alpha
	return {
		"base_rect": {"region": region, "x": x, "y": y},
		"cracks": draw_default_cracks,
		"top_rect": {"region": top_region, "x": x, "y": y},
		"invert_visible": invert_visible,
		"invert_alpha": invert_alpha,
		"invert_rect": invert_rect,
		"mine_item_visible": mine_item_visible,
		"mine_item_rect": mine_item_rect,
		"fract": fract,
		"arrow_count": 4 * arrows,
		"arrows": arrow_list,
		"glow_visible": glow_visible,
		"glow_alpha": glow_alpha,
		"glow_color": glow_result,
	}

@warning_ignore("unused_parameter")
static func source_drill_sense_object_state(frame: Dictionary, sensor: String, has_dominant_item: bool, dominant_item: Variant, super_sense_object_value: Variant) -> Dictionary:
	# DrillBuild.senseObject() (Drill.java:281-284):
	# public Object senseObject(LAccess sensor){
	# if(sensor == LAccess.firstItem) return dominantItem;
	# return super.senseObject(sensor);
	# }
	# over the base default BuildingComp.senseObject() (BuildingComp.java:2128-2136, inside `public Object senseObject(LAccess sensor){`, BuildingComp.java:2128):
	# return switch(sensor){
	# case type -> block;
	# case firstItem -> items == null ? null : items.first();
	# case config -> block.configSenseable() ? config() : null;
	# case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;
	# default -> noSensed;
	# };
	# The sensor spelling is the LAccess enum name `firstItem,` (LAccess.java:8). The dominant item is `public Item dominantItem;` (Drill.java:244), set by the N2262 ore/dominant binding; the caller passes it as explicit params (has_dominant_item, dominant_item) -- the N2311/N2321/N2281 explicit-param precedent. senseObject returns dominantItem itself for firstItem -- null when no dominant item is bound -- and falls through to the caller-passed super result otherwise: the super leg is the live BuildingComp sense (N636, PortGame.source_building_sense_object_state), passed in as an explicit param (the N2317/N2277 super-as-param precedent). The classes are `public class Drill extends Block{` (Drill.java:27) and `public class DrillBuild extends Building{` (Drill.java:237); BurstDrillBuild inherits DrillBuild (`public class BurstDrill extends Drill{`, BurstDrill.java:17). This is a different method from RepairTurret senseObject N2229 (different class) -- no overlap. There is NO driver tick line: senseObject is a logic read, not per-tick state (the N2206 / N2208 / N2223 precedent); the logic-processor dispatch hook is its own later slice.
	if sensor == "firstItem":
		return {"handled": true, "sense_object_value": dominant_item}
	return {"handled": false, "sense_object_value": super_sense_object_value}

@warning_ignore("unused_parameter")
static func source_drill_sense_state(frame: Dictionary, sensor: String, has_dominant_item: bool, progress: float, super_sense_value: Variant, super_sense_value_is_nan: bool) -> Dictionary:
	# DrillBuild.sense() (Drill.java:333-336):
	# public double sense(LAccess sensor){
	# if(sensor == LAccess.progress && dominantItem != null) return progress;
	# return super.sense(sensor);
	# }
	# over the base default BuildingComp.sense() (BuildingComp.java:2093, `public double sense(LAccess sensor){`), whose default is `default -> Float.NaN; //gets converted to null in logic` (BuildingComp.java:2123). The sensor spelling is the LAccess enum name `progress,` (LAccess.java:28). `progress` is the DrillBuild field (`public float progress;`, Drill.java:238), advanced in updateTile (N2294) -- NOT the clamped progress() (`public float progress(){`, Drill.java:327-329, `return dominantItem == null ? 0f : Mathf.clamp(progress / getDrillTime(dominantItem));`), which is its own slice: sense() returns the raw field. The dominant item is `public Item dominantItem;` (Drill.java:244), set by the N2262 ore/dominant binding; the caller passes whether one is bound as has_dominant_item -- the N2311/N2321/N2281 explicit-param precedent. The super leg is the live BuildingComp sense (N1078-N1085), passed in as explicit params (super_sense_value, super_sense_value_is_nan) following the N2317/N2277 super-as-param precedent; the fallthrough leg returns the caller-passed super result. The classes are `public class Drill extends Block{` (Drill.java:27) and `public class DrillBuild extends Building{` (Drill.java:237); BurstDrillBuild inherits DrillBuild (`public class BurstDrill extends Drill{`, BurstDrill.java:17). This is a different method from Turret sense N2293 (different class) -- no overlap. There is NO driver tick line: sense is a logic read, not per-tick state (the N2206 / N2208 / N2223 precedent); the logic-processor dispatch hook is its own later slice.
	if sensor == "progress" and has_dominant_item:
		return {"handled": true, "sense_value": progress, "sense_value_is_nan": false}
	return {"handled": false, "sense_value": super_sense_value, "sense_value_is_nan": super_sense_value_is_nan}

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

static func source_burst_drill_on_proximity_update_state(linked_tiles: Array, tier: int, blocked_items: Variant) -> Dictionary:
	# DrillBuild.onProximityUpdate (Drill.java:266-277,
	# `public void onProximityUpdate(){` with
	# `super.onProximityUpdate();` / `countOre(tile);` /
	# `dominantItem = returnItem;` /
	# `dominantItems = returnCount;`) is inherited whole by
	# BurstDrillBuild (BurstDrill.java:17, `public class
	# BurstDrill extends Drill{`, with BurstDrillBuild,
	# BurstDrill.java:70, `public class BurstDrillBuild
	# extends DrillBuild{`, and DrillBuild,
	# Drill.java:237, `public class DrillBuild extends
	# Building{`) -- BurstDrill does not override it.
	# countOre (Drill.java:198-229):
	# `protected void countOre(Tile tile){`
	# resets the return and the tallies:
	# `returnItem = null;`
	# `returnCount = 0;`
	# `oreCount.clear();`
	# `itemArray.clear();`
	# counts the drop of every linked tile canMine accepts:
	# `for(Tile other : tile.getLinkedTilesAs(this, tempTiles)){`
	# `if(canMine(other)){`
	# `oreCount.increment(getDrop(other), 0, 1);`
	# collects the counted items:
	# `for(Item item : oreCount.keys()){`
	# `itemArray.add(item);`
	# sorts them low-priority-last, then by count, then
	# by id:
	# `int type = Boolean.compare(!item1.lowPriority, !item2.lowPriority);`
	# `if(type != 0) return type;`
	# `int amounts = Integer.compare(oreCount.get(item1, 0), oreCount.get(item2, 0));`
	# `if(amounts != 0) return amounts;`
	# `return Integer.compare(item1.id, item2.id);`
	# and peeks the last one:
	# `if(itemArray.size == 0){`
	# `returnItem = itemArray.peek();`
	# `returnCount = oreCount.get(itemArray.peek(), 0);`
	# canMine (Drill.java:230-235):
	# `public boolean canMine(Tile tile){`
	# rejects a null or static tile:
	# `if(tile == null || tile.block().isStatic()) return false;`
	# and requires a drop whose hardness is at most the
	# tier and which is not blocked:
	# `Item drops = tile.drop();`
	# `return drops != null && drops.hardness <= tier && (blockedItems == null || !blockedItems.contains(drops));`
	# The fields are:
	# `public int tier;`
	# `public @Nullable Item blockedItem;`
	# `public @Nullable Seq<Item> blockedItems;`
	# `protected @Nullable Item returnItem;`
	# `protected int returnCount;`
	# `public int dominantItems;`
	# `public Item dominantItem;`
	# (Drill.java:239-244). Drill.init (Drill.java:93-94)
	# turns a lone blockedItem into the list:
	# `if(blockedItems == null && blockedItem != null){`
	# `blockedItems = Seq.with(blockedItem);`
	# The core count lives in SourceDrillRuntimeState.
	# source_on_proximity_update_state (N2010/N2020), so
	# this gate delegates to it instead of porting countOre
	# again -- one pure function, one owner. The per-def
	# tier / blockedItem are explicit params (the N2212 /
	# N2248 per-def-param precedent): impact-drill tier 6
	# (`tier = 6;`, Blocks.java:3076) with blockedItem
	# thorium (`blockedItem = Items.thorium;`,
	# Blocks.java:3080); eruption-drill tier 7
	# (`tier = 7;`, Blocks.java:3097) with no blocked item.
	# The live driver already stamps the frame: the placement
	# callback (SourceWorldTerrainRuntimeState.gd:116)
	# calls SourceDrillConsumptionRuntimeState.
	# source_on_proximity_update_state for every placed
	# build, and that driver stamps frame["dominant_item"]
	# / frame["dominant_items"] under the shared meta key
	# "source_drill_building" -- the same key as
	# SOURCE_BURST_DRILL_BUILDING_META_KEY -- so the
	# burst-drill frame IS the drill frame. The driver
	# gate is the catalog key, not the value: it returns
	# {"applied": false} only when block.properties
	# lacks "blockedItems", and the catalog carries that
	# key (null-valued) for BOTH defs, so applied is true
	# for both. Proximity update runs at placement, not
	# per tick, so there is NO driver tick line here. The
	# pickedUp reset (`public void pickedUp(){` /
	# `dominantItem = null;`, Drill.java:264-266) is
	# inherited too but waits for its own slice.
	var selected: Dictionary = source_drill_runtime_state.source_on_proximity_update_state(linked_tiles, tier, blocked_items)
	return {"dominant_item": selected["dominant_item"], "dominant_items": selected["dominant_items"]}

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
		# so a burst drill does not take the early return. The
		# liquid rows fold since N2296 when the frame carries
		# liquid observations (the required row into the first
		# pass, the booster row into the optional pass); without
		# observations the fold stays power-only. A burst drill
		# with no power consumer is untouched: the tick models no
		# other consumers yet, and BurstDrillBuild overrides
		# shouldConsume (BurstDrill.java:129, `return
		# items.total() <= itemCapacity - dominantItems &&
		# enabled;`) -- N2295 wires the gate through
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
			var optional_results: Array = []
			# The liquid rows fold here when the frame carries
			# liquid observations (N2296): the block's bound
			# liquid consumers come from the generic N2003
			# binding (SourceConsumeLiquidState.
			# source_bind_liquid_consumers_state, resolved from
			# the block's consumeLiquid defs -- impact water +
			# ozone booster, eruption hydrogen + cyanogen
			# booster, Blocks.java:3089-3090/3119-3120), the
			# booster flag splits the required row from the
			# booster row, and the pure rows function supplies
			# the row dicts the machinery folds (BuildingComp.
			# java:1969-1986). A frame with no stored-amount
			# keys keeps the power-only fold (the BuildTurret
			# precedent): the liquids-module slice has not
			# stamped required_liquid_stored /
			# booster_liquid_stored yet, and defaulting absent
			# to 0 would zero efficiency for every live burst
			# drill. The removal application stays out: the
			# machinery's update_consumers list takes actors
			# with an update() method, and the liquids.remove
			# application waits for the driver slice that owns
			# the liquids module.
			if frame.has("required_liquid_stored") and frame.has("booster_liquid_stored") and block.properties.has("consumeLiquid"):
				var liquid_bound: Dictionary = source_consume_liquid_state.source_bind_liquid_consumers_state(block, catalog)
				var required_amount := -1.0
				var booster_amount := -1.0
				for row in liquid_bound.get("consumers", []):
					if bool(row.get("booster", false)):
						booster_amount = float(row.get("amount", 0.0))
					else:
						required_amount = float(row.get("amount", 0.0))
				if required_amount >= 0.0 and booster_amount >= 0.0:
					var liquid_rows: Dictionary = source_burst_drill_liquid_rows_state(frame, seconds, required_amount, booster_amount)
					required_results.append(liquid_rows.get("required_row", {}))
					optional_results.append(liquid_rows.get("optional_row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, optional_results, [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}

static func source_drill_write_state(frame: Dictionary) -> Dictionary:
	# DrillBuild persists exactly TWO fields, its drill progress and its warmup
	# (Drill.java:384-387):
	# public void write(Writes write){
	# super.write(write);
	# write.f(progress);
	# write.f(warmup);
	# The fields are the DrillBuild float fields (`public float progress;` /
	# `public float warmup;`, Drill.java:238-239), already tracked frame keys
	# advanced by updateTile (N2294); the write function reads both values from
	# the frame (the N2217 RepairTurret precedent). super.write(write) is an
	# empty BuildingComp body (BuildingComp.java:297-299, `//overriden by
	# subclasses!`) -- only the marker is recorded. There is NO driver tick
	# line: persistence is not a per-tick call, and the port has no save/load
	# stream to call this function yet.
	return {"progress": float(frame.get("progress", 0.0)), "warmup": float(frame.get("warmup", 0.0))}

static func source_drill_read_state(frame: Dictionary, stored_progress: float, stored_warmup: float, revision: int) -> Dictionary:
	# DrillBuild restores the two persisted fields only for saves written at
	# revision >= 1 (Drill.java:389-394):
	# public void read(Reads read, byte revision){
	# super.read(read, revision);
	# if(revision >= 1){
	# progress = read.f();
	# warmup = read.f();
	# because the save version is 1 (`public byte version(){` with `return 1;`,
	# Drill.java:380-382; the BuildingComp base returns 0,
	# BuildingComp.java:669-671). A revision-0 save leaves the fields where they
	# already are -- the frame's current values (progress default 0.0, warmup
	# default 0.0, the Java field defaults). super.read(read, revision) is an
	# empty BuildingComp body (BuildingComp.java:302-305) -- only the marker is
	# recorded. DrillBuild has NO readSync override, so there is no readSync
	# follow-up slice (contrast N2322 Turret). There is NO driver tick line:
	# persistence is not a per-tick call.
	var progress: float = float(frame.get("progress", 0.0))
	var warmup: float = float(frame.get("warmup", 0.0))
	if revision >= 1:
		progress = stored_progress
		warmup = stored_warmup
	return {"progress": progress, "warmup": warmup}

@warning_ignore("unused_parameter")
static func source_drill_version_state(frame: Dictionary) -> Dictionary:
	# DrillBuild.version() (Drill.java:380-382):
	# public byte version(){
	# return 1;
	# The save version is 1, so read() applies the persisted progress/warmup for
	# revision >= 1; the BuildingComp base version() returns 0
	# (BuildingComp.java:669-671). The frame is accepted for the family call
	# shape and read for nothing: the version is a class constant, not live
	# state. There is NO driver tick line: the version is a load-time constant,
	# not a per-tick write.
	return {"version": 1}
