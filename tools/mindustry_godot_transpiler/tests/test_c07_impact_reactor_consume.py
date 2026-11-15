import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
IMPACT_REACTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceImpactReactorBuildState.gd'
IMPACT_REACTOR_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorConsumeProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07ImpactReactorConsumeTests(unittest.TestCase):
    def test_c07_impact_reactor_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2187']['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_consume_state')
        # N2182 folded the consumer-side power.status row for the
        # impact reactor (impact-reactor, consumePower 25f,
        # Blocks.java:2642) and N2186 modeled the warmup advance +
        # the live production read -- but the fuel that keeps it
        # warm waited for its own slice: ImpactReactorBuild.updateTile
        # burns blast-compound on a timer INSIDE the warmup hard gate
        # (ImpactReactor.java:91-92, `if(timer(timerUse, itemDuration
        # / timeScale)){` / `consume();`) and drains cryofluid
        # continuously whenever efficiency > 0 (ConsumeLiquid.java:37-39,
        # `build.liquids.remove(liquid, amount * build.edelta() *
        # multiplier.get(build));`, 0.25f x edelta per tick). Without
        # this slice the port would warm up and produce 130f forever
        # while Java burns 1 blast-compound every 140s and drains its
        # cryofluid tank. N2187 is the consume side: one pure function
        # (frame + delta -> {"blast_compound_burned",
        # "cryofluid_drained", "consume_timer", "items", "liquids"})
        # on the same family file N2182/N2186 built, advanced by the
        # SAME driver (source_impact_reactor_tick_buildings_state, the
        # placed-reactor tick) after the consumption fold, stamped
        # onto the same frame -- no new file, no new driver. RED
        # decisions (resolved at RED, recorded in the register
        # docstring): (1) the timer is a per-frame ACCUMULATOR
        # reset to 0 on fire (overshoot dropped, exactly like
        # Interval.get stamping Time.time, Interval.java: `if(got)
        # times[id] = Time.time;`) -- NOT subtract-the-interval
        # (that would carry overshoot and drift the burn cadence vs
        # Java); the global-time wrap case (`Time.time < times[id]`,
        # Interval.java check) is not modeled, documented as
        # negligible. (2) The reactor frame carries NO items /
        # liquids / time_scale keys yet (verified at RED: the driver
        # stamps only block_implementation / team_id / rules_state /
        # cheating / enabled / efficiency / efficiency_scale /
        # power_status / warmup / production_efficiency /
        # total_progress / power_production) -- GREEN stamps `items`
        # (dict, the Building.items precedent, frame["items"] in
        # SourceUnitFactoryBuildState.gd), `liquids` (dict, the
        # SourcePlacedBlockState.gd {"liquids": ...} precedent),
        # `time_scale` (float, default 1.0, the
        # source_placed_block_state.time_scale precedent) and
        # `consume_timer` (float, default 0.0) in the EXISTING
        # driver, the N2186 precedent. (3) The proof drives the pure
        # function with synthetic frames and a pre-advanced timer
        # stamp (no long live tick: consume_timer = 139.9 + delta
        # 0.2 fires once, -1 blast-compound, timer back to 0).
        # (4) consumeTriggerValid() interplay: the default is false
        # (BuildingComp.java:764-766), so ConsumeItems.efficiency is
        # 1 iff the building has the blast-compound
        # (ConsumeItems.java:52) -- the burn assumes the hard gate
        # held (folded efficiency >= 0.9999 already implies the item
        # was present); the pure function burns unconditionally on
        # timer fire inside the gate, matching ConsumeItems.trigger,
        # which removes unconditionally (ItemModule.remove clamps at
        # the stock on hand, ItemModule.java:259); folding the item
        # row into the driver's min efficiency waits for its own
        # slice. Frame keys are snake_case, the port's frame-key
        # convention: `items`, `liquids`, `time_scale`,
        # `consume_timer`, `blast_compound_burned`,
        # `cryofluid_drained`. The family has a SINGLE def:
        # impact-reactor is the only ImpactReactor
        # (Blocks.java:2632) -- there is no second ImpactReactor
        # def to split from. Five new result symbols: the burn
        # count, the drained amount, the timer accumulator, and the
        # updated item / liquid dicts.
        self.assertEqual(
            ledger['N2187']['source_symbols'],
            [
                'source_impact_reactor_consume_state_result.blast_compound_burned',
                'source_impact_reactor_consume_state_result.cryofluid_drained',
                'source_impact_reactor_consume_state_result.consume_timer',
                'source_impact_reactor_consume_state_result.items',
                'source_impact_reactor_consume_state_result.liquids',
            ],
        )
        for name in ledger['N2187']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumeItems.java',
                    'core/src/mindustry/world/consumers/ConsumeLiquid.java',
                    'arc-core/src/arc/util/Interval.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_impact_reactor_consume_state_result.blast_compound_burned': 'SourceImpactReactorBuildState.source_impact_reactor_consume_state',
                    'source_impact_reactor_consume_state_result.cryofluid_drained': 'SourceImpactReactorBuildState.source_impact_reactor_consume_state',
                    'source_impact_reactor_consume_state_result.consume_timer': 'SourceImpactReactorBuildState.source_impact_reactor_consume_state',
                    'source_impact_reactor_consume_state_result.items': 'SourceImpactReactorBuildState.source_impact_reactor_consume_state',
                    'source_impact_reactor_consume_state_result.liquids': 'SourceImpactReactorBuildState.source_impact_reactor_consume_state',
                }[name])
        self.assertEqual(ledger['N2187']['runtime_proof'], '/root/C07ImpactReactorConsumeProof')
        self.assertEqual(
            ledger['N2187']['tests'],
            [
                'test_c07_impact_reactor_consume_registration',
                'test_all_c07_impact_reactor_consume_input_evidence_is_exact',
                'test_impact_reactor_consume_state',
                'test_reference_graph_and_actual_c07_impact_reactor_consume',
            ],
        )
        self.assertTrue(ledger['N2187']['deferred_exprs'])

    def test_all_c07_impact_reactor_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2187']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_impact_reactor_consume_state_result.blast_compound_burned': 'SourceImpactReactorBuildState.source_impact_reactor_consume_state',
                    'source_impact_reactor_consume_state_result.cryofluid_drained': 'SourceImpactReactorBuildState.source_impact_reactor_consume_state',
                    'source_impact_reactor_consume_state_result.consume_timer': 'SourceImpactReactorBuildState.source_impact_reactor_consume_state',
                    'source_impact_reactor_consume_state_result.items': 'SourceImpactReactorBuildState.source_impact_reactor_consume_state',
                    'source_impact_reactor_consume_state_result.liquids': 'SourceImpactReactorBuildState.source_impact_reactor_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/power/ImpactReactor.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'arc-core/src/arc/util/Interval.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2187']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_impact_reactor_consume_state(self):
        impact_reactor = IMPACT_REACTOR_STATE.read_text(encoding='utf-8')
        # The consume side lives on the same impact-reactor build
        # state N2182/N2186 built: the pure function burns
        # blast-compound on a timer INSIDE the warmup hard gate
        # (ImpactReactor.java:79, `if(efficiency >= 0.9999f &&
        # power.status >= 0.99f){`, keep on ONE comment line, the
        # N2148 shootWarmup lesson: a split line fails this test)
        # -- `if(timer(timerUse, itemDuration / timeScale)){`
        # (ImpactReactor.java:91) with `consume();`
        # (ImpactReactor.java:92). `Building.consume()`
        # (BuildingComp.java:1911-1915, `public void consume(){` /
        # `for(Consume cons : block.consumers){` /
        # `cons.trigger(self());`) iterates the block's consumers
        # and triggers each; `Consume.trigger()` default is a no-op
        # (Consume.java:50, `public void trigger(Building
        # build){}`), so only `ConsumeItems.trigger` fires
        # (ConsumeItems.java:44-48, `public void trigger(Building
        # build){` / `build.items.remove(stack.item,
        # Math.round(stack.amount * multiplier.get(build)));`) --
        # `consumeItem(item)` defaults to amount 1 (Block.java:1167-1168,
        # `public ConsumeItems consumeItem(Item item){` / `return
        # consumeItem(item, 1);`), multiplier default 1f
        # (Consume.java:18, `public Floatf<Building> multiplier = b
        # -> 1f;`) -- so -1 blast-compound per timer fire
        # (Blocks.java:2643, `consumeItem(Items.blastCompound);`,
        # with `itemDuration = 140f;`, Blocks.java:2637). The timer
        # slot is `public final int timerUse = timers++;`
        # (ImpactReactor.java:18) on a per-building `Interval(6)`
        # (`transient Interval timer = new Interval(6);`,
        # TimerComp.java:8); `timer()` (TimerComp.java:10-12,
        # `public boolean timer(int index, float time){` /
        # `if(Float.isInfinite(time)) return false;` / `return
        # timer.get(index, time);`) delegates to `Interval.get`,
        # which stamps the absolute game time on fire
        # (Interval.java, `boolean got = check(id, time);` /
        # `if(got) times[id] = Time.time;`, checked by `return
        # Time.time - times[id] >= time || Time.time <
        # times[id];`) -- overshoot is DROPPED, not carried. The
        # port models this with a per-frame accumulator
        # `consume_timer += delta; if consume_timer >= 140 /
        # time_scale: fire, consume_timer = 0` -- reset-to-0 drops
        # overshoot exactly like `Interval.get`; do NOT subtract
        # the interval (that would carry overshoot and drift the
        # burn cadence vs Java). A zero time_scale makes the
        # interval infinite, and `timer()` returns false on
        # infinite time -- so the timer never fires at time_scale
        # 0. The cryofluid is NOT burned by the timer fire:
        # `ConsumeLiquid` has NO trigger override, its drain is
        # `update()` (ConsumeLiquid.java:37-38, `public void
        # update(Building build){` / `build.liquids.remove(liquid,
        # amount * build.edelta() * multiplier.get(build));`),
        # i.e. 0.25f x edelta x 1f per tick (Blocks.java:2644,
        # `consumeLiquid(Liquids.cryofluid, 0.25f);`, with
        # `liquidCapacity = 80f;`, Blocks.java:2640), run by
        # `updateConsumption()`'s second pass
        # (BuildingComp.java:1997-2000, `if(update && efficiency >
        # 0){` / `for(var cons : block.updateConsumers){` /
        # `cons.update(self());`); `Consume.update = true` by
        # default (Consume.java:16, `public boolean update =
        # true;`), so ConsumeLiquid is in `updateConsumers`. The
        # drain is NOT gated on the warmup hard gate -- it runs
        # whenever `shouldConsume() && productionValid()` and the
        # folded efficiency > 0 (`boolean update = shouldConsume()
        # && productionValid();`, BuildingComp.java:1960; the gate
        # is skipped entirely when `!update`:
        # BuildingComp.java:1992, `if(!update){`). `edelta()` is
        # `efficiency * delta()` (BuildingComp.java:1927-1928,
        # `public float edelta(){` / `return efficiency *
        # delta();`) and `delta()` is `Time.delta * timeScale`
        # (BuildingComp.java:1923, `return Time.delta *
        # timeScale;`) -- so the drain per tick is 0.25 *
        # efficiency * delta * time_scale in the port (the port's
        # delta is Time.delta, the N2186 precedent). ImpactReactor
        # has no shouldConsume override, so the BuildingComp
        # default applies (BuildingComp.java:755-756, `public
        # boolean shouldConsume(){` with `return enabled;`) and
        # `productionValid()` defaults true
        # (BuildingComp.java:759-761, `public boolean
        # productionValid(){`). `consumeTriggerValid()` defaults
        # false (BuildingComp.java:764-766, `public boolean
        # consumeTriggerValid(){`), so `ConsumeItems.efficiency`
        # is 1 iff the building has the item
        # (ConsumeItems.java:51-53, `return
        # build.consumeTriggerValid() || build.items.has(items,
        # multiplier.get(build)) ? 1f : 0f;`) -- the burn assumes
        # the hard gate held, which already implies the item was
        # present. Both removes clamp at the stock on hand:
        # `ItemModule.remove` takes `amount = Math.min(amount,
        # items[item.id]);` (ItemModule.java:259) and
        # `LiquidModule.remove` caps to prevent negative removal
        # (LiquidModule.java:126, `//cap to prevent negative
        # removal`) -- so a fire with 0 blast-compound burns 0
        # and a drain past an empty tank drains only what is
        # there; neither dict ever goes negative. Single def --
        # impact-reactor only (size 4, health 900, powerProduction
        # 130f, itemDuration 140f, liquidCapacity 80f, lead 500 /
        # silicon 300 / graphite 400 / thorium 100 / surge-alloy
        # 250 / metaglass 250, Blocks.java:2632-2645). No second
        # ImpactReactor def exists; there is no family split to
        # manage. The driver stamps all five result keys onto the
        # frame (the N2186 precedent), so the frame carries the last
        # tick's burn/drain amounts alongside the updated dicts.
        self.assertIn('static func source_impact_reactor_consume_state(frame: Dictionary, delta: float) -> Dictionary:', impact_reactor)
        self.assertIn('source_impact_reactor_consume_state(frame', impact_reactor)
        self.assertIn('source_impact_reactor_consume_state(frame, seconds)', impact_reactor)
        self.assertIn('frame["items"]', impact_reactor)
        self.assertIn('frame["liquids"]', impact_reactor)
        self.assertIn('frame["time_scale"]', impact_reactor)
        self.assertIn('frame["consume_timer"]', impact_reactor)
        self.assertIn('frame["blast_compound_burned"]', impact_reactor)
        self.assertIn('frame["cryofluid_drained"]', impact_reactor)
        for expr in [
            'if(efficiency >= 0.9999f && power.status >= 0.99f){',
            'if(timer(timerUse, itemDuration / timeScale)){',
            'consume();',
            'public final int timerUse = timers++;',
            'transient Interval timer = new Interval(6);',
            'public boolean timer(int index, float time){',
            'if(Float.isInfinite(time)) return false;',
            'return timer.get(index, time);',
            'boolean got = check(id, time);',
            'if(got) times[id] = Time.time;',
            'return Time.time - times[id] >= time || Time.time < times[id];',
            'public void consume(){',
            'for(Consume cons : block.consumers){',
            'cons.trigger(self());',
            'public void trigger(Building build){}',
            'public void trigger(Building build){',
            'build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));',
            'return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;',
            'public boolean consumeTriggerValid(){',
            'public ConsumeItems consumeItem(Item item){',
            'return consumeItem(item, 1);',
            'consumeItem(Items.blastCompound);',
            'consumeLiquid(Liquids.cryofluid, 0.25f);',
            'itemDuration = 140f;',
            'liquidCapacity = 80f;',
            'public void update(Building build){',
            'build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));',
            'public float edelta(){',
            'return efficiency * delta();',
            'return Time.delta * timeScale;',
            'if(update && efficiency > 0){',
            'for(var cons : block.updateConsumers){',
            'cons.update(self());',
            'public boolean update = true;',
            'public Floatf<Building> multiplier = b -> 1f;',
            'public boolean shouldConsume(){',
            'return enabled;',
            'boolean update = shouldConsume() && productionValid();',
            'public boolean productionValid(){',
            'if(!update){',
            'amount = Math.min(amount, items[item.id]);',
            '//cap to prevent negative removal',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, impact_reactor)
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_impact_reactor_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_impact_reactor_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure function with synthetic
        # frames (no long live tick: the timer fires on a
        # pre-advanced consume_timer stamp): burn -1 per 140s
        # inside the gate, no burn outside the gate, cryofluid
        # drains 0.25f x edelta per tick while efficiency > 0, no
        # drain when disabled or efficiency 0. There are no
        # impactPower / net-bar / persistence keys: the event
        # waits for its own event slice, the bar is display, the
        # persistence waits for its own slice.
        proof = IMPACT_REACTOR_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'burn_minus_one_per_140s_inside_gate',
            'no_burn_outside_gate',
            'cryofluid_drains_per_tick_while_efficiency_positive',
            'no_drain_when_disabled_or_efficiency_zero',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_impact_reactor_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ImpactReactorConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_IMPACT_REACTOR_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'burn_minus_one_per_140s_inside_gate',
            'no_burn_outside_gate',
            'cryofluid_drains_per_tick_while_efficiency_positive',
            'no_drain_when_disabled_or_efficiency_zero',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
