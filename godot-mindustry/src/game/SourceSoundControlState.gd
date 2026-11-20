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

static func source_sound_control_should_play_state(music_vol: int) -> Dictionary:
	# SoundControl.shouldPlay() (SoundControl.java:369-371):
	# `protected boolean shouldPlay(){`
	# `return Core.settings.getInt("musicvol") > 0;`
	# -- the comparison is strict (> 0): a zero or negative
	# music volume reads false. The caller reads the gate
	# every frame (SoundControl.java:304):
	# `if(!shouldPlay()){`
	# and silences the current track when it is false
	# (SoundControl.java:305-306, `current.setVolume(0);`).
	# The Core.settings accessor is NOT ported in this slice:
	# music_vol arrives as an explicit int param.
	return {"should_play": music_vol > 0}

static func source_sound_control_is_playing_state(has_current: bool, current_is_playing: bool) -> Dictionary:
	# SoundControl.isPlaying() (SoundControl.java:251-253):
	# `public boolean isPlaying(){`
	# `return current != null && current.isPlaying();`
	# over the current track (SoundControl.java:34):
	# `protected @Nullable Music current;`
	# -- the null check short-circuits: no current track reads
	# false whatever current_is_playing says. has_current and
	# current_is_playing arrive as explicit params; no Music
	# play / stop calls in this slice. NO audio playback in
	# this slice: these are pure gates, playback belongs to
	# updateLoops (N2264, held waiting for B).
	return {"is_playing": has_current and current_is_playing}

static func source_sound_control_always_play_music_state(rules_always_play_music: bool, setting_alwaysmusic: bool, planet_always_play_music: bool) -> Dictionary:
	# SoundControl.alwaysPlayMusic() (SoundControl.java:266-268):
	# `protected boolean alwaysPlayMusic(){`
	# `return state.rules.alwaysPlayMusic || Core.settings.getBool("alwaysmusic") || (state.getPlanet() != null && state.getPlanet().alwaysPlayMusic);`
	# -- a plain OR of the three flags: any single true flag
	# reads true, all false reads false. The three flags
	# arrive as explicit bool params: rules_always_play_music
	# is state.rules.alwaysPlayMusic, setting_alwaysmusic is
	# Core.settings "alwaysmusic", and
	# planet_always_play_music is (state.getPlanet() != null
	# && state.getPlanet().alwaysPlayMusic) -- the null check
	# is folded into the param, no Planet object is ported
	# in this slice. The caller reads the gate in update()
	# (SoundControl.java:181-183, `if(alwaysPlayMusic()){`
	# + `if(current == null){` + `playRandom();`) and plays
	# a random track when it is true and no current track
	# is set. NO audio playback in this slice: this is a
	# pure gate; playback belongs to updateLoops (N2304,
	# held waiting for B).
	return {"always_play_music": rules_always_play_music or setting_alwaysmusic or planet_always_play_music}

static func source_sound_control_is_dark_state(has_core: bool, core_healthf: float, wave_chance_roll: bool, enemy_chance_roll: bool) -> Dictionary:
	# SoundControl.isDark() (SoundControl.java:285-299):
	# `/** Whether to play dark music.*/`
	# `protected boolean isDark(){`
	# `if(player.team().data().hasCore() && player.team().data().core().healthf() < 0.85f){`
	# `//core damaged -> dark`
	# `return true;`
	# `}`
	# `//it may be dark based on wave`
	# `if(Mathf.chance((float)(Math.log10((state.wave - 17f)/19f) + 1) / 4f)){`
	# `return true;`
	# `}`
	# `//dark based on enemies`
	# `return Mathf.chance(state.enemies / 70f + 0.1f);`
	# `}`
	# -- the decision tree, kept exactly: a damaged core
	# (hasCore() and healthf() strictly below 0.85f) reads
	# dark at once; otherwise the wave roll decides, then
	# the enemy roll. The two Mathf.chance calls are the
	# RNG of this slice -- the first RNG slice of the Game
	# family -- and their OUTCOMES arrive as explicit bool
	# params: wave_chance_roll is
	# `Mathf.chance((float)(Math.log10((state.wave -
	# 17f)/19f) + 1) / 4f)` and enemy_chance_roll is
	# `Mathf.chance(state.enemies / 70f + 0.1f)`, so this
	# function is pure and never rolls RNG itself
	# (Mathf.chance is `d >= 1f || rand.nextFloat() < d`,
	# Mathf.java:240-242; the caller draws the rolls).
	# The wave / enemy counts and the probability formulas
	# are NOT re-evaluated here: each roll outcome already
	# folds its formula in. The caller reads the gate in
	# playRandom() (SoundControl.java:259,
	# `}else if(isDark()){`) and plays a dark track when
	# it is true. NO audio playback in this slice: this is
	# a pure gate; playback belongs to updateLoops (N2304,
	# held waiting for B).
	if has_core and core_healthf < 0.85:
		return {"is_dark": true}
	if wave_chance_roll:
		return {"is_dark": true}
	return {"is_dark": enemy_chance_roll}

