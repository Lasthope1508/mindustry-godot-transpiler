"""Register the Game SoundControl.play(Music) + silence() + keepSilent() (N2336).

SoundControl.play(Music) (SoundControl.java:303-353,
`protected void play(@Nullable Music music){` / `if(
!shouldPlay()){` / `current.setVolume(0);` / `fade =
0f;` / `current.setVolume(fade * Core.settings.getInt(
"musicvol") / 100f);` / `if(silenced){` / `if(current
== null && music != null){` / `current = music;` /
`current.setLooping(true);` / `current.setVolume(fade =
0f);` / `current.play();` / `silenced = false;` /
`}else if(current == music && music != null){` /
`fade = Mathf.clamp(fade + Time.delta /finTime);` /
`}else if(current != null){` / `fade =
Mathf.clamp(fade - Time.delta /foutTime);` / `if(fade
<= 0.01f){` / `current.stop();` / `current = null;` /
`silenced = true;` / `if(music != null){` -- the fade
state machine the caller drives every frame -- is one
pure static function on SourceSoundControlState.gd next
to the N2299 shouldPlay / isPlaying, N2306
alwaysPlayMusic, N2315 isDark, N2326 music getters and
N2331 findMusic. silence() (:374-376, `protected void
silence(){` / `play(null);`) is play(null) and
keepSilent() (:197-199, `public void keepSilent(){` /
`keepSilent = true;`) only sets the flag update()
consumes -- both ride in this one slice, update()
itself stays OUT (it also needs playRandom + updateLoops
N2304, held waiting for B). NO audio playback in this
slice (playback belongs to updateLoops, N2304, held
waiting for B); the play/stop/setVolume/setLooping
calls are returned as playback-command state, never
executed.

RED decisions (resolved at RED): (1) One slice entry
for the three methods, following the N2287 loop
precedent (three overloads, one ledger entry, one
function per overload with its own schema/contract) --
play keeps its own function, silence its own (it
delegates to play with no music), keepSilent its own.
(2) The fade machine is kept exactly, quirks
included: the silenced early return runs AFTER the
volume update, so a silenced machine still issues a
setVolume command each frame; the two new-track
branches order the calls differently (fresh start:
setLooping then setVolume then play; fade-out
restart: setVolume then setLooping then play) --
ported verbatim, NOT unified. (3) The one-arg
Mathf.clamp(value) is max(min(value, 1f), 0f)
(Mathf.java:402-404) -- clampf(value, 0.0, 1.0).
(4) shouldPlay() (N2299) arrives as the explicit
should_play bool param and musicvol as an explicit int
param -- the gate itself is NOT re-ported here.
(5) Music arrives as its name String (the N2287
precedent); `current == music` compares those names,
the port's identity for a track. (6) Null music /
current arrive as explicit bool params (the N2306
precedent -- GDScript typed String params cannot take
null): has_music is `music != null`, has_current is
`current != null`, an unset name is passed as "" and
is never read. (7) keepSilent takes the flag it
writes as its one param -- the old value arrives as
keep_silent and is overwritten unconditionally,
exactly as Java ignores it. (8) playRandom() /
playOnce() / update() stay OUT of scope; updateLoops()
is N2304, held. Three new result symbols per function
group (play 4, silence 4, keepSilent 1). Slice source:
SoundControl.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_sound_control_find_music import DEFERRED as N2331_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SOUND_CONTROL = 'core/src/mindustry/audio/SoundControl.java'
PROOF = '/root/C07SoundControlPlaySilenceProof'
PLAY_OWNER = 'SourceSoundControlState.source_sound_control_play_state'
SILENCE_OWNER = 'SourceSoundControlState.source_sound_control_silence_state'
KEEP_SILENT_OWNER = 'SourceSoundControlState.source_sound_control_keep_silent_state'
TESTS = ['test_c07_sound_control_play_silence_registration', 'test_all_c07_sound_control_play_silence_input_evidence_is_exact', 'test_sound_control_play_silence_state', 'test_reference_graph_and_actual_c07_sound_control_play_silence']
# The 1 slice source the N2336 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    SOUND_CONTROL,
]
EXACT_EXPRS = [
    'protected void play(@Nullable Music music){',
    'if(!shouldPlay()){',
    'current.setVolume(0);',
    'fade = 0f;',
    'current.setVolume(fade * Core.settings.getInt("musicvol") / 100f);',
    'if(silenced){',
    'if(current == null && music != null){',
    'current = music;',
    'current.setLooping(true);',
    'current.setVolume(fade = 0f);',
    'current.play();',
    'silenced = false;',
    '}else if(current == music && music != null){',
    'fade = Mathf.clamp(fade + Time.delta /finTime);',
    '}else if(current != null){',
    'fade = Mathf.clamp(fade - Time.delta /foutTime);',
    'if(fade <= 0.01f){',
    'current.stop();',
    'current = null;',
    'silenced = true;',
    'if(music != null){',
    'protected void silence(){',
    'play(null);',
    'public void keepSilent(){',
    'keepSilent = true;',
    'protected @Nullable Music current;',
    'protected float fade;',
    'protected boolean silenced, keepSilent;',
    'public float finTime = 120f, foutTime = 120f, musicInterval = 3f * Time.toMinutes, musicChance = 0.8f, musicWaveChance = 0.46f;',
    'if(current != null){',
]

# DEFERRED is carried from the N2331 register script via import --
# never retyped. All N2331 entries are carried verbatim (the
# N2326 chain, the B/C notes, and N2331's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2336's Windows proof debt.
DEFERRED = list(N2331_DEFERRED) + [
    'SoundControl.play/silence/keepSilent Windows Godot proof -- debt in GOAL.md section 5, same as N2287/N2299/N2306/N2315/N2326/N2331: the N2336 proof runs headless on Linux here and waits for a Windows Godot run.',
]

FIN_FOUT = 'public float finTime = 120f, foutTime = 120f, musicInterval = 3f * Time.toMinutes, musicChance = 0.8f, musicWaveChance = 0.46f;'


def definitions():
    def a(typ, expr, rule, source=SOUND_CONTROL, **extra):
        return backed(typ, source, expr, rule, **extra)

    play_inputs = {
        'has_music': a('bool', 'if(current == null && music != null){', 'Whether a track is scheduled (SoundControl.java:322, `if(current == null && music != null){`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent; GDScript typed String params cannot take null). A null music reads as no scheduled track.'),
        'music': a('String', 'protected void play(@Nullable Music music){', 'The scheduled track (SoundControl.java:303, `play(@Nullable Music music)`): arrives as an explicit String param, its name (the N2287 precedent); an unset track is passed as "" with has_music false and is never read.'),
        'has_current': a('bool', 'if(current != null){', 'Whether a track is currently playing (SoundControl.java:310, `if(current != null){`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent).'),
        'current': a('String', 'protected @Nullable Music current;', 'The currently playing track (SoundControl.java:34, `protected @Nullable Music current;`): arrives as an explicit String param, its name; an unset current is passed as "" with has_current false and is never read.'),
        'fade': a('float', 'protected float fade;', 'The fade level (SoundControl.java:35, `protected float fade;`): arrives as an explicit float param and is carried out again -- the fade-in / fade-out step writes it.'),
        'silenced': a('bool', 'protected boolean silenced, keepSilent;', 'Whether the machine has faded out completely (SoundControl.java:36, `protected boolean silenced, keepSilent;`): arrives as an explicit bool param and is carried out again.'),
        'should_play': a('bool', 'if(!shouldPlay()){', 'The shouldPlay() gate (SoundControl.java:304, `if(!shouldPlay()){`): arrives as an explicit bool param -- the gate itself is N2299 (`return Core.settings.getInt("musicvol") > 0;`) and is NOT re-ported here. False mutes the current track and zeroes fade.'),
        'music_vol': a('int', 'current.setVolume(fade * Core.settings.getInt("musicvol") / 100f);', 'Core.settings "musicvol" (SoundControl.java:314, `Core.settings.getInt("musicvol")`): arrives as an explicit int param; the current track volume each frame is fade * music_vol / 100.'),
        'time_delta': a('float', 'fade = Mathf.clamp(fade + Time.delta /finTime);', 'Time.delta (SoundControl.java:331, `Time.delta /finTime`): arrives as an explicit float param; the fade step per frame.'),
        'fin_time': a('float', FIN_FOUT, 'The fade-in time (SoundControl.java:20, `public float finTime = 120f, ...`): arrives as an explicit float param; fade rises by time_delta / fin_time.'),
        'fout_time': a('float', FIN_FOUT, 'The fade-out time (SoundControl.java:20, `... foutTime = 120f, ...`): arrives as an explicit float param; fade falls by time_delta / fout_time.'),
    }
    play_outputs = {
        'current': a('String', 'current = music;', 'The track playing after this frame (SoundControl.java:323, `current = music;`): the scheduled track when one starts (or restarts after a fade-out), the old track while it fades, or null when it stopped with no track scheduled.'),
        'fade': a('float', 'fade = Mathf.clamp(fade + Time.delta /finTime);', 'The fade level after this frame (SoundControl.java:331, `fade = Mathf.clamp(fade + Time.delta /finTime);` / :335 fade-out): clamped to [0, 1] by the one-arg Mathf.clamp (Mathf.java:402-404); zeroed by the muted gate and by a fresh start.'),
        'silenced': a('bool', 'silenced = false;', 'Whether the machine is silenced after this frame (SoundControl.java:328, `silenced = false;` / :339 `silenced = true;`): false when a track starts, true when the fade-out stops the track with no restart.'),
        'commands': a('Array', 'current.play();', 'The playback commands this frame issues, in Java order (SoundControl.java:305 `current.setVolume(0);` / :314 volume update / :324-327 setLooping, setVolume, play / :337 stop / :342-345 setVolume, setLooping, play): one Dictionary per call (`track`, `action`, `value` when the call takes one). The driver applies them -- this slice NEVER plays audio itself; playback belongs to updateLoops (N2304, held waiting for B).'),
    }
    silence_inputs = {
        'has_current': a('bool', 'if(current != null){', 'Whether a track is currently playing (SoundControl.java:310, `if(current != null){`): same param as play -- silence() is play(null), so the current track is the one being faded out.'),
        'current': a('String', 'protected @Nullable Music current;', 'The currently playing track (SoundControl.java:34, `protected @Nullable Music current;`): same param as play.'),
        'fade': a('float', 'protected float fade;', 'The fade level (SoundControl.java:35, `protected float fade;`): same param as play.'),
        'silenced': a('bool', 'protected boolean silenced, keepSilent;', 'Whether the machine has faded out completely (SoundControl.java:36, `protected boolean silenced, keepSilent;`): same param as play.'),
        'should_play': a('bool', 'if(!shouldPlay()){', 'The shouldPlay() gate (SoundControl.java:304, `if(!shouldPlay()){`): same param as play -- silence() delegates to play, so the muted gate still applies.'),
        'music_vol': a('int', 'current.setVolume(fade * Core.settings.getInt("musicvol") / 100f);', 'Core.settings "musicvol" (SoundControl.java:314): same param as play.'),
        'time_delta': a('float', 'fade = Mathf.clamp(fade - Time.delta /foutTime);', 'Time.delta (SoundControl.java:335, `Time.delta /foutTime`): same param as play; silence() only ever fades out, so the fade-out step is the one that runs.'),
        'fin_time': a('float', FIN_FOUT, 'The fade-in time (SoundControl.java:20): same param as play -- carried for the delegation, silence() never fades in.'),
        'fout_time': a('float', FIN_FOUT, 'The fade-out time (SoundControl.java:20): same param as play; silence() fades the current track out by time_delta / fout_time.'),
    }
    silence_outputs = {
        'current': a('String', 'current = null;', 'The track playing after this frame (SoundControl.java:338, `current = null;`): null once the fade-out stops the track, else the fading track.'),
        'fade': a('float', 'fade = Mathf.clamp(fade - Time.delta /foutTime);', 'The fade level after this frame (SoundControl.java:335, `fade = Mathf.clamp(fade - Time.delta /foutTime);`): falling toward zero; zeroed by the muted gate.'),
        'silenced': a('bool', 'silenced = true;', 'Whether the machine is silenced after this frame (SoundControl.java:339, `silenced = true;`): true once the fade-out stops the track.'),
        'commands': a('Array', 'current.stop();', 'The playback commands this frame issues, in Java order (SoundControl.java:305 `current.setVolume(0);` / :314 volume update / :337 `current.stop();`): same shape as play -- the driver applies them, this slice NEVER plays audio itself.'),
    }
    keep_silent_inputs = {
        'keep_silent': a('bool', 'protected boolean silenced, keepSilent;', 'The keepSilent flag before this call (SoundControl.java:36, `protected boolean silenced, keepSilent;`): arrives as an explicit bool param -- the field being written, carried like the other state fields -- and is overwritten unconditionally, exactly as Java ignores the old value.'),
    }
    keep_silent_outputs = {
        'keep_silent': a('bool', 'keepSilent = true;', 'The keepSilent flag after this call (SoundControl.java:198, `keepSilent = true;`): always true -- the flag update() consumes (SoundControl.java:160-162, `if(keepSilent){ keepSilent = false; stop(); }`).'),
    }
    return (play_inputs, play_outputs, silence_inputs, silence_outputs, keep_silent_inputs, keep_silent_outputs)


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
    (play_inputs, play_outputs, silence_inputs, silence_outputs, keep_silent_inputs, keep_silent_outputs) = definitions()

    entries = [
        ('N2336', PLAY_OWNER, 'source_sound_control_play_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.play(Music)', play_inputs, play_outputs, True, 'Dictionary'),
        ('N2336', SILENCE_OWNER, 'source_sound_control_silence_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.silence()', silence_inputs, silence_outputs, True, 'Dictionary'),
        ('N2336', KEEP_SILENT_OWNER, 'source_sound_control_keep_silent_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.keepSilent()', keep_silent_inputs, keep_silent_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SoundControl play/silence/keepSilent state from SoundControl.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SoundControl play/silence/keepSilent state from SoundControl.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2336'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2336', dict(status='done', java_source=SOUND_CONTROL, java_class='mindustry.audio.SoundControl', java_method='SoundControl.play(Music); SoundControl.silence(); SoundControl.keepSilent()', godot_owner=PLAY_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2336'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
