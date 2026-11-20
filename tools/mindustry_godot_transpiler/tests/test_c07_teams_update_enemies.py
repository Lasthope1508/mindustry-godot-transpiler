import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
TEAMS_UPDATE_ENEMIES_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamsUpdateEnemiesProof.gd'


class C07TeamsUpdateEnemiesTests(unittest.TestCase):
    def test_c07_teams_update_enemies_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2357']['godot_owner'], 'SourceTeamsRuntimeState.source_teams_update_enemies_state')
        # Teams.updateEnemies() (Teams.java:252-268):
        # `private void updateEnemies(){`
        # `if(state.rules.waves && !active.contains(get(state.rules.waveTeam))){`
        # `active.add(get(state.rules.waveTeam));`
        # `for(TeamData data : active){`
        # `Seq<Team> enemies = new Seq<>();`
        # `for(TeamData other : active){`
        # `if(data.team != other.team){`
        # `enemies.add(other.team);`
        # `}`
        # `}`
        # `data.coreEnemies = enemies.toArray(Team.class);`
        # `}`
        # `}`
        # on `public class Teams{` (Teams.java:24). The wave
        # team is added to active when waves are enabled
        # and it is not active yet; then every active
        # team's coreEnemies is rewritten to the other
        # active teams (the team itself excluded). The
        # wave-team guard reads state.rules.waves /
        # state.rules.waveTeam -- Rules state is NOT
        # ported, so both arrive as explicit params
        # (waves_enabled, wave_team_id; the N2330 param
        # precedent). Team comparison is by team_id, not
        # the Team enum. core_enemies already lives in
        # the teams_state dict (kept by N2074/N2075);
        # this slice REWRITES that field. The call-site
        # `updateEnemies();` already owned by N2074/N2075
        # (registerCore/unregisterCore call it) is callee
        # evidence only, not this method's body. Two new
        # result symbols: teams_state, wave_team_added.
        self.assertEqual(
            ledger['N2357']['source_symbols'],
            [
                'source_teams_update_enemies_state_result.teams_state',
                'source_teams_update_enemies_state_result.wave_team_added',
            ],
        )
        for name in ledger['N2357']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTeamsRuntimeState.source_teams_update_enemies_state')
        self.assertEqual(ledger['N2357']['runtime_proof'], '/root/C07TeamsUpdateEnemiesProof')
        self.assertEqual(
            ledger['N2357']['tests'],
            [
                'test_c07_teams_update_enemies_registration',
                'test_all_c07_teams_update_enemies_input_evidence_is_exact',
                'test_teams_update_enemies_state',
                'test_reference_graph_and_actual_c07_teams_update_enemies',
            ],
        )
        self.assertTrue(ledger['N2357']['deferred_exprs'])

    def test_all_c07_teams_update_enemies_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2357']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTeamsRuntimeState.source_teams_update_enemies_state')
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2357']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_update_enemies_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Teams.updateEnemies() (Teams.java:252-268) adds
        # the wave team to active when waves are enabled
        # and it is not active yet
        # (`if(state.rules.waves && !active.contains(get(state.rules.waveTeam))){`
        # / `active.add(get(state.rules.waveTeam));`), then
        # rewrites every active team's coreEnemies to the
        # other active teams (`for(TeamData data :
        # active){` / `Seq<Team> enemies = new Seq<>();` /
        # `for(TeamData other : active){` /
        # `if(data.team != other.team){` /
        # `enemies.add(other.team);` / `data.coreEnemies =
        # enemies.toArray(Team.class);`). The function is a
        # pure frame-first function: it deep-copies the
        # teams_state, applies the update to the copy via
        # the shared _teams_update_enemies helper (the
        # rules in the copy are set from the explicit
        # waves_enabled / wave_team_id params first), and
        # returns the updated copy plus wave_team_added --
        # the caller's dict is never mutated.
        self.assertIn('static func source_teams_update_enemies_state(teams_state: Dictionary, waves_enabled: bool, wave_team_id: int) -> Dictionary:', teams)
        self.assertIn('return {"teams_state": updated, "wave_team_added": wave_team_added}', teams)
        for expr in [
            'public class Teams{',
            'private void updateEnemies(){',
            'if(state.rules.waves && !active.contains(get(state.rules.waveTeam))){',
            'active.add(get(state.rules.waveTeam));',
            'for(TeamData data : active){',
            'Seq<Team> enemies = new Seq<>();',
            'for(TeamData other : active){',
            'if(data.team != other.team){',
            'enemies.add(other.team);',
            'data.coreEnemies = enemies.toArray(Team.class);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof's keys drive the pure function with
        # synthetic teams_state dicts (no live tick): the
        # wave team is added when waves are on and it is
        # not active / already active means no add / waves
        # off means no add / every team's core_enemies
        # excludes itself / core_enemies are rewritten in
        # the returned dict / an empty active list is a
        # no-op without crashing / the caller's dict is
        # never mutated.
        proof = TEAMS_UPDATE_ENEMIES_PROOF.read_text(encoding='utf-8')
        for key in [
            'wave_team_added',
            'wave_team_already_active',
            'waves_disabled_no_add',
            'enemies_exclude_self',
            'core_enemies_updated',
            'empty_active',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_update_enemies(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamsUpdateEnemiesProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAMS_UPDATE_ENEMIES_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'wave_team_added',
            'wave_team_already_active',
            'waves_disabled_no_add',
            'enemies_exclude_self',
            'core_enemies_updated',
            'empty_active',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
