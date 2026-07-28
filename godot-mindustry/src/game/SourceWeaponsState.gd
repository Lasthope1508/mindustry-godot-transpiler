extends RefCounted
class_name SourceWeaponsState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const SourceWeaponDefaults := preload("res://src/game/SourceWeaponDefaults.gd")
const SourceShootPatternDefaults := preload("res://src/game/SourceShootPatternDefaults.gd")

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"approach_delta": Callable(game, "source_mathf_approach_delta"),
		"lerp_delta": Callable(game, "source_mathf_lerp_delta"),
		"trns_vec": Callable(game, "source_arc_angles_trns_vec"),
		"angles_angle": Callable(game, "source_arc_angles_angle"),
		"move_toward_angle": Callable(game, "source_arc_angles_move_toward"),
		"angle_dist": Callable(game, "source_arc_angles_angle_dist"),
		"mathf_dst": Callable(game, "source_mathf_dst"),
		"status_apply_result": Callable(game, "source_status_apply_result"),
		"bullet_origin_state": Callable(game, "source_weapon_update_bullet_origin_state"),
	}

const SOURCE_WEAPON_RELOAD_DEFAULT := SourceWeaponDefaults.RELOAD_DEFAULT
const SOURCE_WEAPON_RECOIL_TIME_DEFAULT := SourceWeaponDefaults.RECOIL_TIME_DEFAULT
const SOURCE_WEAPON_RECOILS_DEFAULT := SourceWeaponDefaults.RECOILS_DEFAULT
const SOURCE_WEAPON_SMOOTH_RELOAD_SPEED_DEFAULT := SourceWeaponDefaults.SMOOTH_RELOAD_SPEED_DEFAULT
const SOURCE_SHOOT_PATTERN_SHOTS_DEFAULT := SourceShootPatternDefaults.SHOTS_DEFAULT
const SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT := SourceShootPatternDefaults.FIRST_SHOT_DELAY_DEFAULT
const SOURCE_SHOOT_PATTERN_SHOT_DELAY_DEFAULT := SourceShootPatternDefaults.SHOT_DELAY_DEFAULT
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_SHOTS_FIELD := "public int shots = 1;"
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_FIRST_SHOT_DELAY_FIELD := "public float firstShotDelay = 0;"
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_SHOT_DELAY_FIELD := "public float shotDelay = 0;"
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_METHOD := "public void shoot(int totalShots, BulletHandler handler){"
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_LOOP := "for(int i = 0; i < shots; i++){"
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_HANDLER_CALL := "handler.shoot(0, 0, 0, firstShotDelay + shotDelay * i);"
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_MOVER_NULL := "shoot(x, y, rotation, delay, null);"
const SOURCE_WEAPON_CONTINUOUS_DEFAULT := SourceWeaponDefaults.CONTINUOUS_DEFAULT
const SOURCE_WEAPON_SHOOT_WARMUP_SPEED_DEFAULT := SourceWeaponDefaults.SHOOT_WARMUP_SPEED_DEFAULT
const SOURCE_WEAPON_LINEAR_WARMUP_DEFAULT := SourceWeaponDefaults.LINEAR_WARMUP_DEFAULT
const SOURCE_WEAPON_X_DEFAULT := SourceWeaponDefaults.X_DEFAULT
const SOURCE_WEAPON_Y_DEFAULT := SourceWeaponDefaults.Y_DEFAULT
const SOURCE_WEAPON_CONTROLLABLE_DEFAULT := SourceWeaponDefaults.CONTROLLABLE_DEFAULT
const SOURCE_WEAPON_ROTATION_OFFSET_DEGREES := SourceWeaponDefaults.ROTATION_OFFSET_DEGREES
const SOURCE_WEAPON_AUTO_TARGET_DEFAULT := SourceWeaponDefaults.AUTO_TARGET_DEFAULT
const SOURCE_WEAPON_TARGET_INTERVAL_DEFAULT := SourceWeaponDefaults.TARGET_INTERVAL_DEFAULT
const SOURCE_WEAPON_TARGET_SWITCH_INTERVAL_DEFAULT := SourceWeaponDefaults.TARGET_SWITCH_INTERVAL_DEFAULT
const SOURCE_WEAPON_SHOOT_Y_DEFAULT := SourceWeaponDefaults.SHOOT_Y_DEFAULT
const SOURCE_WEAPON_PREDICT_TARGET_DEFAULT := SourceWeaponDefaults.PREDICT_TARGET_DEFAULT
const SOURCE_WEAPON_ROTATE_DEFAULT := SourceWeaponDefaults.ROTATE_DEFAULT
const SOURCE_WEAPON_ROTATE_SPEED_DEFAULT := SourceWeaponDefaults.ROTATE_SPEED_DEFAULT
const SOURCE_WEAPON_ROTATION_LIMIT_DEFAULT := SourceWeaponDefaults.ROTATION_LIMIT_DEFAULT
const SOURCE_WEAPON_BASE_ROTATION_DEFAULT := SourceWeaponDefaults.BASE_ROTATION_DEFAULT
const SOURCE_WEAPON_SHOOT_CONE_DEFAULT := SourceWeaponDefaults.SHOOT_CONE_DEFAULT
const SOURCE_WEAPON_SHOOT_X_DEFAULT := SourceWeaponDefaults.SHOOT_X_DEFAULT
const SOURCE_WEAPON_ALWAYS_SHOOTING_DEFAULT := SourceWeaponDefaults.ALWAYS_SHOOTING_DEFAULT
const SOURCE_WEAPON_AIM_CHANGE_SPEED_DEFAULT := SourceWeaponDefaults.AIM_CHANGE_SPEED_DEFAULT
const SOURCE_WEAPON_ALWAYS_CONTINUOUS_DEFAULT := SourceWeaponDefaults.ALWAYS_CONTINUOUS_DEFAULT
const SOURCE_WEAPON_SHOOT_STATUS_DURATION_DEFAULT := SourceWeaponDefaults.SHOOT_STATUS_DURATION_DEFAULT
const SOURCE_WEAPON_COOLDOWN_TIME_DEFAULT := SourceWeaponDefaults.COOLDOWN_TIME_DEFAULT
const SOURCE_WEAPON_MIN_WARMUP_DEFAULT := SourceWeaponDefaults.MIN_WARMUP_DEFAULT
const SOURCE_WEAPON_FLIP_SPRITE_DEFAULT := SourceWeaponDefaults.FLIP_SPRITE_DEFAULT
const SOURCE_WEAPON_ALTERNATE_DEFAULT := SourceWeaponDefaults.ALTERNATE_DEFAULT
const SOURCE_WEAPON_OTHER_SIDE_DEFAULT := SourceWeaponDefaults.OTHER_SIDE_DEFAULT
const SOURCE_WEAPON_MIN_SHOOT_VELOCITY_DEFAULT := SourceWeaponDefaults.MIN_SHOOT_VELOCITY_DEFAULT
const SOURCE_WEAPON_ACTIVE_SOUND_VOLUME_DEFAULT := SourceWeaponDefaults.ACTIVE_SOUND_VOLUME_DEFAULT
const SOURCE_WEAPON_SHOOT_SOUND_VOLUME_DEFAULT := SourceWeaponDefaults.SHOOT_SOUND_VOLUME_DEFAULT
const SOURCE_WEAPON_SOUND_PITCH_MIN_DEFAULT := SourceWeaponDefaults.SOUND_PITCH_MIN_DEFAULT
const SOURCE_WEAPON_SOUND_PITCH_MAX_DEFAULT := SourceWeaponDefaults.SOUND_PITCH_MAX_DEFAULT
const SOURCE_WEAPON_PARENTIZE_EFFECTS_DEFAULT := SourceWeaponDefaults.PARENTIZE_EFFECTS_DEFAULT
const SOURCE_WEAPON_INACCURACY_DEFAULT := SourceWeaponDefaults.INACCURACY_DEFAULT
const SOURCE_WEAPON_SHAKE_DEFAULT := SourceWeaponDefaults.SHAKE_DEFAULT
const SOURCE_WEAPON_VELOCITY_RND_DEFAULT := SourceWeaponDefaults.VELOCITY_RND_DEFAULT
const SOURCE_WEAPON_EXTRA_VELOCITY_DEFAULT := SourceWeaponDefaults.EXTRA_VELOCITY_DEFAULT

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

