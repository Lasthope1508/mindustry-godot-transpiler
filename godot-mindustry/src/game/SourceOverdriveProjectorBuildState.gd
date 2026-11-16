extends RefCounted
class_name SourceOverdriveProjectorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_projector_boost_state := preload("res://src/game/SourceProjectorBoostState.gd")
const source_overdrive_projector_state := preload("res://src/game/SourceOverdriveProjectorState.gd")
const source_drill_inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

# The OverdriveProjector implementation (OverdriveProjector.java:21, `public class
# OverdriveProjector extends Block{`): overdrive-projector (consumePower 3.50f,
# size 2, range 80f, speedBoost 1.5f, speedBoostPhase 0.75f, useTime 400f,
# phaseRangeBoost 20f, hasBoost=true, phaseFabric booster) and overdrive-dome
# (consumePower 10f, size 3, range 200f, speedBoost 2.5f, useTime 300f,
# hasBoost=false, phaseFabric + silicon booster). Both
# havePower=true (OverdriveProjector.java:38, `hasPower = true;`)
# and hasItems=true. OverdriveProjector extends Block, NOT a drill
# or factory, so it cannot reuse an existing frame key; this
# driver uses its own family frame key
# ("source_overdrive_projector_building", the mechanical-pump /
# beam-drill / mend-projector precedent), and this slice adds the
# overdrive-projector key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it. The port already has OverdriveProjector display/runtime
# state (SourceOverdriveProjectorRuntimeState.gd: `runtime_step_state`
# lerps smooth_efficiency and heat toward 1.0, and `real_boost(
# overdrive_projector, phase_heat, efficiency)` multiplies by
# efficiency with default 1.0 -- the boost fold already consumes
# efficiency) -- the missing piece is the live power.status ->
# efficiency driver, which is exactly this slice. N2194 adds the
# OverdriveBuild.updateTile() advance on top of that driver
# (OverdriveProjector.java:97-120): the frame now tracks
# smoothEfficiency / heat / charge / phaseHeat / useProgress,
# advanced every tick from the folded efficiency, with the
# charge reset at reload; the boost scan
# (OverdriveProjector.java:106-111) is live since N2334 --
# the tick reports the in-range overdrivable targets into
# frame["last_boost_scan"] when the advance reports
# charge_ready -- and only the boost application
# (applyBoost on the reported targets,
# OverdriveProjector.java:110) is deferred to its own
# slice, and consume() (OverdriveProjector.java:118) is
# wired by N2262: when the advance reports use_ready, the
# tick removes the per-def item stacks (projector 1
# phaseFabric; dome 1 phaseFabric + 1 silicon).
const SOURCE_OVERDRIVE_PROJECTOR_BUILD_IMPLEMENTATIONS := ["OverdriveProjector"]
const SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY := "source_overdrive_projector_building"

