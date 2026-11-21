extends "res://src/game/SourceBaseTurretDrawPortBridge.gd"

# ContinuousTurretBuild.getAmmoFraction() (ContinuousTurret.java:75-84):
# `@Override`
# `public float getAmmoFraction(){`
# `//TODO unclean way of calculating ammo fraction to display`
# `float ammoFract = efficiency;`
# `if(findConsumer(f -> f instanceof ConsumeLiquidBase) instanceof ConsumeLiquid cons){`
# `ammoFract = Math.min(ammoFract, liquids.get(cons.liquid) / liquidCapacity);`
# `}`
# `return ammoFract;`
# `}`
# on `public class ContinuousTurretBuild extends TurretBuild{`
# (ContinuousTurret.java:38) inside
# `public class ContinuousTurret extends Turret{`.
# This is the ContinuousTurret override: it starts from the
# block efficiency and caps it by the liquid fraction when a
# ConsumeLiquid consumer exists. The other getAmmoFraction
# overrides own their own bodies and are NOT touched here --
# TurretBuild base (N2348, constant 1f), ItemTurretBuild
# (N1181), LiquidTurretBuild (N1198),
# ContinuousLiquidTurretBuild (N1221), PowerTurretBuild
# (N1168). The findConsumer lookup is NOT ported: its result
# arrives as the explicit has_liquid_consumer + liquid_amount
# params (the N2330 param precedent). NO driver line: a pure
# accessor the HUD caller reads, not a per-tick write.
static func source_continuous_turret_build_get_ammo_fraction_state(efficiency: float, has_liquid_consumer: bool, liquid_amount: float, liquid_capacity: float) -> Dictionary:
	var ammo_fraction: float = efficiency
	if has_liquid_consumer:
		ammo_fraction = minf(ammo_fraction, liquid_amount / liquid_capacity)
	return {"ammo_fraction": ammo_fraction}

# ContinuousTurretBuild.updateTile() (ContinuousTurret.java:86-101):
# `@Override`
# `public void updateTile(){`
# `super.updateTile();`
# `bullets.removeAll(b -> !b.bullet.isAdded() || b.bullet.type == null || b.bullet.owner != this);`
# `if(bullets.any()){`
# `for(var entry : bullets){`
# `updateBullet(entry);`
# `wasShooting = true;`
# `heat = 1f;`
# `curRecoil = recoil;`
# `}`
# `}`
# on `public class ContinuousTurretBuild extends TurretBuild{`
# (ContinuousTurret.java:38) inside
# `public class ContinuousTurret extends Turret{`.
# This is the ContinuousTurret tick: prune dead bullets, then
# when any bullet survives, flag wasShooting, set heat to 1f
# and curRecoil to recoil. super.updateTile() is the
# TurretBuild base tick (Turret.java:490) -- it resets
# wasShooting to false (Turret.java:517) and decays heat /
# curRecoil toward 0, so this slice reads the post-super
# frame: was_shooting is true exactly when pruned bullets
# remain, and heat / cur_recoil keep their input values when
# no bullet remains. updateBullet(entry) is a CALLEE -- its
# body is NOT ported in this slice (batch 13+, draft §4e);
# only the call line is registered as evidence. The bullets
# Seq is NOT ported: it arrives as an explicit param, an
# Array of {is_added, type_null, owner_is_self} dicts (the
# N2330 param precedent). The input array is never mutated:
# the pruned list is a fresh Array.
static func source_continuous_turret_build_update_tile_state(bullets: Array, recoil: float, heat: float, cur_recoil: float) -> Dictionary:
	var pruned: Array = []
	for entry in bullets:
		var flags: Dictionary = entry
		if flags.get("is_added", false) and not flags.get("type_null", true) and flags.get("owner_is_self", false):
			pruned.append(entry)
	var was_shooting: bool = not pruned.is_empty()
	var next_heat: float = 1.0 if was_shooting else heat
	var next_cur_recoil: float = recoil if was_shooting else cur_recoil
	return {"bullets": pruned, "was_shooting": was_shooting, "heat": next_heat, "cur_recoil": next_cur_recoil}

