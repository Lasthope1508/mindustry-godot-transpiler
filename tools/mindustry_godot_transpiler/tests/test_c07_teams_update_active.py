import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
UPDATE_ACTIVE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamsUpdateActiveProof.gd'


class C07TeamsUpdateActiveTests(unittest.TestCase):
    def test_c07_teams_update_active_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2399']['godot_owner'], 'SourceTeamsRuntimeState.source_teams_update_active_state')
        # Teams.updateActive()+Teams() (Teams.java:135-141 + :34-36),
        # one grouped slice (main-thread decision 2026-11-22,
        # batch 24 slot 3: KEEP updateActive+ctor, do NOT
        # switch to destroyPayload -- destroyPayload is a
        # @Remote static, its C07 scope is undecided, decided
        # separately in a later batch; the N2380 seven-method /
        # N2374 five-accessor group precedent): two methods of
        # one active-list lifecycle -- the ctor seeds active
        # with crux, updateActive registers a team in active
        # when needed. Two GD functions, one ledger entry, one
        # owner per function (the N2380 multi-function
        # precedent; the N2378 lesson: a contract owner must
        # be an actual GD function, so the group label
        # `source_teams_update_active_group_state` is NOT an
        # owner -- the ledger godot_owner is the first
        # function owner, `source_teams_update_active_state`).
        # `if(data.active() && !active.contains(data)){` /
        # `active.add(data);` / `updateEnemies();` are already
        # owned by N2074/N2075 -- the guard / add / enemies
        # update ARE implemented here (the file's
        # _teams_active / _teams_update_enemies helpers are
        # those callees) but the exprs are cited as evidence
        # only, never re-registered. `destroyPayload()` is NOT
        # in this slice at all.
        self.assertEqual(
            ledger['N2399']['java_method'],
            'Teams.updateActive()/Teams()',
        )
        self.assertEqual(
            ledger['N2399']['source_symbols'],
            [
                'source_teams_update_active_state_result.active_changed',
                'source_teams_update_active_state_result.active',
                'source_teams_update_active_state_result.enemies_by_team',
                'source_teams_update_active_state_result.teams_state',
                'source_teams_default_constructor_state_result.team_data',
                'source_teams_default_constructor_state_result.active',
                'source_teams_default_constructor_state_result.teams_state',
            ],
        )
        for name in ledger['N2399']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_'))
        self.assertEqual(ledger['N2399']['runtime_proof'], '/root/C07TeamsUpdateActiveProof')
        self.assertEqual(
            ledger['N2399']['tests'],
            [
                'test_c07_teams_update_active_registration',
                'test_all_c07_teams_update_active_input_evidence_is_exact',
                'test_teams_update_active_state',
                'test_reference_graph_and_actual_c07_teams_update_active',
            ],
        )
        self.assertTrue(ledger['N2399']['deferred_exprs'])

    def test_all_c07_teams_update_active_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2399']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_'))
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2399']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_update_active_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Teams.updateActive (Teams.java:135-141): get the
        # team data, and when the team is active and not yet
        # in the active list, add it and refresh enemies.
        # Teams() (Teams.java:34-36): seed the active list
        # with the crux team.
        self.assertIn('static func source_teams_update_active_state(teams_state: Dictionary, team_id: int) -> Dictionary:', teams)
        self.assertIn('static func source_teams_default_constructor_state(teams_state: Dictionary, crux_team_id: int) -> Dictionary:', teams)
        for expr in [
            'TeamData data = get(team);',
            'active.add(get(Team.crux));',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof's keys drive the two pure functions with
        # synthetic inputs (no live tick, no packets): the
        # ctor seeds active with crux on a fresh state;
        # updateActive adds an active team once, skips a team
        # already active or an inactive team, creates a
        # missing team entry without adding it, refreshes the
        # enemies map on add, and keeps the wave team active
        # through updateEnemies; the frame records the active
        # list before and after.
        proof = UPDATE_ACTIVE_PROOF.read_text(encoding='utf-8')
        for key in [
            'ctor_seeds_crux_active',
            'ctor_returns_only_three_keys',
            'update_active_adds_active_team',
            'update_active_skips_already_active',
            'update_active_skips_inactive_team',
            'update_active_creates_missing_team',
            'update_active_updates_enemies',
            'update_active_enemies_keeps_wave_team_active',
            'update_active_frame_active_before_after',
            'update_active_returns_only_four_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_update_active(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamsUpdateActiveProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAMS_UPDATE_ACTIVE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ctor_seeds_crux_active',
            'ctor_returns_only_three_keys',
            'update_active_adds_active_team',
            'update_active_skips_already_active',
            'update_active_skips_inactive_team',
            'update_active_creates_missing_team',
            'update_active_updates_enemies',
            'update_active_enemies_keeps_wave_team_active',
            'update_active_frame_active_before_after',
            'update_active_returns_only_four_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
