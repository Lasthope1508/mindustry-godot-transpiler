import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RULES_STATE = ROOT / 'godot-mindustry/src/game/SourceRulesRuntimeState.gd'
RADIUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RulesBuildRadiusProof.gd'

PROOF_KEYS = [
    'protect_true_adds_extra',
    'protect_false_blocks_all',
    'missing_team_defaults_to_400',
    'protect_true_zero_extra',
    'negative_extra_not_clamped',
]


class C07RulesBuildRadiusTests(unittest.TestCase):
    def test_c07_rules_build_radius_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2461']['godot_owner'], 'SourceRulesRuntimeState.source_rules_build_radius_state')
        # Rules.buildRadius(Team) (Rules.java:267-269): the
        # signature (:267) and the ternary (:268). The global
        # enemyCoreBuildRadius defaults to 400f (:123) and the
        # per-team protectCores defaults to true (:324, TeamRules)
        # with extraCoreBuildRadius defaulting to 0f (:371).
        self.assertEqual(
            ledger['N2461']['java_method'],
            'Rules.buildRadius(Team)',
        )
        self.assertEqual(
            ledger['N2461']['source_symbols'],
            [
                'source_rules_build_radius_state_input.rules_state',
                'source_rules_build_radius_state_input.team_id',
                'source_rules_build_radius_state_result.build_radius',
            ],
        )
        for name in ledger['N2461']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/Rules.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_build_radius_state'))
        self.assertEqual(ledger['N2461']['runtime_proof'], '/root/C07RulesBuildRadiusProof')
        self.assertEqual(
            ledger['N2461']['tests'],
            [
                'test_c07_rules_build_radius_registration',
                'test_all_c07_rules_build_radius_input_evidence_is_exact',
                'test_rules_build_radius_state',
                'test_reference_graph_and_actual_c07_rules_build_radius',
            ],
        )
        self.assertTrue(ledger['N2461']['deferred_exprs'])

    def test_all_c07_rules_build_radius_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2461']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_build_radius_state'))
        slice_sources = {
            'core/src/mindustry/game/Rules.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2461']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_rules_build_radius_state(self):
        rules_state = RULES_STATE.read_text(encoding='utf-8')
        # Rules.buildRadius(Team) (Rules.java:267-269):
        #     return !teams.get(team).protectCores ? 0f :
        #         enemyCoreBuildRadius +
        #         teams.get(team).extraCoreBuildRadius;
        # TRAP: protectCores=false blocks everything -- the
        # ternary returns 0f without adding anything, however
        # large extraCoreBuildRadius is. A port that adds first
        # and checks protect later is wrong. TRAP: no clamp --
        # unlike N2459 unitHealth there is no Math.max here, so
        # a negative extra passes through (400 + -50 = 350).
        # A missing team means the Java fresh TeamRule, so
        # protectCores defaults to true (:324) and
        # extraCoreBuildRadius defaults to 0f (:371), and the
        # answer is the global enemyCoreBuildRadius (400f :123).
        self.assertIn('static func source_rules_build_radius_state(rules_state: Dictionary, team_id: int) -> Dictionary:', rules_state)
        self.assertIn('return {"build_radius":', rules_state)
        # Function order follows Java order: mode() (:249-261)
        # comes before buildRadius() (:267-269), which comes
        # before unitCost() (:275-276) in Rules.java, so
        # source_rules_build_radius_state sits between
        # source_rules_mode_state and source_unit_cost_state in
        # this file.
        self.assertLess(
            rules_state.index('static func source_rules_mode_state('),
            rules_state.index('static func source_rules_build_radius_state('),
        )
        self.assertLess(
            rules_state.index('static func source_rules_build_radius_state('),
            rules_state.index('static func source_unit_cost_state('),
        )
        # The proof drives the pure function with synthetic rules
        # dicts (no live tick, no game state): protect true adds
        # the extra, protect false blocks everything to 0, a
        # missing team defaults to 400, and a negative extra is
        # not clamped.
        proof = RADIUS_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_rules_build_radius(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RulesBuildRadiusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RULES_BUILD_RADIUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
