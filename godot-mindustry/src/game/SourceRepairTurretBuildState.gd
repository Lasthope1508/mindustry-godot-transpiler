extends RefCounted
class_name SourceRepairTurretBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

# The RepairTurret implementation (RepairTurret.java:25, `public class RepairTurret extends Block{`): repair-point (powerUse 1f, Blocks.java:6391, `powerUse = 1f;`; repairSpeed 0.45f, repairRadius 60f, Blocks.java:6388-6389) and repair-turret (powerUse 5f, Blocks.java:6402, `powerUse = 5f;`; size 2, repairSpeed 3f, repairRadius 145f, Blocks.java:6398-6401). RepairTurret extends Block, NOT a factory or crafter, so no existing driver matches it and no frame key exists for it; this driver uses its own family frame key ("source_repair_turret_building", the radar precedent), and this slice adds the repair-turret key to N2142's SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back finds it. The port has NO SourceRepairTurret* files at all yet -- no display/runtime state to lean on -- so the missing piece is the live power.status -> efficiency driver, which is exactly this slice: the updateTile heal advance (RepairTurret.java:207, `target.heal(repairSpeed * strength * edelta() * multiplier);`) heals by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a repair turret with no power would never heal -- its target's health would sit frozen as if power.status were 1.0.
const SOURCE_REPAIR_TURRET_BUILD_IMPLEMENTATIONS := ["RepairTurret"]
const SOURCE_REPAIR_TURRET_BUILDING_META_KEY := "source_repair_turret_building"
# Per-def repair values (Blocks.java:6388-6389/:6400-6401):
# repair-point `repairSpeed = 0.45f;` / `repairRadius = 60f;`,
# repair-turret `repairSpeed = 3f;` / `repairRadius = 145f;`
# (class defaults `public float repairSpeed = 0.3f;` /
# `public float repairRadius = 50f;`, RepairTurret.java:32-33).
# The catalog carries neither for this family, so the driver
# reads these constants (the Separator craftTime precedent).
const SOURCE_REPAIR_POINT_REPAIR_SPEED := 0.45
const SOURCE_REPAIR_POINT_REPAIR_RADIUS := 60.0
const SOURCE_REPAIR_TURRET_REPAIR_SPEED := 3.0
const SOURCE_REPAIR_TURRET_REPAIR_RADIUS := 145.0
# The heal angle margin (RepairTurret.java:205,
# `if(Angles.angleDist(angle, rotation) < 30f){`), the rotation
# slerp progress (RepairTurret.java:209, `0.5f * efficiency *
# timeScale`), the strength lerp progress (RepairTurret.java:
# 212, `0.08f * Time.delta`), and the rotation field default
# (RepairTurret.java:156, `public float strength, rotation = 90;`).
const SOURCE_REPAIR_TURRET_HEAL_ANGLE_MARGIN := 30.0
const SOURCE_REPAIR_TURRET_ROTATION_SLERP_PROGRESS := 0.5
const SOURCE_REPAIR_TURRET_STRENGTH_LERP_PROGRESS := 0.08
const SOURCE_REPAIR_TURRET_ROTATION_DEFAULT := 90.0
# The coolant consumer (repair-turret only): `coolantUse =
# 0.16f;` / `coolantMultiplier = 1.6f;` / `acceptCoolant =
# true;` (Blocks.java:6405-6407); the class defaults are
# `public float coolantUse = 0.5f;` (RepairTurret.java:41) /
# `public float coolantMultiplier = 1f;` (RepairTurret.java:45)
# / `public boolean acceptCoolant = false;`
# (RepairTurret.java:39), so repair-point has NO coolant
# consumer. The filter bounds are `public float maxTemp =
# 0.5f, maxFlammability = 0.1f;` (ConsumeCoolant.java:5) with
# `public boolean allowLiquid = true, allowGas = false;`
# (ConsumeCoolant.java:6). The heat-capacity fallback is the
# Liquid class default `public float heatCapacity = 0.5f;`
# (Liquid.java:42) when the catalog carries no heatCapacity
# for the current liquid. The catalog carries none of the
# coolant defs for this family, so the driver reads these
# constants (the Separator craftTime precedent).
const SOURCE_REPAIR_TURRET_COOLANT_AMOUNT := 0.16
const SOURCE_REPAIR_TURRET_COOLANT_MULTIPLIER := 1.6
const SOURCE_REPAIR_TURRET_COOLANT_MAX_TEMP := 0.5
const SOURCE_REPAIR_TURRET_COOLANT_MAX_FLAMMABILITY := 0.1
const SOURCE_REPAIR_TURRET_LIQUID_HEAT_CAPACITY_DEFAULT := 0.5
# The timer-target interval (RepairTurret.java:214,
# `if(timer(timerTarget, 20)){`): the re-acquire check runs
# every 20 ticks (Time.time counts TICKS, arc Time.java:
# 69-80, `timeRaw += delta;`). The Java timer arg is a
# LITERAL 20 -- unlike the MendProjector / WallCrafter /
# ImpactReactor timers, it is NOT divided by timeScale --
# so the port threshold is the literal duration (N2290
# fix; the N2280 20/time_scale deviation is resolved) and
# Java-exact at every time_scale; see
# source_repair_turret_timer_target_state.
const SOURCE_REPAIR_TURRET_TIMER_TARGET_DURATION := 20.0

static func _is_repair_turret_build_implementation(implementation: String) -> bool:
	return SOURCE_REPAIR_TURRET_BUILD_IMPLEMENTATIONS.has(implementation)

static func _repair_speed_for_block(block_id: String) -> float:
	# repairSpeed is a per-def field (RepairTurret.java:33
	# `public float repairSpeed = 0.3f;`): repair-point 0.45f
	# (Blocks.java:6388, `repairSpeed = 0.45f;`), repair-turret
	# 3f (Blocks.java:6400, `repairSpeed = 3f;`). The catalog
	# carries no repairSpeed for this family, so the driver
	# reads these constants (the Separator craftTime
	# precedent); an unknown RepairTurret id falls back to
	# the repair-point def.
	if block_id == "repair-turret":
		return SOURCE_REPAIR_TURRET_REPAIR_SPEED
	return SOURCE_REPAIR_POINT_REPAIR_SPEED

static func _repair_radius_for_block(block_id: String) -> float:
	# repairRadius is a per-def field (RepairTurret.java:32
	# `public float repairRadius = 50f;`): repair-point 60f
	# (Blocks.java:6389, `repairRadius = 60f;`), repair-turret
	# 145f (Blocks.java:6401, `repairRadius = 145f;`). The
	# catalog carries no repairRadius for this family, so the
	# driver reads these constants (the Separator craftTime
	# precedent); an unknown RepairTurret id falls back to
	# the repair-point def.
	if block_id == "repair-turret":
		return SOURCE_REPAIR_TURRET_REPAIR_RADIUS
	return SOURCE_REPAIR_POINT_REPAIR_RADIUS

