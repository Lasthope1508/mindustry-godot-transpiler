extends RefCounted
class_name SourceWeaponBulletContinuousState

const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_weapon_defaults := preload("res://src/game/SourceWeaponDefaults.gd")

const SOURCE_WEAPON_CONTINUOUS_DEFAULT := source_weapon_defaults.CONTINUOUS_DEFAULT
const SOURCE_WEAPON_ROTATION_OFFSET_DEGREES := source_weapon_defaults.ROTATION_OFFSET_DEGREES
const SOURCE_WEAPON_HALF_CIRCLE_DEGREES := source_math_defaults.HALF_CIRCLE_DEGREES
const SOURCE_WEAPON_RELOAD_DEFAULT := source_weapon_defaults.RELOAD_DEFAULT
const SOURCE_WEAPON_AIM_CHANGE_SPEED_DEFAULT := source_weapon_defaults.AIM_CHANGE_SPEED_DEFAULT
const SOURCE_WEAPON_ALWAYS_CONTINUOUS_DEFAULT := source_weapon_defaults.ALWAYS_CONTINUOUS_DEFAULT
const SOURCE_WEAPON_SHOOT_STATUS_DURATION_DEFAULT := source_weapon_defaults.SHOOT_STATUS_DURATION_DEFAULT
const SOURCE_WEAPON_COOLDOWN_TIME_DEFAULT := source_weapon_defaults.COOLDOWN_TIME_DEFAULT

static func _continuous_gate_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var continuous := bool(weapon_state.get("continuous", SOURCE_WEAPON_CONTINUOUS_DEFAULT))
	var bullet_exists := bool(mount_state.get("bulletExists", false))
	var bullet_is_added := bool(bullet_state.get("isAdded", false))
	var bullet_time := float(bullet_state.get("time", 0.0))
	var bullet_lifetime := float(bullet_state.get("lifetime", 0.0))
	var bullet_type_matches := bool(bullet_state.get("typeMatches", false))
	var gate := continuous and bullet_exists
	var invalid := gate and ((not bullet_is_added) or bullet_time >= bullet_lifetime or (not bullet_type_matches))
	return {
		"continuous": continuous,
		"bulletExists": bullet_exists,
		"bulletIsAdded": bullet_is_added,
		"bulletTime": bullet_time,
		"bulletLifetime": bullet_lifetime,
		"bulletTypeMatches": bullet_type_matches,
		"gate": gate,
		"invalid": invalid,
		"live": gate and not invalid,
	}

static func update_continuous_invalidation_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var base := _continuous_gate_state(mount_state, weapon_state, bullet_state)
	var bullet_exists := bool(base["bulletExists"])
	var invalid := bool(base["invalid"])
	if invalid:
		bullet_exists = false
	return {
		"gate": bool(base["gate"]),
		"invalid": invalid,
		"bulletExists": bullet_exists,
		"continuous": bool(base["continuous"]),
		"bulletIsAdded": bool(base["bulletIsAdded"]),
		"bulletTime": float(base["bulletTime"]),
		"bulletLifetime": float(base["bulletLifetime"]),
		"bulletTypeMatches": bool(base["bulletTypeMatches"]),
		"guardSource": "if(continuous && mount.bullet != null)",
		"invalidConditionSource": "if(!mount.bullet.isAdded() || mount.bullet.time >= mount.bullet.lifetime || mount.bullet.type != bullet)",
		"clearSource": "mount.bullet = null",
	}

static func update_continuous_live_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, bullet_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float, weapon_rotation: float, trns_vec: Callable) -> Dictionary:
	var base := _continuous_gate_state(mount_state, weapon_state, bullet_state)
	var gate := bool(base["gate"])
	var invalid := bool(base["invalid"])
	var live := bool(base["live"])
	var weapon_reload := float(weapon_state.get("reload", SOURCE_WEAPON_RELOAD_DEFAULT))
	var bullet_recoil := float(bullet_state.get("recoil", 0.0))
	var next_reload := float(mount_state.get("reload", 0.0))
	var next_recoil := float(mount_state.get("recoil", 0.0))
	var next_bullet_rotation := weapon_rotation + SOURCE_WEAPON_ROTATION_OFFSET_DEGREES
	var next_bullet_x := float(bullet_state.get("x", bullet_x))
	var next_bullet_y := float(bullet_state.get("y", bullet_y))
	var next_vel_x := float(unit_state.get("velX", 0.0))
	var next_vel_y := float(unit_state.get("velY", 0.0))
	var recoil_vec: Dictionary = trns_vec.call(next_bullet_rotation + SOURCE_WEAPON_HALF_CIRCLE_DEGREES, bullet_recoil * source_delta, 0.0)
	if live:
		next_bullet_x = bullet_x
		next_bullet_y = bullet_y
		next_reload = weapon_reload
		next_recoil = 1.0
		next_vel_x += float(recoil_vec.get("x", 0.0))
		next_vel_y += float(recoil_vec.get("y", 0.0))
	else:
		next_bullet_rotation = float(bullet_state.get("rotation", next_bullet_rotation))
	return {
		"gate": gate,
		"invalid": invalid,
		"live": live,
		"bulletRotation": next_bullet_rotation,
		"bulletX": next_bullet_x,
		"bulletY": next_bullet_y,
		"reload": next_reload,
		"recoil": next_recoil,
		"velX": next_vel_x,
		"velY": next_vel_y,
		"velAddX": float(recoil_vec.get("x", 0.0)) if live else 0.0,
		"velAddY": float(recoil_vec.get("y", 0.0)) if live else 0.0,
		"bulletRotationSource": "mount.bullet.rotation(weaponRotation + 90);",
		"bulletSetSource": "mount.bullet.set(bulletX, bulletY);",
		"reloadSource": "mount.reload = reload;",
		"recoilSource": "mount.recoil = 1f;",
		"velocityAddSource": "unit.vel.add(Tmp.v1.trns(mount.bullet.rotation() + 180f, mount.bullet.type.recoil * Time.delta));",
		"soundReservedSource": "if(shootSound != Sounds.none && !headless){",
	}

