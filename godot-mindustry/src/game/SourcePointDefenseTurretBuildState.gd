extends RefCounted
class_name SourcePointDefenseTurretBuildState

const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

# The PointDefenseTurret implementation (PointDefenseTurret.java:19,
# `public class PointDefenseTurret extends ReloadTurret{`): segment
# (consumePower 8f, size 2, range 180f, reload 8f, bulletDamage 30f,
# shootLength 5f, hasPower true). The only PointDefenseTurret block
# in the game (Blocks.java:3835-3847). PointDefenseBuild extends
# ReloadTurretBuild, NOT TurretBuild, so the turret driver
# (SourceTurretBuildState.gd) explicitly excludes it and no driver
# ticks it at all: it would rotate and reload as if power.status
# were 1.0. This driver is the point-defense tick. The driver uses
# its own family frame key ("source_point_defense_turret_building",
# the turret precedent); the generic turret frame
# ("source_turret_building") stays untouched, and this slice adds
# the point-defense key to N2142's
# SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp/write-back
# finds it.
const SOURCE_POINT_DEFENSE_TURRET_BUILD_IMPLEMENTATIONS := ["PointDefenseTurret"]
const SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY := "source_point_defense_turret_building"

static func _is_point_defense_turret_build_implementation(implementation: String) -> bool:
	return SOURCE_POINT_DEFENSE_TURRET_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_point_defense_turret_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The point-defense tick wires the frame keys the consumption
	# path reads (the N2148 turret pattern): block_implementation
	# is the block's implementation (PointDefenseTurret.java:19,
	# `public class PointDefenseTurret extends ReloadTurret{`),
	# team_id and rules_state are what Java reads as b.team and
	# state.rules, and cheating is the team's live TeamRule value
	# (TeamComp.cheating(), TeamComp.java:17-19 `return team.rules().cheat;`,
	# read through N2099's helper), so a cheating team's segment
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
	# for this segment (N2125); the tick preserves a disabled
	# segment instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_point_defense_turret_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement under the point-defense frame meta key
	# ("source_point_defense_turret_building"). A PointDefenseTurret
	# sprite gets an empty frame bound; the live-loop tick fills its
	# keys every tick. Any other block, or an already-bound sprite,
	# binds nothing.
	if block == null or not _is_point_defense_turret_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_point_defense_turret_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
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
	# so a segment does not take the early return. The
	# point-defense rotation and reload follow the folded
	# efficiency through edelta (BuildingComp.java:1928, `return efficiency * delta();`,
	# PointDefenseTurret.java:81, `rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());`).
	# Documented limits: (1) power-only first pass -- segment
	# has no other consumers; the folded efficiency is the min
	# over the *modeled* consumers (power only). (2) The
	# shouldConsume gate lives in the driver since N2241:
	# PointDefenseBuild.shouldConsume()
	# (PointDefenseTurret.java:105-107, `return super.shouldConsume() && target != null;`)
	# is `enabled && target != null` via
	# source_point_defense_turret_should_consume_state, so a
	# segment with no live target consumes nothing and its
	# efficiency folds to 0 (BuildingComp.java:1947) -- the
	# N2151 "machinery runs with should_consume=true when
	# enabled" approximation ended with N2241.
	# (3) No updateTile advance -- retarget / rotation /
	# reloadCounter / beam effects (PointDefenseTurret.java:62-103)
	# waits for its own slice; the proof carries no progress keys,
	# the edelta fold (PointDefenseTurret.java:81-82) is what the
	# efficiency keys prove.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_point_defense_turret_target_acquire_state(frame: Dictionary, observed_bullets: Array, team_id: int, x: float, y: float, range: float, delta: float) -> Dictionary:
	# PointDefenseBuild.updateTile retarget (PointDefenseTurret.java:65-71):
	# every retargetTime the build re-acquires the nearest enemy
	# hittable bullet in the range rect
	# (`if(timer(timerTarget, retargetTime)){` /
	# `target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));`,
	# PointDefenseTurret.java:65-67), and a pooled bullet is nulled
	# (`if(target != null && !target.isAdded()){` / `target = null;`,
	# PointDefenseTurret.java:69-71). The timer slot is `public final int timerTarget = timers++;`
	# (PointDefenseTurret.java:20) with `public float retargetTime = 5f;`
	# (PointDefenseTurret.java:21) on a per-building Interval
	# (`transient Interval timer = new Interval(6);`, TimerComp.java:8);
	# `timer()` (TimerComp.java:10-12) delegates to `Interval.get`,
	# which fires on elapsed game time (`return Time.time - times[id] >= time || Time.time < times[id];`,
	# Interval.java:29, times[] init 0, so the first fire is at
	# Time.time >= 5) and stamps the fire time (`if(got) times[id] = Time.time;`,
	# Interval.java:24). The port models this with a per-frame
	# accumulator `target_timer += delta; if target_timer >= 5.0: fire,
	# target_timer = 0` -- reset-to-0 drops overshoot exactly like
	# `Interval.get`; do NOT subtract the interval (that would carry
	# overshoot and drift the re-acquire cadence vs Java). The target
	# field is `public @Nullable Bullet target;` (PointDefenseTurret.java:60).
	# The port has no live bullet query (no Groups.bullet equivalent),
	# so the pure function consumes an observed bullet list (the
	# ShockwaveTower N2190 precedent: `observed_bullets`, an array of
	# dicts with team/hittable/x/y, world coords, plus an `id` so the
	# stored target can be re-identified across ticks -- the live
	# `game["bullets"]` dicts carry no team/hittable/id yet, so the
	# driver maps them in a later wiring step and stamps nothing
	# until then). The invalidation reads the CURRENT bullet record:
	# the stored target is looked up by `id` in the observed list
	# (the stored dict is a snapshot, Java holds a live reference
	# over `public @Nullable Bullet target;`; a target whose id is
	# absent from the list is pooled, so it is dropped, and a stored
	# target with no id cannot be re-identified, so it is dropped
	# too -- the RepairTurret N2212 precedent). The re-acquire is a
	# point-in-rect test against the Java intersect rect (x +/- range,
	# y +/- range, range 180f per-def, Blocks.java:3838, `range = 180f;`,
	# the only PointDefenseTurret def) with a min-dst2 pick; ties keep
	# the first bullet (strict `<`, the N2212 precedent). The port
	# models no bullet hitSize, so the rect overlap is approximated
	# by the bullet point, a documented limit owned by a later
	# bullet-hitSize slice (the ShockwaveTower precedent). The
	# re-acquire replaces the target unconditionally on fire -- even
	# a still-valid one is re-picked. The aim / rotation /
	# reloadCounter / shoot half (PointDefenseTurret.java:76-101) is
	# NOT this slice -- it waits for its own slice.
	var target: Variant = frame.get("target", null)
	var target_timer: float = float(frame.get("target_timer", 0.0)) + delta
	var reacquired: bool = false
	if target is Dictionary:
		var target_id: int = int(target.get("id", -1))
		if target_id == -1:
			target = null
		else:
			var fresh: Dictionary = {}
			for bullet in observed_bullets:
				if not (bullet is Dictionary):
					continue
				if int(bullet.get("id", -1)) == target_id:
					fresh = bullet
					break
			if fresh.is_empty():
				target = null
			else:
				target = fresh
	elif target != null:
		target = null
	if target_timer >= 5.0:
		target_timer = 0.0
		reacquired = true
		var best: Variant = null
		var best_dist2: float = 0.0
		var has_target: bool = false
		for bullet in observed_bullets:
			if not (bullet is Dictionary):
				continue
			if int(bullet.get("team", -1)) == team_id:
				continue
			if not bool(bullet.get("hittable", false)):
				continue
			if absf(float(bullet.get("x", 0.0)) - x) > range:
				continue
			if absf(float(bullet.get("y", 0.0)) - y) > range:
				continue
			var dx: float = float(bullet.get("x", 0.0)) - x
			var dy: float = float(bullet.get("y", 0.0)) - y
			var dist2: float = dx * dx + dy * dy
			if not has_target or dist2 < best_dist2:
				best = bullet
				best_dist2 = dist2
				has_target = true
		target = best
	return {"target": target, "has_target": target != null, "target_timer": target_timer, "reacquired": reacquired}

