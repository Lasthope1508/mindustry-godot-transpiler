import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
RADAR_CAN_PICKUP_PROGRESS_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarCanPickupProgressProof.gd'
RADAR_CAN_PICKUP_PROGRESS_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarCanPickupProgressProof.tscn'


class C07RadarCanPickupProgressRowsTests(unittest.TestCase):
    def test_c07_radar_can_pickup_progress_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2479']['godot_owner'], 'SourceRadarBuildState.source_radar_can_pickup_progress_state')
        # The radar tick is live (N2173 power row + N2190
        # updateTile advance + N2427 draw rows + N2474
        # fogRadius accessor) but NOTHING modeled the
        # canPickup / progress() accessors themselves
        # (Radar.java:75-77 / :93-95): canPickup()
        # returns false unconditionally (the base
        # BuildingComp.canPickup() returns
        # block.canPickup, default true, Block.java:176)
        # and progress() returns the build progress
        # field (the base BuildingComp.progress()
        # returns 0f). N2479 ports both as ONE
        # pure-only pure: can_pickup = false,
        # progress = progress. No tick wiring: the
        # caller (pickup/UI path) reads it; the frame
        # progress key is advanced + clamped [0, 1]
        # by the N2190 updateTile advance (Radar.java:68-69).
        # Two new result symbols: the pickup verdict
        # and the progress value.
        self.assertEqual(
            ledger['N2479']['source_symbols'],
            [
                'source_radar_can_pickup_progress_state_result.can_pickup',
                'source_radar_can_pickup_progress_state_result.progress',
            ],
        )
        for name in ledger['N2479']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/Radar.java')
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.source_radar_can_pickup_progress_state')
        self.assertEqual(ledger['N2479']['runtime_proof'], '/root/C07RadarCanPickupProgressProof')
        self.assertEqual(
            ledger['N2479']['tests'],
            [
                'test_c07_radar_can_pickup_progress_rows_registration',
                'test_all_c07_radar_can_pickup_progress_rows_input_evidence_is_exact',
                'test_radar_can_pickup_progress_rows_state',
                'test_reference_graph_and_actual_c07_radar_can_pickup_progress_rows',
            ],
        )
        self.assertTrue(ledger['N2479']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #33 (1-based in
        # DEFERRED-after-advances-32.py): the Radar
        # canPickup / progress() rows entry is REMOVED
        # -- both accessors are live now as a pure.
        # (The driver + N2474 register call it #34 --
        # that was the advances-31 numbering; the
        # advances-32 merge renumbered it to #33.
        # Merge is by entry TEXT, not number.) The
        # forceUpdate CALL (#123) and the read/write
        # rows (#32) stay deferred: they are NOT in
        # this slice's scope. Net 234 - 1 = 233.
        self.assertFalse(any(entry.startswith('Radar canPickup / progress() rows (canPickup false, Radar.java:75-77') for entry in ledger['N2479']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Radar read/write rows (progress, Radar.java:98-110)') for entry in ledger['N2479']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Radar fogControl.forceUpdate call (Vars.fogControl.forceUpdate(team, this), Radar.java:64)') for entry in ledger['N2479']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Radar shouldConsume gate (RadarBuild has no shouldConsume override') for entry in ledger['N2479']['deferred_exprs']))
        self.assertEqual(len(ledger['N2479']['deferred_exprs']), 233)

    def test_all_c07_radar_can_pickup_progress_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2479']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.source_radar_can_pickup_progress_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/Radar.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2479']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_can_pickup_progress_rows_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # RadarBuild.canPickup() (Radar.java:75-77):
        # `public boolean canPickup(){` returns
        # `return false;` -- unconditionally, whatever
        # the progress (the base
        # BuildingComp.canPickup() returns
        # block.canPickup, BuildingComp.java:1838-1840,
        # default true, Block.java:176). progress()
        # (Radar.java:93-95): `public float progress(){`
        # returns `return progress;` -- the build field
        # `public float progress;` (Radar.java:49),
        # tracked on the frame under the same key name
        # (progress) since the N2190 advance; the base
        # BuildingComp.progress() returns 0f
        # (BuildingComp.java:617-619). The field is
        # advanced by `progress += edelta() /
        # discoveryTime;` (Radar.java:68) and clamped
        # by `progress = Mathf.clamp(progress);`
        # (Radar.java:69) to [0, 1] -- the clamp lives
        # in updateTile, NOT in progress(), so the pure
        # itself does not clamp: it returns its input
        # as-is. Pure-only: the caller (pickup/UI path)
        # reads it; no tick wiring here.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_radar_can_pickup_progress_state', radar)
        self.assertIn('public boolean canPickup(){', radar)
        self.assertIn('return false;', radar)
        self.assertIn('public float progress(){', radar)
        self.assertIn('return progress;', radar)
        self.assertIn('public float progress;', radar)
        self.assertIn('progress += edelta() / discoveryTime;', radar)
        self.assertIn('progress = Mathf.clamp(progress);', radar)
        self.assertIn('"can_pickup"', radar)
        self.assertIn('"progress"', radar)
        # The documented limits record the canPickup /
        # progress rows as live (the forceUpdate call +
        # read/write rows still wait -- they are NOT
        # this slice).
        self.assertIn('CanPickup / progress rows live (N2479)', radar)
        # The proof's keys drive the canPickup /
        # progress pure (the unconditional pickup
        # verdict, zero / half / full progress, the
        # clamped live input from the N2190 advance,
        # and the live-input wiring against the frame
        # progress key).
        proof = RADAR_CAN_PICKUP_PROGRESS_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'pickup_false',
            'progress_zero',
            'progress_half',
            'progress_full',
            'progress_clamped',
            'progress_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceRadarBuildState.gd")', proof)
        self.assertTrue(RADAR_STATE.is_file())
        scene = RADAR_CAN_PICKUP_PROGRESS_ROWS_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RadarCanPickupProgressProof.gd', scene)
        self.assertTrue(RADAR_CAN_PICKUP_PROGRESS_ROWS_PROOF.is_file())

    def test_reference_graph_and_actual_c07_radar_can_pickup_progress_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RadarCanPickupProgressProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RADAR_CAN_PICKUP_PROGRESS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'pickup_false',
            'progress_zero',
            'progress_half',
            'progress_full',
            'progress_clamped',
            'progress_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
