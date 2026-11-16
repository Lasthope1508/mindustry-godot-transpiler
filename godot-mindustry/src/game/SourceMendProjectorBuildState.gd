extends RefCounted
class_name SourceMendProjectorBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_projector_boost_state := preload("res://src/game/SourceProjectorBoostState.gd")
const source_mend_projector_state := preload("res://src/game/SourceMendProjectorState.gd")
const source_drill_inventory_state := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

# The MendProjector implementation (MendProjector.java:21, `public class
# MendProjector extends Block{`): mender (consumePower 0.3f,
# size 1, reload 200f, range 40f, healPercent 4f, phaseBoost 4f,
# phaseRangeBoost 20f, silicon booster) and mend-projector
# (consumePower 1.5f, size 2, reload 250f, range 85f,
# healPercent 11f, phaseBoost 15f, phaseFabric booster). Both
# havePower=true (MendProjector.java:42, `hasPower = true;`)
# and hasItems=true. MendProjector extends Block, NOT a drill
# or factory, so it cannot reuse an existing frame key; this
# driver uses its own family frame key
# ("source_mend_projector_building", the mechanical-pump /
# beam-drill precedent), and this slice adds the
# mend-projector key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it. The port already has MendProjector display/runtime
# state (SourceMendProjectorRuntimeState.gd reads
# `runtime_step.get("efficiency", 1.0)` and multiplies the heal
# by it, `healed_amount *= float(runtime_step.get("efficiency", 1.0))` at :67) -- the heal fold already consumes
# efficiency; the missing piece is the live power.status ->
# efficiency driver, which is exactly this slice.
const SOURCE_MEND_PROJECTOR_BUILD_IMPLEMENTATIONS := ["MendProjector"]
const SOURCE_MEND_PROJECTOR_BUILDING_META_KEY := "source_mend_projector_building"

static func _is_mend_projector_build_implementation(implementation: String) -> bool:
	return SOURCE_MEND_PROJECTOR_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_mend_projector_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The mend-projector tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (MendProjector.java:21, `public class MendProjector extends Block{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# mend projector skips consumption like Java's updateConsumption
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
	# for this mend projector (N2125); the tick preserves a disabled
	# mend projector instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	# A new MendBuild starts with an empty item module (the
	# Building.items ItemModule, the factory precedent
	# SourceFactoryBuildState.gd:89-101, `frame["items"] = {}`):
	# the booster item row (N2263) reads the held stacks from
	# frame["items"], so the frame carries the items Dictionary
	# keyed by item name from placement. No live intake fills
	# it yet (the Separator precedent) -- the row reads the
	# frame as-is, so a live mend projector with no intake
	# reads 0 items and folds optionalEfficiency 0.
	return {"items": {}}

static func source_mend_projector_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the mend-projector frame meta key
	# ("source_mend_projector_building"). A MendProjector sprite gets an
	# empty frame bound; the live-loop tick fills its keys every
	# tick. Any other block, or an already-bound sprite, binds
	# nothing.
	if block == null or not _is_mend_projector_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_MEND_PROJECTOR_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_MEND_PROJECTOR_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_mend_projector_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
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
	# so a mend projector does not take the early return. The
	# heal follows the folded efficiency
	# (MendProjector.java:113, `other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);`), with the smooth-efficiency gate
	# (MendProjector.java:96, `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);`) and the heat gate
	# (MendProjector.java:97, `heat = Mathf.lerpDelta(heat, efficiency > 0 && canHeal ? 1f : 0f, 0.08f);`) and the charge advance
	# (MendProjector.java:98, `charge += heat * delta();`).
	# Documented limits: (1) power first pass + booster item
	# optional pass -- the silicon (mender, 1 stack,
	# `consumeItem(Items.silicon).boost();`, Blocks.java:1929)
	# and phaseFabric (mend-projector, 1 stack,
	# `consumeItem(Items.phaseFabric).boost();`, Blocks.java:1941)
	# booster item rows are live since N2263 (ConsumeItems.
	# efficiency, ConsumeItems.java:51-53, binary 1/0), folded
	# into the optional pass (BuildingComp.java:1980-1981) and
	# capped by minEfficiency (BuildingComp.java:1986). The
	# timer-gated consume() (MendProjector.java:102-104,
	# `public float useTime = 400f;`, MendProjector.java:31)
	# is live since N2269: the tick accumulates
	# frame["timer_use_elapsed"] every tick and, between the
	# advance and the heal scan, removes 1 booster item per
	# def when the folded optionalEfficiency is positive and
	# the timer fires and canHeal holds. Documented deviation:
	# the frame-local clock delays the first fire by a full
	# interval after placement (Java fires nearly at once --
	# the global Time.time is already large vs a fresh
	# Interval times[id] = 0, arc Interval.java:20-26); no
	# live intake fills frame["items"] yet (the Separator
	# precedent), so the row and the removal read the frame
	# as-is; canHeal is the documented default true
	# (suppression untracked). Other unmodeled rows still
	# defer (suppression, draw / drawLight / sense, the live
	# building index). (2) No shouldConsume gate --
	# MendBuild has no shouldConsume override, so the default
	# (BuildingComp.java:755-757, `return enabled;`) applies;
	# the machinery runs with should_consume=true when
	# enabled. (3) No suppression gate -- `canHeal =
	# !checkSuppression();` (MendProjector.java:94) needs
	# suppression state the tick does not track yet. (4)
	# updateTile advance -- N2193 advances smoothEfficiency /
	# heat / charge / phaseHeat (MendProjector.java:94-100,
	# 103-105) on the frame, including the charge reset; the
	# timer/consume line (MendProjector.java:102-104) is live
	# since N2269 and the heal scan since N2242 (explicit
	# candidates, MendProjector.java:106-122);
	# the range query is live since N2329 (the broad-phase
	# filter over frame["heal_candidates"], MendProjector.java:112),
	# and the hitbox broad phase is live since N2350 (the
	# N2329 pure now delegates to the STRICT hitbox overlap
	# filter, BlockIndexer.java:345 / Rect.java:274-276);
	# the within/privileged refinement is live since N2335
	# (the STRICT within circle + !privileged narrow filter
	# chained after the broad phase, BlockIndexer.java:346).
	# Fx / sound / recentlyHealed and the live building index
	# still wait.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func _mend_projector_booster_stacks_for_block(block_id: String) -> Array:
	# The per-def booster item stacks (the Separator per-def
	# helper precedent): mender consumes silicon, mend-projector
	# consumes phaseFabric, each a single stack of 1
	# (`consumeItem(Items.silicon).boost();`, Blocks.java:1929;
	# `consumeItem(Items.phaseFabric).boost();`, Blocks.java:1941;
	# consumeItem(item) is a stack of 1, `public ConsumeItems consumeItem(Item item){` / `return consumeItem(item, 1);`,
	# Block.java:1167-1168). Item ids are kebab-case per the
	# catalog ("silicon", "phase-fabric"). An unknown block id
	# has no booster row.
	if block_id == "mender":
		return [{"item": "silicon", "amount": 1}]
	if block_id == "mend-projector":
		return [{"item": "phase-fabric", "amount": 1}]
	return []

