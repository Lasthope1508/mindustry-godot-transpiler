"""Register drill bridge dominant-item binding (N2071).

N2071 makes the drill runtime bridge resolve the actual dominant item
from the drill frame (the ore scan, Drill.onProximityUpdate) instead of
reading the game-global drill_output_item_id. The global defaults to
copper and is only correct while the drill sits on copper ore; the
bridge now follows the same dominant-item resolution the live factory
loop already uses.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
PROOF = '/root/DrillBridgeDominantProof'
TESTS = ['test_drill_bridge_dominant_binding_registration', 'test_all_drill_bridge_dominant_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_drill_bridge_dominant']
DEFERRED = [
    'The one-inventory-owner cleanup stays open in C02 (the secondary drill frame accumulates its own items and the live loop only dumps the primary).',
    'C02 two-Drill gate and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

COUNT_ORE = 'countOre(tile);'
DOMINANT_ITEM = 'dominantItem = returnItem;'
DOMINANT_ITEMS = 'dominantItems = returnCount;'
NULL_GATE = 'if(dominantItem == null){'
TIME_DRILLED = 'timeDrilled += warmup * delta();'
DELAY = 'float delay = getDrillTime(dominantItem);'
PRODUCE_GATE = 'if(items.total() < itemCapacity && dominantItems > 0 && efficiency > 0){'
UPDATE_TILE = 'public void updateTile(){'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, **extra):
        return backed(typ, DRILL, expr, rule, **extra)

    n2071_inputs = {
        'seconds': f('float', TIME_DRILLED, 'Frame delta in seconds driving the drill tick.'),
    }
    n2071_outputs = {
        'drill_active': f('bool', NULL_GATE, 'Whether the drill is active (it has a dominant item).'),
        'drill_warmup_before': f('float', TIME_DRILLED, 'Warmup before this tick.'),
        'drill_warmup': f('float', TIME_DRILLED, 'Warmup after this tick.'),
        'drill_last_speed_before': f('float', DELAY, 'Last drill speed before this tick.'),
        'drill_last_speed': f('float', DELAY, 'Last drill speed after this tick.'),
        'drill_time_drilled_before': f('float', TIME_DRILLED, 'Time drilled before this tick.'),
        'drill_time_drilled_delta': f('float', TIME_DRILLED, 'Time drilled added this tick.'),
        'drill_time_drilled': f('float', TIME_DRILLED, 'Time drilled after this tick.'),
        'drill_delay': f('float', DELAY, 'Drill delay for the dominant item (getDrillTime).'),
        'drill_output_delta': f('float', PRODUCE_GATE, 'Output produced this tick.'),
        'production_state': f('Dictionary', PRODUCE_GATE, 'Production state for this tick.'),
        'offload_amount': f('int', PRODUCE_GATE, 'Items offloaded this tick.'),
        'produced_delta': f('int', PRODUCE_GATE, 'Items produced this tick.'),
        'item_progress': f('float', PRODUCE_GATE, 'Item progress after this tick.'),
        'source_owner': f('String', UPDATE_TILE, 'Source owner of the drill runtime state.'),
    }

    entries = [
        ('N2071', 'PortGame.source_drill_runtime_state', 'source_drill_runtime_state', DRILL, 'mindustry.world.blocks.production.Drill$DrillBuild', 'updateTile', n2071_inputs, n2071_outputs, [COUNT_ORE, DOMINANT_ITEM, DOMINANT_ITEMS, NULL_GATE, TIME_DRILLED, DELAY, PRODUCE_GATE], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed drill bridge dominant item.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed drill bridge; the runtime state resolves the actual dominant item from the drill frame instead of the game-global item id.'))
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
