import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TRACTOR_BEAM_STATE = ROOT / 'godot-mindustry/src/game/SourceTractorBeamTurretBuildState.gd'
TRACTOR_BEAM_RETARGET_CADENCE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TractorBeamTurretRetargetCadenceProof.gd'
TRACTOR_BEAM_RETARGET_CADENCE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TractorBeamTurretRetargetCadenceProof.tscn'


class C07TractorBeamTurretRetargetCadenceTests(unittest.TestCase):
    def test_c07_tractor_beam_turret_retarget_cadence_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2317']['godot_owner'], 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_retarget_timer_state')
        # N2230 ported the updateTile advance (TractorBeamBuild.
        # updateTile(), TractorBeamTurret.java:78-139) in full --
        # the activation early return (:79-82), the eff/edelta
        # fold (:84), the retarget SELECTION as a pure function
        # over an explicit candidate list (Units.closestEnemy:
        # derelict null, dst2 minus hitSize squared, priority
        # wins, strict < first-wins-ties, Units.java:296-313),
        # the coolant consume (:92-106), and the rotation /
        # strength / damage / impulse look-at (:111-139) -- but
        # the TIMER CADENCE itself deferred (no timer helper in
        # the port, the N2193 precedent), so the driver passed
        # retarget_tick false and an empty candidate list and
        # no live retarget ever happened. N2317 is the cadence:
        # the frame-local Interval-equivalent pure function
        # (TimerComp.timer, TimerComp.java:10-13, false on an
        # infinite time, else Interval.get, which resets
        # times[id] = Time.time on fire, arc Interval.java:
        # 20-26; Time.time counts TICKS, arc Time.java:69-80)
        # plus the tick wiring -- the frame clock frame[
        # "timer_retarget_elapsed"] accumulates the tick delta
        # every tick the advance runs, and when it fires the
        # retarget_tick flag reaches the advance with the
        # frame-input unit_candidates; when it does not fire
        # the advance sees retarget_tick false as before. The
        # Java call is `if(timer(timerTarget, retargetTime)){`
        # (TractorBeamTurret.java:87) with `public float
        # retargetTime = 5f;` (:21) -- a LITERAL 5f, no
        # timeScale division (the N2290 lesson: Java passes
        # the duration straight to timer(), unlike the dump
        # timers). Two new result symbols: retarget_tick and
        # timer_elapsed_after.
        self.assertEqual(
            ledger['N2317']['source_symbols'],
            [
                'source_tractor_beam_turret_retarget_timer_state_result.retarget_tick',
                'source_tractor_beam_turret_retarget_timer_state_result.timer_elapsed_after',
            ],
        )
        for name in ledger['N2317']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/TimerComp.java',
                    'core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_tractor_beam_turret_retarget_timer_state_result.retarget_tick': 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_retarget_timer_state',
                    'source_tractor_beam_turret_retarget_timer_state_result.timer_elapsed_after': 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_retarget_timer_state',
                }[name])
        self.assertEqual(ledger['N2317']['runtime_proof'], '/root/C07TractorBeamTurretRetargetCadenceProof')
        self.assertEqual(
            ledger['N2317']['tests'],
            [
                'test_c07_tractor_beam_turret_retarget_cadence_registration',
                'test_all_c07_tractor_beam_turret_retarget_cadence_input_evidence_is_exact',
                'test_tractor_beam_turret_retarget_cadence_state',
                'test_reference_graph_and_actual_c07_tractor_beam_turret_retarget_cadence',
            ],
        )
        self.assertTrue(ledger['N2317']['deferred_exprs'])
        # The cadence is live now, so the TractorBeamTurret
        # live-fill entry that blamed the missing timer is
        # rewritten (same prefix, new text): the cadence clause
        # records the timer as live since N2317, and the
        # remaining deferrals are the live enemy scan, the
        # coolant live fill, the damage / impulse / status
        # application, and the sound / draw rows. One new
        # deferral joined at N2317: the first-fire deviation
        # (still open).
        self.assertTrue(any(entry.startswith('TractorBeamTurret updateTile live fill (') and 'cadence is live since N2317' in entry for entry in ledger['N2317']['deferred_exprs']))
        self.assertFalse(any('there is no timer helper in the port and no live unit query, so the driver passes retarget_tick false and an empty candidate list and no live retarget happens' in entry for entry in ledger['N2317']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('TractorBeamTurret retarget timer first-fire deviation (') for entry in ledger['N2317']['deferred_exprs']))

    def test_all_c07_tractor_beam_turret_retarget_cadence_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2317']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_tractor_beam_turret_retarget_timer_state_result.retarget_tick': 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_retarget_timer_state',
                    'source_tractor_beam_turret_retarget_timer_state_result.timer_elapsed_after': 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_retarget_timer_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The Interval.get / check / Time.time formulas live in
        # Arc, not Mindustry: Interval.java and Time.java under
        # arc-upstream (the N2226 precedent).
        upstream['arc-core/src/arc/util/Interval.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Interval.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/util/Time.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Time.java').read_text(encoding='utf-8')
        for expr in ledger['N2317']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_tractor_beam_turret_retarget_cadence_state(self):
        tractor_beam = TRACTOR_BEAM_STATE.read_text(encoding='utf-8')
        # The pure retarget-timer function is the frame-local
        # Interval-equivalent (TimerComp.timer, TimerComp.
        # java:10-13: `if(Float.isInfinite(time)) return
        # false;` / `return timer.get(index, time);`; Interval.
        # get resets times[id] = Time.time on fire, Interval.
        # java:20-26; check compares Time.time - times[id] >=
        # time, Interval.java:28-30; Time.time counts TICKS,
        # Time.java:69-80): elapsed += source_delta
        # unconditionally (source_delta is the UNSCALED
        # Time.delta in ticks, so the frame clock mirrors the
        # global Time.time); retarget_tick = elapsed >=
        # duration (the LITERAL duration -- no timeScale
        # division, the N2290 lesson: Java passes retargetTime
        # 5f straight to timer(), TractorBeamTurret.java:87);
        # a non-positive time_scale is a defensive guard
        # (retarget_tick false -- the clock still accumulates);
        # timer_elapsed_after resets to 0.0 on fire (a RESET,
        # not a subtraction like the Fracker accumulator). The
        # Java call is `if(timer(timerTarget, retargetTime)){`
        # (TractorBeamTurret.java:87-88) with `public final
        # int timerTarget = timers++;` (:20) and `public float
        # retargetTime = 5f;` (:21). The tick wiring accumulates
        # frame["timer_retarget_elapsed"] every tick the advance
        # runs and passes the live retarget_tick plus the
        # frame-input unit_candidates into the N2230 advance;
        # the selection logic itself is untouched.
        self.assertIn('static func source_tractor_beam_turret_retarget_timer_state', tractor_beam)
        self.assertIn('if(timer(timerTarget, retargetTime)){', tractor_beam)
        self.assertIn('target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));', tractor_beam)
        self.assertIn('public final int timerTarget = timers++;', tractor_beam)
        self.assertIn('public float retargetTime = 5f;', tractor_beam)
        self.assertIn('public class TractorBeamTurret extends BaseTurret{', tractor_beam)
        self.assertIn('if(Float.isInfinite(time)) return false;', tractor_beam)
        self.assertIn('return timer.get(index, time);', tractor_beam)
        self.assertIn('boolean got = check(id, time);', tractor_beam)
        self.assertIn('if(got) times[id] = Time.time;', tractor_beam)
        self.assertIn('return Time.time - times[id] >= time || Time.time < times[id];', tractor_beam)
        self.assertIn('timeRaw += delta;', tractor_beam)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', tractor_beam)
        self.assertIn('SOURCE_TRACTOR_BEAM_TURRET_RETARGET_DURATION := 5.0', tractor_beam)
        self.assertIn('"retarget_tick"', tractor_beam)
        self.assertIn('"timer_elapsed_after"', tractor_beam)
        # The threshold is the literal duration -- no timeScale
        # division anywhere in the pure (the N2290 lesson:
        # Java passes retargetTime 5f straight to timer()).
        self.assertIn('INF if time_scale <= 0.0 else duration', tractor_beam)
        self.assertNotIn('duration / time_scale', tractor_beam)
        # The tick wiring: the timer call with the frame clock
        # + tick delta + live time scale + 5f duration; the
        # elapsed write-back; the frame-input candidates; the
        # live retarget_tick into the N2230 advance call.
        self.assertIn('source_tractor_beam_turret_retarget_timer_state(float(frame.get("timer_retarget_elapsed", 0.0)), source_delta, time_scale, SOURCE_TRACTOR_BEAM_TURRET_RETARGET_DURATION)', tractor_beam)
        self.assertIn('frame["timer_retarget_elapsed"]', tractor_beam)
        self.assertIn('frame.get("unit_candidates", [])', tractor_beam)
        self.assertIn('source_tractor_beam_turret_update_tile_advance_state(frame, source_delta, time_scale, advance_building_x, advance_building_y, team_id, retarget_candidates, retarget_tick, false, 0.0, 0.0, 0.0, 1.0, false)', tractor_beam)
        # The documented limits now record the cadence as live
        # (N2317) and the remaining deferral is the live unit
        # query, not the timer; the old "cadence defers" claim
        # is gone.
        self.assertIn('timer cadence live (N2317)', tractor_beam)
        self.assertNotIn('The TIMER CADENCE defers', tractor_beam)
        self.assertIn('updateTile advance live (N2230)', tractor_beam)
        self.assertIn('shouldConsume gate live (N2218)', tractor_beam)
        # The proof's keys drive the pure timer (fire at 5
        # ticks, no fire below the threshold, no fire on a
        # non-positive time_scale, elapsed reset on fire) plus
        # the live tick (the retarget flag reaches the advance
        # on a fire, and a fire with empty candidates clears
        # the target like Java's unconditional assignment).
        proof = TRACTOR_BEAM_RETARGET_CADENCE_PROOF.read_text(encoding='utf-8')
        for key in [
            'timer_fires_at_five_ticks',
            'timer_no_fire_below_threshold',
            'timer_no_fire_when_time_scale_zero',
            'timer_resets_elapsed_on_fire',
            'live_tick_passes_retarget_on_fire',
            'fire_with_empty_candidates_clears_target',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The literal-5 threshold pin at overdrive (4 + 1
        # fires at time_scale 2.0) and the no-early-fire case
        # (2 + 1 does NOT fire at time_scale 2.0 -- a
        # 5/time_scale deviation would fire there).
        self.assertIn('timer.call(4.0, 1.0, 2.0, duration)', proof)
        self.assertIn('timer.call(2.0, 1.0, 2.0, duration)', proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceTractorBeamTurretBuildState.gd")', proof)
        self.assertIn('tractor_beam_turret_build_state.source_tractor_beam_turret_retarget_timer_state(', proof)
        self.assertIn('tractor_beam_turret_build_state.source_tractor_beam_turret_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(TRACTOR_BEAM_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = TRACTOR_BEAM_RETARGET_CADENCE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07TractorBeamTurretRetargetCadenceProof.gd', scene)
        self.assertIn('C07TractorBeamTurretRetargetCadenceProof', scene)

    def test_reference_graph_and_actual_c07_tractor_beam_turret_retarget_cadence(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TractorBeamTurretRetargetCadenceProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TRACTOR_BEAM_TURRET_RETARGET_CADENCE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'timer_fires_at_five_ticks',
            'timer_no_fire_below_threshold',
            'timer_no_fire_when_time_scale_zero',
            'timer_resets_elapsed_on_fire',
            'live_tick_passes_retarget_on_fire',
            'fire_with_empty_candidates_clears_target',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
