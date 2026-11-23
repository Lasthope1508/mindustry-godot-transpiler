import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
GAME_LOOP_STATE = ROOT / 'godot-mindustry/src/game/SourceGameLoopRuntimeState.gd'
IS_WAITING_WAVE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LogicIsWaitingWaveProof.gd'

PROOF_KEYS = [
    'waiting_wait_enemies',
    'waiting_win_wave_reached',
    'waiting_no_enemies',
    'waiting_win_wave_not_reached',
    'waiting_win_wave_zero',
]


class C07LogicIsWaitingWaveTests(unittest.TestCase):
    def test_c07_logic_is_waiting_wave_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2436']['godot_owner'], 'SourceGameLoopRuntimeState.source_game_loop_is_waiting_wave_state')
        # Logic.isWaitingWave() (Logic.java:605-607): the `:606`
        # line `return (state.rules.waitEnemies ||
        # (state.wave >= state.rules.winWave &&
        # state.rules.winWave > 0)) && state.enemies > 0;` --
        # the pure predicate for whether the wave timer is
        # paused due to enemies (javadoc :604). 0-hit in
        # BOTH ledgers (re-probed at base 70227d4b). The
        # call-site `if(!isWaitingWave())` (Logic.java:577,
        # inside update()) is NOT registered here -- it
        # belongs to the update() driver-tick slice, a
        # later slice. `state.enemies` is read as-is from
        # the frame input; it is never counted here (the
        # count leg lives in Logic.update(), a later
        # slice).
        self.assertEqual(
            ledger['N2436']['java_method'],
            'Logic.isWaitingWave()',
        )
        self.assertEqual(
            ledger['N2436']['exact_exprs'],
            [
                'return (state.rules.waitEnemies || (state.wave >= state.rules.winWave && state.rules.winWave > 0)) && state.enemies > 0;',
            ],
        )
        self.assertEqual(
            ledger['N2436']['source_symbols'],
            [
                'source_game_loop_is_waiting_wave_state_result.waiting',
            ],
        )
        for name in ledger['N2436']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/core/Logic.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameLoopRuntimeState.source_game_loop_is_waiting_wave_state'))
        self.assertEqual(ledger['N2436']['runtime_proof'], '/root/C07LogicIsWaitingWaveProof')
        self.assertEqual(
            ledger['N2436']['tests'],
            [
                'test_c07_logic_is_waiting_wave_registration',
                'test_all_c07_logic_is_waiting_wave_input_evidence_is_exact',
                'test_logic_is_waiting_wave_state',
                'test_reference_graph_and_actual_c07_logic_is_waiting_wave',
            ],
        )
        self.assertTrue(ledger['N2436']['deferred_exprs'])

    def test_all_c07_logic_is_waiting_wave_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2436']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameLoopRuntimeState.source_game_loop_is_waiting_wave_state'))
        slice_sources = {
            'core/src/mindustry/core/Logic.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2436']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_logic_is_waiting_wave_state(self):
        state = GAME_LOOP_STATE.read_text(encoding='utf-8')
        # The GD function is new (N2436): a pure predicate
        # over the frame inputs, returning the `waiting`
        # envelope key. The exact Java expr is quoted
        # verbatim on its own comment line inside
        # source_game_loop_is_waiting_wave_state (the N2378
        # precedent: never split an exact expr across
        # lines).
        self.assertIn('static func source_game_loop_is_waiting_wave_state(wait_enemies: bool, wave: int, win_wave: int, enemies: int) -> Dictionary:', state)
        for expr in [
            'return (state.rules.waitEnemies || (state.wave >= state.rules.winWave && state.rules.winWave > 0)) && state.enemies > 0;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        self.assertIn('"waiting":', state)
        self.assertIn('PORT_GAME_SOURCE_GAME_LOOP_IS_WAITING_WAVE_STATE', state)
        # The proof's keys pin the predicate: waitEnemies
        # with enemies -> waiting; wave at winWave with
        # enemies -> waiting; no enemies -> not waiting
        # even with waitEnemies; wave short of winWave ->
        # not waiting; winWave 0 -> not waiting (the
        # `winWave > 0` guard).
        proof = IS_WAITING_WAVE_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_logic_is_waiting_wave(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LogicIsWaitingWaveProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LOGIC_IS_WAITING_WAVE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
