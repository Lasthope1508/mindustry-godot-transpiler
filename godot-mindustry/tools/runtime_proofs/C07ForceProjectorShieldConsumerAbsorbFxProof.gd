extends Node

const main_scene := preload("res://scenes/Main.tscn")
const force_projector_build_state := preload("res://src/game/SourceForceProjectorBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- shieldConsumer absorb FX rows (N2487):
	# the static shieldConsumer lambda
	# (ForceProjector.java:58-70) fires per absorbed
	# BULLET in deflectBullets:
	# `paramBlock.hitSound.at(bullet.x, bullet.y,
	# 1f + Mathf.range(0.1f), paramBlock.
	# hitSoundVolume);` +
	# `paramBlock.absorbEffect.at(bullet);`
	# (:64-65), with hitSound = Sounds.shieldHit
	# (:47), hitSoundVolume 0.12f (:48), and
	# absorbEffect = Fx.absorb (:49). The absorb
	# gate / hit / buildup are live since N2235
	# (the advance's deflect branch reports
	# absorbed_bullets as a pure result), so this
	# pure consumes the caller-supplied absorbed
	# verdict (one entry of the N2235 advance's
	# absorbed_bullets result, per absorbed BULLET)
	# and reports the sound + effect as pure call
	# records (the N2469 precedent -- no sound
	# played, no effect spawned): hit_sound_call
	# {token "shieldHit", x, y, pitch 1f +
	# pitch_roll, volume 0.12} + absorb_effect_call
	# {effect "Fx.absorb", x, y} when absorbed is
	# true, both null otherwise (the N2397
	# null-when-absent precedent). The pitch roll
	# is caller-supplied (NO RNG in the pure, the
	# N2421 precedent). The sound token is exact:
	# the asset is core/assets/sounds/shieldHit.ogg
	# (the N2444 padLaunch precedent); the record
	# uses the N2468 "token" key form. The effect
	# fires AT the bullet (`public void at(Position
	# pos){`, Effect.java:105 -- create at pos.x /
	# pos.y, rotation 0, no extra args). This is a
	# DIFFERENT call site from the absorbExplosion
	# :272 call (live since N2482) -- the N2423 and
	# N2482 pures are unchanged by this slice. The
	# shield is a 6-sided regular polygon of radius
	# 101.7 at rotation 0f, centered on the building
	# at (0, 0) (apothem 88.07): (50, 50) is inside,
	# (95, 50) is outside the hexagon, (200, 0) is
	# outside entirely (the N2235 fixtures).

	# --- FX fires on absorb: absorbed true at
	# (50, 50) with roll 0.0 records the shieldHit
	# call at exactly (50, 50) with pitch 1.0 and
	# volume 0.12, plus the Fx.absorb call at
	# exactly (50, 50).
	var fired: Dictionary = force_projector_build_state.source_force_projector_shield_consumer_absorb_fx_state(true, 50.0, 50.0, 0.0)
	var fired_sound: Dictionary = fired.get("hit_sound_call", {})
	var fired_effect: Dictionary = fired.get("absorb_effect_call", {})
	proof["fx_on_absorb"] = str(fired_sound.get("token", "")) == "shieldHit" and is_equal_approx(float(fired_sound.get("x", -1.0)), 50.0) and is_equal_approx(float(fired_sound.get("y", -1.0)), 50.0) and is_equal_approx(float(fired_sound.get("pitch", -1.0)), 1.0) and is_equal_approx(float(fired_sound.get("volume", -1.0)), 0.12) and str(fired_effect.get("effect", "")) == "Fx.absorb" and is_equal_approx(float(fired_effect.get("x", -1.0)), 50.0) and is_equal_approx(float(fired_effect.get("y", -1.0)), 50.0)

	# --- FX is null when not absorbed: absorbed
	# false records no calls -- even at a
	# different position, so the coords alone
	# never fire the sound or the effect (the
	# N2397 null-when-absent precedent).
	var idle: Dictionary = force_projector_build_state.source_force_projector_shield_consumer_absorb_fx_state(false, 50.0, 50.0, 0.0)
	var idle_moved: Dictionary = force_projector_build_state.source_force_projector_shield_consumer_absorb_fx_state(false, 123.5, -45.25, 0.07)
	proof["fx_null_when_not_absorbed"] = idle.get("hit_sound_call", {}) == null and idle.get("absorb_effect_call", {}) == null and idle_moved.get("hit_sound_call", {}) == null and idle_moved.get("absorb_effect_call", {}) == null

	# --- Sound token: the sound token is exactly
	# "shieldHit" (the N2468 "token" key form) --
	# not the asset file name, not the Sounds.
	# field path -- and the volume is exactly the
	# hitSoundVolume literal 0.12f.
	var tokened: Dictionary = force_projector_build_state.source_force_projector_shield_consumer_absorb_fx_state(true, 10.0, 20.0, 0.0).get("hit_sound_call", {})
	proof["fx_sound_token"] = str(tokened.get("token", "")) == "shieldHit" and str(tokened.get("token", "")) != "shieldHit.ogg" and str(tokened.get("token", "")) != "Sounds.shieldHit" and is_equal_approx(float(tokened.get("volume", -1.0)), 0.12)

	# --- Pitch roll: the pitch is 1f + the
	# caller-supplied roll -- 1.07 at roll 0.07,
	# 0.9 at roll -0.1 (the [-0.1, 0.1] bound of
	# Mathf.range(0.1f)), 1.0 at roll 0.0. The
	# pure never rolls (NO RNG in pures).
	var pitched: Dictionary = force_projector_build_state.source_force_projector_shield_consumer_absorb_fx_state(true, 10.0, 20.0, 0.07).get("hit_sound_call", {})
	var pitched_low: Dictionary = force_projector_build_state.source_force_projector_shield_consumer_absorb_fx_state(true, 10.0, 20.0, -0.1).get("hit_sound_call", {})
	var pitched_flat: Dictionary = force_projector_build_state.source_force_projector_shield_consumer_absorb_fx_state(true, 10.0, 20.0, 0.0).get("hit_sound_call", {})
	proof["fx_pitch_roll"] = is_equal_approx(float(pitched.get("pitch", -1.0)), 1.07) and is_equal_approx(float(pitched_low.get("pitch", -1.0)), 0.9) and is_equal_approx(float(pitched_flat.get("pitch", -1.0)), 1.0)

	# --- Position: both calls land at exactly
	# (bullet_x, bullet_y) -- (123.5, -45.25)
	# here, and (0, 0) at the building center;
	# the pure passes the bullet position through
	# untouched, with no offset or rounding.
	var placed_sound: Dictionary = force_projector_build_state.source_force_projector_shield_consumer_absorb_fx_state(true, 123.5, -45.25, 0.0).get("hit_sound_call", {})
	var placed_effect: Dictionary = force_projector_build_state.source_force_projector_shield_consumer_absorb_fx_state(true, 123.5, -45.25, 0.0).get("absorb_effect_call", {})
	var placed_center_sound: Dictionary = force_projector_build_state.source_force_projector_shield_consumer_absorb_fx_state(true, 0.0, 0.0, 0.0).get("hit_sound_call", {})
	var placed_center_effect: Dictionary = force_projector_build_state.source_force_projector_shield_consumer_absorb_fx_state(true, 0.0, 0.0, 0.0).get("absorb_effect_call", {})
	proof["fx_position"] = is_equal_approx(float(placed_sound.get("x", -1.0)), 123.5) and is_equal_approx(float(placed_sound.get("y", -1.0)), -45.25) and is_equal_approx(float(placed_effect.get("x", -1.0)), 123.5) and is_equal_approx(float(placed_effect.get("y", -1.0)), -45.25) and is_equal_approx(float(placed_center_sound.get("x", -1.0)), 0.0) and is_equal_approx(float(placed_center_sound.get("y", -1.0)), 0.0) and is_equal_approx(float(placed_center_effect.get("x", -1.0)), 0.0) and is_equal_approx(float(placed_center_effect.get("y", -1.0)), 0.0)

	# --- Live input: the N2235 deflect verdict is
	# the input -- the live advance over the N2235
	# bullet fixtures absorbs ["center", "inside"]
	# (buildup delta 10 + 5 = 15, hit set to 1.0),
	# so the FX fires for the absorbed "inside"
	# bullet at (50, 50) with pitch 1.07 at roll
	# 0.07, and stays null for the "corner" bullet
	# at (95, 50), which the hexagon rejects.
	var shield_frame := {"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 1.0, "warmup": 1.0, "buildup": 0.0, "broken": false, "hit": 0.0}
	var bullet_center := {"id": "center", "x": 0.0, "y": 0.0, "team": 1, "absorbable": true, "absorbed": false, "shield_damage": 10.0}
	var bullet_inside := {"id": "inside", "x": 50.0, "y": 50.0, "team": 1, "absorbable": true, "absorbed": false, "shield_damage": 5.0}
	var bullet_corner := {"id": "corner", "x": 95.0, "y": 50.0, "team": 1, "absorbable": true, "absorbed": false, "shield_damage": 7.0}
	var bullet_far := {"id": "far", "x": 200.0, "y": 0.0, "team": 1, "absorbable": true, "absorbed": false, "shield_damage": 3.0}
	var bullet_ally := {"id": "ally", "x": 0.0, "y": 0.0, "team": 0, "absorbable": true, "absorbed": false, "shield_damage": 10.0}
	var bullet_heavy := {"id": "heavy", "x": 0.0, "y": 0.0, "team": 1, "absorbable": false, "absorbed": false, "shield_damage": 10.0}
	var bullet_spent := {"id": "spent", "x": 0.0, "y": 0.0, "team": 1, "absorbable": true, "absorbed": true, "shield_damage": 10.0}
	var deflect: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(shield_frame, 1.0, 1.0, 0.0, 0.0, [bullet_center, bullet_inside, bullet_corner, bullet_far, bullet_ally, bullet_heavy, bullet_spent], false)
	var absorbed_ids: Array = deflect.get("absorbed_bullets", [])
	var live_fx: Dictionary = force_projector_build_state.source_force_projector_shield_consumer_absorb_fx_state(absorbed_ids.has("inside"), 50.0, 50.0, 0.07)
	var live_sound: Dictionary = live_fx.get("hit_sound_call", {})
	var live_effect: Dictionary = live_fx.get("absorb_effect_call", {})
	var live_miss_fx: Dictionary = force_projector_build_state.source_force_projector_shield_consumer_absorb_fx_state(absorbed_ids.has("corner"), 95.0, 50.0, 0.07)
	proof["fx_live_input"] = absorbed_ids == ["center", "inside"] and is_equal_approx(float(deflect.get("buildup_delta", -1.0)), 15.0) and is_equal_approx(float(deflect.get("hit", -1.0)), 1.0) and str(live_sound.get("token", "")) == "shieldHit" and is_equal_approx(float(live_sound.get("pitch", -1.0)), 1.07) and is_equal_approx(float(live_sound.get("x", -1.0)), 50.0) and is_equal_approx(float(live_sound.get("y", -1.0)), 50.0) and str(live_effect.get("effect", "")) == "Fx.absorb" and is_equal_approx(float(live_effect.get("x", -1.0)), 50.0) and is_equal_approx(float(live_effect.get("y", -1.0)), 50.0) and live_miss_fx.get("hit_sound_call", {}) == null and live_miss_fx.get("absorb_effect_call", {}) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ForceProjectorShieldConsumerAbsorbFxProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
