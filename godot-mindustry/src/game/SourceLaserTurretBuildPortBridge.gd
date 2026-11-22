extends "res://src/game/SourceBaseTurretDrawPortBridge.gd"

# LaserTurretBuild.shouldConsume() (LaserTurret.java:53-58):
# `@Override`
# `public boolean shouldConsume(){`
# `//still consumes power when bullet is around`
# `if(bullets.any() || isActive()) return true;`
# `return isShooting;`
# `}`
# on `public class LaserTurretBuild extends PowerTurretBuild{`
# (LaserTurret.java:44) inside
# `public class LaserTurret extends PowerTurret{`.
# This is the LaserTurret override: the turret still consumes
# power while a bullet is around (bullets.any()) or while it
# is active (isActive(), N2328); otherwise it consumes only
# while shooting (isShooting, N2343). The other shouldConsume
# overrides own their own bodies and are NOT touched here --
# TurretBuild base (N2291), ContinuousLiquidTurretBuild
# (N1225), TractorBeamBuild (N1235), DrillBuild (N2338),
# BurstDrillBuild (N2295). bullets is `public Seq<BulletEntry>
# bullets = new Seq<>();` (LaserTurret.java:45): the seq itself
# is NOT ported -- its emptiness arrives as the explicit
# has_bullets param (the N2330 param precedent). isActive()
# is owned at N2328 and isShooting at N2343 -- their values
# arrive as explicit params; this slice does NOT re-port them.
# NO driver line: a pure predicate the power graph reads, not
# a per-tick write.
static func source_laser_turret_build_should_consume_state(has_bullets: bool, is_active: bool, is_shooting: bool) -> Dictionary:
	var should_consume: bool = is_shooting
	if has_bullets or is_active:
		should_consume = true
	return {"should_consume": should_consume}


# LaserTurretBuild.updateShooting() (LaserTurret.java:120-132):
# `protected void updateShooting(){`
# `if(bullets.any()){`
# `return;`
# `}`
# `if(reloadCounter <= 0 && efficiency > 0 && !charging() && shootWarmup >= minWarmup){`
# `BulletType type = peekAmmo();`
# `shoot(type);`
# `reloadCounter = reload;`
# `}`
# `}`
# on `public class LaserTurretBuild extends PowerTurretBuild{`
# (LaserTurret.java:44) inside
# `public class LaserTurret extends PowerTurret{`.
# The turret shoots only when no bullet is around and the
# guard holds (reloadCounter <= 0, efficiency > 0, not
# charging, shootWarmup >= minWarmup). bullets is
# `public Seq<BulletEntry> bullets = new Seq<>();`
# (LaserTurret.java:45): the seq itself is NOT ported --
# its emptiness arrives as the explicit has_bullets param
# (the N2330 param precedent). peekAmmo() is owned at
# N1172 (PowerTurretBuild, body `return shootType;`) and
# charging() at Turret.java:715-717 (`return queuedBullets
# > 0 && shoot.firstShotDelay > 0;`) -- their values
# arrive as explicit params; shoot(type) is a callee the
# driver performs, so this pure function only decides
# whether to shoot, which type to shoot, and the new
# reloadCounter (reload when shooting, unchanged
# otherwise). NO driver line: a pure decision function the
# tick reads, not a per-tick write.
static func source_laser_turret_build_update_shooting_state(has_bullets: bool, reload_counter: float, efficiency: float, charging: bool, shoot_warmup: float, min_warmup: float, reload: float, ammo_type: Variant) -> Dictionary:
	var should_shoot: bool = false
	var shoot_type: Variant = null
	var new_reload_counter: float = reload_counter
	if not has_bullets:
		if reload_counter <= 0.0 and efficiency > 0.0 and not charging and shoot_warmup >= min_warmup:
			should_shoot = true
			shoot_type = ammo_type
			new_reload_counter = reload
	return {"should_shoot": should_shoot, "shoot_type": shoot_type, "reload_counter": new_reload_counter}


