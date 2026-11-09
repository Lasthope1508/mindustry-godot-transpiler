"""Register the ContinuousLiquidTurret tick frame wiring (N2102).

N2102 wires the turret tick to set the frame keys the N2101 cost
multiplier branch reads, so the multiplier is actually paid live
instead of only on hand-built frame dicts. Java's tick is
ContinuousLiquidTurretBuild.updateTile() (ContinuousLiquidTurret.java);
the multiplier lambda it feeds runs during updateConsumption and reads
b.liquids.current() and the block's ammoTypes
(ContinuousLiquidTurret.java:45-48): var ammo =
ammoTypes.get(b.liquids.current()); return ammo == null ? 1f :
1f / ammo.ammoMultiplier.

SourceContinuousLiquidTurretBuildState.source_tick_frame_state(frame,
block_implementation, liquids, liquid_names_by_id, ammo_types) sets
the frame keys before the consumers run, like the drill tick sets its
keys (N2097): block_implementation from block.implementation so the
N2101 branch dispatches; current_liquid is b.liquids.current() -- the
last received/loaded liquid (LiquidModule.java:80-83) -- read in the
port from the liquid module's "current" via
SourceLiquidModuleState.source_current_state and resolved to its
content name (Java resolves a liquid by id through content.liquid(id);
LiquidModule.java:24 seeds current with content.liquid(0), the first
liquid, water); ammo_types is the block's ammoTypes
(ObjectMap<Liquid, BulletType>, ContinuousLiquidTurret.java:14) in port
form. A module without a current id, or an id with no content name,
leaves current_liquid null and the multiplier keeps its 1.0 default.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java'
LIQUID_MODULE = 'core/src/mindustry/world/modules/LiquidModule.java'
OWNER = 'SourceContinuousLiquidTurretBuildState.source_tick_frame_state'
PROOF = '/root/ContinuousLiquidTurretTickFrameProof'
TESTS = ['test_continuous_liquid_turret_tick_frame_registration', 'test_all_continuous_liquid_turret_tick_frame_input_evidence_is_exact', 'test_reference_graph_and_actual_continuous_liquid_turret_tick_frame']
DEFERRED = [
    'Calling the tick wiring from the live loop (simulate_factory) every tick and binding the turret frame on placement are later slices; the proof wires a placed turret frame directly.',
    'Capturing ammoTypes into the content registry (emitter) so the tick can read the ammo map off the block instead of taking it as a parameter is a later slice; sublimate carries no consumeLiquid or ammoTypes in the registry yet, so no RuntimeConsumer can be bound for it either.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();',
    'var ammo = ammoTypes.get(b.liquids.current());',
    'return ammo == null ? 1f : 1f / ammo.ammoMultiplier;',
    'public Liquid current(){',
    'private Liquid current = content.liquid(0);',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2102_inputs = {
        'frame': f('Dictionary', 'var ammo = ammoTypes.get(b.liquids.current());', 'The building frame (the b of the multiplier lambda); the tick wires its block_implementation, current_liquid and ammo_types keys in place and returns it.'),
        'block_implementation': f('String', 'public class ContinuousLiquidTurret extends ContinuousTurret{', 'The block implementation name, from block.implementation like the drill tick sets it (N2097); the N2101 branch dispatches on ContinuousLiquidTurret.'),
        'liquids': f('Dictionary', 'public Liquid current(){', 'The building liquid module state (b.liquids); current() is the last received/loaded liquid (LiquidModule.java:80-83), read in the port from the module\'s "current" via SourceLiquidModuleState.source_current_state.', source=LIQUID_MODULE),
        'liquid_names_by_id': f('Array', 'private Liquid current = content.liquid(0);', 'Content liquid names indexed by liquid id; Java resolves a liquid by id through content.liquid(id), which seeds the module current at LiquidModule.java:24.', source=LIQUID_MODULE),
        'ammo_types': f('Dictionary', 'public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();', 'The block ammoTypes in port form, liquid name to the bullet type dict carrying ammoMultiplier (BulletType.java:95, default 2f); sublimate maps ozone to 1.2f and cyanogen to the 2f default (Blocks.java:4604-4631).'),
    }
    n2102_outputs = {
        'block_implementation': f('String', 'public class ContinuousLiquidTurret extends ContinuousTurret{', 'The implementation name set on the frame, so the N2101 branch dispatches.'),
        'current_liquid': f('Variant', 'var ammo = ammoTypes.get(b.liquids.current());', 'The content name of the module current liquid, or null when the module has no current id or the id has no content name; the multiplier keeps its 1.0 default then.'),
        'ammo_types': f('Dictionary', 'public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();', 'The block ammoTypes in port form, set on the frame for the multiplier lookup.'),
    }

    entries = [
        ('N2102', OWNER, 'source_tick_frame_state', TURRET, 'mindustry.world.blocks.defense.turrets.ContinuousLiquidTurret.ContinuousLiquidTurretBuild', 'ContinuousLiquidTurretBuild.updateTile()', n2102_inputs, n2102_outputs, EXACT_EXPRS, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ContinuousLiquidTurret tick frame wiring.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ContinuousLiquidTurret tick frame wiring; the tick sets the frame keys the N2101 cost multiplier reads (current_liquid from the liquid module, ammo_types from the block), so the multiplier is paid live.'))
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