static func source_mend_projector_item_consumer_row_state(frame: Dictionary, stacks: Array) -> Dictionary:
	# ConsumeItems.efficiency (ConsumeItems.java:51-53, each
	# exact expr on ONE comment line, the N2148 lesson):
	# `return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;`
	# The result is BINARY 1.0/0.0 -- not a ratio like
	# ConsumeLiquid. The trigger-valid half is the base false
	# (`public boolean consumeTriggerValid(){`, BuildingComp.java:764-766,
	# `return false;`; no MendProjector family overrides it),
	# so the row is 1.0 exactly when every stack is held:
	# `if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;`
	# (ItemModule.java:153-156), with `return get(item) >= amount;`
	# (ItemModule.java:126-128). The multiplier is the Consume
	# default 1f (`public Floatf<Building> multiplier = b -> 1f;`,
	# Consume.java:18) -- neither def sets one -- so the
	# required count is round(amount * 1f) = amount. The counts
	# read through the shared drill inventory helper
	# (SourceDrillInventoryRuntimeState.item_count, the
	# Separator precedent) over frame["items"], not a
	# recomputation; a frame without an items store reads 0,
	# like Java items.get for an item never added. Booster =
	# `return optional(true, true);` (Consume.java:33-35), so
	# the row folds into the OPTIONAL pass only:
	# `for(var cons : block.optionalConsumers){`
	# `optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));`
	# (BuildingComp.java:1980-1981), capped by the min:
	# `efficiency = minEfficiency;`
	# `optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);`
	# (BuildingComp.java:1985-1986), and zeroed when the gate
	# is false (`efficiency = optionalEfficiency = 0f;`,
	# BuildingComp.java:1992-1994) -- the row never touches the
	# min efficiency or shouldConsumePower. phaseHeat already
	# lerps toward the folded optionalEfficiency
	# (`phaseHeat = Mathf.lerpDelta(phaseHeat, optionalEfficiency, 0.1f);`,
	# MendProjector.java:100); this slice only supplies the real
	# optionalEfficiency, and the heal follows it
	# (`other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);`,
	# MendProjector.java:113). The removal side is live since
	# N2269 (the timer-gated consume()
	# `if(optionalEfficiency > 0 && timer(timerUse, useTime / timeScale) && canHeal){`
	# (MendProjector.java:102-104, `public float useTime = 400f;`,
	# MendProjector.java:31) runs in the tick between the
	# advance and the heal scan): ConsumeItems has no update()
	# to run in the second pass, so consumption only ever
	# happens through that timer-gated consume() call
	# (`build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));`,
	# ConsumeItems.java:44-48). A block with no item consumer
	# (empty stacks) contributes no row.
	if stacks.is_empty():
		return {"has_item_row": false, "row": {}}
	var items: Dictionary = frame.get("items", {})
	var has_all := true
	for stack in stacks:
		var entry: Dictionary = stack if stack is Dictionary else {}
		var item_id: String = str(entry.get("item", ""))
		var amount: int = int(entry.get("amount", 0))
		if source_drill_inventory_state.item_count(items, item_id) < amount:
			has_all = false
			break
	var result: float = 1.0 if has_all else 0.0
	return {"has_item_row": true, "row": {"result": result, "is_power": false}}

