"""Register the UnitAssembler payload intake (N2131).

N2129 modeled the assembler's payload module (UnitAssemblerBuild.blocks,
a PayloadSeq) and the ConsumePayloadDynamic efficiency read over it, and
N2130 modeled the trigger that empties it at unit completion -- but the
module never fills: Java fills it when a payload arrives, through
UnitAssemblerBuild.yeetPayload (UnitAssembler.java:688-690, `public void
yeetPayload(Payload payload){ var spawn = getUnitSpawn();
blocks.add(payload.content(), 1); ... }` -- the state half is the one
blocks.add; the Fx/sound lines are presentation, not state), called from
updateTile at UnitAssembler.java:500-503: `if(moveInPayload() &&
!wasOccupied){ yeetPayload(payload); payload = null; }`. The accept
gates decide whether the payload fits the current plan:
acceptUnitPayload (UnitAssembler.java:710-714, `public boolean
acceptUnitPayload(Unit unit){ var plan = plan(); return
plan.requirements.contains(b -> b.item == unit.type() &&
blocks.get(unit.type()) < Mathf.round(b.amount *
state.rules.unitCost(team))); }`) and acceptPayload
(UnitAssembler.java:722-727, `public boolean acceptPayload(Building
source, Payload payload){ var plan = plan(); return (this.payload ==
null || (source instanceof UnitAssemblerModuleBuild)) &&
plan.requirements.contains(b -> b.item == payload.content() &&
blocks.get(payload.content()) < Mathf.round(b.amount *
state.rules.unitCost(team)) - (source instanceof
UnitAssemblerModuleBuild && (this.payload != null &&
this.payload.contentEquals(payload)) ? 1 : 0)); }`). PayloadSeq.add
(PayloadSeq.java:33-38) is `public void add(UnlockableContent block,
int amount){ if(block == null) return; payloads.increment(block,
amount); total += amount; }` -- add(block) is add(block, 1); get(block)
is payloads.get(block) (missing reads 0). moveInPayload
(PayloadBlock.java:186-197) is the arrival check -- movement/visual;
the live-loop call site is a later wiring slice. The multiplier is the
family's Rules.unitCost callback (UnitAssembler.java:175,
`consumeBuilder.each(c -> c.multiplier = b ->
state.rules.unitCost(b.team))`, the N2097 callback); the Consume
default is `b -> 1f` (Consume.java:18).

N2131 is that intake body: SourceUnitFactoryBuildState.
source_unit_factory_assembler_payload_intake_state, the payload twin of
the N2130 trigger. It gates the incoming payload against the plan
requirements at the family's Rules.unitCost multiplier (the module
source counts one less when it is the same payload already held
in-transit), then adds one of its content to the frame's blocks dict
when accepted. The function is pure apart from the frame's own module
and is NOT wired into the tick driver or the shouldConsume gate -- the
intake runs only when a payload arrives; the live-loop call site
(moveInPayload() && !wasOccupied, UnitAssembler.java:500-503) is a
later wiring slice.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
PAYLOAD_BLOCK = 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java'
PAYLOAD_SEQ = 'core/src/mindustry/type/PayloadSeq.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
PROOF = '/root/C06UnitAssemblerPayloadIntakeProof'
TESTS = ['test_c06_unit_assembler_payload_intake_registration', 'test_all_c06_unit_assembler_payload_intake_input_evidence_is_exact', 'test_assembler_payload_intake_gates_then_adds_one', 'test_reference_graph_and_actual_c06_unit_assembler_payload_intake']
DEFERRED = [
    'Wiring the payload efficiency into the shouldConsume gate: the gate keeps reading the frame payload_efficiency default (1.0, N2124) until then, and the N2124 proof assembler-default/live keys (empty blocks read 1.0 there) update with the wiring.',
    'checkTier from the module tiers (UnitAssembler.java:360-376, modules sorted by tier, a tier gap stops the climb) -- plan() clamping is already in the port (N2124).',
    'Live production wiring: the tick driver advances no progress and calls no spawned() yet -- UnitFactory progress (UnitFactory.java:401-403), Reconstructor progress (Reconstructor.java:330-348) and UnitAssembler spawned() (UnitAssembler.java:544-571) are the production slice; the intake call site (moveInPayload() && !wasOccupied, UnitAssembler.java:500-503) is the wiring that calls this slice when a payload arrives.',
    'The unit-factory frames keep the N2125 enabled-only power stamp: their per-class shouldConsume bodies (N2124) are plan-gated, and wiring them to the power stamp needs a unit-factory proof setup of its own.',
    'PowerGraph.getBatteryStored gates on battery.enabled (PowerGraph.java:118-126), but the battery has no tick frame in the port, so its live enabled flag cannot be read yet; the battery dict keeps its static enabled value.',
    'A disabled conveyor reads efficiency 0 in Java (BuildingComp.java:1943-1948) but the port carries no per-belt efficiency yet, so a disabled belt still advances.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public void yeetPayload(Payload payload){',
    'blocks.add(payload.content(), 1);',
    'public boolean acceptUnitPayload(Unit unit){',
    'return plan.requirements.contains(b -> b.item == unit.type() &&',
    'blocks.get(unit.type()) < Mathf.round(b.amount * state.rules.unitCost(team)));',
    'public boolean acceptPayload(Building source, Payload payload){',
    'return (this.payload == null || (source instanceof UnitAssemblerModuleBuild)) &&',
    'plan.requirements.contains(b -> b.item == payload.content() &&',
    'blocks.get(payload.content()) < Mathf.round(b.amount * state.rules.unitCost(team)) -',
    '(source instanceof UnitAssemblerModuleBuild && (this.payload != null && this.payload.contentEquals(payload)) ? 1 : 0));',
    'public PayloadSeq blocks = new PayloadSeq();',
    'public PayloadSeq getPayloads(){',
    'return blocks;',
    'consumeBuilder.each(c -> c.multiplier = b -> state.rules.unitCost(b.team));',
    'if(moveInPayload() && !wasOccupied){',
    'yeetPayload(payload);',
    'consume(consPayload = new ConsumePayloadDynamic((UnitAssemblerBuild build) -> build.plan().requirements));',
    'public void add(UnlockableContent block, int amount){',
    'if(block == null) return;',
    'payloads.increment(block, amount);',
    'total += amount;',
    'public boolean moveInPayload(boolean rotate){',
    'public Floatf<Building> multiplier = b -> 1f;',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=UNIT_ASSEMBLER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2131_intake_inputs = {
        'frame': f('Dictionary', 'public PayloadSeq blocks = new PayloadSeq();', 'The assembler frame; its blocks dict is the building payload module (UnitAssemblerBuild.blocks, a PayloadSeq), missing key reads as an empty module, and its payload key is the currently held single payload content name or null.'),
        'plan': f('Dictionary', 'consume(consPayload = new ConsumePayloadDynamic((UnitAssemblerBuild build) -> build.plan().requirements));', 'The current tier plan (AssemblerUnitPlan); its requirements are the accept-gate rows the intake checks the incoming payload against.'),
        'payload': f('Dictionary', 'public void yeetPayload(Payload payload){', 'The incoming payload descriptor: content name, kind "block" or "unit" (which gate it goes through), and source_is_module mirroring source instanceof UnitAssemblerModuleBuild.'),
    }
    n2131_intake_outputs = {
        'accepted': f('bool', 'public boolean acceptPayload(Building source, Payload payload){', 'Whether the accept gate passed: (frame payload == null or source_is_module) and a plan requirement row has b.item == content and blocks.get(content) < round(amount * multiplier) minus the in-transit module adjustment; unit payloads go through acceptUnitPayload with no held-payload precondition and no adjustment.'),
        'added': f('int', 'blocks.add(payload.content(), 1);', 'How many of the payload content yeetPayload added to the module: 1 when accepted, 0 when rejected.'),
        'blocks': f('Dictionary', 'public void add(UnlockableContent block, int amount){', 'The building payload module snapshot after the intake: PayloadSeq.add increments the content count and the total.', source=PAYLOAD_SEQ),
        'total': f('int', 'total += amount;', 'PayloadSeq.total() after the intake: the module total, up by one when accepted.', source=PAYLOAD_SEQ),
    }

    entries = [
        ('N2131', 'SourceUnitFactoryBuildState.source_unit_factory_assembler_payload_intake_state', 'source_unit_factory_assembler_payload_intake_state', UNIT_ASSEMBLER, 'mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild', 'UnitAssemblerBuild.yeetPayload(Payload); UnitAssemblerBuild.acceptPayload(Building, Payload); UnitAssemblerBuild.acceptUnitPayload(Unit)', n2131_intake_inputs, n2131_intake_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed UnitAssembler payload intake: accept gates + yeetPayload blocks.add.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed UnitAssembler payload intake: accept gates + yeetPayload blocks.add.'))
        all_names.extend(names)

    by_slice['N2131'] = sorted(all_names)
    source_symbols.upsert_source_slice(GODOT, 'N2131', dict(status='done', java_source=UNIT_ASSEMBLER, java_class='mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild', java_method='UnitAssemblerBuild.yeetPayload(Payload); UnitAssemblerBuild.acceptPayload(Building, Payload); UnitAssemblerBuild.acceptUnitPayload(Unit)', godot_owner='SourceUnitFactoryBuildState.source_unit_factory_assembler_payload_intake_state', exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
