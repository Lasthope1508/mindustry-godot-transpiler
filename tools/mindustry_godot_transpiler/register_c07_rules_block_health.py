"""Register Rules.blockHealth(Team) (N2470).

Rules.blockHealth(Team) (Rules.java:296-298) is one slice (batch 49
slot 1):
    public float blockHealth(Team team){
        return blockHealthMultiplier * teams.get(team).blockHealthMultiplier;
    }
It is the sibling of N2096 unitCost, N2462 unitDamage, N2464
unitBuildSpeed and N2468 unitMineSpeed (same file, same shape
`rules_state`, same per-team default): the global multiplier
defaults to 1f (Rules.java:111) and the per-team multiplier
defaults to 1f (Rules.java:365, TeamRules). The trap is that
there is NO floor here -- unlike N2459 unitHealth, which returns
Math.max(product, 0.000001f), a product of 0 returns 0.0 and a
negative product passes through negative; a port that copies the
N2459 floor into this function is wrong. A team missing from the
dict means the Java fresh TeamRule, so its multiplier defaults
to 1f. One GD function on the existing file
SourceRulesRuntimeState.gd (home of N2096 unitCost, N2458 mode,
N2459 unitHealth, N2461 buildRadius, N2462 unitDamage, N2464
unitBuildSpeed, N2465 isBanned, N2466 unitActivationDelay, N2467
hasEnv and N2468 unitMineSpeed), placed between
source_rules_unit_mine_speed_state and source_rules_is_banned_state
because blockHealth() (:296-298) comes after unitMineSpeed()
(:292-294) and before isBanned(Block) (:307-309) in Rules.java.
The const BLOCK_HEALTH_MULTIPLIER_DEFAULT is new in
SourceRulesDefaults.gd (:= 1.0, per Rules.java:111/:365),
following the N2468 precedent (UNIT_MINE_SPEED_MULTIPLIER_DEFAULT).
One slice source: Rules.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RULES = 'core/src/mindustry/game/Rules.java'
PROOF = '/root/C07RulesBlockHealthProof'
BLOCK_HEALTH_OWNER = 'SourceRulesRuntimeState.source_rules_block_health_state'
TESTS = ['test_c07_rules_block_health_registration', 'test_all_c07_rules_block_health_input_evidence_is_exact', 'test_rules_block_health_state', 'test_reference_graph_and_actual_c07_rules_block_health']
# The 1 slice source the N2470 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Rules.java',
]
FORMULA = '        return blockHealthMultiplier * teams.get(team).blockHealthMultiplier;'
EXACT_EXPRS = [
    '    public float blockHealth(Team team){',
    FORMULA,
    '    /** How much health blocks start with. */\n    public float blockHealthMultiplier = 1f;',
    '        /** How much health blocks start with. */\n        public float blockHealthMultiplier = 1f;',
]
JAVA_METHOD = 'Rules.blockHealth(Team)'

DEFERRED = [
    'Rules.blockDamage / buildSpeed -- same multiplier family as unitCost/unitDamage/unitBuildSpeed/unitMineSpeed/blockHealth, left for a later batch so batch 49 is not all one pattern.',
    'Rules.blockHealth() Windows Godot proof -- debt in GOAL.md section 5: the N2470 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RULES, **extra):
        return backed(typ, source, expr, rule, **extra)

    block_health_inputs = {
        'rules_state': a('Dictionary', FORMULA, 'The live rules state (Rules.java:296-298): a Dictionary with the global blockHealthMultiplier (:111, defaults to 1f) and a "teams" dict of per-team blockHealthMultiplier values (:365, TeamRules, defaults to 1f). A team missing from the dict means the Java fresh TeamRule, so its multiplier defaults to 1f.'),
        'team_id': a('int', FORMULA, 'The team whose block health multiplier to read (Rules.java:296, `blockHealth(Team team)`).'),
    }
    block_health_outputs = {
        'block_health': a('float', FORMULA, 'The block health multiplier (Rules.java:296-298): global * team, with NO floor -- a product of 0 returns 0.0 and a negative product passes through negative, unlike N2459 unitHealth which floors at 0.000001f.'),
    }
    return block_health_inputs, block_health_outputs


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
    block_health_inputs, block_health_outputs = definitions()

    entries = [
        ('N2470', BLOCK_HEALTH_OWNER, 'source_rules_block_health_state', RULES, 'mindustry.game.Rules', JAVA_METHOD, block_health_inputs, block_health_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Rules.blockHealth() state from Rules.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Rules.blockHealth() state from Rules.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2470'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2470', dict(status='done', java_source=RULES, java_class='mindustry.game.Rules', java_method=JAVA_METHOD, godot_owner=BLOCK_HEALTH_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2470'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
