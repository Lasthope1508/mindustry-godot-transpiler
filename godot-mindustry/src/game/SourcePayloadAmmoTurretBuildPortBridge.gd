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

# PayloadTurretBuild.getAmmoContent() (PayloadAmmoTurret.java:148-157):
# `public UnlockableContent getAmmoContent(){`
# `if(!payloads.isEmpty()){`
# `for(var content : ammoKeys){`
# `if(payloads.contains(content)){`
# `return content;`
# `}`
# `}`
# `}`
# `return null;`
# `}`
# on `public class PayloadTurretBuild extends TurretBuild{`
# (PayloadAmmoTurret.java:94) inside
# `public class PayloadAmmoTurret extends Turret{`
# (PayloadAmmoTurret.java:21). This is the PayloadAmmoTurret
# override: it returns the first ammo key (in ammoKeys order)
# whose content is currently held in the payloads seq, but
# ONLY when the payloads seq is non-empty
# (`if(!payloads.isEmpty()){` guard) — or null when payloads
# is empty or no key matches. The guard is the distinguishing
# line against currentAmmo (N2358) in the same class:
# currentAmmo scans unconditionally, getAmmoContent scans
# only inside the non-empty guard — same returned value,
# different body, NO dedup. Against useAmmo (N2363):
# getAmmoContent does NOT remove the content
# (`payloads.remove(content);` is absent) and does NOT return
# a BulletType (`return ammoTypes.get(content);` is absent) —
# it returns the content itself. `ammoKeys` comes from
# `ammoKeys = ammoTypes.keys().toSeq().toArray(UnlockableContent.class);`
# (PayloadAmmoTurret.java:89) and `payloads` is
# `public PayloadSeq payloads = new PayloadSeq();`
# (PayloadAmmoTurret.java:95). The payloads.contains lookup
# is NOT ported: the payload contents arrive as the explicit
# payload_contents param and ammoKeys as the explicit
# ammo_keys param (the N2330 param precedent). Content refs
# are plain strings here (content names); the result is the
# matching name or null. NO driver line: a pure accessor the
# HUD / ammo display caller reads, not a per-tick write.
static func source_payload_ammo_turret_build_get_ammo_content_state(ammo_keys: Array, payload_contents: Array) -> Dictionary:
	var ammo_content: Variant = null
	if not payload_contents.is_empty():
		for content in ammo_keys:
			if payload_contents.has(content):
				ammo_content = content
				break
	return {"ammo_content": ammo_content}

# PayloadTurretBuild.peekAmmo() (PayloadAmmoTurret.java:133-140):
# `public BulletType peekAmmo(){`
# `for(var content : ammoKeys){`
# `if(payloads.contains(content)){`
# `return ammoTypes.get(content);`
# `}`
# `}`
# `return null;`
# `}`
# on `public class PayloadTurretBuild extends TurretBuild{`
# (PayloadAmmoTurret.java:94) inside
# `public class PayloadAmmoTurret extends Turret{`
# (PayloadAmmoTurret.java:21). This is the PayloadAmmoTurret
# override: it returns the BulletType of the first ammo key
# (in ammoKeys order) whose content is currently held in the
# payloads seq, or null when none matches — WITHOUT removing
# the content from the seq. The distinguishing line against
# useAmmo (N2363) in the same class is the ABSENCE of
# `payloads.remove(content);`: peekAmmo returns the same
# BulletType useAmmo returns, but leaves the payloads seq
# untouched — calling it twice with the same inputs gives
# the same result, while useAmmo consumes on the first call.
# Against getAmmoContent (N2368): peekAmmo returns a
# BulletType through `return ammoTypes.get(content);`, not
# the content itself. The shared loop/guard lines
# `for(var content : ammoKeys){` and
# `if(payloads.contains(content)){` are text-shared with
# N2358/N2363/N2368 (same class, different methods) — the
# N632-N639 vs N1078-N1085 precedent allows the same text
# under its own java_method. `ammoKeys` comes from
# `ammoKeys = ammoTypes.keys().toSeq().toArray(UnlockableContent.class);`
# (PayloadAmmoTurret.java:89) and `payloads` is
# `public PayloadSeq payloads = new PayloadSeq();`
# (PayloadAmmoTurret.java:95). The payloads.contains lookup
# is NOT ported: the payload contents arrive as the explicit
# payload_contents param and ammoKeys as the explicit
# ammo_keys param (the N2330 param precedent). `ammoTypes`
# (ObjectMap<UnlockableContent, BulletType>,
# PayloadAmmoTurret.java:22) arrives as the explicit
# ammo_types Dictionary param (content name -> bullet type
# name); ObjectMap is NOT ported. Content refs and bullet
# types are plain strings here; the result is the bullet
# type name or null. NO driver line: a pure function the
# shoot path calls, not a per-tick write.
static func source_payload_turret_build_peek_ammo_state(ammo_keys: Array, payload_contents: Array, ammo_types: Dictionary) -> Dictionary:
	var peeked_ammo: Variant = null
	for content in ammo_keys:
		if payload_contents.has(content):
			peeked_ammo = ammo_types.get(content, null)
			break
	return {"peeked_ammo": peeked_ammo}

