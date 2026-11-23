import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_LASER_DEFAULTS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillLaserDefaultsProof.gd'


class C07BeamDrillLaserDefaultsTests(unittest.TestCase):
    def test_c07_beam_drill_laser_defaults_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2440']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_laser_defaults_state')
        # BeamDrill field defaults (BeamDrill.java:28-59), 12
        # lines, no method owns them: the six @Load laser
        # TextureRegions (:28-30, :32-34), the spark/glow
        # colors (:53), the glow/pulse intensities (:54),
        # glowScl (:55), sparks (:56), the five spark
        # numbers (:57) and the boost heat color (:59).
        # NOT this slice: topRegion :36 / glowRegion :37 /
        # range :40 / tier :41 / drillMultipliers :47 /
        # blockedItem :49 / blockedItems :51 (already own),
        # drillTime :39 / laserWidth :42 /
        # optionalBoostIntensity :44 / heatColor :60 (free,
        # deferred to their own slices). 18 result symbols.
        self.assertEqual(
            ledger['N2440']['source_symbols'],
            [
                'source_beam_drill_laser_defaults_state_result.laser',
                'source_beam_drill_laser_defaults_state_result.laser_end',
                'source_beam_drill_laser_defaults_state_result.laser_center',
                'source_beam_drill_laser_defaults_state_result.laser_boost',
                'source_beam_drill_laser_defaults_state_result.laser_end_boost',
                'source_beam_drill_laser_defaults_state_result.laser_center_boost',
                'source_beam_drill_laser_defaults_state_result.spark_color',
                'source_beam_drill_laser_defaults_state_result.glow_color',
                'source_beam_drill_laser_defaults_state_result.glow_intensity',
                'source_beam_drill_laser_defaults_state_result.pulse_intensity',
                'source_beam_drill_laser_defaults_state_result.glow_scl',
                'source_beam_drill_laser_defaults_state_result.sparks',
                'source_beam_drill_laser_defaults_state_result.spark_range',
                'source_beam_drill_laser_defaults_state_result.spark_life',
                'source_beam_drill_laser_defaults_state_result.spark_recurrence',
                'source_beam_drill_laser_defaults_state_result.spark_spread',
                'source_beam_drill_laser_defaults_state_result.spark_size',
                'source_beam_drill_laser_defaults_state_result.boost_heat_color',
            ],
        )
        for name in ledger['N2440']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/BeamDrill.java')
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2440']['runtime_proof'], '/root/C07BeamDrillLaserDefaultsProof')
        self.assertEqual(
            ledger['N2440']['tests'],
            [
                'test_c07_beam_drill_laser_defaults_registration',
                'test_all_c07_beam_drill_laser_defaults_input_evidence_is_exact',
                'test_beam_drill_laser_defaults_state',
                'test_reference_graph_and_actual_c07_beam_drill_laser_defaults',
            ],
        )
        self.assertTrue(ledger['N2440']['deferred_exprs'])

    def test_all_c07_beam_drill_laser_defaults_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2440']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        upstream = (ROOT / 'mindustry-upstream' / 'core/src/mindustry/world/blocks/production/BeamDrill.java').read_text(encoding='utf-8')
        for expr in ledger['N2440']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertIn(expr, upstream)

    def test_beam_drill_laser_defaults_state(self):
        state = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # BeamDrill field defaults (BeamDrill.java:28-59)
        # are load-time block definition setup, not a
        # per-tick driver: they only fix the 12 laser /
        # spark / glow / heat field defaults. The values
        # are NOT live code anywhere else: the draw func
        # (source_beam_drill_draw_state) takes every one
        # of them as an explicit param, and the defaults
        # themselves live only as a prose comment
        # (:562-566) -- this func is the first live home
        # for the values. The laser textures load as
        # name + suffix ("@-beam" etc., BeamDrill.java
        # :28-34) with the drill-laser* fallback names
        # kept in the comment + register rules; the
        # result carries the resolved per-block region
        # name (the N2212/N2224 per-def-param precedent:
        # block_name arrives explicitly). sparkColor is
        # Color.valueOf("fd9e81"), glowColor is
        # Color.white, boostHeatColor is
        # Color.sky.cpy().mul(0.87f) -- GDScript
        # Color.SKY_BLUE * 0.87 (Color * float multiplies
        # all four components, arc Color.mul(float)
        # included). No driver tick line: field
        # defaults are load-time, not per-tick state.
        # frame carries no live keys for this load-time
        # setup -- it is the canonical first param of
        # this family file.
        self.assertIn('static func source_beam_drill_laser_defaults_state(frame: Dictionary, block_name: String) -> Dictionary:', state)
        self.assertIn('return {"laser": laser, "laser_end": laser_end, "laser_center": laser_center, "laser_boost": laser_boost, "laser_end_boost": laser_end_boost, "laser_center_boost": laser_center_boost, "spark_color": spark_color, "glow_color": glow_color, "glow_intensity": glow_intensity, "pulse_intensity": pulse_intensity, "glow_scl": glow_scl, "sparks": sparks, "spark_range": spark_range, "spark_life": spark_life, "spark_recurrence": spark_recurrence, "spark_spread": spark_spread, "spark_size": spark_size, "boost_heat_color": boost_heat_color}', state)
        for expr in [
            'public @Load(value = "@-beam", fallback = "drill-laser") TextureRegion laser;',
            'public @Load(value = "@-beam-end", fallback = "drill-laser-end") TextureRegion laserEnd;',
            'public @Load(value = "@-beam-center", fallback = "drill-laser-center") TextureRegion laserCenter;',
            'public @Load(value = "@-beam-boost", fallback = "drill-laser-boost") TextureRegion laserBoost;',
            'public @Load(value = "@-beam-boost-end", fallback = "drill-laser-boost-end") TextureRegion laserEndBoost;',
            'public @Load(value = "@-beam-boost-center", fallback = "drill-laser-boost-center") TextureRegion laserCenterBoost;',
            'public Color sparkColor = Color.valueOf("fd9e81"), glowColor = Color.white;',
            'public float glowIntensity = 0.2f, pulseIntensity = 0.07f;',
            'public float glowScl = 3f;',
            'public int sparks = 7;',
            'public float sparkRange = 10f, sparkLife = 27f, sparkRecurrence = 4f, sparkSpread = 45f, sparkSize = 3.5f;',
            'public Color boostHeatColor = Color.sky.cpy().mul(0.87f);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure function with
        # synthetic frames (no live tick): the plasma-bore
        # region names (Blocks.java:3038) and the
        # large-plasma-bore region names (Blocks.java:3052)
        # -- neither def overrides any of the 12 lines
        # (only laserWidth 0.7f, Blocks.java:3062) -- plus
        # every scalar / color default.
        proof = BEAM_DRILL_LASER_DEFAULTS_PROOF.read_text(encoding='utf-8')
        for key in [
            'defaults_laser_region',
            'defaults_laser_end_region',
            'defaults_laser_center_region',
            'defaults_laser_boost_region',
            'defaults_laser_end_boost_region',
            'defaults_laser_center_boost_region',
            'defaults_spark_color',
            'defaults_glow_color',
            'defaults_glow_intensity',
            'defaults_pulse_intensity',
            'defaults_glow_scl',
            'defaults_sparks',
            'defaults_spark_range',
            'defaults_spark_life',
            'defaults_spark_recurrence',
            'defaults_spark_spread',
            'defaults_spark_size',
            'defaults_boost_heat_color',
            'defaults_large_bore_regions',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_beam_drill_laser_defaults(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillLaserDefaultsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_LASER_DEFAULTS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'defaults_laser_region',
            'defaults_laser_end_region',
            'defaults_laser_center_region',
            'defaults_laser_boost_region',
            'defaults_laser_end_boost_region',
            'defaults_laser_center_boost_region',
            'defaults_spark_color',
            'defaults_glow_color',
            'defaults_glow_intensity',
            'defaults_pulse_intensity',
            'defaults_glow_scl',
            'defaults_sparks',
            'defaults_spark_range',
            'defaults_spark_life',
            'defaults_spark_recurrence',
            'defaults_spark_spread',
            'defaults_spark_size',
            'defaults_boost_heat_color',
            'defaults_large_bore_regions',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
