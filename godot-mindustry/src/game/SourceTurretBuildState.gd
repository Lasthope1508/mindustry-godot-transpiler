extends RefCounted
class_name SourceTurretBuildState

const source_turret_ammo_state := preload("res://src/game/SourceTurretAmmoState.gd")
const source_item_turret_build_state := preload("res://src/game/SourceItemTurretBuildState.gd")
const source_bullet_runtime_state := preload("res://src/game/SourceBulletRuntimeState.gd")
const source_rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

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
	# rows wait for their own slices. (2) No shouldConsume gate --
	# TurretBuild.shouldConsume() (Turret.java:364-366, `return
	# isShooting || reloadCounter < reload;`) needs targeting/reload
	# state the tick does not track yet; the machinery runs with
	# should_consume=true when enabled. `!enabled` is handled by
	# the machinery's disabled branch, not here.
	if not has_power_consumer:
		return {"has_power_row": false, "row": {}}
	var stamped: Variant = frame.get("power_status", null)
	var live: float = 1.0 if stamped == null else float(stamped)
	return {"has_power_row": true, "row": {"result": live, "is_power": true}}

static func source_turret_warmup_state(shoot_warmup: float, warmup_hold: float, is_shooting: bool, can_consume: bool, charging: bool, controlled: bool, efficiency: float, delta: float, shoot_warmup_speed: float, linear_warmup: bool, warmup_maintain_time: float) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-515) advances the
	# warmup before it aims or shoots. isShooting is
	# `isShooting = alwaysShooting || (unit.controller() instanceof Player ? unit.isShooting() : logicControlled() ? logicShooting : target != null);`
	# (Turret.java:492 -- duo has no player and no logic, so
	# isShooting is target != null after the validateTarget verdict
	# at :491, N2251). The target is
	# `float warmupTarget = (isShooting && canConsume()) || charging() ? 1f : 0f;`
	# (Turret.java:502); ItemTurret canConsume is
	# `return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());`
	# (Turret.java:711). charging is
	# `return queuedBullets > 0 && shoot.firstShotDelay > 0;`
	# (Turret.java:715-717 -- duo firstShotDelay is 0, so charging
	# is false live, but the gate is still checked). controlled is
	# `public boolean controlled(){` / `return unit.isPlayer();`
	# (Turret.java:441-443). The hold is
	# `if(warmupTarget > 0 && !controlled()){` / `warmupHold = 1f;` /
	# `if(warmupHold > 0f){` / `warmupHold -= Time.delta / warmupMaintainTime;`
	# / `warmupTarget = 1f;` (Turret.java:503-509 -- with the duo
	# default warmupMaintainTime 0f the division is +inf, so the
	# hold ends on the very tick it is set). The advance is
	# `if(linearWarmup){` /
	# `shootWarmup = Mathf.approachDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));`
	# / `}else{` /
	# `shootWarmup = Mathf.lerpDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));`
	# (Turret.java:511-515 -- arc Mathf.java:402-404
	# `public static float clamp(float value){` /
	# `return Math.max(Math.min(value, 1f), 0f);` clamps to [0, 1];
	# :415-417 `public static float approach(float from, float to, float speed){` /
	# `return from + Mathf.clamp(to - from, -speed, speed);`;
	# :420-422 `public static float approachDelta(float from, float to, float speed){` /
	# `return approach(from, to, Time.delta * speed);`;
	# :426-428 `public static float lerp(float fromValue, float toValue, float progress){` /
	# `return fromValue + (toValue - fromValue) * progress;`;
	# :430-432 `public static float lerpDelta(float fromValue, float toValue, float progress){` /
	# `return lerp(fromValue, toValue, clamp(progress * Time.delta));`).
	# Class defaults are minWarmup 0f (`public float minWarmup = 0f;`,
	# Turret.java:76), warmupMaintainTime 0f
	# (`public float warmupMaintainTime = 0f;`, :84),
	# shootWarmupSpeed 0.1f (`public float shootWarmupSpeed = 0.1f;`,
	# :136), linearWarmup false (`public boolean linearWarmup = false;`,
	# :138) -- the duo def overrides NONE of them. The shoot gate
	# still reads the warmup
	# (`if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup){`,
	# Turret.java:733 -- duo minWarmup is 0, so the gate always
	# passes, but the warmup still has to advance for the frame to
	# be right). The recoil/heat decay
	# (`curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);` /
	# `heat = Mathf.approachDelta(heat, 0, 1 / cooldownTime);`,
	# Turret.java:519/:526) waits for its own slice.
	var warmup_target: float = 1.0 if ((is_shooting and can_consume) or charging) else 0.0
	if warmup_target > 0.0 and not controlled:
		warmup_hold = 1.0
	if warmup_hold > 0.0:
		warmup_hold -= delta / warmup_maintain_time
		warmup_target = 1.0
	var rate: float = shoot_warmup_speed * (efficiency if warmup_target > 0.0 else 1.0)
	if linear_warmup:
		shoot_warmup = shoot_warmup + clampf(warmup_target - shoot_warmup, -rate * delta, rate * delta)
	else:
		shoot_warmup = lerpf(shoot_warmup, warmup_target, clampf(rate * delta, 0.0, 1.0))
	return {"shoot_warmup": shoot_warmup, "warmup_hold": warmup_hold, "warmup_target": warmup_target}

