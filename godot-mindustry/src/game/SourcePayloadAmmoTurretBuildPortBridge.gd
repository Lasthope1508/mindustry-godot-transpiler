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

# PayloadTurretBuild.displayBars() (PayloadAmmoTurret.java:171-177):
# `@Override`
# `public void displayBars(Table bars){`
# `super.displayBars(bars);`
# ``
# `bars.add(new Bar("stat.ammo", Pal.ammo, () -> (float)totalAmmo / maxAmmo)).growX();`
# `bars.row();`
# `}`
# on `public class PayloadTurretBuild extends TurretBuild{`
# (PayloadAmmoTurret.java:94) inside
# `public class PayloadAmmoTurret extends Turret{`
# (PayloadAmmoTurret.java:21). This is the PayloadAmmoTurret
# override: it adds the ammo bar to the table — a Bar named
# "stat.ammo" whose fraction is the lambda
# `() -> (float)totalAmmo / maxAmmo` — then opens a new row
# (`bars.row();`). `super.displayBars(bars);` is
# callee/context (Block/Building displayBars) — NOT a
# distinguishing expr. The distinguishing lines are
# `bars.add(new Bar("stat.ammo", Pal.ammo, () -> (float)totalAmmo / maxAmmo)).growX();`
# and `bars.row();` (both 0-hit in both ledgers at HEAD
# 4f53d70e). `totalAmmo` is the TurretBuild frame field
# (`public int totalAmmo;`, Turret.java:283), synced by
# updateTile() (`totalAmmo = payloads.total();`,
# PayloadAmmoTurret.java:166); `maxAmmo` is the TurretBuild
# field (`public int maxAmmo = 30;`, Turret.java:47) — both
# arrive as explicit int params. `bars` is the arc Table —
# a row-based layout, so it arrives as the explicit bars
# param: an Array of rows, each row an Array of bar-spec
# dicts; `bars.add(...)` appends the ammo bar spec to the
# current (last) row and `bars.row();` opens a new empty
# row after it. `Pal.ammo` / Table / Bar are NOT ported
# (the N2330 param precedent — N2330's setBars bar spec
# carries key/text/color/fraction; here the task pins the
# bar spec to label + fraction only, no Pal.ammo color).
# The fraction is the lambda value: float(totalAmmo) /
# float(maxAmmo); maxAmmo 0 never divides by zero — the
# guard reports 0.0 (a Bar clamps its fraction anyway,
# Bar.java:31-33). The inputs are never mutated: the rows
# are deep-duplicated and the result carries fresh arrays.
# NO driver line: a UI spec, not a per-tick write — the
# caller wiring waits for its own slice.
static func source_payload_ammo_turret_build_display_bars_state(bars: Array, total_ammo: int, max_ammo: int) -> Dictionary:
	var rows: Array = bars.duplicate(true)
	if rows.is_empty():
		rows.append([])
	var ammo_fraction: float = 0.0
	if max_ammo != 0:
		ammo_fraction = float(total_ammo) / float(max_ammo)
	var current_row: Array = rows[rows.size() - 1]
	current_row.append({"label": "stat.ammo", "fraction": ammo_fraction})
	rows.append([])
	return {"bars": rows, "ammo_fraction": ammo_fraction}

# PayloadTurretBuild.updateTile() (PayloadAmmoTurret.java:165-168):
# `@Override`
# `public void updateTile(){`
# `totalAmmo = payloads.total();`
# `super.updateTile();`
# `}`
# on `public class PayloadTurretBuild extends TurretBuild{`
# (PayloadAmmoTurret.java:94) inside
# `public class PayloadAmmoTurret extends Turret{`
# (PayloadAmmoTurret.java:21). This is the PayloadAmmoTurret
# override: it syncs the frame field totalAmmo from the
# payloads seq (`totalAmmo = payloads.total();`) then calls
# the TurretBuild super tick (`super.updateTile();` —
# callee/context, already owned by N1222/N1417/N2103/N2108/
# N2110/N2153/N2362 — NOT a distinguishing expr). The
# distinguishing line is `totalAmmo = payloads.total();`
# (0-hit in both ledgers at HEAD 4f53d70e). `payloads` is
# `public PayloadSeq payloads = new PayloadSeq();`
# (PayloadAmmoTurret.java:95) and `PayloadSeq.total()` is
# the running sum of added amounts (`public int total(){`
# `return total;` `}`, PayloadSeq.java:22-24) — the
# payload_contents param holds one entry per payload unit
# (the N2330 param precedent), so total() is exactly
# payload_contents.size(). NO driver tick line of its own:
# updateTile only syncs the frame field — the caller wiring
# waits for its own slice.
static func source_payload_ammo_turret_build_update_tile_state(payload_contents: Array) -> Dictionary:
	var total_ammo: int = payload_contents.size()
	return {"total_ammo": total_ammo}

