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

static func source_sound_control_find_music_state(has_name: bool, name: String, assets: Dictionary) -> Dictionary:
	# SoundControl.findMusic(String) (SoundControl.java:387-395):
	# `public static @Nullable Music findMusic(String name){`
	# `if(name == null) return null;`
	# `Music cached = Core.assets.getOrNull(name, Music.class);`
	# `if(cached == null) cached = Core.assets.getOrNull(name + ".ogg", Music.class);`
	# `if(cached == null) cached = Core.assets.getOrNull(name + ".mp3", Music.class);`
	# `if(cached == null) cached = Core.assets.getOrNull("music/" + name + ".ogg", Music.class);`
	# `if(cached == null) cached = Core.assets.getOrNull("music/" + name + ".mp3", Music.class);`
	# `return cached;`
	# `}`
	# -- the static music lookup MusicContainer.get() reads
	# (MusicContainer.java:18-24, lazy
	# `SoundControl.findMusic(name)`, null when the asset
	# is not found): a null name reads null at once, else
	# the first of the five Core.assets.getOrNull branches
	# that hits, in exactly this order, else null. The
	# order is kept exactly, NOT "fixed": the `.ogg`
	# branch runs before `.mp3`, and the `music/` branches
	# run after the plain ones. The function is static
	# and reads no instance state. The Core.assets lookup
	# arrives as an explicit Dictionary param -- the asset
	# registry, lookup key (String) -> resolved asset
	# name (String); a missing key reads null, exactly
	# `Core.assets.getOrNull(key, Music.class)`. Music
	# arrives as its resolved name String (the N2287
	# precedent: the sound itself is its name String);
	# the returned value is the registry value -- the
	# resolved name -- not the lookup key. The null name
	# arrives as an explicit bool param (the N2306
	# precedent -- GDScript typed String params cannot
	# take null): has_name is `name != null`, and an
	# unset name is passed as "" with has_name false.
	# This slice does NOT depend on the three N2326
	# music getters: findMusic stands alone, it resolves
	# one name at a time and never reads a music list.
	# NO audio playback in this slice: this only resolves
	# a name, NO audio is loaded; playback belongs to
	# updateLoops (N2304, held waiting for B).
	if not has_name:
		return {"found_music": null}
	var found = assets.get(name, null)
	if found == null:
		found = assets.get(name + ".ogg", null)
	if found == null:
		found = assets.get(name + ".mp3", null)
	if found == null:
		found = assets.get("music/" + name + ".ogg", null)
	if found == null:
		found = assets.get("music/" + name + ".mp3", null)
	return {"found_music": found}

