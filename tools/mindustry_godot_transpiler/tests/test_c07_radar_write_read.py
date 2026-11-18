import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
RADAR_WRITE_READ_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarWriteReadProof.gd'


class C07RadarWriteReadTests(unittest.TestCase):
    def test_c07_radar_write_read_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2267']['godot_owner'], 'SourceRadarBuildState.source_radar_write_state')
        # RadarBuild persists exactly ONE field, its discovery
        # progress (`write.f(progress);`, Radar.java:101,
        # inside `public void write(Writes write){` /
        # `super.write(write);`, Radar.java:98-99), and
        # restores it unconditionally (`progress = read.f();`,
        # Radar.java:108, inside `public void read(Reads read,
        # byte revision){` / `super.read(read, revision);`,
        # Radar.java:105-106). RadarBuild does NOT override
        # version(), so read ignores `revision` entirely --
        # there is no `if(revision >= ...)` guard like
        # RepairTurret's (N2217). lastRadius /
        # smoothEfficiency / totalProgress are NOT persisted:
        # they are recomputed every tick (Radar.java:61, :63-65,
        # :71, N2248), so a loaded radar rebuilds them from
        # their field defaults. RED decisions (resolved at RED,
        # recorded in the register docstring): (1) Two pure
        # functions on the same family file N2248 / N2249 /
        # N2250 / N2263 built -- write returns {"progress"}
        # only, read returns {"progress"} (the stored value,
        # whatever the revision). (2) Read takes `revision`
        # as an explicit int input and ignores it, so the proof
        # can pin that revisions 0, 1 and 2 give the same
        # result -- the param exists to prove the ignore, not
        # to gate on it. (3) NO driver tick line: persistence
        # is not a per-tick call, and the port has no save/load
        # stream to call these functions yet -- wiring them
        # into a save/load path waits for a
        # persistence-integration slice. (4) The progress
        # default is 0.0, the field default (`public float
        # progress;`, Radar.java:49). (5) Java write.f is a
        # 32-bit float while GDScript float is 64-bit -- the
        # pure functions add NO rounding epsilon; the proof
        # round-trips float32-safe values exactly and checks
        # the inexact value 0.1 with is_equal_approx. Two new
        # result symbols: write.progress, read.progress.
        self.assertEqual(
            ledger['N2267']['source_symbols'],
            [
                'source_radar_write_state_result.progress',
                'source_radar_read_state_result.progress',
            ],
        )
        for name in ledger['N2267']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/Radar.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2267']['runtime_proof'], '/root/C07RadarWriteReadProof')
        self.assertEqual(
            ledger['N2267']['tests'],
            [
                'test_c07_radar_write_read_registration',
                'test_all_c07_radar_write_read_input_evidence_is_exact',
                'test_radar_write_read_state',
                'test_reference_graph_and_actual_c07_radar_write_read',
            ],
        )
        self.assertTrue(ledger['N2267']['deferred_exprs'])

    def test_all_c07_radar_write_read_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2267']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/Radar.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2267']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_write_read_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # RadarBuild persists exactly ONE field, its progress:
        # `public void write(Writes write){` / `super.write(
        # write);` / `write.f(progress);` (Radar.java:98-101),
        # and restores it unconditionally: `public void read(
        # Reads read, byte revision){` / `super.read(read,
        # revision);` / `progress = read.f();`
        # (Radar.java:105-108). RadarBuild does NOT override
        # version(), so `revision` is passed to super only and
        # never read in the body -- the read function takes it
        # and ignores it. The progress default is 0.0 (`public
        # float progress;`, Radar.java:49). lastRadius /
        # smoothEfficiency / totalProgress are NOT persisted --
        # they are recomputed every tick (`smoothEfficiency =
        # Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);`,
        # Radar.java:61; `lastRadius = fogRadius();`,
        # Radar.java:65; `totalProgress += efficiency *
        # edelta();`, Radar.java:71) -- so the write result has
        # exactly one key. There is NO driver tick line:
        # persistence is not a per-tick call, and the port has
        # no save/load stream to call these functions yet.
        self.assertIn('static func source_radar_write_state(frame: Dictionary, progress: float) -> Dictionary:', radar)
        self.assertIn('return {"progress": float(progress)}', radar)
        self.assertIn('static func source_radar_read_state(frame: Dictionary, stored_progress: float, revision: int) -> Dictionary:', radar)
        self.assertIn('return {"progress": float(stored_progress)}', radar)
        for expr in [
            'public void write(Writes write){',
            'super.write(write);',
            'write.f(progress);',
            'public void read(Reads read, byte revision){',
            'super.read(read, revision);',
            'progress = read.f();',
            'public float progress;',
            'public float lastRadius = 0f;',
            'public float smoothEfficiency = 1f;',
            'public float totalProgress;',
            'smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);',
            'lastRadius = fogRadius();',
            'totalProgress += efficiency * edelta();',
            'public float progress(){',
            'return progress;',
            'progress += edelta() / discoveryTime;',
            'progress = Mathf.clamp(progress);',
            'public class Radar extends Block{',
            'public class RadarBuild extends Building{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, radar)
        # The proof's keys drive the pure functions with
        # synthetic frames (no live tick, no save file: the
        # persisted value is one float): write 0.0 / write 0.5
        # round-trips through read / write 1.0 (clamp max) /
        # write returns only progress / read returns only
        # progress / read ignores revision (0, 1, 2 give the
        # same result) / the inexact float32 value 0.1
        # round-trips within float32 tolerance. There are no
        # lastRadius / smoothEfficiency / totalProgress keys:
        # those fields are recomputed every tick, not
        # persisted.
        proof = RADAR_WRITE_READ_PROOF.read_text(encoding='utf-8')
        for key in [
            'write_progress_zero',
            'write_progress_half_round_trips',
            'write_progress_full',
            'write_returns_only_progress',
            'read_returns_only_progress',
            'read_ignores_revision',
            'round_trip_inexact_float32_value',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_radar_write_read(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RadarWriteReadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RADAR_WRITE_READ_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'write_progress_zero',
            'write_progress_half_round_trips',
            'write_progress_full',
            'write_returns_only_progress',
            'read_returns_only_progress',
            'read_ignores_revision',
            'round_trip_inexact_float32_value',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