static func _repair_turret_slerp_delta(from_degrees: float, to_degrees: float, progress: float, source_delta: float) -> float:
	# Mathf.slerpDelta (Mathf.java:460-462, `public static float slerpDelta(float fromDegrees, float toDegrees, float progress){` with `return slerp(fromDegrees, toDegrees, clamp(progress * Time.delta));`): slerp is the angle lerp in degrees (Mathf.java:455-458, `public static float slerp(float fromDegrees, float toDegrees, float progress){` with `float delta = ((toDegrees - fromDegrees + 360 + 180) % 360) - 180;` and `return (fromDegrees + delta * progress + 360) % 360;`), so the wrapped delta picks the shortest way round the circle; clamp is [0, 1] (Mathf.java:402-404, `public static float clamp(float value){` with `return Math.max(Math.min(value, 1f), 0f);`). The port has no slerp helper, so the advance carries this local transliteration (the N2191 precedent -- no separate symbol); GDScript fmod matches Java % (sign of the dividend), so the wrap is exact. source_delta is Time.delta in ticks (seconds * 60 through game_source_delta, arc Time.java:26).
	var clamped: float = clampf(progress * source_delta, 0.0, 1.0)
	var delta: float = fmod(to_degrees - from_degrees + 360.0 + 180.0, 360.0) - 180.0
	return fmod(from_degrees + delta * clamped + 360.0, 360.0)

static func source_repair_turret_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, repair_speed: float, repair_radius: float, building_x: float, building_y: float, candidates: Array) -> Dictionary:
	# The updateTile advance (RepairPointBuild.updateTile(), RepairTurret.java:187-218), the pure frame advance -- the build fields are `public Unit target;` (RepairTurret.java:154), `public Vec2 offset = new Vec2(), lastEnd = new Vec2();` (RepairTurret.java:155) and `public float strength, rotation = 90;` (RepairTurret.java:156), and the advance follows the Java lines in order (each exact expr on ONE comment line, the N2148 lesson):
	# `float multiplier = 1f;`
	# `multiplier = 1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency;`
	# `if(target != null && (target.dead() || target.dst(this) - target.hitSize/2f > repairRadius || target.health() >= target.maxHealth())){`
	# `if(target == null){`
	# `offset.setZero();`
	# `boolean healed = false;`
	# `if(target != null && efficiency > 0){`
	# `float angle = Angles.angle(x, y, target.x + offset.x, target.y + offset.y);`
	# `if(Angles.angleDist(angle, rotation) < 30f){`
	# `target.heal(repairSpeed * strength * edelta() * multiplier);`
	# `rotation = Mathf.slerpDelta(rotation, angle, 0.5f * efficiency * timeScale);`
	# `strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);`
	# `if(timer(timerTarget, 20)){`
	# `target = Units.closest(team, x, y, repairRadius, Unit::damaged);`
	# The Arc formulas, not guesses: lerpDelta is `return lerp(fromValue, toValue, clamp(progress * Time.delta));` (Mathf.java:430-432), slerpDelta is `return slerp(fromDegrees, toDegrees, clamp(progress * Time.delta));` (Mathf.java:460-462) with the wrapped slerp (Mathf.java:455-458), angleDist is the shortest absolute arc (Angles.java:23-28), angle is atan2 in degrees (Angles.java:56-60). delta() is `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) and edelta() is `return efficiency * delta();` (BuildingComp.java:1927-1929). NOTE the strength trap: Java passes `0.08f * Time.delta` as the lerpDelta progress, and lerpDelta multiplies by Time.delta AGAIN -- the port passes 0.08 * source_delta as the progress to the shared lerp_delta helper, so the double delta is exact; the rotation slerp progress (0.5f * efficiency * timeScale) carries NO Time.delta in Java, and the local slerp helper multiplies once. The multiplier is LIVE since N2259: the acceptCoolant branch (RepairTurret.java:188-191, `float multiplier = 1f;` / `if(acceptCoolant){` / `multiplier = 1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency;`) reads frame["coolant_multiplier"], stamped by the tick from the FOLDED optionalEfficiency and the CURRENT liquid's heatCapacity (coolantMultiplier 1.6f, Blocks.java:6406); a frame without the key (bound before N2259, or a direct advance call) keeps the 1.0 default, and repair-point always stamps 1.0 (acceptCoolant=false, RepairTurret.java:39). The frame-key choice is deliberate: the N2226 test pins the advance call text, so the multiplier rides the frame instead of a new parameter. The target is a Dictionary of explicit inputs (the N2212 fixture precedent): dead, distance (the value of `target.dst(this) - target.hitSize/2f`, RepairTurret.java:193), health / max_health (the full-health branch fires only when BOTH are present -- a dict without health data is not known to be full), x / y (the angle), hit_size / damaged / valid (the re-acquire). The heal APPLICATION defers -- target.heal writes into another unit's health and the port has no live unit frames, so the advance returns heal_amount as a pure result. The re-acquire IS ported as a pure selection: Units.closest(team, x, y, range, Unit::damaged) (Units.java:358-372) iterates nearby (Units.java:445-451, `if(unit.within(x, y, radius + unit.hitSize/2f)){`), filters isValid + damaged (`return health < maxHealth - 0.001f;`, HealthComp.java:47-49), and picks min dst2 with strict < (first wins ties); within is a STRICT dst2 < (radius + hitSize/2)^2 (`return Mathf.dst2(getX(), getY(), x, y) < dst*dst;`, Position.java:44-46). Java overwrites the target UNCONDITIONALLY on a timer tick (RepairTurret.java:216), so a non-empty candidate list overwrites the frame target (even to null when no candidate qualifies); an EMPTY list AND an empty frame["unit_candidates"] key mean the timer did not fire and the target is untouched. The TIMER CADENCE is live since N2280 (source_repair_turret_timer_target_state, the frame-local Interval-equivalent, 20f): the tick stamps frame["unit_candidates"] with the frame-input candidates when the timer fires and [] when it does not, and the advance falls back to that key when its explicit list is empty (the coolant_multiplier frame-key precedent, N2259 -- the N2226 test pins the advance call text, so no new parameter); an explicit non-empty list still wins over the frame key. Live unit frames do not exist in the port, so unit_candidates is a frame input and the live Units scan waits for its own slice. lastEnd is only mutated by drawBeam (RepairTurret.java:106-150), never by updateTile, so it is not a frame key here.
	var efficiency: float = float(frame.get("efficiency", 0.0))
	var target: Variant = frame.get("target", null)
	var offset: Dictionary = {"x": 0.0, "y": 0.0}
	var stored_offset: Variant = frame.get("offset", null)
	if stored_offset is Dictionary:
		offset = {"x": float(stored_offset.get("x", 0.0)), "y": float(stored_offset.get("y", 0.0))}
	var strength: float = float(frame.get("strength", 0.0))
	var rotation: float = float(frame.get("rotation", SOURCE_REPAIR_TURRET_ROTATION_DEFAULT))
	if target != null and target is Dictionary:
		var dead: bool = bool(target.get("dead", false))
		var distance: float = float(target.get("distance", 0.0))
		var full_health: bool = target.has("health") and target.has("max_health") and float(target.get("health", 0.0)) >= float(target.get("max_health", 0.0))
		if dead or distance > repair_radius or full_health:
			target = null
	if target == null:
		offset = {"x": 0.0, "y": 0.0}
	var healed: bool = false
	var heal_amount: float = 0.0
	# The coolant multiplier (RepairTurret.java:188-191,
	# `float multiplier = 1f;` / `if(acceptCoolant){` /
	# `multiplier = 1f + liquids.current().heatCapacity *
	# coolantMultiplier * optionalEfficiency;`): the tick
	# stamps frame["coolant_multiplier"] from the FOLDED
	# optionalEfficiency and the CURRENT liquid's heatCapacity
	# (N2259); a frame without the key keeps the Java 1f
	# default, and repair-point always stamps 1.0.
	var multiplier: float = float(frame.get("coolant_multiplier", 1.0))
	if target != null and target is Dictionary and efficiency > 0.0:
		var angle: float = source_math_state.source_angles_angle(building_x, building_y, float(target.get("x", 0.0)) + float(offset.get("x", 0.0)), float(target.get("y", 0.0)) + float(offset.get("y", 0.0)))
		if source_math_state.source_angles_angle_dist(angle, rotation) < SOURCE_REPAIR_TURRET_HEAL_ANGLE_MARGIN:
			healed = true
			var edelta: float = efficiency * source_delta * time_scale
			heal_amount = repair_speed * strength * edelta * multiplier
		rotation = _repair_turret_slerp_delta(rotation, angle, SOURCE_REPAIR_TURRET_ROTATION_SLERP_PROGRESS * efficiency * time_scale, source_delta)
	strength = source_math_state.source_lerp_delta(strength, 1.0 if healed else 0.0, SOURCE_REPAIR_TURRET_STRENGTH_LERP_PROGRESS * source_delta, source_delta)
	# The timer cadence is live since N2280: the tick stamps
	# frame["unit_candidates"] with the frame-input
	# candidates when the timer fires and [] when it does
	# not, and the advance reads that key when the explicit
	# candidate list is empty (the coolant_multiplier
	# frame-key precedent, N2259 -- the N2226 test pins the
	# advance call text, so no new parameter). An explicit
	# non-empty list still wins over the frame key; an empty
	# list AND an empty frame key mean the timer did not
	# fire and the target is untouched.
	var effective_candidates: Array = candidates
	if effective_candidates.is_empty():
		var frame_candidates: Variant = frame.get("unit_candidates", [])
		if frame_candidates is Array:
			effective_candidates = frame_candidates
	if not effective_candidates.is_empty():
		var best: Variant = null
		var best_dst2: float = 0.0
		for candidate in effective_candidates:
			if not (candidate is Dictionary):
				continue
			if not bool(candidate.get("valid", true)):
				continue
			if not bool(candidate.get("damaged", false)):
				continue
			var candidate_dx: float = float(candidate.get("x", 0.0)) - building_x
			var candidate_dy: float = float(candidate.get("y", 0.0)) - building_y
			var candidate_dst2: float = candidate_dx * candidate_dx + candidate_dy * candidate_dy
			var reach: float = repair_radius + float(candidate.get("hit_size", 0.0)) / 2.0
			if candidate_dst2 >= reach * reach:
				continue
			if best == null or candidate_dst2 < best_dst2:
				best = candidate
				best_dst2 = candidate_dst2
		target = best
	return {"target": target, "offset": offset, "strength": strength, "rotation": rotation, "heal_amount": heal_amount, "healed": healed}

