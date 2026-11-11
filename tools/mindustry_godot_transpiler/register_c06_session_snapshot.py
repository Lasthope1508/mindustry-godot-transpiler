"""Register the C06 session proof (N2121).

C06 chains the whole bootstrap world through the real game loop:
drill mines copper -> conveyors -> core; solar panel -> battery ->
lancer; pump -> conduit -> drill water booster. Every leg was wired
by an earlier slice (N2077-N2083 power, N2088-N2093 pump/conduit/
drill, N2108-N2120 factory ticks) but no slice had ever driven the
chain end to end and asserted the session state before/after, so
N2121 adds one pure read of the live session — the snapshot — and
proves the chain over 900 deterministic ticks (300 + 600) from a
reset state.

The snapshot reads the live game object only: the core's held copper
(ItemModule.get, ItemModule.java:209) and health (HealthComp.health,
HealthComp.java:11); the placed power graph grouped at one live tick
(PowerGraph.add groups each building once, PowerGraph.java:277-301)
for needed (getPowerNeeded, :105), produced (getPowerProduced, :95),
battery stored (getBatteryStored, :118, status * capacity over
enabled batteries — the grouped dicts rebuild power_status as 0.0
every frame, so the live status is read from the battery sprite
meta) and capacity (getTotalBatteryCapacity, :142), with coverage
from distributePower (PowerGraph.java:189-190); the drill's
DrillBuild fields from the legacy per-cell stores the tick reads
(timeDrilled += warmup * delta(), Drill.java:296; warmup approaches
speed, Drill.java:304; lastDrillSpeed = (speed * dominantItems *
warmup) / delay, Drill.java:303; produced count from
offload(dominantItem), Drill.java:317; delay = getDrillTime(copper)
= (600 + 50 * 1) / 1 = 650 ticks, Drill.java:170-172 with
hardnessDrillMultiplier 50f at :28 and copper hardness 1) and its
held water (LiquidModule.get, LiquidModule.java:102); the pump's
PumpBuild frame (warmup, totalProgress, Pump.java:111) and held
water; and the water held across the whole conduit line.

Proving the chain exposed one live-loop bug, fixed in this slice:
simulate_factory passed its delta in seconds straight into the belt
advance, but the advance moves items by `moved = speed * edelta()`
(Conveyor.java:262) and edelta is in ticks — Time.delta is the real
frame delta scaled to 60fps ticks (arc Time.java:26, `* 60f`), and
BuildingComp.delta()/edelta() carry it unchanged apart from
timeScale and efficiency (BuildingComp.java:1922-1929). The belts
therefore advanced 60x too slowly: in a 900-tick session no copper
ever reached the core (the first item sat on the first belt cell,
blocking every later dump on the 0.4 item spacing, so drill_items
grew 1..5 while core_copper stayed 0). The N2070 proof never caught
it because its live-loop check calls simulate_factory(game, 1.0),
where 1.0 second and 1.0 tick coincide numerically. The fix converts
at the live-loop boundary (the N2093 pump precedent): a new
source_factory_conveyor_tick_delta_state(seconds) -> {ticks} and
simulate_factory advances the belts by ticks. After the fix the
900-tick session delivers core_copper 0 -> 4 (produced 6, the 5th
and 6th items still in transit), the drill stays boosted
(lastDrillSpeed 5.12/650 from tick 300 on), and the pump/conduit
water matches the pre-fix measurements exactly.

Java: PowerGraph.getBatteryStored/getPowerNeeded/getPowerProduced/
getTotalBatteryCapacity/distributePower; ItemModule.get(Item);
LiquidModule.get(Liquid); HealthComp.health; DrillBuild.updateTile;
PumpBuild fields; Conveyor.updateTile moved = speed * edelta();
Time.delta in ticks.

Deferred: the per-class shouldConsume() bodies
(UnitFactory.java:446, Reconstructor.java:368,
UnitAssembler.java:389); ConsumeItemDynamic.trigger plan stacks
leaving only at unit completion; UnitAssembler plan dynamics
(UnitAssembler.java:158-160); power graph shouldConsumePower from
the live frame enabled flag (Java ConsumePower.requestedPower gates
on entity.shouldConsume(); the port uses static catalog properties,
so a disable -> battery-charges act needs a separate slice);
Predict.intercept + death sweep (defense leg); pause/timeScale/
disable/removal + source-exhaustion/output-full acts.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
POWER_GRAPH = 'core/src/mindustry/world/blocks/power/PowerGraph.java'
ITEM_MODULE = 'core/src/mindustry/world/modules/ItemModule.java'
LIQUID_MODULE = 'core/src/mindustry/world/modules/LiquidModule.java'
HEALTH_COMP = 'core/src/mindustry/entities/comp/HealthComp.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
PUMP = 'core/src/mindustry/world/blocks/production/Pump.java'
CORE_BLOCK = 'core/src/mindustry/world/blocks/storage/CoreBlock.java'
CONVEYOR = 'core/src/mindustry/world/blocks/distribution/Conveyor.java'
TIME = 'arc-core/src/arc/util/Time.java'
SNAPSHOT_OWNER = 'SourceSessionSnapshotState.source_session_snapshot_state'
DELTA_OWNER = 'SourceFactoryRuntimeState.source_factory_conveyor_tick_delta_state'
PROOF = '/root/C06SessionProof'
TESTS = ['test_c06_session_snapshot_registration', 'test_all_c06_session_snapshot_input_evidence_is_exact', 'test_snapshot_reads_live_session_state', 'test_reference_graph_and_actual_c06_session_snapshot']
DEFERRED = [
    'The three per-class shouldConsume() bodies (UnitFactory.java:446, Reconstructor.java:368, UnitAssembler.java:389) are later slices; the tick passes the frame enabled flag as should_consume until then.',
    'The plan stacks leave only at unit completion via ConsumeItemDynamic.trigger (ConsumeItemDynamic.java:53-56); the per-tick second pass removes nothing for items, so the production slice owns the trigger.',
    'The UnitAssembler plan dynamics (ConsumePayloadDynamic, ConsumeItemDynamic over plan().itemReq, ConsumeLiquidsDynamic over plan().liquidReq, UnitAssembler.java:158-160) are later slices; the registry captures no assembler plans yet, so no dynamic rows bind for them.',
    'Power graph shouldConsumePower from the live frame enabled flag is a later slice: Java ConsumePower.requestedPower gates on entity.shouldConsume(), but the port uses static catalog properties, so disabling a building does not change the power graph needed value and a disable -> battery-charges act is not possible yet.',
    'Predict.intercept lead targeting and the death sweep (the defense leg) are later slices; the probe approach (spawn_enemy_unit + load_selected_turret_ammo + the four simulate calls per tick) is recorded in the N2121 handoff as the starting point.',
    'Pause/timeScale/disable/removal and source-exhaustion/output-full acts are later C06 slices.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public class PowerGraph{',
    'public float getPowerProduced(){',
    'public float getPowerNeeded(){',
    'public float getBatteryStored(){',
    'public float getTotalBatteryCapacity(){',
    'float coverage = Mathf.zero(needed) && Mathf.zero(produced) && !charged && Mathf.zero(lastPowerStored) ? 0f : Mathf.zero(needed) ? 1f : Math.min(1, produced / needed);',
    'public int get(Item item){',
    'float health;',
    'public float get(Liquid liquid){',
    'timeDrilled += warmup * delta();',
    'warmup = Mathf.approachDelta(warmup, speed, warmupSpeed);',
    'lastDrillSpeed = (speed * dominantItems * warmup) / delay;',
    'offload(dominantItem);',
    'public float getDrillTime(Item item){',
    'public float hardnessDrillMultiplier = 50f;',
    'public float warmup, totalProgress;',
    'public class CoreBlock extends StorageBlock{',
    'float moved = speed * edelta();',
    'public float edelta(){',
    'return efficiency * delta();',
    'private static Floatp deltaimpl = () -> Math.min(Core.graphics.getDeltaTime() * 60f, 3f);',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=POWER_GRAPH, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2121_snapshot_inputs = {
        'game': f('Object', 'public class PowerGraph{', 'The live game: its placed power graph, core inventory, drill/pump/conduit state are read from it.'),
    }
    n2121_snapshot_outputs = {
        'core_copper': f('int', 'public int get(Item item){', 'The core held copper (ItemModule.get), the drill output that reached the core through the belts.', source=ITEM_MODULE),
        'core_health': f('float', 'float health;', 'The core current health (HealthComp.health).', source=HEALTH_COMP),
        'battery_stored': f('float', 'public float getBatteryStored(){', 'The charge stored across the enabled batteries (status * capacity).'),
        'battery_capacity': f('float', 'public float getTotalBatteryCapacity(){', 'The total battery capacity of the placed graph.'),
        'power_needed': f('float', 'public float getPowerNeeded(){', 'The power the placed consumers need per tick (PowerGraph.getPowerNeeded).'),
        'power_produced': f('float', 'public float getPowerProduced(){', 'The power the placed producers make per tick (PowerGraph.getPowerProduced).'),
        'power_coverage': f('float', 'float coverage = Mathf.zero(needed) && Mathf.zero(produced) && !charged && Mathf.zero(lastPowerStored) ? 0f : Mathf.zero(needed) ? 1f : Math.min(1, produced / needed);', 'The distributePower coverage: 0 when needed, produced and the stored charge are all zero and nothing charged, 1 when needed is zero, else min(1, produced / needed).'),
        'drill_time_drilled': f('float', 'timeDrilled += warmup * delta();', 'The drill time drilled (DrillBuild.timeDrilled, warmup * delta per tick).', source=DRILL),
        'drill_warmup': f('float', 'warmup = Mathf.approachDelta(warmup, speed, warmupSpeed);', 'The drill warmup, approaching the boosted speed 1.6 once water arrives.', source=DRILL),
        'drill_last_speed': f('float', 'lastDrillSpeed = (speed * dominantItems * warmup) / delay;', 'The drill last drill speed ((speed * dominantItems * warmup) / delay); 5.12/650 boosted, 2/650 unboosted.', source=DRILL),
        'drill_water': f('float', 'public float get(Liquid liquid){', 'The water held in the drill liquid module (LiquidModule.get).', source=LIQUID_MODULE),
        'drill_produced_total': f('int', 'offload(dominantItem);', 'The drill offloaded items (DrillBuild offload), the production count.', source=DRILL),
        'pump_warmup': f('float', 'public float warmup, totalProgress;', 'The pump warmup (PumpBuild.warmup).', source=PUMP),
        'pump_total_progress': f('float', 'public float warmup, totalProgress;', 'The pump total progress (PumpBuild.totalProgress, warmup * delta per tick).', source=PUMP),
        'pump_water': f('float', 'public float get(Liquid liquid){', 'The water held in the pump liquid module (LiquidModule.get).', source=LIQUID_MODULE),
        'conduit_water': f('float', 'public float get(Liquid liquid){', 'The water held across the whole conduit line (LiquidModule.get per conduit cell).', source=LIQUID_MODULE),
    }
    n2121_delta_inputs = {
        'seconds': f('float', 'private static Floatp deltaimpl = () -> Math.min(Core.graphics.getDeltaTime() * 60f, 3f);', 'The live-loop delta in seconds (the Godot _process delta); Time.delta is that real delta scaled to 60fps ticks.', source=TIME),
    }
    n2121_delta_outputs = {
        'ticks': f('float', 'float moved = speed * edelta();', 'The same delta in ticks (seconds * 60), the units the belt advance moves items by.', source=CONVEYOR),
    }

    entries = [
        ('N2121', SNAPSHOT_OWNER, 'source_session_snapshot_state', POWER_GRAPH, 'mindustry.world.blocks.power.PowerGraph', 'PowerGraph.getBatteryStored(); PowerGraph.getPowerNeeded(); PowerGraph.getPowerProduced(); PowerGraph.distributePower(); ItemModule.get(Item); DrillBuild.updateTile(); PumpBuild.updateTile()', n2121_snapshot_inputs, n2121_snapshot_outputs, True, 'Dictionary'),
        ('N2121', DELTA_OWNER, 'source_factory_conveyor_tick_delta_state', CONVEYOR, 'mindustry.world.blocks.distribution.Conveyor.ConveyorBuild', 'ConveyorBuild.updateTile()', n2121_delta_inputs, n2121_delta_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2029 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed C06 session snapshot and live-loop belt tick conversion.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed C06 session snapshot: one pure read of the live session inventory, health, production and energy, so the session proof verifies the factory -> core -> defense chain before/after a fixed number of deterministic live-loop ticks; and the live-loop belt tick conversion, so simulate_factory advances the belts by ticks (seconds * 60) and copper reaches the core.'))
        all_names.extend(names)

    by_slice['N2121'] = sorted(all_names)
    # One slice row: the snapshot is the primary owner; the belt tick
    # conversion shares the slice (its symbols carry their own owner).
    # simulate_factory itself has no contract; the one-line call-site
    # change that feeds the conversion into the advance folds into
    # this slice (the wiring the new function exists for).
    source_symbols.upsert_source_slice(GODOT, 'N2121', dict(status='done', java_source=POWER_GRAPH, java_class='mindustry.world.blocks.power.PowerGraph', java_method='PowerGraph.getBatteryStored(); PowerGraph.getPowerNeeded(); PowerGraph.getPowerProduced(); PowerGraph.distributePower(); ItemModule.get(Item); DrillBuild.updateTile(); PumpBuild.updateTile(); ConveyorBuild.updateTile()', godot_owner=SNAPSHOT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
