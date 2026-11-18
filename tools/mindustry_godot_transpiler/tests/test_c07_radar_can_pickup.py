import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
RADAR_CAN_PICKUP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarCanPickupProof.gd'


class C07RadarCanPickupTests(unittest.TestCase):
    def test_c07_radar_can_pickup_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2272']['godot_owner'], 'SourceRadarBuildState.source_radar_can_pickup_state')
        # RadarBuild.canPickup() (Radar.java:75, `public boolean
        # canPickup(){` with `return false;`, Radar.java:76)
        # overrides the base BuildingComp.canPickup()
        # (BuildingComp.java:1838, `public boolean canPickup(){`
        # with `return block.canPickup;`, BuildingComp.java:1839)
        # for Radar: a radar can never be picked up, whatever
        # the frame holds -- the override takes no state, so
        # the pure function takes the family-convention frame
        # and ignores it (the write/read precedent). No driver
        # tick line lands here: pickup is a placement-time
        # gate, not tick state (the accessor precedent
        # N2268/N2249). N2272 closes the canPickup half of
        # the canPickup / progress() deferred row the N2263
        # register carried; the Windows Godot proof debt is
        # re-recorded as its own entry. One new result symbol:
        # can_pickup.
        self.assertEqual(
            ledger['N2272']['source_symbols'],
            [
                'source_radar_can_pickup_state_result.can_pickup',
            ],
        )
        for name in ledger['N2272']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/Radar.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2272']['runtime_proof'], '/root/C07RadarCanPickupProof')
        self.assertEqual(
            ledger['N2272']['tests'],
            [
                'test_c07_radar_can_pickup_registration',
                'test_all_c07_radar_can_pickup_input_evidence_is_exact',
                'test_radar_can_pickup_state',
                'test_reference_graph_and_actual_c07_radar_can_pickup',
            ],
        )
        self.assertTrue(ledger['N2272']['deferred_exprs'])

    def test_all_c07_radar_can_pickup_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2272']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/Radar.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2272']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_can_pickup_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # The pure canPickup() accessor lives on the radar
        # build state next to the N2263 progress accessor:
        # RadarBuild.canPickup() (Radar.java:75, `public
        # boolean canPickup(){` with `return false;`,
        # Radar.java:76) overrides the base
        # BuildingComp.canPickup() (BuildingComp.java:1838,
        # `return block.canPickup;`, BuildingComp.java:1839)
        # for Radar. The override takes no state: the frame
        # is the family-convention first arg (every Radar
        # pure function takes it) and is unused. One def
        # (radar, Radar.java:17, `public class Radar extends
        # Block{`; RadarBuild, Radar.java:48, `public class
        # RadarBuild extends Building{`).
        self.assertIn('static func source_radar_can_pickup_state(frame: Dictionary) -> Dictionary:', radar)
        # The accessor cases, pinned as the pure function's
        # decision structure: the result is always false --
        # no frame key changes it.
        self.assertIn('return {"can_pickup": false}', radar)
        for expr in [
            'public boolean canPickup(){',
            'return false;',
            'public class Radar extends Block{',
            'public class RadarBuild extends Building{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, radar)
        # The proof's keys drive the pure canPickup()
        # accessor (empty frame / progress frame / enabled
        # frame all read false). There are no driver-tick
        # keys: pickup is a placement-time gate, not tick
        # state.
        proof = RADAR_CAN_PICKUP_PROOF.read_text(encoding='utf-8')
        for key in [
            'can_pickup_empty_frame_false',
            'can_pickup_progress_frame_false',
            'can_pickup_enabled_frame_false',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_radar_can_pickup(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RadarCanPickupProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RADAR_CAN_PICKUP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'can_pickup_empty_frame_false',
            'can_pickup_progress_frame_false',
            'can_pickup_enabled_frame_false',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