static func _angle_dist(angle_a: float, angle_b: float) -> float:
	# Angles.angleDist (Angles.java:23-27, `return Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a);`):
	# the min forward/backward distance after mod 360 (Angles.java:19-21, `return angleDist(a, b) <= margin;`,
	# is Angles.within). Mirrors SourceMathState.source_angles_angle_dist.
	var a: float = fposmod(angle_a, 360.0)
	var b: float = fposmod(angle_b, 360.0)
	var forward: float = a - b + 360.0 if a - b < 0.0 else a - b
	var backward: float = b - a + 360.0 if b - a < 0.0 else b - a
	return minf(forward, backward)

static func _move_toward_angle(angle: float, to: float, speed: float) -> float:
	# Angles.moveToward (Angles.java:38-49, `if(Math.abs(angleDist(angle, to)) < speed) return to;`):
	# returns `to` outright when |angleDist| < speed, otherwise steps +-speed along the shorter arc
	# (angleDist is the min forward/backward distance after mod 360, Angles.java:22-27).
	# Mirrors SourceMathState.source_angles_move_toward.
	if absf(_angle_dist(angle, to)) < speed:
		return to
	angle = fposmod(angle, 360.0)
	to = fposmod(to, 360.0)
	var forward_distance: float = absf(angle - to)
	var backward_distance: float = 360.0 - absf(angle - to)
	if (angle > to) == (backward_distance > forward_distance):
		angle -= speed
	else:
		angle += speed
	return angle

