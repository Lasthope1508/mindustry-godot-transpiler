"""Register Rules.buildRadius(Team) (N2461).

Rules.buildRadius(Team) (Rules.java:267-269) is one slice (batch 46
slot 1):
    public float buildRadius(Team team){
        return !teams.get(team).protectCores ? 0f : enemyCoreBuildRadius + teams.get(team).extraCoreBuildRadius;
    }
It is the provider for the already-ported consumer
Teams.anyEnemyCoresWithinBuildRadius (which takes a
build_radius_by_team input) -- this slice defines the radius
itself. The global enemyCoreBuildRadius defaults to 400f
(Rules.java:123) and the per-team protectCores defaults to true
(Rules.java:324, TeamRules) with extraCoreBuildRadius defaulting
to 0f (Rules.java:371). The traps: protectCores=false blocks
everything -- the ternary returns 0f without adding anything,
however large extraCoreBuildRadius is; and there is no clamp --
unlike N2459 unitHealth there is no Math.max here, so a negative
extra passes through (400 + -50 = 350). A team missing from the
dict means the Java fresh TeamRule, so it defaults to
protect=true, extra=0 and the answer is enemyCoreBuildRadius.
One GD function on the existing file
SourceRulesRuntimeState.gd (home of N2096 unitCost, N2458 mode
and N2459 unitHealth), placed after source_rules_mode_state
and before source_unit_cost_state because buildRadius()
(:267-269) sits between mode() (:249-261) and unitCost()
(:275-276) in Rules.java. One slice source: Rules.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RULES = 'core/src/mindustry/game/Rules.java'
PROOF = '/root/C07RulesBuildRadiusProof'
RADIUS_OWNER = 'SourceRulesRuntimeState.source_rules_build_radius_state'
TESTS = ['test_c07_rules_build_radius_registration', 'test_all_c07_rules_build_radius_input_evidence_is_exact', 'test_rules_build_radius_state', 'test_reference_graph_and_actual_c07_rules_build_radius']
# The 1 slice source the N2461 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Rules.java',
]
FORMULA = '        return !teams.get(team).protectCores ? 0f : enemyCoreBuildRadius + teams.get(team).extraCoreBuildRadius;'
EXACT_EXPRS = [
    '    public float buildRadius(Team team){',
    FORMULA,
    '    /** No-build zone around enemy core radius. */\n    public float enemyCoreBuildRadius = 400f;',
    '        /** Whether the core no-build radius/polygonal protection applies to this team, unprotected teams are ignored by team assigner */\n        public boolean protectCores = true;',
    '        /** Extra spacing added to the no-build zone around the core. */\n        public float extraCoreBuildRadius = 0f;',
]
JAVA_METHOD = 'Rules.buildRadius(Team)'

DEFERRED = [
    'Rules.unitDamage / unitBuildSpeed / unitMineSpeed / blockHealth / blockDamage / buildSpeed -- same multiplier family as unitCost/unitHealth, left for later batches so batch 46 is not all one pattern.',
    'Rules.buildRadius() Windows Godot proof -- debt in GOAL.md section 5: the N2461 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RULES, **extra):
        return backed(typ, source, expr, rule, **extra)

    radius_inputs = {
        'rules_state': a('Dictionary', FORMULA, 'The live rules state (Rules.java:267-269): a Dictionary with the global enemyCoreBuildRadius (:123, defaults to 400f) and a "teams" dict of per-team protectCores (:324, TeamRules, defaults to true) and extraCoreBuildRadius (:371, defaults to 0f) values. A team missing from the dict means the Java fresh TeamRule, so protect defaults to true and extra to 0f.'),
        'team_id': a('int', FORMULA, 'The team whose build radius to read (Rules.java:267, `buildRadius(Team team)`).'),
    }
    radius_outputs = {
        'build_radius': a('float', FORMULA, 'The no-build radius around the enemy core (Rules.java:267-269): 0f when protectCores is false, else enemyCoreBuildRadius + extraCoreBuildRadius. No clamp -- a negative extra passes through (400 + -50 = 350), unlike the Math.max floor in N2459 unitHealth.'),
    }
    return radius_inputs, radius_outputs


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
    radius_inputs, radius_outputs = definitions()

    entries = [
        ('N2461', RADIUS_OWNER, 'source_rules_build_radius_state', RULES, 'mindustry.game.Rules', JAVA_METHOD, radius_inputs, radius_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Rules.buildRadius() state from Rules.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Rules.buildRadius() state from Rules.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2461'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2461', dict(status='done', java_source=RULES, java_class='mindustry.game.Rules', java_method=JAVA_METHOD, godot_owner=RADIUS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2461'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
