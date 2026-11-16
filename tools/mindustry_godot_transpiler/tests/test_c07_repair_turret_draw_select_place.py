import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_DRAW_SELECT_PLACE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretDrawSelectPlaceProof.gd'


class C07RepairTurretDrawSelectPlaceTests(unittest.TestCase):
    def test_c07_repair_turret_draw_select_place_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2220']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_draw_select_state')
        # N2212-N2215 made the repair turret live (target acquire,
        # heal advance, rotation slerp, strength lerp), N2217
        # persisted its rotation and N2219 captured the beam state
        # draw() draws each frame -- but nothing in the port
        # captured what the selection / placement UI draws:
        # RepairPointBuild.drawSelect() draws one dash circle
        # around the building (`Drawf.dashCircle(x, y,
        # repairRadius, Pal.accent);`, RepairTurret.java:178,
        # inside `public void drawSelect(){`,
        # RepairTurret.java:177) and RepairTurret.drawPlace()
        # draws the same circle at the ghost position
        # (`Drawf.dashCircle(x * tilesize + offset, y * tilesize
        # + offset, repairRadius, Pal.accent);`,
        # RepairTurret.java:98, inside `public void drawPlace(int
        # x, int y, int rotation, boolean valid){`,
        # RepairTurret.java:95, after `super.drawPlace(x, y,
        # rotation, valid);`, RepairTurret.java:96). RED
        # decisions (resolved at RED, recorded in the register
        # docstring): (1) Two pure functions on the same family
        # file N2174 / N2188 / N2209 / N2212-N2215 / N2217 / N2219
        # built, returning the deterministic dash-circle state:
        # center, radius, color. Rendering itself stays out of
        # the game -- only the state the circle depends on is
        # captured, per the user boundary. (2) The radius is the
        # per-def repairRadius -- repair-point 60f
        # (Blocks.java:6389), repair-turret 145f
        # (Blocks.java:6401), class default 50f (`public float
        # repairRadius = 50f;`, RepairTurret.java:32) -- resolved
        # by the caller through the existing
        # _repair_radius_for_block_id helper (N2212). (3) The
        # place center converts tile coords to world coords with
        # the tilesize and the block offset (`x * tilesize +
        # offset`, RepairTurret.java:98; tilesize 8,
        # Vars.java:135; offset `((size + 1) % 2) * tilesize /
        # 2f`, Block.java:761 -- repair-point size 1, no size
        # override in Blocks.java:6386, so 0.0; repair-turret
        # size 2, Blocks.java:6398, so 4.0), resolved by the new
        # _block_offset_for_block_id helper. (4) The color is
        # Pal.accent in both call sites, represented as the
        # string "Pal.accent" (the SourceBlockDrawState.gd:182
        # precedent). (5) There is NO driver tick line:
        # drawSelect / drawPlace are selection / placement UI,
        # not per-tick -- the functions are called from the
        # selection / placement code, not from the frame loop.
        # (6) drawSelect / drawPlace super calls
        # (`super.drawPlace(x, y, rotation, valid);`,
        # RepairTurret.java:96) draw the block itself, not the
        # circle -- out of scope for this slice. Six new result
        # symbols: select center / radius / color, place center
        # / radius / color.
        self.assertEqual(
            ledger['N2220']['source_symbols'],
            [
                'source_repair_turret_draw_select_state_result.center',
                'source_repair_turret_draw_select_state_result.radius',
                'source_repair_turret_draw_select_state_result.color',
                'source_repair_turret_draw_place_state_result.center',
                'source_repair_turret_draw_place_state_result.radius',
                'source_repair_turret_draw_place_state_result.color',
            ],
        )
        for name in ledger['N2220']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2220']['runtime_proof'], '/root/C07RepairTurretDrawSelectPlaceProof')
        self.assertEqual(
            ledger['N2220']['tests'],
            [
                'test_c07_repair_turret_draw_select_place_registration',
                'test_all_c07_repair_turret_draw_select_place_input_evidence_is_exact',
                'test_repair_turret_draw_select_place_state',
                'test_reference_graph_and_actual_c07_repair_turret_draw_select_place',
            ],
        )
        self.assertTrue(ledger['N2220']['deferred_exprs'])

    def test_all_c07_repair_turret_draw_select_place_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2220']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2220']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_draw_select_place_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # RepairPointBuild.drawSelect() draws one dash circle
        # around the building (`Drawf.dashCircle(x, y,
        # repairRadius, Pal.accent);`, RepairTurret.java:178,
        # inside `public void drawSelect(){`,
        # RepairTurret.java:177) and RepairTurret.drawPlace()
        # draws the same circle at the ghost position
        # (`Drawf.dashCircle(x * tilesize + offset, y * tilesize
        # + offset, repairRadius, Pal.accent);`,
        # RepairTurret.java:98, inside `public void drawPlace(int
        # x, int y, int rotation, boolean valid){`,
        # RepairTurret.java:95, after `super.drawPlace(x, y,
        # rotation, valid);`, RepairTurret.java:96). The radius
        # is the per-def repairRadius -- repair-point 60f
        # (Blocks.java:6389), repair-turret 145f
        # (Blocks.java:6401), class default 50f (`public float
        # repairRadius = 50f;`, RepairTurret.java:32). The place
        # center converts tile coords to world coords with the
        # tilesize and the block offset (`x * tilesize + offset`,
        # RepairTurret.java:98; tilesize 8, Vars.java:135; offset
        # `((size + 1) % 2) * tilesize / 2f`, Block.java:761 --
        # repair-point size 1 so 0.0, repair-turret size 2 so
        # 4.0). The color is Pal.accent in both call sites. There
        # is no driver tick line: drawSelect / drawPlace are
        # selection / placement UI, not per-tick.
        self.assertIn('static func source_repair_turret_draw_select_state(x: float, y: float, repair_radius: float) -> Dictionary:', repair_turret)
        self.assertIn('return {"center": Vector2(x, y), "radius": repair_radius, "color": "Pal.accent"}', repair_turret)
        self.assertIn('static func source_repair_turret_draw_place_state(tile_x: int, tile_y: int, repair_radius: float, tilesize: float, block_offset: float) -> Dictionary:', repair_turret)
        self.assertIn('var center: Vector2 = Vector2(float(tile_x) * tilesize + block_offset, float(tile_y) * tilesize + block_offset)', repair_turret)
        self.assertIn('return {"center": center, "radius": repair_radius, "color": "Pal.accent"}', repair_turret)
        self.assertIn('static func _block_offset_for_block_id(block_id: String) -> float:', repair_turret)
        self.assertIn('if block_id == "repair-turret":', repair_turret)
        self.assertIn('return 4.0', repair_turret)
        self.assertIn('return 0.0', repair_turret)
        for expr in [
            'public void drawSelect(){',
            'Drawf.dashCircle(x, y, repairRadius, Pal.accent);',
            'public void drawPlace(int x, int y, int rotation, boolean valid){',
            'super.drawPlace(x, y, rotation, valid);',
            'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);',
            'public float repairRadius = 50f;',
            'repairRadius / tilesize',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        # The proof's keys drive the pure functions with
        # synthetic values (no live tick: the dash-circle state
        # is pure geometry from the position plus explicit
        # per-def params): select center at the building
        # position / select radius repair-point 60 / select
        # radius repair-turret 145 / select color is accent /
        # place center converts tile to world / place center
        # applies the block offset / place radius repair-turret
        # 145 / place color is accent. There is no live-tick
        # key: drawSelect / drawPlace are UI, not per-tick.
        proof = REPAIR_TURRET_DRAW_SELECT_PLACE_PROOF.read_text(encoding='utf-8')
        for key in [
            'select_center_at_building_position',
            'select_radius_repair_point_60',
            'select_radius_repair_turret_145',
            'select_color_is_accent',
            'place_center_converts_tile_to_world',
            'place_center_applies_block_offset',
            'place_radius_repair_turret_145',
            'place_color_is_accent',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_draw_select_place(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretDrawSelectPlaceProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_DRAW_SELECT_PLACE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'select_center_at_building_position',
            'select_radius_repair_point_60',
            'select_radius_repair_turret_145',
            'select_color_is_accent',
            'place_center_converts_tile_to_world',
            'place_center_applies_block_offset',
            'place_radius_repair_turret_145',
            'place_color_is_accent',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
