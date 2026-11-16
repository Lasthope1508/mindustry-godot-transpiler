extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mend_projector_build_state := preload("res://src/game/SourceMendProjectorBuildState.gd")
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

	# --- MendProjector mendSound rows (N2504):
	# MendBuild.updateTile() heal branch
	# (MendProjector.java:106-122) fires
	# `mendSound.at(this, 1f + Mathf.range(0.1f),
	# mendSoundVolume);` (:120) ONCE PER TICK --
	# after the eachBlock lambda (:112-117), gated
	# on `if(any){` (:119-121) -- not once per
	# healed building, unlike the Fx.healBlockFull
	# effect (:115, live since N2484). The heal
	# scan is live since N2242 (the pure
	# source_mend_projector_heal_scan_state), so
	# this pure consumes the caller-supplied
	# any_healed verdict (the N2242 scan's "any"
	# result key -- true iff at least one
	# candidate was healed) and reports the sound
	# as a pure call record (the N2487 precedent
	# -- no sound played): mend_sound_call {token
	# "healWave", x, y, pitch 1.0 + pitch_roll,
	# volume 0.5} when any_healed is true, null
	# otherwise (the N2397 null-when-absent
	# precedent). mendSound is Sounds.healWave
	# (`public Sound mendSound = Sounds.healWave;`,
	# MendProjector.java:32; the Sounds class is
	# build-generated (mindustry.gen.Sounds, no
	# gen/ dir in the upstream checkout), but the
	# token is exact: the asset is
	# core/assets/sounds/block/healWave.ogg, the
	# N2444 padLaunch precedent) and the volume is
	# the literal mendSoundVolume 0.5f (`public
	# float mendSoundVolume = 0.5f;`, MendProjector.
	# java:33); neither def overrides either
	# (Blocks.java:1919-1942). The call passes
	# `this` (the building, a Position), so the
	# Position overload (`public int at(Position
	# pos, float pitch, float volume){`, arc
	# Sound.java:180-182) fires at the building
	# x/y. The pitch roll is caller-supplied in
	# [-0.1, 0.1] (Mathf.range(r) is the arc
	# uniform roll in [-r, r], arc Mathf.
	# java:220-222) -- NO RNG in the pure (the
	# N2421 precedent). The record uses the
	# "token" key form (the N2487 precedent --
	# the N2469/N2444 "sound" key form is NOT
	# used here). The recentlyHealed (:114) row
	# defers under its own entry.

	# --- Sound fires on heal: any_healed true at
	# the building (40, 24) with roll 0.0 records
	# the healWave call at exactly (40, 24) with
	# pitch 1.0 and volume 0.5.
	var fired: Dictionary = mend_projector_build_state.source_mend_projector_mend_sound_state(true, 40.0, 24.0, 0.0)
	var fired_call: Dictionary = fired.get("mend_sound_call", {})
	proof["sound_on_heal"] = str(fired_call.get("token", "")) == "healWave" and is_equal_approx(float(fired_call.get("x", -1.0)), 40.0) and is_equal_approx(float(fired_call.get("y", -1.0)), 24.0) and is_equal_approx(float(fired_call.get("pitch", -1.0)), 1.0) and is_equal_approx(float(fired_call.get("volume", -1.0)), 0.5)

	# --- Sound is null when not healed:
	# any_healed false records no call -- even at
	# a different position with a nonzero roll, so
	# the coords alone never fire the sound (the
	# N2397 null-when-absent precedent).
	var idle: Dictionary = mend_projector_build_state.source_mend_projector_mend_sound_state(false, 40.0, 24.0, 0.0)
	var idle_moved: Dictionary = mend_projector_build_state.source_mend_projector_mend_sound_state(false, 123.5, -45.25, 0.07)
	proof["sound_null_when_not_healed"] = idle.get("mend_sound_call", {}) == null and idle_moved.get("mend_sound_call", {}) == null

	# --- Sound token: the sound token is exactly
	# "healWave" (the N2487 "token" key form) --
	# not the asset file name, not the Sounds.
	# field path -- and the volume is exactly the
	# mendSoundVolume literal 0.5f.
	var tokened: Dictionary = mend_projector_build_state.source_mend_projector_mend_sound_state(true, 10.0, 20.0, 0.0).get("mend_sound_call", {})
	proof["sound_token"] = str(tokened.get("token", "")) == "healWave" and str(tokened.get("token", "")) != "healWave.ogg" and str(tokened.get("token", "")) != "Sounds.healWave" and is_equal_approx(float(tokened.get("volume", -1.0)), 0.5)

	# --- Pitch roll: the pitch is 1f + the
	# caller-supplied roll -- 1.07 at roll 0.07,
	# 0.9 at roll -0.1 (the [-0.1, 0.1] bound of
	# Mathf.range(0.1f)), 1.0 at roll 0.0. The
	# pure never rolls (NO RNG in pures).
	var pitched: Dictionary = mend_projector_build_state.source_mend_projector_mend_sound_state(true, 10.0, 20.0, 0.07).get("mend_sound_call", {})
	var pitched_low: Dictionary = mend_projector_build_state.source_mend_projector_mend_sound_state(true, 10.0, 20.0, -0.1).get("mend_sound_call", {})
	var pitched_flat: Dictionary = mend_projector_build_state.source_mend_projector_mend_sound_state(true, 10.0, 20.0, 0.0).get("mend_sound_call", {})
	proof["sound_pitch_roll"] = is_equal_approx(float(pitched.get("pitch", -1.0)), 1.07) and is_equal_approx(float(pitched_low.get("pitch", -1.0)), 0.9) and is_equal_approx(float(pitched_flat.get("pitch", -1.0)), 1.0)

	# --- Position: the call lands at exactly
	# (x, y) -- (123.5, -45.25) here, and (0, 0)
	# at the building center; the pure passes the
	# building position through untouched, with no
	# offset or rounding.
	var placed: Dictionary = mend_projector_build_state.source_mend_projector_mend_sound_state(true, 123.5, -45.25, 0.0).get("mend_sound_call", {})
	var placed_center: Dictionary = mend_projector_build_state.source_mend_projector_mend_sound_state(true, 0.0, 0.0, 0.0).get("mend_sound_call", {})
	proof["sound_position"] = is_equal_approx(float(placed.get("x", -1.0)), 123.5) and is_equal_approx(float(placed.get("y", -1.0)), -45.25) and is_equal_approx(float(placed_center.get("x", -1.0)), 0.0) and is_equal_approx(float(placed_center.get("y", -1.0)), 0.0)

	# --- Live input: the N2242 heal verdict is
	# the input -- a charged mender (charge 199 +
	# heat 1 * delta 1 = 200 >= reload 200) with
	# one damaged, unsuppressed candidate heals
	# it for 100 * 4 / 100 * 1 = 4.0 (any true)
	# and the sound fires at the building (0, 0)
	# with pitch 1.07 at roll 0.07; the same tick
	# with a healthy candidate heals nothing (any
	# false, no amounts) and the sound is null.
	var live_frame: Dictionary = {"phase_heat": 0.0, "efficiency": 1.0, "heat": 1.0}
	var live_candidates: Array = [{"damaged": true, "heal_suppressed": false, "max_health": 100.0, "x": 40.0, "y": 24.0, "size": 1, "block": "mender"}]
	var live_scan: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state(live_frame, live_candidates, 199.0, 200.0, 40.0, 4.0, 4.0, 20.0, 1.0, 1.0)
	var live_amounts: Array = live_scan.get("heal_amounts", [])
	var live_fx: Dictionary = mend_projector_build_state.source_mend_projector_mend_sound_state(bool(live_scan.get("any", false)), 0.0, 0.0, 0.07)
	var live_call: Dictionary = live_fx.get("mend_sound_call", {})
	var live_miss_candidates: Array = [{"damaged": false, "heal_suppressed": false, "max_health": 100.0, "x": 40.0, "y": 24.0, "size": 1, "block": "mender"}]
	var live_miss_scan: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state(live_frame, live_miss_candidates, 199.0, 200.0, 40.0, 4.0, 4.0, 20.0, 1.0, 1.0)
	var live_miss_fx: Dictionary = mend_projector_build_state.source_mend_projector_mend_sound_state(bool(live_miss_scan.get("any", true)), 0.0, 0.0, 0.07)
	proof["sound_live_input"] = bool(live_scan.get("any", false)) and bool(live_scan.get("scanned", false)) and is_equal_approx(float(live_scan.get("real_range", -1.0)), 40.0) and live_amounts.size() == 1 and is_equal_approx(float(live_amounts[0]), 4.0) and str(live_call.get("token", "")) == "healWave" and is_equal_approx(float(live_call.get("pitch", -1.0)), 1.07) and is_equal_approx(float(live_call.get("x", -1.0)), 0.0) and is_equal_approx(float(live_call.get("y", -1.0)), 0.0) and is_equal_approx(float(live_call.get("volume", -1.0)), 0.5) and bool(live_miss_scan.get("any", true)) == false and Array(live_miss_scan.get("heal_amounts", [0])).is_empty() and live_miss_fx.get("mend_sound_call", {}) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MendProjectorMendSoundRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
