extends RefCounted
class_name SourceWeaponFiringState

const source_weapon_defaults := preload("res://src/game/SourceWeaponDefaults.gd")
const source_weapon_shoot_pattern_state := preload("res://src/game/SourceWeaponShootPatternState.gd")

const SOURCE_WEAPON_RELOAD_DEFAULT := source_weapon_defaults.RELOAD_DEFAULT
const SOURCE_WEAPON_MIN_WARMUP_DEFAULT := source_weapon_defaults.MIN_WARMUP_DEFAULT
const SOURCE_WEAPON_FLIP_SPRITE_DEFAULT := source_weapon_defaults.FLIP_SPRITE_DEFAULT
const SOURCE_WEAPON_ALTERNATE_DEFAULT := source_weapon_defaults.ALTERNATE_DEFAULT
const SOURCE_WEAPON_OTHER_SIDE_DEFAULT := source_weapon_defaults.OTHER_SIDE_DEFAULT
const SOURCE_WEAPON_MIN_SHOOT_VELOCITY_DEFAULT := source_weapon_defaults.MIN_SHOOT_VELOCITY_DEFAULT
const SOURCE_WEAPON_ACTIVE_SOUND_VOLUME_DEFAULT := source_weapon_defaults.ACTIVE_SOUND_VOLUME_DEFAULT
const SOURCE_WEAPON_ALWAYS_CONTINUOUS_DEFAULT := source_weapon_defaults.ALWAYS_CONTINUOUS_DEFAULT
const SOURCE_WEAPON_ALWAYS_SHOOTING_DEFAULT := source_weapon_defaults.ALWAYS_SHOOTING_DEFAULT
const SOURCE_WEAPON_ROTATE_DEFAULT := source_weapon_defaults.ROTATE_DEFAULT
const SOURCE_WEAPON_BASE_ROTATION_DEFAULT := source_weapon_defaults.BASE_ROTATION_DEFAULT
const SOURCE_WEAPON_SHOOT_CONE_DEFAULT := source_weapon_defaults.SHOOT_CONE_DEFAULT
const SOURCE_WEAPON_SHOOT_STATUS_DURATION_DEFAULT := source_weapon_defaults.SHOOT_STATUS_DURATION_DEFAULT
const SOURCE_WEAPON_SOUND_PITCH_MIN_DEFAULT := source_weapon_defaults.SOUND_PITCH_MIN_DEFAULT
const SOURCE_WEAPON_SOUND_PITCH_MAX_DEFAULT := source_weapon_defaults.SOUND_PITCH_MAX_DEFAULT
const SOURCE_WEAPON_PARENTIZE_EFFECTS_DEFAULT := source_weapon_defaults.PARENTIZE_EFFECTS_DEFAULT
const SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT := source_weapon_shoot_pattern_state.SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT

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
