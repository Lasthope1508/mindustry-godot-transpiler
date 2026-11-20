import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
TEAMS_ANY_ENEMY_CORES_WITHIN_BUILD_RADIUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamsAnyEnemyCoresWithinBuildRadiusProof.gd'


class C07TeamsAnyEnemyCoresWithinBuildRadiusTests(unittest.TestCase):
    def test_c07_teams_any_enemy_cores_within_build_radius_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2359']['godot_owner'], 'SourceTeamsRuntimeState.source_teams_any_enemy_cores_within_build_radius_state')
        # Teams.anyEnemyCoresWithinBuildRadius() (Teams.java:60-72):
        # `public boolean anyEnemyCoresWithinBuildRadius(Team team, float x, float y){`
        # `for(TeamData data : active){`
        # `if(team != data.team && data.team.rules().protectCores){`
        # `for(CoreBuild tile : data.cores){`
        # `if(tile.within(x, y, state.rules.buildRadius(tile.team) + tilesize)){`
        # `return true;`
        # `}`
        # `}`
        # `}`
        # `}`
        # `return false;`
        # `}`
        # on `public class Teams{` (Teams.java:27). The scan
        # walks the active teams, skipping the calling team
        # and teams whose rules do not protect cores
        # (`data.team.rules().protectCores` arrives as the
        # explicit protect_cores_by_team lookup -- Rules is
        # not ported), and each enemy team's cores; a core
        # within `state.rules.buildRadius(tile.team) +
        # tilesize` (the build_radius_by_team lookup plus
        # the tilesize param -- Rules is not ported) of the
        # query point returns true. `tile.within(x, y,
        # radius)` is arc Position.within (Position.java:44-46):
        # `Mathf.dst2(getX(), getY(), x, y) < dst*dst` --
        # a STRICT < on the squared distance. The cores
        # stored in teams_state are opaque refs with no
        # position, so the enemy cores arrive as explicit
        # records {"team_id": int, "x": float, "y": float}
        # (the N2330/N2354 param precedent); only records
        # whose team_id is the active team being scanned
        # are considered. The call-site
        # `state.teams.anyEnemyCoresWithinBuildRadius(...)`
        # already owned by N2042 (Build.validPlaceIgnoreUnits)
        # is callee evidence in another class's slice, not
        # this method's body (batch-11 scope section 1.2).
        # One new result symbol: within.
        self.assertEqual(
            ledger['N2359']['source_symbols'],
            [
                'source_teams_any_enemy_cores_within_build_radius_state_result.within',
            ],
        )
        for name in ledger['N2359']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTeamsRuntimeState.source_teams_any_enemy_cores_within_build_radius_state')
        self.assertEqual(ledger['N2359']['runtime_proof'], '/root/C07TeamsAnyEnemyCoresWithinBuildRadiusProof')
        self.assertEqual(
            ledger['N2359']['tests'],
            [
                'test_c07_teams_any_enemy_cores_within_build_radius_registration',
                'test_all_c07_teams_any_enemy_cores_within_build_radius_input_evidence_is_exact',
                'test_teams_any_enemy_cores_within_build_radius_state',
                'test_reference_graph_and_actual_c07_teams_any_enemy_cores_within_build_radius',
            ],
        )
        self.assertTrue(ledger['N2359']['deferred_exprs'])

    def test_all_c07_teams_any_enemy_cores_within_build_radius_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2359']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTeamsRuntimeState.source_teams_any_enemy_cores_within_build_radius_state')
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2359']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_any_enemy_cores_within_build_radius_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Teams.anyEnemyCoresWithinBuildRadius() (Teams.java:60-72)
        # scans the active teams, skipping the calling team and
        # unprotected teams, and each enemy team's cores; a core
        # within `buildRadius(tile.team) + tilesize` of the query
        # point returns true (`tile.within(x, y, radius)` is a
        # STRICT < on the squared distance, arc Position.java:44-46).
        # Otherwise false. The enemy cores arrive as explicit
        # {"team_id", "x", "y"} records; protectCores and
        # buildRadius arrive as per-team lookups (Rules not ported).
        self.assertIn('static func source_teams_any_enemy_cores_within_build_radius_state(teams_state: Dictionary, team_id: int, x: float, y: float, protect_cores_by_team: Dictionary, build_radius_by_team: Dictionary, tilesize: float, enemy_cores: Array) -> Dictionary:', teams)
        self.assertIn('return {"within": true}', teams)
        self.assertIn('return {"within": false}', teams)
        for expr in [
            'public class Teams{',
            'public boolean anyEnemyCoresWithinBuildRadius(Team team, float x, float y){',
            'for(TeamData data : active){',
            'if(team != data.team && data.team.rules().protectCores){',
            'for(CoreBuild tile : data.cores){',
            'if(tile.within(x, y, state.rules.buildRadius(tile.team) + tilesize)){',
            'return true;',
            'return false;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof's keys drive the pure function with synthetic
        # teams_state dicts and explicit enemy-core records (no live
        # tick, no Rules): an enemy core inside the build radius
        # returns true / an enemy core outside returns false / a core
        # of the calling team is ignored / a core of an unprotected
        # team is ignored / a core exactly on the radius boundary is
        # outside (strict <) / an empty teams_state returns false
        # without crashing / the call mutates neither the teams_state
        # nor the enemy-core records.
        proof = TEAMS_ANY_ENEMY_CORES_WITHIN_BUILD_RADIUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'enemy_core_in_radius',
            'no_enemy_core_outside',
            'same_team_ignored',
            'unprotected_team_ignored',
            'boundary_is_outside',
            'empty_teams_state',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_any_enemy_cores_within_build_radius(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamsAnyEnemyCoresWithinBuildRadiusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAMS_ANY_ENEMY_CORES_WITHIN_BUILD_RADIUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'enemy_core_in_radius',
            'no_enemy_core_outside',
            'same_team_ignored',
            'unprotected_team_ignored',
            'boundary_is_outside',
            'empty_teams_state',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
