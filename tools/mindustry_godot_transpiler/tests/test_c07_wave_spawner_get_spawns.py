import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WAVE_SPAWNER = ROOT / 'godot-mindustry/src/game/SourceWaveSpawnerState.gd'
GET_SPAWNS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WaveSpawnerGetSpawnsProof.gd'


class C07WaveSpawnerGetSpawnsTests(unittest.TestCase):
    def test_c07_wave_spawner_get_spawns_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2446']['godot_owner'], 'SourceWaveSpawnerState.source_wave_spawner_get_spawns_state')
        # WaveSpawner.getSpawns() (WaveSpawner.java:53-55), one method
        # slice (batch 41 slot 1): exactly the 1 body expr
        # `return spawns;` (:54). `spawns` is the WaveSpawner field
        # `private Seq<Tile> spawns = new Seq<>(false);`
        # (WaveSpawner.java:26); GD takes it as an Array input and
        # returns it as-is (precedent N2442 countSpawns, same field;
        # N2123/N2297 micro-accessors).
        self.assertEqual(
            ledger['N2446']['java_method'],
            'WaveSpawner.getSpawns()',
        )
        self.assertEqual(
            ledger['N2446']['source_symbols'],
            [
                'source_wave_spawner_get_spawns_state_result.spawns',
            ],
        )
        for name in ledger['N2446']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/ai/WaveSpawner.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnerState.source_wave_spawner_get_spawns_state'))
        self.assertEqual(ledger['N2446']['runtime_proof'], '/root/C07WaveSpawnerGetSpawnsProof')
        self.assertEqual(
            ledger['N2446']['tests'],
            [
                'test_c07_wave_spawner_get_spawns_registration',
                'test_all_c07_wave_spawner_get_spawns_input_evidence_is_exact',
                'test_wave_spawner_get_spawns_state',
                'test_reference_graph_and_actual_c07_wave_spawner_get_spawns',
            ],
        )
        self.assertTrue(ledger['N2446']['deferred_exprs'])

    def test_all_c07_wave_spawner_get_spawns_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2446']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnerState.source_wave_spawner_get_spawns_state'))
        slice_sources = {
            'core/src/mindustry/ai/WaveSpawner.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2446']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wave_spawner_get_spawns_state(self):
        wave = WAVE_SPAWNER.read_text(encoding='utf-8')
        # WaveSpawner.getSpawns() (WaveSpawner.java:53-55): the 1 body
        # expr only -- `return spawns;` (:54). The consumers
        # (BaseBuilderAI :164/:193, Pathfinder :139/:585) call
        # `spawner.getSpawns()` -- NOT in this slice; they belong to
        # BaseBuilderAI/Pathfinder, outside the C07 VM line.
        self.assertIn('static func source_wave_spawner_get_spawns_state(spawns: Array) -> Dictionary:', wave)
        self.assertIn('return spawns;', wave)
        self.assertIn('{"spawns": spawns}', wave)
        # The proof's keys drive the pure function with synthetic
        # frame inputs (no live tick, no spawner): 0 spawns -> [];
        # n spawns -> the exact input array, order preserved;
        # exactly 1 result key, and a second call on the same
        # inputs yields the same value.
        proof = GET_SPAWNS_PROOF.read_text(encoding='utf-8')
        for key in [
            'spawns_empty_when_no_spawns',
            'spawns_returns_input_array',
            'spawns_preserves_order',
            'spawns_returns_one_key',
            'spawns_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_wave_spawner_get_spawns(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WaveSpawnerGetSpawnsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WAVE_SPAWNER_GET_SPAWNS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'spawns_empty_when_no_spawns',
            'spawns_returns_input_array',
            'spawns_preserves_order',
            'spawns_returns_one_key',
            'spawns_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