static func source_mend_projector_timer_use_state(elapsed: float, duration: float, time_scale: float) -> Dictionary:
	# The frame-local Interval-equivalent for the booster
	# timer (TimerComp.timer, TimerComp.java:10-13, each
	# exact expr on ONE comment line, the N2148 lesson):
	# `if(Float.isInfinite(time)) return false;`
	# `return timer.get(index, time);`
	# Interval.get resets times[id] = Time.time on fire
	# (arc Interval.java:20-26, `boolean got = check(id,
	# time);` / `if(got) times[id] = Time.time;`) and
	# check compares Time.time - times[id] >= time (arc
	# Interval.java:28-30); Time.time counts TICKS (arc
	# Time.java:69-80, `timeRaw += delta;`). The port has
	# no global tick clock at the driver layer, so the
	# elapsed clock is frame-local (frame["timer_use_
	# elapsed"], accumulated by the tick delta every tick,
	# unconditionally -- mirroring Time.time, which grows
	# even while the gate is closed): threshold = duration
	# / time_scale, the Java threshold in
	# `if(optionalEfficiency > 0 && timer(timerUse, useTime / timeScale) && canHeal){`
	# (MendProjector.java:102, `public float useTime =
	# 400f;`, MendProjector.java:31, no def overrides it);
	# a non-positive
	# time_scale is the infinite-time branch (fired
	# false); fired = elapsed >= threshold; elapsed_after
	# RESETS to 0.0 on fire (a reset, not a subtraction
	# like the Fracker accumulator). Documented deviation:
	# Java fires (nearly) immediately after placement
	# when the gate first opens (the global Time.time is
	# already large vs a fresh Interval times[id] = 0);
	# the frame-local clock delays the first fire by a
	# full interval. It cannot be fixed without a global
	# clock -- it waits for a timer-infra slice if exact
	# first-fire timing is ever needed. consume() itself
	# (`for(Consume cons : block.consumers){` /
	# `cons.trigger(self());`, BuildingComp.java:1911-1915)
	# removes 1 booster item per def (mender silicon,
	# mend-projector phaseFabric, Blocks.java:1929/1941):
	# `consumeItem(Items.silicon).boost();`
	# `consumeItem(Items.phaseFabric).boost();`
	# consumeItem(item) is a stack of 1 (Block.java:
	# 1167-1168):
	# `public ConsumeItems consumeItem(Item item){`
	# `return consumeItem(item, 1);`
	# Block.java:1167-1168) via ConsumeItems.trigger
	# (ConsumeItems.java:44-48):
	# `build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));`
	# clamped by ItemModule.remove (ItemModule.java:258-263):
	# `amount = Math.min(amount, items[item.id]);`
	# canHeal is (MendProjector.java:94):
	# `boolean canHeal = !checkSuppression();`
	# and the tick keeps the documented default true
	# (suppression untracked, the N2184 precedent).
	# timeScale defaults 1f (BuildingComp.java:98):
	# `private transient float timeScale = 1f, timeScaleDuration;`
	var threshold: float = INF if time_scale <= 0.0 else duration / time_scale
	var fired: bool = elapsed >= threshold
	var elapsed_after: float = 0.0 if fired else elapsed
	return {"fired": fired, "elapsed_after": elapsed_after, "threshold": threshold}

