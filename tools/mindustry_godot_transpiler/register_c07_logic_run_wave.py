"""Register Logic.runWave() (N2437).

Logic.runWave() (Logic.java:319-325, `public void runWave(){`)
advances the wave: it spawns the next wave's enemies, increments
the wave counter, recomputes the wave timer from the wave
spacing and the campaign difficulty multiplier, and fires a
WaveEvent. The 4 body exprs are all 0-hit in both ledgers
(re-probed at HEAD 70227d4b): `spawner.spawnEnemies();` (:320),
`state.wave++;` (:321), the wavetime assignment (:322) and
`Events.fire(new WaveEvent());` (:324). The wavetime formula in
play() (Logic.java:272, with initialWaveSpacing + `* 2`) is NOT
in this slice, nor is skipWave() (Logic.java:315-317, a later
1-expr slice once runWave lands) nor `state.stats.wavesLasted =
state.wave;` from gameOver() (Logic.java:434, a different
method). One GD function on the NEW SourceGameWaveState.gd (the
file-new precedent is N2405 SourceBaseTurretDefaults.gd + N2407
SourceContinuousTurretDefaults.gd). The two call-sites are
deferred as data in the returned Dictionary: spawner.spawnEnemies()
waits for a WaveSpawner slice (WaveSpawner.java unscanned, method
WaveSpawner 0-hit both ledgers) and Events.fire(new WaveEvent())
waits for an event bus (method Events.on 0-hit both ledgers; no
bus in the port). The wavetime formula is pure math with explicit
inputs: waveSpacing * (isCampaign ? waveTimeMultiplier : 1f).
Four new result symbols: one per result key. One slice source:
Logic.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LOGIC = 'core/src/mindustry/core/Logic.java'
PROOF = '/root/C07LogicRunWaveProof'
RUN_OWNER = 'SourceGameWaveState.source_game_wave_run_state'
TESTS = ['test_c07_logic_run_wave_registration', 'test_all_c07_logic_run_wave_input_evidence_is_exact', 'test_logic_run_wave_state', 'test_reference_graph_and_actual_c07_logic_run_wave']
# The 1 slice source the N2437 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/core/Logic.java',
]
EXACT_EXPRS = [
    'spawner.spawnEnemies();',
    'state.wave++;',
    'state.wavetime = state.rules.waveSpacing * (state.isCampaign() ? state.getPlanet().campaignRules.difficulty.waveTimeMultiplier : 1f);',
    'Events.fire(new WaveEvent());',
]

DEFERRED = [
    'WaveSpawner.spawnEnemies() call-site -- waits for a WaveSpawner slice (WaveSpawner.java unscanned, method WaveSpawner 0-hit both ledgers); the runWave func records spawn_enemies: true as data until then.',
    'Events.fire(new WaveEvent()) -- no event bus in the port (method Events.on 0-hit both ledgers); the runWave func records fired_event: "WaveEvent" as data; event-bus design is a separate main-thread decision.',
    'Logic.skipWave() -- calls runWave(); becomes a 1-expr slice after N2437 lands (same new file SourceGameWaveState.gd).',
    'Logic.runWave() Windows Godot proof -- debt in GOAL.md section 5: the N2437 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=LOGIC, **extra):
        return backed(typ, source, expr, rule, **extra)

    run_inputs = {
        'wave': a('int', 'state.wave++;', 'The current wave counter (Logic.java:321, `state.wave++;`): runWave increments it, so wave is an in param -- the value before this wave runs.'),
        'wave_spacing': a('float', 'state.wavetime = state.rules.waveSpacing * (state.isCampaign() ? state.getPlanet().campaignRules.difficulty.waveTimeMultiplier : 1f);', 'The base wave spacing in seconds (Logic.java:322, the wavetime assignment): state.rules.waveSpacing, the first factor of the wavetime formula.'),
        'is_campaign': a('bool', 'state.wavetime = state.rules.waveSpacing * (state.isCampaign() ? state.getPlanet().campaignRules.difficulty.waveTimeMultiplier : 1f);', 'Whether the game is a campaign game (Logic.java:322, the wavetime assignment): state.isCampaign() selects the difficulty multiplier when true, 1f otherwise.'),
        'wave_time_multiplier': a('float', 'state.wavetime = state.rules.waveSpacing * (state.isCampaign() ? state.getPlanet().campaignRules.difficulty.waveTimeMultiplier : 1f);', 'The campaign difficulty wave-time multiplier (Logic.java:322, the wavetime assignment): state.getPlanet().campaignRules.difficulty.waveTimeMultiplier, applied only when is_campaign is true.'),
    }
    run_outputs = {
        'wave': a('int', 'state.wave++;', 'The wave counter after this run (Logic.java:321, `state.wave++;`): the input wave incremented by one.'),
        'wavetime': a('float', 'state.wavetime = state.rules.waveSpacing * (state.isCampaign() ? state.getPlanet().campaignRules.difficulty.waveTimeMultiplier : 1f);', 'The wave timer after this run (Logic.java:322, the wavetime assignment): waveSpacing * (isCampaign ? waveTimeMultiplier : 1f) -- pure math with explicit inputs; distinct from the play() formula (Logic.java:272) which adds initialWaveSpacing and `* 2`.'),
        'spawn_enemies': a('bool', 'spawner.spawnEnemies();', 'Whether the spawner was asked to spawn this wave\'s enemies (Logic.java:320, `spawner.spawnEnemies();`): WaveSpawner is not ported on either line, so the call-site is recorded as data -- true -- until a WaveSpawner slice lands.'),
        'fired_event': a('String', 'Events.fire(new WaveEvent());', 'The event this run fires (Logic.java:324, `Events.fire(new WaveEvent());`): no event bus exists in the port, so the fire is recorded as data -- the string "WaveEvent" -- until an event bus is designed.'),
    }
    return run_inputs, run_outputs


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
    run_inputs, run_outputs = definitions()

    entries = [
        ('N2437', RUN_OWNER, 'source_game_wave_run_state', LOGIC, 'mindustry.core.Logic', 'Logic.runWave()', run_inputs, run_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Logic.runWave() state from Logic.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Logic.runWave() state from Logic.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: wave, wavetime, spawn_enemies,
    # fired_event -- the result-key order of the GD func.
    by_slice['N2437'] = [
        'source_game_wave_run_state_result.wave',
        'source_game_wave_run_state_result.wavetime',
        'source_game_wave_run_state_result.spawn_enemies',
        'source_game_wave_run_state_result.fired_event',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2437', dict(status='done', java_source=LOGIC, java_class='mindustry.core.Logic', java_method='Logic.runWave()', godot_owner=RUN_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2437'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
