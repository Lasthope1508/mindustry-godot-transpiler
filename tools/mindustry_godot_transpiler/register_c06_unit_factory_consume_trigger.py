"""Register the unit-factory consume() trigger at unit completion (N2128).

N2120 bound one RuntimeConsumer actor per consumeItem/consumeLiquid
row plus one per requirement of the frame's current plan, and the
tick runs those actors through updateConsumption's first and second
passes every tick -- but ConsumeItems has no update body
(Consume.update is empty, Consume.java:52), so the item stacks
never left: a factory could produce forever on the same silicon
and lead. Java removes them only at unit completion, through
BuildingComp.consume() (BuildingComp.java:1911-1915), which
triggers every consumer, and only the item rows remove anything,
through ConsumeItems.trigger (ConsumeItems.java:45-48) and
ConsumeItemDynamic.trigger (ConsumeItemDynamic.java:53-56), each
removing Math.round(amount * multiplier) clamped at what the
module holds (ItemModule.java:258-259). The completion sites are:

- UnitFactoryBuild.updateTile() (UnitFactory.java:420-436):
  `if(progress >= plan.time){ progress %= 1f; ... payload = new
  UnitPayload(unit); ... consume(); }` -- the plan's
  ConsumeItemDynamic stacks leave then.
- ReconstructorBuild.updateTile() (Reconstructor.java:340-349):
  `if(progress >= constructTime){ payload.unit =
  upgrade(...); ... progress %= 1f; ... consume(); }` -- the
  static consumeItem stacks leave then.
- UnitAssemblerBuild.spawned() (UnitAssembler.java:544-571):
  `consume();` first, then the unit is created and
  `blocks.clear();`.

N2128 is the trigger body those sites call:
SourceUnitFactoryBuildState.source_unit_factory_consume_state,
the unit-factory twin of SourceFactoryBuildState.
source_factory_consume_state (N2117): item rows trigger through
their bound actors, liquid rows are skipped (ConsumeLiquid has
no trigger override; its update drains per tick), and the
assembler payload trigger is deferred -- ConsumePayloadDynamic
over plan().requirements (UnitAssembler.java:158) removes payload
stacks from the building's payload module, which the port does
not model yet (the plan-dynamics slice). The tick driver never
calls this function: the trigger runs only at unit completion,
and the live production wiring (progress advance + the call at
completion) is a later slice.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
CONSUME_ITEMS = 'core/src/mindustry/world/consumers/ConsumeItems.java'
CONSUME_ITEM_DYNAMIC = 'core/src/mindustry/world/consumers/ConsumeItemDynamic.java'
CONSUME_LIQUID = 'core/src/mindustry/world/consumers/ConsumeLiquid.java'
UNIT_FACTORY = 'core/src/mindustry/world/blocks/units/UnitFactory.java'
RECONSTRUCTOR = 'core/src/mindustry/world/blocks/units/Reconstructor.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
ITEM_MODULE = 'core/src/mindustry/world/modules/ItemModule.java'
PROOF = '/root/C06UnitFactoryConsumeProof'
TESTS = ['test_c06_unit_factory_consume_trigger_registration', 'test_all_c06_unit_factory_consume_trigger_input_evidence_is_exact', 'test_consume_trigger_removes_only_item_rows', 'test_reference_graph_and_actual_c06_unit_factory_consume_trigger']
DEFERRED = [
    'UnitAssembler plan dynamics (UnitAssembler.java:158-160): ConsumePayloadDynamic over plan().requirements removes payload stacks from the building\'s payload module (UnitAssemblerBuild.blocks), which the port does not model yet; ConsumeItemDynamic over plan().itemReq (empty in vanilla) and ConsumeLiquidsDynamic over plan().liquidReq (its trigger is empty; its update drains per tick).',
    'Live production wiring: the tick driver advances no progress and calls no consume yet -- UnitFactory progress (UnitFactory.java:401-403), Reconstructor progress (Reconstructor.java:330-348) and UnitAssembler spawned() (UnitAssembler.java:544-571) are the production slice; this slice is the trigger body it calls at completion.',
    'The unit-factory frames keep the N2125 enabled-only power stamp: their per-class shouldConsume bodies (N2124) are plan-gated, and wiring them to the power stamp needs a unit-factory proof setup of its own.',
    'PowerGraph.getBatteryStored gates on battery.enabled (PowerGraph.java:118-126), but the battery has no tick frame in the port, so its live enabled flag cannot be read yet; the battery dict keeps its static enabled value.',
    'A disabled conveyor reads efficiency 0 in Java (BuildingComp.java:1943-1948) but the port carries no per-belt efficiency yet, so a disabled belt still advances.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public void consume(){',
    'for(Consume cons : block.consumers){',
    'cons.trigger(self());',
    'public void trigger(Building build){}',
    'build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));',
    'for(ItemStack stack : items.get(build)){',
    'amount = Math.min(amount, items[item.id]);',
    'payload = new UnitPayload(unit);',
    'progress %= 1f;',
    'if(progress >= plan.time){',
    'if(progress >= constructTime){',
    'public void spawned(){',
    'blocks.clear();',
    'public Floatf<Building> multiplier = b -> 1f;',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=BUILDING_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2128_consume_inputs = {
        'frame': f('Dictionary', 'public void consume(){', 'The unit-factory frame (the port Building state) whose item module the triggers remove from.'),
        'consumers': f('Array', 'for(Consume cons : block.consumers){', 'The bound RuntimeConsumer actors, one per consume row (N2120).'),
        'rows': f('Array', 'cons.trigger(self());', 'The consume rows the actors were bound from; liquid rows are skipped, only item rows trigger.'),
    }
    n2128_consume_outputs = {
        'triggered': f('int', 'cons.trigger(self());', 'How many item consumers triggered at unit completion.'),
        'removed': f('Dictionary', 'build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', 'What each item row removed: Math.round(amount * multiplier), clamped at what the module holds.', source=CONSUME_ITEM_DYNAMIC),
    }

    entries = [
        ('N2128', 'SourceUnitFactoryBuildState.source_unit_factory_consume_state', 'source_unit_factory_consume_state', BUILDING_COMP, 'mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild', 'UnitFactoryBuild.updateTile(); BuildingComp.consume(); ConsumeItemDynamic.trigger(Building)', n2128_consume_inputs, n2128_consume_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed unit-factory consume() trigger at unit completion.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed unit-factory consume() trigger at unit completion.'))
        all_names.extend(names)

    by_slice['N2128'] = sorted(all_names)
    source_symbols.upsert_source_slice(GODOT, 'N2128', dict(status='done', java_source=UNIT_FACTORY, java_class='mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild', java_method='UnitFactoryBuild.updateTile(); BuildingComp.consume(); ConsumeItemDynamic.trigger(Building)', godot_owner='SourceUnitFactoryBuildState.source_unit_factory_consume_state', exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
