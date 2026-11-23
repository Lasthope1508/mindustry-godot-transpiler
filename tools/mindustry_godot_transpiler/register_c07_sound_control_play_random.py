"""Register the Game SoundControl.playRandom() (N2347).

SoundControl.playRandom() (SoundControl.java:256-264,
`/** Plays a random track.*/` / `public void
playRandom(){` / `if(state.boss() != null){` /
`playOnce(getBossMusic().random(lastRandomPlayed));` /
`}else if(isDark()){` /
`playOnce(getDarkMusic().random(lastRandomPlayed));` /
`}else{` /
`playOnce(getAmbientMusic().random(lastRandomPlayed));`
-- the branch order is kept exactly: a boss present
reads the boss list first, else isDark() reads the
dark list, else the ambient list. The branch selects
the list; the random pick from that list is the
caller's draw; playOnce (N2345) then starts the
picked track, or blocks with state unchanged when a
track is already playing, the pick is null, or
shouldPlay() is false) is one pure static function
on SourceSoundControlState.gd next to the N2299
shouldPlay / isPlaying, N2306 alwaysPlayMusic,
N2315 isDark, N2326 music getters, N2331 findMusic,
N2336 play/silence/keepSilent, N2339 reload and
N2345 playMusic/playOnce. NO audio playback in
this slice (playback belongs to updateLoops, N2304,
held waiting for B); the setVolume / setLooping /
play calls are returned as playback-command state,
never executed.

RED decisions (resolved at RED): (1) One slice
entry for the one method, following the N2345
precedent (one ledger entry per method group, one
function per method) -- playRandom keeps its own
function and delegates to playOnce (N2345), it does
NOT re-port playOnce. (2) isDark() (N2315) and the
three music getters (N2326) are NOT re-ported here;
their results arrive as explicit params (is_dark,
boss_music, dark_music, ambient_music). (3) The
RNG of this slice is Seq.random(lastRandomPlayed)
(arc Seq.java:1007, returns a random item excluding
the specified element, null when the array is
empty, the single element when size is 1): its
OUTCOME arrives as the explicit has_picked_track /
picked_track params (the N2315 chance-roll
precedent), so the function is pure and never rolls
RNG itself. (4) state.boss() (GameState.java:56-58,
`return teams.bosses.firstOpt();`) is NOT ported
here: only its null test arrives as has_boss (the
N2306 precedent). (5) The selected list is returned
as selected_music, so the branch choice is
observable in the result -- without it the branch
params would be dead, because all three branches
call playOnce the same way; the lists are returned
as-is for the selected branch, matching the
getters' aliasing. (6) current / fade /
lastRandomPlayed arrive as explicit params and are
carried out -- the guard returns them untouched,
the start writes them; has_current / has_picked_track
/ has_last_random_played fold the null checks (the
N2306 precedent -- GDScript typed String params
cannot take null). (7) Music arrives as its name
String (the N2287 precedent). (8) update() stays
OUT (it also needs updateLoops N2304, held). Five
new result symbols (current, fade,
last_random_played, commands, selected_music).
Slice source: SoundControl.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_sound_control_play_music import DEFERRED as N2345_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SOUND_CONTROL = 'core/src/mindustry/audio/SoundControl.java'
PROOF = '/root/C07SoundControlPlayRandomProof'
PLAY_RANDOM_OWNER = 'SourceSoundControlState.source_sound_control_play_random_state'
TESTS = ['test_c07_sound_control_play_random_registration', 'test_all_c07_sound_control_play_random_input_evidence_is_exact', 'test_sound_control_play_random_state', 'test_reference_graph_and_actual_c07_sound_control_play_random']
# The 1 slice source the N2347 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    SOUND_CONTROL,
]
EXACT_EXPRS = [
    '/** Plays a random track.*/',
    'public void playRandom(){',
    'if(state.boss() != null){',
    'playOnce(getBossMusic().random(lastRandomPlayed));',
    '}else if(isDark()){',
    'playOnce(getDarkMusic().random(lastRandomPlayed));',
    '}else{',
    'playOnce(getAmbientMusic().random(lastRandomPlayed));',
    'protected @Nullable Music current;',
    'protected float fade;',
    'protected Music lastRandomPlayed;',
]

# DEFERRED is carried from the N2345 register script via import --
# never retyped. All N2345 entries are carried verbatim (the
# N2339 chain, the B/C notes, and N2345's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2347's Windows proof debt.
DEFERRED = list(N2345_DEFERRED) + [
    'SoundControl.playRandom Windows Godot proof -- debt in GOAL.md section 5, same as N2287/N2299/N2306/N2315/N2326/N2331/N2336/N2339/N2345: the N2347 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SOUND_CONTROL, **extra):
        return backed(typ, source, expr, rule, **extra)

    play_random_inputs = {
        'has_boss': a('bool', 'if(state.boss() != null){', 'Whether a boss unit is present (SoundControl.java:257, `if(state.boss() != null){`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent). state.boss() itself (GameState.java:56-58, `return teams.bosses.firstOpt();`) is NOT ported here, only its null test. True reads the boss list first.'),
        'is_dark': a('bool', '}else if(isDark()){', 'Whether to play dark music (SoundControl.java:259, `}else if(isDark()){`): arrives as an explicit bool param -- the isDark() gate itself is N2315 (`player.team().data().hasCore() && ... healthf() < 0.85f`, wave / enemy chance rolls) and is NOT re-ported here. Only read when no boss is present.'),
        'boss_music': a('Array', 'playOnce(getBossMusic().random(lastRandomPlayed));', 'The boss music list (SoundControl.java:258, `playOnce(getBossMusic().random(lastRandomPlayed));`): arrives as an explicit Array param -- the result of getBossMusic() (N2326), NOT re-ported here. Music arrives as its name String (the N2287 precedent). Only read when a boss is present.'),
        'dark_music': a('Array', 'playOnce(getDarkMusic().random(lastRandomPlayed));', 'The dark music list (SoundControl.java:260, `playOnce(getDarkMusic().random(lastRandomPlayed));`): arrives as an explicit Array param -- the result of getDarkMusic() (N2326), NOT re-ported here. Only read when no boss is present and isDark() is true.'),
        'ambient_music': a('Array', 'playOnce(getAmbientMusic().random(lastRandomPlayed));', 'The ambient music list (SoundControl.java:262, `playOnce(getAmbientMusic().random(lastRandomPlayed));`): arrives as an explicit Array param -- the result of getAmbientMusic() (N2326), NOT re-ported here. Read when no boss is present and isDark() is false.'),
        'has_picked_track': a('bool', 'playOnce(getBossMusic().random(lastRandomPlayed));', 'Whether the random draw picked a track (SoundControl.java:258, `.random(lastRandomPlayed)`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent). Seq.random returns null when the selected list is empty (arc Seq.java:1007-1010), which reads as no pick and playOnce blocks.'),
        'picked_track': a('String', 'playOnce(getBossMusic().random(lastRandomPlayed));', 'The track the random draw picked from the selected list (SoundControl.java:258, `.random(lastRandomPlayed)`): arrives as an explicit String param, its name (the N2287 precedent) -- the RNG OUTCOME (the N2315 chance-roll precedent), so this function never rolls RNG itself. The draw excludes lastRandomPlayed and returns the single element when the list has one (arc Seq.java:1007-1010); an unset pick is passed as "" with has_picked_track false and is never read.'),
        'has_current': a('bool', 'if(current != null || music == null || !shouldPlay()) return; //do not interrupt already-playing tracks', 'Whether a track is currently playing (SoundControl.java:356, the playOnce guard): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent). A playing track blocks the start.'),
        'current': a('String', 'protected @Nullable Music current;', 'The currently playing track (SoundControl.java:34, `protected @Nullable Music current;`): arrives as an explicit String param, its name; an unset current is passed as "" with has_current false and is never read.'),
        'fade': a('float', 'protected float fade;', 'The fade level (SoundControl.java:35, `protected float fade;`): arrives as an explicit float param and is carried out again -- the guard returns it unchanged, the start writes it to 1f.'),
        'has_last_random_played': a('bool', 'protected Music lastRandomPlayed;', 'Whether a last random track is saved (SoundControl.java:31, `protected Music lastRandomPlayed;`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent).'),
        'last_random_played': a('String', 'protected Music lastRandomPlayed;', 'The last random track played (SoundControl.java:31, `protected Music lastRandomPlayed;`): arrives as an explicit String param, its name; an unset track is passed as "" with has_last_random_played false and is never read.'),
        'should_play': a('bool', 'if(current != null || music == null || !shouldPlay()) return; //do not interrupt already-playing tracks', 'The shouldPlay() gate (SoundControl.java:356, `!shouldPlay()`): arrives as an explicit bool param -- the gate itself is N2299 (`return Core.settings.getInt("musicvol") > 0;`) and is NOT re-ported here. False blocks playOnce from starting anything.'),
    }
    play_random_outputs = {
        'current': a('String', 'current = music;', 'The track playing after this call (SoundControl.java:363, `current = music;` in playOnce): the picked track when it starts, the old track (or null) when the guard blocks.'),
        'fade': a('float', 'fade = 1f;', 'The fade level after this call (SoundControl.java:362, `fade = 1f;` in playOnce): 1 when the picked track starts, unchanged when the guard blocks.'),
        'last_random_played': a('String', 'lastRandomPlayed = music;', 'The last random track after this call (SoundControl.java:359, `lastRandomPlayed = music;` in playOnce): the picked track when it starts, unchanged when the guard blocks -- the save exists so the next random pick can skip it.'),
        'commands': a('Array', 'current.play();', 'The playback commands this call issues, in Java order (SoundControl.java:364 `current.setVolume(1f);` / :365 `current.setLooping(false);` / :366 `current.play();` in playOnce): one Dictionary per call (`track`, `action`, `value` when the call takes one). The driver applies them -- this slice NEVER plays audio itself; playback belongs to updateLoops (N2304, held waiting for B).'),
        'selected_music': a('Array', 'if(state.boss() != null){', 'The music list the branch selected (SoundControl.java:257-263, the if / else-if / else chain: boss list when a boss is present, dark list when isDark(), else the ambient list): returned as-is, matching the N2326 getters aliasing. Without it the branch choice would be unobservable in the result, because all three branches call playOnce the same way.'),
    }
    return (play_random_inputs, play_random_outputs)


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
    (play_random_inputs, play_random_outputs) = definitions()

    entries = [
        ('N2347', PLAY_RANDOM_OWNER, 'source_sound_control_play_random_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.playRandom()', play_random_inputs, play_random_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SoundControl playRandom state from SoundControl.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SoundControl playRandom state from SoundControl.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2347'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2347', dict(status='done', java_source=SOUND_CONTROL, java_class='mindustry.audio.SoundControl', java_method='SoundControl.playRandom()', godot_owner=PLAY_RANDOM_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2347'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
