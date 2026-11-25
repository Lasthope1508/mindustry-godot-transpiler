import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RULES_STATE = ROOT / 'godot-mindustry/src/game/SourceRulesRuntimeState.gd'
UNIT_ACTIVATION_DELAY_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RulesUnitActivationDelayProof.gd'

PROOF_KEYS = [
    'adds_both',
    'defaults_zero',
    'missing_team_defaults_to_zero',
    'adds_not_multiplies',
    'negative_team_delay_passes_through',
]


class C07RulesUnitActivationDelayTests(unittest.TestCase):
    def test_c07_rules_unit_activation_delay_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2466']['godot_owner'], 'SourceRulesRuntimeState.source_rules_unit_activation_delay_state')
        # Rules.unitActivationDelay(Team) (Rules.java:315-317):
        # the signature (:315) and the ADD formula (:316).
        # unitFactoryActivationDelay defaults to 0f both
        # globally (:93) and per team (:351, TeamRule).
        self.assertEqual(
            ledger['N2466']['java_method'],
            'Rules.unitActivationDelay(Team)',
        )
        self.assertEqual(
            ledger['N2466']['source_symbols'],
            [
                'source_rules_unit_activation_delay_state_input.rules_state',
                'source_rules_unit_activation_delay_state_input.team_id',
                'source_rules_unit_activation_delay_state_result.unit_activation_delay',
            ],
        )
        for name in ledger['N2466']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/Rules.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_unit_activation_delay_state'))
        self.assertEqual(ledger['N2466']['runtime_proof'], '/root/C07RulesUnitActivationDelayProof')
        self.assertEqual(
            ledger['N2466']['tests'],
            [
                'test_c07_rules_unit_activation_delay_registration',
                'test_all_c07_rules_unit_activation_delay_input_evidence_is_exact',
                'test_rules_unit_activation_delay_state',
                'test_reference_graph_and_actual_c07_rules_unit_activation_delay',
            ],
        )
        self.assertTrue(ledger['N2466']['deferred_exprs'])

    def test_all_c07_rules_unit_activation_delay_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2466']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_unit_activation_delay_state'))
        slice_sources = {
            'core/src/mindustry/game/Rules.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2466']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_rules_unit_activation_delay_state(self):
        rules_state = RULES_STATE.read_text(encoding='utf-8')
        # Rules.unitActivationDelay(Team) (Rules.java:315-317):
        #     return unitFactoryActivationDelay +
        #         teams.get(team).unitFactoryActivationDelay;
        # TRAP: this ADDS -- unlike the sibling Rules
        # multipliers (N2096 unitCost, N2462 unitDamage, N2464
        # unitBuildSpeed) which multiply, 2 + 3 is 5.0, not
        # 6.0. A port that copies the multiply pattern is
        # wrong. TRAP: there is no clamp here -- unlike N2459
        # unitHealth (Math.max), a negative team delay passes
        # through (5 + -2 = 3.0). unitFactoryActivationDelay
        # defaults to 0f both globally (:93) and per team
        # (:351), so a missing team means the Java fresh
        # TeamRule delay of 0.
        self.assertIn('static func source_rules_unit_activation_delay_state(rules_state: Dictionary, team_id: int) -> Dictionary:', rules_state)
        self.assertIn('return {"unit_activation_delay": global_delay + team_delay}', rules_state)
        # Function order follows Java order: isBanned()
        # (:307-309) comes before unitActivationDelay()
        # (:315-317), which comes before the TeamRule
        # accessor source_team_cheating_state in this file,
        # so source_rules_is_banned_state comes before
        # source_rules_unit_activation_delay_state, which
        # comes before source_team_cheating_state.
        self.assertLess(
            rules_state.index('static func source_rules_is_banned_state('),
            rules_state.index('static func source_rules_unit_activation_delay_state('),
        )
        self.assertLess(
            rules_state.index('static func source_rules_unit_activation_delay_state('),
            rules_state.index('static func source_team_cheating_state('),
        )
        # The proof drives the pure function with synthetic
        # rules dicts (no live tick, no game state): the
        # delays add (5 + 3 = 8, 2 + 3 = 5 not 6), both
        # defaults are 0, a missing team adds 0, and a
        # negative team delay passes through unclamped.
        proof = UNIT_ACTIVATION_DELAY_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_rules_unit_activation_delay(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RulesUnitActivationDelayProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RULES_UNIT_ACTIVATION_DELAY_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