static func source_turret_recoil_heat_state(cur_recoil: float, heat: float, recoil_time: float, cooldown_time: float, delta: float) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-532) decays the
	# recoil and the heat after the warmup advance and before it
	# aims or shoots: `curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);`
	# (Turret.java:519) and `heat = Mathf.approachDelta(heat, 0, 1 / cooldownTime);`
	# (:526). approachDelta is `public static float approachDelta(float from, float to, float speed){` /
	# `return approach(from, to, Time.delta * speed);` (arc Mathf.java:420-422) with
	# approach `public static float approach(float from, float to, float speed){` /
	# `return from + Mathf.clamp(to - from, -speed, speed);` (:415-417), so each tick
	# moves the value toward 0 by delta / recoilTime (resp. delta / cooldownTime),
	# never past 0. Class defaults are `public float recoil = 1f;` (:140),
	# `public int recoils = -1;` (:142), `public float recoilTime = -1f;` (:144),
	# `public float recoilPow = 1.8f;` (:146), `public float cooldownTime = 20f;` (:148);
	# the init is `if(recoilTime < 0f) recoilTime = reload;` /
	# `if(cooldownTime < 0f) cooldownTime = reload;` (:208-209 -- duo reload is 20,
	# N2250, so recoilTime is 20 and cooldownTime stays 20, a 0.05-per-tick rate).
	# The fields are `public float curRecoil, heat, logicControlTime = -1;` (:284).
	# The multi-recoil loop (`if(recoils > 0){` / `if(curRecoils == null) curRecoils = new float[recoils];` /
	# `for(int i = 0; i < recoils; i++){` / `curRecoils[i] = Mathf.approachDelta(curRecoils[i], 0, 1 / recoilTime);` / `}`,
	# :520-525) is NOT this slice: it waits for its own slice (N2256) -- duo recoils is 2
	# (`recoils = 2;`, Blocks.java:3301), not the -1 class default, so the loop applies
	# to duo. The shoot stamp (`curRecoil = 1f;` /
	# `heat = 1f;`, :807-810) and the draw offset
	# (`recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);`, :532)
	# are NOT this slice either: the shoot stamp waits with the shoot-stamp slice
	# (N2252 only stamped frame["bullet_spawn"]) and the offset is draw-side.
	# The result is a 2-key dict: `cur_recoil` (after the approachDelta step toward 0)
	# and `heat` (after the approachDelta step toward 0). Delta is the live-loop
	# seconds value, the same convention as the N2253 warmup.
	cur_recoil = cur_recoil + clampf(0.0 - cur_recoil, -delta / recoil_time, delta / recoil_time)
	heat = heat + clampf(0.0 - heat, -delta / cooldown_time, delta / cooldown_time)
	return {"cur_recoil": cur_recoil, "heat": heat}

