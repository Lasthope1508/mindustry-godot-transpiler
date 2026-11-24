import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RULES_STATE = ROOT / 'godot-mindustry/src/game/SourceRulesRuntimeState.gd'
MODE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RulesModeProof.gd'

PROOF_KEYS = [
    'all_flags_false_returns_survival',
    'pvp_beats_all_flags',
    'editor_beats_attack_and_sandbox',
    'attack_beats_sandbox',
    'sandbox_only',
    'missing_keys_default_survival',
]


class C07RulesModeTests(unittest.TestCase):
    def test_c07_rules_mode_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2458']['godot_owner'], 'SourceRulesRuntimeState.source_rules_mode_state')
        # Rules.mode() (Rules.java:249-261): the signature (:249)
        # and the 5 branches -- pvp > editor > attackMode >
        # infiniteResources > survival (default). The enum is
        # returned as its String name (precedent N2454: GameState
        # `state` travels as `state_name`). Gamemode.apply
        # (Gamemode.java, mutating presets) is NOT part of this
        # slice.
        self.assertEqual(
            ledger['N2458']['java_method'],
            'Rules.mode()',
        )
        self.assertEqual(
            ledger['N2458']['source_symbols'],
            [
                'source_rules_mode_state_input.rules_state',
                'source_rules_mode_state_result.mode',
            ],
        )
        for name in ledger['N2458']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/Rules.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_mode_state'))
        self.assertEqual(ledger['N2458']['runtime_proof'], '/root/C07RulesModeProof')
        self.assertEqual(
            ledger['N2458']['tests'],
            [
                'test_c07_rules_mode_registration',
                'test_all_c07_rules_mode_input_evidence_is_exact',
                'test_rules_mode_state',
                'test_reference_graph_and_actual_c07_rules_mode',
            ],
        )
        self.assertTrue(ledger['N2458']['deferred_exprs'])

    def test_all_c07_rules_mode_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2458']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_rules_mode_state'))
        slice_sources = {
            'core/src/mindustry/game/Rules.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2458']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_rules_mode_state(self):
        rules_state = RULES_STATE.read_text(encoding='utf-8')
        # Rules.mode() (Rules.java:249-261): the 5 branches in
        # Java order -- pvp first, survival last. The enum is
        # returned as its String name. TRAP: the priority order
        # is the whole slice -- pvp=true wins even when editor,
        # attackMode and infiniteResources are all true too, so
        # the branches must be checked in Java order and must not
        # be reordered (checking infiniteResources first would
        # return "sandbox" for an attack game). A missing flag
        # means the Java field default (false): all four booleans
        # default to false (pvp :41, editor :51, attackMode :49,
        # infiniteResources :27), so an empty rules state is
        # survival.
        self.assertIn('static func source_rules_mode_state(rules_state: Dictionary) -> Dictionary:', rules_state)
        self.assertIn('return {"mode": "pvp"}', rules_state)
        self.assertIn('return {"mode": "editor"}', rules_state)
        self.assertIn('return {"mode": "attack"}', rules_state)
        self.assertIn('return {"mode": "sandbox"}', rules_state)
        self.assertIn('return {"mode": "survival"}', rules_state)
        # Function order follows Java order: mode() (:249-261)
        # comes before unitCost() (:275-276) in Rules.java, so
        # source_rules_mode_state comes before
        # source_unit_cost_state in this file.
        self.assertLess(
            rules_state.index('static func source_rules_mode_state('),
            rules_state.index('static func source_unit_cost_state('),
        )
        # The proof drives the pure function with synthetic rules
        # dicts (no live tick, no game state): all flags false is
        # survival, pvp beats every other flag, editor beats
        # attack and sandbox, attack beats sandbox, only
        # infiniteResources is sandbox, and a rules state with no
        # flags at all defaults to survival.
        proof = MODE_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_rules_mode(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RulesModeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RULES_MODE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
