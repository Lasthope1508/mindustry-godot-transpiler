import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_DECONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadDeconstructorBuildState.gd'
BUILDING_ITEM_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingItemState.gd'
BLOCK_GEOMETRY = ROOT / 'godot-mindustry/src/game/SourceBlockGeometry.gd'
PAYLOAD_DECONSTRUCTOR_DUMP_NEIGHBOUR_LIVE_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorDumpNeighbourLiveFillProof.gd'
PAYLOAD_DECONSTRUCTOR_DUMP_NEIGHBOUR_LIVE_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorDumpNeighbourLiveFillProof.tscn'
PAYLOAD_DECONSTRUCTOR_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java'
BUILDING_COMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/Block.java'


class C07PayloadDeconstructorDumpNeighbourLiveFillTests(unittest.TestCase):
    def test_c07_payload_deconstructor_dump_neighbour_live_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2407']['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_dump_neighbour_live_fill_state')
        # N2276 ported the dump rows (dumpRate 4 x
        # dumpAccumulate() at the top of updateTile,
        # PayloadDeconstructor.java:111-115, BEFORE the
        # deconstructing progress block, :117+) -- but the
        # two neighbour arrays stayed frame inputs (default
        # []), so a live deconstructor with no fill read an
        # empty proximity and never dumped. N2368 wired the
        # neighbour write-back (the N2353 item helper lands
        # the routed dump in the neighbour store) -- but
        # with no fill the routing never ran. N2407 is the
        # live fill: the tick scans the live proximity (the
        # source_block_proximity_cells_state ring, index i
        # is ring cell i, the N2353 convention) BEFORE the
        # dump pure and fills the two arrays from the live
        # neighbour frames -- accepts/canDump from the
        # DEFAULT BuildingComp gates (acceptItem REQUIRES
        # consumesItem, BuildingComp.java:864-866; the
        # canDump default is true, :1124-1126).
        # Per-block overrides are OUT of scope (a neighbour
        # with a modeled override is evaluated with the
        # DEFAULT gate here -- the override dispatch is a
        # follow-through note, not a new DEFERRED entry).
        # Two new symbols, one per filled array.
        self.assertEqual(
            ledger['N2407']['source_symbols'],
            [
                'source_payload_deconstructor_dump_neighbour_live_fill_state_result.dump_neighbour_accepts',
                'source_payload_deconstructor_dump_neighbour_live_fill_state_result.dump_neighbour_can_dump',
            ],
        )
        for name in ledger['N2407']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_dump_neighbour_live_fill_state')
        self.assertEqual(ledger['N2407']['runtime_proof'], '/root/C07PayloadDeconstructorDumpNeighbourLiveFillProof')
        self.assertEqual(
            ledger['N2407']['tests'],
            [
                'test_c07_payload_deconstructor_dump_neighbour_live_fill_registration',
                'test_all_c07_payload_deconstructor_dump_neighbour_live_fill_input_evidence_is_exact',
                'test_payload_deconstructor_dump_neighbour_live_fill_state',
                'test_reference_graph_and_actual_c07_payload_deconstructor_dump_neighbour_live_fill',
            ],
        )
        self.assertTrue(ledger['N2407']['deferred_exprs'])
        # This slice RESOLVES the dump neighbour live fill
        # entry (DEFERRED #217 in the coordinator's merged
        # numbering, base DEFERRED-after-advances-22, 298
        # entries): the fill is live now, so the entry is
        # REMOVED and the list drops to 297. No new entry:
        # the override-dispatch follow-through is a note, not
        # a deferral. The other PayloadDeconstructor entries
        # stay verbatim.
        self.assertEqual(len(ledger['N2407']['deferred_exprs']), 297)
        self.assertFalse(any(entry.startswith('PayloadDeconstructor dump neighbour live fill (') for entry in ledger['N2407']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor draw / icons rows (') for entry in ledger['N2407']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor setBars row (') for entry in ledger['N2407']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor read/write rows (') for entry in ledger['N2407']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor Fx.breakBlock finish effect (') for entry in ledger['N2407']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor moveInPayload live payload positioning (') for entry in ledger['N2407']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor puddles liquid dump (') for entry in ledger['N2407']['deferred_exprs']))

    def test_all_c07_payload_deconstructor_dump_neighbour_live_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2407']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_dump_neighbour_live_fill_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2407']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_deconstructor_dump_neighbour_live_fill_state(self):
        payload_deconstructor = PAYLOAD_DECONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The live fill (N2407, DEFERRED #217): the tick fills
        # the two neighbour arrays from the live proximity
        # BEFORE the dump pure reads them. Index i is ring
        # cell i (the N2353 convention -- the ring comes from
        # source_block_proximity_cells_state, the sprite from
        # block_sprite_at_cell, the frame from the first
        # SOURCE_CONSUMER_FRAME_META_KEYS meta on the sprite,
        # the N2353/N2371 resolution path). accepts/canDump
        # come from the DEFAULT gates (acceptItem REQUIRES
        # consumesItem -- not just capacity -- plus
        # items.get < getMaximumAccepted,
        # BuildingComp.java:864-866, with getMaximumAccepted
        # = block.itemCapacity, :781-783; the canDump
        # default is true, :1124-1126). consumesItem reads
        # the itemFilter (Block.java:774-775), which the port
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
        self.assertIn('static func source_payload_deconstructor_dump_neighbour_live_fill_state(game: Object, cell: Vector2i, size: int, frame: Dictionary, item_order: Array) -> Dictionary:', payload_deconstructor)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', payload_deconstructor)
        self.assertIn('public boolean acceptItem(Building source, Item item){', payload_deconstructor)
        self.assertIn('return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);', payload_deconstructor)
        self.assertIn('public int getMaximumAccepted(Item item){', payload_deconstructor)
        self.assertIn('return block.itemCapacity;', payload_deconstructor)
        self.assertIn('public boolean canDump(Building to, Item item){', payload_deconstructor)
        self.assertIn('if(other.acceptItem(self(), item) && canDump(other, item)){', payload_deconstructor)
        self.assertIn('public boolean consumesItem(Item item){', payload_deconstructor)
        self.assertIn('return itemFilter[item.id];', payload_deconstructor)
        self.assertIn('public int itemCapacity = 10;', payload_deconstructor)
        # The fill reuses the shared resolution path -- the
        # ring, the cell lookup, the frame-key list -- never a
        # hand-rolled scan. The power-graph and liquid-state
        # preloads are cycle-free (verified by transitive
        # closure: neither the 105-file power-graph tree nor
        # the 53-file liquid-state tree contains this file,
        # and this file already reaches both through the item
        # state).
        self.assertIn('preload("res://src/game/SourcePlacedPowerGraphState.gd")', payload_deconstructor)
        self.assertIn('preload("res://src/game/SourceBuildingLiquidState.gd")', payload_deconstructor)
        self.assertIn('source_block_proximity_cells_state(size, cell.x, cell.y)', payload_deconstructor)
        self.assertIn('game.call("block_sprite_at_cell", neighbour_cell)', payload_deconstructor)
        self.assertIn('SOURCE_CONSUMER_FRAME_META_KEYS', payload_deconstructor)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY', payload_deconstructor)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_BLOCK_IDS', payload_deconstructor)
        self.assertIn('properties.get("consumeItem", [])', payload_deconstructor)
        self.assertIn('properties.get("itemCapacity", 10)', payload_deconstructor)
        self.assertIn('"dump_neighbour_accepts": neighbour_accepts', payload_deconstructor)
        self.assertIn('"dump_neighbour_can_dump": neighbour_can_dump', payload_deconstructor)
        # The fill is called exactly once (its definition plus
        # the one tick call site), with the tick-bound cell
        # (cell is bound before the enabled block, so no
        # inline origin_cell read is needed -- unlike the
        # N2394/N2363 note), the catalog size, and the
        # content item order.
        self.assertEqual(payload_deconstructor.count('source_payload_deconstructor_dump_neighbour_live_fill_state('), 2)
        self.assertIn('source_payload_deconstructor_dump_neighbour_live_fill_state(game, cell, int(block.properties.get("size", 1)), frame, content_item_ids)', payload_deconstructor)
        # The tick wires the fill BEFORE the dump reads the
        # frame arrays: supplied arrays WIN (the N2381
        # precedent -- the N2276/N2368 proofs seed the
        # arrays by hand, so a fill there would overwrite the
        # seed), and a previously live-filled frame
        # (dump_neighbour_live -- port bookkeeping, not Java
        # state) refreshes every tick.
        self.assertIn('has_supplied_dump_neighbour_arrays', payload_deconstructor)
        self.assertIn('frame["dump_neighbour_live"] = true', payload_deconstructor)
        self.assertIn('bool(frame.get("dump_neighbour_live", false))', payload_deconstructor)
        self.assertLess(
            payload_deconstructor.index('source_payload_deconstructor_dump_neighbour_live_fill_state(game, cell, int(block.properties.get("size", 1)), frame, content_item_ids)'),
            payload_deconstructor.index('frame.get("dump_neighbour_accepts", [])'),
        )
        self.assertLess(
            payload_deconstructor.index('frame["dump_neighbour_accepts"] = filled.get("dump_neighbour_accepts", [])'),
            payload_deconstructor.index('frame.get("dump_neighbour_accepts", [])'),
        )
        self.assertLess(
            payload_deconstructor.index('frame["dump_neighbour_can_dump"] = filled.get("dump_neighbour_can_dump", [])'),
            payload_deconstructor.index('frame.get("dump_neighbour_can_dump", [])'),
        )
        # The N2276 dump pins still hold: the dump call, the
        # frame-input reads, the 2-call count, and the dump
        # doc strings.
        self.assertIn('source_payload_deconstructor_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)', payload_deconstructor)
        self.assertEqual(payload_deconstructor.count('source_payload_deconstructor_dump_state('), 2)
        self.assertIn('frame.get("dump_neighbour_accepts", [])', payload_deconstructor)
        self.assertIn('frame.get("dump_neighbour_can_dump", [])', payload_deconstructor)
        self.assertIn('Dump rows live (N2276)', payload_deconstructor)
        self.assertIn('Dump neighbour write-back live since N2368', payload_deconstructor)
        self.assertIn('shouldConsume gate live (N2210)', payload_deconstructor)
        self.assertIn('Partial updateTile advance (N2233)', payload_deconstructor)
        self.assertIn('Live deconstructing fill live (N2291)', payload_deconstructor)
        # The documented limits now record the dump neighbour
        # live fill as live (N2407).
        self.assertIn('dump neighbour live fill is live since N2407', payload_deconstructor)
        self.assertIn('static func source_payload_deconstructor_dump_state', payload_deconstructor)
        self.assertIn('static func source_payload_deconstructor_update_tile_advance_state', payload_deconstructor)
        self.assertIn('static func source_payload_deconstructor_should_consume_state', payload_deconstructor)
        self.assertIn('static func source_payload_deconstructor_tick_buildings_state', payload_deconstructor)
        # The shared helpers exist with their N2353
        # contracts (index i is ring cell i; no sprite / no
        # frame / no store reports written false).
        item_state = BUILDING_ITEM_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_neighbour_item_write_back_state(game: Object, cell: Vector2i, size: int, neighbour_index: int, item: String, amount: int) -> Dictionary:', item_state)
        self.assertIn('"no_frame"', item_state)
        geometry = BLOCK_GEOMETRY.read_text(encoding='utf-8')
        self.assertIn('static func source_block_proximity_cells_state(block_size: int, tile_x: int, tile_y: int) -> Dictionary:', geometry)
        # Scope pins, by Java line number: the dump block
        # runs BEFORE the deconstructing progress block
        # (PayloadDeconstructor.java:111-115 before :117+),
        # the default gates (BuildingComp.java:864-866,
        # :1124-1126) and getMaximumAccepted (:781-783), plus
        # the filter read (Block.java:774-775) and the
        # itemCapacity default (:75).
        deconstructor_lines = PAYLOAD_DECONSTRUCTOR_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(deconstructor_lines[110].strip(), 'if(items.total() > 0){')
        self.assertEqual(deconstructor_lines[112].strip(), 'dumpAccumulate();')
        self.assertEqual(deconstructor_lines[116].strip(), 'if(deconstructing == null){')
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
        # tick (a live deconstructor with NO seeded arrays
        # dumps through the live fill).
        proof = PAYLOAD_DECONSTRUCTOR_DUMP_NEIGHBOUR_LIVE_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'fill_accepts_from_live_neighbour',
            'fill_can_dump_from_live_neighbour',
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
        self.assertIn('preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_DECONSTRUCTOR_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertTrue(BLOCK_GEOMETRY.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('payload_deconstructor_build_state.source_payload_deconstructor_dump_neighbour_live_fill_state(', proof)
        self.assertIn('payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = PAYLOAD_DECONSTRUCTOR_DUMP_NEIGHBOUR_LIVE_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadDeconstructorDumpNeighbourLiveFillProof.gd', scene)
        self.assertIn('C07PayloadDeconstructorDumpNeighbourLiveFillProof', scene)

    def test_reference_graph_and_actual_c07_payload_deconstructor_dump_neighbour_live_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadDeconstructorDumpNeighbourLiveFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_DECONSTRUCTOR_DUMP_NEIGHBOUR_LIVE_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fill_accepts_from_live_neighbour',
            'fill_can_dump_from_live_neighbour',
            'fill_accepts_gate_requires_consumes_item',
            'fill_accepts_gate_requires_capacity',
            'fill_no_frame_neighbour_reports_empty',
            'live_tick_dumps_with_live_fill',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
