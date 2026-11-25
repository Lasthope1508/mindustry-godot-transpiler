import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RULES_STATE = ROOT / 'godot-mindustry/src/game/SourceRulesRuntimeState.gd'
BUILD_SPEED_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RulesUnitBuildSpeedProof.gd'

PROOF_KEYS = [
    'base_one_times_one',
    'product_scales',
    'zero_product_is_zero',
    'negative_product_passes_through',
    'missing_team_defaults_to_one',
]


class C07RulesUnitBuildSpeedTests(unittest.TestCase):
    def test_c07_rules_unit_build_speed_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2464']['godot_owner'], 'SourceRulesRuntimeState.source_rules_unit_build_speed_state')
        # Rules.unitBuildSpeed(Team) (Rules.java:271-273): the
        # signature (:271) and the product formula (:272). The
        # global multiplier defaults to 1f (:81) and the per-team
        # multiplier defaults to 1f (:353, TeamRules) -- the same
        # shape as N2096 unitCost, with NO floor (unlike N2459
        # unitHealth, which has Math.max(..., 0.000001f)).
        self.assertEqual(
            ledger['N2464']['java_method'],
            'Rules.unitBuildSpeed(Team)',
        )
        self.assertEqual(
            ledger['N2464']['source_symbols'],
            [
                'source_rules_unit_build_speed_state_input.rules_state',
                'source_rules_unit_build_speed_state_input.team_id',
                'source_rules_unit_build_speed_state_result.unit_build_speed',
            ],
        )
        for name in ledger['N2464']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/Rules.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_unit_build_speed_state'))
        self.assertEqual(ledger['N2464']['runtime_proof'], '/root/C07RulesUnitBuildSpeedProof')
        self.assertEqual(
            ledger['N2464']['tests'],
            [
                'test_c07_rules_unit_build_speed_registration',
                'test_all_c07_rules_unit_build_speed_input_evidence_is_exact',
                'test_rules_unit_build_speed_state',
                'test_reference_graph_and_actual_c07_rules_unit_build_speed',
            ],
        )
        self.assertTrue(ledger['N2464']['deferred_exprs'])

    def test_all_c07_rules_unit_build_speed_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2464']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_unit_build_speed_state'))
        slice_sources = {
            'core/src/mindustry/game/Rules.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2464']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_rules_unit_build_speed_state(self):
        rules_state = RULES_STATE.read_text(encoding='utf-8')
        # Rules.unitBuildSpeed(Team) (Rules.java:271-273):
        #     return unitBuildSpeedMultiplier *
        #         teams.get(team).unitBuildSpeedMultiplier;
        # TRAP: there is NO floor here -- unlike N2459
        # unitHealth, which returns Math.max(product, 0.000001f),
        # a product of 0 returns 0.0 and a negative product
        # passes through negative. A port that copies the N2459
        # floor into this function is wrong. A missing team
        # means the Java fresh TeamRule, so its multiplier
        # defaults to 1f (:353) like the global default 1f (:81).
        self.assertIn('static func source_rules_unit_build_speed_state(rules_state: Dictionary, team_id: int) -> Dictionary:', rules_state)
        self.assertIn('return {"unit_build_speed": global_multiplier * team_multiplier}', rules_state)
        # Function order follows Java order: buildRadius()
        # (:267-269) comes before unitBuildSpeed() (:271-273),
        # which comes before unitCost() (:275-276) in Rules.java,
        # so source_rules_build_radius_state comes before
        # source_rules_unit_build_speed_state, which comes
        # before source_unit_cost_state in this file.
        self.assertLess(
            rules_state.index('static func source_rules_build_radius_state('),
            rules_state.index('static func source_rules_unit_build_speed_state('),
        )
        self.assertLess(
            rules_state.index('static func source_rules_unit_build_speed_state('),
            rules_state.index('static func source_unit_cost_state('),
        )
        # The proof drives the pure function with synthetic rules
        # dicts (no live tick, no game state): 1x1 is 1, the
        # product scales, a zero product is 0.0 (no floor), a
        # negative product passes through negative, and a team
        # missing from the dict defaults to a 1x multiplier.
        proof = BUILD_SPEED_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_rules_unit_build_speed(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RulesUnitBuildSpeedProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RULES_UNIT_BUILD_SPEED_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