static func source_point_defense_turret_aim_shoot_state(frame: Dictionary, target: Variant, team_id: int, x: float, y: float, range: float, rotate_speed: float, reload: float, shoot_cone: float, bullet_damage: float, block_damage_multiplier: float, edelta: float) -> Dictionary:
	# The aim / shoot half of PointDefenseBuild.updateTile()
	# (PointDefenseTurret.java:76-101, the "look at target" half;
	# N2239 did the retarget half, :62-71). The gate
	# (`if(target != null && target.within(this, range) && target.team != team && target.type() != null && target.type().hittable){`,
	# PointDefenseTurret.java:76) requires all five conditions --
	# a null target, an out-of-range target, a same-team target,
	# a typeless target, or a non-hittable target leaves rotation
	# and reloadCounter untouched and shoots nothing.
	# `target.within(this, range)` is Position.within, dst2 < range^2
	# (STRICT `<`, Position.java:40-46, `return Mathf.dst2(getX(), getY(), x, y) < dst*dst;`).
	# Inside the gate the build turns toward the target
	# (`float dest = angleTo(target);` / `rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());`,
	# PointDefenseTurret.java:77-78) and charges the reload
	# (`reloadCounter += edelta();`, PointDefenseTurret.java:79).
	# `angleTo` is Position.angleTo -> Angles.angle(x, y, tx, ty)
	# (Position.java:12-14), i.e. `Mathf.atan2(x2 - x, y2 - y) *
	# Mathf.radDeg` normalized to [0, 360) -- atan2(dx, dy), 0 degrees
	# is +Y, the opposite of GDScript's `atan2(y, x)`, so this writes
	# `rad_to_deg(atan2(tx - x, ty - y))`, never Vector2.angle_to.
	# `edelta()` is `efficiency * delta()` (BuildingComp.java:1927-1929,
	# `return efficiency * delta();`); the driver passes it precomputed.
	# `rotation` is the float turret rotation, default 90
	# (`public float rotation = 90;`, BaseTurret.java:114 -- NOT
	# BuildingComp.rotation, the int block rotation), and
	# `reloadCounter` is the float on ReloadTurretBuild
	# (`public float reloadCounter;`, ReloadTurret.java:26). Java does
	# NOT clamp reloadCounter here (the clamp lives on the plain
	# TurretBuild, Turret.java:723, which PointDefenseBuild does not
	# extend), so no clamp is invented. The shoot gate
	# (`if(Angles.within(rotation, dest, shootCone) && reloadCounter >= reload){`,
	# PointDefenseTurret.java:82) uses `Angles.within(a, b, margin)` =
	# `angleDist(a, b) <= margin` (Angles.java:19-21, `return angleDist(a, b) <= margin;`),
	# i.e. `<=` shootCone. The damage is
	# `float realDamage = bulletDamage * state.rules.blockDamage(team);`
	# (PointDefenseTurret.java:83) with `blockDamage(team)` =
	# `return blockDamageMultiplier * teams.get(team).blockDamageMultiplier;`
	# (Rules.java:299-300) passed in precomputed; the comparison is
	# STRICT `>` (`if(target.damage() > realDamage){`,
	# PointDefenseTurret.java:84) so a target whose damage equals
	# realDamage is removed, not left at 0
	# (`target.damage(target.damage() - realDamage);`,
	# PointDefenseTurret.java:85, vs `target.remove();`,
	# PointDefenseTurret.java:87). `target.damage()` reads the bullet's
	# remaining-health field (`@Import float x, y, damage, lastX,
	# lastY, time, lifetime;`, BulletComp.java:31) and `target.remove()`
	# is BulletComp.java:83-91. The reset is `reloadCounter = 0;`
	# (PointDefenseTurret.java:97) -- reset-to-0, NOT `%= reload`
	# (that is the plain Turret, Turret.java:738). The effects and
	# sound (`Tmp.v1.trns(rotation, shootLength);` /
	# `beamEffect.at(x + Tmp.v1.x, y + Tmp.v1.y, rotation, color, new Vec2().set(target));` /
	# `shootEffect.at(x + Tmp.v1.x, y + Tmp.v1.y, rotation, color);` /
	# `hitEffect.at(target.x, target.y, color);` /
	# `shootSound.at(x + Tmp.v1.x, y + Tmp.v1.y, Mathf.random(0.9f, 1.1f));`,
	# PointDefenseTurret.java:90-95) are side effects: the pure
	# function spawns nothing and instead returns a shoot_event dict
	# (beam origin + rotation + target position) for the driver /
	# proof to verify; the sound pitch is random (0.9-1.1) so it is
	# NOT in the event. The beam origin uses Tmp.v1.trns(rotation,
	# shootLength) = (cos, sin) of rotation times shootLength (the
	# RepairTurret precedent, SourceRepairTurretBuildState.gd:320);
	# shootLength is the per-def segment value 5f (`shootLength = 5f;`,
	# Blocks.java:3843 -- the class default is `public float shootLength = 3f;`,
	# PointDefenseTurret.java:34) and is NOT a parameter of this
	# function (the RED signature pins the 12 params), so the event
	# uses the per-def 5f with this comment as its source. Class
	# defaults are shootCone 5f, bulletDamage 10f, shootLength 3f
	# (`public float shootCone = 5f;` / `public float bulletDamage = 10f;` /
	# `public float shootLength = 3f;`, PointDefenseTurret.java:31-33)
	# with rotateSpeed 20f and reload 30f from the ctor
	# (`rotateSpeed = 20f;` / `reload = 30f;`, PointDefenseTurret.java:38-39);
	# the segment per-def overrides are range 180f, shootLength 5f,
	# bulletDamage 30f, reload 8f (`range = 180f;` / `shootLength = 5f;` /
	# `bulletDamage = 30f;` / `reload = 8f;`, Blocks.java:3838-3846) --
	# the pure function takes them all as parameters (except the
	# shootLength above) and the driver passes the per-def values.
	var rotation: float = float(frame.get("rotation", 90.0))
	var reload_counter: float = float(frame.get("reload_counter", 0.0))
	var target_damage: float = float(target.get("damage", 0.0)) if target is Dictionary else 0.0
	if target == null or not (target is Dictionary):
		return {"rotation": rotation, "reload_counter": reload_counter, "dest": null, "shot": false, "damage_dealt": 0.0, "target_damage_after": target_damage, "target_removed": false, "shoot_event": null}
	if int(target.get("team", -1)) == team_id:
		return {"rotation": rotation, "reload_counter": reload_counter, "dest": null, "shot": false, "damage_dealt": 0.0, "target_damage_after": target_damage, "target_removed": false, "shoot_event": null}
	if not bool(target.get("has_type", false)):
		return {"rotation": rotation, "reload_counter": reload_counter, "dest": null, "shot": false, "damage_dealt": 0.0, "target_damage_after": target_damage, "target_removed": false, "shoot_event": null}
	if not bool(target.get("hittable", false)):
		return {"rotation": rotation, "reload_counter": reload_counter, "dest": null, "shot": false, "damage_dealt": 0.0, "target_damage_after": target_damage, "target_removed": false, "shoot_event": null}
	var dx: float = float(target.get("x", 0.0)) - x
	var dy: float = float(target.get("y", 0.0)) - y
	var dist2: float = dx * dx + dy * dy
	if dist2 >= range * range:
		return {"rotation": rotation, "reload_counter": reload_counter, "dest": null, "shot": false, "damage_dealt": 0.0, "target_damage_after": target_damage, "target_removed": false, "shoot_event": null}
	var dest: float = fmod(rad_to_deg(atan2(float(target.get("x", 0.0)) - x, float(target.get("y", 0.0)) - y)), 360.0)
	rotation = _move_toward_angle(rotation, dest, rotate_speed * edelta)
	reload_counter += edelta
	var shot: bool = false
	var damage_dealt: float = 0.0
	var target_damage_after: float = target_damage
	var target_removed: bool = false
	var shoot_event: Variant = null
	if _angle_dist(rotation, dest) <= shoot_cone and reload_counter >= reload:
		var real_damage: float = bullet_damage * block_damage_multiplier
		damage_dealt = real_damage
		shot = true
		if float(target.get("damage", 0.0)) > real_damage:
			target_damage_after = float(target.get("damage", 0.0)) - real_damage
		else:
			target_damage_after = 0.0
			target_removed = true
		var beam_x: float = x + cos(deg_to_rad(rotation)) * 5.0
		var beam_y: float = y + sin(deg_to_rad(rotation)) * 5.0
		shoot_event = {"beam_x": beam_x, "beam_y": beam_y, "rotation": rotation, "target_x": float(target.get("x", 0.0)), "target_y": float(target.get("y", 0.0))}
		reload_counter = 0.0
	return {"rotation": rotation, "reload_counter": reload_counter, "dest": dest, "shot": shot, "damage_dealt": damage_dealt, "target_damage_after": target_damage_after, "target_removed": target_removed, "shoot_event": shoot_event}

