import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
TEAMS_CLOSEST_ENEMY_CORE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamsClosestEnemyCoreProof.gd'


class C07TeamsClosestEnemyCoreTests(unittest.TestCase):
    def test_c07_teams_closest_enemy_core_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2354']['godot_owner'], 'SourceTeamsRuntimeState.source_teams_closest_enemy_core_state')
        # Teams.closestEnemyCore() (Teams.java:39-55):
        # `@Nullable`
        # `public CoreBuild closestEnemyCore(float x, float y, Team team){`
        # `CoreBuild closest = null;`
        # `float closestDst = Float.MAX_VALUE;`
        # `for(Team enemy : team.data().coreEnemies){`
        # `for(CoreBuild core : enemy.cores()){`
        # `float dst = Mathf.dst2(x, y, core.getX(), core.getY());`
        # `if(closestDst > dst){`
        # `closest = core;`
        # `closestDst = dst;`
        # `}`
        # `}`
        # `}`
        # `return closest;`
        # `}`
        # on `public class Teams{` (Teams.java:27). The scan
        # walks the calling team's coreEnemies (kept in
        # teams_state by updateEnemies, Teams.java:252-268 --
        # NOT ported here, only read) and each enemy team's
        # cores, keeping the core with the smallest squared
        # distance (Mathf.dst2 is the SQUARED distance, arc
        # Mathf.java:656-659). A strict `>` keeps the FIRST
        # core on a tie. No enemy core means null (the
        # @Nullable return) with closest_dst2 left at
        # Float.MAX_VALUE. The cores stored in teams_state
        # are opaque refs with no position, so the enemy
        # cores arrive as explicit records {"team_id": int,
        # "ref": Variant, "x": float, "y": float} (the
        # N2330 param precedent); only records whose
        # team_id is in the calling team's core_enemies
        # are considered. updateEnemies() itself stays
        # deferred (batch-9 scope section 2.3), as does
        # the 1-line closestCore() delegate
        # (Teams.java:56-58, batch-9 scope section 5c).
        # Two new result symbols: closest_core,
        # closest_dst2.
        self.assertEqual(
            ledger['N2354']['source_symbols'],
            [
                'source_teams_closest_enemy_core_state_result.closest_core',
                'source_teams_closest_enemy_core_state_result.closest_dst2',
            ],
        )
        for name in ledger['N2354']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTeamsRuntimeState.source_teams_closest_enemy_core_state')
        self.assertEqual(ledger['N2354']['runtime_proof'], '/root/C07TeamsClosestEnemyCoreProof')
        self.assertEqual(
            ledger['N2354']['tests'],
            [
                'test_c07_teams_closest_enemy_core_registration',
                'test_all_c07_teams_closest_enemy_core_input_evidence_is_exact',
                'test_teams_closest_enemy_core_state',
                'test_reference_graph_and_actual_c07_teams_closest_enemy_core',
            ],
        )
        self.assertTrue(ledger['N2354']['deferred_exprs'])

    def test_all_c07_teams_closest_enemy_core_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2354']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTeamsRuntimeState.source_teams_closest_enemy_core_state')
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2354']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_closest_enemy_core_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Teams.closestEnemyCore() (Teams.java:39-55) scans
        # the calling team's coreEnemies and each enemy
        # team's cores, keeping the smallest squared
        # distance (`float dst = Mathf.dst2(x, y,
        # core.getX(), core.getY());` / `if(closestDst >
        # dst){` / `closest = core;` / `closestDst = dst;`).
        # No enemy core means null with closest_dst2 at
        # Float.MAX_VALUE. The enemy cores arrive as
        # explicit {"team_id", "ref", "x", "y"} records;
        # only records of a core_enemies team count.
        self.assertIn('static func source_teams_closest_enemy_core_state(teams_state: Dictionary, x: float, y: float, team_id: int, enemy_cores: Array) -> Dictionary:', teams)
        self.assertIn('var closest: Variant = null', teams)
        self.assertIn('var closest_dst2: float = 3.4028235e38', teams)
        self.assertIn('return {"closest_core": closest, "closest_dst2": closest_dst2}', teams)
        for expr in [
            'public class Teams{',
            '@Nullable',
            'public CoreBuild closestEnemyCore(float x, float y, Team team){',
            'CoreBuild closest = null;',
            'float closestDst = Float.MAX_VALUE;',
            'for(Team enemy : team.data().coreEnemies){',
            'for(CoreBuild core : enemy.cores()){',
            'float dst = Mathf.dst2(x, y, core.getX(), core.getY());',
            'if(closestDst > dst){',
            'closest = core;',
            'closestDst = dst;',
            'return closest;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof's keys drive the pure function with
        # synthetic teams_state dicts and explicit enemy-core
        # records (no live tick, no updateEnemies): the
        # nearest enemy core wins / a tie keeps the first
        # core / no enemy cores gives null / a nearer core
        # of a non-enemy team is ignored / closest_dst2 is
        # the squared distance / an empty teams_state gives
        # null without crashing / the call mutates neither
        # the teams_state nor the enemy-core records.
        proof = TEAMS_CLOSEST_ENEMY_CORE_PROOF.read_text(encoding='utf-8')
        for key in [
            'closest_found',
            'closest_tie_first',
            'no_enemy_cores_null',
            'non_enemy_ignored',
            'dst2_squared',
            'empty_teams_state',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_closest_enemy_core(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamsClosestEnemyCoreProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAMS_CLOSEST_ENEMY_CORE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'closest_found',
            'closest_tie_first',
            'no_enemy_cores_null',
            'non_enemy_ignored',
            'dst2_squared',
            'empty_teams_state',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
