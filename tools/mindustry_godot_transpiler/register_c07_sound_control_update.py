"""Register the Game SoundControl.update() driver tick (N2411).

SoundControl.update() (SoundControl.java:128-195,
`public void update(){` -- the per-frame dispatcher:
paused/playing derivation, the finished-track clear,
the 30-tick fade-filter poll, the bus play/stop on
the playing transition, setPaused, then exactly one
leg (keepSilent / menu / editor rules / ingame) and
updateLoops() last) is one pure static function on
SourceSoundControlState.gd next to the N2287 loop,
N2299 shouldPlay/isPlaying, N2306 alwaysPlayMusic,
N2315 isDark, N2326 music getters, N2331 findMusic,
N2336 play/silence/keepSilent, N2339 reload, N2345
playMusic/playOnce, N2347 playRandom, N2349
setupFilters and N2352 stop slices. NO audio
playback in this slice (playback belongs to
updateLoops, N2304, held waiting for B); the bus
and playback calls are returned as command state,
never executed.

RED decisions (resolved at RED): (1) One slice
entry for the one method, following the N2397
driver-tick precedent (one ledger entry per method,
one function per method) -- update() keeps its own
function and delegates to the pure static funcs in
the same file, it does NOT re-port them. (2) The
already-owned lines are NOT re-registered:
`current = null;` + `fade = 0f;` (:134-135,
N2336/N2339/N2345/N2352), `silenced = false;`
(:166/:175, N2336) and the alwaysPlayMusic leg
(:181-183/:189, N2306) -- update() only drives
them through the delegates and explicit params.
(3) setupFilters (N2349), stop (N2352), play /
silence (N2336) are called directly -- their
inputs (filter, should_play, music_vol,
time_delta, fin_time, fout_time) arrive as
explicit params. (4) playRandom (N2347) arrives
as the play_random Callable -- the caller owns
the boss / dark / ambient lists and the RNG draw,
so update() hands it the current state at call
time and merges the N2347 result back in. (5)
updateLoops (N2304, held waiting for B) arrives
as the update_loops Callable -- its body is NOT
ported here, only the call site (:194), recorded
as update_loops_called. (6) The RNG of this
slice is Mathf.chance(musicChance)
(SoundControl.java:187): its OUTCOME arrives as
the explicit chance_roll param (the N2315
chance-roll precedent), so the function never
rolls RNG itself; timer.get(1, 30f) likewise
arrives as the timer_tick outcome. (7)
Time.timeSinceMillis(lastPlayed) is millis() -
lastPlayed (arc Time.java:158-160); now_millis
arrives explicitly and the interval threshold is
`1000 * musicInterval / 60f` (musicInterval
defaults to `3f * Time.toMinutes`, arc
Time.java:12, toMinutes = 60f * 60f). (8) Music
arrives as its name String (the N2287
precedent); Musics.editor / Musics.menu arrive
as their asset-stem names "editor" / "menu".
(9) The sound-bus numeric id
(`Core.audio.soundBus.id`, SoundControl.java:160)
is driver-owned, so the setPaused command names
the bus ("sound") instead of carrying the id.
(10) Filters.paramWet is the int constant 0
(arc Filters.java:6). Eleven new result symbols
(paused, playing, was_playing, current, fade,
silenced, keep_silent, last_played,
last_random_played, commands, update_loops_called).
Slice source: SoundControl.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_sound_control_stop import DEFERRED as N2352_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SOUND_CONTROL = 'core/src/mindustry/audio/SoundControl.java'
PROOF = '/root/C07SoundControlUpdateProof'
UPDATE_OWNER = 'SourceSoundControlState.source_sound_control_update_state'
TESTS = ['test_c07_sound_control_update_registration', 'test_all_c07_sound_control_update_input_evidence_is_exact', 'test_sound_control_update_state', 'test_reference_graph_and_actual_c07_sound_control_update']
# The 1 slice source the N2411 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    SOUND_CONTROL,
]
# The 30 registered lines of update() (SoundControl.java:128-195)
# -- 28 unique strings; the sound-bus play line repeats (:148 +
# :156) and the editor music line repeats (:170 + :176).
# Duplicate exact_exprs have precedent (N1154/N1611/N1780).
EXACT_EXPRS = [
    'boolean paused = state.isGame() && Core.scene.hasDialog();',
    'boolean playing = state.isGame();',
    'if(current != null && !current.isPlaying()){',
    'if(timer.get(1, 30f)){',
    'Core.audio.soundBus.fadeFilterParam(0, Filters.paramWet, paused ? 1f : 0f, 0.4f);',
    'if(playing != wasPlaying){',
    'wasPlaying = playing;',
    'if(playing){',
    'Core.audio.soundBus.play();',
    'setupFilters();',
    'Core.audio.soundBus.stop();',
    'Core.audio.musicBus.play();',
    'Core.audio.soundBus.play();',
    'Core.audio.setPaused(Core.audio.soundBus.id, state.isPaused());',
    'if(keepSilent){',
    'keepSilent = false;',
    'stop();',
    '}else if(state.isMenu()){',
    'if(ui.planet.isShown()){',
    'play(ui.planet.state.planet.launchMusic);',
    '}else if(ui.editor.isShown()){',
    'play(Musics.editor);',
    'play(Musics.menu);',
    '}else if(state.rules.editor){',
    'play(Musics.editor);',
    'silence();',
    '}else if(Time.timeSinceMillis(lastPlayed) > 1000 * musicInterval / 60f){',
    'if(Mathf.chance(musicChance)){',
    'lastPlayed = Time.millis();',
    'updateLoops();',
]

# DEFERRED is carried from the N2352 register script via import --
# never retyped. All N2352 entries are carried verbatim (the
# N2347 chain, the B/C notes, and N2352's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2411's Windows proof debt.
DEFERRED = list(N2352_DEFERRED) + [
    'SoundControl.update Windows Godot proof -- debt in GOAL.md section 5, same as N2287/N2299/N2306/N2315/N2326/N2331/N2336/N2339/N2345/N2347/N2349/N2352: the N2411 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SOUND_CONTROL, **extra):
        return backed(typ, source, expr, rule, **extra)

    update_inputs = {
        'is_game': a('bool', 'boolean playing = state.isGame();', 'Whether the game state is in-game (SoundControl.java:130, `boolean playing = state.isGame();`): drives both the playing flag and the paused derivation; arrives as an explicit bool param -- the state lookup stays with the caller.'),
        'has_dialog': a('bool', 'boolean paused = state.isGame() && Core.scene.hasDialog();', 'Whether a dialog is shown (SoundControl.java:129, `boolean paused = state.isGame() && Core.scene.hasDialog();`): paused is is_game AND has_dialog; arrives as an explicit bool param -- the Core.scene lookup stays with the caller.'),
        'has_current': a('bool', 'if(current != null && !current.isPlaying()){', 'Whether a track is currently playing (SoundControl.java:133, `if(current != null && !current.isPlaying()){`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent).'),
        'current': a('String', 'protected @Nullable Music current;', 'The currently playing track (SoundControl.java:34, `protected @Nullable Music current;`): arrives as an explicit String param, its name (the N2287 precedent); an unset current is passed as "" with has_current false and is never read.'),
        'current_is_playing': a('bool', 'if(current != null && !current.isPlaying()){', 'Whether the current track is still playing (SoundControl.java:133, `!current.isPlaying()`): a finished track is cleared with fade zeroed; arrives as an explicit bool param -- the Music.isPlaying() call stays with the caller.'),
        'timer_tick': a('bool', 'if(timer.get(1, 30f)){', 'Whether the 30-tick fade-filter poll fires (SoundControl.java:139, `if(timer.get(1, 30f)){`): arrives as an explicit bool param -- the Timer lives with the caller; only its outcome is read here.'),
        'was_playing': a('bool', 'protected boolean wasPlaying;', 'Whether music was playing on the previous frame (SoundControl.java:38, `protected boolean wasPlaying;`): arrives as an explicit bool param and is carried out again -- the bus play/stop leg fires only on a transition.'),
        'filter': a('Variant', 'protected AudioFilter filter = new BiquadFilter(){{', 'The SoundControl filter (SoundControl.java:39, `protected AudioFilter filter = new BiquadFilter(){{ set(0, 500, 1); }};`): arrives as an explicit opaque Variant param -- the driver owns the live filter object (the N2287 precedent); passed through to the setupFilters delegate (N2349) when the bus starts.'),
        'is_paused': a('bool', 'Core.audio.setPaused(Core.audio.soundBus.id, state.isPaused());', 'Whether the game is paused (SoundControl.java:160, `state.isPaused()`): carried into the setPaused command; arrives as an explicit bool param -- the state lookup stays with the caller.'),
        'keep_silent': a('bool', 'protected boolean silenced, keepSilent;', 'Whether the keepSilent flag is set (SoundControl.java:36, `protected boolean silenced, keepSilent;`): arrives as an explicit bool param and is carried out again -- the keepSilent leg clears it and calls stop().'),
        'silenced': a('bool', 'protected boolean silenced, keepSilent;', 'Whether playback is silenced (SoundControl.java:36, `protected boolean silenced, keepSilent;`): arrives as an explicit bool param and is carried out again -- written false by the menu / editor legs, true by the stop delegate.'),
        'is_menu': a('bool', '}else if(state.isMenu()){', 'Whether the game state is the menu (SoundControl.java:165, `}else if(state.isMenu()){`): selects the menu leg (planet / editor / menu music); arrives as an explicit bool param -- the state lookup stays with the caller.'),
        'planet_shown': a('bool', 'if(ui.planet.isShown()){', 'Whether the planet screen is shown (SoundControl.java:167, `if(ui.planet.isShown()){`): selects the planet launch music in the menu leg; arrives as an explicit bool param -- the UI lookup stays with the caller.'),
        'has_planet_launch_music': a('bool', 'play(ui.planet.state.planet.launchMusic);', 'Whether the current planet has launch music (SoundControl.java:168, `play(ui.planet.state.planet.launchMusic);`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent).'),
        'planet_launch_music': a('String', 'play(ui.planet.state.planet.launchMusic);', 'The planet launch track (SoundControl.java:168, `play(ui.planet.state.planet.launchMusic);`): arrives as an explicit String param, its name (the N2287 precedent); only read when the planet screen is shown.'),
        'editor_shown': a('bool', '}else if(ui.editor.isShown()){', 'Whether the editor screen is shown (SoundControl.java:169, `}else if(ui.editor.isShown()){`): selects the editor music in the menu leg; arrives as an explicit bool param -- the UI lookup stays with the caller.'),
        'rules_editor': a('bool', '}else if(state.rules.editor){', 'Whether the current rules are the editor rules (SoundControl.java:174, `}else if(state.rules.editor){`): selects the editor leg; arrives as an explicit bool param -- the state lookup stays with the caller.'),
        'always_play_music': a('bool', 'if(alwaysPlayMusic()){', 'The alwaysPlayMusic() gate (SoundControl.java:181, `if(alwaysPlayMusic()){`): arrives as an explicit bool param -- the gate itself is N2306 and is NOT re-ported here; true reads the playRandom leg in the ingame branch.'),
        'last_played': a('int', 'protected long lastPlayed;', 'When the last ingame track was started, in millis (SoundControl.java:33, `protected long lastPlayed;`): arrives as an explicit int param and is carried out again -- the interval leg writes it to now_millis when it fires.'),
        'now_millis': a('int', 'lastPlayed = Time.millis();', 'The current time in millis (SoundControl.java:188, `lastPlayed = Time.millis();`): arrives as an explicit int param -- Time.millis() stays with the caller; used for the interval check and the lastPlayed write.'),
        'music_interval': a('float', 'public float finTime = 120f, foutTime = 120f, musicInterval = 3f * Time.toMinutes, musicChance = 0.8f, musicWaveChance = 0.46f;', 'The music interval field (SoundControl.java:20, `musicInterval = 3f * Time.toMinutes`, Time.toMinutes = 60f * 60f so 10800f): arrives as an explicit float param; the interval threshold is `1000 * musicInterval / 60f` millis.'),
        'chance_roll': a('bool', 'if(Mathf.chance(musicChance)){', 'Whether the per-interval chance roll hit (SoundControl.java:187, `if(Mathf.chance(musicChance)){`): arrives as an explicit bool param -- the RNG OUTCOME (the N2315 chance-roll precedent), so this function never rolls RNG itself.'),
        'fade': a('float', 'protected float fade;', 'The fade level (SoundControl.java:35, `protected float fade;`): arrives as an explicit float param and is carried out again -- zeroed by the finished-track clear, stepped by the play / silence delegates.'),
        'should_play': a('bool', 'if(!shouldPlay()){', 'The shouldPlay() gate (SoundControl.java:304, `if(!shouldPlay()){` in play()): arrives as an explicit bool param -- the gate itself is N2299 (`return Core.settings.getInt("musicvol") > 0;`) and is NOT re-ported here; passed through to the play / silence delegates.'),
        'music_vol': a('int', 'current.setVolume(fade * Core.settings.getInt("musicvol") / 100f);', 'The music volume setting (SoundControl.java:313, `Core.settings.getInt("musicvol")` in play()): arrives as an explicit int param; passed through to the play / silence delegates.'),
        'time_delta': a('float', 'fade = Mathf.clamp(fade + Time.delta /finTime);', 'The frame delta (SoundControl.java:330, `Time.delta` in play()): arrives as an explicit float param; passed through to the play / silence delegates for the fade steps.'),
        'fin_time': a('float', 'public float finTime = 120f, foutTime = 120f, musicInterval = 3f * Time.toMinutes, musicChance = 0.8f, musicWaveChance = 0.46f;', 'The fade-in time field (SoundControl.java:20, `finTime = 120f`): arrives as an explicit float param; passed through to the play / silence delegates.'),
        'fout_time': a('float', 'public float finTime = 120f, foutTime = 120f, musicInterval = 3f * Time.toMinutes, musicChance = 0.8f, musicWaveChance = 0.46f;', 'The fade-out time field (SoundControl.java:20, `foutTime = 120f`): arrives as an explicit float param; passed through to the play / silence delegates.'),
        'has_last_random_played': a('bool', 'protected Music lastRandomPlayed;', 'Whether a last random track is saved (SoundControl.java:31, `protected Music lastRandomPlayed;`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent); passed to the playRandom delegate.'),
        'last_random_played': a('String', 'protected Music lastRandomPlayed;', 'The last random track played (SoundControl.java:31, `protected Music lastRandomPlayed;`): arrives as an explicit String param, its name (the N2287 precedent); passed to the playRandom delegate.'),
        'play_random': a('Callable', 'playRandom();', 'The playRandom() delegate (SoundControl.java:183/:189, `playRandom();`): arrives as a Callable (has_current, current, fade, has_last_random_played, last_random_played) returning the N2347 result Dictionary -- the caller owns the boss / dark / ambient lists and the RNG draw, so the random pick stays with the caller.'),
        'update_loops': a('Callable', 'updateLoops();', 'The updateLoops() call (SoundControl.java:194, `updateLoops();`): arrives as a zero-arg Callable -- the mixer body is N2304 (held waiting for B) and is NOT ported here, only the call site; the call is recorded as update_loops_called.'),
    }
    update_outputs = {
        'paused': a('bool', 'boolean paused = state.isGame() && Core.scene.hasDialog();', 'Whether playback is paused this frame (SoundControl.java:129, `boolean paused = state.isGame() && Core.scene.hasDialog();`): is_game AND has_dialog; drives the fade-filter value (1 when paused, 0 otherwise).'),
        'playing': a('bool', 'boolean playing = state.isGame();', 'Whether music is playing this frame (SoundControl.java:130, `boolean playing = state.isGame();`): the bus play/stop leg fires only on a transition against was_playing.'),
        'was_playing': a('bool', 'wasPlaying = playing;', 'Whether music was playing after this frame (SoundControl.java:145, `wasPlaying = playing;`): the field, updated on every playing transition.'),
        'current': a('String', 'current = null;', 'The track playing after this call (SoundControl.java:134, `current = null;` in the finished-track clear): null when the track finished or was stopped, the new track when a leg started one.'),
        'fade': a('float', 'fade = 0f;', 'The fade level after this call (SoundControl.java:135, `fade = 0f;` in the finished-track clear): 0 when the track finished, stepped by the play / silence / playRandom delegates otherwise.'),
        'silenced': a('bool', 'silenced = false;', 'Whether playback is silenced after this call (SoundControl.java:166/:175, `silenced = false;` in the menu / editor legs): false when a leg selects music, true when the stop delegate ran.'),
        'keep_silent': a('bool', 'keepSilent = false;', 'Whether the keepSilent flag is still set (SoundControl.java:163, `keepSilent = false;`): always false after this call -- the leg clears it and calls stop().'),
        'last_played': a('int', 'lastPlayed = Time.millis();', 'When the last ingame track was started, in millis (SoundControl.java:188, `lastPlayed = Time.millis();`): now_millis when the interval leg fired playRandom, unchanged otherwise.'),
        'last_random_played': a('String', 'lastRandomPlayed = music;', 'The last random track after this call (SoundControl.java:359, `lastRandomPlayed = music;` in playOnce, reached through the playRandom delegate): the picked track when playRandom fired, unchanged otherwise.'),
        'commands': a('Array', 'Core.audio.soundBus.play();', 'The playback commands this call issues, in Java order (SoundControl.java:140 fadeFilterParam / :148 soundBus.play / :149 setupFilters / :152 soundBus.stop / :154 musicBus.play / :156 soundBus.play / :160 setPaused, plus the delegate commands from stop / play / silence / playRandom): one Dictionary per call (`action`, plus `slot`/`param`/`value`/`duration` for the filter, `bus`/`paused` for setPaused, `track` for track commands). The driver applies them -- this slice NEVER plays audio itself; playback belongs to updateLoops (N2304, held waiting for B).'),
        'update_loops_called': a('bool', 'updateLoops();', 'Whether updateLoops() was called (SoundControl.java:194, `updateLoops();`): always true -- the call is unconditional, last in the method.'),
    }
    return (update_inputs, update_outputs)


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs_outputs = [definitions()]
    total = len(EXACT_EXPRS)
    for pair in inputs_outputs:
        for keys in pair:
            total += len(keys)
            for field, meta in keys.items():
                source = meta['java_source']
                text = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
                if meta['java_expr'] not in text:
                    missing.append('%s: %s' % (field, meta['java_expr']))
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    (update_inputs, update_outputs) = definitions()

    entries = [
        ('N2411', UPDATE_OWNER, 'source_sound_control_update_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.update()', update_inputs, update_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SoundControl update state from SoundControl.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SoundControl update state from SoundControl.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2411'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2411', dict(status='done', java_source=SOUND_CONTROL, java_class='mindustry.audio.SoundControl', java_method='SoundControl.update()', godot_owner=UPDATE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2411'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {definition[1] for definition in entries}
    for name, module in modules.items():
        if module.get('canonical_module') == 'api_contracts':
            selected = source_ssot.build_extension_shard(GODOT, name)[module['root_key']]
            if new_owners.intersection(selected):
                optional = module.setdefault('optional_mirror_fields', [])
                if 'return_type' not in optional:
                    optional.append('return_type')
    source_ssot.write_registered_json(GODOT, 'module_manifest', manifest)
    for canonical in ['slice_ledger', 'api_contracts', 'state_schema', 'registry', 'audit_report', 'module_manifest']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    if '--verify' in sys.argv:
        sys.exit(verify())
    main()
