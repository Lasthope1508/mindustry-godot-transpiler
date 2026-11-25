import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RULES_STATE = ROOT / 'godot-mindustry/src/game/SourceRulesRuntimeState.gd'
BLOCK_HEALTH_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RulesBlockHealthProof.gd'

PROOF_KEYS = [
    'base_one_times_one',
    'product_scales',
    'zero_product_is_zero',
    'negative_product_passes_through',
    'missing_team_defaults_to_one',
    'missing_global_defaults_to_one',
    'string_team_key',
    'fractional_product',
]


class C07RulesBlockHealthTests(unittest.TestCase):
    def test_c07_rules_block_health_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2470']['godot_owner'], 'SourceRulesRuntimeState.source_rules_block_health_state')
        # Rules.blockHealth(Team) (Rules.java:296-298): the
        # signature (:296) and the product formula (:297). The
        # global multiplier defaults to 1f (:111) and the per-team
        # multiplier defaults to 1f (:365, TeamRules) -- the same
        # shape as N2096 unitCost, with NO floor (unlike N2459
        # unitHealth, which has Math.max(..., 0.000001f)).
        self.assertEqual(
            ledger['N2470']['java_method'],
            'Rules.blockHealth(Team)',
        )
        self.assertEqual(
            ledger['N2470']['source_symbols'],
            [
                'source_rules_block_health_state_input.rules_state',
                'source_rules_block_health_state_input.team_id',
                'source_rules_block_health_state_result.block_health',
            ],
        )
        for name in ledger['N2470']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/Rules.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_block_health_state'))
        self.assertEqual(ledger['N2470']['runtime_proof'], '/root/C07RulesBlockHealthProof')
        self.assertEqual(
            ledger['N2470']['tests'],
            [
                'test_c07_rules_block_health_registration',
                'test_all_c07_rules_block_health_input_evidence_is_exact',
                'test_rules_block_health_state',
                'test_reference_graph_and_actual_c07_rules_block_health',
            ],
        )
        self.assertTrue(ledger['N2470']['deferred_exprs'])

    def test_all_c07_rules_block_health_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2470']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_block_health_state'))
        slice_sources = {
            'core/src/mindustry/game/Rules.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2470']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_rules_block_health_state(self):
        rules_state = RULES_STATE.read_text(encoding='utf-8')
        # Rules.blockHealth(Team) (Rules.java:296-298):
        #     return blockHealthMultiplier *
        #         teams.get(team).blockHealthMultiplier;
        # TRAP: there is NO floor here -- unlike N2459
        # unitHealth, which returns Math.max(product, 0.000001f),
        # a product of 0 returns 0.0 and a negative product
        # passes through negative. A port that copies the N2459
        # floor into this function is wrong. A missing team
        # means the Java fresh TeamRule, so its multiplier
        # defaults to 1f (:365) like the global default 1f (:111).
        self.assertIn('static func source_rules_block_health_state(rules_state: Dictionary, team_id: int) -> Dictionary:', rules_state)
        self.assertIn('return {"block_health": global_multiplier * team_multiplier}', rules_state)
        # Function order follows Java order: unitMineSpeed()
        # (:292-294) comes before blockHealth() (:296-298),
        # which comes before isBanned(Block) (:307-309) in
        # Rules.java, so source_rules_unit_mine_speed_state comes
        # before source_rules_block_health_state, which comes
        # before source_rules_is_banned_state in this file.
        self.assertLess(
            rules_state.index('static func source_rules_unit_mine_speed_state('),
            rules_state.index('static func source_rules_block_health_state('),
        )
        self.assertLess(
            rules_state.index('static func source_rules_block_health_state('),
            rules_state.index('static func source_rules_is_banned_state('),
        )
        # The proof drives the pure function with synthetic rules
        # dicts (no live tick, no game state): 1x1 is 1, the
        # product scales, a zero product is 0.0 (no floor), a
        # negative product passes through negative, a team
        # missing from the dict defaults to a 1x multiplier, a
        # missing global defaults to 1x, string team keys work
        # like int keys, and fractional products are compared
        # with a tolerance.
        proof = BLOCK_HEALTH_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_rules_block_health(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RulesBlockHealthProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RULES_BLOCK_HEALTH_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
