import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
BUILD_TURRET_PLAN_LOGIC_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretPlanLogicProof.gd'
BUILD_TURRET_PLAN_LOGIC_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretPlanLogicProof.tscn'


class C07BuildTurretPlanLogicTests(unittest.TestCase):
    def test_c07_build_turret_plan_logic_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2244']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_plan_logic_state')
        # N2215 gave the build tower its shouldConsume gate
        # (`return unit.plans().size > 0 && !isHealSuppressed();`,
        # BuildTurret.java:230) over the frame plans key -- but
        # no live fill ever set frame["plans"]: the plan search
        # over team.data().plans, the mimic of nearby builders,
        # the plan validation / break-plan discard, and the
        # suicide-plan removal (BuildTurretBuild.updateTile(),
        # BuildTurret.java:141-225) all waited for the updateTile
        # advance. N2244 is that advance (the plan-logic half;
        # the sync/warmup half, BuildTurret.java:121-140, is
        # N2243 on its own branch, and updateBuildLogic,
        # BuilderComp.java:76+, defers to its own slice): the
        # pure plan logic takes the frame (plans / following /
        # last_plan) plus explicit inputs -- controlled,
        # search_ready (the timer(timerTarget, targetInterval)
        # tick, targetInterval 15), break_check_ready (the
        # timer.get(timerTarget2, 30f) tick), the tower world
        # position + range, the team plans list, the nearby
        # builders list, the team players list, and the two
        # per-request validity predicates the port cannot
        # evaluate live (Build.validPlace / Build.validBreak and
        # the ConstructBuild current-block match) -- and
        # returns the advanced plans / following / last_plan /
        # team_plans plus the branch taken and whether a plan
        # was discarded. Six new result symbols.
        self.assertEqual(
            ledger['N2244']['source_symbols'],
            [
                'source_build_turret_plan_logic_state_result.plans',
                'source_build_turret_plan_logic_state_result.following',
                'source_build_turret_plan_logic_state_result.last_plan',
                'source_build_turret_plan_logic_state_result.team_plans',
                'source_build_turret_plan_logic_state_result.branch',
                'source_build_turret_plan_logic_state_result.plan_discarded',
            ],
        )
        for name in ledger['N2244']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/BuildTurret.java')
                self.assertEqual(symbol['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_plan_logic_state')
        self.assertEqual(ledger['N2244']['runtime_proof'], '/root/C07BuildTurretPlanLogicProof')
        self.assertEqual(
            ledger['N2244']['tests'],
            [
                'test_c07_build_turret_plan_logic_registration',
                'test_all_c07_build_turret_plan_logic_input_evidence_is_exact',
                'test_build_turret_plan_logic_state',
                'test_reference_graph_and_actual_c07_build_turret_plan_logic',
            ],
        )
        self.assertTrue(ledger['N2244']['deferred_exprs'])
        # This slice resolves the plan search / mimic and plan
        # validation / break deferrals, so both entries are gone
        # from DEFERRED -- while the updateTile advance entry is
        # reworded down to the sync/warmup half (N2243) and a
        # new updateBuildLogic entry carries the deferred build
        # simulation.
        self.assertFalse(any(entry.startswith('BuildTurret plan search / mimic rows (') for entry in ledger['N2244']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('BuildTurret plan validation / break rows (') for entry in ledger['N2244']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BuildTurret updateBuildLogic rows (') for entry in ledger['N2244']['deferred_exprs']))
        advance = [entry for entry in ledger['N2244']['deferred_exprs'] if entry.startswith('BuildTurret updateTile advance (')]
        self.assertEqual(len(advance), 1)
        self.assertIn('BuildTurret.java:121-140', advance[0])
        self.assertIn('N2244', advance[0])

    def test_all_c07_build_turret_plan_logic_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2244']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_plan_logic_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
            'core/src/mindustry/entities/comp/BuilderComp.java',
            'core/src/mindustry/game/Teams.java',
            'core/src/mindustry/entities/units/BuildPlan.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2244']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_plan_logic_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # The pure plan logic lives on the build-turret build
        # state: BuildTurretBuild.updateTile(), plan-logic half
        # (BuildTurret.java:141-225). Autonomous
        # (`if(!isControlled()){`, :141) with
        # `unit.updateBuilding(true);` (:142): follower
        # validation (:144-155, `if(!following.isValid() ||
        # !following.activelyBuilding()){` clears following +
        # plans, else plans = [follower's first plan] and
        # `lastPlan = null;`); plan search (:156-173,
        # `}else if(unit.buildPlan() == null &&
        # timer(timerTarget, targetInterval)){` with
        # targetInterval 15, `Queue<BlockPlan> blocks =
        # team.data().plans;`, `if(within(block.x * tilesize,
        # block.y * tilesize, range)){`,
        # `unit.addBuild(new BuildPlan(block.x, block.y,
        # block.rotation, block.block, block.config));`,
        # `blocks.addLast(blocks.removeIndex(i));` rotating the
        # picked plan to the tail, `lastPlan = block;`); mimic
        # (:174-188, `Units.nearby(team, x, y, range, u -> {`,
        # `if(u.canBuild() && u.activelyBuilding()){`,
        # `if(build instanceof ConstructBuild && within(build,
        # range)){`, `following = u;`); validation (:189-216,
        # `BuildPlan req = unit.buildPlan();`,
        # `if(!req.breaking && timer.get(timerTarget2, 30f)){`,
        # the break-plan discard removing the first plan AND the
        # matching team plan (`team.data().plans.remove(p -> p.x
        # == req.x && p.y == req.y);`) with an early `return;`
        # that skips the suicide removal that tick, `boolean
        # valid =` with `!(lastPlan != null && lastPlan.removed)
        # &&` and the ConstructBuild / validBreak / validPlace
        # disjunction, `if(!valid){` discarding the first plan);
        # controlled (`}else{ //is being controlled, forget
        # everything`, :217-220, following = lastPlan = null);
        # suicide-plan removal (:223,
        # `unit.plans().remove(b -> b.build() == this);`,
        # BuildPlan.build() is `return world.build(x, y);`,
        # BuildPlan.java:165-167). `unit.updateBuildLogic();`
        # (:225, BuilderComp.java:76+, `public void
        # updateBuildLogic(){`) is NOT called by the driver --
        # the build simulation defers. buildPlan() is the queue
        # head (`return plans.size == 0 ? null :
        # plans.first();`, BuilderComp.java:313-315). within is
        # the strict squared-distance check
        # (`Mathf.dst2(getX(), getY(), x, y) < dst*dst`, Arc
        # Position.java:44-46) with tilesize 8 (`public static
        # final int tilesize = 8;`, Vars.java:135) and the
        # build-tower range 200f (Blocks.java:2001, `range =
        # 200f;`). The frame gains `following` (default null,
        # the `public @Nullable Unit following;` mirror,
        # BuildTurret.java:94) and `last_plan` (default null,
        # the `public @Nullable BlockPlan lastPlan;` mirror,
        # BuildTurret.java:95; BlockPlan.removed is
        # `public boolean removed;`, Teams.java:497).
        self.assertIn('static func source_build_turret_plan_logic_state', build_turret)
        self.assertIn('"plans": plans', build_turret)
        self.assertIn('"following": following', build_turret)
        self.assertIn('"last_plan": last_plan', build_turret)
        self.assertIn('"team_plans": team_plans', build_turret)
        self.assertIn('"branch": branch', build_turret)
        self.assertIn('"plan_discarded": plan_discarded', build_turret)
        self.assertIn('plan logic live (N2244)', build_turret)
        self.assertIn('if(!isControlled()){', build_turret)
        self.assertIn('unit.updateBuilding(true);', build_turret)
        self.assertIn('if(!following.isValid() || !following.activelyBuilding()){', build_turret)
        self.assertIn('unit.plans().addFirst(following.buildPlan());', build_turret)
        self.assertIn('}else if(unit.buildPlan() == null && timer(timerTarget, targetInterval)){', build_turret)
        self.assertIn('Queue<BlockPlan> blocks = team.data().plans;', build_turret)
        self.assertIn('if(within(block.x * tilesize, block.y * tilesize, range)){', build_turret)
        self.assertIn('unit.addBuild(new BuildPlan(block.x, block.y, block.rotation, block.block, block.config));', build_turret)
        self.assertIn('blocks.addLast(blocks.removeIndex(i));', build_turret)
        self.assertIn('lastPlan = block;', build_turret)
        self.assertIn('Units.nearby(team, x, y, range, u -> {', build_turret)
        self.assertIn('if(u.canBuild() && u.activelyBuilding()){', build_turret)
        self.assertIn('if(build instanceof ConstructBuild && within(build, range)){', build_turret)
        self.assertIn('following = u;', build_turret)
        self.assertIn('}else if(unit.buildPlan() != null){', build_turret)
        self.assertIn('BuildPlan req = unit.buildPlan();', build_turret)
        self.assertIn('if(!req.breaking && timer.get(timerTarget2, 30f)){', build_turret)
        self.assertIn('team.data().plans.remove(p -> p.x == req.x && p.y == req.y);', build_turret)
        self.assertIn('boolean valid =', build_turret)
        self.assertIn('!(lastPlan != null && lastPlan.removed) &&', build_turret)
        self.assertIn('if(!valid){', build_turret)
        self.assertIn('unit.plans().remove(b -> b.build() == this);', build_turret)
        self.assertIn('unit.updateBuildLogic();', build_turret)
        self.assertIn('public int targetInterval = 15;', build_turret)
        self.assertIn('public static final int tilesize = 8;', build_turret)
        self.assertIn('return plans.size == 0 ? null : plans.first();', build_turret)
        self.assertIn('public boolean removed;', build_turret)
        self.assertIn('"following": null', build_turret)
        self.assertIn('"last_plan": null', build_turret)
        # The driver wires the plan logic after the consumption
        # fold (updateConsumption runs before updateTile,
        # BuildingComp.java:2274-2277) and unconditionally, NOT
        # gated on enabled: BuildTurret sets no
        # noUpdateDisabled, so Java runs updateTile for a
        # disabled tower too (`if(enabled ||
        # !block.noUpdateDisabled){`). The wiring sits AFTER the
        # N2243 sync/warmup wiring in Java order (BuildTurret.
        # java:121-140 before :141-225); N2243 lands on its own
        # branch and the coordinator orders the two wirings at
        # integration. The driver passes no live team plans /
        # nearby builders / players yet (empty lists, both
        # timers false, controlled false) and assumes the
        # current request stays valid (req_valid_place_or_break
        # true -- the port cannot evaluate Build.validPlace /
        # validBreak live), so a live tower keeps its plans and
        # the N2215 gate keeps reading them; the pure function
        # proves the search / mimic / discard paths with
        # explicit inputs.
        self.assertIn('static func source_build_turret_tick_buildings_state', build_turret)
        self.assertIn('source_build_turret_plan_logic_state(frame, false, false, false', build_turret)
        self.assertIn('frame["plans"] = advanced_plan["plans"]', build_turret)
        self.assertIn('frame["following"] = advanced_plan["following"]', build_turret)
        self.assertIn('frame["last_plan"] = advanced_plan["last_plan"]', build_turret)
        self.assertIn('SOURCE_BUILD_TURRET_RANGE', build_turret)
        # The N2184 power row and the N2215 gate are preserved.
        self.assertIn('static func source_build_turret_power_status_row_state', build_turret)
        self.assertIn('static func source_build_turret_should_consume_state', build_turret)
        self.assertIn('shouldConsume gate live (N2215)', build_turret)
        # The proof's keys drive the pure plan logic: follower
        # validation clears an invalid follower, the search
        # picks the first in-range placeable team plan, the
        # picked plan rotates to the tail of the team queue,
        # mimic follows the first nearby actively-building
        # builder on a ConstructBuild in range, an invalid plan
        # (lastPlan removed) is discarded, and a plan pointing
        # at the tower itself is removed. Static checks: the
        # proof preloads the build-turret state file that
        # exists, and the scene file references the proof
        # script that exists.
        proof = BUILD_TURRET_PLAN_LOGIC_PROOF.read_text(encoding='utf-8')
        for key in [
            'follower_validation_clears_invalid',
            'plan_search_picks_in_range',
            'plan_search_rotates_queue',
            'mimic_follows_nearby_builder',
            'invalid_plan_discarded',
            'suicide_plan_removed',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceBuildTurretBuildState.gd")', proof)
        self.assertIn('build_turret_build_state.source_build_turret_plan_logic_state(', proof)
        self.assertTrue(BUILD_TURRET_STATE.is_file())
        scene = BUILD_TURRET_PLAN_LOGIC_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BuildTurretPlanLogicProof.gd', scene)
        self.assertTrue(BUILD_TURRET_PLAN_LOGIC_PROOF.is_file())

    def test_reference_graph_and_actual_c07_build_turret_plan_logic(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretPlanLogicProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_PLAN_LOGIC_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'follower_validation_clears_invalid',
            'plan_search_picks_in_range',
            'plan_search_rotates_queue',
            'mimic_follows_nearby_builder',
            'invalid_plan_discarded',
            'suicide_plan_removed',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
