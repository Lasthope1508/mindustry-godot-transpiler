extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
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

	# --- updateTile offload effects rows (N2469):
	# the shake + drillSound + drillEffect call
	# records (BurstDrill.java:114-118) reported as
	# one pure-only pure. The STATE is ALREADY LIVE
	# since N2219 (the advance + the offload itself)
	# and the timerDump dump is live since N2282,
	# so this pure consumes the caller-evaluated
	# gates: cycle_complete = the :106 branch verdict
	# (`if(dominantItems > 0 && progress >=
	# drillTime && items.total() < itemCapacity){`)
	# and was_visible = the :114 gate
	# (`if(wasVisible){`): `Effect.shake(shake,
	# shake, this);` + `drillSound.at(x, y, 1f +
	# Mathf.range(drillSoundPitchRand),
	# drillSoundVolume);` + `drillEffect.at(x +
	# Mathf.range(drillEffectRnd), y + Mathf.range(
	# drillEffectRnd), dominantItem.color);`. The
	# fields are the block fields (shake 2f,
	# drillSound Sounds.drillImpact, drillSoundVolume
	# 0.6f, drillSoundPitchRand 0.1f, drillEffectRnd
	# 0f, drillEffect Fx.shockwave, BurstDrill.
	# java:18/32-33/41-42). The effect is
	# Fx.shockwave (`shockwave = new Effect(10f,
	# 80f, e -> {`, Fx.java:1625) with the dominant
	# item's color (Item.color, Item.java:19 --
	# caller-supplied, not a def lookup). The sound
	# token is drillImpact (drillImpact.ogg --
	# Sounds is build-generated, the N2444 padLaunch
	# precedent). The pitch roll (Mathf.range(0.1f)
	# in [-0.1, 0.1]) and the two effect position
	# rolls (Mathf.range(drillEffectRnd)) are
	# ALREADY-ROLLED caller-supplied inputs -- NO
	# RNG in the pure (the N2421 precedent).
	# drillEffectRnd stays 0f for both defs
	# (BurstDrill.java:41, no def override), so the
	# effect spawns at (x, y) exactly. The pure
	# records the CLASS defaults: both defs override
	# shake = 4f (Blocks.java:3077/:3106) and
	# drillEffect to a MultiEffect (:3076 /
	# :3100-3105), so the per-def rows wait for
	# their own slice (the N2304 per-def precedent).
	# No sound is played, no effect spawned, no
	# camera shaken -- the audio/effect call sites
	# wait for their own slices.

	# --- Effects fire: cycle complete + visible
	# fires all three records. At (100, 200) with a
	# pitch roll of 0.05, zero position rolls and a
	# copper-ish dominant color, the shake is 2.0/
	# 2.0, the sound is drillImpact at pitch 1.0 +
	# 0.05 = 1.05, volume 0.6, and the effect is
	# Fx.shockwave at (100, 200) with the dominant
	# color.
	var fired: Dictionary = burst_drill_build_state.source_burst_drill_offload_effects_state(true, true, 100.0, 200.0, 0.05, 0.0, 0.0, Color(1.0, 0.5, 0.25))
	var fired_shake: Dictionary = fired.get("shake_call", {})
	var fired_sound: Dictionary = fired.get("drill_sound_call", {})
	var fired_effect: Dictionary = fired.get("drill_effect_call", {})
	var fired_color: Color = fired_effect.get("color", Color(0.0, 0.0, 0.0))
	proof["effects_fire"] = is_equal_approx(float(fired_shake.get("intensity", -1.0)), 2.0) and is_equal_approx(float(fired_shake.get("duration", -1.0)), 2.0) and str(fired_sound.get("sound", "")) == "drillImpact" and is_equal_approx(float(fired_sound.get("x", -1.0)), 100.0) and is_equal_approx(float(fired_sound.get("y", -1.0)), 200.0) and is_equal_approx(float(fired_sound.get("pitch", -1.0)), 1.05) and is_equal_approx(float(fired_sound.get("volume", -1.0)), 0.6) and str(fired_effect.get("effect", "")) == "Fx.shockwave" and is_equal_approx(float(fired_effect.get("x", -1.0)), 100.0) and is_equal_approx(float(fired_effect.get("y", -1.0)), 200.0) and is_equal_approx(fired_color.r, 1.0) and is_equal_approx(fired_color.g, 0.5) and is_equal_approx(fired_color.b, 0.25)

	# --- Cycle gate: no cycle complete, no records
	# -- even when visible, with a nonzero pitch
	# roll and nonzero position rolls (the N2397
	# null-when-absent precedent).
	var idle_cycle: Dictionary = burst_drill_build_state.source_burst_drill_offload_effects_state(false, true, 100.0, 200.0, 0.1, 3.5, -2.5, Color(1.0, 0.5, 0.25))
	proof["effects_gate_cycle"] = idle_cycle.get("shake_call", {}) == null and idle_cycle.get("drill_sound_call", {}) == null and idle_cycle.get("drill_effect_call", {}) == null

	# --- Visible gate: not visible, no records --
	# even with a completed cycle, a nonzero pitch
	# roll and nonzero position rolls (the N2397
	# null-when-absent precedent).
	var idle_visible: Dictionary = burst_drill_build_state.source_burst_drill_offload_effects_state(true, false, 100.0, 200.0, -0.1, 3.5, -2.5, Color(1.0, 0.5, 0.25))
	proof["effects_gate_visible"] = idle_visible.get("shake_call", {}) == null and idle_visible.get("drill_sound_call", {}) == null and idle_visible.get("drill_effect_call", {}) == null

	# --- Pitch: pitch is 1f + pitch_roll -- 1.0 at
	# a zero roll, 1.1 at the +0.1 bound, 0.9 at the
	# -0.1 bound (Mathf.range(0.1f) spans [-0.1,
	# 0.1], arc Mathf.java:220-222); the sound token
	# is drillImpact (Sounds.drillImpact,
	# BurstDrill.java:32) and the volume is
	# drillSoundVolume 0.6f (:33).
	var pitched_high: Dictionary = burst_drill_build_state.source_burst_drill_offload_effects_state(true, true, 100.0, 200.0, 0.1, 0.0, 0.0, Color(1.0, 0.5, 0.25)).get("drill_sound_call", {})
	var pitched_low: Dictionary = burst_drill_build_state.source_burst_drill_offload_effects_state(true, true, 100.0, 200.0, -0.1, 0.0, 0.0, Color(1.0, 0.5, 0.25)).get("drill_sound_call", {})
	var pitched_zero: Dictionary = burst_drill_build_state.source_burst_drill_offload_effects_state(true, true, 100.0, 200.0, 0.0, 0.0, 0.0, Color(1.0, 0.5, 0.25)).get("drill_sound_call", {})
	proof["effects_pitch"] = str(pitched_high.get("sound", "")) == "drillImpact" and is_equal_approx(float(pitched_high.get("pitch", -1.0)), 1.1) and is_equal_approx(float(pitched_low.get("pitch", -1.0)), 0.9) and is_equal_approx(float(pitched_zero.get("pitch", -1.0)), 1.0) and is_equal_approx(float(pitched_high.get("volume", -1.0)), 0.6) and is_equal_approx(float(pitched_low.get("volume", -1.0)), 0.6)

	# --- Position: the effect lands at (x +
	# effect_roll_x, y + effect_roll_y) -- (103.5,
	# 197.5) for rolls (3.5, -2.5), and exactly
	# (100, 200) for zero rolls (drillEffectRnd is
	# 0f for both defs, BurstDrill.java:41, so the
	# live effect spawns at (x, y) exactly -- but
	# the pure still takes the rolls as inputs, so
	# the formula stays Java-exact).
	var placed: Dictionary = burst_drill_build_state.source_burst_drill_offload_effects_state(true, true, 100.0, 200.0, 0.0, 3.5, -2.5, Color(1.0, 0.5, 0.25)).get("drill_effect_call", {})
	var placed_zero: Dictionary = burst_drill_build_state.source_burst_drill_offload_effects_state(true, true, 100.0, 200.0, 0.0, 0.0, 0.0, Color(1.0, 0.5, 0.25)).get("drill_effect_call", {})
	proof["effects_position"] = str(placed.get("effect", "")) == "Fx.shockwave" and is_equal_approx(float(placed.get("x", -1.0)), 103.5) and is_equal_approx(float(placed.get("y", -1.0)), 197.5) and is_equal_approx(float(placed_zero.get("x", -1.0)), 100.0) and is_equal_approx(float(placed_zero.get("y", -1.0)), 200.0)

	# --- Color: the effect color is the caller-
	# supplied dominant item color, passed through
	# untouched -- a second color proves the pure
	# does not hardcode one (the color comes from
	# the item def, Item.color, Item.java:19, not a
	# def lookup in the pure).
	var colored: Dictionary = burst_drill_build_state.source_burst_drill_offload_effects_state(true, true, 100.0, 200.0, 0.0, 0.0, 0.0, Color(0.0, 0.75, 1.0)).get("drill_effect_call", {})
	var colored_value: Color = colored.get("color", Color(0.0, 0.0, 0.0))
	proof["effects_color"] = str(colored.get("effect", "")) == "Fx.shockwave" and is_equal_approx(colored_value.r, 0.0) and is_equal_approx(colored_value.g, 0.75) and is_equal_approx(colored_value.b, 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillOffloadEffectsRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
