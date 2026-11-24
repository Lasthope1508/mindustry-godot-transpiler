import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RULES_STATE = ROOT / 'godot-mindustry/src/game/SourceRulesRuntimeState.gd'
DAMAGE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RulesUnitDamageProof.gd'

PROOF_KEYS = [
    'base_one_times_one',
    'product_scales',
    'zero_product_is_zero',
    'negative_product_passes_through',
    'missing_team_defaults_to_one',
]


class C07RulesUnitDamageTests(unittest.TestCase):
    def test_c07_rules_unit_damage_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2462']['godot_owner'], 'SourceRulesRuntimeState.source_rules_unit_damage_state')
        # Rules.unitDamage(Team) (Rules.java:279-281): the
        # signature (:279) and the product formula (:280). The
        # global multiplier defaults to 1f (:85) and the per-team
        # multiplier defaults to 1f (:355, TeamRules) -- the same
        # shape as N2096 unitCost, with NO floor (unlike N2459
        # unitHealth, which has Math.max(..., 0.000001f)).
        self.assertEqual(
            ledger['N2462']['java_method'],
            'Rules.unitDamage(Team)',
        )
        self.assertEqual(
            ledger['N2462']['source_symbols'],
            [
                'source_rules_unit_damage_state_input.rules_state',
                'source_rules_unit_damage_state_input.team_id',
                'source_rules_unit_damage_state_result.unit_damage',
            ],
        )
        for name in ledger['N2462']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/Rules.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_unit_damage_state'))
        self.assertEqual(ledger['N2462']['runtime_proof'], '/root/C07RulesUnitDamageProof')
        self.assertEqual(
            ledger['N2462']['tests'],
            [
                'test_c07_rules_unit_damage_registration',
                'test_all_c07_rules_unit_damage_input_evidence_is_exact',
                'test_rules_unit_damage_state',
                'test_reference_graph_and_actual_c07_rules_unit_damage',
            ],
        )
        self.assertTrue(ledger['N2462']['deferred_exprs'])

    def test_all_c07_rules_unit_damage_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2462']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_unit_damage_state'))
        slice_sources = {
            'core/src/mindustry/game/Rules.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2462']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_rules_unit_damage_state(self):
        rules_state = RULES_STATE.read_text(encoding='utf-8')
        # Rules.unitDamage(Team) (Rules.java:279-281):
        #     return unitDamageMultiplier *
        #         teams.get(team).unitDamageMultiplier;
        # TRAP: there is NO floor here -- unlike N2459
        # unitHealth, which returns Math.max(product, 0.000001f),
        # a product of 0 returns 0.0 and a negative product
        # passes through negative. A port that copies the N2459
        # floor into this function is wrong. A missing team
        # means the Java fresh TeamRule, so its multiplier
        # defaults to 1f (:355) like the global default 1f (:85).
        self.assertIn('static func source_rules_unit_damage_state(rules_state: Dictionary, team_id: int) -> Dictionary:', rules_state)
        self.assertIn('return {"unit_damage": global_multiplier * team_multiplier}', rules_state)
        # Function order follows Java order: unitCost() (:275-276)
        # comes before unitDamage() (:279-281), which comes before
        # unitHealth() (:283-286) in Rules.java, so
        # source_unit_cost_state comes before
        # source_rules_unit_damage_state, which comes before
        # source_rules_unit_health_state in this file.
        self.assertLess(
            rules_state.index('static func source_unit_cost_state('),
            rules_state.index('static func source_rules_unit_damage_state('),
        )
        self.assertLess(
            rules_state.index('static func source_rules_unit_damage_state('),
            rules_state.index('static func source_rules_unit_health_state('),
        )
        # The proof drives the pure function with synthetic rules
        # dicts (no live tick, no game state): 1x1 is 1, the
        # product scales, a zero product is 0.0 (no floor), a
        # negative product passes through negative, and a team
        # missing from the dict defaults to a 1x multiplier.
        proof = DAMAGE_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_rules_unit_damage(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RulesUnitDamageProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RULES_UNIT_DAMAGE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
