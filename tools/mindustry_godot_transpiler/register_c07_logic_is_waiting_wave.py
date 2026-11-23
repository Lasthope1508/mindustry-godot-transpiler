"""Register Logic.isWaitingWave() (N2436).

Logic.isWaitingWave() (Logic.java:605-607, `public boolean
isWaitingWave(){`) is the pure predicate for whether the
wave timer is paused due to enemies (javadoc :604):
`:606` `return (state.rules.waitEnemies || (state.wave
>= state.rules.winWave && state.rules.winWave > 0)) &&
state.enemies > 0;`. The line is 0-hit in BOTH ledgers
(re-probed at base 70227d4b).

One GD function on the existing
SourceGameLoopRuntimeState.gd (the N2123 file): the new
func source_game_loop_is_waiting_wave_state takes the
four frame inputs as explicit params and returns the
`waiting` envelope key. `state.enemies` is read as-is
from the frame input and never counted here (the count
leg lives in Logic.update(), a later slice).

NOT re-registered here: the call-site
`if(!isWaitingWave()){` (Logic.java:577, inside
update()) -- it belongs to the update() driver-tick
slice, a later slice. No other line of isWaitingWave()
exists: the method is one signature line + one return
line.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c06_pause_gate import DEFERRED as N2123_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LOGIC = 'core/src/mindustry/core/Logic.java'
PROOF = '/root/C07LogicIsWaitingWaveProof'
IS_WAITING_WAVE_OWNER = 'SourceGameLoopRuntimeState.source_game_loop_is_waiting_wave_state'
TESTS = ['test_c07_logic_is_waiting_wave_registration', 'test_all_c07_logic_is_waiting_wave_input_evidence_is_exact', 'test_logic_is_waiting_wave_state', 'test_reference_graph_and_actual_c07_logic_is_waiting_wave']
SLICE_SOURCES = [
    'core/src/mindustry/core/Logic.java',
]
EXACT_EXPRS = [
    'return (state.rules.waitEnemies || (state.wave >= state.rules.winWave && state.rules.winWave > 0)) && state.enemies > 0;',
]

# DEFERRED is carried from the N2123 register script via import --
# never retyped. Three entries are added: the N2436 Windows Godot
# proof debt (GOAL.md section 5), the update() call-site, and the
# enemies-count leg.
DEFERRED = N2123_DEFERRED + [
    'Logic.isWaitingWave() N2436 Windows Godot proof -- debt in GOAL.md section 5, same as N2123: the N2436 proof runs headless on Linux here and waits for a Windows Godot run.',
    'The isWaitingWave() call-site `if(!isWaitingWave()){` (Logic.java:577, inside update()) is a later slice: it belongs to the update() driver-tick slice, not to the predicate slice N2436.',
    'The `state.enemies` count leg in Logic.update() is a later slice: isWaitingWave() only reads the frame value, it never counts enemies itself.',
]


def definitions():
    def a(typ, expr, rule, source=LOGIC, **extra):
        return backed(typ, source, expr, rule, **extra)

    expr = 'return (state.rules.waitEnemies || (state.wave >= state.rules.winWave && state.rules.winWave > 0)) && state.enemies > 0;'
    is_waiting_wave_inputs = {
        'wait_enemies': a('bool', expr, 'Whether the rules wait for enemies before the next wave (Logic.java:606, `state.rules.waitEnemies`): the first disjunct of isWaitingWave().'),
        'wave': a('int', expr, 'The current wave number (Logic.java:606, `state.wave`): compared against winWave in the second disjunct of isWaitingWave().'),
        'win_wave': a('int', expr, 'The wave the player must reach to win (Logic.java:606, `state.rules.winWave`): the wave must reach it, and it must be > 0, for the second disjunct of isWaitingWave() to hold.'),
        'enemies': a('int', expr, 'The number of live enemies (Logic.java:606, `state.enemies`): read as-is from the frame input, never counted here -- the count leg lives in Logic.update(), a later slice.'),
    }
    is_waiting_wave_outputs = {
        'waiting': a('bool', expr, 'Whether the wave timer is paused due to enemies (Logic.java:606, the full return line): (waitEnemies || (wave >= winWave && winWave > 0)) && enemies > 0.'),
    }
    return is_waiting_wave_inputs, is_waiting_wave_outputs


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
    is_waiting_wave_inputs, is_waiting_wave_outputs = definitions()

    entries = [
        ('N2436', IS_WAITING_WAVE_OWNER, 'source_game_loop_is_waiting_wave_state', LOGIC, 'mindustry.core.Logic', 'Logic.isWaitingWave()', is_waiting_wave_inputs, is_waiting_wave_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Logic.isWaitingWave() wave-wait predicate state from Logic.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Logic.isWaitingWave() wave-wait predicate state from Logic.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the waiting key only.
    by_slice['N2436'] = [
        'source_game_loop_is_waiting_wave_state_result.waiting',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2436', dict(status='done', java_source=LOGIC, java_class='mindustry.core.Logic', java_method='Logic.isWaitingWave()', godot_owner=IS_WAITING_WAVE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2436'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
