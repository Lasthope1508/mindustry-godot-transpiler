import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_DRAW_SELECT_PLACE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerDrawSelectPlaceProof.gd'


class C07RepairTowerDrawSelectPlaceTests(unittest.TestCase):
    def test_c07_repair_tower_draw_select_place_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2231']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_draw_select_state')
        # N2190 / N2191 / N2211 / N2228 / N2229 made the repair
        # tower live (refresh, should-consume, nearby driver,
        # heal advance, ozone consumer) and N2230 captured its
        # setStats rows -- but nothing in the port captured
        # what the selection / placement UI draws:
        # RepairTowerBuild.drawSelect() draws one dash circle
        # around the building (`Drawf.dashCircle(x, y, range,
        # Pal.placing);`, RepairTower.java:123, inside `public
        # void drawSelect(){`, RepairTower.java:122) and
        # RepairTower.drawPlace() draws the same circle at the
        # ghost position (`Drawf.dashCircle(x * tilesize +
        # offset, y * tilesize + offset, range, Pal.placing);`,
        # RepairTower.java:47, inside `public void drawPlace(int
        # x, int y, int rotation, boolean valid){`,
        # RepairTower.java:44, after `super.drawPlace(x, y,
        # rotation, valid);`, RepairTower.java:45). RED
        # decisions (resolved at RED, recorded in the register
        # docstring): (1) Two pure functions on the same family
        # file N2190 / N2191 / N2211 / N2228 / N2229 / N2230
        # built, returning the deterministic dash-circle state:
        # center, radius, color. Rendering itself stays out of
        # the game -- only the state the circle depends on is
        # captured, per the user boundary. (2) The radius is the
        # per-def range -- unit-repair-tower 100f
        # (Blocks.java:6579), class default 80f (`public float
        # range = 80f;`, RepairTower.java:21) -- passed as an
        # explicit param (the N2220 / N2230 per-def-param
        # precedent; single def, so no _range_for_block_id
        # helper). (3) The place center converts tile coords to
        # world coords with the tilesize and the block offset
        # (`x * tilesize + offset`, RepairTower.java:47;
        # tilesize 8, Vars.java:135; offset `((size + 1) % 2)
        # * tilesize / 2f`, Block.java:761 -- unit-repair-tower
        # size 2, Blocks.java:6578, so 4.0), passed as explicit
        # params (the N2220 draw-place precedent; single def,
        # so no _block_offset_for_block_id helper). (4) The
        # color is Pal.placing in both call sites, represented
        # as the string "Pal.placing" (the
        # SourceBaseTurretDrawState.gd:25 /
        # SourceTurretPlacementState.gd:35 precedent). (5) There
        # is NO driver tick line: drawSelect / drawPlace are
        # selection / placement UI, not per-tick -- the
        # functions are called from the selection / placement
        # code, not from the frame loop. (6) The drawPlace
        # super call (`super.drawPlace(x, y, rotation,
        # valid);`, RepairTower.java:45) draws the block
        # itself, not the circle -- out of scope for this
        # slice. Six new result symbols: select center /
        # radius / color, place center / radius / color.
        self.assertEqual(
            ledger['N2231']['source_symbols'],
            [
                'source_repair_tower_draw_select_state_result.center',
                'source_repair_tower_draw_select_state_result.radius',
                'source_repair_tower_draw_select_state_result.color',
                'source_repair_tower_draw_place_state_result.center',
                'source_repair_tower_draw_place_state_result.radius',
                'source_repair_tower_draw_place_state_result.color',
            ],
        )
        for name in ledger['N2231']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTower.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTowerBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2231']['runtime_proof'], '/root/C07RepairTowerDrawSelectPlaceProof')
        self.assertEqual(
            ledger['N2231']['tests'],
            [
                'test_c07_repair_tower_draw_select_place_registration',
                'test_all_c07_repair_tower_draw_select_place_input_evidence_is_exact',
                'test_repair_tower_draw_select_place_state',
                'test_reference_graph_and_actual_c07_repair_tower_draw_select_place',
            ],
        )
        self.assertTrue(ledger['N2231']['deferred_exprs'])

    def test_all_c07_repair_tower_draw_select_place_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2231']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTowerBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2231']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_draw_select_place_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # RepairTowerBuild.drawSelect() draws one dash circle
        # around the building (`Drawf.dashCircle(x, y, range,
        # Pal.placing);`, RepairTower.java:123, inside `public
        # void drawSelect(){`, RepairTower.java:122) and
        # RepairTower.drawPlace() draws the same circle at the
        # ghost position (`Drawf.dashCircle(x * tilesize +
        # offset, y * tilesize + offset, range, Pal.placing);`,
        # RepairTower.java:47, inside `public void drawPlace(int
        # x, int y, int rotation, boolean valid){`,
        # RepairTower.java:44, after `super.drawPlace(x, y,
        # rotation, valid);`, RepairTower.java:45). The radius
        # is the per-def range -- unit-repair-tower 100f
        # (Blocks.java:6579), class default 80f (`public float
        # range = 80f;`, RepairTower.java:21). The place center
        # converts tile coords to world coords with the
        # tilesize and the block offset (`x * tilesize +
        # offset`, RepairTower.java:47; tilesize 8,
        # Vars.java:135; offset `((size + 1) % 2) * tilesize /
        # 2f`, Block.java:761 -- unit-repair-tower size 2,
        # Blocks.java:6578, so 4.0). The color is Pal.placing
        # in both call sites. There is no driver tick line:
        # drawSelect / drawPlace are selection / placement UI,
        # not per-tick.
        self.assertIn('static func source_repair_tower_draw_select_state(x: float, y: float, range: float) -> Dictionary:', repair_tower)
        self.assertIn('return {"center": Vector2(x, y), "radius": range, "color": "Pal.placing"}', repair_tower)
        self.assertIn('static func source_repair_tower_draw_place_state(tile_x: int, tile_y: int, range: float, tilesize: float, block_offset: float) -> Dictionary:', repair_tower)
        self.assertIn('var center: Vector2 = Vector2(float(tile_x) * tilesize + block_offset, float(tile_y) * tilesize + block_offset)', repair_tower)
        self.assertIn('return {"center": center, "radius": range, "color": "Pal.placing"}', repair_tower)
        for expr in [
            'public void drawSelect(){',
            'Drawf.dashCircle(x, y, range, Pal.placing);',
            'public void drawPlace(int x, int y, int rotation, boolean valid){',
            'super.drawPlace(x, y, rotation, valid);',
            'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);',
            'public float range = 80f;',
            'range = 100f;',
            'public static final int tilesize = 8;',
            'public class RepairTower extends Block{',
            'range / tilesize',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_tower)
        driver_start = repair_tower.index('static func source_repair_tower_tick_buildings_state')
        driver_end = repair_tower.find('\nstatic func ', driver_start + 1)
        driver_body = repair_tower[driver_start:driver_end if driver_end != -1 else len(repair_tower)]
        self.assertNotIn('source_repair_tower_draw_select_state', driver_body)
        self.assertNotIn('source_repair_tower_draw_place_state', driver_body)
        # The proof's keys drive the pure functions with
        # synthetic values (no live tick: the dash-circle state
        # is pure geometry from the position plus explicit
        # per-def params): select center at the building
        # position / select radius catalog 100 / select radius
        # class default 80 / select color is placing / place
        # center converts tile to world / place center applies
        # the block offset / place radius catalog 100 / place
        # color is placing / no driver tick line (the proof
        # reads the state script source and greps the driver
        # body -- a runtime check, not a hardcoded true).
        proof = REPAIR_TOWER_DRAW_SELECT_PLACE_PROOF.read_text(encoding='utf-8')
        for key in [
            'select_center_at_building_position',
            'select_radius_catalog_100',
            'select_radius_class_default_80',
            'select_color_is_placing',
            'place_center_converts_tile_to_world',
            'place_center_applies_block_offset',
            'place_radius_catalog_100',
            'place_color_is_placing',
            'no_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_tower_draw_select_place(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTowerDrawSelectPlaceProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TOWER_DRAW_SELECT_PLACE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'select_center_at_building_position',
            'select_radius_catalog_100',
            'select_radius_class_default_80',
            'select_color_is_placing',
            'place_center_converts_tile_to_world',
            'place_center_applies_block_offset',
            'place_radius_catalog_100',
            'place_color_is_placing',
            'no_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
