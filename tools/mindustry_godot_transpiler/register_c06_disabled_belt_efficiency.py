"""Register the disabled-belt efficiency half (N2135).

The disabled-belt efficiency half, the next item on the N2134 "Next"
list (and the N2134 deferred line: "disabled-belt efficiency half
(BuildingComp.java:1943-1948 -- a disabled conveyor reads efficiency
0 in Java, the port carries no per-belt efficiency yet)"). A conveyor
carries no consumers, so updateConsumption takes the first branch
(BuildingComp.java:1943-1948): `potentialEfficiency = enabled &&
productionValid() ? 1f : 0f; efficiency = optionalEfficiency =
shouldConsume() ? potentialEfficiency : 0f;` -- efficiency 1 when
enabled, 0 when disabled. The belt moves by `float moved = speed *
edelta();` (Conveyor.java:266), and `edelta()` is `efficiency *
delta()` (BuildingComp.java:1927-1929). The port's
SourceConveyorRuntimeState.source_conveyor_advance_state hardcoded
efficiency 1 -- `var moved := speed * delta * time_scale` -- and
carried an explicit deferred comment saying so. A disabled belt
therefore still advanced in the port. This slice gives the advance
step its own per-belt efficiency input (trailing optional param,
default 1.0, so the enabled belt and every existing caller are
unaffected).

No live-path wiring in this slice: the factory advance caller passes
no efficiency (default 1.0) -- there is no per-sprite `enabled` seam
in the factory path, so wiring the live loop to freeze a disabled
belt needs a sprite-enabled seam of its own (deferred follow-up).
The slice delivers the per-belt efficiency in the pure advance
function + the Godot proof, same scope shape as the N2134 stamp.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
CONVEYOR = 'core/src/mindustry/world/blocks/distribution/Conveyor.java'
ADVANCE_OWNER = 'SourceConveyorRuntimeState.source_conveyor_advance_state'
PROOF = '/root/C06DisabledBeltEfficiencyProof'
TESTS = ['test_c06_disabled_belt_efficiency_registration', 'test_all_c06_disabled_belt_efficiency_input_evidence_is_exact', 'test_disabled_belt_efficiency_reads_efficiency', 'test_reference_graph_and_actual_c06_disabled_belt_efficiency']
DEFERRED = [
    'The live-loop belt enabled gate: simulate_factory still advances a disabled belt\'s queue (it passes no efficiency, and reads no per-sprite enabled). In Java a disabled conveyor\'s updateTile never runs (noUpdateDisabled = false, Conveyor.java:52). Wiring the live loop to skip/freeze disabled belts needs a sprite-enabled seam (SourcePlacedBlockState has none) -- a follow-up slice, not this one.',
    'The unit-factory frames keep the N2125 enabled-only power stamp: their per-class shouldConsume bodies (N2124) are plan-gated, and wiring them to the power stamp needs a unit-factory proof setup of its own.',
    'Live production wiring: the tick driver advances no progress and calls no spawned() yet -- UnitFactory progress (UnitFactory.java:401-403), Reconstructor progress (Reconstructor.java:330-348) and UnitAssembler spawned() (UnitAssembler.java:544-571) are the production slice; the intake call site (moveInPayload() && !wasOccupied, UnitAssembler.java:500-503) is the wiring that calls the intake slice when a payload arrives.',
    'Units.canCreate live evaluation (Units.java:115-117) needs live per-type unit counts and the unit cap (the unit-group system, C07); the assembler branch keeps reading frame["can_create"], default true, until then.',
    'lastTier tracking and the progress reset on a tier change (UnitAssembler.java:441-447, if(lastTier != currentTier){ if(lastTier >= 0f){ progress = 0f; } lastTier = lastTier == -2 ? -1 : currentTier; }) -- belongs to the live production/tick wiring, not the disabled-belt efficiency half.',
    'The live-loop module link/unlink call sites: updateModules/removeModule are called from UnitAssemblerModuleBuild link/unlink (UnitAssemblerModule.java:80-83) -- the port has no live module-linking frame event yet, so the frame modules list is an input, not something the tick maintains.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'float moved = speed * edelta();',
    'public float edelta(){',
    'return efficiency * delta();',
    'public void updateConsumption(){',
    'if(!block.hasConsumers || cheating()){',
    'potentialEfficiency = enabled && productionValid() ? 1f : 0f;',
    'efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;',
    '//disabled -> nothing works',
    'if(!enabled){',
    'potentialEfficiency = efficiency = optionalEfficiency = 0f;',
    'shouldConsumePower = false;',
    'noUpdateDisabled = false;',
]


def main():
    # One new symbol: the per-belt efficiency input of the advance step.
    efficiency = backed('float', CONVEYOR, 'float moved = speed * edelta();', 'Per-belt efficiency (Building.efficiency, BuildingComp.java:1943-1948): 1 when the conveyor is enabled, 0 when disabled, so a disabled belt moves by speed * edelta() = 0 and stays frozen; a conveyor carries no consumers, so updateConsumption sets efficiency to 1 only when enabled and productionValid. Default 1.0 in the advance step, so the enabled belt and every existing caller are unaffected.')
    efficiency['used_by'] = [ADVANCE_OWNER]
    symbols = {
        'source_conveyor_advance_state_input.efficiency': dict(status='source-backed', godot_owner=ADVANCE_OWNER, godot_symbol='source_conveyor_advance_state_input.efficiency', java_source=CONVEYOR, java_method='ConveyorBuild.updateTile()', java_expr='float moved = speed * edelta();', rule=efficiency['rule'], tests=TESTS, runtime_proof=PROOF),
    }

    # The efficiency key joins the EXISTING advance input schema
    # (11 keys -> 12) in place, keeping the N2069 source_slice and
    # owner; upsert replaces the whole schema, so deepcopy first.
    schemas = source_symbols.load_source_state_schema(GODOT)['schemas']
    schema = copy.deepcopy(schemas['source_conveyor_advance_state_input'])
    schema['keys']['efficiency'] = efficiency
    source_symbols.upsert_source_state_schema(GODOT, 'source_conveyor_advance_state_input', schema)

    # The efficiency param joins the EXISTING advance contract params
    # (trailing, after clog_heat_before) in place, keeping the N2069
    # source_slice; the return keys do not change.
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    advance_contract = copy.deepcopy(contracts[ADVANCE_OWNER])
    advance_contract['params'] = list(advance_contract['params']) + [dict(name='efficiency', type='float', schema='source_conveyor_advance_state_input.efficiency')]
    advance_contract['tests'] = sorted(set(advance_contract['tests']) | set(TESTS))
    advance_contract['rule'] = 'Source-backed conveyor belt advance; the belt moves its items and hands the front item to the next belt or the core. Items move by speed * edelta() (Conveyor.java:266): the advance takes the building\'s live per-building timeScale (decayed each tick by BuildingComp.update, BuildingComp.java:2265-2267), so a boosted belt moves faster until its duration expires; it also takes the belt\'s own efficiency (BuildingComp.java:1943-1948, 1 when enabled, 0 when disabled), so a disabled belt moves 0 and stays frozen.'
    source_symbols.upsert_source_api_contract(GODOT, ADVANCE_OWNER, advance_contract)

    source_symbols.upsert_source_slice(GODOT, 'N2135', dict(status='done', java_source=CONVEYOR, java_class='mindustry.world.blocks.distribution.Conveyor.ConveyorBuild', java_method='ConveyorBuild.updateTile()', godot_owner=ADVANCE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=['source_conveyor_advance_state_input.efficiency'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {ADVANCE_OWNER}
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
