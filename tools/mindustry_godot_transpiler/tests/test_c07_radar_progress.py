import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
RADAR_PROGRESS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarProgressProof.gd'


class C07RadarProgressTests(unittest.TestCase):
    def test_c07_radar_progress_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2303']['godot_owner'], 'SourceRadarBuildState.source_radar_progress_state')
        # RadarBuild.progress() (Radar.java:93, `public float
        # progress(){` with `return progress;`, Radar.java:94)
        # is the discovery-progress accessor: it returns the
        # frame's progress (the Java field `public float
        # progress;`, Radar.java:49, init 0.0), advanced by
        # updateTile (Radar.java:68, `progress += edelta() /
        # discoveryTime;`, clamped Radar.java:69, `progress =
        # Mathf.clamp(progress);`, N2248) and read by
        # fogRadius() (Radar.java:56, `return fogRadius *
        # progress * smoothEfficiency;`, N2249). It overrides
        # the base BuildingComp.progress() for Radar. N2303
        # closes the accessor half of the canPickup /
        # progress() deferred row with one pure function over
        # the frame (`progress`); canPickup stays deferred in
        # its own narrowed row, the logic-dispatch hook for
        # sensor progress waits for its own slice (the N2255
        # sense precedent), and the write/read persistence
        # (Radar.java:101, `write.f(progress);` /
        # Radar.java:108, `progress = read.f();`) is its own
        # slice. No driver tick line lands here: the accessor
        # is the read its callers share. One new result
        # symbol: progress.
        self.assertEqual(
            ledger['N2303']['source_symbols'],
            [
                'source_radar_progress_state_result.progress',
            ],
        )
        for name in ledger['N2303']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/Radar.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2303']['runtime_proof'], '/root/C07RadarProgressProof')
        self.assertEqual(
            ledger['N2303']['tests'],
            [
                'test_c07_radar_progress_registration',
                'test_all_c07_radar_progress_input_evidence_is_exact',
                'test_radar_progress_state',
                'test_reference_graph_and_actual_c07_radar_progress',
            ],
        )
        self.assertTrue(ledger['N2303']['deferred_exprs'])

    def test_all_c07_radar_progress_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2303']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/Radar.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2303']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_progress_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # The pure progress() accessor lives on the radar
        # build state next to the N2249 fogRadius accessor
        # and the N2248 updateTile advance:
        # RadarBuild.progress() (Radar.java:93, `public float
        # progress(){` with `return progress;`,
        # Radar.java:94) returns the frame's progress. The
        # field is `public float progress;` (Radar.java:49,
        # init 0.0); updateTile advances it (Radar.java:68,
        # `progress += edelta() / discoveryTime;`, clamped
        # Radar.java:69, `progress = Mathf.clamp(progress);`)
        # and fogRadius() reads it (Radar.java:56, `return
        # fogRadius * progress * smoothEfficiency;`). One def
        # (radar, Radar.java:17, `public class Radar extends
        # Block{`; RadarBuild, Radar.java:48, `public class
        # RadarBuild extends Building{`).
        self.assertIn('static func source_radar_progress_state(frame: Dictionary) -> Dictionary:', radar)
        # The accessor cases, pinned as the pure function's
        # decision structure: the progress is the frame's
        # progress, an absent frame starts at the Java
        # default 0.0.
        self.assertIn('float(frame.get("progress", 0.0))', radar)
        with self.subTest(case='the one key is returned'):
            self.assertIn('return {"progress": float(frame.get("progress", 0.0))}', radar)
        for expr in [
            'public float progress(){',
            'return progress;',
            'public float progress;',
            'progress += edelta() / discoveryTime;',
            'progress = Mathf.clamp(progress);',
            'return fogRadius * progress * smoothEfficiency;',
            'public class Radar extends Block{',
            'public class RadarBuild extends Building{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, radar)
        # The proof's keys drive the pure progress()
        # accessor (absent frame starts at 0.0 / half
        # discovery / full discovery / the N2248 advance
        # round-trips through the accessor). There are no
        # logic-dispatch keys: the sensor hook waits for
        # its own slice, and the write/read persistence
        # rows are a separate slice with their own proof.
        proof = RADAR_PROGRESS_PROOF.read_text(encoding='utf-8')
        for key in [
            'progress_absent_frame_starts_at_zero',
            'progress_half_discovery',
            'progress_full_discovery',
            'progress_matches_update_tile_advance',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_radar_progress(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RadarProgressProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RADAR_PROGRESS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'progress_absent_frame_starts_at_zero',
            'progress_half_discovery',
            'progress_full_discovery',
            'progress_matches_update_tile_advance',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
