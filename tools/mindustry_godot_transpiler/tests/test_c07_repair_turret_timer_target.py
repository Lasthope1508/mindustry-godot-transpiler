import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_TIMER_TARGET_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretTimerTargetProof.gd'
REPAIR_TURRET_TIMER_TARGET_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretTimerTargetProof.tscn'


class C07RepairTurretTimerTargetTests(unittest.TestCase):
    def test_c07_repair_turret_timer_target_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2280']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_timer_target_state')
        # N2226 ported the updateTile advance (RepairPointBuild.
        # updateTile(), RepairTurret.java:187-218) in full --
        # the target clear when dead / out of range / full
        # health (:193-194), the heal branch (:203-210), the
        # rotation slerp / strength lerp (:209/:212), and the
        # re-acquire SELECTION as a pure function over an
        # explicit candidate list (Units.closest = min dst2
        # among the damaged, valid, in-range candidates,
        # Units.java:358-372) -- but the TIMER CADENCE itself
        # deferred (no timer helper in the port, the N2193
        # precedent), so the driver passed an empty candidate
        # list and no live re-acquire ever happened. N2280 is
        # the cadence: the frame-local Interval-equivalent
        # pure function (TimerComp.timer, TimerComp.java:
        # 10-13, false on an infinite time, else Interval.get,
        # which resets times[id] = Time.time on fire, arc
        # Interval.java:20-26; Time.time counts TICKS, arc
        # Time.java:69-80) plus the tick wiring -- the frame
        # clock frame["timer_target_elapsed"] accumulates the
        # tick delta every tick the advance runs, and when it
        # fires the frame-input unit_candidates reach the
        # advance; when it does not fire the advance sees []
        # as before. The N2226 test pins the advance call text
        # with a [] literal, so the candidates ride the frame
        # (the coolant_multiplier N2259 precedent): the tick
        # stamps frame["unit_candidates"] with the input
        # candidates on a fire and [] otherwise, and the
        # advance falls back to that key when its explicit
        # list is empty. Two new result symbols: fired and
        # elapsed_after.
        self.assertEqual(
            ledger['N2280']['source_symbols'],
            [
                'source_repair_turret_timer_target_state_result.fired',
                'source_repair_turret_timer_target_state_result.elapsed_after',
            ],
        )
        for name in ledger['N2280']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/TimerComp.java',
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_turret_timer_target_state_result.fired': 'SourceRepairTurretBuildState.source_repair_turret_timer_target_state',
                    'source_repair_turret_timer_target_state_result.elapsed_after': 'SourceRepairTurretBuildState.source_repair_turret_timer_target_state',
                }[name])
        self.assertEqual(ledger['N2280']['runtime_proof'], '/root/C07RepairTurretTimerTargetProof')
        self.assertEqual(
            ledger['N2280']['tests'],
            [
                'test_c07_repair_turret_timer_target_registration',
                'test_all_c07_repair_turret_timer_target_input_evidence_is_exact',
                'test_repair_turret_timer_target_state',
                'test_reference_graph_and_actual_c07_repair_turret_timer_target',
            ],
        )
        self.assertTrue(ledger['N2280']['deferred_exprs'])
        # The cadence is live now, so the two RepairTurret
        # entries that blamed the missing timer are rewritten
        # (same prefixes, new text): the live-acquire entry
        # now waits only on the live Units scan, and the live-
        # fill entry records the cadence as live since N2280.
        # Two new deferrals join: the first-fire deviation and
        # the time-scale threshold deviation (Java passes a
        # literal 20, RepairTurret.java:214, with no timeScale
        # division -- unlike the N2269/N2273 precedents).
        self.assertTrue(any(entry.startswith('RepairTurret live target acquire (') and 'cadence is live since N2280' in entry for entry in ledger['N2280']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTurret updateTile live fill (') and 'cadence is live since N2280' in entry for entry in ledger['N2280']['deferred_exprs']))
        self.assertFalse(any('there is no timer helper in the port and no live unit query, so the driver passes an empty candidate list and no live re-acquire happens' in entry for entry in ledger['N2280']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTurret timer-target first-fire deviation (') for entry in ledger['N2280']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTurret timer-target time-scale threshold deviation (') for entry in ledger['N2280']['deferred_exprs']))

    def test_all_c07_repair_turret_timer_target_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2280']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_turret_timer_target_state_result.fired': 'SourceRepairTurretBuildState.source_repair_turret_timer_target_state',
                    'source_repair_turret_timer_target_state_result.elapsed_after': 'SourceRepairTurretBuildState.source_repair_turret_timer_target_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The Interval.get / check / Time.time formulas live in
        # Arc, not Mindustry: Interval.java and Time.java under
        # arc-upstream (the N2226 precedent).
        upstream['arc-core/src/arc/util/Interval.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Interval.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/util/Time.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Time.java').read_text(encoding='utf-8')
        for expr in ledger['N2280']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_timer_target_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The pure timer-target function is the frame-local
        # Interval-equivalent (TimerComp.timer, TimerComp.
        # java:10-13: `if(Float.isInfinite(time)) return
        # false;` / `return timer.get(index, time);`; Interval.
        # get resets times[id] = Time.time on fire, Interval.
        # java:20-26; check compares Time.time - times[id] >=
        # time, Interval.java:28-30; Time.time counts TICKS,
        # Time.java:69-80): elapsed += source_delta
        # unconditionally; fired = elapsed >= duration /
        # time_scale; a non-positive time_scale is the
        # infinite-time branch (fired false); elapsed_after
        # resets to 0.0 on fire (a RESET, not a subtraction
        # like the Fracker accumulator). The Java call is
        # `if(timer(timerTarget, 20)){` (RepairTurret.java:
        # 214-216) with `public int timerTarget = timers++;`
        # (:29) and `public float repairRadius = 50f;` (:32).
        # NOTE the threshold deviation: Java passes a LITERAL
        # 20 -- no timeScale division, unlike the MendProjector
        # (`timer(timerUse, useTime / timeScale)`,
        # MendProjector.java:102) / WallCrafter / ImpactReactor
        # timers -- so the port's 20/time_scale threshold is
        # Java-exact at time_scale 1f and diverges only under
        # overdrive / slowdown. The tick wiring accumulates
        # frame["timer_target_elapsed"] every tick the advance
        # runs and stamps frame["unit_candidates"] with the
        # frame-input candidates on a fire, [] otherwise; the
        # advance falls back to that frame key when its
        # explicit candidate list is empty (the N2226 test pins
        # the advance call text with a [] literal, so the
        # candidates ride the frame like coolant_multiplier,
        # N2259). The selection logic itself is untouched.
        self.assertIn('static func source_repair_turret_timer_target_state', repair_turret)
        self.assertIn('if(timer(timerTarget, 20)){', repair_turret)
        self.assertIn('rect.setSize(repairRadius * 2).setCenter(x, y);', repair_turret)
        self.assertIn('target = Units.closest(team, x, y, repairRadius, Unit::damaged);', repair_turret)
        self.assertIn('public int timerTarget = timers++;', repair_turret)
        self.assertIn('public float repairRadius = 50f;', repair_turret)
        self.assertIn('if(Float.isInfinite(time)) return false;', repair_turret)
        self.assertIn('return timer.get(index, time);', repair_turret)
        self.assertIn('boolean got = check(id, time);', repair_turret)
        self.assertIn('if(got) times[id] = Time.time;', repair_turret)
        self.assertIn('return Time.time - times[id] >= time || Time.time < times[id];', repair_turret)
        self.assertIn('timeRaw += delta;', repair_turret)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_TIMER_TARGET_DURATION := 20.0', repair_turret)
        self.assertIn('"fired"', repair_turret)
        self.assertIn('"elapsed_after"', repair_turret)
        # The tick wiring: the timer call with the frame clock
        # + tick delta + live time scale + 20f duration; the
        # elapsed write-back; the gated candidate stamp; the
        # frame fallback inside the advance.
        self.assertIn('source_repair_turret_timer_target_state(float(frame.get("timer_target_elapsed", 0.0)), source_delta, time_scale, SOURCE_REPAIR_TURRET_TIMER_TARGET_DURATION)', repair_turret)
        self.assertIn('frame["timer_target_elapsed"]', repair_turret)
        self.assertIn('frame["unit_candidates"]', repair_turret)
        self.assertIn('frame.get("unit_candidates", [])', repair_turret)
        self.assertIn('effective_candidates', repair_turret)
        # The N2226-pinned advance call text is UNCHANGED --
        # the candidates ride the frame, not a new parameter.
        self.assertIn('source_repair_turret_update_tile_advance_state(frame, source_delta, time_scale, advance_repair_speed, advance_repair_radius, advance_building_x, advance_building_y, [])', repair_turret)
        # The documented limits now record the cadence as live
        # (N2280) and the remaining deferral is the live Units
        # scan, not the timer; the old "cadence defers" claim
        # is gone.
        self.assertIn('timer cadence live (N2280)', repair_turret)
        self.assertNotIn('The TIMER CADENCE itself defers', repair_turret)
        self.assertIn('updateTile advance live (N2226)', repair_turret)
        self.assertIn('shouldConsume gate live (N2212)', repair_turret)
        # The proof's keys drive the pure timer (fire at 20
        # ticks, no fire below the threshold, no fire on a
        # non-positive time_scale, elapsed reset on fire) plus
        # the live tick (candidates reach the advance on a
        # fire, [] when the timer has not fired).
        proof = REPAIR_TURRET_TIMER_TARGET_PROOF.read_text(encoding='utf-8')
        for key in [
            'timer_fires_at_twenty_ticks',
            'timer_no_fire_below_threshold',
            'timer_no_fire_when_time_scale_zero',
            'timer_passes_candidates_on_fire',
            'timer_passes_empty_when_not_fired',
            'timer_resets_elapsed_on_fire',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceRepairTurretBuildState.gd")', proof)
        self.assertIn('repair_turret_build_state.source_repair_turret_timer_target_state(', proof)
        self.assertIn('repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(REPAIR_TURRET_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = REPAIR_TURRET_TIMER_TARGET_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RepairTurretTimerTargetProof.gd', scene)
        self.assertIn('C07RepairTurretTimerTargetProof', scene)

    def test_reference_graph_and_actual_c07_repair_turret_timer_target(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretTimerTargetProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_TIMER_TARGET_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'timer_fires_at_twenty_ticks',
            'timer_no_fire_below_threshold',
            'timer_no_fire_when_time_scale_zero',
            'timer_passes_candidates_on_fire',
            'timer_passes_empty_when_not_fired',
            'timer_resets_elapsed_on_fire',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
