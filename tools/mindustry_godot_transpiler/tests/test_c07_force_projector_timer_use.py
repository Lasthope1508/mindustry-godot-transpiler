import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FORCE_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceForceProjectorBuildState.gd'
FORCE_PROJECTOR_TIMER_USE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ForceProjectorTimerUseProof.gd'
FORCE_PROJECTOR_TIMER_USE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ForceProjectorTimerUseProof.tscn'


class C07ForceProjectorTimerUseTests(unittest.TestCase):
    def test_c07_force_projector_timer_use_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2326']['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_timer_use_state')
        # N2235 ported the updateTile advance
        # (ForceBuild.updateTile(),
        # ForceProjector.java:207-268) in full -- the phaseValid
        # / phaseHeat fold, the consume gate (reported as a pure
        # `consumed` result), the radscl / warmup / buildup /
        # broken / hit folds and deflectBullets -- but the TIMER
        # CADENCE itself deferred (no timer helper in the port,
        # the N2193 precedent), so the driver passed consume_tick
        # false and the consume() application deferred with it.
        # N2261 made the phaseFabric item row live (phaseValid
        # reads it directly) and N2258 the coolant live fill,
        # so the only missing half of the gate was the timer.
        # N2326 is the cadence + the application: the pure
        # timer-use function is the frame-local
        # Interval-equivalent of TimerComp.timer
        # (TimerComp.java:10-13, `if(Float.isInfinite(time))
        # return false;` / `return timer.get(index, time);`;
        # Interval.get resets times[id] = Time.time on fire, arc
        # Interval.java:20-26; check compares Time.time -
        # times[id] >= time, arc Interval.java:28-30; Time.time
        # counts TICKS, arc Time.java:75) -- elapsed +=
        # source_delta unconditionally (source_delta is the
        # UNSCALED Time.delta in ticks, so the frame clock
        # mirrors the global Time.time), consume_tick = elapsed
        # >= threshold, where the threshold is duration /
        # time_scale (350f / timeScale -- Java DIVIDES here,
        # unlike the advances-12 literal timers; the N2281 dump
        # precedent), a non-positive time_scale is a defensive
        # guard (consume_tick false, threshold INF -- the clock
        # still accumulates), timer_elapsed_after resets to 0.0
        # on fire (a RESET, not a subtraction like the Fracker
        # accumulator). The tick computes the timer before the
        # N2235 advance call and passes the live consume_tick;
        # when the advance reports consumed, the driver removes
        # 1 phaseFabric from frame["items"] (ConsumeItems.trigger,
        # ConsumeItems.java:44-48, via the shared inventory
        # helper, clamped to the held count like
        # ItemModule.remove). The gate (phaseValid / !broken /
        # efficiency > 0) stays INSIDE the advance -- the timer
        # pure only supplies consume_tick, so a timer fire alone
        # never consumes. Three new result symbols: consume_tick,
        # timer_elapsed_after and threshold.
        self.assertEqual(
            ledger['N2326']['source_symbols'],
            [
                'source_force_projector_timer_use_state_result.consume_tick',
                'source_force_projector_timer_use_state_result.timer_elapsed_after',
                'source_force_projector_timer_use_state_result.threshold',
            ],
        )
        for name in ledger['N2326']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_force_projector_timer_use_state_result.consume_tick': 'core/src/mindustry/entities/comp/TimerComp.java',
                    'source_force_projector_timer_use_state_result.timer_elapsed_after': 'core/src/mindustry/entities/comp/TimerComp.java',
                    'source_force_projector_timer_use_state_result.threshold': 'core/src/mindustry/world/blocks/defense/ForceProjector.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_timer_use_state')
        self.assertEqual(ledger['N2326']['runtime_proof'], '/root/C07ForceProjectorTimerUseProof')
        self.assertEqual(
            ledger['N2326']['tests'],
            [
                'test_c07_force_projector_timer_use_registration',
                'test_all_c07_force_projector_timer_use_input_evidence_is_exact',
                'test_force_projector_timer_use_state',
                'test_reference_graph_and_actual_c07_force_projector_timer_use',
            ],
        )
        self.assertTrue(ledger['N2326']['deferred_exprs'])
        # The cadence + consume application are live now, so the
        # live-fill entry is REWRITTEN in place (the timer /
        # consume halves are gone from it; the live bullet scan
        # + absorb application + effects stay); one new
        # deferral joined at N2326: the first-fire deviation
        # (Java fires nearly at once after placement; the
        # frame-local clock delays the first fire by a full
        # 350f/time_scale interval). DEFERRED goes 325 + 1 = 326.
        self.assertEqual(len(ledger['N2326']['deferred_exprs']), 326)
        self.assertFalse(any('the driver passes consume_tick false' in entry for entry in ledger['N2326']['deferred_exprs']))
        live_fill = [entry for entry in ledger['N2326']['deferred_exprs'] if entry.startswith('ForceProjector updateTile live fill (')]
        self.assertEqual(len(live_fill), 1)
        self.assertIn('live since N2326', live_fill[0])
        self.assertNotIn('timer(timerUse, phaseUseTime / timeScale) cadence', live_fill[0])
        self.assertNotIn('cadence + consume() application + Groups.bullet', live_fill[0])
        self.assertIn('Groups.bullet live scan', live_fill[0])
        self.assertTrue(any(entry.startswith('ForceProjector timer-use first-fire deviation (') for entry in ledger['N2326']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ForceProjector absorbExplosion rows (') for entry in ledger['N2326']['deferred_exprs']))

    def test_all_c07_force_projector_timer_use_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2326']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceForceProjectorBuildState.source_force_projector_timer_use_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ForceProjector.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/modules/ItemModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The Interval.get / check / Time.time formulas live in
        # Arc, not Mindustry: Interval.java and Time.java under
        # arc-upstream (the N2226 precedent).
        upstream['arc-core/src/arc/util/Interval.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Interval.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/util/Time.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Time.java').read_text(encoding='utf-8')
        for expr in ledger['N2326']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_force_projector_timer_use_state(self):
        force_projector = FORCE_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure timer-use function is the frame-local
        # Interval-equivalent (TimerComp.timer, TimerComp.
        # java:10-13: `if(Float.isInfinite(time)) return
        # false;` / `return timer.get(index, time);`; Interval.
        # get resets times[id] = Time.time on fire, Interval.
        # java:20-26; check compares Time.time - times[id] >=
        # time, Interval.java:28-30; Time.time counts TICKS,
        # Time.java:75): elapsed += source_delta
        # unconditionally (source_delta is the UNSCALED
        # Time.delta in ticks, so the frame clock mirrors the
        # global Time.time); consume_tick = elapsed >=
        # threshold, where the threshold is duration /
        # time_scale -- Java DIVIDES phaseUseTime by timeScale
        # here (ForceProjector.java:211), unlike the
        # advances-12 literal timers (the N2290 lesson cuts
        # the other way here: do not invent a literal
        # threshold); a non-positive time_scale is a defensive
        # guard (consume_tick false, threshold INF -- the clock
        # still accumulates); timer_elapsed_after resets to
        # 0.0 on fire (a RESET, not a subtraction like the
        # Fracker accumulator). The Java call is
        # `if(phaseValid && !broken && timer(timerUse,
        # phaseUseTime / timeScale) && efficiency > 0){`
        # (ForceProjector.java:211-213) with `public final int
        # timerUse = timers++;` (:31) and `public float
        # phaseUseTime = 350f;` (:32). The timer ONLY supplies
        # consume_tick -- the gate (phaseValid / !broken /
        # efficiency > 0) stays INSIDE the N2235 advance, so a
        # timer fire alone never consumes. consume() itself
        # (`for(Consume cons : block.consumers){` /
        # `cons.trigger(self());`, BuildingComp.java:1911-1915)
        # removes 1 phaseFabric on the single def only:
        # `itemConsumer = consumeItem(Items.phaseFabric).boost();`
        # (Blocks.java:1974; consumeItem(item) is a stack of 1,
        # Block.java:1167-1168) via ConsumeItems.trigger
        # (ConsumeItems.java:44-48), clamped by ItemModule.remove
        # (ItemModule.java:258-263). The tick wiring computes
        # the timer before the advance call, passes the live
        # consume_tick, and removes 1 phaseFabric when the
        # advance reports consumed (bullets stay [] -- the live
        # bullet scan still defers).
        self.assertIn('static func source_force_projector_timer_use_state', force_projector)
        self.assertIn('if(phaseValid && !broken && timer(timerUse, phaseUseTime / timeScale) && efficiency > 0){', force_projector)
        self.assertIn('public final int timerUse = timers++;', force_projector)
        self.assertIn('public float phaseUseTime = 350f;', force_projector)
        self.assertIn('if(Float.isInfinite(time)) return false;', force_projector)
        self.assertIn('return timer.get(index, time);', force_projector)
        self.assertIn('boolean got = check(id, time);', force_projector)
        self.assertIn('if(got) times[id] = Time.time;', force_projector)
        self.assertIn('return Time.time - times[id] >= time || Time.time < times[id];', force_projector)
        self.assertIn('timeRaw += delta;', force_projector)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', force_projector)
        self.assertIn('for(Consume cons : block.consumers){', force_projector)
        self.assertIn('cons.trigger(self());', force_projector)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', force_projector)
        self.assertIn('itemConsumer = consumeItem(Items.phaseFabric).boost();', force_projector)
        self.assertIn('amount = Math.min(amount, items[item.id]);', force_projector)
        self.assertIn('SOURCE_FORCE_PROJECTOR_PHASE_USE_TIME := 350.0', force_projector)
        self.assertIn('"consume_tick"', force_projector)
        self.assertIn('"timer_elapsed_after"', force_projector)
        self.assertIn('"threshold"', force_projector)
        # The threshold DIVIDES by time_scale -- 350f/timeScale
        # (ForceProjector.java:211), unlike the advances-12
        # literal timers.
        self.assertIn('INF if time_scale <= 0.0 else duration / time_scale', force_projector)
        # The tick wiring: the timer call with the frame clock
        # + tick delta + live time scale + 350f duration; the
        # elapsed write-back; the live consume_tick passed into
        # the advance (bullets stay [] -- the live bullet scan
        # still defers); the consume application removes 1
        # phaseFabric through the shared inventory helper when
        # the advance reports consumed.
        self.assertIn('source_force_projector_timer_use_state(float(frame.get("timer_use_elapsed", 0.0)), source_delta, time_scale, SOURCE_FORCE_PROJECTOR_PHASE_USE_TIME)', force_projector)
        self.assertIn('frame["timer_use_elapsed"]', force_projector)
        self.assertIn('"timer_use_elapsed": 0.0', force_projector)
        self.assertIn('source_force_projector_update_tile_advance_state(frame, source_delta, time_scale, advance_building_x, advance_building_y, [], consume_tick)', force_projector)
        self.assertIn('if bool(advanced.get("consumed", false)):', force_projector)
        self.assertIn('source_drill_inventory_runtime_state.remove_item_state(timer_items, "phase-fabric", 1)', force_projector)
        # The N2235-pinned advance call prefix is UNCHANGED --
        # only the trailing consume_tick argument changed from
        # the false literal.
        self.assertIn('source_force_projector_update_tile_advance_state(frame, source_delta, time_scale, advance_building_x, advance_building_y, []', force_projector)
        # The documented limits now record the cadence +
        # consume application as live (N2326) and the remaining
        # deferral is the live bullet scan, not the timer; the
        # old "driver passes consume_tick false" claims are gone.
        self.assertIn('timerUse cadence + consume() application live (N2326)', force_projector)
        self.assertNotIn('consume_tick false', force_projector)
        self.assertNotIn('the driver passes false', force_projector)
        self.assertIn('updateTile advance live (N2235)', force_projector)
        self.assertIn('phaseFabric booster item row live (N2261)', force_projector)
        # The proof's keys drive the pure timer (fire at
        # 350f/time_scale -- pinned both ways: time_scale 1.0
        # fires at 350, time_scale 2.0 fires at 175, time_scale
        # 0.5 does NOT fire at 350 -- no fire below the
        # threshold, no fire on a non-positive time_scale,
        # elapsed reset on fire) plus the advance gate (a timer
        # fire alone does not consume -- phaseValid / !broken /
        # efficiency > 0 still gate inside the advance) plus the
        # live tick (a fire consumes exactly 1 phaseFabric).
        proof = FORCE_PROJECTOR_TIMER_USE_PROOF.read_text(encoding='utf-8')
        for key in [
            'timer_fires_at_use_time_over_time_scale',
            'timer_no_fire_below_threshold',
            'timer_no_fire_when_time_scale_zero',
            'timer_resets_elapsed_on_fire',
            'live_tick_consumes_phase_fabric_on_fire',
            'consume_tick_alone_does_not_consume',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The / time_scale pin: at time_scale 2.0 the threshold
        # is 175, so 174 + 1 fires -- a literal-350 threshold
        # would NOT fire there; at time_scale 0.5 the threshold
        # is 700, so 349 + 1 does NOT fire -- a literal-350
        # threshold WOULD fire there.
        self.assertIn('timer.call(174.0, 1.0, 2.0, duration)', proof)
        self.assertIn('timer.call(349.0, 1.0, 0.5, duration)', proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceForceProjectorBuildState.gd")', proof)
        self.assertIn('force_projector_build_state.source_force_projector_timer_use_state(', proof)
        self.assertIn('force_projector_build_state.source_force_projector_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(FORCE_PROJECTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = FORCE_PROJECTOR_TIMER_USE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ForceProjectorTimerUseProof.gd', scene)
        self.assertIn('C07ForceProjectorTimerUseProof', scene)

    def test_reference_graph_and_actual_c07_force_projector_timer_use(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ForceProjectorTimerUseProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FORCE_PROJECTOR_TIMER_USE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'timer_fires_at_use_time_over_time_scale',
            'timer_no_fire_below_threshold',
            'timer_no_fire_when_time_scale_zero',
            'timer_resets_elapsed_on_fire',
            'live_tick_consumes_phase_fabric_on_fire',
            'consume_tick_alone_does_not_consume',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
