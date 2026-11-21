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
