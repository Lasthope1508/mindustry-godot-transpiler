extends RefCounted
class_name SourceBulletTypeLifecycleState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_bullet_removed_runtime_state := preload("res://src/game/SourceBulletRemovedRuntimeState.gd")

static func despawned_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var despawn_hit := bool(update_type_state.get("despawnHit", false))
	var bullet_x: Variant = update_bullet_state.get("x", null)
	var bullet_y: Variant = update_bullet_state.get("y", null)
	var hit_call := {}
	var create_units_call := {}
	if despawn_hit:
		hit_call = {
			"call": "hit(b, b.x, b.y, false)",
			"x": bullet_x,
			"y": bullet_y,
			"createFrags": false,
			"called": true,
		}
	else:
		create_units_call = {
			"call": "createUnits(b, b.x, b.y)",
			"x": bullet_x,
			"y": bullet_y,
			"called": true,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"despawnHit": despawn_hit,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"hitCall": hit_call,
		"createUnitsCall": create_units_call,
		"despawnEffectBoundarySource": "despawnEffect.at(b.x, b.y, b.rotation(), hitColor);",
		"despawnSoundBoundarySource": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));",
		"shakeBoundarySource": "Effect.shake(despawnShake, despawnShake, b);",
	}

static func despawned_effect_state(bullet_type_state: Dictionary, bullet_state: Dictionary, dispatch_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_despawned_dispatch_state: Dictionary = dispatch_state.duplicate(true)
	var bullet_x: Variant = update_despawned_dispatch_state.get("bulletX", update_bullet_state.get("x", null))
	var bullet_y: Variant = update_despawned_dispatch_state.get("bulletY", update_bullet_state.get("y", null))
	var despawn_effect: Variant = update_type_state.get("despawnEffect", "Fx.hitBulletSmall")
	var hit_color: Variant = update_type_state.get("hitColor", "Color.white")
	var bullet_rotation := float(update_bullet_state.get("rotation", 0.0))
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"despawnedDispatch": update_despawned_dispatch_state,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"despawnEffectCall": {
			"call": "despawnEffect.at(b.x, b.y, b.rotation(), hitColor)",
			"effect": despawn_effect,
			"x": bullet_x,
			"y": bullet_y,
			"rotation": bullet_rotation,
			"color": hit_color,
		},
		"despawnEffectCallSource": "despawnEffect.at(b.x, b.y, b.rotation(), hitColor);",
		"despawnSoundBoundarySource": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));",
		"shakeBoundarySource": "Effect.shake(despawnShake, despawnShake, b);",
	}

static func despawned_sound_state(bullet_type_state: Dictionary, bullet_state: Dictionary, effect_state: Dictionary, sound_random_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_despawned_effect_state: Dictionary = effect_state.duplicate(true)
	var update_despawn_sound_random_state: Dictionary = sound_random_state.duplicate(true)
	var despawn_sound: Variant = update_type_state.get("despawnSound", "Sounds.none")
	var hit_sound_pitch_range := float(update_type_state.get("hitSoundPitchRange", source_bullet_defaults.HIT_SOUND_PITCH_RANGE_DEFAULT))
	var range_sample: Variant = update_despawn_sound_random_state.get("rangeSample", null)
	var sound_pitch: Variant = null
	if range_sample != null:
		sound_pitch = 1.0 + float(range_sample)
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"despawnedEffect": update_despawned_effect_state,
		"despawnSoundRandom": update_despawn_sound_random_state,
		"despawnSoundCall": {
			"call": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange))",
			"sound": despawn_sound,
			"bullet": update_bullet_state,
			"pitchBase": 1.0,
			"pitchRange": hit_sound_pitch_range,
			"rangeSample": range_sample,
			"pitch": sound_pitch,
		},
		"despawnSoundCallSource": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));",
		"mathfRangeSource": "public static float range(float range){ return random(-range, range); }",
		"shakeBoundarySource": "Effect.shake(despawnShake, despawnShake, b);",
	}

static func despawned_shake_state(bullet_type_state: Dictionary, bullet_state: Dictionary, sound_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_despawned_sound_state: Dictionary = sound_state.duplicate(true)
	var despawn_shake := float(update_type_state.get("despawnShake", 0.0))
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"despawnedSound": update_despawned_sound_state,
		"despawnShake": despawn_shake,
		"shakeCall": {
			"call": "Effect.shake(despawnShake, despawnShake, b)",
			"intensity": despawn_shake,
			"duration": despawn_shake,
			"position": update_bullet_state,
		},
		"shakeCallSource": "Effect.shake(despawnShake, despawnShake, b);",
		"effectShakePositionSource": "public static void shake(float intensity, float duration, Position loc){ shake(intensity, duration, loc.getX(), loc.getY()); }",
		"removedBoundarySource": "public void removed(Bullet b){",
	}

static func removed_trail_fade_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var trail_length := int(update_type_state.get("trailLength", -1))
	var trail_width := float(update_type_state.get("trailWidth", source_bullet_defaults.TRAIL_WIDTH_DEFAULT))
	var trail_color: Variant = update_type_state.get("trailColor", "Pal.missileYellowBack")
	var bullet_x: Variant = update_bullet_state.get("x", null)
	var bullet_y: Variant = update_bullet_state.get("y", null)
	var trail_state: Variant = update_bullet_state.get("trail", null)
	var trail_exists := trail_state != null
	var trail_size: Variant = null
	var trail_copy: Variant = null
	if trail_state is Dictionary:
		trail_size = trail_state.get("size", null)
	var gate_passed := trail_length > 0 and trail_exists and trail_size != null and int(trail_size) > 0
	var trail_fade_call: Variant = null
	if gate_passed:
		if trail_state is Dictionary:
			trail_copy = (trail_state as Dictionary).duplicate(true)
		else:
			trail_copy = trail_state
		trail_fade_call = {
			"call": "Fx.trailFade.at(b.x, b.y, trailWidth, trailColor, b.trail.copy())",
			"x": bullet_x,
			"y": bullet_y,
			"width": trail_width,
			"color": trail_color,
			"trailCopy": trail_copy,
		}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"trailLength": trail_length,
		"trailWidth": trail_width,
		"trailColor": trail_color,
		"trailExists": trail_exists,
		"trailSize": trail_size,
		"gatePassed": gate_passed,
		"trailFadeCall": trail_fade_call,
		"gateSource": "if(trailLength > 0 && b.trail != null && b.trail.size() > 0){",
		"fragBoundarySource": "if(b.frags == 0 && fragOnDespawn && fragBullet != null){",
	}

static func removed_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, trail_fade_state: Dictionary) -> Dictionary:
	return source_bullet_removed_runtime_state.removed_frag_dispatch_state(bullet_type_state, bullet_state, trail_fade_state)
