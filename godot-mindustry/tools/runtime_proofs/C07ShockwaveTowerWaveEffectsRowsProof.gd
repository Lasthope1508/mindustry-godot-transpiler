extends Node

const main_scene := preload("res://scenes/Main.tscn")
const shockwave_tower_build_state := preload("res://src/game/SourceShockwaveTowerBuildState.gd")
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

	# --- Wave effects / sound / shake rows
	# (N2470): the wave effect + sound + shake
	# (ShockwaveTower.java:84-86) and the
	# per-target hit effect (:95) reported as pure
	# call records. The STATE is ALREADY LIVE
	# since N2247 (the fire gate + bullet scan +
	# wave damage + fire reset + heat decay), so
	# this pure consumes the caller-evaluated fired
	# gate (the N2247 fire verdict): `if(targets.
	# size > 0){` + `waveEffect.at(x, y, range,
	# waveColor);` + `shootSound.at(x, y, 1f +
	# Mathf.range(0.15f), 1f);` + `Effect.shake(
	# shake, shake, this);` + `for(var target :
	# targets){` + `hitEffect.at(target.x,
	# target.y, waveColor);`. The fields are
	# Fx.pointShockwave / Fx.hitSquaresColor
	# (Fx.java:223/890), Sounds.shockwaveTower
	# (shockwaveTower.ogg -- Sounds is build-
	# generated, the N2444 padLaunch precedent),
	# waveColor Pal.accent (Pal.java:79), shake 2f
	# (ShockwaveTower.java:29). The pitch roll is
	# an ALREADY-ROLLED caller-supplied input
	# (Mathf.range(0.15f) in [-0.15, 0.15]) -- NO
	# RNG in the pure (the N2421 precedent). DEF
	# BEATS CLASS: the shockwave-tower def sets
	# range = 170f (Blocks.java:2043) over the
	# class range 110f (:25); the pure takes range
	# as a param. No sound is played, no effect
	# spawned, no camera shaken -- the audio/effect
	# call sites wait for their own slices.

	# --- Wave fires: fired with two targets fires
	# all four records. The tower is at (100, 200)
	# with the def range 170.0; the wave effect is
	# Fx.pointShockwave at (100, 200) with range
	# 170.0 and color Pal.accent; the sound is
	# shockwaveTower at pitch 1.0 + 0.1 = 1.1,
	# volume 1.0; the shake is 2.0/2.0; the hit
	# list has one call per target (2).
	var fired_targets: Array = [{"x": 120.0, "y": 210.0}, {"x": 90.0, "y": 190.0}]
	var fired: Dictionary = shockwave_tower_build_state.source_shockwave_tower_wave_effects_state(true, 100.0, 200.0, 170.0, 0.1, fired_targets)
	var fired_wave: Dictionary = fired.get("wave_effect_call", {})
	var fired_sound: Dictionary = fired.get("shoot_sound_call", {})
	var fired_shake: Dictionary = fired.get("shake_call", {})
	var fired_hits: Array = fired.get("hit_effect_calls", [])
	proof["wave_fires"] = str(fired_wave.get("token", "")) == "Fx.pointShockwave" and is_equal_approx(float(fired_wave.get("x", -1.0)), 100.0) and is_equal_approx(float(fired_wave.get("y", -1.0)), 200.0) and is_equal_approx(float(fired_wave.get("range", -1.0)), 170.0) and str(fired_wave.get("color", "")) == "Pal.accent" and str(fired_sound.get("token", "")) == "shockwaveTower" and is_equal_approx(float(fired_sound.get("pitch", -1.0)), 1.1) and is_equal_approx(float(fired_sound.get("volume", -1.0)), 1.0) and is_equal_approx(float(fired_shake.get("intensity", -1.0)), 2.0) and is_equal_approx(float(fired_shake.get("duration", -1.0)), 2.0) and fired_hits.size() == 2

	# --- Wave gate: no fire, no records -- even
	# with targets and a nonzero pitch roll (the
	# N2397 null-when-absent precedent). The hit
	# list is empty, not null -- the pure always
	# returns an Array for the hit calls.
	var idle: Dictionary = shockwave_tower_build_state.source_shockwave_tower_wave_effects_state(false, 100.0, 200.0, 170.0, 0.1, fired_targets)
	var idle_hits: Array = idle.get("hit_effect_calls", [{}])
	proof["wave_gate"] = idle.get("wave_effect_call", {}) == null and idle.get("shoot_sound_call", {}) == null and idle.get("shake_call", {}) == null and idle_hits.is_empty()

	# --- Wave pitch: pitch is 1f + pitch_roll --
	# 1.0 at a zero roll, 1.15 at the +0.15 bound,
	# 0.85 at the -0.15 bound (Mathf.range(0.15f)
	# spans [-0.15, 0.15], arc Mathf.java:220-222);
	# the sound token is shockwaveTower
	# (Sounds.shockwaveTower, ShockwaveTower.
	# java:32) and the volume is the literal 1f
	# (:85).
	var pitched_high: Dictionary = shockwave_tower_build_state.source_shockwave_tower_wave_effects_state(true, 100.0, 200.0, 170.0, 0.15, []).get("shoot_sound_call", {})
	var pitched_low: Dictionary = shockwave_tower_build_state.source_shockwave_tower_wave_effects_state(true, 100.0, 200.0, 170.0, -0.15, []).get("shoot_sound_call", {})
	var pitched_zero: Dictionary = shockwave_tower_build_state.source_shockwave_tower_wave_effects_state(true, 100.0, 200.0, 170.0, 0.0, []).get("shoot_sound_call", {})
	proof["wave_pitch"] = str(pitched_high.get("token", "")) == "shockwaveTower" and is_equal_approx(float(pitched_high.get("pitch", -1.0)), 1.15) and is_equal_approx(float(pitched_low.get("pitch", -1.0)), 0.85) and is_equal_approx(float(pitched_zero.get("pitch", -1.0)), 1.0) and is_equal_approx(float(pitched_high.get("volume", -1.0)), 1.0) and is_equal_approx(float(pitched_low.get("volume", -1.0)), 1.0)

	# --- Wave range / color: the range param is
	# passed through untouched -- the def 170.0
	# (Blocks.java:2043) and the class 110.0
	# (ShockwaveTower.java:25) both land in the
	# wave call as-is; the color is Pal.accent
	# (Pal.java:79) in the wave call and in every
	# hit call.
	var ranged_def: Dictionary = shockwave_tower_build_state.source_shockwave_tower_wave_effects_state(true, 100.0, 200.0, 170.0, 0.0, [{"x": 120.0, "y": 210.0}])
	var ranged_def_wave: Dictionary = ranged_def.get("wave_effect_call", {})
	var ranged_def_hits: Array = ranged_def.get("hit_effect_calls", [])
	var ranged_def_hit: Dictionary = ranged_def_hits[0] if ranged_def_hits.size() > 0 else {}
	var ranged_class: Dictionary = shockwave_tower_build_state.source_shockwave_tower_wave_effects_state(true, 100.0, 200.0, 110.0, 0.0, []).get("wave_effect_call", {})
	proof["wave_range_color"] = is_equal_approx(float(ranged_def_wave.get("range", -1.0)), 170.0) and str(ranged_def_wave.get("color", "")) == "Pal.accent" and is_equal_approx(float(ranged_class.get("range", -1.0)), 110.0) and str(ranged_class.get("color", "")) == "Pal.accent" and str(ranged_def_hit.get("color", "")) == "Pal.accent"

	# --- Hit per target: one hit call per target,
	# in Java loop order -- three targets give
	# three calls, each Fx.hitSquaresColor at the
	# target position with color Pal.accent.
	var three_targets: Array = [{"x": 120.0, "y": 210.0}, {"x": 90.0, "y": 190.0}, {"x": 150.0, "y": 160.0}]
	var three_hits: Array = shockwave_tower_build_state.source_shockwave_tower_wave_effects_state(true, 100.0, 200.0, 170.0, 0.0, three_targets).get("hit_effect_calls", [])
	var hit_first: Dictionary = three_hits[0] if three_hits.size() > 0 else {}
	var hit_second: Dictionary = three_hits[1] if three_hits.size() > 1 else {}
	var hit_third: Dictionary = three_hits[2] if three_hits.size() > 2 else {}
	proof["hit_per_target"] = three_hits.size() == 3 and str(hit_first.get("token", "")) == "Fx.hitSquaresColor" and is_equal_approx(float(hit_first.get("x", -1.0)), 120.0) and is_equal_approx(float(hit_first.get("y", -1.0)), 210.0) and str(hit_first.get("color", "")) == "Pal.accent" and str(hit_second.get("token", "")) == "Fx.hitSquaresColor" and is_equal_approx(float(hit_second.get("x", -1.0)), 90.0) and is_equal_approx(float(hit_second.get("y", -1.0)), 190.0) and str(hit_second.get("color", "")) == "Pal.accent" and str(hit_third.get("token", "")) == "Fx.hitSquaresColor" and is_equal_approx(float(hit_third.get("x", -1.0)), 150.0) and is_equal_approx(float(hit_third.get("y", -1.0)), 160.0) and str(hit_third.get("color", "")) == "Pal.accent"

	# --- Hit empty: fired with no targets gives
	# an empty hit list -- but the wave / sound /
	# shake still fire (the hit list follows the
	# targets, not the gate; Java never produces
	# fired-with-no-targets, since the gate is
	# targets.size > 0 -- the pure reports what
	# the caller supplies).
	var no_targets: Dictionary = shockwave_tower_build_state.source_shockwave_tower_wave_effects_state(true, 100.0, 200.0, 170.0, 0.0, [])
	var no_targets_hits: Array = no_targets.get("hit_effect_calls", [{}])
	proof["hit_empty"] = no_targets_hits.is_empty() and no_targets.get("wave_effect_call", {}) != null and no_targets.get("shoot_sound_call", {}) != null and no_targets.get("shake_call", {}) != null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerWaveEffectsRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
