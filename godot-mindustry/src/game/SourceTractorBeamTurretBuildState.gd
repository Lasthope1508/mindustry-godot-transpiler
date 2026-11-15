extends RefCounted
class_name SourceTractorBeamTurretBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

# The TractorBeamTurret implementation (TractorBeamTurret.java:19,
# `public class TractorBeamTurret extends BaseTurret{`): parallax
# (consumePower 3.3f, size 2, range 300f, force 16f, scaledForce 9f, damage 0.5f,
# rotateSpeed 12, hasPower true). The only TractorBeamTurret block
# in the game (Blocks.java:3640-3653). TractorBeamBuild extends
# BaseTurretBuild, NOT TurretBuild, so the turret driver
# (SourceTurretBuildState.gd) explicitly excludes it and no driver
# ticks it at all: it would rotate and pull as if power.status
# were 1.0. This driver is the tractor-beam tick. The driver uses
# its own family frame key ("source_tractor_beam_turret_building",
# the turret precedent); the generic turret frame
# ("source_turret_building") stays untouched, and this slice adds
# the tractor-beam key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it.
const SOURCE_TRACTOR_BEAM_TURRET_BUILD_IMPLEMENTATIONS := ["TractorBeamTurret"]
const SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY := "source_tractor_beam_turret_building"
# Per-def parallax values (Blocks.java:3640-3653, the only def):
# `force = 16f;` / `scaledForce = 9f;` / `range = 300f;` /
# `damage = 0.5f;` / `rotateSpeed = 12;` -- the DEF wins over the
# class defaults (`public float force = 0.3f;` /
# `public float scaledForce = 0f;` /
# `public float damage = 0f;` / `rotateSpeed = 10f;`,
# TractorBeamTurret.java:26-28, 46; `public float range = 80f;`,
# BaseTurret.java:21). The catalog carries neither force nor
# scaledForce nor damage for this family, so the driver reads
# these constants (the Separator craftTime precedent).
const SOURCE_TRACTOR_BEAM_FORCE := 16.0
const SOURCE_TRACTOR_BEAM_SCALED_FORCE := 9.0
const SOURCE_TRACTOR_BEAM_RANGE := 300.0
const SOURCE_TRACTOR_BEAM_DAMAGE := 0.5
const SOURCE_TRACTOR_BEAM_ROTATE_SPEED := 12.0
# The class values (TractorBeamTurret.java:21, 23, 29):
# `public float retargetTime = 5f;` /
# `public float shootCone = 6f;` /
# `public boolean targetAir = true, targetGround = false;` --
# parallax only targets FLYING units. The rotation field
# default (`public float rotation = 90;`, BaseTurret.java:114),
# the strength lerp progress (TractorBeamTurret.java:120, 135,
# `0.1f`), and the look-at efficiency floor
# (TractorBeamTurret.java:111, `efficiency > 0.02f`).
const SOURCE_TRACTOR_BEAM_SHOOT_CONE := 6.0
# The retarget cadence (TractorBeamTurret.java:21,
# `public float retargetTime = 5f;`, read by the timer call
# `if(timer(timerTarget, retargetTime)){`,
# TractorBeamTurret.java:87): the frame-local Interval
# (N2317) fires every 5 ticks; parallax does not override
# retargetTime (Blocks.java:3640-3653), so the class value
# is the only one. Java passes the duration straight to
# timer() -- NO timeScale division (the N2290 lesson).
const SOURCE_TRACTOR_BEAM_TURRET_RETARGET_DURATION := 5.0
const SOURCE_TRACTOR_BEAM_ROTATION_DEFAULT := 90.0
const SOURCE_TRACTOR_BEAM_STRENGTH_LERP_PROGRESS := 0.1
const SOURCE_TRACTOR_BEAM_EFFICIENCY_MIN := 0.02
const SOURCE_TRACTOR_BEAM_TARGET_AIR := true
const SOURCE_TRACTOR_BEAM_TARGET_GROUND := false

