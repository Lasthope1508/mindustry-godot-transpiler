"""Register the Reconstructor live production tick (N2138).

The Reconstructor half of the live production wiring, the next item
on the N2137 "Next" list (and the N2137 deferred line: "Reconstructor
live production tick (Reconstructor.java:317-356 -- constructing
cache, progress advance, upgrade on completion, progress %= 1f,
consume(), UnitCreateEvent) -- N2138."). The live tick driver
(SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state,
wired from SourceFactoryRuntimeState.gd:192) runs the consumption
half of updateTile every tick and, since N2137, advances production
for UnitFactory frames only: its comment says "Reconstructor and
UnitAssembler keep the consumption-only tick until their own
production slices (N2138, N2139)."

N2138 is that slice for the reconstructor: a pure
source_reconstructor_production_tick_state that advances
progress/time/speedScl per ReconstructorBuild.updateTile()
(Reconstructor.java:317-356) and fires the upgrade call
(payload.unit = upgrade(...).create(...) + consume() +
UnitCreateEvent) when progress >= constructTime, wired into the
tick driver for Reconstructor implementations only. UnitAssembler
keeps the consumption-only tick until N2139. moveOutPayload() is
NOT modeled here -- deferred (payload transport slice) -- so a
payload with no upgrade stays in the frame and no progress
advances. The commandable-unit branch (commandPos/command) and
the create sound are presentation, not state -- not modeled.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
RECONSTRUCTOR = 'core/src/mindustry/world/blocks/units/Reconstructor.java'
PAYLOAD_BLOCK = 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
RULES = 'core/src/mindustry/game/Rules.java'
PROOF = '/root/C06ReconstructorProductionProof'
OWNER = 'SourceUnitFactoryBuildState.source_reconstructor_production_tick_state'
TESTS = ['test_c06_reconstructor_production_tick_registration', 'test_all_c06_reconstructor_production_tick_input_evidence_is_exact', 'test_reconstructor_production_tick_state', 'test_reference_graph_and_actual_c06_reconstructor_production_tick']
DEFERRED = [
    'UnitAssembler live production tick + spawned() (UnitAssembler.java:429-571 -- progress advance, spawned() call at completion, drone progress, tier/lastTier reset) -- N2139.',
    'The intake call site (moveInPayload() && !wasOccupied, UnitAssembler.java:500-503) -- belongs to the UnitAssembler production wiring.',
    'moveOutPayload() transport -- the production tick records moved_out as state but does not move a payload out; a no-upgrade payload stays in the frame until the move-out slice lands.',
    'moveInPayload() approach animation (payVector.approach(Vec2.ZERO, payloadSpeed * delta()), payRotation moveToward, PayloadBlock.java:186-196) -- the pure tick takes payload_in_position as an input; the approach itself belongs to the payload transport slice.',
    'The commandable-unit command branch (commandPos/command, Reconstructor.java:337-343) and createSound (Reconstructor.java:345) -- presentation, not state.',
    'Units.canCreate live evaluation (needs C07: live per-type unit counts and the unit cap); the assembler branch keeps reading frame["can_create"], default true, until then.',
    'lastTier tracking + progress reset on tier change (UnitAssembler.java:441-447) -- belongs to the UnitAssembler production/tick wiring.',
    'The live-loop module link/unlink call sites: updateModules/removeModule are called from UnitAssemblerModuleBuild link/unlink (UnitAssemblerModule.java:80-83) -- the port has no live module-linking frame event yet.',
    'Live-loop belt enabled gate (sprite-enabled seam) -- the pure advance function takes efficiency since N2135; the caller is the missing half.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public void updateTile(){',
    '//cache value to prevent repeated calls and multithreading issues',
    'constructing = constructing();',
    'boolean valid = false;',
    'if(payload != null){',
    'if(!hasUpgrade(payload.unit.type)){',
    'moveOutPayload();',
    'if(moveInPayload()){',
    'if(efficiency > 0){',
    'valid = true;',
    'progress += edelta() * state.rules.unitBuildSpeed(team);',
    'if(progress >= constructTime){',
    'payload.unit = upgrade(payload.unit.type).create(payload.unit.team());',
    'if(payload.unit.isCommandable()){',
    'payload.unit.command().commandPosition(commandPos);',
    'createSound.at(this, 1f + Mathf.range(0.06f), createSoundVolume);',
    'progress %= 1f;',
    'Effect.shake(2f, 3f, this);',
    'Fx.producesmoke.at(this);',
    'consume();',
    'Events.fire(new UnitCreateEvent(payload.unit, this));',
    'speedScl = Mathf.lerpDelta(speedScl, Mathf.num(valid), 0.05f);',
    'time += edelta() * speedScl * state.rules.unitBuildSpeed(team);',
    'return payload != null && hasUpgrade(payload.unit.type);',
    'public float constructTime = 60 * 2;',
    'UnitType[] r =  upgrades.find(u -> u[0] == type);',
    'return r == null ? null : r[1];',
    'return t != null && (t.unlockedNowHost() || team.isAI()) && !type.isBanned();',
    'public boolean moveInPayload(){',
    'return moveInPayload(true);',
    'return hasArrived();',
    'return payVector.isZero(0.01f);',
    'return efficiency * delta();',
    'return unitBuildSpeedMultiplier * teams.get(team).unitBuildSpeedMultiplier;',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=RECONSTRUCTOR, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2138_production_tick_inputs = {
        'frame': f('Dictionary', 'public void updateTile(){', 'The reconstructor frame; carries efficiency (default 1.0), payload (default null), progress/time/speed_scl (defaults 0.0 -- UnitBuild float fields, Java default 0f) and pay_vector (default (0, 0) -- PayloadBlock.payVector, Java default new Vec2()).'),
        'construct_time': f('float', 'public float constructTime = 60 * 2;', 'block.properties.constructTime (Reconstructor.java:36, default 120.0 = 60 * 2; additive-reconstructor overrides to 600).'),
        'has_upgrade': f('bool', 'return t != null && (t.unlockedNowHost() || team.isAI()) && !type.isBanned();', 'Whether the held unit upgrades, from the existing N2124 helper source_unit_factory_has_upgrade_state (Reconstructor.java:388-391).'),
        'upgrade_unit': f('String', 'UnitType[] r =  upgrades.find(u -> u[0] == type);', 'The upgrade target from the existing N2124 helper source_unit_factory_has_upgrade_state (Reconstructor.java:393-396).'),
        'payload_in_position': f('bool', 'return payVector.isZero(0.01f);', 'The moveInPayload() result (PayloadBlock.java:186-196 returns hasArrived(), i.e. payVector.isZero(0.01f)).', source=PAYLOAD_BLOCK),
        'edelta': f('float', 'return efficiency * delta();', 'efficiency * delta (BuildingComp.edelta(), BuildingComp.java:1927-1928).', source=BUILDING_COMP),
        'unit_build_speed': f('float', 'return unitBuildSpeedMultiplier * teams.get(team).unitBuildSpeedMultiplier;', 'Rules.unitBuildSpeed(team) (Rules.java:271-272): the global unitBuildSpeedMultiplier (default 1f) times the team multiplier (default 1f).', source=RULES),
        'source_delta': f('float', 'speedScl = Mathf.lerpDelta(speedScl, Mathf.num(valid), 0.05f);', 'The tick delta for lerpDelta (SourceMathState.source_lerp_delta, Mathf.lerpDelta = lerp(from, to, clamp(progress * Time.delta))).'),
    }
    n2138_production_tick_outputs = {
        'progress': f('float', 'progress += edelta() * state.rules.unitBuildSpeed(team);', 'The frame progress after the tick: advanced by edelta * unit_build_speed while producing, fmod 1.0 on completion, unchanged when no payload, not in position, or no upgrade.'),
        'time': f('float', 'time += edelta() * speedScl * state.rules.unitBuildSpeed(team);', 'The frame time after the tick: advanced by edelta * speed_scl (new value) * unit_build_speed, unconditionally at the end of the tick.'),
        'speed_scl': f('float', 'speedScl = Mathf.lerpDelta(speedScl, Mathf.num(valid), 0.05f);', 'The frame speed_scl after the tick: lerped toward 1.0 while producing (valid), toward 0.0 otherwise (0.05 per tick).'),
        'completed': f('bool', 'if(progress >= constructTime){', 'True when progress reached construct_time this tick: the payload unit was upgraded, the N2128 consume state fired and the UnitCreateEvent recorded.'),
        'constructing': f('bool', 'constructing = constructing();', 'The cached constructing value: payload != null and has_upgrade (Reconstructor.java:319 + 384-386).'),
        'payload_unit': f('String', 'payload.unit = upgrade(payload.unit.type).create(payload.unit.team());', 'The payload unit after the tick: the upgrade target on completion, the held unit otherwise, empty when no payload.'),
    }

    entries = [
        ('N2138', OWNER, 'source_reconstructor_production_tick_state', RECONSTRUCTOR, 'mindustry.world.blocks.units.Reconstructor.ReconstructorBuild', 'ReconstructorBuild.updateTile()', n2138_production_tick_inputs, n2138_production_tick_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Reconstructor live production tick from ReconstructorBuild.updateTile().'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Reconstructor live production tick from ReconstructorBuild.updateTile().'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: one symbol per returned value, in
    # the order the tick driver writes them back (progress, time,
    # speed_scl, completed, constructing, payload_unit) -- not
    # alphabetical.
    by_slice['N2138'] = [
        'source_reconstructor_production_tick_state_result.progress',
        'source_reconstructor_production_tick_state_result.time',
        'source_reconstructor_production_tick_state_result.speed_scl',
        'source_reconstructor_production_tick_state_result.completed',
        'source_reconstructor_production_tick_state_result.constructing',
        'source_reconstructor_production_tick_state_result.payload_unit',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2138', dict(status='done', java_source=RECONSTRUCTOR, java_class='mindustry.world.blocks.units.Reconstructor.ReconstructorBuild', java_method='ReconstructorBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2138'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
