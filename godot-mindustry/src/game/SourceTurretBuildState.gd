extends RefCounted
class_name SourceTurretBuildState

const source_turret_ammo_state := preload("res://src/game/SourceTurretAmmoState.gd")
const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

const SOURCE_TURRET_BUILD_INNER_CLASS := source_turret_source_text_state.SOURCE_TURRET_BUILD_INNER_CLASS
const SOURCE_TURRET_USE_AMMO_METHOD := source_turret_source_text_state.SOURCE_TURRET_USE_AMMO_METHOD
const SOURCE_TURRET_USE_AMMO_CHEATING_GUARD := source_turret_source_text_state.SOURCE_TURRET_USE_AMMO_CHEATING_GUARD

# Every block whose build is a TurretBuild: the three classes that
# extend Turret directly (ItemTurret.java:23, LiquidTurret.java:18,
# PowerTurret.java:8) and the two that extend them (LaserTurret
# extends PowerTurret, LaserTurret.java:15; ContinuousTurret extends
# Turret, ContinuousTurret.java:14). None of ItemTurretBuild,
# LiquidTurretBuild or PowerTurretBuild overrides updateTile, and
# LaserTurretBuild/ContinuousTurretBuild call super.updateTile()
# first (LaserTurret.java:67-68, ContinuousTurret.java:86-87), so
# TurretBuild.updateTile() (Turret.java:490) is the tick for all of
# them. ContinuousLiquidTurret is NOT here: it has its own driver
# (N2103). PointDefenseTurret extends ReloadTurret, TractorBeamTurret
# extends BaseTurret, RepairTurret extends Block and BuildTurret
# extends BaseTurret, so none of them is a TurretBuild.
const SOURCE_TURRET_BUILD_IMPLEMENTATIONS := ["ItemTurret", "LiquidTurret", "PowerTurret", "LaserTurret", "ContinuousTurret"]
const SOURCE_CONTINUOUS_LIQUID_TURRET_IMPLEMENTATION := "ContinuousLiquidTurret"
const SOURCE_TURRET_BUILDING_META_KEY := "source_turret_building"

static func _is_turret_build_implementation(implementation: String) -> bool:
	return SOURCE_TURRET_BUILD_IMPLEMENTATIONS.has(implementation)

static func source_turret_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:
	# The turret tick wires the frame keys the ammo path reads
	# (the N2102 pattern): block_implementation is the block's
	# implementation (Turret.java:36, `public class Turret extends
	# ReloadTurret{`), team_id and rules_state are what Java reads
	# as b.team and state.rules, and cheating is the team's live
	# TeamRule value (TeamComp.cheating(), TeamComp.java:17-19
	# `return team.rules().cheat;`, read through N2099's helper), so
	# a cheating team's turret skips ammo consumption like Java's
	# updateConsumption (BuildingComp.java:1944-1945, "everything is
	# valid when cheating"). A team with no rule keeps the false
	# default (Rules.java:328 TeamRule.cheat, default false).
	frame["block_implementation"] = block_implementation
	frame["team_id"] = team_id
	frame["rules_state"] = rules_state
	frame["cheating"] = bool(source_rules_state.source_team_cheating_state(rules_state, team_id).get("cheating", false))
	# Building.enabled (BuildingComp.java:77, `transient boolean
	# enabled = true;`) is what shouldConsume() returns
	# (BuildingComp.java:755-757), so the power graph reads it live
	# for this turret (N2125); the tick preserves a disabled turret
	# instead of resetting it, the factory pattern
	# (SourceFactoryBuildState.gd:927).
	frame["enabled"] = bool(frame.get("enabled", true))
	return frame

static func _initial_frame() -> Dictionary:
	return {}

static func source_turret_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:
	# Placement creates the Building (Block.java:1002 newBuilding);
	# the port's frame is that Building state, bound on the sprite
	# at placement through the Tile.setBlock proximity path (the same
	# path that binds the drill and ContinuousLiquidTurret frames).
	# A Turret-family sprite gets an empty frame bound; the live-loop
	# tick fills its keys every tick. Any other block, or an
	# already-bound sprite, binds nothing. A ContinuousLiquidTurret
	# binds nothing here: it has its own frame and driver (N2103).
	if block == null or not _is_turret_build_implementation(str(block.implementation)):
		return {"applied": false, "frame": {}}
	if sprite.has_meta(SOURCE_TURRET_BUILDING_META_KEY):
		return {"applied": false, "frame": sprite.get_meta(SOURCE_TURRET_BUILDING_META_KEY)}
	var frame: Dictionary = _initial_frame()
	sprite.set_meta(SOURCE_TURRET_BUILDING_META_KEY, frame)
	return {"applied": true, "frame": frame}

static func source_turret_use_ammo_state(frame: Dictionary, turret_properties: Dictionary, stacks: Array, total_ammo: int) -> Dictionary:
	# TurretBuild.useAmmo() (Turret.java:680-690): a cheating turret
	# returns its peek ammo without consuming anything
	# (`if(cheating()) return peekAmmo();`) — the live-loop tick sets
	# frame["cheating"] from the team's live TeamRule every tick, so
	# a cheating ItemTurret fires without spending ammo. Otherwise
	# the ammo is consumed through the registered stack path
	# (entry.amount -= ammoPerShot, pop when empty, totalAmmo -=
	# ammoPerShot clamped at 0, return entry.type()).
	# ItemTurretBuild does not override useAmmo (ItemTurret.java has
	# no useAmmo; its build inherits TurretBuild.useAmmo), while
	# LiquidTurretBuild and PowerTurretBuild override it with their
	# own cheating branches (N1201, N1170) and never reach this path.
	var cheating := bool(frame.get("cheating", false))
	if cheating:
		var peeked: Dictionary = source_turret_ammo_state.peek_turret_ammo_state(turret_properties, stacks)
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_BUILD_USE_AMMO_STATE,
			"inner_class": SOURCE_TURRET_BUILD_INNER_CLASS,
			"method": SOURCE_TURRET_USE_AMMO_METHOD,
			"cheating_guard_expr": SOURCE_TURRET_USE_AMMO_CHEATING_GUARD,
			"cheating": true,
			"returned_ammo": peeked.get("ammo_data", {}),
			"stacks_after": stacks,
			"total_ammo_after": total_ammo,
			"used": false,
		}
	var used: Dictionary = source_turret_ammo_state.use_turret_ammo_state(turret_properties, stacks, total_ammo)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_BUILD_USE_AMMO_STATE,
		"inner_class": SOURCE_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_TURRET_USE_AMMO_METHOD,
		"cheating_guard_expr": SOURCE_TURRET_USE_AMMO_CHEATING_GUARD,
		"cheating": false,
		"returned_ammo": used.get("ammo_data", {}),
		# The registered stack path names its result
		# "ammo_entries_after" (the ammo stacks after the shot);
		# the useAmmo contract calls them the stacks after.
		"stacks_after": used.get("ammo_entries_after", []),
		"total_ammo_after": int(used.get("total_ammo_after", total_ammo)),
		"used": bool(used.get("used", false)),
	}

static func source_turret_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary:
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
	# so a power turret does not take the early return. PowerTurret's
	# own live read is the same value (PowerTurret.java:30,
	# `return power == null ? 0f : power.status;`), and the
	# warmup fold is what the efficiency keys prove (Turret.java:512, `shootWarmup = Mathf.approachDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));`).
	# Documented limits: (1) the tick models no other consumers --
	# foreshadow's item ammo and lustre's liquid nitrogen are not
	# first-pass rows in this driver yet, so the folded efficiency
	# is the min over the *modeled* consumers (power only); those
	# rows wait for their own slices. (2) The shouldConsume gate
	# is wired by N2291 (source_turret_should_consume_state,
	# TurretBuild.shouldConsume(), Turret.java:364-366, `return
	# isShooting || reloadCounter < reload;`): the tick does not
	# track targeting/reload state yet, so the driver reads frame
	# defaults (is_shooting=false, reload_counter=0.0,
	# reload=10f) and the gate preserves should_consume=true
	# when enabled. `!enabled` is handled by the machinery's
	# disabled branch, not here.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

@warning_ignore("unused_parameter")
static func source_turret_should_consume_state(frame: Dictionary, is_shooting: bool, reload_counter: float, reload: float) -> Dictionary:
	# TurretBuild overrides shouldConsume (Turret.java:364-366):
	# `public boolean shouldConsume(){`
	# `return isShooting || reloadCounter < reload;`
	# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
	# (Turret.java:277), over the base default BuildingComp.shouldConsume
	# (BuildingComp.java:755-757): `public boolean shouldConsume(){`
	# `return enabled;`
	# updateConsumption forces efficiency to zero when the gate is false
	# (BuildingComp.java:1960): `boolean update = shouldConsume() && productionValid();`
	# (BuildingComp.java:1993): `efficiency = optionalEfficiency = 0f;`
	# The two inputs are TurretBuild fields: isShooting (Turret.java:292):
	# `public boolean wasShooting, isShooting;`
	# set in updateTile :492; and reloadCounter (ReloadTurret.java:26):
	# `public float reloadCounter;`
	# advanced in updateReload (Turret.java:720-723) and capped at reload
	# (Turret.java:723): `reloadCounter = Math.min(reloadCounter, reload);`
	# against the per-def reload time (ReloadTurret.java:10):
	# `public float reload = 10f;`
	# The same comparison is the canReload gate (ReloadTurret.java:50):
	# `return reloadCounter < reload;`
	# frame is accepted for the family call shape and reads no live frame
	# key: isShooting / reloadCounter / reload arrive as explicit params
	# (the N2188 precedent), because the tick frame tracks only
	# cheating / enabled / power_status / efficiency today. The comparison
	# is strict (< reload): a counter equal to reload is idle, matching
	# Java exactly.
	return {"should_consume": is_shooting or reload_counter < reload}

# TurretBuild.progress() (Turret.java:425-427):
# `public float progress(){`
# `return Mathf.clamp(reloadCounter / reload);`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277), over the base default BuildingComp.progress
# (BuildingComp.java:617-619): `public float progress(){`
# `return 0f;`
# The two inputs are the same reload pair N2291 wires for
# shouldConsume: reloadCounter (ReloadTurret.java:26):
# `public float reloadCounter;`
# advanced in updateReload (Turret.java:720-723) and capped at reload
# (Turret.java:723): `reloadCounter = Math.min(reloadCounter, reload);`
# against the per-def reload time (ReloadTurret.java:10):
# `public float reload = 10f;`
# arc Mathf.clamp with one argument clamps to [0, 1] (the
# MendProjector precedent, SourceMendProjectorState.gd:41:
# `clamp(charge / reload_value, 0.0, 1.0)`), so a counter past
# reload reads 1 and a negative counter reads 0. The only live
# consumer is sense() case progress (Turret.java:414):
# `case progress -> progress();`
# -- the assigned N2293 slice; setBars (Turret.java:192-202)
# never reads progress(). frame is accepted for the family call
# shape and reads no live frame key: reloadCounter / reload
# arrive as explicit params (the N2188 precedent),
# because the tick frame tracks only cheating / enabled /
# power_status / efficiency today. NO driver line: wiring frame
# defaults would stamp a constant 0.0 progress (0.0 / 10f),
# not a live value -- pure function only, the N2251 / N2252
# precedent; sense() (N2293) calls it with explicit params.
@warning_ignore("unused_parameter")
static func source_turret_progress_state(frame: Dictionary, reload_counter: float, reload: float) -> Dictionary:
	return {"progress": clampf(reload_counter / reload, 0.0, 1.0)}