# LaserTurretBuild.turnToTarget() (LaserTurret.java:135-137):
# `@Override`
# `protected void turnToTarget(float targetRot){`
# `rotation = Angles.moveToward(rotation, targetRot, efficiency * rotateSpeed * delta() * (bullets.any() ? firingMoveFract : 1f));`
# `}`
# LaserTurretBuild.handleBullet() (LaserTurret.java:140-144):
# `@Override`
# `protected void handleBullet(@Nullable Bullet bullet, float offsetX, float offsetY, float angleOffset){`
# `if(bullet != null){`
# `bullets.add(new BulletEntry(bullet, offsetX, offsetY, angleOffset, shootDuration));`
# `}`
# `}`
# on `public class LaserTurretBuild extends PowerTurretBuild{`
# (LaserTurret.java:44) inside
# `public class LaserTurret extends PowerTurret{`.
# MERGED slice (N2346/N2336 precedent): ONE pure function,
# ONE owner, covering BOTH java methods -- the rotation
# turn and the bullet entry are one driver step (the tick
# turns then hands the bullet over), and both read the
# same bullets-any() state. Angles.moveToward is NOT
# re-ported: it already exists as
# SourceMathState.source_angles_move_toward (wraparound,
# snaps when closer than the step). The step is scaled by
# firingMoveFract (LaserTurret.java:16,
# `public float firingMoveFract = 0.25f;`) only while a
# bullet is around, full speed otherwise. bullets is
# `public Seq<BulletEntry> bullets = new Seq<>();`
# (LaserTurret.java:45): the seq itself is NOT ported --
# its emptiness arrives as the explicit has_bullets param
# (the N2330 param precedent). handleBullet appends a
# BulletEntry (Turret.java:864-876, fields bullet/x/y/
# rotation/life, positional from the constructor call:
# offsetX -> x, offsetY -> y, angleOffset -> rotation,
# shootDuration -> life) only for a non-null bullet; the
# seq append itself is the driver-side effect, so this
# pure function returns the entry dict (or null) and the
# driver adds it. Distinguishing Laser from
# ContinuousTurretBuild.turnToTarget/handleBullet (NOT
# owned, later batch): Laser uses firingMoveFract while
# bullets are around and shootDuration as the entry life
# (LaserTurret.java:17, `public float shootDuration =
# 100f;`); Continuous uses duration 0f and initialises
# aim from Tmp.v1 -- no dedup between them. NO driver
# line: pure functions the tick reads, not per-tick writes.
static func source_laser_turret_build_turn_to_target_handle_bullet_state(rotation: float, target_rot: float, efficiency: float, rotate_speed: float, delta: float, has_bullets: bool, firing_move_fract: float, bullet: Variant, offset_x: float, offset_y: float, angle_offset: float, shoot_duration: float) -> Dictionary:
	var move_fract: float = firing_move_fract if has_bullets else 1.0
	var new_rotation: float = source_math_state.source_angles_move_toward(rotation, target_rot, efficiency * rotate_speed * delta * move_fract)
	var bullet_entry: Variant = null
	if bullet != null:
		bullet_entry = {"bullet": bullet, "x": offset_x, "y": offset_y, "rotation": angle_offset, "life": shoot_duration}
	return {"rotation": new_rotation, "bullet_entry": bullet_entry}


