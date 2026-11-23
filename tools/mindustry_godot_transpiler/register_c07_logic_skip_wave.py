"""Register Logic.skipWave() (N2437).

Logic.skipWave() (Logic.java:315-317, `public void skipWave(){`)
skips the current wave by calling runWave(): its only body
expr is `runWave();` (:316). The 1 expr is 0-hit in both
ledgers (re-probed at HEAD 91576ded): it appears only in the
deferred_exprs of N2437 ("Logic.skipWave() -- calls runWave();
becomes a 1-expr slice after N2437 lands") -- a deferred
mention, not an exact_expr, and N2437 does not own it. The
runWave body exprs (:320-324) are owned by N2437 and are NOT
re-registered here; only the call site is. One GD function on
SourceGameWaveState.gd (created by N2437): the skip func
forwards its 4 inputs to source_game_wave_run_state and
returns an envelope with skipped_wave: true plus runWave's 4
result keys. The forward precedent is N2422
(LaserTurretBuild.placed() forwarding to super.placed()).
The 4 forwarded result keys (wave, wavetime, spawn_enemies,
fired_event) keep their N2437 java evidence: each value is
produced by the runWave body line named in its rule, and the
skip func only forwards it. One slice source: Logic.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LOGIC = 'core/src/mindustry/core/Logic.java'
PROOF = '/root/C07LogicSkipWaveProof'
SKIP_OWNER = 'SourceGameWaveState.source_game_wave_skip_state'
TESTS = ['test_c07_logic_skip_wave_registration', 'test_all_c07_logic_skip_wave_input_evidence_is_exact', 'test_logic_skip_wave_state', 'test_reference_graph_and_actual_c07_logic_skip_wave']
# The 1 slice source the N2439 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/core/Logic.java',
]
EXACT_EXPRS = [
    'runWave();',
]

# The first two entries are carried from N2437 (still
# unresolved -- the skip func forwards them through runWave);
# the skipWave entry of N2437 is resolved by this slice.
DEFERRED = [
    'WaveSpawner.spawnEnemies() call-site -- waits for a WaveSpawner slice (WaveSpawner.java unscanned, method WaveSpawner 0-hit both ledgers); the runWave func records spawn_enemies: true as data until then, and skipWave forwards it.',
    'Events.fire(new WaveEvent()) -- no event bus in the port (method Events.on 0-hit both ledgers); the runWave func records fired_event: "WaveEvent" as data, and skipWave forwards it; event-bus design is a separate main-thread decision.',
    'Logic.skipWave() Windows Godot proof -- debt in GOAL.md section 5: the N2439 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=LOGIC, **extra):
        return backed(typ, source, expr, rule, **extra)

    # skipWave forwards runWave's 4 inputs unchanged: the
    # input evidence is the runWave body line that consumes
    # each input (owned N2437 as exact_exprs, reused here
    # as evidence only -- NOT re-registered).
    skip_inputs = {
        'wave': a('int', 'state.wave++;', 'The current wave counter (Logic.java:321, `state.wave++;`): skipWave forwards it to runWave, which increments it, so wave is an in param -- the value before this wave runs.'),
        'wave_spacing': a('float', 'state.wavetime = state.rules.waveSpacing * (state.isCampaign() ? state.getPlanet().campaignRules.difficulty.waveTimeMultiplier : 1f);', 'The base wave spacing in seconds (Logic.java:322, the wavetime assignment): skipWave forwards it to runWave; state.rules.waveSpacing, the first factor of the wavetime formula.'),
        'is_campaign': a('bool', 'state.wavetime = state.rules.waveSpacing * (state.isCampaign() ? state.getPlanet().campaignRules.difficulty.waveTimeMultiplier : 1f);', 'Whether the game is a campaign game (Logic.java:322, the wavetime assignment): skipWave forwards it to runWave; state.isCampaign() selects the difficulty multiplier when true, 1f otherwise.'),
        'wave_time_multiplier': a('float', 'state.wavetime = state.rules.waveSpacing * (state.isCampaign() ? state.getPlanet().campaignRules.difficulty.waveTimeMultiplier : 1f);', 'The campaign difficulty wave-time multiplier (Logic.java:322, the wavetime assignment): skipWave forwards it to runWave; state.getPlanet().campaignRules.difficulty.waveTimeMultiplier, applied only when is_campaign is true.'),
    }
    skip_outputs = {
        'skipped_wave': a('bool', 'runWave();', 'Whether this call skipped a wave (Logic.java:316, `runWave();`): skipWave\'s only body expr calls runWave; the GD function records that the skip ran, returning an envelope with `skipped_wave: true`.'),
        'wave': a('int', 'state.wave++;', 'The wave counter after this skip (Logic.java:321, `state.wave++;`): forwarded from runWave (N2437) -- the input wave incremented by one.'),
        'wavetime': a('float', 'state.wavetime = state.rules.waveSpacing * (state.isCampaign() ? state.getPlanet().campaignRules.difficulty.waveTimeMultiplier : 1f);', 'The wave timer after this skip (Logic.java:322, the wavetime assignment): forwarded from runWave (N2437) -- waveSpacing * (isCampaign ? waveTimeMultiplier : 1f).'),
        'spawn_enemies': a('bool', 'spawner.spawnEnemies();', 'Whether the spawner was asked to spawn this wave\'s enemies (Logic.java:320, `spawner.spawnEnemies();`): forwarded from runWave (N2437) -- recorded as data -- true -- until a WaveSpawner slice lands.'),
        'fired_event': a('String', 'Events.fire(new WaveEvent());', 'The event this skip fires (Logic.java:324, `Events.fire(new WaveEvent());`): forwarded from runWave (N2437) -- recorded as data -- the string "WaveEvent" -- until an event bus is designed.'),
    }
    return skip_inputs, skip_outputs


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
    skip_inputs, skip_outputs = definitions()

    entries = [
        ('N2439', SKIP_OWNER, 'source_game_wave_skip_state', LOGIC, 'mindustry.core.Logic', 'Logic.skipWave()', skip_inputs, skip_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Logic.skipWave() state from Logic.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Logic.skipWave() state from Logic.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: skipped_wave, wave,
    # wavetime, spawn_enemies, fired_event -- the
    # result-key order of the GD func.
    by_slice['N2439'] = [
        'source_game_wave_skip_state_result.skipped_wave',
        'source_game_wave_skip_state_result.wave',
        'source_game_wave_skip_state_result.wavetime',
        'source_game_wave_skip_state_result.spawn_enemies',
        'source_game_wave_skip_state_result.fired_event',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2439', dict(status='done', java_source=LOGIC, java_class='mindustry.core.Logic', java_method='Logic.skipWave()', godot_owner=SKIP_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2439'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
