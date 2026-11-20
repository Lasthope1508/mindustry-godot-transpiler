"""Register the Game SoundControl.setupFilters() (N2349).

SoundControl.setupFilters() (SoundControl.java:70-73,
`protected void setupFilters(){` /
`Core.audio.soundBus.setFilter(0, filter);` /
`Core.audio.soundBus.setFilterParam(0, Filters.paramWet, 0f);`
-- installs the SoundControl filter on sound-bus slot 0
and sets its wet param to 0) is one pure static function
on SourceSoundControlState.gd next to the N2299
shouldPlay / isPlaying, N2306 alwaysPlayMusic,
N2315 isDark, N2326 music getters, N2331 findMusic,
N2336 play/silence/keepSilent, N2339 reload, N2345
playMusic/playOnce and N2347 playRandom. NO audio
playback in this slice (playback belongs to
updateLoops, N2304, held waiting for B); the two
sound-bus calls are returned as command state, never
executed.

RED decisions (resolved at RED): (1) One slice
entry for the one method, following the N2347
precedent (one ledger entry per method group, one
function per method). (2) The `filter` field
(SoundControl.java:39, `protected AudioFilter filter
= new BiquadFilter(){{ set(0, 500, 1); }};`) is
itself unowned -- it arrives as an explicit opaque
Variant param (the N2287 precedent -- the driver
owns the live filter object); this slice never
builds a filter and does NOT register the field
declaration as a new symbol beyond context. (3)
`Filters.paramWet` is the int constant 0 (arc
Filters.java:6, `public static final int paramWet
= 0;`), so the param in the second command is 0 --
the constant itself is NOT an exact_expr here (its
source file is arc, not SoundControl.java); the
rule text records the value. (4) Callers
(constructor :59, update() :149) are NOT ported
here; no driver tick in this slice. (5) update()
stays OUT (it also needs updateLoops N2304, held).
One new result symbol (commands). Slice source:
SoundControl.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_sound_control_play_random import DEFERRED as N2347_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SOUND_CONTROL = 'core/src/mindustry/audio/SoundControl.java'
PROOF = '/root/C07SoundControlSetupFiltersProof'
SETUP_FILTERS_OWNER = 'SourceSoundControlState.source_sound_control_setup_filters_state'
TESTS = ['test_c07_sound_control_setup_filters_registration', 'test_all_c07_sound_control_setup_filters_input_evidence_is_exact', 'test_sound_control_setup_filters_state', 'test_reference_graph_and_actual_c07_sound_control_setup_filters']
# The 1 slice source the N2349 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    SOUND_CONTROL,
]
EXACT_EXPRS = [
    'protected void setupFilters(){',
    'Core.audio.soundBus.setFilter(0, filter);',
    'Core.audio.soundBus.setFilterParam(0, Filters.paramWet, 0f);',
    'protected AudioFilter filter = new BiquadFilter(){{',
    'set(0, 500, 1);',
]

# DEFERRED is carried from the N2347 register script via import --
# never retyped. All N2347 entries are carried verbatim (the
# N2345 chain, the B/C notes, and N2347's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2349's Windows proof debt.
DEFERRED = list(N2347_DEFERRED) + [
    'SoundControl.setupFilters Windows Godot proof -- debt in GOAL.md section 5, same as N2287/N2299/N2306/N2315/N2326/N2331/N2336/N2339/N2345/N2347: the N2349 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SOUND_CONTROL, **extra):
        return backed(typ, source, expr, rule, **extra)

    setup_filters_inputs = {
        'filter': a('Variant', 'protected AudioFilter filter = new BiquadFilter(){{', 'The SoundControl filter (SoundControl.java:39, `protected AudioFilter filter = new BiquadFilter(){{ set(0, 500, 1); }};`): arrives as an explicit opaque Variant param -- the driver owns the live filter object (the N2287 precedent); this slice never builds a filter. Echoed unchanged into the first command.'),
    }
    setup_filters_outputs = {
        'commands': a('Array', 'Core.audio.soundBus.setFilterParam(0, Filters.paramWet, 0f);', 'The sound-bus commands this call issues, in Java order (SoundControl.java:71 `Core.audio.soundBus.setFilter(0, filter);` / :72 `Core.audio.soundBus.setFilterParam(0, Filters.paramWet, 0f);`): one Dictionary per call (`action`, `slot`, plus `filter` for set_filter or `param` + `value` for set_filter_param). `Filters.paramWet` is the int constant 0 (arc Filters.java:6), so the param is 0 and the value is 0.0. The driver applies them -- this slice NEVER plays audio itself; playback belongs to updateLoops (N2304, held waiting for B).'),
    }
    return (setup_filters_inputs, setup_filters_outputs)


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
    (setup_filters_inputs, setup_filters_outputs) = definitions()

    entries = [
        ('N2349', SETUP_FILTERS_OWNER, 'source_sound_control_setup_filters_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.setupFilters()', setup_filters_inputs, setup_filters_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SoundControl setupFilters state from SoundControl.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SoundControl setupFilters state from SoundControl.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2349'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2349', dict(status='done', java_source=SOUND_CONTROL, java_class='mindustry.audio.SoundControl', java_method='SoundControl.setupFilters()', godot_owner=SETUP_FILTERS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2349'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