# TurretBuild.sense() (Turret.java:406-419):
# `public double sense(LAccess sensor){`
# `return switch(sensor){`
# `case ammo -> totalAmmo;`
# `case ammoCapacity -> maxAmmo;`
# `case rotation -> rotation;`
# `case shootX -> World.conv(targetPos.x);`
# `case shootY -> World.conv(targetPos.y);`
# `case shooting -> isShooting ? 1 : 0;`
# `case progress -> progress();`
# `default -> super.sense(sensor);`
# `};`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277), over the base default BuildingComp.sense
# (BuildingComp.java:2093): `public double sense(LAccess sensor){`
# whose default is `default -> Float.NaN; //gets converted to null in logic`
# (BuildingComp.java:2123). The sensor spellings are the LAccess
# enum names `ammo,` (LAccess.java:18), `ammoCapacity,` (:19),
# `progress,` (:28), `rotation,` (:30), `shootX,` (:35),
# `shootY,` (:36), `shooting,` (:49). The inputs are TurretBuild
# fields: totalAmmo (Turret.java:283, `public int totalAmmo;`),
# maxAmmo (Turret.java:47, `public int maxAmmo = 30;`), targetPos
# (Turret.java:290, `public Vec2 targetPos = new Vec2();`),
# isShooting (Turret.java:292, `public boolean wasShooting,
# isShooting;`), and rotation, the Building int rotation
# (BuildingComp.java:69, `transient int rotation;`). World.conv
# (World.java:165-166, `public static float conv(float coord){`
# / `return coord / tilesize;`) divides by tilesize (Vars.java:135,
# `public static final int tilesize = 8;`). The progress case calls
# the N2292 pure function (`return Mathf.clamp(reloadCounter /
# reload);`, Turret.java:426) with explicit params (reloadCounter,
# ReloadTurret.java:26, `public float reloadCounter;`; reload,
# ReloadTurret.java:10, `public float reload = 10f;`). All live
# values arrive as explicit params (the N2188 precedent),
# because the tick frame tracks only cheating / enabled /
# power_status / efficiency today. NO driver line: sense is a logic
# read, not a tick write (the N2206 / N2208 / N2223 precedent); the
# logic-processor dispatch hook is its own later slice. The default
# leg falls through to super.sense, so it returns handled=false
# with a null NaN value for the caller to fall through.
@warning_ignore("unused_parameter")
static func source_turret_sense_state(frame: Dictionary, sensor: String, total_ammo: int, max_ammo: int, rotation: int, target_pos: Vector2, is_shooting: bool, reload_counter: float, reload: float, tilesize: float) -> Dictionary:
	match sensor:
		"ammo":
			return {"handled": true, "sense_value": float(total_ammo), "sense_value_is_nan": false}
		"ammoCapacity":
			return {"handled": true, "sense_value": float(max_ammo), "sense_value_is_nan": false}
		"rotation":
			return {"handled": true, "sense_value": float(rotation), "sense_value_is_nan": false}
		"shootX":
			return {"handled": true, "sense_value": target_pos.x / tilesize, "sense_value_is_nan": false}
		"shootY":
			return {"handled": true, "sense_value": target_pos.y / tilesize, "sense_value_is_nan": false}
		"shooting":
			return {"handled": true, "sense_value": 1.0 if is_shooting else 0.0, "sense_value_is_nan": false}
		"progress":
			return {"handled": true, "sense_value": float(source_turret_progress_state(frame, reload_counter, reload).get("progress", 0.0)), "sense_value_is_nan": false}
	return {"handled": false, "sense_value": null, "sense_value_is_nan": true}

# TurretBuild.fogRadius() (Turret.java:420-423):
# `public float fogRadius(){`
# `return (range + (hasAmmo() ? peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier;`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). The range is the BaseTurret def range
# (BaseTurret.java:21, `public float range = 80f;`) and the
# multiplier is the BaseTurret def fogRadiusMultiplier
# (BaseTurret.java:24, `public float fogRadiusMultiplier = 1f;`) on
# `public class BaseTurret extends Block{` (BaseTurret.java:20).
# tilesize is the world constant (Vars.java:135, `public static
# final int tilesize = 8;`); the ammo range change is the peeked
# bullet's rangeChange (BulletType.java:157, `public float rangeChange = 0f;`, default 0f).
# Unlike range() (Turret.java:342-345, `public float range(){` with `return range + peekAmmo().rangeChange;`),
# which adds rangeChange whenever peekAmmo() is non-null
# (Turret.java:693, `public @Nullable BulletType peekAmmo(){`), fogRadius() adds it only when hasAmmo()
# (Turret.java:698, `public boolean hasAmmo(){`) -- the stricter
# gate (ammo present, enough for a shot, canConsume,
# Turret.java:698-712) -- so the pure function takes has_ammo as
# an explicit bool, not a peeked bullet. The accessor is what the
# fog system reads (FogControl.java:161,
# `Mathf.round(build.fogRadius())`; FogRenderer.java:68,
# `build.fogRadius() * tilesize`); the fog system itself waits for
# its own slice. All live values arrive as explicit params (the
# N2188 precedent), because the tick frame tracks only
# cheating / enabled / power_status / efficiency today. Ammo
# absent preserves the base range: has_ammo false adds 0f (the
# N2291/N2292 absent-preserves precedent). NO driver line:
# fogRadius() is a load-time accessor the fog system reads, not a
# per-tick write (the N2249 precedent).
@warning_ignore("unused_parameter")
static func source_turret_fog_radius_state(frame: Dictionary, range: float, has_ammo: bool, ammo_range_change: float, tilesize: float, fog_radius_multiplier: float) -> Dictionary:
	return {"fog_radius": (range + (ammo_range_change if has_ammo else 0.0)) / tilesize * fog_radius_multiplier}

# TurretBuild.updateTile() warmup advance (Turret.java:502-515):
# `float warmupTarget = (isShooting && canConsume()) || charging() ? 1f : 0f;`
# `if(warmupTarget > 0 && !controlled()){`
# `warmupHold = 1f;`
# `}`
# `if(warmupHold > 0f){`
# `warmupHold -= Time.delta / warmupMaintainTime;`
# `warmupTarget = 1f;`
# `}`
# `if(linearWarmup){`
# `shootWarmup = Mathf.approachDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));`
# `}else{`
# `shootWarmup = Mathf.lerpDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277), inside `public void updateTile(){` (Turret.java:490).
# canConsume() is the TurretBuild override (Turret.java:624-629,
# `public boolean canConsume(){` /
# `if(heatRequirement > 0 && heatReq <= 0f){` /
# `return false;` / `return super.canConsume();`) over the
# BuildingComp gate (BuildingComp.java:1917-1919,
# `public boolean canConsume(){` / `return potentialEfficiency > 0;`).
# heatRequirement is per-def (Turret.java:53,
# `public float heatRequirement = -1f;`; 20f on afflict and 144f on
# malign, Blocks.java:5122/6240) and heatReq is the live field
# (Turret.java:295, `public float heatReq;`), refreshed each tick
# (Turret.java:538-539, `if(heatRequirement > 0){` /
# `heatReq = calculateHeat(sideHeat);`); both arrive as explicit
# params, so a cold heat turret (heatReq <= 0) cannot consume
# even while shooting with power, while a turret with no heat
# requirement (-1f default) ignores heatReq entirely. charging()
# is Turret.java:715-717 (`public boolean charging(){` /
# `return queuedBullets > 0 && shoot.firstShotDelay > 0;`); controlled()
# is Turret.java:441-443 (`public boolean controlled(){` /
# `return unit.isPlayer();`). The hold / warmup fields are Turret.java:286
# (`public float shootWarmup, charge, warmupHold = 0f;`); the per-def knobs
# are warmupMaintainTime (Turret.java:84,
# `public float warmupMaintainTime = 0f;`, `warmupMaintainTime = 120f;` on
# titan / smite / malign, Blocks.java:4803/5909/6242), shootWarmupSpeed
# (Turret.java:136, `public float shootWarmupSpeed = 0.1f;`,
# `shootWarmupSpeed = 0.04f;` on smite, Blocks.java:5904) and linearWarmup
# (Turret.java:138, `public boolean linearWarmup = false;`, no def sets it
# true). The folded efficiency is BuildingComp.java:85
# (`transient float efficiency;`).
# The approach / lerp legs reuse the ported SourceMathState helpers (N489/N490,
# source_approach_delta / source_lerp_delta), which already encode arc
# Mathf.approachDelta / lerpDelta (arc Mathf.java:420/430). The set and the decay
# run in the SAME tick: a hold set to 1f is decayed by Time.delta /
# warmupMaintainTime before the warmupTarget = 1f force, so a fresh hold reads
# 1 - delta/maintain, not 1. With the default warmupMaintainTime 0f the Java float
# division yields Infinity and the hold goes to -Infinity in the same tick -- the
# pure function keeps that behavior, no invented guard. The lerp leg is the
# default (linearWarmup false on every def); the approach leg is the linearWarmup
# branch. The rate folds efficiency only while the target is positive
# (`warmupTarget > 0 ? efficiency : 1f`), so a decaying warmup ignores efficiency.
# All live values arrive as explicit params (the N2188 precedent), because the
# tick frame tracks only cheating / enabled / power_status / efficiency today:
# is_shooting is set by updateTile :492 (not ported yet), charging / controlled read
# reload / unit state the frame does not track yet, and the frame tracks no
# shoot_warmup / warmup_hold keys yet. NO driver line: the driver waits until those
# frame keys are tracked (the N2294 updateTile precedent); the warmup fold the
# power-status row mentions (Turret.java:512-514) is this advance, called with
# explicit params. delta is Time.delta through delta() (BuildingComp.java:1922-1923,
# `public float delta(){` / `return Time.delta * timeScale;`), raw tick seconds, the
# N2248 convention.
@warning_ignore("unused_parameter")
static func source_turret_update_tile_warmup_state(frame: Dictionary, is_shooting: bool, potential_efficiency: float, charging: bool, controlled: bool, warmup_hold: float, shoot_warmup: float, linear_warmup: bool, shoot_warmup_speed: float, efficiency: float, warmup_maintain_time: float, delta: float, heat_requirement: float, heat_req: float) -> Dictionary:
	var can_consume: bool = potential_efficiency > 0.0 and not (heat_requirement > 0.0 and heat_req <= 0.0)
	var warmup_target: float = 1.0 if (is_shooting and can_consume) or charging else 0.0
	var new_warmup_hold: float = warmup_hold
	if warmup_target > 0.0 and not controlled:
		new_warmup_hold = 1.0
	if new_warmup_hold > 0.0:
		new_warmup_hold -= delta / warmup_maintain_time
		warmup_target = 1.0
	var rate: float = shoot_warmup_speed * (efficiency if warmup_target > 0.0 else 1.0)
	var new_shoot_warmup: float
	if linear_warmup:
		new_shoot_warmup = source_math_state.source_approach_delta(shoot_warmup, warmup_target, rate, delta)
	else:
		new_shoot_warmup = source_math_state.source_lerp_delta(shoot_warmup, warmup_target, rate, delta)
	return {"warmup_target": warmup_target, "warmup_hold": new_warmup_hold, "shoot_warmup": new_shoot_warmup}

