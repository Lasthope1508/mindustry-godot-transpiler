import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_DRAWROT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretDrawrotProof.gd'


class C07TurretDrawrotTests(unittest.TestCase):
    def test_c07_turret_drawrot_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2532']['godot_owner'], 'SourceTurretBuildState.source_turret_drawrot_state')
        # drawrot() is the TurretBuild read (Turret.java:359-362):
        # `public float drawrot(){` /
        # `return rotation - 90;`
        # -- it uses the `rotation` AIM rotation field
        # (`public float rotation = 90;`,
        # BaseTurret.java:114), NOT the Building quadrant
        # rotation (0-3). It overrides the BuildingComp
        # base (`public float drawrot(){` /
        # `return block.rotate && block.rotateDraw ? rotation * 90 : 0f;`,
        # BuildingComp.java:587-588), which uses quadrants
        # * 90; the Turret override ignores block.rotate /
        # block.rotateDraw and returns aim rotation - 90.
        # NOT the PointDefense draw state
        # (SourcePointDefenseTurretBuildState.gd:678, key
        # `draw_rotation` inside
        # source_point_defense_turret_draw_state -- a
        # different function for PointDefenseBuild.draw(),
        # same quantity, different key, no clash). One new
        # result symbol: drawrot. The slice mirrors into
        # the defense shard (218/217 -> 219/218); comp stays
        # 572/475.
        self.assertEqual(
            ledger['N2532']['source_symbols'],
            [
                'source_turret_drawrot_state_result.drawrot',
            ],
        )
        for name in ledger['N2532']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/Turret.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_drawrot_state')
        self.assertEqual(ledger['N2532']['runtime_proof'], '/root/C07TurretDrawrotProof')
        self.assertEqual(
            ledger['N2532']['tests'],
            [
                'test_c07_turret_drawrot_registration',
                'test_all_c07_turret_drawrot_input_evidence_is_exact',
                'test_turret_drawrot_state',
                'test_reference_graph_and_actual_c07_turret_drawrot',
            ],
        )
        self.assertTrue(ledger['N2532']['deferred_exprs'])

    def test_all_c07_turret_drawrot_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2532']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_drawrot_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2532']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_drawrot_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # drawrot() (Turret.java:359-362) for the Turret
        # family as one pure function: `rotation - 90` --
        # one float param, one float result key `drawrot`.
        # `rotation` is the aim rotation in degrees, the
        # BaseTurretBuild field (`public float rotation =
        # 90;`, BaseTurret.java:114), an explicit float
        # param, NOT read from the frame (the N2528/N2529/
        # N2530/N2531 param-driven precedent). Java has NO
        # clamp/wrap guard in drawrot() (Turret.java:584
        # only guards inside updateTile, not in drawrot),
        # so negative and >360 rotations pass through
        # unchanged. NO driver tick call site (the
        # N2528/N2530/N2531 precedent): drawrot() is a
        # read, not per-tick, and its only callers are
        # draw code (DrawTurret / DrawDefault), which is
        # rendering outside the game boundary.
        self.assertIn('static func source_turret_drawrot_state(rotation: float) -> Dictionary:', turret)
        self.assertIn('return {"drawrot": rotation - 90.0}', turret)
        self.assertIn('public float drawrot(){', turret)
        self.assertIn('return rotation - 90;', turret)
        self.assertIn('public float rotation = 90;', turret)
        self.assertIn('return block.rotate && block.rotateDraw ? rotation * 90 : 0f;', turret)
        # The pure function sits immediately AFTER
        # source_turret_fog_radius_state (N2531) and BEFORE
        # source_turret_can_heal_state.
        self.assertLess(turret.index('static func source_turret_fog_radius_state('), turret.index('static func source_turret_drawrot_state('))
        self.assertLess(turret.index('static func source_turret_drawrot_state('), turret.index('static func source_turret_can_heal_state('))
        # NO driver tick call site: drawrot() is a read,
        # not per-tick. The tick function must not call the
        # new pure function.
        tick = turret[turret.index('static func source_turret_tick_buildings_state('):]
        self.assertNotIn('source_turret_drawrot_state(', tick)
        # The proof's keys drive the pure function on exact
        # legs: 1 the BaseTurret default rotation 90 -> 0;
        # 2 rotation 0 -> -90; 3 rotation 180 -> 90; 4
        # rotation 270 -> 180; 5 rotation 45 -> -45; 6
        # rotation 360 -> 270 (no wrap); 7 a negative
        # rotation -90 -> -180 (no clamp); 8 the result
        # carries exactly the single `drawrot` key and the
        # value is a float.
        proof = TURRET_DRAWROT_PROOF.read_text(encoding='utf-8')
        for key in [
            'drawrot_default',
            'drawrot_zero',
            'drawrot_half_turn',
            'drawrot_three_quarter',
            'drawrot_quarter',
            'drawrot_full_turn',
            'drawrot_negative',
            'drawrot_single_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_drawrot(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretDrawrotProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_DRAWROT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'drawrot_default',
            'drawrot_zero',
            'drawrot_half_turn',
            'drawrot_three_quarter',
            'drawrot_quarter',
            'drawrot_full_turn',
            'drawrot_negative',
            'drawrot_single_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