static func source_mend_projector_update_tile_advance_state(frame: Dictionary, reload_value: float, time_delta: float, time_scale := 1.0, can_heal := true) -> Dictionary:
	# MendBuild.updateTile() (MendProjector.java:94-120), the
	# pure frame advance -- the build fields are
	# `public float heat, charge = Mathf.random(reload), phaseHeat, smoothEfficiency;` (MendProjector.java:85),
	# and the advance follows the Java lines in order (each
	# exact expr on ONE comment line, the N2148 lesson):
	# `boolean canHeal = !checkSuppression();`
	# `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);`
	# `heat = Mathf.lerpDelta(heat, efficiency > 0 && canHeal ? 1f : 0f, 0.08f);`
	# `charge += heat * delta();`
	# `phaseHeat = Mathf.lerpDelta(phaseHeat, optionalEfficiency, 0.1f);`
	# `if(charge >= reload && canHeal){` then `charge = 0f;`
	# The lerp formula comes from Arc, not from a guess:
	# lerpDelta is `return lerp(fromValue, toValue, clamp(progress * Time.delta));` (Mathf.java:430-432),
	# so the lerps use the UNSCALED Time.delta
	# (source_math_state.source_lerp_delta), while the charge
	# advance uses the SCALED delta():
	# `return Time.delta * timeScale;` (BuildingComp.java:1922-1924).
	# The charge advance uses the NEW heat (Java line order:
	# heat is assigned before the charge line). The reset sits
	# in the `charge >= reload` branch BEFORE the indexer
	# scan, so it does not depend on finding a target --
	# this slice implements the reset and defers the scan.
	# Scoping decisions, all source-backed: (1) can_heal
	# defaults true -- the tick tracks no suppression state
	# (the N2184 BuildTurret suppression precedent); the
	# parameter keeps the suppressed branch (heat lerps
	# toward 0, no reset) provable. (2) efficiency /
	# optional_efficiency read from the frame with the Java
	# field default 0.0 (BuildingComp.java:87, `transient
	# float optionalEfficiency;`); the shared machinery folds
	# both onto the frame (apply_update_consumption_state),
	# and the optional value is the min over the modeled
	# optional consumers (the N2263 booster item row), capped
	# by the folded efficiency. (3) charge binds
	# 0.0 deterministically instead of the Java random init
	# (documented deviation: the random stagger only
	# desynchronizes first-heal timing across projectors).
	# (4) reload_value is per-def (mender 200f,
	# mend-projector 250f, Blocks.java:1923/1936), read by
	# the tick through the family helper. The booster
	# timer/consume line
	# `if(optionalEfficiency > 0 && timer(timerUse, useTime / timeScale) && canHeal){` (MendProjector.java:102-104)
	# is live since N2269 -- the tick runs it between this
	# advance and the heal scan, not inside the advance.
	# DEFERRED, not done and not guessed: the heal scan
	# + sound -- `other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);`
	# (MendProjector.java:113, needs targets/indexer
	# infrastructure) -- plus draw / drawLight / sense
	# (MendProjector.java:122-170). The older runtime
	# simulation (SourceMendProjectorRuntimeState.
	# runtime_step_state) is a separate state store that
	# lerps toward 1.0 unconditionally with no charge reset;
	# this driver frame advance follows Java exactly and
	# does not touch it.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var optional_efficiency: float = float(frame.get("optional_efficiency", 0.0))
	var smooth_efficiency: float = source_math_state.source_lerp_delta(float(frame.get("smooth_efficiency", 0.0)), efficiency, source_projector_boost_state.SOURCE_PROJECTOR_HEAT_LERP_PROGRESS, time_delta)
	var heat_target: float = 1.0 if efficiency > 0.0 and can_heal else 0.0
	var heat: float = source_math_state.source_lerp_delta(float(frame.get("heat", 0.0)), heat_target, source_projector_boost_state.SOURCE_PROJECTOR_HEAT_LERP_PROGRESS, time_delta)
	var charge: float = float(frame.get("charge", 0.0)) + heat * time_delta * time_scale
	var phase_heat: float = source_math_state.source_lerp_delta(float(frame.get("phase_heat", 0.0)), optional_efficiency, source_projector_boost_state.SOURCE_PROJECTOR_PHASE_HEAT_LERP_PROGRESS, time_delta)
	if charge >= reload_value and can_heal:
		charge = 0.0
	frame["smooth_efficiency"] = smooth_efficiency
	frame["heat"] = heat
	frame["charge"] = charge
	frame["phase_heat"] = phase_heat
	return frame

static func source_mend_projector_heal_scan_state(frame: Dictionary, candidates: Array, charge_before: float, reload_value: float, range_value: float, heal_percent: float, phase_boost: float, phase_range_boost: float, time_delta: float, time_scale := 1.0, can_heal := true) -> Dictionary:
	# MendBuild.updateTile() heal branch (MendProjector.java:106-122),
	# the pure scan -- the N2193 advance already ran on this frame
	# (smoothEfficiency / heat / charge / phaseHeat, including the
	# charge reset), so the scan reads the POST-advance phase_heat /
	# heat / efficiency and recomputes the branch crossing from the
	# charge captured BEFORE the advance (each exact expr on ONE
	# comment line, the N2148 lesson):
	# `if(charge >= reload && canHeal){`
	# `float realRange = range + phaseHeat * phaseRangeBoost;`
	# `indexer.eachBlock(this, realRange, b -> b.damaged() && !b.isHealSuppressed(), other -> {`
	# `other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);`
	# `private boolean any = false;`
	# The crossing recompute follows the charge advance line
	# `charge += heat * delta();` (MendProjector.java:98): the
	# advance added heat_after * time_delta * time_scale to
	# charge_before and reset to 0f on crossing, so the scan
	# replays charge_before + heat_after * time_delta *
	# time_scale >= reload_value against the per-def reload --
	# reading the frame charge here would always see the reset
	# 0f. The predicate halves are explicit per-candidate
	# booleans: damaged() is `return health < maxHealth - 0.001f;`
	# (HealthComp.java:47-49) and isHealSuppressed() is
	# `return block.suppressable && Time.time <= healSuppressionTime;`
	# (BuildingComp.java:487-489); the port tracks neither
	# health nor suppression time on candidate buildings, so
	# the caller supplies both. Per-def params are explicit:
	# the defs override the class defaults (mender range 40f /
	# healPercent 4f / phaseBoost 4f / phaseRangeBoost 20f,
	# Blocks.java:1924-1927; mend-projector range 85f /
	# healPercent 11f / phaseBoost 15f, Blocks.java:1937-1939,
	# phaseRangeBoost NOT overridden so the class 50f,
	# MendProjector.java:30, applies). DEFERRED, not done and
	# not guessed: `other.recentlyHealed();` (MendProjector.java:114,
	# a timestamp write on the healed building object),
	# `Fx.healBlockFull.at(other.x, other.y, other.block.size, baseColor, other.block);` (MendProjector.java:115,
	# presentation), and `mendSound.at(this, 1f + Mathf.range(0.1f), mendSoundVolume);` (MendProjector.java:120,
	# sound, gated on `any`) -- the pure scan returns the
	# amounts and the flag and lets the caller apply them.
	# The range filter over the candidate list is live
	# since N2329 (source_mend_projector_supplied_heal_
	# candidates_state, the eachBlock broad phase -- the
	# hitbox overlap filter since N2350) and the
	# within/privileged narrow filter is live since N2335
	# (source_mend_projector_supplied_heal_candidates_
	# narrow_state, chained after the broad phase): the live tick
	# filters frame["heal_candidates"] and passes the
	# narrowed list here. The live building index that would
	# fill frame["heal_candidates"] is deferred still: the
	# port has no live building query, so the caller
	# passes the candidate list explicit.
	var phase_heat: float = float(frame.get("phase_heat", 0.0))
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var heat_after: float = float(frame.get("heat", 0.0))
	var real_range: float = range_value + phase_heat * phase_range_boost
	var crossed: bool = charge_before + heat_after * time_delta * time_scale >= reload_value and can_heal
	var heal_amounts: Array = []
	var any_healed: bool = false
	if crossed:
		for candidate in candidates:
			var entry: Dictionary = candidate if candidate is Dictionary else {}
			if bool(entry.get("damaged", false)) and not bool(entry.get("heal_suppressed", false)):
				var max_health: float = float(entry.get("max_health", 0.0))
				heal_amounts.append(max_health * (heal_percent + phase_heat * phase_boost) / 100.0 * efficiency)
				any_healed = true
	return {"real_range": real_range, "heal_amounts": heal_amounts, "any": any_healed, "scanned": crossed}

