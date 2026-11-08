"""Register live-loop pump update and conduit line placement (N2088-N2089).

N2088 is the pump's updateTile production part (Pump.java:160-176):
each frame it pumps maxPump = min(liquidCapacity - liquids.get(liquidDrop),
amount * pumpAmount * edelta()) into its liquids, warms up toward 1 when
it pumped, and advances totalProgress. The dumpLiquid step (Pump.java:
180-182) is a later slice; this one only fills the pump's own liquids.

N2089 places the conduit line from the pump to the drill (Blocks.java:
2322-2327, conduit liquidCapacity 20, health 45): 7 conduits from (5,13)
up to (5,8) and east to (6,8), adjacent to the drill's west edge at
(7,8), so the C04 gate has a liquid path from the pump to the drill.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PUMP = 'core/src/mindustry/world/blocks/production/Pump.java'
PROOF = '/root/PumpUpdateProof'
TESTS = ['test_pump_update_binding_registration', 'test_all_pump_update_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_pump_update']
DEFERRED = [
    'The pump dumpLiquid step (Pump.java:180-182) and the conduit liquid movement, then the live-loop liquid flow (the C04 gate: pump -> conduit -> Drill uses water as a booster).',
    'C05-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

MAX_PUMP = 'float maxPump = Math.min(liquidCapacity - liquids.get(liquidDrop), amount * pumpAmount * edelta());'
ADD = 'liquids.add(liquidDrop, maxPump);'
WARMUP = 'warmup = Mathf.approachDelta(warmup, maxPump > 0.001f ? 1f : 0f, warmupSpeed);'
TOTAL = 'totalProgress += warmup * Time.delta;'
CONDUIT_DEF = 'conduit = new Conduit("conduit"){{'
CONDUIT_CAP = 'liquidCapacity = 20f;'
CONDUIT_HEALTH = 'health = 45;'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=PUMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2088_inputs = {
        'game': f('Object', MAX_PUMP, 'The game, for the pump sprite and its liquid module.'),
        'cell': f('Vector2i', MAX_PUMP, 'The pump cell to update.'),
        'delta': f('float', TOTAL, 'The frame delta in seconds.'),
    }
    n2088_outputs = {
        'liquid_drop': f('Variant', ADD, 'The pump liquidDrop id, or null when no linked tile is pumpable.'),
        'amount_pumped': f('float', MAX_PUMP, 'The water pumped into the pump liquids this frame.'),
        'warmup': f('float', WARMUP, 'The pump warmup after this frame (approaches 1 while pumping).'),
        'total_progress': f('float', TOTAL, 'The pump totalProgress after this frame.'),
        'liquid_amount': f('float', ADD, 'The water now in the pump liquids.'),
    }
    n2089_inputs = {
        'tile_size': f('int', CONDUIT_DEF, 'The world tile size in pixels.', source=BLOCKS),
    }
    n2089_outputs = {
        'block_id': f('String', CONDUIT_DEF, 'The conduit block id.', source=BLOCKS),
        'role': f('String', CONDUIT_DEF, 'The initial-build role for the conduit line.', source=BLOCKS),
        'cells': f('Array', CONDUIT_DEF, 'The 7 conduit cells from the pump to the drill.', source=BLOCKS),
        'count': f('int', CONDUIT_DEF, 'The number of conduits placed (7).', source=BLOCKS),
        'liquid_capacity': f('float', CONDUIT_CAP, 'The conduit liquidCapacity (20).', source=BLOCKS),
    }

    entries = [
        ('N2088', 'SourcePumpRuntimeState.source_pump_update_state', 'source_pump_update_state', PUMP, 'mindustry.world.blocks.production.Pump$PumpBuild', 'updateTile()', n2088_inputs, n2088_outputs, [MAX_PUMP, ADD, WARMUP, TOTAL], True, 'Dictionary'),
        ('N2089', 'SourceWorldInitialBuildRuntimeState.source_conduit_line_placement_state', 'source_conduit_line_placement_state', BLOCKS, 'mindustry.content.Blocks', 'conduit', n2089_inputs, n2089_outputs, [CONDUIT_DEF, CONDUIT_CAP, CONDUIT_HEALTH], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed pump update and conduit line.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed pump update and conduit line; the pump fills its liquids and the conduits link it to the drill.'))
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