static func source_point_defense_turret_should_consume_state(frame: Dictionary) -> Dictionary:
	# PointDefenseBuild.shouldConsume() (PointDefenseTurret.java:105-107,
	# `public boolean shouldConsume(){` / `return super.shouldConsume() && target != null;`):
	# the super chain is PointDefenseBuild -> ReloadTurretBuild ->
	# BaseTurretBuild -> Building, and neither ReloadTurretBuild nor
	# BaseTurretBuild overrides shouldConsume, so super.shouldConsume()
	# is Building.shouldConsume() (BuildingComp.java:755-757,
	# `return enabled;`, with `transient boolean enabled = true;`,
	# BuildingComp.java:77). TurretBuild.shouldConsume()
	# (Turret.java:364, `return isShooting || reloadCounter < reload;`)
	# is NOT in the chain -- TurretBuild is a sibling branch,
	# PointDefenseBuild extends ReloadTurretBuild directly, so GREEN
	# must NOT use it. The gate is `enabled && target != null`,
	# read from the frame keys the tick (enabled, default true)
	# and N2239 (target, null when no target is stamped) already
	# carry. LIVE CONSEQUENCE (Java-faithful): until the bullet
	# wiring lands, the frame carries no `observed_bullets`, so
	# `target` stays null and `should_consume` is false -- the
	# segment consumes no power and efficiency folds to 0, exactly
	# like Java with no target in range (BuildingComp.java:1947,
	# `efficiency = ... shouldConsume() ? potentialEfficiency : 0f;`).
	# The N2151 "machinery runs with should_consume=true when
	# enabled" approximation ends with this slice.
	var should_consume: bool = bool(frame.get("enabled", true)) and frame.get("target", null) != null
	return {"should_consume": should_consume}

