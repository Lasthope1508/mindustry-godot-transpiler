"""Register Rules.buildSpeed(Team) (N2472).

Rules.buildSpeed(Team) (Rules.java:303-305) is one slice (batch 49
slot 3):
    public float buildSpeed(Team team){
        return buildSpeedMultiplier * teams.get(team).buildSpeedMultiplier;
    }
It is the sibling of N2096 unitCost, N2462 unitDamage, N2464
unitBuildSpeed, N2468 unitMineSpeed, N2470 blockHealth and N2471
blockDamage (same file, same shape `rules_state`, same per-team
default): the global multiplier defaults to 1f (Rules.java:117)
and the per-team multiplier defaults to 1f (Rules.java:369,
TeamRules). The trap is that there is NO floor here -- unlike
N2459 unitHealth, which returns Math.max(product, 0.000001f), a
product of 0 returns 0.0 and a negative product passes through
negative; a port that copies the N2459 floor into this function
is wrong. A team missing from the dict means the Java fresh
TeamRule, so its multiplier defaults to 1f. One GD function on
the existing file SourceRulesRuntimeState.gd (home of N2096
unitCost, N2458 mode, N2459 unitHealth, N2461 buildRadius, N2462
unitDamage, N2464 unitBuildSpeed, N2465 isBanned, N2466
unitActivationDelay, N2467 hasEnv, N2468 unitMineSpeed, N2470
blockHealth and N2471 blockDamage), placed between
source_rules_block_damage_state and source_rules_is_banned_state
because buildSpeed() (:303-305) comes after blockDamage()
(:299-301) and before isBanned(Block) (:307-309) in Rules.java.
The const BUILD_SPEED_MULTIPLIER_DEFAULT is new in
SourceRulesDefaults.gd (:= 1.0, per Rules.java:117/:369),
following the N2470/N2471 precedent
(BLOCK_HEALTH_MULTIPLIER_DEFAULT /
BLOCK_DAMAGE_MULTIPLIER_DEFAULT). It must NOT be confused with
UNIT_BUILD_SPEED_MULTIPLIER_DEFAULT, which belongs to N2464
unitBuildSpeed (a different method). One slice source:
Rules.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RULES = 'core/src/mindustry/game/Rules.java'
PROOF = '/root/C07RulesBuildSpeedProof'
BUILD_SPEED_OWNER = 'SourceRulesRuntimeState.source_rules_build_speed_state'
TESTS = ['test_c07_rules_build_speed_registration', 'test_all_c07_rules_build_speed_input_evidence_is_exact', 'test_rules_build_speed_state', 'test_reference_graph_and_actual_c07_rules_build_speed']
# The 1 slice source the N2472 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Rules.java',
]
FORMULA = '        return buildSpeedMultiplier * teams.get(team).buildSpeedMultiplier;'
EXACT_EXPRS = [
    '    public float buildSpeed(Team team){',
    FORMULA,
    '    /** Multiplier for building speed. */\n    public float buildSpeedMultiplier = 1f;',
    '        /** Multiplier for building speed. */\n        public float buildSpeedMultiplier = 1f;',
]
JAVA_METHOD = 'Rules.buildSpeed(Team)'

DEFERRED = [
    'Rules.buildSpeed() Windows Godot proof -- debt in GOAL.md section 5: the N2472 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RULES, **extra):
        return backed(typ, source, expr, rule, **extra)

    build_speed_inputs = {
        'rules_state': a('Dictionary', FORMULA, 'The live rules state (Rules.java:303-305): a Dictionary with the global buildSpeedMultiplier (:117, defaults to 1f) and a "teams" dict of per-team buildSpeedMultiplier values (:369, TeamRules, defaults to 1f). A team missing from the dict means the Java fresh TeamRule, so its multiplier defaults to 1f.'),
        'team_id': a('int', FORMULA, 'The team whose build speed multiplier to read (Rules.java:303, `buildSpeed(Team team)`).'),
    }
    build_speed_outputs = {
        'build_speed': a('float', FORMULA, 'The build speed multiplier (Rules.java:303-305): global * team, with NO floor -- a product of 0 returns 0.0 and a negative product passes through negative, unlike N2459 unitHealth which floors at 0.000001f.'),
    }
    return build_speed_inputs, build_speed_outputs


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
    build_speed_inputs, build_speed_outputs = definitions()

    entries = [
        ('N2472', BUILD_SPEED_OWNER, 'source_rules_build_speed_state', RULES, 'mindustry.game.Rules', JAVA_METHOD, build_speed_inputs, build_speed_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Rules.buildSpeed() state from Rules.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Rules.buildSpeed() state from Rules.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2472'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2472', dict(status='done', java_source=RULES, java_class='mindustry.game.Rules', java_method=JAVA_METHOD, godot_owner=BUILD_SPEED_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2472'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
