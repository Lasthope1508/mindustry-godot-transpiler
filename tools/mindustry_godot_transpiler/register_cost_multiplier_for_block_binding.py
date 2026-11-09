"""Register the per-block cost multiplier callback (N2097).

N2097 wires the actual source multiplier callbacks, replacing the
default-only binding in SourceConsumeState.source_cost_multiplier_state
(N2007, always 1.0) with the correct lifecycle: Consume.multiplier is
a per-consumer callback (Consume.java:18, default b -> 1f), and unit
factories override it with b -> state.rules.unitCost(b.team)
(UnitFactory.java:109, Reconstructor.java:149,
UnitAssembler.java:175 — the same line in all three files).

SourceConsumeState.source_cost_multiplier_for_block_state(build)
reads the block implementation, team and rules state from the build
dict (the building frame, set by the tick before the consumers are
created) and returns Rules.unitCost for UnitFactory/Reconstructor/
UnitAssembler blocks, 1.0 otherwise. The drill's tick now passes
this function as the consumer Callable (the drill is not a unit
factory, so it keeps the 1.0 default through the new path).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
UNIT_FACTORY = 'core/src/mindustry/world/blocks/units/UnitFactory.java'
RULES = 'core/src/mindustry/game/Rules.java'
PROOF = '/root/CostMultiplierForBlockProof'
TESTS = ['test_cost_multiplier_for_block_binding_registration', 'test_all_cost_multiplier_for_block_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_cost_multiplier_for_block']
DEFERRED = [
    'The game rules state itself (a live, mutable rules dict on the game, read by the tick) is a later slice; the tick currently passes an empty rules state, so unitCost reads the 1.0 defaults until then.',
    'Live TeamRules cheating (consumers do not consume while cheating) is a later C05 slice.',
    'C05 cache invalidation on Block reinit/reload is a later slice.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

DEFAULT = 'public Floatf<Building> multiplier = b -> 1f;'
CALLBACK = 'consumeBuilder.each(c -> c.multiplier = b -> state.rules.unitCost(b.team));'
FORMULA = 'return unitCostMultiplier * teams.get(team).unitCostMultiplier;'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=CONSUME, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2097_inputs = {
        'build': f('Variant', CALLBACK, 'The building frame: block_implementation, team_id and rules_state.', source=UNIT_FACTORY),
    }
    n2097_outputs = {
        'multiplier': f('float', DEFAULT, 'The cost multiplier the block pays: Rules.unitCost for unit factories, 1.0 otherwise.'),
    }

    entries = [
        ('N2097', 'SourceConsumeState.source_cost_multiplier_for_block_state', 'source_cost_multiplier_for_block_state', UNIT_FACTORY, 'mindustry.world.blocks.units.UnitFactory', 'init()', n2097_inputs, n2097_outputs, [DEFAULT, CALLBACK, FORMULA], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed per-block cost multiplier.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed per-block cost multiplier; unit factories pay Rules.unitCost, other blocks pay the 1.0 default.'))
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