# TurretBuild.updateTile() remaining driver-tick legs (Turret.java:494-499,
# :548-557, :566-608):
# `if(unit.isPlayer()){ //there's no reason to update this when a player isn't controlling it`
# `unit.ammo(getAmmoFraction());`
# `soundLoop.update(x, y, shouldActiveSound(), activeSoundVolume());`
# `if(reloadWhileCharging || !charging()){`
# `updateReload();`
# `if(state.rules.fog){`
# `float newRange = hasAmmo() ? peekAmmo().rangeChange : 0f;`
# `if(newRange != lastRangeChange){`
# `lastRangeChange = newRange;`
# `fogControl.forceUpdate(team, this);`
# `if(hasAmmo()){`
# `if(Float.isNaN(reloadCounter)) reloadCounter = 0;`
# `if(timer(timerTarget, target != null ? newTargetInterval : targetInterval)){`
# `findTarget();`
# `boolean canShoot;`
# `if(controlled()){ //player behavior`
# `targetPos.set(unit.aimX(), unit.aimY());`
# `canShoot = unit.isShooting();`
# `}else if(logicControlled()){ //logic behavior`
# `canShoot = logicShooting;`
# `}else{ //default AI behavior`
# `if(!controlled()){`
# `unit.aimX(targetPos.x);`
# `unit.aimY(targetPos.y);`
# `if(alwaysShooting){`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277), inside `public void updateTile(){` (Turret.java:490).
# The guard lines are registered with their Java trailing comments, so they
# are distinct from the same bare text owned elsewhere (`if(unit.isPlayer()){`
# alone is N1899 BuildingComp.handleUnitPayload; `}else{` alone is owned by
# sixteen slices). NOT registered here: `updateCooling();` (N2241),
# `wasShooting = true;` (N2362), `updateShooting();` (remote N2269),
# `if(soundLoop != null){` (N2350). Call-sites already owned arrive as
# Callables/params, never re-registered: updateReload/updateCooling (N2241),
# findTarget (N2316), validateTarget/charging/controlled/logicControlled
# (N2324/N2297), getAmmoFraction (N2348/N2355),
# shouldActiveSound/activeSoundVolume (N2346).
# getAmmoFraction() is Turret.java:324-326 (`public float getAmmoFraction(){` /
# `return 1f;`, "ammo as a fraction of capacity; used for direct turret control
# HUD"); the unit ammo write only runs for a player-controlled unit, so a
# non-player unit applies nothing (null). soundLoop is the nullable
# TurretBuild field (Turret.java:298, `public @Nullable SoundLoop
# soundLoop = (loopSound == Sounds.none ? null : new SoundLoop(loopSound,
# loopSoundVolume));`); the update call passes the build position plus
# shouldActiveSound() (Turret.java:826-828, `public boolean
# shouldActiveSound(){` / `return shootWarmup > 0.01f && loopSound !=
# Sounds.none;`) and activeSoundVolume() (Turret.java:822-824, `public float
# activeSoundVolume(){` / `return shootWarmup;`), both N2346, so an absent
# loop carries a null update. reloadWhileCharging is the per-def flag
# (Turret.java:82, `public boolean reloadWhileCharging = true;`); charging()
# is Turret.java:715-717 (`public boolean charging(){` / `return queuedBullets
# > 0 && shoot.firstShotDelay > 0;`); the gate opens whenever the turret is
# not charging, or while charging when the def allows it, and updateReload()
# (Turret.java:719-720, body N2241) is a call-site: the frame records that it
# was called, never re-ports its body. The fog leg reads state.rules.fog and
# the peeked ammo range change (peekAmmo().rangeChange, Turret.java:344);
# with no ammo the new range is 0f, and fogControl.forceUpdate(team, this)
# (FogControl.java:177) runs only when the range actually changed.
# lastRangeChange is the TurretBuild field (Turret.java:300, `float
# lastRangeChange;`). The hasAmmo block first normalizes a NaN reloadCounter
# to 0 (Float.isNaN, the Java float check), then fires findTarget() (body
# N2316) only when the target timer is ready (timer() is TimerComp.java:10,
# `public boolean timer(int index, float time){`; timerTarget is
# Turret.java:40, `public final int timerTarget = timers++;`, and the
# interval is newTargetInterval with a target, targetInterval without --
# Turret.java:42-44, `public float targetInterval = 20;`). Inside a valid
# target the player branch sets targetPos from the unit aim and reads
# canShoot from unit.isShooting(); the logic branch reads canShoot from
# logicShooting (Turret.java:288, `public boolean logicShooting = false;`);
# the default-AI branch (targetPosition/within, remote N2250) is NOT ported,
# so can_shoot stays null there -- the frame never invents a within() read.
# The aim write runs exactly when !controlled(), after the branch, on the
# (possibly updated) targetPos (targetPos is Turret.java:290, `public Vec2
# targetPos = new Vec2();`; controlled() is Turret.java:441-443, `public
# boolean controlled(){` / `return unit.isPlayer();`; logicControlled() is
# Turret.java:445-447). alwaysShooting is the per-def flag (Turret.java:103,
# `public boolean alwaysShooting = false;`); only its gate is recorded --
# wasShooting = true and updateShooting() inside it belong to N2362 /
# remote N2269. All live values arrive as explicit params (the N2188
# precedent): the tick frame tracks no ammo/sound/reload/fog/target keys yet,
# so there is NO driver tick line (the N2308/N2294 updateTile precedent);
# the driver waits until those frame keys are tracked. Proof asserts frame
# only, never a real shot.
@warning_ignore("unused_parameter")
static func source_turret_update_tile_driver_state(frame: Dictionary, is_player: bool, ammo_fraction: float, has_sound_loop: bool, x: float, y: float, should_active_sound: bool, active_sound_volume: float, reload_while_charging: bool, charging: bool, fog: bool, has_ammo: bool, ammo_range_change: float, last_range_change: float, reload_counter: float, timer_target_ready: bool, validate_target: bool, controlled: bool, logic_controlled: bool, target_pos: Vector2, unit_aim_x: float, unit_aim_y: float, unit_is_shooting: bool, logic_shooting: bool, always_shooting: bool) -> Dictionary:
	var unit_ammo_fraction: Variant = ammo_fraction if is_player else null
	var sound_loop_update: Variant = null
	if has_sound_loop:
		sound_loop_update = {"x": x, "y": y, "active": should_active_sound, "volume": active_sound_volume}
	var reload_gate_open: bool = reload_while_charging or not charging
	var update_reload_called: bool = reload_gate_open
	var new_last_range_change: float = last_range_change
	var fog_range_changed := false
	var fog_force_update_called := false
	if fog:
		var new_range: float = ammo_range_change if has_ammo else 0.0
		if new_range != last_range_change:
			new_last_range_change = new_range
			fog_range_changed = true
			fog_force_update_called = true
	var new_reload_counter: float = reload_counter
	var find_target_called := false
	var new_target_pos: Vector2 = target_pos
	var can_shoot: Variant = null
	var new_unit_aim_x: float = unit_aim_x
	var new_unit_aim_y: float = unit_aim_y
	var always_shooting_gate := false
	if has_ammo:
		if is_nan(new_reload_counter):
			new_reload_counter = 0.0
		if timer_target_ready:
			find_target_called = true
		if validate_target:
			if controlled:
				new_target_pos = Vector2(unit_aim_x, unit_aim_y)
				can_shoot = unit_is_shooting
			elif logic_controlled:
				can_shoot = logic_shooting
			else:
				# Default AI behavior: targetPosition(target) /
				# canShoot = within(...) is remote N2250 -- not
				# ported, so can_shoot stays null.
				pass
			if not controlled:
				new_unit_aim_x = new_target_pos.x
				new_unit_aim_y = new_target_pos.y
		if always_shooting:
			always_shooting_gate = true
	return {"unit_ammo_fraction": unit_ammo_fraction, "sound_loop_update": sound_loop_update, "reload_gate_open": reload_gate_open, "update_reload_called": update_reload_called, "last_range_change": new_last_range_change, "fog_range_changed": fog_range_changed, "fog_force_update_called": fog_force_update_called, "reload_counter": new_reload_counter, "find_target_called": find_target_called, "target_pos": new_target_pos, "can_shoot": can_shoot, "unit_aim_x": new_unit_aim_x, "unit_aim_y": new_unit_aim_y, "always_shooting_gate": always_shooting_gate}

# TurretBuild.estimateDps() (Turret.java:329-332):
# `public float estimateDps(){`
# `if(!hasAmmo()) return 0f;`
# `return shoot.shots / reload * 60f * (peekAmmo() == null ? 0f : peekAmmo().estimateDPS()) * potentialEfficiency * timeScale;`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). The shots are the ShootPattern def shots
# (ShootPattern.java:9, `public int shots = 1;`, default 1; def
# salvo has shots > 1) and the reload is the ReloadTurret def
# reload (ReloadTurret.java:10, `public float reload = 10f;`).
# The potential efficiency is the BuildingComp field
# (BuildingComp.java:89, `transient float potentialEfficiency;`,
# Java default 0.0f, machinery-set later) and the time scale is
# Time.timeScale through delta() (BuildingComp.java:1922-1923,
# `public float delta(){` / `return Time.delta * timeScale;`).
# The peeked bullet's DPS is BulletType.estimateDPS()
# (BulletType.java:414, `public float estimateDPS(){`, recursive
# over spawnUnit / despawnUnit / fragBullet / spawnBullets with
# the cachedDps cache). hasAmmo() (Turret.java:698, `public
# boolean hasAmmo(){`) has a side effect -- it swaps the ammo
# queue when the first entry is short (Turret.java:698-712) --
# so the pure function takes has_ammo as an explicit bool, never
# calls hasAmmo(). peekAmmo() (Turret.java:693, `public
# @Nullable BulletType peekAmmo(){`) is likewise not ported here:
# the caller passes the peeked bullet's DPS explicitly (0.0 when
# peekAmmo() is null, the Java ternary leg). All live values
# arrive as explicit params (the N2188 precedent), because the
# tick frame tracks only cheating / enabled / power_status /
# efficiency today. No ammo returns 0.0 (the Java early return);
# reload = 0 keeps the Java float-division behavior (Infinity
# for a nonzero numerator) -- no invented guard. NO driver line:
# estimateDps() is a read accessor the RTS AI calls
# (RtsAI.java:336, `dps[0] += t.estimateDps();`), not a
# per-tick write (the N2244/N2249 precedent); the AI caller
# waits for its own slice.
@warning_ignore("unused_parameter")
static func source_turret_estimate_dps_state(frame: Dictionary, has_ammo: bool, shots: int, reload: float, peek_ammo_estimate_dps: float, potential_efficiency: float, time_scale: float) -> Dictionary:
	return {"estimate_dps": 0.0 if not has_ammo else float(shots) / reload * 60.0 * peek_ammo_estimate_dps * potential_efficiency * time_scale}

# TurretBuild.canHeal() (Turret.java:635-637):
# `protected boolean canHeal(){`
# `return targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals();`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). targetHealing is the def flag (Turret.java:95,
# `public boolean targetHealing = false;`); hasAmmo() is the gate
# (Turret.java:698, `public boolean hasAmmo(){`) with its ammo-swap
# side effect (Turret.java:698-712), so the pure function takes
# has_ammo as an explicit bool, never calls hasAmmo(). peekAmmo()
# (Turret.java:693, `public @Nullable BulletType peekAmmo(){`) is
# likewise not ported here: the caller passes the peeked bullet's
# flags explicitly -- collidesTeam (BulletType.java:127,
# `public boolean collidesTeam = false;`) and heals()
# (BulletType.java:447, `public boolean heals(){`). Java calls
# peekAmmo() twice but hasAmmo() short-circuits first, so a null
# peek never reaches the field reads; the explicit bools carry the
# same short-circuit (they are meaningful only when has_ammo).
# All live values arrive as explicit params (the N2188 precedent),
# because the tick frame tracks no ammo state yet. NO driver line:
# canHeal() is a predicate the targeting chain reads, not a tick
# write; findTarget() (:651-663) and validateTarget() (:631-633)
# call it with explicit params below.
@warning_ignore("unused_parameter")
static func source_turret_can_heal_state(frame: Dictionary, target_healing: bool, has_ammo: bool, peek_collides_team: bool, peek_heals: bool) -> Dictionary:
	return {"can_heal": target_healing and has_ammo and peek_collides_team and peek_heals}

