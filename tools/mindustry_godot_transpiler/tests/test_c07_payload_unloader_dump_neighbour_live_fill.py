import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_UNLOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadUnloaderBuildState.gd'
BUILDING_ITEM_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingItemState.gd'
BUILDING_LIQUID_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingLiquidState.gd'
BLOCK_GEOMETRY = ROOT / 'godot-mindustry/src/game/SourceBlockGeometry.gd'
PAYLOAD_UNLOADER_DUMP_NEIGHBOUR_LIVE_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderDumpNeighbourLiveFillProof.gd'
PAYLOAD_UNLOADER_DUMP_NEIGHBOUR_LIVE_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderDumpNeighbourLiveFillProof.tscn'
PAYLOAD_UNLOADER_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/PayloadUnloader.java'
BUILDING_COMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/Block.java'


class C07PayloadUnloaderDumpNeighbourLiveFillTests(unittest.TestCase):
    def test_c07_payload_unloader_dump_neighbour_live_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2394']['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_dump_neighbour_live_fill_state')
        # N2293 ported the dump rows (dumpLiquid(current) 2f +
        # offloadSpeed x dumpAccumulate() at the end of
        # updateTile, PayloadUnloader.java:105-108) -- but the
        # six neighbour arrays stayed frame inputs (default
        # []), so a live unloader with no fill read an empty
        # proximity and never dumped. N2380/N2386 wired the
        # neighbour write-backs (the N2371 liquid + N2353 item
        # helpers land the routed dump in the neighbour store)
        # -- but with no fill the routing never ran. N2394 is
        # the live fill: the tick scans the live proximity
        # (the source_block_proximity_cells_state ring, index
        # i is ring cell i, the N2353 convention) BEFORE the
        # dump pure and fills the six arrays from the live
        # neighbour frames -- liquid amounts + capacities from
        # the neighbour liquids modules, accepts/canDump from
        # the DEFAULT BuildingComp gates (acceptItem REQUIRES
        # consumesItem, BuildingComp.java:864-866; acceptLiquid
        # is hasLiquids && consumesLiquid, :868-870; both
        # canDump defaults are true, :910-912/:1124-1126).
        # Per-block overrides are OUT of scope (a neighbour
        # with a modeled override is evaluated with the
        # DEFAULT gate here -- the override dispatch is a
        # follow-through note, not a new DEFERRED entry).
        # Six new symbols, one per filled array.
        self.assertEqual(
            ledger['N2394']['source_symbols'],
            [
                'source_payload_unloader_dump_neighbour_live_fill_state_result.dump_neighbour_liquid_amounts',
                'source_payload_unloader_dump_neighbour_live_fill_state_result.dump_neighbour_liquid_capacities',
                'source_payload_unloader_dump_neighbour_live_fill_state_result.dump_neighbour_accepts_liquid',
                'source_payload_unloader_dump_neighbour_live_fill_state_result.dump_neighbour_can_dump_liquid',
                'source_payload_unloader_dump_neighbour_live_fill_state_result.dump_neighbour_accepts_item',
                'source_payload_unloader_dump_neighbour_live_fill_state_result.dump_neighbour_can_dump_item',
            ],
        )
        for name in ledger['N2394']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_dump_neighbour_live_fill_state')
        self.assertEqual(ledger['N2394']['runtime_proof'], '/root/C07PayloadUnloaderDumpNeighbourLiveFillProof')
        self.assertEqual(
            ledger['N2394']['tests'],
            [
                'test_c07_payload_unloader_dump_neighbour_live_fill_registration',
                'test_all_c07_payload_unloader_dump_neighbour_live_fill_input_evidence_is_exact',
                'test_payload_unloader_dump_neighbour_live_fill_state',
                'test_reference_graph_and_actual_c07_payload_unloader_dump_neighbour_live_fill',
            ],
        )
        self.assertTrue(ledger['N2394']['deferred_exprs'])
        # This slice RESOLVES the dump neighbour live fill
        # entry (DEFERRED #248 in the coordinator's merged
        # numbering, base DEFERRED-after-advances-21, 301
        # entries): the fill is live now, so the entry is
        # REMOVED and the list drops to 300. No new entry:
        # the override-dispatch follow-through is a note, not
        # a deferral. The campaign-unlock surfacing, the live
        # front query, and the movePayload/dumpPayload
        # application entries stay verbatim.
        self.assertEqual(len(ledger['N2394']['deferred_exprs']), 300)
        self.assertFalse(any(entry.startswith('PayloadUnloader dump neighbour live fill (') for entry in ledger['N2394']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadUnloader dumpLiquid campaign unlock surfacing (') for entry in ledger['N2394']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadUnloader live front query (') for entry in ledger['N2394']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadUnloader movePayload/dumpPayload application (') for entry in ledger['N2394']['deferred_exprs']))

    def test_all_c07_payload_unloader_dump_neighbour_live_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2394']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_dump_neighbour_live_fill_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2394']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_unloader_dump_neighbour_live_fill_state(self):
        payload_unloader = PAYLOAD_UNLOADER_STATE.read_text(encoding='utf-8')
        # The live fill (N2394, DEFERRED #248): the tick fills
        # the six neighbour arrays from the live proximity
        # BEFORE the dump pure reads them. Index i is ring
        # cell i (the N2353 convention -- the ring comes from
        # source_block_proximity_cells_state, the sprite from
        # block_sprite_at_cell, the frame from the first
        # SOURCE_CONSUMER_FRAME_META_KEYS meta on the sprite,
        # the N2353/N2371 resolution path). Liquid amounts +
        # capacities come from the neighbour liquids modules
        # (the dumped current liquid only -- the pure dumps
        # liquids.current(), so the fill reads that id);
        # accepts/canDump come from the DEFAULT gates
        # (acceptItem REQUIRES consumesItem -- not just
        # capacity -- plus items.get < getMaximumAccepted,
        # BuildingComp.java:864-866, with getMaximumAccepted
        # = block.itemCapacity, :781-783; acceptLiquid is
        # hasLiquids && consumesLiquid, :868-870; both
        # canDump defaults are true, :910-912/:1124-1126).
        # consumesItem/consumesLiquid read the itemFilter /
        # liquidFilter (Block.java:774-780), which the port
        # represents as the catalog consumeItem /
        # consumeLiquid rows. The item gate answers for the
        # FIRST held item in content order -- the item the
        # dump pure offers (its accepts array is
        # per-neighbour, not per-item, so a per-item answer
        # would misdeliver: Java tries later held items
        # against the same neighbour, and that per-item
        # routing waits for a dump-shape slice). Per-block
        # overrides are OUT of scope: a neighbour with a
        # modeled override is evaluated with the DEFAULT
        # gate here. A neighbour with no frame (no sprite /
        # unknown def / conduit / no meta-key frame) reports
        # the no-frame outcome -- 0.0 / 0.0 / false / false /
        # false / false -- the N2353/N2371 no-frame
        # precedent (a routed item/liquid to a frameless
        # neighbour drops, so the fill closes the gates and
        # nothing routes there). Keep each Java expr on ONE
        # comment line (the N2148 lesson: a split line fails
        # this test).
        self.assertIn('static func source_payload_unloader_dump_neighbour_live_fill_state(game: Object, cell: Vector2i, size: int, frame: Dictionary, item_order: Array) -> Dictionary:', payload_unloader)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', payload_unloader)
        self.assertIn('public boolean acceptItem(Building source, Item item){', payload_unloader)
        self.assertIn('return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);', payload_unloader)
        self.assertIn('public boolean acceptLiquid(Building source, Liquid liquid){', payload_unloader)
        self.assertIn('return block.hasLiquids && block.consumesLiquid(liquid);', payload_unloader)
        self.assertIn('public int getMaximumAccepted(Item item){', payload_unloader)
        self.assertIn('return block.itemCapacity;', payload_unloader)
        self.assertIn('public boolean canDumpLiquid(Building to, Liquid liquid){', payload_unloader)
        self.assertIn('public boolean canDump(Building to, Item item){', payload_unloader)
        self.assertIn('if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){', payload_unloader)
        self.assertIn('float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;', payload_unloader)
        self.assertIn('if(other.acceptItem(self(), item) && canDump(other, item)){', payload_unloader)
        self.assertIn('public boolean consumesItem(Item item){', payload_unloader)
        self.assertIn('return itemFilter[item.id];', payload_unloader)
        self.assertIn('public boolean consumesLiquid(Liquid liq){', payload_unloader)
        self.assertIn('return liquidFilter[liq.id];', payload_unloader)
        self.assertIn('public int itemCapacity = 10;', payload_unloader)
        self.assertIn('liquidCapacity = Mathf.round(10f * consumeAmount);', payload_unloader)
        # The fill reuses the shared resolution path -- the
        # ring, the cell lookup, the frame-key list, the
        # liquid-module read -- never a hand-rolled scan. The
        # power-graph preload is cycle-free (verified by
        # transitive closure: the 105-file power-graph tree
        # does not contain this file, and this file already
        # reaches it through the item state).
        self.assertIn('preload("res://src/game/SourcePlacedPowerGraphState.gd")', payload_unloader)
        self.assertIn('source_block_proximity_cells_state(size, cell.x, cell.y)', payload_unloader)
        self.assertIn('game.call("block_sprite_at_cell", neighbour_cell)', payload_unloader)
        self.assertIn('SOURCE_CONSUMER_FRAME_META_KEYS', payload_unloader)
        self.assertIn('source_get_state(neighbour_liquids, current_id)', payload_unloader)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY', payload_unloader)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_BLOCK_IDS', payload_unloader)
        self.assertIn('properties.get("consumeItem", [])', payload_unloader)
        self.assertIn('properties.get("consumeLiquid", [])', payload_unloader)
        self.assertIn('properties.get("itemCapacity", 10)', payload_unloader)
        self.assertIn('properties.get("liquidCapacity", 10.0)', payload_unloader)
        self.assertIn('properties.get("hasLiquids", false)', payload_unloader)
        self.assertIn('"dump_neighbour_liquid_amounts": neighbour_liquid_amounts', payload_unloader)
        self.assertIn('"dump_neighbour_liquid_capacities": neighbour_liquid_capacities', payload_unloader)
        self.assertIn('"dump_neighbour_accepts_liquid": neighbour_accepts_liquid', payload_unloader)
        self.assertIn('"dump_neighbour_can_dump_liquid": neighbour_can_dump_liquid', payload_unloader)
        self.assertIn('"dump_neighbour_accepts_item": neighbour_accepts_item', payload_unloader)
        self.assertIn('"dump_neighbour_can_dump_item": neighbour_can_dump_item', payload_unloader)
        # The fill is called exactly once (its definition plus
        # the one tick call site), with the origin cell inline
        # (cell is bound after the enabled block, the N2363
        # note) and the catalog size.
        self.assertEqual(payload_unloader.count('source_payload_unloader_dump_neighbour_live_fill_state('), 2)
        self.assertIn('source_payload_unloader_dump_neighbour_live_fill_state(game, fill_cell, int(block.properties.get("size", 1)), frame, item_order)', payload_unloader)
        # The tick wires the fill BEFORE the dump reads the
        # frame arrays: supplied arrays WIN (the N2381
        # precedent -- the N2293/N2380/N2386 proofs seed the
        # arrays by hand, so a fill there would overwrite the
        # seed), and a previously live-filled frame
        # (dump_neighbour_live -- port bookkeeping, not Java
        # state) refreshes every tick.
        self.assertIn('has_supplied_dump_neighbour_arrays', payload_unloader)
        self.assertIn('frame["dump_neighbour_live"] = true', payload_unloader)
        self.assertIn('bool(frame.get("dump_neighbour_live", false))', payload_unloader)
        self.assertLess(
            payload_unloader.index('source_payload_unloader_dump_neighbour_live_fill_state(game, fill_cell, int(block.properties.get("size", 1)), frame, item_order)'),
            payload_unloader.index('frame.get("dump_neighbour_liquid_amounts", [])'),
        )
        self.assertLess(
            payload_unloader.index('frame["dump_neighbour_liquid_amounts"] = filled.get("dump_neighbour_liquid_amounts", [])'),
            payload_unloader.index('frame.get("dump_neighbour_liquid_amounts", [])'),
        )
        self.assertLess(
            payload_unloader.index('frame["liquid_names_by_id"] = liquid_names_by_id'),
            payload_unloader.index('source_payload_unloader_dump_neighbour_live_fill_state(game, fill_cell, int(block.properties.get("size", 1)), frame, item_order)'),
        )
        # The N2293 dump pins still hold: the dump call, the
        # frame-input reads, the 2-call count, and the dump
        # doc strings.
        self.assertIn('source_payload_unloader_dump_state(frame, source_delta, time_scale, item_order, dump_neighbour_liquid_amounts, dump_neighbour_liquid_capacities, dump_neighbour_accepts_liquid, dump_neighbour_can_dump_liquid, dump_neighbour_accepts_item, dump_neighbour_can_dump_item)', payload_unloader)
        self.assertEqual(payload_unloader.count('source_payload_unloader_dump_state('), 2)
        self.assertIn('dump rows live (N2293)', payload_unloader)
        self.assertIn('Dump neighbour write-back live since N2386', payload_unloader)
        self.assertIn('dump neighbour write-back (liquid half) is live since N2380', payload_unloader)
        self.assertIn('shouldConsume gate live (N2209)', payload_unloader)
        self.assertIn('updateTile advance live (N2232)', payload_unloader)
        self.assertIn('live payload fill live (N2279)', payload_unloader)
        # The documented limits now record the dump neighbour
        # live fill as live (N2394).
        self.assertIn('dump neighbour live fill is live since N2394', payload_unloader)
        self.assertIn('static func source_payload_unloader_dump_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_update_tile_advance_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_should_consume_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_tick_buildings_state', payload_unloader)
        # The shared helpers exist with their N2353/N2371
        # contracts (index i is ring cell i; no sprite / no
        # frame / no store reports written false).
        item_state = BUILDING_ITEM_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_neighbour_item_write_back_state(game: Object, cell: Vector2i, size: int, neighbour_index: int, item: String, amount: int) -> Dictionary:', item_state)
        self.assertIn('"no_frame"', item_state)
        liquid_state = BUILDING_LIQUID_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_neighbour_liquid_write_back_state(game: Object, cell: Vector2i, size: int, neighbour_index: int, liquid: String, amount: float) -> Dictionary:', liquid_state)
        self.assertIn('"no_frame"', liquid_state)
        geometry = BLOCK_GEOMETRY.read_text(encoding='utf-8')
        self.assertIn('static func source_block_proximity_cells_state(block_size: int, tile_x: int, tile_y: int) -> Dictionary:', geometry)
        # Scope pins, by Java line number: the default gates
        # (BuildingComp.java:864-870, :910-912, :1124-1126)
        # and getMaximumAccepted (:781-783), plus the filter
        # reads (Block.java:774-780) and the itemCapacity
        # default (:75).
        building_comp_lines = BUILDING_COMP_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(building_comp_lines[780].strip(), 'public int getMaximumAccepted(Item item){')
        self.assertEqual(building_comp_lines[781].strip(), 'return block.itemCapacity;')
        self.assertEqual(building_comp_lines[863].strip(), 'public boolean acceptItem(Building source, Item item){')
        self.assertEqual(building_comp_lines[864].strip(), 'return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);')
        self.assertEqual(building_comp_lines[867].strip(), 'public boolean acceptLiquid(Building source, Liquid liquid){')
        self.assertEqual(building_comp_lines[868].strip(), 'return block.hasLiquids && block.consumesLiquid(liquid);')
        self.assertEqual(building_comp_lines[909].strip(), 'public boolean canDumpLiquid(Building to, Liquid liquid){')
        self.assertEqual(building_comp_lines[910].strip(), 'return true;')
        self.assertEqual(building_comp_lines[1123].strip(), 'public boolean canDump(Building to, Item item){')
        self.assertEqual(building_comp_lines[1124].strip(), 'return true;')
        block_lines = BLOCK_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(block_lines[74].strip(), 'public int itemCapacity = 10;')
        self.assertEqual(block_lines[773].strip(), 'public boolean consumesItem(Item item){')
        self.assertEqual(block_lines[774].strip(), 'return itemFilter[item.id];')
        self.assertEqual(block_lines[777].strip(), 'public boolean consumesLiquid(Liquid liq){')
        self.assertEqual(block_lines[778].strip(), 'return liquidFilter[liq.id];')
        # The proof's keys drive the fill (the liquid arrays,
        # the item arrays, the consumesItem gate, the capacity
        # gate, the no-frame outcome) plus the live tick (a
        # live unloader with NO seeded arrays dumps through
        # the live fill).
        proof = PAYLOAD_UNLOADER_DUMP_NEIGHBOUR_LIVE_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'fill_liquid_arrays_from_live_neighbour',
            'fill_item_arrays_from_live_neighbour',
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
        self.assertIn('preload("res://src/game/SourcePayloadUnloaderBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_UNLOADER_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertTrue(BLOCK_GEOMETRY.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('payload_unloader_build_state.source_payload_unloader_dump_neighbour_live_fill_state(', proof)
        self.assertIn('payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = PAYLOAD_UNLOADER_DUMP_NEIGHBOUR_LIVE_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadUnloaderDumpNeighbourLiveFillProof.gd', scene)
        self.assertIn('C07PayloadUnloaderDumpNeighbourLiveFillProof', scene)
        # N2409 pins (the N2394 proof fix): the multi-press is
        # size 3 (Blocks.java:1059, `size = 3;`), so centred at
        # (31, 20) its footprint (30..32, 19..21) covers ring
        # 4/5/6 with ZERO origin overlap -- and the proof
        # asserts the ring-4 fill values too. The live-tick
        # values are simulation-verified (a Python mirror of
        # the exact GDScript dump_liquid_state + dump_item_state
        # semantics over this scene): liquid transfers 25.0 to
        # ring 4, 12.5 to ring 5, 6.25 to ring 6 (the fraction
        # recomputes from the running amount), so dumped 43.75
        # / live 6.25 / press 43.75; item deliveries land at
        # rings 4, 5, 6, 4 (cursor 0 -> 5 -> 6 -> 7 -> 5), so
        # the final cdump is 5 -- NOT 7, which only holds if
        # ring 4 is (wrongly) ignored. The proof must carry no
        # "size-2" claim about the multi-press.
        self.assertIn('press_cell == Vector2i(31, 20)', proof)
        self.assertIn('is_equal_approx(float(fill_amounts[4]), 5.0)', proof)
        self.assertIn('is_equal_approx(float(fill_capacities[4]), 60.0)', proof)
        self.assertIn('bool(fill_accepts_liquid[4])', proof)
        self.assertIn('bool(fill_can_dump_liquid[4])', proof)
        self.assertIn('bool(coal_accepts_item[4])', proof)
        self.assertIn('bool(coal_can_dump_item[4])', proof)
        self.assertIn('int(unloader_frame.get("cdump", -1)) == 5', proof)
        self.assertNotIn('int(unloader_frame.get("cdump", -1)) == 7', proof)
        self.assertIn('is_equal_approx(float(unloader_frame.get("dumped_liquid", -1.0)), 43.75)', proof)
        self.assertIn('is_equal_approx(live_water, 6.25)', proof)
        self.assertIn('is_equal_approx(press_water, 43.75)', proof)
        self.assertNotIn('size-2', proof)

    def test_reference_graph_and_actual_c07_payload_unloader_dump_neighbour_live_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadUnloaderDumpNeighbourLiveFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_UNLOADER_DUMP_NEIGHBOUR_LIVE_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fill_liquid_arrays_from_live_neighbour',
            'fill_item_arrays_from_live_neighbour',
            'fill_accepts_gate_requires_consumes_item',
            'fill_accepts_gate_requires_capacity',
            'fill_no_frame_neighbour_reports_empty',
            'live_tick_dumps_with_live_fill',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