static func source_sound_control_play_state(has_music: bool, music: String, has_current: bool, current: String, fade: float, silenced: bool, should_play: bool, music_vol: int, time_delta: float, fin_time: float, fout_time: float) -> Dictionary:
	# SoundControl.play(@Nullable Music) (SoundControl.java:303-353):
	# `protected void play(@Nullable Music music){`
	# `if(!shouldPlay()){`
	# `current.setVolume(0);`
	# `fade = 0f;`
	# `return;`
	# `}`
	# `current.setVolume(fade * Core.settings.getInt("musicvol") / 100f);`
	# `if(silenced){`
	# `return;`
	# `}`
	# `if(current == null && music != null){`
	# `current = music;`
	# `current.setLooping(true);`
	# `current.setVolume(fade = 0f);`
	# `current.play();`
	# `silenced = false;`
	# `}else if(current == music && music != null){`
	# `fade = Mathf.clamp(fade + Time.delta /finTime);`
	# `}else if(current != null){`
	# `fade = Mathf.clamp(fade - Time.delta /foutTime);`
	# `if(fade <= 0.01f){`
	# `current.stop();`
	# `current = null;`
	# `silenced = true;`
	# `if(music != null){`
	# `current = music;`
	# `current.setVolume(fade = 0f);`
	# `current.setLooping(true);`
	# `current.play();`
	# `silenced = false;`
	# `}`
	# `}`
	# `}`
	# `}`
	# -- the fade state machine, kept exactly: the caller
	# drives it every frame (SoundControl.java:301-302,
	# "This must be called every frame"). The shouldPlay()
	# gate (N2299, `return Core.settings.getInt("musicvol")
	# > 0;`) arrives as the explicit should_play param and
	# music_vol is Core.settings "musicvol". The one-arg
	# Mathf.clamp(value) is `Math.max(Math.min(value, 1f),
	# 0f)` (Mathf.java:402-404) -- clampf(value, 0.0, 1.0),
	# never "fixed" into a two-bound clamp: it already is
	# one. Time.delta arrives as time_delta; finTime /
	# foutTime arrive as fin_time / fout_time:
	# `public float finTime = 120f, foutTime = 120f, musicInterval = 3f * Time.toMinutes, musicChance = 0.8f, musicWaveChance = 0.46f;`
	# (SoundControl.java:20). The state
	# fields arrive as explicit params (the N2306
	# precedent -- GDScript typed String params cannot
	# take null): has_music is `music != null`, has_current
	# is `current != null` (SoundControl.java:34,
	# `protected @Nullable Music current;`), fade is
	# `protected float fade;`, silenced is `protected
	# boolean silenced, keepSilent;`. Music arrives as its
	# name String (the N2287 precedent); `current == music`
	# compares those names, the port's identity for a
	# track. The playback calls -- current.play() /
	# stop() / setVolume() / setLooping() -- are NOT
	# executed here: they are returned as playback-command
	# state, one Dictionary per call in order (`track`,
	# `action`, `value` when the call takes one), so the
	# driver applies them. QUIRK, kept exactly: the two
	# new-track branches order the calls differently --
	# the fresh start does setLooping then setVolume then
	# play, the fade-out restart does setVolume then
	# setLooping then play -- ported verbatim, NOT
	# unified. Another quirk, kept exactly: the silenced
	# early return runs AFTER the volume update, so a
	# silenced machine still issues a setVolume command
	# each frame. NO audio playback in this slice: this
	# only computes state + commands; playback belongs
	# to updateLoops (N2304, held waiting for B).
	var out_current = current if has_current else null
	var out_fade: float = fade
	var out_silenced: bool = silenced
	var commands: Array = []
	# `if(!shouldPlay()){` + `if(current != null){` +
	# `current.setVolume(0);` + `fade = 0f;` + `return;`
	# (SoundControl.java:304-310) -- the muted gate mutes
	# the current track and zeroes fade, whatever else.
	if not should_play:
		if has_current:
			commands.append({"track": current, "action": "set_volume", "value": 0.0})
		out_fade = 0.0
		return {"current": out_current, "fade": out_fade, "silenced": out_silenced, "commands": commands}
	# `if(current != null){` +
	# `current.setVolume(fade * Core.settings.getInt("musicvol") / 100f);`
	# (SoundControl.java:313-315) -- update volume of
	# current track, from the fade BEFORE this frame's
	# fade step, so a fade-in / fade-out frame plays the
	# old fade's volume.
	if has_current:
		commands.append({"track": current, "action": "set_volume", "value": out_fade * float(music_vol) / 100.0})
	# `if(silenced){` + `return;` (SoundControl.java:318-320)
	# -- do not update once the track has faded out
	# completely, just stop: the volume update above has
	# already run, so a silenced machine still issues it.
	if out_silenced:
		return {"current": out_current, "fade": out_fade, "silenced": out_silenced, "commands": commands}
	# `if(current == null && music != null){` -- begin
	# playing in a new track (SoundControl.java:322-328).
	if not has_current and has_music:
		out_current = music
		commands.append({"track": music, "action": "set_looping", "value": true})
		out_fade = 0.0
		commands.append({"track": music, "action": "set_volume", "value": 0.0})
		commands.append({"track": music, "action": "play"})
		out_silenced = false
	# `}else if(current == music && music != null){` --
	# fade in the playing track (SoundControl.java:329-331).
	elif has_current and has_music and current == music:
		out_fade = clampf(out_fade + time_delta / fin_time, 0.0, 1.0)
	# `}else if(current != null){` -- fade out the current
	# track (SoundControl.java:332-348).
	elif has_current:
		out_fade = clampf(out_fade - time_delta / fout_time, 0.0, 1.0)
		# `if(fade <= 0.01f){` -- stop current track when
		# it hits 0 volume (SoundControl.java:334-346).
		if out_fade <= 0.01:
			commands.append({"track": current, "action": "stop"})
			out_current = null
			out_silenced = true
			# `if(music != null){` -- play newly scheduled
			# track (SoundControl.java:340-346).
			if has_music:
				out_current = music
				out_fade = 0.0
				commands.append({"track": music, "action": "set_volume", "value": 0.0})
				commands.append({"track": music, "action": "set_looping", "value": true})
				commands.append({"track": music, "action": "play"})
				out_silenced = false
	return {"current": out_current, "fade": out_fade, "silenced": out_silenced, "commands": commands}

