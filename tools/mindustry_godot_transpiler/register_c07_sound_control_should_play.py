"""Register the Game SoundControl.shouldPlay() + isPlaying() gates (N2299).

SoundControl.shouldPlay() (SoundControl.java:369-371,
`protected boolean shouldPlay(){` / `return
Core.settings.getInt("musicvol") > 0;`) and
SoundControl.isPlaying() (SoundControl.java:251-253,
`public boolean isPlaying(){` / `return current != null
&& current.isPlaying();`) are one-line gates over the
current track (SoundControl.java:34, `protected @Nullable
Music current;`). shouldPlay is the music gate its caller
reads every frame (SoundControl.java:304,
`if(!shouldPlay()){` -- a false gate silences the current
track, :305-306, `current.setVolume(0);`); isPlaying is
the null-safe current-track check. Both are pure functions
on SourceSoundControlState.gd next to the N2287 loop
accumulator. NO audio playback in this slice (playback
belongs to updateLoops, N2264, held waiting for B).

RED decisions (resolved at RED): (1) Two pure functions
following the N2291 bool-gate precedent, each returning a
Dictionary with the single bool key -- no source_owner
stamp, no owner-registry constant (N2291 has none
either): source_sound_control_should_play_state(music_vol)
and source_sound_control_is_playing_state(has_current,
current_is_playing). (2) Every live value arrives as an
explicit param: music_vol (int) for shouldPlay -- the
Core.settings accessor is NOT ported in this slice;
has_current + current_is_playing for isPlaying -- no
Music.play / stop calls. (3) The comparisons are kept
exactly: shouldPlay is strict (> 0, so zero or negative
musicvol reads false) and isPlaying short-circuits on
the null check (no current track reads false whatever
current_is_playing says). (4) playOnce() / play() /
playMusic() / playRandom() stay OUT of scope -- they call
these guards but are separate slices; updateLoops() is
N2264, held. Two new result symbols. Slice source:
SoundControl.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_sound_control_loop import DEFERRED as N2287_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SOUND_CONTROL = 'core/src/mindustry/audio/SoundControl.java'
PROOF = '/root/C07SoundControlShouldPlayProof'
SHOULD_PLAY_OWNER = 'SourceSoundControlState.source_sound_control_should_play_state'
IS_PLAYING_OWNER = 'SourceSoundControlState.source_sound_control_is_playing_state'
TESTS = ['test_c07_sound_control_should_play_registration', 'test_all_c07_sound_control_should_play_input_evidence_is_exact', 'test_sound_control_should_play_state', 'test_reference_graph_and_actual_c07_sound_control_should_play']
# The 1 slice source the N2299 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    SOUND_CONTROL,
]
EXACT_EXPRS = [
    'public boolean isPlaying(){',
    'return current != null && current.isPlaying();',
    'protected boolean shouldPlay(){',
    'return Core.settings.getInt("musicvol") > 0;',
    'protected @Nullable Music current;',
    'if(!shouldPlay()){',
    'current.setVolume(0);',
]

# DEFERRED is carried from the N2287 register script via import --
# never retyped. All four N2287 entries are carried verbatim
# (B, C, the soundID/curVolume carry-through note, and N2287's
# own Windows proof debt -- none of them is resolved by this
# slice). One entry is added: N2299's Windows proof debt.
DEFERRED = list(N2287_DEFERRED) + [
    'SoundControl.shouldPlay() / isPlaying() Windows Godot proof -- debt in GOAL.md section 5, same as N2287: the N2299 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SOUND_CONTROL, **extra):
        return backed(typ, source, expr, rule, **extra)

    should_play_inputs = {
        'music_vol': a('int', 'return Core.settings.getInt("musicvol") > 0;', 'The music volume setting (SoundControl.java:370, `Core.settings.getInt("musicvol")`): arrives as an explicit int param -- the Core.settings accessor is NOT ported in this slice.'),
    }
    should_play_outputs = {
        'should_play': a('bool', 'return Core.settings.getInt("musicvol") > 0;', 'Whether music should play: true when the music volume setting is above 0 (SoundControl.java:370, strict > 0, so zero or negative reads false); the caller silences the current track when false (SoundControl.java:304-306, `if(!shouldPlay()){` + `current.setVolume(0);`).'),
    }
    is_playing_inputs = {
        'has_current': a('bool', 'protected @Nullable Music current;', 'Whether a current track is set: the SoundControl.current field (SoundControl.java:34, `protected @Nullable Music current;`), null when no track is playing (cleared at :76, :122, :246); passed explicitly because no Music object is ported in this slice.'),
        'current_is_playing': a('bool', 'return current != null && current.isPlaying();', 'Whether the current track is playing (SoundControl.java:252, `current.isPlaying()`): only read when has_current is true -- the Java null check short-circuits first.'),
    }
    is_playing_outputs = {
        'is_playing': a('bool', 'return current != null && current.isPlaying();', 'Whether a track is currently playing: the null-safe current-track check (SoundControl.java:251-253); false when there is no current track, whatever current_is_playing says.'),
    }
    return should_play_inputs, should_play_outputs, is_playing_inputs, is_playing_outputs


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
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
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
    should_play_inputs, should_play_outputs, is_playing_inputs, is_playing_outputs = definitions()

    entries = [
        ('N2299', SHOULD_PLAY_OWNER, 'source_sound_control_should_play_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.shouldPlay()', should_play_inputs, should_play_outputs, True, 'Dictionary'),
        ('N2299', IS_PLAYING_OWNER, 'source_sound_control_is_playing_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.isPlaying()', is_playing_inputs, is_playing_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SoundControl.shouldPlay() / isPlaying() state from SoundControl.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SoundControl.shouldPlay() / isPlaying() state from SoundControl.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: should_play first, then
    # is_playing (the task order).
    by_slice['N2299'] = [
        'source_sound_control_should_play_state_result.should_play',
        'source_sound_control_is_playing_state_result.is_playing',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2299', dict(status='done', java_source=SOUND_CONTROL, java_class='mindustry.audio.SoundControl', java_method='SoundControl.shouldPlay(); SoundControl.isPlaying()', godot_owner=SHOULD_PLAY_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2299'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
