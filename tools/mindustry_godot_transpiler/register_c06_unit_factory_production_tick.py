"""Register the UnitFactory live production tick (N2137).

The UnitFactory half of the live production wiring, the next item on
the N2136 "Next" list (and the N2136 deferred line: "Live production
wiring: the tick driver advances no progress and calls no spawned()
yet -- UnitFactory progress (UnitFactory.java:401-403),
Reconstructor progress (Reconstructor.java:330-348) and
UnitAssembler spawned() (UnitAssembler.java:544-571) are the
production slice"). The live tick driver
(SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state,
wired from SourceFactoryRuntimeState.gd:192) runs the consumption
half of updateTile every tick but advances no progress and calls no
completion: its own comment says "The frame delta is not consumed by
the wiring itself beyond that; a later slice that ticks production
reads it."

N2137 is that slice for the ground factory: a pure
source_unit_factory_production_tick_state that advances
progress/time/speedScl per UnitFactoryBuild.updateTile()
(UnitFactory.java:392-442) and fires the completion call
(payload = new UnitPayload(unit) + consume() + UnitCreateEvent)
when progress >= plan.time, wired into the tick driver for
UnitFactory implementations only. Reconstructor and UnitAssembler
keep the consumption-only tick until their own production slices
(N2138, N2139). moveOutPayload() is NOT modeled here -- deferred
(payload transport slice) -- so a payload created last tick stays
in the frame and the next tick's payload != null branch resets
progress to 0 until the move-out slice lands.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
UNIT_FACTORY = 'core/src/mindustry/world/blocks/units/UnitFactory.java'
RULES = 'core/src/mindustry/game/Rules.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
UNIT_TYPE = 'core/src/mindustry/type/UnitType.java'
PROOF = '/root/C06UnitFactoryProductionProof'
OWNER = 'SourceUnitFactoryBuildState.source_unit_factory_production_tick_state'
TESTS = ['test_c06_unit_factory_production_tick_registration', 'test_all_c06_unit_factory_production_tick_input_evidence_is_exact', 'test_unit_factory_production_tick_state', 'test_reference_graph_and_actual_c06_unit_factory_production_tick']
DEFERRED = [
    'Reconstructor live production tick (Reconstructor.java:317-356 -- constructing cache, progress advance, upgrade on completion, progress %= 1f, consume(), UnitCreateEvent) -- N2138.',
    'UnitAssembler live production tick + spawned() (UnitAssembler.java:429-571 -- progress advance, spawned() call at completion, drone progress, tier/lastTier reset) -- N2139.',
    'The intake call site (moveInPayload() && !wasOccupied, UnitAssembler.java:500-503) -- belongs to the UnitAssembler production wiring.',
    'moveOutPayload() transport -- the production tick does not move a completed payload out yet; a completed factory\'s next tick resets progress to 0 until the move-out slice lands.',
    'Units.canCreate live evaluation (needs C07: live per-type unit counts and the unit cap); the assembler branch keeps reading frame["can_create"], default true, until then.',
    'lastTier tracking + progress reset on tier change (UnitAssembler.java:441-447) -- belongs to the UnitAssembler production/tick wiring.',
    'The live-loop module link/unlink call sites: updateModules/removeModule are called from UnitAssemblerModuleBuild link/unlink (UnitAssemblerModule.java:80-83) -- the port has no live module-linking frame event yet.',
    'Live-loop belt enabled gate (sprite-enabled seam) -- the pure advance function takes efficiency since N2135; the caller is the missing half.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public void updateTile(){',
    'if(!configurable){',
    'currentPlan = 0;',
    'if(currentPlan < 0 || currentPlan >= plans.size){',
    'currentPlan = -1;',
    'if(efficiency > 0 && currentPlan != -1){',
    'time += edelta() * speedScl * Vars.state.rules.unitBuildSpeed(team);',
    'progress += edelta() * Vars.state.rules.unitBuildSpeed(team);',
    'speedScl = Mathf.lerpDelta(speedScl, 1f, 0.05f);',
    'speedScl = Mathf.lerpDelta(speedScl, 0f, 0.05f);',
    'moveOutPayload();',
    'if(currentPlan != -1 && payload == null){',
    'if(plan.unit.isBanned()){',
    'if(progress >= plan.time){',
    'progress %= 1f;',
    'Unit unit = plan.unit.create(team);',
    'payload = new UnitPayload(unit);',
    'payVector.setZero();',
    'consume();',
    'Events.fire(new UnitCreateEvent(payload.unit, this));',
    'progress = Mathf.clamp(progress, 0, plan.time);',
    'progress = 0f;',
    'return efficiency * delta();',
    'return unitBuildSpeedMultiplier * teams.get(team).unitBuildSpeedMultiplier;',
    'return state.rules.isBanned(this);',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=UNIT_FACTORY, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2137_production_tick_inputs = {
        'frame': f('Dictionary', 'public void updateTile(){', 'The factory frame; carries efficiency (default 1.0), current_plan (default -1), payload (default null), progress/time/speed_scl (defaults 0.0 -- UnitBuild float fields, Java default 0f), configurable (default true) and rules_state (bannedUnits, default empty).'),
        'plan': f('Dictionary', 'UnitPlan plan = plans.get(currentPlan);', 'The current plan dict from source_unit_factory_plan_requirements_state (unit + time); empty when the frame has no plan.'),
        'plans_count': f('int', 'if(currentPlan < 0 || currentPlan >= plans.size){', 'block.properties.unitPlans.size() for the bounds check (updateTile forces plan 0 when the block is not configurable, then -1 when out of range).'),
        'edelta': f('float', 'return efficiency * delta();', 'efficiency * delta (BuildingComp.edelta(), BuildingComp.java:1927-1928).', source=BUILDING_COMP),
        'unit_build_speed': f('float', 'return unitBuildSpeedMultiplier * teams.get(team).unitBuildSpeedMultiplier;', 'Rules.unitBuildSpeed(team) (Rules.java:271-272): the global unitBuildSpeedMultiplier (default 1f) times the team multiplier (default 1f).', source=RULES),
        'source_delta': f('float', 'speedScl = Mathf.lerpDelta(speedScl, 1f, 0.05f);', 'The tick delta for lerpDelta (SourceMathState.source_lerp_delta, Mathf.lerpDelta = lerp(from, to, clamp(progress * Time.delta))).'),
    }
    n2137_production_tick_outputs = {
        'progress': f('float', 'progress += edelta() * Vars.state.rules.unitBuildSpeed(team);', 'The frame progress after the tick: advanced by edelta * unit_build_speed while producing, fmod 1.0 then clamped to plan.time on completion, 0 when no plan or a payload is held.'),
        'time': f('float', 'time += edelta() * speedScl * Vars.state.rules.unitBuildSpeed(team);', 'The frame time after the tick: advanced by edelta * speed_scl * unit_build_speed while producing.'),
        'speed_scl': f('float', 'speedScl = Mathf.lerpDelta(speedScl, 1f, 0.05f);', 'The frame speed_scl after the tick: lerped toward 1.0 while producing, toward 0.0 otherwise (0.05 per tick).'),
        'completed': f('bool', 'if(progress >= plan.time){', 'True when progress reached plan.time this tick: the unit was created, the payload set, the N2128 consume state fired and the UnitCreateEvent recorded.'),
        'current_plan': f('int', 'if(currentPlan < 0 || currentPlan >= plans.size){', 'The frame current_plan after the tick: forced to 0 when the block is not configurable, -1 when out of range or the plan unit is banned (Java returns from updateTile, skipping the clamp).'),
    }

    entries = [
        ('N2137', OWNER, 'source_unit_factory_production_tick_state', UNIT_FACTORY, 'mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild', 'UnitFactoryBuild.updateTile()', n2137_production_tick_inputs, n2137_production_tick_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed UnitFactory live production tick from UnitFactoryBuild.updateTile().'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed UnitFactory live production tick from UnitFactoryBuild.updateTile().'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: one symbol per returned value, in
    # the order the tick driver writes them back (progress, time,
    # speed_scl, completed, current_plan) -- not alphabetical.
    by_slice['N2137'] = [
        'source_unit_factory_production_tick_state_result.progress',
        'source_unit_factory_production_tick_state_result.time',
        'source_unit_factory_production_tick_state_result.speed_scl',
        'source_unit_factory_production_tick_state_result.completed',
        'source_unit_factory_production_tick_state_result.current_plan',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2137', dict(status='done', java_source=UNIT_FACTORY, java_class='mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild', java_method='UnitFactoryBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2137'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
