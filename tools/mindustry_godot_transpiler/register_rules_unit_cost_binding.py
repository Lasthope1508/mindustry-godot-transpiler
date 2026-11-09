"""Register the rules unit cost state (N2096).

N2096 is Rules.unitCost(Team team): the multiplier unit factories
pay on every consumer (Rules.java:275-276):
    return unitCostMultiplier * teams.get(team).unitCostMultiplier;
The global multiplier defaults to 1f (Rules.java:83) and the
per-team multiplier defaults to 1f (Rules.java:361, TeamRules).
UnitFactory, Reconstructor and UnitAssembler all set each
consumer's multiplier to b -> state.rules.unitCost(b.team)
(UnitFactory.java:109, Reconstructor.java:149,
UnitAssembler.java:175); this slice is the live rules value those
callbacks read, replacing the default-only 1.0 binding in
SourceConsumeState.source_cost_multiplier_state.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
RULES = 'core/src/mindustry/game/Rules.java'
PROOF = '/root/RulesUnitCostProof'
TESTS = ['test_rules_unit_cost_binding_registration', 'test_all_rules_unit_cost_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_rules_unit_cost']
DEFERRED = [
    'Wiring source_cost_multiplier_state to return unitCost for unit-producing blocks (UnitFactory/Reconstructor/UnitAssembler) is a later slice; this slice is the rules value it reads.',
    'Live TeamRules cheating (consumers do not consume while cheating) is a later C05 slice.',
    'C05 cache invalidation on Block reinit/reload is a later slice.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

GLOBAL = '    /** Multiplier of resources that units take to build. */\n    public float unitCostMultiplier = 1f;'
FORMULA = 'return unitCostMultiplier * teams.get(team).unitCostMultiplier;'
TEAM = '        /** Multiplier of resources that units take to build. */\n        public float unitCostMultiplier = 1f;'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=RULES, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2096_inputs = {
        'rules_state': f('Dictionary', FORMULA, 'The live rules state: global unitCostMultiplier and per-team multipliers.'),
        'team_id': f('int', FORMULA, 'The team whose unit cost multiplier to read.'),
    }
    n2096_outputs = {
        'unit_cost': f('float', FORMULA, 'The unit cost multiplier: global times the team multiplier (1.0 by default).'),
    }

    entries = [
        ('N2096', 'SourceRulesRuntimeState.source_unit_cost_state', 'source_unit_cost_state', RULES, 'mindustry.game.Rules', 'unitCost(Team team)', n2096_inputs, n2096_outputs, [GLOBAL, FORMULA, TEAM], True, 'Dictionary'),
    ]
    for sid, owner, prefix, source, cls, method, inputs, outputs, exprs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2029 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed rules unit cost.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed rules unit cost; unit factories pay this multiplier on every consumer.'))
        by_slice[sid] = names
        source_symbols.upsert_source_slice(GODOT, sid, dict(status='done', java_source=source, java_class=cls, java_method=method, godot_owner=owner, exact_exprs=exprs, source_symbols=names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
    main()
