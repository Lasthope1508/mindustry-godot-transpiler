import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_DRAW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretDrawProof.gd'


class C07RepairTurretDrawTests(unittest.TestCase):
    def test_c07_repair_turret_draw_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2225']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_draw_state')
        # RepairPointBuild.draw() (RepairTurret.java:164-174,
        # `public void draw(){`) draws the base rect at (x, y)
        # with no rotation (`Draw.rect(baseRegion, x, y);` --
        # RepairTurret.java:165), sets the z-layer
        # (`Draw.z(Layer.turret);` -- :167, Layer.turret = 50,
        # Layer.java:48), draws the shadow and the region rect
        # at rotation - 90 (`Drawf.shadow(region,
        # x - (size / 2f), y - (size / 2f), rotation - 90);` --
        # :168 -- and `Draw.rect(region, x, y, rotation - 90);`
        # -- :169), then calls drawBeam (:171-173). The
        # drawBeam call leg is N2219
        # (`source_repair_turret_draw_beam_state`), NOT this
        # slice. The shadow offset quirk stays as Java wrote
        # it: `size / 2f` is subtracted directly on world
        # coords, NOT tilesize-scaled -- repair-point (size 1,
        # the Block default, Block.java:215, `public int
        # size = 1;`, no override in Blocks.java:6386-6394)
        # offsets 0.5, repair-turret (size 2, Blocks.java:6398,
        # `size = 2;`) offsets 1.0.
        # RED decisions (resolved at RED, recorded in the
        # register docstring): (1) One pure function on the
        # same family file N2174 / N2188 / N2209 / N2212-N2215 /
        # N2217 / N2219-N2224 built:
        # source_repair_turret_draw_state(x, y, rotation, size)
        # returning draw_rotation (rotation - 90),
        # shadow_position (x - size / 2f, y - size / 2f),
        # base_position (x, y) and z_layer (50.0,
        # Layer.turret). All four params are explicit floats
        # (the N2220 draw-place / N2223 sense per-def-param
        # precedent for size, and the draw_select precedent
        # for x / y / rotation passed explicitly: rotation
        # defaults to 90, the field init `public float
        # strength, rotation = 90;`, RepairTurret.java:156).
        # (2) There IS a driver tick line, unlike N2220
        # (drawSelect/drawPlace -- UI, no tick line) and N2224
        # (stat display, no tick line): draw() runs every
        # frame after updateTile in the frame loop, and the
        # driver already calls draw_beam_state each tick
        # (SourceRepairTurretBuildState.gd:664), so N2225 adds
        # one draw_state call there, stamping draw_rotation,
        # shadow_position, base_position and z_layer live.
        # Rendering itself stays out of the game -- only the
        # state draw() depends on is captured, per the user
        # boundary. Four new result symbols: draw_rotation,
        # shadow_position, base_position, z_layer.
        self.assertEqual(
            ledger['N2225']['source_symbols'],
            [
                'source_repair_turret_draw_state_result.draw_rotation',
                'source_repair_turret_draw_state_result.shadow_position',
                'source_repair_turret_draw_state_result.base_position',
                'source_repair_turret_draw_state_result.z_layer',
            ],
        )
        for name in ledger['N2225']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                    'core/src/mindustry/graphics/Layer.java',
                    'core/src/mindustry/graphics/Drawf.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2225']['runtime_proof'], '/root/C07RepairTurretDrawProof')
        self.assertEqual(
            ledger['N2225']['tests'],
            [
                'test_c07_repair_turret_draw_registration',
                'test_all_c07_repair_turret_draw_input_evidence_is_exact',
                'test_repair_turret_draw_state',
                'test_reference_graph_and_actual_c07_repair_turret_draw',
            ],
        )
        self.assertTrue(ledger['N2225']['deferred_exprs'])

    def test_all_c07_repair_turret_draw_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2225']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/graphics/Layer.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2225']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_draw_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # RepairPointBuild.draw() (RepairTurret.java:164-174,
        # `public void draw(){`): `Draw.rect(baseRegion, x, y);`
        # (:165) is the base rect at (x, y) with no rotation;
        # `Draw.z(Layer.turret);` (:167) sets the z-layer to
        # Layer.turret = 50 (Layer.java:48, `turret = 50,`);
        # `Drawf.shadow(region, x - (size / 2f),
        # y - (size / 2f), rotation - 90);` (:168, the overload
        # `public static void shadow(TextureRegion region,
        # float x, float y, float rotation){`, Drawf.java:366)
        # draws the shadow at (x - size/2f, y - size/2f);
        # `Draw.rect(region, x, y, rotation - 90);` (:169)
        # draws the region rect at (x, y) with angle
        # rotation - 90. The drawBeam call (:171-173) is N2219,
        # NOT this slice. The shadow offset is the quirk: size
        # is Block.size in tiles (class default 1, Block.java:215,
        # `public int size = 1;`; repair-turret 2, Blocks.java:6398,
        # `size = 2;`) and `size / 2f` is subtracted directly on
        # world coords, NOT tilesize-scaled. rotation defaults
        # to 90 (the field init `public float strength,
        # rotation = 90;`, RepairTurret.java:156). There IS a
        # driver tick line: draw() runs every frame after
        # updateTile, and the driver already calls
        # draw_beam_state each tick
        # (SourceRepairTurretBuildState.gd:664).
        self.assertIn('static func source_repair_turret_draw_state(x: float, y: float, rotation: float, size: float) -> Dictionary:', repair_turret)
        self.assertIn('return {"draw_rotation": draw_rotation, "shadow_position": shadow_position, "base_position": base_position, "z_layer": 50.0}', repair_turret)
        for expr in [
            'public void draw(){',
            'Draw.rect(baseRegion, x, y);',
            'Draw.z(Layer.turret);',
            'Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);',
            'Draw.rect(region, x, y, rotation - 90);',
            'public float strength, rotation = 90;',
            'turret = 50,',
            'public class RepairTurret extends Block{',
            'size = 2;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        # The proof's keys drive the pure function directly
        # plus through the driver tick, at the sample position
        # x=100, y=200: draw rotation at the class-default /
        # zero / half-turn rotations, the shadow offset at the
        # repair-point (size 1) / repair-turret (size 2) defs,
        # and the turret z-layer.
        proof = REPAIR_TURRET_DRAW_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_rotation_default',
            'draw_rotation_zero',
            'draw_rotation_half_turn',
            'draw_shadow_repair_point',
            'draw_shadow_repair_turret',
            'draw_z_layer_turret',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_draw(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretDrawProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_DRAW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_rotation_default',
            'draw_rotation_zero',
            'draw_rotation_half_turn',
            'draw_shadow_repair_point',
            'draw_shadow_repair_turret',
            'draw_z_layer_turret',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