static func source_sound_control_get_boss_music_state(has_rules_dark_music: bool, rules_dark_music: Array, has_planet_dark_music: bool, planet_dark_music: Array, boss_music: Array) -> Dictionary:
	# SoundControl.getBossMusic() (SoundControl.java:270-273):
	# `protected Seq<Music> getBossMusic(){`
	# `if(state.rules.darkMusic != null) return state.rules.darkMusic.map(MusicContainer::get).removeAll(m -> m == null);`
	# `return state.getPlanet() != null && state.getPlanet().darkMusic != null ? state.getPlanet().darkMusic : bossMusic;`
	# `}`
	# -- the boss music list: the rules list with nulls
	# removed when rules.darkMusic is set, else the planet
	# darkMusic when set, else the bossMusic field
	# (SoundControl.java:27, `public Seq<Music> bossMusic
	# = Seq.with();`). QUIRK, kept exactly: boss reads the
	# SHARED rules / planet darkMusic here -- it has no
	# field of its own in these branches -- only the
	# fallback is its own (dark reads the same lists,
	# SoundControl.java:281-282, and falls back to
	# darkMusic). Music arrives as its name String (the
	# N2287 precedent); the MusicContainer::get resolution
	# (MusicContainer.java:18-24, lazy
	# `SoundControl.findMusic(name)`, null when the asset
	# is not found) is folded into the caller param --
	# the container accessor chain is NOT ported in this
	# slice (the N2315 precedent) -- while the
	# `.removeAll(m -> m == null)` filter IS ported: a
	# fresh Array of the non-null names, in order, and
	# the inputs are never mutated. The null checks arrive
	# as explicit bool params (the N2306 precedent --
	# GDScript typed Array params cannot take null):
	# has_rules_dark_music is `state.rules.darkMusic !=
	# null` and has_planet_dark_music is `state.getPlanet()
	# != null && state.getPlanet().darkMusic != null`; a
	# seq param is only read when its flag is true. The
	# planet / fallback branches return the seq as-is,
	# matching Java aliasing. The caller picks a random
	# track from the list in playRandom()
	# (SoundControl.java:258,
	# `playOnce(getBossMusic().random(lastRandomPlayed));`).
	# NO audio playback in this slice: this is a pure
	# getter; playback belongs to updateLoops (N2304,
	# held waiting for B).
	if has_rules_dark_music:
		var filtered: Array = []
		for music in rules_dark_music:
			if music != null:
				filtered.append(music)
		return {"boss_music": filtered}
	if has_planet_dark_music:
		return {"boss_music": planet_dark_music}
	return {"boss_music": boss_music}