# ContinuousTurretBuild.updateBullet() (ContinuousTurret.java:102-130):
# `protected void updateBullet(BulletEntry entry){`
# `float`
# `bulletX = x + Angles.trnsx(rotation - 90, shootX + entry.x, shootY + entry.y),`
# `bulletY = y + Angles.trnsy(rotation - 90, shootX + entry.x, shootY + entry.y),`
# `angle = rotation + entry.rotation;`
# `entry.bullet.rotation(angle);`
# `entry.bullet.set(bulletX, bulletY);`
# `//target length of laser`
# `float shootLength = Math.min(dst(targetPos), range);`
# `//current length of laser`
# `float curLength = dst(entry.bullet.aimX, entry.bullet.aimY);`
# `//resulting length of the bullet (smoothed)`
# `float resultLength = Mathf.approachDelta(curLength, shootLength, aimChangeSpeed);`
# `//actual aim end point based on length`
# `Tmp.v1.trns(rotation, lastLength = resultLength).add(x, y);`
# `entry.bullet.aimX = Tmp.v1.x;`
# `entry.bullet.aimY = Tmp.v1.y;`
# `if(scaleDamageEfficiency){`
# `entry.bullet.damage = entry.bullet.type.damage * Math.min(efficiency, 1f) * timeScale * entry.bullet.damageMultiplier();`
# `}`
# `if(isShooting && hasAmmo()){`
# `entry.bullet.time = entry.bullet.lifetime * entry.bullet.type.optimalLifeFract * Math.min(shootWarmup, efficiency);`
# `entry.bullet.keepAlive = true;`
# `}`
# `}`
# on `public class ContinuousTurretBuild extends TurretBuild{`
# (ContinuousTurret.java:38) inside
# `public class ContinuousTurret extends Turret{`.
# This is the per-bullet half of the ContinuousTurret tick:
# N2362 (updateTile) prunes the bullets seq and calls this
# for each survivor; this slice moves one surviving bullet
# to its rotated muzzle offset, re-aims its laser end point
# toward the target with a smoothed length, and refreshes
# its damage / lifetime while the turret is shooting.
# RED decisions: (1) Angles.trnsx/trnsy here are the
# THREE-arg overloads (Angles.java:74-79): they rotate the
# (shootX + entry.x, shootY + entry.y) offset vector by
# rotation - 90 degrees -- NOT the len overloads -- so the
# offset is Vector2(...).rotated(deg_to_rad(rotation - 90)).
# (2) dst(targetPos) is the distance from the building (x, y)
# to targetPos, and dst(aimX, aimY) the distance from (x, y)
# to the bullet aim point -- both are Vector2.distance_to
# here. (3) Mathf.approachDelta(from, to, speed) is
# approach(from, to, Time.delta * speed) (Mathf.java:420-422),
# so Time.delta arrives as the explicit source_delta param
# (the N2330 param precedent); the step is computed inline,
# exactly SourceMathState.source_approach_delta. aimChangeSpeed
# defaults to Float.POSITIVE_INFINITY (ContinuousTurret.java:17),
# so with delta > 0 the length snaps to shootLength in one tick.
# (4) The resultLength line shares text with N866 (Weapon.update
# continuous laser aim, same text in a different method) --
# registered under this java_method (the N632-N639 vs N1078-N1085
# precedent); flagged for the main thread, see register.
# (5) entry arrives as a Dictionary {x, y, rotation, bullet} and
# bullet as {aim_x, aim_y, damage, time, lifetime, type_damage,
# type_optimal_life_fract, damage_multiplier}: BulletEntry (Turret.java:864-875),
# BulletType.damage / lifetime / optimalLifeFract and
# Bullet.damageMultiplier() (BulletComp.java:95) are NOT re-ported,
# their values arrive as explicit fields (the N2330 param precedent).
# (6) isShooting / hasAmmo() are state / callee already owned
# (N2343 isShooting, N2313 hasAmmo) -- explicit bool params, not
# re-ported. (7) lastLength is the ContinuousTurretBuild field
# (ContinuousTurret.java:40) assigned here, returned as last_length.
# (8) NO driver line: the pure function returns the frame the
# driver writes; the driver tick that calls it per tick is a later
# slice. (9) The input dicts are never mutated: the result is a
# fresh Dictionary built from read values.
static func source_continuous_turret_build_update_bullet_state(entry: Dictionary, x: float, y: float, rotation: float, shoot_x: float, shoot_y: float, target_pos_x: float, target_pos_y: float, range_value: float, aim_change_speed: float, scale_damage_efficiency: bool, efficiency: float, time_scale: float, shoot_warmup: float, is_shooting: bool, has_ammo: bool, source_delta: float) -> Dictionary:
	var bullet: Dictionary = entry.get("bullet", {})
	var entry_x: float = float(entry.get("x", 0.0))
	var entry_y: float = float(entry.get("y", 0.0))
	var entry_rotation: float = float(entry.get("rotation", 0.0))
	var offset: Vector2 = Vector2(shoot_x + entry_x, shoot_y + entry_y).rotated(deg_to_rad(rotation - 90.0))
	var bullet_x: float = x + offset.x
	var bullet_y: float = y + offset.y
	var angle: float = rotation + entry_rotation
	var shoot_length: float = minf(Vector2(x, y).distance_to(Vector2(target_pos_x, target_pos_y)), range_value)
	var cur_length: float = Vector2(x, y).distance_to(Vector2(float(bullet.get("aim_x", 0.0)), float(bullet.get("aim_y", 0.0))))
	var result_length: float = cur_length + clampf(shoot_length - cur_length, -source_delta * aim_change_speed, source_delta * aim_change_speed)
	var aim_end: Vector2 = Vector2(cos(deg_to_rad(rotation)), sin(deg_to_rad(rotation))) * result_length + Vector2(x, y)
	var bullet_damage: float = float(bullet.get("damage", 0.0))
	if scale_damage_efficiency:
		bullet_damage = float(bullet.get("type_damage", 0.0)) * minf(efficiency, 1.0) * time_scale * float(bullet.get("damage_multiplier", 1.0))
	var bullet_time: float = float(bullet.get("time", 0.0))
	var bullet_keep_alive: bool = false
	if is_shooting and has_ammo:
		bullet_time = float(bullet.get("lifetime", 0.0)) * float(bullet.get("type_optimal_life_fract", 0.0)) * minf(shoot_warmup, efficiency)
		bullet_keep_alive = true
	return {"bullet_x": bullet_x, "bullet_y": bullet_y, "bullet_angle": angle, "bullet_aim_x": aim_end.x, "bullet_aim_y": aim_end.y, "bullet_damage": bullet_damage, "bullet_time": bullet_time, "bullet_keep_alive": bullet_keep_alive, "last_length": result_length, "shoot_length": shoot_length, "cur_length": cur_length, "result_length": result_length}