# LaserTurretBuild.updateTile() LEG 1 (LaserTurret.java:67-89):
# `public void updateTile(){`
# `super.updateTile();`
# `bullets.removeAll(b -> !b.bullet.isAdded() || b.bullet.type == null || b.life <= 0f || b.bullet.owner != this);`
# `if(bullets.any()){`
# `for(var entry : bullets){`
# `float`
# `bulletX = x + Angles.trnsx(rotation - 90, shootX + entry.x, shootY + entry.y),`
# `bulletY = y + Angles.trnsy(rotation - 90, shootX + entry.x, shootY + entry.y),`
# `angle = rotation + entry.rotation;`
# `entry.bullet.rotation(angle);`
# `entry.bullet.set(bulletX, bulletY);`
# `entry.bullet.time = entry.bullet.type.lifetime * entry.bullet.type.optimalLifeFract;`
# `entry.bullet.keepAlive = true;`
# `entry.life -= Time.delta * timeScale / Math.max(efficiency, 0.00001f);`
# `}`
# `wasShooting = true;`
# `heat = 1f;`
# `curRecoil = 1f;`
# `}else if(reloadCounter > 0){`
# `... (LEG 2, a later slice) ...`
# `}`
# `}`
# on `public class LaserTurretBuild extends PowerTurretBuild{`
# (LaserTurret.java:44) inside
# `public class LaserTurret extends PowerTurret{`.
# LEG 1 is the whole bullets.any() branch: prune dead bullet
# entries, update each survivor's bullet position/rotation/
# time/keepAlive and decay its life, then set wasShooting/
# heat/curRecoil. Leg 2 (the else-if reloadCounter > 0
# branch, LaserTurret.java:90-108) is a LATER slice: the
# two legs' write-sets are disjoint (leg 1 writes
# bullets/wasShooting/heat/curRecoil, leg 2 writes
# reloadCounter/liquids), the only join is the if/else-if
# guard, and leg 1 returns the branch flag "reload_branch":
# "bullets" (leg 2 later returns "coolant"|"edelta").
# Leg-split approved by the main thread (write-sets
# disjoint, BurstDrill updateTile leg precedent
# N2294+N2149+N2296).
# RED decisions: (1) `super.updateTile();` is a shared
# callee (exact hit in 7 local slices), NOT a
# distinguishing expr. (2) `heat = 1f;` / `wasShooting =
# true;` / `curRecoil = 1f;` are state outputs in the
# returned dict, NOT distinguishing exprs. (3) The shared
# lines `entry.bullet.rotation(angle);` /
# `entry.bullet.set(bulletX, bulletY);` /
# `entry.bullet.keepAlive = true;` (exact 1 hit local:
# N2366, different class), `for(var entry : bullets){`
# (N2362), the three float declarators (N2366),
# `if(bullets.any()){` (N2362, N2364, N2367) are
# text-shares across classes/methods, registered under
# this java_method (the N632-N639 vs N1078-N1085
# precedent). (4) Angles.trnsx/trnsy here are the
# THREE-arg overloads (Angles.java:74-79): they rotate the
# (shootX + entry.x, shootY + entry.y) offset vector by
# rotation - 90 degrees -- NOT the len overloads -- so the
# offset is Vector2(...).rotated(deg_to_rad(rotation - 90))
# (the N2366 precedent). (5) Time.delta arrives as the
# explicit source_delta param (the N2330 param precedent);
# Math.max(efficiency, 0.00001f) is maxf. (6) The bullets
# seq is NOT ported: it arrives as an explicit Array of
# entry dicts {x, y, rotation, life, bullet: {is_added,
# type_null, owner_is_self, time, lifetime,
# type_optimal_life_fract, keep_alive, rotation, x, y}}
# (the N2330 param precedent); the input array is never
# mutated, the pruned+updated list is fresh. (7) NO driver
# line: a pure function the tick reads, not a per-tick
# write; the driver writes the returned bullets back and
# evaluates leg 2 when reload_branch is "reload".
static func source_laser_turret_build_update_tile_leg1_state(bullets: Array, x: float, y: float, rotation: float, shoot_x: float, shoot_y: float, efficiency: float, time_scale: float, source_delta: float, heat: float, cur_recoil: float) -> Dictionary:
	var pruned: Array = []
	for entry in bullets:
		var e: Dictionary = entry
		var bullet: Dictionary = e.get("bullet", {})
		if bool(bullet.get("is_added", false)) and not bool(bullet.get("type_null", true)) and float(e.get("life", 0.0)) > 0.0 and bool(bullet.get("owner_is_self", false)):
			var entry_x: float = float(e.get("x", 0.0))
			var entry_y: float = float(e.get("y", 0.0))
			var entry_rotation: float = float(e.get("rotation", 0.0))
			var offset: Vector2 = Vector2(shoot_x + entry_x, shoot_y + entry_y).rotated(deg_to_rad(rotation - 90.0))
			var bullet_x: float = x + offset.x
			var bullet_y: float = y + offset.y
			var angle: float = rotation + entry_rotation
			var new_life: float = float(e.get("life", 0.0)) - source_delta * time_scale / maxf(efficiency, 0.00001)
			var new_bullet: Dictionary = {
				"is_added": bool(bullet.get("is_added", false)),
				"type_null": bool(bullet.get("type_null", true)),
				"owner_is_self": bool(bullet.get("owner_is_self", false)),
				"time": float(bullet.get("lifetime", 0.0)) * float(bullet.get("type_optimal_life_fract", 0.0)),
				"lifetime": float(bullet.get("lifetime", 0.0)),
				"type_optimal_life_fract": float(bullet.get("type_optimal_life_fract", 0.0)),
				"keep_alive": true,
				"rotation": angle,
				"x": bullet_x,
				"y": bullet_y,
			}
			pruned.append({"x": entry_x, "y": entry_y, "rotation": entry_rotation, "life": new_life, "bullet": new_bullet})
	var was_shooting: bool = not pruned.is_empty()
	var next_heat: float = 1.0 if was_shooting else heat
	var next_cur_recoil: float = 1.0 if was_shooting else cur_recoil
	var reload_branch: String = "bullets" if was_shooting else "reload"
	return {"bullets": pruned, "was_shooting": was_shooting, "heat": next_heat, "cur_recoil": next_cur_recoil, "reload_branch": reload_branch}


