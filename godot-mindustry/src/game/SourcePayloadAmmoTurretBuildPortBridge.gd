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
