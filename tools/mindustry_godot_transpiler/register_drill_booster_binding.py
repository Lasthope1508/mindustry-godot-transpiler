"""Register the drill water booster state (N2093).

N2093 is the drill's water booster: the mechanical drill consumes
water 0.05f as an optional booster (Blocks.java:2873,
consumeLiquid(Liquids.water, 0.05f).boost()), and its updateTile
speed is lerp(1f, liquidBoostIntensity, optionalEfficiency) *
efficiency (Drill.java:301), with liquidBoostIntensity = 1.6f
(Drill.java:38). This slice reads the drill's booster state — its
water, optional_efficiency and speed — so the C04 gate can prove
the drill runs 1.6x faster when water reaches it.

It also corrects N2088: the pump's production used the Godot delta
in seconds directly, but Java's edelta() is in ticks (Arc Time.delta
is getDeltaTime() * 60f, so 1.0 per frame at 60fps). The pump
produced 7/60 water per second instead of 7.0 per second, so it
could never supply the drill's 0.05f-per-frame (3.0/sec) booster
drain and the booster never engaged. source_pump_update_state now
uses the tick-edelta (delta * 60), and the N2088 proof calls it
with a frame delta (1/60s).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/DrillBoosterProof'
TESTS = ['test_drill_booster_binding_registration', 'test_all_drill_booster_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_drill_booster']
DEFERRED = [
    'The live-loop liquid flow (the C04 gate: pump -> conduit -> Drill uses water as a booster) is proven by this slice; the drill runs 1.6x faster when water reaches it.',
    'C05-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

BOOST = 'public float liquidBoostIntensity = 1.6f;'
SPEED = 'float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;'
CONSUMER = 'consumeLiquid(Liquids.water, 0.05f).boost();'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2093_inputs = {
        'game': f('Object', SPEED, 'The game, for the drill sprite, its liquid module and its drill frame.'),
        'cell': f('Vector2i', SPEED, 'The drill cell to read.'),
    }
    n2093_outputs = {
        'water': f('float', CONSUMER, 'The drill water amount.', source=BLOCKS),
        'optional_efficiency': f('float', SPEED, 'The drill optional (booster) efficiency.'),
        'speed': f('float', SPEED, 'The drill speed multiplier (1.0 without water, 1.6 with water).'),
        'boosted': f('bool', BOOST, 'Whether the booster is engaged (optional_efficiency > 0).'),
    }

    entries = [
        ('N2093', 'SourceDrillConsumptionRuntimeState.source_drill_booster_state', 'source_drill_booster_state', DRILL, 'mindustry.world.blocks.production.Drill$DrillBuild', 'updateTile()', n2093_inputs, n2093_outputs, [BOOST, SPEED, CONSUMER], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed drill water booster.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed drill water booster; the drill runs 1.6x faster when water reaches it.'))
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