# ContinuousTurretBuild.updateShooting() (ContinuousTurret.java:138-146):
# `@Override`
# `protected void updateShooting(){`
# `if(bullets.any()){`
# `return;`
# `}`
# `if(canConsume() && !charging() && shootWarmup >= minWarmup){`
# `shoot(peekAmmo());`
# `}`
# `}`
# on `public class ContinuousTurretBuild extends TurretBuild{`
# (ContinuousTurret.java:38) inside
# `public class ContinuousTurret extends Turret{`.
# This is the shoot-decision half of the ContinuousTurret
# tick: N2362 (updateTile) prunes the bullets seq and calls
# updateBullet for each survivor; this slice decides whether
# a new shot is fired this tick -- only when no bullet is
# flying and the consume / charging / warmup guard holds.
# Unlike LaserTurret.updateShooting (N2364) the guard here
# is canConsume() (no reloadCounter / efficiency leg) and
# shoot(peekAmmo()) is a single line -- a different method
# on a different class, no dedup. `shoot(peekAmmo());` is a
# 0-hit in both ledgers; `if(bullets.any()){` shares text
# with N2362 (updateTile, same class) and N2364 (LaserTurret,
# different class) -- registered under this java_method (the
# N632-N639 vs N1078-N1085 precedent).
# RED decisions: (1) canConsume() is the TurretBuild callee
# (Turret.java:624-629, heatRequirement gate then
# super.canConsume()) -- its value arrives as the explicit
# can_consume param, not re-ported. (2) charging() is the
# TurretBuild callee (Turret.java:714-716, `return
# queuedBullets > 0 && shoot.firstShotDelay > 0;`) -- its
# value arrives as the explicit charging param. (3)
# peekAmmo() here is ContinuousTurretBuild.peekAmmo
# (ContinuousTurret.java:70-72, `return shootType;`), whose
# body is already owned by N1172
# (PowerTurretBuild.peekAmmo) -- its value arrives as the
# explicit ammo_type param, not re-ported. shoot() is the
# TurretBuild callee (Turret.java:742) -- the shot decision
# is the observable effect, returned as shot. (4) minWarmup
# is the Turret field (Turret.java:76, default 0f) -- the
# shoot threshold, explicit param. shootWarmup is the
# TurretBuild field (Turret.java:286). (5) The bullets Seq
# is NOT ported: its emptiness arrives as the explicit
# has_bullets param (the N2330 param precedent). (6) NO
# driver line: the pure function returns the decision frame
# the driver writes; the driver tick that calls it per tick
# is a later slice. (7) Two result symbols: shot, ammo_type.
static func source_continuous_turret_build_update_shooting_state(has_bullets: bool, can_consume: bool, charging: bool, shoot_warmup: float, min_warmup: float, ammo_type: Variant) -> Dictionary:
	var shot: bool = false
	var shot_ammo_type: Variant = null
	if not has_bullets:
		if can_consume and not charging and shoot_warmup >= min_warmup:
			shot = true
			shot_ammo_type = ammo_type
	return {"shot": shot, "ammo_type": shot_ammo_type}

