"""Register the ImpactReactor consume live read (N2187).

The consume side N2182/N2186 explicitly deferred (N2186 handoff
Documented limits / Deferred): ImpactReactorBuild.updateTile burns
blast-compound on a timer INSIDE the warmup hard gate
(ImpactReactor.java:91-92, `if(timer(timerUse, itemDuration /
timeScale)){` / `consume();`) and drains cryofluid continuously
whenever efficiency > 0 (ConsumeLiquid.java:37-39, `build.liquids
.remove(liquid, amount * build.edelta() * multiplier.get(build));`,
0.25f x edelta per tick). N2182 folded only the consumer-side
power.status row; N2186 added the warmup advance + the live
production read; N2187 adds the burn + the drain on the same family
file, the same driver and the same frame -- no new file, no new
driver.

RED decisions (the 4 open scoping questions, resolved at RED):
1. Timer stamp: a per-frame ACCUMULATOR `consume_timer` reset to 0
on fire -- overshoot is dropped, exactly like `Interval.get`
stamping the absolute game time (Interval.java, `if(got)
times[id] = Time.time;`); NOT subtract-the-interval (that would
carry overshoot and drift the burn cadence vs Java). The global-time
wrap case (`Time.time < times[id]`, Interval.java check) is not
modeled -- documented as negligible. A zero time_scale makes the
interval infinite, and `timer()` returns false on infinite time
(TimerComp.java:11), so the timer never fires at time_scale 0.
2. Frame keys: the reactor frame carries NO items / liquids /
time_scale keys yet (verified at RED: the driver stamps only
block_implementation / team_id / rules_state / cheating / enabled /
efficiency / efficiency_scale / power_status / warmup /
production_efficiency / total_progress / power_production) -- GREEN
stamps `items` (dict, the Building.items precedent, frame["items"]
in SourceUnitFactoryBuildState.gd), `liquids` (dict, the
SourcePlacedBlockState.gd {"liquids": ...} precedent), `time_scale`
(float, default 1.0, the source_placed_block_state.time_scale
precedent) and `consume_timer` (float, default 0.0) in the EXISTING
driver, the N2186 precedent; the driver stamps all five result keys
onto the frame, the N2186 precedent.
3. Proof keys: burn -1 per 140s inside the gate / no burn outside
the gate / cryofluid 0.25f x edelta per tick while efficiency > 0 /
no drain when disabled or efficiency 0. Synthetic frames + pure
function with a pre-advanced timer stamp (consume_timer = 139.9 +
delta 0.2 fires once, -1 blast-compound, timer back to 0); no long
live tick.
4. consumeTriggerValid() interplay: the default is false
(BuildingComp.java:764-766), so ConsumeItems.efficiency is 1 iff
the building has the blast-compound (ConsumeItems.java:52) -- the
burn assumes the hard gate held (folded efficiency >= 0.9999
already implies the item was present); the pure function burns
unconditionally on timer fire inside the gate, matching
ConsumeItems.trigger, which removes unconditionally (ItemModule.
remove clamps at the stock on hand, ItemModule.java:259);
folding the item row into the driver's min efficiency waits for its
own slice. The drain is NOT gated on the warmup hard gate -- it
runs whenever shouldConsume() && productionValid() and the folded
efficiency > 0 (BuildingComp.java:1960, 1997-2000); the pure
function takes the folded efficiency + enabled from the frame.
Both removes clamp at the stock on hand (ItemModule.remove,
LiquidModule.remove), so neither dict ever goes negative.

Composition, not re-implementation: the shared efficiency machinery
(SourceBuildingEfficiencyState.update_consumption_state) already
folds the N2182 power row into the min efficiency, and the N2182
driver already ticks placed reactors and folds it; N2187 does not
touch either. N2187 supplies the missing burn + drain: one pure
function (source_impact_reactor_consume_state, frame + delta ->
{"blast_compound_burned", "cryofluid_drained", "consume_timer",
"items", "liquids"}), stamped onto the frame by the existing driver
after the consumption fold. The burn gate reads the folded
efficiency, so a reactor that cannot draw its 25f never burns; the
drain reads the same folded efficiency, so a reactor at efficiency
0 drains nothing. Single def (impact-reactor, itemDuration 140f,
Blocks.java:2637; consumeItem blast-compound, Blocks.java:2643;
consumeLiquid cryofluid 0.25f, Blocks.java:2644; liquidCapacity
80f, Blocks.java:2640). No family split: the impact reactor is the
ONLY ImpactReactor def (Blocks.java:2632).
"""