static func source_turret_multi_recoil_state(cur_recoils: Array, recoils: int, recoil_time: float, delta: float) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-532) decays the
	# per-barrel recoil counters right after the singular recoil
	# decay: `if(recoils > 0){` / `if(curRecoils == null) curRecoils = new float[recoils];` /
	# `for(int i = 0; i < recoils; i++){` / `curRecoils[i] = Mathf.approachDelta(curRecoils[i], 0, 1 / recoilTime);` / `}`
	# (Turret.java:520-525). The field is `public @Nullable float[] curRecoils;` (:285),
	# null until the first updateTile tick allocates it, and the class default is
	# `public int recoils = -1;` (:142) -- but duo overrides it: `recoils = 2;`
	# (Blocks.java:3301, inside the duo block 3257-3330), so the loop DOES apply
	# to duo: its two drawer barrel parts carry recoilIndex 0 / 1 (Blocks.java:3302-3311)
	# and DrawTurret reads `tb.curRecoils[part.recoilIndex]` (DrawTurret.java:104/115),
	# so without the decay the barrel recoil never falls back toward 0. The init is
	# `if(recoilTime < 0f) recoilTime = reload;` (:208 -- duo reload is 20, N2250, so
	# recoilTime is 20 and each entry steps toward 0 by delta / 20, never past 0,
	# the same approachDelta as the singular decay (`curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);`,
	# :519; arc Mathf.java:415-422). The result is a 1-key dict: `cur_recoils`, a NEW
	# array of length recoils (missing entries read as 0.0, so a null / absent frame
	# key inits to zeros) -- the input array is never mutated. Delta is the
	# live-loop seconds value, the same convention as the N2254 recoil/heat decay.
	var decayed: Array = []
	if recoils > 0:
		for i in range(recoils):
			var value: float = 0.0
			if i < cur_recoils.size():
				value = float(cur_recoils[i])
			decayed.append(value + clampf(0.0 - value, -delta / recoil_time, delta / recoil_time))
	return {"cur_recoils": decayed}

@warning_ignore("unused_parameter")
static func source_turret_shoot_stamp_state(cur_recoil: float, heat: float, total_shots: int) -> Dictionary:
	# TurretBuild.bullet() (Turret.java:779-812) stamps the recoil
	# and the heat and counts the shot after the bullet is created
	# and handled: `curRecoil = 1f;` (Turret.java:806),
	# `heat = 1f;` (:810) and `totalShots++;` (:811). The fields are
	# `public float curRecoil, heat, logicControlTime = -1;` (:284) and
	# `public int totalShots, barrelCounter;` (:287), both default 0.
	# The multi-recoil stamp (`if(recoils > 0){` /
	# `curRecoils[barrelCounter % recoils] = 1f;` / `}`, :807-809) is
	# NOT this slice: it waits for its own slice (N2257) -- duo
	# recoils is 2 (`recoils = 2;`, Blocks.java:3301), not the -1
	# class default (`public int recoils = -1;`, :142), so the
	# branch applies to duo. The effects / sound / shake lines
	# (:799-805) are NOT this slice either. The result is a 3-key
	# dict: `cur_recoil` 1.0, `heat` 1.0 and `total_shots` (the
	# pre-shot count + 1). The inputs are the pre-shot frame values,
	# so the pure function maps any decayed recoil / heat to 1.0 and
	# any count to count + 1; the next tick decays from 1.0 (N2254).
	return {"cur_recoil": 1.0, "heat": 1.0, "total_shots": total_shots + 1}

static func source_turret_multi_recoil_stamp_state(cur_recoils: Array, barrel: int, recoils: int) -> Dictionary:
	# TurretBuild.bullet() (Turret.java:779-812) stamps the
	# per-barrel recoil counter of the barrel that just fired
	# after the bullet is created and handled: `curRecoil = 1f;`
	# / `if(recoils > 0){` / `curRecoils[barrelCounter % recoils] = 1f;` / `}` /
	# `heat = 1f;` / `totalShots++;` (Turret.java:806-811).
	# The field is `public @Nullable float[] curRecoils;` (:285),
	# null until the first updateTile tick allocates it (N2256
	# decay), and the class default is `public int recoils = -1;`
	# (:142) -- but duo overrides it: `recoils = 2;`
	# (Blocks.java:3301, inside the duo block 3257-3330), so the
	# branch DOES apply to duo: its two drawer barrel parts
	# carry recoilIndex 0 / 1 (Blocks.java:3302-3311) and
	# DrawTurret reads `tb.curRecoils[part.recoilIndex]`
	# (DrawTurret.java:104/115). The counter is
	# `public int totalShots, barrelCounter;` (:287); the barrel
	# is the pre-increment barrelCounter -- pattern.shoot runs
	# before the `}, () -> barrelCounter++);` incrementer
	# (Turret.java:770). The result is a 1-key dict:
	# `cur_recoils`, a NEW array of length recoils (missing
	# entries read as 0.0, so a null / absent frame key inits
	# to zeros) with entry barrel % recoils stamped to 1.0 and
	# every other entry untouched -- the input array is never
	# mutated. When recoils <= 0 the Java guard does nothing,
	# so the function returns the input unchanged.
	var stamped: Array = []
	if recoils > 0:
		for i in range(recoils):
			var value: float = 0.0
			if i < cur_recoils.size():
				value = float(cur_recoils[i])
			stamped.append(value)
		stamped[barrel % recoils] = 1.0
		return {"cur_recoils": stamped}
	return {"cur_recoils": cur_recoils}

