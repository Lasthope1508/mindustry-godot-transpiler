import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WALL_CRAFTER_STATE = ROOT / 'godot-mindustry/src/game/SourceWallCrafterBuildState.gd'
WALL_CRAFTER_GET_EFFICIENCY_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterGetEfficiencyProof.gd'
WALL_CRAFTER_GET_EFFICIENCY_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterGetEfficiencyProof.tscn'


class C07WallCrafterGetEfficiencyTests(unittest.TestCase):
    def test_c07_wall_crafter_get_efficiency_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2301']['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_get_efficiency_state')
        # N2223 proved the updateTile advance (warmup / eff /
        # lastEfficiency / time / totalTime / offload) from an
        # EXPLICIT base efficiency (frame efficiency_factor,
        # default 0f) -- but no live fill ever set it: the
        # getEfficiency scan (WallCrafter.java:141-180) was
        # RED-deferred all along, so a live cliff-crusher
        # never accumulated time. N2301 is the live fill:
        # getEfficiency iterates `size` tiles along the FACING
        # edge (the rotation 0-3 switch) and sums
        # other.block().attributes.get(attribute) for SOLID
        # tiles only -- BLOCK attributes, not the floor
        # attributes of the SolidPump scan (N2292), so the
        # N2292 pure is NOT reused. Five new result symbols:
        # the summed efficiency, the per-tile contributions,
        # the canPlaceOn gate (efficiency > 0), the solid tile
        # count, and the carried rotation.
        self.assertEqual(
            ledger['N2301']['source_symbols'],
            [
                'source_wall_crafter_get_efficiency_state_result.efficiency',
                'source_wall_crafter_get_efficiency_state_result.edge_efficiencies',
                'source_wall_crafter_get_efficiency_state_result.can_place_on',
                'source_wall_crafter_get_efficiency_state_result.solid_tile_count',
                'source_wall_crafter_get_efficiency_state_result.rotation',
            ],
        )
        for name in ledger['N2301']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/WallCrafter.java')
                self.assertEqual(symbol['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_get_efficiency_state')
        self.assertEqual(ledger['N2301']['runtime_proof'], '/root/C07WallCrafterGetEfficiencyProof')
        self.assertEqual(
            ledger['N2301']['tests'],
            [
                'test_c07_wall_crafter_get_efficiency_registration',
                'test_all_c07_wall_crafter_get_efficiency_input_evidence_is_exact',
                'test_wall_crafter_get_efficiency_state',
                'test_reference_graph_and_actual_c07_wall_crafter_get_efficiency',
            ],
        )
        self.assertTrue(ledger['N2301']['deferred_exprs'])
        # This slice resolves the attribute / efficiency entry
        # (58) outright and REWRITES the updateTile live fill
        # entry (169) to drop only the getEfficiency clause --
        # the timerDump / offload-routing / updateEffect /
        # disabled-early-return parts stay. It adds the live
        # edge-tile scan deferral (no live tile scan fills
        # frame["wall_edge_tiles"] yet). Untouched entries
        # (setBars) stay.
        self.assertFalse(any(entry.startswith('WallCrafter attribute / efficiency rows (') for entry in ledger['N2301']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('WallCrafter updateTile live fill (') and 'stamped live by the N2301 getEfficiency fill' in entry for entry in ledger['N2301']['deferred_exprs']))
        self.assertFalse(any('until the getEfficiency fill lands' in entry for entry in ledger['N2301']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('WallCrafter getEfficiency live edge-tile scan (') for entry in ledger['N2301']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('WallCrafter setBars row (') for entry in ledger['N2301']['deferred_exprs']))

    def test_all_c07_wall_crafter_get_efficiency_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2301']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_get_efficiency_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/WallCrafter.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2301']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wall_crafter_get_efficiency_state(self):
        wall_crafter = WALL_CRAFTER_STATE.read_text(encoding='utf-8')
        # The live getEfficiency fill (WallCrafter.
        # getEfficiency(), WallCrafter.java:141-180):
        # `float getEfficiency(int tx, int ty, int rotation,
        # @Nullable Cons<Tile> ctile, @Nullable Intc2 cpos){`
        # iterates `size` tiles along the FACING edge (the
        # rotation 0-3 switch picks the edge from cornerX /
        # cornerY) and sums `other.block().attributes.get(
        # attribute)` for SOLID tiles only (`other != null &&
        # other.solid()`). The attribute is sand for both defs
        # (`public Attribute attribute = Attribute.sand;`,
        # WallCrafter.java:41 -- the brief cited :43, which is
        # the output field; corrected here). canPlaceOn
        # (:137-139) is the placement gate, efficiency > 0.
        # Keep each Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this test).
        self.assertIn('static func source_wall_crafter_get_efficiency_state', wall_crafter)
        self.assertIn('float getEfficiency(int tx, int ty, int rotation, @Nullable Cons<Tile> ctile, @Nullable Intc2 cpos){', wall_crafter)
        self.assertIn('float eff = 0f;', wall_crafter)
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
        self.assertIn('public boolean canPlaceOn(Tile tile, Team team, int rotation){', wall_crafter)
        self.assertIn('return getEfficiency(tile.x, tile.y, rotation, null, null) > 0;', wall_crafter)
        self.assertIn('public Attribute attribute = Attribute.sand;', wall_crafter)
        self.assertIn('public Item output = Items.sand;', wall_crafter)
        self.assertIn('float eff = getEfficiency(tile.x, tile.y, rotation, dest -> {', wall_crafter)
        self.assertIn('attribute = Attribute.sand;', wall_crafter)
        # The pure returns exactly the five N2301 keys, and
        # the attribute rides a driver const (the N2190
        # fogRadius / N2199 transportTime def-constant
        # precedent): sand (WallCrafter.java:41), set
        # explicitly by both defs (Blocks.java:3008/:3022).
        self.assertIn('return {"efficiency": efficiency, "edge_efficiencies": edge_efficiencies, "can_place_on": efficiency > 0.0, "solid_tile_count": solid_tile_count, "rotation": rotation}', wall_crafter)
        self.assertIn('SOURCE_WALL_CRAFTER_ATTRIBUTE := "sand"', wall_crafter)
        # The tick wires the fill BEFORE the advance (Java
        # order: getEfficiency is computed inside updateTile,
        # WallCrafter.java:196, and the N2223 advance reads
        # the frame input efficiency_factor), inside the same
        # enabled gate as the advance (BuildingComp.java:
        # 2276-2277). The edge tiles are frame inputs
        # (default [] -- no tiles, the Java no-adjacent-solid-
        # tiles outcome) until a live tile scan lands; the
        # rotation reads live from the sprite meta (the
        # Constructor / Factory precedent) and the size from
        # the catalog per def (2 / 3, Blocks.java:3007/:3021;
        # the Block class default is 1, Block.java:215).
        # The fill stamps efficiency_factor onto the frame;
        # the advance reads it, unchanged.
        self.assertIn('frame.get("wall_edge_tiles", [])', wall_crafter)
        self.assertIn('source_wall_crafter_get_efficiency_state(wall_edge_tiles, wall_rotation, wall_size, SOURCE_WALL_CRAFTER_ATTRIBUTE)', wall_crafter)
        self.assertIn('frame["efficiency_factor"] = filled["efficiency"]', wall_crafter)
        self.assertLess(
            wall_crafter.index('source_wall_crafter_get_efficiency_state(wall_edge_tiles, wall_rotation, wall_size, SOURCE_WALL_CRAFTER_ATTRIBUTE)'),
            wall_crafter.index('source_wall_crafter_update_tile_advance_state(frame, source_delta, time_scale, drill_time, advance_output_item, advance_item_capacity)'),
        )
        # The documented limits now record the getEfficiency
        # fill as live and the remaining deferrals (the live
        # edge-tile scan, the offload neighbor routing, the
        # updateEffect chance, the disabled early return);
        # the N2223 advance, the N2201 gate, the N2273 timer
        # consume and the N2283 timer dump are preserved.
        self.assertIn('getEfficiency fill live (N2301)', wall_crafter)
        self.assertIn('updateTile advance live (N2223)', wall_crafter)
        self.assertIn('shouldConsume gate live (N2201)', wall_crafter)
        self.assertIn('static func source_wall_crafter_power_status_row_state', wall_crafter)
        self.assertIn('static func source_wall_crafter_should_consume_state', wall_crafter)
        self.assertIn('static func source_wall_crafter_update_tile_advance_state', wall_crafter)
        self.assertIn('static func source_wall_crafter_timer_use_state', wall_crafter)
        self.assertIn('static func source_wall_crafter_timer_dump_state', wall_crafter)
        # The pure N2223 advance is untouched except for the
        # N2398 offload routing: its return dict keeps the seven
        # N2223 keys plus the two N2398 keys
        # (offload_neighbour_index + cdump), and the fill wires
        # BEFORE its call, never inside it.
        self.assertIn('return {"warmup": next_warmup, "eff": eff, "last_efficiency": last_efficiency, "time": next_time, "total_time": next_total_time, "offloaded": offloaded, "items": next_items, "offload_neighbour_index": offload_neighbour_index, "cdump": cdump}', wall_crafter)
        # The proof's keys drive the pure fill (sums solid-
        # tile BLOCK attributes; ignores non-solid tiles and
        # null tiles; an empty edge gives 0; the placement
        # gate is efficiency > 0; rotation is carried
        # through) plus the live tick (a placed
        # cliff-crusher fills efficiency_factor in one tick
        # and the advance accumulates time from it).
        proof = WALL_CRAFTER_GET_EFFICIENCY_PROOF.read_text(encoding='utf-8')
        for key in [
            'sums_solid_tile_attributes',
            'ignores_non_solid_tiles',
            'empty_edge_zero_efficiency',
            'placement_gate_efficiency_positive',
            'live_tick_fills_efficiency_factor',
            'rotation_carried_through',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceWallCrafterBuildState.gd")', proof)
        self.assertTrue(WALL_CRAFTER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('wall_crafter_build_state.source_wall_crafter_get_efficiency_state(', proof)
        self.assertIn('wall_crafter_build_state.source_wall_crafter_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = WALL_CRAFTER_GET_EFFICIENCY_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07WallCrafterGetEfficiencyProof.gd', scene)
        self.assertIn('C07WallCrafterGetEfficiencyProof', scene)

    def test_reference_graph_and_actual_c07_wall_crafter_get_efficiency(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WallCrafterGetEfficiencyProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WALL_CRAFTER_GET_EFFICIENCY_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sums_solid_tile_attributes',
            'ignores_non_solid_tiles',
            'empty_edge_zero_efficiency',
            'placement_gate_efficiency_positive',
            'live_tick_fills_efficiency_factor',
            'rotation_carried_through',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