static func update_continuous_sound_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, runtime_state: Dictionary, bullet_x: float, bullet_y: float) -> Dictionary:
	var base := _continuous_gate_state(mount_state, weapon_state, bullet_state)
	var gate := bool(base["gate"])
	var invalid := bool(base["invalid"])
	var live := bool(base["live"])
	var shoot_sound_is_none := bool(weapon_state.get("shootSoundIsNone", false))
	var headless := bool(runtime_state.get("headless", false))
	var sound_gate := live and (not shoot_sound_is_none) and (not headless)
	var has_sound := bool(mount_state.get("hasSound", false))
	var created_sound := sound_gate and not has_sound
	var sound_update_call = null
	if created_sound:
		has_sound = true
	if sound_gate:
		sound_update_call = {
			"x": bullet_x,
			"y": bullet_y,
			"play": true,
			"call": "mount.sound.update(bulletX, bulletY, true)",
		}
	return {
		"gate": gate,
		"invalid": invalid,
		"live": live,
		"soundGate": sound_gate,
		"hasSound": has_sound,
		"createdSound": created_sound,
		"soundUpdateCall": sound_update_call,
		"shootSoundIsNone": shoot_sound_is_none,
		"headless": headless,
		"soundGuardSource": "if(shootSound != Sounds.none && !headless){",
		"soundCreateSource": "if(mount.sound == null) mount.sound = new SoundLoop(shootSound, 1f);",
		"soundUpdateSource": "mount.sound.update(bulletX, bulletY, true);",
		"soundLoopConstructorSource": "public SoundLoop(Sound sound, float baseVolume){",
		"soundLoopUpdateSource": "public void update(float x, float y, boolean play){",
		"soundLoopUpdateDelegateSource": "update(x, y, play, 1f);",
		"laserLengthReservedSource": "//target length of laser",
	}

static func update_continuous_laser_aim_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float, shoot_angle: float, mathf_dst: Callable, approach_delta: Callable, trns_vec: Callable) -> Dictionary:
	var base := _continuous_gate_state(mount_state, weapon_state, bullet_state)
	var gate := bool(base["gate"])
	var invalid := bool(base["invalid"])
	var live := bool(base["live"])
	var mount_aim_x := float(mount_state.get("aimX", bullet_x))
	var mount_aim_y := float(mount_state.get("aimY", bullet_y))
	var bullet_aim_x := float(bullet_state.get("aimX", bullet_x))
	var bullet_aim_y := float(bullet_state.get("aimY", bullet_y))
	var weapon_range := float(bullet_state.get("range", 0.0))
	var aim_change_speed := float(weapon_state.get("aimChangeSpeed", SOURCE_WEAPON_AIM_CHANGE_SPEED_DEFAULT))
	var shoot_length: float = min(mathf_dst.call(bullet_x, bullet_y, mount_aim_x, mount_aim_y), weapon_range)
	var cur_length: float = mathf_dst.call(bullet_x, bullet_y, bullet_aim_x, bullet_aim_y)
	var result_length: float = approach_delta.call(cur_length, shoot_length, aim_change_speed, source_delta)
	var aim_vec: Dictionary = trns_vec.call(shoot_angle, result_length, 0.0)
	var next_last_length := float(mount_state.get("lastLength", 0.0))
	var next_bullet_aim_x := bullet_aim_x
	var next_bullet_aim_y := bullet_aim_y
	if live:
		next_last_length = result_length
		next_bullet_aim_x = bullet_x + float(aim_vec.get("x", 0.0))
		next_bullet_aim_y = bullet_y + float(aim_vec.get("y", 0.0))
	return {
		"gate": gate,
		"invalid": invalid,
		"live": live,
		"shootLength": shoot_length,
		"curLength": cur_length,
		"resultLength": result_length,
		"lastLength": next_last_length,
		"bulletAimX": next_bullet_aim_x,
		"bulletAimY": next_bullet_aim_y,
		"weaponRange": weapon_range,
		"aimChangeSpeed": aim_change_speed,
		"shootLengthSource": "float shootLength = Math.min(Mathf.dst(bulletX, bulletY, mount.aimX, mount.aimY), range());",
		"curLengthSource": "float curLength = Mathf.dst(bulletX, bulletY, mount.bullet.aimX, mount.bullet.aimY);",
		"resultLengthSource": "float resultLength = Mathf.approachDelta(curLength, shootLength, aimChangeSpeed);",
		"aimEndpointSource": "Tmp.v1.trns(shootAngle, mount.lastLength = resultLength).add(bulletX, bulletY);",
		"bulletAimXSource": "mount.bullet.aimX = Tmp.v1.x;",
		"bulletAimYSource": "mount.bullet.aimY = Tmp.v1.y;",
		"rangeSource": "return bullet.range;",
		"alwaysContinuousReservedSource": "if(alwaysContinuous && mount.shoot){",
	}