static func _is_tractor_beam_turret_build_implementation(implementation: String) -> bool:
	return SOURCE_TRACTOR_BEAM_TURRET_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_tractor_beam_turret_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, building_x: float, building_y: float, team_id: int, candidates: Array, retarget_tick: bool, coolant_present: bool, coolant_amount: float, liquid_amount: float, liquid_heat_capacity: float, block_damage_multiplier: float, status_present: bool) -> Dictionary:
	# The updateTile advance (TractorBeamBuild.updateTile(), TractorBeamTurret.java:78-139), the pure frame advance -- the build fields are `public @Nullable Unit target;` (TractorBeamTurret.java:72), `public float lastX, lastY, strength;` (TractorBeamTurret.java:73), `public boolean any;` (TractorBeamTurret.java:74) and `public float coolantMultiplier = 1f;` (TractorBeamTurret.java:75), plus `public float rotation = 90;` (BaseTurret.java:114) and `public float activationTimer = 0;` (BaseTurret.java:115), and the advance follows the Java lines in order (each exact expr on ONE comment line, the N2148 lesson):
	# `if(activationTimer > 0){`
	# `activationTimer -= Time.delta;`
	# `float eff = efficiency * coolantMultiplier, edelta = eff * delta();`
	# `if(timer(timerTarget, retargetTime)){`
	# `target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));`
	# `if(target != null && coolant != null){`
	# `float maxUsed = coolant.amount;`
	# `Liquid liquid = liquids.current();`
	# `float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));`
	# `liquids.remove(liquid, used);`
	# `coolantMultiplier = 1f + (used * liquid.heatCapacity * coolantMultiplier);`
	# `any = false;`
	# `if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){`
	# `float dest = angleTo(target);`
	# `rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);`
	# `lastX = target.x;`
	# `lastY = target.y;`
	# `strength = Mathf.lerpDelta(strength, 1f, 0.1f);`
	# `if(Angles.within(rotation, dest, shootCone)){`
	# `target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));`
	# `if(status != StatusEffects.none){`
	# `target.apply(status, statusDuration);`
	# `any = true;`
	# `target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));`
	# `strength = Mathf.lerpDelta(strength, 0, 0.1f);`
	# The Arc formulas, not guesses: lerpDelta is `return lerp(fromValue, toValue, clamp(progress * Time.delta));` (Mathf.java:430-432), within is `return angleDist(a, b) <= margin;` (Angles.java:19-21), angle is atan2 in degrees (Angles.java:56-60), Vec2.limit is `return limit2(limit * limit);` (Vec2.java:274-276) clamping the length to AT MOST the limit (Vec2.java:279-285), within is a STRICT dst2 < dst^2 (`return Mathf.dst2(getX(), getY(), x, y) < dst*dst;`, Position.java:44-46), and angleTo is Angles.angle (Position.java:12-14). delta() is `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) and edelta() is `return efficiency * delta();` (BuildingComp.java:1927-1929). NOTE the eff ordering trap: Java computes eff/edelta at :84 BEFORE the coolant branch (:92-106) updates coolantMultiplier, so this tick's rotation / damage / impulse use the INCOMING multiplier and the new multiplier only affects the next tick. NOTE the coolant reset: there is no separate reset of the build coolantMultiplier anywhere in core/src (grep) -- the :105 formula itself yields 1f when used is 0, and the branch only runs when the target is non-null and coolant is present; with no target the multiplier persists. The block-level coolantMultiplier (BaseTurret.java:32, 5f; TractorBeamTurret ctor :46, 1f) is a DIFFERENT field, read by ReloadTurret.updateCooling, not by TractorBeamBuild. The retarget IS ported as a pure selection: Units.closestEnemy (Units.java:296-313) returns null for a derelict team (`if(team == Team.derelict) return null;`), filters dead / predicate / derelict-team / !targetable / inFogTo, computes `float dst2 = e.dst2(x, y) - (e.hitSize * e.hitSize);`, and accepts when `if(dst2 < range*range && (result == null || dst2 < cdist || e.type.targetPriority > cpriority) && e.type.targetPriority >= cpriority){` -- a higher priority wins even when farther; equal priority needs strictly closer (first wins ties). checkTarget is `return (isGrounded() && targetGround) || (isFlying() && targetAir);` (UnitComp.java:74-76); parallax has targetAir true / targetGround false, so only FLYING units qualify. The candidate list IS the nearbyEnemies rect-scan result by contract (enemy-only, so there is no same-team check in closestEnemy -- the look-at guard's target.team() != team is a separate check). The TIMER CADENCE is live since N2317 (source_tractor_beam_turret_retarget_timer_state, the frame-local Interval-equivalent, 5f): the driver wires the live retarget_tick into the advance every tick, and the frame-input unit_candidates ride in with it; retarget_tick false leaves the target untouched even with candidates, and retarget_tick true with an empty list overwrites the target to null exactly like Java's unconditional assignment (unlike N2226, which used an empty candidate list as the no-fire signal). The LIVE unit query still defers -- no live Units scan exists in the port, so unit_candidates is a frame input and a live parallax with no supplied candidates never acquires a target on its own. A candidate without a team defaults to derelict (the port's missing-team default) and is skipped; a candidate without target_priority defaults to 0f (`targetPriority = 0f,`, UnitType.java:129). The damage / status / impulse are PURE RESULTS: damage_dealt = damage * eff * timeScale * blockDamage(team) with `return blockDamageMultiplier * teams.get(team).blockDamageMultiplier;` (Rules.java:299-301, both default 1f); the APPLICATION (damageContinuousPierce / impulseNet / apply writing into another unit) defers -- the port has no live unit frames. The impulse vector runs FROM the target TOWARD the building (set(this).sub(target)) and Vec2.limit clamps its length, it does not set it. The activation early return skips EVERYTHING below it -- including the `any = false;` reset -- so any keeps its previous frame value on that path. The old generated per-line modules (SourceTractorBeamTurretBuildUpdateTile*State.gd) are NOT used here: they are only reachable through the PortBridge/FlowPortBridge instance-method chain (never called from live game code -- PortGame.gd has zero tractor references) and the old module proofs, so they are dead for live gameplay; this pure advance is the live one.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var target: Variant = frame.get("target", null)
	var activation_timer: float = float(frame.get("activation_timer", 0.0))
	var coolant_multiplier: float = float(frame.get("coolant_multiplier", 1.0))
	var rotation: float = float(frame.get("rotation", SOURCE_TRACTOR_BEAM_ROTATION_DEFAULT))
	var strength: float = float(frame.get("strength", 0.0))
	var last_x: float = float(frame.get("last_x", 0.0))
	var last_y: float = float(frame.get("last_y", 0.0))
	var any: bool = bool(frame.get("any", false))
	if activation_timer > 0.0:
		activation_timer -= source_delta
		return {"target": target, "activation_timer": activation_timer, "coolant_multiplier": coolant_multiplier, "coolant_used": 0.0, "rotation": rotation, "strength": strength, "last_target_position": {"x": last_x, "y": last_y}, "damage_dealt": 0.0, "status_applied": false, "impulse": {"x": 0.0, "y": 0.0}, "any": any}
	var eff: float = efficiency * coolant_multiplier
	var edelta: float = eff * source_delta * time_scale
	if retarget_tick:
		var best: Variant = null
		if team_id != source_block_geometry.SOURCE_TEAM_DERELICT_ID:
			var best_dst2: float = 0.0
			var best_priority: float = -99999.0
			for candidate in candidates:
				if not (candidate is Dictionary):
					continue
				if bool(candidate.get("dead", false)):
					continue
				var candidate_flying: bool = bool(candidate.get("flying", false))
				var candidate_grounded: bool = bool(candidate.get("grounded", false))
				if not ((candidate_grounded and SOURCE_TRACTOR_BEAM_TARGET_GROUND) or (candidate_flying and SOURCE_TRACTOR_BEAM_TARGET_AIR)):
					continue
				if int(candidate.get("team", source_block_geometry.SOURCE_TEAM_DERELICT_ID)) == source_block_geometry.SOURCE_TEAM_DERELICT_ID:
					continue
				if not bool(candidate.get("targetable", true)):
					continue
				if bool(candidate.get("in_fog", false)):
					continue
				var candidate_dx: float = float(candidate.get("x", 0.0)) - building_x
				var candidate_dy: float = float(candidate.get("y", 0.0)) - building_y
				var candidate_hit_size: float = float(candidate.get("hit_size", 0.0))
				var candidate_dst2: float = candidate_dx * candidate_dx + candidate_dy * candidate_dy - candidate_hit_size * candidate_hit_size
				var candidate_priority: float = float(candidate.get("target_priority", 0.0))
				if candidate_dst2 < SOURCE_TRACTOR_BEAM_RANGE * SOURCE_TRACTOR_BEAM_RANGE and (best == null or candidate_dst2 < best_dst2 or candidate_priority > best_priority) and candidate_priority >= best_priority:
					best = candidate
					best_dst2 = candidate_dst2
					best_priority = candidate_priority
		target = best
	var coolant_used: float = 0.0
	if target != null and coolant_present:
		var max_used: float = coolant_amount
		var heat_capacity_cap: float = maxf(0.0, (1.0 / coolant_multiplier) / liquid_heat_capacity)
		var used: float = minf(minf(liquid_amount, max_used * source_delta), heat_capacity_cap)
		coolant_used = used
		coolant_multiplier = 1.0 + (used * liquid_heat_capacity * coolant_multiplier)
	any = false
	var damage_dealt: float = 0.0
	var status_applied: bool = false
	var impulse: Dictionary = {"x": 0.0, "y": 0.0}
	var look_at_target: bool = false
	if target != null and target is Dictionary:
		var target_dx: float = float(target.get("x", 0.0)) - building_x
		var target_dy: float = float(target.get("y", 0.0)) - building_y
		var target_dst2: float = target_dx * target_dx + target_dy * target_dy
		var target_hit_size: float = float(target.get("hit_size", 0.0))
		var target_reach: float = SOURCE_TRACTOR_BEAM_RANGE + target_hit_size / 2.0
		var target_within: bool = target_dst2 < target_reach * target_reach
		var target_enemy: bool = int(target.get("team", source_block_geometry.SOURCE_TEAM_DERELICT_ID)) != team_id
		var target_flying: bool = bool(target.get("flying", false))
		var target_grounded: bool = bool(target.get("grounded", false))
		var target_check: bool = (target_grounded and SOURCE_TRACTOR_BEAM_TARGET_GROUND) or (target_flying and SOURCE_TRACTOR_BEAM_TARGET_AIR)
		look_at_target = target_within and target_enemy and target_check and efficiency > SOURCE_TRACTOR_BEAM_EFFICIENCY_MIN
	if look_at_target:
		var dest: float = source_math_state.source_angles_angle(building_x, building_y, float(target.get("x", 0.0)), float(target.get("y", 0.0)))
		rotation = source_math_state.source_angles_move_toward(rotation, dest, SOURCE_TRACTOR_BEAM_ROTATE_SPEED * edelta)
		last_x = float(target.get("x", 0.0))
		last_y = float(target.get("y", 0.0))
		strength = source_math_state.source_lerp_delta(strength, 1.0, SOURCE_TRACTOR_BEAM_STRENGTH_LERP_PROGRESS, source_delta)
		if source_math_state.source_angles_within(rotation, dest, SOURCE_TRACTOR_BEAM_SHOOT_CONE):
			if SOURCE_TRACTOR_BEAM_DAMAGE > 0.0:
				damage_dealt = SOURCE_TRACTOR_BEAM_DAMAGE * eff * time_scale * block_damage_multiplier
			if status_present:
				status_applied = true
			any = true
			var target_dst: float = source_math_state.source_dst(building_x, building_y, float(target.get("x", 0.0)), float(target.get("y", 0.0)))
			var impulse_limit: float = (SOURCE_TRACTOR_BEAM_FORCE + (1.0 - target_dst / SOURCE_TRACTOR_BEAM_RANGE) * SOURCE_TRACTOR_BEAM_SCALED_FORCE) * edelta
			var limited: Dictionary = source_math_state.source_vec2_limit({"x": building_x - float(target.get("x", 0.0)), "y": building_y - float(target.get("y", 0.0))}, impulse_limit)
			impulse = {"x": float(limited.get("x", 0.0)), "y": float(limited.get("y", 0.0))}
	else:
		strength = source_math_state.source_lerp_delta(strength, 0.0, SOURCE_TRACTOR_BEAM_STRENGTH_LERP_PROGRESS, source_delta)
	return {"target": target, "activation_timer": activation_timer, "coolant_multiplier": coolant_multiplier, "coolant_used": coolant_used, "rotation": rotation, "strength": strength, "last_target_position": {"x": last_x, "y": last_y}, "damage_dealt": damage_dealt, "status_applied": status_applied, "impulse": impulse, "any": any}

