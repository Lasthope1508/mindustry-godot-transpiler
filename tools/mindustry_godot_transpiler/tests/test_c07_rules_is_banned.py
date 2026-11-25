import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RULES_STATE = ROOT / 'godot-mindustry/src/game/SourceRulesRuntimeState.gd'
IS_BANNED_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RulesIsBannedProof.gd'

PROOF_KEYS = [
    'blacklist_bans_listed',
    'blacklist_allows_unlisted',
    'whitelist_allows_listed',
    'whitelist_bans_all_when_empty',
    'blacklist_empty_allows_all',
]


class C07RulesIsBannedTests(unittest.TestCase):
    def test_c07_rules_is_banned_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2465']['godot_owner'], 'SourceRulesRuntimeState.source_rules_is_banned_state')
        # Rules.isBanned(Block) (Rules.java:307-309): the
        # signature (:307) and the XOR formula (:308).
        # blockWhitelist defaults to false (:145) and
        # bannedBlocks defaults to an empty ObjectSet (:181).
        # The block travels as its String name -- precedent
        # N2460 GameStats.getPlaced (SourceGameStatsRuntimeState
        # source_game_stats_get_placed_state(stats_state,
        # block: String)), because Java keys the set by Block
        # object and GD keys by name.
        self.assertEqual(
            ledger['N2465']['java_method'],
            'Rules.isBanned(Block)',
        )
        self.assertEqual(
            ledger['N2465']['source_symbols'],
            [
                'source_rules_is_banned_state_input.rules_state',
                'source_rules_is_banned_state_input.block',
                'source_rules_is_banned_state_result.is_banned',
            ],
        )
        for name in ledger['N2465']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/Rules.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_is_banned_state'))
        self.assertEqual(ledger['N2465']['runtime_proof'], '/root/C07RulesIsBannedProof')
        self.assertEqual(
            ledger['N2465']['tests'],
            [
                'test_c07_rules_is_banned_registration',
                'test_all_c07_rules_is_banned_input_evidence_is_exact',
                'test_rules_is_banned_state',
                'test_reference_graph_and_actual_c07_rules_is_banned',
            ],
        )
        self.assertTrue(ledger['N2465']['deferred_exprs'])

    def test_all_c07_rules_is_banned_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2465']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_is_banned_state'))
        slice_sources = {
            'core/src/mindustry/game/Rules.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2465']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_rules_is_banned_state(self):
        rules_state = RULES_STATE.read_text(encoding='utf-8')
        # Rules.isBanned(Block) (Rules.java:307-309):
        #     return blockWhitelist !=
        #         bannedBlocks.contains(block);
        # TRAP: the whitelist INVERTS the answer -- with the
        # whitelist on, a block IN the set is allowed (false)
        # and a block NOT in the set is banned (true); with
        # an empty set and the whitelist on, EVERY block is
        # banned. A port that reads isBanned as "is in the
        # set" (== instead of !=) is wrong in both whitelist
        # cases. blockWhitelist defaults to false (:145) and
        # bannedBlocks defaults to empty (:181), so a missing
        # key means blacklist mode with nothing banned.
        self.assertIn('static func source_rules_is_banned_state(rules_state: Dictionary, block: String) -> Dictionary:', rules_state)
        self.assertIn('return {"is_banned": block_whitelist != banned_blocks.has(block)}', rules_state)
        # Function order follows Java order: unitHealth()
        # (:283-286) comes before isBanned() (:307-309),
        # which comes before the TeamRule accessor
        # source_team_cheating_state in this file, so
        # source_rules_unit_health_state comes before
        # source_rules_is_banned_state, which comes before
        # source_team_cheating_state.
        self.assertLess(
            rules_state.index('static func source_rules_unit_health_state('),
            rules_state.index('static func source_rules_is_banned_state('),
        )
        self.assertLess(
            rules_state.index('static func source_rules_is_banned_state('),
            rules_state.index('static func source_team_cheating_state('),
        )
        # The proof drives the pure function with synthetic
        # rules dicts (no live tick, no game state): the
        # blacklist bans a listed block and allows an
        # unlisted one, the whitelist allows a listed block
        # and bans everything when the set is empty, and an
        # empty blacklist allows everything.
        proof = IS_BANNED_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_rules_is_banned(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RulesIsBannedProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RULES_IS_BANNED_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
