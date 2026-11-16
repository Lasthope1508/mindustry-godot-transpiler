import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_OFFLOAD_NEIGHBOR_ROUTING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillOffloadNeighborRoutingProof.gd'
BURST_DRILL_OFFLOAD_NEIGHBOR_ROUTING_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillOffloadNeighborRoutingProof.tscn'


class C07BurstDrillOffloadNeighborRoutingTests(unittest.TestCase):
    def test_c07_burst_drill_offload_neighbor_routing_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2476']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_offload_route_state')
        # The BurstDrill updateTile STATE is live (N2219
        # advance + N2282 timerDump dump + N2360 dump
        # write-back + N2403 dump neighbour live fill +
        # N2469 offload effects rows) -- but the offload
        # itself still takes the no-neighbor fallback
        # branch (BuildingComp.java:1014,
        # `handleItem(self(), item);`) through the
        # shared inventory helper, so a burst drill
        # with an accepting neighbor still fills its
        # own store. N2476 ports the neighbor routing
        # as ONE routing pure + tick wiring:
        # source_burst_drill_offload_route_state(
        # neighbour_accepts_item, neighbour_can_dump,
        # cdump, offloaded_item_name) scans the
        # neighbour acceptItem/canDump arrays from the
        # saved cdump -- incrementDump BEFORE each
        # check (BuildingComp.java:1006), the neighbour
        # at (i + dump) % proximity.size (:1007) -- and
        # returns the routed neighbour index (-1 = the
        # fallback verdict) + the new cdump. The N2219
        # advance routes EACH offloaded item through it
        # (one offload(dominantItem) call per item,
        # BurstDrill.java:107-109) with the cdump
        # threaded across the loop, and exposes
        # offload_routed_indices + offload_fallback_count
        # + cdump so the tick can land each routed item
        # in its neighbour store through the shared
        # N2353 helper (the N2360 dump write-back
        # precedent); the fallback keeps the
        # add_item_state path. The tick refreshes the
        # N2403 neighbour arrays for the dominant item
        # before the advance (the dump fill answered
        # for the first held item at dump time, and the
        # dump write-back may have filled a neighbour
        # since -- both stale for the offload). Two new
        # result symbols: the routed index, then the
        # new cdump.
        self.assertEqual(
            ledger['N2476']['source_symbols'],
            [
                'source_burst_drill_offload_route_state_result.routed_index',
                'source_burst_drill_offload_route_state_result.cdump_after',
            ],
        )
        for name in ledger['N2476']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_offload_route_state')
        self.assertEqual(ledger['N2476']['runtime_proof'], '/root/C07BurstDrillOffloadNeighborRoutingProof')
        self.assertEqual(
            ledger['N2476']['tests'],
            [
                'test_c07_burst_drill_offload_neighbor_routing_registration',
                'test_all_c07_burst_drill_offload_neighbor_routing_input_evidence_is_exact',
                'test_burst_drill_offload_neighbor_routing_state',
                'test_reference_graph_and_actual_c07_burst_drill_offload_neighbor_routing',
            ],
        )
        self.assertTrue(ledger['N2476']['deferred_exprs'])
        # This slice ports the ROUTING half of
        # DEFERRED #89 (1-based in
        # DEFERRED-after-advances-32.py): the entry is
        # REWRITTEN IN PLACE (the N2459 precedent) to
        # record the routing live since N2476 + the
        # per-def shake/effect rows still waiting --
        # the DEFERRED count does NOT decrease for this
        # slice. Net 234 - 0 = 234.
        rewritten = [entry for entry in ledger['N2476']['deferred_exprs'] if entry.startswith('BurstDrill updateTile offload effects + offload neighbor routing (')]
        self.assertEqual(len(rewritten), 1)
        self.assertIn('live since N2476', rewritten[0])
        self.assertIn('the offload neighbor routing is live since N2476', rewritten[0])
        self.assertIn('per-def shake/effect rows wait for their own slice', rewritten[0])
        self.assertEqual(len(ledger['N2476']['deferred_exprs']), 234)

    def test_all_c07_burst_drill_offload_neighbor_routing_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2476']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceBurstDrillBuildState.source_burst_drill_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2476']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_offload_neighbor_routing_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The offload neighbour routing (offload(),
        # BuildingComp.java:1001-1015) for ONE offloaded
        # item: `public void offload(Item item){` +
        # `produced(item, 1);` + `int dump = this.cdump;`
        # + `for(int i = 0; i < proximity.size; i++){`
        # with `incrementDump(proximity.size);` BEFORE
        # the check + `Building other = proximity.get(
        # (i + dump) % proximity.size);` + `if(other.
        # acceptItem(self(), item) && canDump(other,
        # item)){` + `other.handleItem(self(), item);`,
        # falling back to `handleItem(self(), item);`
        # (:1014) when no neighbour takes it. The scan
        # starts at the cdump SNAPSHOT and incrementDump
        # runs before each check, so the cursor advances
        # once per scanned neighbour INCLUDING the
        # handling one (a routed item leaves the cursor
        # past the handler; a full refused scan returns
        # it to its start -- the N2286 full-cycle
        # invariant). incrementDump is `public void
        # incrementDump(int prox){` (:1116-1120) with
        # `if(prox != 0){` and `cdump = ((cdump + 1) %
        # prox);`; the cursor is the Building field
        # `transient int cdump;` (:68, 0). acceptItem is
        # `public boolean acceptItem(Building source,
        # Item item){` with `return block.consumesItem(
        # item) && items.get(item) <
        # getMaximumAccepted(item);` (:864-866), and
        # canDump defaults to true (`public boolean
        # canDump(Building to, Item item){`, :1124-1126).
        # handleItem is `public void handleItem(Building
        # source, Item item){` with `items.add(item, 1);`
        # (:860-862). The BurstDrill offload branch
        # (BurstDrill.java:106-109) calls offload(
        # dominantItem) once per dominant item:
        # `if(dominantItems > 0 && progress >= drillTime
        # && items.total() < itemCapacity){` +
        # `for(int i = 0; i < dominantItems; i++){` +
        # `offload(dominantItem);`. Keep each Java expr
        # on ONE comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_burst_drill_offload_route_state(neighbour_accepts_item: Array, neighbour_can_dump: Array, cdump: int, offloaded_item_name: String) -> Dictionary:', burst_drill)
        self.assertIn('public void offload(Item item){', burst_drill)
        self.assertIn('produced(item, 1);', burst_drill)
        self.assertIn('int dump = this.cdump;', burst_drill)
        self.assertIn('for(int i = 0; i < proximity.size; i++){', burst_drill)
        self.assertIn('incrementDump(proximity.size);', burst_drill)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', burst_drill)
        self.assertIn('if(other.acceptItem(self(), item) && canDump(other, item)){', burst_drill)
        self.assertIn('other.handleItem(self(), item);', burst_drill)
        self.assertIn('handleItem(self(), item);', burst_drill)
        self.assertIn('public void incrementDump(int prox){', burst_drill)
        self.assertIn('if(prox != 0){', burst_drill)
        self.assertIn('cdump = ((cdump + 1) % prox);', burst_drill)
        self.assertIn('public boolean canDump(Building to, Item item){', burst_drill)
        self.assertIn('transient int cdump;', burst_drill)
        self.assertIn('if(dominantItems > 0 && progress >= drillTime && items.total() < itemCapacity){', burst_drill)
        self.assertIn('for(int i = 0; i < dominantItems; i++){', burst_drill)
        self.assertIn('offload(dominantItem);', burst_drill)
        self.assertIn('public void handleItem(Building source, Item item){', burst_drill)
        self.assertIn('items.add(item, 1);', burst_drill)
        self.assertIn('public boolean acceptItem(Building source, Item item){', burst_drill)
        self.assertIn('return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);', burst_drill)
        # The rotation reuses the shared dump-path helper
        # (SourceBuildingItemDumpState.
        # increment_dump_cursor_state) -- no duplicate
        # modulo in the pure.
        self.assertIn('source_building_item_dump_state.increment_dump_cursor_state(next_cdump, proximity_size)', burst_drill)
        # The advance reads the neighbour gate arrays +
        # the cdump from the frame (the N2403 fill stamps
        # them; the N2219 test pins the 8-arg advance
        # call, so no new params) and routes each
        # offloaded item through the pure with the cdump
        # threaded across the loop; the fallback items
        # land in the own store through the shared
        # inventory helper (one add_item_state call with
        # the fallback count). The advance exposes the
        # routed indices + the fallback count + the
        # cursor after the loop (unregistered API shape,
        # the N2353 precedent -- a schema-sync slice
        # folds them in, the N2367 pattern).
        self.assertIn('var accepts_value: Variant = frame.get("dump_neighbour_accepts")', burst_drill)
        self.assertIn('var neighbour_accepts_item: Array = accepts_value if accepts_value is Array else []', burst_drill)
        self.assertIn('var can_dump_value: Variant = frame.get("dump_neighbour_can_dump")', burst_drill)
        self.assertIn('var neighbour_can_dump: Array = can_dump_value if can_dump_value is Array else []', burst_drill)
        self.assertIn('source_burst_drill_offload_route_state(neighbour_accepts_item, neighbour_can_dump, routed_cdump, dominant_item_name)', burst_drill)
        self.assertIn('source_drill_inventory_runtime_state.add_item_state(next_items, dominant_item_name, offload_fallback_count)', burst_drill)
        self.assertIn('"offload_routed_indices": offload_routed_indices', burst_drill)
        self.assertIn('"offload_fallback_count": offload_fallback_count', burst_drill)
        self.assertIn('"cdump": cdump', burst_drill)
        # The tick refreshes the neighbour arrays for the
        # dominant item before the advance (live-managed
        # frames only -- a frame with supplied arrays
        # keeps its seed), through the same N2403 fill
        # with a probe frame holding one dominant item;
        # then it stamps the cursor after the advance and
        # lands each routed item in its neighbour store
        # through the shared N2353 helper (one handleItem
        # per offloaded item, BuildingComp.java:1009).
        self.assertIn('source_burst_drill_dump_neighbour_live_fill_state(game, cell, int(block.properties.get("size", 1)), {"items": {dominant_item_name: 1}}, content_item_ids)', burst_drill)
        self.assertIn('frame["cdump"] = advanced["cdump"]', burst_drill)
        self.assertIn('for routed_index in advanced.get("offload_routed_indices", []):', burst_drill)
        self.assertIn('source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), int(routed_index), dominant_item_name, 1)', burst_drill)
        self.assertLess(
            burst_drill.index('source_burst_drill_dump_neighbour_live_fill_state(game, cell, int(block.properties.get("size", 1)), {"items": {dominant_item_name: 1}}, content_item_ids)'),
            burst_drill.index('source_burst_drill_update_tile_advance_state(frame, source_delta, time_scale, block_drill_time, block_boost, drill_multiplier, dominant_item_name, int(block.properties.get("itemCapacity", 10)))'),
        )
        self.assertLess(
            burst_drill.index('source_burst_drill_update_tile_advance_state(frame, source_delta, time_scale, block_drill_time, block_boost, drill_multiplier, dominant_item_name, int(block.properties.get("itemCapacity", 10)))'),
            burst_drill.index('source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), int(routed_index), dominant_item_name, 1)'),
        )
        # The documented limits now record the offload
        # neighbor routing as live (N2476); the N2219
        # advance, the N2282 dump, the N2360 write-back,
        # the N2403 fill, and the N2469 effects rows are
        # preserved.
        self.assertIn('updateTile offload neighbor routing live (N2476)', burst_drill)
        self.assertIn('updateTile advance LIVE (N2219)', burst_drill)
        self.assertIn('timerDump dump LIVE (N2282)', burst_drill)
        self.assertIn('timerDump neighbour write-back live since N2360', burst_drill)
        self.assertIn('dump neighbour live fill is live since N2403', burst_drill)
        self.assertIn('updateTile offload effects rows live (N2469)', burst_drill)
        # The proof's keys drive the routing pure (the
        # first accepting neighbour, skipping rejecting
        # neighbours incl. wrap-around, the fallback with
        # the full-cycle invariant, the cdump advancing
        # once per scanned iteration from the snapshot),
        # the advance loop (the cdump threaded across
        # the dominantItems items), plus the live tick
        # (a placed eruption-drill routes its offloaded
        # copper into the surge-smelter frame).
        proof = BURST_DRILL_OFFLOAD_NEIGHBOR_ROUTING_PROOF.read_text(encoding='utf-8')
        for key in [
            'route_first_accepting',
            'route_skips_rejecting',
            'route_fallback',
            'route_cdump_advances',
            'route_loop_cdump',
            'route_live_tick',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceBurstDrillBuildState.gd")', proof)
        self.assertTrue(BURST_DRILL_STATE.exists())
        self.assertTrue(BURST_DRILL_OFFLOAD_NEIGHBOR_ROUTING_PROOF_SCENE.exists())
        self.assertIn('C07BurstDrillOffloadNeighborRoutingProof.gd', BURST_DRILL_OFFLOAD_NEIGHBOR_ROUTING_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_burst_drill_offload_neighbor_routing(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillOffloadNeighborRoutingProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_OFFLOAD_NEIGHBOR_ROUTING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'route_first_accepting',
            'route_skips_rejecting',
            'route_fallback',
            'route_cdump_advances',
            'route_loop_cdump',
            'route_live_tick',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
