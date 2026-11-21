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
