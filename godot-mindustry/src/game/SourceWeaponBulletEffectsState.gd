extends RefCounted
class_name SourceWeaponBulletEffectsState

const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_weapon_defaults := preload("res://src/game/SourceWeaponDefaults.gd")

const SOURCE_WEAPON_RECOILS_DEFAULT := source_weapon_defaults.RECOILS_DEFAULT
const SOURCE_WEAPON_CONTINUOUS_DEFAULT := source_weapon_defaults.CONTINUOUS_DEFAULT
const SOURCE_WEAPON_X_DEFAULT := source_weapon_defaults.X_DEFAULT
const SOURCE_WEAPON_SHOOT_SOUND_VOLUME_DEFAULT := source_weapon_defaults.SHOOT_SOUND_VOLUME_DEFAULT
const SOURCE_WEAPON_SOUND_PITCH_MIN_DEFAULT := source_weapon_defaults.SOUND_PITCH_MIN_DEFAULT
const SOURCE_WEAPON_SOUND_PITCH_MAX_DEFAULT := source_weapon_defaults.SOUND_PITCH_MAX_DEFAULT
const SOURCE_WEAPON_SHAKE_DEFAULT := source_weapon_defaults.SHAKE_DEFAULT
const SOURCE_WEAPON_HALF_CIRCLE_DEGREES := source_math_defaults.HALF_CIRCLE_DEGREES

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
	var recoil_vec: Dictionary = trns_vec.call(shoot_angle + SOURCE_WEAPON_HALF_CIRCLE_DEGREES, bullet_recoil, 0.0)
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
