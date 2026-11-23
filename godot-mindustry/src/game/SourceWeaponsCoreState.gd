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

static func source_weapon_range_state(bullet_range: float) -> Dictionary:
	# Weapon.range() (Weapon.java:288-290,
	# `public float range(){` /
	# `return bullet.range;` /
	# `}`). `bullet` is the weapon bullet type
	# (`public BulletType bullet = Bullets.placeholder;`,
	# Weapon.java:33); `bullet.range` is the BulletType range
	# field (`public float range = 0f;`, BulletType.java:161),
	# computed by calculateRange() at init
	# (BulletType.java:854) and afterPatch
	# (BulletType.java:402) -- calculateRange()
	# (BulletType.java:433-439) is already ported
	# (SourceBulletTypeInitRangeState.gd), so this slice takes
	# the catalog `bullet.range` as its one input and returns
	# it unchanged (the N2533 param-driven precedent: dps()
	# took `bullet_estimate_dps` as a float param).
	# LIVE CONSEQUENCE: DORMANT live today.
	# range() is a catalog read, not per-tick, and no caller
	# reads the new function today (UnitType.init range /
	# maxRange, UnitType.java:971-989, and Weapon.update
	# shootLength, Weapon.java:391, are consumer slices
	# later) -> live behavior does NOT change.
	return {"range": bullet_range}

static func source_weapon_update_decay_state(mount_reload: float, mount_recoil: float, mount_recoils: Array, mount_smooth_reload: float, mount_charge: float, mount_charging: bool, mount_shoot: bool, mount_warmup: float, has_continuous_bullet: bool, recoils: int, recoil_time: float, weapon_reload: float, smooth_reload_speed: float, first_shot_delay: float, shoot_warmup_speed: float, linear_warmup: bool, continuous: bool, can: bool, source_delta: float, reload_multiplier: float) -> Dictionary:
	# Weapon.update() leg 1 (Weapon.java:293-306,
	# `boolean can = unit.canShoot();` /
	# `float lastReload = mount.reload;` /
	# `mount.reload = Math.max(mount.reload - Time.delta * unit.reloadMultiplier, 0);` /
	# `mount.recoil = Mathf.approachDelta(mount.recoil, 0, unit.reloadMultiplier / recoilTime);` /
	# `if(recoils > 0){` /
	# `if(mount.recoils == null) mount.recoils = new float[recoils];` /
	# `for(int i = 0; i < recoils; i++){` /
	# `mount.recoils[i] = Mathf.approachDelta(mount.recoils[i], 0, unit.reloadMultiplier / recoilTime);` /
	# `}` /
	# `}` /
	# `mount.smoothReload = Mathf.lerpDelta(mount.smoothReload, mount.reload / reload, smoothReloadSpeed);` /
	# `mount.charge = mount.charging && shoot.firstShotDelay > 0 ? Mathf.approachDelta(mount.charge, 1, 1 / shoot.firstShotDelay) : 0;` /
	# `float warmupTarget = (can && mount.shoot) || (continuous && mount.bullet != null) || mount.charging ? 1f : 0f;` /
	# `if(linearWarmup){` /
	# `mount.warmup = Mathf.approachDelta(mount.warmup, warmupTarget, shootWarmupSpeed);` /
	# `}else{` /
	# `mount.warmup = Mathf.lerpDelta(mount.warmup, warmupTarget, shootWarmupSpeed);` /
	# `}`).
	# `mount_reload` / `mount_recoil` / `mount_recoils` /
	# `mount_smooth_reload` / `mount_charge` /
	# `mount_charging` / `mount_shoot` / `mount_warmup` /
	# `has_continuous_bullet` are WeaponMount fields
	# (`public float reload;` / `public float recoil;` /
	# `public @Nullable float[] recoils;` /
	# `public float smoothReload;` / `public float charge;` /
	# `public boolean charging;` /
	# `public boolean shoot = false;` /
	# `public float warmup;` /
	# `public @Nullable Bullet bullet;`,
	# WeaponMount.java:12/16/18/30/28/26/34/24/47). An empty
	# `mount_recoils` Array is the GDScript representation
	# of Java `mount.recoils == null`.
	# `recoils` is the weapon barrel-recoil count
	# (`public int recoils = -1;`, Weapon.java:83);
	# `recoil_time` is the return time in ticks
	# (`public float recoilTime = -1f;`, Weapon.java:85 --
	# passed through unchanged, NOT clamped or defaulted);
	# `weapon_reload` is the weapon reload in frames
	# (`public float reload = 1;`, Weapon.java:75);
	# `smooth_reload_speed` / `shoot_warmup_speed` are the
	# lerp speeds (`public float shootWarmupSpeed = 0.1f,
	# smoothReloadSpeed = 0.15f;`, Weapon.java:111);
	# `first_shot_delay` is the shoot-pattern delay
	# (`public float firstShotDelay = 0;`,
	# ShootPattern.java:11); `linear_warmup` is the warmup
	# curve flag (`public boolean linearWarmup = false;`,
	# Weapon.java:113); `continuous` is the continuous
	# weapon flag (`public boolean continuous;`,
	# Weapon.java:53). `can` is the `unit.canShoot()`
	# frame bool, taken as an input (canShoot() itself is
	# NOT re-ported here). `source_delta` is `Time.delta`,
	# `reload_multiplier` is `unit.reloadMultiplier`.
	# ORDER TRAP: `smoothReload` lerps toward the UPDATED
	# reload (`reload' / reload`, :302 runs after :294),
	# not the input reload. `lastReload` (:294) is NOT
	# returned by this leg -- the side-flip leg
	# (Weapon.java:427-432) captures the pre-decay reload
	# in a later slice. `charge` else-branch returns
	# exactly 0 (the old charge is NOT kept).
	# LIVE CONSEQUENCE: DORMANT live today.
	# update() has no driver in the port yet, and no caller
	# reads the new function today -> live behavior does
	# NOT change.
	var reload: float = maxf(mount_reload - source_delta * reload_multiplier, 0.0)
	var recoil: float = source_math_state.source_approach_delta(mount_recoil, 0.0, reload_multiplier / recoil_time, source_delta)
	var out_recoils: Array = mount_recoils.duplicate()
	if recoils > 0:
		while out_recoils.size() < recoils:
			out_recoils.append(0.0)
		for i in recoils:
			out_recoils[i] = source_math_state.source_approach_delta(float(out_recoils[i]), 0.0, reload_multiplier / recoil_time, source_delta)
	var smooth_reload: float = source_math_state.source_lerp_delta(mount_smooth_reload, reload / weapon_reload, smooth_reload_speed, source_delta)
	var charge: float = source_math_state.source_approach_delta(mount_charge, 1.0, 1.0 / first_shot_delay, source_delta) if mount_charging and first_shot_delay > 0.0 else 0.0
	var warmup_target: float = 1.0 if (can and mount_shoot) or (continuous and has_continuous_bullet) or mount_charging else 0.0
	var warmup: float = source_math_state.source_approach_delta(mount_warmup, warmup_target, shoot_warmup_speed, source_delta) if linear_warmup else source_math_state.source_lerp_delta(mount_warmup, warmup_target, shoot_warmup_speed, source_delta)
	return {"reload": reload, "recoil": recoil, "recoils": out_recoils, "smooth_reload": smooth_reload, "charge": charge, "warmup": warmup}