# Units.invalidateTarget() (Units.java:151-158), the 4-arg overload
# validateTarget() calls (Units.java:160-162,
# `return invalidateTarget(target, team, x, y, Float.MAX_VALUE);`):
# `public static boolean invalidateTarget(Posc target, Team team, float x, float y, float range){`
# `return target == null ||`
# `(range != Float.MAX_VALUE && !target.within(x, y, range + (target instanceof Sized hb ? hb.hitSize()/2f : 0f))) ||`
# `(target instanceof Teamc t && t.team() == team) ||`
# `(target instanceof Healthc h && !h.isValid()) ||`
# `(target instanceof Unit u && !u.targetable(team));`
# Called with range Float.MAX_VALUE, the within-range branch is
# dead (`range != Float.MAX_VALUE` is false), so only four observed
# flags remain: the target is null, the target is a Teamc on the
# team argument, the target is a Healthc that is not valid, or the
# target is a Unit that is not targetable by that team. The team
# argument is Team.derelict when canHeal() holds, else the turret
# team (Turret.java:632) -- the driver computes target_same_team
# against that team; the pure function never hard-codes a team id.
# The driver computes the flags per the instanceof semantics (a
# null target makes the other three false); the live Units query
# itself stays on the driver side. NO driver line: the invalidation
# is a predicate the updateTile driver reads (:491/:573), not a
# tick write of its own.
@warning_ignore("unused_parameter")
static func source_turret_invalidate_target_state(frame: Dictionary, target_is_null: bool, target_same_team: bool, target_health_invalid: bool, target_unit_not_targetable: bool) -> Dictionary:
	return {"target_invalid": target_is_null or target_same_team or target_health_invalid or target_unit_not_targetable}

# TurretBuild.validateTarget() (Turret.java:631-633):
# `protected boolean validateTarget(){`
# `return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). controlled() is Turret.java:441-443
# (`public boolean controlled(){` / `return unit.isPlayer();`) and
# logicControlled() is Turret.java:445-447
# (`public boolean logicControlled(){` / `return logicControlTime > 0;`)
# -- controlled() is its own slice (N2324) and logicControlled() is
# N2297; both arrive here as explicit bools (the N2188
# precedent), because the tick frame tracks no unit/player or logic
# key yet. A target that is still valid keeps the turret on it; an
# invalid target is kept only while a player or logic controls the
# turret. NO driver line: updateTile calls validateTarget() at :491
# and :573 -- the driver is its own later slice.
@warning_ignore("unused_parameter")
static func source_turret_validate_target_state(frame: Dictionary, target_invalid: bool, is_controlled: bool, is_logic_controlled: bool) -> Dictionary:
	return {"validate_target": (not target_invalid) or is_controlled or is_logic_controlled}

# TurretBuild.isActive() (Turret.java:449-451):
# `public boolean isActive(){`
# `return (target != null || wasShooting) && enabled && activationTimer <= 0;`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). The three inputs are TurretBuild /
# BaseTurretBuild / BuildingComp fields: target
# (`public @Nullable Posc target;`, Turret.java:289),
# wasShooting (`public boolean wasShooting, isShooting;`,
# Turret.java:292, set in updateTile :517/:600/:608 from the
# previous tick's shooting state), enabled
# (`transient boolean enabled = true;`, BuildingComp.java:77),
# and activationTimer (`public float activationTimer = 0;`,
# BaseTurret.java:115, set to activationTime on placed(),
# BaseTurret.java:120 `activationTimer = activationTime;`,
# against `public float activationTime = 0f;`,
# BaseTurret.java:27 -- the placement delay before a turret
# starts shooting). The BaseTurretBuild class line is
# `public class BaseTurretBuild extends Building implements Ranged, RotBlock{`
# (BaseTurret.java:113). The target arrives as the explicit bool
# target_is_null (the invalidateTarget :488 precedent);
# wasShooting arrives as the explicit bool is_shooting (the
# should_consume :164 / sense :267 / update_tile_warmup :384
# precedent -- the param is named is_shooting per the family
# convention, but for isActive() it carries wasShooting);
# activationTimer arrives as the explicit float
# activation_timer (the frame tracks no activation timer key
# -- _initial_frame() returns {} and the file has no
# activation_timer key); enabled is read from the frame (the
# tick frame stamps frame["enabled"], default true, matching
# the Java field default). The comparison is `<= 0`: a timer
# of exactly 0 is active, matching Java exactly. NO driver
# line: isActive() is a predicate the tick driver reads, not
# a tick write of its own -- wiring it into the driver waits
# for its own slice. isActive() has no caller inside
# Turret.java; its live callers (sound/status paths) are
# their own slices.
@warning_ignore("unused_parameter")
static func source_turret_is_active_state(frame: Dictionary, target_is_null: bool, is_shooting: bool, activation_timer: float) -> Dictionary:
	return {"is_active": (not target_is_null or is_shooting) and bool(frame.get("enabled", true)) and activation_timer <= 0}

# TurretBuild.shouldTurn() (Turret.java:669-671):
# `public boolean shouldTurn(){`
# `return moveWhileCharging || !charging();`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). moveWhileCharging is the Turret def field
# (Turret.java:80, `public boolean moveWhileCharging = true;`)
# and arrives as the explicit bool move_while_charging (the
# N2311/N2261 precedent -- a def field, not build state).
# charging() (Turret.java:715-717, `public boolean charging(){`
# / `return queuedBullets > 0 && shoot.firstShotDelay > 0;`)
# is NOT re-ported here: the caller passes its result as the
# explicit bool charging (the N2311/N2340 precedent -- the
# caller passes the live value); remote N2269 owns charging()
# (dedup at merge). The frame carries no tracked key for this
# predicate (the minRange :593 precedent -- the tick frame
# tracks no charging state yet), so all live values arrive as
# explicit params. NO driver line: shouldTurn() is a predicate
# the updateTile() tick driver reads (:595 `if(shouldTurn()){`
# before turnToTarget(targetRot)) -- wiring it into the driver
# waits for the updateTile() caller slice.
@warning_ignore("unused_parameter")
static func source_turret_should_turn_state(frame: Dictionary, move_while_charging: bool, charging: bool) -> Dictionary:
	return {"should_turn": move_while_charging or not charging}

# TurretBuild.minRange() (Turret.java:334-339):
# `public float minRange(){`
# `if(peekAmmo() != null){`
# `return minRange + peekAmmo().minRangeChange;`
# `}`
# `return minRange;`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). The def minimum is the Turret field
# (Turret.java:74, `public float minRange = 0f;`,
# "Minimum bullet range. Used for artillery only."). The ammo
# change is the peeked bullet's minRangeChange
# (BulletType.java:163, `public float minRangeChange = 0f;`,
# default 0f, "When used in a turret with multiple ammo types,
# this can be set to a non-zero value to influence minRange")
# on `public class BulletType extends Content implements Cloneable{`
# (BulletType.java:29). The gate is peekAmmo() != null
# (Turret.java:693, `public @Nullable BulletType peekAmmo(){` /
# `return ammo.size == 0 ? null : ammo.peek().type();`), NOT
# hasAmmo() (Turret.java:698, `public boolean hasAmmo(){`),
# which has the ammo-swap side effect (Turret.java:698-712)
# and can be false while peekAmmo() is non-null -- so the pure
# function takes has_ammo as an explicit bool carrying the
# peekAmmo() null check (the isActive :509 precedent, where the
# param is_shooting carries wasShooting), never calls
# hasAmmo(). peekAmmo() is likewise not ported here: the caller
# passes the peeked bullet's minRangeChange explicitly (0.0 when
# peekAmmo() is null, the Java fall-through leg). All live values
# arrive as explicit params (the N2188 precedent), because the
# tick frame tracks no ammo state yet. No ammo returns the bare
# def minimum (the Java fall-through leg); with ammo the change
# is added even when it is 0f (the BulletType default). NO
# driver line: minRange() is a read accessor its callers read,
# not a per-tick write (the N2249 precedent) -- drawSelect()
# reads it for the min-range dash circle (Turret.java:485,
# `Drawf.dashCircle(x, y, minRange(), team.color);`) and the
# shoot leg clamps the bullet life scale with it
# (Turret.java:787, `Mathf.clamp(..., minRange() / type.range,
# range() / type.range)`); both callers wait for their own
# slices. (drawPlace() :253 reads the minRange FIELD directly,
# `Drawf.dashCircle(..., minRange, Pal.placing);`, already
# ported as N1162 turret_draw_place.min_range -- that is the
# field, not this method.)
@warning_ignore("unused_parameter")
static func source_turret_min_range_state(frame: Dictionary, min_range: float, has_ammo: bool, ammo_min_range_change: float) -> Dictionary:
	return {"min_range": min_range + ammo_min_range_change if has_ammo else min_range}

# TurretBuild.isShooting() (Turret.java:429-432):
# `public boolean isShooting(){`
# `return isShooting;`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). The field is the TurretBuild field
# (`public boolean wasShooting, isShooting;`, Turret.java:292)
# and arrives as the explicit bool is_shooting (the
# shouldConsume :364 / sense :413 / warmup :502 precedent --
# the field name collides with the method name, so the GD
# param is is_shooting, never isShooting). The field is
# written by updateTile :492 (`isShooting = alwaysShooting ||
# (unit.controller() instanceof Player ? unit.isShooting() :
# logicControlled() ? logicShooting : target != null);`) --
# NOT ported here: this slice only reads the field. The frame
# carries no tracked key for this accessor (the minRange :593
# precedent -- the tick frame tracks no shooting state yet),
# so the live value arrives as the explicit param. NO driver
# line: isShooting() is a read accessor its callers read, not
# a per-tick write (the N2249 precedent) -- no `.isShooting()`
# call site exists in core/src; the FIELD is read directly at
# shouldConsume :365 (`return isShooting || reloadCounter <
# reload;`), sense :413 (`case shooting -> isShooting ? 1 :
# 0;`) and the warmup leg :502 (`float warmupTarget =
# (isShooting && canConsume()) || charging() ? 1f : 0f;`).
@warning_ignore("unused_parameter")
static func source_turret_is_shooting_state(frame: Dictionary, is_shooting: bool) -> Dictionary:
	return {"is_shooting": is_shooting}

# TurretBuild.activeSoundVolume() (Turret.java:822-824):
# `public float activeSoundVolume(){`
# `return shootWarmup;`
# `}`
# and TurretBuild.shouldActiveSound() (Turret.java:826-829):
# `public boolean shouldActiveSound(){`
# `return shootWarmup > 0.01f && loopSound != Sounds.none;`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277) in `public class Turret extends ReloadTurret{`
# (Turret.java:36). shootWarmup is the TurretBuild field
# (Turret.java:286, `public float shootWarmup, charge, warmupHold
# = 0f;`) and arrives as the explicit float shoot_warmup (the
# updateTile warmup :502 precedent -- the field is written by
# updateTile :512/:514, NOT ported here: this slice only reads
# it). loopSound is the Turret def field (Turret.java:128,
# `public Sound loopSound = Sounds.none;`); the `loopSound !=
# Sounds.none` check arrives as the explicit bool has_loop_sound
# (the minRange has_ammo precedent -- a null/non-none check
# carried as an explicit bool, GDScript has no Sound object
# here). The frame carries no tracked key for either accessor
# (the minRange :593 precedent -- the tick frame tracks no
# warmup/loop-sound state yet), so all live values arrive as
# explicit params. Evidence, not ownership: the body `return
# shootWarmup;` already appears in N2297[3] (warmup(),
# Turret.java:355, a different method with the same one-line
# body) -- it does not own activeSoundVolume(). NO driver
# line: both are read accessors/predicates the updateTile()
# tick reads at :499 (`soundLoop.update(x, y,
# shouldActiveSound(), activeSoundVolume());`) -- wiring them
# into the driver waits for the updateTile caller slice.
# soundLoop itself (Turret.java:298) is NOT ported: this slice
# never touches real audio.
@warning_ignore("unused_parameter")
static func source_turret_active_sound_volume_state(frame: Dictionary, shoot_warmup: float) -> Dictionary:
	return {"active_sound_volume": shoot_warmup}

