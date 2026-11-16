import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
IMPACT_REACTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceImpactReactorBuildState.gd'
IMPACT_REACTOR_DRAW_PLAN_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorDrawPlanRowsProof.gd'
IMPACT_REACTOR_DRAW_PLAN_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorDrawPlanRowsProof.tscn'


class C07ImpactReactorDrawPlanRowsTests(unittest.TestCase):
    def test_c07_impact_reactor_draw_plan_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2438']['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_draw_plan_state')
        # The ImpactReactor draw rows are live (N2430)
        # but drawPlanRegion() was NOT ported there:
        # PowerGenerator.drawPlanRegion() is
        # `drawer.drawPlan(this, plan, list);`
        # (PowerGenerator.java:84-85) through the SAME
        # DrawMulti class-default drawer
        # (ImpactReactor.java:34) -- DrawRegion(
        # "-bottom"), DrawPlasma(), DrawDefault() --
        # and DrawMulti.drawPlan iterates in drawer
        # order (DrawMulti.java:40-43). N2438 ports it
        # as ONE pure-only plan pure (the N2419
        # Separator precedent): the generator
        # delegation call + the -bottom plan rect +
        # the (empty) plasma plan call + the default
        # plan region + the team overlay. Five new
        # result symbols.
        self.assertEqual(
            ledger['N2438']['source_symbols'],
            [
                'source_impact_reactor_draw_plan_state_result.plan_generator_call',
                'source_impact_reactor_draw_plan_state_result.plan_bottom_call',
                'source_impact_reactor_draw_plan_state_result.plan_plasma_call',
                'source_impact_reactor_draw_plan_state_result.plan_call',
                'source_impact_reactor_draw_plan_state_result.plan_team_call',
            ],
        )
        slice_sources = {
            'core/src/mindustry/world/blocks/power/ImpactReactor.java',
            'core/src/mindustry/world/blocks/power/PowerGenerator.java',
            'core/src/mindustry/world/draw/DrawMulti.java',
            'core/src/mindustry/world/draw/DrawRegion.java',
            'core/src/mindustry/world/draw/DrawPlasma.java',
            'core/src/mindustry/world/draw/DrawDefault.java',
            'core/src/mindustry/world/draw/DrawBlock.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        for name in ledger['N2438']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], slice_sources)
                self.assertTrue(symbol['godot_owner'].startswith('SourceImpactReactorBuildState.source_impact_reactor_'))
        self.assertEqual(ledger['N2438']['runtime_proof'], '/root/C07ImpactReactorDrawPlanRowsProof')
        self.assertEqual(
            ledger['N2438']['tests'],
            [
                'test_c07_impact_reactor_draw_plan_rows_registration',
                'test_all_c07_impact_reactor_draw_plan_rows_input_evidence_is_exact',
                'test_impact_reactor_draw_plan_rows_state',
                'test_reference_graph_and_actual_c07_impact_reactor_draw_plan_rows',
            ],
        )
        self.assertTrue(ledger['N2438']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #272 (1-based in
        # DEFERRED-after-advances-26.py): the
        # ImpactReactor drawPlan rows entry is REMOVED
        # -- the -bottom plan rect / the DrawDefault
        # plan region / the PowerGenerator delegation
        # are live now, so nothing of the entry
        # remains. Net 273 - 1 = 272.
        self.assertFalse(any(entry.startswith('ImpactReactor drawPlan rows') for entry in ledger['N2438']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor read/write rows (warmup, ImpactReactor.java:130-140') for entry in ledger['N2438']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor per-def stat rows (size 4, health 900') for entry in ledger['N2438']['deferred_exprs']))
        self.assertEqual(len(ledger['N2438']['deferred_exprs']), 272)

    def test_all_c07_impact_reactor_draw_plan_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2438']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceImpactReactorBuildState.source_impact_reactor_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/power/ImpactReactor.java',
            'core/src/mindustry/world/blocks/power/PowerGenerator.java',
            'core/src/mindustry/world/draw/DrawMulti.java',
            'core/src/mindustry/world/draw/DrawRegion.java',
            'core/src/mindustry/world/draw/DrawPlasma.java',
            'core/src/mindustry/world/draw/DrawDefault.java',
            'core/src/mindustry/world/draw/DrawBlock.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2438']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_impact_reactor_draw_plan_rows_state(self):
        impact_reactor = IMPACT_REACTOR_STATE.read_text(encoding='utf-8')
        # The drawPlan rows (PowerGenerator.
        # drawPlanRegion(), PowerGenerator.java:84-85,
        # `drawer.drawPlan(this, plan, list);`) run the
        # DrawMulti class-default drawer
        # (ImpactReactor.java:34), in order:
        # DrawRegion("-bottom") rects its plan region
        # at (plan.drawx(), plan.drawy()) with
        # rotation 0 (buildingRotate false, rotation
        # 0); DrawPlasma() draws NOTHING in the plan
        # (no drawPlan() override in DrawPlasma or its
        # parent DrawFlame -- the base is the no-op
        # DrawBlock.drawPlan); DrawDefault draws the
        # default plan region
        # (`block.drawDefaultPlanRegion(plan, list);`,
        # DrawDefault.java:18) -- the fullIcon rect at
        # the plan position, rotation 0 (ImpactReactor
        # sets no rotate), then the team overlay, only
        # in a world context with a player and a found
        # team region, coloring the team color only
        # when the team's region IS the base team
        # region -- and finally drawPlanConfig, the
        # base no-op, so the plan carries no config
        # call. Pure-only: the tick never plans.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_impact_reactor_draw_plan_state', impact_reactor)
        self.assertIn('drawer = new DrawMulti(new DrawRegion("-bottom"), new DrawPlasma(), new DrawDefault());', impact_reactor)
        self.assertIn('public DrawBlock drawer = new DrawDefault();', impact_reactor)
        self.assertIn('drawer.drawPlan(this, plan, list);', impact_reactor)
        self.assertIn('for(var draw : drawers){', impact_reactor)
        self.assertIn('draw.drawPlan(block, plan, list);', impact_reactor)
        self.assertIn('if(!drawPlan) return;', impact_reactor)
        self.assertIn('Draw.rect(region, plan.drawx()+ x, plan.drawy() + y, (buildingRotate ? plan.rotation * 90f : 0 + rotation));', impact_reactor)
        self.assertIn('region = Core.atlas.find(name != null ? name : block.name + suffix);', impact_reactor)
        self.assertIn('public class DrawPlasma extends DrawFlame{', impact_reactor)
        self.assertIn('public void drawPlan(Block block, BuildPlan plan, Eachable<BuildPlan> list){', impact_reactor)
        self.assertIn('block.drawDefaultPlanRegion(plan, list);', impact_reactor)
        self.assertIn('TextureRegion reg = getPlanRegion(plan, list);', impact_reactor)
        self.assertIn('Draw.rect(reg, plan.drawx(), plan.drawy(), !rotate || !rotateDraw ? 0 : plan.rotation * 90);', impact_reactor)
        self.assertIn('if(plan.worldContext && player != null && teamRegion != null && teamRegion.found()){', impact_reactor)
        self.assertIn('if(teamRegions[player.team().id] == teamRegion) Draw.color(player.team().color, a);', impact_reactor)
        self.assertIn('Draw.rect(teamRegions[player.team().id], plan.drawx(), plan.drawy());', impact_reactor)
        self.assertIn('return fullIcon;', impact_reactor)
        self.assertIn('public void drawPlanConfig(BuildPlan plan, Eachable<BuildPlan> list){', impact_reactor)
        self.assertIn('public boolean rotate;', impact_reactor)
        self.assertIn('impactReactor = new ImpactReactor("impact-reactor"){{', impact_reactor)
        self.assertIn('size = 4;', impact_reactor)
        # The documented limits record the drawPlan
        # rows as live (the old "drawPlanRegion waits
        # for its own slice" text is gone -- the plan
        # pure is live now).
        self.assertIn('DrawPlan rows live (N2438)', impact_reactor)
        self.assertNotIn('drawPlanRegion waits for its own slice', impact_reactor)
        # The proof's keys drive the plan pure (the
        # bottom plan rect, the default plan region,
        # the generator delegation + the empty plasma
        # call, the team overlay on + off, the plan
        # rotation fold to 0).
        proof = IMPACT_REACTOR_DRAW_PLAN_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_plan_bottom',
            'draw_plan_default',
            'draw_plan_generator',
            'draw_plan_team_on',
            'draw_plan_team_off',
            'draw_plan_rotation',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceImpactReactorBuildState.gd")', proof)
        self.assertTrue(IMPACT_REACTOR_STATE.exists())
        self.assertTrue(IMPACT_REACTOR_DRAW_PLAN_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07ImpactReactorDrawPlanRowsProof.gd', IMPACT_REACTOR_DRAW_PLAN_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_impact_reactor_draw_plan_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ImpactReactorDrawPlanRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_IMPACT_REACTOR_DRAW_PLAN_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_plan_bottom',
            'draw_plan_default',
            'draw_plan_generator',
            'draw_plan_team_on',
            'draw_plan_team_off',
            'draw_plan_rotation',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