static func source_weapon_update_aim_state(unit_x: float, unit_y: float, unit_rotation: float, weapon_x: float, weapon_y: float, weapon_shoot_x: float, weapon_shoot_y: float, mount_rotation: float, mount_target_rotation: float, mount_aim_x: float, mount_aim_y: float, mount_shoot: bool, mount_rotate: bool, can: bool, rotate: bool, rotate_speed: float, rotation_limit: float, base_rotation: float, always_shooting: bool, source_delta: float) -> Dictionary:
	# Weapon.update() leg 2 (Weapon.java:313-315, :350-371,
	# :373, bulletRotation :455-457,
	# `float` /
	# `mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),` /
	# `mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y);` /
	# `if(rotate && (mount.rotate || mount.shoot) && can){` /
	# `float axisX = unit.x + Angles.trnsx(unit.rotation - 90,  x, y),` /
	# `axisY = unit.y + Angles.trnsy(unit.rotation - 90,  x, y);` /
	# `mount.targetRotation = Angles.angle(axisX, axisY, mount.aimX, mount.aimY) - unit.rotation;` /
	# `mount.rotation = Angles.moveToward(mount.rotation, mount.targetRotation, rotateSpeed * Time.delta);` /
	# `if(rotationLimit < 360){` /
	# `float dst = Angles.angleDist(mount.rotation, baseRotation);` /
	# `if(dst > rotationLimit/2f){` /
	# `mount.rotation = Angles.moveToward(mount.rotation, baseRotation, dst - rotationLimit/2f);` /
	# `}` /
	# `}` /
	# `}else if(!rotate){` /
	# `mount.rotation = baseRotation;` /
	# `mount.targetRotation = unit.angleTo(mount.aimX, mount.aimY);` /
	# `}` /
	# `float` /
	# `weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),` /
	# `bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY),` /
	# `bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY),` /
	# `shootAngle = bulletRotation(unit, mount, bulletX, bulletY);` /
	# `if(alwaysShooting) mount.shoot = true;` /
	# bulletRotation (Weapon.java:455-457,
	# `protected float bulletRotation(Unit unit, WeaponMount mount, float bulletX, float bulletY){` /
	# `return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation;` /
	# `}`).
	# `unit_x` / `unit_y` / `unit_rotation` are the unit
	# position and rotation (`unit.x` / `unit.y` /
	# `unit.rotation`). `weapon_x` / `weapon_y` are the
	# weapon offsets (`public float x = 5f, y = 0f;`,
	# Weapon.java:93); `weapon_shoot_x` /
	# `weapon_shoot_y` are the shoot offsets
	# (`public float shootX = 0f, shootY = 3f;`,
	# Weapon.java:91). `mount_rotation` /
	# `mount_target_rotation` / `mount_aim_x` /
	# `mount_aim_y` / `mount_shoot` / `mount_rotate` are
	# WeaponMount fields (`public float rotation;` /
	# `public float targetRotation;` /
	# `public float aimX, aimY;` /
	# `public boolean shoot = false;` /
	# `public boolean rotate = false;`,
	# WeaponMount.java:14/20/32/34/38) -- `mount.shoot` /
	# `mount.rotate` / `mount.aimX` / `mount.aimY` come
	# from the autoTarget block (Weapon.java:315-347) as
	# FRAME INPUTS (the N2540 `can` precedent: that block
	# is BLOCKED on the live entity scan, so its outputs
	# are inputs here, not re-ported). `can` is the
	# `unit.canShoot()` frame bool, taken as an input
	# (canShoot() itself is NOT re-ported here,
	# Weapon.java:293). `rotate` is the weapon flag
	# (`public boolean rotate = false;`, Weapon.java:45);
	# `rotate_speed` is the rotation speed
	# (`public float rotateSpeed = 20f;`, Weapon.java:73);
	# `rotation_limit` is the rotation limit
	# (`public float rotationLimit = 361f;`,
	# Weapon.java:107 -- the 361f default skips the clamp
	# unless it is under 360); `base_rotation` is the
	# weapon start rotation
	# (`public float baseRotation = 0f;`, Weapon.java:49);
	# `always_shooting` is the always-shoot flag
	# (`public boolean alwaysShooting = false;`,
	# Weapon.java:63). `source_delta` is `Time.delta`.
	# ORDER TRAP: `axisX` / `axisY` (:351-352) are the
	# IDENTICAL formula to `mountX` / `mountY` (:314-315)
	# -- the same value, recomputed, not a different
	# offset. The rotate block reads `mount.rotate` /
	# `mount.shoot` BEFORE alwaysShooting (:373) sets
	# `mount.shoot = true` -- the returned `mount_shoot`
	# is the post-alwaysShooting value, but the rotate
	# guard uses the input. `mount.rotation` used in
	# weaponRotation (:368) and bulletRotation (:456) is
	# the UPDATED rotation, not the input. The `!rotate`
	# branch sets `mount.targetRotation =
	# unit.angleTo(aimX, aimY)` with NO subtraction of
	# `unit.rotation` (unlike the rotate branch).
	# `rotationLimit` default 361f skips the clamp unless
	# it is under 360, and `dst` is computed on the
	# moveToward-updated rotation. bulletRotation's
	# non-rotate branch is all three terms:
	# `Angles.angle(bulletX, bulletY, aimX, aimY) +
	# (unit.rotation - unit.angleTo(aimX, aimY)) +
	# baseRotation` (`unit.angleTo(x, y)` is
	# `Angles.angle(unit.x, unit.y, x, y)` -- the same
	# `source_angles_angle` helper in the port).
	# LIVE CONSEQUENCE: DORMANT live today.
	# update() has no driver in the port yet, and no caller
	# reads the new function today -> live behavior does
	# NOT change.
	var mount_offset: Dictionary = source_math_state.source_angles_trns_vec(unit_rotation - 90.0, weapon_x, weapon_y)
	var mount_x: float = unit_x + float(mount_offset.get("x", 0.0))
	var mount_y: float = unit_y + float(mount_offset.get("y", 0.0))
	var out_rotation: float = mount_rotation
	var out_target_rotation: float = mount_target_rotation
	if rotate and (mount_rotate or mount_shoot) and can:
		var axis_offset: Dictionary = source_math_state.source_angles_trns_vec(unit_rotation - 90.0, weapon_x, weapon_y)
		var axis_x: float = unit_x + float(axis_offset.get("x", 0.0))
		var axis_y: float = unit_y + float(axis_offset.get("y", 0.0))
		out_target_rotation = source_math_state.source_angles_angle(axis_x, axis_y, mount_aim_x, mount_aim_y) - unit_rotation
		out_rotation = source_math_state.source_angles_move_toward(mount_rotation, out_target_rotation, rotate_speed * source_delta)
		if rotation_limit < 360.0:
			var dst: float = source_math_state.source_angles_angle_dist(out_rotation, base_rotation)
			if dst > rotation_limit / 2.0:
				out_rotation = source_math_state.source_angles_move_toward(out_rotation, base_rotation, dst - rotation_limit / 2.0)
	elif not rotate:
		out_rotation = base_rotation
		out_target_rotation = source_math_state.source_angles_angle(unit_x, unit_y, mount_aim_x, mount_aim_y)
	var weapon_rotation: float = unit_rotation - 90.0 + (out_rotation if rotate else base_rotation)
	var bullet_offset: Dictionary = source_math_state.source_angles_trns_vec(weapon_rotation, weapon_shoot_x, weapon_shoot_y)
	var bullet_x: float = mount_x + float(bullet_offset.get("x", 0.0))
	var bullet_y: float = mount_y + float(bullet_offset.get("y", 0.0))
	var shoot_angle: float = (unit_rotation + out_rotation) if rotate else source_math_state.source_angles_angle(bullet_x, bullet_y, mount_aim_x, mount_aim_y) + (unit_rotation - source_math_state.source_angles_angle(unit_x, unit_y, mount_aim_x, mount_aim_y)) + base_rotation
	var out_shoot: bool = true if always_shooting else mount_shoot
	return {"mount_x": mount_x, "mount_y": mount_y, "mount_rotation": out_rotation, "mount_target_rotation": out_target_rotation, "weapon_rotation": weapon_rotation, "bullet_x": bullet_x, "bullet_y": bullet_y, "shoot_angle": shoot_angle, "mount_shoot": out_shoot}

