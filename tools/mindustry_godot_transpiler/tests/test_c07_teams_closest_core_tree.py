import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
CLOSEST_CORE_TREE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamsClosestCoreTreeProof.gd'


class C07TeamsClosestCoreTreeTests(unittest.TestCase):
    def test_c07_teams_closest_core_tree_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2392']['godot_owner'], 'SourceTeamsRuntimeState.source_teams_closest_core_state')
        # Teams.closestCore()+TeamData.tree()
        # (Teams.java:56-58 + :437-440), one grouped slice
        # (main-thread decision 2026-11-21, the N2380
        # seven-method / N2374 five-accessor group
        # precedent): two one-to-two-line read-only lookup
        # methods on Teams/TeamData (`cores` + `unitTree`).
        # Two GD functions, one ledger entry, one owner per
        # function (the N2380 multi-function precedent; the
        # N2378 lesson: a contract owner must be an actual GD
        # function, so the group label
        # `source_teams_closest_core_tree_state` is NOT an
        # owner -- the ledger godot_owner is the first
        # function owner, `source_teams_closest_core_state`).
        # `get(team)` in closestCore() is the Teams.get(Team)
        # lookup, already the exact_expr of N2380 -- the
        # cores arrive already resolved, not re-ported.
        # `Geometry.findClosest` arrives as a Callable param;
        # `Vars.world.getQuadBounds` arrives as a Callable
        # param; the QuadTree itself is NOT ported. Two new
        # result symbols.
        self.assertEqual(
            ledger['N2392']['java_method'],
            'Teams.closestCore(float, float, Team)/TeamData.tree()',
        )
        self.assertEqual(
            ledger['N2392']['source_symbols'],
            [
                'source_teams_closest_core_state_result.core',
                'source_team_data_tree_state_result.unit_tree',
            ],
        )
        for name in ledger['N2392']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team'))
        self.assertEqual(ledger['N2392']['runtime_proof'], '/root/C07TeamsClosestCoreTreeProof')
        self.assertEqual(
            ledger['N2392']['tests'],
            [
                'test_c07_teams_closest_core_tree_registration',
                'test_all_c07_teams_closest_core_tree_input_evidence_is_exact',
                'test_teams_closest_core_tree_state',
                'test_reference_graph_and_actual_c07_teams_closest_core_tree',
            ],
        )
        self.assertTrue(ledger['N2392']['deferred_exprs'])

    def test_all_c07_teams_closest_core_tree_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2392']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team'))
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2392']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_closest_core_tree_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Teams.closestCore()+TeamData.tree()
        # (Teams.java:56-58 + :437-440):
        # closestCore returns whatever Geometry.findClosest
        # returns for the resolved cores (null when none);
        # tree() returns the cached unitTree, or the fresh
        # tree from the world-bounds Callable when the
        # cache is null (the lazy init).
        self.assertIn('static func source_teams_closest_core_state(x: float, y: float, cores: Array, find_closest: Callable) -> Dictionary:', teams)
        self.assertIn('static func source_team_data_tree_state(unit_tree: Variant, world_quad_bounds: Callable) -> Dictionary:', teams)
        for expr in [
            'public static class TeamData{',
            'public CoreBuild closestCore(float x, float y, Team team){',
            'return Geometry.findClosest(x, y, get(team).cores);',
            'public QuadTree<Unit> tree(){',
            'if(unitTree == null) unitTree = new QuadTree<>(Vars.world.getQuadBounds(new Rect()));',
            'return unitTree;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof's keys drive the two pure functions with
        # synthetic inputs (no live tick): closestCore returns
        # the nearest core / null when no cores / returns
        # only its one key; tree() creates a fresh tree when
        # the cache is null / returns the cached tree (never
        # calling the bounds Callable) when present /
        # returns only its one key.
        proof = CLOSEST_CORE_TREE_PROOF.read_text(encoding='utf-8')
        for key in [
            'closest_core_returns_nearest_core',
            'closest_core_null_when_no_cores',
            'closest_core_returns_only_one_key',
            'tree_creates_when_cache_null',
            'tree_returns_cached_when_present',
            'tree_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_closest_core_tree(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamsClosestCoreTreeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAMS_CLOSEST_CORE_TREE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'closest_core_returns_nearest_core',
            'closest_core_null_when_no_cores',
            'closest_core_returns_only_one_key',
            'tree_creates_when_cache_null',
            'tree_returns_cached_when_present',
            'tree_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
