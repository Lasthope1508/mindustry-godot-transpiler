"""Register the UnitAssembler payload trigger at completion (N2130).

N2129 modeled the assembler's payload module (UnitAssemblerBuild.blocks,
a PayloadSeq) and the ConsumePayloadDynamic efficiency read over it, but
the stacks never left: Java removes them only at unit completion, through
BuildingComp.consume() (BuildingComp.java:1911-1915), which triggers every
consumer, and the payload row removes Math.round(amount * multiplier) per
requirement stack through ConsumePayloadDynamic.trigger
(ConsumePayloadDynamic.java:34-39): `float mult =
multiplier.get(build); for(PayloadStack stack :
payloads.get(build)){ build.getPayloads().remove(stack.item,
Math.round(stack.amount * mult)); }` -- the rows are plan().requirements
(UnitAssembler.java:158, `consume(consPayload = new
ConsumePayloadDynamic((UnitAssemblerBuild build) ->
build.plan().requirements));`). PayloadSeq.remove(block, amount)
(PayloadSeq.java:40-42) is `add(block, -amount)` -- no clamp: a short
stack goes negative before the clear (unlike ItemModule.remove in N2128,
which clamps), so the port records the requested removal per stack.
UnitAssemblerBuild.spawned() (UnitAssembler.java:543-571) calls consume()
first (line 546), then creates the unit, then `progress = 0f; ...
blocks.clear();` (line 571) at the end; PayloadSeq.clear()
(PayloadSeq.java:61-64) is `payloads.clear(); total = 0;`. The
multiplier is the family's Rules.unitCost callback
(UnitAssembler.java:175, `consumeBuilder.each(c -> c.multiplier = b ->
state.rules.unitCost(b.team))`, the N2097 callback); the Consume
default is `b -> 1f` (Consume.java:18).

N2130 is that trigger body: SourceUnitFactoryBuildState.
source_unit_factory_assembler_payload_trigger_state, the payload twin of
the N2128 consume() trigger. It removes Math.round(amount * multiplier)
per requirement stack from the frame's blocks dict (no clamp -- mirror
PayloadSeq.remove), records it in `removed`, then clears the module
unconditionally (spawned() always clears, including extra blocks beyond
the plan and short/empty modules). The function is pure and is NOT wired
into the tick driver or the shouldConsume gate -- the tick never calls it;
the live production wiring (progress advance + the call at completion)
is a later slice.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
CONSUME_PAYLOAD_DYNAMIC = 'core/src/mindustry/world/consumers/ConsumePayloadDynamic.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
PAYLOAD_SEQ = 'core/src/mindustry/type/PayloadSeq.java'
PROOF = '/root/C06UnitAssemblerPayloadTriggerProof'
TESTS = ['test_c06_unit_assembler_payload_trigger_registration', 'test_all_c06_unit_assembler_payload_trigger_input_evidence_is_exact', 'test_assembler_payload_trigger_removes_plan_stacks_then_clears', 'test_reference_graph_and_actual_c06_unit_assembler_payload_trigger']
DEFERRED = [
    'Payload intake: yeetPayload (UnitAssembler.java:688-690, blocks.add(payload.content(), 1)) and acceptPayload/acceptUnitPayload (UnitAssembler.java:711-727, blocks.get(payload.content()) < Mathf.round(b.amount * state.rules.unitCost(team))) -- the slice that fills the module.',
    'Wiring the payload efficiency into the shouldConsume gate: the gate keeps reading the frame payload_efficiency default (1.0, N2124) until then, and the N2124 proof assembler-default/live keys (empty blocks read 1.0 there) update with the wiring.',
    'checkTier from the module tiers (UnitAssembler.java:360-376, modules sorted by tier, a tier gap stops the climb) -- plan() clamping is already in the port (N2124).',
    'Live production wiring: the tick driver advances no progress and calls no spawned() yet -- UnitFactory progress (UnitFactory.java:401-403), Reconstructor progress (Reconstructor.java:330-348) and UnitAssembler spawned() (UnitAssembler.java:544-571) are the production slice; this slice is the trigger body it calls at completion.',
    'The unit-factory frames keep the N2125 enabled-only power stamp: their per-class shouldConsume bodies (N2124) are plan-gated, and wiring them to the power stamp needs a unit-factory proof setup of its own.',
    'PowerGraph.getBatteryStored gates on battery.enabled (PowerGraph.java:118-126), but the battery has no tick frame in the port, so its live enabled flag cannot be read yet; the battery dict keeps its static enabled value.',
    'A disabled conveyor reads efficiency 0 in Java (BuildingComp.java:1943-1948) but the port carries no per-belt efficiency yet, so a disabled belt still advances.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public void trigger(Building build){',
    'float mult = multiplier.get(build);',
    'for(PayloadStack stack : payloads.get(build)){',
    'build.getPayloads().remove(stack.item, Math.round(stack.amount * mult));',
    'public void consume(){',
    'for(Consume cons : block.consumers){',
    'cons.trigger(self());',
    'public Floatf<Building> multiplier = b -> 1f;',
    'consumeBuilder.each(c -> c.multiplier = b -> state.rules.unitCost(b.team));',
    'consume(consPayload = new ConsumePayloadDynamic((UnitAssemblerBuild build) -> build.plan().requirements));',
    'public void spawned(){',
    'blocks.clear();',
    'public void remove(UnlockableContent block, int amount){',
    'add(block, -amount);',
    'public void clear(){',
    'payloads.clear();',
    'total = 0;',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=UNIT_ASSEMBLER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2130_trigger_inputs = {
        'frame': f('Dictionary', 'public PayloadSeq blocks = new PayloadSeq();', 'The assembler frame; its blocks dict is the building payload module (UnitAssemblerBuild.blocks, a PayloadSeq), missing key reads as an empty module.'),
        'plan': f('Dictionary', 'consume(consPayload = new ConsumePayloadDynamic((UnitAssemblerBuild build) -> build.plan().requirements));', 'The current tier plan (AssemblerUnitPlan); its requirements are the ConsumePayloadDynamic rows the trigger removes.'),
    }
    n2130_trigger_outputs = {
        'triggered': f('int', 'for(PayloadStack stack : payloads.get(build)){', 'How many requirement stacks the trigger removed at unit completion.', source=CONSUME_PAYLOAD_DYNAMIC),
        'removed': f('Dictionary', 'build.getPayloads().remove(stack.item, Math.round(stack.amount * mult));', 'What each requirement stack removed: Math.round(amount * multiplier), no clamp (PayloadSeq.remove is add(block, -amount)).', source=CONSUME_PAYLOAD_DYNAMIC),
        'cleared': f('bool', 'blocks.clear();', 'Whether spawned() cleared the payload module at the end (always true).', source=UNIT_ASSEMBLER),
        'blocks': f('Dictionary', 'public void clear(){', 'The building payload module snapshot after the clear: always empty.', source=PAYLOAD_SEQ),
        'total': f('int', 'total = 0;', 'PayloadSeq.total() after the clear: always 0.', source=PAYLOAD_SEQ),
    }

    entries = [
        ('N2130', 'SourceUnitFactoryBuildState.source_unit_factory_assembler_payload_trigger_state', 'source_unit_factory_assembler_payload_trigger_state', UNIT_ASSEMBLER, 'mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild', 'UnitAssemblerBuild.spawned(); BuildingComp.consume(); ConsumePayloadDynamic.trigger(Building)', n2130_trigger_inputs, n2130_trigger_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed UnitAssembler payload trigger at unit completion + spawned() blocks.clear().'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed UnitAssembler payload trigger at unit completion + spawned() blocks.clear().'))
        all_names.extend(names)

    by_slice['N2130'] = sorted(all_names)
    source_symbols.upsert_source_slice(GODOT, 'N2130', dict(status='done', java_source=UNIT_ASSEMBLER, java_class='mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild', java_method='UnitAssemblerBuild.spawned(); BuildingComp.consume(); ConsumePayloadDynamic.trigger(Building)', godot_owner='SourceUnitFactoryBuildState.source_unit_factory_assembler_payload_trigger_state', exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