static func source_tractor_beam_turret_retarget_timer_state(elapsed: float, source_delta: float, time_scale: float, duration: float) -> Dictionary:
	# The frame-local Interval-equivalent for the retarget
	# cadence (TimerComp.timer, TimerComp.java:10-13, each
	# exact expr on ONE comment line, the N2148 lesson):
	# `if(Float.isInfinite(time)) return false;`
	# `return timer.get(index, time);`
	# Interval.get resets times[id] = Time.time on fire
	# (arc Interval.java:20-26):
	# `boolean got = check(id, time);`
	# `if(got) times[id] = Time.time;`
	# and check compares Time.time - times[id] >= time (arc
	# Interval.java:28-30):
	# `return Time.time - times[id] >= time || Time.time < times[id];`
	# Time.time counts TICKS (arc Time.java:69-80):
	# `timeRaw += delta;`
	# The port has no global tick clock at the driver layer, so
	# the elapsed clock is frame-local (frame["timer_retarget_
	# elapsed"], accumulated by the tick delta every tick the
	# advance runs, unconditionally -- mirroring Time.time,
	# which grows even while the gate is closed): elapsed +=
	# source_delta unconditionally (source_delta is the
	# UNSCALED Time.delta in ticks -- game_source_delta is
	# seconds * 60, never scaled by timeScale -- so the
	# frame clock mirrors the global Time.time exactly);
	# retarget_tick = elapsed >= duration (the LITERAL
	# duration, no timeScale division -- the N2290 lesson);
	# timer_elapsed_after RESETS to 0.0 on fire (a reset, not
	# a subtraction like the Fracker accumulator); a
	# non-positive time_scale is a defensive guard
	# (retarget_tick false -- see below). The Java call is
	# (TractorBeamTurret.java:87-88):
	# `if(timer(timerTarget, retargetTime)){`
	# `target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));`
	# with `public final int timerTarget = timers++;`
	# (TractorBeamTurret.java:20) and `public float retargetTime = 5f;`
	# (TractorBeamTurret.java:21) on `public class TractorBeamTurret extends BaseTurret{`
	# (TractorBeamTurret.java:19). Java passes retargetTime
	# STRAIGHT to timer() -- no timeScale division, unlike
	# the MendProjector (`timer(timerUse, useTime /
	# timeScale)`, MendProjector.java:102) / WallCrafter /
	# ImpactReactor timers -- so Java retargets every 5
	# global ticks whatever the building timeScale is, and
	# the port threshold is the literal duration. time_scale
	# stays a parameter (signature stability -- the contract,
	# call sites, and tests keep it) and is still read: a
	# non-positive time_scale never fires, a defensive port
	# guard for a corrupt frame input -- Java timeScale is
	# always positive in practice (the default,
	# BuildingComp.java:98, is
	# `private transient float timeScale = 1f, timeScaleDuration;`;
	# applyBoost / applySlowdown take positive intensities,
	# BuildingComp.java:461-478; decay resets it to 1f,
	# BuildingComp.java:2265-2266), so the guard is
	# unreachable in Java-exact play and the threshold is
	# Java-exact at every reachable time_scale. Note the
	# clock still ACCUMULATES at time_scale 0 (source_delta
	# is unscaled) -- only the fire is guarded. The timer
	# runs in the driver BEFORE the advance call, so the
	# activation early return (TractorBeamTurret.java:79-82)
	# does not stop the clock -- and that matches Java: the
	# global Time.time keeps growing during activation, so
	# Java's timer fires on the first check after activation
	# ends (times[id] is stale); the port's accumulated
	# elapsed fires on the first tick after activation ends
	# the same way. Documented deviation (first
	# fire): Java fires (nearly) immediately after placement
	# (the global Time.time is already large vs a fresh
	# Interval times[id] = 0); the frame-local clock delays
	# the first fire by a full interval (5 ticks). It cannot
	# be fixed without a global clock -- it waits for a
	# timer-infra slice if exact first-fire timing is ever
	# needed.
	var threshold: float = INF if time_scale <= 0.0 else duration
	var accumulated: float = elapsed + source_delta
	var retarget_tick: bool = accumulated >= threshold
	var timer_elapsed_after: float = 0.0 if retarget_tick else accumulated
	return {"retarget_tick": retarget_tick, "timer_elapsed_after": timer_elapsed_after}

