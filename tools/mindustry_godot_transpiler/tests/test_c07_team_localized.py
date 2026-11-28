import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
LOCALIZED_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamLocalizedProof.gd'

PROOF_KEYS = [
    'localized_bundle_hit',
    'localized_bundle_missing_falls_back_to_name',
    'localized_empty_bundle_value_is_not_missing',
    'localized_custom_bundle_value_verbatim',
    'localized_missing_with_dotted_name',
    'localized_hit_with_unicode_value',
    'localized_idempotent',
    'localized_returns_only_one_key',
]


class C07TeamLocalizedTests(unittest.TestCase):
    def test_c07_team_localized_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2494']['godot_owner'], 'SourceTeamsRuntimeState.source_team_localized_state')
        # Team.localized() (Team.java:135-137):
        #     public String localized(){
        #         return Core.bundle.get("team." + name + ".name", name);
        #     }
        # Core.bundle.get(key, def) is I18NBundle.get
        # (arc-core I18NBundle.java:412-414): has(key) ?
        # get(key) : def -- for the key "team." + name +
        # ".name". Core.bundle is NOT ported here, so the
        # raw lookup result arrives as the precomputed
        # bundle_value input (the getOrNull-equivalent:
        # null when the key is absent; N1271
        # ability_localized.bundle_get precedent), and the
        # GD function falls back to the name only on a
        # missing key. TWIN-REGISTER (main-thread approval
        # 2026-11-28 ~11:40, N2474 precedent): the body
        # literal is already an exact_expr of N2488
        # (Team.coloredName quotes localized() as
        # dependency evidence and defers it for its own
        # slice) -- N2488 is the original owner of the
        # shared literal, this slice ports localized()
        # as its own GD function.
        self.assertEqual(
            ledger['N2494']['java_method'],
            'Team.localized()',
        )
        self.assertEqual(
            ledger['N2494']['source_symbols'],
            [
                'source_team_localized_state_input.name',
                'source_team_localized_state_input.bundle_value',
                'source_team_localized_state_result.localized',
            ],
        )
        for name in ledger['N2494']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/Team.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team_localized_state'))
        self.assertEqual(ledger['N2494']['runtime_proof'], '/root/C07TeamLocalizedProof')
        self.assertEqual(
            ledger['N2494']['tests'],
            [
                'test_c07_team_localized_registration',
                'test_all_c07_team_localized_input_evidence_is_exact',
                'test_team_localized_state',
                'test_reference_graph_and_actual_c07_team_localized',
            ],
        )
        self.assertTrue(ledger['N2494']['deferred_exprs'])

    def test_all_c07_team_localized_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2494']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team_localized_state'))
        slice_sources = {
            'core/src/mindustry/game/Team.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2494']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_team_localized_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Team.localized() (Team.java:135-137) is a bundle
        # lookup with a fallback: Core.bundle.get("team."
        # + name + ".name", name) -- I18NBundle.get(key,
        # def) returns the bundle value when the key
        # exists, else the default (the name). The bundle
        # itself is not ported, so the raw lookup result
        # arrives as the precomputed bundle_value input
        # (null when the key is absent) and the GD
        # function falls back to name only then. TRAP: an
        # empty bundle value is a real value, not a miss
        # -- it passes through, never replaced by name.
        self.assertIn('static func source_team_localized_state(name: String, bundle_value: Variant) -> Dictionary:', teams)
        self.assertIn('"team." + name + ".name"', teams)
        self.assertIn('return {"localized": localized}', teams)
        # Function order follows Java order: Team.get()
        # (:58-60) comes before localized() (:135-137),
        # which comes before coloredName() (:139-141), so
        # source_team_localized_state sits between
        # source_team_get_state and
        # source_team_colored_name_state in this file.
        self.assertLess(
            teams.index('static func source_team_get_state('),
            teams.index('static func source_team_localized_state('),
        )
        self.assertLess(
            teams.index('static func source_team_localized_state('),
            teams.index('static func source_team_colored_name_state('),
        )
        # The proof drives the pure function with synthetic
        # inputs (no live tick, no game state): a bundle
        # hit, a missing key falling back to the name, an
        # empty bundle value passing through, a custom
        # bundle value used verbatim, a dotted name
        # falling back verbatim, a non-ASCII bundle value,
        # idempotence, and exactly one result key.
        proof = LOCALIZED_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_team_localized(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamLocalizedProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAM_LOCALIZED_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
