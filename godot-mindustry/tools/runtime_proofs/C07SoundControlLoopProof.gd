extends Node

const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_sound_control_state := preload("res://src/game/SourceSoundControlState.gd")

# Core.audio falloff (Audio.java:13, `public float falloff =
# 16000f;`) and the camera (listener) position the falloff is
# measured from. All expectations below are hand-computed from
# SoundControl.java:93-117 + Sound.java:151-157, not from the
# implementation: at the camera dst2 is 0, so baseVol is
# clamp(1 / (0 / 16000)) = clamp(inf) = 1; 400 away on x dst2
# is 160000, so baseVol is 1 / (160000 / 16000) = 0.1; with a
# 100 falloff offset dst2 is 160000 - 10000 = 150000, so baseVol
# is 1 / (150000 / 16000) = 1 / 9.375.
const AUDIO_FALLOFF := 16000.0
const CAM_X := 100.0
const CAM_Y := 200.0


func _ready() -> void:
	# SoundControl.loop() (SoundControl.java:93-117) only
	# accumulates numbers into SoundData
	# (SoundControl.java:378-385): there is no updateLoops key
	# here -- the mixer (C, N2264) waits for B -- and no audio
	# playback key: loop() plays nothing.
	var prev := {"volume": 0.8, "pitch": 0.3, "total": 2.0, "total_volume": 0.7, "sum_x": 10.0, "sum_y": 20.0, "sound_id": 7, "cur_volume": 0.4}

	# 4-arg loop at the camera, fresh SoundData: baseVol 1,
	# vol 0.5 -- volume 0.5, pitch 0.5, total 1, totalVolume
	# 0.5, sum (100, 200).
	var at_camera: Dictionary = source_sound_control_state.source_sound_control_loop_state("beamHeal", CAM_X, CAM_Y, 0.5, 1.0, false, CAM_X, CAM_Y, AUDIO_FALLOFF, 0.0, {})
	var loop_at_camera_full: bool = is_equal_approx(float(at_camera.get("volume", -1.0)), 0.5) and is_equal_approx(float(at_camera.get("pitch", -1.0)), 0.5) and is_equal_approx(float(at_camera.get("total", -1.0)), 1.0) and is_equal_approx(float(at_camera.get("total_volume", -1.0)), 0.5) and is_equal_approx(float(at_camera.get("sum_x", -1.0)), 100.0) and is_equal_approx(float(at_camera.get("sum_y", -1.0)), 200.0)

	# 4-arg loop 400 away on x: baseVol 0.1, vol 0.1 with
	# volume 1 and pitch 2 -- volume 0.1, pitch 0.2, total
	# 0.1, totalVolume 0.1, sum (50, 20).
	var far: Dictionary = source_sound_control_state.source_sound_control_loop_state("beamHeal", 500.0, 200.0, 1.0, 2.0, false, CAM_X, CAM_Y, AUDIO_FALLOFF, 0.0, {})
	var loop_far_falloff: bool = is_equal_approx(float(far.get("volume", -1.0)), 0.1) and is_equal_approx(float(far.get("pitch", -1.0)), 0.2) and is_equal_approx(float(far.get("total", -1.0)), 0.1) and is_equal_approx(float(far.get("total_volume", -1.0)), 0.1) and is_equal_approx(float(far.get("sum_x", -1.0)), 50.0) and is_equal_approx(float(far.get("sum_y", -1.0)), 20.0)

	# 4-arg loop onto a non-empty prev at the camera: volume
	# clamps 0.8 + 0.5 to 1.0, pitch 0.3 + 0.5 to 0.8, total
	# 2 + 1 to 3, totalVolume 0.7 + 0.5 to 1.2, sum (10 +
	# 100, 20 + 200); sound_id 7 and cur_volume 0.4 pass
	# through unchanged (updateLoops owns them).
	var accumulated: Dictionary = source_sound_control_state.source_sound_control_loop_state("beamHeal", CAM_X, CAM_Y, 0.5, 1.0, false, CAM_X, CAM_Y, AUDIO_FALLOFF, 0.0, prev)
	var loop_accumulates_prev: bool = is_equal_approx(float(accumulated.get("volume", -1.0)), 1.0) and is_equal_approx(float(accumulated.get("pitch", -1.0)), 0.8) and is_equal_approx(float(accumulated.get("total", -1.0)), 3.0) and is_equal_approx(float(accumulated.get("total_volume", -1.0)), 1.2) and is_equal_approx(float(accumulated.get("sum_x", -1.0)), 110.0) and is_equal_approx(float(accumulated.get("sum_y", -1.0)), 220.0) and int(accumulated.get("sound_id", -1)) == 7 and is_equal_approx(float(accumulated.get("cur_volume", -1.0)), 0.4)

	# The three guards (SoundControl.java:104) each return the
	# previous SoundData unchanged: headless, Sounds.none,
	# and volume at the 0.00001f threshold.
	var headless_result: Dictionary = source_sound_control_state.source_sound_control_loop_state("beamHeal", CAM_X, CAM_Y, 0.5, 1.0, true, CAM_X, CAM_Y, AUDIO_FALLOFF, 0.0, prev)
	var loop_headless_noop: bool = _matches_prev(headless_result, prev)
	var none_result: Dictionary = source_sound_control_state.source_sound_control_loop_state("none", CAM_X, CAM_Y, 0.5, 1.0, false, CAM_X, CAM_Y, AUDIO_FALLOFF, 0.0, prev)
	var loop_none_sound_noop: bool = _matches_prev(none_result, prev)
	var tiny_result: Dictionary = source_sound_control_state.source_sound_control_loop_state("beamHeal", CAM_X, CAM_Y, 0.00001, 1.0, false, CAM_X, CAM_Y, AUDIO_FALLOFF, 0.0, prev)
	var loop_tiny_volume_noop: bool = _matches_prev(tiny_result, prev)

	# 3-arg loop (SoundControl.java:99-101): pitch defaults to
	# 1f, so at the camera with volume 0.5 the pitch result is
	# 0.5, same as the 4-arg call with pitch 1.
	var positioned: Dictionary = source_sound_control_state.source_sound_control_loop_position_state("beamHeal", CAM_X, CAM_Y, 0.5, false, CAM_X, CAM_Y, AUDIO_FALLOFF, 0.0, {})
	var loop_position_pitch_defaults_one: bool = is_equal_approx(float(positioned.get("volume", -1.0)), 0.5) and is_equal_approx(float(positioned.get("pitch", -1.0)), 0.5) and is_equal_approx(float(positioned.get("total", -1.0)), 1.0) and is_equal_approx(float(positioned.get("total_volume", -1.0)), 0.5) and is_equal_approx(float(positioned.get("sum_x", -1.0)), 100.0) and is_equal_approx(float(positioned.get("sum_y", -1.0)), 200.0)

	# 2-arg loop (SoundControl.java:93-97): the sound position
	# IS the camera position, so with the camera at (300, 400)
	# and volume 0.5 the sum is (300, 400) and the rest matches
	# the at-camera 4-arg call.
	var volumed: Dictionary = source_sound_control_state.source_sound_control_loop_volume_state("beamHeal", 0.5, false, 300.0, 400.0, AUDIO_FALLOFF, 0.0, {})
	var loop_volume_uses_camera_position: bool = is_equal_approx(float(volumed.get("volume", -1.0)), 0.5) and is_equal_approx(float(volumed.get("pitch", -1.0)), 0.5) and is_equal_approx(float(volumed.get("total", -1.0)), 1.0) and is_equal_approx(float(volumed.get("total_volume", -1.0)), 0.5) and is_equal_approx(float(volumed.get("sum_x", -1.0)), 300.0) and is_equal_approx(float(volumed.get("sum_y", -1.0)), 400.0)

	# 4-arg loop with a 100 falloff offset, 400 away on x:
	# baseVol is 1 / 9.375, so volume, pitch, total and
	# totalVolume are all 1 / 9.375 and the sum is (500 / 9.375,
	# 200 / 9.375).
	var base_vol: float = 1.0 / 9.375
	var offset: Dictionary = source_sound_control_state.source_sound_control_loop_state("beamHeal", 500.0, 200.0, 1.0, 1.0, false, CAM_X, CAM_Y, AUDIO_FALLOFF, 100.0, {})
	var loop_falloff_offset: bool = is_equal_approx(float(offset.get("volume", -1.0)), base_vol) and is_equal_approx(float(offset.get("pitch", -1.0)), base_vol) and is_equal_approx(float(offset.get("total", -1.0)), base_vol) and is_equal_approx(float(offset.get("total_volume", -1.0)), base_vol) and is_equal_approx(float(offset.get("sum_x", -1.0)), 500.0 * base_vol) and is_equal_approx(float(offset.get("sum_y", -1.0)), 200.0 * base_vol)

	var proof := {
		"loop_at_camera_full": loop_at_camera_full,
		"loop_far_falloff": loop_far_falloff,
		"loop_accumulates_prev": loop_accumulates_prev,
		"loop_headless_noop": loop_headless_noop,
		"loop_none_sound_noop": loop_none_sound_noop,
		"loop_tiny_volume_noop": loop_tiny_volume_noop,
		"loop_position_pitch_defaults_one": loop_position_pitch_defaults_one,
		"loop_volume_uses_camera_position": loop_volume_uses_camera_position,
		"loop_falloff_offset": loop_falloff_offset,
	}
	proof["matches"] = proof["loop_at_camera_full"] and proof["loop_far_falloff"] and proof["loop_accumulates_prev"] and proof["loop_headless_noop"] and proof["loop_none_sound_noop"] and proof["loop_tiny_volume_noop"] and proof["loop_position_pitch_defaults_one"] and proof["loop_volume_uses_camera_position"] and proof["loop_falloff_offset"]
	proof_state.write_proof("C07SoundControlLoopProof", proof)
	await get_tree().process_frame
	get_tree().quit(proof_state.exit_code(proof))


func _matches_prev(result: Dictionary, prev: Dictionary) -> bool:
	return is_equal_approx(float(result.get("volume", -1.0)), float(prev.get("volume", 0.0))) and is_equal_approx(float(result.get("pitch", -1.0)), float(prev.get("pitch", 0.0))) and is_equal_approx(float(result.get("total", -1.0)), float(prev.get("total", 0.0))) and is_equal_approx(float(result.get("total_volume", -1.0)), float(prev.get("total_volume", 0.0))) and is_equal_approx(float(result.get("sum_x", -1.0)), float(prev.get("sum_x", 0.0))) and is_equal_approx(float(result.get("sum_y", -1.0)), float(prev.get("sum_y", 0.0))) and int(result.get("sound_id", -1)) == int(prev.get("sound_id", 0)) and is_equal_approx(float(result.get("cur_volume", -1.0)), float(prev.get("cur_volume", 0.0)))