# PayloadTurretBuild.getPayloads() (PayloadAmmoTurret.java:143-145):
# `@Override`
# `public PayloadSeq getPayloads(){`
# `return payloads;`
# `}`
# on `public class PayloadTurretBuild extends TurretBuild{`
# (PayloadAmmoTurret.java:94) inside
# `public class PayloadAmmoTurret extends Turret{`
# (PayloadAmmoTurret.java:21). This is the PayloadAmmoTurret
# override: it returns the payloads seq itself
# (`return payloads;`, 0-hit in both ledgers at HEAD
# 4f53d70e). `payloads` is
# `public PayloadSeq payloads = new PayloadSeq();`
# (PayloadAmmoTurret.java:95) — it arrives as the explicit
# payload_contents param (the N2330 param precedent) and
# the result returns a copy of it, so the caller's seq is
# never aliased. NO driver line: a pure accessor the
# payload / HUD caller reads, not a per-tick write.
static func source_payload_ammo_turret_build_get_payloads_state(payload_contents: Array) -> Dictionary:
	return {"payloads": payload_contents.duplicate()}

# PayloadAmmoTurret.limitRange(float) (PayloadAmmoTurret.java:45-49):
# `public void limitRange(float margin){`
# `for(var entry : ammoTypes.copy().entries()){`
# `entry.value.lifetime = (range + margin) / entry.value.speed;`
# `}`
# `}`
# on `public class PayloadAmmoTurret extends Turret{`
# (PayloadAmmoTurret.java:21). This is the PayloadAmmoTurret
# class method: it copies every ammo bullet and rewrites its
# lifetime to (range + margin) / speed
# (`entry.value.lifetime = (range + margin) / entry.value.speed;`).
# `ammoTypes` is `public ObjectMap<UnlockableContent, BulletType> ammoTypes`
# (PayloadAmmoTurret.java:22) and arrives as the explicit
# ammo_entries param (one dict per ammo entry: content /
# lifetime / speed -- the N2330 param precedent); the copy in
# Java (`ammoTypes.copy()`) means the original bullets are
# never touched, so the result returns fresh dicts and the
# input is never mutated. `range` is the BaseTurret field
# (`public float range = 80f;`, BaseTurret.java:21) and
# arrives as the explicit range_value param; `margin`
# arrives as an explicit float param. Float division by a
# zero speed yields Infinity, exactly like Java float
# division -- no guard is invented. NO driver tick line:
# limitRange is a def-time setup call, not per-tick state.
static func source_payload_ammo_turret_limit_range_state(ammo_entries: Array, range_value: float, margin: float) -> Dictionary:
	var updated: Array = []
	for entry in ammo_entries:
		var row: Dictionary = (entry as Dictionary).duplicate()
		row["lifetime"] = (range_value + margin) / float(row.get("speed", 0.0))
		updated.append(row)
	return {"ammo_entries": updated}

# PayloadAmmoTurret.limitRange() (PayloadAmmoTurret.java:40-42):
# `public void limitRange(){`
# `limitRange(1f);`
# `}`
# on `public class PayloadAmmoTurret extends Turret{`
# (PayloadAmmoTurret.java:21). This is the no-arg form: it
# delegates to limitRange(float) with margin 1f
# (`limitRange(1f);`), so the lifetimes are (range + 1.0) /
# speed. The delegation is the GD call below (the N2379
# sibling-call precedent: onProximityUpdate calls
# updateLasers/updateFacing by name in the same file).
# NO driver tick line: a def-time setup call.
static func source_payload_ammo_turret_limit_range_default_state(ammo_entries: Array, range_value: float) -> Dictionary:
	return source_payload_ammo_turret_limit_range_state(ammo_entries, range_value, 1.0)