static func update_passive_timers_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, source_delta: float, approach_delta: Callable, lerp_delta: Callable) -> Dictionary:
	var can_shoot := bool(unit_state.get("canShoot", false))
	var reload_multiplier := float(unit_state.get("reloadMultiplier", 1.0))
	var current_reload := float(mount_state.get("reload", 0.0))
	var current_recoil := float(mount_state.get("recoil", 0.0))
	var current_smooth_reload := float(mount_state.get("smoothReload", 0.0))
	var current_charge := float(mount_state.get("charge", 0.0))
	var current_warmup := float(mount_state.get("warmup", 0.0))
	var charging := bool(mount_state.get("charging", false))
	var mount_shoot := bool(mount_state.get("shoot", false))
	var bullet_state = mount_state.get("bullet", null)
	var has_bullet: bool = bullet_state != null and not (bullet_state is Dictionary and bullet_state.is_empty())
	var reload_time := float(weapon_state.get("reload", SOURCE_WEAPON_RELOAD_DEFAULT))
	var raw_recoil_time := float(weapon_state.get("recoilTime", SOURCE_WEAPON_RECOIL_TIME_DEFAULT))
	var recoil_time := reload_time if raw_recoil_time < 0.0 else raw_recoil_time
	var recoils_count := int(weapon_state.get("recoils", SOURCE_WEAPON_RECOILS_DEFAULT))
	var smooth_reload_speed := float(weapon_state.get("smoothReloadSpeed", SOURCE_WEAPON_SMOOTH_RELOAD_SPEED_DEFAULT))
	var first_shot_delay := float(weapon_state.get("firstShotDelay", SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT))
	var continuous := bool(weapon_state.get("continuous", SOURCE_WEAPON_CONTINUOUS_DEFAULT))
	var shoot_warmup_speed := float(weapon_state.get("shootWarmupSpeed", SOURCE_WEAPON_SHOOT_WARMUP_SPEED_DEFAULT))
	var linear_warmup := bool(weapon_state.get("linearWarmup", SOURCE_WEAPON_LINEAR_WARMUP_DEFAULT))
	var new_reload: float = maxf(current_reload - source_delta * reload_multiplier, 0.0)
	var new_recoil: float = approach_delta.call(current_recoil, 0.0, reload_multiplier / recoil_time, source_delta)
	var new_recoils: Array = []
	var mount_recoils = mount_state.get("recoils", [])
	if recoils_count > 0:
		for i in range(recoils_count):
			var recoil_value := 0.0
			if mount_recoils is Array and i < mount_recoils.size():
				recoil_value = float(mount_recoils[i])
			new_recoils.append(approach_delta.call(recoil_value, 0.0, reload_multiplier / recoil_time, source_delta))
	var new_smooth_reload: float = lerp_delta.call(current_smooth_reload, new_reload / reload_time, smooth_reload_speed, source_delta)
	var new_charge := 0.0
	if charging and first_shot_delay > 0.0:
		new_charge = approach_delta.call(current_charge, 1.0, 1.0 / first_shot_delay, source_delta)
	var warmup_target := 1.0 if ((can_shoot and mount_shoot) or (continuous and has_bullet) or charging) else 0.0
	var new_warmup := 0.0
	if linear_warmup:
		new_warmup = approach_delta.call(current_warmup, warmup_target, shoot_warmup_speed, source_delta)
	else:
		new_warmup = lerp_delta.call(current_warmup, warmup_target, shoot_warmup_speed, source_delta)
	return {
		"canShootCall": "boolean can = unit.canShoot();",
		"canShoot": can_shoot,
		"lastReload": current_reload,
		"reload": new_reload,
		"recoil": new_recoil,
		"recoils": new_recoils,
		"smoothReload": new_smooth_reload,
		"charge": new_charge,
		"warmupTarget": warmup_target,
		"warmup": new_warmup,
		"reloadAssignment": "mount.reload = Math.max(mount.reload - Time.delta * unit.reloadMultiplier, 0);",
		"recoilAssignment": "mount.recoil = Mathf.approachDelta(mount.recoil, 0, unit.reloadMultiplier / recoilTime);",
		"smoothReloadAssignment": "mount.smoothReload = Mathf.lerpDelta(mount.smoothReload, mount.reload / reload, smoothReloadSpeed);",
		"chargeAssignment": "mount.charge = mount.charging && shoot.firstShotDelay > 0 ? Mathf.approachDelta(mount.charge, 1, 1 / shoot.firstShotDelay) : 0;",
		"warmupTargetSource": "float warmupTarget = (can && mount.shoot) || (continuous && mount.bullet != null) || mount.charging ? 1f : 0f;",
		"warmupMode": "Mathf.approachDelta" if linear_warmup else "Mathf.lerpDelta",
		"deltaSource": "Time.delta",
		"recoilTimeInitSource": "if(w.recoilTime < 0) w.recoilTime = w.reload;",
	}

static func update_mount_origin_state(unit_state: Dictionary, weapon_state: Dictionary, trns_vec: Callable) -> Dictionary:
	var unit_x := float(unit_state.get("x", 0.0))
	var unit_y := float(unit_state.get("y", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var weapon_x := float(weapon_state.get("x", SOURCE_WEAPON_X_DEFAULT))
	var weapon_y := float(weapon_state.get("y", SOURCE_WEAPON_Y_DEFAULT))
	var angle_degrees := unit_rotation - SOURCE_WEAPON_ROTATION_OFFSET_DEGREES
	var rotated: Dictionary = trns_vec.call(angle_degrees, weapon_x, weapon_y)
	var mount_x := unit_x + float(rotated["x"])
	var mount_y := unit_y + float(rotated["y"])
	return {
		"methodSource": "public void update(Unit unit, WeaponMount mount){",
		"angle": angle_degrees,
		"trnsx": float(rotated["x"]),
		"trnsy": float(rotated["y"]),
		"mountX": mount_x,
		"mountY": mount_y,
		"mountXSource": "mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),",
		"mountYSource": "mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y);",
		"anglesSource": "rv.set(x, y).rotate(angle)",
		"vec2RotateSource": "newX = this.x * cos - this.y * sin; newY = this.x * sin + this.y * cos",
	}

static func update_auto_target_retarget_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, source_delta: float, mount_x: float, mount_y: float, find_target_result_exists: bool) -> Dictionary:
	var controllable := bool(weapon_state.get("controllable", SOURCE_WEAPON_CONTROLLABLE_DEFAULT))
	var auto_target := bool(weapon_state.get("autoTarget", SOURCE_WEAPON_AUTO_TARGET_DEFAULT))
	var current_retarget := float(mount_state.get("retarget", 0.0))
	var target_interval := float(weapon_state.get("targetInterval", SOURCE_WEAPON_TARGET_INTERVAL_DEFAULT))
	var target_switch_interval := float(weapon_state.get("targetSwitchInterval", SOURCE_WEAPON_TARGET_SWITCH_INTERVAL_DEFAULT))
	var current_target_exists := bool(mount_state.get("targetExists", false))
	var gate := (not controllable) and auto_target
	var retarget_after_decrement := current_retarget - source_delta
	var next_retarget := current_retarget
	var target_exists := current_target_exists
	var finder_call: Variant = null
	if gate:
		next_retarget = retarget_after_decrement
	if gate and retarget_after_decrement <= 0.0:
		finder_call = {
			"call": "findTarget(unit, mountX, mountY, bullet.range, bullet.collidesAir, bullet.collidesGround)",
			"mountX": mount_x,
			"mountY": mount_y,
			"range": float(bullet_state.get("range", 0.0)),
			"air": bool(bullet_state.get("collidesAir", true)),
			"ground": bool(bullet_state.get("collidesGround", true)),
		}
		target_exists = find_target_result_exists
		next_retarget = target_switch_interval if target_exists else target_interval
	return {
		"gate": gate,
		"retarget": next_retarget,
		"retargetAfterDecrement": retarget_after_decrement,
		"findTargetCalled": finder_call != null,
		"findTargetCall": finder_call,
		"targetExists": target_exists,
		"gateSource": "if(!controllable && autoTarget){",
		"retargetSource": "if((mount.retarget -= Time.delta) <= 0f){",
		"findTargetSource": "mount.target = findTarget(unit, mountX, mountY, bullet.range, bullet.collidesAir, bullet.collidesGround);",
		"intervalSource": "mount.retarget = mount.target == null ? targetInterval : targetSwitchInterval;",
	}

static func update_auto_target_invalidation_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, mount_x: float, mount_y: float, check_target_result: bool) -> Dictionary:
	var controllable := bool(weapon_state.get("controllable", SOURCE_WEAPON_CONTROLLABLE_DEFAULT))
	var auto_target := bool(weapon_state.get("autoTarget", SOURCE_WEAPON_AUTO_TARGET_DEFAULT))
	var target_exists := bool(mount_state.get("targetExists", false))
	var gate := (not controllable) and auto_target
	var check_called := gate and target_exists
	var check_call: Variant = null
	if check_called:
		check_call = {
			"call": "checkTarget(unit, mount.target, mountX, mountY, bullet.range)",
			"mountX": mount_x,
			"mountY": mount_y,
			"range": float(bullet_state.get("range", 0.0)),
		"shootY": float(weapon_state.get("shootY", SOURCE_WEAPON_SHOOT_Y_DEFAULT)),
		"rangeWithShootY": float(bullet_state.get("range", 0.0)) + absf(float(weapon_state.get("shootY", SOURCE_WEAPON_SHOOT_Y_DEFAULT))),
		}
	if check_called and check_target_result:
		target_exists = false
	return {
		"gate": gate,
		"checkTargetCalled": check_called,
		"checkTargetCall": check_call,
		"checkTargetResult": check_target_result if check_called else false,
		"targetExists": target_exists,
		"targetCleared": check_called and check_target_result,
		"gateSource": "if(!controllable && autoTarget)",
		"guardSource": "if(mount.target != null && checkTarget(unit, mount.target, mountX, mountY, bullet.range)){",
		"clearSource": "mount.target = null;",
		"checkTargetSource": "return Units.invalidateTarget(target, unit.team, x, y, range + Math.abs(shootY));",
		"invalidateTargetSource": "target == null || out of range || same team || invalid health || unit not targetable",
	}

static func update_auto_target_shoot_aim_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, can_shoot: bool, mount_x: float, mount_y: float, target_within_result: bool, predicted_aim: Dictionary) -> Dictionary:
	var target_exists := bool(mount_state.get("targetExists", false))
	var aim_x := float(mount_state.get("aimX", 0.0))
	var aim_y := float(mount_state.get("aimY", 0.0))
	var bullet_range := float(bullet_state.get("range", 0.0))
	var shoot_y := float(weapon_state.get("shootY", SOURCE_WEAPON_SHOOT_Y_DEFAULT))
	var target_hit_size := float(mount_state.get("targetHitSize", 0.0)) if bool(mount_state.get("targetSized", false)) else 0.0
	var predict_target := bool(weapon_state.get("predictTarget", SOURCE_WEAPON_PREDICT_TARGET_DEFAULT))
	var within_range := bullet_range + absf(shoot_y) + target_hit_size / 2.0
	var shoot := false
	if target_exists:
		shoot = target_within_result and can_shoot
		if predict_target:
			aim_x = float(predicted_aim.get("x", aim_x))
			aim_y = float(predicted_aim.get("y", aim_y))
		else:
			aim_x = float(mount_state.get("targetX", aim_x))
			aim_y = float(mount_state.get("targetY", aim_y))
	var next_rotate := shoot
	return {
		"targetExists": target_exists,
		"withinRange": within_range,
		"targetWithin": target_within_result if target_exists else false,
		"canShoot": can_shoot,
		"shoot": shoot,
		"rotate": next_rotate,
		"aimX": aim_x,
		"aimY": aim_y,
		"predictTarget": predict_target,
		"mountX": mount_x,
		"mountY": mount_y,
		"shootInitSource": "boolean shoot = false;",
		"targetGuardSource": "if(mount.target != null){",
		"withinSource": "mount.target.within(mountX, mountY, bullet.range + Math.abs(shootY) + (mount.target instanceof Sized s ? s.hitSize()/2f : 0f))",
		"shootSource": "shoot = mount.target.within(mountX, mountY, bullet.range + Math.abs(shootY) + (mount.target instanceof Sized s ? s.hitSize()/2f : 0f)) && can;",
		"predictGuardSource": "if(predictTarget){",
		"predictSource": "Vec2 to = Predict.intercept(unit, mount.target, bullet);",
		"predictAimXSource": "mount.aimX = to.x;",
		"predictAimYSource": "mount.aimY = to.y;",
		"directAimXSource": "mount.aimX = mount.target.x();",
		"directAimYSource": "mount.aimY = mount.target.y();",
		"shootRotateSource": "mount.shoot = mount.rotate = shoot;",
		"logicNoteSource": "//note that shooting state is not affected, as these cannot be controlled",
		"predictInterceptSource": "public static Vec2 intercept(Position src, Position dst, BulletType bullet){",
		"predictInterceptReturnSource": "return intercept(src, dst, 0f, 0f, bullet.keepVelocity, bullet.speed);",
	}

