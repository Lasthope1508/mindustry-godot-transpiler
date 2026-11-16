import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WALL_CRAFTER_STATE = ROOT / 'godot-mindustry/src/game/SourceWallCrafterBuildState.gd'
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
WALL_CRAFTER_EDGE_TILES_LIVE_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterEdgeTilesLiveFillProof.gd'
WALL_CRAFTER_EDGE_TILES_LIVE_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterEdgeTilesLiveFillProof.tscn'
WALL_CRAFTER_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/production/WallCrafter.java'
BLOCK_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/Block.java'
BLOCKS_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/content/Blocks.java'


class C07WallCrafterEdgeTilesLiveFillTests(unittest.TestCase):
    def test_c07_wall_crafter_edge_tiles_live_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2459']['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_edge_tiles_live_fill_state')
        # N2301 ported the getEfficiency fill (WallCrafter.
        # java:141-180, recomputed each enabled tick from
        # frame["wall_edge_tiles"], default []) -- but the
        # edge tiles stayed frame inputs, so a live
        # cliff-crusher with no fill read an empty edge and
        # never accumulated time. N2459 is the live scan:
        # the tick scans the tile map (frame["world_tiles"],
        # the BeamDrill N2339 pattern, Dict keyed "x,y")
        # over the FACING edge (the cornerX/cornerY +
        # rotation 0-3 switch, WallCrafter.java:143-166)
        # BEFORE the N2301 recompute and fills the
        # per-edge-tile dict array ({solid,
        # attribute_value} in edge order i = 0..size-1).
        # One new symbol: the filled edge-tile dict array.
        self.assertEqual(
            ledger['N2459']['source_symbols'],
            [
                'source_wall_crafter_edge_tiles_live_fill_state_result.wall_edge_tiles',
            ],
        )
        for name in ledger['N2459']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/WallCrafter.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_edge_tiles_live_fill_state')
        self.assertEqual(ledger['N2459']['runtime_proof'], '/root/C07WallCrafterEdgeTilesLiveFillProof')
        self.assertEqual(
            ledger['N2459']['tests'],
            [
                'test_c07_wall_crafter_edge_tiles_live_fill_registration',
                'test_all_c07_wall_crafter_edge_tiles_live_fill_input_evidence_is_exact',
                'test_wall_crafter_edge_tiles_live_fill_state',
                'test_reference_graph_and_actual_c07_wall_crafter_edge_tiles_live_fill',
            ],
        )
        self.assertTrue(ledger['N2459']['deferred_exprs'])
        # This slice RESOLVES the WallCrafter getEfficiency
        # live edge-tile scan entry (DEFERRED #210 in the
        # coordinator's merged numbering, base
        # DEFERRED-after-advances-29, 253 entries): the scan
        # is live now, so the entry is REMOVED and the list
        # drops to 252. The updateTile live fill entry is
        # REWRITTEN IN PLACE (the N2301/N2398 precedent) to
        # record the scan live -- its other clauses stay.
        # No new entry: the live tile-producer gap (no
        # producer stamps frame["world_tiles"] or
        # frame["wall_attribute_by_tile"] yet) is a
        # follow-through note, not a deferral -- the pure +
        # frame inputs work with seeded maps. The setBars,
        # large-variant and frame-items-intake entries stay
        # verbatim.
        self.assertEqual(len(ledger['N2459']['deferred_exprs']), 252)
        self.assertFalse(any(entry.startswith('WallCrafter getEfficiency live edge-tile scan (') for entry in ledger['N2459']['deferred_exprs']))
        live_fill = [entry for entry in ledger['N2459']['deferred_exprs'] if entry.startswith('WallCrafter updateTile live fill (')]
        self.assertEqual(len(live_fill), 1)
        self.assertIn('the live edge-tile scan is live since N2459', live_fill[0])
        self.assertNotIn('the live edge-tile scan waits for its own slice', live_fill[0])
        self.assertIn('the updateEffect chance waits for its own slice', live_fill[0])
        self.assertTrue(any(entry.startswith('WallCrafter setBars row (') for entry in ledger['N2459']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('WallCrafter large variant (') for entry in ledger['N2459']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('WallCrafter frame items intake (') for entry in ledger['N2459']['deferred_exprs']))

    def test_all_c07_wall_crafter_edge_tiles_live_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2459']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_edge_tiles_live_fill_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/WallCrafter.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2459']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wall_crafter_edge_tiles_live_fill_state(self):
        wall_crafter = WALL_CRAFTER_STATE.read_text(encoding='utf-8')
        # The live edge-tile scan (N2459, DEFERRED #210):
        # the tick fills the facing-edge dict array from the
        # live tile map BEFORE the N2301 getEfficiency
        # recompute reads it. getEfficiency
        # (WallCrafter.java:141-180) iterates `size` tiles
        # along the FACING edge: cornerX = tx - (size-1)/2,
        # cornerY = ty - (size-1)/2 (INTEGER division: size
        # 3 -> 1, size 2 -> 0), s = size; rotation 0 ->
        # (cornerX+s, cornerY+i); 1 -> (cornerX+i,
        # cornerY+s); 2 -> (cornerX-1, cornerY+i); 3 ->
        # (cornerX+i, cornerY-1). Tile other =
        # world.tile(rx, ry); only `other != null &&
        # other.solid()` tiles contribute, summing
        # `other.block().attributes.get(attribute)` -- BLOCK
        # attributes, not floor attributes. The cpos
        # callback (:167-169) is a draw-plan hook (draw,
        # :239) with no tick effect -- the N2426 draw pure
        # already takes the facing tiles caller-supplied --
        # and the ctile callback (:175-177) drives the
        # updateEffect chance (:196-205, still deferred);
        # neither is ported here. Each entry is the exact
        # N2301 dict shape {solid, attribute_value} in edge
        # order (i = 0..size-1): a missing tile (no "x,y"
        # key) is a null tile (Java: other == null ->
        # skipped, contributes 0), a non-solid tile is
        # gated out the same way. Keep each Java expr on
        # ONE comment line (the N2148 lesson: a split line
        # fails this test).
        self.assertIn('static func source_wall_crafter_edge_tiles_live_fill_state(world_tiles: Dictionary, wall_attribute_by_tile: Dictionary, cell: Vector2i, size: int, rotation: int) -> Dictionary:', wall_crafter)
        self.assertIn('float getEfficiency(int tx, int ty, int rotation, @Nullable Cons<Tile> ctile, @Nullable Intc2 cpos){', wall_crafter)
        self.assertIn('int cornerX = tx - (size-1)/2, cornerY = ty - (size-1)/2, s = size;', wall_crafter)
        self.assertIn('for(int i = 0; i < size; i++){', wall_crafter)
        self.assertIn('switch(rotation){', wall_crafter)
        self.assertIn('case 0 -> {', wall_crafter)
        self.assertIn('rx = cornerX + s;', wall_crafter)
        self.assertIn('ry = cornerY + i;', wall_crafter)
        self.assertIn('case 1 -> {', wall_crafter)
        self.assertIn('rx = cornerX + i;', wall_crafter)
        self.assertIn('ry = cornerY + s;', wall_crafter)
        self.assertIn('case 2 -> {', wall_crafter)
        self.assertIn('rx = cornerX - 1;', wall_crafter)
        self.assertIn('case 3 -> {', wall_crafter)
        self.assertIn('ry = cornerY - 1;', wall_crafter)
        self.assertIn('if(cpos != null){', wall_crafter)
        self.assertIn('cpos.get(rx, ry);', wall_crafter)
        self.assertIn('Tile other = world.tile(rx, ry);', wall_crafter)
        self.assertIn('if(other != null && other.solid()){', wall_crafter)
        self.assertIn('float at = other.block().attributes.get(attribute);', wall_crafter)
        self.assertIn('eff += at;', wall_crafter)
        self.assertIn('if(at > 0 && ctile != null){', wall_crafter)
        self.assertIn('ctile.get(other);', wall_crafter)
        self.assertIn('return eff;', wall_crafter)
        self.assertIn('public Attribute attribute = Attribute.sand;', wall_crafter)
        self.assertIn('attribute = Attribute.sand;', wall_crafter)
        # DESIGN DECISION (verified, not guessed): the
        # BeamDrill world_tiles convention carries {solid,
        # wall_drop} per tile
        # (SourceBeamDrillBuildState.gd:392) and NO block
        # attribute field -- wall_drop is the drop ITEM,
        # not the block attribute -- and no producer stamps
        # frame["world_tiles"] anywhere (the BeamDrill tick
        # only reads it, frame.get default {}, and proofs
        # seed it). So this slice defines the MINIMAL
        # extension in the pure's input contract (the
        # caller-supplied wall_attribute_by_tile Dict "x,y"
        # -> float, the WALL BLOCK's attribute value per
        # tile) and documents the producer gap (the live
        # tile producer that stamps those fields waits for
        # its own slice) -- it does NOT invent a tile
        # producer (the N2414 precedent).
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        self.assertIn('world_tiles is a Dict keyed "x,y" to {solid,', beam_drill)
        self.assertNotIn('wall_attribute_by_tile', beam_drill)
        self.assertIn('wall_attribute_by_tile', wall_crafter)
        self.assertIn('tile producer', wall_crafter)
        # The fill walks the facing edge in Java order (i =
        # 0..size-1) from cornerX / cornerY, reads the tile
        # map by "x,y" key, and builds one N2301-shaped
        # dict per edge tile -- always exactly `size`
        # entries (Java reads exactly `size` tiles; a
        # missing or non-solid tile contributes a
        # {solid: false, attribute_value: 0.0} entry, the
        # Java contributes-0 outcome).
        self.assertIn('var corner_x: int = cell.x - (size - 1) / 2', wall_crafter)
        self.assertIn('var corner_y: int = cell.y - (size - 1) / 2', wall_crafter)
        self.assertIn('match rotation:', wall_crafter)
        self.assertIn('rx = corner_x + size', wall_crafter)
        self.assertIn('ry = corner_y + i', wall_crafter)
        self.assertIn('rx = corner_x + i', wall_crafter)
        self.assertIn('ry = corner_y + size', wall_crafter)
        self.assertIn('rx = corner_x - 1', wall_crafter)
        self.assertIn('ry = corner_y - 1', wall_crafter)
        self.assertIn('var key: String = str(rx) + "," + str(ry)', wall_crafter)
        self.assertIn('world_tiles.get(key, null)', wall_crafter)
        self.assertIn('{"solid": false, "attribute_value": 0.0}', wall_crafter)
        self.assertIn('{"solid": true, "attribute_value": float(wall_attribute_by_tile.get(key, 0.0))}', wall_crafter)
        self.assertIn('"wall_edge_tiles": wall_edge_tiles', wall_crafter)
        # The fill is called exactly once (its definition
        # plus the one tick call site), with the frame tile
        # map, the caller-supplied attribute map, the origin
        # cell inline (cell is bound after the enabled
        # block, the N2363 note), and the catalog size +
        # live rotation the N2301 recompute already binds.
        self.assertEqual(wall_crafter.count('source_wall_crafter_edge_tiles_live_fill_state('), 2)
        self.assertIn('source_wall_crafter_edge_tiles_live_fill_state(fill_world_tiles, fill_wall_attribute, fill_cell, wall_size, wall_rotation)', wall_crafter)
        # The tick wires the fill BEFORE the N2301 recompute
        # reads the frame array: frame["world_tiles"] and
        # frame["wall_attribute_by_tile"] default to {}
        # (an empty map fills an all-non-solid edge,
        # preserving the no-fill behavior). A supplied array
        # WINS (the N2381 precedent -- the N2301 proof seeds
        # wall_edge_tiles by hand, so a fill there would
        # overwrite the seed), and a previously live-filled
        # frame (wall_edge_tiles_live -- port bookkeeping,
        # not Java state, the N2394 precedent) refreshes
        # every tick. The local wall_edge_tiles rebinds
        # from the frame after the fill so the recompute
        # reads the filled array.
        self.assertIn('has_supplied_wall_edge_tiles', wall_crafter)
        self.assertIn('frame.get("world_tiles", {})', wall_crafter)
        self.assertIn('frame.get("wall_attribute_by_tile", {})', wall_crafter)
        self.assertIn('frame["wall_edge_tiles_live"] = true', wall_crafter)
        self.assertIn('bool(frame.get("wall_edge_tiles_live", false))', wall_crafter)
        self.assertIn('frame["wall_edge_tiles"] = edge_filled.get("wall_edge_tiles", [])', wall_crafter)
        self.assertIn('wall_edge_tiles = frame["wall_edge_tiles"]', wall_crafter)
        self.assertLess(
            wall_crafter.index('source_wall_crafter_edge_tiles_live_fill_state(fill_world_tiles, fill_wall_attribute, fill_cell, wall_size, wall_rotation)'),
            wall_crafter.index('source_wall_crafter_get_efficiency_state(wall_edge_tiles, wall_rotation, wall_size, SOURCE_WALL_CRAFTER_ATTRIBUTE)'),
        )
        self.assertLess(
            wall_crafter.index('frame["wall_edge_tiles"] = edge_filled.get("wall_edge_tiles", [])'),
            wall_crafter.index('source_wall_crafter_get_efficiency_state(wall_edge_tiles, wall_rotation, wall_size, SOURCE_WALL_CRAFTER_ATTRIBUTE)'),
        )
        # The N2301 recompute pins still hold: the call, the
        # frame-input read, the efficiency_factor stamp, the
        # N2301 return dict, and the doc strings.
        self.assertIn('frame.get("wall_edge_tiles", [])', wall_crafter)
        self.assertIn('source_wall_crafter_get_efficiency_state(wall_edge_tiles, wall_rotation, wall_size, SOURCE_WALL_CRAFTER_ATTRIBUTE)', wall_crafter)
        self.assertIn('frame["efficiency_factor"] = filled["efficiency"]', wall_crafter)
        self.assertIn('return {"efficiency": efficiency, "edge_efficiencies": edge_efficiencies, "can_place_on": efficiency > 0.0, "solid_tile_count": solid_tile_count, "rotation": rotation}', wall_crafter)
        self.assertIn('getEfficiency fill live (N2301)', wall_crafter)
        self.assertIn('updateTile advance live (N2223)', wall_crafter)
        self.assertIn('shouldConsume gate live (N2201)', wall_crafter)
        self.assertIn('offload neighbor routing is live since N2398', wall_crafter)
        self.assertIn('Draw rows live (N2426)', wall_crafter)
        # The documented limits now record the live
        # edge-tile scan as live (N2459).
        self.assertIn('live edge-tile scan is live since N2459', wall_crafter)
        self.assertIn('static func source_wall_crafter_get_efficiency_state', wall_crafter)
        self.assertIn('static func source_wall_crafter_update_tile_advance_state', wall_crafter)
        self.assertIn('static func source_wall_crafter_should_consume_state', wall_crafter)
        self.assertIn('static func source_wall_crafter_tick_buildings_state', wall_crafter)
        # Scope pins, by Java line number: getEfficiency
        # (WallCrafter.java:141-180), the corner math (:143),
        # the tile lookup + solid gate + attribute read
        # (:171-173), the attribute field (:41), and the def
        # constants (Blocks.java:3007-3008 / :3021-3022) plus
        # the Block class size default (Block.java:215).
        wall_crafter_lines = WALL_CRAFTER_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(wall_crafter_lines[40].strip(), 'public Attribute attribute = Attribute.sand;')
        self.assertEqual(wall_crafter_lines[140].strip(), 'float getEfficiency(int tx, int ty, int rotation, @Nullable Cons<Tile> ctile, @Nullable Intc2 cpos){')
        self.assertEqual(wall_crafter_lines[142].strip(), 'int cornerX = tx - (size-1)/2, cornerY = ty - (size-1)/2, s = size;')
        self.assertEqual(wall_crafter_lines[170].strip(), 'Tile other = world.tile(rx, ry);')
        self.assertEqual(wall_crafter_lines[171].strip(), 'if(other != null && other.solid()){')
        self.assertEqual(wall_crafter_lines[172].strip(), 'float at = other.block().attributes.get(attribute);')
        block_lines = BLOCK_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(block_lines[214].strip(), 'public int size = 1;')
        blocks_lines = BLOCKS_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(blocks_lines[3006].strip(), 'size = 2;')
        self.assertEqual(blocks_lines[3007].strip(), 'attribute = Attribute.sand;')
        self.assertEqual(blocks_lines[3020].strip(), 'size = 3;')
        self.assertEqual(blocks_lines[3021].strip(), 'attribute = Attribute.sand;')
        # The proof's keys drive the fill (facing-edge
        # coordinates at rotation 0 and rotation 1 -- with
        # rotations 2/3 folded into the rot1 key -- the
        # solid gate, missing tiles, supplied-wins) plus the
        # live tick (a live cliff-crusher with a seeded solid
        # edge accumulates efficiency through the N2301
        # recompute).
        proof = WALL_CRAFTER_EDGE_TILES_LIVE_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'edge_coords_rot0',
            'edge_coords_rot1',
            'edge_solid_gate',
            'edge_missing_tile',
            'edge_supplied_wins',
            'edge_live_tick',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        for line in proof.splitlines():
            if 'preload("res://' in line:
                res_path = line.split('preload("res://', 1)[1].split('"', 1)[0]
                with self.subTest(preload=res_path):
                    self.assertTrue((ROOT / 'godot-mindustry' / res_path).is_file(), res_path)
        self.assertIn('preload("res://src/game/SourceWallCrafterBuildState.gd")', proof)
        self.assertTrue(WALL_CRAFTER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('wall_crafter_build_state.source_wall_crafter_edge_tiles_live_fill_state(', proof)
        self.assertIn('wall_crafter_build_state.source_wall_crafter_get_efficiency_state(', proof)
        self.assertIn('wall_crafter_build_state.source_wall_crafter_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = WALL_CRAFTER_EDGE_TILES_LIVE_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07WallCrafterEdgeTilesLiveFillProof.gd', scene)
        self.assertIn('C07WallCrafterEdgeTilesLiveFillProof', scene)

    def test_reference_graph_and_actual_c07_wall_crafter_edge_tiles_live_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WallCrafterEdgeTilesLiveFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WALL_CRAFTER_EDGE_TILES_LIVE_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'edge_coords_rot0',
            'edge_coords_rot1',
            'edge_solid_gate',
            'edge_missing_tile',
            'edge_supplied_wins',
            'edge_live_tick',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
