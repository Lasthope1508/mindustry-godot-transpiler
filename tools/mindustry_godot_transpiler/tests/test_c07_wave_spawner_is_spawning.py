import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WAVE_SPAWNER = ROOT / 'godot-mindustry/src/game/SourceWaveSpawnerState.gd'
IS_SPAWNING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WaveSpawnerIsSpawningProof.gd'


class C07WaveSpawnerIsSpawningTests(unittest.TestCase):
    def test_c07_wave_spawner_is_spawning_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2444']['godot_owner'], 'SourceWaveSpawnerState.source_wave_spawner_is_spawning_state')
        # WaveSpawner.isSpawning() (WaveSpawner.java:213-215), one method
        # slice (batch 40 slot 2): exactly the 1 body expr
        # `return spawning && !net.client();` (:214). `spawning` is the
        # WaveSpawner field `private boolean spawning = false;`
        # (WaveSpawner.java:27); GD takes it as a bool input and
        # `net.client()` as the frame input is_client, never resolved
        # here (precedent N2438 checkCampaignStats, same
        # `... && !net.client()` shape; N2123/N2297 micro-accessors).
        self.assertEqual(
            ledger['N2444']['java_method'],
            'WaveSpawner.isSpawning()',
        )
        self.assertEqual(
            ledger['N2444']['source_symbols'],
            [
                'source_wave_spawner_is_spawning_state_result.spawning',
            ],
        )
        for name in ledger['N2444']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/ai/WaveSpawner.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnerState.source_wave_spawner_is_spawning_state'))
        self.assertEqual(ledger['N2444']['runtime_proof'], '/root/C07WaveSpawnerIsSpawningProof')
        self.assertEqual(
            ledger['N2444']['tests'],
            [
                'test_c07_wave_spawner_is_spawning_registration',
                'test_all_c07_wave_spawner_is_spawning_input_evidence_is_exact',
                'test_wave_spawner_is_spawning_state',
                'test_reference_graph_and_actual_c07_wave_spawner_is_spawning',
            ],
        )
        self.assertTrue(ledger['N2444']['deferred_exprs'])

    def test_all_c07_wave_spawner_is_spawning_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2444']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnerState.source_wave_spawner_is_spawning_state'))
        slice_sources = {
            'core/src/mindustry/ai/WaveSpawner.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2444']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wave_spawner_is_spawning_state(self):
        wave = WAVE_SPAWNER.read_text(encoding='utf-8')
        # WaveSpawner.isSpawning() (WaveSpawner.java:213-215): the 1 body
        # expr only -- `return spawning && !net.client();` (:214). The
        # checkGameState() call-site `spawner.isSpawning();` (:369) is NOT
        # in this slice -- it belongs to checkGameState, a later slice.
        self.assertIn('static func source_wave_spawner_is_spawning_state(spawning: bool, is_client: bool) -> Dictionary:', wave)
        self.assertIn('return spawning && !net.client();', wave)
        self.assertIn('{"spawning": spawning and not is_client}', wave)
        # The proof's keys drive the pure function with synthetic
        # frame inputs (no live tick, no spawner): spawning +
        # not client -> true; not spawning -> false; client ->
        # false; exactly 1 result key, and a second call on the
        # same inputs yields the same value.
        proof = IS_SPAWNING_PROOF.read_text(encoding='utf-8')
        for key in [
            'spawning_true_when_spawning_and_not_client',
            'spawning_false_when_not_spawning',
            'spawning_false_when_client',
            'spawning_returns_one_key',
            'spawning_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_wave_spawner_is_spawning(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WaveSpawnerIsSpawningProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WAVE_SPAWNER_IS_SPAWNING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'spawning_true_when_spawning_and_not_client',
            'spawning_false_when_not_spawning',
            'spawning_false_when_client',
            'spawning_returns_one_key',
            'spawning_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
