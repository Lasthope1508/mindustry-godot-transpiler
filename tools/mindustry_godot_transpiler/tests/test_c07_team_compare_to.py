import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
COMPARE_TO_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamCompareToProof.gd'

PROOF_KEYS = [
    'less_returns_minus_one',
    'greater_returns_one',
    'equal_returns_zero',
    'difference_is_not_returned',
    'negative_ids_compare_correctly',
]


class C07TeamCompareToTests(unittest.TestCase):
    def test_c07_team_compare_to_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2463']['godot_owner'], 'SourceTeamsRuntimeState.source_team_compare_to_state')
        # Team.compareTo(Team) (Team.java:159-162): the
        # signature (:160) and the Integer.compare call
        # (:161). The field `id` is `public final int`
        # (:18) and Team implements Comparable<Team>
        # (:16) -- the @Override (:159) marks this as the
        # Comparable implementation, not a helper. The
        # result is exactly -1, 0 or 1 -- never the
        # difference of the ids: 0 vs 255 is -1, not -255.
        self.assertEqual(
            ledger['N2463']['java_method'],
            'Team.compareTo(Team)',
        )
        self.assertEqual(
            ledger['N2463']['source_symbols'],
            [
                'source_team_compare_to_state_input.team_id',
                'source_team_compare_to_state_input.other_team_id',
                'source_team_compare_to_state_result.comparison',
            ],
        )
        for name in ledger['N2463']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/Team.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team_compare_to_state'))
        self.assertEqual(ledger['N2463']['runtime_proof'], '/root/C07TeamCompareToProof')
        self.assertEqual(
            ledger['N2463']['tests'],
            [
                'test_c07_team_compare_to_registration',
                'test_all_c07_team_compare_to_input_evidence_is_exact',
                'test_team_compare_to_state',
                'test_reference_graph_and_actual_c07_team_compare_to',
            ],
        )
        self.assertTrue(ledger['N2463']['deferred_exprs'])

    def test_all_c07_team_compare_to_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2463']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team_compare_to_state'))
        slice_sources = {
            'core/src/mindustry/game/Team.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2463']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_team_compare_to_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Team.compareTo(Team) (Team.java:159-162):
        #     @Override
        #     public int compareTo(Team team){
        #         return Integer.compare(id, team.id);
        #     }
        # TRAP: Integer.compare returns exactly -1, 0 or 1 --
        # never the difference of the ids: 0 vs 255 is -1,
        # not -255. A port that returns id - other_id is
        # wrong (and risks int overflow in Java). GDScript
        # ints are 64-bit signed, so the ternary comparison
        # below reproduces Integer.compare for every int,
        # including negatives. The function takes the two
        # team ids directly (Team.id is a plain int, :18) --
        # unlike source_team_get_state, it needs no
        # all_teams array.
        self.assertIn('static func source_team_compare_to_state(team_id: int, other_team_id: int) -> Dictionary:', teams)
        self.assertIn('return {"comparison": comparison}', teams)
        # Function order follows Java order: Team.get()
        # (:58-60) comes before compareTo() (:159-162) in
        # Team.java, so source_team_get_state comes before
        # source_team_compare_to_state in this file.
        self.assertLess(
            teams.index('static func source_team_get_state('),
            teams.index('static func source_team_compare_to_state('),
        )
        self.assertLess(
            teams.index('static func source_team_compare_to_state('),
            teams.index('static func source_team_state('),
        )
        # The proof drives the pure function with synthetic
        # ids (no live tick, no game state): less is -1,
        # greater is 1, equal is 0, 0 vs 255 is -1 (not
        # -255), and negative ids still compare correctly.
        proof = COMPARE_TO_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_team_compare_to(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamCompareToProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAM_COMPARE_TO_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
