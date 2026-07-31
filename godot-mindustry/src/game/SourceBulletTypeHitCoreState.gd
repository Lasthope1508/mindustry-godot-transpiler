extends RefCounted
class_name SourceBulletTypeHitCoreState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_bullet_runtime := preload("res://src/game/SourceBulletRuntime.gd")

const SOURCE_BULLET_SUPPRESSION_DURATION_DEFAULT := source_bullet_defaults.SUPPRESSION_DURATION_DEFAULT

static func hit_default_state(bullet_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var hit_x := float(update_bullet_state.get("x", 0.0))
	var hit_y := float(update_bullet_state.get("y", 0.0))
	var create_frags := true
	var hit_call := {"call": "hit(b, b.x, b.y, true)", "x": hit_x, "y": hit_y, "createFrags": create_frags}
	return {
		"bullet": update_bullet_state,
		"x": hit_x,
		"y": hit_y,
		"createFrags": create_frags,
		"hitCall": hit_call,
		"hitDefaultCallSource": "hit(b, b.x, b.y, true)",
		"hitOverloadBoundarySource": "public void hit(Bullet b, float x, float y)",
		"hitSource": "public void hit(Bullet b){",
	}

static func hit_xy_default_state(bullet_state: Dictionary, xy_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = xy_state.duplicate(true)
	var hit_x := float(update_hit_xy_state.get("x", 0.0))
	var hit_y := float(update_hit_xy_state.get("y", 0.0))
	var create_frags := true
	var hit_call := {"call": "hit(b, x, y, true)", "x": hit_x, "y": hit_y, "createFrags": create_frags}
	return {
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"x": hit_x,
		"y": hit_y,
		"createFrags": create_frags,
		"hitCall": hit_call,
		"hitXYDefaultCallSource": "hit(b, x, y, true)",
		"hitCreateFragsBoundarySource": "public void hit(Bullet b, float x, float y, boolean createFrags)",
		"hitSource": "public void hit(Bullet b, float x, float y){",
	}

static func hit_effects_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var hit_x := float(update_hit_xy_state.get("x", 0.0))
	var hit_y := float(update_hit_xy_state.get("y", 0.0))
	var hit_effect: Variant = update_type_state.get("hitEffect", "Fx.hitBulletSmall")
	var hit_sound: Variant = update_type_state.get("hitSound", "Sounds.none")
	var hit_sound_pitch := float(update_type_state.get("hitSoundPitch", 1.0))
	var hit_sound_pitch_range := float(update_type_state.get("hitSoundPitchRange", source_bullet_defaults.HIT_SOUND_PITCH_RANGE_DEFAULT))
	var hit_sound_volume := float(update_type_state.get("hitSoundVolume", 1.0))
	var hit_shake := float(update_type_state.get("hitShake", 0.0))
	var hit_color: Variant = update_type_state.get("hitColor", "Color.white")
	var bullet_rotation := float(update_bullet_state.get("rotation", 0.0))
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"x": hit_x,
		"y": hit_y,
		"hitEffectCall": {"call": "hitEffect.at(x, y, b.rotation(), hitColor)", "effect": hit_effect, "x": hit_x, "y": hit_y, "rotation": bullet_rotation, "color": hit_color},
		"hitSoundCall": {"call": "hitSound.at(x, y, hitSoundPitch + Mathf.range(hitSoundPitchRange), hitSoundVolume)", "sound": hit_sound, "x": hit_x, "y": hit_y, "pitchBase": hit_sound_pitch, "pitchRange": hit_sound_pitch_range, "volume": hit_sound_volume},
		"shakeCall": {"call": "Effect.shake(hitShake, hitShake, b)", "amountX": hit_shake, "amountY": hit_shake, "bullet": update_bullet_state},
		"hitEffectCallSource": "hitEffect.at(x, y, b.rotation(), hitColor)",
		"hitSoundCallSource": "hitSound.at(x, y, hitSoundPitch + Mathf.range(hitSoundPitchRange), hitSoundVolume)",
		"shakeCallSource": "Effect.shake(hitShake, hitShake, b)",
		"fragBranchBoundarySource": "if(createFrags && fragOnHit)",
	}

static func hit_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_frag_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var update_hit_frag_state: Dictionary = hit_frag_state.duplicate(true)
	var hit_x := float(update_hit_xy_state.get("x", 0.0))
	var hit_y := float(update_hit_xy_state.get("y", 0.0))
	var create_frags := bool(update_hit_frag_state.get("createFrags", false))
	var frag_on_hit := bool(update_type_state.get("fragOnHit", true))
	var delay_frags := bool(update_type_state.get("delayFrags", false))
	var frag_bullet: Variant = update_type_state.get("fragBullet", null)
	var frag_bullet_exists := frag_bullet != null
	var frag_bullet_delay_frags := false
	if frag_bullet is Dictionary:
		var frag_bullet_state: Dictionary = frag_bullet
		frag_bullet_delay_frags = bool(frag_bullet_state.get("delayFrags", false))
	var frag_gate_passed := create_frags and frag_on_hit
	var delay_frag_gate_passed := frag_gate_passed and delay_frags and frag_bullet_exists and frag_bullet_delay_frags
	var time_run_call := {}
	var create_frags_call := {}
	if delay_frag_gate_passed:
		time_run_call = {"call": "Time.run(0f, () -> createFrags(b, x, y))", "delay": 0.0, "x": hit_x, "y": hit_y, "scheduled": true}
	elif frag_gate_passed:
		create_frags_call = {"call": "createFrags(b, x, y)", "x": hit_x, "y": hit_y, "called": true}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"hitFrag": update_hit_frag_state,
		"x": hit_x,
		"y": hit_y,
		"createFrags": create_frags,
		"fragOnHit": frag_on_hit,
		"delayFrags": delay_frags,
		"fragBullet": frag_bullet,
		"fragBulletExists": frag_bullet_exists,
		"fragBulletDelayFrags": frag_bullet_delay_frags,
		"fragGatePassed": frag_gate_passed,
		"delayFragGatePassed": delay_frag_gate_passed,
		"timeRunCall": time_run_call,
		"createFragsCall": create_frags_call,
		"fragGateSource": "if(createFrags && fragOnHit)",
		"delayGateSource": "if(delayFrags && fragBullet != null && fragBullet.delayFrags)",
		"timeRunCallSource": "Time.run(0f, () -> createFrags(b, x, y))",
		"createFragsCallSource": "createFrags(b, x, y)",
		"postFragBoundarySource": "createPuddles(b, x, y)",
	}