static func source_repair_turret_timer_target_state(elapsed: float, source_delta: float, time_scale: float, duration: float) -> Dictionary:
	# The frame-local Interval-equivalent for the timer-target
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
	# the elapsed clock is frame-local (frame["timer_target_
	# elapsed"], accumulated by the tick delta every tick the
	# advance runs, unconditionally -- mirroring Time.time,
	# which grows even while the gate is closed): elapsed +=
	# source_delta unconditionally (source_delta is the
	# UNSCALED Time.delta in ticks -- game_source_delta is
	# seconds * 60, never scaled by timeScale -- so the
	# frame clock mirrors the global Time.time exactly);
	# fired = elapsed >= duration (the LITERAL duration,
	# no timeScale division, N2290 fix of the N2280
	# 20/time_scale deviation); elapsed_after RESETS to
	# 0.0 on fire (a reset, not a subtraction like the
	# Fracker accumulator); a non-positive time_scale is
	# a defensive guard (fired false -- see below). The
	# Java call is
	# (RepairTurret.java:214-216):
	# `if(timer(timerTarget, 20)){`
	# `rect.setSize(repairRadius * 2).setCenter(x, y);`
	# `target = Units.closest(team, x, y, repairRadius, Unit::damaged);`
	# with `public int timerTarget = timers++;`
	# (RepairTurret.java:29) and `public float repairRadius = 50f;`
	# (RepairTurret.java:32). Java passes a LITERAL 20 to
	# timer() -- no timeScale division, unlike the
	# MendProjector (`timer(timerUse, useTime /
	# timeScale)`, MendProjector.java:102) / WallCrafter /
	# ImpactReactor timers -- so Java re-acquires every 20
	# global ticks whatever the building timeScale is, and
	# the port threshold is the literal duration (N2290
	# fix; the N2280 20/time_scale deviation is resolved).
	# time_scale stays a parameter (signature stability --
	# the contract, call sites, and tests keep it) and is
	# still read: a non-positive time_scale never fires, a
	# defensive port guard for a corrupt frame input --
	# Java timeScale is always positive in practice (the
	# default, BuildingComp.java:98, is
	# `private transient float timeScale = 1f, timeScaleDuration;`;
	# applyBoost / applySlowdown take positive intensities,
	# BuildingComp.java:461-478; decay resets it to 1f,
	# BuildingComp.java:2265-2266), so the guard is
	# unreachable in Java-exact play and the threshold is
	# Java-exact at every reachable time_scale. Note the
	# clock still ACCUMULATES at time_scale 0 (source_delta
	# is unscaled) -- only the fire is guarded. Documented
	# deviation (first
	# fire): Java fires (nearly) immediately after placement
	# (the global Time.time is already large vs a fresh
	# Interval times[id] = 0); the frame-local clock delays
	# the first fire by a full interval (20 ticks). It cannot
	# be fixed without a global clock -- it waits for a
	# timer-infra slice if exact first-fire timing is ever
	# needed.
	var threshold: float = INF if time_scale <= 0.0 else duration
	var accumulated: float = elapsed + source_delta
	var fired: bool = accumulated >= threshold
	var elapsed_after: float = 0.0 if fired else accumulated
	return {"fired": fired, "elapsed_after": elapsed_after}

