import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class ConduitUpdateBindingTests(unittest.TestCase):
    def test_conduit_update_binding_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        for sid, owner, schema, return_type, return_keys in [
            ('N2091', 'SourceWorldInitialBuildRuntimeState.source_conduit_rotation_state', 'source_conduit_rotation_state_input', 'Dictionary', ['block_id', 'rotations', 'count']),
            ('N2092', 'SourceConduitRuntimeState.source_conduit_update_state', 'source_conduit_update_state_input', 'Dictionary', ['liquid', 'flowed', 'smooth_liquid', 'flow_timer', 'update_tile_called', 'enabled']),
        ]:
            with self.subTest(slice=sid):
                self.assertEqual(ledger[sid]['godot_owner'], owner)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
                self.assertTrue(ledger[sid]['deferred_exprs'])

    def test_all_conduit_update_binding_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for sid in ['N2091', 'N2092']:
            for name in ledger[sid]['source_symbols']:
                with self.subTest(symbol=name):
                    symbol = symbols[name]
                    self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                    self.assertEqual(symbol['godot_owner'], ledger[sid]['godot_owner'])

    def test_conduit_update_uses_source_delta_ticks_not_raw_seconds(self):
        # N2196: Java Time.delta is ticks (arc Time.java:26,
        # getDeltaTime() * 60f), so Mathf.lerpDelta (Mathf.java:430-432)
        # and the flow timer (Conduit.java:252 timer(timerFlow, 1), arc
        # Interval.get/check in ticks — Interval.java:19-28, Time.time
        # advances by Time.delta per tick, Time.java:72-75) both run in
        # ticks. The live loop passes raw seconds, so the conduit must
        # convert with game_source_delta (seconds x 60) inside
        # source_conduit_update_state and use the ticks for both.
        source = (ROOT / 'godot-mindustry' / 'src' / 'game' / 'SourceConduitRuntimeState.gd').read_text(encoding='utf-8')
        self.assertIn('var source_delta := source_placed_block_state.game_source_delta(game, delta)', source)
        self.assertIn('source_math_state.source_lerp_delta(smooth_liquid, current_amount / CONDUIT_LIQUID_CAPACITY, 0.05, source_delta)', source)
        self.assertIn('flow_timer += source_delta', source)
        self.assertNotIn('0.05, delta)', source)
        self.assertNotIn('flow_timer += delta', source)
        # Conduit.java:252 timer(timerFlow, 1) is 1 tick, not 1 second:
        # the stale "1s" reading of the interval must be gone.
        self.assertIn('const CONDUIT_FLOW_INTERVAL := 1.0', source)
        self.assertNotIn('timerFlow, 1s', source)

    def test_reference_graph_and_actual_conduit_update(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/ConduitUpdateProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('CONDUIT_UPDATE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
