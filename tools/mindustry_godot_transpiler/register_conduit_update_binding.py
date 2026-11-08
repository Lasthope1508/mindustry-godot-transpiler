"""Register conduit rotation placement and conduit updateTile (N2091-N2092).

N2091 is the conduit rotation placement: conduits are rotatable
(Conduit.java:48, rotate = true), and the bootstrap line needs its
conduits pointing toward the drill — the 5 north-running conduits
(5,13)-(5,9) point north (rotation 1) and the 2 east-running
conduits (5,8), (6,8) point east (rotation 0) — so
tile.nearby(rotation) in moveLiquidForward reaches the next conduit
or the drill. The rotations are applied to the conduit sprites'
"rotation" meta when the world is built.

N2092 is the conduit's updateTile (Conduit.java:249-255): smoothLiquid
lerps toward currentAmount / liquidCapacity (0.05), and when the
conduit holds more than 0.0001 liquid and its flow timer (timerFlow,
1s) fires, it calls moveLiquidForward(leaks, liquids.current()),
which moves the liquid to the block in its rotation direction via
the bound moveLiquid (pressure fractions, BuildingComp.java:939+)
or leaks a puddle (leakAmount = liquids.get(liquid) / 1.5f) when
there is no building ahead. The flow timer lives on the conduit
sprite's meta frame, like the pump's warmup.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
CONDUIT = 'core/src/mindustry/world/blocks/liquid/Conduit.java'
BUILDING = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/ConduitUpdateProof'
TESTS = ['test_conduit_update_binding_registration', 'test_all_conduit_update_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_conduit_update']
DEFERRED = [
    'The drill water booster (the mechanical drill consumes water 0.05f as a booster, 1.6x speed), then the live-loop liquid flow (the C04 gate: pump -> conduit -> Drill uses water as a booster).',
    'C05-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

CONDUIT_DEF = 'conduit = new Conduit("conduit"){{'
CONDUIT_CAP = 'liquidCapacity = 20f;'
ROTATE = 'rotate = true;'
SMOOTH = 'smoothLiquid = Mathf.lerpDelta(smoothLiquid, liquids.currentAmount() / liquidCapacity, 0.05f);'
FLOW_GUARD = 'if(liquids.currentAmount() > 0.0001f && timer(timerFlow, 1)){'
MOVE_FORWARD = 'moveLiquidForward(leaks, liquids.current());'
LEAK = 'float leakAmount = liquids.get(liquid) / 1.5f;'
FLOW = 'float flow = Math.min(Mathf.clamp((fract - ofract)) * (block.liquidCapacity), liquids.get(liquid));'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=BLOCKS, **extra):
        return backed(typ, source, expr, rule, **extra)

    def g(typ, expr, rule, source=CONDUIT, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2091_inputs = {
        'tile_size': f('int', CONDUIT_DEF, 'The world tile size in pixels.'),
    }
    n2091_outputs = {
        'block_id': f('String', CONDUIT_DEF, 'The conduit block id.'),
        'rotations': f('Dictionary', ROTATE, 'The rotation per conduit cell (1 north, 0 east), keyed by cell.', source=CONDUIT),
        'count': f('int', CONDUIT_DEF, 'The number of conduits (7).'),
    }
    n2092_inputs = {
        'game': g('Object', MOVE_FORWARD, 'The game, for the conduit sprite, its liquid module and its forward neighbor.'),
        'cell': g('Vector2i', MOVE_FORWARD, 'The conduit cell to update.'),
        'delta': g('float', SMOOTH, 'The frame delta in seconds.'),
    }
    n2092_outputs = {
        'liquid': g('Variant', MOVE_FORWARD, 'The conduit current liquid id, or null when it holds none.'),
        'flowed': g('float', FLOW, 'The water moved forward this frame (0 when the flow timer has not fired).', source=BUILDING),
        'smooth_liquid': g('float', SMOOTH, 'The conduit smoothLiquid after this frame.'),
        'flow_timer': g('float', FLOW_GUARD, 'The conduit flow timer after this frame.'),
    }

    entries = [
        ('N2091', 'SourceWorldInitialBuildRuntimeState.source_conduit_rotation_state', 'source_conduit_rotation_state', BLOCKS, 'mindustry.content.Blocks', 'conduit', n2091_inputs, n2091_outputs, [CONDUIT_DEF, CONDUIT_CAP, ROTATE], True, 'Dictionary'),
        ('N2092', 'SourceConduitRuntimeState.source_conduit_update_state', 'source_conduit_update_state', CONDUIT, 'mindustry.world.blocks.liquid.Conduit$ConduitBuild', 'updateTile()', n2092_inputs, n2092_outputs, [SMOOTH, FLOW_GUARD, MOVE_FORWARD, LEAK, FLOW], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed conduit rotation and updateTile.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed conduit rotation and updateTile; the conduits point at the drill and push water forward once per second.'))
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
