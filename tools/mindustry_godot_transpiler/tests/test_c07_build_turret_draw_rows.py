import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
BUILD_TURRET_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretDrawRowsProof.gd'
BUILD_TURRET_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretDrawRowsProof.tscn'


class C07BuildTurretDrawRowsTests(unittest.TestCase):
    def test_c07_build_turret_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2431']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_draw_state')
        # The BuildTurret tick is live (N2215 shouldConsume
        # gate + N2243 sync/warmup advance + N2244 plan
        # logic + N2272 updateBuildLogic counter/selection
        # + N2251 nitrogen row) but NOTHING modeled
        # draw(): the base rect (BuildTurret.java:236),
        # the turret-layer shadow / region pair at
        # rotation - 90 (:241-242), the glow additive
        # by warmup (:244-246) and the drawBuilding
        # call when efficiency > 0 (:248-250). N2431
        # ports draw() as ONE pure-only draw pure, the
        # N2421 precedent: draw is never called by the
        # tick, so the pure takes caller-supplied
        # inputs (frame x / y / rotation / elevation /
        # warmup / efficiency, the glow found flag, the
        # heat color token, the unit presence flag) and
        # returns the draw calls as data. unit.
        # drawBuilding() is a call into the builder unit
        # -- the pure RECORDS the call, it does not model
        # unit draw. Five new result symbols: the base /
        # shadow / region calls, the glow call (null when
        # the glow region is not found) and the build
        # call (null when efficiency <= 0 or no unit).
        self.assertEqual(
            ledger['N2431']['source_symbols'],
            [
                'source_build_turret_draw_state_result.base_call',
                'source_build_turret_draw_state_result.shadow_call',
                'source_build_turret_draw_state_result.region_call',
                'source_build_turret_draw_state_result.glow_call',
                'source_build_turret_draw_state_result.build_call',
            ],
        )
        for name in ledger['N2431']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/BuildTurret.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_'))
        self.assertEqual(ledger['N2431']['runtime_proof'], '/root/C07BuildTurretDrawRowsProof')
        self.assertEqual(
            ledger['N2431']['tests'],
            [
                'test_c07_build_turret_draw_rows_registration',
                'test_all_c07_build_turret_draw_rows_input_evidence_is_exact',
                'test_build_turret_draw_rows_state',
                'test_reference_graph_and_actual_c07_build_turret_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2431']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #96 (1-based in
        # the merged advances-25 DEFERRED base): the
        # BuildTurret draw rows entry is REMOVED -- the
        # base rect, the shadow / region pair, the glow
        # additive by warmup and the drawBuilding call
        # are all live now, so nothing of the entry
        # remains. Net 280 - 1 = 279.
        self.assertFalse(any(entry.startswith('BuildTurret draw rows (') for entry in ledger['N2431']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BuildTurret unit rows (') for entry in ledger['N2431']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BuildTurret read/write rows (') for entry in ledger['N2431']['deferred_exprs']))
        self.assertEqual(len(ledger['N2431']['deferred_exprs']), 279)

    def test_all_c07_build_turret_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2431']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2431']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_draw_rows_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # The draw rows (BuildTurretBuild.draw(),
        # BuildTurret.java:234-251): `Draw.rect(baseRegion,
        # x, y);` + `Draw.color();` + `Draw.z(Layer.turret);`
        # + the Drawf.shadow / Draw.rect region pair at
        # rotation - 90 + the glow additive by warmup
        # when the glow region is found + unit.
        # drawBuilding() when efficiency > 0. The shadow
        # shifts by elevation -- the FIELD elevation
        # (`public float elevation = -1f;`), lifted by
        # init() to size / 2f (`if(elevation < 0) elevation
        # = size / 2f;`), so the size-3 build-tower
        # shifts by 1.5 (NOT the RepairTurret literal
        # size / 2f -- here the field is the shift and
        # the init lift is what sets it). The glow is
        # the Drawf.additive overload (region, color,
        # alpha, x, y, rotation, layer) at
        # Layer.turretHeat with alpha warmup -- the
        # additive body multiplies by the color alpha
        # (`Draw.color(color, alpha * color.a);`), and
        # heatColor carries a 0.9f alpha (`public Color
        # heatColor = Pal.accent.cpy().a(0.9f);`), so
        # the effective glow alpha is warmup * 0.9.
        # heatColor has NO def override (the single
        # build-tower def, Blocks.java:1997-2006, sets
        # neither elevation nor heatColor), and
        # baseRegion is the `@-base` region with the
        # block-@size fallback. Pure-only: the tick
        # never calls draw (draw is called by the
        # renderer), and unit.drawBuilding() is
        # recorded as a call, not modeled. Keep each
        # Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_build_turret_draw_state', build_turret)
        self.assertIn('public void draw(){', build_turret)
        self.assertIn('Draw.rect(baseRegion, x, y);', build_turret)
        self.assertIn('Draw.color();', build_turret)
        self.assertIn('Draw.z(Layer.turret);', build_turret)
        self.assertIn('Drawf.shadow(region, x - elevation, y - elevation, rotation - 90);', build_turret)
        self.assertIn('Draw.rect(region, x, y, rotation - 90);', build_turret)
        self.assertIn('if(glowRegion.found()){', build_turret)
        self.assertIn('Drawf.additive(glowRegion, heatColor, warmup, x, y, rotation - 90f, Layer.turretHeat);', build_turret)
        self.assertIn('if(efficiency > 0){', build_turret)
        self.assertIn('unit.drawBuilding();', build_turret)
        self.assertIn('public @Load(value = "@-base", fallback = "block-@size") TextureRegion baseRegion;', build_turret)
        self.assertIn('public @Load("@-glow") TextureRegion glowRegion;', build_turret)
        self.assertIn('public float elevation = -1f;', build_turret)
        self.assertIn('public Color heatColor = Pal.accent.cpy().a(0.9f);', build_turret)
        self.assertIn('if(elevation < 0) elevation = size / 2f;', build_turret)
        self.assertIn('public float warmup;', build_turret)
        self.assertIn('public BlockUnitc unit = (BlockUnitc)unitType.create(team);', build_turret)
        self.assertIn('public static void shadow(TextureRegion region, float x, float y, float rotation){', build_turret)
        self.assertIn('Draw.color(Pal.shadow);', build_turret)
        self.assertIn('public static void additive(TextureRegion region, Color color, float alpha, float x, float y, float rotation, float layer){', build_turret)
        self.assertIn('Draw.color(color, alpha * color.a);', build_turret)
        self.assertIn('Draw.blend(Blending.additive);', build_turret)
        self.assertIn('buildTower = new BuildTurret("build-tower"){{', build_turret)
        self.assertIn('size = 3;', build_turret)
        self.assertIn('public float rotation = 90;', build_turret)
        # The def constants (verified first): the
        # effective elevation for the size-3 build-tower
        # is 1.5 (the init lift, size / 2f) and the
        # heatColor alpha is 0.9f (the class default,
        # no def override).
        self.assertIn('SOURCE_BUILD_TURRET_ELEVATION := 1.5', build_turret)
        self.assertIn('SOURCE_BUILD_TURRET_HEAT_COLOR_ALPHA := 0.9', build_turret)
        # The documented limits record the draw rows as
        # live.
        self.assertIn('Draw rows live (N2431)', build_turret)
        # The proof's keys drive the draw pure (the base
        # / shadow / region geometry at the effective
        # elevation 1.5, the glow found branch with the
        # warmup * 0.9 effective alpha, the glow
        # not-found null, the build call at efficiency
        # > 0 with a unit present, the no-call branches
        # at efficiency <= 0, the rotation - 90 math and
        # the elevation shift at several values).
        proof = BUILD_TURRET_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_base_shadow_region',
            'draw_glow_found',
            'draw_glow_not_found',
            'draw_build_call',
            'draw_build_no_call',
            'draw_rotation_elevation',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceBuildTurretBuildState.gd")', proof)
        self.assertTrue(BUILD_TURRET_STATE.exists())
        self.assertTrue(BUILD_TURRET_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07BuildTurretDrawRowsProof.gd', BUILD_TURRET_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_build_turret_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_base_shadow_region',
            'draw_glow_found',
            'draw_glow_not_found',
            'draw_build_call',
            'draw_build_no_call',
            'draw_rotation_elevation',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
