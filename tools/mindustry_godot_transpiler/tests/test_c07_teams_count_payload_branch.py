import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
COUNT_PAYLOAD_BRANCH_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamsCountPayloadBranchProof.gd'

EXACT_EXPRS = [
    'if(unit instanceof Payloadc payloadc){',
    'var payloads = payloadc.payloads();',
    'for(int i = 0; i < payloads.size; i++){',
    'if(payloads.get(i) instanceof UnitPayload payload){',
]

PROOF_KEYS = [
    'payload_branch_counts_unit_payload_units',
    'payload_branch_skips_non_unit_payloads',
    'payload_branch_counts_nested_payload_units',
    'payload_branch_skips_other_team_payload_units',
    'payload_branch_empty_payloads_changes_nothing',
    'payload_branch_returns_expected_keys',
]


class C07TeamsCountPayloadBranchTests(unittest.TestCase):
    def test_c07_teams_count_payload_branch_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2415']['godot_owner'], 'SourceTeamsRuntimeState.source_teams_count_payload_branch_state')
        # Teams.count() payload branch (Teams.java:168-179),
        # one sub-slice (batch 30 slot 2, the N2408
        # sub-slice precedent): the method body is already
        # owned in large part by N2141 (the signature, the
        # updateCount call, the count(payload.unit)
        # recursion), so only the 4 payload-branch exprs
        # are registered here. The branch is ported as one
        # pure function taking payloads as an explicit Array
        # param (the N2408 precedent: live queries become
        # params); the recursion reaches count() through
        # the _team_data_count_unit helper (call-site,
        # N2383), which is the N2141 callee.
        self.assertEqual(
            ledger['N2415']['java_method'],
            'Teams.count(Unit)',
        )
        self.assertEqual(
            ledger['N2415']['source_symbols'],
            [
                'source_teams_count_payload_branch_state_result.type_counts',
                'source_teams_count_payload_branch_state_result.unit_count',
                'source_teams_count_payload_branch_state_result.team_unit_counts',
            ],
        )
        for name in ledger['N2415']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_count_payload_branch_state'))
        self.assertEqual(ledger['N2415']['runtime_proof'], '/root/C07TeamsCountPayloadBranchProof')
        self.assertEqual(
            ledger['N2415']['tests'],
            [
                'test_c07_teams_count_payload_branch_registration',
                'test_all_c07_teams_count_payload_branch_input_evidence_is_exact',
                'test_teams_count_payload_branch_state',
                'test_reference_graph_and_actual_c07_teams_count_payload_branch',
            ],
        )
        self.assertTrue(ledger['N2415']['deferred_exprs'])

    def test_all_c07_teams_count_payload_branch_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2415']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_count_payload_branch_state'))
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2415']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_count_payload_branch_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Teams.count (Teams.java:168-179), the payload
        # branch only: the Payloadc gate, the payloads()
        # Seq, the index loop, and the UnitPayload gate;
        # count(payload.unit) is the N2141 recursion,
        # reached here through the _team_data_count_unit
        # helper (call-site, not re-registered).
        self.assertIn('static func source_teams_count_payload_branch_state(payloads: Array, team_id: int, type_counts: Array, unit_count: int, content_unit_size: int, team_unit_counts: Dictionary) -> Dictionary:', teams)
        for expr in EXACT_EXPRS:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof drives the pure function with synthetic
        # payload Arrays (no live tick): a UnitPayload unit
        # is counted into its type count, unitCount and the
        # name-keyed counts; non-unit payloads (a raw
        # Variant, a block record with no type_id) are
        # skipped; nested payload units recurse through the
        # helper; a payload unit of another team is skipped
        # (the single-team frame view, same as the N2383
        # helper); empty payloads change nothing; the
        # result carries exactly the four expected keys in
        # order.
        proof = COUNT_PAYLOAD_BRANCH_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_count_payload_branch(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamsCountPayloadBranchProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAMS_COUNT_PAYLOAD_BRANCH_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
