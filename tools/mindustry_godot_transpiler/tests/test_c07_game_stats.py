import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
GAME_STATS_STATE = ROOT / 'godot-mindustry/src/game/SourceGameStatsRuntimeState.gd'
GAME_STATS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07GameStatsProof.gd'

PROOF_KEYS = [
    'missing_block_returns_zero',
    'placed_counts',
    'destroyed_counts',
    'independent_maps',
    'idempotent_second_call',
    'empty_stats_zero',
]


class C07GameStatsTests(unittest.TestCase):
    def test_c07_game_stats_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2460']['godot_owner'], 'SourceGameStatsRuntimeState.source_game_stats_get_placed_state; SourceGameStatsRuntimeState.source_game_stats_get_destroyed_state')
        # GameStats.getPlaced(Block) + getDestroyed(Block)
        # (GameStats.java:30-36): each is a single
        # `map.get(block, 0)` on its own ObjectIntMap -- placed
        # reads placedBlockCount (:21), destroyed reads
        # destroyedBlockCount (:24). The two maps are
        # independent: a block present in one map only still
        # returns 0 from the other, and a missing block returns
        # 0 (the default of `get(block, 0)`), never KeyError or
        # null. coreItemCount (:28) and the int counters are NOT
        # part of this slice.
        self.assertEqual(
            ledger['N2460']['java_method'],
            'GameStats.getPlaced(Block)/getDestroyed(Block)',
        )
        self.assertEqual(
            ledger['N2460']['source_symbols'],
            [
                'source_game_stats_get_placed_state_result.placed',
                'source_game_stats_get_destroyed_state_result.destroyed',
            ],
        )
        for name in ledger['N2460']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/GameStats.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameStatsRuntimeState.source_game_stats_get_'))
        self.assertEqual(ledger['N2460']['runtime_proof'], '/root/C07GameStatsProof')
        self.assertEqual(
            ledger['N2460']['tests'],
            [
                'test_c07_game_stats_registration',
                'test_all_c07_game_stats_input_evidence_is_exact',
                'test_game_stats_state',
                'test_reference_graph_and_actual_c07_game_stats',
            ],
        )
        self.assertTrue(ledger['N2460']['deferred_exprs'])

    def test_all_c07_game_stats_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2460']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameStatsRuntimeState.source_game_stats_get_'))
        slice_sources = {
            'core/src/mindustry/game/GameStats.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2460']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_game_stats_state(self):
        game_stats_state = GAME_STATS_STATE.read_text(encoding='utf-8')
        # GameStats.getPlaced(Block) + getDestroyed(Block)
        # (GameStats.java:30-36): each is a single
        # `map.get(block, 0)` on its own ObjectIntMap. GD takes
        # the stats as a Dictionary plus the block as a String
        # name (option (A) data-driven, precedent N2453/N2455/
        # N2456/N2457); it does not build GameStats objects
        # itself. The lookup is `.get(block, 0)` on the right
        # map -- a missing block returns 0, and the two maps
        # are never mixed: getDestroyed must not be derived
        # from placed counts (no `placed - destroyed`, no
        # cross-map read).
        self.assertIn('static func source_game_stats_get_placed_state(stats_state: Dictionary, block: String) -> Dictionary:', game_stats_state)
        self.assertIn('static func source_game_stats_get_destroyed_state(stats_state: Dictionary, block: String) -> Dictionary:', game_stats_state)
        self.assertIn('return {"placed": int(placed.get(block, 0))}', game_stats_state)
        self.assertIn('return {"destroyed": int(destroyed.get(block, 0))}', game_stats_state)
        # The proof drives the pure functions with synthetic
        # stats dicts (no live tick, no game state): a missing
        # block returns 0 from both maps, placed counts read
        # back, destroyed counts read back, the two maps stay
        # independent, repeat calls are idempotent, and empty
        # stats return 0.
        proof = GAME_STATS_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_game_stats(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07GameStatsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_GAME_STATS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
