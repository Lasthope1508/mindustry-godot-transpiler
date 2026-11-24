"""Register Rules.unitHealth(Team) (N2459).

Rules.unitHealth(Team) (Rules.java:283-286) is one slice (batch 45
slot 2):
    public float unitHealth(Team team){
        //a 0 here would be a very bad idea.
        return Math.max(unitHealthMultiplier * teams.get(team).unitHealthMultiplier, 0.000001f);
    }
It is the sibling of N2096 unitCost (same file, same shape
`rules_state`, same per-team default): the global multiplier
defaults to 1f (Rules.java:87) and the per-team multiplier
defaults to 1f (Rules.java:363, TeamRules). The trap is the
0.000001f floor -- a product of 0 (or negative) still returns
0.000001, not 0, exactly as the Java comment :284 says; a port
that clamps to 0 is wrong. A team missing from the dict means
the Java fresh TeamRule, so its multiplier defaults to 1f.
One GD function on the existing file
SourceRulesRuntimeState.gd (home of N2096 unitCost and N2458
mode), placed after source_unit_cost_state because unitHealth()
(:283-286) comes after unitCost() (:275-276) in Rules.java. One
slice source: Rules.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RULES = 'core/src/mindustry/game/Rules.java'
PROOF = '/root/C07RulesUnitHealthProof'
HEALTH_OWNER = 'SourceRulesRuntimeState.source_rules_unit_health_state'
TESTS = ['test_c07_rules_unit_health_registration', 'test_all_c07_rules_unit_health_input_evidence_is_exact', 'test_rules_unit_health_state', 'test_reference_graph_and_actual_c07_rules_unit_health']
# The 1 slice source the N2459 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Rules.java',
]
FORMULA = '        return Math.max(unitHealthMultiplier * teams.get(team).unitHealthMultiplier, 0.000001f);'
EXACT_EXPRS = [
    '    public float unitHealth(Team team){',
    '        //a 0 here would be a very bad idea.',
    FORMULA,
    '    /** How much health units start with. */\n    public float unitHealthMultiplier = 1f;',
    '        /** How much health units start with. */\n        public float unitHealthMultiplier = 1f;',
]
JAVA_METHOD = 'Rules.unitHealth(Team)'

DEFERRED = [
    'Rules.unitDamage / unitBuildSpeed / unitMineSpeed / blockHealth / blockDamage / buildSpeed -- same multiplier family as unitCost/unitHealth, left for a later batch so batch 45 is not all one pattern.',
    'Rules.unitHealth() Windows Godot proof -- debt in GOAL.md section 5: the N2459 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RULES, **extra):
        return backed(typ, source, expr, rule, **extra)

    health_inputs = {
        'rules_state': a('Dictionary', FORMULA, 'The live rules state (Rules.java:283-286): a Dictionary with the global unitHealthMultiplier (:87, defaults to 1f) and a "teams" dict of per-team unitHealthMultiplier values (:363, TeamRules, defaults to 1f). A team missing from the dict means the Java fresh TeamRule, so its multiplier defaults to 1f.'),
        'team_id': a('int', FORMULA, 'The team whose unit health multiplier to read (Rules.java:283, `unitHealth(Team team)`).'),
    }
    health_outputs = {
        'unit_health': a('float', FORMULA, 'The unit health multiplier (Rules.java:283-286): Math.max(global * team, 0.000001f). The floor is 0.000001, not 0 -- a product of 0 or negative still returns 0.000001, exactly as the Java comment :284 says ("a 0 here would be a very bad idea").'),
    }
    return health_inputs, health_outputs


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
    health_inputs, health_outputs = definitions()

    entries = [
        ('N2459', HEALTH_OWNER, 'source_rules_unit_health_state', RULES, 'mindustry.game.Rules', JAVA_METHOD, health_inputs, health_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2096 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Rules.unitHealth() state from Rules.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Rules.unitHealth() state from Rules.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2459'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2459', dict(status='done', java_source=RULES, java_class='mindustry.game.Rules', java_method=JAVA_METHOD, godot_owner=HEALTH_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2459'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