static func source_mend_projector_supplied_heal_candidates_state(candidates: Array, real_range: float, building_x: float, building_y: float) -> Dictionary:
	# The heal scan range query (MendProjector.java:106-122),
	# the pure eachBlock broad phase -- the N2242 heal scan
	# already filters damaged + not heal-suppressed and folds
	# the heal, but takes its candidate list explicit with NO
	# range filter; this pure adds the range half of the Java
	# scan (each exact expr on ONE comment line, the N2148
	# lesson):
	# `float realRange = range + phaseHeat * phaseRangeBoost;`
	# `indexer.eachBlock(this, realRange, b -> b.damaged() && !b.isHealSuppressed(), other -> {`
	# `public boolean eachBlock(Teamc team, float range, Boolf<Building> pred, Cons<Building> cons){`
	# `return eachBlock(team.team(), team.getX(), team.getY(), range, pred, cons);`
	# `public boolean eachBlock(@Nullable Team team, float wx, float wy, float range, Boolf<Building> pred, Cons<Building> cons){`
	# `buildings.intersect(wx - range, wy - range, range*2f, range*2f, b -> {`
	# `if(b.within(wx, wy, range + b.hitSize() / 2f) && pred.get(b) && !b.block.privileged){`
	# `return Mathf.dst2(getX(), getY(), x, y) < dst*dst;`
	# `public float range = 60f;`
	# `public float phaseRangeBoost = 50f;`
	# `range = 40f;`
	# `phaseRangeBoost = 20f;`
	# `range = 85f;`
	# The rect is in WORLD units directly -- the quadtree
	# intersect takes (wx - range, wy - range, range*2f,
	# range*2f), no tilesize factor (BlockIndexer.java:345;
	# contrast the RegenProjector rect, which multiplies by
	# tilesize, N2277) -- so the half-side is realRange
	# itself. Java's intersect is a QuadTree HITBOX overlap
	# query, not a center test: the QuadTree admits a
	# building whose hitbox (a hitSize-sided square centered
	# on the building, BuildingComp.java:2293) STRICTLY
	# overlaps the query rect (QuadTree.java:190-191 /
	# Rect.java:274-276). The N2329 port tested candidate
	# CENTERS against the rect inclusively (the N2277
	# precedent) -- an approximation that dropped
	# large-hitbox buildings whose center sat outside the
	# rect but within range + hitSize/2; since N2350 this
	# pure DELEGATES to the hitbox broad phase
	# (source_mend_projector_heal_candidates_hitbox_state)
	# instead, keeping its signature and its {candidates}
	# return shape. The per-def range / phaseRangeBoost ride
	# the caller's real_range (mender 40f / 20f, Blocks.java:
	# 1924/1927; mend-projector 85f / class 50f, Blocks.java:
	# 1937 / MendProjector.java:30); the class defaults are
	# range 60f / phaseRangeBoost 50f (MendProjector.java:
	# 27/30). Documented deviation, source-backed: the rect
	# is only Java's BROAD phase -- the float-range overload
	# then admits only `b.within(wx, wy, range + b.hitSize()
	# / 2f)` (a STRICT dst2 < (range + hitSize/2)^2 circle,
	# Position.java:44-46) with the predicate and
	# `!b.block.privileged` (BlockIndexer.java:346) -- so
	# the port admits rect corners Java rejects (for a small
	# hitSize); the narrow-check refinement is live since
	# N2335 (source_mend_projector_supplied_heal_candidates_
	# narrow_state, chained after this broad phase) -- the
	# rect-corner half is fixed, and the large-hitbox-miss
	# half is fixed since N2350 (the hitbox broad phase).
	# Scoping decisions, all source-backed: (1)
	# the pure filters RANGE ONLY -- it does NOT filter
	# damaged / heal_suppressed (the N2242 heal scan already
	# does, MendProjector.java:112 predicate halves), so a
	# healthy or suppressed in-range candidate is admitted
	# here and dropped downstream. (2) A candidate dict
	# carries x / y (world position, the building center)
	# plus hit_size (default 0.0, the N2335 narrow
	# precedent -- a degenerate point hitbox) plus its other
	# keys untouched (damaged / heal_suppressed / max_health
	# -- the pure only filters, it never rewrites an entry);
	# a missing x or y key EXCLUDES the candidate, and a
	# non-Dictionary entry is excluded the same way. (3)
	# The admitted entries are the candidate dicts
	# themselves, in candidate order, like Java's
	# Seq<Building>. (4) The team filter is the caller's:
	# Java visits the projector team's buildingTree only
	# (BlockIndexer.java:343), so the caller supplies
	# same-team candidates. The live building index that
	# would supply frame["heal_candidates"] still waits
	# (DEFERRED).
	return source_mend_projector_heal_candidates_hitbox_state(candidates, real_range, building_x, building_y)