@warning_ignore("unused_parameter")
static func source_turret_should_active_sound_state(frame: Dictionary, shoot_warmup: float, has_loop_sound: bool) -> Dictionary:
	return {"should_active_sound": shoot_warmup > 0.01 and has_loop_sound}

# The BlockStatus.inactive value (BlockStatus.java:12,
# `inactive(Color.lightGray);`) has no N1888 constant: the
# BuildingComp.status() helper only returns logicDisable /
# noOutput / noInput / active, so the activation-timer leg of
# TurretBuild.status() carries its own family-local const.
const SOURCE_TURRET_STATUS_INACTIVE := "inactive"

# TurretBuild.status() (Turret.java:369-374):
# `public BlockStatus status(){`
# `if(enabled && !hasAmmo()) return BlockStatus.noInput;`
# ``
# `return super.status();`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277) in `public class Turret extends ReloadTurret{`
# (Turret.java:36). The super chain has two layers:
# BaseTurretBuild.status() (BaseTurret.java:143-145):
# `public BlockStatus status() {`
# `return (activationTimer <= 0)? super.status() : BlockStatus.inactive;`
# `}`
# on `public class BaseTurretBuild extends Building implements Ranged, RotBlock{`
# (BaseTurret.java:113) in `public class BaseTurret extends Block{`
# (BaseTurret.java:20), over BuildingComp.status()
# (BuildingComp.java:632-646):
# `public BlockStatus status(){`
# `if(!enabled){`
# `return BlockStatus.logicDisable;`
# `}`
# `if(!shouldConsume()){`
# `return BlockStatus.noOutput;`
# `}`
# `if(efficiency <= 0 || !productionValid()){`
# `return BlockStatus.noInput;`
# `}`
# `return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;`
# `}`
# -- already live as N1888 PortGame.source_building_status_state,
# whose result arrives here as the explicit building_status param.
# enabled is the Building field (`transient boolean enabled = true;`,
# BuildingComp.java:77), read from the tick frame (stamped by
# source_turret_tick_frame_state, absent reads true, the N2125
# precedent). has_ammo is an explicit bool carrying hasAmmo()
# (Turret.java:698-712, `public boolean hasAmmo(){`, with the
# ammo-swap side effect, the canConsume() gate and the cheating()
# leg) -- NOT ported here, the N2311/N2261 precedent, because no
# slice owns hasAmmo() yet. activation_timer is an explicit float
# carrying BaseTurretBuild.activationTimer (`public float
# activationTimer = 0;`, BaseTurret.java:115, set to activationTime
# on placed()). The noInput leg is `noInput(Pal.remove),`
# (BlockStatus.java:9); the inactive leg is BlockStatus.inactive.
# The first leg needs BOTH conditions: a disabled turret with no
# ammo falls through to super.status(), which itself returns
# logicDisable for !enabled -- so the function adds no enabled
# check of its own in the super leg. NO driver tick line: status()
# is a read accessor its callers read, not a per-tick write (the
# N2249/N2221 precedent).
static func source_turret_status_state(frame: Dictionary, has_ammo: bool, activation_timer: float, building_status: String) -> Dictionary:
	var enabled: bool = bool(frame.get("enabled", true))
	if enabled and not has_ammo:
		return {"status": source_building_access_state.SOURCE_BUILDING_STATUS_NO_INPUT}
	if activation_timer <= 0.0:
		return {"status": building_status}
	return {"status": SOURCE_TURRET_STATUS_INACTIVE}

# TurretBuild.warmup() (Turret.java:354-356):
# `public float warmup(){`
# `return shootWarmup;`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277) in `public class Turret extends ReloadTurret{`
# (Turret.java:36). shoot_warmup is the TurretBuild field (`public float
# shootWarmup, charge, warmupHold = 0f;`, Turret.java:286, default 0f),
# advanced toward warmupTarget by the updateTile warmup leg (N2308,
# Turret.java:502-515) -- NOT re-ported here (the N2311/N2261
# precedent): it arrives as an explicit param. NO driver tick line:
# warmup() is a read accessor its callers read, not a per-tick write
# (the N2249/N2221 precedent) -- the minWarmup fire gate reads it
# (Turret.java:733) and the sound loop reads it; both callers wait
# for their own slices.
@warning_ignore("unused_parameter")
static func source_turret_warmup_state(frame: Dictionary, shoot_warmup: float) -> Dictionary:
	return {"warmup": shoot_warmup}

# TurretBuild.drawrot() (Turret.java:359-361):
# `public float drawrot(){`
# `return rotation - 90;`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). rotation is the RotComp float aim angle
# (`@SyncField(false) @SyncLocal float rotation;`, RotComp.java:8,
# default 0.0) -- NOT the Building int rotation 0-3 (`transient int
# rotation;`, BuildingComp.java:69). The caller binds it from the
# frame bound by source_turret_bind_frame_state (frame["rotation"],
# the carrier N2322's write/read already use, default 0.0); it
# arrives here as an explicit param (the N2311/N2261 precedent).
# NO driver tick line: drawrot() is a read accessor the draw path
# reads, not a per-tick write (the N2249/N2221 precedent).
@warning_ignore("unused_parameter")
static func source_turret_drawrot_state(frame: Dictionary, rotation: float) -> Dictionary:
	return {"drawrot": rotation - 90.0}

# TurretBuild.drawSelect() (Turret.java:481-488):
# `public void drawSelect(){`
# `super.drawSelect();`
# ``
# `if(drawMinRange){`
# `Drawf.dashCircle(x, y, minRange(), team.color);`
# `}`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277) in `public class Turret extends ReloadTurret{`
# (Turret.java:36). super.drawSelect() is the base
# BuildingComp.drawSelect() (BuildingComp.java:1242-1248) -- ALREADY
# LIVE as N573 PortGame.source_building_draw_select_state, NOT
# re-ported here: it runs first at the call site and its output does
# not feed the Turret leg. draw_min_range is the block-level Turret
# def field (`public boolean drawMinRange;`, Turret.java:70, "If true,
# a range ring is also drawn for minRange."), default false -- a def
# field, not build state, so it arrives as an explicit param (the
# N2311/N2261 precedent). min_range is the LIVE minRange() value
# (`public float minRange(){`, Turret.java:334, `return minRange +
# peekAmmo().minRangeChange;`, Turret.java:335) -- computed by the
# caller through N2282 source_turret_min_range_state and passed in as
# an explicit param, NOT re-ported here. team_color is `team.color`
# (Turret.java:485), passed as an explicit String (the
# SourceBuildingDrawState draw_team precedent). Drawf.dashCircle is
# NOT played back: the function returns the draw-command state the
# circle depends on (whether it is drawn, center, radius, color).
# When drawMinRange is false no circle is drawn, so the radius reads
# 0.0 (all four keys are always present, schema-stable). NO driver
# tick line: drawSelect() is selection UI, not per-tick state (the
# N2249/N2221 precedent). This is a different method from N2329
# peekAmmo() (which minRange() reads) and from drawPlace()
# (Turret.java:252-253, which reads the minRange FIELD directly --
# already ported as N1162 turret_draw_place.min_range).
static func source_turret_draw_select_state(x: float, y: float, draw_min_range: bool, min_range: float, team_color: String) -> Dictionary:
	if draw_min_range:
		return {"draw_min_range_circle": true, "center": Vector2(x, y), "radius": min_range, "color": team_color}
	return {"draw_min_range_circle": false, "center": Vector2(x, y), "radius": 0.0, "color": team_color}

# BaseTurretBuild.drawSelect() (BaseTurret.java:133-135):
# `public void drawSelect(){`
# `Drawf.dashCircle(x, y, range(), team.color);`
# `}`
# on `public class BaseTurretBuild extends Building implements Ranged, RotBlock{`
# (BaseTurret.java:110). The whole method is one line: it draws one dash
# circle around the building. The center is the building world position,
# the radius is the LIVE range() value (`public float range(){`,
# BaseTurret.java:124, `return range;`, BaseTurret.java:125 -- computed
# by the caller and passed in as the explicit range_value param, NOT
# re-ported here; the field `range` (BaseTurret.java:22, `public float
# range = 80f;`) is evidence only, the N2311/N2261 precedent), the color
# is the building team color (`team.color`, passed as an explicit String,
# the SourceBuildingDrawState draw_team precedent). Drawf.dashCircle
# arrives as an explicit Callable param (the N2377 drawer precedent:
# guarded with is_valid(), invoked with .call()), NOT re-ported here;
# Drawf itself is NOT ported. NO driver tick line: drawSelect() is
# selection UI, not per-tick state (the N2249/N2221 precedent). This is
# a different method from N2334 TurretBuild.drawSelect() (selection UI,
# Turret.java:481-488, the min-range circle, which calls
# super.drawSelect() first) and from drawPlace()
# (BaseTurret.java:84-92, which draws the range circle at place time).
static func source_base_turret_build_draw_select_state(x: float, y: float, range_value: float, team_color: String, dash_circle: Callable) -> Dictionary:
	var dash_circle_called: bool = false
	if dash_circle.is_valid():
		dash_circle.call(x, y, range_value, team_color)
		dash_circle_called = true
	return {"dash_circle_called": dash_circle_called, "center": Vector2(x, y), "radius": range_value, "color": team_color}

# TurretBuild.draw() (Turret.java:476-478):
# `public void draw(){`
# `drawer.draw(this);`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). The whole method is one line: it delegates the
# draw to the block-level drawer (`public DrawBlock drawer = new DrawTurret();`,
# Turret.java:155) -- the DrawBlock that draws the whole turret. The drawer arrives as an
# explicit Callable param (the SourceBlockGeometry world_tile_lookup precedent: guarded
# with is_valid(), invoked with .call()), NOT re-ported here;
# DrawTurret itself is NOT ported. The build (`this`) arrives as
# an explicit Dictionary param. NO driver tick line: draw() is a
# render delegate, not per-tick state (the N2249/N2221 precedent).
# This is a different method from N2334 drawSelect() (selection
# UI, Turret.java:481-488) and from drawPlace() (Turret.java:252-253,
# already ported as N1162 turret_draw_place.min_range).
static func source_turret_draw_state(drawer: Callable, build: Dictionary) -> Dictionary:
	var drawer_called: bool = false
	if drawer.is_valid():
		drawer.call(build)
		drawer_called = true
	return {"draw_delegated": true, "drawer_called": drawer_called}

# TurretBuild.canControl() (Turret.java:376-378):
# `public boolean canControl(){`
# `return playerControllable;`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). player_controllable is the block-level Turret
# field (`public boolean playerControllable = true;`, Turret.java:97,
# "If true, this turret can be controlled by players."), default
# true -- a def field, not build state, so it arrives as an explicit
# param (the N2311/N2261 precedent). NO driver tick line:
# canControl() is a read accessor the control dispatch reads, not a
# per-tick write (the N2249/N2221 precedent).
@warning_ignore("unused_parameter")
static func source_turret_can_control_state(frame: Dictionary, player_controllable: bool) -> Dictionary:
	return {"can_control": player_controllable}

