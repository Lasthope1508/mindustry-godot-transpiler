import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_DRAW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillDrawProof.gd'


class C07BeamDrillDrawTests(unittest.TestCase):
    def test_c07_beam_drill_draw_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2382']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_draw_state')
        # BeamDrillBuild.draw() (BeamDrill.java:275-361, `public void
        # draw(){`) is the BeamDrillBuild render method: the base +
        # top rects, the per-face laser (center rects when the laser
        # point sits on the face tile, Drawf.laser beams otherwise),
        # the Lod.l2 spark loop driven by the build rand, and the
        # additive glow rect. One pure function on the existing
        # SourceBeamDrillBuildState.gd (the N2314/N2325 draw
        # precedent): it returns the computed draw state and does NOT
        # touch real Draw / Drawf / Lines playback. NO driver tick
        # line: draw() is per-frame render state, not per-tick state.
        # The 42 distinguishing exprs are the 27 scope exprs
        # (re-probed at HEAD 0ac2993f in both ledgers, 27/31 0-hit)
        # plus 15 extra 0-hit exprs from the same method body (the
        # boost gates, the alpha/scl calls, the spark-loop locals,
        # the spark loop header). The 4 SHARE exprs
        # (`if(glowRegion.found()){` [N2184, N2314] / `Draw.z(Layer.
        # blockAdditive);` [N2181, N2314] / `Draw.blend(Blending.
        # additive);` [N2181, N2314, N2325] / `Draw.reset();` [13
        # local / 12 remote]) are evidence only, NOT distinguishing.
        # Time.time is the explicit time_ticks param; rand.setState(i,
        # id) seeds the arc xorshift Rand directly; Tmp is scratch
        # only; absin goes through SourceMathState.source_absin with
        # the original scl (the arc formula differs by a 2x period
        # factor, documented not worked around). Eight new result
        # symbols: base_rect, top_rect, is_payload, lasers,
        # glow_visible, glow_alpha, glow_color, glow_rect.
        self.assertEqual(
            ledger['N2382']['source_symbols'],
            [
                'source_beam_drill_draw_state_result.base_rect',
                'source_beam_drill_draw_state_result.top_rect',
                'source_beam_drill_draw_state_result.is_payload',
                'source_beam_drill_draw_state_result.lasers',
                'source_beam_drill_draw_state_result.glow_visible',
                'source_beam_drill_draw_state_result.glow_alpha',
                'source_beam_drill_draw_state_result.glow_color',
                'source_beam_drill_draw_state_result.glow_rect',
            ],
        )
        for name in ledger['N2382']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BeamDrill.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2382']['runtime_proof'], '/root/C07BeamDrillDrawProof')
        self.assertEqual(
            ledger['N2382']['tests'],
            [
                'test_c07_beam_drill_draw_registration',
                'test_all_c07_beam_drill_draw_input_evidence_is_exact',
                'test_beam_drill_draw_state',
                'test_reference_graph_and_actual_c07_beam_drill_draw',
            ],
        )
        self.assertTrue(ledger['N2382']['deferred_exprs'])

    def test_all_c07_beam_drill_draw_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2382']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2382']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_draw_state(self):
        state = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # BeamDrillBuild.draw() (BeamDrill.java:275-361) returns the
        # computed draw state: base + top rects, per-face laser
        # (centered rects vs Drawf.laser beams, boost-gated), the
        # Lod.l2 spark loop (rand.setState(i, id) + three draws per
        # spark), and the additive glow. Time.time is the explicit
        # time_ticks param; the rand helpers are file-local xorshift
        # (the RepairTurret-proven logic, N2289/N2290) so this file
        # does not depend on the Windows line's RepairTurret file.
        # NO driver tick line: draw() is per-frame render state.
        self.assertIn('static func source_beam_drill_draw_state(x: float, y: float, region: Variant, top_region: Variant, laser: Variant, laser_end: Variant, laser_center: Variant, laser_boost: Variant, laser_end_boost: Variant, laser_center_boost: Variant, glow_region: Variant, glow_region_found: bool, rotation: int, size: int, build_id: int, warmup: float, boost_warmup: float, is_payload: bool, facing: Array, lasers: Array, laser_width: float, glow_scl: float, pulse_intensity: float, glow_color: Variant, glow_intensity: float, spark_color: Variant, boost_heat_color: Variant, heat_color: Variant, heat_pulse: float, heat_pulse_scl: float, sparks: int, spark_life: float, spark_recurrence: float, spark_range: float, spark_spread: float, spark_size: float, time_ticks: float, lod_l2: bool, lod_alpha2: float, tilesize: float) -> Dictionary:', state)
        self.assertIn('return {"base_rect": base_rect, "top_rect": top_rect, "is_payload": is_payload, "lasers": laser_entries, "glow_visible": glow_visible, "glow_alpha": glow_alpha, "glow_color": glow_col, "glow_rect": glow_rect}', state)
        self.assertIn('var rand_state: Dictionary = {"seed0": i, "seed1": build_id}', state)
        for expr in [
            'Draw.rect(block.region, x, y);',
            'Draw.rect(topRegion, x, y, rotdeg());',
            'if(isPayload()) return;',
            'var dir = Geometry.d4(rotation);',
            'int ddx = Geometry.d4x(rotation + 1), ddy = Geometry.d4y(rotation + 1);',
            'Tile face = facing[i];',
            'Item drop = face.wallDrop();',
            'Point2 p = lasers[i];',
            'float lx = face.worldx() - (dir.x/2f)*tilesize, ly = face.worldy() - (dir.y/2f)*tilesize;',
            'float width = (laserWidth + Mathf.absin(Time.time + i*5 + (id % 9)*9, glowScl, pulseIntensity)) * warmup;',
            'Draw.z(Layer.power - 1);',
            'Draw.mixcol(glowColor, Mathf.absin(Time.time + i*5 + id*9, glowScl, glowIntensity));',
            'if(Math.abs(p.x - face.x) + Math.abs(p.y - face.y) == 0){',
            'Draw.scl(width);',
            'Draw.rect(laserCenter, lx, ly);',
            'Draw.rect(laserCenterBoost, lx, ly);',
            'float lsx = (p.x - dir.x/2f) * tilesize, lsy = (p.y - dir.y/2f) * tilesize;',
            'Drawf.laser(laser, laserEnd, lsx, lsy, lx, ly, width);',
            'Drawf.laser(laserBoost, laserEndBoost, lsx, lsy, lx, ly, width);',
            'Draw.color(Tmp.c1.set(heatColor).lerp(boostHeatColor, boostWarmup), warmup * (heatColor.a * (1f - heatPulse + Mathf.absin(heatPulseScl, heatPulse))));',
            'Draw.rect(glowRegion, x, y, rotdeg());',
            'if(Lod.l2){',
            'Lines.stroke(warmup);',
            'rand.setState(i, id);',
            'Color spark = Tmp.c3.set(sparkColor).lerp(boostHeatColor, boostWarmup);',
            'float fin = (Time.time / sparkLife + rand.random(sparkRecurrence + 1f)) % sparkRecurrence;',
            'if(fin <= 1f) Lines.lineAngle(lx + px + or * ddx, ly + py + or * ddy, Angles.angle(px, py), Mathf.slope(fin) * sparkSize);',
            'if(face != null){',
            'if(drop == null) continue;',
            'if(boostWarmup < 0.99f){',
            'Draw.alpha(1f - boostWarmup);',
            'if(boostWarmup > 0.01f){',
            'Draw.alpha(boostWarmup);',
            'Draw.scl();',
            'if(boostWarmup > 0.001f){',
            'Color col = drop.color;',
            'float or = rand.range(2f);',
            'Tmp.v1.set(sparkRange * fin, 0).rotate(rotdeg() + rand.range(sparkSpread));',
            'Color result = Tmp.c1.set(spark).lerp(col, fin);',
            'Draw.color(result.r, result.g, result.b, result.a * Lod.alpha2);',
            'float px = Tmp.v1.x, py = Tmp.v1.y;',
            'for(int j = 0; j < sparks; j++){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure function with synthetic
        # frames (no live tick): base/top rects / payload early
        # return / centered vs beam branch / width+mix formula /
        # boost gates / spark count + fin range / the oracle first
        # draws (independent Python arc-Rand oracle) / determinism /
        # seed sensitivity / spark line geometry / Lod off / glow /
        # null face + null drop skips / the eight-key shape.
        proof = BEAM_DRILL_DRAW_PROOF.read_text(encoding='utf-8')
        for key in [
            'base_and_top_rects',
            'payload_returns_early',
            'centered_branch',
            'beam_branch',
            'width_and_mix_formula',
            'boost_gates',
            'spark_count_and_fin_range',
            'spark_oracle_first_draws',
            'spark_determinism',
            'spark_seed_sensitivity',
            'spark_line_geometry',
            'lod_off_skips_sparks',
            'glow_state',
            'null_face_and_null_drop_skipped',
            'returns_only_eight_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_beam_drill_draw(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillDrawProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_DRAW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'base_and_top_rects',
            'payload_returns_early',
            'centered_branch',
            'beam_branch',
            'width_and_mix_formula',
            'boost_gates',
            'spark_count_and_fin_range',
            'spark_oracle_first_draws',
            'spark_determinism',
            'spark_seed_sensitivity',
            'spark_line_geometry',
            'lod_off_skips_sparks',
            'glow_state',
            'null_face_and_null_drop_skipped',
            'returns_only_eight_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
