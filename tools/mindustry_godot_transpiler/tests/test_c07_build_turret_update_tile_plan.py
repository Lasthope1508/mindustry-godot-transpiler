import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
BUILD_TURRET_PLAN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretUpdateTilePlanProof.gd'


class C07BuildTurretUpdateTilePlanTests(unittest.TestCase):
    def test_c07_build_turret_update_tile_plan_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2423']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_update_tile_plan_state')
        # BuildTurretBuild.updateTile() plan legs
        # (BuildTurret.java:121-227): the plan search / follow /
        # mimic / validate advance -- 9 distinct exprs, all
        # 0-hit in both ledgers at RED:
        # `following = null;` (:147/:175/:218, one expr, three
        # positions)
        # `for(int i = 0; i < blocks.size; i++){` (:158)
        # `var block = blocks.get(i);` (:159)
        # `var btype = block.block;` (:161)
        # `if(Build.validPlace(btype, unit.team(), block.x,
        # block.y, block.rotation) && (state.rules.infiniteResources
        # || team.rules().infiniteResources ||
        # team.items().has(btype.requirements,
        # state.rules.buildCostMultiplier))){` (:163)
        # `if(unit.buildPlan() == null){` (:174)
        # `if(following  != null) return;` (:177, two spaces)
        # `team.data().plans.remove(p -> p.x == req.x &&
        # p.y == req.y);` (:198)
        # `(req.breaking ?` (:207, ternary fragment)
        # Nothing already owned by N2184 (136 exprs) is
        # re-registered -- especially the :156 search opener,
        # the :189 validate opener, :217 `}else{`, the
        # plan-search / mimic / validate bodies and
        # `unit.updateBuildLogic();`. Leg-slice inside an
        # already-owned method (the N2397 precedent).
        self.assertEqual(
            ledger['N2423']['source_symbols'],
            [
                'source_build_turret_update_tile_plan_state_result.following_cleared',
                'source_build_turret_update_tile_plan_state_result.found_plan',
                'source_build_turret_update_tile_plan_state_result.found_btype',
                'source_build_turret_update_tile_plan_state_result.found_index',
                'source_build_turret_update_tile_plan_state_result.mimic',
                'source_build_turret_update_tile_plan_state_result.mimic_early_return',
                'source_build_turret_update_tile_plan_state_result.team_plans',
                'source_build_turret_update_tile_plan_state_result.valid_break_branch',
            ],
        )
        for name in ledger['N2423']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/BuildTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBuildTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2423']['runtime_proof'], '/root/C07BuildTurretUpdateTilePlanProof')
        self.assertEqual(
            ledger['N2423']['tests'],
            [
                'test_c07_build_turret_update_tile_plan_registration',
                'test_all_c07_build_turret_update_tile_plan_input_evidence_is_exact',
                'test_build_turret_update_tile_plan_state',
                'test_reference_graph_and_actual_c07_build_turret_update_tile_plan',
            ],
        )
        self.assertTrue(ledger['N2423']['deferred_exprs'])

    def test_all_c07_build_turret_update_tile_plan_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2423']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBuildTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2423']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_update_tile_plan_state(self):
        state = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # BuildTurretBuild.updateTile() plan legs
        # (BuildTurret.java:121-227): one pure function over
        # explicit params -- follower validity / control /
        # build-plan presence, the team plan queue, an explicit
        # validPlace Callable, the request being validated and
        # the mimic callback's following state. No engine calls.
        self.assertIn('static func source_build_turret_update_tile_plan_state(has_following: bool, following_valid: bool, controlled: bool, build_plan_null: bool, team_plans: Array, valid_place: Callable, req_breaking: bool, req_pos: Vector2i, player_breaking_same_pos: bool, mimic_following_set: bool) -> Dictionary:', state)
        for expr in [
            'following = null;',
            'for(int i = 0; i < blocks.size; i++){',
            'var block = blocks.get(i);',
            'var btype = block.block;',
            'if(Build.validPlace(btype, unit.team(), block.x, block.y, block.rotation) && (state.rules.infiniteResources || team.rules().infiniteResources || team.items().has(btype.requirements, state.rules.buildCostMultiplier))){',
            'if(unit.buildPlan() == null){',
            'if(following  != null) return;',
            'team.data().plans.remove(p -> p.x == req.x && p.y == req.y);',
            '(req.breaking ?',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure function with
        # fixtures (no live tick).
        proof = BUILD_TURRET_PLAN_PROOF.read_text(encoding='utf-8')
        for key in [
            'follower_invalid_clears_following',
            'valid_follower_kept',
            'controlled_clears_following',
            'search_finds_first_valid_plan',
            'search_finds_none_starts_mimic',
            'has_plan_skips_search',
            'player_breaking_removes_plan',
            'break_branch_selected',
            'mimic_early_return_when_following_set',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_build_turret_update_tile_plan(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretUpdateTilePlanProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_UPDATE_TILE_PLAN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'follower_invalid_clears_following',
            'valid_follower_kept',
            'controlled_clears_following',
            'search_finds_first_valid_plan',
            'search_finds_none_starts_mimic',
            'has_plan_skips_search',
            'player_breaking_removes_plan',
            'break_branch_selected',
            'mimic_early_return_when_following_set',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
