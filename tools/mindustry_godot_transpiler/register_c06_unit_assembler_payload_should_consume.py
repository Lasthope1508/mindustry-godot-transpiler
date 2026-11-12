"""Register the shouldConsume payload-efficiency wiring (N2132).

N2129 modeled the assembler's payload module (UnitAssemblerBuild.blocks,
a PayloadSeq) and the ConsumePayloadDynamic efficiency read over it, and
N2131 modeled the intake that fills it -- but the shouldConsume gate
kept reading the frame's payload_efficiency default (1.0, N2124) instead
of the module. UnitAssemblerBuild.shouldConsume()
(UnitAssembler.java:389-391) is `return enabled && !wasOccupied &&
Units.canCreate(team, plan().unit) && consPayload.efficiency(this) > 0
&& consItem.efficiency(this) > 0 && team.activateUnitFactories();` --
the consPayload.efficiency(this) > 0 conjunct is the one this slice
wires. consPayload is declared at UnitAssembler.java:158,
`consume(consPayload = new ConsumePayloadDynamic((UnitAssemblerBuild
build) -> build.plan().requirements));`, and
ConsumePayloadDynamic.efficiency (ConsumePayloadDynamic.java:20-29) is
1.0 only when every requirement stack is held at Math.round(amount *
mult), 0.0 otherwise.

N2132 is that wiring: the assembler's shouldConsume branch calls
source_unit_factory_assembler_payload_state(frame, plan) (N2129) and
reads its payload_efficiency, so a blocks-less assembler reads 0.0 --
the Java behavior -- and a full one reads 1.0. No new symbol, contract
or schema: the wiring makes the already-registered
source_unit_factory_should_consume_state_result.payload_efficiency
(N2124) live, and the N2124 proof's assembler keys update with it
(a blocks-less assembler reads 0.0, a full one 1.0). Units.canCreate
stays deferred (frame can_create, default true, needs C07 live unit
counts).
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
CONSUME_PAYLOAD_DYNAMIC = 'core/src/mindustry/world/consumers/ConsumePayloadDynamic.java'
PROOF = '/root/C06UnitFactoryShouldConsumeProof'
SYMBOL = 'source_unit_factory_should_consume_state_result.payload_efficiency'
TESTS = ['test_c06_unit_assembler_payload_should_consume_registration', 'test_all_c06_unit_assembler_payload_should_consume_input_evidence_is_exact', 'test_assembler_payload_efficiency_gates_should_consume', 'test_reference_graph_and_actual_c06_unit_assembler_payload_should_consume']
DEFERRED = [
    'checkTier from the module tiers (UnitAssembler.java:360-376, modules sorted by tier, a tier gap stops the climb) -- plan() clamping is already in the port (N2124).',
    'Live production wiring: the tick driver advances no progress and calls no spawned() yet -- UnitFactory progress (UnitFactory.java:401-403), Reconstructor progress (Reconstructor.java:330-348) and UnitAssembler spawned() (UnitAssembler.java:544-571) are the production slice; the intake call site (moveInPayload() && !wasOccupied, UnitAssembler.java:500-503) is the wiring that calls the intake slice when a payload arrives.',
    'The unit-factory frames keep the N2125 enabled-only power stamp: their per-class shouldConsume bodies (N2124) are plan-gated, and wiring them to the power stamp needs a unit-factory proof setup of its own.',
    'PowerGraph.getBatteryStored gates on battery.enabled (PowerGraph.java:118-126), but the battery has no tick frame in the port, so its live enabled flag cannot be read yet; the battery dict keeps its static enabled value.',
    'A disabled conveyor reads efficiency 0 in Java (BuildingComp.java:1943-1948) but the port carries no per-belt efficiency yet, so a disabled belt still advances.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'return enabled && !wasOccupied && Units.canCreate(team, plan().unit) && consPayload.efficiency(this) > 0 && consItem.efficiency(this) > 0 && team.activateUnitFactories();',
    'consume(consPayload = new ConsumePayloadDynamic((UnitAssemblerBuild build) -> build.plan().requirements));',
    'public float efficiency(Building build){',
    'for(PayloadStack stack : payloads.get(build)){',
    'if(!build.getPayloads().contains(stack.item, Math.round(stack.amount * mult))){',
    'return 0f;',
    'return 1f;',
]


def main():
    registry = source_symbols.load_source_symbol_registry(GODOT)
    existing = registry['symbols'][SYMBOL]
    # The wiring adds no new symbol: it makes the already-registered
    # shouldConsume payload_efficiency result live. Only its rule (the
    # frame default is stale once the gate reads the module) and its
    # tests (the N2132 module now covers it) change.
    symbols = {
        SYMBOL: dict(
            existing,
            rule='The payload-consumer efficiency (ConsumePayloadDynamic.efficiency); the shouldConsume gate reads it live from the payload module through source_unit_factory_assembler_payload_state (N2132) instead of the frame default (1.0, N2124).',
            tests=list(existing['tests']) + TESTS,
        ),
    }
    source_symbols.upsert_source_slice(GODOT, 'N2132', dict(status='done', java_source=UNIT_ASSEMBLER, java_class='mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild', java_method='UnitAssemblerBuild.shouldConsume()', godot_owner='SourceUnitFactoryBuildState.source_unit_factory_should_consume_state', exact_exprs=EXACT_EXPRS, source_symbols=[SYMBOL], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    source_ssot.write_registered_json(GODOT, 'module_manifest', manifest)
    for canonical in ['slice_ledger', 'api_contracts', 'state_schema', 'registry', 'audit_report', 'module_manifest']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    main()