static func source_turret_recoil_offset_state(rotation: float, cur_recoil: float, recoil_pow: float, recoil: float) -> Dictionary:
	# TurretBuild.updateTile() (Turret.java:490-615) recomputes
	# the draw offset every tick, after the recoil/heat decay
	# (:519/:526) and before turnToTarget (:595-596) and
	# updateShooting (:601/:609): `recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);`
	# (Turret.java:532). The field is `public Vec2 recoilOffset = new Vec2();`
	# (:280, `/** Turret sprite offset, based on recoil. Updated
	# every frame. */`), the power curve is `public float recoilPow = 1.8f;`
	# (:146, `/** power curve applied to visual recoil */`) and the
	# class default is `public float recoil = 1f;`
	# (:140, `/** Visual amount by which the turret recoils back
	# per shot. */`) -- duo overrides it with `recoil = 0.5f;`
	# (Blocks.java:3315, inside the duo block 3257-3330). The
	# field is `public float curRecoil, heat, logicControlTime = -1;`
	# (:284). trns sets the vector from the angle and the length
	# (x = cos(rotation) * mag, y = sin(rotation) * mag, mag =
	# -pow(cur_recoil, recoil_pow) * recoil), so a fresh shot
	# (curRecoil 1.0) kicks the sprite back along its rotation by
	# exactly recoil, and no recoil leaves the offset at zero.
	# The result is a 1-key dict: `recoil_offset`, a
	# `{"x": .., "y": ..}` dict -- the frame's JSON-friendly
	# convention, same as frame["target_pos"] from the N2250
	# aim state. The formula itself was already proven once on
	# the legacy PortGame path (N742,
	# `PortGame.source_turret_recoil_offset`, MCP: recoil 0.5 /
	# rotation 0 / curRecoil 1 -> Vector2(-0.5, 0.0)); this is
	# the LIVE frame tick on the new duo driver.
	var magnitude: float = -pow(cur_recoil, recoil_pow) * recoil
	var offset_x: float = cos(deg_to_rad(rotation)) * magnitude
	var offset_y: float = sin(deg_to_rad(rotation)) * magnitude
	return {"recoil_offset": {"x": offset_x, "y": offset_y}}

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
		# and there is no shouldConsume gate yet (Turret.java:364-366
		# needs targeting/reload state the tick does not track),
		# so the machinery runs with should_consume=true when
		# enabled. productionValid is the canonical true default
		# (SourceBuildingAccessState.production_valid_state()).
		var has_power_consumer: bool = bool(block.properties.has("consumePower"))
		if has_power_consumer and bool(frame.get("enabled", true)) and not bool(frame.get("cheating", false)):
			var should_consume: bool = bool(frame.get("enabled", true))
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
		if block_id == "duo":
			# The duo half of TurretBuild.updateTile() (Turret.java:490-615,
			# N2250): the aim / reload / shoot half runs on the shared
			# TurretBuild driver, guarded on block `duo` -- the only
			# ItemTurret def this slice ticks. The per-def duo values are
			# range 160, rotateSpeed 10, reload 20, shootCone 15, shootY 3,
			# inaccuracy 2 (Blocks.java:3257-3324, `range = 160;` /
			# `rotateSpeed = 10f;` / `reload = 20f;` / `shootCone = 15f;` /
			# `shootY = 3f;` / `inaccuracy = 2f;`), shootX 0 (the class
			# default, Turret.java:66), ammoPerShot 1 and consumeAmmoOnce
			# true (the class defaults, Turret.java:49/:51). The target
			# verdict is validateTarget (Turret.java:631-633, N2251):
			# the driver judges the acquired target at the head of
			# the duo branch, clears frame["target"] / frame["has_target"]
			# when the verdict is invalid (Turret.java:491,
			# `if(!validateTarget()) target = null;`), and feeds the
			# verdict into the aim/shoot target_valid arg -- target_valid
			# false leaves rotation at its charged value and shoots
			# nothing. findTarget acquisition still waits for its own
			# slice, so until then a frame with has_target false holds
			# no acquired target: the stale target dict (if any) counts
			# as null for the verdict, exactly as Java's target field
			# is null when nothing is acquired. The peeked ammo's reloadMultiplier /
			# rangeChange / speed come from the catalog ammo data
			# (copper 1.0/0/2.5, graphite 0.8/16/3.5, silicon 1.5/0/3,
			# Blocks.java:3259-3295) with the BulletType defaults
			# (BulletType.java:97/:157/:37) when the peeked type omits
			# them. potential_efficiency is the frame's stamped value
			# (duo has no power consumer, so the consumption branch above
			# never stamps it; the absent default is 1.0, the enabled +
			# production-valid first pass, BuildingComp.java:1946 -- the
			# coolant fold waits for its own slice, the driver's existing
			# "models no other consumers yet" approximation). shoot_warmup
			# is the frame's stamped warmup (N2253 advances it with the
			# warmup lerp before the aim/shoot call below; the absent
			# default is the 0.0 field default, and duo minWarmup is 0f
			# so the gate still passes).
			# charging is the frame's stamped flag (duo firstShotDelay is
			# 0, so charging is false live, but the gate is still checked).
			# baseReloadSpeed is efficiency (ReloadTurret.java:45-47,
			# `return efficiency;`), 1.0 before any stamp (the N2240
			# edelta precedent). The shot writes back live: rotation /
			# reload_counter / shot / shoot_event / dest / target_pos /
			# barrel_counter / was_shooting are stamped on the frame every
			# tick, and a shot persists the consumed ammo stacks + total
			# back to the game dicts (the N2247 write-back precedent).
			var duo_key: String = str(game.call("cell_key", cell))
			var duo_stacks_map: Dictionary = game.get("turret_ammo_stacks") if game.get("turret_ammo_stacks") is Dictionary else {}
			var duo_totals_map: Dictionary = game.get("turret_total_ammo") if game.get("turret_total_ammo") is Dictionary else {}
			var duo_entries: Array = duo_stacks_map.get(duo_key, [])
			var duo_total: int = int(duo_totals_map.get(duo_key, 0))
			var duo_peek: Dictionary = source_turret_ammo_state.peek_turret_ammo(game, cell, block)
			# peek_turret_ammo already returns the ammo_data dict
			# itself ({"item", "speed", "reloadMultiplier",
			# "rangeChange", ...}), not a wrapper with an
			# "ammo_data" key -- unwrapping it again yields {}
			# and silently falls back to speed 1.0 /
			# reloadMultiplier 1.0 / rangeChange 0.0.
			var duo_ammo_data: Dictionary = duo_peek
			# validateTarget() at the head of the duo branch
			# (Turret.java:491, `if(!validateTarget()) target = null;`,
			# N2251): a frame with has_target false holds no acquired
			# target, so its target dict (if any) counts as null for
			# the verdict -- in Java the target field is null when
			# nothing is acquired. An invalid verdict clears the frame
			# target and feeds false into the aim/shoot target_valid
			# arg; the team / health / targetable / controlled bools
			# are stamped in from the frame with vacuous defaults
			# (health_valid / unit_targetable true, same team /
			# controlled / logic_controlled false) until their live
			# wiring lands in its own slice.
			var validate: Dictionary = source_item_turret_build_state.source_item_turret_validate_target_state(
				frame.get("target", null) == null or not bool(frame.get("has_target", false)),
				bool(frame.get("target_same_team_effective", false)),
				bool(frame.get("target_health_valid", true)),
				bool(frame.get("target_unit_targetable", true)),
				bool(frame.get("controlled", false)),
				bool(frame.get("logic_controlled", false)))
			if not bool(validate.get("valid", true)):
				frame["target"] = null
				frame["has_target"] = false
			# The warmup lerp advance (Turret.java:502-515, N2253)
			# runs before the aim/shoot call: Java order :502-514
			# is before the shoot gate :733, and aim/shoot read
			# shoot_warmup as a gate input. canConsume reads the
			# peek (last) stack amount (Turret.java:711,
			# `return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());`)
			# against ammoPerShot 1 for duo.
			var duo_peek_amount: int = 0
			if not duo_entries.is_empty():
				var duo_peek_entry: Dictionary = duo_entries[duo_entries.size() - 1]
				duo_peek_amount = int(duo_peek_entry.get("amount", 0))
			var duo_can_consume: bool = not duo_entries.is_empty() and (duo_peek_amount >= 1 or bool(frame.get("cheating", false)))
			var warmup: Dictionary = source_turret_warmup_state(float(frame.get("shoot_warmup", 0.0)), float(frame.get("warmup_hold", 0.0)), bool(frame.get("has_target", false)) and bool(validate.get("valid", false)), duo_can_consume, bool(frame.get("charging", false)), bool(frame.get("controlled", false)), float(frame.get("efficiency", 1.0)), seconds, 0.1, false, 0.0)
			frame["shoot_warmup"] = warmup.get("shoot_warmup", 0.0)
			frame["warmup_hold"] = warmup.get("warmup_hold", 0.0)
			# The recoil/heat decay (Turret.java:519/:526, N2254)
			# runs after the warmup advance and before the aim/shoot
			# call: Java order :519/:526 is after :502-515 and before
			# the shoot gate :733. Duo recoilTime is reload 20
			# (Turret.java:208) and cooldownTime is the class default
			# 20 (:148), so the driver passes 20.0 / 20.0.
			var recoil_heat: Dictionary = source_turret_recoil_heat_state(float(frame.get("cur_recoil", 0.0)), float(frame.get("heat", 0.0)), 20.0, 20.0, seconds)
			frame["cur_recoil"] = recoil_heat.get("cur_recoil", 0.0)
			frame["heat"] = recoil_heat.get("heat", 0.0)
			# The multi-recoil decay (Turret.java:520-525, N2256)
			# runs right after the singular recoil/heat decay:
			# Java order :519 then :520-525. Duo recoils is 2
			# (Blocks.java:3301, not the -1 class default at
			# Turret.java:142), recoilTime is reload 20
			# (Turret.java:208), so the driver passes 2 / 20.0.
			var multi_recoil: Dictionary = source_turret_multi_recoil_state(frame.get("cur_recoils", []), 2, 20.0, seconds)
			frame["cur_recoils"] = multi_recoil.get("cur_recoils", [])
			# The recoilOffset draw (Turret.java:532, N2258) runs
			# right after the recoil decays: Java order :519/:520-525
			# decay, :532 offset, :595-596 turnToTarget, :601/:609
			# updateShooting -- so the offset uses the PREVIOUS
			# tick's rotation (frame["rotation"], default 90.0 like
			# the aim stamp) and the cur_recoil DECAYED this tick,
			# and it lags a shot by one tick (the tick that shoots
			# still offsets from the pre-shot recoil; the next tick
			# kicks). Duo recoilPow is 1.8 (Turret.java:146) and
			# duo recoil is 0.5 (Blocks.java:3315, not the 1.0
			# class default at Turret.java:140).
			var recoil_offset: Dictionary = source_turret_recoil_offset_state(float(frame.get("rotation", 90.0)), float(frame.get("cur_recoil", 0.0)), 1.8, 0.5)
			frame["recoil_offset"] = recoil_offset.get("recoil_offset", {"x": 0.0, "y": 0.0})
			var aim: Dictionary = source_item_turret_build_state.source_item_turret_aim_shoot_state(frame, frame.get("target", null),
				bool(validate.get("valid", false)), team_id, sprite.position.x, sprite.position.y, seconds,
				float(frame.get("potential_efficiency", 1.0)), float(frame.get("shoot_warmup", 0.0)), bool(frame.get("charging", false)),
				duo_entries, duo_total, int(frame.get("barrel_counter", 0)),
				160.0, 10.0, 20.0, 15.0, 0.0, 3.0, 2.0, 1, true,
				float(duo_ammo_data.get("reloadMultiplier", 1.0)), float(duo_ammo_data.get("rangeChange", 0.0)), float(duo_ammo_data.get("speed", 1.0)),
				true, 0.0, false, bool(frame.get("cheating", false)), float(frame.get("efficiency", 1.0)))
			frame["rotation"] = aim.get("rotation", 90.0)
			frame["reload_counter"] = aim.get("reload_counter", 0.0)
			frame["shot"] = aim.get("shot", false)
			frame["shoot_event"] = aim.get("shoot_event", null)
			frame["dest"] = aim.get("dest", null)
			frame["target_pos"] = aim.get("target_pos", null)
			frame["barrel_counter"] = aim.get("barrel_counter_after", 0)
			frame["was_shooting"] = aim.get("was_shooting", false)
			if bool(aim.get("shot", false)):
				duo_stacks_map[duo_key] = aim.get("ammo_entries_after", duo_entries)
				duo_totals_map[duo_key] = int(aim.get("total_ammo_after", duo_total))
				game.set("turret_ammo_stacks", duo_stacks_map)
				game.set("turret_total_ammo", duo_totals_map)
				# bullet() spawn (Turret.java:779-801, N2252): the
				# shoot_event N2250 computed is consumed here -- the
				# pure function derives the spawn origin / angle /
				# velocity from it (ShootAlternate barrel offset,
				# inaccuracy draw, lifeScl 1.0 for duo), the spawn
				# dict is stamped on the frame, and the origin +
				# shoot_angle + the peeked ammo_data go to the
				# existing runtime spawn bridge
				# (SourceBulletRuntimeState.spawn_turret_bullet --
				# the single writer of game["bullets"], N2242/N2243:
				# it converts speed to per-second (x60) and lifetime
				# to seconds (/60) and appends the live dict with
				# the team stamp). The barrel is the pre-increment
				# shoot_event barrel (pattern.shoot runs before the
				# `}, () -> barrelCounter++);` incrementer,
				# Turret.java:770). The random draws are params:
				# x_spread defaults 0.0 (xRand is 0 for duo) and
				# inaccuracy_draw defaults to a live randf_range(-2,
				# 2) draw -- the +-2 degrees faithful to Java -- while
				# the proof seeds a fixed draw through the frame key,
				# so the pure function itself never calls randf.
				var shoot_event: Dictionary = aim.get("shoot_event", {})
				var spawn: Dictionary = source_item_turret_build_state.source_item_turret_bullet_spawn_state(
					shoot_event, sprite.position.x, sprite.position.y, aim.get("target_pos", null),
					int(shoot_event.get("barrel", 0)),
					0.0, 3.0, 3.5, 2, 0, false,
					float(frame.get("x_spread", 0.0)), float(frame.get("inaccuracy_draw", randf_range(-2.0, 2.0))), float(duo_ammo_data.get("speed", 1.0)), float(duo_ammo_data.get("damage", 0.0)),
					float(duo_ammo_data.get("lifetime", 40.0)), float(duo_ammo_data.get("hitSize", 4.0)), 160.0)
				frame["bullet_spawn"] = spawn
				source_bullet_runtime_state.spawn_turret_bullet(game, Vector2(float(spawn.get("bullet_x", 0.0)), float(spawn.get("bullet_y", 0.0))), frame.get("target", null), duo_ammo_data, team_id, float(spawn.get("shoot_angle", 90.0)))
				# The shoot stamp (Turret.java:806-811, N2255)
				# runs after bullet() creates the bullet (:797):
				# `curRecoil = 1f;` / `heat = 1f;` /
				# `totalShots++;` -- the recoil and the heat are
				# 1.0 on the frame until the next tick decays
				# them (N2254), and the shot is counted.
				var shoot_stamp: Dictionary = source_turret_shoot_stamp_state(float(frame.get("cur_recoil", 0.0)), float(frame.get("heat", 0.0)), int(frame.get("total_shots", 0)))
				frame["cur_recoil"] = shoot_stamp.get("cur_recoil", 1.0)
				frame["heat"] = shoot_stamp.get("heat", 1.0)
				frame["total_shots"] = shoot_stamp.get("total_shots", 0)
				# The multi-recoil stamp (Turret.java:807-809, N2257)
				# runs right after the singular shoot stamp: Java
				# order :806 then :807-809, both inside bullet(),
				# after the bullet spawn (:797). The barrel is the
				# pre-increment shoot_event barrel (pattern.shoot
				# runs before the barrelCounter++ incrementer,
				# Turret.java:770) -- NOT frame["barrel_counter"],
				# which the aim tick already stamped with
				# barrel_counter_after = barrelCounter + 1. Duo
				# recoils is 2 (Blocks.java:3301, not the -1 class
				# default at Turret.java:142).
				var multi_recoil_stamp: Dictionary = source_turret_multi_recoil_stamp_state(frame.get("cur_recoils", []), int(shoot_event.get("barrel", 0)), 2)
				frame["cur_recoils"] = multi_recoil_stamp.get("cur_recoils", [])
		results_by_cell[game.call("cell_key", cell)] = wired
		ticked_count += 1
	return {"ticked_count": ticked_count, "results_by_cell": results_by_cell}
