extends Node

const main_scene := preload("res://scenes/Main.tscn")
const launch_pad_build_state := preload("res://src/game/SourceLaunchPadBuildState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# --- Launch FX rows (N2444): the launch sound +
	# effect + shake (LaunchPad.java:149/156/158)
	# reported as pure call records. The launch fire
	# itself is ALREADY LIVE since N2238 (the
	# full-and-timed gate, the stacks copy,
	# items.clear(), the launchCounter = 0f reset,
	# exposing launched + launched_stacks) and the pod
	# descriptor since N2397, so this pure consumes
	# the N2238 launched gate: `launchSound.at(x, y,
	# 1f + Mathf.range(launchSoundPitchRand));` +
	# `Fx.launchPod.at(this);` + `Effect.shake(3f, 3f,
	# this);`. The sound is Sounds.padLaunch
	# (LaunchPad.java:34, asset padLaunch.ogg), the
	# pitch is 1f + the caller-supplied roll in
	# [-0.1, 0.1] (Mathf.range(launchSoundPitchRand),
	# arc Mathf.range(r) = random(-r, r) -- NO RNG in
	# the pure, the N2421 precedent), the effect is
	# Fx.launchPod (Fx.java:2747), and the shake is
	# intensity 3f / duration 3f (Effect.shake, Effect.
	# java:210-212 delegates to :201). No sound is
	# played, no effect spawned, no camera shaken --
	# the audio/effect call sites wait for their own
	# slices.

	# --- Null when not launched: no launch, no
	# sound/FX -- even with a nonzero pitch roll, a
	# false launched gate reports all three calls null
	# (the N2397 null-when-absent precedent).
	var idle: Dictionary = launch_pad_build_state.source_launch_pad_launch_effect_state(false, 240.0, 180.0, 0.07)
	var idle_empty: Dictionary = launch_pad_build_state.source_launch_pad_launch_effect_state(false, 16.0, 32.0, -0.1)
	proof["effect_null_when_not_launched"] = idle.get("sound_call", {}) == null and idle.get("fx_call", {}) == null and idle.get("shake_call", {}) == null and idle_empty.get("sound_call", {}) == null and idle_empty.get("fx_call", {}) == null and idle_empty.get("shake_call", {}) == null

	# --- Sound pitch: pitch is 1f + pitch_roll --
	# 1.0 at a zero roll, 1.1 at the +0.1 bound, 0.9
	# at the -0.1 bound (Mathf.range(0.1f) spans
	# [-0.1, 0.1], arc Mathf.java:220-222); the sound
	# token is padLaunch (Sounds.padLaunch, LaunchPad.
	# java:34) and the call rides the pad's x/y.
	var pitched: Dictionary = launch_pad_build_state.source_launch_pad_launch_effect_state(true, 240.0, 180.0, 0.07)
	var pitched_sound: Dictionary = pitched.get("sound_call", {})
	var pitched_high: Dictionary = launch_pad_build_state.source_launch_pad_launch_effect_state(true, 240.0, 180.0, 0.1).get("sound_call", {})
	var pitched_low: Dictionary = launch_pad_build_state.source_launch_pad_launch_effect_state(true, 240.0, 180.0, -0.1).get("sound_call", {})
	var pitched_zero: Dictionary = launch_pad_build_state.source_launch_pad_launch_effect_state(true, 240.0, 180.0, 0.0).get("sound_call", {})
	proof["effect_sound_pitch"] = str(pitched_sound.get("sound", "")) == "padLaunch" and is_equal_approx(float(pitched_sound.get("pitch", -1.0)), 1.07) and is_equal_approx(float(pitched_high.get("pitch", -1.0)), 1.1) and is_equal_approx(float(pitched_low.get("pitch", -1.0)), 0.9) and is_equal_approx(float(pitched_zero.get("pitch", -1.0)), 1.0) and is_equal_approx(float(pitched_sound.get("x", -1.0)), 240.0) and is_equal_approx(float(pitched_sound.get("y", -1.0)), 180.0)

	# --- FX call: the effect is launchPod
	# (Fx.launchPod, Fx.java:2747), fired at the pad
	# -- `.at(this)` positions it at the pad's x/y.
	var fired: Dictionary = launch_pad_build_state.source_launch_pad_launch_effect_state(true, 240.0, 180.0, 0.0)
	var fired_fx: Dictionary = fired.get("fx_call", {})
	proof["effect_fx_call"] = str(fired_fx.get("effect", "")) == "launchPod" and is_equal_approx(float(fired_fx.get("x", -1.0)), 240.0) and is_equal_approx(float(fired_fx.get("y", -1.0)), 180.0)

	# --- Shake params: intensity 3f, duration 3f
	# (Effect.shake(3f, 3f, this), LaunchPad.java:158
	# -- the Position overload, Effect.java:210-212,
	# delegates to shake(intensity, duration, x, y),
	# Effect.java:201), at the pad's x/y.
	var fired_shake: Dictionary = fired.get("shake_call", {})
	proof["effect_shake_params"] = is_equal_approx(float(fired_shake.get("intensity", -1.0)), 3.0) and is_equal_approx(float(fired_shake.get("duration", -1.0)), 3.0) and is_equal_approx(float(fired_shake.get("x", -1.0)), 240.0) and is_equal_approx(float(fired_shake.get("y", -1.0)), 180.0)

	# --- X/Y passthrough: all three calls carry the
	# pad's world position untouched, at a second
	# position (16.0, 32.0) with a nonzero roll.
	var other: Dictionary = launch_pad_build_state.source_launch_pad_launch_effect_state(true, 16.0, 32.0, -0.04)
	var other_sound: Dictionary = other.get("sound_call", {})
	var other_fx: Dictionary = other.get("fx_call", {})
	var other_shake: Dictionary = other.get("shake_call", {})
	proof["effect_xy_passthrough"] = is_equal_approx(float(other_sound.get("x", -1.0)), 16.0) and is_equal_approx(float(other_sound.get("y", -1.0)), 32.0) and is_equal_approx(float(other_fx.get("x", -1.0)), 16.0) and is_equal_approx(float(other_fx.get("y", -1.0)), 32.0) and is_equal_approx(float(other_shake.get("x", -1.0)), 16.0) and is_equal_approx(float(other_shake.get("y", -1.0)), 32.0) and is_equal_approx(float(other_sound.get("pitch", -1.0)), 0.96)

	# --- Live frame values: a placed launch-pad's
	# frame launches through the N2238 advance and
	# the effect pure reads launched from the live
	# frame. The pad holds a full load (copper 60 +
	# lead 40 = 100 = itemCapacity) with launchCounter
	# 1199.0 at the driver launchTime stamp 1200f
	# (launch-pad, Blocks.java:6794) and efficiency
	# 1.0; one N2238 advance tick (delta 1.0, timeScale
	# 1.0) adds edelta = efficiency * delta * timeScale
	# = 1.0, so the counter reaches 1200f with a full
	# pad -- the launch fires, the stacks copy out, the
	# items clear, and the counter resets to 0f. The
	# effect pure then reads launched from that live
	# advance (pitch roll 0.05, caller-supplied).
	var launch_pad_cell := Vector2i(28, 21)
	var launch_pad := Sprite2D.new()
	game.add_child(launch_pad)
	game.call("record_placed_block", launch_pad, blocks_by_id["launch-pad"], launch_pad_cell)
	launch_pad_build_state.source_launch_pad_bind_frame_state(launch_pad, blocks_by_id["launch-pad"])
	var launch_pad_frame: Dictionary = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	launch_pad_frame["efficiency"] = 1.0
	launch_pad_frame["launch_counter"] = 1199.0
	launch_pad_frame["launch_time"] = 60.0 * 20.0
	launch_pad_frame["items"] = {"copper": 60, "lead": 40}
	var advanced: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state(launch_pad_frame, 1.0, 1.0, 100)
	launch_pad_frame["launch_counter"] = float(advanced.get("launch_counter", -1.0))
	launch_pad_frame["items"] = advanced.get("items", {})
	launch_pad_frame["launched"] = bool(advanced.get("launched", false))
	launch_pad_frame["launched_stacks"] = advanced.get("launched_stacks", {})
	var live: Dictionary = launch_pad_build_state.source_launch_pad_launch_effect_state(bool(launch_pad_frame.get("launched", false)), 240.0, 180.0, 0.05)
	var live_sound: Dictionary = live.get("sound_call", {})
	var live_fx: Dictionary = live.get("fx_call", {})
	var live_shake: Dictionary = live.get("shake_call", {})
	proof["effect_live_frame_values"] = bool(advanced.get("launched", false)) and advanced.get("launched_stacks", {}) == {"copper": 60, "lead": 40} and launch_pad_frame.get("items", {"x": 1}) == {} and is_equal_approx(float(launch_pad_frame.get("launch_counter", -1.0)), 0.0) and live.get("sound_call", null) != null and str(live_sound.get("sound", "")) == "padLaunch" and is_equal_approx(float(live_sound.get("pitch", -1.0)), 1.05) and str(live_fx.get("effect", "")) == "launchPod" and is_equal_approx(float(live_shake.get("intensity", -1.0)), 3.0) and is_equal_approx(float(live_shake.get("duration", -1.0)), 3.0) and is_equal_approx(float(live_fx.get("x", -1.0)), 240.0) and is_equal_approx(float(live_fx.get("y", -1.0)), 180.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaunchPadLaunchEffectProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