# ContinuousTurretBuild.turnToTarget() (ContinuousTurret.java:149-151):
# `@Override`
# `protected void turnToTarget(float targetRot){`
# `rotation = Angles.moveToward(rotation, targetRot, efficiency * rotateSpeed * delta());`
# `}`
# ContinuousTurretBuild.handleBullet() (ContinuousTurret.java:154-164):
# `@Override`
# `protected void handleBullet(@Nullable Bullet bullet, float offsetX, float offsetY, float angleOffset){`
# `if(bullet != null){`
# `bullets.add(new BulletEntry(bullet, offsetX, offsetY, angleOffset, 0f));`
# `//make sure the length updates to the last set value`
# `Tmp.v1.trns(rotation, shootY + lastLength).add(x, y);`
# `bullet.aimX = Tmp.v1.x;`
# `bullet.aimY = Tmp.v1.y;`
# `}`
# `}`
# on `public class ContinuousTurretBuild extends TurretBuild{`
# (ContinuousTurret.java:38) inside
# `public class ContinuousTurret extends Turret{`.
# This is the turn-and-hand-over step of the ContinuousTurret
# tick: the tick turns rotation toward the target, then hands
# the new bullet over as a BulletEntry -- one driver step,
# hence one record, one symbol/owner, with BOTH java_method
# names (the N2346/N2336 merged-slice precedent, same shape
# as LaserTurret turnToTarget+handleBullet N2369).
# Distinguishing Continuous from Laser (N2369): the turn step
# here has NO firingMoveFract factor (LaserTurret.java:136
# scales by `(bullets.any() ? firingMoveFract : 1f)`), the
# entry life is 0f (not shootDuration), and the aim is
# initialised from Tmp.v1 (shootY + lastLength) -- no dedup
# between them. The two aim lines share text with N851
# (Weapon.handleBullet, different class) -- registered under
# this java_method (the N632-N639 vs N1078-N1085 precedent).
# RED decisions: (1) Angles.moveToward is NOT re-ported: it
# already exists as SourceMathState.source_angles_move_toward
# (wraparound, snaps when closer than the step), called here
# exactly as N2369 calls it. (2) delta() is the BuildingComp
# callee (BuildingComp.java:1922-1924, `return Time.delta *
# timeScale;`) -- its value arrives as the explicit delta
# param, not re-ported. (3) shootY is the TurretBuild field
# (Turret.java:66, default NEGATIVE_INFINITY, resolved to
# size * tilesize / 2f at :206) -- the resolved value arrives
# as the explicit shoot_y param. (4) lastLength is the
# ContinuousTurretBuild field (ContinuousTurret.java:40,
# default size * 4f, written by updateBullet N2366) -- its
# value arrives as the explicit last_length param; read() is
# NOT ported here (a later slice). (5) The bullets Seq is NOT
# ported: the seq append itself is the driver-side effect, so
# the pure function returns the entry dict (or null) and the
# driver adds it. BulletEntry fields (Turret.java:864-875):
# bullet/x/y/rotation/life, positional from the constructor
# call: offsetX -> x, offsetY -> y, angleOffset -> rotation,
# 0f -> life. (6) The aim uses the NEW rotation: in the tick
# turnToTarget runs before handleBullet, so Tmp.v1.trns reads
# the already-turned rotation -- the proof checks this
# (aim_uses_new_rotation). (7) For a null bullet Java does
# nothing at all: no entry and no aim update. The pure
# function returns bullet_aim_x/y as 0.0 then, and they are
# only meaningful when bullet_entry is non-null -- the driver
# must not apply them otherwise. (8) NO driver line: the pure
# function returns the frame the driver writes; the driver
# tick that calls it per tick is a later slice. (9) The input
# bullet Variant is never mutated: the result is a fresh
# Dictionary built from read values.
static func source_continuous_turret_build_turn_to_target_handle_bullet_state(rotation: float, target_rot: float, efficiency: float, rotate_speed: float, delta: float, x: float, y: float, shoot_y: float, last_length: float, bullet: Variant, offset_x: float, offset_y: float, angle_offset: float) -> Dictionary:
	var new_rotation: float = source_math_state.source_angles_move_toward(rotation, target_rot, efficiency * rotate_speed * delta)
	var bullet_entry: Variant = null
	var bullet_aim_x: float = 0.0
	var bullet_aim_y: float = 0.0
	if bullet != null:
		bullet_entry = {"bullet": bullet, "x": offset_x, "y": offset_y, "rotation": angle_offset, "life": 0.0}
		var aim_end: Vector2 = Vector2(cos(deg_to_rad(new_rotation)), sin(deg_to_rad(new_rotation))) * (shoot_y + last_length) + Vector2(x, y)
		bullet_aim_x = aim_end.x
		bullet_aim_y = aim_end.y
	return {"rotation": new_rotation, "bullet_entry": bullet_entry, "bullet_aim_x": bullet_aim_x, "bullet_aim_y": bullet_aim_y}

