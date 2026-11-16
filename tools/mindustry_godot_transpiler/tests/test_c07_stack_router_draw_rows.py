import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_ROUTER_STATE = ROOT / 'godot-mindustry/src/game/SourceStackRouterBuildState.gd'
STACK_ROUTER_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterDrawRowsProof.gd'
STACK_ROUTER_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterDrawRowsProof.tscn'


class C07StackRouterDrawRowsTests(unittest.TestCase):
    def test_c07_stack_router_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2433']['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_draw_state')
        # The StackRouter tick is live (N2181 power.status
        # row + N2240 updateTile advance + N2324 target()
        # selection + N2332 acceptItem gate) but NOTHING
        # modeled draw(): drawCached() calls the parent
        # DuctRouter draw() (StackRouter.java:73-75),
        # draw() glows additive by power.status
        # (:78-87), and drawSelect() is the parent
        # super.drawSelect() + drawItemSelection(sortItem)
        # (DuctRouter.java:93-99). N2433 ports all three
        # as ONE pure-only draw pure, the N2431
        # precedent: draw is never called by the tick,
        # so the pure takes caller-supplied inputs
        # (frame x / y / rotation / sort item / power
        # status, the glow found flag, the glow color /
        # alpha) and returns the draw calls as data.
        # The icons rows ride the draw pure (icons()
        # takes no args and the SSOT schema validator
        # requires non-empty input keys, the N2396
        # precedent). Six new result symbols: the
        # cached base / sort / top calls, the glow
        # call (null when the gate fails), the select
        # call (super recorded + drawItemSelection
        # recorded as a CALL) and the icon regions.
        self.assertEqual(
            ledger['N2433']['source_symbols'],
            [
                'source_stack_router_draw_state_result.cached_base_call',
                'source_stack_router_draw_state_result.cached_sort_call',
                'source_stack_router_draw_state_result.cached_top_call',
                'source_stack_router_draw_state_result.glow_call',
                'source_stack_router_draw_state_result.select_call',
                'source_stack_router_draw_state_result.icon_regions',
            ],
        )
        expected_sources = {
            'source_stack_router_draw_state_result.cached_base_call': 'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'source_stack_router_draw_state_result.cached_sort_call': 'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'source_stack_router_draw_state_result.cached_top_call': 'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'source_stack_router_draw_state_result.glow_call': 'core/src/mindustry/world/blocks/distribution/StackRouter.java',
            'source_stack_router_draw_state_result.select_call': 'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'source_stack_router_draw_state_result.icon_regions': 'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
        }
        for name in ledger['N2433']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackRouterBuildState.source_stack_router_'))
        self.assertEqual(ledger['N2433']['runtime_proof'], '/root/C07StackRouterDrawRowsProof')
        self.assertEqual(
            ledger['N2433']['tests'],
            [
                'test_c07_stack_router_draw_rows_registration',
                'test_all_c07_stack_router_draw_rows_input_evidence_is_exact',
                'test_stack_router_draw_rows_state',
                'test_reference_graph_and_actual_c07_stack_router_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2433']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #68 (1-based in
        # the merged advances-26 DEFERRED base): the
        # StackRouter draw / drawCached rows entry is
        # REMOVED -- the cached parent draw (base rect
        # + sort center / top rect), the glow by
        # power.status and the parent drawSelect are
        # all live now, so nothing of the entry
        # remains. Net 273 - 1 = 272. The setStats /
        # icons / drawPlanRegion entry (#70) STAYS:
        # icons() rides this draw pure as the
        # icon_regions key, but setStats /
        # drawPlanRegion / minimapColor / rotatedOutput
        # still wait for their own slice (the
        # coordinator refines that entry at
        # integration).
        self.assertFalse(any(entry.startswith('StackRouter draw / drawCached rows (') for entry in ledger['N2433']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter config / sortItem rows (') for entry in ledger['N2433']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter setStats / icons / drawPlanRegion rows (') for entry in ledger['N2433']['deferred_exprs']))
        self.assertEqual(len(ledger['N2433']['deferred_exprs']), 272)

    def test_all_c07_stack_router_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2433']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackRouterBuildState.source_stack_router_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/StackRouter.java',
            'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/graphics/Pal.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2433']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stack_router_draw_rows_state(self):
        stack_router = STACK_ROUTER_STATE.read_text(encoding='utf-8')
        # The draw rows (StackRouterBuild.drawCached(),
        # StackRouter.java:73-75, + draw(), :78-87, +
        # the parent DuctRouterBuild.draw(),
        # DuctRouter.java:83-92, + drawSelect(),
        # :93-99): drawCached() calls super.draw() --
        # the DuctRouter draw, base rect + sort center
        # when sortItem != null else the top rect at
        # rotdeg() -- and draw() glows additive when
        # the glow region is found AND power != null
        # AND power.status > 0, with alpha glowAlpha *
        # power.status at Layer.blockAdditive, the rect
        # at rotation * 90. drawSelect() records
        # super.drawSelect() + drawItemSelection(
        # sortItem), which draws the item icon only
        # when the selection is non-null
        # (BuildingComp.java:1249-1250). The icons rows
        # (DuctRouter.java:55-57) return {region,
        # topRegion} and ride the draw pure. rotdeg()
        # is rotation * 90 (BuildingComp.java:582-584)
        # and rotation is the transient int
        # (BuildingComp.java:69). glowAlpha is 1f and
        # glowColor is Pal.redLight ("feb380",
        # Pal.java:138) -- the single surge-router def
        # (Blocks.java:2255-2268) sets NEITHER, so
        # both take the class defaults. Pure-only: the
        # tick never calls draw (drawCached/draw are
        # called by the renderer, drawSelect by the
        # UI), and drawItemSelection is recorded as a
        # call, not modeled. Keep each Java expr on
        # ONE comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_stack_router_draw_state', stack_router)
        self.assertIn('public void drawCached(){', stack_router)
        self.assertIn('super.draw();', stack_router)
        self.assertIn('public void draw(){', stack_router)
        self.assertIn('if(glowRegion.found() && power != null && power.status > 0){', stack_router)
        self.assertIn('Draw.z(Layer.blockAdditive);', stack_router)
        self.assertIn('Draw.color(glowColor, glowAlpha * power.status);', stack_router)
        self.assertIn('Draw.blend(Blending.additive);', stack_router)
        self.assertIn('Draw.rect(glowRegion, x, y, rotation * 90);', stack_router)
        self.assertIn('Draw.blend();', stack_router)
        self.assertIn('Draw.color();', stack_router)
        self.assertIn('public @Load(value = "@-glow", fallback = "arrow-glow") TextureRegion glowRegion;', stack_router)
        self.assertIn('public float glowAlpha = 1f;', stack_router)
        self.assertIn('public Color glowColor = Pal.redLight;', stack_router)
        self.assertIn('drawDynamic = true;', stack_router)
        self.assertIn('Draw.rect(region, x, y);', stack_router)
        self.assertIn('if(sortItem != null){', stack_router)
        self.assertIn('Draw.color(sortItem.color);', stack_router)
        self.assertIn('Draw.rect("center", x, y);', stack_router)
        self.assertIn('Draw.rect(topRegion, x, y, rotdeg());', stack_router)
        self.assertIn('public void drawSelect(){', stack_router)
        self.assertIn('super.drawSelect();', stack_router)
        self.assertIn('drawItemSelection(sortItem);', stack_router)
        self.assertIn('public TextureRegion[] icons(){', stack_router)
        self.assertIn('return new TextureRegion[]{region, topRegion};', stack_router)
        self.assertIn('public @Load(value = "@-top") TextureRegion topRegion;', stack_router)
        self.assertIn('public @Nullable Item sortItem;', stack_router)
        self.assertIn('drawCached = true;', stack_router)
        self.assertIn('public float rotdeg(){', stack_router)
        self.assertIn('return rotation * 90;', stack_router)
        self.assertIn('public void drawItemSelection(@Nullable UnlockableContent selection){', stack_router)
        self.assertIn('if(selection != null){', stack_router)
        self.assertIn('transient int rotation;', stack_router)
        self.assertIn('surgeRouter = new StackRouter("surge-router"){{', stack_router)
        self.assertIn('consumePower(3f / 60f);', stack_router)
        self.assertIn('redLight = Color.valueOf("feb380"),', stack_router)
        # The def constants (verified first): the glow
        # alpha is 1f and the glow color is Pal.redLight
        # (the class defaults -- the single surge-router
        # def sets neither).
        self.assertIn('SOURCE_STACK_ROUTER_GLOW_ALPHA := 1.0', stack_router)
        self.assertIn('SOURCE_STACK_ROUTER_GLOW_COLOR := "Pal.redLight"', stack_router)
        # The documented limits record the draw rows as
        # live (the old "No draw/config modeling" text
        # is gone -- config still waits, draw does not).
        self.assertIn('Draw rows live (N2433)', stack_router)
        self.assertNotIn('No draw/config modeling', stack_router)
        # The proof's keys drive the draw pure (the
        # cached sort-item branch with the center rect
        # in the sort item color, the cached top branch
        # at rotdeg, the glow gate on/off incl. the
        # power-null -1 sentinel and the strict > 0
        # gate, the glow alpha math glowAlpha *
        # power.status at rotation * 90, the select
        # call with the recorded super + item
        # selection, and the icon regions).
        proof = STACK_ROUTER_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_cached_sort_item',
            'draw_cached_top',
            'draw_glow_gate',
            'draw_glow_alpha',
            'draw_select_call',
            'draw_icons',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceStackRouterBuildState.gd")', proof)
        self.assertTrue(STACK_ROUTER_STATE.exists())
        self.assertTrue(STACK_ROUTER_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07StackRouterDrawRowsProof.gd', STACK_ROUTER_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_stack_router_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07StackRouterDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_STACK_ROUTER_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_cached_sort_item',
            'draw_cached_top',
            'draw_glow_gate',
            'draw_glow_alpha',
            'draw_select_call',
            'draw_icons',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