static func source_sound_control_silence_state(has_current: bool, current: String, fade: float, silenced: bool, should_play: bool, music_vol: int, time_delta: float, fin_time: float, fout_time: float) -> Dictionary:
	# SoundControl.silence() (SoundControl.java:374-376):
	# `protected void silence(){`
	# `play(null);`
	# `}`
	# -- fades out the current track, unless it has already
	# been silenced: silence IS play(null), so this
	# delegates to the play state machine with no music
	# and returns its result unchanged -- no separate
	# fade logic, no separate slice. The caller is
	# update() (SoundControl.java:176, `silence();`) when
	# leaving the menu for ingame music. NO audio
	# playback in this slice: this only computes state +
	# commands; playback belongs to updateLoops (N2304,
	# held waiting for B).
	return source_sound_control_play_state(false, "", has_current, current, fade, silenced, should_play, music_vol, time_delta, fin_time, fout_time)

static func source_sound_control_keep_silent_state(keep_silent: bool) -> Dictionary:
	# SoundControl.keepSilent() (SoundControl.java:197-199):
	# `public void keepSilent(){`
	# `keepSilent = true;`
	# `}`
	# -- only sets the flag (SoundControl.java:36,
	# `protected boolean silenced, keepSilent;`) that
	# update() consumes (SoundControl.java:160-162,
	# `if(keepSilent){` + `keepSilent = false;` +
	# `stop();`): the old value arrives as the keep_silent
	# param -- the field being written, carried like the
	# other state fields -- and is overwritten
	# unconditionally, exactly as Java ignores it. This
	# slice does NOT port update(): update() also needs
	# playRandom (G4b) + updateLoops (N2304, held). NO
	# audio playback in this slice.
	return {"keep_silent": true}

const RELOAD_AMBIENT_MUSIC := ["game1", "game3", "game6", "game8", "game9", "fine"]
const RELOAD_DARK_MUSIC := ["game2", "game5", "game7", "game4"]
const RELOAD_BOSS_MUSIC := ["boss1", "boss2", "game2", "game5"]
const RELOAD_UI_FOLDER := "ui"