import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_impact_reactor_power_production import DEFERRED as N2186_DEFERRED
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
IMPACT_REACTOR = 'core/src/mindustry/world/blocks/power/ImpactReactor.java'
TIMER_COMP = 'core/src/mindustry/entities/comp/TimerComp.java'
INTERVAL = 'arc-core/src/arc/util/Interval.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
CONSUME_ITEMS = 'core/src/mindustry/world/consumers/ConsumeItems.java'
CONSUME_LIQUID = 'core/src/mindustry/world/consumers/ConsumeLiquid.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
ITEM_MODULE = 'core/src/mindustry/world/modules/ItemModule.java'
LIQUID_MODULE = 'core/src/mindustry/world/modules/LiquidModule.java'
PROOF = '/root/C07ImpactReactorConsumeProof'
OWNER = 'SourceImpactReactorBuildState.source_impact_reactor_consume_state'
TESTS = ['test_c07_impact_reactor_consume_registration', 'test_all_c07_impact_reactor_consume_input_evidence_is_exact', 'test_impact_reactor_consume_state', 'test_reference_graph_and_actual_c07_impact_reactor_consume']
EXACT_EXPRS = ['if(efficiency >= 0.9999f && power.status >= 0.99f){', 'if(timer(timerUse, itemDuration / timeScale)){', 'consume();', 'public final int timerUse = timers++;', 'transient Interval timer = new Interval(6);', 'public boolean timer(int index, float time){', 'if(Float.isInfinite(time)) return false;', 'return timer.get(index, time);', 'boolean got = check(id, time);', 'if(got) times[id] = Time.time;', 'return Time.time - times[id] >= time || Time.time < times[id];', 'public void consume(){', 'for(Consume cons : block.consumers){', 'cons.trigger(self());', 'public void trigger(Building build){}', 'public void trigger(Building build){', 'build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', 'return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;', 'public boolean consumeTriggerValid(){', 'public ConsumeItems consumeItem(Item item){', 'return consumeItem(item, 1);', 'consumeItem(Items.blastCompound);', 'consumeLiquid(Liquids.cryofluid, 0.25f);', 'itemDuration = 140f;', 'liquidCapacity = 80f;', 'public void update(Building build){', 'build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', 'public float edelta(){', 'return efficiency * delta();', 'return Time.delta * timeScale;', 'if(update && efficiency > 0){', 'for(var cons : block.updateConsumers){', 'cons.update(self());', 'public boolean update = true;', 'public Floatf<Building> multiplier = b -> 1f;', 'public boolean shouldConsume(){', 'return enabled;', 'boolean update = shouldConsume() && productionValid();', 'public boolean productionValid(){', 'if(!update){', 'amount = Math.min(amount, items[item.id]);', '//cap to prevent negative removal']
DEFERRED = list(N2186_DEFERRED) + [
    'ImpactReactor consume timer wrap case (Interval.check returns true when Time.time < times[id], Interval.java -- a global time reset) -- the port accumulator models the stamp reset (consume_timer = 0 on fire, overshoot dropped) but does not model the wrap; documented as negligible, not a drift source in normal play.',
    'ImpactReactor ConsumeItems.efficiency item-presence fold (items.has blast-compound, ConsumeItems.java:52) in the reactor driver fold -- the burn assumes the hard gate held (folded efficiency >= 0.9999 already implies the item was present); folding the item row into the driver min efficiency waits for its own slice.',
    'ImpactReactor ConsumeLiquid.efficiency liquid-presence fold (liquids.get(cryofluid) / (0.25f * ed) capped at 1, ConsumeLiquid.java:41-46) in the reactor driver fold -- the drain assumes efficiency > 0 and clamps at the stock on hand; folding the liquid row into the driver min efficiency waits for its own slice.',
    'ImpactReactor Windows Godot proof -- debt in GOAL.md section 5, same as N2182-N2186: the N2187 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=IMPACT_REACTOR, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2187_inputs = {
        'frame': f('Dictionary', 'if(efficiency >= 0.9999f && power.status >= 0.99f){', 'The impact-reactor frame carrying the folded efficiency (set by update_consumption_state earlier in the same tick), the live power.status (stamped by the N2142 graph update), the items / liquids dicts, the consume_timer accumulator and the time_scale (all stamped by the driver, the N2186 precedent); null stamps fold to the assembler defaults (efficiency 1.0, power.status 1.0, time_scale 1.0, consume_timer 0.0).'),
        'delta': f('float', 'return Time.delta * timeScale;', 'The tick delta (Time.delta): the timer accumulator advances by delta and the cryofluid drain is 0.25f x edelta per tick, edelta = efficiency * Time.delta * timeScale.'),
    }
    n2187_outputs = {
        'blast_compound_burned': f('int', 'build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', 'The blast-compound burned this tick (ConsumeItems.java:46, consumeItem defaults to amount 1, Block.java:1167-1168, multiplier default 1f, Consume.java:18): 1 when the timer fires inside the hard gate and stock is on hand, 0 otherwise; ItemModule.remove clamps at the stock (ItemModule.java:259).', source=CONSUME_ITEMS),
        'cryofluid_drained': f('float', 'build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', 'The cryofluid drained this tick (ConsumeLiquid.java:38): 0.25f x efficiency x delta x time_scale while enabled and efficiency > 0 (BuildingComp.java:1997-2000, second pass), 0f when disabled or efficiency 0; LiquidModule.remove caps to prevent negative removal (LiquidModule.java:126).', source=CONSUME_LIQUID),
        'consume_timer': f('float', 'if(got) times[id] = Time.time;', 'The timer accumulator after this tick (Interval.java: stamp reset to absolute game time on fire, overshoot dropped): seconds since the last burn, reset to 0 when the timer fires, never carrying overshoot.', source=INTERVAL),
        'items': f('Dictionary', 'build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', 'The updated items dict after the burn (ConsumeItems.java:46): blast-compound decremented by the burn, clamped at 0 by ItemModule.remove (ItemModule.java:259).', source=CONSUME_ITEMS),
        'liquids': f('Dictionary', 'build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', 'The updated liquids dict after the drain (ConsumeLiquid.java:38): cryofluid decremented by the drain, capped at 0 by LiquidModule.remove (LiquidModule.java:126).', source=CONSUME_LIQUID),
    }

    entries = [
        ('N2187', OWNER, 'source_impact_reactor_consume_state', IMPACT_REACTOR, 'mindustry.world.blocks.power.ImpactReactor.ImpactReactorBuild', 'ImpactReactorBuild.updateTile()', n2187_inputs, n2187_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ImpactReactor blast-compound timer burn + cryofluid continuous drain from ImpactReactor.java / ConsumeItems.java / ConsumeLiquid.java / Interval.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ImpactReactor blast-compound timer burn + cryofluid continuous drain from ImpactReactor.java / ConsumeItems.java / ConsumeLiquid.java / Interval.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: blast_compound_burned,
    # cryofluid_drained, consume_timer, then items, then liquids.
    by_slice['N2187'] = [
        'source_impact_reactor_consume_state_result.blast_compound_burned',
        'source_impact_reactor_consume_state_result.cryofluid_drained',
        'source_impact_reactor_consume_state_result.consume_timer',
        'source_impact_reactor_consume_state_result.items',
        'source_impact_reactor_consume_state_result.liquids',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2187', dict(status='done', java_source=IMPACT_REACTOR, java_class='mindustry.world.blocks.power.ImpactReactor.ImpactReactorBuild', java_method='ImpactReactorBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2187'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
