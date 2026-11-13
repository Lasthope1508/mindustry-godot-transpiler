"""Register the turret power.status live read (N2148).

The turret family's live read, following the N2145/N2146/N2147
pure-row pattern. N2142's live loop stamps frame["power_status"]
each tick before the turret tick runs, and the write-back is
generic: SourcePlacedPowerGraphState
SOURCE_CONSUMER_FRAME_META_KEYS includes
"source_turret_building", so turret frames already receive the
live status. But the turret tick driver
(SourceTurretBuildState.source_turret_tick_buildings_state, N2108)
only refreshes frame keys (block_implementation, team_id,
rules_state, cheating, enabled) and never runs updateConsumption
at all -- unlike the factory/adjacent/drill drivers it has no
first-pass required_results -- so an unpowered power turret warms
up, rotates and reloads as if power.status were 1.0. N2148
appends a pure power row over the stamped frame value to the
tick driver's first pass, so the shared machinery folds it into
the min efficiency (BuildingComp.java:1969-1976,
ConsumePower.efficiency is build.power.status) and the warmup
fold (Turret.java:512-514) follows it.

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_non_optional_pass_state) already folds
{"result": ..., "is_power": true} rows into the min efficiency.
N2148 does not touch it. N2148 supplies the missing pure power
row + the tick-driver wiring. No has_consumers fix is needed,
unlike N2145: the machinery runs only when the block has a power
consumer, and the power consumer counts toward hasConsumers
(Block.java:1449). No shouldConsume gate: TurretBuild.
shouldConsume() (Turret.java:364-366, `return isShooting ||
reloadCounter < reload;`) needs targeting/reload state the tick
does not track yet; the machinery runs with should_consume=true
when enabled, and the warmup gate itself (Turret.java:512-514,
efficiency only applied when warmupTarget > 0) is what gates
shooting behaviour on the recorded efficiency.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
POWER_MODULE = 'core/src/mindustry/world/modules/PowerModule.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07TurretPowerStatusProof'
OWNER = 'SourceTurretBuildState.source_turret_power_status_row_state'
TESTS = ['test_c07_turret_power_status_registration', 'test_all_c07_turret_power_status_input_evidence_is_exact', 'test_turret_power_status_row_state', 'test_reference_graph_and_actual_c07_turret_power_status']
DEFERRED = [
    'power.status live read for the PointDefenseTurret (segment, consumePower 8f) and TractorBeamTurret (parallax, consumePower 3.3f) -- neither is a TurretBuild (they extend ReloadTurret / BaseTurret) and each keeps its own driver; each waits for its own slice.',
    'BurstDrill power (eruption-drill / impact-drill) -- BurstDrill has its own driver, out of scope for the base-Drill slice.',
    'SolidPump power (water-extractor) -- SolidPump has its own driver, out of scope for the base-Drill slice.',
    'Foreshadow item-ammo and lustre liquid-nitrogen first-pass rows -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); those rows wait for their own slices.',
    'Turret shouldConsume gate (isShooting / reloadCounter, Turret.java:364-366) -- needs targeting/reload state the tick does not track yet.',
    'Turret warmup/reload advance on the folded efficiency -- the N2148 proof carries no progress keys; needs its own slice.',
    'spawn_occupied / spawn_visual_occupied frame inputs -- checkSolid(spawn, false/true) (UnitAssembler.java:675-680) needs tile solidity + a nearby-units query; the port\'s check_solid_state() is a no-arg stub returning false; waits for a collision/tile-solidity frame-data slice.',
    'allow_update frame input -- the canonical allow_update_state exists (SourceBuildingAccessState, BuildingComp.java:622-627) but the driver cannot supply its inputs: rules_state carries only unitCostMultiplier + teams (no env, limitMapArea, limits), and the catalog carries no block env/privileged flags; waits for a rules-state capture slice.',
    'Per-unit AssemblerAI.inPosition() evaluation from live unit pos/rotation/targetPos/targetAngle -- the count reads the recorded in_position flag; the units list carries no pos/rotation yet.',
    'moveOutPayload() modeling -- the assembler production tick still has no payload move-out.',
    'Net readUnits / whenSyncedUnits drone sync -- presentation/net, not state.',
    'Live UnitComp.add() / remove() lifecycle hooks (UnitComp.java:591-598, 603-604, 752) -- no live unit lifecycle in the port yet.',
    'PayloadComp add/remove count hooks (PayloadComp.java:101, 200) -- same, payload lifecycle not ported yet.',
    'Teams.updateTeamStats full multi-team rebuild (present/bosses/players/unitsByType/unitTree, Teams.java:182-245) -- N2141 rebuilds one team\'s counts only.',
    'Units.notifyUnitSpawn / spawn path, Call.unitCapDeath / Call.unitEnvDeath net calls -- presentation/net, not state.',
    'C07-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'return build.power.status;',
    'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;',
    'hasConsumers = consumers.length > 0;',
    'consumePower(6f);',
    'consumePower(3.3f);',
    'consumePower(17f);',
    'return power == null ? 0f : power.status;',
    'shootWarmup = Mathf.approachDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));',
    'minEfficiency = Math.min(minEfficiency, result);',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2148_inputs = {
        'frame': f('Dictionary', 'return build.power.status;', 'The building frame carrying the graph-stamped power_status (ConsumePower.java:39, the canonical power.status read): the live value the row folds; null before the first graph update, folding to 1.0.', source=CONSUME_POWER),
        'has_power_consumer': f('bool', 'hasConsumers = consumers.length > 0;', 'Whether the block has a power consumer (Block.java:1449): the driver gate -- the row joins the first pass only when the block consumes power, and the power consumer counts toward hasConsumers.', source=BLOCK),
    }
    n2148_outputs = {
        'row': f('Dictionary', 'return build.power.status;', 'The power row for the first pass (ConsumePower.java:39, the canonical power.status read): {"result": live power.status, "is_power": true}, folded by the non-optional pass into the min efficiency.', source=CONSUME_POWER),
        'has_power_row': f('bool', 'for(var cons : block.nonOptionalConsumers){', 'Whether the row joins the first pass (BuildingComp.java:1969): true when the block has a power consumer; the row is the power consumer\'s entry in the non-optional pass.', source=BUILDING_COMP),
    }

    entries = [
        ('N2148', OWNER, 'source_turret_power_status_row_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.updateTile()', n2148_inputs, n2148_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed turret power.status row from ConsumePower.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed turret power.status row from ConsumePower.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the row, then its presence flag.
    by_slice['N2148'] = [
        'source_turret_power_status_row_state_result.row',
        'source_turret_power_status_row_state_result.has_power_row',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2148', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2148'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
