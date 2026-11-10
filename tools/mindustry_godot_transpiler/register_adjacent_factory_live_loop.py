"""Register the adjacent factory families live-loop tick (N2114).

The factory-adjacent families had no live-loop tick: Separator,
Incinerator, WallCrafter and SingleBlockProducer builds are not
GenericCrafterBuilds, so the N2110 factory tick never touched them
and their cheating flag stayed at the false default. N2114 wires
them the way N2110 wired the GenericCrafter family: the frame is
bound at placement and the driver refreshes its keys from the live
rules every tick, the updateConsumption adapter runs the shared
efficiency machinery with the live cheating flag (N2111 pattern),
and each family's own shouldConsume() body gates efficiency
(N2113 pattern).

Java: a placed block's Building is created by Block.newBuilding()
(Block.java:1002); the port's frame is that Building state, bound
on the sprite at placement through the Tile.setBlock proximity path
(the same path that binds the drill, ContinuousLiquidTurret, turret
and factory frames). Every tick the live loop runs each family's
updateTile() -- SeparatorBuild.updateTile() (Separator.java:130),
IncineratorBuild.updateTile() (Incinerator.java:30),
WallCrafterBuild.updateTile() (WallCrafter.java:187, super first),
BlockProducerBuild.updateTile() (BlockProducer.java:107, super
first) -- after updateConsumption through Building.update()
(BuildingComp.java:2262-2274). The tick refreshes the frame's
cheating flag from the live rules (TeamComp.cheating(),
TeamComp.java:17-19, through N2099's helper), so a cheating team's
adjacent factory counts everything as valid
(BuildingComp.java:1944-1945, `if(!block.hasConsumers ||
cheating()){`). Each family's shouldConsume() is its own body:
SeparatorBuild.shouldConsume() (Separator.java:92-100) counts the
held items minus the consumeItem inputs (consItems, found by
init(), Separator.java:56) and consumes while the remainder fits
itemCapacity (`return total < itemCapacity && enabled;`);
WallCrafterBuild.shouldConsume() (WallCrafter.java:226-227)
consumes while the held output stack fits itemCapacity (`return
items.get(output) < itemCapacity;`, no enabled check -- Building.
updateConsumption handles enabled separately);
IncineratorBuild does not override shouldConsume, so the Building
default applies (`return enabled;`, BuildingComp.java:755-756);
BlockProducerBuild.shouldConsume() (BlockProducer.java:102-103)
is the Building default plus a recipe (`return
super.shouldConsume() && recipe() != null;`), and
SingleBlockProducerBuild.recipe() returns the block's result
(SingleBlockProducer.java:19-20, default Blocks.router,
SingleBlockProducer.java:9).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
SEPARATOR = 'core/src/mindustry/world/blocks/production/Separator.java'
INCINERATOR = 'core/src/mindustry/world/blocks/production/Incinerator.java'
WALL_CRAFTER = 'core/src/mindustry/world/blocks/production/WallCrafter.java'
SINGLE_BLOCK_PRODUCER = 'core/src/mindustry/world/blocks/production/SingleBlockProducer.java'
BLOCK_PRODUCER = 'core/src/mindustry/world/blocks/payloads/BlockProducer.java'
BLOCK = 'core/src/mindustry/world/Block.java'
TILE = 'core/src/mindustry/world/Tile.java'
TEAM_COMP = 'core/src/mindustry/entities/comp/TeamComp.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
TICK_FRAME_OWNER = 'SourceAdjacentFactoryBuildState.source_adjacent_factory_tick_frame_state'
BIND_OWNER = 'SourceAdjacentFactoryBuildState.source_adjacent_factory_bind_frame_state'
TICK_OWNER = 'SourceAdjacentFactoryBuildState.source_adjacent_factory_tick_buildings_state'
CONSUMPTION_OWNER = 'SourceAdjacentFactoryBuildState.source_adjacent_factory_update_consumption_state'
SHOULD_CONSUME_OWNER = 'SourceAdjacentFactoryBuildState.source_adjacent_factory_should_consume_state'
PROOF = '/root/AdjacentFactoryLiveLoopProof'
TESTS = ['test_adjacent_factory_live_loop_registration', 'test_all_adjacent_factory_live_loop_input_evidence_is_exact', 'test_tick_wires_frame_and_driver_runs_from_live_loop', 'test_reference_graph_and_actual_adjacent_factory_live_loop']
DEFERRED = [
    'Binding the adjacent families RuntimeConsumer actors (one per consumeItem/consumeLiquid row, the drill model, N2097/N2100/N2112) so the non-cheating consumption path actually consumes is a later slice; the adapter runs the shared updateConsumption machinery over an empty actor list until then.',
    'The C05 gate (lifecycle replacement, storage independence, consumer classification) is a later slice; the adjacent families are the last factory-adjacent work before it.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public class Separator extends Block{',
    'public class SeparatorBuild extends Building{',
    'consItems = findConsumer(c -> c instanceof ConsumeItems);',
    'public boolean shouldConsume(){',
    'return total < itemCapacity && enabled;',
    'public void updateTile(){',
    'public class Incinerator extends Block{',
    'public class IncineratorBuild extends Building{',
    'public class WallCrafter extends Block{',
    'public class WallCrafterBuild extends Building{',
    'return items.get(output) < itemCapacity;',
    'public class SingleBlockProducer extends BlockProducer{',
    'public Block result = Blocks.router;',
    'public class SingleBlockProducerBuild extends BlockProducerBuild{',
    'public Block recipe(){',
    'return result;',
    'public abstract class BlockProducer extends PayloadBlock{',
    'return super.shouldConsume() && recipe() != null;',
    'public final Building newBuilding(){',
    'public boolean cheating(){',
    'return team.rules().cheat;',
    'return enabled;',
    'if(!block.hasConsumers || cheating()){',
    'updateConsumption();',
    'public int itemCapacity = 10;',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=SEPARATOR, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2114_tick_frame_inputs = {
        'frame': f('Dictionary', 'public class SeparatorBuild extends Building{', 'The adjacent-factory frame (the port Building state) the tick wires every tick.'),
        'block_implementation': f('String', 'public class Separator extends Block{', "The block's implementation, from block.implementation like the factory tick sets it (N2110); the driver only ticks Separator/Incinerator/WallCrafter/SingleBlockProducer builds."),
        'team_id': f('int', 'public boolean cheating(){', "The building's team id, from the sprite's team meta; cheating() reads this team's TeamRule.", source=TEAM_COMP),
        'rules_state': f('Dictionary', 'return team.rules().cheat;', 'The live game rules (Vars.state.rules, N2098), returned as-is so the cheat read stays live.', source=TEAM_COMP),
    }
    n2114_tick_frame_outputs = {
        'frame': f('Dictionary', 'public class SeparatorBuild extends Building{', 'The wired frame, with block_implementation, team_id, rules_state and the live cheating flag set.'),
    }
    n2114_bind_inputs = {
        'sprite': f('Sprite2D', 'public final Building newBuilding(){', 'The placed Building sprite; only an adjacent-family sprite gets a frame bound at placement.', source=BLOCK),
        'block': f('Object', 'public class Separator extends Block{', 'The typed block definition; the frame binds only when its implementation is an adjacent-family build (Separator, Incinerator, WallCrafter, SingleBlockProducer).'),
    }
    n2114_bind_outputs = {
        'applied': f('bool', 'public final Building newBuilding(){', 'Whether the frame was actually bound at placement; false for any other block or an already-bound sprite.', source=BLOCK),
        'frame': f('Dictionary', 'public final Building newBuilding(){', 'The bound frame -- the port Building state created at placement (Block.newBuilding); empty until the live-loop tick fills its keys.', source=BLOCK),
    }
    n2114_tick_inputs = {
        'game': f('Object', 'build.onProximityUpdate();', 'The live game world: the placed-building index, the content catalog and the live rules the tick reads every tick.', source=TILE),
        'seconds': f('float', 'public void updateTile(){', 'The frame delta; the wiring itself only refreshes keys, so the delta is carried for the later consumption slices.'),
    }
    n2114_tick_outputs = {
        'ticked_count': f('int', 'public void updateTile(){', 'How many placed adjacent-family builds had their frame keys refreshed this tick.'),
        'results_by_cell': f('Dictionary', 'public class SeparatorBuild extends Building{', 'Per-cell wired frames, keyed by the game cell key like the factory tick results; a cell maps to its refreshed frame dict.'),
    }
    n2114_consumption_inputs = {
        'frame': f('Dictionary', 'if(!block.hasConsumers || cheating()){', "The adjacent-factory frame; its cheating flag decides whether updateConsumption takes the early return.", source=BUILDING_COMP),
        'has_consumers': f('bool', 'if(!block.hasConsumers || cheating()){', 'Whether the block has consumers (block.hasConsumers); with none, updateConsumption returns early just like when cheating.', source=BUILDING_COMP),
        'enabled': f('bool', 'potentialEfficiency = enabled && productionValid() ? 1f : 0f;', 'Whether the building is enabled; the cheating branch sets potentialEfficiency from enabled and productionValid.', source=BUILDING_COMP),
        'production_valid': f('bool', 'potentialEfficiency = enabled && productionValid() ? 1f : 0f;', 'Whether production is valid (productionValid()); the cheating branch sets potentialEfficiency from enabled and productionValid.', source=BUILDING_COMP),
        'should_consume': f('bool', 'efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;', 'Whether the build should consume (its family shouldConsume()); the cheating branch sets efficiency from it.', source=BUILDING_COMP),
        'efficiency_scale': f('float', 'public float efficiencyScale(){', 'The efficiency scale (BuildingComp.efficiencyScale(), default 1f) the machinery multiplies the result by.', source=BUILDING_COMP),
    }
    n2114_consumption_outputs = {
        'cheating': f('bool', 'if(!block.hasConsumers || cheating()){', 'Whether the frame cheated, so updateConsumption took the early return and skipped consumption.', source=BUILDING_COMP),
        'skipped_consumption': f('bool', 'if(!block.hasConsumers || cheating()){', 'Whether consumption was skipped: the Java early-return condition itself (no consumers, or cheating).', source=BUILDING_COMP),
        'potential_efficiency': f('float', 'potentialEfficiency = enabled && productionValid() ? 1f : 0f;', 'The potential efficiency from the cheating branch (enabled and productionValid, else 0).', source=BUILDING_COMP),
        'efficiency': f('float', 'efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;', 'The efficiency from the cheating branch (potential when shouldConsume, else 0).', source=BUILDING_COMP),
        'optional_efficiency': f('float', 'efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;', 'The optional efficiency from the cheating branch (same as efficiency here).', source=BUILDING_COMP),
        'should_consume_power': f('bool', 'if(!block.hasConsumers || cheating()){', 'Whether the build should consume power; the cheating branch sets it true.', source=BUILDING_COMP),
    }
    n2114_should_consume_inputs = {
        'frame': f('Dictionary', 'public boolean shouldConsume(){', "The adjacent-factory frame; its held items and enabled flag are what each family's shouldConsume() reads."),
        'block': f('Object', 'public class Separator extends Block{', "The typed block definition; its implementation picks the family's shouldConsume() body and its itemCapacity/output bound it."),
    }
    n2114_should_consume_outputs = {
        'should_consume': f('bool', 'return total < itemCapacity && enabled;', 'Whether the build may consume this tick: its outputs have room and it is enabled (Separator body; the other families return their own body).'),
        'output_blocked': f('bool', 'return items.get(output) < itemCapacity;', 'Whether an output item is blocked: the held output stack reaches itemCapacity (WallCrafter body).', source=WALL_CRAFTER),
        'buffer_full': f('bool', 'return total < itemCapacity && enabled;', 'Whether the held items minus the consumeItem inputs fill itemCapacity (Separator body).'),
    }

    entries = [
        ('N2114', TICK_FRAME_OWNER, 'source_adjacent_factory_tick_frame_state', SEPARATOR, 'mindustry.world.blocks.production.Separator.SeparatorBuild', 'SeparatorBuild.updateTile()', n2114_tick_frame_inputs, n2114_tick_frame_outputs, True, 'Dictionary'),
        ('N2114', BIND_OWNER, 'source_adjacent_factory_bind_frame_state', BLOCK, 'mindustry.world.Block', 'Block.newBuilding()', n2114_bind_inputs, n2114_bind_outputs, True, 'Dictionary'),
        ('N2114', TICK_OWNER, 'source_adjacent_factory_tick_buildings_state', SEPARATOR, 'mindustry.world.blocks.production.Separator.SeparatorBuild', 'SeparatorBuild.updateTile()', n2114_tick_inputs, n2114_tick_outputs, True, 'Dictionary'),
        ('N2114', CONSUMPTION_OWNER, 'source_adjacent_factory_update_consumption_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp', 'BuildingComp.updateConsumption()', n2114_consumption_inputs, n2114_consumption_outputs, True, 'Dictionary'),
        ('N2114', SHOULD_CONSUME_OWNER, 'source_adjacent_factory_should_consume_state', SEPARATOR, 'mindustry.world.blocks.production.Separator.SeparatorBuild', 'SeparatorBuild.shouldConsume()', n2114_should_consume_inputs, n2114_should_consume_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed adjacent factory family live-loop tick, placement frame binding, updateConsumption adapter and per-family shouldConsume().'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed adjacent factory family live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live rules every simulate_factory tick, so a cheating team\'s adjacent factory counts everything as valid in updateConsumption, and the tick gates efficiency on the family\'s own shouldConsume() body.'))
        all_names.extend(names)
    by_slice['N2114'] = all_names
    # One slice row: the live-loop tick driver is the primary owner; the
    # frame wiring, placement bind, consumption adapter and
    # shouldConsume helpers share the slice (their symbols carry their
    # own owner).
    source_symbols.upsert_source_slice(GODOT, 'N2114', dict(status='done', java_source=SEPARATOR, java_class='mindustry.world.blocks.production.Separator.SeparatorBuild', java_method='SeparatorBuild.updateTile(); SeparatorBuild.shouldConsume(); WallCrafterBuild.shouldConsume(); BlockProducerBuild.shouldConsume(); BuildingComp.updateConsumption()', godot_owner=TICK_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=all_names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
