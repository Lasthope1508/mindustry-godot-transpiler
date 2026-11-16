import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_CONVEYOR_STATE = ROOT / 'godot-mindustry/src/game/SourceStackConveyorBuildState.gd'
STACK_CONVEYOR_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackConveyorDrawRowsProof.gd'
STACK_CONVEYOR_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackConveyorDrawRowsProof.tscn'


class C07StackConveyorDrawRowsTests(unittest.TestCase):
    def test_c07_stack_conveyor_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2434']['godot_owner'], 'SourceStackConveyorBuildState.source_stack_conveyor_draw_state')
        # The StackConveyor tick is live (N2180 power row +
        # N2239 updateTile advance) but NOTHING modeled
        # draw() + drawCached(): the cached base rect +
        # the edge rects + the load/unload input slices
        # (StackConveyor.java:124-149) and the glow
        # branch + the interpolated stack + the sized
        # item (StackConveyor.java:151-192). N2434 ports
        # both as ONE pure-only draw pure, the N2415
        # UnitCargoLoader pattern: draw is never called
        # by the tick, so the pure takes caller-supplied
        # inputs (x / y / rotation / state / blendprox /
        # near + front squareSprite flags / link /
        # from_world / last_item / power_status /
        # glow_found / glow_color / glow_alpha / cooldown
        # / items_total / item_capacity / item_size) and
        # returns the draw calls as data. StackConveyor
        # has NO icons() override (Block.java:976 is the
        # default), so there is no icons() pure to
        # register -- and a zero-arg pure cannot register
        # (the SSOT schema validator requires non-empty
        # input keys, the N2396 precedent). Eight new
        # result symbols: the cached call, the glow call,
        # the stack call + its interpolated position +
        # angle, the item call + its size.
        self.assertEqual(
            ledger['N2434']['source_symbols'],
            [
                'source_stack_conveyor_draw_state_result.cached_call',
                'source_stack_conveyor_draw_state_result.glow_call',
                'source_stack_conveyor_draw_state_result.stack_call',
                'source_stack_conveyor_draw_state_result.item_call',
                'source_stack_conveyor_draw_state_result.stack_x',
                'source_stack_conveyor_draw_state_result.stack_y',
                'source_stack_conveyor_draw_state_result.stack_angle',
                'source_stack_conveyor_draw_state_result.item_size',
            ],
        )
        for name in ledger['N2434']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/distribution/StackConveyor.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackConveyorBuildState.source_stack_conveyor_'))
        self.assertEqual(ledger['N2434']['runtime_proof'], '/root/C07StackConveyorDrawRowsProof')
        self.assertEqual(
            ledger['N2434']['tests'],
            [
                'test_c07_stack_conveyor_draw_rows_registration',
                'test_all_c07_stack_conveyor_draw_rows_input_evidence_is_exact',
                'test_stack_conveyor_draw_rows_state',
                'test_reference_graph_and_actual_c07_stack_conveyor_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2434']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #61 (1-based in
        # DEFERRED-after-advances-26.py): the
        # StackConveyor draw / drawCached rows entry is
        # REMOVED -- draw() + drawCached() are live now,
        # so nothing of the entry remains. Net 273 - 1 =
        # 272.
        self.assertFalse(any(entry.startswith('StackConveyor draw / drawCached rows (glow alpha by power.status, StackConveyor.java:156-158') for entry in ledger['N2434']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackConveyor blends / rotatedOutput / drawPlanRegion rows') for entry in ledger['N2434']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackConveyor acceptStack / handleStack / removeStack / itemTaken / acceptItem rows') for entry in ledger['N2434']['deferred_exprs']))
        self.assertEqual(len(ledger['N2434']['deferred_exprs']), 272)

    def test_all_c07_stack_conveyor_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2434']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackConveyorBuildState.source_stack_conveyor_'))
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/distribution/StackConveyor.java'),
            ('mindustry-upstream', 'core/src/mindustry/Vars.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/Autotiler.java'),
            ('arc-upstream', 'arc-core/src/arc/math/Interp.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Geometry.java'),
            ('arc-upstream', 'arc-core/src/arc/math/Mathf.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2434']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stack_conveyor_draw_rows_state(self):
        stack_conveyor = STACK_CONVEYOR_STATE.read_text(encoding='utf-8')
        # The draw rows (StackConveyorBuild.drawCached(),
        # StackConveyor.java:124-149 + draw(),
        # StackConveyor.java:151-192): drawCached rects
        # regions[state] at rotdeg(), the edge rects
        # where the blendprox bit is clear, the sliced
        # bottom inputs while stateLoad and the sliced
        # top front rect while stateUnload; draw sets z
        # Layer.block - 0.1f, glows additively by
        # power.status when the glow region is found,
        # returns early when link == -1 or from == null
        # or lastItem == null, then interpolates the
        # stack position from the link tile with
        # Interp.linear at 1 - cooldown and lerps its
        # angle with Interp.smooth at 1 - clamp(
        # cooldown * 2, 0, 1), and draws the last item
        # at itemSize * lerp(min(items.total() /
        # itemCapacity, 1), 1, 0.4). The state constants
        # are stateMove 0 / stateLoad 1 / stateUnload 2
        # (StackConveyor.java:25); regions[state] is the
        # `@-#` length-3 array (StackConveyor.java:27);
        # itemSize is 5f (Vars.java:115), tilesize is 8
        # (Vars.java:135 -- NEVER the game tile_size 32,
        # the N2375 lesson); glowAlpha 1f / glowColor
        # Pal.redLight (StackConveyor.java:34-35, no def
        # override -- neither plastanium-conveyor nor
        # surge-conveyor, Blocks.java:2084/2237, sets
        # them); Interp.smooth is a * a * (3 - 2 * a)
        # (arc Interp.java:11) and Interp.linear is the
        # identity (arc Interp.java:8); d4x is {1, 0,
        # -1, 0} and d4y is {0, 1, 0, -1} (arc Geometry.
        # java:24-25); Mathf.mod wraps negatives (arc
        # Mathf.java:579-581), so GDScript posmod is the
        # exact match; rotdeg() is rotation * 90
        # (BuildingComp.java:582-584); sliced bottom/top
        # are botHalf/topHalf (Autotiler.java:55-57).
        # Pure-only: the tick never calls draw -- draw
        # is called by the renderer.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_stack_conveyor_draw_state', stack_conveyor)
        self.assertIn('protected static final int stateMove = 0, stateLoad = 1, stateUnload = 2;', stack_conveyor)
        self.assertIn('public @Load(value = "@-#", length = 3) TextureRegion[] regions;', stack_conveyor)
        self.assertIn('public @Load("@-edge") TextureRegion edgeRegion;', stack_conveyor)
        self.assertIn('public @Load("@-stack") TextureRegion stackRegion;', stack_conveyor)
        self.assertIn('public @Load(value = "@-glow") TextureRegion glowRegion;', stack_conveyor)
        self.assertIn('public @Load(value = "@-edge-glow", fallback = "@-glow") TextureRegion edgeGlowRegion;', stack_conveyor)
        self.assertIn('public float glowAlpha = 1f;', stack_conveyor)
        self.assertIn('public Color glowColor = Pal.redLight;', stack_conveyor)
        self.assertIn('public void drawCached(){', stack_conveyor)
        self.assertIn('Draw.rect(regions[state], x, y, rotdeg());', stack_conveyor)
        self.assertIn('if((blendprox & (1 << i)) == 0){', stack_conveyor)
        self.assertIn('Draw.rect(edgeRegion, x, y, (rotation - i) * 90);', stack_conveyor)
        self.assertIn('if(state == stateLoad){', stack_conveyor)
        self.assertIn('int dir = Mathf.mod(rotation - i, 4);', stack_conveyor)
        self.assertIn('var near = nearby(dir);', stack_conveyor)
        self.assertIn('if((blendprox & (1 << i)) != 0 && i != 0 && near != null && !near.block.squareSprite){', stack_conveyor)
        self.assertIn('Draw.rect(sliced(regions[0], SliceMode.bottom), x + Geometry.d4x(dir) * tilesize*0.75f, y + Geometry.d4y(dir) * tilesize*0.75f, (float)(dir*90));', stack_conveyor)
        self.assertIn('}else if(state == stateUnload){ //front unload', stack_conveyor)
        self.assertIn('if((blendprox & (1)) != 0 && front() != null && !front().block.squareSprite){', stack_conveyor)
        self.assertIn('Draw.rect(sliced(regions[0], SliceMode.top), x + Geometry.d4x(rotation) * tilesize*0.75f, y + Geometry.d4y(rotation) * tilesize*0.75f, rotation * 90f);', stack_conveyor)
        self.assertIn('public void draw(){', stack_conveyor)
        self.assertIn('Draw.z(Layer.block - 0.1f);', stack_conveyor)
        self.assertIn('Tile from = world.tile(link);', stack_conveyor)
        self.assertIn('if(glowRegion.found() && power != null && power.status > 0f){', stack_conveyor)
        self.assertIn('Draw.color(glowColor, glowAlpha * power.status);', stack_conveyor)
        self.assertIn('Draw.rect(state == stateLoad ? edgeGlowRegion : glowRegion, x, y, rotation * 90);', stack_conveyor)
        self.assertIn('if(link == -1 || from == null || lastItem == null) return;', stack_conveyor)
        self.assertIn('int fromRot = from.build == null ? rotation : from.build.rotation;', stack_conveyor)
        self.assertIn('Tmp.v1.interpolate(Tmp.v2, 1f - cooldown, Interp.linear);', stack_conveyor)
        self.assertIn('float a = (fromRot%4) * 90;', stack_conveyor)
        self.assertIn('float b = (rotation%4) * 90;', stack_conveyor)
        self.assertIn('if((fromRot%4) == 3 && (rotation%4) == 0) a = -1 * 90;', stack_conveyor)
        self.assertIn('if((fromRot%4) == 0 && (rotation%4) == 3) a =  4 * 90;', stack_conveyor)
        self.assertIn('if(glowRegion.found()){', stack_conveyor)
        self.assertIn('Draw.z(Layer.blockAdditive + 0.01f);', stack_conveyor)
        self.assertIn('Draw.rect(stackRegion, Tmp.v1.x, Tmp.v1.y, Mathf.lerp(a, b, Interp.smooth.apply(1f - Mathf.clamp(cooldown * 2, 0f, 1f))));', stack_conveyor)
        self.assertIn('float size = itemSize * Mathf.lerp(Math.min((float)items.total() / itemCapacity, 1), 1f, 0.4f);', stack_conveyor)
        self.assertIn('Draw.rect(lastItem.fullIcon, Tmp.v1.x, Tmp.v1.y, size, size, 0);', stack_conveyor)
        self.assertIn('public int state, blendprox;', stack_conveyor)
        self.assertIn('public int link = -1;', stack_conveyor)
        self.assertIn('public float cooldown;', stack_conveyor)
        self.assertIn('public Item lastItem;', stack_conveyor)
        self.assertIn('public static final float itemSize = 5f;', stack_conveyor)
        self.assertIn('public static final int tilesize = 8;', stack_conveyor)
        self.assertIn('Interp smooth = a -> a * a * (3 - 2 * a);', stack_conveyor)
        self.assertIn('Interp linear = a -> a;', stack_conveyor)
        self.assertIn('public final static int[] d4x = {1, 0, -1, 0};', stack_conveyor)
        self.assertIn('public final static int[] d4y = {0, 1, 0, -1};', stack_conveyor)
        self.assertIn('return ((x % n) + n) % n;', stack_conveyor)
        self.assertIn('public float rotdeg(){', stack_conveyor)
        self.assertIn('return rotation * 90;', stack_conveyor)
        self.assertIn('default TextureRegion sliced(TextureRegion input, SliceMode mode){', stack_conveyor)
        self.assertIn('return mode == SliceMode.none ? input : mode == SliceMode.bottom ? botHalf(input) : topHalf(input);', stack_conveyor)
        # The documented limits record the draw rows as
        # live (the old "No draw/config modeling" text is
        # gone -- drawSelect / config still defer, draw
        # does not).
        self.assertIn('Draw rows live (N2434)', stack_conveyor)
        self.assertNotIn('No draw/config modeling', stack_conveyor)
        # The proof's keys drive the draw pure (the
        # cached load branch + the cached unload branch,
        # the glow gate + region select, the stack
        # interpolate + angle wraparound, the item size
        # lerp, the early return).
        proof = STACK_CONVEYOR_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_cached_load',
            'draw_cached_unload',
            'draw_glow',
            'draw_stack',
            'draw_item_size',
            'draw_early_return',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceStackConveyorBuildState.gd")', proof)
        self.assertTrue(STACK_CONVEYOR_STATE.exists())
        self.assertTrue(STACK_CONVEYOR_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07StackConveyorDrawRowsProof.gd', STACK_CONVEYOR_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_stack_conveyor_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07StackConveyorDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_STACK_CONVEYOR_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_cached_load',
            'draw_cached_unload',
            'draw_glow',
            'draw_stack',
            'draw_item_size',
            'draw_early_return',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
