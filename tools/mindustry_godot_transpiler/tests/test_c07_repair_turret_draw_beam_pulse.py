import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_DRAW_BEAM_PULSE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretDrawBeamPulseProof.gd'


class C07RepairTurretDrawBeamPulseTests(unittest.TestCase):
    def test_c07_repair_turret_draw_beam_pulse_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2252']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_draw_beam_pulse_state')
        # N2219 captured the deterministic beam state but left the
        # pulse circle unmodeled, and N2251 modeled the jitter
        # (the first three Rand draws) but left the pulse phase
        # for this slice: the pulse phase (`float f =
        # (Time.time / 85f + rand.random(1f)) % 1f;`,
        # RepairTurret.java:138) is the FOURTH draw from the
        # SAME seeded Rand sequence as the N2251 jitter draws,
        # so it reuses that slice's xorshift helpers, not a
        # re-seed. `Draw.alpha(1f - Interp.pow5In.apply(f));`
        # (RepairTurret.java:140) fades the pulse circle with
        # pow5In -- Interp.pow5In is PowIn(5) (Interp.java:45),
        # apply(a) = pow(a, 5) (Interp.java:119-121), so alpha
        # = 1 - f^5. `Lines.stroke(strength * pulseStroke);`
        # (RepairTurret.java:141) and `Lines.circle(lastEnd.x,
        # lastEnd.y, 1f + f * pulseRadius);`
        # (RepairTurret.java:142) draw the circle. The pulse
        # block sits inside the strength guard (`if(strength >
        # 0.01f){`, RepairTurret.java:129) -- the same guard the
        # N2219 draw_beam_state already returns as beam_visible.
        # Four new result symbols: f, alpha, stroke,
        # circle_radius.
        self.assertEqual(
            ledger['N2252']['source_symbols'],
            [
                'source_repair_turret_draw_beam_pulse_state_result.f',
                'source_repair_turret_draw_beam_pulse_state_result.alpha',
                'source_repair_turret_draw_beam_pulse_state_result.stroke',
                'source_repair_turret_draw_beam_pulse_state_result.circle_radius',
            ],
        )
        for name in ledger['N2252']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                    'arc-core/src/arc/math/Interp.java',
                    'arc-core/src/arc/math/Rand.java',
                    'arc-core/src/arc/util/Time.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2252']['runtime_proof'], '/root/C07RepairTurretDrawBeamPulseProof')
        self.assertEqual(
            ledger['N2252']['tests'],
            [
                'test_c07_repair_turret_draw_beam_pulse_registration',
                'test_all_c07_repair_turret_draw_beam_pulse_input_evidence_is_exact',
                'test_repair_turret_draw_beam_pulse_state',
                'test_reference_graph_and_actual_c07_repair_turret_draw_beam_pulse',
            ],
        )
        self.assertTrue(ledger['N2252']['deferred_exprs'])

    def test_all_c07_repair_turret_draw_beam_pulse_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2252']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                source = symbol['java_source']
                upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / source).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'arc-core/src/arc/math/Interp.java',
            'arc-core/src/arc/math/Rand.java',
            'arc-core/src/arc/util/Time.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2252']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_draw_beam_pulse_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The pulse phase is the fourth Rand draw from the same
        # seeded sequence as the N2251 jitter draws
        # (`rand.setSeed(id + (target instanceof Entityc e ?
        # e.id() : 0));`, RepairTurret.java:111): `float f =
        # (Time.time / 85f + rand.random(1f)) % 1f;`
        # (RepairTurret.java:138), `Draw.alpha(1f -
        # Interp.pow5In.apply(f));` (RepairTurret.java:140),
        # `Lines.stroke(strength * pulseStroke);`
        # (RepairTurret.java:141), `Lines.circle(lastEnd.x,
        # lastEnd.y, 1f + f * pulseRadius);`
        # (RepairTurret.java:142), inside the strength guard
        # (`if(strength > 0.01f){`, RepairTurret.java:129).
        # Interp.pow5In is PowIn(5) (Interp.java:45,
        # `PowIn pow5In = new PowIn(5);`), apply(a) = pow(a, 5)
        # (Interp.java:119-121, `return
        # (float)Math.pow(a, power);`), so alpha = 1 - f^5.
        # Time.time is the tick counter (Time.java:15, 60fps
        # units). The rand draw is taken as an explicit float
        # param (0..1): the caller supplies the fourth draw --
        # the proof replays the N2251 seeded sequence (seed 10:
        # r1 257.980828 / r2 38.301969 / r3 3.008420 / r4
        # 0.350668) to show the linkage, but the pure function
        # itself does not re-seed and invents no building id.
        # There is NO driver tick line: the frame carries no
        # absolute tick and no fourth Rand draw, so the pulse
        # cannot be stamped live yet -- the N2219
        # draw_beam_state still returns the pre-pulse beam
        # (pulse_stroke only) until a wiring slice adds those
        # frame fields.
        self.assertIn('static func source_repair_turret_draw_beam_pulse_state(strength: float, pulse_stroke: float, pulse_radius: float, time_ticks: float, rand_draw: float) -> Dictionary:', repair_turret)
        self.assertIn('var f: float = fmod(time_ticks / 85.0 + rand_draw, 1.0)', repair_turret)
        self.assertIn('var alpha: float = 1.0 - pow(f, 5.0)', repair_turret)
        self.assertIn('var stroke: float = strength * pulse_stroke', repair_turret)
        self.assertIn('var circle_radius: float = 1.0 + f * pulse_radius', repair_turret)
        self.assertIn('return {"f": f, "alpha": alpha, "stroke": stroke, "circle_radius": circle_radius}', repair_turret)
        for expr in [
            'float f = (Time.time / 85f + rand.random(1f)) % 1f;',
            'Draw.alpha(1f - Interp.pow5In.apply(f));',
            'Lines.stroke(strength * pulseStroke);',
            'Lines.circle(lastEnd.x, lastEnd.y, 1f + f * pulseRadius);',
            'if(strength > 0.01f){',
            'PowIn pow5In = new PowIn(5);',
            'return (float)Math.pow(a, power);',
            'public float random(float max){',
            'return nextFloat() * max;',
            'public static float time, globalTime;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        # The proof's keys drive the pure function with explicit
        # params (no live tick: the pulse state is pure Rand +
        # Time.time from explicit inputs): f from the formula /
        # f wrapping mod 1 at 85 ticks / alpha = 1 - f^5 / the
        # stroke scaling with strength / the circle radius
        # growing with f / the fourth draw matching the seed-10
        # oracle replay / f advancing with time / f staying in
        # [0, 1). There is no live-tick key: there is no driver
        # line yet, the frame carries no absolute tick or fourth
        # Rand draw. There is no laser-drawing key: the laser
        # itself is the N2219 slice.
        proof = REPAIR_TURRET_DRAW_BEAM_PULSE_PROOF.read_text(encoding='utf-8')
        for key in [
            'pulse_f_matches_formula',
            'pulse_f_wraps_mod_1',
            'pulse_alpha_is_one_minus_f_pow5',
            'pulse_stroke_scales_with_strength',
            'pulse_circle_radius_grows_with_f',
            'pulse_fourth_draw_matches_seed_10_oracle',
            'pulse_f_advances_with_time',
            'pulse_f_in_unit_range',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_draw_beam_pulse(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretDrawBeamPulseProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_DRAW_BEAM_PULSE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'pulse_f_matches_formula',
            'pulse_f_wraps_mod_1',
            'pulse_alpha_is_one_minus_f_pow5',
            'pulse_stroke_scales_with_strength',
            'pulse_circle_radius_grows_with_f',
            'pulse_fourth_draw_matches_seed_10_oracle',
            'pulse_f_advances_with_time',
            'pulse_f_in_unit_range',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
