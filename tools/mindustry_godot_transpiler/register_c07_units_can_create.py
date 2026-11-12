"""Register the Units.canCreate live evaluation (N2140).

The C07 entry slice and the first item on the N2139 "Next" list
(C07-C12 per the completion backlog). The N2139 handoff deferred
`Units.canCreate` live evaluation to C07 ("needs C07: live per-type
unit counts + the unit cap"); the assembler `should_consume` branch
(`SourceUnitFactoryBuildState.gd:593`) and the production tick
driver (`SourceUnitFactoryBuildState.gd:778`) still read
`frame["can_create"]`, default true. N2140 is that slice: a pure
`source_units_can_create_state` that evaluates `Units.canCreate(team,
type)` (Units.java:115-117) and wires both assembler call sites to
call it instead of the permissive frame default.

Composition, not re-implementation: `getCap` and `countType` already
have port-bridge pure functions (`PortGame.source_unit_cap_state`,
`PortGame.source_unit_count_state`, `SourceUnitUpdatePortBridge.gd:
105-111`, registered symbols `unit_cap.*` / `unit_count.*`);
`isBanned` logic already exists in the factory file
(`SourceUnitFactoryBuildState.gd:152-174`, `unitWhitelist !=
bannedUnits.contains(unit)`). N2140 composes those three
already-ported pieces with `type.useUnitCap` into the one
predicate -- it does not duplicate the cap formula or the count
lookup. The count itself reads the frame's `team_unit_counts`
map (default 0 for a missing unit, exactly
`TeamData.countType`, Teams.java:442-444); the map is not recorded
by any frame yet, so the count stays 0 until the unit-group
slice lands, and the count bridge takes an int `type.id` the
unit catalog does not provide (catalog ids are name strings),
so the wiring reads the frame map directly instead of routing
through it.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
UNITS = 'core/src/mindustry/entities/Units.java'
TEAMS = 'core/src/mindustry/game/Teams.java'
UNIT_TYPE = 'core/src/mindustry/type/UnitType.java'
RULES = 'core/src/mindustry/game/Rules.java'
TEAM = 'core/src/mindustry/game/Team.java'
GAME_STATE = 'core/src/mindustry/core/GameState.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
PROOF = '/root/C07UnitsCanCreateProof'
OWNER = 'SourceUnitRuntimeState.source_units_can_create_state'
TESTS = ['test_c07_units_can_create_registration', 'test_all_c07_units_can_create_input_evidence_is_exact', 'test_units_can_create_state', 'test_reference_graph_and_actual_c07_units_can_create']
DEFERRED = [
    'Live per-type unit counts in the frame (team.data().typeCounts, Teams.java:430-444) -- the pure function takes count_type as an input; the frame reads team_unit_counts (default 0) until a unit-group slice lands.',
    'Per-type useUnitCap in the unit catalog (UnitType.java:205) -- the catalog captures only health/hitSize/speed per unit type, so the wiring reads the Java default true until a catalog slice lands.',
    'TeamData.unitCap live read (Teams.java:298) -- no TeamData read site in the port, so the cap bridge reads 0 until a teams slice lands.',
    'Team.ignoreUnitCap live read (Team.java:22) -- no Team read site in the port, so the wiring reads the Java default false until a teams slice lands.',
    'Net readUnits/whenSyncedUnits drone sync (UnitAssembler.java:430-460) -- client sync, needs the net slice.',
    'units.removeAll(u -> !u.isAdded() || u.dead || !(u.controller() instanceof AssemblerAI)) (UnitAssembler.java:461) -- live unit list, no port frame for it yet.',
    'AI perimeter arrangement (ai.targetPos.trns(...), ai.targetAngle, UnitAssembler.java:506-513) -- AssemblerAI presentation, not state.',
    'Live-world spawn path in spawned() (unit.set, unit.add, unit.buildOn, acceptPayload/handlePayload, Units.notifyUnitSpawn, UnitAssembler.java:548-563) -- the pure tick records spawned/consumed/unit_created_event as state.',
    'Commandable commandPos branch + createSound + Fx.unitAssemble (UnitAssembler.java:549-551, 564-566) -- presentation, not state.',
    'Call.assemblerDroneSpawned net call (UnitAssembler.java:488) -- the pure tick records drone_spawned as state.',
    'Drone controller-not-AssemblerAI bug guard (UnitAssembler.java:479-490) -- data-patch guard, deferred to a validation slice.',
    'checkSolid live collision queries + getUnitSpawn geometry (UnitAssembler.java:332-336, 675-681) -- the pure tick takes occupancy as inputs.',
    'power.status live read -- the driver folds frame["power_status"] (null -> 1.0) until a power-status slice lands.',
    'C07-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public static boolean canCreate(Team team, UnitType type){',
    'return !type.useUnitCap || (team.data().countType(type) < getCap(team) && !type.isBanned());',
    'public static int getCap(Team team){',
    'if((team == state.rules.waveTeam && !state.rules.pvp) || (state.isCampaign() && team == state.rules.waveTeam) || state.rules.disableUnitCap || team.ignoreUnitCap){',
    'return Integer.MAX_VALUE;',
    'return Math.max(0, state.rules.unitCapVariable ? state.rules.unitCap + team.data().unitCap : state.rules.unitCap);',
    'public int countType(UnitType type){',
    'return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];',
    'useUnitCap = true,',
    'public boolean isBanned(){',
    'return state.rules.isBanned(this);',
    'public boolean pvp;',
    'public boolean unitCapVariable = true;',
    'public int unitCap = 0;',
    'public boolean disableUnitCap;',
    'public Team waveTeam = Team.crux;',
    'public boolean isBanned(UnitType unit){',
    'return unitWhitelist != bannedUnits.contains(unit);',
    'public boolean ignoreUnitCap = false;',
    'public boolean isCampaign(){',
    'return enabled && !wasOccupied && Units.canCreate(team, plan().unit) && consPayload.efficiency(this) > 0 && consItem.efficiency(this) > 0 && team.activateUnitFactories();',
    'if(!wasOccupied && efficiency > 0 && Units.canCreate(team, plan.unit)){',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=UNITS, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2140_can_create_inputs = {
        'use_unit_cap': f('bool', 'useUnitCap = true,', 'type.useUnitCap (UnitType.java:205, default true); the unit catalog captures only health/hitSize/speed per unit type, so the wiring reads the Java default until a catalog slice lands.', source=UNIT_TYPE),
        'count_type': f('int', 'return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];', 'team.data().countType(type) (Teams.java:442-444); the frame reads team_unit_counts (default 0 for a missing unit) until the unit-group slice lands.', source=TEAMS),
        'unit_cap': f('int', 'return Math.max(0, state.rules.unitCapVariable ? state.rules.unitCap + team.data().unitCap : state.rules.unitCap);', 'Units.getCap(team) (Units.java:118-125), computed by the caller through the existing SourceUnitUpdateState.cap_state bridge.', source=UNITS),
        'is_banned': f('bool', 'return unitWhitelist != bannedUnits.contains(unit);', 'Rules.isBanned(unit) (Rules.java:311-313); the same read the factory has_upgrade state already does.', source=RULES),
    }
    n2140_can_create_outputs = {
        'can_create': f('bool', 'return !type.useUnitCap || (team.data().countType(type) < getCap(team) && !type.isBanned());', 'Units.canCreate(team, type) (Units.java:115-117): true when the type opts out of the cap, or the live count is under the cap and the type is not banned.', source=UNITS),
        'unit_cap': f('int', 'return Math.max(0, state.rules.unitCapVariable ? state.rules.unitCap + team.data().unitCap : state.rules.unitCap);', 'The evaluated Units.getCap(team) (Units.java:118-125) the predicate compared against.', source=UNITS),
        'count_type': f('int', 'return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];', 'The evaluated team.data().countType(type) (Teams.java:442-444) the predicate compared against.', source=TEAMS),
        'is_banned': f('bool', 'return unitWhitelist != bannedUnits.contains(unit);', 'The evaluated Rules.isBanned(unit) (Rules.java:311-313) the predicate compared against.', source=RULES),
    }

    entries = [
        ('N2140', OWNER, 'source_units_can_create_state', UNITS, 'mindustry.entities.Units', 'Units.canCreate(Team, UnitType)', n2140_can_create_inputs, n2140_can_create_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Units.canCreate predicate from Units.canCreate(Team, UnitType).'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Units.canCreate predicate from Units.canCreate(Team, UnitType).'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: one symbol per returned value, in
    # the order the predicate returns them (can_create, unit_cap,
    # count_type, is_banned) -- not alphabetical.
    by_slice['N2140'] = [
        'source_units_can_create_state_result.can_create',
        'source_units_can_create_state_result.unit_cap',
        'source_units_can_create_state_result.count_type',
        'source_units_can_create_state_result.is_banned',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2140', dict(status='done', java_source=UNITS, java_class='mindustry.entities.Units', java_method='Units.canCreate(Team, UnitType)', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2140'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
