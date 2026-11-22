extends RefCounted
class_name SourceWeaponsCoreState

const source_weapon_defaults := preload("res://src/game/SourceWeaponDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

const SOURCE_WEAPON_BASE_ROTATION_DEFAULT := source_weapon_defaults.BASE_ROTATION_DEFAULT

static func setup_mounts_state(weapon_states: Array) -> Dictionary:
	var mounts: Array = []
	for index in weapon_states.size():
		var weapon_state: Dictionary = weapon_states[index]
		mounts.append({
			"index": index,
			"weapon": str(weapon_state.get("weapon", "weapon%d" % index)),
			"call": "mounts[i] = def.weapons.get(i).mountType.get(def.weapons.get(i));",
			"constructor": "public WeaponMount(Weapon weapon){",
			"rotation": float(weapon_state.get("baseRotation", SOURCE_WEAPON_BASE_ROTATION_DEFAULT)),
		})
	return {
		"method": "void setupWeapons(UnitType def){",
		"array": "mounts = new WeaponMount[def.weapons.size];",
		"loop": "for(int i = 0; i < mounts.length; i++){",
		"mounts": mounts,
	}

static func source_weapon_dps_state(bullet_estimate_dps: float, reload: float, shoot_shots: int) -> Dictionary:
	# Weapon.dps() (Weapon.java:188-190,
	# `public float dps(){` /
	# `return (bullet.estimateDPS() / reload) * shoot.shots * 60f;`).
	# `bullet_estimate_dps` is the caller-computed
	# `bullet.estimateDPS()` (N2529,
	# `source_bullet_type_estimate_dps_state`, 13 params):
	# a float param, NOT called directly here -- calling
	# N2529 from inside this function would force all 13
	# bullet params into the Weapon signature (the
	# N2528/N2529/N2533 param-driven precedent: N2528 took
	# `peek_ammo_dps`, N2529 took `spawn_unit_dps` /
	# `despawn_unit_dps`, N2533 took `weapons_dps_sum`).
	# `reload` is the weapon reload in frames
	# (`public float reload = 1;`, Weapon.java:75 --
	# `RELOAD_DEFAULT := 1.0` in SourceWeaponDefaults.gd).
	# `shoot_shots` is the ShootPattern shot count
	# (`public int shots = 1;`,
	# ShootPattern.java:8-9, "amount of shots per
	# \"trigger pull\"" -- `SHOTS_DEFAULT := 1` in
	# SourceShootPatternDefaults.gd; the weapon holds
	# the pattern as
	# `public ShootPattern shoot = new ShootPattern();`
	# (Weapon.java:97). dps() has NO
	# cache (no `cachedDps` / `dpsEstimate` field in
	# Weapon.java -- unlike BulletType `cachedDps` and
	# UnitType `dpsEstimate`): it recomputes on every
	# call, so there is no `cached_dps` return key and no
	# `branch` key -- the single return key is `dps`.
	# dps() has NO `reload == 0` guard (only `addStats()`
	# Weapon.java:180 guards `reload > 0` for display):
	# the faithful port does not add one -- Java float /
	# 0 is Infinity, not a throw, and GDScript float /
	# 0.0 behaves the same.
	# LIVE CONSEQUENCE: DORMANT live today.
	# dps() is a read/estimate, not per-tick, and no
	# caller reads the new function today (N2533 still
	# takes `weapons_dps_sum` as a float param; wiring
	# N2533 -> N2534 is a separate consumer slice; C11
	# HUD / stats display reads `dps` in a later slice)
	# -> live behavior does NOT change. The only callers
	# in Java today are `UnitType.estimateDps()` via
	# `weapons.sumf(Weapon::dps)` (UnitType.java:1136)
	# and `addStats()` (Weapon.java:180-182, an inline
	# display formula, not a dps() call).
	return {"dps": (bullet_estimate_dps / reload) * float(shoot_shots) * 60.0}

static func source_weapon_shots_per_sec_state(reload: float, shoot_shots: int) -> Dictionary:
	# Weapon.shotsPerSec() (Weapon.java:192-194,
	# `public float shotsPerSec(){` /
	# `return shoot.shots * 60f / reload;`).
	# `reload` is the weapon reload in frames
	# (`public float reload = 1;`, Weapon.java:75 --
	# `RELOAD_DEFAULT := 1.0` in SourceWeaponDefaults.gd).
	# `shoot_shots` is the ShootPattern shot count
	# (`public int shots = 1;`,
	# ShootPattern.java:8-9, "amount of shots per
	# \"trigger pull\"" -- `SHOTS_DEFAULT := 1` in
	# SourceShootPatternDefaults.gd; the weapon holds
	# the pattern as
	# `public ShootPattern shoot = new ShootPattern();`
	# (Weapon.java:97). shotsPerSec() has NO
	# cache (no `cachedDps` / `dpsEstimate` field in
	# Weapon.java -- unlike BulletType `cachedDps` and
	# UnitType `dpsEstimate`): it recomputes on every
	# call, so there is no `cached_shots_per_sec`
	# return key and no `branch` key -- the single
	# return key is `shots_per_sec`.
	# shotsPerSec() has NO `reload == 0` guard (only
	# `addStats()` Weapon.java:180 guards `reload > 0`
	# for display): the faithful port does not add one
	# -- Java float / 0 is Infinity, not a throw, and
	# GDScript float / 0.0 behaves the same.
	# LIVE CONSEQUENCE: DORMANT live today.
	# shotsPerSec() is a read/estimate, not per-tick,
	# and no caller reads the new function today (no
	# Java caller outside Weapon itself; the C11 HUD /
	# stats display reads `shots_per_sec` in a later
	# slice) -> live behavior does NOT change.
	return {"shots_per_sec": float(shoot_shots) * 60.0 / reload}

static func source_weapon_draw_outline_state(outline_found: bool, unit_rotation: float, unit_x: float, unit_y: float, mount_recoil: float, mount_rotation: float, rotate: bool, base_rotation: float, recoil: float, recoil_pow: float, weapon_x: float, weapon_y: float, flip_sprite: bool) -> Dictionary:
	# Weapon.drawOutline() (Weapon.java:196-213,
	# `public void drawOutline(Unit unit, WeaponMount mount){` /
	# `if(!outlineRegion.found()) return;` /
	# `rotation = unit.rotation - 90,` /
	# `realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,` /
	# `weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),` /
	# `wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),` /
	# `wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);` /
	# `Draw.xscl = -Mathf.sign(flipSprite);` /
	# `Draw.rect(outlineRegion, wx, wy, weaponRotation);` /
	# `Draw.xscl = 1f;`).
	# `outline_found` is a bool param: the guard is first in
	# Java, and the port mirrors the draw_team_top_state
	# precedent (SourceBuildingDrawState.gd:159-163, which
	# takes `team_region_found` as its first param and
	# returns `{"visible": false}` when the region is not
	# found) -- when the outline region is not found,
	# drawOutline() returns before computing anything, so
	# this function returns only `visible: false` and no
	# draw keys. The `Draw.xscl = 1f;` reset after Draw.rect
	# is render-state restore, not a return value -- the
	# returned `xscl` is the value drawOutline() sets before
	# the rect call. `xscl` is `-Mathf.sign(flipSprite)`;
	# arc Mathf.sign(boolean) (Mathf.java:203-205) is 1 if
	# true else -1, so xscl is -1.0 when flip_sprite is true
	# and +1.0 otherwise (NOT the float overload, which is
	# -1 if f < 0 else 1). The trns legs reuse the existing
	# port: no scalar trnsx/trnsy port exists, and
	# `source_angles_trns_vec` (SourceMathState.gd:140)
	# computes exactly Angles.trnsx/trnsy(angle, x, y)
	# (arc Angles.java:74-82, `rv.set(x, y).rotate(angle)`).
	# `mount_recoil` / `mount_rotation` are WeaponMount
	# fields (`public float rotation;` /
	# `public float recoil;`, WeaponMount.java:14/16).
	# `rotate` is the weapon flag (`public boolean rotate =
	# false;`, Weapon.java:45 -- `ROTATE_DEFAULT := false`
	# in SourceWeaponDefaults.gd); `base_rotation` is the
	# weapon start rotation (`public float baseRotation =
	# 0f;`, Weapon.java:49); `recoil` is the visual
	# knockback (`public float recoil = 1.5f;`,
	# Weapon.java:81); `recoil_pow` is the recoil power
	# curve (`public float recoilPow = 1.8f;`,
	# Weapon.java:87); `weapon_x` / `weapon_y` are the
	# weapon offsets (`public float x = 5f, y = 0f;`,
	# Weapon.java:93); `flip_sprite` is the render flip
	# flag (`public boolean flipSprite = false;`,
	# Weapon.java:41). The intermediates `rotation` /
	# `real_recoil` are NOT return keys -- they are encoded
	# in `outline_x` / `outline_y` / `weapon_rotation`.
	# LIVE CONSEQUENCE: DORMANT live today.
	# drawOutline() is draw code, rendering is outside the
	# game, and no caller reads the new function today (its
	# only Java caller is draw() when `top` is true,
	# Weapon.java:227-229, itself draw code; the draw()
	# port is a later slice) -> live behavior does NOT
	# change.
	if not outline_found:
		return {"visible": false}
	var rotation: float = unit_rotation - 90.0
	var real_recoil: float = pow(mount_recoil, recoil_pow) * recoil
	var weapon_rotation: float = rotation + (mount_rotation if rotate else base_rotation)
	var base_offset: Dictionary = source_math_state.source_angles_trns_vec(rotation, weapon_x, weapon_y)
	var recoil_offset: Dictionary = source_math_state.source_angles_trns_vec(weapon_rotation, 0.0, -real_recoil)
	var wx: float = unit_x + float(base_offset.get("x", 0.0)) + float(recoil_offset.get("x", 0.0))
	var wy: float = unit_y + float(base_offset.get("y", 0.0)) + float(recoil_offset.get("y", 0.0))
	var xscl: float = -1.0 if flip_sprite else 1.0
	return {"visible": true, "outline_x": wx, "outline_y": wy, "weapon_rotation": weapon_rotation, "xscl": xscl}

static func source_weapon_draw_state(z: float, unit_rotation: float, unit_x: float, unit_y: float, mount_recoil: float, mount_rotation: float, rotate: bool, base_rotation: float, recoil: float, recoil_pow: float, weapon_x: float, weapon_y: float, flip_sprite: bool, shadow: float, top: bool, region_found: bool, cell_region_found: bool, heat_region_found: bool, mount_heat: float, layer_offset: float, parts_count: int) -> Dictionary:
	# Weapon.draw() (Weapon.java:214-286,
	# `public void draw(Unit unit, WeaponMount mount){` /
	# `float z = Draw.z();` /
	# `Draw.z(z + layerOffset);` /
	# `rotation = unit.rotation - 90,` /
	# `realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,` /
	# `weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),` /
	# `wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),` /
	# `wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);` /
	# `if(shadow > 0){` / `Drawf.shadow(wx, wy, shadow);` /
	# `if(top){` / `drawOutline(unit, mount);` /
	# `if(parts.size > 0){` /
	# `Draw.xscl *= -Mathf.sign(flipSprite);` /
	# `if(region.found()) Draw.rect(region, wx, wy, weaponRotation);` /
	# `if(cellRegion.found()){` /
	# `if(heatRegion.found() && mount.heat > 0){` /
	# `Draw.z(z);`).
	# draw() has NO early return (unlike drawOutline): every
	# branch returns all thirteen keys. `z` is the caller-passed
	# Draw.z() before the layer offset (`float z = Draw.z();`,
	# Weapon.java:214 -- the proof passes 0.0 for a fresh draw);
	# `z_draw` is `z + layerOffset` (`Draw.z(z + layerOffset);`,
	# Weapon.java:215 -- `public float layerOffset = 0f;`,
	# Weapon.java:127, "draw Z offset relative to the default
	# value"). The `Draw.z(z);` restore at the end is
	# render-state restore, not a return value. `shadow_drawn`
	# is `shadow > 0` (Weapon.java:224 -- `public float shadow
	# = -1f;`, Weapon.java:99, "radius of shadow drawn under
	# the weapon; <0 to disable"); `outline_called` is `top`
	# (Weapon.java:228-229 -- `public boolean top = true;`,
	# Weapon.java:51, "whether to draw the outline on top";
	# the drawOutline call body is already N2537's function,
	# only the flag is returned here). `has_parts` is
	# `parts_count > 0` (`if(parts.size > 0){`,
	# Weapon.java:232 -- per-part DrawPart drawing, both
	# under/over loops with DrawPart.params.set / setRecoil,
	# is a DrawPart subsystem slice later, NOT ported here).
	# `xscl` is `-Mathf.sign(flipSprite)`; arc
	# Mathf.sign(boolean) (Mathf.java:203-205) is 1 if true
	# else -1, so xscl is -1.0 when flip_sprite is true and
	# +1.0 otherwise (`public boolean flipSprite = false;`,
	# Weapon.java:41). `region_drawn` is `region_found`
	# (Weapon.java:253); `cell_drawn` is `cell_region_found`
	# (Weapon.java:255); `heat_drawn` is `heat_region_found`
	# AND `mount_heat > 0` (Weapon.java:261 -- `mount.heat`
	# is a WeaponMount field, WeaponMount.java:22).
	# cellColor / heatColor / applyColor values are
	# render-only, no return key. The trns legs reuse the
	# existing port: no scalar trnsx/trnsy port exists, and
	# `source_angles_trns_vec` (SourceMathState.gd:140)
	# computes exactly Angles.trnsx/trnsy(angle, x, y)
	# (arc Angles.java:74-82, `rv.set(x, y).rotate(angle)`).
	# `mount_recoil` / `mount_rotation` are WeaponMount
	# fields (`public float rotation;` /
	# `public float recoil;`, WeaponMount.java:14/16).
	# `rotate` is the weapon flag (`public boolean rotate =
	# false;`, Weapon.java:45); `base_rotation` is the weapon
	# start rotation (`public float baseRotation = 0f;`,
	# Weapon.java:49); `recoil` is the visual knockback
	# (`public float recoil = 1.5f;`, Weapon.java:81);
	# `recoil_pow` is the recoil power curve (`public float
	# recoilPow = 1.8f;`, Weapon.java:87); `weapon_x` /
	# `weapon_y` are the weapon offsets (`public float x =
	# 5f, y = 0f;`, Weapon.java:93).
	# LIVE CONSEQUENCE: DORMANT live today.
	# draw() is draw code, rendering is outside the game, and
	# no caller reads the new function today -> live behavior
	# does NOT change.
	var z_draw: float = z + layer_offset
	var rotation: float = unit_rotation - 90.0
	var real_recoil: float = pow(mount_recoil, recoil_pow) * recoil
	var weapon_rotation: float = rotation + (mount_rotation if rotate else base_rotation)
	var base_offset: Dictionary = source_math_state.source_angles_trns_vec(rotation, weapon_x, weapon_y)
	var recoil_offset: Dictionary = source_math_state.source_angles_trns_vec(weapon_rotation, 0.0, -real_recoil)
	var wx: float = unit_x + float(base_offset.get("x", 0.0)) + float(recoil_offset.get("x", 0.0))
	var wy: float = unit_y + float(base_offset.get("y", 0.0)) + float(recoil_offset.get("y", 0.0))
	var xscl: float = -1.0 if flip_sprite else 1.0
	var shadow_drawn: bool = shadow > 0.0
	var outline_called: bool = top
	var has_parts: bool = parts_count > 0
	var region_drawn: bool = region_found
	var cell_drawn: bool = cell_region_found
	var heat_drawn: bool = heat_region_found and mount_heat > 0.0
	return {"rotation": rotation, "real_recoil": real_recoil, "weapon_rotation": weapon_rotation, "wx": wx, "wy": wy, "xscl": xscl, "z_draw": z_draw, "shadow_drawn": shadow_drawn, "outline_called": outline_called, "has_parts": has_parts, "region_drawn": region_drawn, "cell_drawn": cell_drawn, "heat_drawn": heat_drawn}

static func set_rotation_state(mount_states: Array, source_rotation: float) -> Dictionary:
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		mounts.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"assignment": "mount.rotation = rotation;",
			"sourceParameter": "rotation",
			"rotation": source_rotation,
		})
	return {
		"method": "void setWeaponRotation(float rotation){",
		"loop": "for(WeaponMount mount : mounts){",
		"mounts": mounts,
	}