static func source_mend_projector_heal_candidates_hitbox_state(candidates: Array, real_range: float, building_x: float, building_y: float) -> Dictionary:
	# The heal scan hitbox broad phase (BlockIndexer.
	# java:345), the pure QuadTree hitbox overlap filter --
	# the N2329 pure tested candidate CENTERS against the
	# eachBlock rect inclusively (the N2277 precedent), an
	# approximation that dropped large-hitbox buildings
	# whose center sat outside the rect but within range +
	# hitSize/2 before the N2335 narrow check ever saw
	# them. Java's buildings.intersect is a QuadTree HITBOX
	# overlap query: EntityGroup.intersect delegates to the
	# QuadTree (each exact expr on ONE comment line, the
	# N2148 lesson):
	# `public void intersect(float x, float y, float width, float height, Cons<? super T> out){`
	# `tree.intersect(x, y, width, height, out);`
	# `hitbox(item);`
	# `if(tmp.overlaps(x, y, width, height)){`
	# `return x < rx + rwidth && x + width > rx && y < ry + rheight && y + height > ry;`
	# `out.setCentered(x, y, block.size * tilesize, block.size * tilesize);`
	# `return tile.block().size * tilesize;`
	# The overlap is STRICT (Rect.java:274-276): a hitbox
	# edge exactly touching the rect edge does NOT overlap,
	# so a degenerate hitSize-0 hitbox on the edge or corner
	# is dropped while the same point strictly inside is
	# admitted -- the port excludes on the negated STRICT
	# test on both axes (the N2340 ShockwaveTower precedent).
	# A building's hitbox is a hitSize-sided square centered
	# on the building (BuildingComp.java:2293), with hitSize
	# the building hitbox size in world units
	# (BuildingComp.java:2048); a real building always has
	# hitSize >= 8 (size 1 * tilesize 8), so a real building
	# centered exactly on the rect edge is admitted -- its
	# hitbox overlaps. Scoping decisions, all source-backed:
	# (1) the pure filters HITBOX OVERLAP ONLY -- it does
	# NOT filter damaged / heal_suppressed (the N2242 heal
	# scan already does, MendProjector.java:112 predicate
	# halves) and does NOT filter within / privileged (the
	# N2335 narrow pure chains after it). (2) A candidate
	# dict carries x / y (world position, the building
	# center) plus hit_size (default 0.0, the N2335 narrow
	# precedent) plus its other keys untouched (damaged /
	# heal_suppressed / max_health -- the pure only filters,
	# it never rewrites an entry); a missing x or y key
	# EXCLUDES the candidate (the N2329 precedent), and a
	# non-Dictionary entry is excluded the same way. (3)
	# The admitted entries are the candidate dicts
	# themselves, in candidate order, like Java's
	# Seq<Building>. (4) The chain order is hitbox broad
	# phase -> narrow: the tick passes the N2329 ranged
	# list (now hitbox-backed) into the N2335 narrow pure
	# at the SAME realRange and building position, and
	# passes the narrowed list into the N2242 heal scan.
	var in_range: Array = []
	for candidate in candidates:
		if not (candidate is Dictionary):
			continue
		if not candidate.has("x") or not candidate.has("y"):
			continue
		var half_size: float = float(candidate.get("hit_size", 0.0)) / 2.0
		var candidate_x: float = float(candidate.get("x", 0.0))
		var candidate_y: float = float(candidate.get("y", 0.0))
		if candidate_x - half_size >= building_x + real_range or candidate_x + half_size <= building_x - real_range:
			continue
		if candidate_y - half_size >= building_y + real_range or candidate_y + half_size <= building_y - real_range:
			continue
		in_range.append(candidate)
	return {"candidates": in_range}

