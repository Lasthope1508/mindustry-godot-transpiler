import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
SEPARATOR_TIMER_DUMP_WRITE_BACK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorTimerDumpWriteBackProof.gd'
SEPARATOR_TIMER_DUMP_WRITE_BACK_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorTimerDumpWriteBackProof.tscn'


class C07SeparatorTimerDumpWriteBackTests(unittest.TestCase):
    def test_c07_separator_timer_dump_write_back_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2361']['godot_owner'], 'SourceSeparatorBuildState.source_separator_timer_dump_state')
        # N2281 gave the separator its timerDump dump
        # (`if(timer(timerDump, dumpTime / timeScale)){
        # dump(); }`, Separator.java:165-166) through the
        # shared dump_item_state routing -- but the advance
        # swallowed the routing outcome (only items/cdump came
        # back), so the dumped item left the separator without
        # landing in any neighbour store. Java hands the item
        # over for real: `other.handleItem(self(), item);`
        # (BuildingComp.java:1089), and handleItem is
        # `items.add(item, 1);` (BuildingComp.java:860-862).
        # N2361 is the timerDump dump neighbour write-back
        # (the N2353 offload precedent): the advance exposes
        # the routed neighbour index + the dumped item from
        # the shared port (handled_index / handled_item), and
        # the tick wires the shared helper
        # source_neighbour_item_write_back_state after the
        # timerDump advance when dumped, so the dumped item
        # lands in the neighbour frame or belt queue. Two new
        # result symbols: the routed neighbour index and the
        # dumped item. The result schema + contract are NOT
        # touched here (the N2353 precedent: the new advance
        # keys are unregistered API shape until the
        # schema-sync fold).
        self.assertEqual(
            ledger['N2361']['source_symbols'],
            [
                'source_separator_timer_dump_state_result.dump_neighbour_index',
                'source_separator_timer_dump_state_result.dumped_item',
            ],
        )
        for name in ledger['N2361']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/comp/BuildingComp.java')
                self.assertEqual(symbol['godot_owner'], 'SourceSeparatorBuildState.source_separator_timer_dump_state')
        self.assertEqual(ledger['N2361']['runtime_proof'], '/root/C07SeparatorTimerDumpWriteBackProof')
        self.assertEqual(
            ledger['N2361']['tests'],
            [
                'test_c07_separator_timer_dump_write_back_registration',
                'test_all_c07_separator_timer_dump_write_back_input_evidence_is_exact',
                'test_separator_timer_dump_write_back_state',
                'test_reference_graph_and_actual_c07_separator_timer_dump_write_back',
            ],
        )
        self.assertTrue(ledger['N2361']['deferred_exprs'])
        # This slice resolves the Separator timerDump dump
        # neighbour write-back deferral and adds no new entry:
        # the dump neighbour live fill stays (the accept /
        # canDump arrays are still frame inputs, default []),
        # the first-fire deviation stays, and the follow-ups
        # entry is rewritten by the coordinator at merge (the
        # Separator timerDump line leaves the waiting list
        # there, not here).
        self.assertFalse(any(entry.startswith('Separator timerDump dump neighbour write-back (') for entry in ledger['N2361']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator timerDump dump neighbour live fill (') for entry in ledger['N2361']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator timerDump first-fire deviation (') for entry in ledger['N2361']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Neighbour item write-back follow-ups (') for entry in ledger['N2361']['deferred_exprs']))

    def test_all_c07_separator_timer_dump_write_back_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2361']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceSeparatorBuildState.source_separator_timer_dump_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/Separator.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2361']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_separator_timer_dump_write_back_state(self):
        separator = SEPARATOR_STATE.read_text(encoding='utf-8')
        # The timerDump advance exposes the routing outcome so
        # the tick can wire it: dump_neighbour_index is the
        # handled neighbour from dump_item_state
        # (handled_index, -1 when nothing dumped) and
        # dumped_item is the handed item (handled_item, "" when
        # nothing dumped) -- the first held item in content
        # order an accepting neighbour takes (dump(null),
        # BuildingComp.java:1072-1113, neighbours outer /
        # content items inner). The shared port already
        # reports both; the advance only surfaces them (the
        # N2353 offload_neighbour_index precedent). Keep each
        # Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this test).
        self.assertIn('static func source_separator_timer_dump_state', separator)
        self.assertIn('source_building_item_dump_state.dump_item_state(', separator)
        self.assertIn('result.get("handled_index", -1)', separator)
        self.assertIn('result.get("handled_item", "")', separator)
        self.assertIn('"dump_neighbour_index"', separator)
        self.assertIn('"dumped_item"', separator)
        self.assertIn('other.handleItem(self(), item);', separator)
        self.assertIn('public void handleItem(Building source, Item item){', separator)
        self.assertIn('items.add(item, 1);', separator)
        # The tick calls the shared helper after the timerDump
        # persist when dumped (Java order: the dump at
        # Separator.java:165-166 is the last step of
        # updateTile), with the catalog size, the routed
        # index, the dumped item, and amount 1 (one handleItem
        # per dump, BuildingComp:1089). Index i is ring cell i
        # (the N2353 convention). A failed write-back (no
        # sprite / no frame / no items store / full belt)
        # drops the item -- the routing already decided, so
        # there is no fallback to the separator's own store.
        self.assertIn('source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), dump_index, str(timer_dump.get("dumped_item", "")), 1)', separator)
        self.assertLess(
            separator.index('source_separator_timer_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)'),
            separator.index('source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), dump_index, str(timer_dump.get("dumped_item", "")), 1)'),
        )
        self.assertLess(
            separator.index('frame["cdump"] = timer_dump.get("cursor_after", frame.get("cdump", 0))'),
            separator.index('source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), dump_index, str(timer_dump.get("dumped_item", "")), 1)'),
        )
        # The N2353 offload wiring is a SEPARATE path (the
        # offload at Separator.java:160-161 precedes the dump
        # at :165-166) and is untouched: the offload helper
        # call still runs after the advance and before the
        # timerDump dump.
        self.assertIn('source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), offload_index, str(advanced.get("picked_item", "")), 1)', separator)
        self.assertLess(
            separator.index('source_building_item_state.source_neighbour_item_write_back_state(game, cell, int(block.properties.get("size", 1)), offload_index, str(advanced.get("picked_item", "")), 1)'),
            separator.index('source_separator_timer_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)'),
        )
        # The documented limits now record the timerDump dump
        # neighbour write-back as live (N2361) with the dump
        # neighbour live fill still deferred; the N2353
        # offload write-back, the N2343 routing, the N2222
        # advance, the N2281 dump, the N2200 gate, and the
        # N2169 power row are preserved.
        self.assertIn('timerDump dump neighbour write-back live since N2361', separator)
        self.assertIn('offload neighbour write-back live since N2353', separator)
        self.assertIn('offload neighbor routing live since N2343', separator)
        self.assertIn('Partial updateTile advance (N2222)', separator)
        self.assertIn('timerDump dump is live since N2281', separator)
        self.assertIn('shouldConsume gate live (N2200)', separator)
        self.assertIn('static func source_separator_offload_routing_context_state', separator)
        self.assertIn('static func source_separator_update_tile_advance_state', separator)
        self.assertIn('static func source_separator_timer_dump_state', separator)
        # The proof's keys drive the advance's exposed routed
        # index + dumped item (routed / refused / not-fired /
        # empty-store) and the live tick (a dumped item lands
        # in the neighbour frame; a dumped item to a storeless
        # neighbour still leaves the separator).
        proof = SEPARATOR_TIMER_DUMP_WRITE_BACK_PROOF.read_text(encoding='utf-8')
        for key in [
            'advance_exposes_dumped_neighbour_index',
            'live_tick_writes_dumped_item_to_neighbour_frame',
            'live_tick_dumped_item_leaves_separator_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceSeparatorBuildState.gd")', proof)
        self.assertTrue(SEPARATOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('separator_build_state.source_separator_timer_dump_state(', proof)
        self.assertIn('separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = SEPARATOR_TIMER_DUMP_WRITE_BACK_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07SeparatorTimerDumpWriteBackProof.gd', scene)
        self.assertIn('C07SeparatorTimerDumpWriteBackProof', scene)

    def test_reference_graph_and_actual_c07_separator_timer_dump_write_back(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SeparatorTimerDumpWriteBackProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SEPARATOR_TIMER_DUMP_WRITE_BACK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'advance_exposes_dumped_neighbour_index',
            'live_tick_writes_dumped_item_to_neighbour_frame',
            'live_tick_dumped_item_leaves_separator_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
