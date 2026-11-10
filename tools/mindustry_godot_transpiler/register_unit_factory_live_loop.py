"""Register the factory family live-loop tick and placement frame binding (N2109).

The factory family's own tick did not exist in the live loop: drills,
pumps, conduits, the ContinuousLiquidTurret and the turret family
ticked every simulate_factory tick, but a placed ground factory,
reconstructor or assembler never had its frame keys refreshed, so its
cheating flag stayed at the false default and BuildingComp.
updateConsumption() could never take its cheating branch live. N2109
wires the family tick the way N2108 wired the turret family: the frame
is bound at placement and the driver refreshes its keys from the live
rules every tick, and the consumption adapter runs the shared
updateConsumption machinery with that live flag, so a cheating team's
factory skips consumption.

Java: a placed block's Building is created by Block.newBuilding()
(Block.java:1002); the port's frame is that Building state, bound on
the sprite at placement through the Tile.setBlock proximity path (the
same path that binds the drill, ContinuousLiquidTurret and turret
frames). Every tick the live loop runs the family updateTile methods
(UnitFactoryBuild.updateTile(), UnitFactory.java:392;
ReconstructorBuild.updateTile(), Reconstructor.java:317;
UnitAssemblerBuild.updateTile(), UnitAssembler.java:429); each of them
runs updateConsumption() through the Building update, and the tick
refreshes the frame's cheating flag from the live rules
(TeamComp.cheating(), TeamComp.java:17-19, through N2099's helper).
BuildingComp.updateConsumption() (BuildingComp.java:1943-1951) returns
early when cheating -- `if(!block.hasConsumers || cheating()){`,
potentialEfficiency from enabled and productionValid, efficiency from
shouldConsume, no consumer updated -- and the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state)
already implements that method; the adapter runs it with the frame's
live flag and no bound consumer actors yet (binding the factory's
RuntimeConsumer actors is a later slice, like the
ContinuousLiquidTurret binding in N2106). The three classes all set
each consumer's multiplier to Rules.unitCost (UnitFactory.java:109,
Reconstructor.java:149, UnitAssembler.java:175, bound by N2096-N2097).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
UNIT_FACTORY = 'core/src/mindustry/world/blocks/units/UnitFactory.java'
RECONSTRUCTOR = 'core/src/mindustry/world/blocks/units/Reconstructor.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
BLOCK = 'core/src/mindustry/world/Block.java'
TILE = 'core/src/mindustry/world/Tile.java'
TEAM_COMP = 'core/src/mindustry/entities/comp/TeamComp.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
TICK_FRAME_OWNER = 'SourceUnitFactoryBuildState.source_unit_factory_tick_frame_state'
BIND_OWNER = 'SourceUnitFactoryBuildState.source_unit_factory_bind_frame_state'
TICK_OWNER = 'SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state'
CONSUMPTION_OWNER = 'SourceUnitFactoryBuildState.source_unit_factory_update_consumption_state'
PROOF = '/root/UnitFactoryLiveLoopProof'
TESTS = ['test_unit_factory_live_loop_registration', 'test_all_unit_factory_live_loop_input_evidence_is_exact', 'test_tick_wires_frame_and_update_consumption_reads_cheating', 'test_reference_graph_and_actual_unit_factory_live_loop']
DEFERRED = [
    'Binding the factory family RuntimeConsumer actors (one per consumeLiquid/consumeItem row, the drill model, N2097/N2100) so the non-cheating consumption path actually consumes is a later slice; the adapter runs the shared updateConsumption machinery over an empty actor list until then.',
    'The three per-class shouldConsume() bodies (UnitFactory.java:446, Reconstructor.java:368, UnitAssembler.java:389) are later slices; the adapter takes should_consume as an input.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public class UnitFactoryBuild extends UnitBuild{',
    'public class ReconstructorBuild extends UnitBuild{',
    'public class UnitAssemblerBuild extends PayloadBlockBuild<Payload>{',
    'public void updateTile(){',
    'public void updateConsumption(){',
    'if(!block.hasConsumers || cheating()){',
    'potentialEfficiency = enabled && productionValid() ? 1f : 0f;',
    'efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;',
    'consumeBuilder.each(c -> c.multiplier = b -> state.rules.unitCost(b.team));',
    'public float efficiencyScale(){',
    'public final Building newBuilding(){',
    'public boolean cheating(){',
    'return team.rules().cheat;',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=UNIT_FACTORY, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2109_tick_frame_inputs = {
        'frame': f('Dictionary', 'public class UnitFactoryBuild extends UnitBuild{', 'The factory frame (the port Building state) the tick wires every tick.'),
        'block_implementation': f('String', 'public class UnitFactoryBuild extends UnitBuild{', "The block's implementation, from block.implementation like the drill/turret ticks set it (N2097/N2108); the driver only ticks factory-family builds."),
        'team_id': f('int', 'public boolean cheating(){', "The building's team id, from the sprite's team meta; cheating() reads this team's TeamRule.", source=TEAM_COMP),
        'rules_state': f('Dictionary', 'return team.rules().cheat;', 'The live game rules (Vars.state.rules, N2098), returned as-is so the cheat read stays live.', source=TEAM_COMP),
    }
    n2109_tick_frame_outputs = {
        'frame': f('Dictionary', 'public class UnitFactoryBuild extends UnitBuild{', 'The wired frame, with block_implementation, team_id, rules_state and the live cheating flag set.'),
    }
    n2109_bind_inputs = {
        'sprite': f('Sprite2D', 'public final Building newBuilding(){', 'The placed Building sprite; only a factory-family sprite gets a frame bound at placement.', source=BLOCK),
        'block': f('Object', 'public class UnitFactoryBuild extends UnitBuild{', 'The typed block definition; the frame binds only when its implementation is a factory-family build (UnitFactory, Reconstructor, UnitAssembler).'),
    }
    n2109_bind_outputs = {
        'applied': f('bool', 'public final Building newBuilding(){', 'Whether the frame was actually bound at placement; false for any other block or an already-bound sprite.', source=BLOCK),
        'frame': f('Dictionary', 'public final Building newBuilding(){', 'The bound frame -- the port Building state created at placement (Block.newBuilding); empty until the live-loop tick fills its keys.', source=BLOCK),
    }
    n2109_tick_inputs = {
        'game': f('Object', 'build.onProximityUpdate();', 'The live game world: the placed-building index, the content catalog and the live rules the tick reads every tick.', source=TILE),
        'seconds': f('float', 'public void updateTile(){', 'The frame delta; the wiring itself only refreshes keys, so the delta is carried for the later production/consumption slices.'),
    }
    n2109_tick_outputs = {
        'ticked_count': f('int', 'public void updateTile(){', 'How many placed factory-family builds had their frame keys refreshed this tick.'),
        'results_by_cell': f('Dictionary', 'public class UnitFactoryBuild extends UnitBuild{', 'Per-cell wired frames, keyed by the game cell key like the drill/turret tick results; a cell maps to its refreshed frame dict.'),
    }
    n2109_consumption_inputs = {
        'frame': f('Dictionary', 'if(!block.hasConsumers || cheating()){', "The factory frame; its cheating flag decides whether updateConsumption takes the early return.", source=BUILDING_COMP),
        'has_consumers': f('bool', 'if(!block.hasConsumers || cheating()){', 'Whether the block has consumers (block.hasConsumers); with none, updateConsumption returns early just like when cheating.', source=BUILDING_COMP),
        'enabled': f('bool', 'potentialEfficiency = enabled && productionValid() ? 1f : 0f;', 'Whether the building is enabled; the cheating branch sets potentialEfficiency from enabled and productionValid.', source=BUILDING_COMP),
        'production_valid': f('bool', 'potentialEfficiency = enabled && productionValid() ? 1f : 0f;', 'Whether production is valid (productionValid()); the cheating branch sets potentialEfficiency from enabled and productionValid.', source=BUILDING_COMP),
        'should_consume': f('bool', 'efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;', 'Whether the build should consume (shouldConsume()); the cheating branch sets efficiency from it.', source=BUILDING_COMP),
        'efficiency_scale': f('float', 'public float efficiencyScale(){', 'The efficiency scale (BuildingComp.efficiencyScale(), default 1f) the machinery multiplies the result by.', source=BUILDING_COMP),
    }
    n2109_consumption_outputs = {
        'cheating': f('bool', 'if(!block.hasConsumers || cheating()){', 'Whether the frame cheated, so updateConsumption took the early return and skipped consumption.', source=BUILDING_COMP),
        'skipped_consumption': f('bool', 'if(!block.hasConsumers || cheating()){', 'Whether consumption was skipped: the Java early-return condition itself (no consumers, or cheating).', source=BUILDING_COMP),
        'potential_efficiency': f('float', 'potentialEfficiency = enabled && productionValid() ? 1f : 0f;', 'The potential efficiency from the cheating branch (enabled and productionValid, else 0).', source=BUILDING_COMP),
        'efficiency': f('float', 'efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;', 'The efficiency from the cheating branch (potential when shouldConsume, else 0).', source=BUILDING_COMP),
        'optional_efficiency': f('float', 'efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;', 'The optional efficiency from the cheating branch (same as efficiency here).', source=BUILDING_COMP),
        'should_consume_power': f('bool', 'if(!block.hasConsumers || cheating()){', 'Whether the build should consume power; the cheating branch sets it true.', source=BUILDING_COMP),
    }

    entries = [
        ('N2109', TICK_FRAME_OWNER, 'source_unit_factory_tick_frame_state', UNIT_FACTORY, 'mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild', 'UnitFactoryBuild.updateTile()', n2109_tick_frame_inputs, n2109_tick_frame_outputs, True, 'Dictionary'),
        ('N2109', BIND_OWNER, 'source_unit_factory_bind_frame_state', BLOCK, 'mindustry.world.Block', 'Block.newBuilding()', n2109_bind_inputs, n2109_bind_outputs, True, 'Dictionary'),
        ('N2109', TICK_OWNER, 'source_unit_factory_tick_buildings_state', UNIT_FACTORY, 'mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild', 'UnitFactoryBuild.updateTile()', n2109_tick_inputs, n2109_tick_outputs, True, 'Dictionary'),
        ('N2109', CONSUMPTION_OWNER, 'source_unit_factory_update_consumption_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp', 'BuildingComp.updateConsumption()', n2109_consumption_inputs, n2109_consumption_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed factory family live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live rules every simulate_factory tick, so BuildingComp.updateConsumption() skips consumption for a cheating team.'))
        all_names.extend(names)
    by_slice['N2109'] = all_names
    # One slice row: the live-loop tick driver is the primary owner; the
    # frame wiring, placement bind and consumption adapter share the slice
    # (their symbols carry their own owner).
    source_symbols.upsert_source_slice(GODOT, 'N2109', dict(status='done', java_source=UNIT_FACTORY, java_class='mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild', java_method='UnitFactoryBuild.updateTile(); Block.newBuilding(); BuildingComp.updateConsumption()', godot_owner=TICK_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=all_names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
