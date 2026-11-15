import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_DECONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadDeconstructorBuildState.gd'
PAYLOAD_DECONSTRUCTOR_DUMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorDumpProof.gd'
PAYLOAD_DECONSTRUCTOR_DUMP_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorDumpProof.tscn'


class C07PayloadDeconstructorDumpTests(unittest.TestCase):
    def test_c07_payload_deconstructor_dump_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2276']['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_dump_state')
        # N2166 gave the deconstructor its live power.status row,
        # N2210 its live shouldConsume gate (deconstructing !=
        # null && enabled), N2233 its updateTile advance
        # (progress / accum / transfer / finish / intake) -- but
        # the dump block at the TOP of updateTile
        # (PayloadDeconstructor.java:111-115) was RED-deferred
        # all along: dumpRate 4 x dumpAccumulate() when
        # items.total() > 0, so a deconstructor never dumped
        # anything even with a full store. N2276 is the dump
        # rows: dumpAccumulate() (BuildingComp.java:1048-1050)
        # delegates to dumpAccumulate(null)
        # (BuildingComp.java:1053-1061), which adds delta() to
        # dumpAccum and dumps while dumpAccum >= 1f, subtracting
        # 1f EVERY iteration -- unconditionally, whether or not
        # the dump succeeded. dump(null)
        # (BuildingComp.java:1072-1113) scans proximity from the
        # cdump cursor and, for each neighbour, the content
        # items in order, handing the first held item an
        # accepting neighbour takes (acceptItem && canDump),
        # removing 1 from the store and advancing the cursor.
        # Four new result symbols: the accum, the dumped flag,
        # the items, and the cursor after the tick.
        self.assertEqual(
            ledger['N2276']['source_symbols'],
            [
                'source_payload_deconstructor_dump_state_result.dump_accum_after',
                'source_payload_deconstructor_dump_state_result.dumped',
                'source_payload_deconstructor_dump_state_result.items_after',
                'source_payload_deconstructor_dump_state_result.cursor_after',
            ],
        )
        for name in ledger['N2276']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_dump_state')
        self.assertEqual(ledger['N2276']['runtime_proof'], '/root/C07PayloadDeconstructorDumpProof')
        self.assertEqual(
            ledger['N2276']['tests'],
            [
                'test_c07_payload_deconstructor_dump_registration',
                'test_all_c07_payload_deconstructor_dump_input_evidence_is_exact',
                'test_payload_deconstructor_dump_state',
                'test_reference_graph_and_actual_c07_payload_deconstructor_dump',
            ],
        )
        self.assertTrue(ledger['N2276']['deferred_exprs'])
        # This slice resolves the PayloadDeconstructor dump rows
        # deferral and adds the neighbour live fill + the
        # neighbour write-back deferrals. The live deconstructing
        # fill entry stays: the dump reads frame["items"] as-is,
        # and the handlePayload live fill still waits for its own
        # slice.
        self.assertFalse(any(entry.startswith('PayloadDeconstructor dump rows (') for entry in ledger['N2276']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor dump neighbour live fill (') for entry in ledger['N2276']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor dump neighbour write-back (') for entry in ledger['N2276']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor live deconstructing fill (') for entry in ledger['N2276']['deferred_exprs']))

    def test_all_c07_payload_deconstructor_dump_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2276']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_dump_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2276']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_deconstructor_dump_state(self):
        payload_deconstructor = PAYLOAD_DECONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The pure dump lives on the payload-deconstructor build
        # state: the updateTile dump block
        # (PayloadDeconstructor.java:111-115) runs dumpRate 4 x
        # dumpAccumulate() when items.total() > 0 -- BEFORE the
        # deconstructing progress block (:117+), so the dump
        # drains the store the advance filled LAST tick, not the
        # items the advance adds THIS tick. dumpAccumulate()
        # (BuildingComp.java:1048-1050) delegates to
        # dumpAccumulate(null) (BuildingComp.java:1053-1061):
        # dumpAccum += delta(), then while dumpAccum >= 1f dump
        # and subtract 1f -- the subtraction is UNCONDITIONAL,
        # it runs even when dump() returns false. dump(null)
        # (BuildingComp.java:1072-1113) guards on hasItems /
        # non-empty store / non-empty proximity, scans
        # proximity from the cdump cursor and, for each
        # neighbour, the content items in order, handing the
        # first held item an accepting neighbour takes
        # (acceptItem && canDump), removing 1 from the store
        # and advancing the cursor once per neighbour checked
        # (incrementDump, BuildingComp.java:1116-1120, guarded
        # on prox != 0). Keep each Java expr on ONE comment
        # line (the N2148 shootWarmup lesson: a split line
        # fails this test). delta() is Time.delta * timeScale
        # (BuildingComp.java:1922-1924) -- NOT edelta(): the
        # dump cadence ignores efficiency, so a deconstructor
        # at zero power still dumps (the N2233 advance, by
        # contrast, runs on edelta()).
        self.assertIn('static func source_payload_deconstructor_dump_state', payload_deconstructor)
        self.assertIn('if(items.total() > 0){', payload_deconstructor)
        self.assertIn('for(int i = 0; i < dumpRate; i++){', payload_deconstructor)
        self.assertIn('dumpAccumulate();', payload_deconstructor)
        self.assertIn('public boolean dumpAccumulate(){', payload_deconstructor)
        self.assertIn('return dumpAccumulate(null);', payload_deconstructor)
        self.assertIn('public boolean dumpAccumulate(Item item){', payload_deconstructor)
        self.assertIn('boolean res = false;', payload_deconstructor)
        self.assertIn('dumpAccum += delta();', payload_deconstructor)
        self.assertIn('while(dumpAccum >= 1f){', payload_deconstructor)
        self.assertIn('res |= dump(item);', payload_deconstructor)
        self.assertIn('dumpAccum -=1f;', payload_deconstructor)
        self.assertIn('public boolean dump(){', payload_deconstructor)
        self.assertIn('return dump(null);', payload_deconstructor)
        self.assertIn('public boolean dump(Item todump){', payload_deconstructor)
        self.assertIn('if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;', payload_deconstructor)
        self.assertIn('int dump = this.cdump;', payload_deconstructor)
        self.assertIn('var allItems = content.items();', payload_deconstructor)
        self.assertIn('int itemSize = allItems.size;', payload_deconstructor)
        self.assertIn('if(todump == null){', payload_deconstructor)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', payload_deconstructor)
        self.assertIn('if(!items.has(ii)) continue;', payload_deconstructor)
        self.assertIn('Item item = (Item)itemArray[ii];', payload_deconstructor)
        self.assertIn('if(other.acceptItem(self(), item) && canDump(other, item)){', payload_deconstructor)
        self.assertIn('other.handleItem(self(), item);', payload_deconstructor)
        self.assertIn('items.remove(item, 1);', payload_deconstructor)
        self.assertIn('incrementDump(proximity.size);', payload_deconstructor)
        self.assertIn('public void incrementDump(int prox){', payload_deconstructor)
        self.assertIn('if(prox != 0){', payload_deconstructor)
        self.assertIn('cdump = ((cdump + 1) % prox);', payload_deconstructor)
        self.assertIn('private transient float dumpAccum;', payload_deconstructor)
        self.assertIn('transient int cdump;', payload_deconstructor)
        self.assertIn('return Time.delta * timeScale;', payload_deconstructor)
        self.assertIn('public boolean canDump(Building to, Item item){', payload_deconstructor)
        self.assertIn('hasItems = true;', payload_deconstructor)
        self.assertIn('public int dumpRate = 4;', payload_deconstructor)
        # The dump reuses the shared dump routing -- the
        # dump(null) port SourceBuildingItemDumpState.
        # dump_item_state (the putItem gate
        # game_put_item_state is the WRONG shape here: it dumps
        # one SPECIFIC item and needs a game object for its
        # increment callbacks, while dumpAccumulate calls
        # dump(null), whose shared port is dump_item_state) --
        # and the drill inventory totals helper, never a
        # hand-rolled total. dumpRate is a driver constant (4,
        # the class default; neither def overrides it).
        self.assertIn('source_building_item_dump_state.dump_item_state(', payload_deconstructor)
        self.assertIn('inventory.items_total(items)', payload_deconstructor)
        self.assertIn('SOURCE_PAYLOAD_DECONSTRUCTOR_DUMP_RATE := 4', payload_deconstructor)
        self.assertIn('const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")', payload_deconstructor)
        # The frame carries the dump state at the Java field
        # defaults: dumpAccum 0f (BuildingComp.java:99) and
        # cdump 0 (BuildingComp.java:68); the neighbour
        # acceptItem / canDump arrays are frame inputs
        # (default [] -- no neighbours, the Java
        # proximity.size == 0 outcome) until a live proximity
        # fill lands. The tick wires the dump into the live
        # loop BEFORE the progress advance (Java order:
        # PayloadDeconstructor.java:111-115 runs before :117+),
        # inside the same enabled gate as the advance
        # (BuildingComp.java:2276-2277), with the content item
        # ids in catalog order (game source_item_catalog
        # item_names_by_id, the factory precedent) and the
        # source delta / timeScale the advance already reads.
        self.assertIn('"dump_accum": 0.0', payload_deconstructor)
        self.assertIn('"cdump": 0', payload_deconstructor)
        self.assertIn('frame.get("dump_neighbour_accepts", [])', payload_deconstructor)
        self.assertIn('frame.get("dump_neighbour_can_dump", [])', payload_deconstructor)
        self.assertIn('source_item_catalog', payload_deconstructor)
        self.assertIn('item_names_by_id', payload_deconstructor)
        self.assertIn('source_payload_deconstructor_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)', payload_deconstructor)
        self.assertIn('frame["dump_accum"]', payload_deconstructor)
        self.assertIn('frame["cdump"]', payload_deconstructor)
        self.assertLess(
            payload_deconstructor.index('source_payload_deconstructor_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)'),
            payload_deconstructor.index('source_payload_deconstructor_update_tile_advance_state(frame, source_delta, time_scale, deconstruct_speed, item_capacity, build_cost_multiplier, unit_cost_multiplier)'),
        )
        # The documented limits now record the dump as live
        # (dumpRate 4 + dumpAccumulate) and the remaining
        # deferrals (the neighbour live fill, the neighbour
        # write-back, the deconstructing fill); the N2233
        # advance, the N2210 gate, and the N2166 power row are
        # preserved.
        self.assertIn('Dump rows live (N2276)', payload_deconstructor)
        self.assertIn('Partial updateTile advance (N2233)', payload_deconstructor)
        self.assertIn('shouldConsume gate live (N2210)', payload_deconstructor)
        self.assertIn('static func source_payload_deconstructor_power_status_row_state', payload_deconstructor)
        self.assertIn('static func source_payload_deconstructor_should_consume_state', payload_deconstructor)
        self.assertIn('static func source_payload_deconstructor_update_tile_advance_state', payload_deconstructor)
        # The proof's keys drive the pure dump (the accum
        # growing by delta each call, the dump firing when the
        # accum reaches 1f -- including the unconditional
        # subtract on a failed dump -- the 4-per-tick rate, the
        # empty-store skip, the item leaving the store in
        # content order, the cursor advancing per neighbour
        # checked) plus the live tick (a placed deconstructor
        # dumps 4 items in one tick at a full accum).
        proof = PAYLOAD_DECONSTRUCTOR_DUMP_PROOF.read_text(encoding='utf-8')
        for key in [
            'dump_accumulates_with_delta',
            'dump_fires_when_accum_reaches_one',
            'dump_rate_four_per_tick',
            'no_dump_when_items_empty',
            'dump_removes_item_from_store',
            'dump_cursor_advances',
            'live_tick_dumps_item',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_DECONSTRUCTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('payload_deconstructor_build_state.source_payload_deconstructor_dump_state(', proof)
        self.assertIn('payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = PAYLOAD_DECONSTRUCTOR_DUMP_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadDeconstructorDumpProof.gd', scene)
        self.assertIn('C07PayloadDeconstructorDumpProof', scene)

    def test_reference_graph_and_actual_c07_payload_deconstructor_dump(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadDeconstructorDumpProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_DECONSTRUCTOR_DUMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'dump_accumulates_with_delta',
            'dump_fires_when_accum_reaches_one',
            'dump_rate_four_per_tick',
            'no_dump_when_items_empty',
            'dump_removes_item_from_store',
            'dump_cursor_advances',
            'live_tick_dumps_item',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
