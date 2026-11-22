import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WAVE_SPAWNER = ROOT / 'godot-mindustry/src/game/SourceWaveSpawnerState.gd'
COUNT_SPAWNS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WaveSpawnerCountSpawnsProof.gd'


class C07WaveSpawnerCountSpawnsTests(unittest.TestCase):
    def test_c07_wave_spawner_count_spawns_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2442']['godot_owner'], 'SourceWaveSpawnerState.source_wave_spawner_count_spawns_state')
        # WaveSpawner.countSpawns() (WaveSpawner.java:49-51), one method
        # slice (batch 39 slot 2): exactly the 1 body expr
        # `return spawns.size;` (:50). `spawns` is the WaveSpawner
        # field `private Seq<Tile> spawns = new Seq<>(false);`
        # (WaveSpawner.java:26); GD takes it as an Array input and
        # does not recompute it from the world. First WaveSpawner
        # slice on either line. One GD function on the NEW file
        # SourceWaveSpawnerState.gd; pure accessor, precedent
        # N2123/N2297 (micro-accessors) + N2405/N2407 (new files).
        self.assertEqual(
            ledger['N2442']['java_method'],
            'WaveSpawner.countSpawns()',
        )
        self.assertEqual(
            ledger['N2442']['source_symbols'],
            [
                'source_wave_spawner_count_spawns_state_result.count',
            ],
        )
        for name in ledger['N2442']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/ai/WaveSpawner.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnerState.source_wave_spawner_count_spawns_state'))
        self.assertEqual(ledger['N2442']['runtime_proof'], '/root/C07WaveSpawnerCountSpawnsProof')
        self.assertEqual(
            ledger['N2442']['tests'],
            [
                'test_c07_wave_spawner_count_spawns_registration',
                'test_all_c07_wave_spawner_count_spawns_input_evidence_is_exact',
                'test_wave_spawner_count_spawns_state',
                'test_reference_graph_and_actual_c07_wave_spawner_count_spawns',
            ],
        )
        self.assertTrue(ledger['N2442']['deferred_exprs'])

    def test_all_c07_wave_spawner_count_spawns_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2442']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnerState.source_wave_spawner_count_spawns_state'))
        slice_sources = {
            'core/src/mindustry/ai/WaveSpawner.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2442']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wave_spawner_count_spawns_state(self):
        wave = WAVE_SPAWNER.read_text(encoding='utf-8')
        # WaveSpawner.countSpawns() (WaveSpawner.java:49-51): the 1 body
        # expr only -- `return spawns.size;` (:50). spawnEnemies()
        # (WaveSpawner.java:62-110) is NOT in this slice.
        self.assertIn('static func source_wave_spawner_count_spawns_state(spawns: Array) -> Dictionary:', wave)
        self.assertIn('return spawns.size;', wave)
        self.assertIn('{"count": spawns.size()}', wave)
        # The proof's keys drive the pure function with synthetic
        # spawn lists (no live tick, no world scan, no spawner):
        # 0 spawns -> 0, 1 spawn -> 1, n spawns -> n, exactly 1
        # result key, and a second call on the same inputs yields
        # the same value.
        proof = COUNT_SPAWNS_PROOF.read_text(encoding='utf-8')
        for key in [
            'count_zero_spawns',
            'count_one_spawn',
            'count_many_spawns',
            'count_returns_one_key',
            'count_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_wave_spawner_count_spawns(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WaveSpawnerCountSpawnsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WAVE_SPAWNER_COUNT_SPAWNS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'count_zero_spawns',
            'count_one_spawn',
            'count_many_spawns',
            'count_returns_one_key',
            'count_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
