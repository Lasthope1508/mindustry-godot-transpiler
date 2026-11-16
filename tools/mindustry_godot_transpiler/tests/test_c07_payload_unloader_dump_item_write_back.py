import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_UNLOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadUnloaderBuildState.gd'
BUILDING_ITEM_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingItemState.gd'
ITEM_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceItemBridgeBuildState.gd'
PAYLOAD_UNLOADER_DUMP_ITEM_WRITE_BACK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderDumpItemWriteBackProof.gd'
PAYLOAD_UNLOADER_DUMP_ITEM_WRITE_BACK_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderDumpItemWriteBackProof.tscn'


class C07PayloadUnloaderDumpItemWriteBackTests(unittest.TestCase):
    def test_c07_payload_unloader_dump_item_write_back_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2386']['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_dump_state')
        # N2293 ported the dump rows (dumpLiquid(current) 2f +
        # offloadSpeed x dumpAccumulate() at the end of
        # updateTile, PayloadUnloader.java:105-108) -- but the
        # dumped liquid/item left the store without landing
        # in any neighbour store: Java hands the item over
        # for real (`other.handleItem(self(), item);`,
        # BuildingComp.java:1089), and handleItem is
        # `items.add(item, 1);`
        # (BuildingComp.java:860-862). N2380 wired the LIQUID
        # half (dump_neighbour_index + dumped_liquid_name +
        # the N2371 helper); N2386 is the ITEM half (the
        # N2368/N2369 pattern): the dump advance exposes
        # dump_deliveries -- one {"neighbour_index": ...,
        # "item": ...} dict per successful dump attempt, in
        # attempt order -- and the tick lands each dumped
        # item in the neighbour store through the shared
        # source_neighbour_item_write_back_state helper
        # (N2353). ARRAY, not a scalar pair: dumpAccumulate
        # "May dump multiple times per frame"
        # (BuildingComp.java:1052) and offloadSpeed 4 runs
        # it 4 times per tick, so one tick can dump several
        # items and a scalar would drop every delivery but
        # one. KEY COLLISION: dump_neighbour_index is
        # ALREADY the liquid half's scalar key (N2380) -- the
        # item half does NOT reuse it; the deliveries array
        # carries the item routing instead. One new symbol;
        # the six N2293 dump result symbols + the two N2380
        # liquid keys are re-listed (the N2321
        # shared-ownership precedent). The schema + contract
        # fold lives in a later schema-sync slice (the N2367
        # precedent), NOT here.
        self.assertEqual(
            ledger['N2386']['source_symbols'],
            [
                'source_payload_unloader_dump_state_result.liquids_after',
                'source_payload_unloader_dump_state_result.dumped_liquid',
                'source_payload_unloader_dump_state_result.items_after',
                'source_payload_unloader_dump_state_result.dumped_items',
                'source_payload_unloader_dump_state_result.cursor_after',
                'source_payload_unloader_dump_state_result.dump_accum_after',
                'source_payload_unloader_dump_state_result.dump_neighbour_index',
                'source_payload_unloader_dump_state_result.dumped_liquid_name',
                'source_payload_unloader_dump_state_result.dump_deliveries',
            ],
        )
        for name in ledger['N2386']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_dump_state')
        self.assertEqual(ledger['N2386']['runtime_proof'], '/root/C07PayloadUnloaderDumpItemWriteBackProof')
        self.assertEqual(
            ledger['N2386']['tests'],
            [
                'test_c07_payload_unloader_dump_item_write_back_registration',
                'test_all_c07_payload_unloader_dump_item_write_back_input_evidence_is_exact',
                'test_payload_unloader_dump_item_write_back_state',
                'test_reference_graph_and_actual_c07_payload_unloader_dump_item_write_back',
            ],
        )
        self.assertTrue(ledger['N2386']['deferred_exprs'])
        # This slice RESOLVES the dump neighbour write-back
        # entry (DEFERRED #304 in the coordinator's merged
        # numbering, base DEFERRED-after-advances-20, 306
        # entries): both halves are live now, so the entry
        # is REMOVED and the list drops to 305. The liquid
        # follow-ups entry (#301) still mentions the Unloader
        # item half -- the coordinator rewrites it at merge;
        # it stays as-is here. The dump neighbour live fill
        # (the neighbour arrays are still frame inputs,
        # default []) stays deferred, and no new deferral is
        # added.
        self.assertEqual(len(ledger['N2386']['deferred_exprs']), 305)
        self.assertFalse(any(entry.startswith('PayloadUnloader dump neighbour write-back (') for entry in ledger['N2386']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadUnloader dump neighbour live fill (') for entry in ledger['N2386']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Neighbour liquid write-back follow-ups (') for entry in ledger['N2386']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Neighbour item write-back follow-ups (') for entry in ledger['N2386']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadUnloader live front query (') for entry in ledger['N2386']['deferred_exprs']))

    def test_all_c07_payload_unloader_dump_item_write_back_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2386']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_dump_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2386']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_unloader_dump_item_write_back_state(self):
        payload_unloader = PAYLOAD_UNLOADER_STATE.read_text(encoding='utf-8')
        # The dump advance (N2293) now exposes its item
        # deliveries: dumpAccumulate can dump MULTIPLE
        # times per frame ("May dump multiple times per
        # frame. Use with care.",
        # BuildingComp.java:1052, and offloadSpeed 4 runs it
        # 4 times per tick, PayloadUnloader.java:105-108),
        # so a scalar routed index + item would drop every
        # delivery but one -- the advance returns
        # dump_deliveries, one {"neighbour_index": ...,
        # "item": ...} dict per successful dump attempt, in
        # attempt order (empty when nothing dumped). The
        # routed index is the handled index the shared
        # dump_item_state reports (handled_index, the (i +
        # dump) % proximity.size neighbour dump(null) handed
        # to, `other.handleItem(self(), item);`,
        # BuildingComp.java:1089) and the item is its
        # handled_item. Index i is ring cell i (the N2353
        # convention): the helper resolves the index
        # through the source_block_proximity_cells_state
        # ring, so the live fill must fill the frame
        # neighbour inputs in ring order. KEY COLLISION:
        # dump_neighbour_index is ALREADY the liquid half's
        # scalar key (N2380) -- the item half does NOT reuse
        # it and does NOT add a second scalar pair; the
        # liquid keys are untouched. The key is a
        # registered symbol of this slice (the N2360
        # pattern); the schema/contract fold waits for a
        # later schema-sync slice (the N2367 precedent).
        self.assertIn('var dump_deliveries: Array = []', payload_unloader)
        self.assertIn('dump_deliveries.append({"neighbour_index": int(result.get("handled_index", -1)), "item": str(result.get("handled_item", ""))})', payload_unloader)
        self.assertIn('"dump_deliveries": dump_deliveries', payload_unloader)
        self.assertIn('"neighbour_index"', payload_unloader)
        self.assertIn('"dump_neighbour_index": dump_neighbour_index, "dumped_liquid_name": dumped_liquid_name', payload_unloader)
        # The tick wires the shared helper after the dump
        # advance write-back (one call per delivery, amount
        # 1 -- one handleItem per dump, BuildingComp:1089),
        # with the catalog size (the unloader is size 3)
        # and the delivery's routed index + item, reading
        # the origin_cell meta inline as dump_cell (cell is
        # bound after the enabled block, the N2363 note).
        # A failed write-back (no sprite / no frame / no
        # items store / full belt) drops the item -- the
        # routing already decided, so there is no fallback
        # to the unloader's own store (the N2353 precedent).
        # The liquid wiring (N2380, above) is untouched.
        self.assertIn('preload("res://src/game/SourceBuildingItemState.gd")', payload_unloader)
        self.assertIn('for delivery in dumped.get("dump_deliveries", []):', payload_unloader)
        self.assertIn('source_building_item_state.source_neighbour_item_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), delivery_index, delivery_item, 1)', payload_unloader)
        self.assertLess(
            payload_unloader.index('frame["dumped_items"] = dumped["dumped_items"]'),
            payload_unloader.index('for delivery in dumped.get("dump_deliveries", []):'),
        )
        self.assertLess(
            payload_unloader.index('source_building_liquid_state.source_neighbour_liquid_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid_name", "")), float(dumped.get("dumped_liquid", 0.0)))'),
            payload_unloader.index('for delivery in dumped.get("dump_deliveries", []):'),
        )
        # The documented limits now record the dump
        # neighbour write-back as live for BOTH halves
        # (N2380 liquid + N2386 item) and the old
        # item-half deferral text is gone; the N2293 dump,
        # the N2232 advance, the N2209 gate, and the N2279
        # live fill are preserved. (The N2380 deferral
        # wording survives only as a quoted historical note
        # on the handleItem line, so the N2380 pin still
        # reads true.)
        self.assertIn('Dump neighbour write-back live since N2386', payload_unloader)
        self.assertIn('dump neighbour write-back (liquid half) is live since N2380', payload_unloader)
        self.assertNotIn('waits for its own follow-through slice', payload_unloader)
        self.assertNotIn('without landing in any neighbour store yet', payload_unloader)
        self.assertIn('dump rows live (N2293)', payload_unloader)
        self.assertIn('shouldConsume gate live (N2209)', payload_unloader)
        self.assertIn('updateTile advance live (N2232)', payload_unloader)
        self.assertIn('live payload fill live (N2279)', payload_unloader)
        self.assertIn('static func source_payload_unloader_dump_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_update_tile_advance_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_should_consume_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_tick_buildings_state', payload_unloader)
        # The shared helper exists with its N2353 contract
        # (the item arrives by name, amount 1 per dump; no
        # sprite / no frame / no store / full belt reports
        # written false with a reason).
        item_state = BUILDING_ITEM_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_neighbour_item_write_back_state(game: Object, cell: Vector2i, size: int, neighbour_index: int, item: String, amount: int) -> Dictionary:', item_state)
        self.assertIn('"no_frame"', item_state)
        # The proof's keys drive the advance's exposed
        # deliveries (single / multi / second-neighbour /
        # no-dump) and the live tick (dumped items land in
        # the neighbour frame; dumped items to a storeless
        # neighbour still leave the unloader).
        proof = PAYLOAD_UNLOADER_DUMP_ITEM_WRITE_BACK_PROOF.read_text(encoding='utf-8')
        for key in [
            'advance_exposes_dump_deliveries',
            'live_tick_writes_dumped_item_to_neighbour_frame',
            'live_tick_dumped_item_leaves_unloader_without_frame',
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
        self.assertIn('preload("res://src/game/SourceBuildingItemState.gd")', proof)
        self.assertTrue(BUILDING_ITEM_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceItemBridgeBuildState.gd")', proof)
        self.assertTrue(ITEM_BRIDGE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('payload_unloader_build_state.source_payload_unloader_dump_state(', proof)
        self.assertIn('payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = PAYLOAD_UNLOADER_DUMP_ITEM_WRITE_BACK_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadUnloaderDumpItemWriteBackProof.gd', scene)
        self.assertIn('C07PayloadUnloaderDumpItemWriteBackProof', scene)

    def test_reference_graph_and_actual_c07_payload_unloader_dump_item_write_back(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadUnloaderDumpItemWriteBackProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_UNLOADER_DUMP_ITEM_WRITE_BACK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'advance_exposes_dump_deliveries',
            'live_tick_writes_dumped_item_to_neighbour_frame',
            'live_tick_dumped_item_leaves_unloader_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