# ContinuousTurretBuild.version() (ContinuousTurret.java:176-178):
# `@Override`
# `public byte version(){`
# `return 3;`
# `}`
# ContinuousTurretBuild.write() (ContinuousTurret.java:181-185):
# `@Override`
# `public void write(Writes write){`
# `super.write(write);`
# `write.f(lastLength);`
# `}`
# ContinuousTurretBuild.read() (ContinuousTurret.java:188-194):
# `@Override`
# `public void read(Reads read, byte revision){`
# `super.read(read, revision);`
# `if(revision >= 3){`
# `lastLength = read.f();`
# `}`
# `}`
# on `public class ContinuousTurretBuild extends TurretBuild{`
# (ContinuousTurret.java:38) inside
# `public class ContinuousTurret extends Turret{`.
# This is the persistence record of the ContinuousTurret
# build: version() stamps the save revision 3, write()
# persists the single own field lastLength, and read()
# restores it only for saves at revision >= 3 (the N2322
# TurretBuild / N2286 DrillBuild merged-slice precedent).
# The name `version` shares text with 7 other-class slices
# (N1187/N745/N923/N1885/N2217/N2286/N2322) -- registered
# under this java_method with the class prefix. The
# `super.write(write);` / `super.read(read, revision);`
# lines each EXACT-hit 9 slices -- they are callee/context
# only, NOT distinguishing exprs: the super layer is
# TurretBuild.write/read (N2322), not re-ported here.
# RED decisions: (1) lastLength is the ContinuousTurretBuild
# field (`public float lastLength = size * 4f;`,
# ContinuousTurret.java:40), written by updateBullet (N2366)
# and read by handleBullet (N2370) -- its value arrives as
# the explicit last_length param. (2)
# The port has no save/load stream, so the value read.f()
# would return arrives as the explicit stored_last_length
# param (the N2330 param precedent); a revision below 3
# leaves lastLength where it already is. (3) The write
# carries no revision: write.f(lastLength) persists the
# current value whatever the revision, so write_last_length
# never depends on the revision param. (4) Java write.f is
# a 32-bit float while GDScript float is 64-bit -- the pure
# function adds NO rounding epsilon; the proof round-trips
# float32-safe values exactly. (5) NO driver tick line:
# persistence is not a per-tick call, and the port has no
# save/load stream to call this function yet. (6) Three
# result symbols: version, write_last_length, last_length.
static func source_continuous_turret_build_version_write_read_state(last_length: float, revision: int, stored_last_length: float) -> Dictionary:
	var version: int = 3
	var write_last_length: float = last_length
	var read_last_length: float = last_length
	if revision >= 3:
		read_last_length = stored_last_length
	return {"version": version, "write_last_length": write_last_length, "last_length": read_last_length}
