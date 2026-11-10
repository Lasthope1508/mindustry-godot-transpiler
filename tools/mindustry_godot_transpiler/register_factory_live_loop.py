"""Register the factory family live-loop tick and placement frame binding (N2110).

The factory family's own tick did not exist in the live loop: drills,
pumps, conduits, the ContinuousLiquidTurret and the turret family
ticked every simulate_factory tick, but a placed silicon-smelter or
graphite-press never had its frame keys refreshed, so its cheating
flag stayed at the false default and BuildingComp.updateConsumption()
could never take its cheating branch live. N2110 wires the family
tick the way N2108 wired the turret family: the frame is bound at
placement and the driver refreshes its keys from the live rules every
tick.

Java: a placed block's Building is created by Block.newBuilding()
(Block.java:1002); the port's frame is that Building state, bound on
the sprite at placement through the Tile.setBlock proximity path (the
same path that binds the drill, ContinuousLiquidTurret and turret
frames). Every tick the live loop runs GenericCrafterBuild.updateTile()
(GenericCrafter.java:235), after updateConsumption through
Building.update() (BuildingComp.java:2262-2274); AttributeCrafterBuild
does not override updateTile, and HeatCrafterBuild/HeatProducerBuild
call super.updateTile() first (HeatCrafter.java:48-51,
HeatProducer.java:46-47), so that tick is the family tick. The tick
refreshes the frame's cheating flag from the live rules
(TeamComp.cheating(), TeamComp.java:17-19, through N2099's helper), so
a cheating team's factory counts everything as valid
(BuildingComp.java:1944-1945, `if(!block.hasConsumers || cheating()){`).
Separator, Incinerator and WallCrafter extend Block directly and
SingleBlockProducer extends BlockProducer, so none of them is a
GenericCrafterBuild and they are not wired here.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
GENERIC_CRAFTER = 'core/src/mindustry/world/blocks/production/GenericCrafter.java'
ATTRIBUTE_CRAFTER = 'core/src/mindustry/world/blocks/production/AttributeCrafter.java'
HEAT_CRAFTER = 'core/src/mindustry/world/blocks/production/HeatCrafter.java'
HEAT_PRODUCER = 'core/src/mindustry/world/blocks/heat/HeatProducer.java'
BLOCK = 'core/src/mindustry/world/Block.java'
TILE = 'core/src/mindustry/world/Tile.java'
TEAM_COMP = 'core/src/mindustry/entities/comp/TeamComp.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
TICK_FRAME_OWNER = 'SourceFactoryBuildState.source_factory_tick_frame_state'
BIND_OWNER = 'SourceFactoryBuildState.source_factory_bind_frame_state'
TICK_OWNER = 'SourceFactoryBuildState.source_factory_tick_buildings_state'
PROOF = '/root/FactoryLiveLoopProof'
TESTS = ['test_factory_live_loop_registration', 'test_all_factory_live_loop_input_evidence_is_exact', 'test_tick_wires_frame_and_driver_runs_from_live_loop', 'test_reference_graph_and_actual_factory_live_loop']
DEFERRED = [
    'Threading the frame cheating flag into GenericCrafterBuild updateConsumption efficiency (BuildingComp.java:1944-1945, `if(!block.hasConsumers || cheating()){`) so a cheating factory actually skips consumption and keeps efficiency is a later slice; the tick wiring the flag live is what this slice does.',
    'Wiring the remaining factory-adjacent families (Separator, Incinerator, WallCrafter, SingleBlockProducer -- Block/BlockProducer builds, not GenericCrafterBuild) to the live cheating value is a later slice.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public class GenericCrafter extends Block{',
    'public class GenericCrafterBuild extends Building{',
    'public boolean shouldConsume(){',
    'public void updateTile(){',
    'progress += getProgressIncrease(craftTime);',
    'if(progress >= 1f){',
    'dumpOutputs();',
    'public class AttributeCrafter extends GenericCrafter{',
    'public class AttributeCrafterBuild extends GenericCrafterBuild{',
    'public class HeatCrafter extends GenericCrafter{',
    'public class HeatCrafterBuild extends GenericCrafterBuild implements HeatConsumer{',
    'public class HeatProducer extends GenericCrafter{',
    'public class HeatProducerBuild extends GenericCrafterBuild implements HeatBlock{',
    'super.updateTile();',
    'public final Building newBuilding(){',
    'public boolean cheating(){',
    'return team.rules().cheat;',
    'if(!block.hasConsumers || cheating()){',
    'updateConsumption();',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=GENERIC_CRAFTER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2109_tick_frame_inputs = {
        'frame': f('Dictionary', 'public class GenericCrafterBuild extends Building{', 'The factory frame (the port Building state) the tick wires every tick.'),
        'block_implementation': f('String', 'public class GenericCrafter extends Block{', "The block's implementation, from block.implementation like the turret tick sets it (N2108); the driver only ticks GenericCrafterBuild implementations."),
        'team_id': f('int', 'public boolean cheating(){', "The building's team id, from the sprite's team meta; cheating() reads this team's TeamRule.", source=TEAM_COMP),
        'rules_state': f('Dictionary', 'return team.rules().cheat;', 'The live game rules (Vars.state.rules, N2098), returned as-is so the cheat read stays live.', source=TEAM_COMP),
    }
    n2109_tick_frame_outputs = {
        'frame': f('Dictionary', 'public class GenericCrafterBuild extends Building{', 'The wired frame, with block_implementation, team_id, rules_state and the live cheating flag set.'),
    }
    n2109_bind_inputs = {
        'sprite': f('Sprite2D', 'public final Building newBuilding(){', 'The placed Building sprite; only a factory-family sprite gets a frame bound at placement.', source=BLOCK),
        'block': f('Object', 'public class AttributeCrafter extends GenericCrafter{', 'The typed block definition; the frame binds only when its implementation is a GenericCrafterBuild (GenericCrafter, AttributeCrafter, HeatCrafter, HeatProducer).', source=ATTRIBUTE_CRAFTER),
    }
    n2109_bind_outputs = {
        'applied': f('bool', 'public final Building newBuilding(){', 'Whether the frame was actually bound at placement; false for any other block or an already-bound sprite.', source=BLOCK),
        'frame': f('Dictionary', 'public final Building newBuilding(){', 'The bound frame -- the port Building state created at placement (Block.newBuilding); empty until the live-loop tick fills its keys.', source=BLOCK),
    }
    n2109_tick_inputs = {
        'game': f('Object', 'build.onProximityUpdate();', 'The live game world: the placed-building index, the content catalog and the live rules the tick reads every tick.', source=TILE),
        'seconds': f('float', 'public void updateTile(){', 'The frame delta; the wiring itself only refreshes keys, so the delta is carried for the later crafting/consumption slices.'),
    }
    n2109_tick_outputs = {
        'ticked_count': f('int', 'public void updateTile(){', 'How many placed factory-family builds had their frame keys refreshed this tick.'),
        'results_by_cell': f('Dictionary', 'public class GenericCrafterBuild extends Building{', 'Per-cell wired frames, keyed by the game cell key like the turret tick results; a cell maps to its refreshed frame dict.'),
    }

    entries = [
        ('N2110', TICK_FRAME_OWNER, 'source_factory_tick_frame_state', GENERIC_CRAFTER, 'mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', 'GenericCrafterBuild.updateTile()', n2109_tick_frame_inputs, n2109_tick_frame_outputs, True, 'Dictionary'),
        ('N2110', BIND_OWNER, 'source_factory_bind_frame_state', BLOCK, 'mindustry.world.Block', 'Block.newBuilding()', n2109_bind_inputs, n2109_bind_outputs, True, 'Dictionary'),
        ('N2110', TICK_OWNER, 'source_factory_tick_buildings_state', GENERIC_CRAFTER, 'mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', 'GenericCrafterBuild.updateTile()', n2109_tick_inputs, n2109_tick_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed factory family live-loop tick and placement frame binding.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed factory family live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live rules every simulate_factory tick, so a cheating team\'s factory counts everything as valid in updateConsumption.'))
        all_names.extend(names)
    by_slice['N2110'] = all_names
    # One slice row: the live-loop tick driver is the primary owner; the
    # frame wiring and placement bind helpers share the slice (their
    # symbols carry their own owner).
    source_symbols.upsert_source_slice(GODOT, 'N2110', dict(status='done', java_source=GENERIC_CRAFTER, java_class='mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', java_method='GenericCrafterBuild.updateTile(); Block.newBuilding()', godot_owner=TICK_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=all_names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
