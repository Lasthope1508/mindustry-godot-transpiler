"""Register the assembler drones_in_position live count (N2144).

The first deferred frame-input follow-up named in the N2138, N2139
and N2142 handoffs ("frame has no drones_in_position (default 0,
eff 0, no progress until a drone-position slice lands)"). N2139
wired the assembler production tick and its pure function takes
in_position_count as an input, but the tick driver read it from
frame.get("drones_in_position", 0) and the frame never stamped a
live value, so eff was 0 and no progress advanced. N2144 is that
live count: the AssemblerAI-only drone list counted through
inPosition() (UnitAssembler.java:516), exposed as one pure count
over the frame's units list so the driver stamps
frame["drones_in_position"] before the tick call.

Composition, not re-implementation: the tick function
(source_unit_assembler_production_tick_state, N2139) already
divides in_position_count by dronesCreated
(UnitAssembler.java:516); N2144 does not touch it. N2144 supplies
the missing count + driver stamp.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
ASSEMBLER_AI = 'core/src/mindustry/ai/types/AssemblerAI.java'
UNIT_TYPES = 'core/src/mindustry/content/UnitTypes.java'
PROOF = '/root/C07AssemblerDronesInPositionProof'
OWNER = 'SourceUnitFactoryBuildState.source_assembler_drones_in_position_state'
TESTS = ['test_c07_assembler_drones_in_position_registration', 'test_all_c07_assembler_drones_in_position_input_evidence_is_exact', 'test_assembler_drones_in_position_state', 'test_reference_graph_and_actual_c07_assembler_drones_in_position']
DEFERRED = [
    'spawn_occupied / spawn_visual_occupied frame inputs -- checkSolid(spawn, false/true) (UnitAssembler.java:675-680) needs tile solidity + a nearby-units query; the port\'s check_solid_state() is a no-arg stub returning false; waits for a collision/tile-solidity frame-data slice.',
    'allow_update frame input -- the canonical allow_update_state exists (SourceBuildingAccessState, BuildingComp.java:622-627) but the driver cannot supply its inputs: rules_state carries only unitCostMultiplier + teams (no env, limitMapArea, limits), and the catalog carries no block env/privileged flags; waits for a rules-state capture slice.',
    'Per-unit AssemblerAI.inPosition() evaluation from live unit pos/rotation/targetPos/targetAngle -- the count reads the recorded in_position flag; the units list carries no pos/rotation yet.',
    'moveOutPayload() modeling -- the assembler production tick still has no payload move-out.',
    'Net readUnits / whenSyncedUnits drone sync -- presentation/net, not state.',
    'Live UnitComp.add() / remove() lifecycle hooks (UnitComp.java:591-598, 603-604, 752) -- no live unit lifecycle in the port yet.',
    'PayloadComp add/remove count hooks (PayloadComp.java:101, 200) -- same, payload lifecycle not ported yet.',
    'Teams.updateTeamStats full multi-team rebuild (present/bosses/players/unitsByType/unitTree, Teams.java:182-245) -- N2141 rebuilds one team\'s counts only.',
    'Units.notifyUnitSpawn / spawn path, Call.unitCapDeath / Call.unitEnvDeath net calls -- presentation/net, not state.',
    'power.status live read for the other consumer families (drill, turret, factory, adjacent) -- the write-back stamps every consumer\'s frame generically, but only the unit-factory driver reads frame["power_status"] so far; the other families\' consumption paths still fold their own defaults until their slices land.',
    'C07-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'float eff = (units.count(u -> ((AssemblerAI)u.controller()).inPosition()) / (float)dronesCreated);',
    'units.removeAll(u -> !u.isAdded() || u.dead || !(u.controller() instanceof AssemblerAI));',
    'public boolean inPosition(){',
    'return unit.within(targetPos, 10f) && Angles.within(unit.rotation, targetAngle, 15f);',
    'public UnitType droneType = UnitTypes.assemblyDrone;',
    'assemblyDrone = new ErekirUnitType("assembly-drone"){{',
    'public int dronesCreated = 4;',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=UNIT_ASSEMBLER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2144_inputs = {
        'units': f('Array', 'units.removeAll(u -> !u.isAdded() || u.dead || !(u.controller() instanceof AssemblerAI));', 'The AssemblerAI-only drone list the count runs over (UnitAssembler.java:460): the frame\'s units list, filtered in Java to added, live, AssemblerAI-controlled units; the count reads the recorded in_position flag per entry.'),
    }
    n2144_outputs = {
        'drones_in_position': f('int', 'float eff = (units.count(u -> ((AssemblerAI)u.controller()).inPosition()) / (float)dronesCreated);', 'The count of AssemblerAI drones in position (UnitAssembler.java:516): the numerator the tick divides by dronesCreated for eff; 2 of 4 drones in position -> eff 0.5.'),
    }

    entries = [
        ('N2144', OWNER, 'source_assembler_drones_in_position_state', UNIT_ASSEMBLER, 'mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild', 'UnitAssemblerBuild.updateTile()', n2144_inputs, n2144_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed assembler drones_in_position count from UnitAssembler.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed assembler drones_in_position count from UnitAssembler.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the single result symbol.
    by_slice['N2144'] = [
        'source_assembler_drones_in_position_state_result.drones_in_position',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2144', dict(status='done', java_source=UNIT_ASSEMBLER, java_class='mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild', java_method='UnitAssemblerBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2144'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
