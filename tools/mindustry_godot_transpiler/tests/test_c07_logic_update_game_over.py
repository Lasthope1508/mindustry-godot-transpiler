import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
GAME_OVER = ROOT / 'godot-mindustry/src/game/SourceGameOverCoreDestroyedState.gd'
GAMEPLAY_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceGameplayRuntimePortBridge.gd'
UPDATE_GAME_OVER_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LogicUpdateGameOverProof.gd'


class C07LogicUpdateGameOverTests(unittest.TestCase):
    def test_c07_logic_update_game_over_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2443']['godot_owner'], 'PortGame.source_game_over_core_destroyed_state')
        # Logic.updateGameOver() (Logic.java:426-431) and
        # Logic.gameOver() (Logic.java:434-439) share the one
        # body expr `state.won = player.team() == winner;`
        # (:429 and :436) -- a twin slice (batch 39 slot 3):
        # both methods assign won the same way, so both are
        # registered here under the game-over owner. The
        # updateGameOver guard lines (:427 `state.gameOver
        # = true;`, owned by the shared key
        # playable_game_over_runtime, and :428
        # `if(!headless){`, owned N1249/N1250/N608/...)
        # are NOT re-registered; the gameOver remainder
        # (:435 wavesLasted, :437 Time.run restart show,
        # :438 netClient.setQuiet) is deferred.
        self.assertEqual(
            ledger['N2443']['java_method'],
            'Logic.updateGameOver()/Logic.gameOver()',
        )
        self.assertEqual(
            ledger['N2443']['source_symbols'],
            [
                'source_game_over_core_destroyed_result.won_expr',
                'source_game_over_core_destroyed_result.won',
            ],
        )
        for name in ledger['N2443']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/core/Logic.java')
                self.assertTrue(symbol['godot_owner'].startswith('PortGame.source_game_over_core_destroyed_state'))
        self.assertEqual(ledger['N2443']['runtime_proof'], '/root/C07LogicUpdateGameOverProof')
        self.assertEqual(
            ledger['N2443']['tests'],
            [
                'test_c07_logic_update_game_over_registration',
                'test_all_c07_logic_update_game_over_input_evidence_is_exact',
                'test_logic_update_game_over_state',
                'test_reference_graph_and_actual_c07_logic_update_game_over',
            ],
        )
        self.assertTrue(ledger['N2443']['deferred_exprs'])
        # Twin-register into the shared owner (precedent
        # N2435): the contract keeps source_slice
        # playable_game_over_runtime, gains the two new
        # params and the two new return keys.
        contract = contracts['PortGame.source_game_over_core_destroyed_state']
        self.assertEqual(contract['source_slice'], 'playable_game_over_runtime')
        self.assertEqual(
            [param['name'] for param in contract['params']],
            ['core_health_value', 'game_over_value', 'attack_mode', 'player_team', 'winner_team'],
        )
        self.assertIn('won', contract['return_keys'])
        self.assertIn('won_expr', contract['return_keys'])

    def test_all_c07_logic_update_game_over_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        schema = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        for name in ledger['N2443']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('PortGame.source_game_over_core_destroyed_state'))
        slice_sources = {
            'core/src/mindustry/core/Logic.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2443']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)
        for key in ('player_team', 'winner_team'):
            with self.subTest(input=key):
                expr = schema['source_game_over_core_destroyed_input']['keys'][key]['java_expr']
                self.assertIn(expr, upstream['core/src/mindustry/core/Logic.java'])

    def test_logic_update_game_over_state(self):
        module = GAME_OVER.read_text(encoding='utf-8')
        # Logic.updateGameOver() :429 + Logic.gameOver()
        # :436 (twin): the func gains the two optional
        # team params (defaults keep the two existing
        # callers compiling) and returns won as data --
        # the player team compared against the winner
        # team -- plus the exact expr recorded as a
        # string, following the existing *_expr keys.
        self.assertIn('static func core_destroyed_state(core_health_value: float, game_over_value: bool, attack_mode := false, player_team: String = "", winner_team: String = "") -> Dictionary:', module)
        self.assertIn('"won_expr": "state.won = player.team() == winner;"', module)
        self.assertIn('"won": player_team == winner_team', module)
        bridge = GAMEPLAY_BRIDGE.read_text(encoding='utf-8')
        self.assertIn('func source_game_over_core_destroyed_state(core_health_value: float, game_over_value: bool, attack_mode := false, player_team: String = "", winner_team: String = "") -> Dictionary:', bridge)
        self.assertIn('return source_gameplay_game_over_core_destroyed_state_script.core_destroyed_state(core_health_value, game_over_value, attack_mode, player_team, winner_team)', bridge)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick, no event bus):
        # same team wins, another team loses, the
        # envelope gains exactly the two new keys, the
        # winner key is untouched, and a second call is
        # idempotent.
        proof = UPDATE_GAME_OVER_PROOF.read_text(encoding='utf-8')
        for key in [
            'won_same_team_true',
            'won_other_team_false',
            'won_returns_thirteen_keys',
            'won_expr_exact',
            'won_preserves_winner',
            'won_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_logic_update_game_over(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LogicUpdateGameOverProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LOGIC_UPDATE_GAME_OVER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'won_same_team_true',
            'won_other_team_false',
            'won_returns_thirteen_keys',
            'won_expr_exact',
            'won_preserves_winner',
            'won_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
