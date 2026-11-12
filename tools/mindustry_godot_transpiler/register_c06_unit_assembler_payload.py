"""Register the UnitAssembler payload module and its efficiency (N2129).

N2124 wired the assembler's per-class shouldConsume() body but left
its payload conjunct on a permissive frame default: consPayload
efficiency (ConsumePayloadDynamic.java:24-32) needs the building's
payload module (the payload stacks held), which the port did not
model. Java holds them in UnitAssemblerBuild.blocks
(UnitAssembler.java:323, `public PayloadSeq blocks = new
PayloadSeq();`), returned by getPayloads() (UnitAssembler.java:717-719,
`return blocks;`): an ObjectIntMap<UnlockableContent> of held
payload counts plus its total (PayloadSeq.java). The efficiency
reads `float mult = multiplier.get(build); for(PayloadStack stack :
payloads.get(build)){ if(!build.getPayloads().contains(stack.item,
Math.round(stack.amount * mult))){ return 0f; } } return 1f;` --
binary 1/0, with PayloadSeq.contains(block, amount) = get(block)
>= amount (PayloadSeq.java:71-73). The multiplier is the family's
Rules.unitCost callback (UnitAssembler.java:175,
`consumeBuilder.each(c -> c.multiplier = b ->
state.rules.unitCost(b.team))`), the N2097 callback, not the
Consume default (Consume.java:18, `b -> 1f`).

N2129 is that module and that read: the frame's `blocks` dict
(content name to held count, missing key reads as an empty module
-- Java constructs the field empty, never null) plus
SourceUnitFactoryBuildState.source_unit_factory_assembler_payload_state,
which returns the efficiency, a snapshot of the module and its
total (PayloadSeq.total()). The plan is the current tier's
AssemblerUnitPlan (vanquish: stell 4 + tungsten-wall-large 10;
conquer: locus 6 + carbide-wall-large 20). The function is pure
and is NOT wired into the shouldConsume gate yet -- the gate keeps
reading the frame's payload_efficiency default (1.0, N2124) until
the wiring slice lands it with the blocks the payload intake
fills, like the N2128 trigger before the production wiring.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
CONSUME_PAYLOAD_DYNAMIC = 'core/src/mindustry/world/consumers/ConsumePayloadDynamic.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
PAYLOAD_SEQ = 'core/src/mindustry/type/PayloadSeq.java'
PAYLOAD_STACK = 'core/src/mindustry/type/PayloadStack.java'
PROOF = '/root/C06UnitAssemblerPayloadProof'
TESTS = ['test_c06_unit_assembler_payload_registration', 'test_all_c06_unit_assembler_payload_input_evidence_is_exact', 'test_assembler_payload_reads_blocks_not_the_gate_default', 'test_reference_graph_and_actual_c06_unit_assembler_payload']
DEFERRED = [
    'ConsumePayloadDynamic.trigger at unit completion (ConsumePayloadDynamic.java:34-39, build.getPayloads().remove(stack.item, Math.round(stack.amount * mult))) plus spawned() blocks.clear() (UnitAssembler.java:544-571) -- the production slice that calls consume() at completion.',
    'Payload intake: yeetPayload (UnitAssembler.java:688-690, blocks.add(payload.content(), 1)) and acceptPayload/acceptUnitPayload (UnitAssembler.java:711-727, blocks.get(payload.content()) < Mathf.round(b.amount * state.rules.unitCost(team))) -- the slice that fills the module.',
    'Wiring the payload efficiency into the shouldConsume gate: the gate keeps reading the frame payload_efficiency default (1.0, N2124) until then, and the N2124 proof assembler-default/live keys (empty blocks read 1.0 there) update with the wiring.',
    'checkTier from the module tiers (UnitAssembler.java:360-376, modules sorted by tier, a tier gap stops the climb) -- plan() clamping is already in the port (N2124).',
    'Live production wiring: the tick driver advances no progress and calls no spawned() yet -- UnitFactory progress (UnitFactory.java:401-403), Reconstructor progress (Reconstructor.java:330-348) and UnitAssembler spawned() (UnitAssembler.java:544-571) are the production slice.',
    'The unit-factory frames keep the N2125 enabled-only power stamp: their per-class shouldConsume bodies (N2124) are plan-gated, and wiring them to the power stamp needs a unit-factory proof setup of its own.',
    'PowerGraph.getBatteryStored gates on battery.enabled (PowerGraph.java:118-126), but the battery has no tick frame in the port, so its live enabled flag cannot be read yet; the battery dict keeps its static enabled value.',
    'A disabled conveyor reads efficiency 0 in Java (BuildingComp.java:1943-1948) but the port carries no per-belt efficiency yet, so a disabled belt still advances.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'consume(consPayload = new ConsumePayloadDynamic((UnitAssemblerBuild build) -> build.plan().requirements));',
    'consumeBuilder.each(c -> c.multiplier = b -> state.rules.unitCost(b.team));',
    'public PayloadSeq blocks = new PayloadSeq();',
    'public PayloadSeq getPayloads(){',
    'return blocks;',
    'blocks.add(payload.content(), 1);',
    'blocks.clear();',
    'if(!build.getPayloads().contains(stack.item, Math.round(stack.amount * mult))){',
    'float mult = multiplier.get(build);',
    'build.getPayloads().remove(stack.item, Math.round(stack.amount * mult));',
    'payloads.increment(block, amount);',
    'public int get(UnlockableContent block){',
    'return get(block) >= amount;',
    'public void clear(){',
    'public Floatf<Building> multiplier = b -> 1f;',
    'public Seq<PayloadStack> requirements;',
    'public int amount = 1;',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=UNIT_ASSEMBLER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2129_payload_inputs = {
        'frame': f('Dictionary', 'public PayloadSeq blocks = new PayloadSeq();', 'The assembler frame; its blocks dict is the building payload module (UnitAssemblerBuild.blocks, a PayloadSeq), missing key reads as an empty module.'),
        'plan': f('Dictionary', 'consume(consPayload = new ConsumePayloadDynamic((UnitAssemblerBuild build) -> build.plan().requirements));', 'The current tier plan (AssemblerUnitPlan); its requirements are what the payload efficiency reads.'),
    }
    n2129_payload_outputs = {
        'payload_efficiency': f('float', 'if(!build.getPayloads().contains(stack.item, Math.round(stack.amount * mult))){', 'ConsumePayloadDynamic.efficiency: 0.0 unless every requirement stack is held at Math.round(amount * multiplier), else 1.0.', source=CONSUME_PAYLOAD_DYNAMIC),
        'blocks': f('Dictionary', 'public PayloadSeq blocks = new PayloadSeq();', 'The building payload module snapshot: content name to held count, the port form of PayloadSeq payloads.', source=UNIT_ASSEMBLER),
        'total': f('int', 'public int total(){', 'PayloadSeq.total(): how many payloads the module holds in all.', source=PAYLOAD_SEQ),
    }

    entries = [
        ('N2129', 'SourceUnitFactoryBuildState.source_unit_factory_assembler_payload_state', 'source_unit_factory_assembler_payload_state', UNIT_ASSEMBLER, 'mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild', 'UnitAssemblerBuild.plan(); ConsumePayloadDynamic.efficiency(Building)', n2129_payload_inputs, n2129_payload_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed UnitAssembler payload module and ConsumePayloadDynamic efficiency.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed UnitAssembler payload module and ConsumePayloadDynamic efficiency.'))
        all_names.extend(names)

    by_slice['N2129'] = sorted(all_names)
    source_symbols.upsert_source_slice(GODOT, 'N2129', dict(status='done', java_source=UNIT_ASSEMBLER, java_class='mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild', java_method='UnitAssemblerBuild.plan(); ConsumePayloadDynamic.efficiency(Building)', godot_owner='SourceUnitFactoryBuildState.source_unit_factory_assembler_payload_state', exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