static func control_state(mount_states: Array, rotate_value: bool, shoot_value: bool) -> Dictionary:
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		var controllable := bool(mount_state.get("controllable", true))
		mounts.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"controlled": controllable,
			"guard": "if(mount.weapon.controllable){",
			"rotateAssignment": "mount.rotate = rotate;",
			"shootAssignment": "mount.shoot = shoot;",
			"rotate": rotate_value if controllable else bool(mount_state.get("rotate", false)),
			"shoot": shoot_value if controllable else bool(mount_state.get("shoot", false)),
		})
	return {
		"controlMethod": "void controlWeapons(boolean rotate, boolean shoot){",
		"loop": "for(WeaponMount mount : mounts){",
		"isRotate": rotate_value,
		"isShooting": shoot_value,
		"mounts": mounts,
	}

static func control_rotate_shoot_state(mount_states: Array, rotate_shoot: bool) -> Dictionary:
	var weapon_control_state := control_state(mount_states, rotate_shoot, rotate_shoot)
	weapon_control_state["delegate"] = "controlWeapons(rotateShoot, rotateShoot);"
	weapon_control_state["rotateShootMethod"] = "void controlWeapons(boolean rotateShoot){"
	weapon_control_state["rotateShootDelegate"] = "controlWeapons(rotateShoot, rotateShoot);"
	return weapon_control_state

