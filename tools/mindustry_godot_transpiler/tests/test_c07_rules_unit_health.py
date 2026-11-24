import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RULES_STATE = ROOT / 'godot-mindustry/src/game/SourceRulesRuntimeState.gd'
HEALTH_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RulesUnitHealthProof.gd'

PROOF_KEYS = [
    'base_one_times_one',
    'product_scales',
    'floor_not_zero',
    'negative_product_floored',
    'missing_team_defaults_to_one',
]


class C07RulesUnitHealthTests(unittest.TestCase):
    def test_c07_rules_unit_health_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2459']['godot_owner'], 'SourceRulesRuntimeState.source_rules_unit_health_state')
        # Rules.unitHealth(Team) (Rules.java:283-286): the
        # signature (:283), the floor comment (:284) and the
        # Math.max formula (:285). The global multiplier
        # defaults to 1f (:87) and the per-team multiplier
        # defaults to 1f (:363, TeamRules) -- the same shape as
        # N2096 unitCost, plus the 0.000001f floor.
        self.assertEqual(
            ledger['N2459']['java_method'],
            'Rules.unitHealth(Team)',
        )
        self.assertEqual(
            ledger['N2459']['source_symbols'],
            [
                'source_rules_unit_health_state_input.rules_state',
                'source_rules_unit_health_state_input.team_id',
                'source_rules_unit_health_state_result.unit_health',
            ],
        )
        for name in ledger['N2459']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/Rules.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_unit_health_state'))
        self.assertEqual(ledger['N2459']['runtime_proof'], '/root/C07RulesUnitHealthProof')
        self.assertEqual(
            ledger['N2459']['tests'],
            [
                'test_c07_rules_unit_health_registration',
                'test_all_c07_rules_unit_health_input_evidence_is_exact',
                'test_rules_unit_health_state',
                'test_reference_graph_and_actual_c07_rules_unit_health',
            ],
        )
        self.assertTrue(ledger['N2459']['deferred_exprs'])

    def test_all_c07_rules_unit_health_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2459']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_unit_health_state'))
        slice_sources = {
            'core/src/mindustry/game/Rules.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2459']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_rules_unit_health_state(self):
        rules_state = RULES_STATE.read_text(encoding='utf-8')
        # Rules.unitHealth(Team) (Rules.java:283-286):
        #     return Math.max(unitHealthMultiplier *
        #         teams.get(team).unitHealthMultiplier, 0.000001f);
        # TRAP: the floor is 0.000001, not 0 -- a product of 0
        # (or negative) still returns 0.000001, exactly as the
        # Java comment :284 says ("a 0 here would be a very bad
        # idea"). A port that clamps to 0 is wrong. A missing
        # team means the Java fresh TeamRule, so its multiplier
        # defaults to 1f (:363) like the global default 1f (:87).
        self.assertIn('static func source_rules_unit_health_state(rules_state: Dictionary, team_id: int) -> Dictionary:', rules_state)
        self.assertIn('return {"unit_health": maxf(', rules_state)
        self.assertIn('0.000001', rules_state)
        # Function order follows Java order: unitCost() (:275-276)
        # comes before unitHealth() (:283-286) in Rules.java, so
        # source_unit_cost_state comes before
        # source_rules_unit_health_state in this file.
        self.assertLess(
            rules_state.index('static func source_unit_cost_state('),
            rules_state.index('static func source_rules_unit_health_state('),
        )
        # The proof drives the pure function with synthetic rules
        # dicts (no live tick, no game state): 1x1 is 1, the
        # product scales, a zero or negative product is floored
        # to 0.000001 (not 0), and a team missing from the dict
        # defaults to a 1x multiplier.
        proof = HEALTH_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_rules_unit_health(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RulesUnitHealthProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RULES_UNIT_HEALTH_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