static func source_tractor_beam_turret_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The tractor-beam tick wires the frame keys the consumption
	# path reads (the N2148 turret pattern): block_implementation
	# is the block's implementation (TractorBeamTurret.java:19,
	# `public class TractorBeamTurret extends BaseTurret{`),
	# team_id and rules_state are what Java reads as b.team and
	# state.rules, and cheating is the team's live TeamRule value
	# (TeamComp.cheating(), TeamComp.java:17-19 `return team.rules().cheat;`,
	# read through N2099's helper), so a cheating team's parallax
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
	# for this parallax (N2125); the tick preserves a disabled
	# parallax instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {"target": null}

static func source_tractor_beam_turret_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the tractor-beam frame meta key
	# ("source_tractor_beam_turret_building"). A TractorBeamTurret
	# sprite gets a frame bound with the target key defaulting to
	# null (the Java field `public @Nullable Unit target;`,
	# TractorBeamTurret.java:72, defaults to null); the live-loop
	# tick fills its other keys every tick. Any other block, or an
	# already-bound sprite, binds nothing.
	if block == null or not _is_tractor_beam_turret_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_tractor_beam_turret_should_consume_state(frame: Dictionary) -> Dictionary:
	# TractorBeamBuild overrides shouldConsume (TractorBeamTurret.java:141, `public boolean shouldConsume(){` with `return super.shouldConsume() && target != null;`, TractorBeamTurret.java:142): the gate reads the live target AND the super default. The super is the BuildingComp default (`return enabled;`, BuildingComp.java:755-756): the chain is TractorBeamBuild (TractorBeamTurret.java:71, `public class TractorBeamBuild extends BaseTurretBuild{`) -> BaseTurretBuild (BaseTurret.java:113, `public class BaseTurretBuild extends Building implements Ranged, RotBlock{`) -> Building; BaseTurret.java does NOT override shouldConsume (grep 0 matches), so the default applies. Turret.TurretBuild.shouldConsume() (Turret.java:364, `return isShooting || reloadCounter < reload;`) is NOT in this chain -- the tractor beam extends BaseTurret (`public class TractorBeamTurret extends BaseTurret{`, TractorBeamTurret.java:19), NOT Turret. The field is `public @Nullable Unit target;` (TractorBeamTurret.java:72) -- the target is a UNIT. The gate reads frame["enabled"] internal (the super default, the N2212 RepairTurret precedent): target (frame["target"], default null for a frame bound before this slice -- the Java field default) and enabled (frame["enabled"], default true -- BuildingComp.java:77, `transient boolean enabled = true;`); no live fill sets frame["target"] yet -- the live retarget (Units.closestEnemy, TractorBeamTurret.java:88, `target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));`, every retargetTime 5f, TractorBeamTurret.java:21, 87) is the updateTile advance (TractorBeamTurret.java:78-139): N2230 ports the retarget / coolant / rotation / strength / damage / impulse advance as a pure function and the timer cadence is live since N2317 (the frame-local Interval, 5f, retarget_tick wired into the advance; candidates ride frame["unit_candidates"], default []), but the live unit query waits for the live-fill slice, so no live fill sets frame["target"] yet without supplied candidates. When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The rotation and pull follow the folded efficiency through eff/edelta (TractorBeamTurret.java:84, `float eff = efficiency * coolantMultiplier, edelta = eff * delta();`, TractorBeamTurret.java:117, `rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);`). The only def is parallax (size 2, `range = 300f;`, `consumePower(3.3f);`, Blocks.java:3640-3653). The shouldConsume gate is live (N2218).
	var target: Variant = frame.get("target", null)
	var enabled: bool = bool(frame.get("enabled", true))
	return {"should_consume": target != null and enabled, "has_target": target != null}

