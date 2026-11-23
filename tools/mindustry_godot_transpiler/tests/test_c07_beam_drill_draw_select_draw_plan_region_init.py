import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_DRAW_SELECT_DRAW_PLAN_REGION_INIT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillDrawSelectDrawPlanRegionInitProof.gd'


class C07BeamDrillDrawSelectDrawPlanRegionInitTests(unittest.TestCase):
    def test_c07_beam_drill_draw_select_draw_plan_region_init_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2394']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_draw_select_state')
        # BeamDrillBuild.drawSelect() (BeamDrill.java:231-234,
        # `public void drawSelect(){`) is one line:
        # `drawItemSelection(lastItem);` -- the BuildingComp
        # selection icon for the last mined item.
        # BeamDrill.drawPlanRegion() (BeamDrill.java:113-117,
        # `public void drawPlanRegion(BuildPlan plan,
        # Eachable<BuildPlan> list){`) draws the block region
        # (`Draw.rect(region, plan.drawx(), plan.drawy());`,
        # N1411 -- NOT this slice) and the top region rotated
        # by the plan rotation (`Draw.rect(topRegion,
        # plan.drawx(), plan.drawy(), plan.rotation * 90);`).
        # BeamDrill.init() (BeamDrill.java:81-89, `public void
        # init(){`) widens the clip radius
        # (`updateClipRadius((range + 2) * tilesize);`, Block
        # .java:1006-1008) and then runs the generic
        # `super.init();` plus the blockedItems fill (N2012 /
        # N2302 -- NOT this slice). Three pure functions on
        # the existing SourceBeamDrillBuildState.gd (the N2391
        # canPlaceOn+setBars precedent): they return the
        # computed frame data and do NOT touch real Draw /
        # Drawf playback. NO driver tick line: drawSelect /
        # drawPlanRegion are selection/placement UI, init is a
        # load-time clip setup. The 3 distinguishing exprs are
        # the 0-hit lines re-probed at base d8037fbc in both
        # ledgers. The HIT lines (`Draw.rect(region,
        # plan.drawx(), plan.drawy());` N1411, `super.init();`
        # generic, the two blockedItems lines N2012/N2302) are
        # evidence only, NOT distinguishing. Seven new result
        # symbols: draw_item_selection_called, last_item,
        # draw_rect_called, top_region_rotation, plan_position,
        # clip_radius, update_clip_radius_called.
        self.assertEqual(
            ledger['N2394']['source_symbols'],
            [
                'source_beam_drill_draw_select_state_result.draw_item_selection_called',
                'source_beam_drill_draw_select_state_result.last_item',
                'source_beam_drill_draw_plan_region_state_result.draw_rect_called',
                'source_beam_drill_draw_plan_region_state_result.top_region_rotation',
                'source_beam_drill_draw_plan_region_state_result.plan_position',
                'source_beam_drill_init_state_result.clip_radius',
                'source_beam_drill_init_state_result.update_clip_radius_called',
            ],
        )
        for name in ledger['N2394']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BeamDrill.java',
                    'core/src/mindustry/Vars.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2394']['runtime_proof'], '/root/C07BeamDrillDrawSelectDrawPlanRegionInitProof')
        self.assertEqual(
            ledger['N2394']['tests'],
            [
                'test_c07_beam_drill_draw_select_draw_plan_region_init_registration',
                'test_all_c07_beam_drill_draw_select_draw_plan_region_init_input_evidence_is_exact',
                'test_beam_drill_draw_select_draw_plan_region_init_state',
                'test_reference_graph_and_actual_c07_beam_drill_draw_select_draw_plan_region_init',
            ],
        )
        self.assertTrue(ledger['N2394']['deferred_exprs'])

    def test_all_c07_beam_drill_draw_select_draw_plan_region_init_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2394']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/Vars.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2394']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_draw_select_draw_plan_region_init_state(self):
        state = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # BeamDrillBuild.drawSelect() (BeamDrill.java:231-234)
        # delegates the last-item selection icon to
        # drawItemSelection (BuildingComp.java:1249), which
        # arrives as an explicit Callable and is NOT
        # re-ported. BeamDrill.drawPlanRegion()
        # (BeamDrill.java:113-117) draws only the top region
        # here (`Draw.rect(topRegion, plan.drawx(),
        # plan.drawy(), plan.rotation * 90);`); the plain
        # region rect is N1411. BeamDrill.init()
        # (BeamDrill.java:81-89) widens the clip radius to
        # (range + 2) * tilesize through the updateClipRadius
        # Callable (Block.java:1006-1008, NOT re-ported);
        # `super.init();` and the blockedItems fill are NOT
        # this slice. NO driver tick line.
        self.assertIn('static func source_beam_drill_draw_select_state(frame: Dictionary, last_item: Variant, draw_item_selection: Callable) -> Dictionary:', state)
        self.assertIn('static func source_beam_drill_draw_plan_region_state(frame: Dictionary, plan_drawx: float, plan_drawy: float, plan_rotation: int, top_region: Variant, draw_rect: Callable) -> Dictionary:', state)
        self.assertIn('static func source_beam_drill_init_state(frame: Dictionary, range_value: int, tilesize: float, update_clip_radius: Callable) -> Dictionary:', state)
        self.assertIn('return {"draw_item_selection_called": draw_item_selection_called, "last_item": last_item}', state)
        self.assertIn('return {"draw_rect_called": draw_rect_called, "top_region_rotation": top_region_rotation, "plan_position": Vector2(plan_drawx, plan_drawy)}', state)
        self.assertIn('return {"clip_radius": clip_radius, "update_clip_radius_called": update_clip_radius_called}', state)
        for expr in [
            'drawItemSelection(lastItem);',
            'Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);',
            'updateClipRadius((range + 2) * tilesize);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure functions with
        # synthetic frames (no live tick): the selection
        # delegate receives the last item / returns it /
        # an invalid delegate is not called / the plan
        # region top rotation is rotation * 90 / the draw
        # rect delegate receives the top region at the plan
        # position / the plan position / the clip radius is
        # (range + 2) * tilesize / the clip delegate receives
        # it / the large-bore range gives 64.0 / the
        # result-key shapes.
        proof = BEAM_DRILL_DRAW_SELECT_DRAW_PLAN_REGION_INIT_PROOF.read_text(encoding='utf-8')
        for key in [
            'select_calls_delegate_with_last_item',
            'select_returns_last_item',
            'select_invalid_delegate_not_called',
            'plan_region_top_rotation',
            'plan_region_calls_draw_rect',
            'plan_region_position',
            'init_clip_radius',
            'init_calls_update_clip_radius',
            'init_large_bore_clip_radius',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_beam_drill_draw_select_draw_plan_region_init(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillDrawSelectDrawPlanRegionInitProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_DRAW_SELECT_DRAW_PLAN_REGION_INIT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'select_calls_delegate_with_last_item',
            'select_returns_last_item',
            'select_invalid_delegate_not_called',
            'plan_region_top_rotation',
            'plan_region_calls_draw_rect',
            'plan_region_position',
            'init_clip_radius',
            'init_calls_update_clip_radius',
            'init_large_bore_clip_radius',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
