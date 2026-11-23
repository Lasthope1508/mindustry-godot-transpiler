import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WAVE_SPAWN_RUNTIME = ROOT / 'godot-mindustry/src/game/SourceWaveSpawnRuntimeState.gd'
CAN_SPAWN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SpawnGroupCanSpawnProof.gd'


class C07SpawnGroupCanSpawnTests(unittest.TestCase):
    def test_c07_spawn_group_can_spawn_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2447']['godot_owner'], 'SourceWaveSpawnRuntimeState.source_wave_spawn_can_spawn_state')
        # SpawnGroup.canSpawn(int) (SpawnGroup.java:62-64), one method
        # slice (batch 41 slot 2): exactly the 1 body expr
        # `return spawn == -1 || spawn == position;` (:63). `spawn` is
        # the SpawnGroup field `public int spawn = -1;`
        # (SpawnGroup.java:44, "If not -1, the unit will only spawn in
        # spawnpoints with these packed coordinates."): -1 means every
        # position. GD takes spawn + position as int inputs, never
        # packs/unpacks coords here. No call-site of canSpawn exists
        # outside SpawnGroup.java (grep: 0 hits) -- this slice ports
        # only the predicate.
        self.assertEqual(
            ledger['N2447']['java_method'],
            'SpawnGroup.canSpawn(int)',
        )
        self.assertEqual(
            ledger['N2447']['source_symbols'],
            [
                'source_wave_spawn_can_spawn_state_result.can_spawn',
            ],
        )
        for name in ledger['N2447']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/SpawnGroup.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnRuntimeState.source_wave_spawn_can_spawn_state'))
        self.assertEqual(ledger['N2447']['runtime_proof'], '/root/C07SpawnGroupCanSpawnProof')
        self.assertEqual(
            ledger['N2447']['tests'],
            [
                'test_c07_spawn_group_can_spawn_registration',
                'test_all_c07_spawn_group_can_spawn_input_evidence_is_exact',
                'test_spawn_group_can_spawn_state',
                'test_reference_graph_and_actual_c07_spawn_group_can_spawn',
            ],
        )
        self.assertTrue(ledger['N2447']['deferred_exprs'])

    def test_all_c07_spawn_group_can_spawn_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2447']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnRuntimeState.source_wave_spawn_can_spawn_state'))
        slice_sources = {
            'core/src/mindustry/game/SpawnGroup.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2447']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_spawn_group_can_spawn_state(self):
        wave = WAVE_SPAWN_RUNTIME.read_text(encoding='utf-8')
        # SpawnGroup.canSpawn(int) (SpawnGroup.java:62-64): the 1 body
        # expr only -- `return spawn == -1 || spawn == position;`
        # (:63). No call-site of canSpawn exists outside
        # SpawnGroup.java -- this slice ports only the predicate.
        self.assertIn('static func source_wave_spawn_can_spawn_state(spawn: int, position: int) -> Dictionary:', wave)
        self.assertIn('return spawn == -1 || spawn == position;', wave)
        self.assertIn('{"can_spawn": spawn == -1 or spawn == position}', wave)
        # The proof's keys drive the pure function with synthetic
        # frame inputs (no live tick, no spawner): spawn == -1 ->
        # true for any position; spawn == position -> true; spawn
        # different from position (both >= 0) -> false; exactly 1
        # result key, and a second call on the same inputs yields
        # the same value.
        proof = CAN_SPAWN_PROOF.read_text(encoding='utf-8')
        for key in [
            'can_spawn_true_when_spawn_minus_one',
            'can_spawn_true_when_spawn_equals_position',
            'can_spawn_false_when_different',
            'can_spawn_returns_one_key',
            'can_spawn_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_spawn_group_can_spawn(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SpawnGroupCanSpawnProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SPAWN_GROUP_CAN_SPAWN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'can_spawn_true_when_spawn_minus_one',
            'can_spawn_true_when_spawn_equals_position',
            'can_spawn_false_when_different',
            'can_spawn_returns_one_key',
            'can_spawn_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
