"""Register the Game SoundControl.stop() (N2352).

SoundControl.stop() (SoundControl.java:118-127,
`public void stop(){` / `silenced = true;` /
`if(current != null){` / `current.stop();` /
`current = null;` / `fade = 0f;` -- silences playback,
then stops the current track (only when one is
playing), clears it and zeroes the fade) is one pure
static function on SourceSoundControlState.gd next to
the N2299 shouldPlay / isPlaying, N2306
alwaysPlayMusic, N2315 isDark, N2326 music getters,
N2331 findMusic, N2336 play/silence/keepSilent, N2339
reload, N2345 playMusic/playOnce, N2347 playRandom
and N2349 setupFilters. NO audio playback in this
slice (playback belongs to updateLoops, N2304, held
waiting for B); the stop is returned as one command
(`track`, `action` -- the N2345 shape), never
executed.

RED decisions (resolved at RED): (1) One slice
entry for the one method, following the N2347
precedent (one ledger entry per method group, one
function per method). (2) Music arrives as its name
String (the N2287 precedent); has_current folds the
null check (the N2306 precedent); an unset current is
passed as "" with has_current false and is never
read. (3) YELLOW FLAG (scope batch 8 section 3.3):
`silenced = true;` already appears in N2336,
`current.stop();` in N2336/N2345, `current = null;`
and `fade = 0f;` in N2336/N2339/N2345 -- same text,
DIFFERENT method (stop() vs silence() / play()); the
registry precedent (N632-N639 vs N1078-N1085)
allows identical exact_exprs under different
java_methods. This slice registers stop() with those
exprs and does NOT skip the method or change owner
because of the overlap. (4) stop() is a SEPARATE
public method from silence() / keepSilent() (N2336
own those); do not confuse them. (5) Caller
update() :165-167 is NOT ported here; update()
stays OUT (it also needs updateLoops N2304, held).
One new result symbol group (silenced, current,
fade, stopped, commands). Slice source:
SoundControl.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_sound_control_setup_filters import DEFERRED as N2349_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SOUND_CONTROL = 'core/src/mindustry/audio/SoundControl.java'
PROOF = '/root/C07SoundControlStopProof'
STOP_OWNER = 'SourceSoundControlState.source_sound_control_stop_state'
TESTS = ['test_c07_sound_control_stop_registration', 'test_all_c07_sound_control_stop_input_evidence_is_exact', 'test_sound_control_stop_state', 'test_reference_graph_and_actual_c07_sound_control_stop']
# The 1 slice source the N2352 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    SOUND_CONTROL,
]
EXACT_EXPRS = [
    'public void stop(){',
    'silenced = true;',
    'if(current != null){',
    'current.stop();',
    'current = null;',
    'fade = 0f;',
    'protected @Nullable Music current;',
    'protected float fade;',
    'protected boolean silenced, keepSilent;',
]

# DEFERRED is carried from the N2349 register script via import --
# never retyped. All N2349 entries are carried verbatim (the
# N2347 chain, the B/C notes, and N2349's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2352's Windows proof debt.
DEFERRED = list(N2349_DEFERRED) + [
    'SoundControl.stop Windows Godot proof -- debt in GOAL.md section 5, same as N2287/N2299/N2306/N2315/N2326/N2331/N2336/N2339/N2345/N2347/N2349: the N2352 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SOUND_CONTROL, **extra):
        return backed(typ, source, expr, rule, **extra)

    stop_inputs = {
        'has_current': a('bool', 'if(current != null){', 'Whether a track is currently playing (SoundControl.java:120, `if(current != null){`): arrives as an explicit bool param -- the null check is folded into this param (the N2306 precedent).'),
        'current': a('String', 'protected @Nullable Music current;', 'The currently playing track (SoundControl.java:34, `protected @Nullable Music current;`): arrives as an explicit String param, its name (the N2287 precedent); an unset current is passed as "" with has_current false and is never read.'),
        'fade': a('float', 'protected float fade;', 'The fade level (SoundControl.java:35, `protected float fade;`): arrives as an explicit float param and is carried out again -- the stop branch writes it to 0, the no-track branch returns it unchanged.'),
    }
    stop_outputs = {
        'silenced': a('bool', 'silenced = true;', 'Whether playback is silenced after this call (SoundControl.java:119, `silenced = true;`): always true -- set unconditionally, before the current-track guard.'),
        'current': a('String', 'current = null;', 'The track playing after this call (SoundControl.java:122, `current = null;`): always null -- cleared when a track was playing, and already null when none was.'),
        'fade': a('float', 'fade = 0f;', 'The fade level after this call (SoundControl.java:123, `fade = 0f;`): 0 when a track was stopped, the incoming fade unchanged when no track was playing.'),
        'stopped': a('bool', 'current.stop();', 'Whether a stop command was issued (SoundControl.java:121, `current.stop();`): true exactly when a track was playing -- folds the guard, so the driver knows whether the command list is non-empty without reading it.'),
        'commands': a('Array', 'current.stop();', 'The playback commands this call issues, in Java order (SoundControl.java:121 `current.stop();` when a track is playing, nothing otherwise): one Dictionary per call (`track`, `action` -- the N2345 shape). The driver applies them -- this slice NEVER plays audio itself; playback belongs to updateLoops (N2304, held waiting for B).'),
    }
    return (stop_inputs, stop_outputs)


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
    (stop_inputs, stop_outputs) = definitions()

    entries = [
        ('N2352', STOP_OWNER, 'source_sound_control_stop_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.stop()', stop_inputs, stop_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SoundControl stop state from SoundControl.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SoundControl stop state from SoundControl.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2352'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2352', dict(status='done', java_source=SOUND_CONTROL, java_class='mindustry.audio.SoundControl', java_method='SoundControl.stop()', godot_owner=STOP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2352'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
