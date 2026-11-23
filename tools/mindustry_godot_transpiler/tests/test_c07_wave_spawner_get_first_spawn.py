import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WAVE_SPAWNER = ROOT / 'godot-mindustry/src/game/SourceWaveSpawnerState.gd'
GET_FIRST_SPAWN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WaveSpawnerGetFirstSpawnProof.gd'

PROOF_KEYS = [
    'empty_list_returns_null',
    'single_tile_returns_that_tile',
    'last_tile_wins_not_first',
    'order_sensitivity_reversed',
    'get_first_spawn_returns_one_key',
    'get_first_spawn_idempotent_second_call',
]


class C07WaveSpawnerGetFirstSpawnTests(unittest.TestCase):
    def test_c07_wave_spawner_get_first_spawn_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2455']['godot_owner'], 'SourceWaveSpawnerState.source_wave_spawner_get_first_spawn_state')
        # WaveSpawner.getFirstSpawn() (WaveSpawner.java:40-47): the
        # 3 distinct body exprs only -- `firstSpawn = null;` (:42),
        # `eachGroundSpawn((cx, cy) -> { firstSpawn = world.tile(cx, cy); });`
        # (:43-45) and `return firstSpawn;` (:46). The callback
        # overwrites firstSpawn UNCONDITIONALLY on every enumerated
        # ground spawn point, so despite the name the method returns
        # the LAST enumerated tile (or null when there are none).
        # GD takes the already-enumerated ground spawn tiles as an
        # Array input (option (A) data-driven, precedent N2453) and
        # does not enumerate them itself: eachGroundSpawn is NOT
        # ported and belongs to a later slice. The field
        # `private Tile firstSpawn = null;` (:29) is NOT registered
        # here (field decl; it is a per-call local in the port).
        self.assertEqual(
            ledger['N2455']['java_method'],
            'WaveSpawner.getFirstSpawn()',
        )
        self.assertEqual(
            ledger['N2455']['source_symbols'],
            [
                'source_wave_spawner_get_first_spawn_state_result.first_spawn',
            ],
        )
        for name in ledger['N2455']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/ai/WaveSpawner.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnerState.source_wave_spawner_get_first_spawn_state'))
        self.assertEqual(ledger['N2455']['runtime_proof'], '/root/C07WaveSpawnerGetFirstSpawnProof')
        self.assertEqual(
            ledger['N2455']['tests'],
            [
                'test_c07_wave_spawner_get_first_spawn_registration',
                'test_all_c07_wave_spawner_get_first_spawn_input_evidence_is_exact',
                'test_wave_spawner_get_first_spawn_state',
                'test_reference_graph_and_actual_c07_wave_spawner_get_first_spawn',
            ],
        )
        self.assertTrue(ledger['N2455']['deferred_exprs'])

    def test_all_c07_wave_spawner_get_first_spawn_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2455']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnerState.source_wave_spawner_get_first_spawn_state'))
        slice_sources = {
            'core/src/mindustry/ai/WaveSpawner.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2455']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wave_spawner_get_first_spawn_state(self):
        wave = WAVE_SPAWNER.read_text(encoding='utf-8')
        # WaveSpawner.getFirstSpawn() (WaveSpawner.java:40-47): the
        # 3 distinct body exprs only. GD takes the already-enumerated
        # ground spawn tiles as an Array input (option (A)
        # data-driven, precedent N2453) and does not enumerate them
        # itself: eachGroundSpawn is NOT ported and belongs to a
        # later slice. The callback overwrites the result on every
        # tile, so the GD loop must NOT break early -- the last tile
        # wins, exactly like the Java.
        self.assertIn('static func source_wave_spawner_get_first_spawn_state(ground_spawn_tiles: Array) -> Dictionary:', wave)
        self.assertIn('return {"first_spawn": first_spawn}', wave)
        # The proof's keys drive the pure function with synthetic
        # tile lists (no live tick, no spawner, no world scan):
        # empty -> null, 1 tile -> that tile, >=2 tiles -> the LAST
        # tile (the name trap), reversed order -> the other end,
        # exactly 1 result key, and a second call on the same inputs
        # yields the same value.
        proof = GET_FIRST_SPAWN_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_wave_spawner_get_first_spawn(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WaveSpawnerGetFirstSpawnProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WAVE_SPAWNER_GET_FIRST_SPAWN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