static func source_point_defense_turret_cooling_state(frame: Dictionary, has_coolant: bool, coolant_amount: float, coolant_efficiency: float, heat_capacity: float, coolant_multiplier: float, reload: float, edelta: float) -> Dictionary:
	# updateCooling() (ReloadTurret.java:28-38, called from
	# PointDefenseTurret.java:74-76 `if(coolant != null){` /
	# `updateCooling();` before the aim/shoot half): the gate
	# (`if(canReload() && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0){`,
	# ReloadTurret.java:29) uses canReload() = `reloadCounter < reload`
	# (`return reloadCounter < reload;`, ReloadTurret.java:46-48);
	# capacity is the consumed liquid's heatCapacity
	# (`float capacity = coolant instanceof ConsumeLiquidFilter filter ? filter.getConsumed(this).heatCapacity : (coolant.consumes(liquids.current()) ? liquids.current().heatCapacity : 0.4f);`,
	# ReloadTurret.java:30 -- ConsumeCoolant extends
	# ConsumeLiquidFilter, so the filter branch applies);
	# amount = `coolant.amount * coolant.efficiency(this)`
	# (`float amount = coolant.amount * coolant.efficiency(this);`,
	# ReloadTurret.java:31); `coolant.update(this);`
	# (ReloadTurret.java:32) removes `amount * edelta() * multiplier`
	# (`build.liquids.remove(liq, amount * build.edelta() * multiplier.get(build));`,
	# ConsumeLiquidFilter.java:44-49, multiplier default 1f,
	# `public Floatf<Building> multiplier = b -> 1f;`, Consume.java:18)
	# -- the pure function returns that as coolant_consumed for a
	# later wiring slice to apply, since the frame carries no liquid
	# inventory; the reload boost is `reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier();`
	# (ReloadTurret.java:33) with coolantMultiplier = 2f for
	# PointDefenseTurret (`coolantMultiplier = 2f;`,
	# PointDefenseTurret.java:42; the BaseTurret class default is 5f)
	# and ammoReloadMultiplier() = 1f (ReloadTurret.java:41-43).
	# The coolEffect chance (`if(Mathf.chance(0.06 * amount)){`,
	# ReloadTurret.java:35) is a random visual, NOT in the pure
	# function (the N2240 random-pitch precedent). Coolant
	# efficiency (ConsumeLiquidFilter.java:50-56) is
	# `return liq != null ? Math.min(build.liquids.get(liq) / (amount * ed * multiplier.get(build)), 1f) : 0f;`
	# over the getConsumed liquid, 0 when none -- passed in as a
	# parameter, like N2240's block_damage_multiplier. The
	# coolant is found by BaseTurret.init
	# (`coolant = findConsumer(c -> c instanceof ConsumeCoolant);`,
	# BaseTurret.java:50-52); the only PointDefenseTurret def,
	# segment (`segment = new PointDefenseTurret("segment"){{`,
	# Blocks.java:3835-3845, `consumePower(8f);` / `reload = 8f;`),
	# defines NO coolant consumer, so coolant stays null and the
	# driver call is a faithful no-op for segment. `edelta()` is
	# `efficiency * delta()` (BuildingComp.java:1927-1929,
	# `return efficiency * delta();`), passed in precomputed.
	# `cooling_applied` is false whenever the gate fails, and
	# `coolant_consumed` is 0.0 then; `reload_counter` is
	# unchanged when the gate fails.
	var reload_counter: float = float(frame.get("reload_counter", 0.0))
	var efficiency: float = float(frame.get("efficiency", 1.0))
	var cooling_applied: bool = false
	var coolant_consumed: float = 0.0
	if has_coolant and reload_counter < reload and coolant_efficiency > 0.0 and efficiency > 0.0:
		var amount: float = coolant_amount * coolant_efficiency
		coolant_consumed = amount * edelta
		reload_counter += amount * edelta * heat_capacity * coolant_multiplier
		cooling_applied = true
	return {"reload_counter": reload_counter, "cooling_applied": cooling_applied, "coolant_consumed": coolant_consumed}

