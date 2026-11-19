import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_UNIT_WORLD_POSITION_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretUnitWorldPositionProof.gd'


class C07TurretUnitWorldPositionTests(unittest.TestCase):
    def test_c07_turret_unit_world_position_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2274']['godot_owner'], 'SourceTurretBuildState.source_turret_unit_world_position_state')
        # TurretBuild.updateTile() syncs its block unit every
        # tick (Turret.java:529-531): `unit.tile(this);` -- and
        # tile() positions the unit in world coordinates:
        # `set(tile);` (BlockUnitComp.java:24) ->
        # `set(pos.getX(), pos.getY());` (PosComp.java:24) ->
        # Tile.getX()/getY() are drawx()/drawy()
        # (Tile.java:727-734), drawx() is
        # `block().offset + worldx()` (:175-177), worldx() is
        # `x * tilesize` (:166-168), and Block.offset is
        # `((size + 1) % 2) * tilesize / 2f` (Block.java:761).
        # N2260 stamped the cell (`unit_tile`); this slice
        # stamps the world position the frame was missing:
        # `unit_world_x` and `unit_world_y` (plus the tile
        # re-assert). Three new result symbols: unit_world_x,
        # unit_world_y and unit_tile. The maxHealth/health
        # re-sync of tile() still waits for its own slice: the
        # frame carries no live building-health key yet.
        self.assertEqual(
            ledger['N2274']['source_symbols'],
            [
                'source_turret_unit_world_position_state_result.unit_world_x',
                'source_turret_unit_world_position_state_result.unit_world_y',
                'source_turret_unit_world_position_state_result.unit_tile',
            ],
        )
        for name in ledger['N2274']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/Tile.java',
                    'core/src/mindustry/entities/comp/BlockUnitComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_unit_world_position_state_result.unit_world_x': 'SourceTurretBuildState.source_turret_unit_world_position_state',
                    'source_turret_unit_world_position_state_result.unit_world_y': 'SourceTurretBuildState.source_turret_unit_world_position_state',
                    'source_turret_unit_world_position_state_result.unit_tile': 'SourceTurretBuildState.source_turret_unit_world_position_state',
                }[name])
        self.assertEqual(ledger['N2274']['runtime_proof'], '/root/C07TurretUnitWorldPositionProof')
        self.assertEqual(
            ledger['N2274']['tests'],
            [
                'test_c07_turret_unit_world_position_registration',
                'test_all_c07_turret_unit_world_position_input_evidence_is_exact',
                'test_turret_unit_world_position_state',
                'test_reference_graph_and_actual_c07_turret_unit_world_position',
            ],
        )
        self.assertTrue(ledger['N2274']['deferred_exprs'])

    def test_all_c07_turret_unit_world_position_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2274']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_unit_world_position_state_result.unit_world_x': 'SourceTurretBuildState.source_turret_unit_world_position_state',
                    'source_turret_unit_world_position_state_result.unit_world_y': 'SourceTurretBuildState.source_turret_unit_world_position_state',
                    'source_turret_unit_world_position_state_result.unit_tile': 'SourceTurretBuildState.source_turret_unit_world_position_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/comp/BlockUnitComp.java',
            'core/src/mindustry/entities/comp/PosComp.java',
            'core/src/mindustry/world/Tile.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2274']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_unit_world_position_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.updateTile() (Turret.java:490-532) syncs
        # its block unit every tick: `unit.tile(this);`
        # (:529) -- and tile() positions the unit in world
        # coordinates: `set(tile);` (BlockUnitComp.java:24) ->
        # `set(pos.getX(), pos.getY());` (PosComp.java:24) ->
        # Tile.getX()/getY() are drawx()/drawy()
        # (Tile.java:727-734), drawx() is
        # `block().offset + worldx()` (:175-177), worldx() is
        # `x * tilesize` (:166-168), and Block.offset is
        # `offset = ((size + 1) % 2) * tilesize / 2f;`
        # (Block.java:761) -- 0 for odd sizes, tilesize/2 for
        # even sizes. The port already has drawx/drawy as
        # SourceBlockGeometry.tile_drawx_state /
        # tile_drawy_state. The pure function takes the
        # building cell, the block size and tilesize, and
        # returns all three keys:
        # `{"unit_world_x": .., "unit_world_y": .., "unit_tile": ..}`.
        # The driver tick reads the cell, calls the pure
        # function with duo size 1.0 and tilesize 8.0, then
        # stamps all three keys back on the frame -- the tick
        # runs right after the N2260 unit sync tick and before
        # the N2258 recoilOffset tick (Java order :529-531
        # sync, :532 offset), so the world position is live
        # before the aim call.
        self.assertIn('static func source_turret_unit_world_position_state(cell: Vector2i, block_size: float, tilesize: float) -> Dictionary:', turret)
        self.assertIn('return {"unit_world_x": unit_world_x, "unit_world_y": unit_world_y, "unit_tile": cell}', turret)
        self.assertIn('unit.tile(this);', turret)
        self.assertIn('set(tile);', turret)
        self.assertIn('set(pos.getX(), pos.getY());', turret)
        self.assertIn('return drawx();', turret)
        self.assertIn('return drawy();', turret)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch AFTER
        # the N2260 unit sync tick and BEFORE the N2258
        # recoilOffset tick (Java order :529-531 sync, :532
        # offset): it reads the cell, calls the new pure
        # function with duo size 1.0 and tilesize 8.0, then
        # stamps all three keys back on the frame (the x/y
        # defaults are the duo live values for the cell --
        # offset 0, tilesize 8, so cell * 8).
        self.assertIn('var unit_world_position: Dictionary = source_turret_unit_world_position_state(cell, 1.0, 8.0)', turret)
        self.assertIn('frame["unit_world_x"] = unit_world_position.get("unit_world_x", float(cell.x) * 8.0)', turret)
        self.assertIn('frame["unit_world_y"] = unit_world_position.get("unit_world_y", float(cell.y) * 8.0)', turret)
        self.assertIn('frame["unit_tile"] = unit_world_position.get("unit_tile", cell)', turret)
        # The proof's keys drive the world position through the
        # pure function and the real driver (the duo world x/y
        # at cell (28, 21) are 28*8 = 224.0 / 21*8 = 168.0 /
        # an even size 2 offsets both by tilesize/2 = 4.0 /
        # an odd size 3 offsets by 0 / the origin cell maps to
        # (0.0, 0.0) / the tile link is re-asserted / all three
        # keys are stamped on the frame after the tick / the duo
        # live tick stamps 224.0 / 168.0).
        # There are no maxHealth/health keys: the tile() health
        # re-sync waits for a live building-health source.
        proof = TURRET_UNIT_WORLD_POSITION_PROOF.read_text(encoding='utf-8')
        for key in [
            'unit_world_x_duo_size1',
            'unit_world_y_duo_size1',
            'unit_world_offset_even_size2',
            'unit_world_offset_odd_size3',
            'unit_world_origin_cell',
            'unit_tile_reasserted',
            'unit_world_stamped_to_frame',
            'unit_world_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_unit_world_position(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretUnitWorldPositionProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_UNIT_WORLD_POSITION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'unit_world_x_duo_size1',
            'unit_world_y_duo_size1',
            'unit_world_offset_even_size2',
            'unit_world_offset_odd_size3',
            'unit_world_origin_cell',
            'unit_tile_reasserted',
            'unit_world_stamped_to_frame',
            'unit_world_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