static func source_sound_control_get_ambient_music_state(has_rules_ambient_music: bool, rules_ambient_music: Array, has_planet_ambient_music: bool, planet_ambient_music: Array, ambient_music: Array) -> Dictionary:
	# SoundControl.getAmbientMusic() (SoundControl.java:275-278):
	# `protected Seq<Music> getAmbientMusic(){`
	# `if(state.rules.ambientMusic != null) return state.rules.ambientMusic.map(MusicContainer::get).removeAll(m -> m == null);`
	# `return state.getPlanet() != null && state.getPlanet().ambientMusic != null ? state.getPlanet().ambientMusic : ambientMusic;`
	# `}`
	# -- the ambient music list: the rules list with nulls
	# removed when rules.ambientMusic is set, else the
	# planet ambientMusic when set, else the ambientMusic
	# field (SoundControl.java:23, `public Seq<Music>
	# ambientMusic = Seq.with();`). Same shape as
	# getBossMusic above, with its own rules / planet /
	# field lists. Music arrives as its name String; the
	# MusicContainer::get resolution is folded into the
	# caller param (NOT ported, the N2315 precedent) and
	# the `.removeAll(m -> m == null)` filter IS ported
	# into a fresh Array, inputs never mutated. The null
	# checks arrive as explicit bool params (the N2306
	# precedent -- GDScript typed Array params cannot take
	# null): has_rules_ambient_music is
	# `state.rules.ambientMusic != null` and
	# has_planet_ambient_music is `state.getPlanet() !=
	# null && state.getPlanet().ambientMusic != null`; a
	# seq param is only read when its flag is true. The
	# planet / fallback branches return the seq as-is,
	# matching Java aliasing. The caller picks a random
	# track from the list in playRandom()
	# (SoundControl.java:262,
	# `playOnce(getAmbientMusic().random(lastRandomPlayed));`).
	# NO audio playback in this slice: this is a pure
	# getter; playback belongs to updateLoops (N2304,
	# held waiting for B).
	if has_rules_ambient_music:
		var filtered: Array = []
		for music in rules_ambient_music:
			if music != null:
				filtered.append(music)
		return {"ambient_music": filtered}
	if has_planet_ambient_music:
		return {"ambient_music": planet_ambient_music}
	return {"ambient_music": ambient_music}

static func source_sound_control_get_dark_music_state(has_rules_dark_music: bool, rules_dark_music: Array, has_planet_dark_music: bool, planet_dark_music: Array, dark_music: Array) -> Dictionary:
	# SoundControl.getDarkMusic() (SoundControl.java:280-283):
	# `protected Seq<Music> getDarkMusic(){`
	# `if(state.rules.darkMusic != null) return state.rules.darkMusic.map(MusicContainer::get).removeAll(m -> m == null);`
	# `return state.getPlanet() != null && state.getPlanet().darkMusic != null ? state.getPlanet().darkMusic : darkMusic;`
	# `}`
	# -- the dark music list: the rules list with nulls
	# removed when rules.darkMusic is set, else the planet
	# darkMusic when set, else the darkMusic field
	# (SoundControl.java:25, `public Seq<Music> darkMusic
	# = Seq.with();`). QUIRK, kept exactly: the rules line
	# above is byte-identical to the boss getter's
	# (SoundControl.java:271) -- boss and dark read the
	# SAME rules / planet darkMusic, ported verbatim, NOT
	# "fixed"; only the fallback differs (darkMusic here,
	# bossMusic for boss). Music arrives as its name
	# String; the MusicContainer::get resolution is folded
	# into the caller param (NOT ported, the N2315
	# precedent) and the `.removeAll(m -> m == null)`
	# filter IS ported into a fresh Array, inputs never
	# mutated. The null checks arrive as explicit bool
	# params (the N2306 precedent -- GDScript typed Array
	# params cannot take null): has_rules_dark_music is
	# `state.rules.darkMusic != null` and
	# has_planet_dark_music is `state.getPlanet() != null
	# && state.getPlanet().darkMusic != null`; a seq param
	# is only read when its flag is true. The planet /
	# fallback branches return the seq as-is, matching
	# Java aliasing. The caller picks a random track from
	# the list in playRandom() (SoundControl.java:260,
	# `playOnce(getDarkMusic().random(lastRandomPlayed));`).
	# NO audio playback in this slice: this is a pure
	# getter; playback belongs to updateLoops (N2304,
	# held waiting for B).
	if has_rules_dark_music:
		var filtered: Array = []
		for music in rules_dark_music:
			if music != null:
				filtered.append(music)
		return {"dark_music": filtered}
	if has_planet_dark_music:
		return {"dark_music": planet_dark_music}
	return {"dark_music": dark_music}
