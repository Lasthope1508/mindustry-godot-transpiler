import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
POINT_DEFENSE_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourcePointDefenseTurretBuildState.gd'
POINT_DEFENSE_TURRET_RETARGET_CADENCE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretRetargetCadenceProof.gd'
POINT_DEFENSE_TURRET_RETARGET_CADENCE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretRetargetCadenceProof.tscn'


class C07PointDefenseTurretRetargetCadenceTests(unittest.TestCase):
    def test_c07_point_defense_turret_retarget_cadence_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2316']['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_retarget_timer_state')
        # N2229 ported the updateTile advance (PointDefenseBuild.
        # updateTile(), PointDefenseTurret.java:62-103) in full --
        # the retarget SELECTION as a pure function over an
        # explicit bullet list with a retarget_tick bool
        # (Groups.bullet RECTANGLE intersect + min raw dst2,
        # Seq.min last-wins ties, :65-67), the pooled clear
        # (:70-72), the coolant branch (:74-76), and the
        # look-at branch (:78-103) -- but the TIMER CADENCE
        # itself deferred (no timer helper in the port, the
        # N2193 precedent), so the driver passed retarget_tick
        # false and an empty list and no live retarget ever
        # happened. N2316 is the cadence: the pure retarget-
        # timer function is the frame-local Interval-
        # equivalent of TimerComp.timer (TimerComp.java:10-13,
        # `if(Float.isInfinite(time)) return false;` /
        # `return timer.get(index, time);`; Interval.get resets
        # times[id] = Time.time on fire, arc Interval.java:
        # 20-26; check compares Time.time - times[id] >= time,
        # arc Interval.java:28-30; Time.time counts TICKS, arc
        # Time.java:69-80) -- elapsed += source_delta
        # unconditionally (source_delta is the UNSCALED
        # Time.delta in ticks, so the frame clock mirrors the
        # global Time.time), retarget_tick = elapsed >=
        # duration (the LITERAL duration -- no timeScale
        # division, the N2290 lesson: Java passes retargetTime
        # 5f straight to timer(), PointDefenseTurret.java:65),
        # a non-positive time_scale is a defensive guard
        # (retarget_tick false -- the clock still accumulates),
        # timer_elapsed_after resets to 0.0 on fire (a RESET,
        # not a subtraction like the Fracker accumulator). The
        # tick accumulates frame["timer_retarget_elapsed"]
        # every tick the advance runs and passes the timer's
        # retarget_tick into the N2229 advance (replacing the
        # false literal); the bullets stay the empty list as
        # before -- the live bullet query still defers, so a
        # fire with no bullets clears the target to null
        # exactly like Java's unconditional assignment
        # (PointDefenseTurret.java:66). Two new result symbols:
        # retarget_tick and timer_elapsed_after.
        self.assertEqual(
            ledger['N2316']['source_symbols'],
            [
                'source_point_defense_turret_retarget_timer_state_result.retarget_tick',
                'source_point_defense_turret_retarget_timer_state_result.timer_elapsed_after',
            ],
        )
        for name in ledger['N2316']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/TimerComp.java',
                    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_retarget_timer_state_result.retarget_tick': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_retarget_timer_state',
                    'source_point_defense_turret_retarget_timer_state_result.timer_elapsed_after': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_retarget_timer_state',
                }[name])
        self.assertEqual(ledger['N2316']['runtime_proof'], '/root/C07PointDefenseTurretRetargetCadenceProof')
        self.assertEqual(
            ledger['N2316']['tests'],
            [
                'test_c07_point_defense_turret_retarget_cadence_registration',
                'test_all_c07_point_defense_turret_retarget_cadence_input_evidence_is_exact',
                'test_point_defense_turret_retarget_cadence_state',
                'test_reference_graph_and_actual_c07_point_defense_turret_retarget_cadence',
            ],
        )
        self.assertTrue(ledger['N2316']['deferred_exprs'])
        # The cadence is live now, so the PointDefenseTurret
        # live-fill entry that blamed the missing timer is
        # rewritten (same prefix, new text): the cadence clause
        # records the timer as live since N2316, and the entry
        # now waits only on the live bullet scan fill, the
        # coolant live fill, the damage application on the live
        # bullet, and the effects/sound. One new deferral
        # joined at N2316: the first-fire deviation (the
        # frame-local clock delays the first retarget by a full
        # 5-tick interval; Java fires nearly immediately after
        # placement).
        self.assertTrue(any(entry.startswith('PointDefenseTurret updateTile live fill (') and 'cadence is live since N2316' in entry for entry in ledger['N2316']['deferred_exprs']))
        self.assertFalse(any('there is no timer helper in the port and no live bullet query, so the driver passes retarget_tick false and an empty list and no live retarget happens' in entry for entry in ledger['N2316']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PointDefenseTurret retarget first-fire deviation (') for entry in ledger['N2316']['deferred_exprs']))

    def test_all_c07_point_defense_turret_retarget_cadence_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2316']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_retarget_timer_state_result.retarget_tick': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_retarget_timer_state',
                    'source_point_defense_turret_retarget_timer_state_result.timer_elapsed_after': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_retarget_timer_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The Interval.get / check / Time.time formulas live in
        # Arc, not Mindustry: Interval.java and Time.java under
        # arc-upstream (the N2226 precedent).
        upstream['arc-core/src/arc/util/Interval.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Interval.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/util/Time.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Time.java').read_text(encoding='utf-8')
        for expr in ledger['N2316']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_point_defense_turret_retarget_cadence_state(self):
        point_defense_turret = POINT_DEFENSE_TURRET_STATE.read_text(encoding='utf-8')
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
        # division, the N2290 lesson); a non-positive
        # time_scale is a defensive guard (retarget_tick false
        # -- the clock still accumulates); timer_elapsed_after
        # resets to 0.0 on fire (a RESET, not a subtraction
        # like the Fracker accumulator). The Java call is
        # `if(timer(timerTarget, retargetTime)){`
        # (PointDefenseTurret.java:65-67) with `public final
        # int timerTarget = timers++;` (:20) and `public float
        # retargetTime = 5f;` (:21). Java passes retargetTime
        # straight to timer() -- no timeScale division, unlike
        # the MendProjector (`timer(timerUse, useTime /
        # timeScale)`, MendProjector.java:102) / WallCrafter /
        # ImpactReactor timers -- so the timer fires every 5
        # ticks at EVERY time_scale. The tick wiring
        # accumulates frame["timer_retarget_elapsed"] every
        # tick the advance runs and passes the timer's
        # retarget_tick into the N2229 advance (replacing the
        # false literal); the bullets stay the empty list as
        # before -- the live bullet query still defers, so a
        # fire with no bullets clears the target to null
        # exactly like Java's unconditional assignment
        # (PointDefenseTurret.java:66). The selection logic
        # itself is untouched (N2229).
        self.assertIn('static func source_point_defense_turret_retarget_timer_state', point_defense_turret)
        self.assertIn('if(timer(timerTarget, retargetTime)){', point_defense_turret)
        self.assertIn('target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', point_defense_turret)
        self.assertIn('public final int timerTarget = timers++;', point_defense_turret)
        self.assertIn('public float retargetTime = 5f;', point_defense_turret)
        self.assertIn('if(Float.isInfinite(time)) return false;', point_defense_turret)
        self.assertIn('return timer.get(index, time);', point_defense_turret)
        self.assertIn('boolean got = check(id, time);', point_defense_turret)
        self.assertIn('if(got) times[id] = Time.time;', point_defense_turret)
        self.assertIn('return Time.time - times[id] >= time || Time.time < times[id];', point_defense_turret)
        self.assertIn('timeRaw += delta;', point_defense_turret)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', point_defense_turret)
        self.assertIn('SOURCE_POINT_DEFENSE_TURRET_RETARGET_TIME := 5.0', point_defense_turret)
        self.assertIn('"retarget_tick"', point_defense_turret)
        self.assertIn('"timer_elapsed_after"', point_defense_turret)
        # N2290-lesson pin: the threshold is the literal
        # duration -- no timeScale division anywhere in the
        # pure (the N2280 20/time_scale deviation must not
        # repeat here).
        self.assertIn('INF if time_scale <= 0.0 else duration', point_defense_turret)
        self.assertNotIn('duration / time_scale', point_defense_turret)
        # The tick wiring: the timer call with the frame clock
        # + tick delta + live time scale + 5f duration; the
        # elapsed write-back; the retarget_tick passed into
        # the N2229 advance (replacing the false literal) with
        # the bullets still the empty list.
        self.assertIn('source_point_defense_turret_retarget_timer_state(float(frame.get("timer_retarget_elapsed", 0.0)), source_delta, time_scale, SOURCE_POINT_DEFENSE_TURRET_RETARGET_TIME)', point_defense_turret)
        self.assertIn('frame["timer_retarget_elapsed"]', point_defense_turret)
        self.assertIn('source_point_defense_turret_update_tile_advance_state(frame, source_delta, time_scale, SOURCE_POINT_DEFENSE_TURRET_RANGE, SOURCE_POINT_DEFENSE_TURRET_BULLET_DAMAGE, SOURCE_POINT_DEFENSE_TURRET_RELOAD, advance_building_x, advance_building_y, [], retarget_tick)', point_defense_turret)
        # The documented limits now record the cadence as live
        # (N2316) and the remaining deferral is the live bullet
        # query, not the timer; the old "cadence defers" claim
        # is gone.
        self.assertIn('timer cadence live (N2316)', point_defense_turret)
        self.assertNotIn('The TIMER CADENCE itself defers', point_defense_turret)
        self.assertIn('updateTile advance live (N2229)', point_defense_turret)
        self.assertIn('shouldConsume gate live (N2217)', point_defense_turret)
        # The proof's keys drive the pure timer (fire at 5
        # ticks, no fire below the threshold, no fire on a
        # non-positive time_scale, elapsed reset on fire) plus
        # the live tick (the timer's retarget_tick reaches the
        # advance on a fire, and a fire with the empty bullet
        # list clears the target to null).
        proof = POINT_DEFENSE_TURRET_RETARGET_CADENCE_PROOF.read_text(encoding='utf-8')
        for key in [
            'timer_fires_at_five_ticks',
            'timer_no_fire_below_threshold',
            'timer_no_fire_when_time_scale_zero',
            'timer_resets_elapsed_on_fire',
            'live_tick_passes_retarget_on_fire',
            'fire_with_empty_bullets_clears_target',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # N2290-lesson pin: the proof pins the literal-5
        # threshold at overdrive (4 + 1 fires at time_scale
        # 2.0) and the no-early-fire case (2 + 1 does NOT fire
        # at time_scale 2.0 -- a 5/time_scale deviation would
        # fire there).
        self.assertIn('timer.call(4.0, 1.0, 2.0, duration)', proof)
        self.assertIn('timer.call(2.0, 1.0, 2.0, duration)', proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourcePointDefenseTurretBuildState.gd")', proof)
        self.assertIn('point_defense_turret_build_state.source_point_defense_turret_retarget_timer_state(', proof)
        self.assertIn('point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(POINT_DEFENSE_TURRET_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = POINT_DEFENSE_TURRET_RETARGET_CADENCE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PointDefenseTurretRetargetCadenceProof.gd', scene)
        self.assertIn('C07PointDefenseTurretRetargetCadenceProof', scene)

    def test_reference_graph_and_actual_c07_point_defense_turret_retarget_cadence(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PointDefenseTurretRetargetCadenceProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POINT_DEFENSE_TURRET_RETARGET_CADENCE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'timer_fires_at_five_ticks',
            'timer_no_fire_below_threshold',
            'timer_no_fire_when_time_scale_zero',
            'timer_resets_elapsed_on_fire',
            'live_tick_passes_retarget_on_fire',
            'fire_with_empty_bullets_clears_target',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
