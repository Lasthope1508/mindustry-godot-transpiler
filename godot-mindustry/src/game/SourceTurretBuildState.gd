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
	# is wired by N2253 (source_turret_should_consume_state,
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
# The two inputs are the same reload pair N2253 wires for
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
# -- the assigned N2255 slice; setBars (Turret.java:192-202)
# never reads progress(). frame is accepted for the family call
# shape and reads no live frame key: reloadCounter / reload
# arrive as explicit params (the N2188 precedent),
# because the tick frame tracks only cheating / enabled /
# power_status / efficiency today. NO driver line: wiring frame
# defaults would stamp a constant 0.0 progress (0.0 / 10f),
# not a live value -- pure function only, the N2251 / N2252
# precedent; sense() (N2255) calls it with explicit params.
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
# the N2254 pure function (`return Mathf.clamp(reloadCounter /
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
# N2253/N2254 absent-preserves precedent). NO driver line:
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
# frame keys are tracked (the N2256 updateTile precedent); the warmup fold the
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
		# and the shouldConsume gate is wired by N2253
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
