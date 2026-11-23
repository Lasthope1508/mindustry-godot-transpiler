extends RefCounted
class_name SourceBaseTurretDefaults


static func source_base_turret_default_constructor_state(base_turret_defaults: Dictionary, block_flags: Variant) -> Dictionary:
	# BaseTurret(String name) (BaseTurret.java:36-46):
	# `public BaseTurret(String name){`
	# `super(name);` -- already the exact_expr of N2185,
	# the Block super-ctor runs before these assignments;
	# cited as evidence only, never re-registered.
	# `update = true;` -- 22-slice-owned and `solid =
	# true;` -- 11-slice-owned; neither is re-registered
	# here. `group = BlockGroup.turrets;` -- N2184-owned
	# (BuildTurret init); cited as evidence only, never
	# re-registered. The 4 ctor assignments below are the
	# only exprs this slice owns: each writes a literal
	# field default into the BaseTurret def, so the
	# function writes the same 4 literals into
	# base_turret_defaults (in/out) and returns them.
	# `outlineIcon = true;`
	# `attacks = true;`
	# `priority = TargetPriority.turret;`
	# `flags = EnumSet.of(BlockFlag.turret);`
	# `TargetPriority.turret` is the float constant 1f
	# (TargetPriority.java: `turret = 1f;`, the Block
	# priority field is a float defaulting to
	# TargetPriority.base = 0f, Block.java:253), so the
	# priority default is the float literal 1.0.
	# `EnumSet.of(BlockFlag.turret)` is the block-flag
	# enum value (`turret` -- "Any turret.",
	# BlockFlag.java:11-12) -- it arrives as the explicit
	# block_flags Variant param, NOT re-ported (the
	# N2401 BeamDrill ctor precedent). No Draw is
	# ported: these are block-level field defaults,
	# frame data only (bool/float literals + one enum
	# param).
	var outline_icon := true
	var attacks := true
	var priority := 1.0
	var flags: Variant = block_flags
	base_turret_defaults["outline_icon"] = outline_icon
	base_turret_defaults["attacks"] = attacks
	base_turret_defaults["priority"] = priority
	base_turret_defaults["flags"] = flags
	return {"outline_icon": outline_icon, "attacks": attacks, "priority": priority, "flags": flags, "base_turret_defaults": base_turret_defaults}