# TurretBuild.logicControlled() (Turret.java:445-447):
# `public boolean logicControlled(){`
# `return logicControlTime > 0;`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). logic_control_time is the TurretBuild field
# (`public float curRecoil, heat, logicControlTime = -1;`,
# Turret.java:284, default -1), set to logicControlCooldown
# (`public final static float logicControlCooldown = 60 * 2;`,
# Turret.java:38) by control() (Turret.java:384/394) while logic
# holds the turret; it arrives as an explicit param (the
# N2311/N2261 precedent), because the tick frame tracks no logic
# key yet. NO driver tick line: logicControlled() is a read
# accessor its callers read, not a per-tick write (the N2249/N2221
# precedent) -- updateTile's isShooting computation reads it
# (Turret.java:492) and findTarget's validateTarget reads it
# (Turret.java:632); both callers wait for their own slices.
# controlled() (Turret.java:441-443, `return unit.isPlayer();`)
# is its own slice (N2324), below.
@warning_ignore("unused_parameter")
static func source_turret_logic_controlled_state(frame: Dictionary, logic_control_time: float) -> Dictionary:
	return {"logic_controlled": logic_control_time > 0.0}

# TurretBuild.controlled() (Turret.java:441-443):
# `public boolean controlled(){`
# `return unit.isPlayer();`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). unit is the TurretBuild field
# (`public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`,
# Turret.java:291), synced by unit() (N2307): controlled() reads the
# result of unit() (`unit.isPlayer();`, Turret.java:442).
# isPlayer() itself (`public boolean isPlayer(){` /
# `return controller instanceof Player;`, UnitComp.java:949-951) is
# NOT re-ported here (Unit/BlockUnitc are not ported): its result
# arrives as the explicit is_player param (the N2311/N2261
# precedent). NO driver tick line: controlled() is a read accessor
# its callers read, not a per-tick write (the N2249/N2221 precedent)
# -- validateTarget() reads it (Turret.java:632) and updateTile's
# player-control branch reads it (Turret.java:494); both callers
# wait for their own slices. NOT control() (Turret.java:384-394,
# remote N2264): a different method -- it sets logicControlTime and
# the player controller, it does not read unit.isPlayer().
@warning_ignore("unused_parameter")
static func source_turret_controlled_state(frame: Dictionary, is_player: bool) -> Dictionary:
	return {"controlled": is_player}

# TurretBuild.unit() (Turret.java:434-439):
# `public Unit unit(){`
# `unit.tile(this);`
# `unit.team(team);`
# `return (Unit)unit;`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). unit is the TurretBuild field
# `public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`
# (Turret.java:291), created once from UnitTypes.block -- NOT re-ported
# here (Unit/BlockUnitc are not ported): it arrives as an explicit param
# (the N2311/N2261 precedent).
# team_id is the building team as an int (the tick-frame convention:
# source_turret_tick_frame_state binds frame["team_id"]); the Building
# team is `@Import Team team;` (BuildingComp.java:62) and the unit team
# field defaults to derelict (`Team team = Team.derelict;`,
# TeamComp.java:15). The function performs the sync itself: it copies
# the input unit dict, sets tile to the building frame (`this`,
# `unit.tile(this);` resolving to
# `public void tile(Building tile){` (BlockUnitComp.java:17), on the
# tile field `@ReadOnly transient Building tile;`
# (BlockUnitComp.java:14)) and team_id to the building team, and
# returns the synced unit. The stat derivation INSIDE
# BlockUnitComp.tile(Building) (maxHealth/health/hitSize/set,
# BlockUnitComp.java:17-27) is NOT applied here: tile() is a separate
# method on a different component -- it stays deferred for its own
# slice. NO driver tick line: unit() is a read accessor its callers
# read, not a per-tick write (the N2249/N2221 precedent) --
# controlled() reads the result (`unit.isPlayer();`,
# Turret.java:442) and is its own slice (N2324).
static func source_turret_unit_state(frame: Dictionary, unit: Dictionary, team_id: int) -> Dictionary:
	var synced: Dictionary = unit.duplicate()
	synced["tile"] = frame
	synced["team_id"] = team_id
	return {"unit": synced}

# TurretBuild.hasAmmo() (Turret.java:698-713):
# `public boolean hasAmmo(){`
# `//skip first entry if it has less than the required amount of ammo`
# `if(ammo.size >= 2 && ammo.peek().amount < ammoPerShot){`
# `for(int i = 0; i < ammo.size; i ++){`
# `if(ammo.get(i).amount >= ammoPerShot){`
# `ammo.swap(ammo.size - 1, i);`
# `break;`
# `}`
# `}`
# `//used for "side-ammo" like gas in some turrets`
# `if(!canConsume()) return false;`
# `return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). ammo is the TurretBuild field
# (`public Seq<AmmoEntry> ammo = new Seq<>();`, Turret.java:282) and
# ammoPerShot the block field (`public int ammoPerShot = 1;`, Turret.java:49).
# Both arrive as explicit params (the N2311/N2261 precedent): the ammo list as an Array of
# {amount, item} dicts (the peek_ammo_stack_state convention -- Seq.peek()
# is the last entry). canConsume() (Turret.java:624) and cheating() are
# NOT re-ported here: their results arrive as explicit bool params.
# The swap runs BEFORE the canConsume() gate (Java order), so the
# returned ammo_stacks_after carries the swap even when has_ammo is
# false for can_consume. NO driver tick line: hasAmmo() is a predicate
# its callers read, not a per-tick write (the N2249/N2221 precedent) --
# estimateDps() (N2301) and targetPosition() (Turret.java:454) read the
# result; targetPosition() still waits for peekAmmo() (T6).
@warning_ignore("unused_parameter")
static func source_turret_has_ammo_state(frame: Dictionary, ammo_stacks: Array, ammo_per_shot: int, can_consume: bool, cheating: bool) -> Dictionary:
	var stacks_after: Array = ammo_stacks.duplicate(true)
	if stacks_after.size() >= 2:
		var peeked: Dictionary = stacks_after[stacks_after.size() - 1] if stacks_after[stacks_after.size() - 1] is Dictionary else {}
		if int(peeked.get("amount", 0)) < ammo_per_shot:
			for index in stacks_after.size():
				var candidate: Dictionary = stacks_after[index] if stacks_after[index] is Dictionary else {}
				if int(candidate.get("amount", 0)) >= ammo_per_shot:
					var last_entry: Dictionary = stacks_after[stacks_after.size() - 1] if stacks_after[stacks_after.size() - 1] is Dictionary else {}
					stacks_after[stacks_after.size() - 1] = candidate
					stacks_after[index] = last_entry
					break
	if not can_consume:
		return {"has_ammo": false, "ammo_stacks_after": stacks_after}
	var has_ammo := false
	if stacks_after.size() > 0:
		var peeked_after: Dictionary = stacks_after[stacks_after.size() - 1] if stacks_after[stacks_after.size() - 1] is Dictionary else {}
		has_ammo = int(peeked_after.get("amount", 0)) >= ammo_per_shot or cheating
	return {"has_ammo": has_ammo, "ammo_stacks_after": stacks_after}

# TurretBuild.peekAmmo() (Turret.java:693-695):
# `/** @return the ammo type that will be returned if useAmmo is called. */`
# `public @Nullable BulletType peekAmmo(){`
# `return ammo.size == 0 ? null : ammo.peek().type();`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). ammo is the TurretBuild field
# (`public Seq<AmmoEntry> ammo = new Seq<>();`, Turret.java:282) and
# arrives as an explicit param (the N2313 hasAmmo precedent): the ammo
# list as an Array of {amount, item, type} dicts (the
# peek_ammo_stack_state convention -- Seq.peek() is the last entry).
# AmmoEntry is the abstract entry type (`public static abstract class
# AmmoEntry{`, Turret.java:257) with `public int amount;` and
# `public abstract BulletType type();` (Turret.java:258-260). type() is
# NOT re-ported here: for ItemEntry it resolves through the block
# ammoTypes map (`return ammoTypes.get(item);`, ItemTurret.java:236-238)
# and the map itself is NOT ported -- the BulletType NAME arrives as
# the explicit "type" value on each entry dict, and the function
# returns that name (or null). peekAmmo() reads only the peek: no
# amount check and no swap, unlike hasAmmo() (N2313) -- an entry with
# amount 0 still returns its type, and the input list is never
# mutated. NO driver tick line: peekAmmo() is a pure accessor its
# callers read, not a per-tick write (the N2249/N2221 precedent) --
# targetPosition() (Turret.java:454, remote N2266) and useAmmo()
# (N2108) read the result; neither caller is ported here.
@warning_ignore("unused_parameter")
static func source_turret_peek_ammo_state(frame: Dictionary, ammo_stacks: Array) -> Dictionary:
	if ammo_stacks.is_empty():
		return {"peek_ammo": null}
	var peeked: Dictionary = ammo_stacks[ammo_stacks.size() - 1] if ammo_stacks[ammo_stacks.size() - 1] is Dictionary else {}
	var peeked_type: Variant = peeked.get("type", null)
	return {"peek_ammo": peeked_type}

# TurretBuild.getAmmoContent() (Turret.java:319-321):
# `@Nullable`
# `public UnlockableContent getAmmoContent(){`
# `return null;`
# `}`
# and TurretBuild.getAmmoFraction() (Turret.java:324-326):
# `/** @return ammo as a fraction of capacity; used for direct turret control HUD */`
# `public float getAmmoFraction(){`
# `return 1f;`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277) in `public class Turret extends ReloadTurret{`.
# Both are base-class defaults, not overrides: the base
# TurretBuild has no ammo content (null) and counts as full
# (1f); the subclass overrides (ItemTurretBuild N1180/N1181,
# LiquidTurretBuild N1197/N1198, ContinuousLiquidTurretBuild
# N1220/N1221, PowerTurretBuild N1168) own their own bodies
# and are NOT touched here. Both are constants: no live
# input besides the frame itself, which carries no tracked
# key for either accessor (the isShooting :429 precedent --
# the frame is the family-convention first arg, kept even
# when the function reads nothing from it). NO driver line:
# both are pure defaults its callers read, not per-tick
# writes (the N2249 precedent) -- updateTile :495 reads
# getAmmoFraction() and DrawTurret :108-112 reads
# getAmmoContent(); neither caller is ported here.
@warning_ignore("unused_parameter")
static func source_turret_get_ammo_content_state(frame: Dictionary) -> Dictionary:
	return {"ammo_content": null}

@warning_ignore("unused_parameter")
static func source_turret_get_ammo_fraction_state(frame: Dictionary) -> Dictionary:
	return {"ammo_fraction": 1.0}

# TurretBuild.remove() (Turret.java:303-308):
# `@Override`
# `public void remove(){`
# `super.remove();`
# `if(soundLoop != null){`
# `soundLoop.stop();`
# `}`
# `}`
# and TurretBuild.onDestroyed() (Turret.java:311-317):
# `@Override`
# `public void onDestroyed(){`
# `super.onDestroyed();`
# `if(soundLoop != null){`
# `soundLoop.stop();`
# `}`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277) in `public class Turret extends ReloadTurret{`.
# Both stop the sound loop when it is non-null and do
# nothing when it is null; the two bodies differ only in
# the super call. soundLoop is the TurretBuild field
# (Turret.java:298) `public @Nullable SoundLoop soundLoop = (loopSound == Sounds.none ? null : new SoundLoop(loopSound, loopSoundVolume));`
# and arrives as the explicit bool
# has_sound_loop (the minRange has_ammo precedent -- a
# null check carried as an explicit bool; GDScript has no
# SoundLoop object here). super.remove() /
# super.onDestroyed() are the Building base -- deferred,
# not ported. NO driver line: the engine lifecycle calls
# remove() / onDestroyed(); no call site is ported here
# (the shouldTurn/isShooting precedent -- updateTile :499
# only UPDATES the loop, it never removes or destroys it).
# NO SoundLoop playback: both functions only return the
# stopped flag, never real audio (the N2346 precedent).
@warning_ignore("unused_parameter")
static func source_turret_remove_state(frame: Dictionary, has_sound_loop: bool) -> Dictionary:
	return {"sound_loop_stopped": has_sound_loop}

