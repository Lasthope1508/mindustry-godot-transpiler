"""Register battery power-status write + live-loop wiring (N2083).

N2083 writes a battery's power_status to its sprite meta and wires
the live-loop step to persist it: source_factory_update_power_graph_state
reads the stored status into each battery dict before the update and
writes the result back after, so a charged battery can discharge on a
later frame (Java: useBatteries multiplies battery.power.status,
PowerGraph.java:164; chargeBatteries adds to it, :181). _group_state
adds the origin cell to each battery dict so the step can resolve the
sprite. The proof pre-charges the battery to 0.5 and asserts the
deficit step discharges it (power_battery_used 0.1) and the stored
status drops.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
POWER_GRAPH = 'core/src/mindustry/world/blocks/power/PowerGraph.java'
PROOF = '/root/BatteryPowerStatusProof'
TESTS = ['test_battery_power_status_binding_registration', 'test_all_battery_power_status_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_battery_power_status']
DEFERRED = [
    'The full-power case (coverage 1.0 with produced >= needed); C04-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

USED = 'battery.power.status *= (1f-consumedPowerPercentage);'
CHARGED = 'battery.power.status += (1f - battery.power.status) * chargedPercent;'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, **extra):
        return backed(typ, POWER_GRAPH, expr, rule, **extra)

    n2083_inputs = {
        'game': f('Object', USED, 'The game, used to resolve the battery sprite at the cell.'),
        'cell': f('Vector2i', USED, 'The battery origin cell.'),
        'status': f('float', CHARGED, 'The power_status to store.'),
    }
    n2083_outputs = {
        'stored': f('bool', USED, 'Whether the status was stored on a battery sprite.'),
        'reason': f('String', CHARGED, 'Why the write succeeded or failed.'),
    }

    entries = [
        ('N2083', 'SourcePlacedPowerGraphState.source_battery_set_power_status_for_cell_state', 'source_battery_set_power_status_for_cell_state', POWER_GRAPH, 'mindustry.world.blocks.power.PowerGraph', 'useBatteries', n2083_inputs, n2083_outputs, [USED, CHARGED], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed battery power_status write on the sprite meta.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed battery power_status write; the live-loop step uses it to persist the status after each update.'))
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