static func source_mend_projector_supplied_heal_candidates_narrow_state(candidates: Array, real_range: float, building_x: float, building_y: float) -> Dictionary:
	# The heal scan narrow check (BlockIndexer.java:346),
	# the pure within / privileged filter -- the N2329 rect
	# pure is only Java's BROAD phase: past the rect, the
	# float-range overload admits only the STRICT within
	# circle plus the predicate plus the privileged
	# exclusion (each exact expr on ONE comment line, the
	# N2148 lesson):
	# `float realRange = range + phaseHeat * phaseRangeBoost;`
	# `indexer.eachBlock(this, realRange, b -> b.damaged() && !b.isHealSuppressed(), other -> {`
	# `buildings.intersect(wx - range, wy - range, range*2f, range*2f, b -> {`
	# `if(b.within(wx, wy, range + b.hitSize() / 2f) && pred.get(b) && !b.block.privileged){`
	# `return Mathf.dst2(getX(), getY(), x, y) < dst*dst;`
	# `return tile.block().size * tilesize;`
	# `public boolean privileged = false;`
	# Within is STRICT (Position.java:44-46): dst2 <
	# (range + hitSize/2)^2, so exactly at range +
	# hitSize/2 is OUT -- the port excludes on dst2 >=
	# limit^2, the same strict boundary. hitSize is the
	# building hitbox size in world units
	# (BuildingComp.java:2048), so the limit grows with
	# the candidate's own hitbox; privileged defaults
	# false (Block.java:148). Scoping decisions, all
	# source-backed: (1) the pure filters WITHIN +
	# PRIVILEGED ONLY -- it does NOT filter damaged /
	# heal_suppressed (the N2242 heal scan already does,
	# MendProjector.java:112 predicate halves), so a
	# healthy or suppressed in-circle candidate is
	# admitted here and dropped downstream. (2) A
	# candidate dict carries x / y (world position, the
	# building center) plus hit_size (default 0.0, the
	# N2226 RepairTurret precedent) and privileged
	# (default false) plus its other keys untouched
	# (damaged / heal_suppressed / max_health -- the pure
	# only filters, it never rewrites an entry); a missing
	# x or y key EXCLUDES the candidate (the N2329
	# precedent), and a non-Dictionary entry is excluded
	# the same way. (3) The admitted entries are the
	# candidate dicts themselves, in candidate order,
	# like Java's Seq<Building>. (4) The chain order is
	# hitbox broad phase -> narrow: the tick passes the
	# N2329 ranged list here, at the SAME realRange and
	# building position, and passes the narrowed list
	# into the N2242 heal scan. The broad phase is the
	# Java-exact hitbox overlap since N2350 (the N2329
	# pure delegates to source_mend_projector_heal_
	# candidates_hitbox_state) -- the old rect center test
	# that dropped large-hitbox buildings whose center sat
	# outside the rect is gone (DEFERRED #326 resolved).
	var narrowed: Array = []
	for candidate in candidates:
		if not (candidate is Dictionary):
			continue
		if not candidate.has("x") or not candidate.has("y"):
			continue
		if bool(candidate.get("privileged", false)):
			continue
		var limit: float = real_range + float(candidate.get("hit_size", 0.0)) / 2.0
		var dx: float = float(candidate.get("x", 0.0)) - building_x
		var dy: float = float(candidate.get("y", 0.0)) - building_y
		if dx * dx + dy * dy >= limit * limit:
			continue
		narrowed.append(candidate)
	return {"candidates": narrowed}