# LaserTurretBuild.updateTile() LEG 2 (LaserTurret.java:90-106):
# `}else if(reloadCounter > 0){`
# `if(coolant != null){`
# `//TODO does not handle multi liquid req?`
# `Liquid liquid = liquids.current();`
# `float maxUsed = coolant.amount;`
# `float used = (cheating() ? maxUsed : Math.min(liquids.get(liquid), maxUsed)) * delta();`
# `reloadCounter -= used * liquid.heatCapacity * coolantMultiplier;`
# `liquids.remove(liquid, used);`
# `if(Mathf.chance(0.06 * used)){`
# `coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));`
# `}`
# `}else{`
# `reloadCounter -= edelta();`
# `}`
# `}`
# on `public class LaserTurretBuild extends PowerTurretBuild{`
# (LaserTurret.java:44) inside
# `public class LaserTurret extends PowerTurret{`.
# LEG 2 is the whole else-if reloadCounter > 0 branch:
# with coolant, burn liquid to cool the reload counter
# down (used * liquid.heatCapacity *
# coolantMultiplier) and remove the used liquid,
# sometimes spawning the cool effect; without coolant,
# the counter falls by edelta(). The class decls,
# @Override, `public void updateTile(){` and
# `if(bullets.any()){` are NOT re-registered here --
# they stay owned by N2372 (leg 1) and are only
# context/callees for this leg.
# RED decisions: (1) The guard `reloadCounter > 0` is
# evaluated inside the pure function (the leg-1
# precedent: leg 1 evaluates bullets.any() itself and
# returns the branch flag); when the guard fails
# nothing happens and reload_branch is "none". (2)
# `coolant` is `ConsumeLiquid` (Turret.java, field
# `coolant`, `coolant.amount` is the per-second cap):
# it arrives as an explicit Dictionary {amount} or
# null. `coolantMultiplier` is a LaserTurret field
# with default 1f (LaserTurret.java:22,
# `coolantMultiplier = 1f;`): it arrives as an
# explicit float, the driver passes 1.0 when unset.
# `reload` is NOT a param: it never appears in
# LaserTurret.java:90-106 (progress() reads it, a
# different method). (3) `liquids` is the
# LiquidModule (BuildingComp.liquids): it arrives as
# an explicit Dictionary (liquid name -> amount) and
# is NEVER mutated -- the returned dict is fresh.
# `liquids.current()` arrives as the explicit
# current_liquid key (the N1243 TractorBeam coolant
# precedent); `liquids.get(liquid)` is the stored
# amount for that key (0 when absent); `liquids.
# remove(liquid, used)` caps the removal at zero
# (LiquidModule.remove: "cap to prevent negative
# removal", `add(liquid, Math.max(-amount,
# -liquids[liquid.id]))`). When cheating, used =
# maxUsed * delta() even if less is stored, so the
# removal still caps at zero. When current_liquid
# is null there is nothing to remove and the liquids
# dict passes through unchanged. (4) cheating() /
# delta() / edelta() are Building methods
# (BuildingComp.java:1922-1930: delta() is Time.delta
# * timeScale, edelta() is efficiency * delta()):
# they arrive as explicit cheating/delta/edelta
# params. (5) `Mathf.chance(0.06 * used)` arrives as
# the explicit chance_result bool and the two
# `Mathf.range(size * tilesize / 2f)` offsets as
# explicit range_x/range_y floats (the N1246
# TractorBeam coolant-effect precedent); the effect
# itself is NOT ported -- the pure function returns
# the cool_effect_call dict (or {} when not
# spawned), the driver performs the spawn. (6) The
# TODO comment ("does not handle multi liquid req?")
# is recorded here only: single-current-liquid
# behaviour is what the code does. (7) NO driver
# line: a pure function the tick reads, not a
# per-tick write; the driver writes the returned
# reloadCounter/liquids back when reload_branch is
# "coolant" or "edelta".
static func source_laser_turret_build_update_tile_leg2_state(reload_counter: float, coolant: Variant, coolant_multiplier: float, cheating: bool, delta: float, edelta: float, liquids: Dictionary, current_liquid: Variant, liquid_heat_capacity: float, chance_result: bool, x: float, y: float, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	var max_used: float = 0.0
	var used: float = 0.0
	var new_reload_counter: float = reload_counter
	var new_liquids: Dictionary = liquids.duplicate()
	var reload_branch: String = "none"
	var cool_effect_called: bool = false
	var cool_effect_call: Dictionary = {}
	if reload_counter > 0.0:
		if coolant != null:
			var coolant_dict: Dictionary = coolant
			max_used = float(coolant_dict.get("amount", 0.0))
			var stored: float = 0.0
			if current_liquid != null:
				stored = float(liquids.get(current_liquid, 0.0))
			var base: float = max_used if cheating else minf(stored, max_used)
			used = base * delta
			new_reload_counter = reload_counter - used * liquid_heat_capacity * coolant_multiplier
			if current_liquid != null:
				new_liquids[current_liquid] = maxf(0.0, stored - used)
			reload_branch = "coolant"
			if chance_result:
				cool_effect_called = true
				cool_effect_call = {"call": "coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));", "x": x + range_x, "y": y + range_y, "range": size * source_tilesize / 2.0}
		else:
			new_reload_counter = reload_counter - edelta
			reload_branch = "edelta"
	return {"reload_counter": new_reload_counter, "liquids": new_liquids, "used": used, "max_used": max_used, "reload_branch": reload_branch, "cool_effect_called": cool_effect_called, "cool_effect_call": cool_effect_call}


# LaserTurret.setStats() (LaserTurret.java:26-33):
# `public void setStats(){`
# `super.setStats();`
# `stats.remove(Stat.booster);`
# `if(coolant != null){`
# `stats.add(Stat.input, StatValues.boosters(reload, coolant.amount, coolantMultiplier, false, this::consumesLiquid));`
# `}`
# `}`
# on `public class LaserTurret extends PowerTurret{`
# (LaserTurret.java:15) inside
# `public class LaserTurret extends PowerTurret{`.
# setStats drops the booster stat row (the base
# Turret stats add a booster row that does not apply
# to the laser) and, when a coolant consumer exists,
# adds an input row with the boosters spec: reload,
# coolant.amount, coolantMultiplier, baseReload
# false, and the consumesLiquid filter. `super.
# setStats();` is a shared callee (exact hit in 18
# local slices), NOT a distinguishing expr. `stats`
# is the Stats UI object: it arrives as an explicit
# Array of row dicts (the N2384 setStats precedent)
# and is NEVER mutated -- the returned rows are
# fresh. `coolant` is `ConsumeLiquidBase`
# (BaseTurret.java:34, `public @Nullable
# ConsumeLiquidBase coolant;`): it arrives as an
# explicit Dictionary {amount} or null.
# `coolantMultiplier` is a LaserTurret field with
# default 1f (LaserTurret.java:22,
# `coolantMultiplier = 1f;`): it arrives as an
# explicit float. `this::consumesLiquid` is
# Block.consumesLiquid (Block.java:778,
# `public boolean consumesLiquid(Liquid liq)`): the
# Boolf<Liquid> filter StatValues.boosters takes
# (StatValues.java:439, `public static StatValue
# boosters(float reload, float maxUsed, float
# multiplier, boolean baseReload, Boolf<Liquid>
# filter)`) -- it arrives as an explicit Callable,
# the driver evaluates it per liquid when rendering
# the row. NO driver line: a pure function the setup
# reads, not a per-tick write.
static func source_laser_turret_build_set_stats_state(stats: Array, coolant: Variant, reload: float, coolant_multiplier: float, consumes_liquid: Callable) -> Dictionary:
	var rows: Array = []
	for row in stats:
		var stat_row: Dictionary = (row as Dictionary).duplicate()
		if stat_row.get("stat", "") == "booster":
			continue
		rows.append(stat_row)
	if coolant != null:
		var coolant_dict: Dictionary = coolant
		rows.append({"stat": "input", "boosters": {"reload": reload, "coolant_amount": float(coolant_dict.get("amount", 0.0)), "coolant_multiplier": coolant_multiplier, "base_reload": false, "consumes_liquid": consumes_liquid}})
	return {"stats": rows}


# LaserTurret.init() (LaserTurret.java:36-43):
# `@Override`
# `public void init(){`
# `super.init();`
# `if(coolant == null){`
# `coolant = findConsumer(c -> c instanceof ConsumeLiquidBase);`
# `}`
# `}`
# on `public class LaserTurret extends PowerTurret{`
# (LaserTurret.java:15) inside
# `public class LaserTurret extends PowerTurret{`.
# init resolves the coolant consumer when it is still
# null: findConsumer takes the predicate `c ->
# c instanceof ConsumeLiquidBase` (Block.java:1104,
# `public <T extends Consume> T findConsumer(Boolf
# <Consume> filter)`) and returns the first matching
# consumer, or null when none matches. The predicate
# itself is NOT ported -- the driver runs
# findConsumer and the found consumer arrives as the
# explicit found_consumer param (nullable), following
# the brief's approved shape. `super.init();` is a
# shared callee (exact hit in 38 local slices), NOT
# a distinguishing expr. When coolant is already set
# the finder never runs and the value passes through
# unchanged. NO driver line: a pure function the setup
# reads, not a per-tick write.
static func source_laser_turret_build_init_state(coolant: Variant, found_consumer: Variant) -> Dictionary:
	var resolved_coolant: Variant = coolant
	var coolant_found: bool = false
	if coolant == null:
		resolved_coolant = found_consumer
		coolant_found = found_consumer != null
	return {"coolant": resolved_coolant, "coolant_found": coolant_found}


# LaserTurretBuild.progress() (LaserTurret.java:110-112):
# `@Override`
# `public float progress(){`
# `return 1f - Mathf.clamp(reloadCounter / reload);`
# `}`
# on `public class LaserTurretBuild extends PowerTurretBuild{`
# (LaserTurret.java:44) inside
# `public class LaserTurret extends PowerTurret{`.
# progress is the reload fraction remaining: 1 when
# the counter is at 0 (ready to fire), 0 when it is
# at or past reload. Mathf.clamp with one argument
# clamps to [0, 1] (arc Mathf.clamp(value) =
# clamp(value, 0, 1)), so an over-full counter
# clamps to 0 and a negative counter clamps to 1.
# reloadCounter is the TurretBuild reload counter,
# reload is Turret.reload -- both arrive as explicit
# float params. NO driver line: a pure function the
# tick reads, not a per-tick write.
static func source_laser_turret_build_progress_state(reload_counter: float, reload: float) -> Dictionary:
	var progress: float = 1.0 - clampf(reload_counter / reload, 0.0, 1.0)
	return {"progress": progress}


# LaserTurretBuild.activeSoundVolume() (LaserTurret.java:147-149):
# `@Override`
# `public float activeSoundVolume(){`
# `return 1f;`
# `}`
# and LaserTurretBuild.shouldActiveSound()
# (LaserTurret.java:152-154):
# `@Override`
# `public boolean shouldActiveSound(){`
# `return bullets.any();`
# `}`
# on `public class LaserTurretBuild extends PowerTurretBuild{`
# (LaserTurret.java:44) inside
# `public class LaserTurret extends PowerTurret{`.
# MERGED slice (the N2346/N2389 precedent): ONE pure
# function, ONE owner, covering BOTH methods -- the volume
# is a constant 1f and the sound gate is bullets.any();
# both are read by the same updateTile soundLoop call
# (`soundLoop.update(x, y, shouldActiveSound(),
# activeSoundVolume());`, Turret.java:499, the N2346
# precedent) and both take the same bullets-any() state.
# bullets is `public Seq<BulletEntry> bullets = new Seq<>();`
# (LaserTurret.java:45): the seq itself is NOT ported --
# its emptiness arrives as the explicit has_bullets param
# (the N2330 param precedent). The twin-class overrides
# own their own bodies and are NOT touched here --
# TurretBuild base (N2346, shootWarmup-driven),
# ContinuousTurretBuild (N2389, same bullets.any() body,
# different class). NO audio playback in this slice
# (playback belongs to the updateTile tick, which reads
# both -- soundLoop itself is NOT ported here). NO driver
# line: pure read accessors the tick reads, not per-tick
# writes.
static func source_laser_turret_build_active_sound_state(has_bullets: bool) -> Dictionary:
	var active_sound_volume: float = 1.0
	var should_active_sound: bool = has_bullets
	return {"active_sound_volume": active_sound_volume, "should_active_sound": should_active_sound}


# LaserTurretBuild.placed() (LaserTurret.java:59-64):
# `@Override`
# `public void placed(){`
# `super.placed();`
# `reloadCounter = reload;`
# `}`
# on `public class LaserTurretBuild extends PowerTurretBuild{`
# (LaserTurret.java:44) inside
# `public class LaserTurret extends PowerTurret{`.
# Call-site fragment: `super.placed();` is the only free expr --
# `reloadCounter = reload;` is already owned at N2364
# (LaserTurretBuild.updateShooting) and is NOT re-registered.
# The super call runs BaseTurretBuild.placed() (whose own body
# is not ported here -- only the call site); the GD function
# records that placed() ran, returning a frame with
# `placed: true` (the N2318 canPickup precedent: a bare
# call-site returns a frame). NO driver line: placed() runs
# once at build placement, not per-tick. Zero params:
# placed() takes no state (the N1206 zero-param contract
# precedent -- result schema only, no input schema).
static func source_laser_turret_build_placed_state() -> Dictionary:
	# `super.placed();`
	return {"placed": true}
