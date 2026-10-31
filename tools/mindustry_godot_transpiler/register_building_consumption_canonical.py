"""Register the complete BuildingComp consumption state and its runtime application boundary.

Stage contracts keep their existing owners. This file adds only composition/application
contracts and makes the existing consumer-row representation explicit.
"""
from pathlib import Path

from mindustry_port import source_ssot, source_symbols

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SOURCE = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/Main.BuildingConsumptionCanonicalProof'
TESTS = ['test_complete_path_has_one_domain_owner_and_no_inline_behavior', 'test_second_pass_expected_never_uses_actual_efficiency', 'test_consumption_complete_contract_and_row_schema_are_registered']
OWNER = 'PortGame.source_building_update_consumption_state'
APPLY = 'PortGame.source_building_apply_update_consumption_state'


def key(type_name, expr, rule, **extra):
    return dict(type=type_name, status='source-backed', java_source=SOURCE, java_method='updateConsumption()', java_expr=expr, rule=rule, **extra)


def main():
    schemas = source_symbols.load_source_state_schema(GODOT)['schemas']
    params = []
    # Compose input references from the original stage contracts, without new aliases/owners.
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    for stage in ('initial', 'non_optional_pass', 'optional_pass', 'second_pass'):
        for param in contracts[f'PortGame.source_building_update_consumption_{stage}_state']['params']:
            if param['name'] not in {p['name'] for p in params} and param['name'] not in ('update', 'efficiency'):
                params.append(dict(param))
    result_keys = {}
    for field, origin in {
        'efficiency': 'efficiency', 'optional_efficiency': 'efficiency', 'potential_efficiency': 'efficiency',
        'min_efficiency': 'efficiency', 'update': 'efficiency', 'should_consume_power': 'non_optional_pass',
        'updated_consumers': 'second_pass', 'update_count': 'second_pass', 'returned': 'initial',
    }.items():
        schema = f'source_building_update_consumption_{origin}_result'
        result_keys[field] = dict(type=schemas[schema]['keys'][field]['type'], status='alias', alias_of=f'{schema}.{field}', rule='Complete method composes existing canonical stage state; branch-specific fields remain optional.')
    source_symbols.upsert_source_state_schema(GODOT, 'source_building_update_consumption_result', dict(status='active', owner=OWNER, runtime_proof=PROOF, keys=result_keys))
    source_symbols.upsert_source_state_schema(GODOT, 'source_building_apply_update_consumption_input', dict(status='active', owner=APPLY, runtime_proof=PROOF, keys={
        'consumption_state': key('Dictionary', 'public void updateConsumption(){', 'Calculated complete state from source_building_update_consumption_result; state assignment precedes consumer updates.', schema='source_building_update_consumption_result'),
        'self_state': dict(type='Dictionary', status='alias', alias_of='source_building_update_consumption_second_pass_input.self_state', rule='Mutable Godot dictionary adapter for self(); consumers must implement update(self_state).'),
    }))
    source_symbols.upsert_source_state_schema(GODOT, 'source_building_apply_update_consumption_result', dict(status='active', owner=APPLY, runtime_proof=PROOF, keys={field: dict(type=meta['type'], status='alias', alias_of=f'source_building_update_consumption_result.{field}') for field, meta in result_keys.items()}))
    source_symbols.upsert_source_state_schema(GODOT, 'source_building_consumer_efficiency_row', dict(status='active', owner=OWNER, runtime_proof=PROOF, keys={
        'result': key('float', 'float result = cons.efficiency(self());', 'Canonical evaluated consumer efficiency result.'),
        'efficiency': dict(type='float', status='alias', alias_of='source_building_consumer_efficiency_row.result', rule='Existing helper compatibility field for cons.efficiency(self()); both paths use the same canonical reader.'),
        'is_power': key('bool', 'cons != block.consPower', 'Adapter identifies whether the consumer is block.consPower; omitted means non-power as in existing stage API.'),
    }))
    for stage, field in [('non_optional_pass','non_optional_consumer_results'), ('optional_pass','optional_consumer_results')]:
        name = f'source_building_update_consumption_{stage}_input'
        entry = schemas[name]
        entry['keys'][field]['element_schema'] = 'source_building_consumer_efficiency_row'
        entry['keys'][field]['rule'] = 'Explicit runtime iteration results. Canonical rows are dictionaries with result (compatibility alias efficiency); missing values retain the existing stage neutral 1.0 default.'
        if stage == 'optional_pass':
            entry['keys'][field]['rule'] += ' Legacy numeric elements are accepted only by the canonical optional reader; production bridges use dictionary rows.'
        source_symbols.upsert_source_state_schema(GODOT, name, entry)
    # Explicit frame schema for update()'s optional complete-runtime adapter input.
    frame = {}
    for param in params:
        frame[param['name']] = dict(type=param['type'], status='alias', alias_of=param['schema'], rule='Required when a complete consumption frame is supplied to generated update(); source expressions are evaluated by the caller.')
    frame.pop('self_state')
    source_symbols.upsert_source_state_schema(GODOT, 'source_building_update_consumption_frame', dict(status='active', owner=APPLY, runtime_proof=PROOF, keys=frame))
    entries = {}
    expressions = ['public void updateConsumption(){', 'updateEfficiencyMultiplier();', 'cons.update(self());']
    for slice_id, owner, fields, api_params, return_keys in [
        ('N1989', OWNER, result_keys, params, list(result_keys)),
        ('N1990', APPLY, {'consumption_state': None, 'self_state': None}, [dict(name='consumption_state', type='Dictionary', schema='source_building_apply_update_consumption_input.consumption_state'), dict(name='self_state', type='Dictionary', schema='source_building_apply_update_consumption_input.self_state')], list(result_keys)),
    ]:
        names = []
        for field in fields:
            name = f'building_consumption_complete.{field}' if owner == OWNER else f'building_consumption_apply.{field}'
            symbol = f'source_building_update_consumption_result.{field}' if owner == OWNER else f'source_building_apply_update_consumption_input.{field}'
            entries[name] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=SOURCE, java_method='updateConsumption()', java_expr=expressions[0], rule='Composed state/application adapter uses existing stage ownership and exact source ordering.', tests=TESTS, runtime_proof=PROOF)
            names.append(name)
        source_symbols.upsert_source_slice(GODOT, slice_id, dict(status='done', java_source=SOURCE, java_class='mindustry.entities.comp.BuildingComp', java_method='updateConsumption()', godot_owner=owner, exact_exprs=expressions, source_symbols=names, tests=TESTS, runtime_proof=PROOF, rule='Complete canonical consumption composition.' if owner == OWNER else 'Assign canonical fields before dispatching supplied concrete consumers; generated update() accepts the registered complete frame at argument 11. Legacy no-frame update() remains a source-call inspection marker.', deferred_exprs=['Concrete resource availability evaluation remains supplied by the caller; this boundary executes already selected consumer.update(self()).']))
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=slice_id, java_source=SOURCE, source_method='updateConsumption()', params=api_params, return_keys=return_keys, tests=TESTS, runtime_proof=PROOF, rule='Pure complete-method state; no consumer side effects.' if owner == OWNER else 'Mutable dictionary self() adapter; applies four fields then dispatches each planned concrete consumer exactly once. Invalid consumer interfaces fail instead of being silently skipped.'))
    source_symbols.upsert_source_symbols(GODOT, entries)
    for name in ('comp_slices', 'comp_api_contracts'):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == '__main__':
    main()
