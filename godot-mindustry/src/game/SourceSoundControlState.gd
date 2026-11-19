extends RefCounted
class_name SourceSoundControlState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

# SoundControl.loop() (SoundControl.java:93-117) owns all three
# overloads in this one slice -- they are one method family and
# the two small ones delegate to the 4-arg accumulator:
# `public void loop(Sound sound, float volume){`
# `if(Vars.headless) return;`
# `loop(sound, Core.camera.position, volume);`
# `public void loop(Sound sound, Position pos, float volume){`
# `loop(sound, pos, volume, 1f);`
# `public void loop(Sound sound, Position pos, float volume, float pitch){`
# `if(Vars.headless || sound == Sounds.none || volume <= 0.00001f) return;`
# `float baseVol = sound.calcFalloff(pos.getX(), pos.getY());`
# `float vol = baseVol * volume;`
# `SoundData data = sounds.get(sound, SoundData::new);`
# `data.volume += vol;`
# `data.pitch += pitch * vol;`
# `data.volume = Mathf.clamp(data.volume, 0f, 1f);`
# `data.total += baseVol;`
# `data.totalVolume += vol;`
# `data.sum.add(pos.getX() * baseVol, pos.getY() * baseVol);`
# This is an independent game slice, NOT ambient C: it only
# accumulates numbers into SoundData (SoundControl.java:378-385):
# `protected static class SoundData{`
# `float volume, pitch;`
# `float total;`
# `Vec2 sum = new Vec2();`
# `int soundID;`
# `float curVolume, totalVolume;`
# It does not touch SoundControl.updateLoops() (N2264, held
# waiting for the Windows driver tick B, N2260) and does not
# depend on the RepairTurret driver tick. NO audio playback in
# this slice: loop() only accumulates numbers into SoundData;
# playback belongs to updateLoops (N2264).
# The live values arrive as explicit params: headless from the
# N2259 accessor (SourceGameHeadlessState), the camera position
# (Core.camera.position), Core.audio falloff (Audio.java:13,
# `public float falloff = 16000f;`) and the Sound falloff offset
# (Sound.java:32, `float falloffOffset = 0f;`). The previous
# SoundData for the sound is the `prev` Dictionary -- the
# `sounds.get(sound, SoundData::new)` map lookup
# (SoundControl.java:43, `protected ObjectMap<Sound, SoundData>
# sounds = new ObjectMap<>();`): an empty prev is a fresh
# SoundData, all fields zero. soundID and curVolume are NOT
# written by loop() -- updateLoops owns them -- so they pass
# through unchanged; the other six fields accumulate. The sound
# itself is its name String; Sounds.none is the string "none"
# (the N2222 precedent: `SOURCE_REPAIR_TURRET_AMBIENT_SOUND !=
# "none"` in SourceRepairTurretBuildState.gd).
const SOUND_NONE := "none"
const LOOP_VOLUME_EPSILON := 0.00001
const LOOP_DEFAULT_PITCH := 1.0