static func source_repair_turret_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The repair-turret tick wires the frame keys the
	# consumption path reads (the N2148 turret pattern):
	# block_implementation is the block's implementation
	# (RepairTurret.java:25, `public class RepairTurret extends Block{`; RepairPointBuild, RepairTurret.java:153, `public class RepairPointBuild extends Building implements Ranged, RotBlock{`),
	# team_id and rules_state are what Java reads as b.team
	# and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(),
	# TeamComp.java:17-19 `return team.rules().cheat;`, read
	# through N2099's helper), so a cheating team's
	# repair turret skips consumption like Java's updateConsumption
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
	# for this repair turret (N2125); the tick preserves a disabled
	# repair turret instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {"target": null, "liquids": {}}

static func source_repair_turret_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the repair-turret frame meta key
	# ("source_repair_turret_building"). A RepairTurret sprite gets a
	# frame bound with the target key defaulting to null (the Java field
	# `public Unit target;`, RepairTurret.java:154, defaults to null);
	# the live-loop tick fills its other keys every tick. Any other
	# block, or an already-bound sprite, binds nothing.
	if block == null or not _is_repair_turret_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_REPAIR_TURRET_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_REPAIR_TURRET_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_REPAIR_TURRET_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_repair_turret_should_consume_state(frame: Dictionary) -> Dictionary:
	# RepairPointBuild overrides shouldConsume (RepairTurret.java:221, `public boolean shouldConsume(){` with `return target != null && enabled;`, RepairTurret.java:222): the gate reads the live target AND the enabled flag. The field is `public Unit target;` (RepairTurret.java:154) on RepairPointBuild (`public class RepairPointBuild extends Building implements Ranged, RotBlock{`, RepairTurret.java:153); RepairTurret extends Block (RepairTurret.java:25, `public class RepairTurret extends Block{`), so the default (`return enabled;`, BuildingComp.java:755) does NOT apply here. Unlike the UnitCargoLoader gate (N2211) this one HAS `&& enabled` -- the override includes the enabled check, so the pure gate reads both frame keys (the ItemBridge N2188 precedent): target (frame["target"], default null for a frame bound before this slice -- the Java field default) and enabled (frame["enabled"], default true -- BuildingComp.java:77, `transient boolean enabled = true;`); no live fill sets frame["target"] yet -- the live target acquire (Units.closest, RepairTurret.java:216, `target = Units.closest(team, x, y, repairRadius, Unit::damaged);`, every 20 ticks, RepairTurret.java:214, plus the clear when dead / out of range / full health, RepairTurret.java:193-194) is the updateTile advance (RepairTurret.java:187-218): N2226 ports the clear + the pure re-acquire selection and N2280 the timer cadence (frame-local Interval, 20f, candidates ride frame["unit_candidates"]), but the live unit query still waits for the live-fill slice, so no live fill sets frame["target"] yet without supplied candidates. When the gate is false updateConsumption forces efficiency to zero (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The heal advance (RepairTurret.java:207, `target.heal(repairSpeed * strength * edelta() * multiplier);`) follows the folded efficiency. The power consumer is conditional (`consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);`, RepairTurret.java:89) -- the two defs carry powerUse 1f (repair-point, Blocks.java:6391, `powerUse = 1f;`) and 5f (repair-turret, Blocks.java:6402, `powerUse = 5f;`).
	var target: Variant = frame.get("target", null)
	var enabled: bool = bool(frame.get("enabled", true))
	return {"should_consume": target != null and enabled, "has_target": target != null}

