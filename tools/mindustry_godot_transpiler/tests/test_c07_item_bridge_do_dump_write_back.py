import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceItemBridgeBuildState.gd'
BUILDING_ITEM_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingItemState.gd'
ITEM_BRIDGE_DO_DUMP_WRITE_BACK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeDoDumpWriteBackProof.gd'
ITEM_BRIDGE_DO_DUMP_WRITE_BACK_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeDoDumpWriteBackProof.tscn'


class C07ItemBridgeDoDumpWriteBackTests(unittest.TestCase):
    def test_c07_item_bridge_do_dump_write_back_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2362']['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_do_dump_state')
        # N2288 ported the unlinked-branch doDump
        # (ItemBridge.java:335-337, dumpAccumulate() at
        # :350-353, dump(null) through the shared
        # dump_item_state routing, BuildingComp.java:
        # 1072-1113) -- but the dumped item left the bridge
        # without landing in any neighbour store: Java
        # hands it over for real (`other.handleItem(self(),
        # item);`, BuildingComp.java:1089), and handleItem
        # is `items.add(item, 1);`
        # (BuildingComp.java:860-862). N2362 is the
        # write-back wiring (the N2353 precedent): the
        # doDump advance exposes its deliveries and the
        # tick lands each dumped item in the neighbour
        # store through the shared
        # source_neighbour_item_write_back_state helper.
        # Wiring-only at slice time: the ledger entry reuses
        # the five N2288 doDump result symbols (the N2321
        # shared-ownership precedent). N2367 (schema-sync
        # fold) registered the dump_deliveries key as a
        # symbol of this slice, so the list is the five
        # shared symbols plus dump_deliveries.
        self.assertEqual(
            ledger['N2362']['source_symbols'],
            [
                'source_item_bridge_do_dump_state_result.dump_accum_after',
                'source_item_bridge_do_dump_state_result.dumped',
                'source_item_bridge_do_dump_state_result.dump_attempts',
                'source_item_bridge_do_dump_state_result.items_after',
                'source_item_bridge_do_dump_state_result.cursor_after',
                'source_item_bridge_do_dump_state_result.dump_deliveries',
            ],
        )
        for name in ledger['N2362']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_do_dump_state')
        self.assertEqual(ledger['N2362']['runtime_proof'], '/root/C07ItemBridgeDoDumpWriteBackProof')
        self.assertEqual(
            ledger['N2362']['tests'],
            [
                'test_c07_item_bridge_do_dump_write_back_registration',
                'test_all_c07_item_bridge_do_dump_write_back_input_evidence_is_exact',
                'test_item_bridge_do_dump_write_back_state',
                'test_reference_graph_and_actual_c07_item_bridge_do_dump_write_back',
            ],
        )
        self.assertTrue(ledger['N2362']['deferred_exprs'])
        # This slice resolves the doDump neighbour
        # write-back entry (#259); the live neighbour fill
        # (the acceptItem/canDump arrays are still frame
        # inputs, default []) stays deferred, and no new
        # deferral is added.
        self.assertFalse(any(entry.startswith('ItemBridge doDump neighbour write-back (') for entry in ledger['N2362']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge doDump live neighbour fill (') for entry in ledger['N2362']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge live items intake (') for entry in ledger['N2362']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge checkAccept facing (') for entry in ledger['N2362']['deferred_exprs']))

    def test_all_c07_item_bridge_do_dump_write_back_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2362']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_do_dump_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2362']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_bridge_do_dump_write_back_state(self):
        item_bridge = ITEM_BRIDGE_STATE.read_text(encoding='utf-8')
        # The doDump advance (N2288) now exposes its
        # deliveries: dumpAccumulate can dump MULTIPLE
        # times per frame ("allow dumping multiple times
        # per frame", ItemBridge.java:351), so a scalar
        # routed index + item would drop every delivery
        # but one -- the advance returns dump_deliveries,
        # one {"neighbour_index": ..., "item": ...} dict
        # per successful dump attempt, in attempt order
        # (empty when nothing dumped). The routed index is
        # the handled index the shared dump_item_state
        # reports (handled_index) and the item is its
        # handled_item -- the neighbour dump(null) handed
        # to (`other.handleItem(self(), item);`,
        # BuildingComp.java:1089). Index i is ring cell i
        # (the N2353 convention): the helper resolves the
        # index through the
        # source_block_proximity_cells_state ring, so the
        # live fill must fill the frame neighbour inputs
        # in ring order. The key is UNREGISTERED API shape
        # (the N2353 offload precedent -- the schema-sync
        # slice folds it into
        # source_item_bridge_do_dump_state_result later),
        # so the contract keeps its five return keys.
        self.assertIn('dump_deliveries', item_bridge)
        self.assertIn('"dump_deliveries": dump_deliveries', item_bridge)
        self.assertIn('result.get("handled_index", -1)', item_bridge)
        self.assertIn('result.get("handled_item", "")', item_bridge)
        self.assertIn('"neighbour_index"', item_bridge)
        # The tick wires the shared helper after the doDump
        # advance write-back (one call per delivery, amount
        # 1 -- one handleItem per dump, BuildingComp:1089),
        # with the catalog size (the bridge is size 1) and
        # the delivery's routed index + item. A failed
        # write-back (no sprite / no frame / no items
        # store / full belt) drops the item -- the routing
        # already decided, so there is no fallback to the
        # bridge's own store (the N2353 precedent).
        self.assertIn('preload("res://src/game/SourceBuildingItemState.gd")', item_bridge)
        self.assertIn('for delivery in dumped.get("dump_deliveries", []):', item_bridge)
        self.assertIn('source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), delivery_index, delivery_item, 1)', item_bridge)
        self.assertLess(
            item_bridge.index('frame["cdump"] = dumped["cursor_after"]'),
            item_bridge.index('for delivery in dumped.get("dump_deliveries", []):'),
        )
        # The documented limits now record the doDump
        # neighbour write-back as live (N2362) and the old
        # "no neighbour write-back yet" text is gone; the
        # N2288 doDump, the N2225 transport advance, the
        # N2188 gate, the N2197 link frame state, and the
        # N2321 timer snapshot are preserved.
        self.assertIn('doDump neighbour write-back live since N2362', item_bridge)
        self.assertNotIn('no neighbour write-back yet', item_bridge)
        self.assertIn('doDump live (N2288)', item_bridge)
        self.assertIn('updateTile transport advance live (N2225)', item_bridge)
        self.assertIn('shouldConsume gate LIVE (N2188)', item_bridge)
        self.assertIn('static func source_item_bridge_do_dump_state', item_bridge)
        self.assertIn('static func source_item_bridge_update_transport_state', item_bridge)
        self.assertIn('static func source_item_bridge_should_consume_state', item_bridge)
        self.assertIn('static func source_item_bridge_tick_buildings_state', item_bridge)
        # The proof's keys drive the advance's exposed
        # deliveries (single / multi / second-neighbour /
        # no-dump) and the live tick (a dumped item lands
        # in the neighbour frame; a dumped item to a
        # storeless neighbour still leaves the bridge).
        proof = ITEM_BRIDGE_DO_DUMP_WRITE_BACK_PROOF.read_text(encoding='utf-8')
        for key in [
            'advance_exposes_dump_deliveries',
            'live_tick_writes_dumped_item_to_neighbour_frame',
            'live_tick_dumped_item_leaves_bridge_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceItemBridgeBuildState.gd")', proof)
        self.assertTrue(ITEM_BRIDGE_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBuildingItemState.gd")', proof)
        self.assertTrue(BUILDING_ITEM_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('item_bridge_build_state.source_item_bridge_do_dump_state(', proof)
        self.assertIn('item_bridge_build_state.source_item_bridge_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = ITEM_BRIDGE_DO_DUMP_WRITE_BACK_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ItemBridgeDoDumpWriteBackProof.gd', scene)
        self.assertIn('C07ItemBridgeDoDumpWriteBackProof', scene)

    def test_reference_graph_and_actual_c07_item_bridge_do_dump_write_back(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemBridgeDoDumpWriteBackProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_BRIDGE_DO_DUMP_WRITE_BACK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'advance_exposes_dump_deliveries',
            'live_tick_writes_dumped_item_to_neighbour_frame',
            'live_tick_dumped_item_leaves_bridge_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
