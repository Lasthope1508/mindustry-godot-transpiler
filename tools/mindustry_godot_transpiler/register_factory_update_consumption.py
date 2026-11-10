"""Register the GenericCrafter updateConsumption efficiency adapter (N2111).

N2110 wired the factory family's frame keys live (the tick refreshes
the cheating flag from team.rules().cheat every simulate_factory
tick), but nothing read that flag on the consumption path: a cheating
silicon-smelter still ran the full consumer machinery. N2111 threads
the flag through, the GenericCrafter equivalent of N2109's unit-factory
adapter: source_factory_update_consumption_state runs the shared
SourceBuildingEfficiencyState.update_consumption_state with the frame's
live cheating flag, so a cheating factory takes BuildingComp's early
return and skips consumption at full efficiency.

Java: BuildingComp.updateConsumption() (BuildingComp.java:1943-1951)
returns early when cheating -- `if(!block.hasConsumers ||
cheating()){`, potentialEfficiency from enabled and productionValid,
efficiency from shouldConsume, no consumer updated -- and the shared
efficiency machinery (SourceBuildingEfficiencyState.
update_consumption_state) already implements that method; the adapter
runs it with the frame's live flag and no bound consumer actors yet
(binding the factory's RuntimeConsumer actors is a later slice, like
the ContinuousLiquidTurret binding in N2106). The tick itself runs
after updateConsumption through Building.update()
(BuildingComp.java:2262-2274), so this adapter is the consumption half
of GenericCrafterBuild.updateTile() (GenericCrafter.java:235).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
GENERIC_CRAFTER = 'core/src/mindustry/world/blocks/production/GenericCrafter.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
CONSUMPTION_OWNER = 'SourceFactoryBuildState.source_factory_update_consumption_state'
PROOF = '/root/FactoryUpdateConsumptionProof'
TESTS = ['test_factory_update_consumption_registration', 'test_all_factory_update_consumption_input_evidence_is_exact', 'test_update_consumption_reads_frame_cheating', 'test_reference_graph_and_actual_factory_update_consumption']
DEFERRED = [
    'Binding the GenericCrafter family RuntimeConsumer actors (one per consumeItem/consumeLiquid row, the drill model, N2097/N2100) so the non-cheating consumption path actually consumes is a later slice; the adapter runs the shared updateConsumption machinery over an empty actor list until then.',
    'The GenericCrafterBuild.shouldConsume() body (GenericCrafter.java:203, output-space checks) is a later slice; the adapter takes should_consume as an input.',
    'Wiring the remaining factory-adjacent families (Separator, Incinerator, WallCrafter, SingleBlockProducer -- Block/BlockProducer builds, not GenericCrafterBuild) to the live cheating value is a later slice.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public class GenericCrafterBuild extends Building{',
    'public void updateTile(){',
    'public boolean shouldConsume(){',
    'public void updateConsumption(){',
    'if(!block.hasConsumers || cheating()){',
    'potentialEfficiency = enabled && productionValid() ? 1f : 0f;',
    'efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;',
    'public float efficiencyScale(){',
    'updateConsumption();',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=GENERIC_CRAFTER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2111_consumption_inputs = {
        'frame': f('Dictionary', 'if(!block.hasConsumers || cheating()){', "The factory frame; its cheating flag decides whether updateConsumption takes the early return.", source=BUILDING_COMP),
        'has_consumers': f('bool', 'if(!block.hasConsumers || cheating()){', 'Whether the block has consumers (block.hasConsumers); with none, updateConsumption returns early just like when cheating.', source=BUILDING_COMP),
        'enabled': f('bool', 'potentialEfficiency = enabled && productionValid() ? 1f : 0f;', 'Whether the building is enabled; the cheating branch sets potentialEfficiency from enabled and productionValid.', source=BUILDING_COMP),
        'production_valid': f('bool', 'potentialEfficiency = enabled && productionValid() ? 1f : 0f;', 'Whether production is valid (productionValid()); the cheating branch sets potentialEfficiency from enabled and productionValid.', source=BUILDING_COMP),
        'should_consume': f('bool', 'efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;', 'Whether the build should consume (shouldConsume()); the cheating branch sets efficiency from it.', source=BUILDING_COMP),
        'efficiency_scale': f('float', 'public float efficiencyScale(){', 'The efficiency scale (BuildingComp.efficiencyScale(), default 1f) the machinery multiplies the result by.', source=BUILDING_COMP),
    }
    n2111_consumption_outputs = {
        'cheating': f('bool', 'if(!block.hasConsumers || cheating()){', 'Whether the frame cheated, so updateConsumption took the early return and skipped consumption.', source=BUILDING_COMP),
        'skipped_consumption': f('bool', 'if(!block.hasConsumers || cheating()){', 'Whether consumption was skipped: the Java early-return condition itself (no consumers, or cheating).', source=BUILDING_COMP),
        'potential_efficiency': f('float', 'potentialEfficiency = enabled && productionValid() ? 1f : 0f;', 'The potential efficiency from the cheating branch (enabled and productionValid, else 0).', source=BUILDING_COMP),
        'efficiency': f('float', 'efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;', 'The efficiency from the cheating branch (potential when shouldConsume, else 0).', source=BUILDING_COMP),
        'optional_efficiency': f('float', 'efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;', 'The optional efficiency from the cheating branch (same as efficiency here).', source=BUILDING_COMP),
        'should_consume_power': f('bool', 'if(!block.hasConsumers || cheating()){', 'Whether the build should consume power; the cheating branch sets it true.', source=BUILDING_COMP),
    }

    entries = [
        ('N2111', CONSUMPTION_OWNER, 'source_factory_update_consumption_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp', 'BuildingComp.updateConsumption()', n2111_consumption_inputs, n2111_consumption_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed GenericCrafter updateConsumption efficiency adapter; the frame cheating flag wired live by N2110 decides whether BuildingComp.updateConsumption() takes its early return.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed GenericCrafter updateConsumption efficiency adapter; runs the shared updateConsumption machinery with the frame live cheating flag, so a cheating factory skips consumption at full efficiency.'))
        all_names.extend(names)
    by_slice['N2111'] = all_names
    # One slice row: the consumption adapter is the only owner.
    source_symbols.upsert_source_slice(GODOT, 'N2111', dict(status='done', java_source=GENERIC_CRAFTER, java_class='mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', java_method='GenericCrafterBuild.updateTile(); BuildingComp.updateConsumption()', godot_owner=CONSUMPTION_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=all_names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
