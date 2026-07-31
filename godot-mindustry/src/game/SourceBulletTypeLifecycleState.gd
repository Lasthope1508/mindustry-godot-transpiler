extends RefCounted
class_name SourceBulletTypeLifecycleState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_bullet_runtime := preload("res://src/game/SourceBulletRuntime.gd")

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
	var runtime_state := source_bullet_runtime.despawned_dispatch_state(bullet_type_state, bullet_state)
	runtime_state["bulletType"] = update_type_state
	runtime_state["bullet"] = update_bullet_state
	runtime_state["despawnHit"] = despawn_hit
	runtime_state["bulletX"] = bullet_x
	runtime_state["bulletY"] = bullet_y
	runtime_state["hitCall"] = hit_call
	runtime_state["createUnitsCall"] = create_units_call
	var source_trace := {
		"despawnEffectBoundarySource": "despawnEffect.at(b.x, b.y, b.rotation(), hitColor);",
		"despawnSoundBoundarySource": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));",
		"shakeBoundarySource": "Effect.shake(despawnShake, despawnShake, b);",
	}
	runtime_state["despawnEffectBoundarySource"] = source_trace.get("despawnEffectBoundarySource", "")
	runtime_state["despawnSoundBoundarySource"] = source_trace.get("despawnSoundBoundarySource", "")
	runtime_state["shakeBoundarySource"] = source_trace.get("shakeBoundarySource", "")
	return runtime_state

static func despawned_effect_state(bullet_type_state: Dictionary, bullet_state: Dictionary, dispatch_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_despawned_dispatch_state: Dictionary = dispatch_state.duplicate(true)
	var bullet_x: Variant = update_despawned_dispatch_state.get("bulletX", update_bullet_state.get("x", null))
	var bullet_y: Variant = update_despawned_dispatch_state.get("bulletY", update_bullet_state.get("y", null))
	var despawn_effect: Variant = update_type_state.get("despawnEffect", "Fx.hitBulletSmall")
	var hit_color: Variant = update_type_state.get("hitColor", "Color.white")
	var bullet_rotation := float(update_bullet_state.get("rotation", 0.0))
	var runtime_state := source_bullet_runtime.despawned_effect_state(bullet_type_state, bullet_state, dispatch_state)
	runtime_state["bulletType"] = update_type_state
	runtime_state["bullet"] = update_bullet_state
	runtime_state["despawnedDispatch"] = update_despawned_dispatch_state
	runtime_state["bulletX"] = bullet_x
	runtime_state["bulletY"] = bullet_y
	runtime_state["despawnEffectCall"] = {
		"call": "despawnEffect.at(b.x, b.y, b.rotation(), hitColor)",
		"effect": despawn_effect,
		"x": bullet_x,
		"y": bullet_y,
		"rotation": bullet_rotation,
		"color": hit_color,
	}
	var source_trace := {
		"despawnEffectCallSource": "despawnEffect.at(b.x, b.y, b.rotation(), hitColor);",
		"despawnSoundBoundarySource": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));",
		"shakeBoundarySource": "Effect.shake(despawnShake, despawnShake, b);",
	}
	runtime_state["despawnEffectCallSource"] = source_trace.get("despawnEffectCallSource", "")
	runtime_state["despawnSoundBoundarySource"] = source_trace.get("despawnSoundBoundarySource", "")
	runtime_state["shakeBoundarySource"] = source_trace.get("shakeBoundarySource", "")
	return runtime_state

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
	var runtime_state := source_bullet_runtime.despawned_sound_state(bullet_type_state, bullet_state, effect_state, sound_random_state)
	runtime_state["bulletType"] = update_type_state
	runtime_state["bullet"] = update_bullet_state
	runtime_state["despawnedEffect"] = update_despawned_effect_state
	runtime_state["despawnSoundRandom"] = update_despawn_sound_random_state
	runtime_state["despawnSoundCall"] = {
		"call": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange))",
		"sound": despawn_sound,
		"bullet": update_bullet_state,
		"pitchBase": 1.0,
		"pitchRange": hit_sound_pitch_range,
		"rangeSample": range_sample,
		"pitch": sound_pitch,
	}
	var source_trace := {
		"despawnSoundCallSource": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));",
		"mathfRangeSource": "public static float range(float range){ return random(-range, range); }",
		"shakeBoundarySource": "Effect.shake(despawnShake, despawnShake, b);",
	}
	runtime_state["despawnSoundCallSource"] = source_trace.get("despawnSoundCallSource", "")
	runtime_state["mathfRangeSource"] = source_trace.get("mathfRangeSource", "")
	runtime_state["shakeBoundarySource"] = source_trace.get("shakeBoundarySource", "")
	return runtime_state

