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