static func aim_state(mount_states: Array, unit_x: float, unit_y: float, target_x: float, target_y: float, aim_dst: float) -> Dictionary:
	var aim_vector := Vector2(target_x, target_y) - Vector2(unit_x, unit_y)
	if aim_vector.length() < aim_dst and aim_vector.length_squared() > 0.0:
		aim_vector = aim_vector.normalized() * aim_dst
	var final_x := aim_vector.x + unit_x
	var final_y := aim_vector.y + unit_y
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		var controllable := bool(mount_state.get("controllable", true))
		mounts.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"controlled": controllable,
			"guard": "mount.weapon.controllable",
			"aimXAssignment": "mount.aimX = x;",
			"aimYAssignment": "mount.aimY = y;",
			"aimX": final_x if controllable else float(mount_state.get("aimX", 0.0)),
			"aimY": final_y if controllable else float(mount_state.get("aimY", 0.0)),
		})
	return {
		"floatMethod": "void aim(float x, float y){",
		"tmp": "Tmp.v1.set(x, y).sub(this.x, this.y);",
		"minDistance": "if(Tmp.v1.len() < type.aimDst) Tmp.v1.setLength(type.aimDst);",
		"zeroVectorSetLength": "return (oldLen2 == 0 || oldLen2 == len2) ? this : scl((float)Math.sqrt(len2 / oldLen2));",
		"aimX": final_x,
		"aimY": final_y,
		"mounts": mounts,
	}