static func source_repair_turret_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
	# ConsumePower.efficiency (ConsumePower.java:38-40, `return build.power.status;`): the power consumer's efficiency is the building's live power.status, and the first pass folds it into the min efficiency (BuildingComp.java:1969-1976, `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`). The graph update stamps frame["power_status"] each tick (N2142); a missing stamp folds to 1.0 before the first graph update, the assembler fold (UnitAssembler.java:469, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`). A block with no power consumer contributes no row. The power consumer counts toward hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a repair turret does not take the early return. The repair turret's power draw is CONDITIONAL, not static: `consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);` (RepairTurret.java:89), and ConsumePowerCondition only draws when its condition holds (ConsumePowerCondition.java:17, `return consume.get(entity) ? usage : 0f;`) -- the catalog consumePower None is CORRECT for this family, it records no static consumePower def; the two defs carry powerUse 1f (repair-point, Blocks.java:6391, `powerUse = 1f;`) and 5f (repair-turret, Blocks.java:6402, `powerUse = 5f;`), and the block declares `public float powerUse;` (RepairTurret.java:34) with `hasPower = true;` (RepairTurret.java:60). The pure row is still the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39) -- ConsumePowerCondition does not override efficiency(), so the row folds power.status exactly like the static case. The updateTile advance follows the folded efficiency: the heal advance (RepairTurret.java:207, `target.heal(repairSpeed * strength * edelta() * multiplier);`) heals by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a repair turret with no power would never heal. RepairPointBuild overrides shouldConsume (RepairTurret.java:221, `public boolean shouldConsume(){` with `return target != null && enabled;`, RepairTurret.java:222); updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). The shouldConsume gate is live (N2212) -- the pure gate (source_repair_turret_should_consume_state) feeds should_consume to the machinery from the frame target key (null with no target, non-null once a damaged unit is locked) and the enabled flag; the timer cadence is live since N2280 (N2226: the clear + pure re-acquire selection are live; the live unit query still waits for the live-fill slice, so no live fill sets frame["target"] yet without supplied candidates). The repair turret is its own family (RepairTurret.java:25, `public class RepairTurret extends Block{`; RepairPointBuild, RepairTurret.java:153, `public class RepairPointBuild extends Building implements Ranged, RotBlock{`). Two defs (repair-point, `powerUse = 1f;`, Blocks.java:6391; repair-turret, `powerUse = 5f;`, Blocks.java:6402).
	# Documented limits: (1) power + coolant optional pass -- the repair turret's power consumer is conditional (ConsumePowerCondition, target-gated), so the folded efficiency is the min over the *modeled* non-optional consumers (power only); the coolant optional consumer (repair-turret only: ConsumeCoolant 0.16f, acceptCoolant, coolantMultiplier 1.6f, Blocks.java:6405-6407; `consume(new ConsumeCoolant(coolantUse)).optional(true, true);`, RepairTurret.java:86) is LIVE since N2259 (source_repair_turret_coolant_row_state, ConsumeLiquidFilter.efficiency, ConsumeLiquidFilter.java:50-55; the second-pass removal is ConsumeLiquidFilter.update, ConsumeLiquidFilter.java:42-47), folding into the optional pass (BuildingComp.java:1979-1981); coolant is the ONLY optional consumer on this family, so optionalEfficiency is complete. The conditional power DRAW (ConsumePowerCondition usage gated on target != null, ConsumePowerCondition.java:17) is still not modeled -- the row still reads power.status (ConsumePowerCondition does not override efficiency()). (2) shouldConsume gate live (N2212) -- RepairPointBuild overrides shouldConsume (`target != null && enabled`, RepairTurret.java:221-223); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the pure gate reads the frame target key (default null) plus enabled and feeds should_consume to the machinery; the timer cadence is live since N2280 (N2226: the clear + pure re-acquire selection are live; the live unit query still waits for the live-fill slice, so no live fill sets frame["target"] yet without supplied candidates). (3) updateTile advance live (N2226) -- the target clear / heal amount / rotation slerp / strength lerp / pure re-acquire selection (RepairTurret.java:187-218) run on the frame; the coolant multiplier is live since N2259 (frame["coolant_multiplier"] from the folded optionalEfficiency + current heatCapacity, RepairTurret.java:190); the timer cadence live (N2280) -- the frame-local Interval (20f, literal-20 threshold Java-exact since N2290) passes frame-input unit_candidates into the advance when it fires, [] otherwise; the heal application (target.heal writes into another unit frame) and the live Units scan (no live unit query exists in the port) wait for the live-fill slice. (4) Two defs -- repair-point (powerUse 1f) and repair-turret (powerUse 5f + coolant) share the one driver; repairSpeed / repairRadius are now read per def by the advance (N2226, driver constants -- the catalog carries neither); length / beamWidth / pulseRadius per-def values wait for their own verification slice. (5) RepairTower (unit-repair-tower) is a different class and NOT covered by this driver.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_repair_turret_coolant_filter_state(liquid_props: Dictionary) -> Dictionary:
	# The ConsumeCoolant filter (ConsumeCoolant.java:12, the
	# exact expr on ONE comment line, the N2148 lesson):
	# `this.filter = liquid -> liquid.coolant && (this.allowLiquid && !liquid.gas || this.allowGas && liquid.gas) && liquid.temperature <= maxTemp && liquid.flammability < maxFlammability;`
	# with `public float maxTemp = 0.5f, maxFlammability = 0.1f;` (ConsumeCoolant.java:5) and `public boolean allowLiquid = true, allowGas = false;` (ConsumeCoolant.java:6) -- the default constructor `this(amount, true, false);` (ConsumeCoolant.java:17) is what RepairTurret uses (`consume(new ConsumeCoolant(coolantUse))`, RepairTurret.java:86), so the gas term reduces to `!liquid.gas`. The catalog carries only overrides, so a missing prop falls back to the Liquid.java class default: `public boolean gas = false;` (Liquid.java:28), `public float flammability;` (Liquid.java:38, no initializer, so 0f), `public float temperature = 0.5f;` (Liquid.java:40), `public boolean coolant = true;` (Liquid.java:50). With defaults + catalog overrides only water (temp 0.5 default, flam 0 default, heatCapacity 0.4f) and cryofluid (temp 0.25f, flam 0 default, heatCapacity 0.9f) pass: oil flam 1.2, slag temp 1.0, neoplasm temp 0.54, arkycite flam 0.4, gallium coolant=false, and the four gases (ozone / hydrogen / nitrogen / cyanogen) are excluded by allowGas=false. The helper is a local transliteration (the N2191 slerp precedent -- no separate symbol).
	var coolant: bool = bool(liquid_props.get("coolant", true))
	var gas: bool = bool(liquid_props.get("gas", false))
	var temperature: float = float(liquid_props.get("temperature", SOURCE_REPAIR_TURRET_COOLANT_MAX_TEMP))
	var flammability: float = float(liquid_props.get("flammability", 0.0))
	return {"passes": coolant and not gas and temperature <= SOURCE_REPAIR_TURRET_COOLANT_MAX_TEMP and flammability < SOURCE_REPAIR_TURRET_COOLANT_MAX_FLAMMABILITY}

static func source_repair_turret_coolant_consumed_state(liquids: Dictionary, liquid_props_by_id: Array) -> Dictionary:
	# getConsumed (ConsumeLiquidFilter.java:63-76, each exact
	# expr on ONE comment line, the N2148 lesson):
	# `if(filter.get(build.liquids.current()) && build.liquids.currentAmount() > 0){`
	# `return build.liquids.current();`
	# `if(filter.get(liq) && build.liquids.get(liq) > 0){`
	# The current liquid wins when the filter matches it and
	# its amount is above 0; otherwise the FIRST liquid in
	# content order (the catalog liquids order, index = id)
	# that the filter matches with amount above 0; nothing
	# matches, null -- returned here as -1 (the
	# liquid_id_by_name -1 precedent). The amounts read
	# through the shared liquid module helper with the
	# Fracker guard (SourceFrackerBuildState.gd:221,
	# `liquids.has("liquids")` + bounds check): a store
	# without a liquids array, or a liquid never added,
	# reads 0.0, like Java's liquids.get. The helper is a
	# local transliteration (the N2191 slerp precedent -- no
	# separate symbol).
	if not liquids.has("liquids"):
		return {"consumed_liquid": -1}
	var amounts: Array = liquids["liquids"]
	var current: Variant = liquids.get("current", null)
	if current != null and int(current) >= 0 and int(current) < amounts.size() and int(current) < liquid_props_by_id.size():
		var current_props: Dictionary = liquid_props_by_id[int(current)] if liquid_props_by_id[int(current)] is Dictionary else {}
		if bool(source_repair_turret_coolant_filter_state(current_props).get("passes", false)) and float(source_liquid_module_state.source_get_state(liquids, int(current)).get("amount", 0.0)) > 0.0:
			return {"consumed_liquid": int(current)}
	for liquid_id in range(amounts.size()):
		if liquid_id >= liquid_props_by_id.size():
			break
		var props: Dictionary = liquid_props_by_id[liquid_id] if liquid_props_by_id[liquid_id] is Dictionary else {}
		if bool(source_repair_turret_coolant_filter_state(props).get("passes", false)) and float(source_liquid_module_state.source_get_state(liquids, liquid_id).get("amount", 0.0)) > 0.0:
			return {"consumed_liquid": liquid_id}
	return {"consumed_liquid": -1}

static func source_repair_turret_coolant_multiplier_state(current_heat_capacity: float, optional_efficiency: float, coolant_multiplier := SOURCE_REPAIR_TURRET_COOLANT_MULTIPLIER) -> Dictionary:
	# The heal multiplier (RepairTurret.java:188-191, the
	# exact expr on ONE comment line, the N2148 lesson):
	# `float multiplier = 1f;`
	# `multiplier = 1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency;`
	# The heat capacity is the CURRENT liquid's (not the
	# liquid the row consumed -- getConsumed may pick a
	# different liquid than current when current fails the
	# filter), the coolantMultiplier is the def 1.6f
	# (`coolantMultiplier = 1.6f;`, Blocks.java:6406; class
	# default `public float coolantMultiplier = 1f;`,
	# RepairTurret.java:45), and optionalEfficiency is the
	# FOLDED value (capped by minEfficiency,
	# `optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);`, BuildingComp.java:1986, and zeroed
	# when the gate is false, BuildingComp.java:1992-1994),
	# NOT the fold-time 1f assumption. When acceptCoolant is
	# false (repair-point, `public boolean acceptCoolant =
	# false;`, RepairTurret.java:39) Java never runs the
	# branch and the multiplier stays 1f -- the tick passes
	# 1.0 for repair-point and never calls this helper. The
	# helper is a local transliteration (the N2191 slerp
	# precedent -- no separate symbol).
	return {"multiplier": 1.0 + current_heat_capacity * coolant_multiplier * optional_efficiency}

