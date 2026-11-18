import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
POINT_DEFENSE_STATE = ROOT / 'godot-mindustry/src/game/SourcePointDefenseTurretBuildState.gd'
POINT_DEFENSE_DRAW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretDrawProof.gd'


class C07PointDefenseTurretDrawTests(unittest.TestCase):
    def test_c07_point_defense_turret_draw_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2244']['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_draw_state')
        # PointDefenseBuild.draw() (PointDefenseTurret.java:110-114,
        # `public void draw(){`) draws the base rect at (x, y)
        # with no rotation (`Draw.rect(baseRegion, x, y);` --
        # PointDefenseTurret.java:111), draws the shadow and the
        # region rect at rotation - 90 (`Drawf.shadow(region,
        # x - (size / 2f), y - (size / 2f), rotation - 90);` --
        # :112, the overload `public static void shadow(
        # TextureRegion region, float x, float y, float
        # rotation){`, Drawf.java:366 -- and `Draw.rect(region,
        # x, y, rotation - 90);` -- :113). There is NO Draw.z
        # call here, unlike RepairTurret.draw()
        # (RepairTurret.java:167, `Draw.z(Layer.turret);`) --
        # so this slice has NO z_layer symbol, only the three
        # draw keys. The shadow offset quirk stays as Java
        # wrote it: `size / 2f` is subtracted directly on world
        # coords, NOT tilesize-scaled -- segment (size 2, the
        # only PointDefenseTurret def, Blocks.java:3842,
        # `size = 2;`) offsets 1.0, the class default size 1
        # (Block.java:215, `public int size = 1;`) offsets 0.5.
        # RED decisions (resolved at RED, recorded in the
        # register docstring): (1) One pure function on the
        # same family file N2151 / N2239-N2243 built:
        # source_point_defense_turret_draw_state(x, y, rotation,
        # size) returning draw_rotation (rotation - 90),
        # shadow_position (x - size / 2f, y - size / 2f) and
        # base_position (x, y). All four params are explicit
        # floats (the N2225 draw precedent). (2) There IS a
        # driver tick line, like N2225 (unlike N2224 setStats
        # and N2227 icons, which are load-time reads): draw()
        # runs every frame after updateTile in the frame loop,
        # so the driver stamps draw_rotation, shadow_position
        # and base_position live after the aim/shoot block.
        # Rendering itself stays out of the game -- only the
        # state draw() depends on is captured, per the user
        # boundary. Three new result symbols: draw_rotation,
        # shadow_position, base_position.
        self.assertEqual(
            ledger['N2244']['source_symbols'],
            [
                'source_point_defense_turret_draw_state_result.draw_rotation',
                'source_point_defense_turret_draw_state_result.shadow_position',
                'source_point_defense_turret_draw_state_result.base_position',
            ],
        )
        for name in ledger['N2244']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
                    'core/src/mindustry/graphics/Drawf.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourcePointDefenseTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2244']['runtime_proof'], '/root/C07PointDefenseTurretDrawProof')
        self.assertEqual(
            ledger['N2244']['tests'],
            [
                'test_c07_point_defense_turret_draw_registration',
                'test_all_c07_point_defense_turret_draw_input_evidence_is_exact',
                'test_point_defense_turret_draw_state',
                'test_reference_graph_and_actual_c07_point_defense_turret_draw',
            ],
        )
        self.assertTrue(ledger['N2244']['deferred_exprs'])

    def test_all_c07_point_defense_turret_draw_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2244']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePointDefenseTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2244']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_point_defense_turret_draw_state(self):
        point_defense = POINT_DEFENSE_STATE.read_text(encoding='utf-8')
        # PointDefenseBuild.draw() (PointDefenseTurret.java:110-114,
        # `public void draw(){`): `Draw.rect(baseRegion, x, y);`
        # (:111) is the base rect at (x, y) with no rotation;
        # `Drawf.shadow(region, x - (size / 2f),
        # y - (size / 2f), rotation - 90);` (:112, the overload
        # `public static void shadow(TextureRegion region,
        # float x, float y, float rotation){`, Drawf.java:366)
        # draws the shadow at (x - size/2f, y - size/2f) with
        # angle rotation - 90; `Draw.rect(region, x, y,
        # rotation - 90);` (:113) draws the region rect at
        # (x, y) with angle rotation - 90. There is NO Draw.z
        # call -- unlike RepairTurret.draw() (:167) -- so no
        # z_layer key. The shadow offset is the quirk: size is
        # Block.size in tiles (class default 1, Block.java:215,
        # `public int size = 1;`; segment 2, Blocks.java:3842,
        # `size = 2;`) and `size / 2f` is subtracted directly on
        # world coords, NOT tilesize-scaled. rotation defaults
        # to 90 (the field init `public float rotation = 90;`,
        # BaseTurret.java:114). There IS a driver tick line:
        # draw() runs every frame after updateTile, so the
        # driver stamps the three draw keys live right after
        # the aim/shoot block, with the per-def segment size
        # 2.0 (the only PointDefenseTurret def).
        self.assertIn('static func source_point_defense_turret_draw_state(x: float, y: float, rotation: float, size: float) -> Dictionary:', point_defense)
        self.assertIn('return {"draw_rotation": draw_rotation, "shadow_position": shadow_position, "base_position": base_position}', point_defense)
        for expr in [
            'public void draw(){',
            'Draw.rect(baseRegion, x, y);',
            'Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);',
            'Draw.rect(region, x, y, rotation - 90);',
            'public static void shadow(TextureRegion region, float x, float y, float rotation){',
            'public float rotation = 90;',
            'public int size = 1;',
            'size = 2;',
            'public class PointDefenseTurret extends ReloadTurret{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, point_defense)
        self.assertIn('var draw: Dictionary = source_point_defense_turret_draw_state(sprite.position.x, sprite.position.y, float(frame.get("rotation", 90.0)), 2.0)', point_defense)
        self.assertIn('frame["draw_rotation"] = draw.get("draw_rotation", 0.0)', point_defense)
        self.assertIn('frame["shadow_position"] = draw.get("shadow_position", Vector2.ZERO)', point_defense)
        self.assertIn('frame["base_position"] = draw.get("base_position", Vector2.ZERO)', point_defense)
        # The proof's keys drive the pure function directly
        # plus through the driver tick, at the sample position
        # x=100, y=200: draw rotation at the class-default /
        # zero / half-turn rotations, the shadow offset at the
        # segment (size 2) / class-default (size 1) sizes, and
        # the base position. There is no z-layer key: the
        # PointDefense draw() sets no z.
        proof = POINT_DEFENSE_DRAW_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_rotation_default',
            'draw_rotation_zero',
            'draw_rotation_half_turn',
            'draw_shadow_segment',
            'draw_shadow_default_size',
            'draw_base_position',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_point_defense_turret_draw(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PointDefenseTurretDrawProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POINT_DEFENSE_TURRET_DRAW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_rotation_default',
            'draw_rotation_zero',
            'draw_rotation_half_turn',
            'draw_shadow_segment',
            'draw_shadow_default_size',
            'draw_base_position',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
