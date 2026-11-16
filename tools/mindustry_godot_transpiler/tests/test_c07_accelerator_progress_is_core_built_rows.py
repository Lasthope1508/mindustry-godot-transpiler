import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ACCELERATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceAcceleratorBuildState.gd'
ACCELERATOR_PROGRESS_IS_CORE_BUILT_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorProgressIsCoreBuiltRowsProof.gd'
ACCELERATOR_PROGRESS_IS_CORE_BUILT_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorProgressIsCoreBuiltRowsProof.tscn'


class C07AcceleratorProgressIsCoreBuiltRowsTests(unittest.TestCase):
    def test_c07_accelerator_progress_is_core_built_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2485']['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_progress_is_core_built_state')
        # The accelerator tick is live (N2191 updateTile
        # advance + N2267 item rows + N2271 launch +
        # N2342 battery stamp + N2354 launch drain +
        # N2373 draw rows + N2422 bar rows + N2452
        # getCursor rows) but NOTHING computed the
        # progress() / isCoreBuilt() accessors
        # themselves (Accelerator.java:149-150 /
        # :153-154): is_core_built was only an INPUT
        # of source_accelerator_get_maximum_accepted_state
        # and source_accelerator_accept_item_state.
        # N2485 ports both as ONE pure-only pure:
        # progress = progress, is_core_built =
        # progress >= 1f. No tick wiring: the caller
        # (launch/UI path) reads it; the frame
        # progress key is advanced + clamped to 1f
        # by the N2191 updateTile advance
        # (Accelerator.java:143-144). Two new result
        # symbols: the progress value and the
        # core-built verdict.
        self.assertEqual(
            ledger['N2485']['source_symbols'],
            [
                'source_accelerator_progress_is_core_built_state_result.progress',
                'source_accelerator_progress_is_core_built_state_result.is_core_built',
            ],
        )
        for name in ledger['N2485']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/campaign/Accelerator.java')
                self.assertEqual(symbol['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_progress_is_core_built_state')
        self.assertEqual(ledger['N2485']['runtime_proof'], '/root/C07AcceleratorProgressIsCoreBuiltRowsProof')
        self.assertEqual(
            ledger['N2485']['tests'],
            [
                'test_c07_accelerator_progress_is_core_built_rows_registration',
                'test_all_c07_accelerator_progress_is_core_built_rows_input_evidence_is_exact',
                'test_accelerator_progress_is_core_built_rows_state',
                'test_reference_graph_and_actual_c07_accelerator_progress_is_core_built_rows',
            ],
        )
        self.assertTrue(ledger['N2485']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #64 (1-based in
        # DEFERRED-after-advances-33.py): the
        # Accelerator progress / isCoreBuilt rows
        # entry is REMOVED -- both accessors are live
        # now as a pure. The write/read serialization
        # the entry also mentions (Accelerator.java:310
        # / :318 -- the entry lines are right, the
        # driver comment :305/:311 was wrong, fixed
        # by this slice) DEFERS to its own slice with
        # no new entry (the wave scope decision).
        # Merge is by entry TEXT, not number. Net
        # 231 - 1 = 230.
        self.assertFalse(any(entry.startswith('Accelerator progress / isCoreBuilt rows (progress() returns progress, Accelerator.java:149-150') for entry in ledger['N2485']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator launch rows (buildConfiguration consume() / useBatteries / progress reset') for entry in ledger['N2485']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator launch animator rows (LaunchAnimator: launchDuration() 120f+220f, Accelerator.java:324-325') for entry in ledger['N2485']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator shouldConsume gate -- AcceleratorBuild has NO shouldConsume override') for entry in ledger['N2485']['deferred_exprs']))
        self.assertEqual(len(ledger['N2485']['deferred_exprs']), 230)

    def test_all_c07_accelerator_progress_is_core_built_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2485']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_progress_is_core_built_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/Accelerator.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2485']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_accelerator_progress_is_core_built_rows_state(self):
        accelerator = ACCELERATOR_STATE.read_text(encoding='utf-8')
        # AcceleratorBuild.progress() (Accelerator.java:149-150):
        # `public float progress(){` returns
        # `return progress;` -- the build field
        # `public float progress;` (Accelerator.java:121),
        # tracked on the frame under the same key name
        # (progress) since the N2191 advance; and
        # isCoreBuilt() (Accelerator.java:153-154):
        # `public boolean isCoreBuilt(){` returns
        # `return progress >= 1f;` -- the >= 1f
        # boundary is exact (progress exactly 1f IS
        # core-built). The field is advanced by
        # `progress += Time.delta * efficiency /
        # buildDuration;` (Accelerator.java:143) and
        # clamped by `progress = Math.min(progress,
        # 1f);` (Accelerator.java:144) -- the clamp
        # lives in updateTile, NOT in progress(), so
        # the pure itself does not clamp: it returns
        # its input as-is. Pure-only: the caller
        # (launch/UI path) reads it; no tick wiring
        # here. The write/read serialization
        # (`write.f(progress);` :310 / `progress =
        # read.f();` :318) is NOT this slice.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_accelerator_progress_is_core_built_state', accelerator)
        self.assertIn('public float progress(){', accelerator)
        self.assertIn('return progress;', accelerator)
        self.assertIn('public boolean isCoreBuilt(){', accelerator)
        self.assertIn('return progress >= 1f;', accelerator)
        self.assertIn('public float progress;', accelerator)
        self.assertIn('progress += Time.delta * efficiency / buildDuration;', accelerator)
        self.assertIn('progress = Math.min(progress, 1f);', accelerator)
        self.assertIn('"progress"', accelerator)
        self.assertIn('"is_core_built"', accelerator)
        # The documented limits record the progress /
        # isCoreBuilt rows as live (the write/read
        # serialization still waits -- it is NOT
        # this slice).
        self.assertIn('Progress / isCoreBuilt rows live (N2485)', accelerator)
        # The proof's keys drive the progress /
        # isCoreBuilt pure (zero / half / full
        # progress, the core-built verdict, the exact
        # 1f boundary, and the live-input wiring
        # against the frame progress key).
        proof = ACCELERATOR_PROGRESS_IS_CORE_BUILT_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'progress_zero',
            'progress_half',
            'progress_full',
            'core_built_true',
            'core_built_boundary',
            'progress_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceAcceleratorBuildState.gd")', proof)
        self.assertTrue(ACCELERATOR_STATE.is_file())
        scene = ACCELERATOR_PROGRESS_IS_CORE_BUILT_ROWS_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07AcceleratorProgressIsCoreBuiltRowsProof.gd', scene)
        self.assertTrue(ACCELERATOR_PROGRESS_IS_CORE_BUILT_ROWS_PROOF.is_file())

    def test_reference_graph_and_actual_c07_accelerator_progress_is_core_built_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07AcceleratorProgressIsCoreBuiltRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ACCELERATOR_PROGRESS_IS_CORE_BUILT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'progress_zero',
            'progress_half',
            'progress_full',
            'core_built_true',
            'core_built_boundary',
            'progress_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