@warning_ignore("unused_parameter")
static func source_turret_on_destroyed_state(frame: Dictionary, has_sound_loop: bool) -> Dictionary:
	return {"sound_loop_stopped": has_sound_loop}

# TurretBuild.findEnemy() (Turret.java:639-649):
# `protected Posc findEnemy(float range){`
# `if(targetAir && !targetGround){`
# `return Units.bestEnemy(team, x, y, range, e -> !e.dead() && !e.isGrounded() && unitFilter.get(e), unitSort);`
# `}else{`
# `var ammo = peekAmmo();`
# `boolean buildings = targetGround && targetBlocks && (ammo == null || ammo.targetBlocks), missiles = ammo == null || ammo.targetMissiles;`
# `return Units.bestTarget(team, x, y, range,`
# `e -> !e.dead() && unitFilter.get(e) && (e.isGrounded() || targetAir) && (!e.isGrounded() || targetGround) && (missiles || !(e instanceof TimedKillc)),`
# `b -> buildings && buildingFilter.get(b), unitSort);`
# `}`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). Units.bestTarget (Units.java:284-294,
# `public static Teamc bestTarget(Team team, float x, float y, float range, Boolf<Unit> unitPred, Boolf<Building> tilePred, Sortf sort){`)
# returns null for a derelict team (`if(team == Team.derelict) return null;`),
# checks units first (`Unit unit = bestEnemy(team, x, y, range, unitPred, sort);`)
# and only then buildings (`return findEnemyTile(team, x, y, range, tilePred);`).
# Units.bestEnemy (Units.java:318-338,
# `public static Unit bestEnemy(Team team, float x, float y, float range, Boolf<Unit> predicate, Sortf sort){`)
# skips dead / pred-fail / derelict / out-of-range / untargetable /
# in-fog candidates
# (`if(e.dead() || !predicate.get(e) || e.team == Team.derelict || !e.within(x, y, range + e.hitSize/2f) || !e.targetable(team) || e.inFogTo(team)) return;`)
# and picks by sort.cost
# (`float cost = sort.cost(e, x, y);`)
# with the targetPriority tie-break
# (`if((result == null || cost < cdist || e.type.targetPriority > cpriority) && e.type.targetPriority >= cpriority){`).
# The default sort is UnitSorts.closest = Unit::dst2
# (UnitSorts.java:11, `closest = Unit::dst2,`, over the def
# `public Sortf unitSort = UnitSorts.closest;`, Turret.java:107), so
# the cost is the candidate dst2; unitFilter (Turret.java:109, default
# `u -> true`) and buildingFilter (Turret.java:111) arrive as the
# per-candidate unit_filter / building_filter flags, and the
# branch-specific predicate legs (grounded, timed-kill) are computed
# here from the is_grounded / is_timed_kill flags. The building
# fallback is Units.findEnemyTile (Units.java:222-225,
# `public static Building findEnemyTile(Team team, float x, float y, float range, Boolf<Building> pred){`)
# into BlockIndexer.findEnemyTile (BlockIndexer.java:486-487) with the
# UnitSorts.buildingDefault priority (UnitSorts.java:22,
# `buildingDefault = b -> b.block.priority,`): per building,
# `float dist = candidate.dst(x, y) - candidate.hitSize() / 2f;`
# (BlockIndexer.java:472) must satisfy
# `float bdst = next.dst(x, y) - next.hitSize() / 2f;`
# (BlockIndexer.java:512) with
# `if(bdst < range && (closest == null ||`
# (BlockIndexer.java:513), and the winner is closer-and-at-least-
# equal-priority or strictly higher priority -- the same acceptance
# rule the cross-team loop applies. The live Units queries
# (nearbyEnemies scan, indexer.findEnemyTile / findTile, inFogTo)
# stay on the driver side, which stamps the candidate flags (the
# N2242 live-bullets precedent); the candidates carry an `id` key
# so the driver can resolve the chosen dict back to a live entity
# (the N2242 observed-dict precedent). SourceTurretTargetingState.gd
# is NOT reused: it only picks the nearest candidate by distance and
# has no slice owner -- it lacks the predicate filters, the
# targetPriority tie-break and the building fallback ported here.
# NO driver line: findTarget() (:651-663) calls this with explicit
# params; the updateTile driver is its own later slice.
@warning_ignore("unused_parameter")
static func source_turret_find_enemy_state(frame: Dictionary, team_is_derelict: bool, range: float, target_air: bool, target_ground: bool, target_blocks: bool, ammo_is_null: bool, ammo_target_blocks: bool, ammo_target_missiles: bool, unit_candidates: Array, building_candidates: Array) -> Dictionary:
	if team_is_derelict:
		return {"target": null}
	var air_only: bool = target_air and not target_ground
	var buildings: bool = target_ground and target_blocks and (ammo_is_null or ammo_target_blocks)
	var missiles: bool = ammo_is_null or ammo_target_missiles
	var best: Variant = null
	var best_cost: float = 0.0
	var best_priority: float = -99999.0
	for candidate in unit_candidates:
		if not (candidate is Dictionary):
			continue
		if bool(candidate.get("dead", false)):
			continue
		if bool(candidate.get("team_is_derelict", false)):
			continue
		if not bool(candidate.get("within_range", false)):
			continue
		if not bool(candidate.get("targetable", false)):
			continue
		if bool(candidate.get("in_fog", false)):
			continue
		if not bool(candidate.get("unit_filter", false)):
			continue
		var is_grounded: bool = bool(candidate.get("is_grounded", false))
		if air_only:
			if is_grounded:
				continue
		else:
			if not (is_grounded or target_air):
				continue
			if not ((not is_grounded) or target_ground):
				continue
			if not (missiles or not bool(candidate.get("is_timed_kill", false))):
				continue
		var cost: float = float(candidate.get("dst2", 0.0))
		var priority: float = float(candidate.get("target_priority", 0.0))
		if (best == null or cost < best_cost or priority > best_priority) and priority >= best_priority:
			best = candidate
			best_cost = cost
			best_priority = priority
	if best != null:
		return {"target": best}
	if air_only:
		return {"target": null}
	if not buildings:
		return {"target": null}
	var best_building: Variant = null
	var best_dist: float = 0.0
	var best_bpriority: float = 0.0
	for candidate in building_candidates:
		if not (candidate is Dictionary):
			continue
		if not bool(candidate.get("building_filter", false)):
			continue
		var dist: float = sqrt(float(candidate.get("dst2", 0.0))) - float(candidate.get("hit_size", 0.0)) / 2.0
		if not (dist < range):
			continue
		var bpriority: float = float(candidate.get("priority", 0.0))
		if best_building == null or (dist < best_dist and bpriority >= best_bpriority) or bpriority > best_bpriority:
			best_building = candidate
			best_dist = dist
			best_bpriority = bpriority
	return {"target": best_building}

# TurretBuild.findTarget() (Turret.java:651-663):
# `protected void findTarget(){`
# `float trackRange = trackingRange(), range = range();`
# `target = findEnemy(range);`
# `if(!Mathf.equal(trackRange, range) && target == null){`
# `target = findEnemy(trackRange);`
# `}`
# `if(target == null && canHeal()){`
# `target = Units.findAllyTile(team, x, y, range, b -> b.damaged() && b != this);`
# `}`
# `}`
# on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# (Turret.java:277). The standard-range target is always preferred:
# the tracking range is tried only when it differs from the standard
# range and nothing was found yet. Mathf.equal is an epsilon compare
# (Mathf.java:544-546, `return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;`,
# with `public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits`,
# Mathf.java:10) -- not `==` and not GDScript is_equal_approx (whose
# epsilon is 0.00001). The ally-tile fallback is Units.findAllyTile
# (Units.java:217-219,
# `public static Building findAllyTile(Team team, float x, float y, float range, Boolf<Building> pred){`
# / `return indexer.findTile(team, x, y, range, pred);`), which only
# runs when the target is still null and canHeal() holds; the ally
# tile arrives as a pre-filtered observed dict (damaged and not this
# build -- the `b -> b.damaged() && b != this` predicate is the
# driver's). range() and trackingRange() arrive as explicit params
# (the N2188 precedent); the findEnemy calls themselves are the
# driver's, which passes the found standard / track targets in.
# NO driver line: updateTile calls findTarget() at :570 -- the driver
# is its own later slice.
@warning_ignore("unused_parameter")
static func source_turret_find_target_state(frame: Dictionary, range: float, track_range: float, found_standard: Variant, found_track: Variant, can_heal: bool, ally_tile: Variant) -> Dictionary:
	var target: Variant = found_standard
	if absf(track_range - range) > 0.000001 and target == null:
		target = found_track
	if target == null and can_heal:
		target = ally_tile
	return {"target": target}

# TurretBuild.trackingRange() (Turret.java:349-351, `public float trackingRange(){` /
# `return range() + trackingRange - range;`) over the TurretBuild.range() result
# (Turret.java:342-345, `public float range(){` with `return range + peekAmmo().rangeChange;`
# when peekAmmo() is non-null (Turret.java:693, `public @Nullable BulletType peekAmmo(){`),
# else `return range;`), the Turret def trackingRange field (Turret.java:72,
# `public float trackingRange = 0f;`, "Range at which it finds and locks on to the target,
# but does not shoot.") and the BaseTurret def range (BaseTurret.java:21,
# `public float range = 80f;`). The peeked bullet's rangeChange is
# BulletType.java:157, `public float rangeChange = 0f;`, default 0f. init() clamps the
# field (Turret.java:217, `trackingRange = Math.max(range, trackingRange);`), so after init
# trackingRange() >= range(). All live values arrive as explicit params (the N2188
# precedent): the range() result arrives as range_value because range() reads peekAmmo()
# and the tick frame tracks no ammo state yet (the N2316 precedent; the old N739/N740
# range() rows live in PortGame, not on this state). NO driver line: trackingRange() is a
# load-time accessor findTarget reads at Turret.java:652
# (`float trackRange = trackingRange(), range = range();`), not a per-tick write (the
# N2311/N2249 accessor precedent). `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
# and `public class BaseTurret extends Block{`.
@warning_ignore("unused_parameter")
static func source_turret_tracking_range_state(frame: Dictionary, range_value: float, tracking_range: float, range: float) -> Dictionary:
	return {"tracking_range": range_value + tracking_range - range}

const TURRET_SAVE_VERSION := 1

