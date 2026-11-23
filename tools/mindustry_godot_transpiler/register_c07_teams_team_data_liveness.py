"""Register TeamData liveness accessors (N2374).

TeamData.hasCore()+isAlive()+noCores()+core()+hasAI()
(Teams.java:450-472,
`public boolean hasCore(){` /
`return cores.size > 0;` /
`public boolean isAlive(){` /
`return hasCore();` /
`public boolean noCores(){` /
`return cores.isEmpty();` /
`@Nullable` /
`public CoreBuild core(){` /
`return cores.isEmpty() ? null : cores.first();` /
`public boolean hasAI(){` /
`return team.rules().rtsAi || team.rules().buildAi;`) is one
grouped slice: five one-line accessors, one record, five
java_method entries, one shared owner -- main-thread decision
2026-11-21 (the N2326/N2297 group precedent). isAlive()
delegates to hasCore() -- that delegate is inside this same
group, not an outside dedup. active() (Teams.java:446-448)
is EXCLUDED: its only line is already the exact_expr of
N2074+N2075. The cores arrive as an explicit Array of opaque
core refs (the N2330 param precedent); team.rules() arrives
as the explicit team_rules dict {rts_ai, build_ai} because
Rules is not ported. Five new result symbols: has_core,
is_alive, no_cores, core, has_ai. One slice source:
Teams.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_each_enemy_core import DEFERRED as N2365_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamDataLivenessProof'
LIVENESS_OWNER = 'SourceTeamsRuntimeState.source_team_data_liveness_state'
TESTS = ['test_c07_teams_team_data_liveness_registration', 'test_all_c07_teams_team_data_liveness_input_evidence_is_exact', 'test_teams_team_data_liveness_state', 'test_reference_graph_and_actual_c07_teams_team_data_liveness']
# The 1 slice source the N2374 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'public class Teams{',
    'public boolean hasCore(){',
    'return cores.size > 0;',
    'public boolean isAlive(){',
    'return hasCore();',
    'public boolean noCores(){',
    'return cores.isEmpty();',
    '@Nullable',
    'public CoreBuild core(){',
    'return cores.isEmpty() ? null : cores.first();',
    'public boolean hasAI(){',
    'return team.rules().rtsAi || team.rules().buildAi;',
]

# DEFERRED is carried from the N2365 register script via import --
# never retyped. All N2365 entries are carried verbatim (the
# Game chain, the B/C notes, and N2365's own Windows proof
# debt -- none of them is resolved by this slice). One entry is
# added: N2374's Windows proof debt.
DEFERRED = list(N2365_DEFERRED) + [
    'TeamData.hasCore()+isAlive()+noCores()+core()+hasAI() Windows Godot proof -- debt in GOAL.md section 5, same as N2365: the N2374 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    liveness_inputs = {
        'cores': a('Array', 'return cores.size > 0;', 'The team cores as opaque refs (Teams.java:451, `return cores.size > 0;`): the cores seq is NOT ported -- it arrives as an explicit Array (the N2330 param precedent); the caller passes the team\'s cores, in order, so core() can return the first.'),
        'team_rules': a('Dictionary', 'return team.rules().rtsAi || team.rules().buildAi;', 'The team rules as {rts_ai, build_ai} (Teams.java:471, `return team.rules().rtsAi || team.rules().buildAi;`): team.rules() is Rules state (not ported), so it arrives as an explicit dict (the N2330 param precedent); missing keys read as false.'),
    }
    liveness_outputs = {
        'has_core': a('bool', 'return cores.size > 0;', 'Whether the team has any core (Teams.java:451, `return cores.size > 0;`): true exactly when the cores Array is non-empty.'),
        'is_alive': a('bool', 'return hasCore();', 'Whether the team is alive (Teams.java:456, `return hasCore();`): isAlive() delegates to hasCore() in Java, so this is the same value as has_core -- the delegate is inside this same group, not an outside dedup.'),
        'no_cores': a('bool', 'return cores.isEmpty();', 'Whether the team has no cores (Teams.java:460, `return cores.isEmpty();`): the exact inverse of has_core.'),
        'core': a('Variant', 'return cores.isEmpty() ? null : cores.first();', 'The first core, or null (Teams.java:465, `return cores.isEmpty() ? null : cores.first();`): null when the team has no cores (the @Nullable return, Teams.java:463) -- the caller must null-check before using it.'),
        'has_ai': a('bool', 'return team.rules().rtsAi || team.rules().buildAi;', 'Whether the team is controlled by the AI and builds bases (Teams.java:471, `return team.rules().rtsAi || team.rules().buildAi;`): true when either rts_ai or build_ai is set in team_rules.'),
    }
    return (liveness_inputs, liveness_outputs)


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
    (liveness_inputs, liveness_outputs) = definitions()

    entries = [
        ('N2374', LIVENESS_OWNER, 'source_team_data_liveness_state', TEAMS, 'mindustry.game.Teams.TeamData', 'TeamData.hasCore()/isAlive()/noCores()/core()/hasAI()', liveness_inputs, liveness_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TeamData.hasCore()+isAlive()+noCores()+core()+hasAI() state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TeamData.hasCore()+isAlive()+noCores()+core()+hasAI() state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: has_core, is_alive, no_cores, core, has_ai.
    by_slice['N2374'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2374', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams.TeamData', java_method='TeamData.hasCore()/isAlive()/noCores()/core()/hasAI()', godot_owner=LIVENESS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2374'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