# PayloadAmmoTurret.setStats() (PayloadAmmoTurret.java:51-56):
# `@Override`
# `public void setStats(){`
# `super.setStats();`
# `stats.remove(Stat.itemCapacity);`
# `stats.add(Stat.ammo, StatValues.ammo(ammoTypes, true));`
# `}`
# on `public class PayloadAmmoTurret extends Turret{`
# (PayloadAmmoTurret.java:21). This is the PayloadAmmoTurret
# class method: it drops the itemCapacity stat row
# (`stats.remove(Stat.itemCapacity);` -- hits N1175 in both
# ledgers, evidence only, NOT a distinguishing expr) and
# adds the ammo row
# (`stats.add(Stat.ammo, StatValues.ammo(ammoTypes, true));`).
# `super.setStats();` is callee/context (Block/Turret super
# stats) -- NOT a distinguishing expr. `stats` (Stats UI
# API) arrives as the explicit stats param (rows of stat
# dicts -- the N2330 param precedent); `StatValues.ammo`
# is NOT ported -- the ammo row spec carries the ammo types
# list and the showUnit flag (`show_unit: true`,
# StatValues.java:606-607 `ammo(map, boolean showUnit)`).
# NO driver tick line: a UI spec, not a per-tick write --
# the caller wiring waits for its own slice.
static func source_payload_ammo_turret_set_stats_state(stats: Array, ammo_types: Array) -> Dictionary:
	var rows: Array = []
	for row in stats:
		var stat_row: Dictionary = (row as Dictionary).duplicate()
		if stat_row.get("stat", "") == "itemCapacity":
			continue
		rows.append(stat_row)
	rows.append({"stat": "ammo", "ammo_types": ammo_types.duplicate(), "show_unit": true})
	return {"stats": rows}

# PayloadTurretBuild.hasAmmo() (PayloadAmmoTurret.java:117-120):
# `@Override`
# `public boolean hasAmmo(){`
# `return payloads.total() > 0;`
# `}`
# on `public class PayloadTurretBuild extends TurretBuild{`
# (PayloadAmmoTurret.java:94) inside
# `public class PayloadAmmoTurret extends Turret{`
# (PayloadAmmoTurret.java:21). This is the PayloadAmmoTurret
# override: it reports whether any payload unit is held --
# `payloads.total() > 0` -- or false when the seq is empty.
# `payloads` is `public PayloadSeq payloads = new PayloadSeq();`
# (PayloadAmmoTurret.java:95) and arrives as the explicit
# payload_contents param -- one entry per payload unit, so
# total() is exactly payload_contents.size() (the N2381
# updateTile precedent: `totalAmmo = payloads.total();`).
# The distinguishing line is
# `return payloads.total() > 0;`
# (0-hit in both ledgers at HEAD 1047fc24). NO driver line:
# a pure predicate the shoot path reads
# (TurretBuild.hasAmmo callers), not a per-tick write.
static func source_payload_ammo_turret_build_has_ammo_state(payload_contents: Array) -> Dictionary:
	var has_ammo: bool = payload_contents.size() > 0
	return {"has_ammo": has_ammo}

