import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
TEAMS_EACH_ENEMY_CORE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamsEachEnemyCoreProof.gd'


class C07TeamsEachEnemyCoreTests(unittest.TestCase):
    def test_c07_teams_each_enemy_core_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2365']['godot_owner'], 'SourceTeamsRuntimeState.source_teams_each_enemy_core_state')
        # Teams.eachEnemyCore() (Teams.java:86-94):
        # `public void eachEnemyCore(Team team, Cons<Building> ret){`
        # `for(TeamData data : active){`
        # `if(team != data.team){`
        # `for(Building tile : data.cores){`
        # `ret.get(tile);`
        # `}`
        # `}`
        # `}`
        # `}`
        # on `public class Teams{` (Teams.java:24). Java hands each
        # enemy core to the Cons<Building> callback; GDScript has no
        # Java Cons, so the port is a pure function returning an
        # Array of enemy cores (main-thread decision 2026-11-21,
        # recorded in allocations.json N2365): each core is
        # [team_id, x, y] and the caller iterates the returned Array
        # instead of a callback. The cores stored in teams_state are
        # opaque refs with no position, so the enemy cores arrive as
        # explicit records {"team_id": int, "x": float, "y": float}
        # (the N2330/N2354 param precedent); only records whose
        # team_id is the active team being scanned are collected, in
        # active-team order then enemy_cores order. Unlike N2361
        # (anyEnemyCoresWithin), there is no protectCores condition
        # and no radius -- every enemy team's cores are collected.
        # The payload is the "cores" Array inside the
        # family-convention Dictionary envelope (the SSOT validator
        # accepts only return_type Dictionary or void, so a bare
        # Array return cannot be registered).
        # One new result symbol: cores.
        self.assertEqual(
            ledger['N2365']['source_symbols'],
            [
                'source_teams_each_enemy_core_state_result.cores',
            ],
        )
        for name in ledger['N2365']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTeamsRuntimeState.source_teams_each_enemy_core_state')
        self.assertEqual(ledger['N2365']['runtime_proof'], '/root/C07TeamsEachEnemyCoreProof')
        self.assertEqual(
            ledger['N2365']['tests'],
            [
                'test_c07_teams_each_enemy_core_registration',
                'test_all_c07_teams_each_enemy_core_input_evidence_is_exact',
                'test_teams_each_enemy_core_state',
                'test_reference_graph_and_actual_c07_teams_each_enemy_core',
            ],
        )
        self.assertTrue(ledger['N2365']['deferred_exprs'])

    def test_all_c07_teams_each_enemy_core_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2365']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTeamsRuntimeState.source_teams_each_enemy_core_state')
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2365']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_each_enemy_core_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Teams.eachEnemyCore() (Teams.java:86-94) walks the active
        # teams, skipping the calling team, and collects every enemy
        # team's cores as [team_id, x, y] entries in the returned
        # Array (active-team order, then enemy_cores order). No
        # protectCores condition and no radius, unlike N2361.
        self.assertIn('static func source_teams_each_enemy_core_state(teams_state: Dictionary, team_id: int, enemy_cores: Array) -> Dictionary:', teams)
        self.assertIn('return {"cores": found}', teams)
        for expr in [
            'public class Teams{',
            'public void eachEnemyCore(Team team, Cons<Building> ret){',
            'for(TeamData data : active){',
            'if(team != data.team){',
            'for(Building tile : data.cores){',
            'ret.get(tile);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof's keys drive the pure function with synthetic
        # teams_state dicts and explicit enemy-core records (no live
        # tick, no Cons callback): enemy cores are collected /
        # the calling team's cores are excluded / order follows
        # active-team order then enemy_cores order / no enemy cores
        # returns an empty Array / an empty teams_state returns an
        # empty Array without crashing / the call mutates neither
        # the teams_state nor the enemy-core records.
        proof = TEAMS_EACH_ENEMY_CORE_PROOF.read_text(encoding='utf-8')
        for key in [
            'enemy_cores_collected',
            'same_team_excluded',
            'order_active_then_cores',
            'no_enemy_cores_empty',
            'empty_teams_state',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_each_enemy_core(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamsEachEnemyCoreProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAMS_EACH_ENEMY_CORE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'enemy_cores_collected',
            'same_team_excluded',
            'order_active_then_cores',
            'no_enemy_cores_empty',
            'empty_teams_state',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
