import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILDING_ITEM_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingItemState.gd'
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
SEPARATOR_NEIGHBOUR_WRITE_BACK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorNeighbourWriteBackProof.gd'
SEPARATOR_NEIGHBOUR_WRITE_BACK_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorNeighbourWriteBackProof.tscn'


class C07SeparatorNeighbourWriteBackTests(unittest.TestCase):
    def test_c07_separator_neighbour_write_back_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2353']['godot_owner'], 'SourceBuildingItemState.source_neighbour_item_write_back_state')
        # N2343 routed the Separator's picked result to the
        # first accepting neighbour from the cdump cursor
        # through offload_item_state -- but the shared port
        # only bumped the ephemeral neighbour dict item_count,
        # so the routed item left the separator without landing
        # in any neighbour store. Java hands the item over for
        # real: `other.handleItem(self(), item);`
        # (BuildingComp.java:1009), and handleItem is
        # `items.add(item, 1);` (BuildingComp.java:860-862).
        # N2353 is the shared neighbour write-back helper +
        # the Separator offload wiring: the helper maps the
        # routed neighbour index to a ring cell (the
        # source_block_proximity_cells_state ring, so index i
        # is ring cell i -- the live fill must fill the frame
        # neighbour inputs in ring order), resolves the sprite
        # at that cell, and lands the item in the neighbour's
        # store -- a belt neighbour's conveyor queue (the
        # factory dump precedent, ConveyorBuild.handleItem) or
        # a building neighbour's frame items (the first
        # SOURCE_CONSUMER_FRAME_META_KEYS frame present, the
        # N2142 set_meta write-back precedent, through the
        # shared inventory add_item_state). No sprite, no
        # frame, a frame with no items store, or a full belt
        # reports written false with a reason -- the item is
        # already routed away, so there is no fallback to the
        # separator's own store. Three new result symbols: the
        # written flag, the reason, and the neighbour cell.
        self.assertEqual(
            ledger['N2353']['source_symbols'],
            [
                'source_neighbour_item_write_back_state_result.written',
                'source_neighbour_item_write_back_state_result.reason',
                'source_neighbour_item_write_back_state_result.neighbour_cell',
            ],
        )
        for name in ledger['N2353']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/blocks/distribution/Conveyor.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBuildingItemState.source_neighbour_item_write_back_state')
        self.assertEqual(ledger['N2353']['runtime_proof'], '/root/C07SeparatorNeighbourWriteBackProof')
        self.assertEqual(
            ledger['N2353']['tests'],
            [
                'test_c07_separator_neighbour_write_back_registration',
                'test_all_c07_separator_neighbour_write_back_input_evidence_is_exact',
                'test_separator_neighbour_write_back_state',
                'test_reference_graph_and_actual_c07_separator_neighbour_write_back',
            ],
        )
        self.assertTrue(ledger['N2353']['deferred_exprs'])
        # This slice resolves the Separator offload neighbour
        # write-back deferral (#322) and adds one new entry:
        # the remaining dump/offload write-backs follow the
        # helper in their own wiring slices (the item ones call
        # it with their routed neighbour index; the liquid ones
        # need their own handleLiquid helper; core/conduit
        # neighbours carry no frame in
        # SOURCE_CONSUMER_FRAME_META_KEYS, so a routed item to
        # a core or conduit still drops with reason no_frame
        # until a core/conduit store mapping lands). The live
        # fill of the shared frame inputs stays on the N2281
        # dump entry, and the Separator timerDump dump
        # neighbour write-back stays deferred (the dump path
        # does not call the helper yet).
        self.assertFalse(any(entry.startswith('Separator offload neighbour write-back (') for entry in ledger['N2353']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Neighbour item write-back follow-ups (') for entry in ledger['N2353']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator timerDump dump neighbour live fill (') for entry in ledger['N2353']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator timerDump dump neighbour write-back (') for entry in ledger['N2353']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator timerDump first-fire deviation (') for entry in ledger['N2353']['deferred_exprs']))

    def test_all_c07_separator_neighbour_write_back_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2353']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBuildingItemState.source_neighbour_item_write_back_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/Separator.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/distribution/Conveyor.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2353']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_separator_neighbour_write_back_state(self):
        building_item = BUILDING_ITEM_STATE.read_text(encoding='utf-8')
        # The shared helper lives on the Building item state --
        # the handleItem / acceptItem home -- because the
        # write-back IS other.handleItem (BuildingComp.java:
        # 1009): `public void handleItem(Building source, Item
        # item){` with `items.add(item, 1);` (:860-862), no
        # capacity check (acceptItem already gated, :1008).
        # The multi-item form is handleStack (`public void
        # handleStack(Item item, int amount, @Nullable Teamc
        # source){` with `items.add(item, amount);`, :795-798).
        # Keep each Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this test).
        self.assertIn('static func source_neighbour_item_write_back_state', building_item)
        self.assertIn('public void offload(Item item){', building_item)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', building_item)
        self.assertIn('if(other.acceptItem(self(), item) && canDump(other, item)){', building_item)
        self.assertIn('other.handleItem(self(), item);', building_item)
        self.assertIn('public void handleItem(Building source, Item item){', building_item)
        self.assertIn('items.add(item, 1);', building_item)
        self.assertIn('public void handleStack(Item item, int amount, @Nullable Teamc source){', building_item)
        self.assertIn('items.add(item, amount);', building_item)
        # The belt path is ConveyorBuild.handleItem
        # (Conveyor.java:362-376): `if(len >= capacity)
        # return;` with itemSpace 0.4f / capacity 3
        # (Conveyor.java:27-28), through the shared
        # source_conveyor_handle_for_cell_state (the drill
        # dump hooks precedent, including the facing-edge
        # source cell and the per-item count_before), and the
        # queue lands back through
        # source_conveyor_set_queue_for_cell_state. A belt is
        # told from a building neighbour by the conveyor queue
        # meta key on the sprite (checked FIRST: a conveyor's
        # handleItem goes to its belt queue, never to a frame
        # items dict).
        self.assertIn('private static final float itemSpace = 0.4f;', building_item)
        self.assertIn('private static final int capacity = 3;', building_item)
        self.assertIn('if(len >= capacity) return;', building_item)
        self.assertIn('SOURCE_NEIGHBOUR_CONVEYOR_CAPACITY := 3', building_item)
        self.assertIn('SOURCE_NEIGHBOUR_CONVEYOR_ITEM_SPACE := 0.4', building_item)
        self.assertIn('source_conveyor_runtime_state.source_conveyor_handle_for_cell_state(', building_item)
        self.assertIn('source_conveyor_runtime_state.source_conveyor_set_queue_for_cell_state(', building_item)
        self.assertIn('source_conveyor_runtime_state.SOURCE_CONVEYOR_QUEUE_META_KEY', building_item)
        self.assertIn('source_block_geometry.source_block_facing_edge_state(', building_item)
        # The frame path is the N2142 write-back precedent:
        # the neighbour frame is the first
        # SOURCE_CONSUMER_FRAME_META_KEYS key present on the
        # sprite, the item lands through the shared inventory
        # add_item_state, and the frame is written back with
        # set_meta. The ring cell comes from
        # source_block_proximity_cells_state (index i is ring
        # cell i), the sprite from block_sprite_at_cell.
        self.assertIn('source_placed_power_graph_state.SOURCE_CONSUMER_FRAME_META_KEYS', building_item)
        self.assertIn('source_block_geometry.source_block_proximity_cells_state(', building_item)
        self.assertIn('game.call("block_sprite_at_cell", neighbour_cell)', building_item)
        self.assertIn('inventory.add_item_state(', building_item)
        self.assertIn('sprite.set_meta(meta_key, frame)', building_item)
        # The return shape is {written, reason,
        # neighbour_cell}; the reasons cover every exit: a
        # belt write, a live-frame write, and the no-store
        # exits (no sprite, no frame, a frame with no items
        # store, a full belt) plus the invalid-input guards.
        self.assertIn('"written"', building_item)
        self.assertIn('"reason"', building_item)
        self.assertIn('"neighbour_cell"', building_item)
        self.assertIn('"belt"', building_item)
        self.assertIn('"live_frame"', building_item)
        self.assertIn('"no_sprite"', building_item)
        self.assertIn('"no_frame"', building_item)
        self.assertIn('"no_items_store"', building_item)
        self.assertIn('"belt_full"', building_item)
        self.assertIn('"invalid_index"', building_item)
        self.assertIn('"invalid_amount"', building_item)
        # The separator advance exposes the offload outcome so
        # the tick can wire it: offload_neighbour_index is the
        # handled neighbour from offload_item_state
        # (SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY, -1 when
        # no offload ran or it fell back) and offload_routed
        # is the routed flag. The tick calls the helper after
        # the advance write-back and before the timerDump dump
        # (Java order: the offload at Separator.java:160-161
        # precedes the dump at :165-166), with the catalog
        # size, the routed index, the picked item, and amount
        # 1 (one handleItem per offload, BuildingComp:1009).
        separator = SEPARATOR_STATE.read_text(encoding='utf-8')
        self.assertIn('offload_neighbour_index', separator)
        self.assertIn('offload_routed', separator)
        self.assertIn('inventory.SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY', separator)
        self.assertIn('source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), offload_index, str(advanced.get("picked_item", "")), 1)', separator)
        self.assertLess(
            separator.index('frame["cdump"] = advanced["cdump"]'),
            separator.index('source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), offload_index, str(advanced.get("picked_item", "")), 1)'),
        )
        self.assertLess(
            separator.index('source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), offload_index, str(advanced.get("picked_item", "")), 1)'),
            separator.index('source_separator_timer_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)'),
        )
        # The documented limits now record the offload
        # neighbour write-back as live (N2353) with the dump
        # write-back + shared live fill still deferred; the
        # N2343 routing, the N2222 advance, the N2281 dump,
        # the N2200 gate, and the N2169 power row are
        # preserved.
        self.assertIn('offload neighbour write-back live since N2353', separator)
        self.assertIn('offload neighbor routing live since N2343', separator)
        self.assertIn('Partial updateTile advance (N2222)', separator)
        self.assertIn('timerDump dump is live since N2281', separator)
        self.assertIn('shouldConsume gate live (N2200)', separator)
        self.assertIn('static func source_separator_offload_routing_context_state', separator)
        self.assertIn('static func source_separator_update_tile_advance_state', separator)
        self.assertIn('static func source_separator_timer_dump_state', separator)
        # The proof's keys drive the helper directly (a frame
        # neighbour lands the item, a belt neighbour queues
        # it, a storeless neighbour reports no_frame, an empty
        # cell reports no_sprite), the advance's exposed
        # routed index (routed / fallback / capacity-skipped),
        # and the live tick (a crafted pick lands in the
        # neighbour frame; a routed pick to a storeless
        # neighbour still leaves the separator).
        proof = SEPARATOR_NEIGHBOUR_WRITE_BACK_PROOF.read_text(encoding='utf-8')
        for key in [
            'write_back_frame_neighbour_lands_item',
            'write_back_belt_neighbour_queues_item',
            'write_back_no_frame_reports_no_frame',
            'write_back_no_sprite_reports_no_sprite',
            'advance_exposes_routed_neighbour_index',
            'live_tick_writes_offloaded_item_to_neighbour_frame',
            'live_tick_routed_item_leaves_separator_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceBuildingItemState.gd")', proof)
        self.assertTrue(BUILDING_ITEM_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceSeparatorBuildState.gd")', proof)
        self.assertTrue(SEPARATOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('building_item_state.source_neighbour_item_write_back_state(', proof)
        self.assertIn('separator_build_state.source_separator_update_tile_advance_state(', proof)
        self.assertIn('separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = SEPARATOR_NEIGHBOUR_WRITE_BACK_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07SeparatorNeighbourWriteBackProof.gd', scene)
        self.assertIn('C07SeparatorNeighbourWriteBackProof', scene)

    def test_reference_graph_and_actual_c07_separator_neighbour_write_back(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SeparatorNeighbourWriteBackProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SEPARATOR_NEIGHBOUR_WRITE_BACK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'write_back_frame_neighbour_lands_item',
            'write_back_belt_neighbour_queues_item',
            'write_back_no_frame_reports_no_frame',
            'write_back_no_sprite_reports_no_sprite',
            'advance_exposes_routed_neighbour_index',
            'live_tick_writes_offloaded_item_to_neighbour_frame',
            'live_tick_routed_item_leaves_separator_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
