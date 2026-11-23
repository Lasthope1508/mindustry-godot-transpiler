"""Register the Game SoundControl.isDark() gate (N2315).

SoundControl.isDark() (SoundControl.java:285-299,
`protected boolean isDark(){` / `if(player.team()
.data().hasCore() && player.team().data().core()
.healthf() < 0.85f){` / `//core damaged -> dark` /
`return true;` / `//it may be dark based on wave` /
`if(Mathf.chance((float)(Math.log10((state.wave -
17f)/19f) + 1) / 4f)){` / `//dark based on enemies` /
`return Mathf.chance(state.enemies / 70f + 0.1f);`)
is the dark-music gate: a damaged core (hasCore() and
healthf() strictly below 0.85f) reads dark at once,
otherwise the wave chance roll decides, then the enemy
chance roll. Its caller reads the gate in playRandom()
(SoundControl.java:259, `}else if(isDark()){`) and plays
a dark track when it is true. It is a pure function on
SourceSoundControlState.gd next to the N2299 shouldPlay /
isPlaying and N2306 alwaysPlayMusic gates. NO audio
playback in this slice (playback belongs to updateLoops,
N2304, held waiting for B).

RED decisions (resolved at RED): (1) One pure function
following the N2299/N2306 bool-gate precedent, returning
a Dictionary with the single bool key -- no source_owner
stamp, no owner-registry constant (N2299 has none
either): source_sound_control_is_dark_state(has_core,
core_healthf, wave_chance_roll, enemy_chance_roll).
(2) This is the first RNG slice of the Game family: the
two Mathf.chance outcomes arrive as explicit bool params
-- wave_chance_roll is `Mathf.chance((float)(Math.log10(
(state.wave - 17f)/19f) + 1) / 4f)` and
enemy_chance_roll is `Mathf.chance(state.enemies / 70f
+ 0.1f)` -- so the ported function is pure and never
rolls RNG itself (Mathf.chance is `d >= 1f ||
rand.nextFloat() < d`, Mathf.java:240-242; the caller
draws the rolls). The wave / enemy counts and the
probability formulas are NOT re-evaluated here: each
roll outcome already folds its formula in. (3) The
comparisons are kept exactly: the core branch is strict
(< 0.85f, so exactly 0.85f falls through to the rolls)
and short-circuits on hasCore() (no core reads false
whatever core_healthf says). (4) playRandom() /
playOnce() / update() stay OUT of scope -- they call
this guard but are separate slices; updateLoops() is
N2304, held. One new result symbol. Slice source:
SoundControl.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_sound_control_always_play_music import DEFERRED as N2306_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SOUND_CONTROL = 'core/src/mindustry/audio/SoundControl.java'
PROOF = '/root/C07SoundControlIsDarkProof'
IS_DARK_OWNER = 'SourceSoundControlState.source_sound_control_is_dark_state'
TESTS = ['test_c07_sound_control_is_dark_registration', 'test_all_c07_sound_control_is_dark_input_evidence_is_exact', 'test_sound_control_is_dark_state', 'test_reference_graph_and_actual_c07_sound_control_is_dark']
# The 1 slice source the N2315 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    SOUND_CONTROL,
]
EXACT_EXPRS = [
    'protected boolean isDark(){',
    'if(player.team().data().hasCore() && player.team().data().core().healthf() < 0.85f){',
    '//core damaged -> dark',
    '//it may be dark based on wave',
    'if(Mathf.chance((float)(Math.log10((state.wave - 17f)/19f) + 1) / 4f)){',
    '//dark based on enemies',
    'return Mathf.chance(state.enemies / 70f + 0.1f);',
    '}else if(isDark()){',
]

# DEFERRED is carried from the N2306 register script via import --
# never retyped. All N2306 entries are carried verbatim (the
# N2287 chain, the B/C notes, and N2306's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2315's Windows proof debt.
DEFERRED = list(N2306_DEFERRED) + [
    'SoundControl.isDark() Windows Godot proof -- debt in GOAL.md section 5, same as N2287/N2299: the N2315 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SOUND_CONTROL, **extra):
        return backed(typ, source, expr, rule, **extra)

    is_dark_inputs = {
        'has_core': a('bool', 'player.team().data().hasCore()', 'Whether the player team has a core (SoundControl.java:287, `player.team().data().hasCore()`): arrives as an explicit bool param -- the player.team().data() accessor chain is NOT ported in this slice.'),
        'core_healthf': a('float', 'player.team().data().core().healthf()', 'The core health fraction (SoundControl.java:287, `player.team().data().core().healthf()`): arrives as an explicit float param -- the player.team().data().core() accessor chain is NOT ported in this slice. Only read when has_core is true.'),
        'wave_chance_roll': a('bool', 'Mathf.chance((float)(Math.log10((state.wave - 17f)/19f) + 1) / 4f)', 'The outcome of the wave chance roll (SoundControl.java:293, `Mathf.chance((float)(Math.log10((state.wave - 17f)/19f) + 1) / 4f)`): arrives as an explicit bool param -- the first RNG roll of the Game family, drawn by the caller; the wave count and the log10 probability formula are folded into this outcome, never re-evaluated here, and the ported function never rolls RNG itself.'),
        'enemy_chance_roll': a('bool', 'Mathf.chance(state.enemies / 70f + 0.1f)', 'The outcome of the enemy chance roll (SoundControl.java:298, `Mathf.chance(state.enemies / 70f + 0.1f)`): arrives as an explicit bool param -- the second RNG roll of the Game family, drawn by the caller; the enemy count and the / 70f + 0.1f probability formula are folded into this outcome, never re-evaluated here.'),
    }
    is_dark_outputs = {
        'is_dark': a('bool', 'protected boolean isDark(){', 'Whether to play dark music (SoundControl.java:285-299): true at once when the core is damaged (hasCore() and healthf() strictly below 0.85f), else true when the wave chance roll passes, else the enemy chance roll outcome. The caller plays a dark track when true (SoundControl.java:259, `}else if(isDark()){` + `playOnce(getDarkMusic().random(lastRandomPlayed));`).'),
    }
    return is_dark_inputs, is_dark_outputs


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
    is_dark_inputs, is_dark_outputs = definitions()

    entries = [
        ('N2315', IS_DARK_OWNER, 'source_sound_control_is_dark_state', SOUND_CONTROL, 'mindustry.audio.SoundControl', 'SoundControl.isDark()', is_dark_inputs, is_dark_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SoundControl.isDark() state from SoundControl.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SoundControl.isDark() state from SoundControl.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2315'] = [
        'source_sound_control_is_dark_state_result.is_dark',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2315', dict(status='done', java_source=SOUND_CONTROL, java_class='mindustry.audio.SoundControl', java_method='SoundControl.isDark()', godot_owner=IS_DARK_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2315'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
