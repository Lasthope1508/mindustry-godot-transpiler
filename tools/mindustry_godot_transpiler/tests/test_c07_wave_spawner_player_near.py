import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WAVE_SPAWNER = ROOT / 'godot-mindustry/src/game/SourceWaveSpawnerState.gd'
PLAYER_NEAR_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WaveSpawnerPlayerNearProof.gd'


class C07WaveSpawnerPlayerNearTests(unittest.TestCase):
    def test_c07_wave_spawner_player_near_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2451']['godot_owner'], 'SourceWaveSpawnerState.source_wave_spawner_player_near_state')
        # WaveSpawner.playerNear() (WaveSpawner.java:58-60), one method
        # slice (batch 42 slot 3): exactly the 1 body expr -- the full
        # return line (:59). `spawns` is the WaveSpawner field
        # `private Seq<Tile> spawns = new Seq<>(false);`
        # (WaveSpawner.java:26); GD takes it as an Array of tile dicts
        # and never recomputes it from the world (precedent N2442
        # countSpawns / N2446 getSpawns, same field; N2123/N2297
        # micro-accessors).
        self.assertEqual(
            ledger['N2451']['java_method'],
            'WaveSpawner.playerNear()',
        )
        self.assertEqual(
            ledger['N2451']['source_symbols'],
            [
                'source_wave_spawner_player_near_state_result.player_near',
            ],
        )
        for name in ledger['N2451']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/ai/WaveSpawner.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnerState.source_wave_spawner_player_near_state'))
        self.assertEqual(ledger['N2451']['runtime_proof'], '/root/C07WaveSpawnerPlayerNearProof')
        self.assertEqual(
            ledger['N2451']['tests'],
            [
                'test_c07_wave_spawner_player_near_registration',
                'test_all_c07_wave_spawner_player_near_input_evidence_is_exact',
                'test_wave_spawner_player_near_state',
                'test_reference_graph_and_actual_c07_wave_spawner_player_near',
            ],
        )
        self.assertTrue(ledger['N2451']['deferred_exprs'])

    def test_all_c07_wave_spawner_player_near_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2451']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnerState.source_wave_spawner_player_near_state'))
        slice_sources = {
            'core/src/mindustry/ai/WaveSpawner.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2451']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wave_spawner_player_near_state(self):
        wave = WAVE_SPAWNER.read_text(encoding='utf-8')
        # WaveSpawner.playerNear() (WaveSpawner.java:58-60): the 1 body
        # expr only -- the full return line (:59). `tilesize` is
        # Vars.tilesize = 8 (Vars.java:135), NOT 32 -- the batch 42
        # draft said 32, which is wrong; verified from upstream.
        # `has_spawns` is a bool input (precedent spawn_knockback_state;
        # the live value comes from source_game_loop_has_spawns_state,
        # never called cross-file here). The HudFragment call-site
        # `spawner.playerNear()` (HudFragment.java:664) is NOT in this
        # slice -- it belongs to HudFragment, a later slice.
        self.assertIn('static func source_wave_spawner_player_near_state(has_spawns: bool, player_dead: bool, spawns: Array, player_pos: Vector2, drop_zone_radius: float, player_team_id: int, wave_team_id: int) -> Dictionary:', wave)
        self.assertIn('{"player_near": player_near}', wave)
        # The proof's keys drive the pure function with synthetic
        # frame inputs (no live tick, no spawner): hasSpawns=false ->
        # false; player dead -> false; spawn near + other team ->
        # true; spawn far -> false; same wave team -> false;
        # exactly 1 result key, and a second call on the same
        # inputs yields the same value.
        proof = PLAYER_NEAR_PROOF.read_text(encoding='utf-8')
        for key in [
            'player_near_false_when_no_spawns',
            'player_near_false_when_player_dead',
            'player_near_true_when_spawn_near_and_other_team',
            'player_near_false_when_spawn_far',
            'player_near_false_when_same_wave_team',
            'player_near_returns_one_key',
            'player_near_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_wave_spawner_player_near(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WaveSpawnerPlayerNearProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WAVE_SPAWNER_PLAYER_NEAR_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'player_near_false_when_no_spawns',
            'player_near_false_when_player_dead',
            'player_near_true_when_spawn_near_and_other_team',
            'player_near_false_when_spawn_far',
            'player_near_false_when_same_wave_team',
            'player_near_returns_one_key',
            'player_near_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
