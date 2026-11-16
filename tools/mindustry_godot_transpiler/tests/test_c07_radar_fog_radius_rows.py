import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
RADAR_FOG_RADIUS_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarFogRadiusRowsProof.gd'
RADAR_FOG_RADIUS_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarFogRadiusRowsProof.tscn'


class C07RadarFogRadiusRowsTests(unittest.TestCase):
    def test_c07_radar_fog_radius_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2474']['godot_owner'], 'SourceRadarBuildState.source_radar_fog_radius_state')
        # The radar tick is live (N2173 power row + N2190
        # updateTile advance + N2427 draw rows) but
        # NOTHING modeled the fogRadius() accessor
        # itself (Radar.java:55-57): the updateTile
        # advance (N2190) computes fog_radius_now
        # INLINE (`fog_radius * progress_before *
        # smooth_efficiency`) and the draw pure (N2427)
        # takes fog_radius_live as a caller-supplied
        # input -- neither exposes the accessor as a
        # source-backed pure. N2474 ports fogRadius()
        # as ONE pure-only pure: fog_radius =
        # fog_radius_field * progress *
        # smooth_efficiency, Java-exact multiplication
        # order. No tick wiring: the pure COMPUTES the
        # input the update_tile + draw pures already
        # take as caller-supplied, and the caller wires
        # it later. One new result symbol: the fog
        # radius itself.
        self.assertEqual(
            ledger['N2474']['source_symbols'],
            [
                'source_radar_fog_radius_state_result.fog_radius',
            ],
        )
        for name in ledger['N2474']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/Radar.java')
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.source_radar_fog_radius_state')
        self.assertEqual(ledger['N2474']['runtime_proof'], '/root/C07RadarFogRadiusRowsProof')
        self.assertEqual(
            ledger['N2474']['tests'],
            [
                'test_c07_radar_fog_radius_rows_registration',
                'test_all_c07_radar_fog_radius_rows_input_evidence_is_exact',
                'test_radar_fog_radius_rows_state',
                'test_reference_graph_and_actual_c07_radar_fog_radius_rows',
            ],
        )
        self.assertTrue(ledger['N2474']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #124 (1-based in
        # DEFERRED-after-advances-31.py): the Radar
        # fogRadius rows entry is REMOVED -- fogRadius()
        # is live now as a pure. The forceUpdate CALL
        # (#127) and canPickup / progress() (#34) stay
        # deferred: they are NOT in this slice's scope.
        # Net 238 - 1 = 237.
        self.assertFalse(any(entry.startswith('Radar fogRadius rows (fogRadius() = fogRadius * progress * smoothEfficiency, Radar.java:55-57') for entry in ledger['N2474']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Radar canPickup / progress() rows (canPickup false, Radar.java:75-77') for entry in ledger['N2474']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Radar fogControl.forceUpdate call (Vars.fogControl.forceUpdate(team, this), Radar.java:64)') for entry in ledger['N2474']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Radar read/write rows (progress, Radar.java:98-110)') for entry in ledger['N2474']['deferred_exprs']))
        self.assertEqual(len(ledger['N2474']['deferred_exprs']), 237)

    def test_all_c07_radar_fog_radius_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2474']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.source_radar_fog_radius_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/Radar.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2474']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_fog_radius_rows_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # RadarBuild.fogRadius() (Radar.java:55-57):
        # `public float fogRadius(){` returns
        # `return fogRadius * progress *
        # smoothEfficiency;` -- the field times the
        # build progress times the smoothed efficiency,
        # Java-exact multiplication order. The field is
        # `public int fogRadius = -1;` (Block.java:348);
        # the Radar constructor sets the class default
        # `fogRadius = 10;` (Radar.java:33) and the
        # single radar def overrides it to `fogRadius =
        # 34;` (Blocks.java:1991) -- the pure takes the
        # field as an input so either def works. The
        # build fields are `public float progress;`
        # (Radar.java:49) and `public float
        # smoothEfficiency = 1f;` (Radar.java:51), both
        # tracked on the frame by the N2190 advance
        # under the same key names (progress /
        # smooth_efficiency); `public float lastRadius
        # = 0f;` (Radar.java:50) rides the frame as
        # last_radius. The updateTile gate
        # `if(Math.abs(fogRadius() - lastRadius) >=
        # 0.5f){` (Radar.java:63) with the write
        # `lastRadius = fogRadius();` (Radar.java:65)
        # is what consumes this pure's value -- the
        # N2190 advance computes it inline as
        # fog_radius_now and the N2427 draw pure takes
        # it as the caller-supplied fog_radius_live
        # input, so this pure computes the SAME
        # quantity both already use (the wiring note:
        # the caller wires this pure's output into
        # them later; pure-only, no tick wiring here).
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_radar_fog_radius_state', radar)
        self.assertIn('public float fogRadius(){', radar)
        self.assertIn('return fogRadius * progress * smoothEfficiency;', radar)
        self.assertIn('fogRadius = 10;', radar)
        self.assertIn('public float progress;', radar)
        self.assertIn('public float smoothEfficiency = 1f;', radar)
        self.assertIn('public int fogRadius = -1;', radar)
        self.assertIn('fogRadius = 34;', radar)
        self.assertIn('if(Math.abs(fogRadius() - lastRadius) >= 0.5f){', radar)
        self.assertIn('lastRadius = fogRadius();', radar)
        self.assertIn('public float lastRadius = 0f;', radar)
        self.assertIn('"fog_radius"', radar)
        # The documented limits record the fog radius
        # accessor as live (the forceUpdate call +
        # canPickup / progress() still wait -- they are
        # NOT this slice).
        self.assertIn('Fog radius accessor live (N2474)', radar)
        # The proof's keys drive the fog radius pure
        # (full discovery, zero progress, half
        # efficiency, the class-default vs def field,
        # the Java-exact multiplication order, and the
        # live-input wiring against the N2190 advance).
        proof = RADAR_FOG_RADIUS_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'fog_full',
            'fog_zero_progress',
            'fog_half_efficiency',
            'fog_def',
            'fog_formula_order',
            'fog_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceRadarBuildState.gd")', proof)
        self.assertTrue(RADAR_STATE.is_file())
        scene = RADAR_FOG_RADIUS_ROWS_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RadarFogRadiusRowsProof.gd', scene)
        self.assertTrue(RADAR_FOG_RADIUS_ROWS_PROOF.is_file())

    def test_reference_graph_and_actual_c07_radar_fog_radius_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RadarFogRadiusRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RADAR_FOG_RADIUS_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fog_full',
            'fog_zero_progress',
            'fog_half_efficiency',
            'fog_def',
            'fog_formula_order',
            'fog_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
