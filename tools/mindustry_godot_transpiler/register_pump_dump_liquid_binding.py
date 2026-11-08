"""Register the pump dumpLiquid step (N2090).

N2090 is the pump's updateTile dump step (Pump.java:180-182): if
liquidDrop != null, dumpLiquid(liquidDrop). BuildingComp.dumpLiquid
(liquid) calls dumpLiquid(liquid, 2f) — scaling 2, any output
direction — which routes the pump's water to its liquid neighbors
through the bound dump_liquid_state (routing gate + fraction
transfer), and the pump's liquids and each neighbor's liquids are
written back. This drains the pump into the conduit at (5,13) so
the C04 gate has water flowing out of the pump.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PUMP = 'core/src/mindustry/world/blocks/production/Pump.java'
BUILDING = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/PumpDumpLiquidProof'
TESTS = ['test_pump_dump_liquid_binding_registration', 'test_all_pump_dump_liquid_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_pump_dump_liquid']
DEFERRED = [
    'The conduit liquid movement (moveLiquidForward) and the drill water booster, then the live-loop liquid flow (the C04 gate: pump -> conduit -> Drill uses water as a booster).',
    'C05-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

DUMP_GUARD = 'if(liquidDrop != null){'
DUMP_CALL = 'dumpLiquid(liquidDrop);'
DUMP_SCALING = 'dumpLiquid(liquid, 2f);'
DUMP_EMPTY = 'if(liquids.get(liquid) <= 0.0001f) return;'
OFRACT = 'float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;'
TRANSFER = 'if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=PUMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2090_inputs = {
        'game': f('Object', DUMP_CALL, 'The game, for the pump sprite, its liquid module and its liquid neighbors.'),
        'cell': f('Vector2i', DUMP_CALL, 'The pump cell to dump from.'),
    }
    n2090_outputs = {
        'liquid_drop': f('Variant', DUMP_GUARD, 'The pump liquidDrop id, or null when no linked tile is pumpable.'),
        'amount_dumped': f('float', TRANSFER, 'The water dumped from the pump liquids to its liquid neighbors.', source=BUILDING),
        'liquid_amount': f('float', DUMP_EMPTY, 'The water left in the pump liquids after the dump.', source=BUILDING),
        'dump_cursor': f('int', DUMP_SCALING, 'The pump dump cursor (cdump) after the dump.', source=BUILDING),
    }

    entries = [
        ('N2090', 'SourcePumpRuntimeState.source_pump_dump_liquid_state', 'source_pump_dump_liquid_state', PUMP, 'mindustry.world.blocks.production.Pump$PumpBuild', 'updateTile()', n2090_inputs, n2090_outputs, [DUMP_GUARD, DUMP_CALL, DUMP_SCALING, DUMP_EMPTY, OFRACT, TRANSFER], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed pump dumpLiquid step.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed pump dumpLiquid step; the pump drains its water into its liquid neighbors.'))
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
