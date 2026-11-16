import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourceMassDriverBuildState.gd'
BUILDING_ITEM_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingItemState.gd'
ITEM_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceItemBridgeBuildState.gd'
MASS_DRIVER_DUMP_WRITE_BACK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverDumpWriteBackProof.gd'
MASS_DRIVER_DUMP_WRITE_BACK_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverDumpWriteBackProof.tscn'


class C07MassDriverDumpWriteBackTests(unittest.TestCase):
    def test_c07_mass_driver_dump_write_back_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2369']['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_dump_state')
        # N2294 ported the dumpAccumulate dump (MassDriver.
        # java:163-166, `//dump when idle or accepting` /
        # `if(state == DriverState.idle || state ==
        # DriverState.accepting){ dumpAccumulate(); }`,
        # dumpAccumulate(null) accumulating `dumpAccum +=
        # delta();` and dumping while `dumpAccum >= 1f`
        # (BuildingComp.java:1053-1061) -- possibly
        # MULTIPLE times per tick -- through dump() =
        # dump(null) (BuildingComp.java:1064-1066), the
        # neighbour-outer / item-inner scan (BuildingComp.
        # java:1072-1114)) -- but the dumped item left the
        # mass driver without landing in any neighbour
        # store: Java hands it over for real
        # (`other.handleItem(self(), item);`, BuildingComp.
        # java:1089), and handleItem is `items.add(item,
        # 1);` (BuildingComp.java:860-862). N2369 is the
        # write-back wiring (the N2362 ItemBridge
        # precedent): the dump advance exposes its
        # deliveries and the tick lands each dumped item
        # in the neighbour store through the shared
        # source_neighbour_item_write_back_state helper
        # (N2353). One new symbol (dump_deliveries, the
        # N2360 register-new-keys precedent); the four
        # N2294 dump result symbols are re-listed (the
        # N2321 shared-ownership precedent). The contract
        # keeps its four return keys -- dump_deliveries is
        # UNREGISTERED API shape for the schema-sync fold
        # (the N2367 precedent).
        self.assertEqual(
            ledger['N2369']['source_symbols'],
            [
                'source_mass_driver_dump_state_result.dump_accum_after',
                'source_mass_driver_dump_state_result.dumped',
                'source_mass_driver_dump_state_result.items_after',
                'source_mass_driver_dump_state_result.cursor_after',
                'source_mass_driver_dump_state_result.dump_deliveries',
            ],
        )
        for name in ledger['N2369']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/distribution/MassDriver.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_dump_state')
        self.assertEqual(ledger['N2369']['runtime_proof'], '/root/C07MassDriverDumpWriteBackProof')
        self.assertEqual(
            ledger['N2369']['tests'],
            [
                'test_c07_mass_driver_dump_write_back_registration',
                'test_all_c07_mass_driver_dump_write_back_input_evidence_is_exact',
                'test_mass_driver_dump_write_back_state',
                'test_reference_graph_and_actual_c07_mass_driver_dump_write_back',
            ],
        )
        self.assertTrue(ledger['N2369']['deferred_exprs'])
        # This slice resolves the dump neighbour
        # write-back entry (#279 in the coordinator's
        # merged numbering); the dump neighbour live fill
        # (the acceptItem/canDump arrays are still frame
        # inputs, default []) stays deferred, and no new
        # deferral is added. The Time.run arrival cleanup
        # and the bullet entity entries stay too.
        self.assertFalse(any(entry.startswith('MassDriver dump neighbour write-back (') for entry in ledger['N2369']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver dump neighbour live fill (') for entry in ledger['N2369']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver fire arrival / Time.run cleanup (') for entry in ledger['N2369']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver bullet entity / DriverBulletData rows (') for entry in ledger['N2369']['deferred_exprs']))

    def test_all_c07_mass_driver_dump_write_back_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2369']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_dump_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/MassDriver.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2369']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mass_driver_dump_write_back_state(self):
        mass_driver = MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The dump advance (N2294) now exposes its
        # deliveries: dumpAccumulate can dump MULTIPLE
        # times per frame ("May dump multiple times per
        # frame", BuildingComp.java:1052), so a scalar
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
        # (the N2362 precedent -- the schema-sync slice
        # folds it into
        # source_mass_driver_dump_state_result later), so
        # the contract keeps its four return keys.
        self.assertIn('dump_deliveries', mass_driver)
        self.assertIn('"dump_deliveries": dump_deliveries', mass_driver)
        self.assertIn('result.get("handled_index", -1)', mass_driver)
        self.assertIn('result.get("handled_item", "")', mass_driver)
        self.assertIn('"neighbour_index"', mass_driver)
        # The tick wires the shared helper after the dump
        # advance write-back (one call per delivery, amount
        # 1 -- one handleItem per dump, BuildingComp:1089),
        # with the catalog size (the mass driver is size 3)
        # and the delivery's routed index + item. A failed
        # write-back (no sprite / no frame / no items
        # store / full belt) drops the item -- the routing
        # already decided, so there is no fallback to the
        # driver's own store (the N2353 precedent).
        self.assertIn('preload("res://src/game/SourceBuildingItemState.gd")', mass_driver)
        self.assertIn('for delivery in dumped.get("dump_deliveries", []):', mass_driver)
        self.assertIn('source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), delivery_index, delivery_item, 1)', mass_driver)
        self.assertLess(
            mass_driver.index('frame["cdump"] = dumped.get("cursor_after", frame.get("cdump", 0))'),
            mass_driver.index('for delivery in dumped.get("dump_deliveries", []):'),
        )
        # The documented limits now record the dump
        # neighbour write-back as live (N2369) and the old
        # "not written into the neighbour frame yet" /
        # "no neighbour write-back" text is gone; the N2294
        # dump, the N2237 advance, and the N2336 acceptItem
        # gate are preserved.
        self.assertIn('dump neighbour write-back is live since N2369', mass_driver)
        self.assertNotIn('the dumped item is not written into the neighbour frame yet', mass_driver)
        self.assertNotIn('no neighbour write-back', mass_driver)
        self.assertNotIn('does not write the item into the neighbour frame', mass_driver)
        self.assertIn('dumpAccumulate (:164-166) is live since N2294', mass_driver)
        self.assertIn('updateTile advance live (N2237)', mass_driver)
        self.assertIn('acceptItem live (N2336)', mass_driver)
        self.assertIn('static func source_mass_driver_dump_state', mass_driver)
        self.assertIn('static func source_mass_driver_update_tile_advance_state', mass_driver)
        self.assertIn('static func source_mass_driver_accept_item_state', mass_driver)
        self.assertIn('static func source_mass_driver_tick_buildings_state', mass_driver)
        # The proof's keys drive the advance's exposed
        # deliveries (single / multi / second-neighbour /
        # no-dump) and the live tick (a dumped item lands
        # in the neighbour frame; a dumped item to a
        # storeless neighbour still leaves the driver).
        proof = MASS_DRIVER_DUMP_WRITE_BACK_PROOF.read_text(encoding='utf-8')
        for key in [
            'advance_exposes_dump_deliveries',
            'live_tick_writes_dumped_item_to_neighbour_frame',
            'live_tick_dumped_item_leaves_driver_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceMassDriverBuildState.gd")', proof)
        self.assertTrue(MASS_DRIVER_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBuildingItemState.gd")', proof)
        self.assertTrue(BUILDING_ITEM_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceItemBridgeBuildState.gd")', proof)
        self.assertTrue(ITEM_BRIDGE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('mass_driver_build_state.source_mass_driver_dump_state(', proof)
        self.assertIn('mass_driver_build_state.source_mass_driver_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = MASS_DRIVER_DUMP_WRITE_BACK_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07MassDriverDumpWriteBackProof.gd', scene)
        self.assertIn('C07MassDriverDumpWriteBackProof', scene)

    def test_reference_graph_and_actual_c07_mass_driver_dump_write_back(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MassDriverDumpWriteBackProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MASS_DRIVER_DUMP_WRITE_BACK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'advance_exposes_dump_deliveries',
            'live_tick_writes_dumped_item_to_neighbour_frame',
            'live_tick_dumped_item_leaves_driver_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