@warning_ignore("unused_parameter")
static func source_mend_projector_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the mend-projector tick wiring every
	# tick (MendBuild.updateTile(), MendProjector.java:94,
	# gates on the smooth-efficiency gate (MendProjector.java:96,
	# `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);`) and folds the
	# heal (MendProjector.java:113,
	# `other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);`), so the
	# heal fold follows the folded efficiency; no
	# placed-buildings driver ticks MendProjector blocks, so this
	# driver is the placed-mend-projector tick): each placed
	# MendProjector build gets its frame keys refreshed from the
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
		if not _is_mend_projector_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_mend_projector_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_mend_projector_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a mend projector with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the heal fold (MendProjector.java:113)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449,
		# `hasConsumers = consumers.length > 0;`), so a mend
		# projector does not take the early return. The booster
		# item row folds into the optional pass since N2263
		# (mender silicon / mend-projector phaseFabric,
		# Blocks.java:1929/1941; ConsumeItems.efficiency,
		# ConsumeItems.java:51-53, binary 1/0), so a mend
		# projector with no booster items folds
		# optionalEfficiency 0 while the power min is
		# untouched. A mend projector with no power consumer is
		# untouched: there is no shouldConsume gate yet
		# (MendBuild has no shouldConsume override; the default
		# BuildingComp.java:755-757 `return enabled;` applies),
		# so the machinery runs with should_consume=true when enabled.
		# productionValid is the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_mend_projector_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var optional_results: Array = []
			var item_row: Dictionary = source_mend_projector_item_consumer_row_state(frame, _mend_projector_booster_stacks_for_block(block_id))
			if bool(item_row.get("has_item_row", false)):
				optional_results.append(item_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, optional_results, [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# The updateTile advance runs for every ticked mend
		# projector, inside or outside the consumption gate:
		# updateTile runs even when disabled
		# (BuildingComp.java:2276, `if(enabled ||
		# !block.noUpdateDisabled){` with noUpdateDisabled
		# false, Block.java:170), and updateConsumption runs
		# first (BuildingComp.java:2274), so the advance
		# follows the frame efficiency the machinery last
		# folded. The per-def reload comes from the family
		# helper (mender 200f, mend-projector 250f,
		# Blocks.java:1923/1936); Time.delta in ticks from
		# the placed-block helper; timeScale live from the
		# sprite meta (default 1f, BuildingComp.java:98);
		# canHeal is the documented default true
		# (suppression untracked, the N2184 precedent).
		var time_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		# The frame-local timer clock (N2269) accumulates
		# the tick delta EVERY tick, unconditionally --
		# mirroring Time.time, which grows even while the
		# gate is closed (arc Time.java:69-80, `timeRaw +=
		# delta;`), so the timer fires at once when the
		# gate reopens.
		frame["timer_use_elapsed"] = float(frame.get("timer_use_elapsed", 0.0)) + time_delta
		var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		var reload_value: float = source_mend_projector_state.projector_reload(block)
		# The heal scan (N2242) runs right after the advance,
		# in Java order (MendProjector.java:106-122 follows the
		# advance lines :94-100): capture charge_before BEFORE
		# the advance, because the advance resets the frame
		# charge to 0f on crossing and the scan recomputes the
		# crossing from it. The per-def scan params come from
		# the block properties with the class defaults where a
		# def does not override (range 60f, healPercent 12f,
		# phaseBoost 12f, phaseRangeBoost 50f,
		# MendProjector.java:27-30).
		# The range query is live since N2329: after the
		# advance (realRange needs the post-advance
		# phase_heat), the tick filters the frame heal
		# candidates (frame["heal_candidates"], default
		# [] -- no candidates, the Java no-buildings-in-range
		# outcome) through the scan pure at the live realRange
		# from the live building position (origin cell + block
		# offset, the N2306 RepairTower precedent: Building
		# x/y are tile.drawx()/drawy(), BuildingComp.java:124)
		# and passes the ranged list into the heal scan; the
		# broad phase is the Java-exact hitbox overlap since
		# N2350 (the N2329 pure delegates to the hitbox pure);
		# the within/privileged narrow filter is live since N2335:
		# the tick chains the narrow pure after the broad phase
		# (same realRange and building position) and passes
		# the NARROWED list into the heal scan, so a rect
		# corner or a privileged building is never healed.
		# The live building index that would fill the frame
		# list still waits. The tick records the scan result
		# on the frame as last_heal_scan (its `any` entry
		# mirrors the Java `any` field, MendProjector.java:35).
		var charge_before: float = float(frame.get("charge", 0.0))
		source_mend_projector_update_tile_advance_state(frame, reload_value, time_delta, time_scale)
		# The booster timer consume (N2269) runs between the
		# advance and the heal scan, in Java order
		# (MendProjector.java:102-104 before :106+):
		# `if(optionalEfficiency > 0 && timer(timerUse, useTime / timeScale) && canHeal){`
		# -- the folded optionalEfficiency is positive and
		# the frame-local timer fires at useTime 400f over
		# the live timeScale and canHeal holds (the
		# documented default true, suppression untracked,
		# the N2184 precedent). consume() removes 1 booster
		# item per def DIRECTLY through the shared inventory
		# helper (clamped to the held count, ItemModule.
		# java:258-263) and the elapsed clock resets to 0.0
		# (Interval.get resets times[id] = Time.time on
		# fire, arc Interval.java:20-26). The elapsed clock
		# is NOT reset when the gate is closed -- Java
		# short-circuits before calling timer(), so the
		# Interval keeps its old stamp and fires at once
		# when the gate reopens.
		var timer_use: Dictionary = source_mend_projector_timer_use_state(float(frame.get("timer_use_elapsed", 0.0)), 400.0, time_scale)
		if float(frame.get("optional_efficiency", 0.0)) > 0.0 and bool(timer_use.get("fired", false)):
			var timer_items: Dictionary = (frame.get("items", {}) as Dictionary).duplicate(true)
			for booster_stack in _mend_projector_booster_stacks_for_block(block_id):
				var booster_entry: Dictionary = booster_stack if booster_stack is Dictionary else {}
				var booster_removed: Dictionary = source_drill_inventory_state.remove_item_state(timer_items, str(booster_entry.get("item", "")), int(booster_entry.get("amount", 0)))
				timer_items = booster_removed.get(source_drill_inventory_state.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, timer_items)
			frame["items"] = timer_items
			frame["timer_use_elapsed"] = 0.0
		var scan_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		var scan_block_size: int = int(block.properties.get("size", 1))
		var scan_block_offset: float = float((scan_block_size + 1) % 2) * source_world_defaults.TILESIZE / 2.0
		var scan_building_x: float = source_block_geometry.tile_drawx_state(scan_cell.x, source_world_defaults.TILESIZE, scan_block_offset)
		var scan_building_y: float = source_block_geometry.tile_drawy_state(scan_cell.y, source_world_defaults.TILESIZE, scan_block_offset)
		var scan_range: float = float(block.properties.get("range", 60.0))
		var scan_phase_range_boost: float = float(block.properties.get("phaseRangeBoost", 50.0))
		var scan_real_range: float = scan_range + float(frame.get("phase_heat", 0.0)) * scan_phase_range_boost
		var scan_candidates: Array = []
		var frame_heal_candidates: Variant = frame.get("heal_candidates", [])
		if frame_heal_candidates is Array:
			scan_candidates = frame_heal_candidates
		var ranged_candidates: Dictionary = source_mend_projector_supplied_heal_candidates_state(scan_candidates, scan_real_range, scan_building_x, scan_building_y)
		var narrowed_candidates: Dictionary = source_mend_projector_supplied_heal_candidates_narrow_state(ranged_candidates.get("candidates", []), scan_real_range, scan_building_x, scan_building_y)
		var heal_scan: Dictionary = source_mend_projector_heal_scan_state(frame, narrowed_candidates.get("candidates", []), charge_before, reload_value, scan_range, float(block.properties.get("healPercent", 12.0)), float(block.properties.get("phaseBoost", 12.0)), scan_phase_range_boost, time_delta, time_scale)
		frame["last_heal_scan"] = heal_scan
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
