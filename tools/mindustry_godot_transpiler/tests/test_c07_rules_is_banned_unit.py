import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RULES_STATE = ROOT / 'godot-mindustry/src/game/SourceRulesRuntimeState.gd'
IS_BANNED_UNIT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RulesIsBannedUnitProof.gd'

PROOF_KEYS = [
    'blacklist_bans_listed',
    'blacklist_allows_unlisted',
    'whitelist_allows_listed',
    'whitelist_bans_all_when_empty',
    'blacklist_empty_allows_all',
    'missing_keys_default',
    'multiple_entries',
    'whitelist_multiple',
]


class C07RulesIsBannedUnitTests(unittest.TestCase):
    def test_c07_rules_is_banned_unit_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2469']['godot_owner'], 'SourceRulesRuntimeState.source_rules_is_banned_unit_state')
        # Rules.isBanned(UnitType) (Rules.java:311-313): the
        # signature (:311) and the XOR formula (:312). The
        # unitWhitelist defaults to false (:147) and
        # bannedUnits defaults to an empty ObjectSet<UnitType>
        # (:183). Sibling of N2465 isBanned(Block), whose
        # deferred_exprs explicitly left this method for a
        # later batch; the unit travels as its String name,
        # same precedent as the block (N2460 GameStats
        # getPlaced keys blocks by name in GD).
        self.assertEqual(
            ledger['N2469']['java_method'],
            'Rules.isBanned(UnitType)',
        )
        self.assertEqual(
            ledger['N2469']['source_symbols'],
            [
                'source_rules_is_banned_unit_state_input.rules_state',
                'source_rules_is_banned_unit_state_input.unit',
                'source_rules_is_banned_unit_state_result.is_banned',
            ],
        )
        for name in ledger['N2469']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/Rules.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_is_banned_unit_state'))
        self.assertEqual(ledger['N2469']['runtime_proof'], '/root/C07RulesIsBannedUnitProof')
        self.assertEqual(
            ledger['N2469']['tests'],
            [
                'test_c07_rules_is_banned_unit_registration',
                'test_all_c07_rules_is_banned_unit_input_evidence_is_exact',
                'test_rules_is_banned_unit_state',
                'test_reference_graph_and_actual_c07_rules_is_banned_unit',
            ],
        )
        self.assertTrue(ledger['N2469']['deferred_exprs'])

    def test_all_c07_rules_is_banned_unit_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2469']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_is_banned_unit_state'))
        slice_sources = {
            'core/src/mindustry/game/Rules.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2469']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_rules_is_banned_unit_state(self):
        rules_state = RULES_STATE.read_text(encoding='utf-8')
        # Rules.isBanned(UnitType) (Rules.java:311-313):
        #     return unitWhitelist !=
        #         bannedUnits.contains(unit);
        # TRAP: the whitelist INVERTS the answer -- with the
        # whitelist on, a unit IN the set is allowed (false)
        # and a unit NOT in the set is banned (true); with
        # an empty set and the whitelist on, EVERY unit is
        # banned. A port that reads isBanned as "is in the
        # set" (== instead of !=) is wrong in both whitelist
        # cases, and a port that copies N2465's field names
        # (blockWhitelist/bannedBlocks) instead of
        # unitWhitelist/bannedUnits is wrong everywhere.
        # unitWhitelist defaults to false (:147) and
        # bannedUnits defaults to empty (:183), so a missing
        # key means blacklist mode with nothing banned.
        self.assertIn('static func source_rules_is_banned_unit_state(rules_state: Dictionary, unit: String) -> Dictionary:', rules_state)
        self.assertIn('return {"is_banned": unit_whitelist != banned_units.has(unit)}', rules_state)
        # Function order follows Java order: isBanned(Block)
        # (:307-309) comes before isBanned(UnitType)
        # (:311-313), which comes before
        # unitActivationDelay() (:315-317) in Rules.java, so
        # source_rules_is_banned_state comes before
        # source_rules_is_banned_unit_state, which comes
        # before source_rules_unit_activation_delay_state in
        # this file.
        self.assertLess(
            rules_state.index('static func source_rules_is_banned_state('),
            rules_state.index('static func source_rules_is_banned_unit_state('),
        )
        self.assertLess(
            rules_state.index('static func source_rules_is_banned_unit_state('),
            rules_state.index('static func source_rules_unit_activation_delay_state('),
        )
        # The proof drives the pure function with synthetic
        # rules dicts (no live tick, no game state): the
        # blacklist bans a listed unit and allows an
        # unlisted one, the whitelist allows a listed unit
        # and bans everything when the set is empty, an
        # empty blacklist allows everything, missing keys
        # default to blacklist-empty, and multi-entry sets
        # behave the same in both modes.
        proof = IS_BANNED_UNIT_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_rules_is_banned_unit(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RulesIsBannedUnitProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RULES_IS_BANNED_UNIT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