static func update_always_continuous_keepalive_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary, status_apply_result: Callable) -> Dictionary:
	var base := _continuous_gate_state(mount_state, weapon_state, bullet_state)
	var gate := bool(base["gate"])
	var invalid := bool(base["invalid"])
	var live := bool(base["live"])
	var bullet_time := float(base["bulletTime"])
	var bullet_lifetime := float(base["bulletLifetime"])
	var always_continuous := bool(weapon_state.get("alwaysContinuous", SOURCE_WEAPON_ALWAYS_CONTINUOUS_DEFAULT))
	var mount_shoot := bool(mount_state.get("shoot", false))
	var mount_warmup := float(mount_state.get("warmup", 0.0))
	var optimal_life_fract := float(bullet_state.get("optimalLifeFract", 0.0))
	var keepalive_gate := live and always_continuous and mount_shoot
	var next_bullet_time := bullet_time
	var next_keep_alive := bool(bullet_state.get("keepAlive", false))
	if keepalive_gate:
		next_bullet_time = bullet_lifetime * optimal_life_fract * mount_warmup
		next_keep_alive = true
	var shoot_status := "" if weapon_state.get("shootStatus", "none") == null else str(weapon_state.get("shootStatus", "none"))
	var shoot_status_duration := float(weapon_state.get("shootStatusDuration", SOURCE_WEAPON_SHOOT_STATUS_DURATION_DEFAULT))
	var status_immune := bool(unit_state.get("statusImmune", false))
	var status_result: Dictionary = status_apply_result.call(shoot_status, shoot_status_duration, status_immune)
	var status_applied := keepalive_gate and bool(status_result.get("statusApplied", false))
	var status_application: Dictionary = {}
	if status_applied:
		status_application = status_result.get("statusApplication", {})
	return {
		"gate": gate,
		"invalid": invalid,
		"live": live,
		"alwaysContinuous": always_continuous,
		"mountShoot": mount_shoot,
		"keepaliveGate": keepalive_gate,
		"bulletTime": next_bullet_time,
		"keepAlive": next_keep_alive,
		"shootStatus": shoot_status,
		"shootStatusDuration": shoot_status_duration,
		"statusImmune": status_immune,
		"statusApplied": status_applied,
		"statusApplication": status_application,
		"guardSource": "if(alwaysContinuous && mount.shoot){",
		"timeSource": "mount.bullet.time = mount.bullet.lifetime * mount.bullet.type.optimalLifeFract * mount.warmup;",
		"keepAliveSource": "mount.bullet.keepAlive = true;",
		"unitApplySource": "unit.apply(shootStatus, shootStatusDuration);",
		"statusApplyGuardSource": status_result.get("statusApplyGuardSource", ""),
	}

static func update_continuous_idle_heat_sound_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float) -> Dictionary:
	var continuous := bool(weapon_state.get("continuous", SOURCE_WEAPON_CONTINUOUS_DEFAULT))
	var bullet_exists := bool(mount_state.get("bulletExists", false))
	var continuous_live_gate := continuous and bullet_exists
	var idle_gate := not continuous_live_gate
	var current_heat := float(mount_state.get("heat", 0.0))
	var reload_multiplier := float(unit_state.get("reloadMultiplier", 1.0))
	var cooldown_time := float(weapon_state.get("cooldownTime", SOURCE_WEAPON_COOLDOWN_TIME_DEFAULT))
	var next_heat := current_heat
	if idle_gate:
		next_heat = max(current_heat - source_delta * reload_multiplier / cooldown_time, 0.0)
	var has_sound := bool(mount_state.get("hasSound", false))
	var sound_update_call = null
	if idle_gate and has_sound:
		sound_update_call = {
			"x": bullet_x,
			"y": bullet_y,
			"play": false,
		}
	return {
		"continuous": continuous,
		"bulletExists": bullet_exists,
		"continuousLiveGate": continuous_live_gate,
		"idleGate": idle_gate,
		"heat": next_heat,
		"reloadMultiplier": reload_multiplier,
		"cooldownTime": cooldown_time,
		"hasSound": has_sound,
		"soundUpdateCall": sound_update_call,
		"heatSource": "mount.heat = Math.max(mount.heat - Time.delta * unit.reloadMultiplier / cooldownTime, 0)",
		"soundGuardSource": "if(mount.sound != null)",
		"soundUpdateSource": "mount.sound.update(bulletX, bulletY, false)",
	}
