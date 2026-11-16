import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourceMassDriverBuildState.gd'
MASS_DRIVER_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverDrawRowsProof.gd'
MASS_DRIVER_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverDrawRowsProof.tscn'


class C07MassDriverDrawRowsTests(unittest.TestCase):
    def test_c07_mass_driver_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2396']['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_draw_rows_state')
        # The MassDriver tick is live (N2237 advance +
        # N2294 dump + N2336 acceptItem + N2369 dump
        # write-back) and sense is live (N2392), but
        # NOTHING modeled draw(): draw base/shadow
        # (MassDriver.java:230-242), drawConfigure link
        # circles/arrows (:244-264), drawPlace range
        # circle + link line (:80-102), icons (:75-77).
        # N2396 ports all four areas as pure-only draw
        # pures, the N2356/N2372 pattern: draw is never
        # called by the tick, so the pures take
        # caller-supplied inputs (frame rotation /
        # reloadCounter, link state, placement tile) and
        # return the draw calls as data. The icons rows
        # ride the draw pure (icons() takes no args and
        # the SSOT schema validator requires non-empty
        # input keys) -- three pures, nine new result
        # symbols: the draw base / shadow / rect calls +
        # the icons region list, the drawConfigure circle
        # / arrow calls + dash circle, and the drawPlace
        # dash circle + link line calls.
        self.assertEqual(
            ledger['N2396']['source_symbols'],
            [
                'source_mass_driver_draw_rows_state_result.base_call',
                'source_mass_driver_draw_rows_state_result.shadow_call',
                'source_mass_driver_draw_rows_state_result.rect_call',
                'source_mass_driver_draw_rows_state_result.icon_regions',
                'source_mass_driver_draw_configure_state_result.circle_calls',
                'source_mass_driver_draw_configure_state_result.arrow_calls',
                'source_mass_driver_draw_configure_state_result.dash_circle_call',
                'source_mass_driver_draw_place_state_result.dash_circle_call',
                'source_mass_driver_draw_place_state_result.link_line_calls',
            ],
        )
        for name in ledger['N2396']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/distribution/MassDriver.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceMassDriverBuildState.source_mass_driver_'))
        self.assertEqual(ledger['N2396']['runtime_proof'], '/root/C07MassDriverDrawRowsProof')
        self.assertEqual(
            ledger['N2396']['tests'],
            [
                'test_c07_mass_driver_draw_rows_registration',
                'test_all_c07_mass_driver_draw_rows_input_evidence_is_exact',
                'test_mass_driver_draw_rows_state',
                'test_reference_graph_and_actual_c07_mass_driver_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2396']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #301 (1-based in
        # the merged advances-21 DEFERRED base): the
        # MassDriver draw / drawConfigure / drawPlace /
        # icons entry is REMOVED -- the sense half was
        # already live since N2392, and the draw half is
        # live now, so nothing of the entry remains. Net
        # 301 - 1 = 300.
        self.assertFalse(any(entry.startswith('MassDriver draw / drawConfigure / drawPlace / icons rows (') for entry in ledger['N2396']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver handlePayload / receive rows (') for entry in ledger['N2396']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver read/write rows (') for entry in ledger['N2396']['deferred_exprs']))
        self.assertEqual(len(ledger['N2396']['deferred_exprs']), 300)

    def test_all_c07_mass_driver_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2396']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceMassDriverBuildState.source_mass_driver_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/MassDriver.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2396']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mass_driver_draw_rows_state(self):
        mass_driver = MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The draw rows (MassDriverBuild.draw(),
        # MassDriver.java:230-242): `Draw.rect(baseRegion,
        # x, y);` + `Draw.z(Layer.turret);` + the
        # Drawf.shadow / Draw.rect region pair recoiling
        # reloadCounter * knockback along rotation + 180f
        # (`public float knockback = 4f;`, :32) -- the
        # shadow shifts by the INT-divided (size / 2), so
        # a size-3 driver shifts by 1, NOT 1.5. The
        # drawConfigure rows (:244-264): `float sin =
        # Mathf.absin(Time.time, 6f, 1f);` + the accent
        # self circle + per-shooter place circles/arrows
        # + the linked-target circle/arrow behind
        # `if(linkValid()){` + `Drawf.dashCircle(x, y,
        # range, Pal.accent);`. The drawPlace rows
        # (:80-102): the accent range dash circle at
        # x * tilesize (NO offset) + the dotted link line
        # toward a selected in-range mass driver (`int
        # segs = (int)(selected.dst(x * tilesize, y *
        # tilesize) / tilesize);`, gray stroke 4f then
        # placing stroke 2f). The icons rows (:75-77):
        # `return new TextureRegion[]{baseRegion, region};`
        # (`public @Load("@-base") TextureRegion
        # baseRegion;`, :44). The absin pulse is
        # Java-exact through the shared helper at the
        # DOUBLED scale 12f (the N2372 lesson: Java absin
        # folds a 2f the helper does not, Mathf.java:78-80,
        # arc). The drawPlace offset is the Block offset
        # (`offset = ((size + 1) % 2) * tilesize / 2f;`,
        # Block.java:761 -- 0 for the odd size-3 driver,
        # 4.0 for an even size-2 block) and tilesize is
        # the Java constant 8.0 (`public static final int
        # tilesize = 8;`, Vars.java:135 -- NEVER the game
        # tile_size 32, the N2375 lesson). Pure-only: the
        # tick never calls draw (draw is called by the
        # renderer, drawConfigure/drawPlace by the UI,
        # icons by the atlas).
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_mass_driver_draw_rows_state', mass_driver)
        self.assertIn('static func source_mass_driver_draw_configure_state', mass_driver)
        self.assertIn('static func source_mass_driver_draw_place_state', mass_driver)
        self.assertIn('Draw.rect(baseRegion, x, y);', mass_driver)
        self.assertIn('Draw.z(Layer.turret);', mass_driver)
        self.assertIn('Drawf.shadow(region,', mass_driver)
        self.assertIn('x + Angles.trnsx(rotation + 180f, reloadCounter * knockback) - (size / 2),', mass_driver)
        self.assertIn('y + Angles.trnsy(rotation + 180f, reloadCounter * knockback) - (size / 2), rotation - 90);', mass_driver)
        self.assertIn('Draw.rect(region,', mass_driver)
        self.assertIn('x + Angles.trnsx(rotation + 180f, reloadCounter * knockback),', mass_driver)
        self.assertIn('y + Angles.trnsy(rotation + 180f, reloadCounter * knockback), rotation - 90);', mass_driver)
        self.assertIn('public float knockback = 4f;', mass_driver)
        self.assertIn('public @Load("@-base") TextureRegion baseRegion;', mass_driver)
        self.assertIn('float sin = Mathf.absin(Time.time, 6f, 1f);', mass_driver)
        self.assertIn('Draw.color(Pal.accent);', mass_driver)
        self.assertIn('Lines.stroke(1f);', mass_driver)
        self.assertIn('Drawf.circles(x, y, (tile.block().size / 2f + 1) * tilesize + sin - 2f, Pal.accent);', mass_driver)
        self.assertIn('for(var shooter : waitingShooters){', mass_driver)
        self.assertIn('Drawf.circles(shooter.x, shooter.y, (tile.block().size / 2f + 1) * tilesize + sin - 2f, Pal.place);', mass_driver)
        self.assertIn('Drawf.arrow(shooter.x, shooter.y, x, y, size * tilesize + sin, 4f + sin, Pal.place);', mass_driver)
        self.assertIn('if(linkValid()){', mass_driver)
        self.assertIn('Drawf.circles(target.x, target.y, (target.block.size / 2f + 1) * tilesize + sin - 2f, Pal.place);', mass_driver)
        self.assertIn('Drawf.arrow(x, y, target.x, target.y, size * tilesize + sin, 4f + sin);', mass_driver)
        self.assertIn('Drawf.dashCircle(x, y, range, Pal.accent);', mass_driver)
        self.assertIn('public void drawPlace(int x, int y, int rotation, boolean valid){', mass_driver)
        self.assertIn('super.drawPlace(x, y, rotation, valid);', mass_driver)
        self.assertIn('Drawf.dashCircle(x * tilesize, y * tilesize, range, Pal.accent);', mass_driver)
        self.assertIn('if(!control.input.config.isShown()) return;', mass_driver)
        self.assertIn('Building selected = control.input.config.getSelected();', mass_driver)
        self.assertIn('if(selected == null || selected.block != this || !selected.within(x * tilesize, y * tilesize, range)) return;', mass_driver)
        self.assertIn('Tmp.v1.set(x * tilesize + offset, y * tilesize + offset).sub(selected.x, selected.y).limit((size / 2f + 1) * tilesize + sin + 0.5f);', mass_driver)
        self.assertIn('float x2 = x * tilesize - Tmp.v1.x, y2 = y * tilesize - Tmp.v1.y,', mass_driver)
        self.assertIn('x1 = selected.x + Tmp.v1.x, y1 = selected.y + Tmp.v1.y;', mass_driver)
        self.assertIn('int segs = (int)(selected.dst(x * tilesize, y * tilesize) / tilesize);', mass_driver)
        self.assertIn('Lines.stroke(4f, Pal.gray);', mass_driver)
        self.assertIn('Lines.dashLine(x1, y1, x2, y2, segs);', mass_driver)
        self.assertIn('Lines.stroke(2f, Pal.placing);', mass_driver)
        self.assertIn('Draw.reset();', mass_driver)
        self.assertIn('public TextureRegion[] icons(){', mass_driver)
        self.assertIn('return new TextureRegion[]{baseRegion, region};', mass_driver)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', mass_driver)
        self.assertIn('public static final int tilesize = 8;', mass_driver)
        # The absin pulse passes the DOUBLED scale 12f to
        # the shared helper (the N2372 lesson -- Java
        # absin(Time.time, 6f, 1f) == helper(time, 12f, 1f)).
        self.assertIn('source_absin(time_value, 12.0, 1.0)', mass_driver)
        # The documented limits record the draw rows as
        # live (the old "No link/config / handlePayload /
        # draw / read-write rows" deferral text is gone).
        self.assertIn('Draw rows live (N2396)', mass_driver)
        self.assertNotIn('No link/config / handlePayload / draw / read-write rows', mass_driver)
        # The proof's keys drive the draw pures (the base
        # / shadow / rect geometry incl. the 4.0 recoil of
        # a just-fired driver, the drawConfigure circles /
        # arrows for a shooter + a linked target, the
        # drawPlace range circle + the dotted link line
        # toward a selected in-range driver, the icons
        # region list, plus the live frame rotation /
        # reloadCounter / link feeding the draw pures).
        proof = MASS_DRIVER_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_base_shadow',
            'draw_configure_link',
            'draw_place_range',
            'draw_place_link_line',
            'draw_icons',
            'draw_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceMassDriverBuildState.gd")', proof)
        self.assertTrue(MASS_DRIVER_STATE.exists())
        self.assertTrue(MASS_DRIVER_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07MassDriverDrawRowsProof.gd', MASS_DRIVER_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_mass_driver_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MassDriverDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MASS_DRIVER_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_base_shadow',
            'draw_configure_link',
            'draw_place_range',
            'draw_place_link_line',
            'draw_icons',
            'draw_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
