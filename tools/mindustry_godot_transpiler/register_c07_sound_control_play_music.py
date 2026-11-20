"""Register the Game SoundControl.playMusic(Music, boolean) + playOnce(Music) (N2345).

SoundControl.playMusic(Music, boolean) (SoundControl.java:243-249,
`public void playMusic(@Nullable Music music, boolean interrupt){` /
`if(interrupt && current != null){` / `current.stop();` /
`current = null;` / `playOnce(music);` -- interrupt stops the
current track first, clears current, then playOnce(music) runs
with the cleared current) and SoundControl.playOnce(Music)
(SoundControl.java:355-367, `protected void playOnce(Music
music){` / `if(current != null || music == null ||
!shouldPlay()) return; //do not interrupt already-playing
tracks` / `lastRandomPlayed = music;` / `fade = 1f;` /
`current = music;` / `current.setVolume(1f);` /
`current.setLooping(false);` / `current.play();` -- the
start-once gate: the three guard legs return with state
untouched, otherwise the track is saved as lastRandomPlayed,
fade is set to 1, current becomes the track, and it is started
with setVolume(1f), setLooping(false), play() in exactly that
order) are two pure static functions on
SourceSoundControlState.gd next to the N2299 shouldPlay /
isPlaying, N2306 alwaysPlayMusic, N2315 isDark, N2326 music
getters, N2331 findMusic, N2336 play/silence/keepSilent and
N2339 reload. NO audio playback in this slice (playback
belongs to updateLoops, N2304, held waiting for B); the
stop / setVolume / setLooping / play calls are returned as
playback-command state, never executed.

RED decisions (resolved at RED): (1) One slice entry for
the two methods, following the N2336 precedent (one ledger
entry per method group, one function per method) -- playMusic
keeps its own function and delegates to playOnce, playOnce
keeps its own. (2) shouldPlay() (N2299) arrives as the
explicit should_play bool param and is NOT re-ported here;
the guard legs are ported, the gate itself is not. (3)
current / fade / lastRandomPlayed arrive as explicit params
and are carried out -- the guard returns them untouched,
the start writes them; has_current / has_music /
has_last_random_played fold the null checks (the N2306
precedent -- GDScript typed String params cannot take
null). (4) Music arrives as its name String (the N2287
precedent); `current == music` identity is the name, the
port's identity for a track. (5) The interrupt stop command
comes FIRST in playMusic's command list, before playOnce's
own commands, in Java order. (6) play() (:303-353, batch 3
N2336) does NOT call playOnce -- two separate state
machines; play() is NOT re-ported here. (7) playRandom()
(G4b) is NOT ported here -- this slice unlocks it for the
next batch (it calls playOnce 3 times). update() stays OUT
(it also needs playRandom + updateLoops N2304, held). Four
new result symbols per function (playMusic 4, playOnce 4).
Slice source: SoundControl.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_sound_control_reload import DEFERRED as N2339_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SOUND_CONTROL = 'core/src/mindustry/audio/SoundControl.java'
PROOF = '/root/C07SoundControlPlayMusicProof'
PLAY_MUSIC_OWNER = 'SourceSoundControlState.source_sound_control_play_music_state'
PLAY_ONCE_OWNER = 'SourceSoundControlState.source_sound_control_play_once_state'
TESTS = ['test_c07_sound_control_play_music_registration', 'test_all_c07_sound_control_play_music_input_evidence_is_exact', 'test_sound_control_play_music_state', 'test_reference_graph_and_actual_c07_sound_control_play_music']
# The 1 slice source the N2345 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    SOUND_CONTROL,
]
EXACT_EXPRS = [
    'public void playMusic(@Nullable Music music, boolean interrupt){',
    'if(interrupt && current != null){',
    'current.stop();',
    'current = null;',
    'playOnce(music);',
    'protected void playOnce(Music music){',
    'if(current != null || music == null || !shouldPlay()) return; //do not interrupt already-playing tracks',
    'lastRandomPlayed = music;',
    'fade = 1f;',
    'current = music;',
    'current.setVolume(1f);',
    'current.setLooping(false);',
    'current.play();',
    'protected @Nullable Music current;',
    'protected float fade;',
    'protected Music lastRandomPlayed;',
]

# DEFERRED is carried from the N2339 register script via import --
# never retyped. All N2339 entries are carried verbatim (the
# N2326 chain, the B/C notes, and N2339's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2345's Windows proof debt.
DEFERRED = list(N2339_DEFERRED) + [
    'SoundControl.playMusic/playOnce Windows Godot proof -- debt in GOAL.md section 5, same as N2287/N2299/N2306/N2315/N2326/N2331/N2336/N2339: the N2345 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SOUND_CONTROL, **extra):
        return backed(typ, source, expr, rule, **extra)

    play_music_inputs = {
        'has_music': a('bool', 'public void playMusic(@Nullable Music music, boolean interrupt){', 'Whether a track is scheduled (SoundControl.java:243, `playMusic(@Nullable Music music, boolean interrupt)`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent; GDScript typed String params cannot take null). A null music reads as no scheduled track and playOnce blocks.'),
        'music': a('String', 'public void playMusic(@Nullable Music music, boolean interrupt){', 'The scheduled track (SoundControl.java:243, `playMusic(@Nullable Music music, boolean interrupt)`): arrives as an explicit String param, its name (the N2287 precedent); an unset track is passed as "" with has_music false and is never read.'),
        'interrupt': a('bool', 'if(interrupt && current != null){', 'Whether to stop the current track first (SoundControl.java:244, `if(interrupt && current != null){`): arrives as an explicit bool param; true with a current track issues the stop command and clears current before playOnce runs.'),
        'has_current': a('bool', 'if(interrupt && current != null){', 'Whether a track is currently playing (SoundControl.java:244, `if(interrupt && current != null){`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent).'),
        'current': a('String', 'protected @Nullable Music current;', 'The currently playing track (SoundControl.java:34, `protected @Nullable Music current;`): arrives as an explicit String param, its name; an unset current is passed as "" with has_current false and is never read.'),
        'fade': a('float', 'protected float fade;', 'The fade level (SoundControl.java:35, `protected float fade;`): arrives as an explicit float param and is carried out again -- the interrupt branch does NOT touch it; only playOnce writes it (to 1f on start).'),
        'has_last_random_played': a('bool', 'protected Music lastRandomPlayed;', 'Whether a last random track is saved (SoundControl.java:31, `protected Music lastRandomPlayed;`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent).'),
        'last_random_played': a('String', 'protected Music lastRandomPlayed;', 'The last random track played (SoundControl.java:31, `protected Music lastRandomPlayed;`): arrives as an explicit String param, its name; an unset track is passed as "" with has_last_random_played false and is never read.'),
        'should_play': a('bool', 'if(current != null || music == null || !shouldPlay()) return; //do not interrupt already-playing tracks', 'The shouldPlay() gate (SoundControl.java:356, `!shouldPlay()`): arrives as an explicit bool param -- the gate itself is N2299 (`return Core.settings.getInt("musicvol") > 0;`) and is NOT re-ported here. False blocks playOnce from starting anything.'),
    }
    play_music_outputs = {
        'current': a('String', 'current = null;', 'The track playing after this call (SoundControl.java:246, `current = null;` / playOnce :363 `current = music;`): null when the interrupt stopped the track with no start, the scheduled track when playOnce starts it, or the old track when playOnce is blocked.'),
        'fade': a('float', 'fade = 1f;', 'The fade level after this call (SoundControl.java:362, `fade = 1f;`): 1 when playOnce starts a track, unchanged otherwise -- the interrupt branch never writes it.'),
        'last_random_played': a('String', 'lastRandomPlayed = music;', 'The last random track after this call (SoundControl.java:359, `lastRandomPlayed = music;`): the scheduled track when playOnce starts it, unchanged when playOnce is blocked.'),
        'commands': a('Array', 'current.play();', 'The playback commands this call issues, in Java order (SoundControl.java:245 `current.stop();` when interrupt stops a track, then playOnce :364-366 setVolume, setLooping, play): one Dictionary per call (`track`, `action`, `value` when the call takes one). The driver applies them -- this slice NEVER plays audio itself; playback belongs to updateLoops (N2304, held waiting for B).'),
    }
    play_once_inputs = {
        'has_music': a('bool', 'protected void playOnce(Music music){', 'Whether a track is scheduled (SoundControl.java:355, `playOnce(Music music)`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent). A null music reads as no scheduled track and the guard blocks.'),
        'music': a('String', 'protected void playOnce(Music music){', 'The scheduled track (SoundControl.java:355, `playOnce(Music music)`): arrives as an explicit String param, its name (the N2287 precedent); an unset track is passed as "" with has_music false and is never read.'),
        'has_current': a('bool', 'if(current != null || music == null || !shouldPlay()) return; //do not interrupt already-playing tracks', 'Whether a track is currently playing (SoundControl.java:356, `if(current != null || music == null || !shouldPlay()) return;`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent). A playing track blocks the start.'),
        'current': a('String', 'protected @Nullable Music current;', 'The currently playing track (SoundControl.java:34, `protected @Nullable Music current;`): arrives as an explicit String param, its name; an unset current is passed as "" with has_current false and is never read.'),
        'fade': a('float', 'protected float fade;', 'The fade level (SoundControl.java:35, `protected float fade;`): arrives as an explicit float param and is carried out again -- the guard returns it unchanged, the start writes it to 1f.'),
        'has_last_random_played': a('bool', 'protected Music lastRandomPlayed;', 'Whether a last random track is saved (SoundControl.java:31, `protected Music lastRandomPlayed;`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent).'),
        'last_random_played': a('String', 'protected Music lastRandomPlayed;', 'The last random track played (SoundControl.java:31, `protected Music lastRandomPlayed;`): arrives as an explicit String param, its name; an unset track is passed as "" with has_last_random_played false and is never read.'),
        'should_play': a('bool', 'if(current != null || music == null || !shouldPlay()) return; //do not interrupt already-playing tracks', 'The shouldPlay() gate (SoundControl.java:356, `!shouldPlay()`): arrives as an explicit bool param -- the gate itself is N2299 (`return Core.settings.getInt("musicvol") > 0;`) and is NOT re-ported here. False blocks the start.'),
    }
    play_once_outputs = {
        'current': a('String', 'current = music;', 'The track playing after this call (SoundControl.java:363, `current = music;`): the scheduled track when it starts, the old track (or null) when the guard blocks.'),
        'fade': a('float', 'fade = 1f;', 'The fade level after this call (SoundControl.java:362, `fade = 1f;`): 1 when the track starts, unchanged when the guard blocks.'),
        'last_random_played': a('String', 'lastRandomPlayed = music;', 'The last random track after this call (SoundControl.java:359, `lastRandomPlayed = music;`): the scheduled track when it starts, unchanged when the guard blocks -- the save exists so the next random pick can skip it.'),
        'commands': a('Array', 'current.play();', 'The playback commands this call issues, in Java order (SoundControl.java:364 `current.setVolume(1f);` / :365 `current.setLooping(false);` / :366 `current.play();`): one Dictionary per call (`track`, `action`, `value` when the call takes one). The driver applies them -- this slice NEVER plays audio itself; playback belongs to updateLoops (N2304, held waiting for B).'),
    }
    return (play_music_inputs, play_music_outputs, play_once_inputs, play_once_outputs)


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
    (play_music_inputs, play_music_outputs, play_once_inputs, play_once_outputs) = definitions()

    entries = [
        ('N2345', PLAY_MUSIC_OWNER, 'source_sound_control_play_music_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.playMusic(Music, boolean)', play_music_inputs, play_music_outputs, True, 'Dictionary'),
        ('N2345', PLAY_ONCE_OWNER, 'source_sound_control_play_once_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.playOnce(Music)', play_once_inputs, play_once_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SoundControl playMusic/playOnce state from SoundControl.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SoundControl playMusic/playOnce state from SoundControl.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2345'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2345', dict(status='done', java_source=SOUND_CONTROL, java_class='mindustry.audio.SoundControl', java_method='SoundControl.playMusic(Music, boolean); SoundControl.playOnce(Music)', godot_owner=PLAY_MUSIC_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2345'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
