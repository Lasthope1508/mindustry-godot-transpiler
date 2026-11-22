import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
TO_STRING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamsToStringProof.gd'


class C07TeamsToStringTests(unittest.TestCase):
    def test_c07_teams_to_string_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2412']['godot_owner'], 'SourceTeamsRuntimeState.source_teams_block_plan_to_string_state')
        # Teams BlockPlan.toString() + TeamData.toString()
        # (Teams.java:507-513 and :474-479), one merged slice
        # (main-thread decision 2026-11-22, batch 29 slot 2:
        # two debug-only toString methods, 9 exprs, the N1192
        # toString precedent). Both are pure functions that
        # concatenate their fields exactly as upstream Java
        # does; null prints as "null". The SSOT contract
        # return_type only accepts Dictionary or void, so
        # each function returns a one-key envelope
        # {"to_string": ...} (the N2365 envelope precedent)
        # instead of a bare String.
        self.assertEqual(
            ledger['N2412']['java_method'],
            'Teams.BlockPlan.toString()/TeamData.toString()',
        )
        self.assertEqual(
            ledger['N2412']['source_symbols'],
            [
                'source_teams_block_plan_to_string_state_result.to_string',
                'source_teams_team_data_to_string_state_result.to_string',
            ],
        )
        for name in ledger['N2412']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_'))
        self.assertEqual(ledger['N2412']['runtime_proof'], '/root/C07TeamsToStringProof')
        self.assertEqual(
            ledger['N2412']['tests'],
            [
                'test_c07_teams_to_string_registration',
                'test_all_c07_teams_to_string_input_evidence_is_exact',
                'test_teams_to_string_state',
                'test_reference_graph_and_actual_c07_teams_to_string',
            ],
        )
        self.assertTrue(ledger['N2412']['deferred_exprs'])

    def test_all_c07_teams_to_string_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2412']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_'))
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2412']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_to_string_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Teams.BlockPlan.toString() (Teams.java:507-513)
        # concatenates x/y/rotation/block/config after the
        # "BlockPlan{" prefix; TeamData.toString()
        # (Teams.java:474-479) concatenates cores/team after
        # the "TeamData{" prefix. Java prints null as
        # "null"; numbers print decimal. The `'}';` line is
        # part of the Java body shown in comments but is
        # NOT a registered expr (brief decision).
        self.assertIn('static func source_teams_block_plan_to_string_state(x: int, y: int, rotation: int, block: Variant, config: Variant) -> Dictionary:', teams)
        self.assertIn('static func source_teams_team_data_to_string_state(cores: Variant, team: Variant) -> Dictionary:', teams)
        for expr in [
            'return "BlockPlan{" +',
            '"x=" + x +',
            '", y=" + y +',
            '", rotation=" + rotation +',
            '", block=" + block +',
            '", config=" + config +',
            'return "TeamData{" +',
            '"cores=" + cores +',
            '", team=" + team +',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof's keys drive the pure functions with
        # synthetic inputs (no live tick): the happy paths
        # build the exact Java strings, null block/config/
        # cores/team print as "null", negative/short-range
        # values print decimal, and each envelope has
        # exactly one key.
        proof = TO_STRING_PROOF.read_text(encoding='utf-8')
        for key in [
            'block_plan_to_string_builds_exact_string',
            'block_plan_to_string_prints_null_as_null',
            'block_plan_to_string_returns_only_one_key',
            'team_data_to_string_builds_exact_string',
            'team_data_to_string_prints_null_as_null',
            'team_data_to_string_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_to_string(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamsToStringProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAMS_TO_STRING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'block_plan_to_string_builds_exact_string',
            'block_plan_to_string_prints_null_as_null',
            'block_plan_to_string_returns_only_one_key',
            'team_data_to_string_builds_exact_string',
            'team_data_to_string_prints_null_as_null',
            'team_data_to_string_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
