import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WAVE_SPAWNER = ROOT / 'godot-mindustry/src/game/SourceWaveSpawnerState.gd'
SPAWN_COUNTS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WaveSpawnerSpawnCountsProof.gd'


class C07WaveSpawnerSpawnCountsTests(unittest.TestCase):
    def test_c07_wave_spawner_spawn_counts_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2453']['godot_owner'], 'SourceWaveSpawnerState.source_wave_spawner_spawn_counts_state')
        # WaveSpawner.countGroundSpawns() (WaveSpawner.java:201-205) +
        # WaveSpawner.countFlyerSpawns() (WaveSpawner.java:207-211),
        # one combined slice (batch 43 slot 2): exactly the 4 distinct
        # body exprs -- `tmpCount = 0;` (:202/:208, shared),
        # `eachGroundSpawn((x, y) -> tmpCount ++);` (:203),
        # `eachFlyerSpawn(-1, (x, y) -> tmpCount ++);` (:209) and
        # `return tmpCount;` (:204/:210, shared). Each Java method
        # resets tmpCount, counts one callback invocation per
        # enumerated spawn point, and returns the total -- so the
        # count IS the size of the enumerated list. GD takes the two
        # already-enumerated lists as Array inputs (option (A)
        # data-driven, decided at spawn) and does not enumerate them
        # itself: eachGroundSpawn / eachFlyerSpawn are NOT ported and
        # belong to later slices. The field `private int tmpCount;`
        # (:25) is NOT registered here (field decl, no GD state).
        self.assertEqual(
            ledger['N2453']['java_method'],
            'WaveSpawner.countGroundSpawns() + WaveSpawner.countFlyerSpawns()',
        )
        self.assertEqual(
            ledger['N2453']['source_symbols'],
            [
                'source_wave_spawner_spawn_counts_state_result.flyer_spawn_count',
                'source_wave_spawner_spawn_counts_state_result.ground_spawn_count',
            ],
        )
        for name in ledger['N2453']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/ai/WaveSpawner.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnerState.source_wave_spawner_spawn_counts_state'))
        self.assertEqual(ledger['N2453']['runtime_proof'], '/root/C07WaveSpawnerSpawnCountsProof')
        self.assertEqual(
            ledger['N2453']['tests'],
            [
                'test_c07_wave_spawner_spawn_counts_registration',
                'test_all_c07_wave_spawner_spawn_counts_input_evidence_is_exact',
                'test_wave_spawner_spawn_counts_state',
                'test_reference_graph_and_actual_c07_wave_spawner_spawn_counts',
            ],
        )
        self.assertTrue(ledger['N2453']['deferred_exprs'])

    def test_all_c07_wave_spawner_spawn_counts_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2453']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnerState.source_wave_spawner_spawn_counts_state'))
        slice_sources = {
            'core/src/mindustry/ai/WaveSpawner.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2453']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wave_spawner_spawn_counts_state(self):
        wave = WAVE_SPAWNER.read_text(encoding='utf-8')
        # WaveSpawner.countGroundSpawns() (WaveSpawner.java:201-205) +
        # WaveSpawner.countFlyerSpawns() (WaveSpawner.java:207-211):
        # the 4 distinct body exprs only. Each Java method resets
        # tmpCount, counts one callback invocation per enumerated
        # spawn point, and returns the total -- so the count IS the
        # size of the enumerated list. GD takes the two
        # already-enumerated lists as Array inputs (option (A)
        # data-driven, decided at spawn) and does not enumerate them
        # itself: eachGroundSpawn / eachFlyerSpawn are NOT ported and
        # belong to later slices. The field `private int tmpCount;`
        # (:25) is NOT registered here (field decl, no GD state).
        self.assertIn('static func source_wave_spawner_spawn_counts_state(ground_spawn_points: Array, flyer_spawn_points: Array) -> Dictionary:', wave)
        self.assertIn('{"ground_spawn_count": ground_spawn_points.size(), "flyer_spawn_count": flyer_spawn_points.size()}', wave)
        # The proof's keys drive the pure function with synthetic
        # spawn-point lists (no live tick, no spawner, no world scan):
        # 2 counts x 3 cases each (empty -> 0, 1 point -> 1,
        # N points -> N), exactly 2 result keys, and a second call on
        # the same inputs yields the same values.
        proof = SPAWN_COUNTS_PROOF.read_text(encoding='utf-8')
        for key in [
            'ground_count_zero_when_empty',
            'ground_count_one_when_one_point',
            'ground_count_many_points',
            'flyer_count_zero_when_empty',
            'flyer_count_one_when_one_point',
            'flyer_count_many_points',
            'spawn_counts_returns_two_keys',
            'spawn_counts_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_wave_spawner_spawn_counts(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WaveSpawnerSpawnCountsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WAVE_SPAWNER_SPAWN_COUNTS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ground_count_zero_when_empty',
            'ground_count_one_when_one_point',
            'ground_count_many_points',
            'flyer_count_zero_when_empty',
            'flyer_count_one_when_one_point',
            'flyer_count_many_points',
            'spawn_counts_returns_two_keys',
            'spawn_counts_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
