"""Register the Game SoundControl.alwaysPlayMusic() gate (N2306).

SoundControl.alwaysPlayMusic() (SoundControl.java:266-268,
`protected boolean alwaysPlayMusic(){` / `return
state.rules.alwaysPlayMusic ||
Core.settings.getBool("alwaysmusic") ||
(state.getPlanet() != null &&
state.getPlanet().alwaysPlayMusic);`) is a one-line gate
over three bool flags: the rules flag
(state.rules.alwaysPlayMusic), the "alwaysmusic" settings
flag, and the planet flag (null-safe: the planet branch
only reads when state.getPlanet() != null). Its caller
reads the gate in update() (SoundControl.java:181-183,
`if(alwaysPlayMusic()){` + `if(current == null){` +
`playRandom();`) and plays a random track when the gate
is true and no current track is set. It is a pure
function on SourceSoundControlState.gd next to the N2299
shouldPlay / isPlaying gates. NO audio playback in this
slice (playback belongs to updateLoops, N2304, held
waiting for B).

RED decisions (resolved at RED): (1) One pure function
following the N2299 bool-gate precedent, returning a
Dictionary with the single bool key -- no source_owner
stamp, no owner-registry constant (N2299 has none
either): source_sound_control_always_play_music_state(
rules_always_play_music, setting_alwaysmusic,
planet_always_play_music). (2) Every live value arrives
as an explicit param: the three flags -- the
state.rules / Core.settings / state.getPlanet()
accessors are NOT ported in this slice; the planet
null check is folded into the planet_always_play_music
param (false when there is no planet or its flag is
false). (3) The disjunction is kept exactly: a plain
OR of the three flags, so any single true flag reads
true and all false reads false. (4) playRandom() /
playOnce() / update() stay OUT of scope -- they call
this guard but are separate slices; updateLoops() is
N2304, held. One new result symbol. Slice source:
SoundControl.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_sound_control_should_play import DEFERRED as N2299_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SOUND_CONTROL = 'core/src/mindustry/audio/SoundControl.java'
PROOF = '/root/C07SoundControlAlwaysPlayMusicProof'
ALWAYS_PLAY_MUSIC_OWNER = 'SourceSoundControlState.source_sound_control_always_play_music_state'
TESTS = ['test_c07_sound_control_always_play_music_registration', 'test_all_c07_sound_control_always_play_music_input_evidence_is_exact', 'test_sound_control_always_play_music_state', 'test_reference_graph_and_actual_c07_sound_control_always_play_music']
# The 1 slice source the N2306 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    SOUND_CONTROL,
]
EXACT_EXPRS = [
    'protected boolean alwaysPlayMusic(){',
    'return state.rules.alwaysPlayMusic || Core.settings.getBool("alwaysmusic") || (state.getPlanet() != null && state.getPlanet().alwaysPlayMusic);',
    'if(alwaysPlayMusic()){',
    'if(current == null){',
    'playRandom();',
]

# DEFERRED is carried from the N2299 register script via import --
# never retyped. All N2299 entries are carried verbatim (the
# N2287 chain, the B/C notes, and N2299's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2306's Windows proof debt.
DEFERRED = list(N2299_DEFERRED) + [
    'SoundControl.alwaysPlayMusic() Windows Godot proof -- debt in GOAL.md section 5, same as N2287/N2299: the N2306 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SOUND_CONTROL, **extra):
        return backed(typ, source, expr, rule, **extra)

    always_play_music_inputs = {
        'rules_always_play_music': a('bool', 'state.rules.alwaysPlayMusic', 'The rules flag (SoundControl.java:267, `state.rules.alwaysPlayMusic`): arrives as an explicit bool param -- the state.rules accessor is NOT ported in this slice.'),
        'setting_alwaysmusic': a('bool', 'Core.settings.getBool("alwaysmusic")', 'The "alwaysmusic" settings flag (SoundControl.java:267, `Core.settings.getBool("alwaysmusic")`): arrives as an explicit bool param -- the Core.settings accessor is NOT ported in this slice.'),
        'planet_always_play_music': a('bool', '(state.getPlanet() != null && state.getPlanet().alwaysPlayMusic)', 'The planet flag (SoundControl.java:267, `(state.getPlanet() != null && state.getPlanet().alwaysPlayMusic)`): false when there is no planet or its flag is false -- the null check is folded into this explicit bool param, no Planet object is ported in this slice.'),
    }
    always_play_music_outputs = {
        'always_play_music': a('bool', 'return state.rules.alwaysPlayMusic || Core.settings.getBool("alwaysmusic") || (state.getPlanet() != null && state.getPlanet().alwaysPlayMusic);', 'Whether music should always play: a plain OR of the three flags (SoundControl.java:266-268); any single true flag reads true, all false reads false. The caller plays a random track when true and no current track is set (SoundControl.java:181-183, `if(alwaysPlayMusic()){` + `if(current == null){` + `playRandom();`).'),
    }
    return always_play_music_inputs, always_play_music_outputs


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
    always_play_music_inputs, always_play_music_outputs = definitions()

    entries = [
        ('N2306', ALWAYS_PLAY_MUSIC_OWNER, 'source_sound_control_always_play_music_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.alwaysPlayMusic()', always_play_music_inputs, always_play_music_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SoundControl.alwaysPlayMusic() state from SoundControl.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SoundControl.alwaysPlayMusic() state from SoundControl.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2306'] = [
        'source_sound_control_always_play_music_state_result.always_play_music',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2306', dict(status='done', java_source=SOUND_CONTROL, java_class='mindustry.audio.SoundControl', java_method='SoundControl.alwaysPlayMusic()', godot_owner=ALWAYS_PLAY_MUSIC_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2306'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