# PayloadTurretBuild.acceptPayload() (PayloadAmmoTurret.java:107-110):
# `@Override`
# `public boolean acceptPayload(Building source, Payload payload){`
# `return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());`
# `}`
# on `public class PayloadTurretBuild extends TurretBuild{`
# (PayloadAmmoTurret.java:94) inside
# `public class PayloadAmmoTurret extends Turret{`
# (PayloadAmmoTurret.java:21). This is the PayloadAmmoTurret
# override: it gates payload intake on capacity
# (`payloads.total() < maxAmmo`) AND ammo membership
# (`ammoTypes.containsKey(payload.content())`) -- a payload
# whose content is not an ammo type is refused even when
# there is room. `payloads` is
# `public PayloadSeq payloads = new PayloadSeq();`
# (PayloadAmmoTurret.java:95) and arrives as the explicit
# payload_contents param -- one entry per payload unit, so
# total() is exactly payload_contents.size() (the N2381
# updateTile precedent). `maxAmmo` is the constructor field
# (`maxAmmo = 3;`, PayloadAmmoTurret.java:28) and arrives as
# an explicit int param. `ammoTypes`
# (ObjectMap<UnlockableContent, BulletType>,
# PayloadAmmoTurret.java:22) arrives as the explicit
# ammo_types Dictionary param (content name -> bullet type
# name); ObjectMap is NOT ported (the N2330 param
# precedent). `payload.content()` is a field on the given
# Payload -- it arrives as the explicit payload_content
# param (content name or null); `Payload`/`PayloadSeq` are
# NOT ported. The `source` (Building) param is unused in
# the body and is NOT a param. The distinguishing line is
# `return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());`
# (0-hit in both ledgers at HEAD 1047fc24). NO driver line:
# a pure predicate the payload intake caller reads, not a
# per-tick write.
static func source_payload_ammo_turret_build_accept_payload_state(payload_contents: Array, max_ammo: int, ammo_types: Dictionary, payload_content: Variant) -> Dictionary:
	var accepts_payload: bool = payload_contents.size() < max_ammo and ammo_types.has(payload_content)
	return {"accepts_payload": accepts_payload}

# PayloadTurretBuild.handlePayload() (PayloadAmmoTurret.java:112-115):
# `@Override`
# `public void handlePayload(Building source, Payload payload){`
# `payloads.add(payload.content());`
# `}`
# on `public class PayloadTurretBuild extends TurretBuild{`
# (PayloadAmmoTurret.java:94) inside
# `public class PayloadAmmoTurret extends Turret{`
# (PayloadAmmoTurret.java:21). This is the PayloadAmmoTurret
# override: it adds the payload's content to the seq
# (`payloads.add(payload.content());`). The mutation is
# modeled as param in/out (the N2313 param precedent): the
# payload contents arrive as the explicit payload_contents
# param, the function duplicates it, appends the content,
# and returns the updated list as payload_contents in the
# result -- the input array is never mutated. A null
# content is a no-op: `PayloadSeq.add` returns early on
# null (`if(block == null) return;`, PayloadSeq.java:35-37
# via `add(UnlockableContent block, int amount)`). The
# `source` (Building) param is unused in the body and is
# NOT a param. The distinguishing line is
# `payloads.add(payload.content());`
# (0-hit in both ledgers at HEAD 1047fc24). NO driver line:
# a pure seq update the intake caller applies, not a
# per-tick write -- the caller wiring waits for its own
# slice.
static func source_payload_ammo_turret_build_handle_payload_state(payload_contents: Array, payload_content: Variant) -> Dictionary:
	var updated_contents: Array = payload_contents.duplicate()
	if payload_content != null:
		updated_contents.append(payload_content)
	return {"payload_contents": updated_contents}

