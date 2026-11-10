"""Register the GenericCrafter dumpOutputs() live-loop slice (N2119).

N2118 wired the warmup / continuous liquid output / totalProgress
half of GenericCrafterBuild.updateTile() (GenericCrafter.java:235-266)
but the tick still ended at the craft check: a factory kept its
outputs forever -- N2117's craft proof even notes "keeps its output
until a belt takes it (dumpOutputs is a later slice)". N2119 is the
third C06 slice and wires dumpOutputs() (GenericCrafter.java:317-332),
called unconditionally at the end of updateTile
(GenericCrafter.java:263):

- the item half fires on the dump timer: outputItems != null and
  timer(timerDump, dumpTime / timeScale) (GenericCrafter.java:319),
  then dump(output.item) once per output row. timerDump is the
  Block timer slot (Block.java:436 `protected final int
  timerDump = timers++;`); dumpTime is Block.dumpTime, 5
  (Block.java:438), unless a block overrides it (none does);
  timeScale is the building time scale, 1f by default
  (BuildingComp.java:98). TimerComp.timer (TimerComp.java:10-13)
  returns false for an infinite interval and otherwise
  timer.get(index, time): Interval.get stamps times[id] =
  Time.time when it fires, so the elapsed timer resets to 0, and
  Time.time advances in seconds, so the port accumulates Godot
  delta seconds.
- dump(item) is BuildingComp.dump (BuildingComp.java:1072-1105):
  it returns false when the block has no items, the module is
  empty, there is no proximity, or the item is not held, and
  otherwise offers the item to each proximity building in cdump
  order (acceptItem && canDump -> handleItem, one item removed)
  and advances cdump per neighbor checked. The port reuses the
  accepted drill dump composition
  (SourceBuildingItemDumpState.source_drill_dump_step_state), the
  same one the N2117 offload uses, but with the frame's own item
  module: a dumped item leaves the frame, a refused one stays.
- the liquid half runs every tick, with no timer gate: for each
  output liquid, dir = liquidOutputDirections[i] when the
  directions array covers the row, else -1, then
  dumpLiquid(output.liquid, 2f, dir) (GenericCrafter.java:324-330).
  liquidOutputDirections defaults to {-1} (GenericCrafter.java:34);
  the electrolyzer overrides it to {1, 3} (Blocks.java:1395), so
  ozone dumps north and hydrogen south. dumpLiquid(liquid, scaling,
  outputDir) (BuildingComp.java:886-908) returns when the building
  holds <= 0.0001, skips neighbors whose (outputDir + rotation) % 4
  is not their relativeTo, and transfers (fract - ofract) *
  liquidCapacity / scaling to each neighbor whose fraction is
  lower, through transferLiquid (BuildingComp.java:916-926: flow =
  min(next capacity - held, amount), guarded by acceptLiquid).
  The port reuses SourceBuildingLiquidState.dump_liquid_state, the
  same composition the pump dump uses, over the factory's proximity
  ring; only conduit neighbors are dump destinations in this slice
  (the pump's rule: conduit liquidCapacity 20, Blocks.java:2322-2327;
  a factory neighbor does not acceptLiquid a foreign output liquid
  under BuildingComp.acceptLiquid).

Java: BuildingComp.delta() = Time.delta * timeScale and edelta() =
efficiency * delta() (BuildingComp.java:1922-1929); the port edelta
convention is seconds * TICK_RATE. The cryofluid mixer outputs
cryofluid 12f/60f per tick (Blocks.java:1170) into a 36.0 liquid
capacity; the electrolyzer outputs ozone 4f/60 and hydrogen 6f/60
(Blocks.java:1394).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
GENERIC_CRAFTER = 'core/src/mindustry/world/blocks/production/GenericCrafter.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
TIMER_COMP = 'core/src/mindustry/entities/comp/TimerComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
TICK_OWNER = 'SourceFactoryBuildState.source_factory_tick_buildings_state'
PROOF = '/root/C06FactoryDumpOutputsProof'
TESTS = ['test_factory_dump_outputs_registration', 'test_all_factory_dump_outputs_input_evidence_is_exact', 'test_tick_dumps_outputs', 'test_reference_graph_and_actual_c06_factory_dump_outputs_gate']
DEFERRED = [
    'HeatCrafterBuild.warmupTarget() (HeatCrafter.java:70-72, Mathf.clamp(heat / heatRequirement)) is deferred: the frame carries no heat state yet, so a heat crafter takes the GenericCrafter default 1f until the heat slice lands.',
    'The updateEffect chance branch (GenericCrafter.java:247-249) is not wired: it is a visual effect only.',
    'Liquid dump destinations other than conduits are deferred: a neighboring factory does not acceptLiquid a foreign output liquid (BuildingComp.acceptLiquid), and other liquid blocks have no port accept rule yet.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public void dumpOutputs(){',
    'dumpOutputs();',
    'if(outputItems != null && timer(timerDump, dumpTime / timeScale)){',
    'for(ItemStack output : outputItems){',
    'dump(output.item);',
    'if(outputLiquids != null){',
    'for(int i = 0; i < outputLiquids.length; i++){',
    'int dir = liquidOutputDirections.length > i ? liquidOutputDirections[i] : -1;',
    'dumpLiquid(outputLiquids[i].liquid, 2f, dir);',
    'public int[] liquidOutputDirections = {-1};',
    'liquidOutputDirections = new int[]{1, 3};',
    'public int dumpTime = 5;',
    'protected final int timerDump = timers++;',
    'public boolean timer(int index, float time){',
    'if(Float.isInfinite(time)) return false;',
    'return timer.get(index, time);',
    'public void dumpLiquid(Liquid liquid, float scaling, int outputDir){',
    'if(liquids.get(liquid) <= 0.0001f) return;',
    'if(outputDir != -1 && (outputDir + rotation) % 4 != relativeTo(other)) continue;',
    'float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;',
    'float fract = liquids.get(liquid) / block.liquidCapacity;',
    'if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);',
    'public boolean dump(Item todump){',
    'if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;',
    'public void transferLiquid(Building next, float amount, Liquid liquid){',
    'float flow = Math.min(next.block.liquidCapacity - next.liquids.get(liquid), amount);',
    'int dump = this.cdump;',
    'outputLiquids = LiquidStack.with(Liquids.ozone, 4f / 60, Liquids.hydrogen, 6f / 60);',
    'outputLiquid = new LiquidStack(Liquids.cryofluid, 12f / 60f);',
    'return Time.delta * timeScale;',
    'private transient float timeScale = 1f, timeScaleDuration;',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=GENERIC_CRAFTER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2119_dump_interval_inputs = {
        'dump_time': f('float', 'public int dumpTime = 5;', 'Block.dumpTime, 5 unless the block overrides it (none does).', source=BLOCK),
        'time_scale': f('float', 'private transient float timeScale = 1f, timeScaleDuration;', 'The building time scale, 1f by default.', source=BUILDING_COMP),
    }
    n2119_dump_interval_outputs = {
        'dump_interval': f('float', 'if(outputItems != null && timer(timerDump, dumpTime / timeScale)){', 'dumpTime / timeScale seconds between item dumps.'),
    }

    n2119_dump_timer_inputs = {
        'dump_timer': f('float', 'return timer.get(index, time);', 'The seconds since the dump timer last fired (Interval times[timerDump], Time.time - times[id]).', source=TIMER_COMP),
        'seconds': f('float', 'public boolean timer(int index, float time){', 'The frame delta in seconds; Interval.get compares Time.time, which advances in seconds.', source=TIMER_COMP),
        'dump_time': f('float', 'public int dumpTime = 5;', 'Block.dumpTime, 5 unless the block overrides it (none does).', source=BLOCK),
        'time_scale': f('float', 'private transient float timeScale = 1f, timeScaleDuration;', 'The building time scale, 1f by default.', source=BUILDING_COMP),
    }
    n2119_dump_timer_outputs = {
        'dump_timer': f('float', 'return timer.get(index, time);', '0.0 when the timer fired (Interval.get stamps times[id] = Time.time), else the accumulated seconds.', source=TIMER_COMP),
        'should_dump': f('bool', 'if(Float.isInfinite(time)) return false;', 'Whether the interval elapsed; an infinite interval never fires.', source=TIMER_COMP),
        'dump_interval': f('float', 'if(outputItems != null && timer(timerDump, dumpTime / timeScale)){', 'dumpTime / timeScale seconds between item dumps.'),
    }

    n2119_dump_liquid_inputs = {
        'game': f('Object', 'public void dumpLiquid(Liquid liquid, float scaling, int outputDir){', 'The live game: the proximity ring and the conduit neighbors are read from it.', source=BUILDING_COMP),
        'cell': f('Vector2i', 'if(outputDir != -1 && (outputDir + rotation) % 4 != relativeTo(other)) continue;', "The building's cell; the proximity ring is computed from it and relativeTo is read off it.", source=BUILDING_COMP),
        'block': f('Object', 'public void dumpLiquid(Liquid liquid, float scaling, int outputDir){', 'The typed block definition; its liquidCapacity and liquidOutputDirections are what the dump routes by.', source=BUILDING_COMP),
        'liquids': f('Dictionary', 'if(liquids.get(liquid) <= 0.0001f) return;', "The building's liquid module the dumped liquid is removed from.", source=BUILDING_COMP),
        'liquid_ids': f('Dictionary', 'outputLiquid = new LiquidStack(Liquids.cryofluid, 12f / 60f);', 'The catalog name-to-id map: the liquid module is id-indexed, so the output liquid name resolves to an id through it.', source=BLOCKS),
        'liquid_name': f('String', 'dumpLiquid(outputLiquids[i].liquid, 2f, dir);', 'The output liquid name, one row of outputLiquids per tick.'),
        'output_dir': f('int', 'int dir = liquidOutputDirections.length > i ? liquidOutputDirections[i] : -1;', 'The output direction for this liquid row, else -1 for any direction.'),
    }
    n2119_dump_liquid_outputs = {
        'liquid': f('String', 'dumpLiquid(outputLiquids[i].liquid, 2f, dir);', 'The liquid dumped.'),
        'amount_dumped': f('float', 'if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);', 'How much left the building module this tick.', source=BUILDING_COMP),
        'liquid_amount': f('float', 'float fract = liquids.get(liquid) / block.liquidCapacity;', 'What the building still holds after the dump.', source=BUILDING_COMP),
        'dump_cursor': f('int', 'int dump = this.cdump;', 'The dump cursor after the routing pass.', source=BUILDING_COMP),
    }

    n2119_dump_outputs_inputs = {
        'game': f('Object', 'public boolean dump(Item todump){', 'The live game: the proximity ring and the conveyor queues are read from it.', source=BUILDING_COMP),
        'frame': f('Dictionary', 'public void dumpOutputs(){', "The factory frame; its dumpTimer accumulates, its cdump cursor advances, and its items lose what a neighbor takes."),
        'cell': f('Vector2i', 'dump(output.item);', "The building's cell; the proximity ring is computed from it."),
        'block': f('Object', 'if(outputItems != null && timer(timerDump, dumpTime / timeScale)){', 'The typed block definition; its outputItems / outputLiquids rows are what the dump loops over.'),
        'liquids': f('Dictionary', 'if(liquids.get(liquid) <= 0.0001f) return;', "The building's liquid module the dumped liquids are removed from.", source=BUILDING_COMP),
        'liquid_ids': f('Dictionary', 'outputLiquids = LiquidStack.with(Liquids.ozone, 4f / 60, Liquids.hydrogen, 6f / 60);', 'The catalog name-to-id map: the liquid module is id-indexed, so the output liquid names resolve to ids through it.', source=BLOCKS),
        'seconds': f('float', 'public boolean timer(int index, float time){', 'The frame delta in seconds; the dump timer accumulates Time.time seconds.', source=TIMER_COMP),
        'time_scale': f('float', 'private transient float timeScale = 1f, timeScaleDuration;', 'The building time scale; the dump interval is dumpTime / timeScale.', source=BUILDING_COMP),
    }
    n2119_dump_outputs_outputs = {
        'item_dump_fired': f('bool', 'if(outputItems != null && timer(timerDump, dumpTime / timeScale)){', 'Whether the dump timer fired this tick.'),
        'dumped_items': f('Array', 'dump(output.item);', 'The output items dumped this tick, one per output row a neighbor took.'),
        'dumped_liquids': f('Dictionary', 'dumpLiquid(outputLiquids[i].liquid, 2f, dir);', 'What each output liquid lost to its dump this tick.'),
        'dump_timer': f('float', 'return timer.get(index, time);', 'The dump timer after this tick: 0.0 when it fired, else the accumulated seconds.', source=TIMER_COMP),
        'cdump_after': f('int', 'int dump = this.cdump;', 'The dump cursor after the routing passes.', source=BUILDING_COMP),
        'items_after': f('Dictionary', 'if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;', "The frame's item module after the dumps.", source=BUILDING_COMP),
        'liquids_after': f('Dictionary', 'if(liquids.get(liquid) <= 0.0001f) return;', 'The liquid module after the dumps.', source=BUILDING_COMP),
    }

    entries = [
        ('N2119', 'SourceFactoryBuildState.source_factory_dump_interval_state', 'source_factory_dump_interval_state', GENERIC_CRAFTER, 'mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', 'GenericCrafterBuild.dumpOutputs()', n2119_dump_interval_inputs, n2119_dump_interval_outputs, True, 'Dictionary'),
        ('N2119', 'SourceFactoryBuildState.source_factory_dump_timer_state', 'source_factory_dump_timer_state', GENERIC_CRAFTER, 'mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', 'GenericCrafterBuild.dumpOutputs()', n2119_dump_timer_inputs, n2119_dump_timer_outputs, True, 'Dictionary'),
        ('N2119', 'SourceFactoryBuildState.source_factory_dump_liquid_state', 'source_factory_dump_liquid_state', GENERIC_CRAFTER, 'mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', 'GenericCrafterBuild.dumpOutputs()', n2119_dump_liquid_inputs, n2119_dump_liquid_outputs, True, 'Dictionary'),
        ('N2119', 'SourceFactoryBuildState.source_factory_dump_outputs_state', 'source_factory_dump_outputs_state', GENERIC_CRAFTER, 'mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', 'GenericCrafterBuild.dumpOutputs()', n2119_dump_outputs_inputs, n2119_dump_outputs_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed GenericCrafter dumpOutputs() live-loop slice.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed GenericCrafter dumpOutputs() live-loop slice.'))
        all_names.extend(names)

    # The live-loop tick driver (N2110) gains the dumpOutputs half
    # (N2113 pattern: deepcopy the existing contract and extend its
    # rule and tests, keeping the N2110 source_slice the driver
    # itself was registered under; the game+seconds params are
    # unchanged, so no new tick symbols).
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    tick_contract = copy.deepcopy(contracts[TICK_OWNER])
    tick_contract['tests'] = sorted(set(tick_contract['tests']) | set(TESTS))
    tick_contract['rule'] = 'Source-backed factory family live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live rules every simulate_factory tick, so a cheating team\'s factory counts everything as valid in updateConsumption, and the tick binds one RuntimeConsumer per consumeItem/consumeLiquid row and runs the bound actors through updateConsumption so the placed factory consumes its liquid rows each tick and gates efficiency on its item rows, with shouldConsume() read live from the output space every tick so a factory with a full output ticks at efficiency 0, and with efficiency above zero the progress climbs by getProgressIncrease(craftTime) and a completed progress crafts (consume + offload), and the tick also approaches warmup toward warmupTarget() at warmupSpeed, handles each output liquid once per tick at getProgressIncrease(1f) capped at the remaining liquid capacity, and banks warmup * Time.delta into totalProgress every tick before the craft check, and the tick ends by dumping outputs: the item rows dump to a belt neighbor when the dump timer (dumpTime / timeScale, 5 seconds by default) fires, and each output liquid dumps to its conduit neighbors at scaling 2 in its liquidOutputDirections direction every tick.'
    source_symbols.upsert_source_api_contract(GODOT, TICK_OWNER, tick_contract)

    by_slice['N2119'] = sorted(all_names)
    # One slice row: the tick driver is the primary owner (the
    # dumpOutputs half is wired into it); the four new functions are
    # registered under it.
    source_symbols.upsert_source_slice(GODOT, 'N2119', dict(status='done', java_source=GENERIC_CRAFTER, java_class='mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', java_method='GenericCrafterBuild.dumpOutputs(); GenericCrafterBuild.updateTile(); BuildingComp.dumpLiquid(Liquid, float, int); BuildingComp.dump(Item); BuildingComp.transferLiquid(Building, float, Liquid); TimerComp.timer(int, float)', godot_owner=TICK_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
    # The emitter change in this slice adds liquidOutputDirections
    # to the GenericCrafter family in content_registry.py, and the
    # emitter's own main regenerates the canonical
    # content_registry.json from it; the blocks shard mirror is
    # rebuilt here (the N2114 lesson: a stale mirror fails the
    # gate).
    source_ssot.write_registered_json(GODOT, 'content_registry_blocks', source_ssot.build_extension_shard(GODOT, 'content_registry_blocks'))


if __name__ == '__main__':
    main()
