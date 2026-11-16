import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BUILDING_ITEM_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingItemState.gd'
BLOCK_GEOMETRY = ROOT / 'godot-mindustry/src/game/SourceBlockGeometry.gd'
BURST_DRILL_DUMP_NEIGHBOUR_LIVE_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillDumpNeighbourLiveFillProof.gd'
BURST_DRILL_DUMP_NEIGHBOUR_LIVE_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillDumpNeighbourLiveFillProof.tscn'
BURST_DRILL_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/production/BurstDrill.java'
BUILDING_COMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/Block.java'


class C07BurstDrillDumpNeighbourLiveFillTests(unittest.TestCase):
    def test_c07_burst_drill_dump_neighbour_live_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2403']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_dump_neighbour_live_fill_state')
        # N2282 ported the timerDump dump (the frame-local
        # Interval-equivalent, 5f/time_scale,
        # BurstDrill.java:83-84) -- but the two neighbour
        # arrays stayed frame inputs (default []), so a live
        # burst drill with no fill read an empty proximity
        # and never dumped. N2360 wired the neighbour
        # write-back (the N2353 helper lands the routed dump
        # in the neighbour store) -- but with no fill the
        # routing never ran. N2403 is the live fill: the
        # tick scans the live proximity (the
        # source_block_proximity_cells_state ring, index i
        # is ring cell i, the N2353 convention) BEFORE the
        # dump pure and fills the two arrays from the live
        # neighbour frames -- accepts/canDump from the
        # DEFAULT BuildingComp gates (acceptItem REQUIRES
        # consumesItem, BuildingComp.java:864-866; the
        # canDump default is true, :1124-1126). Per-block
        # overrides are OUT of scope (a neighbour with a
        # modeled override is evaluated with the DEFAULT
        # gate here -- the override dispatch is a
        # follow-through note, not a new DEFERRED entry).
        # Two new symbols, one per filled array.
        self.assertEqual(
            ledger['N2403']['source_symbols'],
            [
                'source_burst_drill_dump_neighbour_live_fill_state_result.dump_neighbour_accepts',
                'source_burst_drill_dump_neighbour_live_fill_state_result.dump_neighbour_can_dump',
            ],
        )
        for name in ledger['N2403']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BurstDrill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_dump_neighbour_live_fill_state')
        self.assertEqual(ledger['N2403']['runtime_proof'], '/root/C07BurstDrillDumpNeighbourLiveFillProof')
        self.assertEqual(
            ledger['N2403']['tests'],
            [
                'test_c07_burst_drill_dump_neighbour_live_fill_registration',
                'test_all_c07_burst_drill_dump_neighbour_live_fill_input_evidence_is_exact',
                'test_burst_drill_dump_neighbour_live_fill_state',
                'test_reference_graph_and_actual_c07_burst_drill_dump_neighbour_live_fill',
            ],
        )
        self.assertTrue(ledger['N2403']['deferred_exprs'])
        # This slice RESOLVES the timerDump neighbour live
        # fill entry (DEFERRED #228 in the coordinator's
        # merged numbering, base DEFERRED-after-advances-22,
        # 298 entries): the fill is live now, so the entry
        # is REMOVED and the list drops to 297. No new
        # entry: the override-dispatch follow-through is a
        # note, not a deferral. The first-fire deviation,
        # the offload effects + neighbor routing, and the
        # timerDump write-back follow-ups entries stay
        # verbatim.
        self.assertEqual(len(ledger['N2403']['deferred_exprs']), 297)
        self.assertFalse(any(entry.startswith('BurstDrill timerDump neighbour live fill (') for entry in ledger['N2403']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BurstDrill timerDump first-fire deviation (') for entry in ledger['N2403']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BurstDrill updateTile offload effects + offload neighbor routing (') for entry in ledger['N2403']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Neighbour item write-back follow-ups (') for entry in ledger['N2403']['deferred_exprs']))

    def test_all_c07_burst_drill_dump_neighbour_live_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2403']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_dump_neighbour_live_fill_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2403']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_dump_neighbour_live_fill_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The live fill (N2403, DEFERRED #228): the tick fills
        # the two neighbour arrays from the live proximity
        # BEFORE the dump pure reads them. Index i is ring
        # cell i (the N2353 convention -- the ring comes from
        # source_block_proximity_cells_state, the sprite from
        # block_sprite_at_cell, the frame from the first
        # SOURCE_CONSUMER_FRAME_META_KEYS meta on the sprite,
        # the N2353 resolution path). The accepts/canDump
        # arrays come from the DEFAULT gates (acceptItem
        # REQUIRES consumesItem -- not just capacity -- plus
        # items.get < getMaximumAccepted,
        # BuildingComp.java:864-866, with getMaximumAccepted
        # = block.itemCapacity, :781-783; the canDump
        # default is true, :1124-1126). consumesItem reads
        # the itemFilter (Block.java:774-776), which the port
        # represents as the catalog consumeItem rows. The
        # item gate answers for the FIRST held item in
        # content order -- the item the dump pure offers
        # (its accepts array is per-neighbour, not per-item,
        # so a per-item answer would misdeliver: Java tries
        # later held items against the same neighbour, and
        # that per-item routing waits for a dump-shape
        # slice). Per-block overrides are OUT of scope: a
        # neighbour with a modeled override is evaluated
        # with the DEFAULT gate here. A neighbour with no
        # frame (no sprite / unknown def / conduit / no
        # meta-key frame) reports the no-frame outcome --
        # false / false -- the N2353 no-frame precedent (a
        # routed item to a frameless neighbour drops, so the
        # fill closes the gates and nothing routes there).
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_burst_drill_dump_neighbour_live_fill_state(game: Object, cell: Vector2i, size: int, frame: Dictionary, item_order: Array) -> Dictionary:', burst_drill)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', burst_drill)
        self.assertIn('public boolean acceptItem(Building source, Item item){', burst_drill)
        self.assertIn('return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);', burst_drill)
        self.assertIn('public int getMaximumAccepted(Item item){', burst_drill)
        self.assertIn('return block.itemCapacity;', burst_drill)
        self.assertIn('public boolean canDump(Building to, Item item){', burst_drill)
        self.assertIn('if(other.acceptItem(self(), item) && canDump(other, item)){', burst_drill)
        self.assertIn('if(other.acceptItem(self(), todump) && canDump(other, todump)){', burst_drill)
        self.assertIn('public boolean consumesItem(Item item){', burst_drill)
        self.assertIn('return itemFilter[item.id];', burst_drill)
        self.assertIn('public int itemCapacity = 10;', burst_drill)
        # The fill reuses the shared resolution path -- the
        # ring, the cell lookup, the frame-key list -- never
        # a hand-rolled scan. Both new preloads are
        # cycle-free (verified by transitive closure: the
        # 105-file power-graph tree and the 53-file liquid
        # tree do not contain this file, and this file
        # already reaches the power-graph state through the
        # item state).
        self.assertIn('preload("res://src/game/SourcePlacedPowerGraphState.gd")', burst_drill)
        self.assertIn('preload("res://src/game/SourceBuildingLiquidState.gd")', burst_drill)
        self.assertIn('source_block_proximity_cells_state(size, cell.x, cell.y)', burst_drill)
        self.assertIn('game.call("block_sprite_at_cell", neighbour_cell)', burst_drill)
        self.assertIn('SOURCE_CONSUMER_FRAME_META_KEYS', burst_drill)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY', burst_drill)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_BLOCK_IDS', burst_drill)
        self.assertIn('properties.get("consumeItem", [])', burst_drill)
        self.assertIn('properties.get("itemCapacity", 10)', burst_drill)
        self.assertIn('"dump_neighbour_accepts": neighbour_accepts', burst_drill)
        self.assertIn('"dump_neighbour_can_dump": neighbour_can_dump', burst_drill)
        # The fill is called exactly twice (its definition plus
        # two tick call sites), with the tick cell in scope
        # (cell is bound before the enabled block in this
        # driver, so no N2363 inline origin_cell read) and
        # the catalog size + the content item order. The second
        # call site is the N2476 offload refresh (probe frame
        # {"items": {dominant_item_name: 1}} -- the fill reads
        # only frame["items"], so the probe makes the fill
        # answer for the dominant item; gated on
        # dump_neighbour_live, live-managed frames only).
        self.assertEqual(burst_drill.count('source_burst_drill_dump_neighbour_live_fill_state('), 3)
        self.assertIn('source_burst_drill_dump_neighbour_live_fill_state(game, cell, int(block.properties.get("size", 1)), frame, content_item_ids)', burst_drill)
        # The tick wires the fill BEFORE the dump reads the
        # frame arrays: supplied arrays WIN (the N2381
        # precedent -- the N2282/N2360 proofs seed the
        # arrays by hand, so a fill there would overwrite the
        # seed), and a previously live-filled frame
        # (dump_neighbour_live -- port bookkeeping, not Java
        # state) refreshes every tick.
        self.assertIn('has_supplied_dump_neighbour_arrays', burst_drill)
        self.assertIn('frame["dump_neighbour_live"] = true', burst_drill)
        self.assertIn('bool(frame.get("dump_neighbour_live", false))', burst_drill)
        self.assertLess(
            burst_drill.index('source_burst_drill_dump_neighbour_live_fill_state(game, cell, int(block.properties.get("size", 1)), frame, content_item_ids)'),
            burst_drill.index('frame.get("dump_neighbour_accepts", [])'),
        )
        self.assertLess(
            burst_drill.index('frame["dump_neighbour_accepts"] = filled.get("dump_neighbour_accepts", [])'),
            burst_drill.index('frame.get("dump_neighbour_accepts", [])'),
        )
        self.assertLess(
            burst_drill.index('frame["dump_neighbour_can_dump"] = filled.get("dump_neighbour_can_dump", [])'),
            burst_drill.index('frame.get("dump_neighbour_can_dump", [])'),
        )
        # The N2282/N2360 dump pins still hold: the dump call,
        # the frame-input reads, and the dump doc strings.
        self.assertIn('source_burst_drill_timer_dump_state(frame, source_delta, time_scale, dominant_item_name, content_item_ids, neighbour_accepts, neighbour_can_dump)', burst_drill)
        self.assertEqual(burst_drill.count('source_burst_drill_timer_dump_state('), 2)
        self.assertIn('frame.get("dump_neighbour_accepts", [])', burst_drill)
        self.assertIn('frame.get("dump_neighbour_can_dump", [])', burst_drill)
        self.assertIn('timerDump dump LIVE (N2282)', burst_drill)
        self.assertIn('timerDump neighbour write-back live since N2360', burst_drill)
        self.assertIn('gate LIVE (N2203)', burst_drill)
        self.assertIn('updateTile advance LIVE (N2219)', burst_drill)
        # The documented limits now record the dump neighbour
        # live fill as live (N2403).
        self.assertIn('dump neighbour live fill is live since N2403', burst_drill)
        self.assertIn('static func source_burst_drill_timer_dump_state', burst_drill)
        self.assertIn('static func source_burst_drill_update_tile_advance_state', burst_drill)
        self.assertIn('static func source_burst_drill_should_consume_state', burst_drill)
        self.assertIn('static func source_burst_drill_tick_buildings_state', burst_drill)
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
        # getMaximumAccepted (:781-783), plus the filter
        # read (Block.java:774-776) and the itemCapacity
        # default (:75).
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
        # The proof's keys drive the fill (the accepts array,
        # the canDump array, the consumesItem gate, the
        # capacity gate, the no-frame outcome) plus the live
        # tick (a live burst drill with NO seeded arrays
        # dumps through the live fill).
        proof = BURST_DRILL_DUMP_NEIGHBOUR_LIVE_FILL_PROOF.read_text(encoding='utf-8')
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
        self.assertIn('preload("res://src/game/SourceBurstDrillBuildState.gd")', proof)
        self.assertTrue(BURST_DRILL_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertTrue(BLOCK_GEOMETRY.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('burst_drill_build_state.source_burst_drill_dump_neighbour_live_fill_state(', proof)
        self.assertIn('burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = BURST_DRILL_DUMP_NEIGHBOUR_LIVE_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BurstDrillDumpNeighbourLiveFillProof.gd', scene)
        self.assertIn('C07BurstDrillDumpNeighbourLiveFillProof', scene)

    def test_reference_graph_and_actual_c07_burst_drill_dump_neighbour_live_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillDumpNeighbourLiveFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_DUMP_NEIGHBOUR_LIVE_FILL_PROOF ')]
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