static func source_sound_control_loop_state(sound: String, pos_x: float, pos_y: float, volume: float, pitch: float, headless: bool, camera_x: float, camera_y: float, audio_falloff: float, falloff_offset: float, prev: Dictionary) -> Dictionary:
	# The result is the updated SoundData, carried through from
	# prev so a guard return leaves every field exactly where it
	# was (a fresh SoundData reads all zeros, the Java default).
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SOUND_CONTROL_LOOP_STATE,
		"volume": float(prev.get("volume", 0.0)),
		"pitch": float(prev.get("pitch", 0.0)),
		"total": float(prev.get("total", 0.0)),
		"total_volume": float(prev.get("total_volume", 0.0)),
		"sum_x": float(prev.get("sum_x", 0.0)),
		"sum_y": float(prev.get("sum_y", 0.0)),
		"sound_id": int(prev.get("sound_id", 0)),
		"cur_volume": float(prev.get("cur_volume", 0.0)),
	}
	# `if(Vars.headless || sound == Sounds.none || volume <=
	# 0.00001f) return;` (SoundControl.java:104).
	if headless or sound == SOUND_NONE or volume <= LOOP_VOLUME_EPSILON:
		return result
	# Sound.calcFalloff(x, y) (Sound.java:151-157), kept exactly:
	# `public float calcFalloff(float x, float y){`
	# `if(Core.app.isHeadless()) return 1f;`
	# `float dst2 = Math.max(Mathf.dst2(x, y,
	# Core.camera.position.x, Core.camera.position.y) -
	# falloffOffset*falloffOffset, 0f);`
	# `return Mathf.clamp(1f / (dst2 / Core.audio.falloff));`
	# The headless branch is subsumed by the loop guard above:
	# the guard runs before calcFalloff in Java (:104 before
	# :106), and the port's single headless param covers both
	# Vars.headless and Core.app.isHeadless() -- both derive
	# from the same DisplayServer check (N2259, Option 1) -- so
	# the lines below are the non-headless path of calcFalloff.
	# Mathf.dst2(x1, y1, x2, y2) is (x2 - x1) * (x2 - x1) +
	# (y2 - y1) * (y2 - y1) (Mathf.java:656-659), and the
	# one-arg Mathf.clamp(value) is `Math.max(Math.min(value,
	# 1f), 0f)` (Mathf.java:402-404) -- clampf(value, 0.0, 1.0),
	# never "fixed" into a two-bound clamp: it already is one.
	var dx: float = camera_x - pos_x
	var dy: float = camera_y - pos_y
	var dst2: float = maxf(dx * dx + dy * dy - falloff_offset * falloff_offset, 0.0)
	var base_vol: float = clampf(1.0 / (dst2 / audio_falloff), 0.0, 1.0)
	var vol: float = base_vol * volume
	# `data.volume += vol;` then `data.volume =
	# Mathf.clamp(data.volume, 0f, 1f);` (SoundControl.java:110,
	# :112) -- the three-arg clamp, folded into one line.
	result["volume"] = clampf(float(result["volume"]) + vol, 0.0, 1.0)
	# `data.pitch += pitch * vol;` (SoundControl.java:111).
	result["pitch"] = float(result["pitch"]) + pitch * vol
	# `data.total += baseVol;` (SoundControl.java:113).
	result["total"] = float(result["total"]) + base_vol
	# `data.totalVolume += vol;` (SoundControl.java:114).
	result["total_volume"] = float(result["total_volume"]) + vol
	# `data.sum.add(pos.getX() * baseVol, pos.getY() * baseVol);`
	# (SoundControl.java:115) -- the position weighted by
	# baseVol, stored as sum_x / sum_y (the Vec2 sum field,
	# SoundControl.java:381, `Vec2 sum = new Vec2();`).
	result["sum_x"] = float(result["sum_x"]) + pos_x * base_vol
	result["sum_y"] = float(result["sum_y"]) + pos_y * base_vol
	return result

static func source_sound_control_loop_position_state(sound: String, pos_x: float, pos_y: float, volume: float, headless: bool, camera_x: float, camera_y: float, audio_falloff: float, falloff_offset: float, prev: Dictionary) -> Dictionary:
	# loop(Sound, Position, float) (SoundControl.java:99-101):
	# `public void loop(Sound sound, Position pos, float volume){`
	# `loop(sound, pos, volume, 1f);`
	# -- pitch defaults to 1f, and the call delegates to the
	# 4-arg accumulator above; the result is re-stamped with
	# this overload's owner.
	var result: Dictionary = source_sound_control_loop_state(sound, pos_x, pos_y, volume, LOOP_DEFAULT_PITCH, headless, camera_x, camera_y, audio_falloff, falloff_offset, prev)
	result["source_owner"] = source_runtime_owner_registry.PORT_GAME_SOURCE_SOUND_CONTROL_LOOP_POSITION_STATE
	return result

static func source_sound_control_loop_volume_state(sound: String, volume: float, headless: bool, camera_x: float, camera_y: float, audio_falloff: float, falloff_offset: float, prev: Dictionary) -> Dictionary:
	# loop(Sound, float) (SoundControl.java:93-97):
	# `public void loop(Sound sound, float volume){`
	# `if(Vars.headless) return;`
	# `loop(sound, Core.camera.position, volume);`
	# -- the headless guard is enforced by the accumulator the
	# call delegates to, and the sound position IS the camera
	# position, so camera_x / camera_y serve as both the
	# position and the listener. The result is re-stamped with
	# this overload's owner.
	var result: Dictionary = source_sound_control_loop_position_state(sound, camera_x, camera_y, volume, headless, camera_x, camera_y, audio_falloff, falloff_offset, prev)
	result["source_owner"] = source_runtime_owner_registry.PORT_GAME_SOURCE_SOUND_CONTROL_LOOP_VOLUME_STATE
	return result
