import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_UNLOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadUnloaderBuildState.gd'
PAYLOAD_UNLOADER_LOAD_TIMER_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderLoadTimerProof.gd'
PAYLOAD_UNLOADER_LOAD_TIMER_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderLoadTimerProof.tscn'
PAYLOAD_UNLOADER_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/PayloadUnloader.java'
PAYLOAD_LOADER_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/PayloadLoader.java'
TIMER_COMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/entities/comp/TimerComp.java'
BUILDING_COMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java'
INTERVAL_JAVA = ROOT / 'arc-upstream/arc-core/src/arc/util/Interval.java'
TIME_JAVA = ROOT / 'arc-upstream/arc-core/src/arc/util/Time.java'


class C07PayloadUnloaderLoadTimerTests(unittest.TestCase):
    def test_c07_payload_unloader_load_timer_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2320']['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_load_timer_state')
        # N2232 ported the updateTile advance in full
        # (moveInPayload / moveOutPayload + unload
        # items/liquids + battery unload into
        # lastOutputPower) -- but the TIMER CADENCE itself
        # deferred (no timer helper in the port, the N2193
        # precedent), so the driver passed load_tick false
        # and no live unload tick ever fired. N2320 is the
        # cadence: the frame-local Interval-equivalent pure
        # function (TimerComp.timer, TimerComp.java:10-13,
        # false on an infinite time, else Interval.get,
        # which resets times[id] = Time.time on fire, arc
        # Interval.java:20-26; Time.time counts TICKS, arc
        # Time.java:69-80) plus the tick wiring -- the frame
        # clock frame["timer_load_elapsed"] accumulates the
        # tick delta every tick the advance runs, and the
        # load tick fires when efficiency > 0.01 and the
        # clock reaches loadTime / efficiency (loadTime 2f,
        # PayloadLoader.java:22, inherited). The threshold
        # divides by EFFICIENCY, not timeScale (the N2290
        # lesson: never invent a / time_scale). Two new
        # result symbols: load_tick and timer_elapsed_after.
        self.assertEqual(
            ledger['N2320']['source_symbols'],
            [
                'source_payload_unloader_load_timer_state_result.load_tick',
                'source_payload_unloader_load_timer_state_result.timer_elapsed_after',
            ],
        )
        for name in ledger['N2320']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
                    'core/src/mindustry/entities/comp/TimerComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_load_timer_state')
        self.assertEqual(ledger['N2320']['runtime_proof'], '/root/C07PayloadUnloaderLoadTimerProof')
        self.assertEqual(
            ledger['N2320']['tests'],
            [
                'test_c07_payload_unloader_load_timer_registration',
                'test_all_c07_payload_unloader_load_timer_input_evidence_is_exact',
                'test_payload_unloader_load_timer_state',
                'test_reference_graph_and_actual_c07_payload_unloader_load_timer',
            ],
        )
        self.assertTrue(ledger['N2320']['deferred_exprs'])
        # This slice resolves the timer-cadence entry (the
        # cadence is live since N2320) and adds one narrower
        # entry (the first-fire deviation, the N2280
        # precedent). The live front query and the
        # movePayload/dumpPayload application entries stay
        # verbatim.
        self.assertFalse(any(entry.startswith('PayloadUnloader updateTile timer cadence (') for entry in ledger['N2320']['deferred_exprs']))
        for prefix in [
            'PayloadUnloader load timer first-fire deviation (',
            'PayloadUnloader live front query (',
            'PayloadUnloader movePayload/dumpPayload application (',
        ]:
            with self.subTest(prefix=prefix):
                self.assertTrue(any(entry.startswith(prefix) for entry in ledger['N2320']['deferred_exprs']))

    def test_all_c07_payload_unloader_load_timer_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2320']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_load_timer_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The Interval.get / check / Time.time formulas live in
        # Arc, not Mindustry: Interval.java and Time.java under
        # arc-upstream (the N2226 precedent).
        upstream['arc-core/src/arc/util/Interval.java'] = INTERVAL_JAVA.read_text(encoding='utf-8')
        upstream['arc-core/src/arc/util/Time.java'] = TIME_JAVA.read_text(encoding='utf-8')
        for expr in ledger['N2320']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_unloader_load_timer_state(self):
        payload_unloader = PAYLOAD_UNLOADER_STATE.read_text(encoding='utf-8')
        # The pure load-timer function is the frame-local
        # Interval-equivalent (TimerComp.timer, TimerComp.
        # java:10-13: `if(Float.isInfinite(time)) return
        # false;` / `return timer.get(index, time);`;
        # Interval.get resets times[id] = Time.time on fire,
        # arc Interval.java:20-26; check compares Time.time -
        # times[id] >= time, arc Interval.java:28-30;
        # Time.time counts TICKS, arc Time.java:69-80):
        # elapsed += source_delta unconditionally
        # (source_delta is the UNSCALED Time.delta in ticks,
        # so the frame clock mirrors the global Time.time);
        # load_tick = (efficiency > 0.01) and (elapsed >=
        # loadTime / efficiency) -- the threshold divides by
        # EFFICIENCY, not timeScale (the N2290 lesson); a
        # non-positive time_scale is a defensive guard
        # (threshold INF, never fires -- the clock still
        # accumulates); efficiency <= 0 is the same infinite
        # rule (the divide-by-zero guard); elapsed_after
        # RESETS to 0.0 only when load_tick is true (a reset,
        # not a subtraction like the Fracker accumulator).
        # The Java short-circuit order matters: efficiency <=
        # 0.01 means Java never calls timer(), so the clock
        # keeps accumulating and a recovered efficiency fires
        # at once. The Java call is `if(efficiency > 0.01f &&
        # timer(timerLoad, loadTime / efficiency)){`
        # (PayloadUnloader.java:69) with `public final int
        # timerLoad = timers++;` (PayloadLoader.java:20) and
        # `public float loadTime = 2f;` (PayloadLoader.java:
        # 22, inherited). The gate `efficiency > 0.01 and
        # load_tick` already lives in the N2232 advance pure
        # -- the timer pure only computes load_tick, it does
        # not duplicate the gate. The tick wiring accumulates
        # frame["timer_load_elapsed"] every tick the advance
        # runs (after the consumption fold, before the
        # advance call) and passes the computed load_tick
        # into the advance instead of false. The Unloader has
        # NO dynamic power consumer (`loadPowerDynamic =
        # false`, PayloadUnloader.java:18) -- the folded
        # efficiency is the power-only fold, exact.
        self.assertIn('static func source_payload_unloader_load_timer_state', payload_unloader)
        self.assertIn('if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){', payload_unloader)
        self.assertIn('public final int timerLoad = timers++;', payload_unloader)
        self.assertIn('public float loadTime = 2f;', payload_unloader)
        self.assertIn('public class PayloadUnloader extends PayloadLoader{', payload_unloader)
        self.assertIn('public class PayloadUnloaderBuild extends PayloadLoaderBuild{', payload_unloader)
        self.assertIn('loadPowerDynamic = false;', payload_unloader)
        self.assertIn('if(Float.isInfinite(time)) return false;', payload_unloader)
        self.assertIn('return timer.get(index, time);', payload_unloader)
        self.assertIn('boolean got = check(id, time);', payload_unloader)
        self.assertIn('if(got) times[id] = Time.time;', payload_unloader)
        self.assertIn('return Time.time - times[id] >= time || Time.time < times[id];', payload_unloader)
        self.assertIn('timeRaw += delta;', payload_unloader)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', payload_unloader)
        self.assertIn('"load_tick"', payload_unloader)
        self.assertIn('"timer_elapsed_after"', payload_unloader)
        # The threshold divides load_time by EFFICIENCY, with
        # the infinite guard on a non-positive time_scale or
        # a non-positive efficiency (the TimerComp infinite
        # rule + the divide-by-zero guard) -- and NEVER by
        # time_scale (the N2290 lesson).
        self.assertIn('INF if time_scale <= 0.0 or efficiency <= 0.0 else load_time / efficiency', payload_unloader)
        self.assertNotIn('load_time / time_scale', payload_unloader)
        self.assertNotIn('load_time / efficiency / time_scale', payload_unloader)
        # The short-circuit order: the efficiency gate feeds
        # load_tick itself (Java never calls timer() at
        # efficiency <= 0.01, so the clock keeps accumulating
        # and a recovered efficiency fires at once), and the
        # reset happens ONLY when load_tick is true.
        self.assertIn('efficiency > 0.01 and accumulated >= threshold', payload_unloader)
        self.assertIn('0.0 if load_tick else accumulated', payload_unloader)
        # The tick wiring: the timer call with the frame clock
        # + tick delta + live time scale + folded frame
        # efficiency + the 2f load-time const; the elapsed
        # write-back; the computed load_tick passed into the
        # advance (replacing the false literal). The pure is
        # called exactly once (its definition plus the one
        # tick call site).
        self.assertIn('source_payload_unloader_load_timer_state(float(frame.get("timer_load_elapsed", 0.0)), source_delta, time_scale, float(frame.get("efficiency", 0.0)), SOURCE_PAYLOAD_UNLOADER_LOAD_TIME)', payload_unloader)
        self.assertEqual(payload_unloader.count('source_payload_unloader_load_timer_state('), 2)
        self.assertIn('frame["timer_load_elapsed"]', payload_unloader)
        self.assertIn('source_payload_unloader_update_tile_advance_state(frame, source_delta, time_scale, load_tick, item_order, front)', payload_unloader)
        # The fresh frame binds the timer clock with the Java
        # Interval default (times[] init 0) and the tick
        # preserves it on a frame bound before this slice.
        self.assertIn('"timer_load_elapsed": 0.0', payload_unloader)
        self.assertIn('if not frame.has("timer_load_elapsed"):', payload_unloader)
        # Scope pins, by line number: the unload gate is
        # PayloadUnloader.java:69 (the hasItems guard is :68);
        # timerLoad / loadTime are PayloadLoader.java:20/:22;
        # TimerComp.timer is TimerComp.java:10-13; Interval.get
        # resets at Interval.java:23-24 and check compares at
        # :29; Time.time grows at Time.java:75.
        unloader_lines = PAYLOAD_UNLOADER_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(unloader_lines[67].strip(), 'if(payload.block().hasItems && !full()){')
        self.assertEqual(unloader_lines[68].strip(), 'if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){')
        loader_lines = PAYLOAD_LOADER_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(loader_lines[19].strip(), 'public final int timerLoad = timers++;')
        self.assertEqual(loader_lines[21].strip(), 'public float loadTime = 2f;')
        timer_lines = TIMER_COMP_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(timer_lines[9].strip(), 'public boolean timer(int index, float time){')
        self.assertEqual(timer_lines[10].strip(), 'if(Float.isInfinite(time)) return false;')
        self.assertEqual(timer_lines[11].strip(), 'return timer.get(index, time);')
        interval_lines = INTERVAL_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(interval_lines[22].strip(), 'boolean got = check(id, time);')
        self.assertEqual(interval_lines[23].strip(), 'if(got) times[id] = Time.time;')
        self.assertEqual(interval_lines[28].strip(), 'return Time.time - times[id] >= time || Time.time < times[id];')
        time_lines = TIME_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(time_lines[74].strip(), 'timeRaw += delta;')
        self.assertIn('loadPowerDynamic = false;', PAYLOAD_UNLOADER_JAVA.read_text(encoding='utf-8'))
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', BUILDING_COMP_JAVA.read_text(encoding='utf-8'))
        # The documented limits now record the timer cadence
        # as live (N2320) with the first-fire deviation; the
        # old "driver passes load_tick false" claim is gone
        # from the driver (the N2232 test's pinned call text
        # is updated at integration).
        self.assertIn('timer cadence live (N2320)', payload_unloader)
        self.assertNotIn('driver passes load_tick false', payload_unloader)
        self.assertNotIn('The timer cadence defers', payload_unloader)
        self.assertIn('shouldConsume gate live (N2209)', payload_unloader)
        self.assertIn('updateTile advance live (N2232)', payload_unloader)
        self.assertIn('live payload fill live (N2279)', payload_unloader)
        self.assertIn('dump rows live (N2293)', payload_unloader)
        self.assertIn('static func source_payload_unloader_update_tile_advance_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_should_consume_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_handle_payload_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_dump_state', payload_unloader)
        # The proof's keys drive the pure timer (fire at
        # 2f/efficiency, no fire below the threshold, no fire
        # when efficiency is low -- the clock still
        # accumulating -- fire at once when efficiency
        # recovers, no fire on a non-positive time_scale)
        # plus the live tick (a placed payload-unloader
        # unloads items on a fire and holds them when the
        # timer has not fired).
        proof = PAYLOAD_UNLOADER_LOAD_TIMER_PROOF.read_text(encoding='utf-8')
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
        # eff 1.0 fires at 2 ticks (1 + 1), eff 0.5 needs 4
        # (3 + 1), and eff 0.5 at 3 ticks does NOT fire.
        self.assertIn('timer.call(1.0, 1.0, 1.0, 1.0, load_time)', proof)
        self.assertIn('timer.call(3.0, 1.0, 1.0, 0.5, load_time)', proof)
        self.assertIn('timer.call(2.0, 1.0, 1.0, 0.5, load_time)', proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourcePayloadUnloaderBuildState.gd")', proof)
        self.assertIn('payload_unloader_build_state.source_payload_unloader_load_timer_state(', proof)
        self.assertIn('payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(PAYLOAD_UNLOADER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_UNLOADER_LOAD_TIMER_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadUnloaderLoadTimerProof.gd', scene)
        self.assertIn('C07PayloadUnloaderLoadTimerProof', scene)

    def test_reference_graph_and_actual_c07_payload_unloader_load_timer(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadUnloaderLoadTimerProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_UNLOADER_LOAD_TIMER_PROOF ')]
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