static func source_turret_write_state(frame: Dictionary) -> Dictionary:
	# TurretBuild persists exactly TWO fields, its reload counter and its aim rotation
	# (Turret.java:831-834):
	# public void write(Writes write){
	# super.write(write);
	# write.f(reloadCounter);
	# write.f(rotation);
	# The reload counter is the ReloadTurretBuild field (`public float reloadCounter;`,
	# ReloadTurret.java:26), default 0.0, advanced by updateReload (Turret.java:720-723)
	# and read by shouldConsume (Turret.java:364-366, `return isShooting || reloadCounter < reload;`).
	# The rotation is the RotComp float aim angle (`@SyncField(false) @SyncLocal float rotation;`,
	# RotComp.java:8), default 0.0 -- NOT the Building int rotation 0-3 (`transient int rotation;`,
	# BuildingComp.java:69) that sense() takes as an explicit int param; the two are shadowed
	# (Turret.java:543-544, `//sync underlying rotation; 0-3 rotation is a shadowed field` and
	# `((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4);`). super.write(write)
	# is an empty BuildingComp body (`public void write(Writes write){` with `//overriden by subclasses!`,
	# BuildingComp.java:297-300) -- only the marker is recorded (the N2217 RepairTurret precedent).
	# The write returns ONLY the two persisted values, in Java write order (reloadCounter first,
	# rotation second); nothing else survives save/load. There is NO driver tick line: persistence
	# is not a per-tick call, and the port has no save/load stream to call this function yet.
	# The classes (Turret.java:36, :277): `public class Turret extends ReloadTurret{` and
	# `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`; the parents
	# (ReloadTurret.java:9, :25): `public class ReloadTurret extends BaseTurret{` and
	# `public class ReloadTurretBuild extends BaseTurretBuild{`.
	return {"reload_counter": float(frame.get("reload_counter", 0.0)), "rotation": float(frame.get("rotation", 0.0))}

static func source_turret_read_state(frame: Dictionary, stored_reload_counter: float, stored_rotation: float, revision: int) -> Dictionary:
	# TurretBuild restores the two persisted fields only for saves written at revision >= 1
	# (Turret.java:838-844):
	# public void read(Reads read, byte revision){
	# super.read(read, revision);
	# if(revision >= 1){
	# reloadCounter = read.f();
	# rotation = read.f();
	# because the save version is 1 (`public byte version(){` with `return 1;`, Turret.java:848-850;
	# the BuildingComp base returns 0, BuildingComp.java:669-671, `public byte version(){` with `return 0;`).
	# A revision-0 save leaves the fields where they already are -- the frame's current values
	# (reload_counter default 0.0, rotation default 0.0, the Java field defaults). super.read(read, revision)
	# is an empty BuildingComp body (BuildingComp.java:302-305) -- only the marker is recorded.
	# readSync() (Turret.java:853-862, `public void readSync(Reads read, byte revision){` with
	# `//maintain rotation and reload when syncing so clients don't see turrets snapping around`) is its
	# own slice, not this one. There is NO driver tick line: persistence is not a per-tick call.
	var reload_counter: float = float(frame.get("reload_counter", 0.0))
	var rotation: float = float(frame.get("rotation", 0.0))
	if revision >= 1:
		reload_counter = stored_reload_counter
		rotation = stored_rotation
	return {"reload_counter": reload_counter, "rotation": rotation}

@warning_ignore("unused_parameter")
static func source_turret_read_sync_state(frame: Dictionary, read_data: Dictionary, revision: int) -> Dictionary:
	# TurretBuild.readSync() (Turret.java:853-861):
	# public void readSync(Reads read, byte revision){
	# //maintain rotation and reload when syncing so clients don't see turrets snapping around
	# float oldRot = rotation, oldReload = reloadCounter;
	# readAll(read, revision);
	# rotation = oldRot;
	# reloadCounter = oldReload;
	# The sync snapshots the aim rotation and the reload counter, applies the sync
	# payload via readAll, then restores both values, so clients do not see turrets
	# snapping around. readAll(read, revision) is the Building base call
	# (BuildingComp.java:283-286, `public void readAll(Reads read, byte revision){`
	# with `readBase(read);` / `read(read, revision);`): the payload it applies
	# arrives here as the already-parsed dict read_data -- Building.readAll itself
	# is NOT ported (the N2330 param precedent), and the call line is shared text
	# with N1776 (BuildingComp.readSync, a different class and method) -- callee
	# evidence, not ownership of TurretBuild.readSync(). The rotation preserved
	# here is the RotComp float aim angle (`@SyncField(false) @SyncLocal float
	# rotation;`, RotComp.java:8), NOT the Building int rotation 0-3
	# (`transient int rotation;`, BuildingComp.java:69) that sense() takes as an
	# explicit int param; the two are shadowed (Turret.java:543-544,
	# `//sync underlying rotation; 0-3 rotation is a shadowed field`, the N2322
	# precedent). The reload counter is the ReloadTurretBuild field
	# (`public float reloadCounter;`, ReloadTurret.java:26), default 0.0,
	# advanced by updateReload (Turret.java:720-723). revision is passed through
	# to readAll and the Turret override never branches on it (the N2322 read()
	# guard `if(revision >= 1){` belongs to read(), not to readSync()).
	# read_applied is true exactly when the parsed sync payload is non-empty:
	# the Turret override applies whatever readAll read and then restores the
	# two preserved values. There is NO driver tick line: the engine net sync
	# calls readSync(), and the port has no net stream to call this function yet.
	# The classes (Turret.java:36, :277): `public class Turret extends ReloadTurret{`
	# and `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`.
	var old_rotation: float = float(frame.get("rotation", 0.0))
	var old_reload_counter: float = float(frame.get("reload_counter", 0.0))
	var read_applied: bool = not read_data.is_empty()
	return {"rotation": old_rotation, "reload_counter": old_reload_counter, "read_applied": read_applied}

@warning_ignore("unused_parameter")
static func source_turret_handle_liquid_state(frame: Dictionary, has_coolant: bool, liquid_amount: float) -> Dictionary:
	# TurretBuild.handleLiquid() (Turret.java:615-621):
	# public void handleLiquid(Building source, Liquid liquid, float amount){
	# if(coolant != null && liquids.currentAmount() <= 0.001f){
	# Events.fire(Trigger.turretCool);
	# }
	# super.handleLiquid(source, liquid, amount);
	# }
	# When the turret block has a coolant consumer and the liquid store is
	# (near-)empty, the turret-cool event fires
	# (`Events.fire(Trigger.turretCool);`) -- the port records it as the bool
	# flag turret_cool_fired, it does NOT port Events/Trigger. The base
	# BuildingComp.handleLiquid (BuildingComp.java:872-874,
	# `public void handleLiquid(Building source, Liquid liquid, float amount){`
	# with `liquids.add(liquid, amount);`) is ALWAYS called via super -- the
	# port records it as the flag super_called, it does NOT port
	# Building.handleLiquid (the N585 base slice owns the
	# `liquids.add(liquid, amount);` line). The signature line is shared text
	# with N585 (BuildingComp.handleLiquid base, a different class and
	# method) and N2118 (GenericCrafterBuild evidence) -- callee/context
	# evidence, not ownership of TurretBuild.handleLiquid(); this slice
	# registers the correct java_method = TurretBuild.handleLiquid(). The
	# coolant field lives on the block
	# (`public @Nullable ConsumeLiquidBase coolant;`, BaseTurret.java:34)
	# and arrives here as the explicit bool param has_coolant; the liquid
	# amount is `public float currentAmount(){` (LiquidModule.java:98) and
	# arrives as the explicit float param liquid_amount (the N2330 param
	# precedent). The frame is accepted for the family call shape and read
	# for nothing: handleLiquid writes no frame state. There is NO driver
	# tick line: the engine calls handleLiquid() when liquid enters the
	# building, and the port has no liquid flow to call this function yet.
	# The classes (Turret.java:36, :277): `public class Turret extends ReloadTurret{`
	# and `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`.
	var turret_cool_fired: bool = has_coolant and liquid_amount <= 0.001
	return {"turret_cool_fired": turret_cool_fired, "super_called": true}

@warning_ignore("unused_parameter")
static func source_turret_version_state(frame: Dictionary) -> Dictionary:
	# TurretBuild.version() (Turret.java:848-850):
	# public byte version(){
	# return 1;
	# The save version is 1, so read() applies the persisted reloadCounter/rotation for revision >= 1;
	# the BuildingComp base version() returns 0 (BuildingComp.java:669-671). The frame is accepted for
	# the family call shape and read for nothing: the version is a class constant, not live state.
	# There is NO driver tick line: the version is a load-time constant, not a per-tick write.
	return {"version": 1}

@warning_ignore("unused_parameter")
static func source_turret_tick_buildings_state(game: Object, seconds: float) -> Dictionary:
	# The live loop calls the turret tick wiring every tick
	# (TurretBuild.updateTile(), Turret.java:490, runs
	# updateConsumption through super.updateTile(); ItemTurretBuild,
	# LiquidTurretBuild and PowerTurretBuild do not override
	# updateTile, and LaserTurretBuild/ContinuousTurretBuild call
	# super.updateTile() first): each placed Turret-family build
	# gets its frame keys refreshed from the live rules, so the
	# frame's cheating flag tracks team.rules().cheat and useAmmo
	# skips consumption for a cheating team. The frame is bound at
	# placement (source_turret_bind_frame_state); a sprite that somehow
	# lacks one gets it bound here instead of crashing the loop. A
	# ContinuousLiquidTurret is skipped: it has its own driver
	# (N2103). The frame delta is not consumed by the wiring itself
	# (it only refreshes keys); a later slice that ticks shooting or
	# consumption reads it.
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
		if str(block.implementation) == SOURCE_CONTINUOUS_LIQUID_TURRET_IMPLEMENTATION:
			continue
		if not _is_turret_build_implementation(str(block.implementation)):
			continue
		var bound: Dictionary = source_turret_bind_frame_state(sprite, block)
		var frame: Dictionary = bound.get("frame", {})
		var team_id: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID))
		var rules_state: Variant = source_rules_state.source_game_rules_state(game.get("rules_state")).get("rules", {})
		var wired: Dictionary = source_turret_tick_frame_state(frame, str(block.implementation), team_id, rules_state)
		# The power consumer reads live since N2148 (the graph
		# update stamps frame["power_status"] each tick, N2142):
		# a turret with a power consumer folds the pure power row
		# into the first pass, so ConsumePower.efficiency folds
		# into the min efficiency like every other non-optional
		# consumer, and the warmup fold (Turret.java:512-514)
		# follows it. The power consumer counts toward hasConsumers
		# (Block.java:1449, `hasConsumers = consumers.length > 0;`),
		# so a power turret does not take the early return. A
		# turret with no power consumer is untouched: the tick
		# models no other consumers yet (foreshadow's item ammo
		# and lustre's liquid nitrogen wait for their own slices),
		# and the shouldConsume gate is wired by N2291
		# (source_turret_should_consume_state, Turret.java:364-366
		# `return isShooting || reloadCounter < reload;`): the
		# tick does not track targeting/reload state yet, so the
		# driver reads frame defaults (is_shooting=false,
		# reload_counter=0.0, reload=10f -- the Java field
		# defaults, boolean false / float 0f /
		# ReloadTurret.java:10) and the gate preserves
		# should_consume=true when enabled. productionValid is
		# the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(source_turret_should_consume_state(frame, bool(frame.get("is_shooting", false)), float(frame.get("reload_counter", 0.0)), float(frame.get("reload", 10.0))).get("should_consume", true))
			var valid: bool = source_building_access_state.production_valid_state()
			var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)
			frame["efficiency"] = setup.get("efficiency", 1.0)
			frame["efficiency_scale"] = source_building_efficiency_state.efficiency_scale_state()
			var power_row: Dictionary = source_turret_power_status_row_state(frame, true)
			var required_results: Array = []
			if bool(power_row.get("has_power_row", false)):
				required_results.append(power_row.get("row", {}))
			var consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, bool(frame.get("cheating", false)), bool(frame.get("enabled", true)), valid, should_consume, float(frame.get("efficiency_scale", 1.0)), required_results, [], [], frame)
			source_building_efficiency_state.apply_update_consumption_state(consumption, frame)
		var cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
