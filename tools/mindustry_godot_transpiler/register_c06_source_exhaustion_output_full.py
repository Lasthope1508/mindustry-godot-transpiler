"""Register the source-exhaustion / output-full acts in the live-loop power stamp (N2127).

The power graph's consumer dicts are rebuilt from the catalog every
frame, and N2125's stamp read only the placed building's live frame
`enabled` flag. That left two Java acts unwired for the factory
families:

- Output-full (GenericCrafterBuild.shouldConsume(),
  GenericCrafter.java:203-231): an output item whose held stack plus
  one output would exceed itemCapacity, or every output liquid full
  at liquidCapacity - 0.001f, makes shouldConsume() false — and
  ConsumePower.requestedPower (ConsumePower.java:60-63) charges an
  unbuffered consumer `usage * (entity.shouldConsume() ? 1f : 0f)`,
  so an output-full factory must request nothing. The adjacent
  family's own body (Separator.java:99-108 counts held items minus
  consume inputs against itemCapacity, WallCrafter.java:246-248,
  BlockProducer.java:108-110, else the Building default) is the same
  `entity.shouldConsume()` factor for those builds.
- Source-exhaustion (BuildingComp.updateConsumption first pass,
  BuildingComp.java:1971-1974): a non-power, non-optional consumer
  whose efficiency is at most 0.0000001f clears shouldConsumePower,
  and PowerGraph.getPowerNeeded (PowerGraph.java:105-115) sums only
  consumers whose shouldConsumePower is set — so a starved factory
  stops drawing power even while its outputs have room. The tick
  already computes that flag (SourceBuildingEfficiencyState.
  update_consumption_non_optional_pass_state, applied to the frame
  by apply_update_consumption_state), so the stamp reads the frame's
  live `should_consume_power` key, falling back to `enabled` before
  the first tick.

N2127 extends the N2125 helper in place (same signature, same
return keys): for a factory frame `should_consume` is the family's
per-class shouldConsume body and `shouldConsumePower` is the frame's
live first-pass flag. No new symbols, contracts, or schemas — the
helper contract (N2125) and the live-loop driver contract (N2077)
gain the extended rule and the N2127 tests in place.

Java: BuildingComp.updateConsumption() first pass
(BuildingComp.java:1960-1978):
    boolean update = shouldConsume() && productionValid();
    float minEfficiency = 1f;
    efficiency = optionalEfficiency = 1f;
    shouldConsumePower = true;
    for(var cons : block.nonOptionalConsumers){
        float result = cons.efficiency(self());
        if(cons != block.consPower && result <= 0.0000001f){
            shouldConsumePower = false;
        }
        minEfficiency = Math.min(minEfficiency, result);
    }
GenericCrafterBuild.shouldConsume() (GenericCrafter.java:202-231):
    public boolean shouldConsume(){
        if(outputItems != null){
            for(var output : outputItems){
                if(items.get(output.item) + output.amount > itemCapacity){
                    return false;
                }
            }
        }
        if(outputLiquids != null && !ignoreLiquidFullness){
            boolean allFull = true;
            for(var output : outputLiquids){
                if(liquids.get(output.liquid) >= liquidCapacity - 0.001f){
                    if(!dumpExtraLiquid){
                        return false;
                    }
                }else{
                    allFull = false;
                }
            }
            if(allFull){
                return false;
            }
        }
        return enabled;
    }
ConsumePower.requestedPower (ConsumePower.java:57-63):
    public float requestedPower(Building entity){
        return buffered ?
            (1f - entity.power.status) * capacity :
            usage * (entity.shouldConsume() ? 1f : 0f);
    }
PowerGraph.getPowerNeeded() (PowerGraph.java:105-115) sums only
consumers whose shouldConsumePower is set, at
`consumePower.requestedPower(consumer) * consumer.delta()`.
ConsumeItems.efficiency (ConsumeItems.java:51-54) is 1 only when the
item module holds the stack (else 0); ConsumeLiquid.efficiency
(ConsumeLiquid.java:41-47) is the held liquid over the per-edelta
requirement, capped at 1. SeparatorBuild.shouldConsume()
(Separator.java:99-108) consumes while the held items minus the
consume inputs fit itemCapacity.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
POWER_GRAPH = 'core/src/mindustry/world/blocks/power/PowerGraph.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
GENERIC_CRAFTER = 'core/src/mindustry/world/blocks/production/GenericCrafter.java'
CONSUME_ITEMS = 'core/src/mindustry/world/consumers/ConsumeItems.java'
CONSUME_LIQUID = 'core/src/mindustry/world/consumers/ConsumeLiquid.java'
SEPARATOR = 'core/src/mindustry/world/blocks/production/Separator.java'
HELPER_OWNER = 'SourcePlacedPowerGraphState.source_consumer_should_consume_for_cell_state'
DRIVER_OWNER = 'SourceFactoryRuntimeState.source_factory_update_power_graph_state'
PROOF = '/root/C06SourceExhaustionProof'
TESTS = ['test_c06_source_exhaustion_output_full_registration', 'test_all_c06_source_exhaustion_output_full_input_evidence_is_exact', 'test_stamp_reads_factory_should_consume_and_first_pass_flag', 'test_reference_graph_and_actual_c06_source_exhaustion_output_full']
DEFERRED = [
    'The unit-factory frames keep the N2125 enabled-only stamp: their per-class shouldConsume bodies (UnitFactory.java:445-448, Reconstructor.java:367-369, UnitAssembler.java:389-391, N2124) are plan-gated, and wiring them to the power stamp needs a unit-factory proof setup of its own.',
    'PowerGraph.getBatteryStored gates on battery.enabled (PowerGraph.java:118-126), but the battery has no tick frame in the port, so its live enabled flag cannot be read yet; the battery dict keeps its static enabled value.',
    'A disabled conveyor reads efficiency 0 in Java (BuildingComp.java:1943-1948) but the port carries no per-belt efficiency yet, so a disabled belt still advances.',
    'ConsumeItemDynamic.trigger at unit completion (ConsumeItemDynamic.java:53-56).',
    'UnitAssembler plan dynamics (UnitAssembler.java:158-160).',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    '            if(cons != block.consPower && result <= 0.0000001f){',
    '                shouldConsumePower = false;',
    '                    if(items.get(output.item) + output.amount > itemCapacity){',
    '                    if(liquids.get(output.liquid) >= liquidCapacity - 0.001f){',
    '                if(allFull){',
    '            return enabled;',
    '            usage * (entity.shouldConsume() ? 1f : 0f);',
    '            if(consumer.shouldConsumePower){',
    '                powerNeeded += consumePower.requestedPower(consumer) * consumer.delta();',
    '        return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;',
    '        return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);',
    '            return total < itemCapacity && enabled;',
]

# The helper's own symbols (N2125) are the ones whose meaning this
# slice extends; shared symbol listings across slices are the
# established pattern (753 symbols appear in more than one slice).
HELPER_SYMBOLS = [
    'source_consumer_should_consume_for_cell_state_input.cell',
    'source_consumer_should_consume_for_cell_state_input.game',
    'source_consumer_should_consume_for_cell_state_result.found',
    'source_consumer_should_consume_for_cell_state_result.reason',
    'source_consumer_should_consume_for_cell_state_result.shouldConsumePower',
    'source_consumer_should_consume_for_cell_state_result.should_consume',
]


def main():
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']

    # The helper (N2125) gains the factory branches: deepcopy the
    # existing contract and extend its rule, keeping the N2125
    # source_slice and the same params/return keys (the signature
    # does not change — the stamp only reads more live frame state
    # for factory-family frames).
    helper_contract = copy.deepcopy(contracts[HELPER_OWNER])
    helper_contract['tests'] = sorted(set(helper_contract['tests']) | set(TESTS))
    helper_contract['rule'] = 'Source-backed power-graph consumer live should-consume value; the helper reads a placed building\'s live frame enabled flag, so the grouped consumer dict carries what ConsumePower.requestedPower() and PowerGraph.getPowerNeeded() read. For a factory-family frame the should_consume value is the family\'s per-class shouldConsume() body — the GenericCrafter output-full gate (an output item over itemCapacity, or every output liquid full) or the adjacent family\'s own body — and shouldConsumePower is the frame\'s live updateConsumption first-pass flag, false when a non-power consumer fails (source exhaustion) and true when cheating or no consumer fails.'
    source_symbols.upsert_source_api_contract(GODOT, HELPER_OWNER, helper_contract)

    # The live-loop driver (N2077) gains the same stamp sentence:
    # deepcopy the existing contract and extend its rule, keeping
    # the N2077 source_slice and the same params/return keys.
    driver_contract = copy.deepcopy(contracts[DRIVER_OWNER])
    driver_contract['tests'] = sorted(set(driver_contract['tests']) | set(TESTS))
    driver_contract['rule'] = 'Source-backed live-loop power graph update; each frame the placed graph runs PowerGraph.update(). Each grouped consumer dict is stamped with its building\'s live cheating value (TeamComp.cheating() from the live rules) and with its live should_consume / shouldConsumePower values (BuildingComp.shouldConsume() from the frame enabled flag) before the update runs, so the cheat gate fires when the first consumer\'s team cheats and a disabled building requests no power. For a factory-family frame the stamp is the family\'s per-class shouldConsume() body (the output-full gate) and the frame\'s live updateConsumption first-pass should_consume_power flag (false when a non-power consumer fails), so a starved or output-full factory stops drawing power.'
    source_symbols.upsert_source_api_contract(GODOT, DRIVER_OWNER, driver_contract)

    # One slice row: the live-loop driver is the primary owner; the
    # helper shares the slice (its symbols carry their own owner).
    source_symbols.upsert_source_slice(GODOT, 'N2127', dict(status='done', java_source=POWER_GRAPH, java_class='mindustry.world.blocks.power.PowerGraph', java_method='update', godot_owner=DRIVER_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(HELPER_SYMBOLS), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {HELPER_OWNER, DRIVER_OWNER}
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