static func aim_position_state(mount_states: Array, unit_x: float, unit_y: float, position_x: float, position_y: float, aim_dst: float) -> Dictionary:
	var weapon_aim_state := aim_state(mount_states, unit_x, unit_y, position_x, position_y, aim_dst)
	weapon_aim_state["positionMethod"] = "void aim(Position pos){"
	weapon_aim_state["positionDelegate"] = "aim(pos.getX(), pos.getY());"
	return weapon_aim_state

static func can_shoot_state(disarmed_value: bool) -> Dictionary:
	var can_shoot := not disarmed_value
	return {
		"canShootMethod": "boolean canShoot(){",
		"return": "return !disarmed;",
		"disarmed": disarmed_value,
		"canShoot": can_shoot,
	}

static func remove_continuous_bullet_cleanup_state(mount_states: Array, unit_id: int) -> Dictionary:
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		var bullet_state: Dictionary = mount_state.get("bullet", {})
		var has_bullet := not bullet_state.is_empty()
		var owns_bullet := has_bullet and int(bullet_state.get("owner", -1)) == unit_id
		var continuous := bool(mount_state.get("continuous", false))
		var cleanup := continuous and has_bullet and owns_bullet
		var result_bullet = null
		var bullet_time = null
		if has_bullet:
			bullet_time = float(bullet_state.get("lifetime", 0.0)) - 10.0
			if not cleanup:
				bullet_time = float(bullet_state.get("time", 0.0))
				result_bullet = {
					"owner": int(bullet_state.get("owner", -1)),
					"time": bullet_time,
					"lifetime": float(bullet_state.get("lifetime", 0.0)),
				}
		mounts.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"guard": "if(mount.weapon.continuous && mount.bullet != null && mount.bullet.owner == self()){",
			"continuous": continuous,
			"hadBullet": has_bullet,
			"ownsBullet": owns_bullet,
			"cleanup": cleanup,
			"timeAssignment": "mount.bullet.time = mount.bullet.lifetime - 10f;",
			"clearAssignment": "mount.bullet = null;",
			"bulletTime": bullet_time,
			"bullet": result_bullet,
		})
	return {
		"removeMethod": "public void remove(){",
		"loop": "for(WeaponMount mount : mounts){",
		"unit": unit_id,
		"mounts": mounts,
	}

