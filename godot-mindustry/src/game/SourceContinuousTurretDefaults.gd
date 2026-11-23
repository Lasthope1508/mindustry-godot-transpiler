extends RefCounted
class_name SourceContinuousTurretDefaults


static func source_continuous_turret_default_constructor_state(continuous_turret_defaults: Dictionary) -> Dictionary:
	# ContinuousTurret(String name) (ContinuousTurret.java:20-25):
	# `public ContinuousTurret(String name){`
	# `super(name);` -- already the exact_expr of N2185,
	# the Block super-ctor runs before these assignments;
	# cited as evidence only, never re-registered.
	# `envEnabled |= Env.space;` -- also N2185-owned
	# (env flags are set by the Block super-ctor chain);
	# cited as evidence only, never re-registered. The 2
	# ctor assignments below are the only exprs this
	# slice owns: each writes a literal field default
	# into the ContinuousTurret def, so the function
	# writes the same 2 literals into
	# continuous_turret_defaults (in/out) and returns
	# them.
	# `coolantMultiplier = 1f;`
	# `displayAmmoMultiplier = false;`
	# `coolantMultiplier` is declared on BaseTurret
	# (BaseTurret.java:32, `public float
	# coolantMultiplier = 5f;`), so the ctor overrides
	# the 5f base default with 1f -- continuous turrets
	# need no coolant boost. The same literal also
	# appears in the LaserTurret() and
	# TractorBeamTurret() ctors; this slice owns only
	# the ContinuousTurret() leg (java_method
	# `ContinuousTurret(String name)`).
	# `displayAmmoMultiplier` is declared on Turret
	# (Turret.java:99, `public boolean
	# displayAmmoMultiplier = true;`), so the ctor
	# disables the ammo-multiplier stat display for
	# continuous turrets. Both defaults are frame data
	# only (one float literal + one bool literal); no
	# Draw is ported.
	var coolant_multiplier := 1.0
	var display_ammo_multiplier := false
	continuous_turret_defaults["coolant_multiplier"] = coolant_multiplier
	continuous_turret_defaults["display_ammo_multiplier"] = display_ammo_multiplier
	return {"coolant_multiplier": coolant_multiplier, "display_ammo_multiplier": display_ammo_multiplier, "continuous_turret_defaults": continuous_turret_defaults}
