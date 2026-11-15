import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
IMPACT_REACTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceImpactReactorBuildState.gd'
IMPACT_REACTOR_ITEM_ROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorItemRowProof.gd'
IMPACT_REACTOR_ITEM_ROW_PROOF_TSCN = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorItemRowProof.tscn'


class C07ImpactReactorItemRowTests(unittest.TestCase):
    def test_c07_impact_reactor_item_row_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2266']['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_item_consumer_row_state')
        # N2182 wired the impact reactor's live power.status
        # read, N2192 advanced the warmup and N2254 folded the
        # cryofluid row -- but the folded efficiency was still
        # the min over the power + liquid rows only: the reactor
        # also consumes 1 blast-compound (Blocks.java:2643,
        # `consumeItem(Items.blastCompound);`), a REQUIRED
        # non-optional consumer, so a reactor with an empty
        # blast-compound store still folded efficiency 1.0 and
        # warmed up as if fully supplied -- and it never burned
        # the compound at all, because the consume timer
        # (ImpactReactor.java:91-92, `if(timer(timerUse,
        # itemDuration / timeScale)){` with `consume();`) had no
        # port. ConsumeItems.efficiency (ConsumeItems.java:51-53,
        # `return build.consumeTriggerValid() ||
        # build.items.has(items, multiplier.get(build)) ? 1f :
        # 0f;`) is BINARY 1/0, and consumeTriggerValid() is
        # false at the base (BuildingComp.java:764-766) with no
        # ImpactReactor override, so the row turns on the held
        # stacks alone. The timer is TimerComp.timer
        # (TimerComp.java:10-13, `if(Float.isInfinite(time))
        # return false;` with `return timer.get(index,
        # time);`) over arc Interval.get (Interval.java:20-26),
        # which fires when the elapsed time reaches duration /
        # timeScale and RESETS on fire (`if(got) times[id] =
        # Time.time;`, Interval.java:24); Time.time counts in
        # TICKS (`timeRaw += delta;`, arc Time.java:75). The
        # def itemDuration is 140f (Blocks.java:2637), NOT the
        # class default 60f (ImpactReactor.java:20). N2266 is
        # the item row + the timer-gated consume: a pure BINARY
        # row folded into the first-pass min, a pure
        # frame-local Interval-equivalent timer (the port has
        # NO global tick clock at the driver layer, so the
        # driver accumulates source_delta into
        # frame["timer_use_elapsed"] every tick,
        # unconditionally), and a DIRECT removal of 1
        # blast-compound when the warmup gate holds and the
        # timer fires (consume() triggers only the item
        # consumer -- ConsumePower / ConsumeLiquid do not
        # override trigger). Five new result symbols: the row
        # and its presence flag, plus fired / elapsed_after /
        # threshold.
        self.assertEqual(
            ledger['N2266']['source_symbols'],
            [
                'source_impact_reactor_item_consumer_row_state_result.row',
                'source_impact_reactor_item_consumer_row_state_result.has_item_row',
                'source_impact_reactor_timer_use_state_result.fired',
                'source_impact_reactor_timer_use_state_result.elapsed_after',
                'source_impact_reactor_timer_use_state_result.threshold',
            ],
        )
        for name in ledger['N2266']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumeItems.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/entities/comp/TimerComp.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/blocks/power/ImpactReactor.java',
                    'arc-core/src/arc/util/Interval.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_impact_reactor_item_consumer_row_state_result.row': 'SourceImpactReactorBuildState.source_impact_reactor_item_consumer_row_state',
                    'source_impact_reactor_item_consumer_row_state_result.has_item_row': 'SourceImpactReactorBuildState.source_impact_reactor_item_consumer_row_state',
                    'source_impact_reactor_timer_use_state_result.fired': 'SourceImpactReactorBuildState.source_impact_reactor_timer_use_state',
                    'source_impact_reactor_timer_use_state_result.elapsed_after': 'SourceImpactReactorBuildState.source_impact_reactor_timer_use_state',
                    'source_impact_reactor_timer_use_state_result.threshold': 'SourceImpactReactorBuildState.source_impact_reactor_timer_use_state',
                }[name])
        self.assertEqual(ledger['N2266']['runtime_proof'], '/root/C07ImpactReactorItemRowProof')
        self.assertEqual(
            ledger['N2266']['tests'],
            [
                'test_c07_impact_reactor_item_row_registration',
                'test_all_c07_impact_reactor_item_row_input_evidence_is_exact',
                'test_impact_reactor_item_consumer_row_state',
                'test_reference_graph_and_actual_c07_impact_reactor_item_row',
            ],
        )
        self.assertTrue(ledger['N2266']['deferred_exprs'])
        # This slice resolves the item-row and consume-timer
        # deferrals the earlier registers carried -- both must
        # be gone -- and records the two halves it still defers:
        # the frame-local first-fire deviation and the missing
        # live items intake. The impact-power event stays
        # deferred too.
        self.assertFalse(any(entry.startswith('ImpactReactor item consumer row (consumeItem blast-compound') for entry in ledger['N2266']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('ImpactReactor consume-timer rows (timer(timerUse, itemDuration / timeScale)') for entry in ledger['N2266']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor timer first-fire deviation') for entry in ledger['N2266']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor frame items intake') for entry in ledger['N2266']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor impactPower event rows') for entry in ledger['N2266']['deferred_exprs']))

    def test_all_c07_impact_reactor_item_row_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2266']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_impact_reactor_item_consumer_row_state_result.row': 'SourceImpactReactorBuildState.source_impact_reactor_item_consumer_row_state',
                    'source_impact_reactor_item_consumer_row_state_result.has_item_row': 'SourceImpactReactorBuildState.source_impact_reactor_item_consumer_row_state',
                    'source_impact_reactor_timer_use_state_result.fired': 'SourceImpactReactorBuildState.source_impact_reactor_timer_use_state',
                    'source_impact_reactor_timer_use_state_result.elapsed_after': 'SourceImpactReactorBuildState.source_impact_reactor_timer_use_state',
                    'source_impact_reactor_timer_use_state_result.threshold': 'SourceImpactReactorBuildState.source_impact_reactor_timer_use_state',
                }[name])
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/consumers/ConsumeItems.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/consumers/Consume.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/modules/ItemModule.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/TimerComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/power/ImpactReactor.java'),
            ('arc-upstream', 'arc-core/src/arc/util/Interval.java'),
            ('arc-upstream', 'arc-core/src/arc/util/Time.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2266']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_impact_reactor_item_consumer_row_state(self):
        impact_reactor = IMPACT_REACTOR_STATE.read_text(encoding='utf-8')
        # The pure item row lives on the impact-reactor build
        # state: ConsumeItems.efficiency
        # (ConsumeItems.java:51-53) over the frame items store,
        # BINARY 1/0 -- 1 when every stack is held, 0
        # otherwise -- folded by the first pass
        # (BuildingComp.java:1969-1976) into the min
        # efficiency; a starved row stops the power draw
        # (BuildingComp.java:1972-1974). consumeTriggerValid()
        # is false at the base (BuildingComp.java:764-766)
        # and no ImpactReactor / GeneratorBuild /
        # PowerGenerator override exists, so the trigger term
        # is always false. items.has (ItemModule.java:153-158)
        # requires EVERY stack at round(amount * multiplier),
        # with has(item, amount) = get(item) >= amount
        # (ItemModule.java:126-128); the multiplier defaults
        # to 1f (Consume.java:18), so the required count is
        # the amount itself. The counts come from the shared
        # drill inventory helper
        # (SourceDrillInventoryRuntimeState.item_count) over
        # the frame items key (a Dictionary keyed by item
        # name, default {} for a frame bound before this
        # slice). The single def consumes one blast-compound,
        # `consumeItem(Items.blastCompound);`
        # (Blocks.java:2643; consumeItem(item) is
        # ItemStack(item, 1), Block.java:1167-1168).
        # The pure timer is the frame-local
        # Interval-equivalent for `if(timer(timerUse,
        # itemDuration / timeScale)){` (ImpactReactor.java:91):
        # TimerComp.timer (TimerComp.java:10-13) returns false
        # for an infinite time and otherwise delegates to arc
        # Interval.get (Interval.java:20-26), which fires when
        # the elapsed time reaches the threshold and RESETS on
        # fire (`if(got) times[id] = Time.time;`,
        # Interval.java:24) -- reset, NOT subtract like the
        # Fracker accumulator. Time.time counts in TICKS
        # (`timeRaw += delta;`, arc Time.java:75), so the
        # threshold is duration / time_scale in ticks (140f /
        # timeScale for the single def, Blocks.java:2637, NOT
        # the class default 60f, ImpactReactor.java:20). The
        # driver accumulates source_delta into
        # frame["timer_use_elapsed"] every tick,
        # unconditionally -- mirroring Time.time rising every
        # frame, even while the gate is closed -- and after
        # the N2192 advance it recomputes the warmup gate
        # from the frame (efficiency >= 0.9999 &&
        # power_status >= 0.99, power_status 1.0 when
        # unstamped, like the advance); when the gate holds
        # AND the timer fires, consume() removes 1
        # blast-compound through the shared inventory remove
        # (clamped to what the module holds,
        # ItemModule.java:258-263) and resets the clock to
        # 0.0. ConsumeItems has NO update override, so the
        # second pass never consumes items -- the removal
        # happens only through consume()
        # (BuildingComp.java:1911-1915, `for(Consume cons :
        # block.consumers){` with `cons.trigger(self());`),
        # and ConsumeItems.trigger removes `build.items.
        # remove(stack.item, Math.round(stack.amount *
        # multiplier.get(build)));` (ConsumeItems.java:44-48).
        # KNOWN DEVIATION (first-fire): Java fires (nearly)
        # immediately after placement when the gate first
        # opens (global Time.time is already large vs a
        # fresh Interval times[]=0), while the frame-local
        # clock delays the first fire by a full interval.
        # No live intake fills frame["items"] yet (the
        # Separator precedent), so the row reads the frame
        # as-is. The impact-power event
        # (ImpactReactor.java:87-88) still waits for its own
        # slice. The advance function itself is UNTOUCHED
        # (N2192).
        self.assertIn('static func source_impact_reactor_item_consumer_row_state(frame: Dictionary, stacks: Array) -> Dictionary:', impact_reactor)
        self.assertIn('static func source_impact_reactor_timer_use_state(elapsed: float, duration: float, time_scale: float) -> Dictionary:', impact_reactor)
        self.assertIn('const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")', impact_reactor)
        self.assertIn('const SOURCE_IMPACT_REACTOR_ITEM := "blast-compound"', impact_reactor)
        self.assertIn('const SOURCE_IMPACT_REACTOR_ITEM_AMOUNT := 1', impact_reactor)
        self.assertIn('const SOURCE_IMPACT_REACTOR_ITEM_DURATION := 140.0', impact_reactor)
        self.assertIn('return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;', impact_reactor)
        self.assertIn('public boolean consumeTriggerValid(){', impact_reactor)
        self.assertIn('if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;', impact_reactor)
        self.assertIn('return get(item) >= amount;', impact_reactor)
        self.assertIn('consumeItem(Items.blastCompound);', impact_reactor)
        self.assertIn('return consumeItem(item, 1);', impact_reactor)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', impact_reactor)
        self.assertIn('itemDuration = 140f;', impact_reactor)
        self.assertIn('public float itemDuration = 60f;', impact_reactor)
        self.assertIn('if(timer(timerUse, itemDuration / timeScale)){', impact_reactor)
        self.assertIn('consume();', impact_reactor)
        self.assertIn('if(Float.isInfinite(time)) return false;', impact_reactor)
        self.assertIn('return timer.get(index, time);', impact_reactor)
        self.assertIn('if(got) times[id] = Time.time;', impact_reactor)
        self.assertIn('return Time.time - times[id] >= time || Time.time < times[id];', impact_reactor)
        self.assertIn('timeRaw += delta;', impact_reactor)
        self.assertIn('amount = Math.min(amount, items[item.id]);', impact_reactor)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', impact_reactor)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', impact_reactor)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', impact_reactor)
        self.assertIn('if(cons != block.consPower && result <= 0.0000001f){', impact_reactor)
        self.assertIn('if(efficiency >= 0.9999f && power.status >= 0.99f){', impact_reactor)
        self.assertIn('for(Consume cons : block.consumers){', impact_reactor)
        self.assertIn('cons.trigger(self());', impact_reactor)
        self.assertIn('"items": {}', impact_reactor)
        self.assertIn('required_results.append(item_row.get("row", {}))', impact_reactor)
        self.assertIn('frame["timer_use_elapsed"] = float(frame.get("timer_use_elapsed", 0.0)) + source_delta', impact_reactor)
        self.assertIn('source_impact_reactor_timer_use_state(float(frame.get("timer_use_elapsed", 0.0)), SOURCE_IMPACT_REACTOR_ITEM_DURATION, time_scale)', impact_reactor)
        self.assertIn('inventory.remove_item_state(items, SOURCE_IMPACT_REACTOR_ITEM, SOURCE_IMPACT_REACTOR_ITEM_AMOUNT)', impact_reactor)
        self.assertIn('frame["timer_use_elapsed"] = 0.0', impact_reactor)
        self.assertIn('"is_power": false', impact_reactor)
        self.assertIn('has_item_row', impact_reactor)
        # The documented limits record the item row + timer as
        # live, the first-fire deviation, the missing live
        # intake, and the still-deferred impact-power event.
        self.assertIn('item row is live (N2266)', impact_reactor)
        self.assertIn('first-fire', impact_reactor)
        self.assertIn('NO live intake fills frame["items"] yet', impact_reactor)
        self.assertIn('impact-power event (ImpactReactor.java:87-88) still waits for its own slice', impact_reactor)
        # The proof's keys drive the pure row (binary held /
        # missing) and the pure timer (fire at the 140-tick
        # threshold, no fire below it or at a non-positive
        # time scale) plus the live tick (the item row folds
        # the required min, the timer consume removes exactly
        # one blast-compound, no fire when the warmup gate is
        # closed).
        proof = IMPACT_REACTOR_ITEM_ROW_PROOF.read_text(encoding='utf-8')
        self.assertIn('res://src/game/SourceImpactReactorBuildState.gd', proof)
        for key in [
            'item_row_binary_blast_compound',
            'item_row_folds_required_min',
            'timer_fires_at_item_duration',
            'timer_no_fire_below_threshold',
            'timer_consume_removes_one',
            'timer_no_fire_when_gate_closed',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof checks (BRIEF-COMMON): every preload in
        # the proof points at a file that exists, and the scene
        # loads this proof script.
        for preload_path in re.findall(r'preload\("(res://[^"]+)"\)', proof):
            with self.subTest(preload=preload_path):
                self.assertTrue((ROOT / 'godot-mindustry' / preload_path[len('res://'):]).is_file(), preload_path)
        tscn = IMPACT_REACTOR_ITEM_ROW_PROOF_TSCN.read_text(encoding='utf-8')
        self.assertIn('res://tools/runtime_proofs/C07ImpactReactorItemRowProof.gd', tscn)

    def test_reference_graph_and_actual_c07_impact_reactor_item_row(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ImpactReactorItemRowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_IMPACT_REACTOR_ITEM_ROW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'item_row_binary_blast_compound',
            'item_row_folds_required_min',
            'timer_fires_at_item_duration',
            'timer_no_fire_below_threshold',
            'timer_consume_removes_one',
            'timer_no_fire_when_gate_closed',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
