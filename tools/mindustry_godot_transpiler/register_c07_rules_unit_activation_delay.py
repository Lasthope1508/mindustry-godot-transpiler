"""Register Rules.unitActivationDelay(Team) (N2466).

Rules.unitActivationDelay(Team) (Rules.java:315-317) is one slice
(batch 47 slot 3):
    public float unitActivationDelay(Team team){
        return unitFactoryActivationDelay + teams.get(team).unitFactoryActivationDelay;
    }
unitFactoryActivationDelay defaults to 0f both globally
(Rules.java:93) and per team (Rules.java:351, TeamRule). The trap
is that this ADDS: unlike the sibling Rules multipliers (N2096
unitCost, N2462 unitDamage, N2464 unitBuildSpeed) which multiply,
2 + 3 is 5.0, not 6.0 -- a port that copies the multiply pattern
is wrong. There is also no clamp: unlike N2459 unitHealth, which
returns Math.max(product, 0.000001f), a negative team delay passes
through (5 + -2 = 3.0). The const
UNIT_FACTORY_ACTIVATION_DELAY_DEFAULT := 0.0 already exists in
SourceRulesDefaults.gd (:34), so no new const is needed. One GD
function on the existing file SourceRulesRuntimeState.gd (home of
N2096 unitCost, N2458 mode, N2459 unitHealth, N2461 buildRadius,
N2462 unitDamage, N2464 unitBuildSpeed and N2465 isBanned),
placed after source_rules_is_banned_state and before
source_team_cheating_state because unitActivationDelay()
(:315-317) comes after isBanned() (:307-309) in Rules.java. One
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
PROOF = '/root/C07RulesUnitActivationDelayProof'
UNIT_ACTIVATION_DELAY_OWNER = 'SourceRulesRuntimeState.source_rules_unit_activation_delay_state'
TESTS = ['test_c07_rules_unit_activation_delay_registration', 'test_all_c07_rules_unit_activation_delay_input_evidence_is_exact', 'test_rules_unit_activation_delay_state', 'test_reference_graph_and_actual_c07_rules_unit_activation_delay']
# The 1 slice source the N2466 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Rules.java',
]
FORMULA = '        return unitFactoryActivationDelay + teams.get(team).unitFactoryActivationDelay;'
EXACT_EXPRS = [
    '    public float unitActivationDelay(Team team){',
    FORMULA,
    '    /** Time until unit factories activate (global). */\n    public float unitFactoryActivationDelay = 0f;',
    '        /** Time until unit factories activate. This is used for enemy teams in attack maps. */\n        public float unitFactoryActivationDelay = 0f;',
]
JAVA_METHOD = 'Rules.unitActivationDelay(Team)'

DEFERRED = [
    'Rules.unitActivationDelay(Team) Windows Godot proof -- debt in GOAL.md section 5: the N2466 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RULES, **extra):
        return backed(typ, source, expr, rule, **extra)

    unit_activation_delay_inputs = {
        'rules_state': a('Dictionary', FORMULA, 'The live rules state (Rules.java:315-317): a Dictionary with unitFactoryActivationDelay (:93, defaults to 0f) and teams (:29, TeamRules) mapping team id to unitFactoryActivationDelay (:351, defaults to 0f). A missing key means the Java field default.'),
        'team_id': a('int', FORMULA, 'The team id (Rules.java:315, `unitActivationDelay(Team team)`) -- the team whose TeamRule delay is added to the global delay.'),
    }
    unit_activation_delay_outputs = {
        'unit_activation_delay': a('float', FORMULA, 'The activation delay in ticks (Rules.java:315-317): unitFactoryActivationDelay + teams.get(team).unitFactoryActivationDelay -- an ADD, not a multiply (2 + 3 is 5.0, not 6.0), with no clamp, so a negative team delay passes through (5 + -2 = 3.0).'),
    }
    return unit_activation_delay_inputs, unit_activation_delay_outputs


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
    unit_activation_delay_inputs, unit_activation_delay_outputs = definitions()

    entries = [
        ('N2466', UNIT_ACTIVATION_DELAY_OWNER, 'source_rules_unit_activation_delay_state', RULES, 'mindustry.game.Rules', JAVA_METHOD, unit_activation_delay_inputs, unit_activation_delay_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Rules.unitActivationDelay() state from Rules.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Rules.unitActivationDelay() state from Rules.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2466'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2466', dict(status='done', java_source=RULES, java_class='mindustry.game.Rules', java_method=JAVA_METHOD, godot_owner=UNIT_ACTIVATION_DELAY_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2466'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