static func _is_overdrive_projector_build_implementation(implementation: String) -> bool:
	return SOURCE_OVERDRIVE_PROJECTOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_overdrive_projector_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The overdrive-projector tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (OverdriveProjector.java:21, `public class OverdriveProjector extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# overdrive projector skips consumption like Java's updateConsumption
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
	# for this overdrive projector (N2125); the tick preserves a disabled
	# overdrive projector instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# Build fields (OverdriveProjector.java:84):
	# public float heat, charge = Mathf.random(reload), phaseHeat, smoothEfficiency, useProgress;
	# Java floats default to 0; charge is the exception, a
	# uniform random in [0, reload). The port binds charge
	# deterministically to 0.0 -- the runtime-state default
	# precedent (SourceOverdriveProjectorRuntimeState.
	# capture_state / runtime_step_state default charge 0.0,
	# same for MendProjector) -- so proofs start from a known
	# state and the first charge cycle runs the full reload.
	# The frame also carries the held items (N2262): the
	# item rows read frame["items"] (Dictionary keyed by
	# item name, the factory precedent), starting empty --
	# no live intake fills it yet (the Separator precedent).
	return {"smooth_efficiency": 0.0, "heat": 0.0, "charge": 0.0, "phase_heat": 0.0, "use_progress": 0.0, "items": {}}

static func source_overdrive_projector_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, has_boost: bool, reload_value: float, use_time_value: float) -> Dictionary:
	# OverdriveBuild.updateTile() (OverdriveProjector.java:97-120), the internal advance,
	# in exact Java order. The lerp is Arc's lerpDelta (Mathf.java:430-432):
	# return lerp(fromValue, toValue, clamp(progress * Time.delta));
	# with lerp `fromValue + (toValue - fromValue) * progress` (Mathf.java:425-427),
	# via the canonical source_lerp_delta; source_delta is Time.delta in ticks
	# (seconds * 60, game_source_delta -- never raw seconds, the N2186/N2187/N2191
	# lesson: raw seconds run 60x slow). The frame carries the folded efficiency
	# (the N2157 power row) and optionalEfficiency, already folded by the shared
	# machinery (BuildingComp.java:1965 `efficiency = optionalEfficiency = 1f;`, then
	# the optional pass BuildingComp.java:1981 and the min fold BuildingComp.java:1986
	# `optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);`); the
	# projector's optional phaseFabric row is modeled since N2262 (the dome has
	# no optional consumer, so its optionalEfficiency equals the min efficiency),
	# so a missing optional_efficiency stamp defaults to the frame efficiency, and
	# a missing efficiency stamp folds to 1.0 before the first consumption pass,
	# the assembler fold (UnitAssembler.java:469).
	# smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);
	# heat = Mathf.lerpDelta(heat, efficiency > 0 ? 1f : 0f, 0.08f);
	# charge += heat * Time.delta;
	# phaseHeat = Mathf.lerpDelta(phaseHeat, optionalEfficiency, 0.1f);
	# charge = 0f;
	# useProgress += delta();
	# useProgress %= useTime;
	# return (speedBoost + phaseHeat * speedBoostPhase) * efficiency;
	# Charge advances on raw Time.delta -- NOT delta() (BuildingComp.java:1922-1924):
	# return Time.delta * timeScale;
	# -- unlike MendProjector (`charge += heat * delta();`); only useProgress uses
	# delta(), so timeScale scales the use timer but never the charge. phaseHeat
	# lerps only when hasBoost (OverdriveProjector.java:102 `if(hasBoost){`); the
	# overdrive-dome sets hasBoost = false (Blocks.java:1960), so its phaseHeat
	# stays 0. The charge reset sits inside `if(charge >= reload){` BEFORE the
	# indexer scan (OverdriveProjector.java:106-111), so the reset does not depend
	# on finding a target -- this slice resets, and only the boost application is
	# deferred (OverdriveProjector.java:110):
	# indexer.eachBlock(this, realRange, other -> other.block.canOverdrive, other -> other.applyBoost(realBoost(), reload + 1f));
	# The useProgress wrap is unconditional arithmetic in the `if(useProgress >= useTime){`
	# branch: consume() returns void, so nothing gates the wrap on consume's outcome --
	# the wrap fires whenever the timer crosses useTime, and the runtime-step
	# precedent wraps too (SourceOverdriveProjectorRuntimeState.runtime_step_state
	# fmods use_progress at use_time); the consume() item side effect
	# (OverdriveProjector.java:118) is wired by the tick since N2262: when this
	# advance reports use_ready, the tick removes the per-def stacks through
	# the shared inventory helper, clamped to the held count.
	# realBoost() is NOT computed here: it is a pure computation over phaseHeat and
	# efficiency already covered by SourceOverdriveProjectorRuntimeState.real_boost
	# and the N2157 real-boost fold, and its only updateTile consumer is the
	# deferred boost application. hasBoost / reload / useTime are per-def catalog
	# values (overdrive-projector: hasBoost true, reload 60f, useTime 400f;
	# overdrive-dome: hasBoost false, reload 60f, useTime 300f, Blocks.java:1958),
	# passed in by the driver through SourceOverdriveProjectorState's accessors.
	var efficiency: float = float(frame.get("efficiency", 1.0))
	var optional_efficiency: float = float(frame.get("optional_efficiency", efficiency))
	var smooth_efficiency: float = source_math_state.source_lerp_delta(float(frame.get("smooth_efficiency", 0.0)), efficiency, source_projector_boost_state.SOURCE_PROJECTOR_HEAT_LERP_PROGRESS, source_delta)
	var heat: float = source_math_state.source_lerp_delta(float(frame.get("heat", 0.0)), 1.0 if efficiency > 0.0 else 0.0, source_projector_boost_state.SOURCE_PROJECTOR_HEAT_LERP_PROGRESS, source_delta)
	var charge: float = float(frame.get("charge", 0.0)) + heat * source_delta
	var phase_heat: float = float(frame.get("phase_heat", 0.0))
	if has_boost:
		phase_heat = source_math_state.source_lerp_delta(phase_heat, optional_efficiency, source_projector_boost_state.SOURCE_PROJECTOR_PHASE_HEAT_LERP_PROGRESS, source_delta)
	var charge_ready: bool = charge >= reload_value
	if charge_ready:
		charge = 0.0
	var use_progress: float = float(frame.get("use_progress", 0.0))
	if efficiency > 0.0:
		use_progress += source_delta * time_scale
	var use_ready: bool = use_progress >= use_time_value
	if use_ready:
		use_progress = fmod(use_progress, use_time_value) if use_time_value > 0.0 else 0.0
	return {"advanced": {"smooth_efficiency": smooth_efficiency, "heat": heat, "charge": charge, "phase_heat": phase_heat, "use_progress": use_progress}, "charge_ready": charge_ready, "use_ready": use_ready}

static func source_overdrive_projector_supplied_boost_targets_state(candidates: Array, real_range: float, building_x: float, building_y: float) -> Dictionary:
	# The boost scan range query (OverdriveProjector.java:106-111),
	# the pure eachBlock rect filter + canOverdrive predicate -- the
	# N2194 advance already ran on this frame (smoothEfficiency /
	# heat / charge / phaseHeat, including the charge reset), so the
	# scan reads the POST-advance phase_heat through the caller's
	# real_range and runs when the advance reports charge_ready
	# (each exact expr on ONE comment line, the N2148 lesson):
	# `if(charge >= reload){`
	# `float realRange = range + phaseHeat * phaseRangeBoost;`
	# `indexer.eachBlock(this, realRange, other -> other.block.canOverdrive, other -> other.applyBoost(realBoost(), reload + 1f));`
	# `public boolean eachBlock(Teamc team, float range, Boolf<Building> pred, Cons<Building> cons){`
	# `return eachBlock(team.team(), team.getX(), team.getY(), range, pred, cons);`
	# `public boolean eachBlock(@Nullable Team team, float wx, float wy, float range, Boolf<Building> pred, Cons<Building> cons){`
	# `buildings.intersect(wx - range, wy - range, range*2f, range*2f, b -> {`
	# `if(b.within(wx, wy, range + b.hitSize() / 2f) && pred.get(b) && !b.block.privileged){`
	# `return Mathf.dst2(getX(), getY(), x, y) < dst*dst;`
	# `public boolean canOverdrive = true;`
	# `public float range = 80f;`
	# `public float phaseRangeBoost = 20f;`
	# `range = 200f;`
	# `hasBoost = false;`
	# `return (speedBoost + phaseHeat * speedBoostPhase) * efficiency;`
	# The rect is in WORLD units directly -- the quadtree
	# intersect takes (wx - range, wy - range, range*2f,
	# range*2f), no tilesize factor (BlockIndexer.java:345)
	# -- so the half-side is realRange itself and the test is
	# |dx| <= realRange and |dy| <= realRange, INCLUSIVE on
	# the edge (the N2277 center-in-rect precedent: a corner
	# candidate at (realRange, realRange) is IN the rect and
	# out of any circle). The per-def range / phaseRangeBoost
	# ride the caller's real_range (overdrive-projector 80f /
	# 20f, OverdriveProjector.java:24/28; overdrive-dome range
	# 200f, Blocks.java:1956, phaseRangeBoost NOT overridden
	# so the class 20f applies -- and the dome's hasBoost =
	# false, Blocks.java:1960, keeps its phaseHeat at 0, so
	# its realRange is always the base 200f). Documented
	# deviation, source-backed: the rect is only Java's BROAD
	# phase -- the float-range overload then admits only
	# `b.within(wx, wy, range + b.hitSize() / 2f)` (a STRICT
	# dst2 < (range + hitSize/2)^2 circle, Position.java:44-46)
	# with the predicate and `!b.block.privileged`
	# (BlockIndexer.java:346) -- so the port admits rect
	# corners Java rejects (for a small hitSize) and misses
	# large-hitbox buildings whose center sits outside the
	# rect but within range + hitSize/2; the narrow-check
	# refinement waits for its own slice (DEFERRED, the N2329
	# precedent). Scoping decisions, all source-backed: (1)
	# the pure filters RANGE + the canOverdrive predicate --
	# the Java pred half (`other.block.canOverdrive`,
	# OverdriveProjector.java:110); a candidate dict carries
	# x / y (world position, the building center) plus
	# can_overdrive, and a MISSING can_overdrive reads TRUE
	# -- the Java field default (`public boolean canOverdrive
	# = true;`, Block.java:309); only defs that opt out
	# (Blocks.java:2392/6591/6596/6602/6612/6951) read false.
	# (2) A missing x or y key EXCLUDES the candidate, and a
	# non-Dictionary entry is excluded the same way. (3) The
	# admitted entries are the candidate dicts themselves, in
	# candidate order, like Java's Seq<Building>; the pure
	# only filters, it never rewrites an entry. (4) The team
	# filter is the caller's: Java visits the projector team's
	# buildingTree only (BlockIndexer.java:343), so the caller
	# supplies same-team candidates. APPLICATION DEFERRED, not
	# done and not guessed: the pure only REPORTS the targets
	# -- applyBoost(realBoost(), reload + 1f) on another
	# building (OverdriveProjector.java:110; realBoost() is
	# `return (speedBoost + phaseHeat * speedBoostPhase) *
	# efficiency;`, OverdriveProjector.java:124, already
	# covered by SourceOverdriveProjectorRuntimeState.
	# real_boost) waits for its own slice (DEFERRED, the
	# N2325 heal_applications precedent). The live building
	# index that would supply frame["boost_candidates"] still
	# waits (DEFERRED).
	var boost_targets: Array = []
	for candidate in candidates:
		if not (candidate is Dictionary):
			continue
		if not candidate.has("x") or not candidate.has("y"):
			continue
		if not bool(candidate.get("can_overdrive", true)):
			continue
		var dx: float = absf(float(candidate.get("x", 0.0)) - building_x)
		var dy: float = absf(float(candidate.get("y", 0.0)) - building_y)
		if dx > real_range or dy > real_range:
			continue
		boost_targets.append(candidate)
	return {"boost_targets": boost_targets, "real_range": real_range}

static func source_overdrive_projector_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the overdrive-projector frame meta key
	# ("source_overdrive_projector_building"). An OverdriveProjector sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_overdrive_projector_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_overdrive_projector_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
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
	# so an overdrive projector does not take the early return. The
	# real boost follows the folded efficiency
	# (OverdriveProjector.java:124, `return (speedBoost + phaseHeat * speedBoostPhase) * efficiency;`), with the smooth-efficiency gate
	# (OverdriveProjector.java:98, `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);`) and the heat gate
	# (OverdriveProjector.java:99, `heat = Mathf.lerpDelta(heat, efficiency > 0 ? 1f : 0f, 0.08f);`) and the charge advance
	# (OverdriveProjector.java:100, `charge += heat * Time.delta;`).
	# Documented limits: (1) power + item rows -- item rows live (N2262):
	# the overdrive-projector phaseFabric booster row
	# (consumeItem(Items.phaseFabric).boost(), Blocks.java:1948) folds
	# the optional pass and the overdrive-dome phaseFabric+silicon row
	# (consumeItems(with(Items.phaseFabric, 1, Items.silicon, 1)),
	# Blocks.java:1961, REQUIRED) folds the first pass, so the folded
	# efficiency is the min over the *modeled* consumers (power + items). No live intake fills
	# frame["items"] yet (the Separator precedent) -- a live
	# projector with no intake folds the booster row 0 and a
	# live dome folds efficiency 0 until an intake slice
	# lands; the other unmodeled rows still defer. (2) No shouldConsume gate --
	# OverdriveBuild has no shouldConsume override, so the default
	# (BuildingComp.java:755-757, `return enabled;`) applies;
	# the machinery runs with should_consume=true when
	# enabled. (3) updateTile advance DONE (N2194) -- smoothEfficiency /
	# heat / charge / phaseHeat / useProgress advance every tick
	# (OverdriveProjector.java:97-120) and charge resets at reload;
	# the boost scan is live since N2334 -- the realRange fold
	# (OverdriveProjector.java:107) and the eachBlock rect filter
	# + canOverdrive predicate (OverdriveProjector.java:110)
	# report the in-range overdrivable targets into
	# frame["last_boost_scan"] when the advance reports
	# charge_ready -- and only the boost application (applyBoost
	# on the reported targets, OverdriveProjector.java:110)
	# still waits for its own slice, as does the live building
	# index that would fill frame["boost_candidates"]. (4)
	# useProgress consume() rows -- useTime 400f /
	# dome 300f (OverdriveProjector.java:117-120): useProgress
	# advances and wraps at useTime since N2194, and the
	# consume() removal wired (N2262): when the advance
	# reports use_ready the tick removes the per-def stacks
	# (projector 1 phaseFabric; dome 1 phaseFabric + 1
	# silicon), clamped to the held count; the dome's
	# hasBoost=false (Blocks.java:1960) means its phaseHeat
	# stays 0, which the advance models. (5) Draw rows live (N2435)
	# -- the draw pure (source_overdrive_projector_draw_rows_state) models
	# draw() (:137-158: the super call + the Lod.l2 gate +
	# the top region at heat * absin(Time.time, 50f / PI2,
	# 1f) * 0.5f * Lod.alpha2 + the 4-point ring at stroke
	# (2f * f + 0.1f) * heat), drawLight() (:92-94, the
	# smoothEfficiency-scaled light), drawSelect() (:128-133,
	# the realRange dash circle + the selected targets) and
	# drawPlace() (:54-61, the range dash circle + the
	# selected targets at the tile position). Pure-only: the
	# tick never calls draw / drawLight / drawSelect /
	# drawPlace -- draw is called by the renderer,
	# drawSelect / drawPlace by the UI, and the call sites
	# wait for renderer/UI slices. The pure is named
	# draw_rows_state (not draw_state): the older display
	# path already owns the
	# source_overdrive_projector_draw_state schemas
	# (PortGame.source_overdrive_projector_draw_state, N726)
	# and reusing the name would overwrite those schemas --
	# the N2372 MendProjector precedent. OverdriveProjector
	# has NO icons() override, so there is no icon_regions
	# key (the N2429 ItemBridge precedent).
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_overdrive_projector_item_consumer_row_state(frame: Dictionary, stacks: Array) -> Dictionary:
	# ConsumeItems.efficiency (ConsumeItems.java:51-53,
	# `return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;`):
	# BINARY 1/0 -- NOT a ratio like ConsumeLiquid. consumeTriggerValid()
	# base returns false (BuildingComp.java:764-766,
	# `public boolean consumeTriggerValid(){` / `return false;` / `}`),
	# and no OverdriveProjector build overrides it, so the row is 1
	# exactly when the held items satisfy EVERY stack: has(stacks,
	# multiplier) (ItemModule.java:153-156) requires
	# `has(stack.item, Math.round(stack.amount * multiplier))` per stack,
	# with has(item, amount) = get(item) >= amount
	# (ItemModule.java:126-128, `return get(item) >= amount;`). The
	# multiplier is the 1f default (Consume.java:18,
	# `public Floatf<Building> multiplier = b -> 1f;`) -- neither def sets
	# one (Blocks.java:1948/1961) -- so the demand is the stack amount
	# itself. The counts read through the shared inventory helper
	# (SourceDrillInventoryRuntimeState.item_count) over frame["items"]
	# (Dictionary keyed by item name, the factory precedent
	# SourceFactoryBuildState.gd:89-101); a frame without the key reads
	# 0, like Java items.get on an item never added.
	# Per-def stacks come from the catalog consumeItem property:
	# overdrive-projector `[{"item": "phase-fabric", "amount": 1,
	# "optional": true, "booster": true}]` (Blocks.java:1948,
	# `consumeItem(Items.phaseFabric).boost();`, `consumeItem(item)` =
	# ItemStack(item, 1) via `return consumeItem(item, 1);`,
	# Block.java:1167-1168) -- booster = optional(true, true)
	# (Consume.java:33-35, `return optional(true, true);`) so the row
	# folds the optional pass
	# (BuildingComp.java:1980-1981, `for(var cons : block.optionalConsumers){` /
	# `optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));`),
	# capped by the min efficiency (BuildingComp.java:1986,
	# `optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);`);
	# overdrive-dome `[{"item": "phase-fabric", "amount": 1},
	# {"item": "silicon", "amount": 1}]` (Blocks.java:1961,
	# `consumeItems(with(Items.phaseFabric, 1, Items.silicon, 1));`, NO
	# .boost()) -- REQUIRED, so the row folds the first pass
	# (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` /
	# `minEfficiency = Math.min(minEfficiency, result);`), result 0 stops
	# power (BuildingComp.java:1972-1973, `shouldConsumePower = false;`),
	# and the dome needs BOTH stacks (1 only when phaseFabric AND silicon
	# are held). A def with no item consumer contributes no row.
	# Documented limits: no live intake fills frame["items"] yet (the
	# Separator precedent) -- acceptItem / conveyor delivery / dump into
	# the building waits for its own slice; the row reads the frame
	# as-is, so a live projector with no intake folds the booster row 0
	# and a live dome folds efficiency 0.
	if stacks.is_empty():
		return {"has_item_row": false, "row": {}, "is_optional": false}
	var items: Dictionary = frame.get("items", {})
	var is_optional: bool = bool(stacks[0].get("optional", false)) if stacks[0] is Dictionary else false
	var result: float = 1.0
	for stack in stacks:
		if not (stack is Dictionary):
			continue
		var amount: int = int(stack.get("amount", 0))
		if source_drill_inventory.item_count(items, str(stack.get("item", ""))) < amount:
			result = 0.0
			break
	return {"has_item_row": true, "row": {"result": result, "is_power": false}, "is_optional": is_optional}

static func source_overdrive_projector_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the overdrive-projector tick wiring every
	# tick (OverdriveBuild.updateTile(), OverdriveProjector.java:97,
	# gates on the smooth-efficiency gate (OverdriveProjector.java:98,
	# `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);`) and folds the
	# real boost (OverdriveProjector.java:124,
	# `return (speedBoost + phaseHeat * speedBoostPhase) * efficiency;`), so the
	# real-boost fold follows the folded efficiency; no
	# placed-buildings driver ticks OverdriveProjector blocks, so this
	# driver is the placed-overdrive-projector tick): each placed
	# OverdriveProjector build gets its frame keys refreshed from the
	# live rules, so the frame's cheating flag tracks
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
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if not _is_overdrive_projector_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_overdrive_projector_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_overdrive_projector_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# an overdrive projector with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the real-boost fold (OverdriveProjector.java:124)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449,
		# `hasConsumers = consumers.length > 0;`), so an overdrive
		# projector does not take the early return. An overdrive projector with
		# no power consumer is untouched: the tick folds the power row and,
		# since N2262, the per-def item rows (the projector's phaseFabric
		# booster row into the optional pass, the dome's
		# phaseFabric+silicon required row into the first pass), and there
		# is no shouldConsume gate yet
		# (OverdriveBuild has no shouldConsume override; the default
		# BuildingComp.java:755-757 `return enabled;` applies),
		# so the machinery runs with should_consume=true when enabled.
		# productionValid is the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		# N2262: the per-def item stacks come from the catalog
		# consumeItem property (overdrive-projector: 1
		# phaseFabric, optional booster; overdrive-dome: 1
		# phaseFabric + 1 silicon, required) -- read once here
		# so the fold below and the consume() removal after the
		# advance share the same stacks.
		var item_stacks: Array = block.properties.get("consumeItem", [])
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_overdrive_projector_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			# N2262: the item row folds per def -- the
			# projector's booster row joins the optional pass,
			# the dome's required row joins the first pass (the
			# fold handles the min + shouldConsumePower).
			var optional_results: Array = []
			var item_row: Dictionary = source_overdrive_projector_item_consumer_row_state(frame, item_stacks)
			if bool(item_row.get("has_item_row", false)):
				if bool(item_row.get("is_optional", false)):
					optional_results.append(item_row.get("row", {}))
				else:
					required_results.append(item_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, optional_results, [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2194: the updateTile advance runs every tick for every
		# placed OverdriveProjector build (Java updateTile runs
		# every tick for update=true blocks -- the gate
		# `if(enabled || !block.noUpdateDisabled){`
		# (BuildingComp.java:2277-2279) always passes because
		# noUpdateDisabled defaults false, Block.java:170), AFTER
		# the consumption fold, so it reads the freshly folded
		# efficiency and optionalEfficiency. Known deviation
		# (the driver-wide disabled gap, deferred in the N2194
		# register): when disabled, the driver skips the
		# consumption fold, so the frame efficiency goes stale
		# and this advance keeps charging from it -- in Java a
		# disabled projector's efficiency is zeroed
		# (BuildingComp.java:1954-1957), so heat decays toward
		# 0 and useProgress stops. source_delta is
		# Time.delta in ticks (seconds * 60 via game_source_delta,
		# never raw seconds); the timeScale for delta() is read
		# live from the sprite meta (the N2189 precedent), and
		# hasBoost / reload / useTime are the per-def catalog
		# values through SourceOverdriveProjectorState's
		# accessors (overdrive-projector: hasBoost true, reload
		# 60f, useTime 400f; overdrive-dome: hasBoost false,
		# reload 60f, useTime 300f). The advanced frame merges
		# back into the bound frame; charge_ready is the
		# boost-fire signal the scan below consumes (N2334),
		# and use_ready is the consume-fire signal the tick
		# below consumes (N2262).
		var advance: Dictionary = source_overdrive_projector_update_tile_advance_state(frame, source_placed_block_state.game_source_delta(game, seconds), source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game)), source_overdrive_projector_state.has_boost(block), source_overdrive_projector_state.projector_reload(block), source_overdrive_projector_state.use_time(block))
		frame.merge(advance.get("advanced", {}), true)
		# N2262: consume() (OverdriveProjector.java:117-120,
		# `if(useProgress >= useTime){` / `consume();` /
		# `useProgress %= useTime;`) -- the advance reports
		# use_ready when the timer crosses useTime (the wrap is
		# unconditional arithmetic, consume() returns void), and
		# the tick applies the item side effect here: consume()
		# triggers every consumer (BuildingComp.java:1911-1915,
		# `for(Consume cons : block.consumers){` /
		# `cons.trigger(self());`), but only ConsumeItems
		# overrides trigger (ConsumeItems.java:44-48,
		# `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));`;
		# ConsumePower and ConsumeLiquid keep the base no-op
		# `public void trigger(Building build){}`,
		# Consume.java:50), so consume() removes the per-def
		# stacks -- projector 1 phaseFabric, dome 1 phaseFabric
		# + 1 silicon -- clamped to the held count
		# (ItemModule.remove, ItemModule.java:258-263,
		# `amount = Math.min(amount, items[item.id]);`)
		# through the shared inventory helper (the Fracker
		# precedent). No removal when use_ready is false: the
		# timer has not crossed useTime yet. The advance only
		# grows useProgress when efficiency > 0, so a starved
		# dome (required row 0 -> efficiency 0) never reaches
		# use_ready and never consumes.
		if bool(advance.get("use_ready", false)):
			var items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
			for stack in item_stacks:
				if not (stack is Dictionary):
					continue
				var removed: Dictionary = source_drill_inventory.remove_item_state(items, str(stack.get("item", "")), int(stack.get("amount", 0)))
				items = removed.get(source_drill_inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, items)
			frame["items"] = items
		# N2334: the boost scan runs AFTER the advance (realRange
		# needs the post-advance phase_heat), in Java order
		# (OverdriveProjector.java:106-111): when the advance
		# reports charge_ready, the tick folds the live realRange
		# from the post-advance frame phase_heat + the block props
		# through the existing projector_range accessor (the SAME
		# formula the drawSelect fold uses, OverdriveProjector.
		# java:129 -- range + phaseHeat * phaseRangeBoost, the
		# N2329 realRange precedent -- no duplicate math) and
		# filters the frame boost candidates (frame[
		# "boost_candidates"], default [] -- no candidates, the
		# Java no-buildings-in-range outcome) from the live
		# building position (origin cell + block offset, the
		# N2306 RepairTower precedent: Building x/y are
		# tile.drawx()/drawy(), BuildingComp.java:124). The scan
		# reports its targets into the frame as last_boost_scan;
		# the boost APPLICATION (applyBoost on the reported
		# targets, OverdriveProjector.java:110) still waits for
		# its own slice (DEFERRED), and the live building index
		# that would fill frame["boost_candidates"] still waits
		# too. When charge is not ready, Java runs no scan at
		# all (the `if(charge >= reload){` gate), so the tick
		# reports an empty target list at the live realRange.
		var scan_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		var scan_block_size: int = int(block.properties.get("size", 1))
		var scan_block_offset: float = float((scan_block_size + 1) % 2) * source_world_defaults.TILESIZE / 2.0
		var scan_building_x: float = source_block_geometry.tile_drawx_state(scan_cell.x, source_world_defaults.TILESIZE, scan_block_offset)
		var scan_building_y: float = source_block_geometry.tile_drawy_state(scan_cell.y, source_world_defaults.TILESIZE, scan_block_offset)
		var scan_real_range: float = source_overdrive_projector_state.projector_range(block, float(frame.get("phase_heat", 0.0)))
		var scan_candidates: Array = []
		var frame_boost_candidates: Variant = frame.get("boost_candidates", [])
		if frame_boost_candidates is Array:
			scan_candidates = frame_boost_candidates
		var boost_scan: Dictionary = {"boost_targets": [], "real_range": scan_real_range}
		if bool(advance.get("charge_ready", false)):
			boost_scan = source_overdrive_projector_supplied_boost_targets_state(scan_candidates, scan_real_range, scan_building_x, scan_building_y)
		frame["last_boost_scan"] = boost_scan
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}

static func source_overdrive_projector_draw_rows_state(x_value: float, y_value: float, tile_x: int, tile_y: int, range_value: float, phase_heat: float, phase_range_boost: float, light_radius: float, smooth_efficiency: float, heat: float, time_value: float, lod_l2: bool, lod_alpha2: float, size_value: float, base_color: String, phase_color: String, selected_blocks: Array, place_valid: bool) -> Dictionary:
	# The draw rows (OverdriveBuild.draw(), OverdriveProjector.java:137-158; OverdriveBuild.drawLight(), :92-94; OverdriveBuild.drawSelect(), :128-133; OverdriveProjector.drawPlace(), :54-61), the pure draw-call dict -- the port never draws for real (the N2421 RepairTurret precedent: the pure returns the draw calls as data). Java draws, in order (each exact expr on ONE comment line, the N2148 lesson):
	# `public void draw(){`
	# `super.draw();`
	# `if(!Lod.l2) return;`
	# `float f = 1f - (Time.time / 100f) % 1f;`
	# `Draw.color(baseColor, phaseColor, phaseHeat);`
	# `Draw.alpha(heat * Mathf.absin(Time.time, 50f / Mathf.PI2, 1f) * 0.5f * Lod.alpha2);`
	# `Draw.rect(topRegion, x, y);`
	# `Draw.alpha(Lod.alpha2);`
	# `Lines.stroke((2f * f + 0.1f) * heat);`
	# `float r = Math.max(0f, Mathf.clamp(2f - f * 2f) * size * tilesize / 2f - f - 0.2f), w = Mathf.clamp(0.5f - f) * size * tilesize;`
	# `Lines.beginLine();`
	# `for(int i = 0; i < 4; i++){`
	# `Lines.linePoint(x + Geometry.d4(i).x * r + Geometry.d4(i).y * w, y + Geometry.d4(i).y * r - Geometry.d4(i).x * w);`
	# `if(f < 0.5f) Lines.linePoint(x + Geometry.d4(i).x * r - Geometry.d4(i).y * w, y + Geometry.d4(i).y * r + Geometry.d4(i).x * w);`
	# `Lines.endLine(true);`
	# `Draw.reset();`
	# `public void drawLight(){`
	# `Drawf.light(x, y, lightRadius * smoothEfficiency, baseColor, 0.7f * smoothEfficiency);`
	# `public void drawSelect(){`
	# `float realRange = range + phaseHeat * phaseRangeBoost;`
	# `indexer.eachBlock(this, realRange, other -> other.block.canOverdrive, other -> Drawf.selected(other, Tmp.c1.set(baseColor).a(Mathf.absin(4f, 1f))));`
	# `Drawf.dashCircle(x, y, realRange, baseColor);`
	# `public void drawPlace(int x, int y, int rotation, boolean valid){`
	# `super.drawPlace(x, y, rotation, valid);`
	# `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, baseColor);`
	# `indexer.eachBlock(player.team(), x * tilesize + offset, y * tilesize + offset, range, other -> other.block.canOverdrive, other -> Drawf.selected(other, Tmp.c1.set(baseColor).a(Mathf.absin(4f, 1f))));`
	# The pure is named draw_rows_state (not draw_state): the older display path already owns the source_overdrive_projector_draw_state schemas (PortGame.source_overdrive_projector_draw_state, N726) and reusing the name would overwrite those schemas -- the N2372 MendProjector precedent. The f factor is computed AFTER the Lod guard (line order :140 before :142 -- the REVERSE of MendProjector, where f comes first), so the pure reports f 0.0 when hidden, with empty top/ring calls and zeroed draw scalars (the N726 display-state precedent: it returns f 0.0 when !lod_l2); the base call is still recorded because super.draw() runs BEFORE the guard (:138). topRegion is the `@-top` region (`public @Load("@-top") TextureRegion topRegion;`, OverdriveProjector.java:22). The absin calls are Java-exact through the shared helper at the DOUBLED scale: Java absin is `return (sin(in, scl * 2f, mag) + mag) / 2f;` (`public static float absin(float in, float scl, float mag){`, Mathf.java:78-80, arc), while the helper is (sin(value / scl) * 0.5 + 0.5) * mag (SourceMathState.source_absin), i.e. helper(v, s) == Java absin(v, s / 2f) -- so the pure passes 100f / PI2 for the draw absin and 8f for the select/place absin(4f, 1f), the 2-arg form that reads Time.time (`public static float absin(float scl, float mag){` / `return absin(Time.time, scl, mag);`, Mathf.java:74-75, arc) -- the N2372/N2382 precedent. The ring geometry uses Geometry.d4 (`public static Point2 d4(int i){`, Geometry.java:43; `public final static Point2[] d4 = {`, Geometry.java:9-14, (1,0) / (0,1) / (-1,0) / (0,-1)) with r and w from the clamp line, where clamp is the 1-arg [0,1] clamp (`public static float clamp(float value){`, Mathf.java:402, arc) -- GDScript clampf(v, 0.0, 1.0); the loop adds the extra point when f < 0.5f, so the ring has 4 points at f >= 0.5 and 8 at f < 0.5, closed by Lines.endLine(true). The drawPlace tile position uses the Block offset (`offset = ((size + 1) % 2) * tilesize / 2f;`, Block.java:761) -- 4 for the size-2 projector, 0 for the size-3 dome -- computed from size_value so the pure stays def-agnostic. The drawLight call is the Drawf.light overload (`public static void light(float x, float y, float radius, Color color, float opacity){`, Drawf.java:301-304) with radius lightRadius * smoothEfficiency and opacity 0.7f * smoothEfficiency; drawLight has NO Lod gate and no emitLight check in the method itself (emitLight gates the renderer call site, not the method). The selected call is Drawf.selected (`public static void selected(Building tile, Color color){`, Drawf.java:330-332) with the baseColor at the absin alpha; the dash circle is Drawf.dashCircle (`public static void dashCircle(float x, float y, float rad, Color color){`, Drawf.java:398-404) -- the double stroke (`Lines.stroke(3f, Pal.gray);` + `Lines.stroke(1f, color);`) is the callee's body, recorded as one call (the N2396 callee-geometry precedent). The eachBlock visit has no live building index behind it (the boost-scan live-index DEFERRED entry -- same index), so the caller supplies the selected blocks explicit (the N2242 heal-scan precedent); ONE array serves both drawSelect and drawPlace (the N2372 MendProjector precedent: the two queries differ only in center/range, which the caller evaluated) -- the pure renders one selected call per supplied candidate and does NOT range-filter (the range half is the index's visit, not the draw). A candidate dict carries x / y (world position); a missing x or y key EXCLUDES the candidate (the N2329 precedent), and a non-Dictionary entry is excluded the same way. The def constants are verified first: `public float range = 80f;` (OverdriveProjector.java:24) with the dome override `range = 200f;` (Blocks.java:1956, `overdriveDome = new OverdriveProjector("overdrive-dome"){{`); `public float phaseRangeBoost = 20f;` (:28, no def override); `lightRadius = 50f;` (:42, no def override) next to `emitLight = true;` (:41); `public Color baseColor = Color.valueOf("feb380");` (:30) and `public Color phaseColor = Color.valueOf("ffd59e");` (:31, no def overrides); the projector def is `overdriveProjector = new OverdriveProjector("overdrive-projector"){{` (Blocks.java:1944) with size 2, the dome with size 3 and `hasBoost = false;` (Blocks.java:1960). Lod is the zoom-detail gate (`public static boolean l2 = true;` / `public static float alpha2 = 1f;`, Lod.java:16-17, fading with camera zoom, Lod.java:22-31): the port has no live camera zoom at the driver layer, so lod_l2 / lod_alpha2 are explicit params (the N2372 precedent). The colors ride as symbolic tokens (the N2415 / ShockwaveTower precedent -- the port never draws for real). OverdriveProjector has NO icons() override (no "icon" line in OverdriveProjector.java at all), so there is no icon_regions key -- the base Block.icons() default applies (the N2429 ItemBridge precedent). Time.time is caller-supplied as time_value (the N2396/N2372 convention -- draw never runs in the tick, so the tick never stamps it). Pure-only: the tick never calls draw / drawLight / drawSelect / drawPlace -- draw is called by the renderer, drawSelect / drawPlace by the UI, and the call sites wait for renderer/UI slices.
	var base_call: Dictionary = {
		"call": "super.draw();",
		"x": x_value,
		"y": y_value,
	}
	var f: float = 0.0
	var top_absin: float = 0.0
	var top_alpha: float = 0.0
	var stroke: float = 0.0
	var ring_r: float = 0.0
	var ring_w: float = 0.0
	var ring_points: Array = []
	var top_call: Dictionary = {}
	var ring_call: Dictionary = {}
	if lod_l2:
		f = 1.0 - fmod(time_value / 100.0, 1.0)
		top_absin = source_math_state.source_absin(time_value, 100.0 / source_math_state.SOURCE_PI2, 1.0)
		top_alpha = heat * top_absin * 0.5 * lod_alpha2
		stroke = (2.0 * f + 0.1) * heat
		ring_r = max(0.0, clampf(2.0 - f * 2.0, 0.0, 1.0) * size_value * source_world_defaults.TILESIZE / 2.0 - f - 0.2)
		ring_w = clampf(0.5 - f, 0.0, 1.0) * size_value * source_world_defaults.TILESIZE
		var d4x: Array = [1.0, 0.0, -1.0, 0.0]
		var d4y: Array = [0.0, 1.0, 0.0, -1.0]
		for i in range(4):
			var dx: float = float(d4x[i])
			var dy: float = float(d4y[i])
			ring_points.append({"x": x_value + dx * ring_r + dy * ring_w, "y": y_value + dy * ring_r - dx * ring_w})
			if f < 0.5:
				ring_points.append({"x": x_value + dx * ring_r - dy * ring_w, "y": y_value + dy * ring_r + dx * ring_w})
		top_call = {
			"call": "Draw.rect(topRegion, x, y);",
			"region": "topRegion",
			"color": {"from": base_color, "to": phase_color, "t": phase_heat},
			"alpha": top_alpha,
			"x": x_value,
			"y": y_value,
		}
		ring_call = {
			"call": "Lines.beginLine(); Lines.endLine(true);",
			"points": ring_points,
			"point_count": ring_points.size(),
			"stroke": stroke,
			"alpha": lod_alpha2,
			"r": ring_r,
			"w": ring_w,
			"closed": true,
		}
	var light_call: Dictionary = {
		"call": "Drawf.light(x, y, lightRadius * smoothEfficiency, baseColor, 0.7f * smoothEfficiency);",
		"x": x_value,
		"y": y_value,
		"radius": light_radius * smooth_efficiency,
		"color": base_color,
		"alpha": 0.7 * smooth_efficiency,
	}
	var real_range: float = range_value + phase_heat * phase_range_boost
	var selected_alpha: float = source_math_state.source_absin(time_value, 8.0, 1.0)
	var selected_calls: Array = []
	for candidate in selected_blocks:
		if not (candidate is Dictionary):
			continue
		if not candidate.has("x") or not candidate.has("y"):
			continue
		selected_calls.append({
			"call": "Drawf.selected(other, Tmp.c1.set(baseColor).a(Mathf.absin(4f, 1f)))",
			"x": float(candidate.get("x", 0.0)),
			"y": float(candidate.get("y", 0.0)),
			"color": base_color,
			"alpha": selected_alpha,
		})
	var select_call: Dictionary = {
		"dash_call": {
			"call": "Drawf.dashCircle(x, y, realRange, baseColor);",
			"x": x_value,
			"y": y_value,
			"radius": real_range,
			"color": base_color,
		},
		"selected_calls": selected_calls,
		"real_range": real_range,
		"selected_alpha": selected_alpha,
	}
	var offset_value: float = float((int(size_value) + 1) % 2) * source_world_defaults.TILESIZE / 2.0
	var place_x: float = float(tile_x) * source_world_defaults.TILESIZE + offset_value
	var place_y: float = float(tile_y) * source_world_defaults.TILESIZE + offset_value
	var place_call: Dictionary = {
		"super_call": "super.drawPlace(x, y, rotation, valid);",
		"valid": place_valid,
		"dash_call": {
			"call": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, baseColor);",
			"x": place_x,
			"y": place_y,
			"radius": range_value,
			"color": base_color,
		},
		"selected_calls": selected_calls,
		"offset": offset_value,
	}
	return {
		"super_expr": "super.draw();",
		"lod_guard_expr": "if(!Lod.l2) return;",
		"f_expr": "float f = 1f - (Time.time / 100f) % 1f;",
		"color_expr": "Draw.color(baseColor, phaseColor, phaseHeat);",
		"top_alpha_expr": "Draw.alpha(heat * Mathf.absin(Time.time, 50f / Mathf.PI2, 1f) * 0.5f * Lod.alpha2);",
		"top_rect_expr": "Draw.rect(topRegion, x, y);",
		"ring_alpha_expr": "Draw.alpha(Lod.alpha2);",
		"stroke_expr": "Lines.stroke((2f * f + 0.1f) * heat);",
		"ring_dims_expr": "float r = Math.max(0f, Mathf.clamp(2f - f * 2f) * size * tilesize / 2f - f - 0.2f), w = Mathf.clamp(0.5f - f) * size * tilesize;",
		"ring_begin_expr": "Lines.beginLine();",
		"ring_loop_expr": "for(int i = 0; i < 4; i++){",
		"ring_point_expr": "Lines.linePoint(x + Geometry.d4(i).x * r + Geometry.d4(i).y * w, y + Geometry.d4(i).y * r - Geometry.d4(i).x * w);",
		"ring_extra_expr": "if(f < 0.5f) Lines.linePoint(x + Geometry.d4(i).x * r - Geometry.d4(i).y * w, y + Geometry.d4(i).y * r + Geometry.d4(i).x * w);",
		"ring_end_expr": "Lines.endLine(true);",
		"reset_expr": "Draw.reset();",
		"light_expr": "Drawf.light(x, y, lightRadius * smoothEfficiency, baseColor, 0.7f * smoothEfficiency);",
		"select_range_expr": "float realRange = range + phaseHeat * phaseRangeBoost;",
		"select_each_block_expr": "indexer.eachBlock(this, realRange, other -> other.block.canOverdrive, other -> Drawf.selected(other, Tmp.c1.set(baseColor).a(Mathf.absin(4f, 1f))));",
		"select_dash_expr": "Drawf.dashCircle(x, y, realRange, baseColor);",
		"place_super_expr": "super.drawPlace(x, y, rotation, valid);",
		"place_dash_expr": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, baseColor);",
		"place_each_block_expr": "indexer.eachBlock(player.team(), x * tilesize + offset, y * tilesize + offset, range, other -> other.block.canOverdrive, other -> Drawf.selected(other, Tmp.c1.set(baseColor).a(Mathf.absin(4f, 1f))));",
		"x": x_value,
		"y": y_value,
		"tile_x": tile_x,
		"tile_y": tile_y,
		"range": range_value,
		"phase_heat": phase_heat,
		"phase_range_boost": phase_range_boost,
		"light_radius": light_radius,
		"smooth_efficiency": smooth_efficiency,
		"heat": heat,
		"time_value": time_value,
		"lod_l2": lod_l2,
		"lod_alpha2": lod_alpha2,
		"size": size_value,
		"base_color": base_color,
		"phase_color": phase_color,
		"place_valid": place_valid,
		"visible": lod_l2,
		"f": f,
		"top_absin": top_absin,
		"top_alpha": top_alpha,
		"stroke": stroke,
		"ring_r": ring_r,
		"ring_w": ring_w,
		"ring_point_count": ring_points.size(),
		"real_range": real_range,
		"selected_alpha": selected_alpha,
		"offset": offset_value,
		"place_x": place_x,
		"place_y": place_y,
		"base_call": base_call,
		"top_call": top_call,
		"ring_call": ring_call,
		"light_call": light_call,
		"select_call": select_call,
		"place_call": place_call,
	}