# PayloadAmmoTurret.init() (PayloadAmmoTurret.java:59-93):
# `public void init(){`
# `consume(new ConsumePayloadFilter(i -> ammoTypes.containsKey(i)){`
# on `public class PayloadAmmoTurret extends Turret{`
# (PayloadAmmoTurret.java:21). The anonymous
# ConsumePayloadFilter overrides build(), efficiency() and
# display(); displayContent() is its package-private helper:
# `void displayContent(Building build, MultiReqImage image, UnlockableContent content){`
# `if(filter.get(content) && content.unlockedNow()){`
# `image.add(new ReqImage(new Image(content.uiIcon), () -> build instanceof PayloadTurretBuild it && !it.payloads.isEmpty() && it.currentAmmo() == content));`
# `}`
# `}`
# (PayloadAmmoTurret.java:71-75). build() walks the content
# lists in order, blocks first then units:
# `for(var block : content.blocks()) displayContent(build, image, block);`
# `for(var unit : content.units()) displayContent(build, image, unit);`
# (PayloadAmmoTurret.java:65-66). efficiency() is the
# any-payload gate:
# `return build instanceof PayloadTurretBuild it && it.payloads.any() ? 1f : 0f;`
# (PayloadAmmoTurret.java:81). display() is a no-op
# comment (`//don't display`, PayloadAmmoTurret.java:86)
# and owns no expr. `ammoKeys = ...`
# (PayloadAmmoTurret.java:89) and `super.init();` are
# already owned (N2358/N2363/N2368/N2371 and generic) and
# are NOT re-registered here. The `filter` is the
# ConsumePayloadFilter predicate (ConsumePayloadFilter.java,
# `public Boolf<UnlockableContent> filter;`); `content`
# is `Vars.content`, `content.uiIcon` is the
# `public TextureRegion uiIcon;` field
# (UnlockableContent.java:46), `content.unlockedNow()` is
# UnlockableContent.java:273. `payloads` is
# `public PayloadSeq payloads = new PayloadSeq();`
# (PayloadAmmoTurret.java:95) on
# `public class PayloadTurretBuild extends TurretBuild{`
# (PayloadAmmoTurret.java:94). content.blocks/units arrive
# as explicit Array params, filter/unlockedNow/uiIcon as
# explicit Callable params (the N2330 param precedent);
# Table/MultiReqImage/ReqImage/Stats are NOT ported -- the
# result is frame data: the displayed list (content +
# uiIcon + per-entry visibility) in blocks-then-units order
# plus the efficiency value. payloads.any() and
# !payloads.isEmpty() are the same fact (PayloadSeq.java:
# 14-20, any() is `total > 0`, isEmpty() is `total == 0`),
# so one payloads_any bool param stands for both the
# efficiency gate and the ReqImage visibility lambda.
# currentAmmo() (N2358) arrives as the explicit
# current_ammo param, NOT re-ported. An invalid filter or
# unlocked_now callable closes that gate (the entry is
# excluded); an invalid ui_icon callable yields an empty
# icon string (the entry is still listed). NO driver line:
# init() registers the consumer once, it is not a per-tick
# write -- the caller wiring waits for its own slice.
static func source_payload_ammo_turret_init_state(content_blocks: Array, content_units: Array, filter: Callable, unlocked_now: Callable, ui_icon: Callable, is_payload_turret_build: bool, payloads_any: bool, current_ammo: Variant) -> Dictionary:
	var display_contents: Array = []
	for content in content_blocks:
		if filter.is_valid() and bool(filter.call(content)) and unlocked_now.is_valid() and bool(unlocked_now.call(content)):
			display_contents.append({"content": content, "ui_icon": str(ui_icon.call(content)) if ui_icon.is_valid() else "", "visible": is_payload_turret_build and payloads_any and current_ammo == content})
	for content in content_units:
		if filter.is_valid() and bool(filter.call(content)) and unlocked_now.is_valid() and bool(unlocked_now.call(content)):
			display_contents.append({"content": content, "ui_icon": str(ui_icon.call(content)) if ui_icon.is_valid() else "", "visible": is_payload_turret_build and payloads_any and current_ammo == content})
	var efficiency: float = 1.0 if is_payload_turret_build and payloads_any else 0.0
	return {"display_contents": display_contents, "efficiency": efficiency}

# PayloadAmmoTurret(String name)
# (PayloadAmmoTurret.java:26-33). One ctor slice (batch 30
# slot 3): the 1 distinguishing field default only.
# `maxAmmo = 3;` (PayloadAmmoTurret.java:29) overrides the
# Turret base default `public int maxAmmo = 30;`
# (Turret.java:47): the payload ammo turret holds at most 3
# payload ammo at once. `super(name);` is N2185-owned and
# `acceptsPayload = true;` is N2168-owned -- neither is
# re-registered here. The value is an int literal, so it
# arrives as an explicit int param and passes through (the
# N2413 ctor precedent). The default is frame data only; no
# Draw is ported.
static func source_payload_ammo_turret_default_constructor_state(payload_ammo_turret_defaults: Dictionary, max_ammo: int) -> Dictionary:
	payload_ammo_turret_defaults["max_ammo"] = max_ammo
	return {"max_ammo": max_ammo, "payload_ammo_turret_defaults": payload_ammo_turret_defaults}