static func despawned_shake_state(bullet_type_state: Dictionary, bullet_state: Dictionary, sound_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_despawned_sound_state: Dictionary = sound_state.duplicate(true)
	var despawn_shake := float(update_type_state.get("despawnShake", 0.0))
	var runtime_state := source_bullet_runtime.despawned_shake_state(bullet_type_state, bullet_state, sound_state)
	runtime_state["bulletType"] = update_type_state
	runtime_state["bullet"] = update_bullet_state
	runtime_state["despawnedSound"] = update_despawned_sound_state
	runtime_state["despawnShake"] = despawn_shake
	runtime_state["shakeCall"] = {
		"call": "Effect.shake(despawnShake, despawnShake, b)",
		"intensity": despawn_shake,
		"duration": despawn_shake,
		"position": update_bullet_state,
	}
	var source_trace := {
		"shakeCallSource": "Effect.shake(despawnShake, despawnShake, b);",
		"effectShakePositionSource": "public static void shake(float intensity, float duration, Position loc){ shake(intensity, duration, loc.getX(), loc.getY()); }",
		"removedBoundarySource": "public void removed(Bullet b){",
	}
	runtime_state["shakeCallSource"] = source_trace.get("shakeCallSource", "")
	runtime_state["effectShakePositionSource"] = source_trace.get("effectShakePositionSource", "")
	runtime_state["removedBoundarySource"] = source_trace.get("removedBoundarySource", "")
	return runtime_state

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
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_removed_trail_fade_state: Dictionary = trail_fade_state.duplicate(true)
	var bullet_frags := int(update_bullet_state.get("frags", 0))
	var frag_on_despawn := bool(update_type_state.get("fragOnDespawn", true))
	var frag_bullet: Variant = update_type_state.get("fragBullet", null)
	var frag_bullet_exists := frag_bullet != null
	var bullet_x: Variant = update_bullet_state.get("x", null)
	var bullet_y: Variant = update_bullet_state.get("y", null)
	var frag_gate_passed := bullet_frags == 0 and frag_on_despawn and frag_bullet_exists
	var create_frags_call := {}
	if frag_gate_passed:
		create_frags_call = {
			"call": "createFrags(b, b.x, b.y)",
			"x": bullet_x,
			"y": bullet_y,
			"called": true,
		}
	var runtime_state := source_bullet_runtime.removed_frag_dispatch_state(bullet_type_state, bullet_state, trail_fade_state)
	runtime_state["bulletType"] = update_type_state
	runtime_state["bullet"] = update_bullet_state
	runtime_state["removedTrailFade"] = update_removed_trail_fade_state
	runtime_state["bulletFrags"] = bullet_frags
	runtime_state["fragOnDespawn"] = frag_on_despawn
	runtime_state["fragBullet"] = frag_bullet
	runtime_state["fragBulletExists"] = frag_bullet_exists
	runtime_state["fragGatePassed"] = frag_gate_passed
	runtime_state["createFragsCall"] = create_frags_call
	var source_trace := {
		"fragGateSource": "if(b.frags == 0 && fragOnDespawn && fragBullet != null){",
		"createFragsCallSource": "createFrags(b, b.x, b.y);",
		"buildingDamageBoundarySource": "public float buildingDamage(Bullet b){",
	}
	runtime_state["fragGateSource"] = source_trace.get("fragGateSource", "")
	runtime_state["createFragsCallSource"] = source_trace.get("createFragsCallSource", "")
	runtime_state["buildingDamageBoundarySource"] = source_trace.get("buildingDamageBoundarySource", "")
	return runtime_state