static func source_repair_turret_coolant_row_state(frame: Dictionary, has_coolant_consumer: bool, liquid_props_by_id: Array, amount: float, source_delta: float, time_scale: float, multiplier := 1.0) -> Dictionary:
	# ConsumeLiquidFilter.efficiency (ConsumeLiquidFilter.java:50-55, each
	# exact expr on ONE comment line, the N2148 lesson):
	# `float ed = build.edelta();`
	# `if(ed <= 0.00000001f) return 0f;`
	# `return liq != null ? Math.min(build.liquids.get(liq) / (amount * ed * multiplier.get(build)), 1f) : 0f;`
	# NOTE the filter difference from ConsumeLiquid: ed is
	# `build.edelta()` WITHOUT efficiencyScale (ConsumeLiquid
	# multiplies, `float ed = build.edelta() *
	# build.efficiencyScale();`, ConsumeLiquid.java:43) -- do
	# not copy the ConsumeLiquid formula here. The optional
	# pass folds the row into optionalEfficiency
	# (BuildingComp.java:1979-1981, `for(var cons : block.optionalConsumers){` / `optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));`), capped by the min efficiency (`efficiency = minEfficiency;`, BuildingComp.java:1985; `optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);`, BuildingComp.java:1986) -- a starved coolant row lowers optionalEfficiency, never the min efficiency, and it does NOT stop power draw (the shouldConsumePower cut at BuildingComp.java:1972-1974 only runs over the non-optional pass). In the first pass efficiency is assumed 1f (BuildingComp.java:1964-1966), so edelta() is delta() (`return efficiency * delta();`, BuildingComp.java:1927-1929, with efficiency 1f) and delta() is `return Time.delta * timeScale;` (BuildingComp.java:1922-1924) -- the source delta in ticks times the time scale. The liquid to consume comes from getConsumed (ConsumeLiquidFilter.java:63-76, `if(filter.get(build.liquids.current()) && build.liquids.currentAmount() > 0){` / `return build.liquids.current();` / `if(filter.get(liq) && build.liquids.get(liq) > 0){`), and the row reports it as consumed_liquid (-1 when null) so the tick's second pass removes from the right liquid. The multiplier is the Consume default 1f (Consume.java:18, `public Floatf<Building> multiplier = b -> 1f;`) -- the def sets no multiplier. The row is NOT power (`"is_power": false`). The second pass removes the consumed coolant (ConsumeLiquidFilter.update, ConsumeLiquidFilter.java:42-47, `build.liquids.remove(liq, amount * build.edelta() * multiplier.get(build));`) when `if(update && efficiency > 0){` (BuildingComp.java:1999-2000, `cons.update(self());`), with edelta from the FOLDED efficiency -- the tick does that removal directly after apply_update_consumption_state, with `boolean update = shouldConsume() && productionValid();` (BuildingComp.java:1960) as the guard; the machinery only RECORDS update consumers (SourceBuildingEfficiencyState.gd:136-152). The consumer is `consume(new ConsumeCoolant(coolantUse)).optional(true, true);` (RepairTurret.java:86, `if(acceptCoolant){` at :84) -- optional + booster (`return optional(true, true);`, Consume.java:34, the boost() body), update=true by default (Consume.java:16), so the second pass consumes automatically. The def is the repair-turret only (`coolantUse = 0.16f;`, Blocks.java:6405; `coolantMultiplier = 1.6f;`, Blocks.java:6406; `acceptCoolant = true;`, Blocks.java:6407); repair-point has no coolant consumer (`public boolean acceptCoolant = false;`, RepairTurret.java:39; class defaults `public float coolantUse = 0.5f;`, RepairTurret.java:41, and `public float coolantMultiplier = 1f;`, RepairTurret.java:45). The repair turret is its own family (RepairTurret.java:25, `public class RepairTurret extends Block{`; RepairPointBuild, RepairTurret.java:153, `public class RepairPointBuild extends Building implements Ranged, RotBlock{`); the gate is `return target != null && enabled;` (RepairTurret.java:222) and the heal advance is `target.heal(repairSpeed * strength * edelta() * multiplier);` (RepairTurret.java:207).
	if not has_coolant_consumer:
		return {"has_coolant_row": false, "row": {}, "consumed_liquid": -1}
	var liquids: Dictionary = frame.get("liquids", {})
	var consumed: Dictionary = source_repair_turret_coolant_consumed_state(liquids, liquid_props_by_id)
	var consumed_liquid: int = int(consumed.get("consumed_liquid", -1))
	var edelta: float = source_delta * time_scale
	var ed: float = edelta
	if ed <= 0.00000001:
		return {"has_coolant_row": true, "row": {"result": 0.0, "is_power": false}, "consumed_liquid": consumed_liquid}
	if consumed_liquid < 0:
		return {"has_coolant_row": true, "row": {"result": 0.0, "is_power": false}, "consumed_liquid": -1}
	var liquid_amount := 0.0
	if liquids.has("liquids") and consumed_liquid < int(liquids["liquids"].size()):
		liquid_amount = float(source_liquid_module_state.source_get_state(liquids, consumed_liquid).get("amount", 0.0))
	return {"has_coolant_row": true, "row": {"result": minf(liquid_amount / (amount * ed * multiplier), 1.0), "is_power": false}, "consumed_liquid": consumed_liquid}

