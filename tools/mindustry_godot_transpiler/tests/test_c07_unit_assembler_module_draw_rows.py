import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_ASSEMBLER_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitAssemblerModuleBuildState.gd'
UNIT_ASSEMBLER_MODULE_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleDrawRowsProof.gd'
UNIT_ASSEMBLER_MODULE_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleDrawRowsProof.tscn'


class C07UnitAssemblerModuleDrawRowsTests(unittest.TestCase):
    def test_c07_unit_assembler_module_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2425']['godot_owner'], 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_draw_state')
        # The UnitAssemblerModule tick is live (N2248
        # advance + N2299 acceptPayload + N2314 handoff
        # gate + N2345 canPlaceOn + N2348 tier stamp +
        # N2351 checkTier wiring + N2358 getLink
        # discovery + N2370 moduleFits wiring + N2381
        # flagged fill) but NOTHING modeled draw():
        # the base rect + the blends-gated input side
        # regions + the always-drawn side region + the
        # payload draw on Layer.blockOver + the top
        # rect on Layer.blockOver + 0.1f
        # (UnitAssemblerModule.java:90-108), drawPlace
        # (:38-45, super + the link delegation),
        # drawPlanRegion (:54-58) or icons() (:59-63).
        # N2425 ports draw() + drawPlace +
        # drawPlanRegion + icons() as ONE pure-only draw
        # pure, the N2396 MassDriver pattern: draw is
        # never called by the tick, so the pure takes
        # caller-supplied inputs (x / y / rotation /
        # blends + the payload + the link + the plan)
        # and returns the draw calls as data, with the
        # icons riding the pure as the icon_regions
        # result key (a pure icons() 0-arg FAILS the
        # register because the validator requires input
        # keys non-empty). Eight new result symbols:
        # the base call, the input calls, the side call,
        # the payload call, the top call, the place
        # call, the plan call, and the icon regions.
        self.assertEqual(
            ledger['N2425']['source_symbols'],
            [
                'source_unit_assembler_module_draw_state_result.base_call',
                'source_unit_assembler_module_draw_state_result.input_calls',
                'source_unit_assembler_module_draw_state_result.side_call',
                'source_unit_assembler_module_draw_state_result.payload_call',
                'source_unit_assembler_module_draw_state_result.top_call',
                'source_unit_assembler_module_draw_state_result.place_call',
                'source_unit_assembler_module_draw_state_result.plan_call',
                'source_unit_assembler_module_draw_state_result.icon_regions',
            ],
        )
        for name in ledger['N2425']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                if name.endswith('.payload_call'):
                    self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java')
                else:
                    self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_'))
        self.assertEqual(ledger['N2425']['runtime_proof'], '/root/C07UnitAssemblerModuleDrawRowsProof')
        self.assertEqual(
            ledger['N2425']['tests'],
            [
                'test_c07_unit_assembler_module_draw_rows_registration',
                'test_all_c07_unit_assembler_module_draw_rows_input_evidence_is_exact',
                'test_unit_assembler_module_draw_rows_state',
                'test_reference_graph_and_actual_c07_unit_assembler_module_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2425']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #31 (1-based in
        # DEFERRED-after-advances-25.py): the
        # UnitAssemblerModule draw / drawPlace /
        # drawPlanRegion / icons rows entry is REMOVED
        # -- draw() + drawPlace + drawPlanRegion +
        # icons() are live now, so nothing of the entry
        # remains. Net 280 - 1 = 279.
        self.assertFalse(any(entry.startswith('UnitAssemblerModule draw / drawPlace / drawPlanRegion / icons rows (draw side regions / payload / top region, UnitAssemblerModule.java:31-50, 59-63, 90-108; icons, UnitAssemblerModule.java:59-63)') for entry in ledger['N2425']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule onRemoved / drawSelect rows (removeModule on remove, UnitAssemblerModule.java:111-115; drawSelect link highlight, UnitAssemblerModule.java:118-123)') for entry in ledger['N2425']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule link / findLink rows (getLink over the flagged unitAssembler builds, UnitAssemblerModule.java:65-69; findLink / removeModule / updateModules, UnitAssemblerModule.java:75-83; moduleFits, UnitAssembler.java:338)') for entry in ledger['N2425']['deferred_exprs']))
        self.assertEqual(len(ledger['N2425']['deferred_exprs']), 279)

    def test_all_c07_unit_assembler_module_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2425']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/units/BuildPlan.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2425']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_assembler_module_draw_rows_state(self):
        unit_assembler_module = UNIT_ASSEMBLER_MODULE_STATE.read_text(encoding='utf-8')
        # The draw rows (UnitAssemblerModuleBuild.draw(),
        # UnitAssemblerModule.java:90-108): `Draw.rect(
        # region, x, y);` always, then the input side
        # regions (`for(int i = 0; i < 4; i++){` +
        # `if(blends(i) && i != rotation){` +
        # `drawSideRegion(inRegion, x, y, i - 2);`),
        # then the always-drawn side region
        # (`drawSideRegion(rotation >= 2 ? sideRegion2
        # : sideRegion1, x, y, rotation);`), then
        # `Draw.z(Layer.blockOver);` + `payRotation =
        # rotdeg();` + `drawPayload();`, then `Draw.z(
        # Layer.blockOver + 0.1f);` + `Draw.rect(
        # topRegion, x, y);` always. drawPlace
        # (UnitAssemblerModule.java:38-45) is the super
        # call (`super.drawPlace(x, y, rotation,
        # valid);`) plus the link delegation (`var link
        # = getLink(player.team(), x, y, rotation);` +
        # `if(link != null){` + `link.block.drawPlace(
        # link.tile.x, link.tile.y, link.rotation,
        # true);`). drawPlanRegion (:54-58) rects the
        # base + the side region + the top at the plan
        # position (`Draw.rect(region, plan.drawx(),
        # plan.drawy());` + `drawSideRegion(plan.
        # rotation >= 2 ? sideRegion2 : sideRegion1,
        # plan.drawx(), plan.drawy(), plan.rotation);`
        # + `Draw.rect(topRegion, plan.drawx(), plan.
        # drawy());`). icons() (`public TextureRegion[]
        # icons(){` / `return new TextureRegion[]{region,
        # topRegion};`, :59-63) rides the pure as
        # icon_regions (the N2396 precedent -- a pure
        # icons() 0-arg FAILS the register).
        # drawPayload() (PayloadBlock.java:246-253)
        # draws the HELD payload when present (`if(
        # payload != null){` + `updatePayload();` +
        # `Draw.z(Layer.blockOver);` + `payload.draw();`
        # ). blends(i) is the PayloadBlock neighbour
        # check (PayloadBlock.java:170-172, `return
        # PayloadBlock.blends(this, direction);`) -- the
        # pure takes the 4 verdicts as an explicit Array
        # input (the neighbour query waits for its own
        # slice). drawSideRegion (Block.java:497-505)
        # places the region at the side edge (`var p =
        # Geometry.d4[Mathf.mod(rotation, 4)];` + `float
        # s = size * tilesize/2f;`) -- the edge geometry
        # is the canonical SourceBlockDrawState pure
        # (region.width / region.scl are atlas values),
        # so this pure reports the calls symbolically
        # (region token + center + rotation + the
        # draw rotation). rotdeg() is rotation * 90
        # (BuildingComp.java:582-584). The plan
        # drawx/drawy are x*tilesize + block.offset
        # (BuildPlan.java:142-148). The module has NO
        # drawer field -- draw() is a direct override,
        # not a drawer dispatch (the N2419 lesson).
        # Pure-only: the tick never calls draw (draw is
        # called by the renderer), drawPlace/drawPlan-
        # Region by the placement UI, icons by the atlas.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_unit_assembler_module_draw_state', unit_assembler_module)
        self.assertIn('Draw.rect(region, x, y);', unit_assembler_module)
        self.assertIn('for(int i = 0; i < 4; i++){', unit_assembler_module)
        self.assertIn('if(blends(i) && i != rotation){', unit_assembler_module)
        self.assertIn('drawSideRegion(inRegion, x, y, i - 2);', unit_assembler_module)
        self.assertIn('drawSideRegion(rotation >= 2 ? sideRegion2 : sideRegion1, x, y, rotation);', unit_assembler_module)
        self.assertIn('Draw.z(Layer.blockOver);', unit_assembler_module)
        self.assertIn('payRotation = rotdeg();', unit_assembler_module)
        self.assertIn('drawPayload();', unit_assembler_module)
        self.assertIn('Draw.z(Layer.blockOver + 0.1f);', unit_assembler_module)
        self.assertIn('Draw.rect(topRegion, x, y);', unit_assembler_module)
        self.assertIn('super.drawPlace(x, y, rotation, valid);', unit_assembler_module)
        self.assertIn('var link = getLink(player.team(), x, y, rotation);', unit_assembler_module)
        self.assertIn('if(link != null){', unit_assembler_module)
        self.assertIn('link.block.drawPlace(link.tile.x, link.tile.y, link.rotation, true);', unit_assembler_module)
        self.assertIn('Draw.rect(region, plan.drawx(), plan.drawy());', unit_assembler_module)
        self.assertIn('drawSideRegion(plan.rotation >= 2 ? sideRegion2 : sideRegion1, plan.drawx(), plan.drawy(), plan.rotation);', unit_assembler_module)
        self.assertIn('Draw.rect(topRegion, plan.drawx(), plan.drawy());', unit_assembler_module)
        self.assertIn('public TextureRegion[] icons(){', unit_assembler_module)
        self.assertIn('return new TextureRegion[]{region, topRegion};', unit_assembler_module)
        self.assertIn('public @Load("@-side1") TextureRegion sideRegion1;', unit_assembler_module)
        self.assertIn('public @Load("@-side2") TextureRegion sideRegion2;', unit_assembler_module)
        self.assertIn('public void drawPayload(){', unit_assembler_module)
        self.assertIn('if(payload != null){', unit_assembler_module)
        self.assertIn('updatePayload();', unit_assembler_module)
        self.assertIn('payload.draw();', unit_assembler_module)
        self.assertIn('public boolean blends(int direction){', unit_assembler_module)
        self.assertIn('return PayloadBlock.blends(this, direction);', unit_assembler_module)
        self.assertIn('public @Nullable T payload;', unit_assembler_module)
        self.assertIn('public TextureRegion topRegion, outRegion, inRegion;', unit_assembler_module)
        self.assertIn('public Vec2 payVector = new Vec2();', unit_assembler_module)
        self.assertIn('public float payRotation;', unit_assembler_module)
        self.assertIn('public void drawSideRegion(TextureRegion region, float x, float y, int rotation){', unit_assembler_module)
        self.assertIn('var p = Geometry.d4[Mathf.mod(rotation, 4)];', unit_assembler_module)
        self.assertIn('float s = size * tilesize/2f;', unit_assembler_module)
        self.assertIn('public float rotdeg(){', unit_assembler_module)
        self.assertIn('return rotation * 90;', unit_assembler_module)
        self.assertIn('public float drawx(){', unit_assembler_module)
        self.assertIn('return x*tilesize + (block == null ? 0 : block.offset);', unit_assembler_module)
        self.assertIn('public float drawy(){', unit_assembler_module)
        self.assertIn('return y*tilesize + (block == null ? 0 : block.offset);', unit_assembler_module)
        self.assertIn('size = 5;', unit_assembler_module)
        # The documented limits record the draw rows as
        # live (the old "No link/draw/onRemoved rows"
        # text is gone -- link rows are live since
        # N2358/N2381, draw rows live now, onRemoved /
        # drawSelect still defer).
        self.assertIn('Draw rows live (N2425)', unit_assembler_module)
        self.assertNotIn('No link/draw/onRemoved rows', unit_assembler_module)
        # The proof's keys drive the draw pure (the
        # base rect + input side regions, the payload
        # branch, the top region, the drawPlace link /
        # no-link delegation, the drawPlanRegion plan
        # calls, the merged icons).
        proof = UNIT_ASSEMBLER_MODULE_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_base_inputs',
            'draw_payload_branch',
            'draw_top_region',
            'draw_place_link',
            'draw_plan_region',
            'draw_icons_merged',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")', proof)
        self.assertTrue(UNIT_ASSEMBLER_MODULE_STATE.exists())
        self.assertTrue(UNIT_ASSEMBLER_MODULE_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07UnitAssemblerModuleDrawRowsProof.gd', UNIT_ASSEMBLER_MODULE_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_unit_assembler_module_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitAssemblerModuleDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_ASSEMBLER_MODULE_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_base_inputs',
            'draw_payload_branch',
            'draw_top_region',
            'draw_place_link',
            'draw_plan_region',
            'draw_icons_merged',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
