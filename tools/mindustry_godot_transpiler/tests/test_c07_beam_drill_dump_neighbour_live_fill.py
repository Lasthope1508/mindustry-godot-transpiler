import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BUILDING_ITEM_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingItemState.gd'
BLOCK_GEOMETRY = ROOT / 'godot-mindustry/src/game/SourceBlockGeometry.gd'
BEAM_DRILL_DUMP_NEIGHBOUR_LIVE_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillDumpNeighbourLiveFillProof.gd'
BEAM_DRILL_DUMP_NEIGHBOUR_LIVE_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillDumpNeighbourLiveFillProof.tscn'
BEAM_DRILL_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/production/BeamDrill.java'
BUILDING_COMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/Block.java'


class C07BeamDrillDumpNeighbourLiveFillTests(unittest.TestCase):
    def test_c07_beam_drill_dump_neighbour_live_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2405']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_dump_neighbour_live_fill_state')
        # N2289 ported the timerDump dump (dumpTime 5f /
        # timeScale, BeamDrill.java:264-266, dump(null) through
        # the shared dump_item_state routing) -- but the
        # neighbour accept/canDump arrays stayed frame inputs
        # (default []), so a live beam drill with no fill read
        # an empty proximity and never dumped. N2363 wired the
        # neighbour write-back (the N2353 helper lands the
        # routed dump in the neighbour store) -- but with no
        # fill the routing never ran. N2405 is the live fill,
        # the N2394 pattern for the BeamDrill driver: the tick
        # scans the live proximity (the
        # source_block_proximity_cells_state ring, index i is
        # ring cell i, the N2353 convention) BEFORE the dump
        # pure and fills the two arrays from the live
        # neighbour frames -- accepts from the DEFAULT
        # BuildingComp acceptItem gate (acceptItem REQUIRES
        # consumesItem, BuildingComp.java:864-866), canDump
        # from the default true (BuildingComp.java:1124-1126).
        # Per-block overrides are OUT of scope (a neighbour
        # with a modeled override is evaluated with the
        # DEFAULT gate here -- the override dispatch is a
        # follow-through note, not a new DEFERRED entry).
        # Two new symbols, one per filled array.
        self.assertEqual(
            ledger['N2405']['source_symbols'],
            [
                'source_beam_drill_dump_neighbour_live_fill_state_result.dump_neighbour_accepts',
                'source_beam_drill_dump_neighbour_live_fill_state_result.dump_neighbour_can_dump',
            ],
        )
        for name in ledger['N2405']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BeamDrill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_dump_neighbour_live_fill_state')
        self.assertEqual(ledger['N2405']['runtime_proof'], '/root/C07BeamDrillDumpNeighbourLiveFillProof')
        self.assertEqual(
            ledger['N2405']['tests'],
            [
                'test_c07_beam_drill_dump_neighbour_live_fill_registration',
                'test_all_c07_beam_drill_dump_neighbour_live_fill_input_evidence_is_exact',
                'test_beam_drill_dump_neighbour_live_fill_state',
                'test_reference_graph_and_actual_c07_beam_drill_dump_neighbour_live_fill',
            ],
        )
        self.assertTrue(ledger['N2405']['deferred_exprs'])
        # This slice RESOLVES the BeamDrill timerDump dump
        # neighbour live fill entry (DEFERRED #240 in the
        # coordinator's merged numbering, base
        # DEFERRED-after-advances-22, 298 entries): the fill
        # is live now, so the entry is REMOVED and the list
        # drops to 297. No new entry: the override-dispatch
        # follow-through is a note, not a deferral. The
        # first-fire deviation (#239) and the
        # PayloadDeconstructor incoming payload entry (#241)
        # stay verbatim.
        self.assertEqual(len(ledger['N2405']['deferred_exprs']), 297)
        self.assertFalse(any(entry.startswith('BeamDrill timerDump dump neighbour live fill (') for entry in ledger['N2405']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill timerDump first-fire deviation (') for entry in ledger['N2405']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor incoming payload live source (') for entry in ledger['N2405']['deferred_exprs']))

    def test_all_c07_beam_drill_dump_neighbour_live_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2405']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_dump_neighbour_live_fill_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2405']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_dump_neighbour_live_fill_state(self):
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # The live fill (N2405, DEFERRED #240): the tick fills
        # the two neighbour arrays from the live proximity
        # BEFORE the timerDump dump pure reads them. Index i
        # is ring cell i (the N2353 convention -- the ring
        # comes from source_block_proximity_cells_state, the
        # sprite from block_sprite_at_cell, the frame from the
        # first SOURCE_CONSUMER_FRAME_META_KEYS meta on the
        # sprite, the N2353 resolution path). Accepts/canDump
        # come from the DEFAULT gates (acceptItem REQUIRES
        # consumesItem -- not just capacity -- plus
        # items.get < getMaximumAccepted,
        # BuildingComp.java:864-866, with getMaximumAccepted
        # = block.itemCapacity, :781-783; the canDump default
        # is true, :1124-1126). consumesItem reads the
        # itemFilter (Block.java:774-780), which the port
        # represents as the catalog consumeItem rows. The
        # item gate answers for the FIRST held item in
        # content order -- the item the dump pure offers (its
        # accepts array is per-neighbour, not per-item, so a
        # per-item answer would misdeliver: Java tries later
        # held items against the same neighbour, and that
        # per-item routing waits for a dump-shape slice).
        # Per-block overrides are OUT of scope: a neighbour
        # with a modeled override is evaluated with the
        # DEFAULT gate here. A neighbour with no frame (no
        # sprite / unknown def / conduit / no meta-key frame)
        # reports the no-frame outcome -- false / false --
        # the N2353/N2371 no-frame precedent (a routed item
        # to a frameless neighbour drops, so the fill closes
        # the gates and nothing routes there). Keep each Java
        # expr on ONE comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_beam_drill_dump_neighbour_live_fill_state(game: Object, cell: Vector2i, size: int, frame: Dictionary, item_order: Array) -> Dictionary:', beam_drill)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', beam_drill)
        self.assertIn('Building other = world.build(tile.x + point.x, tile.y + point.y);', beam_drill)
        self.assertIn('Point2[] nearby = Edges.getEdges(block.size);', beam_drill)
        self.assertIn('public boolean acceptItem(Building source, Item item){', beam_drill)
        self.assertIn('return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);', beam_drill)
        self.assertIn('public int getMaximumAccepted(Item item){', beam_drill)
        self.assertIn('return block.itemCapacity;', beam_drill)
        self.assertIn('public boolean canDump(Building to, Item item){', beam_drill)
        self.assertIn('if(other.acceptItem(self(), item) && canDump(other, item)){', beam_drill)
        self.assertIn('public boolean consumesItem(Item item){', beam_drill)
        self.assertIn('return itemFilter[item.id];', beam_drill)
        self.assertIn('public int itemCapacity = 10;', beam_drill)
        self.assertIn('var allItems = content.items();', beam_drill)
        # The fill reuses the shared resolution path -- the
        # ring, the cell lookup, the frame-key list -- never
        # a hand-rolled scan. The power-graph + liquid-state
        # preloads are cycle-free (verified by transitive
        # closure: the 105-file power-graph tree and the
        # 53-file liquid-state tree do not contain this file,
        # and this file already reaches both through the item
        # state).
        self.assertIn('preload("res://src/game/SourcePlacedPowerGraphState.gd")', beam_drill)
        self.assertIn('preload("res://src/game/SourceBuildingLiquidState.gd")', beam_drill)
        self.assertIn('source_block_proximity_cells_state(size, cell.x, cell.y)', beam_drill)
        self.assertIn('game.call("block_sprite_at_cell", neighbour_cell)', beam_drill)
        self.assertIn('SOURCE_CONSUMER_FRAME_META_KEYS', beam_drill)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY', beam_drill)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_BLOCK_IDS', beam_drill)
        self.assertIn('properties.get("consumeItem", [])', beam_drill)
        self.assertIn('properties.get("itemCapacity", 10)', beam_drill)
        self.assertIn('"dump_neighbour_accepts": neighbour_accepts', beam_drill)
        self.assertIn('"dump_neighbour_can_dump": neighbour_can_dump', beam_drill)
        # The fill is called exactly once (its definition plus
        # the one tick call site), with the origin cell inline
        # (cell is bound after the enabled block, the N2363
        # note), the catalog size, and the content item ids
        # the timerDump dump already reads.
        self.assertEqual(beam_drill.count('source_beam_drill_dump_neighbour_live_fill_state('), 2)
        self.assertIn('source_beam_drill_dump_neighbour_live_fill_state(game, fill_cell, int(block.properties.get("size", 1)), frame, content_item_ids)', beam_drill)
        # The tick wires the fill BEFORE the dump reads the
        # frame arrays: supplied arrays WIN (the N2381
        # precedent -- the N2289/N2363 proofs seed the arrays
        # by hand, so a fill there would overwrite the seed),
        # and a previously live-filled frame
        # (dump_neighbour_live -- port bookkeeping, not Java
        # state) refreshes every tick.
        self.assertIn('has_supplied_dump_neighbour_arrays', beam_drill)
        self.assertIn('frame["dump_neighbour_live"] = true', beam_drill)
        self.assertIn('bool(frame.get("dump_neighbour_live", false))', beam_drill)
        self.assertLess(
            beam_drill.index('source_beam_drill_dump_neighbour_live_fill_state(game, fill_cell, int(block.properties.get("size", 1)), frame, content_item_ids)'),
            beam_drill.index('frame.get("dump_neighbour_accepts", [])'),
        )
        self.assertLess(
            beam_drill.index('frame["dump_neighbour_accepts"] = filled.get("dump_neighbour_accepts", [])'),
            beam_drill.index('frame.get("dump_neighbour_accepts", [])'),
        )
        self.assertLess(
            beam_drill.index('frame["dump_neighbour_can_dump"] = filled.get("dump_neighbour_can_dump", [])'),
            beam_drill.index('frame.get("dump_neighbour_can_dump", [])'),
        )
        # The N2289 dump pins still hold: the dump call, the
        # frame-input reads, the 2-call count, and the dump
        # doc strings.
        self.assertIn('source_beam_drill_timer_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)', beam_drill)
        self.assertEqual(beam_drill.count('source_beam_drill_timer_dump_state('), 2)
        self.assertIn('timerDump dump is live since N2289', beam_drill)
        self.assertIn('dump neighbour write-back live since N2363', beam_drill)
        self.assertIn('(3) Partial updateTile', beam_drill)
        self.assertIn('advance (N2195)', beam_drill)
        self.assertIn('shouldConsume gate live (N2202)', beam_drill)
        # The documented limits now record the dump neighbour
        # live fill as live (N2405).
        self.assertIn('dump neighbour live fill is live since N2405', beam_drill)
        self.assertIn('static func source_beam_drill_timer_dump_state', beam_drill)
        self.assertIn('static func source_beam_drill_update_tile_advance_state', beam_drill)
        self.assertIn('static func source_beam_drill_should_consume_state', beam_drill)
        self.assertIn('static func source_beam_drill_tick_buildings_state', beam_drill)
        # The shared helper exists with its N2353 contract
        # (index i is ring cell i; no sprite / no frame / no
        # store reports written false).
        item_state = BUILDING_ITEM_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_neighbour_item_write_back_state(game: Object, cell: Vector2i, size: int, neighbour_index: int, item: String, amount: int) -> Dictionary:', item_state)
        self.assertIn('"no_frame"', item_state)
        geometry = BLOCK_GEOMETRY.read_text(encoding='utf-8')
        self.assertIn('static func source_block_proximity_cells_state(block_size: int, tile_x: int, tile_y: int) -> Dictionary:', geometry)
        # Scope pins, by Java line number: the default gates
        # (BuildingComp.java:864-866, :1124-1126) and
        # getMaximumAccepted (:781-783), plus the filter read
        # (Block.java:774-775) and the itemCapacity default
        # (:75).
        building_comp_lines = BUILDING_COMP_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(building_comp_lines[780].strip(), 'public int getMaximumAccepted(Item item){')
        self.assertEqual(building_comp_lines[781].strip(), 'return block.itemCapacity;')
        self.assertEqual(building_comp_lines[863].strip(), 'public boolean acceptItem(Building source, Item item){')
        self.assertEqual(building_comp_lines[864].strip(), 'return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);')
        self.assertEqual(building_comp_lines[1123].strip(), 'public boolean canDump(Building to, Item item){')
        self.assertEqual(building_comp_lines[1124].strip(), 'return true;')
        block_lines = BLOCK_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(block_lines[74].strip(), 'public int itemCapacity = 10;')
        self.assertEqual(block_lines[773].strip(), 'public boolean consumesItem(Item item){')
        self.assertEqual(block_lines[774].strip(), 'return itemFilter[item.id];')
        beam_drill_lines = BEAM_DRILL_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(beam_drill_lines[263].strip(), 'if(timer(timerDump, dumpTime / timeScale)){')
        # The proof's keys drive the fill (the accepts array,
        # the canDump array, the consumesItem gate, the
        # capacity gate, the no-frame outcome) plus the live
        # tick (a live beam drill with NO seeded arrays dumps
        # through the live fill).
        proof = BEAM_DRILL_DUMP_NEIGHBOUR_LIVE_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'fill_accepts_from_live_neighbours',
            'fill_can_dump_from_live_neighbours',
            'fill_accepts_gate_requires_consumes_item',
            'fill_accepts_gate_requires_capacity',
            'fill_no_frame_neighbour_reports_empty',
            'live_tick_dumps_with_live_fill',
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
        self.assertIn('preload("res://src/game/SourceBeamDrillBuildState.gd")', proof)
        self.assertTrue(BEAM_DRILL_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertTrue(BLOCK_GEOMETRY.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('beam_drill_build_state.source_beam_drill_dump_neighbour_live_fill_state(', proof)
        self.assertIn('beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = BEAM_DRILL_DUMP_NEIGHBOUR_LIVE_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BeamDrillDumpNeighbourLiveFillProof.gd', scene)
        self.assertIn('C07BeamDrillDumpNeighbourLiveFillProof', scene)

    def test_reference_graph_and_actual_c07_beam_drill_dump_neighbour_live_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillDumpNeighbourLiveFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_DUMP_NEIGHBOUR_LIVE_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fill_accepts_from_live_neighbours',
            'fill_can_dump_from_live_neighbours',
            'fill_accepts_gate_requires_consumes_item',
            'fill_accepts_gate_requires_capacity',
            'fill_no_frame_neighbour_reports_empty',
            'live_tick_dumps_with_live_fill',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