static func hit_post_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, frag_dispatch_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var update_hit_frag_dispatch_state: Dictionary = frag_dispatch_state.duplicate(true)
	var hit_x := float(update_hit_frag_dispatch_state.get("x", update_hit_xy_state.get("x", 0.0)))
	var hit_y := float(update_hit_frag_dispatch_state.get("y", update_hit_xy_state.get("y", 0.0)))
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"hitFragDispatch": update_hit_frag_dispatch_state,
		"x": hit_x,
		"y": hit_y,
		"createPuddlesCall": {"call": "createPuddles(b, x, y)", "x": hit_x, "y": hit_y, "called": true},
		"createIncendCall": {"call": "createIncend(b, x, y)", "x": hit_x, "y": hit_y, "called": true},
		"createUnitsCall": {"call": "createUnits(b, x, y)", "x": hit_x, "y": hit_y, "called": true},
		"createPuddlesCallSource": "createPuddles(b, x, y)",
		"createIncendCallSource": "createIncend(b, x, y)",
		"createUnitsCallSource": "createUnits(b, x, y)",
		"suppressionBoundarySource": "if(suppressionRange > 0)",
	}

@warning_ignore("shadowed_variable")
static func hit_suppression_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_post_frag_dispatch_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var update_hit_post_frag_dispatch_state: Dictionary = hit_post_frag_dispatch_state.duplicate(true)
	var hit_x := float(update_hit_post_frag_dispatch_state.get("x", update_hit_xy_state.get("x", 0.0)))
	var hit_y := float(update_hit_post_frag_dispatch_state.get("y", update_hit_xy_state.get("y", 0.0)))
	var bullet_x := float(update_bullet_state.get("x", 0.0))
	var bullet_y := float(update_bullet_state.get("y", 0.0))
	var bullet_team: Variant = update_bullet_state.get("team", null)
	var suppression_range := float(update_type_state.get("suppressionRange", -1.0))
	var suppression_duration := float(update_type_state.get("suppressionDuration", SOURCE_BULLET_SUPPRESSION_DURATION_DEFAULT))
	var suppression_effect_chance := float(update_type_state.get("suppressionEffectChance", 50.0))
	var suppress_color: Variant = update_type_state.get("suppressColor", "Pal.sapBullet")
	var suppression_gate_passed := suppression_range > 0.0
	var suppression_vector := {"x": bullet_x, "y": bullet_y}
	var apply_suppression_call := {}
	if suppression_gate_passed:
		apply_suppression_call = {"call": "Damage.applySuppression(b.team, b.x, b.y, suppressionRange, suppressionDuration, 0f, suppressionEffectChance, new Vec2(b.x, b.y), suppressColor)", "team": bullet_team, "x": bullet_x, "y": bullet_y, "range": suppression_range, "reload": suppression_duration, "maxDelay": 0.0, "applyParticleChance": suppression_effect_chance, "source": suppression_vector, "effectColor": suppress_color, "called": true}
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"hitPostFragDispatch": update_hit_post_frag_dispatch_state,
		"x": hit_x,
		"y": hit_y,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"bulletTeam": bullet_team,
		"suppressionRange": suppression_range,
		"suppressionDuration": suppression_duration,
		"suppressionEffectChance": suppression_effect_chance,
		"suppressColor": suppress_color,
		"suppressionGatePassed": suppression_gate_passed,
		"suppressionVector": suppression_vector,
		"applySuppressionCall": apply_suppression_call,
		"suppressionGateSource": "if(suppressionRange > 0)",
		"pooledVec2CommentSource": "//bullets are pooled, require separate Vec2 instance",
		"applySuppressionCallSource": "Damage.applySuppression(b.team, b.x, b.y, suppressionRange, suppressionDuration, 0f, suppressionEffectChance, new Vec2(b.x, b.y), suppressColor)",
		"splashDamageBoundarySource": "createSplashDamage(b, x, y)",
	}

@warning_ignore("shadowed_variable")
static func hit_splash_damage_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_suppression_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_hit_xy_state: Dictionary = hit_xy_state.duplicate(true)
	var update_hit_suppression_state: Dictionary = hit_suppression_state.duplicate(true)
	var hit_x := float(update_hit_suppression_state.get("x", update_hit_xy_state.get("x", 0.0)))
	var hit_y := float(update_hit_suppression_state.get("y", update_hit_xy_state.get("y", 0.0)))
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"hitXY": update_hit_xy_state,
		"hitSuppression": update_hit_suppression_state,
		"x": hit_x,
		"y": hit_y,
		"createSplashDamageCall": {"call": "createSplashDamage(b, x, y)", "x": hit_x, "y": hit_y, "called": true},
		"createSplashDamageCallSource": "createSplashDamage(b, x, y)",
		"createSplashDamageMethodBoundarySource": "public void createSplashDamage(Bullet b, float x, float y)",
		"lightningBoundarySource": "for(int i = 0; i < lightning; i++)",
		"suppressionBoundarySource": "if(suppressionRange > 0)",
	}
