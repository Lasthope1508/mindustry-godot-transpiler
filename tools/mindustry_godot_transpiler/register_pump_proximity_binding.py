"""Register pump proximity scan bindings (N2086-N2087).

N2086 maps a floor block id to its liquidDrop (and liquidMultiplier),
so the pump can tell whether a tile is pumpable. The mapping is the
floor definitions in Blocks.java: deep-water/shallow-water/
tainted-water/deep-tainted-water drop water, tar drops oil,
pooled-cryofluid drops cryofluid (multiplier 0.5), molten-slag drops
slag, arkycite-floor drops arkycite; deep-water and deep-tainted-water
have multiplier 1.5, the rest 1.0 (Floor.java default).

N2087 is the pump's onProximityUpdate (Pump.java:141-152): it scans
the pump's linked tiles, and for each tile whose floor has a
liquidDrop (canPump: tile != null && tile.floor().liquidDrop != null)
it sets liquidDrop and adds the floor's liquidMultiplier to amount.
The result is stored on the pump sprite's meta frame (like the drill
frame), so the live-loop update (updateTile) can use it.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PUMP = 'core/src/mindustry/world/blocks/production/Pump.java'
PROOF = '/root/PumpProximityProof'
TESTS = ['test_pump_proximity_binding_registration', 'test_all_pump_proximity_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_pump_proximity']
DEFERRED = [
    'The live-loop pump update (updateTile: pumping into liquids, then dumpLiquid to the conduits) and the conduit line from the pump to the drill (the C04 gate).',
    'C05-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

WATER_FLOOR = 'water = new Floor("shallow-water"){{'
WATER_DROP = 'liquidDrop = Liquids.water;'
OIL_DROP = 'liquidDrop = Liquids.oil;'
CRYO_DROP = 'liquidDrop = Liquids.cryofluid;'
SLAG_DROP = 'liquidDrop = Liquids.slag;'
ARKY_DROP = 'liquidDrop = Liquids.arkycite;'
MULT_15 = 'liquidMultiplier = 1.5f;'
MULT_05 = 'liquidMultiplier = 0.5f;'
SCAN = 'for(Tile other : tile.getLinkedTiles(tempTiles)){'
CAN_PUMP = 'return tile != null && tile.floor().liquidDrop != null;'
SET_DROP = 'liquidDrop = other.floor().liquidDrop;'
ADD_AMOUNT = 'amount += other.floor().liquidMultiplier;'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=BLOCKS, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2086_inputs = {
        'floor_id': f('String', WATER_FLOOR, 'The floor block id to resolve.'),
    }
    n2086_outputs = {
        'liquid_drop': f('Variant', WATER_DROP, 'The floor liquidDrop id, or null when the floor drops nothing.'),
        'liquid_multiplier': f('float', MULT_15, 'The floor liquidMultiplier (1.5 for deep water, 0.5 for pooled cryofluid, 1.0 otherwise).'),
        'is_liquid': f('bool', WATER_FLOOR, 'Whether the floor is a liquid floor (has a liquidDrop).'),
    }
    n2087_inputs = {
        'game': f('Object', SCAN, 'The game, for the world tiles and the pump sprite.', source=PUMP),
        'cell': f('Vector2i', SCAN, 'The pump cell to scan from.', source=PUMP),
    }
    n2087_outputs = {
        'liquid_drop': f('Variant', SET_DROP, 'The pump liquidDrop id, or null when no linked tile is pumpable.', source=PUMP),
        'amount': f('float', ADD_AMOUNT, 'The summed liquidMultiplier of the pumpable linked tiles.', source=PUMP),
        'stored': f('bool', SET_DROP, 'Whether the result was stored on the pump sprite frame.', source=PUMP),
    }

    entries = [
        ('N2086', 'SourceWorldTerrainRuntimeState.source_floor_liquid_drop_state', 'source_floor_liquid_drop_state', BLOCKS, 'mindustry.content.Blocks', 'water', n2086_inputs, n2086_outputs, [WATER_FLOOR, WATER_DROP, OIL_DROP, CRYO_DROP, SLAG_DROP, ARKY_DROP, MULT_15, MULT_05], True, 'Dictionary'),
        ('N2087', 'SourcePumpRuntimeState.source_pump_proximity_state', 'source_pump_proximity_state', PUMP, 'mindustry.world.blocks.production.Pump$PumpBuild', 'onProximityUpdate()', n2087_inputs, n2087_outputs, [SCAN, CAN_PUMP, SET_DROP, ADD_AMOUNT], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed pump proximity scan.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed pump proximity scan; the pump scans its linked tiles for a liquidDrop.'))
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
