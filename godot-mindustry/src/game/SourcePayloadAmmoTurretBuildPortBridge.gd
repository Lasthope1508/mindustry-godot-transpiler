extends "res://src/game/SourceBaseTurretDrawPortBridge.gd"

# PayloadTurretBuild.currentAmmo() (PayloadAmmoTurret.java:97-105):
# `public UnlockableContent currentAmmo(){`
# `for(var content : ammoKeys){`
# `if(payloads.contains(content)){`
# `return content;`
# `}`
# `}`
# `return null;`
# `}`
# on `public class PayloadTurretBuild extends TurretBuild{`
# (PayloadAmmoTurret.java:94) inside
# `public class PayloadAmmoTurret extends Turret{`
# (PayloadAmmoTurret.java:21). This is the PayloadAmmoTurret
# override: it returns the first ammo key (in ammoKeys order)
# whose content is currently held in the payloads seq, or
# null when none matches. `ammoKeys` comes from
# `ammoKeys = ammoTypes.keys().toSeq().toArray(UnlockableContent.class);`
# (PayloadAmmoTurret.java:89) and `payloads` is
# `public PayloadSeq payloads = new PayloadSeq();`
# (PayloadAmmoTurret.java:95). The payloads.contains lookup
# is NOT ported: the payload contents arrive as the explicit
# payload_contents param and ammoKeys as the explicit
# ammo_keys param (the N2330 param precedent). Content refs
# are plain strings here (content names); the result is the
# matching name or null. NO driver line: a pure accessor
# the HUD caller reads, not a per-tick write.
static func source_payload_ammo_turret_build_current_ammo_state(ammo_keys: Array, payload_contents: Array) -> Dictionary:
	var current_ammo: Variant = null
	for content in ammo_keys:
		if payload_contents.has(content):
			current_ammo = content
			break
	return {"current_ammo": current_ammo}

# PayloadTurretBuild.useAmmo() (PayloadAmmoTurret.java:122-131):
# `public BulletType useAmmo(){`
# `for(var content : ammoKeys){`
# `if(payloads.contains(content)){`
# `payloads.remove(content);`
# `return ammoTypes.get(content);`
# `}`
# `}`
# `return null;`
# `}`
# on `public class PayloadTurretBuild extends TurretBuild{`
# (PayloadAmmoTurret.java:94) inside
# `public class PayloadAmmoTurret extends Turret{`
# (PayloadAmmoTurret.java:21). This is the PayloadAmmoTurret
# override: it consumes the first ammo key (in ammoKeys order)
# whose content is currently held in the payloads seq — it
# removes that content from the seq and returns its BulletType
# from ammoTypes — or null when none matches. The distinguishing
# pair against peekAmmo/currentAmmo in the same class is
# `payloads.remove(content);` +
# `return ammoTypes.get(content);`: peekAmmo returns the same
# BulletType WITHOUT removing, currentAmmo returns the content
# itself WITHOUT removing. `ammoKeys` comes from
# `ammoKeys = ammoTypes.keys().toSeq().toArray(UnlockableContent.class);`
# (PayloadAmmoTurret.java:89) and `payloads` is
# `public PayloadSeq payloads = new PayloadSeq();`
# (PayloadAmmoTurret.java:95). The payloads.remove MUTATION is
# modeled as param in/out (the N2313 param precedent): the
# payload contents arrive as the explicit payload_contents
# param, the function duplicates it, erases the consumed
# content from the copy, and returns the updated list as
# payload_contents in the result — the input arrays are never
# mutated. `ammoTypes` (ObjectMap<UnlockableContent,
# BulletType>, PayloadAmmoTurret.java:22) arrives as the
# explicit ammo_types Dictionary param (content name ->
# bullet type name); ObjectMap is NOT ported. Content refs
# and bullet types are plain strings here; the result is the
# bullet type name or null. NO driver line: a pure function
# the shoot path calls (TurretBuild.shoot Turret.java:772 /
# bullet Turret.java:814), not a per-tick write — the caller
# wiring waits for its own slice.
static func source_payload_ammo_turret_build_use_ammo_state(ammo_keys: Array, payload_contents: Array, ammo_types: Dictionary) -> Dictionary:
	var used_ammo: Variant = null
	var remaining_contents: Array = payload_contents.duplicate()
	for content in ammo_keys:
		if payload_contents.has(content):
			remaining_contents.erase(content)
			used_ammo = ammo_types.get(content, null)
			break
	return {"used_ammo": used_ammo, "payload_contents": remaining_contents}
