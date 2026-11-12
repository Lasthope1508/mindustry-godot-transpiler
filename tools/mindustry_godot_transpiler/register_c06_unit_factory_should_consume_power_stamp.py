"""Register the unit-factory shouldConsume wiring to the power stamp (N2136).

N2124 modeled the unit-factory family's per-class shouldConsume()
bodies (UnitFactoryBuild.shouldConsume(), UnitFactory.java:445-448:
`if(currentPlan == -1) return false; return enabled && payload ==
null && team.activateUnitFactories();`; ReconstructorBuild.
shouldConsume(), Reconstructor.java:367-369: `return constructing &&
enabled && team.activateUnitFactories();`; UnitAssemblerBuild.
shouldConsume(), UnitAssembler.java:389-391: `return enabled &&
!wasOccupied && Units.canCreate(team, plan().unit) &&
consPayload.efficiency(this) > 0 && consItem.efficiency(this) > 0 &&
team.activateUnitFactories();`) -- but the power stamp
(SourcePlacedPowerGraphState.source_consumer_should_consume_for_cell_state,
N2125) kept reading the unit-factory frame's `enabled` flag only, the
same enabled-only fallthrough the drill, turret and
continuous-liquid-turret families keep (their shouldConsume IS the
Building default, `return enabled;`, BuildingComp.java:755-757). A
plan-less ground factory, a payload-less reconstructor, or a
blocks-less assembler therefore kept charging power in the graph,
while ConsumePower.requestedPower (ConsumePower.java:56-60) charges
`usage * (entity.shouldConsume() ? 1f : 0f)`.

N2136 is that wiring: the stamp calls
source_unit_factory_should_consume_state (N2124) for the
unit-factory frame -- the same pattern as the factory and
adjacent-factory branches already in the stamp -- so the graph reads
the per-class body instead of the frame's enabled flag. No new
symbol, contract or schema: the wiring makes the already-registered
source_unit_factory_should_consume_state_result.should_consume
(N2124) live, and the N2125 proof's stamp keys grow by five (a
plan-less factory, a planned factory, a disabled factory, a
payload-less reconstructor, a blocks-less assembler).
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
UNIT_FACTORY = 'core/src/mindustry/world/blocks/units/UnitFactory.java'
PROOF = '/root/C06PowerShouldConsumeProof'
SYMBOL = 'source_unit_factory_should_consume_state_result.should_consume'
TESTS = ['test_c06_unit_factory_should_consume_power_stamp_registration', 'test_all_c06_unit_factory_should_consume_power_stamp_input_evidence_is_exact', 'test_unit_factory_should_consume_wires_into_power_stamp', 'test_reference_graph_and_actual_c06_unit_factory_should_consume_power_stamp']
DEFERRED = [
    'Live production wiring: the tick driver advances no progress and calls no spawned() yet -- UnitFactory progress (UnitFactory.java:401-403), Reconstructor progress (Reconstructor.java:330-348) and UnitAssembler spawned() (UnitAssembler.java:544-571) are the production slice; the intake call site (moveInPayload() && !wasOccupied, UnitAssembler.java:500-503) is the wiring that calls the intake slice when a payload arrives.',
    'Units.canCreate live evaluation (needs C07: live per-type unit counts and the unit cap); the assembler branch keeps reading frame["can_create"], default true, until then.',
    'lastTier tracking + progress reset on tier change (UnitAssembler.java:441-447) -- belongs to the live production/tick wiring.',
    'The live-loop module link/unlink call sites: updateModules/removeModule are called from UnitAssemblerModuleBuild link/unlink (UnitAssemblerModule.java:80-83) -- the port has no live module-linking frame event yet.',
    'Live-loop belt enabled gate (sprite-enabled seam) -- the pure advance function takes efficiency since N2135; the caller is the missing half.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public boolean shouldConsume(){',
    'if(currentPlan == -1) return false;',
    'return enabled && payload == null && team.activateUnitFactories();',
    'return constructing && enabled && team.activateUnitFactories();',
    'return enabled && !wasOccupied && Units.canCreate(team, plan().unit) && consPayload.efficiency(this) > 0 && consItem.efficiency(this) > 0 && team.activateUnitFactories();',
    'public float requestedPower(Building entity){',
    'usage * (entity.shouldConsume() ? 1f : 0f)',
    'return enabled;',
    'if(!enabled){',
    'potentialEfficiency = efficiency = optionalEfficiency = 0f;',
    'shouldConsumePower = false;',
    'if(cons != block.consPower && result <= 0.0000001f){',
]


def main():
    registry = source_symbols.load_source_symbol_registry(GODOT)
    existing = registry['symbols'][SYMBOL]
    # The wiring adds no new symbol: it makes the already-registered
    # shouldConsume result live in the power stamp. Only its rule
    # (the stamp now reads it instead of the frame's enabled flag)
    # and its tests (the N2136 module now covers it) change.
    symbols = {
        SYMBOL: dict(
            existing,
            rule='The per-class body for this frame and block: the UnitFactory plan/payload/activation gate, the Reconstructor constructing gate, or the UnitAssembler occupied/plan/can-create/payload/item gate. The power stamp reads it live through SourcePlacedPowerGraphState.source_consumer_should_consume_for_cell_state (N2136) instead of the frame\'s enabled flag.',
            tests=list(existing['tests']) + TESTS,
        ),
    }
    source_symbols.upsert_source_slice(GODOT, 'N2136', dict(status='done', java_source=UNIT_FACTORY, java_class='mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild', java_method='UnitFactoryBuild.shouldConsume()', godot_owner='SourcePlacedPowerGraphState.source_consumer_should_consume_for_cell_state', exact_exprs=EXACT_EXPRS, source_symbols=[SYMBOL], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
