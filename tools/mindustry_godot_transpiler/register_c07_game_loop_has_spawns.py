"""Register GameState.hasSpawns() (N2448).

GameState.hasSpawns() (GameState.java:68-70, `public boolean
hasSpawns(){`) is a pure predicate: its only body expr is
`return rules.waves && ((rules.waveTeam.cores().size > 0 && rules.attackMode) || rules.spawns.size > 0);`
(:69). The 1 expr is 0-hit in both ledgers (re-probed at HEAD
70405e1e + origin 6d09d677; the only `hasSpawns` hit anywhere is
the N825 call-site `state.hasSpawns()` in a different method's
condition, not this body). `rules` is the GameState input param,
not an owned schema. `rules.waveTeam.cores()` arrives as the
frame input wave_team_core_count (the count, not the cores()
call -- Team.cores() is a later slice, see batch 41 scope §4c)
and `rules.spawns` as spawn_group_count. The call-sites
(WaveSpawner.playerNear :59 + eachGroundSpawn :126, UnitComp
:772, MinimapRenderer :298, OverlayRenderer :203) are NOT
registered here -- they belong to their own methods. One GD
function on the existing file SourceGameLoopRuntimeState.gd
(opened by N2123 isPaused). One slice source:
GameState.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
GAME_STATE = 'core/src/mindustry/core/GameState.java'
PROOF = '/root/C07GameLoopHasSpawnsProof'
HAS_SPAWNS_OWNER = 'SourceGameLoopRuntimeState.source_game_loop_has_spawns_state'
TESTS = ['test_c07_game_loop_has_spawns_registration', 'test_all_c07_game_loop_has_spawns_input_evidence_is_exact', 'test_game_loop_has_spawns_state', 'test_reference_graph_and_actual_c07_game_loop_has_spawns']
# The 1 slice source the N2448 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/core/GameState.java',
]
EXACT_EXPRS = [
    'return rules.waves && ((rules.waveTeam.cores().size > 0 && rules.attackMode) || rules.spawns.size > 0);',
]

DEFERRED = [
    'The hasSpawns() call-sites -- WaveSpawner.playerNear (WaveSpawner.java:59) + eachGroundSpawn (:126), UnitComp (:772), MinimapRenderer (:298), OverlayRenderer (:203) -- are not in this slice; they belong to their own methods.',
    'Team.cores() (GameState.java:69, `rules.waveTeam.cores()`) is not ported here; GD takes the wave-team core count as a frame input. Team.cores() is a batch 42 candidate (batch 41 scope §4c).',
    'GameState.hasSpawns() Windows Godot proof -- debt in GOAL.md section 5: the N2448 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=GAME_STATE, **extra):
        return backed(typ, source, expr, rule, **extra)

    expr = 'return rules.waves && ((rules.waveTeam.cores().size > 0 && rules.attackMode) || rules.spawns.size > 0);'
    has_spawns_inputs = {
        'waves': a('bool', 'rules.waves', 'Whether waves are enabled (GameState.java:69, `rules.waves`): the first conjunct of hasSpawns(); `rules` is the GameState input param, not an owned schema.'),
        'wave_team_core_count': a('int', 'rules.waveTeam.cores().size > 0', 'How many cores the wave team still has (GameState.java:69, `rules.waveTeam.cores().size > 0`): the count arrives as a frame input; Team.cores() itself is a later slice.'),
        'attack_mode': a('bool', 'rules.attackMode', 'Whether the rules are in attack mode (GameState.java:69, `rules.attackMode`): gates the wave-team-core leg of hasSpawns().'),
        'spawn_group_count': a('int', 'rules.spawns.size > 0', 'How many spawn groups the rules still have (GameState.java:69, `rules.spawns.size > 0`): the count arrives as a frame input.'),
    }
    has_spawns_outputs = {
        'has_spawns': a('bool', expr, 'Whether this map has a spawn point for a wave (GameState.java:69, the full return line): waves on AND (wave team has a core in attack mode OR there are spawn groups).'),
    }
    return has_spawns_inputs, has_spawns_outputs


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
    has_spawns_inputs, has_spawns_outputs = definitions()

    entries = [
        ('N2448', HAS_SPAWNS_OWNER, 'source_game_loop_has_spawns_state', GAME_STATE, 'mindustry.core.GameState', 'GameState.hasSpawns()', has_spawns_inputs, has_spawns_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed GameState.hasSpawns() state from GameState.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed GameState.hasSpawns() state from GameState.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: has_spawns -- the single
    # result key of the GD func.
    by_slice['N2448'] = [
        'source_game_loop_has_spawns_state_result.has_spawns',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2448', dict(status='done', java_source=GAME_STATE, java_class='mindustry.core.GameState', java_method='GameState.hasSpawns()', godot_owner=HAS_SPAWNS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2448'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