static func source_sound_control_reload_state(has_current: bool, current: String, fade: float, sound_parents: Dictionary) -> Dictionary:
	# SoundControl.reload() (SoundControl.java:75-91):
	# `protected void reload(){`
	# `current = null;`
	# `fade = 0f;`
	# `ambientMusic = Seq.with(Musics.game1, Musics.game3, Musics.game6, Musics.game8, Musics.game9, Musics.fine);`
	# `darkMusic = Seq.with(Musics.game2, Musics.game5, Musics.game7, Musics.game4);`
	# `bossMusic = Seq.with(Musics.boss1, Musics.boss2, Musics.game2, Musics.game5);`
	# `for(var sound : Core.assets.getAll(Sound.class, new Seq<>())){`
	# `var file = Fi.get(Core.assets.getAssetFileName(sound));`
	# `if(file.parent().name().equals("ui")){`
	# `sound.setBus(uiBus);`
	# `}`
	# `}`
	# `Events.fire(new MusicRegisterEvent());`
	# `}`
	# -- reload rebuilds the three music lists from the
	# Musics fields, in exactly this order, and assigns
	# the uiBus to every Sound asset whose file sits in
	# the "ui" folder, then fires a MusicRegisterEvent.
	# The lists are rebuilt from scratch every call:
	# `public Seq<Music> ambientMusic = Seq.with();`
	# `public Seq<Music> darkMusic = Seq.with();`
	# `public Seq<Music> bossMusic = Seq.with();`
	# (SoundControl.java:23, :25, :27) are the fields
	# being overwritten. Music arrives as its name
	# String (the N2287 precedent): the Musics field
	# names are the asset names -- game1..game9, fine,
	# boss1, boss2 all exist as core/assets/music/*.ogg
	# in the upstream checkout. The old current / fade
	# arrive as explicit params -- `protected @Nullable
	# Music current;` (SoundControl.java:34) and
	# `protected float fade;` (:35), with has_current
	# folding the null check (the N2306 precedent) --
	# and are overwritten unconditionally, exactly as
	# Java ignores them (the keepSilent precedent,
	# N2336): reload resets them to null / 0 whatever
	# they were. The asset enumeration
	# (`Core.assets.getAll(Sound.class, new Seq<>())`)
	# and the file-name resolution
	# (`Fi.get(Core.assets.getAssetFileName(sound))`
	# + `file.parent().name()`) arrive folded into one
	# explicit Dictionary param -- sound name ->
	# parent folder name -- and the
	# `file.parent().name().equals("ui")` check IS
	# ported, case-sensitive, in order. The
	# bus assignment is returned as state: ui_bus_sounds
	# lists the sounds assigned to the uiBus field
	# (`public AudioBus uiBus = new AudioBus();`,
	# SoundControl.java:29). `Events.fire(new
	# MusicRegisterEvent());` is evidence only -- the
	# event system is NOT ported in this slice. reload()
	# is called from `Events.on(ClientLoadEvent.class, e
	# -> reload());` (SoundControl.java:46); the caller
	# is NOT ported here. NO audio playback in this
	# slice: this only computes state + the
	# bus-assignment list; playback belongs to
	# updateLoops (N2304, held waiting for B).
	var ambient_music: Array = RELOAD_AMBIENT_MUSIC.duplicate()
	var dark_music: Array = RELOAD_DARK_MUSIC.duplicate()
	var boss_music: Array = RELOAD_BOSS_MUSIC.duplicate()
	var ui_bus_sounds: Array = []
	for sound in sound_parents:
		if String(sound_parents[sound]) == RELOAD_UI_FOLDER:
			ui_bus_sounds.append(sound)
	return {"current": null, "fade": 0.0, "ambient_music": ambient_music, "dark_music": dark_music, "boss_music": boss_music, "ui_bus_sounds": ui_bus_sounds}

static func source_sound_control_play_once_state(has_music: bool, music: String, has_current: bool, current: String, fade: float, has_last_random_played: bool, last_random_played: String, should_play: bool) -> Dictionary:
	# SoundControl.playOnce(Music) (SoundControl.java:355-367):
	# `/** Plays a music track once and only once. If something is already playing, does nothing.*/`
	# `protected void playOnce(Music music){`
	# `if(current != null || music == null || !shouldPlay()) return; //do not interrupt already-playing tracks`
	# `//save last random track played to prevent duplicates`
	# `lastRandomPlayed = music;`
	# `//set fade to 1 and play it, stopping the current when it's done`
	# `fade = 1f;`
	# `current = music;`
	# `current.setVolume(1f);`
	# `current.setLooping(false);`
	# `current.play();`
	# `}`
	# -- the start-once gate, kept exactly: the three guard
	# legs short-circuit in Java order (a track is already
	# playing, the music is null, shouldPlay() is false) and
	# return with state untouched; otherwise the track is
	# saved as lastRandomPlayed (SoundControl.java:31,
	# `protected Music lastRandomPlayed;`) so the next
	# random pick can skip it, fade is set to 1, current
	# becomes the track, and the track is started with
	# setVolume(1f), setLooping(false), play() -- in
	# exactly that order, NOT reordered. shouldPlay()
	# (N2299, `return Core.settings.getInt("musicvol") >
	# 0;`) arrives as the explicit should_play param and
	# is NOT re-ported here. The state fields arrive as
	# explicit params (the N2306 precedent -- GDScript
	# typed String params cannot take null): has_current
	# is `current != null` (SoundControl.java:34,
	# `protected @Nullable Music current;`), fade is
	# `protected float fade;` (:35), has_last_random_played
	# is `lastRandomPlayed != null`, and has_music is
	# `music != null`; an unset name is passed as "" with
	# its flag false and is never read. Music arrives as
	# its name String (the N2287 precedent). The playback
	# calls -- current.setVolume() / setLooping() / play()
	# -- are NOT executed here: they are returned as
	# playback-command state, one Dictionary per call in
	# order (`track`, `action`, `value` when the call
	# takes one), so the driver applies them. The caller
	# is playMusic() (SoundControl.java:248,
	# `playOnce(music);`) and playRandom()
	# (SoundControl.java:258/:260/:262, after this slice
	# unlocks G4b) -- this slice does NOT port
	# playRandom(), only the callee it calls. NO audio
	# playback in this slice: this only computes state +
	# commands; playback belongs to updateLoops (N2304,
	# held waiting for B).
	var out_current = current if has_current else null
	var out_fade: float = fade
	var out_last = last_random_played if has_last_random_played else null
	var commands: Array = []
	# `if(current != null || music == null || !shouldPlay()) return;`
	# (SoundControl.java:356) -- do not interrupt
	# already-playing tracks: state passes through
	# unchanged, no commands.
	if has_current or not has_music or not should_play:
		return {"current": out_current, "fade": out_fade, "last_random_played": out_last, "commands": commands}
	# `lastRandomPlayed = music;` (SoundControl.java:359).
	out_last = music
	# `fade = 1f;` (SoundControl.java:362).
	out_fade = 1.0
	# `current = music;` (SoundControl.java:363).
	out_current = music
	# `current.setVolume(1f);` (SoundControl.java:364).
	commands.append({"track": music, "action": "set_volume", "value": 1.0})
	# `current.setLooping(false);` (SoundControl.java:365).
	commands.append({"track": music, "action": "set_looping", "value": false})
	# `current.play();` (SoundControl.java:366).
	commands.append({"track": music, "action": "play"})
	return {"current": out_current, "fade": out_fade, "last_random_played": out_last, "commands": commands}

