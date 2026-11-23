import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
GAME_LOOP = ROOT / 'godot-mindustry/src/game/SourceGameLoopRuntimeState.gd'
HAS_SPAWNS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07GameLoopHasSpawnsProof.gd'


class C07GameLoopHasSpawnsTests(unittest.TestCase):
    def test_c07_game_loop_has_spawns_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2448']['godot_owner'], 'SourceGameLoopRuntimeState.source_game_loop_has_spawns_state')
        # GameState.hasSpawns() (GameState.java:68-70), one method
        # slice (batch 41 slot 3): exactly the 1 body expr
        # `return rules.waves && ((rules.waveTeam.cores().size > 0 && rules.attackMode) || rules.spawns.size > 0);`
        # (:69). `rules.waveTeam.cores()` arrives as the frame
        # input wave_team_core_count (the count, not the cores()
        # call -- Team.cores() is a later slice) and
        # `rules.spawns` as spawn_group_count; `rules` itself
        # is an input param, not an owned schema.
        self.assertEqual(
            ledger['N2448']['java_method'],
            'GameState.hasSpawns()',
        )
        self.assertEqual(
            ledger['N2448']['source_symbols'],
            [
                'source_game_loop_has_spawns_state_result.has_spawns',
            ],
        )
        for name in ledger['N2448']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/core/GameState.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameLoopRuntimeState.source_game_loop_has_spawns_state'))
        self.assertEqual(ledger['N2448']['runtime_proof'], '/root/C07GameLoopHasSpawnsProof')
        self.assertEqual(
            ledger['N2448']['tests'],
            [
                'test_c07_game_loop_has_spawns_registration',
                'test_all_c07_game_loop_has_spawns_input_evidence_is_exact',
                'test_game_loop_has_spawns_state',
                'test_reference_graph_and_actual_c07_game_loop_has_spawns',
            ],
        )
        self.assertTrue(ledger['N2448']['deferred_exprs'])

    def test_all_c07_game_loop_has_spawns_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2448']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameLoopRuntimeState.source_game_loop_has_spawns_state'))
        slice_sources = {
            'core/src/mindustry/core/GameState.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2448']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_game_loop_has_spawns_state(self):
        game_loop = GAME_LOOP.read_text(encoding='utf-8')
        # GameState.hasSpawns() (GameState.java:68-70): the 1 body
        # expr only -- `return rules.waves && ((rules.waveTeam.cores().size > 0 && rules.attackMode) || rules.spawns.size > 0);`
        # (:69). The call-sites (WaveSpawner.playerNear :59 +
        # eachGroundSpawn :126, UnitComp :772, MinimapRenderer
        # :298, OverlayRenderer :203) are NOT in this slice --
        # they belong to their own methods. `Team.cores()` is
        # NOT ported here -- GD takes the core count as input.
        self.assertIn('static func source_game_loop_has_spawns_state(waves: bool, wave_team_core_count: int, attack_mode: bool, spawn_group_count: int) -> Dictionary:', game_loop)
        self.assertIn('return rules.waves && ((rules.waveTeam.cores().size > 0 && rules.attackMode) || rules.spawns.size > 0);', game_loop)
        self.assertIn('waves and ((wave_team_core_count > 0 and attack_mode) or spawn_group_count > 0)', game_loop)
        # The proof's keys drive the pure function with synthetic
        # frame inputs (no live tick, no game): waves off ->
        # false; waves + spawn groups -> true; waves + attack
        # mode + wave-team core -> true; waves + neither ->
        # false; exactly the payload key plus the source_owner
        # envelope key, and a second call on the same inputs
        # yields the same value.
        proof = HAS_SPAWNS_PROOF.read_text(encoding='utf-8')
        for key in [
            'has_spawns_false_when_waves_off',
            'has_spawns_true_when_spawn_groups',
            'has_spawns_true_when_attack_mode_and_core',
            'has_spawns_false_when_no_spawns_no_core',
            'has_spawns_returns_owner_plus_one_key',
            'has_spawns_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_game_loop_has_spawns(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07GameLoopHasSpawnsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_GAME_LOOP_HAS_SPAWNS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'has_spawns_false_when_waves_off',
            'has_spawns_true_when_spawn_groups',
            'has_spawns_true_when_attack_mode_and_core',
            'has_spawns_false_when_no_spawns_no_core',
            'has_spawns_returns_owner_plus_one_key',
            'has_spawns_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