static func source_tractor_beam_turret_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
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
	# so a parallax does not take the early return. The
	# tractor-beam rotation and pull follow the folded
	# efficiency through eff/edelta (BuildingComp.java:1928, `return efficiency * delta();`,
	# TractorBeamTurret.java:84, `float eff = efficiency * coolantMultiplier, edelta = eff * delta();`,
	# TractorBeamTurret.java:117, `rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);`).
	# Documented limits: (1) power-only first pass -- parallax
	# has no other consumers; the folded efficiency is the min
	# over the *modeled* consumers (power only). (2)
	# shouldConsume gate live (N2218) --
	# TractorBeamBuild.shouldConsume()
	# (TractorBeamTurret.java:141-143, `return super.shouldConsume() && target != null;`)
	# reads the live unit target (frame["target"], default null)
	# plus enabled (the BuildingComp super default); when the
	# gate is false Java forces efficiency to 0
	# (BuildingComp.java:1960 + 1992-1994); the pure gate reads
	# the frame target key plus enabled and feeds should_consume
	# to the machinery; no live fill sets frame["target"] yet
	# without supplied candidates (N2230: the retarget /
	# coolant / rotation / strength / damage / impulse
	# advance is live as a pure function; the timer cadence
	# is live since N2317, the live unit query waits for the
	# live-fill slice). (3) updateTile advance live (N2230)
	# -- the activation early return / retarget / coolant
	# consume / rotation / strength / damage / status /
	# impulse (TractorBeamTurret.java:78-139) run on the
	# frame; the timer cadence live (N2317) -- the
	# frame-local Interval (5f, retarget_tick wired into the
	# advance; candidates ride frame["unit_candidates"],
	# default []); the damage / impulse / status application
	# (no live unit frames), the live unit query (no live
	# Units scan exists in the port), the coolant live fill
	# (coolant is null for parallax), and the sound loop /
	# laser draw wait for the live-fill slice.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_tractor_beam_turret_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the tractor-beam tick wiring every tick
	# (TractorBeamBuild.updateTile(), TractorBeamTurret.java:78,
	# reads the folded efficiency for its rotation and pull; the
	# turret driver never ticks TractorBeamTurret implementations,
	# so this driver is the tractor-beam tick): each placed
	# TractorBeamTurret build gets its frame keys refreshed from
	# the live rules, so the frame's cheating flag tracks
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
		if not _is_tractor_beam_turret_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_tractor_beam_turret_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_tractor_beam_turret_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2152 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a parallax with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the eff/edelta fold (TractorBeamTurret.java:84, 117)
		# follows it. The power consumer counts toward hasConsumers
		# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
		# so a parallax does not take the early return. A parallax
		# with no power consumer is untouched: the tick models no
		# other consumers yet, and TractorBeamBuild overrides
		# shouldConsume (TractorBeamTurret.java:141, `public boolean shouldConsume(){`
		# with `return super.shouldConsume() && target != null;`, TractorBeamTurret.java:142)
		# -- N2218 feeds the live gate to the machinery (the pure
		# gate is source_tractor_beam_turret_should_consume_state,
		# fed the frame); the N2152 RED decision is resolved. The
		# gate's super term is the BuildingComp default (`return
		# enabled;`, BuildingComp.java:755-756), so the pure gate
		# reads frame["enabled"] too (the N2212 RepairTurret
		# precedent); the outer guard below already runs the
		# machinery only when enabled. productionValid is the
		# canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_tractor_beam_turret_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_tractor_beam_turret_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# N2230: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, `public boolean noUpdateDisabled = false;`
		# (Block.java:170), so Java runs updateTile even when
		# disabled -- in Java a disabled parallax's strength
		# DECAYS toward 0 (efficiency is zeroed by the
		# disabled early return, BuildingComp.java:1954-1957)
		# and the rotation freezes (the look-at branch needs
		# efficiency > 0.02f, TractorBeamTurret.java:111). The
		# port keeps the enabled gate below as a pragmatic
		# choice (the N2195 coordinator-fix precedent): the
		# driver skips the consumption fold when disabled, so
		# the frame efficiency goes stale and running the
		# advance on it would rotate/pull from a stale
		# efficiency. The driver-wide disabled-early-return
		# slice (deferred in the N2230 register) removes this
		# gate for all families. super.updateTile() is an empty
		# no-op (BuildingComp.java:2010-2012), so the driver
		# owes it nothing. The source delta is Time.delta in
		# ticks: game_source_delta(game, seconds) is seconds *
		# 60 (arc Time.java:26), never raw seconds. timeScale
		# reads live from the sprite meta, default 1.0
		# (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`). The building
		# position comes from the origin cell: Building x/y
		# are tile.drawx()/drawy() (BuildingComp.java:124,
		# `set(tile.drawx(), tile.drawy());`), drawx is
		# block.offset + tile.worldx() (Tile.java:175-176) with
		# the block offset `offset = ((size + 1) % 2) * tilesize / 2f;`
		# (Block.java:761) -- 4 for the size-2 parallax. N2317:
		# the retarget cadence is live -- the frame-local
		# Interval (5f, source_tractor_beam_turret_retarget_
		# timer_state) runs before the advance call and its
		# retarget_tick reaches the advance with the
		# frame-input unit_candidates; a fire with an empty
		# list clears the target, exactly like Java's
		# unconditional assignment (TractorBeamTurret.java:
		# 88). No live unit query exists in the port yet, so
		# unit_candidates is a frame input (default []) and
		# the live Units scan waits for its own slice. The
		# clock runs only while enabled (the same pragmatic
		# gate as the advance itself -- Java runs updateTile
		# even when disabled, BuildingComp.java:2276-2277);
		# the driver-wide disabled-early-return slice removes
		# this gate for all families. First-fire deviation:
		# Java fires nearly at once after placement; the frame
		# clock delays the first fire by a full interval
		# (5 ticks). The coolant inputs are all default
		# no-op (parallax has no ConsumeCoolant consumer, so
		# coolant is null); blockDamage is the 1.0 default
		# (Rules.java:113/:367, no rules helper reads it in
		# the port); status is none for parallax, so
		# status_present is false.
		if bool(frame.get("enabled", true)):
			var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
			var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
			var advance_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
			var advance_block_size: int = int(block.properties.get("size", 1))
			var advance_block_offset: float = float((advance_block_size + 1) % 2) * source_world_defaults.TILESIZE / 2.0
			var advance_building_x: float = source_block_geometry.tile_drawx_state(advance_cell.x, source_world_defaults.TILESIZE, advance_block_offset)
			var advance_building_y: float = source_block_geometry.tile_drawy_state(advance_cell.y, source_world_defaults.TILESIZE, advance_block_offset)
			# N2317: the retarget cadence (TractorBeamTurret.
			# java:87-88, `if(timer(timerTarget, retargetTime)){`
			# / `target = Units.closestEnemy(team, x, y, range,
			# u -> u.checkTarget(targetAir, targetGround));`) --
			# the frame-local clock (frame["timer_retarget_
			# elapsed"]) accumulates the tick delta every tick
			# the advance runs, and when it fires the live
			# retarget_tick plus the frame-input unit_candidates
			# reach the advance; when it does not fire the
			# advance sees retarget_tick false as before. The
			# timer runs BEFORE the advance call, so the
			# activation early return does not stop the clock
			# (and that matches Java: the global Time.time
			# keeps growing during activation). Live unit
			# frames do not exist in the port, so
			# unit_candidates is a frame input (seeded by the
			# proof; the live Units scan waits for its own
			# slice).
			var retarget_timer: Dictionary = source_tractor_beam_turret_retarget_timer_state(float(frame.get("timer_retarget_elapsed", 0.0)), source_delta, time_scale, SOURCE_TRACTOR_BEAM_TURRET_RETARGET_DURATION)
			frame["timer_retarget_elapsed"] = retarget_timer.get("timer_elapsed_after", 0.0)
			var retarget_tick: bool = bool(retarget_timer.get("retarget_tick", false))
			var retarget_candidates: Array = []
			var frame_unit_candidates: Variant = frame.get("unit_candidates", [])
			if frame_unit_candidates is Array:
				retarget_candidates = frame_unit_candidates
			var advanced: Dictionary = source_tractor_beam_turret_update_tile_advance_state(frame, source_delta, time_scale, advance_building_x, advance_building_y, team_id, retarget_candidates, retarget_tick, false, 0.0, 0.0, 0.0, 1.0, false)
			frame["target"] = advanced["target"]
			frame["activation_timer"] = advanced["activation_timer"]
			frame["coolant_multiplier"] = advanced["coolant_multiplier"]
			frame["coolant_used"] = advanced["coolant_used"]
			frame["rotation"] = advanced["rotation"]
			frame["strength"] = advanced["strength"]
			var advanced_last: Dictionary = advanced.get("last_target_position", {})
			frame["last_x"] = float(advanced_last.get("x", 0.0))
			frame["last_y"] = float(advanced_last.get("y", 0.0))
			frame["damage_dealt"] = advanced["damage_dealt"]
			frame["status_applied"] = advanced["status_applied"]
			frame["impulse"] = advanced["impulse"]
			frame["any"] = advanced["any"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