static func remove_sound_stop_state(mount_states: Array) -> Dictionary:
	var mounts: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		var has_sound := bool(mount_state.get("sound", false))
		var stop_call = null
		if has_sound:
			stop_call = {
				"call": "mount.sound.stop();",
				"method": "public void stop(){",
				"idGuard": "if(id != -1){",
				"effects": ["Core.audio.stop(id);", "id = -1;", "volume = 0f;"],
			}
		mounts.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"guard": "if(mount.sound != null){",
			"hasSound": has_sound,
			"stopCall": stop_call,
		})
	return {
		"loop": "for(WeaponMount mount : mounts){",
		"mounts": mounts,
	}

static func update_dispatch_state(mount_states: Array, unit_id: int) -> Dictionary:
	var dispatches: Array = []
	for index in mount_states.size():
		var mount_state: Dictionary = mount_states[index]
		dispatches.append({
			"index": index,
			"weapon": str(mount_state.get("weapon", "weapon%d" % index)),
			"unit": unit_id,
			"call": "mount.weapon.update(self(), mount);",
			"unitArg": "self()",
			"mountArg": "mount",
			"weaponUpdateMethod": "public void update(Unit unit, WeaponMount mount){",
		})
	return {
		"updateComment": "/** Update shooting and rotation for this unit. */",
		"updateOverride": "@Override\n    public void update(){",
		"loop": "for(WeaponMount mount : mounts){",
		"mountsField": "@SyncLocal WeaponMount[] mounts = {};",
		"dispatches": dispatches,
	}
