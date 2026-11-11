import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
GAME_LOOP_STATE = ROOT / 'godot-mindustry/src/game/SourceGameLoopRuntimeState.gd'
ROOT_BRIDGE = ROOT / 'godot-mindustry/src/game/SourcePortGameRootStatePortBridge.gd'


class C06PauseGateTests(unittest.TestCase):
    def test_c06_pause_gate_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2123']['godot_owner'], 'SourceGameLoopRuntimeState.source_game_loop_paused_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourceGameLoopRuntimeState.source_game_loop_paused_state', 'source_game_loop_paused_state_input', 'Dictionary', ['paused'], 'N2123'),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], source_slice)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(
            [param['name'] for param in contracts['SourceGameLoopRuntimeState.source_game_loop_paused_state']['params']],
            ['game'],
        )
        self.assertEqual(len(ledger['N2123']['source_symbols']), 2)
        self.assertTrue(ledger['N2123']['deferred_exprs'])

    def test_all_c06_pause_gate_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        owners = {
            'source_game_loop_paused_state_': 'SourceGameLoopRuntimeState.source_game_loop_paused_state',
        }
        for name in ledger['N2123']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                prefix = next(p for p in owners if name.startswith(p))
                self.assertEqual(symbol['godot_owner'], owners[prefix])
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/core/GameState.java'),
            ('mindustry-upstream', 'core/src/mindustry/core/Logic.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2123']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_pause_gate_reads_live_game_state(self):
        game_loop = GAME_LOOP_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_game_loop_paused_state(game: Object) -> Dictionary:', game_loop)
        self.assertIn('PORT_GAME_SOURCE_GAME_LOOP_PAUSED_STATE', game_loop)
        self.assertIn('source_game_loop_paused_state(game)', game_loop)
        # Logic.update (Logic.java:507) gates the whole game update on
        # !state.isPaused(): the tick, Time.update and every sim run
        # only while unpaused. The port gate sits at the top of
        # process_tick, before Time.update and before any sim.
        self.assertIn('if bool(source_game_loop_paused_state(game).get("paused", false)):', game_loop)
        self.assertIn('# Logic.update (Logic.java:507): `if(!state.isPaused())`', game_loop)
        root_bridge = ROOT_BRIDGE.read_text(encoding='utf-8')
        self.assertIn('var paused := false', root_bridge)
        registry = (ROOT / 'godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd').read_text(encoding='utf-8')
        self.assertIn('PORT_GAME_SOURCE_GAME_LOOP_PAUSED_STATE', registry)

    def test_reference_graph_and_actual_c06_pause_gate(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06PauseProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_PAUSE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
