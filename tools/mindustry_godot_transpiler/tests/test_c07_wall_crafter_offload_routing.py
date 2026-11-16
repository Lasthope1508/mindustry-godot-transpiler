import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WALL_CRAFTER_STATE = ROOT / 'godot-mindustry/src/game/SourceWallCrafterBuildState.gd'
BUILDING_ITEM_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingItemState.gd'
BUILDING_ITEM_DUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingItemDumpState.gd'
BLOCK_GEOMETRY_STATE = ROOT / 'godot-mindustry/src/game/SourceBlockGeometry.gd'
WALL_CRAFTER_OFFLOAD_ROUTING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterOffloadRoutingProof.gd'
WALL_CRAFTER_OFFLOAD_ROUTING_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterOffloadRoutingProof.tscn'


class C07WallCrafterOffloadRoutingTests(unittest.TestCase):
    def test_c07_wall_crafter_offload_routing_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2398']['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_update_tile_advance_state')
        # N2223 ported the updateTile advance (WallCrafterBuild.
        # updateTile(), WallCrafter.java:187-223) -- but the
        # offload inside it went to the building's own
        # inventory only (inventory.offload_item_state with no
        # routing context, the handleItem fallback,
        # BuildingComp.java:1014/:860-861). Java offload()
        # (BuildingComp.java:1001-1014) scans proximity from
        # the cdump cursor first (`int dump = this.cdump;`,
        # `incrementDump(proximity.size);` before each check)
        # and hands the produced item to the first neighbour
        # where `other.acceptItem(self(), item) &&
        # canDump(other, item)` holds (`other.handleItem(self(),
        # item);`, :1009), falling back to `handleItem(self(),
        # item)` (:1014) only when no neighbour takes it.
        # N2398 is the routing (the N2283 timerDump pattern):
        # the advance routes the produced output through the
        # shared dump_item_state routing over the SAME
        # neighbour acceptItem/canDump frame inputs the
        # timerDump reads (Java has ONE proximity list) and
        # the SAME cdump cursor, and the tick lands the
        # routed item in the neighbour store through the
        # shared source_neighbour_item_write_back_state
        # helper (N2353). Two new symbols
        # (offload_neighbour_index + cdump -- the brief's +1
        # estimate counted only the routing key, but the
        # shared-cursor requirement forces the advance to
        # return the post-offload cursor too, the Separator
        # N2343 precedent; the N2386 estimate-correction
        # precedent); the seven N2223 advance result symbols
        # are re-listed (the N2321 shared-ownership
        # precedent). No schema upsert, no contract upsert --
        # the schema-sync slice folds the keys into
        # source_wall_crafter_update_tile_advance_state_result
        # (the N2367 precedent). produced(item, 1)
        # (BuildingComp.java:1002) DEFERS -- the port models
        # no sector production stats in this driver, so no
        # stats write is invented.
        self.assertEqual(
            ledger['N2398']['source_symbols'],
            [
                'source_wall_crafter_update_tile_advance_state_result.warmup',
                'source_wall_crafter_update_tile_advance_state_result.eff',
                'source_wall_crafter_update_tile_advance_state_result.last_efficiency',
                'source_wall_crafter_update_tile_advance_state_result.time',
                'source_wall_crafter_update_tile_advance_state_result.total_time',
                'source_wall_crafter_update_tile_advance_state_result.offloaded',
                'source_wall_crafter_update_tile_advance_state_result.items',
                'source_wall_crafter_update_tile_advance_state_result.offload_neighbour_index',
                'source_wall_crafter_update_tile_advance_state_result.cdump',
            ],
        )
        for name in ledger['N2398']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/WallCrafter.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_update_tile_advance_state')
        self.assertEqual(ledger['N2398']['runtime_proof'], '/root/C07WallCrafterOffloadRoutingProof')
        self.assertEqual(
            ledger['N2398']['tests'],
            [
                'test_c07_wall_crafter_offload_routing_registration',
                'test_all_c07_wall_crafter_offload_routing_input_evidence_is_exact',
                'test_wall_crafter_offload_routing_state',
                'test_reference_graph_and_actual_c07_wall_crafter_offload_routing',
            ],
        )
        self.assertTrue(ledger['N2398']['deferred_exprs'])
        # DEFERRED #256 is REWRITTEN IN PLACE, not resolved:
        # the offload neighbour routing is live since N2398
        # and the live edge-tile scan + updateEffect chance +
        # disabled early return still wait. Count stays 301.
        self.assertEqual(len(ledger['N2398']['deferred_exprs']), 301)
        live_fill = [entry for entry in ledger['N2398']['deferred_exprs'] if entry.startswith('WallCrafter updateTile live fill (')]
        self.assertEqual(len(live_fill), 1)
        self.assertIn('the offload neighbor routing is live since N2398', live_fill[0])
        self.assertIn('the live edge-tile scan waits for its own slice', live_fill[0])
        self.assertIn('the updateEffect chance waits for its own slice', live_fill[0])
        self.assertIn('the driver-wide disabled-early-return slice removes this gate for all families', live_fill[0])
        self.assertNotIn('the port offloads to own inventory only', live_fill[0])

    def test_all_c07_wall_crafter_offload_routing_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2398']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/WallCrafter.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2398']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wall_crafter_offload_routing_state(self):
        wall_crafter = WALL_CRAFTER_STATE.read_text(encoding='utf-8')
        # The advance signature is UNCHANGED (the N2223 test
        # pins the call string): the routing reads its inputs
        # from the frame -- the shared neighbour arrays
        # (dump_neighbour_accepts / dump_neighbour_can_dump,
        # the SAME pair the N2283 timerDump reads, Java has
        # ONE proximity list) and the shared cdump cursor.
        self.assertIn('static func source_wall_crafter_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float, drill_time: float, output_item: String, item_capacity: int) -> Dictionary:', wall_crafter)
        self.assertIn('frame.get("dump_neighbour_accepts", [])', wall_crafter)
        self.assertIn('frame.get("dump_neighbour_can_dump", [])', wall_crafter)
        self.assertIn('frame.get("cdump", 0)', wall_crafter)
        # The offload still produces into the own store first
        # (inventory.offload_item_state, the handleItem
        # fallback, BuildingComp.java:1014/:860-861) and THEN
        # routes the produced item through the shared
        # dump_item_state routing (the N2283 pattern): the
        # todump branch only ever touches the output item's
        # amount, so the item ids are the single-element
        # [output_item] array (the full catalog order is only
        # needed for the null dump-any branch, which offload
        # never takes). On a routed offload the produced item
        # leaves the own store (amounts_after[0]) and the
        # handled neighbour index is exposed; on no accepting
        # neighbour the item stays home (the Java
        # handleItem(self) outcome, :1014). The cursor comes
        # back from dump_item_state (once per checked
        # neighbour, Java-exact: incrementDump per check,
        # BuildingComp.java:1006/:1116-1120).
        self.assertIn('inventory.offload_item_state(items, output_item)', wall_crafter)
        self.assertIn('source_building_item_dump_state.dump_item_state(true, inventory.items_total(next_items), offload_neighbour_accepts.size(), output_item, inventory.item_count(next_items, output_item) > 0, [output_item], [inventory.item_count(next_items, output_item)], offload_neighbour_accepts, offload_neighbour_can_dump, cdump)', wall_crafter)
        self.assertIn('routed.get("handled_index", -1)', wall_crafter)
        self.assertIn('routed.get("item_amounts_by_index", [])', wall_crafter)
        self.assertIn('routed.get("cdump", cdump)', wall_crafter)
        # The advance exposes the routing as ONE scalar key
        # (offload_neighbour_index, -1 when it stayed home --
        # offload() returns after the FIRST success, so a
        # single delivery needs no array, contrast N2386's
        # dumpAccumulate multi-fire) plus the post-offload
        # cdump (the Separator N2343 precedent).
        self.assertIn('"offload_neighbour_index": offload_neighbour_index', wall_crafter)
        self.assertIn('"cdump": cdump', wall_crafter)
        # The tick persists both keys into the frame right
        # after the advance write-back -- the cdump BEFORE
        # the timerDump dump runs (Java order: the offload at
        # WallCrafter.java:214 precedes the dump at :220-221),
        # so the dump scans from the post-offload cursor and
        # the cursor is never double-advanced (each path
        # advances it only for its own checks).
        self.assertIn('frame["offload_neighbour_index"] = advanced["offload_neighbour_index"]', wall_crafter)
        self.assertIn('frame["cdump"] = advanced["cdump"]', wall_crafter)
        self.assertLess(
            wall_crafter.index('frame["cdump"] = advanced["cdump"]'),
            wall_crafter.index('source_wall_crafter_timer_dump_state(float(frame.get("timer_dump_elapsed", 0.0)), time_scale, frame, advance_output_item, content_item_ids, dump_neighbour_accepts, dump_neighbour_can_dump)'),
        )
        # The tick lands the routed output in the neighbour
        # store through the shared helper (N2353) right after
        # the advance write-back (amount 1, the catalog
        # per-def size already bound as wall_size, the ring
        # index from the advance). cell is bound after the
        # enabled block, so the origin_cell meta is read
        # inline as offload_cell (the N2363 precedent). A
        # failed write-back drops the item -- the routing
        # already decided, so there is no fallback to the
        # wall crafter's own store (the N2353 precedent).
        self.assertIn('preload("res://src/game/SourceBuildingItemState.gd")', wall_crafter)
        self.assertIn('var offload_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)', wall_crafter)
        self.assertIn('source_building_item_state.source_neighbour_item_write_back_state(game, offload_cell, wall_size, offload_index, advance_output_item, 1)', wall_crafter)
        # The documented limits now record the offload
        # neighbour routing as live (N2398) and the old
        # "port offloads to own inventory only" text is gone;
        # the N2223 advance, the N2273 timerUse consume, the
        # N2283 timerDump dump and the N2301 getEfficiency
        # fill are preserved.
        self.assertIn('offload neighbor routing is live since N2398', wall_crafter)
        self.assertNotIn('the port offloads to own inventory only', wall_crafter)
        self.assertIn('updateTile advance live (N2223)', wall_crafter)
        self.assertIn('timerUse booster consume is live since N2273', wall_crafter)
        self.assertIn('timerDump dump is live since N2283', wall_crafter)
        self.assertIn('getEfficiency fill live (N2301)', wall_crafter)
        # The shared helpers exist: dump_item_state (the
        # routing) and the N2353 neighbour write-back.
        dump_state = BUILDING_ITEM_DUMP_STATE.read_text(encoding='utf-8')
        self.assertIn('static func dump_item_state(', dump_state)
        self.assertIn('increment_dump_cursor_state(next_cursor, proximity_size)', dump_state)
        item_state = BUILDING_ITEM_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_neighbour_item_write_back_state(game: Object, cell: Vector2i, size: int, neighbour_index: int, item: String, amount: int) -> Dictionary:', item_state)
        # The proof's keys drive the advance's exposed index
        # (routed / wrapped-cursor / refused / no-neighbour /
        # idle / canDump-refuses) and the live tick (a routed
        # offload lands in the neighbour frame; a refused
        # offload falls back to the own inventory; a routed
        # offload to a storeless neighbour still leaves the
        # crafter).
        proof = WALL_CRAFTER_OFFLOAD_ROUTING_PROOF.read_text(encoding='utf-8')
        for key in [
            'advance_exposes_offload_neighbour_index',
            'live_tick_routes_offloaded_item_to_neighbour_frame',
            'live_tick_offload_falls_back_to_inventory',
            'live_tick_routed_item_leaves_crafter_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceWallCrafterBuildState.gd")', proof)
        self.assertTrue(WALL_CRAFTER_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertTrue(BLOCK_GEOMETRY_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('wall_crafter_build_state.source_wall_crafter_update_tile_advance_state(', proof)
        self.assertIn('wall_crafter_build_state.source_wall_crafter_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = WALL_CRAFTER_OFFLOAD_ROUTING_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07WallCrafterOffloadRoutingProof.gd', scene)
        self.assertIn('C07WallCrafterOffloadRoutingProof', scene)

    def test_reference_graph_and_actual_c07_wall_crafter_offload_routing(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WallCrafterOffloadRoutingProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WALL_CRAFTER_OFFLOAD_ROUTING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'advance_exposes_offload_neighbour_index',
            'live_tick_routes_offloaded_item_to_neighbour_frame',
            'live_tick_offload_falls_back_to_inventory',
            'live_tick_routed_item_leaves_crafter_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
