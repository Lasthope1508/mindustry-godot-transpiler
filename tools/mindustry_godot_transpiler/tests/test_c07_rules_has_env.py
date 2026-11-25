import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RULES_STATE = ROOT / 'godot-mindustry/src/game/SourceRulesRuntimeState.gd'
HAS_ENV_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RulesHasEnvProof.gd'

PROOF_KEYS = [
    'default_has_terrestrial',
    'default_has_spores',
    'default_lacks_space',
    'zero_flag_always_false',
    'any_overlap_not_all_bits',
    'custom_env_exact',
    'combined_flag_both_present',
    'missing_env_key_defaults',
]


class C07RulesHasEnvTests(unittest.TestCase):
    def test_c07_rules_has_env_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2467']['godot_owner'], 'SourceRulesRuntimeState.source_rules_has_env_state')
        # Rules.hasEnv(int) (Rules.java:263-265): the
        # signature (:263) and the ANY-overlap formula
        # (:264). The env field defaults to Vars.defaultEnv
        # (Rules.java:163; Vars.java:65), which is 233.
        self.assertEqual(
            ledger['N2467']['java_method'],
            'Rules.hasEnv(int)',
        )
        self.assertEqual(
            ledger['N2467']['source_symbols'],
            [
                'source_rules_has_env_state_input.rules_state',
                'source_rules_has_env_state_input.env_flag',
                'source_rules_has_env_state_result.has_env',
            ],
        )
        for name in ledger['N2467']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/Rules.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_has_env_state'))
        self.assertEqual(ledger['N2467']['runtime_proof'], '/root/C07RulesHasEnvProof')
        self.assertEqual(
            ledger['N2467']['tests'],
            [
                'test_c07_rules_has_env_registration',
                'test_all_c07_rules_has_env_input_evidence_is_exact',
                'test_rules_has_env_state',
                'test_reference_graph_and_actual_c07_rules_has_env',
            ],
        )
        self.assertTrue(ledger['N2467']['deferred_exprs'])

    def test_all_c07_rules_has_env_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2467']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_has_env_state'))
        slice_sources = {
            'core/src/mindustry/game/Rules.java',
            'core/src/mindustry/Vars.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2467']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_rules_has_env_state(self):
        rules_state = RULES_STATE.read_text(encoding='utf-8')
        # Rules.hasEnv(int) (Rules.java:263-265):
        #     return (this.env & env) != 0;
        # TRAP: this is an ANY-overlap check, not ALL-bits
        # -- a combined flag is true when ANY of its bits
        # is set (flag 2|8=10 is true on the default env
        # 233 because spores=8 is set, even though space=2
        # is not). A port that checks (env & flag) == flag
        # is wrong. TRAP: flag 0 is always false -- 0 &
        # anything is 0. The env field defaults to
        # Vars.defaultEnv (Rules.java:163; Vars.java:65) =
        # terrestrial|spores|groundOil|groundWater|oxygen
        # = 1|8|32|64|128 = 233, so a missing "env" key
        # means 233.
        self.assertIn('static func source_rules_has_env_state(rules_state: Dictionary, env_flag: int) -> Dictionary:', rules_state)
        self.assertIn('return {"has_env": (env & env_flag) != 0}', rules_state)
        # Function order follows Java order: mode()
        # (:249-261) comes before hasEnv() (:263-265),
        # which comes before buildRadius() (:267-269),
        # so source_rules_mode_state comes before
        # source_rules_has_env_state, which comes before
        # source_rules_build_radius_state.
        self.assertLess(
            rules_state.index('static func source_rules_mode_state('),
            rules_state.index('static func source_rules_has_env_state('),
        )
        self.assertLess(
            rules_state.index('static func source_rules_has_env_state('),
            rules_state.index('static func source_rules_build_radius_state('),
        )
        # The proof drives the pure function with synthetic
        # rules dicts (no live tick, no game state): the
        # default env 233 has terrestrial and spores but
        # not space, flag 0 is always false, a combined
        # flag needs only one overlapping bit, a custom
        # env matches exactly its own bits, and a missing
        # env key falls back to 233.
        proof = HAS_ENV_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_rules_has_env(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RulesHasEnvProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RULES_HAS_ENV_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
