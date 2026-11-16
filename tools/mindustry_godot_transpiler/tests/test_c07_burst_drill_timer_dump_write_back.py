import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BUILDING_ITEM_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingItemState.gd'
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
BLOCK_GEOMETRY_STATE = ROOT / 'godot-mindustry/src/game/SourceBlockGeometry.gd'
BURST_DRILL_TIMER_DUMP_WRITE_BACK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillTimerDumpWriteBackProof.gd'
BURST_DRILL_TIMER_DUMP_WRITE_BACK_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillTimerDumpWriteBackProof.tscn'


class C07BurstDrillTimerDumpWriteBackTests(unittest.TestCase):
    def test_c07_burst_drill_timer_dump_write_back_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2360']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_timer_dump_state')
        # The N2282 timerDump advance runs the shared
        # dump_item_state routing and returns {fired,
        # elapsed_after, dumped, items_after, cursor_after}
        # -- it does NOT expose the routed neighbour index or
        # the dumped item, so the dumped item left the burst
        # drill without landing in any neighbour store: Java
        # hands it over for real, `other.handleItem(self(),
        # item);` (BuildingComp.java:1089, the dump(null)
        # branch) and `other.handleItem(self(), todump);`
        # (:1103, the specific branch), and handleItem is
        # `items.add(item, 1);` (BuildingComp.java:860-862).
        # N2360 is the N2353-precedent wiring: the advance
        # exposes the routed neighbour index + the dumped
        # item, and the tick lands the item in the neighbour
        # store through the shared
        # source_neighbour_item_write_back_state helper after
        # the advance when dumped. Two new result symbols:
        # the routed neighbour index and the dumped item.
        # They are registered in the registry only -- the
        # schema + contract fold waits for the schema-sync
        # slice (the N2353 precedent: that slice left the
        # advance keys unregistered too), so contracts and
        # schemas do not move in this slice.
        self.assertEqual(
            ledger['N2360']['source_symbols'],
            [
                'source_burst_drill_timer_dump_state_result.dump_neighbour_index',
                'source_burst_drill_timer_dump_state_result.dumped_item',
            ],
        )
        for name in ledger['N2360']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_timer_dump_state')
        self.assertEqual(ledger['N2360']['runtime_proof'], '/root/C07BurstDrillTimerDumpWriteBackProof')
        self.assertEqual(
            ledger['N2360']['tests'],
            [
                'test_c07_burst_drill_timer_dump_write_back_registration',
                'test_all_c07_burst_drill_timer_dump_write_back_input_evidence_is_exact',
                'test_burst_drill_timer_dump_write_back_state',
                'test_reference_graph_and_actual_c07_burst_drill_timer_dump_write_back',
            ],
        )
        self.assertTrue(ledger['N2360']['deferred_exprs'])
        # This slice resolves the BurstDrill timerDump
        # neighbour write-back deferral (#245 in the
        # DEFERRED-after-advances-17 numbering -- the brief
        # said #244, but #244 is the neighbour live fill
        # entry, which stays) and narrows the N2353
        # follow-ups entry (the BurstDrill timerDump clause
        # drops out of its pending list); the live fill and
        # the first-fire deviation stay deferred.
        self.assertFalse(any(entry.startswith('BurstDrill timerDump neighbour write-back (') for entry in ledger['N2360']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BurstDrill timerDump neighbour live fill (') for entry in ledger['N2360']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BurstDrill timerDump first-fire deviation (') for entry in ledger['N2360']['deferred_exprs']))
        follow_ups = [entry for entry in ledger['N2360']['deferred_exprs'] if entry.startswith('Neighbour item write-back follow-ups (')]
        self.assertEqual(len(follow_ups), 1)
        self.assertNotIn('BurstDrill timerDump', follow_ups[0])
        self.assertIn('Separator timerDump dump', follow_ups[0])

    def test_all_c07_burst_drill_timer_dump_write_back_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2360']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_timer_dump_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/BurstDrill.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2360']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_timer_dump_write_back_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The timerDump advance exposes the routed neighbour
        # index + the dumped item (N2360): the handled index
        # is the dump_item_state result key
        # SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY
        # ("handled_index", SourceDrillInventorySourceText-
        # State.gd:57 -- VERIFIED against the shared port,
        # which returns the literal "handled_index" key), and
        # the dumped item is the port's handled_item -- the
        # dominant item (todump) on the specific branch
        # (BuildingComp.java:1103, `other.handleItem(self(),
        # todump);`) and the first held item in content order
        # on the dump(null) branch (:1089, `other.handleItem(
        # self(), item);`). A no-fire tick reports index -1
        # and an empty dumped item. Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a split
        # line fails this test).
        self.assertIn('static func source_burst_drill_timer_dump_state', burst_drill)
        self.assertIn('source_drill_inventory_runtime_state.SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY', burst_drill)
        self.assertIn('result.get("handled_item", null)', burst_drill)
        self.assertIn('"dump_neighbour_index": dump_neighbour_index', burst_drill)
        self.assertIn('"dumped_item": dumped_item', burst_drill)
        self.assertIn('"dump_neighbour_index": -1, "dumped_item": ""', burst_drill)
        self.assertIn('other.handleItem(self(), item);', burst_drill)
        self.assertIn('other.handleItem(self(), todump);', burst_drill)
        # The stale N2282 sentence is gone: the write-back no
        # longer waits for its own slice.
        self.assertNotIn('the write-back waits for its own slice', burst_drill)
        # The tick wires the shared helper after the dump and
        # before the advance (Java order: handleItem happens
        # INSIDE dump(), BurstDrill.java:83-84, before the
        # :87+ advance), gated on dumped + a valid routed
        # index, with the origin cell, the catalog size (the
        # ring shape depends on it), the routed index, the
        # dumped item, and amount 1 (one handleItem per dump,
        # BuildingComp.java:1089/:1103). The cell is hoisted
        # to the loop top (the Separator precedent) so the
        # wiring can read it before the results write-back.
        self.assertIn('const source_building_item_state := preload("res://src/game/SourceBuildingItemState.gd")', burst_drill)
        self.assertIn('if bool(dumped.get("dumped", false)):', burst_drill)
        self.assertIn('var dump_index: int = int(dumped.get("dump_neighbour_index", -1))', burst_drill)
        self.assertIn('if dump_index >= 0:', burst_drill)
        self.assertIn('source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_item", "")), 1)', burst_drill)
        self.assertLess(
            burst_drill.index('source_burst_drill_timer_dump_state(frame, source_delta, time_scale, dominant_item_name, content_item_ids, neighbour_accepts, neighbour_can_dump)'),
            burst_drill.index('source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_item", "")), 1)'),
        )
        self.assertLess(
            burst_drill.index('source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_item", "")), 1)'),
            burst_drill.index('source_burst_drill_update_tile_advance_state(frame, source_delta, time_scale, block_drill_time, block_boost, drill_multiplier, dominant_item_name, int(block.properties.get("itemCapacity", 10)))'),
        )
        # The documented limits now record the timerDump
        # neighbour write-back as live (N2360); the N2282
        # dump, the N2219 advance, the N2203 gate, the N2257
        # liquid rows, and the N2149 power row are preserved.
        self.assertIn('timerDump neighbour write-back live since N2360', burst_drill)
        self.assertIn('timerDump dump LIVE (N2282)', burst_drill)
        self.assertIn('updateTile advance LIVE (N2219)', burst_drill)
        self.assertIn('static func source_burst_drill_power_status_row_state', burst_drill)
        self.assertIn('static func source_burst_drill_should_consume_state', burst_drill)
        self.assertIn('static func source_burst_drill_update_tile_advance_state', burst_drill)
        # The proof's keys drive the advance's exposed routed
        # index + dumped item (routed / dump(null) fallback /
        # no-fire / blocked) and the live tick (a dumped item
        # lands in the neighbour frame; a dumped item to a
        # frameless neighbour still leaves the drill).
        proof = BURST_DRILL_TIMER_DUMP_WRITE_BACK_PROOF.read_text(encoding='utf-8')
        for key in [
            'advance_exposes_dumped_neighbour_index',
            'live_tick_writes_dumped_item_to_neighbour_frame',
            'live_tick_dumped_item_leaves_drill_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceBurstDrillBuildState.gd")', proof)
        self.assertTrue(BURST_DRILL_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBuildingItemState.gd")', proof)
        self.assertTrue(BUILDING_ITEM_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceSeparatorBuildState.gd")', proof)
        self.assertTrue(SEPARATOR_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertTrue(BLOCK_GEOMETRY_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('burst_drill_build_state.source_burst_drill_timer_dump_state(', proof)
        self.assertIn('burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertIn('write_proof("C07BurstDrillTimerDumpWriteBackProof"', proof)
        scene = BURST_DRILL_TIMER_DUMP_WRITE_BACK_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BurstDrillTimerDumpWriteBackProof.gd', scene)
        self.assertIn('[node name="C07BurstDrillTimerDumpWriteBackProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_burst_drill_timer_dump_write_back(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillTimerDumpWriteBackProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_TIMER_DUMP_WRITE_BACK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'advance_exposes_dumped_neighbour_index',
            'live_tick_writes_dumped_item_to_neighbour_frame',
            'live_tick_dumped_item_leaves_drill_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
