"""Register the UnitAssembler live production tick (N2139).

The UnitAssembler half of the live production wiring, the last item
on the N2138 "Next" list (and the N2138 deferred line: "UnitAssembler
live production tick + spawned() (UnitAssembler.java:429-571 --
progress advance, spawned() call at completion, drone progress,
tier/lastTier reset) -- N2139."). The live tick driver
(SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state,
wired from SourceFactoryRuntimeState.gd:192) runs the consumption
half of updateTile every tick and, since N2137/N2138, advances
production for UnitFactory and Reconstructor frames; its comment
says "UnitAssembler keeps the consumption-only tick until its own
production slice (N2139)."

N2139 is that slice: a pure
source_unit_assembler_production_tick_state that runs one tick of
UnitAssemblerBuild.updateTile() (UnitAssembler.java:429-571) -- tier
reset, warmup/drone advance, drone spawn, the moveInPayload() &&
!wasOccupied intake call site, spawn-occupancy warmups, the progress
advance `progress += edelta() * unitBuildSpeed * eff / plan.time`,
and the spawned() call (Call.assemblerUnitSpawned(tile) -> consume()
+ blocks.clear() + UnitCreateEvent) when progress >= 1f -- wired
into the tick driver for UnitAssembler implementations only. With
it, production is live for all three factory-family
implementations. moveOutPayload() is NOT modeled here -- deferred
(payload transport slice). The commandable-unit branch
(commandPos/command), the live-world spawn path (unit.set/add/
buildOn/acceptPayload), createSound and Fx.unitAssemble are
presentation/live-world, not state -- not modeled, like N2137/N2138.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
PAYLOAD_BLOCK = 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
RULES = 'core/src/mindustry/game/Rules.java'
PROOF = '/root/C06UnitAssemblerProductionProof'
OWNER = 'SourceUnitFactoryBuildState.source_unit_assembler_production_tick_state'
TESTS = ['test_c06_unit_assembler_production_tick_registration', 'test_all_c06_unit_assembler_production_tick_input_evidence_is_exact', 'test_unit_assembler_production_tick_state', 'test_reference_graph_and_actual_c06_unit_assembler_production_tick']
DEFERRED = [
    'Net readUnits/whenSyncedUnits drone sync (UnitAssembler.java:430-460) -- client sync, needs the net slice.',
    'units.removeAll(u -> !u.isAdded() || u.dead || !(u.controller() instanceof AssemblerAI)) (UnitAssembler.java:461) -- live unit list, no port frame for it yet.',
    'AI perimeter arrangement (ai.targetPos.trns(...), ai.targetAngle, UnitAssembler.java:506-513) -- AssemblerAI presentation, not state.',
    'Live-world spawn path in spawned() (unit.set, unit.add, unit.buildOn, acceptPayload/handlePayload, Units.notifyUnitSpawn, UnitAssembler.java:548-563) -- the pure tick records spawned/consumed/unit_created_event as state.',
    'Commandable commandPos branch + createSound + Fx.unitAssemble (UnitAssembler.java:549-551, 564-566) -- presentation, not state.',
    'Call.assemblerDroneSpawned net call (UnitAssembler.java:488) -- the pure tick records drone_spawned as state.',
    'Drone controller-not-AssemblerAI bug guard (UnitAssembler.java:479-490) -- data-patch guard, deferred to a validation slice.',
    'checkSolid live collision queries + getUnitSpawn geometry (UnitAssembler.java:332-336, 675-681) -- the pure tick takes occupancy as inputs.',
    'Units.canCreate live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch keeps reading frame["can_create"], default true, until then.',
    'power.status live read -- the driver folds frame["power_status"] (null -> 1.0) until a power-status slice lands.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'if(lastTier != currentTier){',
    'if(lastTier >= 0f){',
    'progress = 0f;',
    'lastTier == -2 ? -1 : currentTier;',
    'if(!allowUpdate()){',
    'units.each(Unit::kill);',
    'units.clear();',
    'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;',
    'powerWarmup = Mathf.lerpDelta(powerStatus, powerStatus > 0.0001f ? 1f : 0f, 0.1f);',
    'droneWarmup = Mathf.lerpDelta(droneWarmup, units.size < dronesCreated ? powerStatus : 0f, 0.1f);',
    'totalDroneProgress += droneWarmup * delta();',
    'if(units.size < dronesCreated && enabled && (droneProgress += delta() * state.rules.unitBuildSpeed(team) * powerStatus / droneConstructTime) >= 1f){',
    'var unit = droneType.create(team);',
    'if(unit.controller() instanceof AssemblerAI){',
    'if(units.size >= dronesCreated){',
    'droneProgress = 0f;',
    'if(moveInPayload() && !wasOccupied){',
    'yeetPayload(payload);',
    'payload = null;',
    'wasOccupied = checkSolid(spawn, false);',
    'boolean visualOccupied = checkSolid(spawn, true);',
    'float eff = (units.count(u -> ((AssemblerAI)u.controller()).inPosition()) / (float)dronesCreated);',
    'sameTypeWarmup = Mathf.lerpDelta(sameTypeWarmup, wasOccupied && !visualOccupied ? 0f : 1f, 0.1f);',
    'invalidWarmup = Mathf.lerpDelta(invalidWarmup, visualOccupied ? 1f : 0f, 0.1f);',
    'if(!wasOccupied && efficiency > 0 && Units.canCreate(team, plan.unit)){',
    'warmup = Mathf.lerpDelta(warmup, efficiency, 0.1f);',
    'if((progress += edelta() * state.rules.unitBuildSpeed(team) * eff / plan.time) >= 1f){',
    'Call.assemblerUnitSpawned(tile);',
    'warmup = Mathf.lerpDelta(warmup, 0f, 0.1f);',
    'var plan = plan();',
    'consume();',
    'var unit = plan.unit.create(team);',
    'blocks.clear();',
    'Events.fire(new UnitCreateEvent(unit, this));',
    'return plans.get(Math.min(currentTier, plans.size - 1));',
    'public float droneConstructTime = 60f * 4f;',
    'public int dronesCreated = 4;',
    'public int currentTier = 0;',
    'public int lastTier = -2;',
    'public boolean wasOccupied = false;',
    'public float droneProgress, totalDroneProgress;',
    'return efficiency * delta();',
    'return unitBuildSpeedMultiplier * teams.get(team).unitBuildSpeedMultiplier;',
    'return hasArrived();',
    'return payVector.isZero(0.01f);',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=UNIT_ASSEMBLER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2139_production_tick_inputs = {
        'frame': f('Dictionary', 'public void updateTile(){', 'The assembler frame; carries efficiency (default 1.0), payload (default null), blocks (default {}), progress/warmup/drone_warmup/power_warmup/same_type_warmup/invalid_warmup/drone_progress/total_drone_progress (defaults 0.0 -- UnitAssemblerBuild float fields, Java default 0f), current_tier (default 0), last_tier (default -2), was_occupied (default false), units_count (default 0), enabled (default true).'),
        'plan': f('Dictionary', 'return plans.get(Math.min(currentTier, plans.size - 1));', 'The current tier plan {unit, time} from the N2124 source_unit_factory_assembler_plan_state(block, tier) (UnitAssembler.java:383-386).'),
        'drones_created': f('int', 'public int dronesCreated = 4;', 'block.properties.dronesCreated (UnitAssembler.java:46, default 4); the catalog does not capture it yet, so the driver reads the default until a catalog slice lands.'),
        'drone_construct_time': f('float', 'public float droneConstructTime = 60f * 4f;', 'block.properties.droneConstructTime (UnitAssembler.java:45, default 240.0 = 60 * 4); the catalog does not capture it yet, so the driver reads the default until a catalog slice lands.'),
        'payload_in_position': f('bool', 'return payVector.isZero(0.01f);', 'The moveInPayload() result (PayloadBlock.java:186-196 returns hasArrived(), i.e. payVector.isZero(0.01f)), read from the frame pay_vector like the N2138 driver.', source=PAYLOAD_BLOCK),
        'spawn_occupied': f('bool', 'wasOccupied = checkSolid(spawn, false);', 'The live checkSolid(spawn, false) result; the frame records no spawn_occupied yet, so the driver defaults false ("spawn free") until a collision slice lands.'),
        'spawn_visual_occupied': f('bool', 'boolean visualOccupied = checkSolid(spawn, true);', 'The live checkSolid(spawn, true) result; the frame records no spawn_visual_occupied yet, so the driver defaults false until a collision slice lands.'),
        'in_position_count': f('int', 'float eff = (units.count(u -> ((AssemblerAI)u.controller()).inPosition()) / (float)dronesCreated);', 'Drones in position (AssemblerAI.inPosition()); the frame records no drones_in_position yet, so the driver defaults 0 -- eff 0 and no progress until a drone-position slice lands.'),
        'allow_update': f('bool', 'if(!allowUpdate()){', 'BuildingComp.allowUpdate() (BuildingComp.java:622-627, team/environment/map-area gate); the frame records no allow_update yet, so the driver defaults true.'),
        'can_create': f('bool', 'if(!wasOccupied && efficiency > 0 && Units.canCreate(team, plan.unit)){', 'Units.canCreate(team, plan.unit); the live evaluation needs C07, so the driver keeps reading frame["can_create"], default true (already read by the N2132 shouldConsume branch).'),
        'power_status': f('Variant', 'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', 'The power status: null means no power consumer -> 1.0 (Java power == null ? 1f : power.status); the driver folds !enabled into 0.0 before passing it.'),
        'edelta': f('float', 'return efficiency * delta();', 'efficiency * delta (BuildingComp.edelta(), BuildingComp.java:1927-1928).', source=BUILDING_COMP),
        'unit_build_speed': f('float', 'return unitBuildSpeedMultiplier * teams.get(team).unitBuildSpeedMultiplier;', 'Rules.unitBuildSpeed(team) (Rules.java:271-272): the global unitBuildSpeedMultiplier (default 1f) times the team multiplier (default 1f).', source=RULES),
        'source_delta': f('float', 'powerWarmup = Mathf.lerpDelta(powerStatus, powerStatus > 0.0001f ? 1f : 0f, 0.1f);', 'The tick delta for lerpDelta (SourceMathState.source_lerp_delta, Mathf.lerpDelta = lerp(from, to, clamp(progress * Time.delta))).'),
    }
    n2139_production_tick_outputs = {
        'progress': f('float', 'if((progress += edelta() * state.rules.unitBuildSpeed(team) * eff / plan.time) >= 1f){', 'The frame progress after the tick: advanced by edelta * unit_build_speed * eff / plan.time while producing, reset to 0.0 on completion (spawned() sets progress = 0f) and on tier change, unchanged when occupied, efficiency 0, or can_create false.'),
        'warmup': f('float', 'warmup = Mathf.lerpDelta(warmup, efficiency, 0.1f);', 'The frame warmup after the tick: lerped toward efficiency while producing, toward 0.0 otherwise (0.1 per tick).'),
        'drone_progress': f('float', 'if(units.size < dronesCreated && enabled && (droneProgress += delta() * state.rules.unitBuildSpeed(team) * powerStatus / droneConstructTime) >= 1f){', 'The drone progress after the tick: advanced by source_delta * unit_build_speed * power_status / drone_construct_time while a drone slot is free, reset to 0.0 on spawn and when all slots are filled.'),
        'total_drone_progress': f('float', 'totalDroneProgress += droneWarmup * delta();', 'The total drone progress after the tick: advanced by the new drone_warmup * source_delta every tick.'),
        'completed': f('bool', 'Call.assemblerUnitSpawned(tile);', 'True when progress reached 1.0 this tick: spawned() fired (consume() + blocks.clear() + UnitCreateEvent) and the tick driver performs the N2128 consume call.'),
        'was_occupied': f('bool', 'wasOccupied = checkSolid(spawn, false);', 'The spawn occupancy after the tick: the spawn_occupied input (live checkSolid(spawn, false)); the production gate reads the new value.'),
    }

    entries = [
        ('N2139', OWNER, 'source_unit_assembler_production_tick_state', UNIT_ASSEMBLER, 'mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild', 'UnitAssemblerBuild.updateTile()', n2139_production_tick_inputs, n2139_production_tick_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed UnitAssembler live production tick from UnitAssemblerBuild.updateTile().'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed UnitAssembler live production tick from UnitAssemblerBuild.updateTile().'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: one symbol per returned value, in
    # the order the tick driver writes them back (progress, warmup,
    # drone_progress, total_drone_progress, completed, was_occupied)
    # -- not alphabetical.
    by_slice['N2139'] = [
        'source_unit_assembler_production_tick_state_result.progress',
        'source_unit_assembler_production_tick_state_result.warmup',
        'source_unit_assembler_production_tick_state_result.drone_progress',
        'source_unit_assembler_production_tick_state_result.total_drone_progress',
        'source_unit_assembler_production_tick_state_result.completed',
        'source_unit_assembler_production_tick_state_result.was_occupied',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2139', dict(status='done', java_source=UNIT_ASSEMBLER, java_class='mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild', java_method='UnitAssemblerBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2139'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
