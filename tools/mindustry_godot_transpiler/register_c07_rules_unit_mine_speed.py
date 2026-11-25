"""Register Rules.unitMineSpeed(Team) (N2468).

Rules.unitMineSpeed(Team) (Rules.java:292-294) is one slice (batch 48
slot 2):
    public float unitMineSpeed(Team team){
        return unitMineSpeedMultiplier * teams.get(team).unitMineSpeedMultiplier;
    }
It is the sibling of N2096 unitCost, N2462 unitDamage and N2464
unitBuildSpeed (same file, same shape `rules_state`, same per-team
default): the global multiplier defaults to 1f (Rules.java:91) and
the per-team multiplier defaults to 1f (Rules.java:359, TeamRules).
The trap is that there is NO floor here -- unlike N2459 unitHealth,
which returns Math.max(product, 0.000001f), a product of 0 returns
0.0 and a negative product passes through negative; a port that
copies the N2459 floor into this function is wrong. A team missing
from the dict means the Java fresh TeamRule, so its multiplier
defaults to 1f. One GD function on the existing file
SourceRulesRuntimeState.gd (home of N2096 unitCost, N2458 mode,
N2459 unitHealth, N2461 buildRadius, N2462 unitDamage, N2464
unitBuildSpeed, N2465 isBanned, N2466 unitActivationDelay and N2467
hasEnv), placed between source_rules_unit_health_state and
source_rules_is_banned_state because unitMineSpeed() (:292-294)
comes after unitHealth() (:283-286) and before isBanned(Block)
(:307-309) in Rules.java. The const
UNIT_MINE_SPEED_MULTIPLIER_DEFAULT is new in SourceRulesDefaults.gd
(:= 1.0, per Rules.java:91/:359), following the N2464 precedent
(UNIT_BUILD_SPEED_MULTIPLIER_DEFAULT). One slice source: Rules.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RULES = 'core/src/mindustry/game/Rules.java'
PROOF = '/root/C07RulesUnitMineSpeedProof'
MINE_SPEED_OWNER = 'SourceRulesRuntimeState.source_rules_unit_mine_speed_state'
TESTS = ['test_c07_rules_unit_mine_speed_registration', 'test_all_c07_rules_unit_mine_speed_input_evidence_is_exact', 'test_rules_unit_mine_speed_state', 'test_reference_graph_and_actual_c07_rules_unit_mine_speed']
# The 1 slice source the N2468 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Rules.java',
]
FORMULA = '        return unitMineSpeedMultiplier * teams.get(team).unitMineSpeedMultiplier;'
EXACT_EXPRS = [
    '    public float unitMineSpeed(Team team){',
    FORMULA,
    '    /** How fast units can mine. */\n    public float unitMineSpeedMultiplier = 1f;',
    '        /** How fast units can mine. */\n        public float unitMineSpeedMultiplier = 1f;',
]
JAVA_METHOD = 'Rules.unitMineSpeed(Team)'

DEFERRED = [
    'Rules.blockHealth / blockDamage / buildSpeed -- same multiplier family as unitCost/unitDamage/unitBuildSpeed/unitMineSpeed, left for a later batch so batch 48 is not all one pattern.',
    'Rules.unitMineSpeed() Windows Godot proof -- debt in GOAL.md section 5: the N2468 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RULES, **extra):
        return backed(typ, source, expr, rule, **extra)

    mine_speed_inputs = {
        'rules_state': a('Dictionary', FORMULA, 'The live rules state (Rules.java:292-294): a Dictionary with the global unitMineSpeedMultiplier (:91, defaults to 1f) and a "teams" dict of per-team unitMineSpeedMultiplier values (:359, TeamRules, defaults to 1f). A team missing from the dict means the Java fresh TeamRule, so its multiplier defaults to 1f.'),
        'team_id': a('int', FORMULA, 'The team whose unit mine speed multiplier to read (Rules.java:292, `unitMineSpeed(Team team)`).'),
    }
    mine_speed_outputs = {
        'unit_mine_speed': a('float', FORMULA, 'The unit mine speed multiplier (Rules.java:292-294): global * team, with NO floor -- a product of 0 returns 0.0 and a negative product passes through negative, unlike N2459 unitHealth which floors at 0.000001f.'),
    }
    return mine_speed_inputs, mine_speed_outputs


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
    mine_speed_inputs, mine_speed_outputs = definitions()

    entries = [
        ('N2468', MINE_SPEED_OWNER, 'source_rules_unit_mine_speed_state', RULES, 'mindustry.game.Rules', JAVA_METHOD, mine_speed_inputs, mine_speed_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Rules.unitMineSpeed() state from Rules.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Rules.unitMineSpeed() state from Rules.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2468'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2468', dict(status='done', java_source=RULES, java_class='mindustry.game.Rules', java_method=JAVA_METHOD, godot_owner=MINE_SPEED_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2468'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
