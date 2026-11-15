import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_LOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadLoaderBuildState.gd'
PAYLOAD_LOADER_LOAD_TIMER_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadLoaderLoadTimerProof.gd'
PAYLOAD_LOADER_LOAD_TIMER_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadLoaderLoadTimerProof.tscn'


class C07PayloadLoaderLoadTimerTests(unittest.TestCase):
    def test_c07_payload_loader_load_timer_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2319']['godot_owner'], 'SourcePayloadLoaderBuildState.source_payload_loader_load_timer_state')
        # Advance N2231 ported the updateTile advance in full
        # -- shouldExport / moveInPayload / moveOutPayload /
        # load items+liquids / battery charge
        # (PayloadLoader.java:148-220) -- but the LOAD TIMER
        # CADENCE deferred (no timer helper in the port), so
        # the pure advance took an explicit load_tick bool
        # and the driver passed false: no live load tick ever
        # fired. N2319 is the cadence: the frame-local
        # Interval-equivalent pure function (TimerComp.timer,
        # TimerComp.java:10-13, false on an infinite time,
        # else Interval.get, which resets times[id] =
        # Time.time on fire, arc Interval.java:20-26;
        # Time.time counts TICKS, arc Time.java:69-80) plus
        # the tick wiring -- the frame clock
        # frame["timer_load_elapsed"] accumulates the tick
        # delta every tick, and when it fires the driver
        # passes load_tick true into the N2231 advance. The
        # Java gate is `if(efficiency > 0.01f &&
        # timer(timerLoad, loadTime / efficiency)){`
        # (PayloadLoader.java:157) with `public float
        # loadTime = 2f;` (:22): the threshold divides by
        # EFFICIENCY, not timeScale (the N2290 lesson -- no
        # `/ time_scale` anywhere in the pure). Java
        # short-circuits: eff <= 0.01 means timer() is never
        # called (no reset), but Time.time still advances --
        # so the port accumulates elapsed unconditionally and
        # fires as soon as efficiency recovers. The gate
        # `efficiency > 0.01 and load_tick` already lives in
        # the advance pure (:446); the timer pure only
        # computes load_tick and never duplicates the gate.
        # Two new result symbols: load_tick and
        # timer_elapsed_after.
        self.assertEqual(
            ledger['N2319']['source_symbols'],
            [
                'source_payload_loader_load_timer_state_result.load_tick',
                'source_payload_loader_load_timer_state_result.timer_elapsed_after',
            ],
        )
        for name in ledger['N2319']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
                    'core/src/mindustry/entities/comp/TimerComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadLoaderBuildState.source_payload_loader_load_timer_state')
        self.assertEqual(ledger['N2319']['runtime_proof'], '/root/C07PayloadLoaderLoadTimerProof')
        self.assertEqual(
            ledger['N2319']['tests'],
            [
                'test_c07_payload_loader_load_timer_registration',
                'test_all_c07_payload_loader_load_timer_input_evidence_is_exact',
                'test_payload_loader_load_timer_state',
                'test_reference_graph_and_actual_c07_payload_loader_load_timer',
            ],
        )
        self.assertTrue(ledger['N2319']['deferred_exprs'])
        # The cadence is live now, so the entry that blamed
        # the missing timer is resolved, and one new
        # deferral joins: the first-fire deviation (Java
        # fires nearly at once after placement; the
        # frame-local clock delays the first fire by a full
        # 2f/efficiency interval).
        self.assertFalse(any(entry.startswith('PayloadLoader load timer cadence (') for entry in ledger['N2319']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadLoader load timer first-fire deviation (') for entry in ledger['N2319']['deferred_exprs']))

    def test_all_c07_payload_loader_load_timer_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2319']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadLoaderBuildState.source_payload_loader_load_timer_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The Interval.get / check / Time.time formulas live in
        # Arc, not Mindustry: Interval.java and Time.java under
        # arc-upstream (the N2226 precedent).
        upstream['arc-core/src/arc/util/Interval.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Interval.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/util/Time.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Time.java').read_text(encoding='utf-8')
        for expr in ledger['N2319']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_loader_load_timer_state(self):
        payload_loader = PAYLOAD_LOADER_STATE.read_text(encoding='utf-8')
        # The pure load-timer function is the frame-local
        # Interval-equivalent (TimerComp.timer, TimerComp.
        # java:10-13: `if(Float.isInfinite(time)) return
        # false;` / `return timer.get(index, time);`;
        # Interval.get resets times[id] = Time.time on fire,
        # Interval.java:20-26; check compares Time.time -
        # times[id] >= time, Interval.java:28-30; Time.time
        # counts TICKS, Time.java:69-80): elapsed +=
        # source_delta unconditionally (source_delta is the
        # UNSCALED Time.delta in ticks, so the frame clock
        # mirrors the global Time.time); load_tick = (eff >
        # 0.01) and (elapsed >= loadTime / eff) -- the
        # threshold divides by EFFICIENCY, not timeScale
        # (the N2290 lesson); the Java short-circuit order
        # means eff <= 0.01 never resets (but the clock
        # still accumulates, so a recovered efficiency fires
        # at once); a non-positive time_scale is a defensive
        # guard (never fires -- the clock still accumulates);
        # elapsed_after resets to 0.0 on fire (a RESET, not
        # a subtraction like the Fracker accumulator). The
        # Java gate is `if(efficiency > 0.01f &&
        # timer(timerLoad, loadTime / efficiency)){`
        # (PayloadLoader.java:157) with `public final int
        # timerLoad = timers++;` (:20) and `public float
        # loadTime = 2f;` (:22). The gate `efficiency > 0.01
        # and load_tick` already lives in the N2231 advance
        # pure (:446); the timer pure only computes
        # load_tick and never duplicates the gate.
        self.assertIn('static func source_payload_loader_load_timer_state', payload_loader)
        self.assertIn('if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){', payload_loader)
        self.assertIn('public final int timerLoad = timers++;', payload_loader)
        self.assertIn('public float loadTime = 2f;', payload_loader)
        self.assertIn('public class PayloadLoader extends PayloadBlock{', payload_loader)
        self.assertIn('public class PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{', payload_loader)
        self.assertIn('boolean acceptedAny = true;', payload_loader)
        self.assertIn('acceptedAny = false;', payload_loader)
        self.assertIn('if(Float.isInfinite(time)) return false;', payload_loader)
        self.assertIn('return timer.get(index, time);', payload_loader)
        self.assertIn('boolean got = check(id, time);', payload_loader)
        self.assertIn('if(got) times[id] = Time.time;', payload_loader)
        self.assertIn('return Time.time - times[id] >= time || Time.time < times[id];', payload_loader)
        self.assertIn('timeRaw += delta;', payload_loader)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', payload_loader)
        self.assertIn('"load_tick"', payload_loader)
        self.assertIn('"timer_elapsed_after"', payload_loader)
        # The threshold divides by efficiency -- never by
        # time_scale (the N2290 lesson: do not invent a
        # `/ time_scale` the Java call does not have).
        self.assertIn('threshold = load_time / efficiency', payload_loader)
        self.assertNotIn('load_time / time_scale', payload_loader)
        # The tick wiring: the timer call with the frame
        # clock + tick delta + live time scale + the FOLDED
        # frame efficiency + loadTime 2f, after the
        # consumption fold and before the advance call; the
        # elapsed write-back; load_tick passed into the
        # N2231 advance (no longer the false literal).
        self.assertIn('source_payload_loader_load_timer_state(float(frame.get("timer_load_elapsed", 0.0)), source_delta, time_scale, float(frame.get("efficiency", 0.0)), SOURCE_PAYLOAD_LOADER_LOAD_TIME)', payload_loader)
        self.assertIn('frame["timer_load_elapsed"]', payload_loader)
        self.assertIn('"timer_load_elapsed": 0.0', payload_loader)
        self.assertIn('source_payload_loader_update_tile_advance_state(frame, source_delta, time_scale, load_tick, rotdeg_value, true, item_order, liquid_names_by_id, front, false, SOURCE_PAYLOAD_LOADER_BASE_POWER_USE)', payload_loader)
        # The documented limits now record the cadence as
        # live (N2319); the N2231 advance, N2208 gate, N2295
        # acceptPayload, N2278 fill and N2315 intake text
        # stays.
        self.assertIn('load timer cadence live (N2319)', payload_loader)
        self.assertIn('updateTile advance live (N2231)', payload_loader)
        self.assertIn('shouldConsume gate live (N2208)', payload_loader)
        self.assertIn('acceptPayload rows live (N2295)', payload_loader)
        self.assertIn('live payload fill live (N2278)', payload_loader)
        self.assertIn('Intake full-gate wiring live (N2315)', payload_loader)
        # The proof's keys drive the pure timer (fire at
        # 2f/efficiency -- 2 ticks at eff 1.0, 4 ticks at
        # eff 0.5 -- no fire below the threshold, no fire
        # when efficiency is low, fire at once when
        # efficiency recovers, no fire on a non-positive
        # time_scale) plus the live tick (load_tick reaches
        # the advance on a fire and loads items, nothing
        # loads when the timer has not fired).
        proof = PAYLOAD_LOADER_LOAD_TIMER_PROOF.read_text(encoding='utf-8')
        for key in [
            'timer_fires_at_load_time_over_efficiency',
            'timer_no_fire_below_threshold',
            'timer_no_fire_when_efficiency_low',
            'timer_fires_when_efficiency_recovers',
            'timer_no_fire_when_time_scale_zero',
            'live_tick_passes_load_tick_on_fire',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof pins the efficiency-divided threshold:
        # eff 0.5 needs 4 ticks (3 + 1 fires, 2 + 1 does
        # not) and eff 1.0 fires at 2 ticks (1 + 1).
        self.assertIn('timer.call(3.0, 1.0, 1.0, 0.5, load_time)', proof)
        self.assertIn('timer.call(2.0, 1.0, 1.0, 0.5, load_time)', proof)
        self.assertIn('timer.call(1.0, 1.0, 1.0, 1.0, load_time)', proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourcePayloadLoaderBuildState.gd")', proof)
        self.assertIn('payload_loader_build_state.source_payload_loader_load_timer_state(', proof)
        self.assertIn('payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(PAYLOAD_LOADER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_LOADER_LOAD_TIMER_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadLoaderLoadTimerProof.gd', scene)
        self.assertIn('C07PayloadLoaderLoadTimerProof', scene)

    def test_reference_graph_and_actual_c07_payload_loader_load_timer(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadLoaderLoadTimerProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_LOADER_LOAD_TIMER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'timer_fires_at_load_time_over_efficiency',
            'timer_no_fire_below_threshold',
            'timer_no_fire_when_efficiency_low',
            'timer_fires_when_efficiency_recovers',
            'timer_no_fire_when_time_scale_zero',
            'live_tick_passes_load_tick_on_fire',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
