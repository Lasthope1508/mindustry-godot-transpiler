import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_TIMER_CHECK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerTimerCheckProof.gd'
SHOCKWAVE_TOWER_TIMER_CHECK_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerTimerCheckProof.tscn'


class C07ShockwaveTowerTimerCheckTests(unittest.TestCase):
    def test_c07_shockwave_tower_timer_check_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2318']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_timer_check_state')
        # N2247 ported the updateTile advance
        # (ShockwaveTowerBuild.updateTile(),
        # ShockwaveTower.java:72-105) in full -- the fire gate
        # over the already-charged counter, the bullet scan
        # (rect intersect, enemy + hittable filter), the wave
        # damage, the fire reset and the heat decay -- but the
        # TIMER CADENCE itself deferred (no timer helper in the
        # port, the N2193 precedent), so the driver passed
        # check_ready false and no live fire ever happened.
        # N2318 is the cadence: the frame-local
        # Interval-equivalent pure function (TimerComp.timer,
        # TimerComp.java:10-13, false on an infinite time, else
        # Interval.get, which resets times[id] = Time.time on
        # fire, arc Interval.java:20-26; Time.time counts
        # TICKS, arc Time.java:69-80) plus the tick wiring --
        # the frame clock frame["timer_check_elapsed"]
        # accumulates the tick delta every tick the advance
        # runs, and when it fires the advance sees check_ready
        # true. Java passes checkInterval (8f) with NO
        # timeScale division (the N2290 lesson -- do not
        # invent a / time_scale), so the threshold is the
        # literal duration. Three new result symbols:
        # check_ready, timer_elapsed_after and threshold.
        self.assertEqual(
            ledger['N2318']['source_symbols'],
            [
                'source_shockwave_tower_timer_check_state_result.check_ready',
                'source_shockwave_tower_timer_check_state_result.timer_elapsed_after',
                'source_shockwave_tower_timer_check_state_result.threshold',
            ],
        )
        for name in ledger['N2318']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/TimerComp.java',
                    'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_timer_check_state_result.check_ready': 'SourceShockwaveTowerBuildState.source_shockwave_tower_timer_check_state',
                    'source_shockwave_tower_timer_check_state_result.timer_elapsed_after': 'SourceShockwaveTowerBuildState.source_shockwave_tower_timer_check_state',
                    'source_shockwave_tower_timer_check_state_result.threshold': 'SourceShockwaveTowerBuildState.source_shockwave_tower_timer_check_state',
                }[name])
        self.assertEqual(ledger['N2318']['runtime_proof'], '/root/C07ShockwaveTowerTimerCheckProof')
        self.assertEqual(
            ledger['N2318']['tests'],
            [
                'test_c07_shockwave_tower_timer_check_registration',
                'test_all_c07_shockwave_tower_timer_check_input_evidence_is_exact',
                'test_shockwave_tower_timer_check_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_timer_check',
            ],
        )
        self.assertTrue(ledger['N2318']['deferred_exprs'])
        # The cadence is live now, so the timer-fill entry is
        # gone; the live bullet scan entry stays (candidates
        # are still [] live); one new deferral joined at
        # N2318: the first-fire deviation (Java fires nearly
        # at once after placement; the frame-local clock
        # delays the first fire by a full 8-tick interval).
        self.assertFalse(any(entry.startswith('ShockwaveTower updateTile live timer fill (') for entry in ledger['N2318']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower updateTile live bullet scan fill (') for entry in ledger['N2318']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower timer-check first-fire deviation (') for entry in ledger['N2318']['deferred_exprs']))

    def test_all_c07_shockwave_tower_timer_check_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2318']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_timer_check_state_result.check_ready': 'SourceShockwaveTowerBuildState.source_shockwave_tower_timer_check_state',
                    'source_shockwave_tower_timer_check_state_result.timer_elapsed_after': 'SourceShockwaveTowerBuildState.source_shockwave_tower_timer_check_state',
                    'source_shockwave_tower_timer_check_state_result.threshold': 'SourceShockwaveTowerBuildState.source_shockwave_tower_timer_check_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The Interval.get / check / Time.time formulas live in
        # Arc, not Mindustry: Interval.java and Time.java under
        # arc-upstream (the N2226 precedent).
        upstream['arc-core/src/arc/util/Interval.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Interval.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/util/Time.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Time.java').read_text(encoding='utf-8')
        for expr in ledger['N2318']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_timer_check_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The pure timer-check function is the frame-local
        # Interval-equivalent (TimerComp.timer, TimerComp.
        # java:10-13: `if(Float.isInfinite(time)) return
        # false;` / `return timer.get(index, time);`; Interval.
        # get resets times[id] = Time.time on fire, Interval.
        # java:20-26; check compares Time.time - times[id] >=
        # time, Interval.java:28-30; Time.time counts TICKS,
        # Time.java:69-80): elapsed += source_delta
        # unconditionally (source_delta is the UNSCALED
        # Time.delta in ticks, so the frame clock mirrors the
        # global Time.time); check_ready = elapsed >=
        # threshold (the LITERAL duration -- Java passes
        # checkInterval (8f) with no timeScale division, the
        # N2290 lesson); a non-positive time_scale is a
        # defensive guard (check_ready false, threshold INF --
        # the clock still accumulates); timer_elapsed_after
        # resets to 0.0 on fire (a RESET, not a subtraction
        # like the Fracker accumulator). The Java call is
        # `if(potentialEfficiency > 0 && (reloadCounter +=
        # edelta()) >= reload && timer(timerCheck,
        # checkInterval)){` (ShockwaveTower.java:73) with
        # `public int timerCheck = timers ++;` (:23) and
        # `public float checkInterval = 8f;` (:31). The timer
        # ONLY supplies check_ready -- the fire gate still
        # needs potentialEfficiency > 0 and counter >= reload
        # (the N2247 advance gates on all three), so a timer
        # fire alone never fires the wave. The tick wiring
        # accumulates frame["timer_check_elapsed"] every tick
        # the advance runs and passes the computed check_ready
        # into the advance (the live bullet scan is live since
        # N2327 -- the advance call passes the scanned list,
        # not the empty literal). The reload charge (N2187)
        # is untouched.
        self.assertIn('static func source_shockwave_tower_timer_check_state', shockwave_tower)
        self.assertIn('if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', shockwave_tower)
        self.assertIn('public int timerCheck = timers ++;', shockwave_tower)
        self.assertIn('public float checkInterval = 8f;', shockwave_tower)
        self.assertIn('if(Float.isInfinite(time)) return false;', shockwave_tower)
        self.assertIn('return timer.get(index, time);', shockwave_tower)
        self.assertIn('boolean got = check(id, time);', shockwave_tower)
        self.assertIn('if(got) times[id] = Time.time;', shockwave_tower)
        self.assertIn('return Time.time - times[id] >= time || Time.time < times[id];', shockwave_tower)
        self.assertIn('timeRaw += delta;', shockwave_tower)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', shockwave_tower)
        self.assertIn('SOURCE_SHOCKWAVE_TOWER_CHECK_INTERVAL := 8.0', shockwave_tower)
        self.assertIn('"check_ready"', shockwave_tower)
        self.assertIn('"timer_elapsed_after"', shockwave_tower)
        self.assertIn('"threshold"', shockwave_tower)
        # The threshold is the literal duration -- no
        # timeScale division anywhere in the pure (the N2290
        # lesson: Java passes checkInterval, not
        # checkInterval / timeScale).
        self.assertIn('INF if time_scale <= 0.0 else duration', shockwave_tower)
        self.assertNotIn('duration / time_scale', shockwave_tower)
        # The tick wiring: the timer call with the frame clock
        # + tick delta + live time scale + 8f duration; the
        # elapsed write-back; check_ready passed into the
        # advance with the refined bullet list (the live
        # bullet scan is live since N2327 -- the N2318 pin
        # on the empty candidate list was updated by the
        # N2327 follow-through, the N2316 / d4c14912
        # precedent -- and the hitbox refinement is live
        # since N2340, so the advance now takes the refined
        # list, the N2335 follow-through precedent).
        self.assertIn('source_shockwave_tower_timer_check_state(float(frame.get("timer_check_elapsed", 0.0)), source_placed_block_state.game_source_delta(game, seconds), source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game)), SOURCE_SHOCKWAVE_TOWER_CHECK_INTERVAL)', shockwave_tower)
        self.assertIn('frame["timer_check_elapsed"]', shockwave_tower)
        self.assertIn('SOURCE_SHOCKWAVE_TOWER_COOLDOWN_MULTIPLIER, refined_bullets, check_ready)', shockwave_tower)
        # The N2247-pinned advance call prefix is UNCHANGED --
        # only the trailing check_ready argument changed from
        # the false literal.
        self.assertIn('source_shockwave_tower_update_tile_advance_state(frame, source_placed_block_state.game_source_delta(game, seconds)', shockwave_tower)
        # The documented limits now record the cadence as live
        # (N2318) and the remaining deferral is the live bullet
        # scan, not the timer; the old "cadence defers" claim
        # is gone.
        self.assertIn('timerCheck cadence live (N2318)', shockwave_tower)
        self.assertNotIn('The TIMER CADENCE itself defers', shockwave_tower)
        self.assertIn('updateTile advance live (N2247)', shockwave_tower)
        self.assertIn('shouldConsume gate live (N2187)', shockwave_tower)
        # The proof's keys drive the pure timer (fire at 8
        # ticks, no fire below the threshold, no fire on a
        # non-positive time_scale, elapsed reset on fire) plus
        # the live tick (check_ready reaches the advance on a
        # fire, and a timer fire alone does not fire the wave
        # -- the advance gate still needs the charged counter).
        proof = SHOCKWAVE_TOWER_TIMER_CHECK_PROOF.read_text(encoding='utf-8')
        for key in [
            'timer_fires_at_eight_ticks',
            'timer_no_fire_below_threshold',
            'timer_no_fire_when_time_scale_zero',
            'timer_resets_elapsed_on_fire',
            'live_tick_passes_check_ready_on_fire',
            'timer_fire_alone_does_not_fire_wave',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # N2290-lesson pin: the proof pins the literal-8
        # threshold at overdrive (7 + 1 fires at time_scale
        # 2.0) and the no-early-fire case (3 + 1 does NOT fire
        # at time_scale 2.0 -- a checkInterval / time_scale
        # deviation would fire there, threshold 4).
        self.assertIn('timer.call(7.0, 1.0, 2.0, duration)', proof)
        self.assertIn('timer.call(3.0, 1.0, 2.0, duration)', proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceShockwaveTowerBuildState.gd")', proof)
        self.assertIn('shockwave_tower_build_state.source_shockwave_tower_timer_check_state(', proof)
        self.assertIn('shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(SHOCKWAVE_TOWER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = SHOCKWAVE_TOWER_TIMER_CHECK_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ShockwaveTowerTimerCheckProof.gd', scene)
        self.assertIn('C07ShockwaveTowerTimerCheckProof', scene)

    def test_reference_graph_and_actual_c07_shockwave_tower_timer_check(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerTimerCheckProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_TIMER_CHECK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'timer_fires_at_eight_ticks',
            'timer_no_fire_below_threshold',
            'timer_no_fire_when_time_scale_zero',
            'timer_resets_elapsed_on_fire',
            'live_tick_passes_check_ready_on_fire',
            'timer_fire_alone_does_not_fire_wave',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