# PayloadTurretBuild.write()+read() (PayloadAmmoTurret.java:179-190):
# `@Override`
# `public void write(Writes write){`
# `super.write(write);`
# `payloads.write(write);`
# `}`
# `@Override`
# `public void read(Reads read, byte revision){`
# `super.read(read, revision);`
# `payloads.read(read);`
# `payloads.removeAll(u -> !ammoTypes.containsKey(u));`
# `}`
# on `public class PayloadTurretBuild extends TurretBuild{`
# (PayloadAmmoTurret.java:94) inside
# `public class PayloadAmmoTurret extends Turret{`
# (PayloadAmmoTurret.java:21). This is the PayloadAmmoTurret
# override: write persists the payloads seq
# (`payloads.write(write);`) and read restores it
# (`payloads.read(read);`) then drops every held content
# whose type is not in ammoTypes
# (`payloads.removeAll(u -> !ammoTypes.containsKey(u));`).
# `super.write(write);` / `super.read(read, revision);` are
# callee/context (TurretBuild.write/read already owned by
# N2322) — NOT distinguishing exprs. The distinguishing
# lines are `payloads.write(write);`, `payloads.read(read);`
# and `payloads.removeAll(u -> !ammoTypes.containsKey(u));`
# (all three 0-hit in both ledgers at HEAD 76d71f1e).
# `payloads` is `public PayloadSeq payloads = new PayloadSeq();`
# (PayloadAmmoTurret.java:95) and `ammoTypes` is
# `public ObjectMap<UnlockableContent, BulletType> ammoTypes = new ObjectMap<>();`
# (PayloadAmmoTurret.java:22). The payloads seq arrives as
# the explicit payload_contents param (write input) and the
# stored seq read back from the stream as the explicit
# stored_payload_contents param (read input); ammoTypes
# arrives as the explicit ammo_types Dictionary param
# (content name -> bullet type name); ObjectMap is NOT
# ported (the N2330 param precedent). The write result is
# the persisted contents in order (a copy of the held
# contents); the read result is the stored contents
# filtered to ammoTypes members, in stored order. The
# inputs are never mutated: both results are fresh arrays.
# Content refs are plain strings here. NO driver line: pure
# persistence functions, not a per-tick write — the caller
# wiring waits for its own slice.
static func source_payload_ammo_turret_build_write_read_state(payload_contents: Array, stored_payload_contents: Array, ammo_types: Dictionary) -> Dictionary:
	var write_payload_contents: Array = payload_contents.duplicate()
	var read_payload_contents: Array = []
	for content in stored_payload_contents:
		if ammo_types.has(content):
			read_payload_contents.append(content)
	return {"write_payload_contents": write_payload_contents, "payload_contents": read_payload_contents}
