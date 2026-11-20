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
