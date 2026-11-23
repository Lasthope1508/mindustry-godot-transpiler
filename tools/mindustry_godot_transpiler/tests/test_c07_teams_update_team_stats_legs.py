import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
UPDATE_TEAM_STATS_LEGS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamsUpdateTeamStatsLegsProof.gd'

PROOF_KEYS = [
    'team_data_lookup_resets_each_team',
    'team_data_lookup_creates_missing_team',
    'tree_insert_appends_unit',
    'tree_insert_creates_tree_when_absent',
    'tree_insert_clears_stale_first',
    'presence_loop_reads_team_data',
]


class C07TeamsUpdateTeamStatsLegsTests(unittest.TestCase):
    def test_c07_teams_update_team_stats_legs_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2430']['godot_owner'], 'SourceTeamsRuntimeState.source_teams_update_team_stats_state')
        # Teams.updateTeamStats() (Teams.java:181-251): the 2
        # leftover legs N2383 did not register --
        # `TeamData data = team.data();` (:186 + :244, the
        # per-team lookup, registered ONCE despite the two
        # positions) and `data.tree().insert(unit);`
        # (:217, the unit-tree insert). The GD function
        # already exists (N2383): this slice extends it --
        # it adds no new owner, no new contract and no new
        # schema (the N2425 precedent: a leg-slice in an
        # already-owned method; same shape as N2427).
        # `TeamData data = unit.team.data();` (:215) is a
        # DIFFERENT expr (variable `unit.team`, already
        # owned at N2383) -- the two are registered
        # separately. `data.presentFlag =
        # data.buildings.size > 0;` / `data.units.add(unit);`
        # / `data.unitsByType[unit.type.id].add(unit);` /
        # `count(unit);` stay owned at N2383/N2141.
        self.assertEqual(
            ledger['N2430']['java_method'],
            'Teams.updateTeamStats()',
        )
        self.assertEqual(
            ledger['N2430']['exact_exprs'],
            [
                'TeamData data = team.data();',
                'data.tree().insert(unit);',
            ],
        )
        self.assertEqual(
            ledger['N2430']['source_symbols'],
            [
                'source_teams_update_team_stats_state_result.teams_state',
                'source_teams_update_team_stats_state_result.present',
                'source_teams_update_team_stats_state_result.bosses',
                'source_teams_update_team_stats_state_result.unit_counts_by_team',
            ],
        )
        for name in ledger['N2430']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_update_team_stats_state'))
        self.assertEqual(ledger['N2430']['runtime_proof'], '/root/C07TeamsUpdateTeamStatsLegsProof')
        self.assertEqual(
            ledger['N2430']['tests'],
            [
                'test_c07_teams_update_team_stats_legs_registration',
                'test_all_c07_teams_update_team_stats_legs_input_evidence_is_exact',
                'test_teams_update_team_stats_legs_state',
                'test_reference_graph_and_actual_c07_teams_update_team_stats_legs',
            ],
        )
        self.assertTrue(ledger['N2430']['deferred_exprs'])

    def test_all_c07_teams_update_team_stats_legs_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2430']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_update_team_stats_state'))
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2430']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_update_team_stats_legs_state(self):
        state = TEAMS_STATE.read_text(encoding='utf-8')
        # The GD function already exists (N2383); N2430
        # registers the 2 leftover legs it already
        # implements -- the per-team `team.data()` lookup
        # (reset loop :186 + presence loop :244, each
        # team's dict read from teams_state["teams"], a
        # missing entry created via `_teams_data` exactly
        # as Java `team.data()` creates it) and the
        # `data.tree().insert(unit)` (the unit appended to
        # its team's unit_tree {"inserted": [...]} list,
        # created lazily when the team had none, cleared
        # first by the reset). Each leg is quoted verbatim
        # on its own comment line (the N2378 precedent:
        # never split an exact expr across lines).
        self.assertIn('static func source_teams_update_team_stats_state(teams_state: Dictionary, units: Array, players: Array, wave_team_id: int, content_unit_size: int, present: Array, bosses: Array) -> Dictionary:', state)
        for expr in [
            'TeamData data = team.data();',
            'data.tree().insert(unit);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive one leg each: the reset
        # loop's lookup returns each team's own dict (a
        # team's stale units are cleared, its present_flag
        # comes from its buildings); a unit of a team with
        # no entry creates it via the lookup; every unit
        # lands in its own team's tree insert list; the
        # tree is created lazily when absent; the stale
        # inserts are cleared first; the presence loop's
        # lookup reads each team's data to rebuild present.
        proof = UPDATE_TEAM_STATS_LEGS_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_update_team_stats_legs(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamsUpdateTeamStatsLegsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAMS_UPDATE_TEAM_STATS_LEGS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
