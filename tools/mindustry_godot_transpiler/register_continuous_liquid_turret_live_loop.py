"""Register the ContinuousLiquidTurret live-loop tick and placement frame binding (N2103).

N2102 wired the turret tick (source_tick_frame_state) but nothing called
it from the live loop and no frame was bound when a sublimate was placed,
so the N2101 multiplier was only paid on hand-built frame dicts. N2103
calls the tick wiring from simulate_factory every tick and binds the
turret frame on placement.

Java: a placed block's Building is created by Block.newBuilding()
(Block.java:1002); the port's frame is that Building state, bound on the
sprite at placement through the Tile.setBlock proximity path (the same
path that binds the drill frame on proximity update). Every tick the live
loop runs ContinuousLiquidTurretBuild.updateTile() (which calls
super.updateTile(), ContinuousTurret.java:86-87, running updateConsumption
and the multiplier lambda); the port tick wiring (N2102) sets the frame
keys the lambda reads -- block_implementation, current_liquid from
b.liquids.current() (LiquidModule.java:80-83) and ammo_types from the
block's ammoTypes (ContinuousLiquidTurret.java:14) -- so the multiplier
is actually paid live. Sublimate's ammo map is Blocks.java:4604-4631
(ozone 1.2f, cyanogen the BulletType 2f default); it is a source-backed
constant in the build state until the emitter captures ammoTypes into
the content registry (later slice).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java'
CONTINUOUS_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
TILE = 'core/src/mindustry/world/Tile.java'
LIQUID_MODULE = 'core/src/mindustry/world/modules/LiquidModule.java'
BIND_OWNER = 'SourceContinuousLiquidTurretBuildState.source_bind_frame_state'
TICK_OWNER = 'SourceContinuousLiquidTurretBuildState.source_tick_buildings_state'
PROOF = '/root/ContinuousLiquidTurretLiveLoopProof'
TESTS = ['test_continuous_liquid_turret_live_loop_registration', 'test_all_continuous_liquid_turret_live_loop_input_evidence_is_exact', 'test_reference_graph_and_actual_continuous_liquid_turret_live_loop']
DEFERRED = [
    'Capturing ammoTypes into the content registry (emitter) so the tick reads the ammo map off the block instead of the source-backed sublimate map in SourceContinuousLiquidTurretBuildState is a later slice; sublimate carries no consumeLiquid or ammoTypes in the registry yet, so no RuntimeConsumer can be bound for it either.',
    'Wiring other buildings (turrets, factories) to the live cheating value is a later slice.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public final Building newBuilding(){',
    'public class ContinuousLiquidTurret extends ContinuousTurret{',
    'public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();',
    'public void updateTile(){',
    'super.updateTile();',
    'var ammo = ammoTypes.get(b.liquids.current());',
    'return ammo == null ? 1f : 1f / ammo.ammoMultiplier;',
    'Liquids.ozone, new ContinuousFlameBulletType(){{',
    'ammoMultiplier = 1.2f;',
    'Liquids.cyanogen, new ContinuousFlameBulletType(){{',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2103_bind_inputs = {
        'sprite': f('Sprite2D', 'public class ContinuousLiquidTurret extends ContinuousTurret{', 'The placed Building sprite; only a ContinuousLiquidTurret sprite gets a frame bound at placement.'),
        'block': f('Object', 'public class ContinuousLiquidTurret extends ContinuousTurret{', 'The typed block definition; the frame binds only when its implementation is ContinuousLiquidTurret.'),
    }
    n2103_bind_outputs = {
        'applied': f('bool', 'public final Building newBuilding(){', 'Whether the frame was actually bound at placement; false for any other block or an already-bound sprite.', source=BLOCK),
        'frame': f('Dictionary', 'public final Building newBuilding(){', 'The bound frame -- the port Building state created at placement (Block.newBuilding); empty until the live-loop tick fills its keys.', source=BLOCK),
    }
    n2103_tick_inputs = {
        'game': f('Object', 'build.onProximityUpdate();', 'The live game world: the placed-building index, the content catalog and the liquid module state the tick reads every tick.', source=TILE),
    }
    n2103_tick_outputs = {
        'ticked_count': f('int', 'public void updateTile(){', 'How many placed ContinuousLiquidTurret builds had their frame keys refreshed this tick.'),
        'results_by_cell': f('Dictionary', 'super.updateTile();', 'Per-cell wired frames, keyed by the game cell key like the drill tick results; a cell maps to its refreshed frame dict.', source=CONTINUOUS_TURRET),
    }

    entries = [
        ('N2103', BIND_OWNER, 'source_bind_frame_state', BLOCK, 'mindustry.world.Block', 'Block.newBuilding()', n2103_bind_inputs, n2103_bind_outputs, True, 'Dictionary'),
        ('N2103', TICK_OWNER, 'source_tick_buildings_state', TURRET, 'mindustry.world.blocks.defense.turrets.ContinuousLiquidTurret.ContinuousLiquidTurretBuild', 'ContinuousLiquidTurretBuild.updateTile()', n2103_tick_inputs, n2103_tick_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2029 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ContinuousLiquidTurret live-loop tick and placement frame binding.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ContinuousLiquidTurret live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live liquid module every simulate_factory tick, so the N2101 cost multiplier is paid live.'))
        all_names.extend(names)
    by_slice['N2103'] = all_names
    # One slice row: the live-loop tick driver is the primary owner; the
    # placement bind shares the slice (its symbols carry their own owner).
    source_symbols.upsert_source_slice(GODOT, 'N2103', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.ContinuousLiquidTurret.ContinuousLiquidTurretBuild', java_method='ContinuousLiquidTurretBuild.updateTile(); Block.newBuilding()', godot_owner=TICK_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=all_names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