static func source_sound_control_play_music_state(has_music: bool, music: String, interrupt: bool, has_current: bool, current: String, fade: float, has_last_random_played: bool, last_random_played: String, should_play: bool) -> Dictionary:
	# SoundControl.playMusic(@Nullable Music, boolean) (SoundControl.java:243-249):
	# `public void playMusic(@Nullable Music music, boolean interrupt){`
	# `if(interrupt && current != null){`
	# `current.stop();`
	# `current = null;`
	# `}`
	# `playOnce(music);`
	# `}`
	# -- interrupt stops the current track first (only when
	# one is playing -- the `current != null` leg), clears
	# current, and then playOnce(music) runs with the
	# cleared current: the interrupt stop command comes
	# FIRST in the command list, before playOnce's own
	# commands, in Java order. When interrupt is false,
	# playOnce sees the live current and its guard blocks
	# the start, exactly as Java never clears current.
	# When interrupt is true but no track is playing, no
	# stop is issued and playOnce starts the track. fade
	# is NOT touched by the interrupt branch -- only
	# playOnce writes it (to 1f on start) -- so the
	# incoming fade passes through to playOnce unchanged.
	# The params are playOnce's params plus interrupt
	# (SoundControl.java:243, `boolean interrupt`):
	# has_music / has_current / has_last_random_played
	# fold the null checks (the N2306 precedent), Music
	# arrives as its name String (the N2287 precedent),
	# should_play is the shouldPlay() gate (N2299, NOT
	# re-ported here). The callers of playMusic() are NOT
	# ported here beyond this delegation. NO audio playback
	# in this slice:
	# this only computes state + commands; playback
	# belongs to updateLoops (N2304, held waiting for B).
	var out_current = current if has_current else null
	var commands: Array = []
	# `if(interrupt && current != null){` +
	# `current.stop();` + `current = null;`
	# (SoundControl.java:244-247).
	if interrupt and has_current:
		commands.append({"track": current, "action": "stop"})
		out_current = null
	# `playOnce(music);` (SoundControl.java:248) -- the
	# delegation, with the interrupt-adjusted current.
	var once: Dictionary = source_sound_control_play_once_state(has_music, music, out_current != null, out_current if out_current != null else "", fade, has_last_random_played, last_random_played, should_play)
	var all_commands: Array = commands + (once.get("commands", []) as Array)
	once["commands"] = all_commands
	return once
