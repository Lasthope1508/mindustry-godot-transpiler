import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_ROUTER_STATE = ROOT / 'godot-mindustry/src/game/SourceStackRouterBuildState.gd'
STACK_ROUTER_STATS_PLAN_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterStatsPlanRowsProof.gd'
STACK_ROUTER_STATS_PLAN_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterStatsPlanRowsProof.tscn'


class C07StackRouterStatsPlanRowsTests(unittest.TestCase):
    def test_c07_stack_router_stats_plan_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2442']['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_stats_state')
        # The StackRouter tick is live (N2181 power.status
        # row + N2240 updateTile advance + N2324 target()
        # selection + N2332 acceptItem gate) and the draw
        # rows are live (N2433 draw / drawCached / glow /
        # drawSelect / icons) but NOTHING modeled the
        # stats / plan rows: setStats() adds the
        # itemsMoved stat (DuctRouter.java:48-52),
        # drawPlanRegion() draws the base + top plan
        # rects (:60-63), minimapColor() returns the
        # sort item color rgba (:66-69) and
        # rotatedOutput() is false (:72-74).
        # StackRouter inherits all four from
        # DuctRouter (StackRouter.java:11, `public
        # class StackRouter extends DuctRouter{`) and
        # overrides NONE of them. N2442 ports them as
        # TWO pure-only pures (the N2419 draw + plan
        # precedent): the stats pure takes speed /
        # itemCapacity and returns the items-moved
        # rate + the Stat / StatUnit tokens, and the
        # plan pure takes the plan position / rotation
        # / sort item and returns the two plan calls +
        # the minimap color + rotatedOutput. Seven new
        # result symbols: the stats rate + key + unit,
        # the plan base / top calls, the minimap color
        # and rotatedOutput.
        self.assertEqual(
            ledger['N2442']['source_symbols'],
            [
                'source_stack_router_stats_state_result.items_moved_per_second',
                'source_stack_router_stats_state_result.stat_key',
                'source_stack_router_stats_state_result.stat_unit',
                'source_stack_router_draw_plan_state_result.base_call',
                'source_stack_router_draw_plan_state_result.top_call',
                'source_stack_router_draw_plan_state_result.minimap_color',
                'source_stack_router_draw_plan_state_result.rotated_output',
            ],
        )
        expected_sources = {
            'source_stack_router_stats_state_result.items_moved_per_second': 'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'source_stack_router_stats_state_result.stat_key': 'core/src/mindustry/world/meta/Stat.java',
            'source_stack_router_stats_state_result.stat_unit': 'core/src/mindustry/world/meta/StatUnit.java',
            'source_stack_router_draw_plan_state_result.base_call': 'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'source_stack_router_draw_plan_state_result.top_call': 'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'source_stack_router_draw_plan_state_result.minimap_color': 'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'source_stack_router_draw_plan_state_result.rotated_output': 'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
        }
        for name in ledger['N2442']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackRouterBuildState.source_stack_router_'))
        self.assertEqual(ledger['N2442']['runtime_proof'], '/root/C07StackRouterStatsPlanRowsProof')
        self.assertEqual(
            ledger['N2442']['tests'],
            [
                'test_c07_stack_router_stats_plan_rows_registration',
                'test_all_c07_stack_router_stats_plan_rows_input_evidence_is_exact',
                'test_stack_router_stats_plan_rows_state',
                'test_reference_graph_and_actual_c07_stack_router_stats_plan_rows',
            ],
        )
        self.assertTrue(ledger['N2442']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #68 (1-based in
        # the merged advances-27 DEFERRED base): the
        # StackRouter setStats / drawPlanRegion rows
        # entry is REMOVED -- setStats itemsMoved,
        # drawPlanRegion, minimapColor and
        # rotatedOutput are all live now (icons() was
        # already live since N2433 via icon_regions in
        # the draw pure). Net 266 - 1 = 265. The
        # config / sortItem and read/write entries
        # STAY.
        self.assertFalse(any(entry.startswith('StackRouter setStats / drawPlanRegion rows (') for entry in ledger['N2442']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter config / sortItem rows (') for entry in ledger['N2442']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter read/write rows (') for entry in ledger['N2442']['deferred_exprs']))
        self.assertEqual(len(ledger['N2442']['deferred_exprs']), 265)

    def test_all_c07_stack_router_stats_plan_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2442']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackRouterBuildState.source_stack_router_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/StackRouter.java',
            'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/content/Items.java',
            'core/src/mindustry/world/meta/Stat.java',
            'core/src/mindustry/world/meta/StatUnit.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The rgba() int format lives in arc, not
        # mindustry (the N2191 precedent): Color.
        # rgba() returns rgba8888() (Color.
        # java:365-367).
        upstream['arc-core/src/arc/graphics/Color.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/graphics/Color.java').read_text(encoding='utf-8')
        for expr in ledger['N2442']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stack_router_stats_plan_rows_state(self):
        stack_router = STACK_ROUTER_STATE.read_text(encoding='utf-8')
        # The stats rows (DuctRouter.setStats(),
        # DuctRouter.java:48-52): super.setStats()
        # then stats.add(Stat.itemsMoved, 60f / speed
        # * itemCapacity, StatUnit.itemsSecond) --
        # the float math is Java-exact: 60f / speed
        # FIRST, then times itemCapacity. The class
        # defaults are speed 5f (DuctRouter.java:19)
        # and itemCapacity 10 (StackRouter.java:20),
        # so the class-default rate is 60 / 5 * 10 =
        # 120 items per second. The single
        # surge-router def sets speed 6f
        # (Blocks.java:2259) and NO itemCapacity
        # override (Blocks.java:2255-2268), so its
        # rate is 60 / 6 * 10 = 100; the duct-router
        # def sets speed 4f (Blocks.java:2196) with
        # the DuctRouter class itemCapacity 1
        # (DuctRouter.java:31), so its rate is 60 /
        # 4 * 1 = 15. There is NO "stack-router" def
        # in Blocks.java -- surge-router is the only
        # StackRouter def. The tokens are exact:
        # itemsMoved (Stat.java:52) and itemsSecond
        # (StatUnit.java:20).
        # The plan rows (DuctRouter.drawPlanRegion(),
        # DuctRouter.java:60-63): the base rect at the
        # plan position and the top rect at the plan
        # position rotated plan.rotation * 90.
        # minimapColor() (DuctRouter.java:66-69)
        # returns 0 when the build or the sort item is
        # null, else sortItem.color.rgba() -- the
        # rgba8888 int (arc Color.java:365-367), NOT a
        # string token. rotatedOutput()
        # (DuctRouter.java:72-74) returns false.
        # Pure-only: the tick never calls setStats /
        # drawPlanRegion / minimapColor /
        # rotatedOutput. Keep each Java expr on ONE
        # comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_stack_router_stats_state', stack_router)
        self.assertIn('static func source_stack_router_draw_plan_state', stack_router)
        self.assertIn('public void setStats(){', stack_router)
        self.assertIn('super.setStats();', stack_router)
        self.assertIn('stats.add(Stat.itemsMoved, 60f / speed * itemCapacity, StatUnit.itemsSecond);', stack_router)
        self.assertIn('public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){', stack_router)
        self.assertIn('Draw.rect(region, plan.drawx(), plan.drawy());', stack_router)
        self.assertIn('Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);', stack_router)
        self.assertIn('public int minimapColor(Tile tile){', stack_router)
        self.assertIn('var build = (DuctRouterBuild)tile.build;', stack_router)
        self.assertIn('return build == null || build.sortItem == null ? 0 : build.sortItem.color.rgba();', stack_router)
        self.assertIn('public boolean rotatedOutput(int x, int y){', stack_router)
        self.assertIn('return false;', stack_router)
        self.assertIn('public float speed = 5f;', stack_router)
        self.assertIn('public @Load(value = "@-top") TextureRegion topRegion;', stack_router)
        self.assertIn('public @Nullable Item sortItem;', stack_router)
        self.assertIn('itemCapacity = 10;', stack_router)
        self.assertIn('public class StackRouter extends DuctRouter{', stack_router)
        self.assertIn('itemsMoved = new Stat("itemsMoved", StatCat.items),', stack_router)
        self.assertIn('itemsSecond = new StatUnit("itemsSecond"),', stack_router)
        self.assertIn('surgeRouter = new StackRouter("surge-router"){{', stack_router)
        self.assertIn('speed = 6f;', stack_router)
        self.assertIn('ductRouter = new DuctRouter("duct-router"){{', stack_router)
        self.assertIn('speed = 4f;', stack_router)
        self.assertIn('surgeAlloy = new Item("surge-alloy", Color.valueOf("f3e979")){{', stack_router)
        self.assertIn('public int rgba(){', stack_router)
        self.assertIn('return rgba8888();', stack_router)
        # The documented limits record the stats/plan
        # rows as live.
        self.assertIn('Stats/plan rows live (N2442)', stack_router)
        # The proof's keys drive the two pures (the
        # stats math at the class defaults 60/5*10 =
        # 120 plus the surge-router 60/6*10 = 100 and
        # duct-router 60/4*1 = 15 def rates, the
        # exact Stat / StatUnit tokens, the plan base
        # + top rects with the top at rotation * 90,
        # the minimap color 0 when the sort item is
        # null vs the surge-alloy rgba int when set,
        # and rotatedOutput false).
        proof = STACK_ROUTER_STATS_PLAN_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_math',
            'stats_tokens',
            'plan_base',
            'plan_top_rotdeg',
            'plan_minimap',
            'plan_rotated_output',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceStackRouterBuildState.gd")', proof)
        self.assertTrue(STACK_ROUTER_STATE.exists())
        self.assertTrue(STACK_ROUTER_STATS_PLAN_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07StackRouterStatsPlanRowsProof.gd', STACK_ROUTER_STATS_PLAN_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_stack_router_stats_plan_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07StackRouterStatsPlanRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_STACK_ROUTER_STATS_PLAN_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_math',
            'stats_tokens',
            'plan_base',
            'plan_top_rotdeg',
            'plan_minimap',
            'plan_rotated_output',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