@warning_ignore("unused_parameter")
static func source_repair_turret_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the repair-turret tick wiring every
	# tick (RepairPointBuild.updateTile(), RepairTurret.java:187,
	# advances the heal by the heal advance (RepairTurret.java:207, `target.heal(repairSpeed * strength * edelta() * multiplier);`), so the heal advance follows the folded efficiency; no placed-buildings driver ticks RepairTurret blocks, so this driver is the placed-repair-turret tick): each placed RepairTurret build gets its frame keys refreshed from the live rules, so the frame's cheating flag tracks team.rules().cheat and the consumption machinery skips consumption for a cheating team. The frame is bound at placement; a sprite that somehow lacks one gets it bound here instead of crashing the loop.
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
	# The catalog liquid properties in content order (index =
	# liquid id, the source_liquid_catalog_state precedent):
	# the coolant filter + heat-capacity reads need the per-
	# liquid props (coolant / gas / temperature / flammability
	# / heatCapacity), and the catalog carries only overrides
	# -- the filter helper fills the Liquid.java defaults for
	# missing props.
	var liquid_props_by_id: Array = []
	for liquid in catalog.get_many("liquid"):
		liquid_props_by_id.append(liquid.properties)
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		var block_id: String = str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if not blocks_by_id.has(block_id):
			continue
		var block = blocks_by_id[block_id]
		if not _is_repair_turret_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_repair_turret_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_repair_turret_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The frame carries the Building.liquids LiquidModule
		# (frame["liquids"]): the live store lives on the
		# sprite meta (source_building_liquids, initialized
		# at placement), so the driver syncs the reference
		# into the frame each tick BEFORE the fold and the
		# pure coolant row reads the held coolant from it
		# (the Fracker:623 precedent).
		frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
		# Time.delta in ticks from the placed-block helper;
		# timeScale live from the sprite meta (default 1f,
		# BuildingComp.java:98). Both are needed BEFORE the
		# fold (the coolant row's edelta is source_delta *
		# time_scale with efficiency assumed 1f) and again
		# by the updateTile advance below, so they are read
		# once here.
		var source_delta: float = source_placed_block_state.game_source_delta(game, seconds)
		var time_scale: float = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))
		# The power consumer reads live since N2153 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a repair turret with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the heal advance (RepairTurret.java:207)
		# follows it. The power consumer counts toward
		# hasConsumers (Block.java:1449, `hasConsumers = consumers.length > 0;`), so a repair turret does not take the early return. The driver gate reads the conditional consumer through the catalog: the conditional registration (RepairTurret.java:89, `consumePowerCond(powerUse, (RepairPointBuild entity) -> entity.target != null);`) carries no static consumePower def, so the catalog records consumePower None (CORRECT) but consumesPower true for both defs -- the gate is `block.properties.has("consumePower")` or the catalog consumesPower flag, so a repair turret is ticked while a block with no power consumer at all is untouched: the tick models no other consumers yet (the updateTile advance is live, N2226, wired below after the consumption fold), and RepairPointBuild overrides shouldConsume (RepairTurret.java:221, `public boolean shouldConsume(){` with `return target != null && enabled;`, RepairTurret.java:222) -- N2212 feeds the live gate to the machinery (the pure gate is source_repair_turret_should_consume_state, fed the frame); the N2174 RED decision is resolved. The gate HAS an enabled term (Java returns `target != null && enabled;`), so the pure gate reads frame["enabled"] too (the ItemBridge N2188 precedent); the outer guard below already runs the machinery only when enabled. productionValid is the canonical true default (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower") or block.properties.get("consumesPower", false))
		# The coolant consumer is repair-turret ONLY
		# (`acceptCoolant = true;`, Blocks.java:6407;
		# repair-point keeps the class default
		# `public boolean acceptCoolant = false;`,
		# RepairTurret.java:39). The catalog carries no
		# acceptCoolant flag for this family, so the gate is
		# the block id (the repairSpeed precedent). The flag
		# is read by the consumption fold below AND by the
		# advance multiplier, so it is defined outside the
		# fold guard.
		var has_coolant_consumer: bool = block_id == "repair-turret"
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var gate: Dictionary = source_repair_turret_should_consume_state(frame)
			var should_consume: bool = bool(gate.get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_repair_turret_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			# The coolant optional consumer (repair-turret
			# only: `consume(new ConsumeCoolant(coolantUse)).
			# optional(true, true);`, RepairTurret.java:86,
			# with coolantUse 0.16f, Blocks.java:6405): the
			# pure row reads the held coolant from the
			# synced frame store and folds into the OPTIONAL
			# pass (BuildingComp.java:1979-1981), never the
			# min efficiency -- a starved coolant row lowers
			# optionalEfficiency, not efficiency. repair-point
			# appends no row (acceptCoolant=false). The
			# multiplier is the Consume default 1f
			# (Consume.java:18 -- the def sets none).
			var coolant_consume_multiplier := 1.0
			var coolant_row: Dictionary = source_repair_turret_coolant_row_state(frame, has_coolant_consumer, liquid_props_by_id, SOURCE_REPAIR_TURRET_COOLANT_AMOUNT, source_delta, time_scale, coolant_consume_multiplier)
			var optional_results: Array = []
			if bool(coolant_row.get("has_coolant_row", false)):
				optional_results.append(coolant_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, optional_results, [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
			# Second pass (BuildingComp.java:1999-2000,
			# `if(update && efficiency > 0){`): ConsumeLiquidFilter.
			# update removes `amount * edelta() * multiplier`
			# (ConsumeLiquidFilter.java:42-47, `build.liquids.
			# remove(liq, amount * build.edelta() *
			# multiplier.get(build));`) from the liquid the row
			# consumed, with edelta from the FOLDED efficiency
			# -- NOT the 1f assumed in the first pass. Direct
			# removal after the fold (the machinery only
			# RECORDS update consumers, SourceBuildingEfficiency
			# State.gd:136-152); the shared module helper
			# clamps at zero and the cache_sums follow the
			# SolidPump precedent (empty when the store has no
			# flow).
			if has_coolant_consumer and bool(setup.get("update", false)) and float(frame.get("efficiency", 0.0)) > 0.0:
				var consumed_liquid: int = int(coolant_row.get("consumed_liquid", -1))
				if consumed_liquid >= 0:
					var folded_edelta: float = float(frame.get("efficiency", 0.0)) * source_delta * time_scale
					var remove_amount: float = SOURCE_REPAIR_TURRET_COOLANT_AMOUNT * folded_edelta * coolant_consume_multiplier
					var liquids_store: Dictionary = frame.get("liquids", {})
					if liquids_store.has("liquids") and consumed_liquid < int(liquids_store["liquids"].size()):
						var cache_sums: Array = []
						if liquids_store.get("flow") != null:
							cache_sums.resize(int(liquids_store["liquids"].size()))
							cache_sums.fill(0.0)
						source_liquid_module_state.source_remove_state(liquids_store, consumed_liquid, remove_amount, cache_sums)
		# N2226: the updateTile advance runs after consumption,
		# like Java's Building.update() (BuildingComp.java:2274
		# updateConsumption(), then the updateTile gate
		# `if(enabled || !block.noUpdateDisabled){` at
		# BuildingComp.java:2276-2277; noUpdateDisabled defaults
		# false, `public boolean noUpdateDisabled = false;`
		# (Block.java:170), so Java runs updateTile even when
		# disabled -- in Java a disabled repair turret's
		# strength DECAYS toward 0 (efficiency is zeroed by the
		# disabled early return, BuildingComp.java:1954-1957)
		# and the rotation freezes (the heal branch needs
		# efficiency > 0, RepairTurret.java:203). The port keeps
		# the enabled gate below as a pragmatic choice (the
		# N2195 coordinator-fix precedent): the driver skips
		# the consumption fold when disabled, so the frame
		# efficiency goes stale and running the advance on it
		# would charge strength/heal from a stale efficiency.
		# The driver-wide disabled-early-return slice
		# (deferred in the N2226 register) removes this gate
		# for all families. super.updateTile() is an empty
		# no-op (BuildingComp.java:2010-2012), so the driver
		# owes it nothing. The source delta is Time.delta in
		# ticks: game_source_delta(game, seconds) is seconds *
		# 60 (arc Time.java:26), never raw seconds, and
		# timeScale reads live from the sprite meta, default
		# 1.0 (BuildingComp.java:98 `private transient float
		# timeScale = 1f, timeScaleDuration;`) -- both were
		# read above, before the fold, for the coolant row.
		# N2259: the coolant multiplier is live --
		# `multiplier = 1f + liquids.current().heatCapacity *
		# coolantMultiplier * optionalEfficiency;`
		# (RepairTurret.java:190, coolantMultiplier 1.6f,
		# Blocks.java:6406) reads the FOLDED
		# optionalEfficiency (stamped by apply above) and the
		# CURRENT liquid's heatCapacity from the catalog
		# props (Java default 0.5f, Liquid.java:42, when the
		# catalog carries none) -- the current liquid, not
		# the liquid the row consumed. The advance reads it
		# from frame["coolant_multiplier"] (the frame-key
		# choice: the N2226 test pins the advance call text,
		# so no new parameter); repair-point keeps 1.0
		# (acceptCoolant=false). When the fold did not run
		# this tick (disabled / cheating / no power
		# consumer) the frame holds no fresh
		# optional_efficiency, so the multiplier falls back
		# to 1.0. repairSpeed /
		# repairRadius come from the per-def driver helpers
		# (repair-point 0.45f/60f, repair-turret 3f/145f,
		# Blocks.java:6388-6389/:6400-6401 -- the catalog
		# carries neither). The building position comes from
		# the origin cell: Building x/y are tile.drawx()/
		# drawy() (BuildingComp.java:124,
		# `set(tile.drawx(), tile.drawy());`), drawx is
		# block.offset + tile.worldx() (Tile.java:175-176) with
		# the block offset `offset = ((size + 1) % 2) * tilesize / 2f;`
		# (Block.java:761) -- 0 for the size-1 repair-point, 4
		# for the size-2 repair-turret. N2280: the timer-target
		# cadence is live -- the tick stamps frame["unit_
		# candidates"] with the frame-input candidates when
		# the 20-tick frame-local timer fires and [] when it
		# does not (the N2226 test pins the advance call text
		# with a [] literal, so the candidates ride the frame
		# like coolant_multiplier, N2259); no live unit query
		# exists in the port yet, so unit_candidates is a frame
		# input and the live Units scan waits for its own
		# slice.
		if bool(frame.get("enabled", true)):
			var advance_coolant_multiplier := 1.0
			if has_coolant_consumer:
				var coolant_store: Dictionary = frame.get("liquids", {})
				var current_liquid: Variant = coolant_store.get("current", null)
				var current_heat_capacity := SOURCE_REPAIR_TURRET_LIQUID_HEAT_CAPACITY_DEFAULT
				if current_liquid != null and int(current_liquid) >= 0 and int(current_liquid) < liquid_props_by_id.size():
					var current_props: Dictionary = liquid_props_by_id[int(current_liquid)] if liquid_props_by_id[int(current_liquid)] is Dictionary else {}
					current_heat_capacity = float(current_props.get("heatCapacity", SOURCE_REPAIR_TURRET_LIQUID_HEAT_CAPACITY_DEFAULT))
				advance_coolant_multiplier = float(source_repair_turret_coolant_multiplier_state(current_heat_capacity, float(frame.get("optional_efficiency", 0.0))).get("multiplier", 1.0))
			frame["coolant_multiplier"] = advance_coolant_multiplier
			var advance_repair_speed: float = _repair_speed_for_block(block_id)
			var advance_repair_radius: float = _repair_radius_for_block(block_id)
			var advance_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
			var advance_block_size: int = int(block.properties.get("size", 1))
			var advance_block_offset: float = float((advance_block_size + 1) % 2) * source_world_defaults.TILESIZE / 2.0
			var advance_building_x: float = source_block_geometry.tile_drawx_state(advance_cell.x, source_world_defaults.TILESIZE, advance_block_offset)
			var advance_building_y: float = source_block_geometry.tile_drawy_state(advance_cell.y, source_world_defaults.TILESIZE, advance_block_offset)
			# N2280: the timer-target cadence (RepairTurret.java:
			# 214-216, `if(timer(timerTarget, 20)){` /
			# `rect.setSize(repairRadius * 2).setCenter(x, y);` /
			# `target = Units.closest(team, x, y, repairRadius,
			# Unit::damaged);`) -- the frame-local clock
			# (frame["timer_target_elapsed"]) accumulates the
			# tick delta every tick the advance runs, and when
			# it fires the frame-input unit_candidates reach
			# the advance; when it does not fire the advance
			# sees [] as before. The advance call text is
			# pinned by the N2226 test, so the candidates ride
			# the frame (the coolant_multiplier N2259
			# precedent): the tick stamps frame["unit_
			# candidates"] with the input candidates on a fire
			# and [] otherwise, and the advance falls back to
			# that key when its explicit list is empty. Live
			# unit frames do not exist in the port, so
			# unit_candidates is a frame input (seeded by the
			# proof; the live Units scan waits for its own
			# slice). The clock runs only while enabled (the
			# same pragmatic gate as the advance itself --
			# Java runs updateTile even when disabled,
			# BuildingComp.java:2276-2277); the driver-wide
			# disabled-early-return slice removes this gate
			# for all families. First-fire deviation: Java
			# fires nearly at once after placement; the frame
			# clock delays the first fire by a full interval
			# (20 ticks).
			var timer_target: Dictionary = source_repair_turret_timer_target_state(float(frame.get("timer_target_elapsed", 0.0)), source_delta, time_scale, SOURCE_REPAIR_TURRET_TIMER_TARGET_DURATION)
			frame["timer_target_elapsed"] = timer_target.get("elapsed_after", 0.0)
			var timer_target_candidates: Array = []
			if bool(timer_target.get("fired", false)):
				var frame_unit_candidates: Variant = frame.get("unit_candidates", [])
				if frame_unit_candidates is Array:
					timer_target_candidates = frame_unit_candidates
			frame["unit_candidates"] = timer_target_candidates
			var advanced: Dictionary = source_repair_turret_update_tile_advance_state(frame, source_delta, time_scale, advance_repair_speed, advance_repair_radius, advance_building_x, advance_building_y, [])
			frame["target"] = advanced["target"]
			frame["offset"] = advanced["offset"]
			frame["strength"] = advanced["strength"]
			frame["rotation"] = advanced["rotation"]
			frame["heal_amount"] = advanced["heal_amount"]
			frame["healed"] = advanced["healed"]
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
