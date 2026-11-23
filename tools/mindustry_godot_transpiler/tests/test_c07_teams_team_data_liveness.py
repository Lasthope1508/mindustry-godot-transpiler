import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
TEAM_DATA_LIVENESS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamDataLivenessProof.gd'


class C07TeamsTeamDataLivenessTests(unittest.TestCase):
    def test_c07_teams_team_data_liveness_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2374']['godot_owner'], 'SourceTeamsRuntimeState.source_team_data_liveness_state')
        # TeamData.hasCore()+isAlive()+noCores()+core()+hasAI()
        # (Teams.java:450-472), one grouped slice (main-thread
        # decision 2026-11-21, N2326/N2297 group precedent):
        # `public boolean hasCore(){`
        # `return cores.size > 0;`
        # `public boolean isAlive(){`
        # `return hasCore();`
        # `public boolean noCores(){`
        # `return cores.isEmpty();`
        # `@Nullable`
        # `public CoreBuild core(){`
        # `return cores.isEmpty() ? null : cores.first();`
        # `public boolean hasAI(){`
        # `return team.rules().rtsAi || team.rules().buildAi;`
        # isAlive() delegates to hasCore() -- that delegate is
        # inside this same group, not an outside dedup.
        # active() (Teams.java:446-448) is EXCLUDED: its only
        # line is already the exact_expr of N2074+N2075.
        # cores arrives as an explicit Array of opaque core refs
        # (the N2330 param precedent); team.rules() arrives as
        # the explicit team_rules dict {rts_ai, build_ai}
        # because Rules is not ported. NO driver line: five
        # pure one-line accessors the tick reads, not a
        # per-tick write.
        # Five new result symbols: has_core, is_alive,
        # no_cores, core, has_ai.
        self.assertEqual(
            ledger['N2374']['java_method'],
            'TeamData.hasCore()/isAlive()/noCores()/core()/hasAI()',
        )
        self.assertEqual(
            ledger['N2374']['source_symbols'],
            [
                'source_team_data_liveness_state_result.has_core',
                'source_team_data_liveness_state_result.is_alive',
                'source_team_data_liveness_state_result.no_cores',
                'source_team_data_liveness_state_result.core',
                'source_team_data_liveness_state_result.has_ai',
            ],
        )
        for name in ledger['N2374']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTeamsRuntimeState.source_team_data_liveness_state')
        self.assertEqual(ledger['N2374']['runtime_proof'], '/root/C07TeamDataLivenessProof')
        self.assertEqual(
            ledger['N2374']['tests'],
            [
                'test_c07_teams_team_data_liveness_registration',
                'test_all_c07_teams_team_data_liveness_input_evidence_is_exact',
                'test_teams_team_data_liveness_state',
                'test_reference_graph_and_actual_c07_teams_team_data_liveness',
            ],
        )
        self.assertTrue(ledger['N2374']['deferred_exprs'])

    def test_all_c07_teams_team_data_liveness_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2374']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTeamsRuntimeState.source_team_data_liveness_state')
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2374']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_team_data_liveness_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # TeamData.hasCore()+isAlive()+noCores()+core()+hasAI()
        # (Teams.java:450-472): hasCore is `cores.size > 0`;
        # isAlive delegates to hasCore; noCores is
        # `cores.isEmpty()`; core is the first core or null;
        # hasAI is `team.rules().rtsAi || team.rules().buildAi`.
        # active() (Teams.java:446-448) is NOT ported here --
        # its only line is already the exact_expr of
        # N2074+N2075.
        self.assertIn('static func source_team_data_liveness_state(cores: Array, team_rules: Dictionary) -> Dictionary:', teams)
        self.assertIn('return {"has_core": has_core, "is_alive": has_core, "no_cores": cores.is_empty(), "core": first_core, "has_ai": has_ai}', teams)
        for expr in [
            'public class Teams{',
            'public boolean hasCore(){',
            'return cores.size > 0;',
            'public boolean isAlive(){',
            'return hasCore();',
            'public boolean noCores(){',
            'return cores.isEmpty();',
            '@Nullable',
            'public CoreBuild core(){',
            'return cores.isEmpty() ? null : cores.first();',
            'public boolean hasAI(){',
            'return team.rules().rtsAi || team.rules().buildAi;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof's keys drive the pure function with synthetic
        # cores Arrays and team_rules dicts (no live tick):
        # hasCore true with cores / false when empty / isAlive
        # delegates to hasCore / noCores is the inverse of
        # hasCore / core is the first core when present / null
        # when empty / hasAI true on rtsAi / true on buildAi /
        # false when neither / the result carries only its
        # five keys.
        proof = TEAM_DATA_LIVENESS_PROOF.read_text(encoding='utf-8')
        for key in [
            'has_core_true_with_cores',
            'has_core_false_when_empty',
            'is_alive_delegates_has_core',
            'no_cores_inverse_of_has_core',
            'core_first_when_present',
            'core_null_when_empty',
            'has_ai_rts_ai',
            'has_ai_build_ai',
            'has_ai_false_when_neither',
            'returns_only_five_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_team_data_liveness(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamDataLivenessProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAM_DATA_LIVENESS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'has_core_true_with_cores',
            'has_core_false_when_empty',
            'is_alive_delegates_has_core',
            'no_cores_inverse_of_has_core',
            'core_first_when_present',
            'core_null_when_empty',
            'has_ai_rts_ai',
            'has_ai_build_ai',
            'has_ai_false_when_neither',
            'returns_only_five_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