@warning_ignore("unused_parameter")
static func source_point_defense_turret_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the point-defense tick wiring every tick
	# (PointDefenseBuild.updateTile(), PointDefenseTurret.java:62,
	# reads the folded efficiency for its rotation and reload; the
	# turret driver never ticks PointDefenseTurret implementations,
	# so this driver is the point-defense tick): each placed
	# PointDefenseTurret build gets its frame keys refreshed from
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
		if not _is_point_defense_turret_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_point_defense_turret_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_point_defense_turret_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2151 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a segment with a power consumer folds the pure power
		# row into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the edelta fold (PointDefenseTurret.java:81-82)
		# follows it. The power consumer counts toward hasConsumers
		# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
		# so a segment does not take the early return. A segment
		# with no power consumer is untouched: the tick models no
		# other consumers yet, and the shouldConsume gate
		# (PointDefenseTurret.java:105-107, `enabled && target !=
		# null` via source_point_defense_turret_should_consume_state)
		# now gates the machinery below -- a segment with no live
		# target consumes nothing and its efficiency folds to 0.
		# productionValid is the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(source_point_defense_turret_should_consume_state(frame).get("should_consume", false))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_point_defense_turret_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		# The retarget half of PointDefenseBuild.updateTile()
		# (PointDefenseTurret.java:65-71) runs every tick,
		# UNCONDITIONAL on power/enabled/cheating: Java updateTile
		# runs regardless -- only the aim/shoot half needs
		# efficiency (PointDefenseTurret.java:76-101, waits for
		# its own slice). The driver stamps the acquired target
		# live (the N2212 precedent) only once a caller provides
		# observed bullets: the live `game["bullets"]` dicts carry
		# no team/hittable/id yet, so the driver maps them in a
		# later wiring step and stamps nothing until then; a frame
		# without `observed_bullets` keeps whatever target it had
		# (the N2190 finding). The range is per-def 180f
		# (Blocks.java:3838, `range = 180f;`, the only
		# PointDefenseTurret def).
		if frame.has("observed_bullets"):
			var acquire: Dictionary = source_point_defense_turret_target_acquire_state(frame, frame.get("observed_bullets", []), team_id, sprite.position.x, sprite.position.y, 180.0, seconds)
			frame["target"] = acquire.get("target", null)
			frame["has_target"] = acquire.get("has_target", false)
			frame["target_timer"] = acquire.get("target_timer", 0.0)
			# The aim/shoot half of PointDefenseBuild.updateTile()
			# (PointDefenseTurret.java:76-101) runs in the same tick,
			# right after the retarget, on the just-acquired target
			# (the N2239 precedent): the pure function gates on the
			# target itself, so a tick with no target stamps the
			# unchanged rotation / reloadCounter and no shot. The
			# per-def segment values are range 180f, rotateSpeed 20f,
			# reload 8f, shootCone 5f, bulletDamage 30f
			# (Blocks.java:3838-3846, `range = 180f;` / `shootLength = 5f;` /
			# `bulletDamage = 30f;` / `reload = 8f;`, the only
			# PointDefenseTurret def; rotateSpeed 20f and shootCone 5f
			# are the class values, PointDefenseTurret.java:31-39).
			# blockDamageMultiplier is state.rules.blockDamage(team)
			# (Rules.java:299-300, `return blockDamageMultiplier * teams.get(team).blockDamageMultiplier;`),
			# read from the rules dict under the "blockDamage" key
			# (the SourceBulletTypeDamageState precedent) with the 1.0
			# Java default (Rules.java:113, `public float blockDamageMultiplier = 1f;`,
			# TeamRule default 1f, Rules.java:367); edelta is
			# efficiency * delta (BuildingComp.java:1927-1929,
			# `return efficiency * delta();`), the folded efficiency
			# the consumption branch stamped above (1.0 before the
			# first graph update, the assembler fold precedent).
			# The shot writes back live: a damaged target keeps its
			# remaining damage (the observed dict IS the live bullet
			# record, the N2239 precedent -- Java holds a live Bullet
			# reference over `public @Nullable Bullet target;`), a
			# lethally shot target is nulled this tick (the next
			# tick's acquire re-validates by id; the port models no
			# live bullet removal, a documented limit owned by a
			# later bullet-removal slice).
			var block_damage_multiplier: float = float(rules_state.get("blockDamage", 1.0)) if rules_state is Dictionary else 1.0
			var edelta: float = float(frame.get("efficiency", 1.0)) * seconds
			# The coolant call of PointDefenseBuild.updateTile()
			# (PointDefenseTurret.java:74-76, `if(coolant != null){ updateCooling(); }`)
			# runs BEFORE the aim/shoot half (:77-101), so its
			# reloadCounter boost feeds the shoot gate. The only
			# PointDefenseTurret def, segment, defines NO coolant
			# consumer (Blocks.java:3835-3845), so BaseTurret.init
			# leaves coolant null and the call is a faithful no-op
			# for segment: has_coolant=false, coolant_multiplier
			# the per-def 2.0 (PointDefenseTurret.java:42),
			# reload the per-def 8.0 (Blocks.java:3845), other
			# params 0.0. The pure function models the
			# class-level behavior with synthetic inputs in
			# tests/proof; the live liquid wiring waits for a
			# later slice.
			var cooling: Dictionary = source_point_defense_turret_cooling_state(frame, false, 0.0, 0.0, 0.0, 2.0, 8.0, edelta)
			frame["reload_counter"] = cooling.get("reload_counter", 0.0)
			var aim: Dictionary = source_point_defense_turret_aim_shoot_state(frame, frame.get("target", null), team_id, sprite.position.x, sprite.position.y, 180.0, 20.0, 8.0, 5.0, 30.0,
				block_damage_multiplier, edelta)
			frame["rotation"] = aim.get("rotation", 90.0)
			frame["reload_counter"] = aim.get("reload_counter", 0.0)
			frame["shot"] = aim.get("shot", false)
			frame["shoot_event"] = aim.get("shoot_event", null)
			var aim_target: Variant = frame.get("target", null)
			if aim_target is Dictionary:
				if bool(aim.get("target_removed", false)):
					frame["target"] = null
				elif bool(aim.get("shot", false)):
					aim_target["damage"] = aim.get("target_damage_after", 0.0)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
