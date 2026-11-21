import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
TEAMS_LOOKUP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamsLookupProof.gd'


class C07TeamsLookupTests(unittest.TestCase):
    def test_c07_teams_lookup_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2380']['godot_owner'], 'SourceTeamsRuntimeState.source_teams_get_state')
        # Teams.get()+getOrNull()+playerCores()+cores()+
        # isActive()+canInteract()+getActive()
        # (Teams.java:97-133), one grouped slice (main-thread
        # decision 2026-11-21, the N2374 five-accessor / N2330
        # three-method group precedent): seven one-to-three-line
        # lookup methods sharing the one lookup core
        # (`map[team.id]` + `get(team)`). Seven GD functions,
        # one ledger entry, one owner per function (the N2330
        # multi-function precedent; the N2378 lesson: a
        # contract owner must be an actual GD function, so the
        # group label `source_teams_lookup_state` is NOT an
        # owner -- the ledger godot_owner is the first
        # function owner, `source_teams_get_state`).
        # `TeamData.active()` in isActive()/getActive() is
        # already the exact_expr of N2074/N2075 -- the file's
        # `_teams_active` helper is that callee, called as
        # evidence only. `new TeamData(team)` creates the empty
        # TeamData dict shape `_teams_data` already builds.
        # `get()` called by playerCores/cores/isActive INSIDE
        # the group is an internal self-reference, not an
        # outside expr. `state.rules.defaultTeam` /
        # `Team.derelict` arrive as explicit params.
        # `map` is teams_state["teams"]; get() WRITES it when
        # the team is missing; getOrNull() only READS it;
        # getActive() WRITES teams_state["active"].
        # Thirteen new result symbols.
        self.assertEqual(
            ledger['N2380']['java_method'],
            'Teams.get(Team)/Teams.getOrNull(Team)/Teams.playerCores()/Teams.cores(Team)/Teams.isActive(Team)/Teams.canInteract(Team, Team)/Teams.getActive()',
        )
        self.assertEqual(
            ledger['N2380']['source_symbols'],
            [
                'source_teams_get_state_result.team_data',
                'source_teams_get_state_result.created',
                'source_teams_get_state_result.teams_state',
                'source_teams_get_or_null_state_result.team_data',
                'source_teams_player_cores_state_result.cores',
                'source_teams_player_cores_state_result.teams_state',
                'source_teams_cores_state_result.cores',
                'source_teams_cores_state_result.teams_state',
                'source_teams_is_active_state_result.is_active',
                'source_teams_is_active_state_result.teams_state',
                'source_teams_can_interact_state_result.can_interact',
                'source_teams_get_active_state_result.active',
                'source_teams_get_active_state_result.teams_state',
            ],
        )
        for name in ledger['N2380']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_'))
        self.assertEqual(ledger['N2380']['runtime_proof'], '/root/C07TeamsLookupProof')
        self.assertEqual(
            ledger['N2380']['tests'],
            [
                'test_c07_teams_lookup_registration',
                'test_all_c07_teams_lookup_input_evidence_is_exact',
                'test_teams_lookup_state',
                'test_reference_graph_and_actual_c07_teams_lookup',
            ],
        )
        self.assertTrue(ledger['N2380']['deferred_exprs'])

    def test_all_c07_teams_lookup_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2380']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_'))
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2380']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_lookup_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Teams.get()+getOrNull()+playerCores()+cores()+
        # isActive()+canInteract()+getActive()
        # (Teams.java:97-133): get returns the existing
        # TeamData or creates + stores a new empty one; getOrNull
        # returns the entry or null and never creates;
        # playerCores/cores return get(...).cores; isActive is
        # get(team).active() via the _teams_active callee; 
        # canInteract is `team == other || other == derelict`;
        # getActive prunes inactive teams from active and
        # returns it.
        self.assertIn('static func source_teams_get_state(teams_state: Dictionary, team_id: int) -> Dictionary:', teams)
        self.assertIn('static func source_teams_get_or_null_state(teams_state: Dictionary, team_id: int) -> Dictionary:', teams)
        self.assertIn('static func source_teams_player_cores_state(teams_state: Dictionary, default_team_id: int) -> Dictionary:', teams)
        self.assertIn('static func source_teams_cores_state(teams_state: Dictionary, team_id: int) -> Dictionary:', teams)
        self.assertIn('static func source_teams_is_active_state(teams_state: Dictionary, team_id: int) -> Dictionary:', teams)
        self.assertIn('static func source_teams_can_interact_state(team_id: int, other_team_id: int, derelict_team_id: int) -> Dictionary:', teams)
        self.assertIn('static func source_teams_get_active_state(teams_state: Dictionary) -> Dictionary:', teams)
        for expr in [
            'public class Teams{',
            'public TeamData get(Team team){',
            'var data = map[team.id];',
            'if(data != null){',
            'return data;',
            'return map[team.id] = new TeamData(team);',
            'public @Nullable TeamData getOrNull(Team team){',
            'return map[team.id];',
            'public Seq<CoreBuild> playerCores(){',
            'return get(state.rules.defaultTeam).cores;',
            'public Seq<CoreBuild> cores(Team team){',
            'return get(team).cores;',
            'public boolean isActive(Team team){',
            'return get(team).active();',
            'public boolean canInteract(Team team, Team other){',
            'return team == other || other == Team.derelict;',
            'public Seq<TeamData> getActive(){',
            'active.removeAll(t -> !t.active());',
            'return active;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof's keys drive the seven pure functions with
        # synthetic teams_state dicts (no live tick): get
        # creates a missing team / returns the existing one;
        # getOrNull returns the existing one / null when missing
        # / never creates an entry; playerCores returns the
        # default team's cores; cores returns the team's cores;
        # isActive is true with cores / false when empty / true
        # for the wave team; canInteract is true for the same
        # team / true when the other team is derelict / false
        # for other teams; getActive removes inactive teams /
        # keeps the wave team; get returns only its three keys.
        proof = TEAMS_LOOKUP_PROOF.read_text(encoding='utf-8')
        for key in [
            'get_creates_missing_team_data',
            'get_returns_existing_team_data',
            'get_or_null_returns_existing',
            'get_or_null_null_when_missing',
            'get_or_null_does_not_create_entry',
            'player_cores_default_team_cores',
            'cores_returns_team_cores',
            'is_active_true_with_cores',
            'is_active_false_when_empty',
            'is_active_true_for_wave_team',
            'can_interact_same_team',
            'can_interact_derelict_other',
            'can_interact_false_for_other_teams',
            'get_active_removes_inactive_teams',
            'get_active_keeps_wave_team',
            'get_returns_only_three_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_lookup(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamsLookupProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAMS_LOOKUP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'get_creates_missing_team_data',
            'get_returns_existing_team_data',
            'get_or_null_returns_existing',
            'get_or_null_null_when_missing',
            'get_or_null_does_not_create_entry',
            'player_cores_default_team_cores',
            'cores_returns_team_cores',
            'is_active_true_with_cores',
            'is_active_false_when_empty',
            'is_active_true_for_wave_team',
            'can_interact_same_team',
            'can_interact_derelict_other',
            'can_interact_false_for_other_teams',
            'get_active_removes_inactive_teams',
            'get_active_keeps_wave_team',
            'get_returns_only_three_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