# Weapon cooldownTime field default (Weapon.java:89, `public float cooldownTime = 20f;`):
# field-decl-only slice (merge decision: remote N2542 trimmed to this one expr -- the
# heat-decay leg it carried is owned by N864, SourceWeaponBulletContinuousState.gd:231,
# which reads cooldownTime from the weapon state with this same default). The default
# is also the live const SourceWeaponDefaults.COOLDOWN_TIME_DEFAULT (20.0); this func
# is the slice's live home for the decl, per the N2440 field-decl precedent. NO driver
# tick line: a def field default, not per-tick state.
static func source_weapon_cooldown_time_defaults_state() -> Dictionary:
	return {"cooldown_time": 20.0}

# Weapon side-flip field defaults (Weapon.java:125/:43/:41, WeaponMount.java:40):
# field-decl-only slice (merge decision: remote N2543 trimmed -- the
# side-flip leg it carried is owned by local N856 (flip body,
# `wasFlipped` / if / 2 assignments) + N870 (`lastReload`); the
# `public float reload = 1;` expr is already claimed by N2534 +
# N2535 and NOT taken here). The 4 decls kept here, per the N2440
# field-decl precedent + the N2542 trim precedent:
# `//flip weapon shoot side for alternating weapons`
# `public int otherSide = -1;` / `public boolean alternate = true;` /
# `public boolean flipSprite = false;` / `public boolean side;`
# (WeaponMount, Java boolean default false). NO driver tick line: def
# field defaults, not per-tick state.
static func source_weapon_side_flip_defaults_state() -> Dictionary:
	return {"other_side": -1, "alternate": true, "flip_sprite": false, "side": false}

static func source_weapon_init_state(always_continuous: bool, continuous: bool) -> Dictionary:
	# Weapon.init() (Weapon.java:561-566,
	# `@CallSuper` /
	# `public void init(){` /
	# `if(alwaysContinuous){` /
	# `continuous = true;` /
	# `}`).
	# `always_continuous` is the always-continuous flag
	# (`/** whether this weapon uses continuous fire
	# without reloading; implies continuous = true */
	# public boolean alwaysContinuous;`, Weapon.java:55).
	# `continuous` is the current hold-bullet flag (`/**
	# whether to hold the bullet in place while firing; it
	# will still require reload. */ public boolean
	# continuous;`, Weapon.java:53) -- a separate param
	# because the pure function returns the field's new
	# value without mutating live state (the N2540
	# precedent: a count / null-check is an input).
	# Only set when `alwaysContinuous` is true; otherwise
	# the current `continuous` value is kept unchanged
	# (including when it is already true).
	# LIVE CONSEQUENCE: DORMANT live today.
	# init() has no driver in the port yet, and no caller
	# reads the new function today -> live behavior does
	# NOT change.
	var out_continuous: bool = true if always_continuous else continuous
	return {"continuous": out_continuous}

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