static func update_rotate_toward_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, can_shoot: bool, source_delta: float, trns_vec: Callable, angles_angle: Callable, move_toward_angle: Callable, angle_dist: Callable) -> Dictionary:
	var mount_rotate := bool(mount_state.get("rotate", false))
	var mount_shoot := bool(mount_state.get("shoot", false))
	var current_rotation := float(mount_state.get("rotation", 0.0))
	var current_target_rotation := float(mount_state.get("targetRotation", 0.0))
	var aim_x := float(mount_state.get("aimX", 0.0))
	var aim_y := float(mount_state.get("aimY", 0.0))
	var weapon_x := float(weapon_state.get("x", SOURCE_WEAPON_X_DEFAULT))
	var weapon_y := float(weapon_state.get("y", SOURCE_WEAPON_Y_DEFAULT))
	var rotate_speed := float(weapon_state.get("rotateSpeed", SOURCE_WEAPON_ROTATE_SPEED_DEFAULT))
	var rotation_limit := float(weapon_state.get("rotationLimit", SOURCE_WEAPON_ROTATION_LIMIT_DEFAULT))
	var base_rotation := float(weapon_state.get("baseRotation", SOURCE_WEAPON_BASE_ROTATION_DEFAULT))
	var unit_x := float(unit_state.get("x", 0.0))
	var unit_y := float(unit_state.get("y", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var gate := bool(weapon_state.get("rotate", SOURCE_WEAPON_ROTATE_DEFAULT)) and (mount_rotate or mount_shoot) and can_shoot
	var non_rotate_branch := not bool(weapon_state.get("rotate", SOURCE_WEAPON_ROTATE_DEFAULT))
	var axis_angle := unit_rotation - SOURCE_WEAPON_ROTATION_OFFSET_DEGREES
	var axis_vec: Dictionary = trns_vec.call(axis_angle, weapon_x, weapon_y)
	var axis_x := unit_x + float(axis_vec["x"])
	var axis_y := unit_y + float(axis_vec["y"])
	var target_rotation := current_target_rotation
	var next_rotation := current_rotation
	var limit_dst := 0.0
	if gate:
		target_rotation = angles_angle.call(axis_x, axis_y, aim_x, aim_y) - unit_rotation
		next_rotation = move_toward_angle.call(current_rotation, target_rotation, rotate_speed * source_delta)
	if gate and rotation_limit < 360.0:
		limit_dst = angle_dist.call(next_rotation, base_rotation)
		if limit_dst > rotation_limit / 2.0:
			next_rotation = move_toward_angle.call(next_rotation, base_rotation, limit_dst - rotation_limit / 2.0)
	elif non_rotate_branch:
		next_rotation = base_rotation
		target_rotation = angles_angle.call(unit_x, unit_y, aim_x, aim_y)
	return {
		"gate": gate,
		"axisAngle": axis_angle,
		"axisX": axis_x,
		"axisY": axis_y,
		"targetRotation": target_rotation,
		"rotation": next_rotation,
		"rotationLimit": rotation_limit,
		"baseRotation": base_rotation,
		"limitDistance": limit_dst,
		"rotationLimitApplied": gate and rotation_limit < 360.0 and limit_dst > rotation_limit / 2.0,
		"nonRotateApplied": non_rotate_branch,
		"canShoot": can_shoot,
		"mountRotate": mount_rotate,
		"mountShoot": mount_shoot,
		"gateSource": "if(rotate && (mount.rotate || mount.shoot) && can){",
		"axisXSource": "float axisX = unit.x + Angles.trnsx(unit.rotation - 90,  x, y),",
		"axisYSource": "axisY = unit.y + Angles.trnsy(unit.rotation - 90,  x, y);",
		"targetRotationSource": "mount.targetRotation = Angles.angle(axisX, axisY, mount.aimX, mount.aimY) - unit.rotation;",
		"rotationSource": "mount.rotation = Angles.moveToward(mount.rotation, mount.targetRotation, rotateSpeed * Time.delta);",
		"rotationLimitSource": "if(rotationLimit < 360){",
		"limitDistanceSource": "float dst = Angles.angleDist(mount.rotation, baseRotation);",
		"limitMoveSource": "mount.rotation = Angles.moveToward(mount.rotation, baseRotation, dst - rotationLimit/2f);",
		"nonRotateSource": "else if(!rotate){",
		"baseRotationSource": "mount.rotation = baseRotation;",
		"angleToSource": "mount.targetRotation = unit.angleTo(mount.aimX, mount.aimY);",
	}

static func update_bullet_origin_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, mount_x: float, mount_y: float, trns_vec: Callable, angles_angle: Callable) -> Dictionary:
	var rotate_weapon := bool(weapon_state.get("rotate", SOURCE_WEAPON_ROTATE_DEFAULT))
	var mount_rotation := float(mount_state.get("rotation", 0.0))
	var aim_x := float(mount_state.get("aimX", 0.0))
	var aim_y := float(mount_state.get("aimY", 0.0))
	var base_rotation := float(weapon_state.get("baseRotation", SOURCE_WEAPON_BASE_ROTATION_DEFAULT))
	var shoot_x := float(weapon_state.get("shootX", SOURCE_WEAPON_SHOOT_X_DEFAULT))
	var shoot_y := float(weapon_state.get("shootY", SOURCE_WEAPON_SHOOT_Y_DEFAULT))
	var unit_x := float(unit_state.get("x", 0.0))
	var unit_y := float(unit_state.get("y", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var weapon_rotation := unit_rotation - SOURCE_WEAPON_ROTATION_OFFSET_DEGREES + (mount_rotation if rotate_weapon else base_rotation)
	var bullet_vec: Dictionary = trns_vec.call(weapon_rotation, shoot_x, shoot_y)
	var bullet_x := mount_x + float(bullet_vec["x"])
	var bullet_y := mount_y + float(bullet_vec["y"])
	var shoot_angle := unit_rotation + mount_rotation
	if not rotate_weapon:
		shoot_angle = angles_angle.call(bullet_x, bullet_y, aim_x, aim_y) + (unit_rotation - angles_angle.call(unit_x, unit_y, aim_x, aim_y)) + base_rotation
	return {
		"rotate": rotate_weapon,
		"weaponRotation": weapon_rotation,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"shootAngle": shoot_angle,
		"mountX": mount_x,
		"mountY": mount_y,
		"shootX": shoot_x,
		"shootY": shoot_y,
		"baseRotation": base_rotation,
		"weaponRotationSource": "weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),",
		"bulletXSource": "bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY),",
		"bulletYSource": "bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY),",
		"shootAngleSource": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY);",
		"bulletRotationMethodSource": "protected float bulletRotation(Unit unit, WeaponMount mount, float bulletX, float bulletY){",
		"bulletRotationSource": "return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation;",
		"anglesTrnsxSource": "public static float trnsx(float angle, float x, float y){",
		"anglesTrnsySource": "public static float trnsy(float angle, float x, float y){",
		"anglesAngleSource": "public static float angle(float x, float y, float x2, float y2){",
		"positionAngleToSource": "default float angleTo(float x, float y){",
	}

static func update_always_shooting_state(mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	var shoot := bool(mount_state.get("shoot", false))
	var always_shooting := bool(weapon_state.get("alwaysShooting", SOURCE_WEAPON_ALWAYS_SHOOTING_DEFAULT))
	if always_shooting:
		shoot = true
	return {
		"shoot": shoot,
		"alwaysShooting": always_shooting,
		"alwaysShootingSource": "if(alwaysShooting) mount.shoot = true;",
		"continuousReservedSource": "if(continuous && mount.bullet != null){",
	}

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
	var next_bullet_rotation := weapon_rotation + 90.0
	var next_bullet_x := float(bullet_state.get("x", bullet_x))
	var next_bullet_y := float(bullet_state.get("y", bullet_y))
	var next_vel_x := float(unit_state.get("velX", 0.0))
	var next_vel_y := float(unit_state.get("velY", 0.0))
	var recoil_vec: Dictionary = trns_vec.call(next_bullet_rotation + 180.0, bullet_recoil * source_delta, 0.0)
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

static func update_alternating_side_flip_state(mount_state: Dictionary, weapon_state: Dictionary, unit_mount_states: Array) -> Dictionary:
	var current_side := bool(mount_state.get("side", false))
	var was_flipped := current_side
	var flip_sprite := bool(weapon_state.get("flipSprite", SOURCE_WEAPON_FLIP_SPRITE_DEFAULT))
	var alternate := bool(weapon_state.get("alternate", SOURCE_WEAPON_ALTERNATE_DEFAULT))
	var other_side := int(weapon_state.get("otherSide", SOURCE_WEAPON_OTHER_SIDE_DEFAULT))
	var current_reload := float(mount_state.get("reload", 0.0))
	var last_reload := float(mount_state.get("lastReload", current_reload))
	var weapon_reload := float(weapon_state.get("reload", SOURCE_WEAPON_RELOAD_DEFAULT))
	var crosses_half_reload := current_reload <= weapon_reload / 2.0 and last_reload > weapon_reload / 2.0
	var flip_gate := other_side >= 0 and alternate and current_side == flip_sprite and other_side < unit_mount_states.size() and crosses_half_reload
	var next_unit_mount_states: Array = []
	for mount_item in unit_mount_states:
		var mount_copy: Dictionary = {}
		if typeof(mount_item) == TYPE_DICTIONARY:
			mount_copy = (mount_item as Dictionary).duplicate()
		next_unit_mount_states.append(mount_copy)
	var next_mount_side := current_side
	if flip_gate:
		next_unit_mount_states[other_side]["side"] = not bool(next_unit_mount_states[other_side].get("side", false))
		next_mount_side = not current_side
	return {
		"wasFlipped": was_flipped,
		"flipGate": flip_gate,
		"crossesHalfReload": crosses_half_reload,
		"mountSide": next_mount_side,
		"otherSide": other_side,
		"unitMounts": next_unit_mount_states,
		"guardSource": "if(otherSide >= 0 && alternate && mount.side == flipSprite && otherSide < unit.mounts.length && mount.reload <= reload / 2f && lastReload > reload / 2f){",
		"otherSideFlipSource": "unit.mounts[otherSide].side = !unit.mounts[otherSide].side;",
		"mountSideFlipSource": "mount.side = !mount.side;",
		"shootGateSource": "(!alternate || wasFlipped == flipSprite) &&",
	}

static func update_active_sound_loop_state(mount_state: Dictionary, weapon_state: Dictionary, runtime_state: Dictionary, can_shoot: bool, unit_id: int) -> Dictionary:
	var headless := bool(runtime_state.get("headless", false))
	var active_sound := str(weapon_state.get("activeSound", "none"))
	var mount_shoot := bool(mount_state.get("shoot", false))
	var mount_warmup := float(mount_state.get("warmup", 0.0))
	var min_warmup := float(weapon_state.get("minWarmup", SOURCE_WEAPON_MIN_WARMUP_DEFAULT))
	var active_sound_volume := float(weapon_state.get("activeSoundVolume", SOURCE_WEAPON_ACTIVE_SOUND_VOLUME_DEFAULT))
	var active_sound_gate := not headless and active_sound != "none" and mount_shoot and can_shoot and mount_warmup >= min_warmup
	var sound_loop_call = null
	if active_sound_gate:
		sound_loop_call = {
			"sound": active_sound,
			"unit": unit_id,
			"volume": active_sound_volume,
		}
	return {
		"activeSoundGate": active_sound_gate,
		"headless": headless,
		"activeSound": active_sound,
		"mountShoot": mount_shoot,
		"canShoot": can_shoot,
		"mountWarmup": mount_warmup,
		"minWarmup": min_warmup,
		"activeSoundVolume": active_sound_volume,
		"soundLoopCall": sound_loop_call,
		"guardSource": "if(!headless && activeSound != Sounds.none && mount.shoot && can && mount.warmup >= minWarmup){",
		"loopSource": "Vars.control.sound.loop(activeSound, unit, activeSoundVolume);",
		"soundControlGuardSource": "if(Vars.headless || sound == Sounds.none || volume <= 0.00001f) return;",
		"velLenReservedSource": "float velLen = unit.isRemote() ? unit.vel.len() : unit.deltaLen() / Time.delta;",
	}

static func update_velocity_length_state(unit_state: Dictionary, source_delta: float) -> Dictionary:
	var is_remote := bool(unit_state.get("isRemote", false))
	var vel_x := float(unit_state.get("velX", 0.0))
	var vel_y := float(unit_state.get("velY", 0.0))
	var delta_x := float(unit_state.get("deltaX", 0.0))
	var delta_y := float(unit_state.get("deltaY", 0.0))
	var remote_vel_len := sqrt(vel_x * vel_x + vel_y * vel_y)
	var local_delta_len := sqrt(delta_x * delta_x + delta_y * delta_y)
	var vel_len := remote_vel_len if is_remote else local_delta_len / source_delta
	return {
		"velLen": vel_len,
		"isRemote": is_remote,
		"remoteVelLen": remote_vel_len,
		"localDeltaLen": local_delta_len,
		"sourceDelta": source_delta,
		"branch": "unit.vel.len" if is_remote else "unit.deltaLen / Time.delta",
		"velLenSource": "float velLen = unit.isRemote() ? unit.vel.len() : unit.deltaLen() / Time.delta;",
		"isRemoteSource": "boolean isRemote(){\n        return ((Object)this) instanceof Unitc u && u.isPlayer() && !isLocal();\n    }",
		"deltaLenSource": "float deltaLen(){\n        return Mathf.len(deltaX, deltaY);\n    }",
		"vec2LenSource": "public float len(){\n        return (float)Math.sqrt(x * x + y * y);\n    }",
		"timeDeltaSource": "public static float delta = 1f;",
		"shootGateSource": "velLen >= minShootVelocity && //check velocity requirements",
	}

static func update_shoot_gate_prefix_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, can_shoot: bool, was_flipped: bool, vel_len: float) -> Dictionary:
	var mount_shoot := bool(mount_state.get("shoot", false))
	var mount_warmup := float(mount_state.get("warmup", 0.0))
	var total_shots := int(mount_state.get("totalShots", 0))
	var alternate := bool(weapon_state.get("alternate", SOURCE_WEAPON_ALTERNATE_DEFAULT))
	var flip_sprite := bool(weapon_state.get("flipSprite", SOURCE_WEAPON_FLIP_SPRITE_DEFAULT))
	var min_warmup := float(weapon_state.get("minWarmup", SOURCE_WEAPON_MIN_WARMUP_DEFAULT))
	var min_shoot_velocity := float(weapon_state.get("minShootVelocity", SOURCE_WEAPON_MIN_SHOOT_VELOCITY_DEFAULT))
	var bullet_kill_shooter := bool(bullet_state.get("killShooter", false))
	var kill_shooter_once_blocked := bullet_kill_shooter and total_shots > 0
	var alternate_gate := (not alternate) or was_flipped == flip_sprite
	var warmup_gate := mount_warmup >= min_warmup
	var velocity_gate := vel_len >= min_shoot_velocity
	var shoot_gate_prefix := mount_shoot and can_shoot and not kill_shooter_once_blocked and alternate_gate and warmup_gate and velocity_gate
	return {
		"shootGatePrefix": shoot_gate_prefix,
		"mountShoot": mount_shoot,
		"canShoot": can_shoot,
		"killShooterOnceBlocked": kill_shooter_once_blocked,
		"alternateGate": alternate_gate,
		"warmupGate": warmup_gate,
		"velocityGate": velocity_gate,
		"totalShots": total_shots,
		"velLen": vel_len,
		"minShootVelocity": min_shoot_velocity,
		"shootCommentSource": "//shoot if applicable",
		"mountShootGateSource": "if(mount.shoot && //must be shooting",
		"canGateSource": "can && //must be able to shoot",
		"killShooterGateSource": "!(bullet.killShooter && mount.totalShots > 0) && //if the bullet kills the shooter, you should only ever be able to shoot once",
		"alternateGateSource": "(!alternate || wasFlipped == flipSprite) &&",
		"warmupGateSource": "mount.warmup >= minWarmup && //must be warmed up",
		"velocityGateSource": "velLen >= minShootVelocity && //check velocity requirements",
		"reloadGateReservedSource": "(mount.reload <= 0.0001f || (alwaysContinuous && mount.bullet == null)) && //reload has to be 0, or it has to be an always-continuous weapon",
	}

static func update_reload_gate_state(mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	var mount_reload := float(mount_state.get("reload", 0.0))
	var always_continuous := bool(weapon_state.get("alwaysContinuous", SOURCE_WEAPON_ALWAYS_CONTINUOUS_DEFAULT))
	var mount_bullet_null := not bool(mount_state.get("hasBullet", false))
	var reload_ready := mount_reload <= 0.0001
	var always_continuous_ready := always_continuous and mount_bullet_null
	var reload_gate := reload_ready or (always_continuous and mount_bullet_null)
	return {
		"reloadGate": reload_gate,
		"reloadReady": reload_ready,
		"alwaysContinuousReady": always_continuous_ready,
		"mountReload": mount_reload,
		"alwaysContinuous": always_continuous,
		"mountBulletNull": mount_bullet_null,
		"reloadGateSource": "(mount.reload <= 0.0001f || (alwaysContinuous && mount.bullet == null)) && //reload has to be 0, or it has to be an always-continuous weapon",
		"coneGateReservedSource": "(alwaysShooting || Angles.within(rotate ? mount.rotation : unit.rotation + baseRotation, mount.targetRotation, shootCone)) //has to be within the cone",
		"weaponAlwaysContinuousSource": "public boolean alwaysContinuous;",
		"mountReloadSource": "public float reload;",
		"mountBulletSource": "public @Nullable Bullet bullet;",
	}

static func update_cone_gate_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, angle_dist: Callable) -> Dictionary:
	var always_shooting := bool(weapon_state.get("alwaysShooting", SOURCE_WEAPON_ALWAYS_SHOOTING_DEFAULT))
	var weapon_rotate := bool(weapon_state.get("rotate", SOURCE_WEAPON_ROTATE_DEFAULT))
	var base_rotation := float(weapon_state.get("baseRotation", SOURCE_WEAPON_BASE_ROTATION_DEFAULT))
	var shoot_cone := float(weapon_state.get("shootCone", SOURCE_WEAPON_SHOOT_CONE_DEFAULT))
	var mount_rotation := float(mount_state.get("rotation", 0.0))
	var target_rotation := float(mount_state.get("targetRotation", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var current_rotation := mount_rotation if weapon_rotate else unit_rotation + base_rotation
	var angle_distance: float = float(angle_dist.call(current_rotation, target_rotation))
	var within_cone := angle_distance <= shoot_cone
	var cone_gate := always_shooting or within_cone
	return {
		"coneGate": cone_gate,
		"alwaysShooting": always_shooting,
		"rotate": weapon_rotate,
		"currentRotation": current_rotation,
		"targetRotation": target_rotation,
		"shootCone": shoot_cone,
		"angleDistance": angle_distance,
		"withinCone": within_cone,
		"coneGateSource": "(alwaysShooting || Angles.within(rotate ? mount.rotation : unit.rotation + baseRotation, mount.targetRotation, shootCone))",
		"anglesWithinSource": "return angleDist(a, b) <= margin",
		"anglesAngleDistSource": "return Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a)",
		"shootCallReservedSource": "shoot(unit, mount, bulletX, bulletY, shootAngle)",
	}

static func update_shoot_call_reload_state(mount_state: Dictionary, weapon_state: Dictionary, unit_id: int, bullet_x: float, bullet_y: float, shoot_angle: float, shoot_gate: bool) -> Dictionary:
	var current_reload := float(mount_state.get("reload", 0.0))
	var weapon_reload := float(weapon_state.get("reload", SOURCE_WEAPON_RELOAD_DEFAULT))
	var next_reload := weapon_reload if shoot_gate else current_reload
	var shoot_call = null
	if shoot_gate:
		shoot_call = {
			"unit": unit_id,
			"x": bullet_x,
			"y": bullet_y,
			"rotation": shoot_angle,
		}
	return {
		"shootGate": shoot_gate,
		"mountReload": next_reload,
		"previousReload": current_reload,
		"weaponReload": weapon_reload,
		"shootCall": shoot_call,
		"shootCallSource": "shoot(unit, mount, bulletX, bulletY, shootAngle);",
		"reloadResetSource": "mount.reload = reload;",
		"shootMethodReservedSource": "protected void shoot(Unit unit, WeaponMount mount, float shootX, float shootY, float rotation){",
		"shootStatusApplyReservedSource": "unit.apply(shootStatus, shootStatusDuration);",
	}

static func shoot_charge_start_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary, shoot_x: float, shoot_y: float, charge_rotation: float, status_apply_result: Callable) -> Dictionary:
	var shoot_status := "" if weapon_state.get("shootStatus", "none") == null else str(weapon_state.get("shootStatus", "none"))
	var shoot_status_duration := float(weapon_state.get("shootStatusDuration", SOURCE_WEAPON_SHOOT_STATUS_DURATION_DEFAULT))
	var status_immune := bool(unit_state.get("statusImmune", false))
	var status_result: Dictionary = status_apply_result.call(shoot_status, shoot_status_duration, status_immune)
	var first_shot_delay := float(weapon_state.get("firstShotDelay", SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT))
	var charge_gate := first_shot_delay > 0.0
	var mount_charging := bool(mount_state.get("charging", false))
	var charge_sound := str(weapon_state.get("chargeSound", "none"))
	var sound_pitch_min := float(weapon_state.get("soundPitchMin", SOURCE_WEAPON_SOUND_PITCH_MIN_DEFAULT))
	var sound_pitch_max := float(weapon_state.get("soundPitchMax", SOURCE_WEAPON_SOUND_PITCH_MAX_DEFAULT))
	var charge_sound_call: Variant = null
	var keep_velocity := bool(bullet_state.get("keepVelocity", true))
	var parentize_effects := bool(weapon_state.get("parentizeEffects", SOURCE_WEAPON_PARENTIZE_EFFECTS_DEFAULT))
	var unit_id := int(unit_state.get("id", 0))
	var charge_effect_parent: Variant = null
	if keep_velocity or parentize_effects:
		charge_effect_parent = unit_id
	var charge_effect_call: Variant = null
	if charge_gate:
		mount_charging = true
		charge_sound_call = {
			"sound": charge_sound,
			"x": shoot_x,
			"y": shoot_y,
			"pitchMin": sound_pitch_min,
			"pitchMax": sound_pitch_max,
		}
		charge_effect_call = {
			"effect": str(bullet_state.get("chargeEffect", "none")),
			"x": shoot_x,
			"y": shoot_y,
			"rotation": charge_rotation,
			"effectParent": charge_effect_parent,
		}
	return {
		"statusApplied": status_result.get("statusApplied", false),
		"statusApplication": status_result.get("statusApplication", {}),
		"chargeGate": charge_gate,
		"mountCharging": mount_charging,
		"chargeSoundCall": charge_sound_call,
		"chargeEffectCall": charge_effect_call,
		"firstShotDelay": first_shot_delay,
		"keepVelocity": keep_velocity,
		"parentizeEffects": parentize_effects,
		"statusApplySource": "unit.apply(shootStatus, shootStatusDuration);",
		"statusApplyGuardSource": status_result.get("statusApplyGuardSource", ""),
		"chargeGateSource": "if(shoot.firstShotDelay > 0){",
		"mountChargingSource": "mount.charging = true;",
		"chargeSoundSource": "chargeSound.at(shootX, shootY, Mathf.random(soundPitchMin, soundPitchMax));",
		"chargeEffectSource": "bullet.chargeEffect.at(shootX, shootY, rotation, bullet.keepVelocity || parentizeEffects ? unit : null);",
		"shootLoopReservedSource": "shoot.shoot(mount.barrelCounter, (xOffset, yOffset, angle, delay, mover) -> {",
	}

static func shoot_pattern_default_events(shoot_state: Dictionary) -> Array:
	var shots := int(shoot_state.get("shots", SOURCE_SHOOT_PATTERN_SHOTS_DEFAULT))
	var first_shot_delay := float(shoot_state.get("firstShotDelay", SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT))
	var shot_delay := float(shoot_state.get("shotDelay", SOURCE_SHOOT_PATTERN_SHOT_DELAY_DEFAULT))
	var events := []
	for i in shots:
		events.append({
			"xOffset": 0.0,
			"yOffset": 0.0,
			"angleOffset": 0.0,
			"delay": first_shot_delay + shot_delay * float(i),
			"mover": null,
		})
	return events

static func generated_shoot_pattern_default_events_bridge_state(shots: int, first_shot_delay: float, shot_delay: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/pattern/ShootPattern.gd", "java_method_shoot_1", [shots, first_shot_delay, shot_delay], null)
	var canonical = shoot_pattern_default_events({
		"shots": shots,
		"firstShotDelay": first_shot_delay,
		"shotDelay": shot_delay,
	})
	return {
		"source_owner": "PortGame.source_shoot_pattern_default_events",
		"generated_owner": "ShootPattern.java_method_shoot_1",
		"result": result,
		"canonical": canonical,
		"matches": result.get("events", []) == canonical,
	}

static func generated_shoot_pattern_default_events_default_bridge_state() -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/pattern/ShootPattern.gd", "java_method_shoot_1", [], null)
	var canonical = shoot_pattern_default_events({})
	return {
		"source_owner": "PortGame.source_shoot_pattern_default_events",
		"generated_owner": "ShootPattern.java_method_shoot_1",
		"result": result,
		"canonical": canonical,
		"defaulted_args": ["shots", "firstShotDelay", "shotDelay"],
		"matches": result.get("events", []) == canonical,
	}

static func generated_shoot_pattern_compat_dispatch_bridge_state(total_shots: int, shots: int, first_shot_delay: float, shot_delay: float, barrel_incrementer_present: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/pattern/ShootPattern.gd", "java_method_shoot_0", [total_shots, shots, first_shot_delay, shot_delay, barrel_incrementer_present], null)
	var canonical = shoot_pattern_default_events({
		"shots": shots,
		"firstShotDelay": first_shot_delay,
		"shotDelay": shot_delay,
	})
	return {
		"source_owner": "PortGame.source_shoot_pattern_default_events",
		"generated_owner": "ShootPattern.java_method_shoot_0",
		"result": result,
		"canonical": canonical,
		"matches": result.get("events", []) == canonical and int(result.get("barrelIncrementerCalls", -1)) == 0,
	}

static func generated_shoot_pattern_flip_bridge_state() -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/pattern/ShootPattern.gd", "java_method_flip_2", [], null)
	var canonical = {"source_owner": "ShootPattern.flip", "generated_owner": "ShootPattern.java_method_flip_2", "source": "core/src/mindustry/entities/pattern/ShootPattern.java", "method": "public void flip(){", "comment": "/** Subclasses should override this to flip its sides. */", "no_op": true, "mutated_fields": []}
	return {
		"source_owner": "ShootPattern.flip",
		"generated_owner": "ShootPattern.java_method_flip_2",
		"result": result,
		"canonical": canonical,
		"matches": bool(result.get("no_op", false)) and result.get("mutated_fields", []) == [],
	}

static func generated_shoot_pattern_copy_bridge_state(shots: int, first_shot_delay: float, shot_delay: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/pattern/ShootPattern.gd", "java_method_copy_3", [shots, first_shot_delay, shot_delay], null)
	var expected_copy := {"shots": shots, "firstShotDelay": first_shot_delay, "shotDelay": shot_delay}
	var canonical := expected_copy
	return {
		"source_owner": "ShootPattern.copy",
		"generated_owner": "ShootPattern.java_method_copy_3",
		"result": result,
		"expected_copy": expected_copy,
		"canonical": canonical,
		"matches": result.get("copy", {}) == expected_copy and bool(result.get("same_reference", true)) == false,
	}

static func shoot_default_pattern_dispatch_state(mount_state: Dictionary, shoot_state: Dictionary) -> Dictionary:
	var total_shots := int(mount_state.get("totalShots", 0))
	var barrel_counter := int(mount_state.get("barrelCounter", 0))
	var pattern_events := shoot_pattern_default_events(shoot_state)
	var bullet_calls := []
	var scheduled_calls := []
	for event in pattern_events:
		total_shots += 1
		var event_barrel := barrel_counter
		var event_delay := float(event.get("delay", 0.0))
		var bullet_call := {
			"xOffset": float(event.get("xOffset", 0.0)),
			"yOffset": float(event.get("yOffset", 0.0)),
			"angleOffset": float(event.get("angleOffset", 0.0)),
			"mover": event.get("mover", null),
			"barrel": event_barrel,
		}
		if event_delay > 0.0:
			scheduled_calls.append({
				"delay": event_delay,
				"setBarrelCounter": event_barrel,
				"bulletCall": bullet_call,
				"restoreBarrelCounter": barrel_counter,
			})
		else:
			bullet_calls.append(bullet_call)
	return {
		"patternEvents": pattern_events,
		"bulletCalls": bullet_calls,
		"scheduledCalls": scheduled_calls,
		"totalShots": total_shots,
		"barrelCounter": barrel_counter,
		"barrelIncrementerCalls": 0,
		"shootDispatchSource": "shoot.shoot(mount.barrelCounter, (xOffset, yOffset, angle, delay, mover) -> {",
		"patternCompatSource": "shoot(totalShots, handler)",
		"patternHandlerSource": "handler.shoot(0, 0, 0, firstShotDelay + shotDelay * i);",
		"totalShotsSource": "mount.totalShots ++;",
		"barrelCaptureSource": "int barrel = mount.barrelCounter;",
		"timeRunSource": "Time.run(delay, () -> {",
		"restoreBarrelSource": "mount.barrelCounter = prev;",
		"directBulletSource": "bullet(unit, mount, xOffset, yOffset, angle, mover);",
		"barrelIncrementerSource": "}, () -> mount.barrelCounter++);",
	}

static func bullet_initial_guard_state(unit_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	var unit_added := bool(unit_state.get("isAdded", false))
	var bullet_continues := unit_added
	var mount_charging := bool(mount_state.get("charging", false))
	if bullet_continues:
		mount_charging = false
	return {
		"unitAdded": unit_added,
		"bulletContinues": bullet_continues,
		"mountCharging": mount_charging,
		"unitAddedGuardSource": "if(!unit.isAdded()) return",
		"chargingResetSource": "mount.charging = false",
		"geometryReservedSource": "float xSpread = Mathf.range(xRand)",
	}

static func bullet_geometry_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, trns_vec: Callable) -> Dictionary:
	var guard_state := bullet_initial_guard_state(unit_state, mount_state)
	var bullet_continues := bool(guard_state.get("bulletContinues", false))
	if not bullet_continues:
		return {
			"bulletContinues": false,
			"mountCharging": guard_state.get("mountCharging", false),
			"xSpreadSource": "xSpread = Mathf.range(xRand)",
			"ySpreadSource": "ySpread = Mathf.range(yRand)",
			"shootAngleReservedSource": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY) + angleOffset",
		}
	var unit_x := float(unit_state.get("x", 0.0))
	var unit_y := float(unit_state.get("y", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var weapon_x := float(weapon_state.get("x", SOURCE_WEAPON_X_DEFAULT))
	var weapon_y := float(weapon_state.get("y", SOURCE_WEAPON_Y_DEFAULT))
	var weapon_rotate := bool(weapon_state.get("rotate", SOURCE_WEAPON_ROTATE_DEFAULT))
	var mount_rotation := float(mount_state.get("rotation", 0.0))
	var base_rotation := float(weapon_state.get("baseRotation", SOURCE_WEAPON_BASE_ROTATION_DEFAULT))
	var shoot_x := float(weapon_state.get("shootX", SOURCE_WEAPON_SHOOT_X_DEFAULT))
	var shoot_y := float(weapon_state.get("shootY", SOURCE_WEAPON_SHOOT_Y_DEFAULT))
	var weapon_rotation := unit_rotation - SOURCE_WEAPON_ROTATION_OFFSET_DEGREES + (mount_rotation if weapon_rotate else base_rotation)
	var mount_vec: Dictionary = trns_vec.call(unit_rotation - SOURCE_WEAPON_ROTATION_OFFSET_DEGREES, weapon_x, weapon_y)
	var mount_x := unit_x + float(mount_vec["x"])
	var mount_y := unit_y + float(mount_vec["y"])
	var bullet_offset_x := shoot_x + x_offset + x_spread
	var bullet_offset_y := shoot_y + y_offset + y_spread
	var bullet_vec: Dictionary = trns_vec.call(weapon_rotation, bullet_offset_x, bullet_offset_y)
	var bullet_x := mount_x + float(bullet_vec["x"])
	var bullet_y := mount_y + float(bullet_vec["y"])
	return {
		"bulletContinues": true,
		"mountCharging": guard_state.get("mountCharging", false),
		"xSpread": x_spread,
		"ySpread": y_spread,
		"weaponRotation": weapon_rotation,
		"mountX": mount_x,
		"mountY": mount_y,
		"bulletOffsetX": bullet_offset_x,
		"bulletOffsetY": bullet_offset_y,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"xSpreadSource": "xSpread = Mathf.range(xRand)",
		"ySpreadSource": "ySpread = Mathf.range(yRand)",
		"mathfRangeSource": "return random(-range, range)",
		"weaponRotationSource": "weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation)",
		"mountXSource": "mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y)",
		"mountYSource": "mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y)",
		"bulletXSource": "bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX + xOffset + xSpread, this.shootY + yOffset + ySpread)",
		"bulletYSource": "bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX + xOffset + xSpread, this.shootY + yOffset + ySpread)",
		"anglesSource": "rv.set(x, y).rotate(angle)",
		"shootAngleReservedSource": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY) + angleOffset",
	}

static func bullet_angle_life_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float, trns_vec: Callable, bullet_origin_state: Callable, mathf_dst: Callable) -> Dictionary:
	var geometry_state := bullet_geometry_state(unit_state, mount_state, weapon_state, x_offset, y_offset, x_spread, y_spread, trns_vec)
	var bullet_continues := bool(geometry_state.get("bulletContinues", false))
	if not bullet_continues:
		return {
			"bulletContinues": false,
			"mountCharging": geometry_state.get("mountCharging", false),
			"shootAngleSource": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY) + angleOffset",
			"lifeSclSource": "lifeScl = bullet.scaleLife ? Mathf.clamp(Mathf.dst(bulletX, bulletY, mount.aimX, mount.aimY) / bullet.range) : 1f",
			"angleSource": "angle = shootAngle + Mathf.range(inaccuracy + bullet.inaccuracy)",
		}
	var mount_x := float(geometry_state["mountX"])
	var mount_y := float(geometry_state["mountY"])
	var bullet_x := float(geometry_state["bulletX"])
	var bullet_y := float(geometry_state["bulletY"])
	var adjusted_weapon_state := weapon_state.duplicate(true)
	adjusted_weapon_state["shootX"] = float(weapon_state.get("shootX", SOURCE_WEAPON_SHOOT_X_DEFAULT)) + x_offset + x_spread
	adjusted_weapon_state["shootY"] = float(weapon_state.get("shootY", SOURCE_WEAPON_SHOOT_Y_DEFAULT)) + y_offset + y_spread
	var bullet_rotation_state: Dictionary = bullet_origin_state.call(mount_state, adjusted_weapon_state, unit_state, mount_x, mount_y)
	var shoot_angle := float(bullet_rotation_state["shootAngle"]) + angle_offset
	var life_scl := 1.0
	var bullet_scale_life := bool(bullet_state.get("scaleLife", false))
	var bullet_range := float(bullet_state.get("range", 0.0))
	var target_distance: float = float(mathf_dst.call(bullet_x, bullet_y, float(mount_state.get("aimX", 0.0)), float(mount_state.get("aimY", 0.0))))
	if bullet_scale_life:
		var life_ratio := target_distance / bullet_range
		life_scl = clampf(life_ratio, 0.0, 1.0)
	var weapon_inaccuracy := float(weapon_state.get("inaccuracy", SOURCE_WEAPON_INACCURACY_DEFAULT))
	var bullet_inaccuracy := float(bullet_state.get("inaccuracy", 0.0))
	var angle := shoot_angle + angle_spread
	return {
		"bulletContinues": true,
		"mountCharging": geometry_state.get("mountCharging", false),
		"shootAngle": shoot_angle,
		"bulletRotation": float(bullet_rotation_state["shootAngle"]),
		"lifeScl": life_scl,
		"angle": angle,
		"angleSpread": angle_spread,
		"inaccuracyRange": weapon_inaccuracy + bullet_inaccuracy,
		"bulletScaleLife": bullet_scale_life,
		"bulletRange": bullet_range,
		"targetDistance": target_distance,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"mountX": mount_x,
		"mountY": mount_y,
		"bulletRotationSource": "return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation",
		"shootAngleSource": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY) + angleOffset",
		"lifeSclSource": "lifeScl = bullet.scaleLife ? Mathf.clamp(Mathf.dst(bulletX, bulletY, mount.aimX, mount.aimY) / bullet.range) : 1f",
		"mathfDstSource": "public static float dst(float x1, float y1, float x2, float y2)",
		"mathfClampSource": "return Math.max(Math.min(value, 1f), 0f)",
		"angleSource": "angle = shootAngle + Mathf.range(inaccuracy + bullet.inaccuracy)",
		"mathfRangeSource": "return random(-range, range)",
	}

static func bullet_shooter_state(unit_state: Dictionary, controller_state: Dictionary) -> Dictionary:
	var unit_id: Variant = unit_state.get("id", null)
	var controller_is_missile_ai := str(controller_state.get("type", "")) == "MissileAI"
	var missile_shooter: Variant = controller_state.get("shooter", null)
	var shooter: Variant = controller_state.get("shooter", null) if controller_is_missile_ai else unit_id
	return {
		"unit": unit_id,
		"controllerIsMissileAI": controller_is_missile_ai,
		"missileShooter": missile_shooter,
		"shooter": shooter,
		"shooterSelectionSource": "Entityc shooter = unit.controller() instanceof MissileAI ai ? ai.shooter : unit",
		"missileShooterSource": "public @Nullable Unit shooter",
		"unitControllerFieldSource": "private UnitController controller",
		"unitControllerSource": "public UnitController controller(){ return controller; }",
		"missileAiClassSource": "public class MissileAI extends AIController{",
		"bulletCreateReservedSource": "mount.bullet = bullet.create(unit, shooter, unit.team, bulletX, bulletY, angle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd) + extraVelocity, lifeScl, null, mover, mount.aimX, mount.aimY, mount.target)",
		"bulletCreateShooterParamSource": "@Nullable Entityc owner, @Nullable Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl,",
		"bulletCreateNullShooterFallbackSource": "bullet.shooter = (shooter == null ? owner : shooter)",
	}

static func bullet_create_call_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, controller_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float, velocity_random: float, mover: Variant, trns_vec: Callable, bullet_origin_state: Callable, mathf_dst: Callable) -> Dictionary:
	var angle_life_state := bullet_angle_life_state(unit_state, mount_state, weapon_state, bullet_state, x_offset, y_offset, x_spread, y_spread, angle_offset, angle_spread, trns_vec, bullet_origin_state, mathf_dst)
	var bullet_continues := bool(angle_life_state.get("bulletContinues", false))
	if not bullet_continues:
		return {
			"bulletContinues": false,
			"mountCharging": angle_life_state.get("mountCharging", false),
			"bulletCreateCall": null,
			"mountBulletSetFromCreateCall": false,
			"bulletCreateCallSource": "mount.bullet = bullet.create(unit, shooter, unit.team, bulletX, bulletY, angle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd) + extraVelocity, lifeScl, null, mover, mount.aimX, mount.aimY, mount.target)",
		}
	var shooter_state := bullet_shooter_state(unit_state, controller_state)
	var velocity_rnd := float(weapon_state.get("velocityRnd", SOURCE_WEAPON_VELOCITY_RND_DEFAULT))
	var extra_velocity := float(weapon_state.get("extraVelocity", SOURCE_WEAPON_EXTRA_VELOCITY_DEFAULT))
	var velocity_scl := (1.0 - velocity_rnd) + velocity_random + extra_velocity
	var bullet_create_call := {
		"owner": unit_state.get("id", null),
		"shooter": shooter_state.get("shooter", null),
		"team": unit_state.get("team", null),
		"x": angle_life_state["bulletX"],
		"y": angle_life_state["bulletY"],
		"angle": angle_life_state["angle"],
		"damage": -1.0,
		"velocityScl": velocity_scl,
		"lifetimeScl": angle_life_state["lifeScl"],
		"data": null,
		"mover": mover,
		"aimX": float(mount_state.get("aimX", 0.0)),
		"aimY": float(mount_state.get("aimY", 0.0)),
		"target": mount_state.get("target", null),
	}
	return {
		"bulletContinues": true,
		"mountCharging": angle_life_state.get("mountCharging", false),
		"bulletCreateCall": bullet_create_call,
		"mountBulletSetFromCreateCall": true,
		"velocityRnd": velocity_rnd,
		"velocityRandom": velocity_random,
		"extraVelocity": extra_velocity,
		"velocityScl": velocity_scl,
		"angleLifeState": angle_life_state,
		"shooterState": shooter_state,
		"bulletCreateCallSource": "mount.bullet = bullet.create(unit, shooter, unit.team, bulletX, bulletY, angle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd) + extraVelocity, lifeScl, null, mover, mount.aimX, mount.aimY, mount.target)",
		"mathfRandomSource": "return rand.nextFloat() * range",
		"handleBulletReservedSource": "handleBullet(unit, mount, mount.bullet)",
	}

static func bullet_handle_call_state(unit_state: Dictionary, mount_state: Dictionary, create_call_state: Dictionary, created_bullet: Variant) -> Dictionary:
	var bullet_continues := bool(create_call_state.get("bulletContinues", false))
	if not bullet_continues:
		return {
			"bulletContinues": false,
			"handleBulletCalled": false,
			"handleBulletCall": null,
			"handleBulletSource": "handleBullet(unit, mount, mount.bullet)",
		}
	var handle_bullet_call := {
		"unit": unit_state.get("id", null),
		"mount": mount_state.get("id", null),
		"mountBullet": created_bullet,
		"bullet": created_bullet,
	}
	return {
		"bulletContinues": true,
		"handleBulletCalled": true,
		"handleBulletCall": handle_bullet_call,
		"mountBullet": created_bullet,
		"handleBulletSource": "handleBullet(unit, mount, mount.bullet)",
		"handleBulletInternalsReservedSource": "protected void handleBullet(Unit unit, WeaponMount mount, Bullet bullet)",
		"continuousBranchReservedSource": "if(continuous)",
		"soundReservedSource": "if(!continuous)",
	}

static func handle_bullet_continuous_geometry_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, trns_vec: Callable) -> Dictionary:
	var continuous := bool(weapon_state.get("continuous", SOURCE_WEAPON_CONTINUOUS_DEFAULT))
	if not continuous:
		return {
			"continuous": false,
			"continuousGate": false,
			"aimUpdateReservedSource": "Tmp.v1.trns(bulletRotation(unit, mount, bulletX, bulletY), shootY + mount.lastLength).add(bulletX, bulletY);",
		}
	var unit_x := float(unit_state.get("x", 0.0))
	var unit_y := float(unit_state.get("y", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var weapon_rotate := bool(weapon_state.get("rotate", SOURCE_WEAPON_ROTATE_DEFAULT))
	var mount_rotation := float(mount_state.get("rotation", 0.0))
	var base_rotation := float(weapon_state.get("baseRotation", SOURCE_WEAPON_BASE_ROTATION_DEFAULT))
	var weapon_x := float(weapon_state.get("x", SOURCE_WEAPON_X_DEFAULT))
	var weapon_y := float(weapon_state.get("y", SOURCE_WEAPON_Y_DEFAULT))
	var shoot_x := float(weapon_state.get("shootX", SOURCE_WEAPON_SHOOT_X_DEFAULT))
	var shoot_y := float(weapon_state.get("shootY", SOURCE_WEAPON_SHOOT_Y_DEFAULT))
	var weapon_rotation := unit_rotation - SOURCE_WEAPON_ROTATION_OFFSET_DEGREES + (mount_rotation if weapon_rotate else base_rotation)
	var mount_vec: Dictionary = trns_vec.call(unit_rotation - SOURCE_WEAPON_ROTATION_OFFSET_DEGREES, weapon_x, weapon_y)
	var mount_x := unit_x + float(mount_vec["x"])
	var mount_y := unit_y + float(mount_vec["y"])
	var bullet_vec: Dictionary = trns_vec.call(weapon_rotation, shoot_x, shoot_y)
	var bullet_x := mount_x + float(bullet_vec["x"])
	var bullet_y := mount_y + float(bullet_vec["y"])
	return {
		"continuous": true,
		"continuousGate": true,
		"weaponRotation": weapon_rotation,
		"mountX": mount_x,
		"mountY": mount_y,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"shootX": shoot_x,
		"shootY": shoot_y,
		"lastLength": float(mount_state.get("lastLength", 0.0)),
		"continuousGateSource": "if(continuous){",
		"weaponRotationSource": "weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),",
		"mountXSource": "mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),",
		"mountYSource": "mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y),",
		"bulletXSource": "bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY),",
		"bulletYSource": "bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY);",
		"anglesSource": "rv.set(x, y).rotate(angle)",
		"anglesTrnsxSource": "return rv.set(x, y).rotate(angle).x;",
		"anglesTrnsySource": "return rv.set(x, y).rotate(angle).y;",
		"aimUpdateReservedSource": "Tmp.v1.trns(bulletRotation(unit, mount, bulletX, bulletY), shootY + mount.lastLength).add(bulletX, bulletY);",
	}

static func handle_bullet_aim_update_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, trns_vec: Callable, bullet_origin_state: Callable) -> Dictionary:
	var geometry_state := handle_bullet_continuous_geometry_state(unit_state, mount_state, weapon_state, trns_vec)
	if not bool(geometry_state.get("continuousGate", false)):
		return {
			"continuous": false,
			"continuousGate": false,
			"bulletAimUpdated": false,
			"bulletAimX": float(bullet_state.get("aimX", 0.0)),
			"bulletAimY": float(bullet_state.get("aimY", 0.0)),
			"aimUpdateSkippedSource": "if(continuous)",
		}
	var bullet_rotation_state: Dictionary = bullet_origin_state.call(mount_state, weapon_state, unit_state, float(geometry_state["mountX"]), float(geometry_state["mountY"]))
	var bullet_rotation := float(bullet_rotation_state["shootAngle"])
	var aim_length := float(geometry_state["shootY"]) + float(geometry_state["lastLength"])
	var aim_vec: Dictionary = trns_vec.call(bullet_rotation, aim_length, 0.0)
	var bullet_aim_x := float(aim_vec["x"]) + float(geometry_state["bulletX"])
	var bullet_aim_y := float(aim_vec["y"]) + float(geometry_state["bulletY"])
	return {
		"continuous": true,
		"continuousGate": true,
		"bulletAimUpdated": true,
		"weaponRotation": float(geometry_state["weaponRotation"]),
		"mountX": float(geometry_state["mountX"]),
		"mountY": float(geometry_state["mountY"]),
		"bulletX": float(geometry_state["bulletX"]),
		"bulletY": float(geometry_state["bulletY"]),
		"bulletRotation": bullet_rotation,
		"aimLength": aim_length,
		"bulletAimX": bullet_aim_x,
		"bulletAimY": bullet_aim_y,
		"previousBulletAimX": float(bullet_state.get("aimX", 0.0)),
		"previousBulletAimY": float(bullet_state.get("aimY", 0.0)),
		"aimUpdateSource": "Tmp.v1.trns(bulletRotation(unit, mount, bulletX, bulletY), shootY + mount.lastLength).add(bulletX, bulletY);",
		"bulletAimXSource": "bullet.aimX = Tmp.v1.x;",
		"bulletAimYSource": "bullet.aimY = Tmp.v1.y;",
		"bulletRotationSource": "return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation",
		"vec2TrnsSource": "return set(amount, 0).rotate(angle);",
		"vec2AddSource": "this.x += x; this.y += y;",
	}

static func bullet_sound_state(create_call_state: Dictionary, weapon_state: Dictionary, sound_pitch: float) -> Dictionary:
	if not bool(create_call_state.get("bulletContinues", false)):
		return {
			"bulletContinues": false,
			"soundCall": null,
			"effectsReservedSource": "if(mount.allowShootEffects){",
		}
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	if bullet_create_call.is_empty():
		return {
			"bulletContinues": true,
			"soundCall": null,
			"soundSkipped": true,
			"effectsReservedSource": "if(mount.allowShootEffects){",
		}
	var continuous := bool(weapon_state.get("continuous", SOURCE_WEAPON_CONTINUOUS_DEFAULT))
	var sound_name := str(weapon_state.get("shootSound", "shoot"))
	var branch_source := "if(!continuous)"
	var call_source := "shootSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax), shootSoundVolume);"
	if continuous:
		sound_name = str(weapon_state.get("initialShootSound", "none"))
		branch_source = "}else{"
		call_source = "initialShootSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax), shootSoundVolume);"
	var sound_call := {
		"sound": sound_name,
		"x": float(bullet_create_call.get("x", 0.0)),
		"y": float(bullet_create_call.get("y", 0.0)),
		"pitch": sound_pitch,
		"volume": float(weapon_state.get("shootSoundVolume", SOURCE_WEAPON_SHOOT_SOUND_VOLUME_DEFAULT)),
	}
	return {
		"bulletContinues": true,
		"continuous": continuous,
		"soundCall": sound_call,
		"soundPitchMin": float(weapon_state.get("soundPitchMin", SOURCE_WEAPON_SOUND_PITCH_MIN_DEFAULT)),
		"soundPitchMax": float(weapon_state.get("soundPitchMax", SOURCE_WEAPON_SOUND_PITCH_MAX_DEFAULT)),
		"soundBranchSource": branch_source,
		"soundCallSource": "shootSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax), shootSoundVolume);",
		"initialSoundCallSource": "initialShootSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax), shootSoundVolume);",
		"selectedSoundCallSource": call_source,
		"mathfRandomSource": "return start + rand.nextFloat() * (end - start);",
		"effectsReservedSource": "if(mount.allowShootEffects){",
	}

static func bullet_effects_state(create_call_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary) -> Dictionary:
	if not bool(create_call_state.get("bulletContinues", false)):
		return {
			"bulletContinues": false,
			"effectsGate": false,
			"effectCalls": [],
			"recoilReservedSource": "unit.vel.add(Tmp.v1.trns(shootAngle + 180f, bullet.recoil))",
		}
	var allow_shoot_effects := bool(mount_state.get("allowShootEffects", true))
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	if not allow_shoot_effects or bullet_create_call.is_empty():
		return {
			"bulletContinues": true,
			"effectsGate": false,
			"effectCalls": [],
			"effectsGateSource": "if(mount.allowShootEffects)",
			"recoilReservedSource": "unit.vel.add(Tmp.v1.trns(shootAngle + 180f, bullet.recoil))",
		}
	var weapon_x := float(weapon_state.get("x", SOURCE_WEAPON_X_DEFAULT))
	var x_sign := -1.0 if weapon_x < 0.0 else 1.0
	var mount_x := float(create_call_state.get("mountX", bullet_create_call.get("x", 0.0)))
	var mount_y := float(create_call_state.get("mountY", bullet_create_call.get("y", 0.0)))
	var bullet_x := float(bullet_create_call.get("x", 0.0))
	var bullet_y := float(bullet_create_call.get("y", 0.0))
	var angle_value := float(bullet_create_call.get("angle", 0.0))
	var hit_color = bullet_state.get("hitColor", "white")
	var unit_id = unit_state.get("id", unit_state)
	var effect_calls := [
		{
			"effect": str(weapon_state.get("ejectEffect", "none")),
			"x": mount_x,
			"y": mount_y,
			"angle": angle_value * x_sign,
			"kind": "ejectEffect",
		},
		{
			"effect": str(bullet_state.get("shootEffect", "shootSmall")),
			"x": bullet_x,
			"y": bullet_y,
			"angle": angle_value,
			"color": hit_color,
			"unit": unit_id,
			"kind": "shootEffect",
		},
		{
			"effect": str(bullet_state.get("smokeEffect", "shootSmallSmoke")),
			"x": bullet_x,
			"y": bullet_y,
			"angle": angle_value,
			"color": hit_color,
			"unit": unit_id,
			"kind": "smokeEffect",
		},
	]
	return {
		"bulletContinues": true,
		"effectsGate": true,
		"effectCalls": effect_calls,
		"weaponX": weapon_x,
		"xSign": x_sign,
		"effectsGateSource": "if(mount.allowShootEffects)",
		"ejectEffectSource": "ejectEffect.at(mountX, mountY, angle * Mathf.sign(this.x))",
		"shootEffectSource": "bullet.shootEffect.at(bulletX, bulletY, angle, bullet.hitColor, unit)",
		"smokeEffectSource": "bullet.smokeEffect.at(bulletX, bulletY, angle, bullet.hitColor, unit)",
		"mathfSignSource": "return (f < 0 ? -1 : 1)",
		"recoilReservedSource": "unit.vel.add(Tmp.v1.trns(shootAngle + 180f, bullet.recoil))",
	}

static func bullet_recoil_velocity_state(create_call_state: Dictionary, unit_state: Dictionary, bullet_state: Dictionary, trns_vec: Callable) -> Dictionary:
	var unit_vel: Dictionary = unit_state.get("vel", {"x": 0.0, "y": 0.0})
	var unit_vel_before := {
		"x": float(unit_vel.get("x", 0.0)),
		"y": float(unit_vel.get("y", 0.0)),
	}
	if not bool(create_call_state.get("bulletContinues", false)):
		return {
			"bulletContinues": false,
			"recoilVelocityApplied": false,
			"unitVelBefore": unit_vel_before,
			"unitVelAfter": unit_vel_before.duplicate(),
			"recoilVector": {"x": 0.0, "y": 0.0, "angle": 0.0},
			"recoilVelocitySource": "unit.vel.add(Tmp.v1.trns(shootAngle + 180f, bullet.recoil))",
			"vec2TrnsSource": "return set(amount, 0).rotate(angle)",
			"vec2AddSource": "x += v.x; y += v.y",
			"shakeReservedSource": "Effect.shake(shake, shake, bulletX, bulletY)",
		}
	var angle_life_state: Dictionary = create_call_state.get("angleLifeState", {})
	var shoot_angle := float(angle_life_state.get("shootAngle", 0.0))
	var bullet_recoil := float(bullet_state.get("recoil", 0.0))
	var recoil_vec: Dictionary = trns_vec.call(shoot_angle + 180.0, bullet_recoil, 0.0)
	var unit_vel_after := {
		"x": float(unit_vel_before["x"]) + float(recoil_vec.get("x", 0.0)),
		"y": float(unit_vel_before["y"]) + float(recoil_vec.get("y", 0.0)),
	}
	return {
		"bulletContinues": true,
		"recoilVelocityApplied": true,
		"shootAngle": shoot_angle,
		"bulletRecoil": bullet_recoil,
		"unitVelBefore": unit_vel_before,
		"unitVelAfter": unit_vel_after,
		"recoilVector": recoil_vec,
		"recoilVelocitySource": "unit.vel.add(Tmp.v1.trns(shootAngle + 180f, bullet.recoil))",
		"vec2TrnsSource": "return set(amount, 0).rotate(angle)",
		"vec2AddSource": "x += v.x; y += v.y",
		"shakeReservedSource": "Effect.shake(shake, shake, bulletX, bulletY)",
	}

static func bullet_shake_state(create_call_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	if not bool(create_call_state.get("bulletContinues", false)):
		return {
			"bulletContinues": false,
			"shakeEffectCalled": false,
			"shakeCall": null,
			"shakeCallSource": "Effect.shake(shake, shake, bulletX, bulletY)",
			"effectCameraGuardSource": "if(Core.camera == null) return",
			"effectFalloffSource": "shake(Mathf.clamp(1f / (distance * distance / shakeFalloff)) * intensity, duration)",
			"effectPrivateShakeSource": "private static void shake(float intensity, float duration)",
			"mountRecoilReservedSource": "mount.recoil = 1f",
		}
	var bullet_create_call: Dictionary = create_call_state.get("bulletCreateCall", {})
	if bullet_create_call.is_empty():
		return {
			"bulletContinues": true,
			"shakeEffectCalled": false,
			"shakeCall": null,
			"shakeCallSource": "Effect.shake(shake, shake, bulletX, bulletY)",
			"effectCameraGuardSource": "if(Core.camera == null) return",
			"effectFalloffSource": "shake(Mathf.clamp(1f / (distance * distance / shakeFalloff)) * intensity, duration)",
			"effectPrivateShakeSource": "private static void shake(float intensity, float duration)",
			"mountRecoilReservedSource": "mount.recoil = 1f",
		}
	var shake_intensity := float(weapon_state.get("shake", SOURCE_WEAPON_SHAKE_DEFAULT))
	var effect_shake_call := {
		"intensity": shake_intensity,
		"duration": shake_intensity,
		"x": float(bullet_create_call.get("x", 0.0)),
		"y": float(bullet_create_call.get("y", 0.0)),
	}
	return {
		"bulletContinues": true,
		"shakeEffectCalled": true,
		"shakeCall": effect_shake_call,
		"shakeCallSource": "Effect.shake(shake, shake, bulletX, bulletY)",
		"effectCameraGuardSource": "if(Core.camera == null) return",
		"effectDistanceSource": "float distance = Core.camera.position.dst(x, y)",
		"effectDistanceFloorSource": "if(distance < 1) distance = 1",
		"effectFalloffSource": "shake(Mathf.clamp(1f / (distance * distance / shakeFalloff)) * intensity, duration)",
		"effectPrivateShakeSource": "private static void shake(float intensity, float duration)",
		"rendererShakeSource": "Vars.renderer.shake(intensity, duration)",
		"mountRecoilReservedSource": "mount.recoil = 1f",
	}

static func bullet_mount_recoil_state(create_call_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	var current_recoil := float(mount_state.get("recoil", 0.0))
	if not bool(create_call_state.get("bulletContinues", false)):
		return {
			"bulletContinues": false,
			"mountRecoilApplied": false,
			"mountRecoilBefore": current_recoil,
			"mountRecoil": current_recoil,
			"mountRecoilSource": "mount.recoil = 1f",
			"recoilSlotsReservedSource": "if(recoils > 0){ mount.recoils[mount.barrelCounter % recoils] = 1f; }",
			"heatReservedSource": "mount.heat = 1f",
		}
	return {
		"bulletContinues": true,
		"mountRecoilApplied": true,
		"mountRecoilBefore": current_recoil,
		"mountRecoil": 1.0,
		"mountRecoilSource": "mount.recoil = 1f",
		"recoilSlotsReservedSource": "if(recoils > 0){ mount.recoils[mount.barrelCounter % recoils] = 1f; }",
		"heatReservedSource": "mount.heat = 1f",
	}

static func bullet_recoil_slots_state(create_call_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	var recoils_count := int(weapon_state.get("recoils", SOURCE_WEAPON_RECOILS_DEFAULT))
	var barrel_counter := int(mount_state.get("barrelCounter", 0))
	var raw_recoils = mount_state.get("recoils", [])
	var recoils_values: Array = []
	if raw_recoils is Array:
		recoils_values = raw_recoils.duplicate()
	if not bool(create_call_state.get("bulletContinues", false)):
		return {
			"bulletContinues": false,
			"recoilSlotsApplied": false,
			"recoils": recoils_values,
			"recoilIndex": -1,
			"recoilsCount": recoils_count,
			"barrelCounter": barrel_counter,
			"recoilSlotsSource": "if(recoils > 0){ mount.recoils[mount.barrelCounter % recoils] = 1f; }",
			"updateInitSource": "if(mount.recoils == null) mount.recoils = new float[recoils]",
			"heatReservedSource": "mount.heat = 1f",
		}
	if recoils_count <= 0:
		return {
			"bulletContinues": true,
			"recoilSlotsApplied": false,
			"recoils": recoils_values,
			"recoilIndex": -1,
			"recoilsCount": recoils_count,
			"barrelCounter": barrel_counter,
			"recoilSlotsSource": "if(recoils > 0){ mount.recoils[mount.barrelCounter % recoils] = 1f; }",
			"updateInitSource": "if(mount.recoils == null) mount.recoils = new float[recoils]",
			"heatReservedSource": "mount.heat = 1f",
		}
	var recoil_index := barrel_counter % recoils_count
	while recoils_values.size() < recoils_count:
		recoils_values.append(0.0)
	recoils_values[recoil_index] = 1.0
	return {
		"bulletContinues": true,
		"recoilSlotsApplied": true,
		"recoils": recoils_values,
		"recoilIndex": recoil_index,
		"recoilsCount": recoils_count,
		"barrelCounter": barrel_counter,
		"recoilSlotsSource": "if(recoils > 0){ mount.recoils[mount.barrelCounter % recoils] = 1f; }",
		"updateInitSource": "if(mount.recoils == null) mount.recoils = new float[recoils]",
		"heatReservedSource": "mount.heat = 1f",
	}

static func bullet_heat_state(create_call_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	var current_heat := float(mount_state.get("heat", 0.0))
	if not bool(create_call_state.get("bulletContinues", false)):
		return {
			"bulletContinues": false,
			"mountHeatApplied": false,
			"mountHeatBefore": current_heat,
			"mountHeat": current_heat,
			"mountHeatSource": "mount.heat = 1f",
			"bulletMethodComplete": false,
		}
	return {
		"bulletContinues": true,
		"mountHeatApplied": true,
		"mountHeatBefore": current_heat,
		"mountHeat": 1.0,
		"mountHeatSource": "mount.heat = 1f",
		"bulletMethodComplete": true,
	}
