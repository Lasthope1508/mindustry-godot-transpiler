import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
SEPARATOR_OFFLOAD_ROUTING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorOffloadRoutingProof.gd'
SEPARATOR_OFFLOAD_ROUTING_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorOffloadRoutingProof.tscn'


class C07SeparatorOffloadRoutingTests(unittest.TestCase):
    def test_c07_separator_offload_routing_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2343']['godot_owner'], 'SourceSeparatorBuildState.source_separator_offload_routing_context_state')
        # N2222 gave the separator its updateTile advance
        # (progress / warmup / totalProgress / seed / consume()
        # / the offload random result pick, Separator.java:
        # 130-167) -- and the advance already accepted a
        # routing_context argument for the offload
        # (Separator.java:160-161, `if(item != null &&
        # items.get(item) < itemCapacity){` with
        # `offload(item);`), running the pick through the
        # shared offload_item_state port of offload()
        # (BuildingComp.java:1001-1016). But the live tick
        # never passed one: the advance call took the default
        # {} context, so the picked result always fell back to
        # the separator's own items (the Java
        # no-neighbor-accepts outcome) even when a neighbour
        # would have taken it. N2343 is the routing: the pure
        # routing-context builder turns the frame neighbour
        # inputs into the context offload_item_state reads --
        # the neighbors array [{accepts_item, can_dump,
        # item_count}] plus the dump cursor -- and the tick
        # passes it into the advance call. The frame inputs
        # are the SAME arrays the N2281 dump reads
        # (dump_neighbour_accepts / dump_neighbour_can_dump,
        # default []): Java has ONE proximity list, and
        # offload() and dump() scan the same neighbours with
        # the same acceptItem/canDump answers, so the port
        # keeps one pair of frame inputs instead of adding a
        # synonym pair. The cursor is the frame cdump (the
        # shared `this.cdump` Java reads at BuildingComp.
        # java:1003, `int dump = this.cdump;`): offload()
        # rotates it once per neighbour checked
        # (incrementDump, BuildingComp.java:1116-1120) and
        # inspects from the saved value ((i + dump) %
        # proximity.size, :1007), so a routed pick leaves the
        # cursor past the handling neighbour and a full
        # refused scan returns it to its start (the N2286
        # full-cycle invariant). Two new result symbols: the
        # neighbors array and the dump cursor.
        self.assertEqual(
            ledger['N2343']['source_symbols'],
            [
                'source_separator_offload_routing_context_state_result.neighbors',
                'source_separator_offload_routing_context_state_result.dump_cursor',
            ],
        )
        for name in ledger['N2343']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/blocks/production/Separator.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSeparatorBuildState.source_separator_offload_routing_context_state')
        self.assertEqual(ledger['N2343']['runtime_proof'], '/root/C07SeparatorOffloadRoutingProof')
        self.assertEqual(
            ledger['N2343']['tests'],
            [
                'test_c07_separator_offload_routing_registration',
                'test_all_c07_separator_offload_routing_input_evidence_is_exact',
                'test_separator_offload_routing_state',
                'test_reference_graph_and_actual_c07_separator_offload_routing',
            ],
        )
        self.assertTrue(ledger['N2343']['deferred_exprs'])
        # This slice resolves the Separator offload neighbor
        # routing deferral and adds one new one: the offload
        # neighbour write-back (a routed item leaves the
        # separator without landing in any neighbour store --
        # the shared port only bumps the ephemeral neighbour
        # dict item_count). The live fill of the shared frame
        # inputs stays on the N2281 dump entry (the same
        # arrays feed both paths, so one live fill serves
        # both); the first-fire deviation entry is untouched.
        self.assertFalse(any(entry.startswith('Separator offload neighbor routing (') for entry in ledger['N2343']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator offload neighbour write-back (') for entry in ledger['N2343']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator timerDump dump neighbour live fill (') for entry in ledger['N2343']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator timerDump first-fire deviation (') for entry in ledger['N2343']['deferred_exprs']))

    def test_all_c07_separator_offload_routing_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2343']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceSeparatorBuildState.source_separator_offload_routing_context_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/Separator.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2343']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_separator_offload_routing_state(self):
        separator = SEPARATOR_STATE.read_text(encoding='utf-8')
        # The pure routing-context builder turns the frame
        # neighbour inputs into the context the shared
        # offload_item_state port reads: the neighbors array
        # [{accepts_item, can_dump, item_count}] plus the
        # dump cursor (SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY /
        # SOURCE_DRILL_INVENTORY_DUMP_CURSOR_KEY, "neighbors" /
        # "dump_cursor"). offload() (BuildingComp.java:
        # 1001-1016) scans proximity from the saved cdump:
        # `produced(item, 1);` (:1002), `int dump =
        # this.cdump;` (:1003), then for each neighbour
        # `incrementDump(proximity.size);` BEFORE the check
        # (:1006) and `Building other = proximity.get((i +
        # dump) % proximity.size);` (:1007) -- rotate the
        # cursor, then inspect from its saved value (the
        # offload_item_state order) -- handing the item to
        # the first neighbour where `if(other.acceptItem(self(),
        # item) && canDump(other, item)){` (:1008) holds, via
        # `other.handleItem(self(), item);` (:1009), and
        # falling back to `handleItem(self(), item);`
        # (:1014) when no neighbour takes it. incrementDump
        # (BuildingComp.java:1116-1120) is `cdump = ((cdump +
        # 1) % prox);` guarded on prox != 0; the cursor is
        # the Building field `transient int cdump;`
        # (BuildingComp.java:68, 0). The Separator call site
        # is Separator.java:160-161 (`if(item != null &&
        # items.get(item) < itemCapacity){` / `offload(item);`).
        # Keep each Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this test).
        self.assertIn('static func source_separator_offload_routing_context_state', separator)
        self.assertIn('public void offload(Item item){', separator)
        self.assertIn('produced(item, 1);', separator)
        self.assertIn('int dump = this.cdump;', separator)
        self.assertIn('for(int i = 0; i < proximity.size; i++){', separator)
        self.assertIn('incrementDump(proximity.size);', separator)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', separator)
        self.assertIn('if(other.acceptItem(self(), item) && canDump(other, item)){', separator)
        self.assertIn('other.handleItem(self(), item);', separator)
        self.assertIn('handleItem(self(), item);', separator)
        self.assertIn('public void incrementDump(int prox){', separator)
        self.assertIn('cdump = ((cdump + 1) % prox);', separator)
        self.assertIn('transient int cdump;', separator)
        self.assertIn('if(item != null && items.get(item) < itemCapacity){', separator)
        self.assertIn('offload(item);', separator)
        # The builder returns the routing context through the
        # inventory key constants (not literal strings), with
        # the neighbour dicts carrying accepts_item / can_dump
        # / item_count (the offload_item_state shape: the port
        # reads accepts_item && can_dump per neighbour and
        # bumps item_count on the handled one). A missing
        # answer in one array reads false (the dump_item_state
        # bounds-checked precedent), so a mismatched pair
        # still scans the longer proximity with the missing
        # side refusing.
        self.assertIn('inventory.SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY', separator)
        self.assertIn('inventory.SOURCE_DRILL_INVENTORY_DUMP_CURSOR_KEY', separator)
        self.assertIn('"accepts_item"', separator)
        self.assertIn('"can_dump"', separator)
        self.assertIn('"item_count"', separator)
        # The tick builds the context from the SAME frame
        # inputs the N2281 dump reads (Java has ONE proximity
        # list; offload and dump scan the same neighbours) and
        # the frame cdump, and passes it into the advance call
        # -- before the advance, so the craft offload in this
        # tick already routes. The advance still defaults a
        # missing cursor from the frame cdump when a direct
        # caller passes a context without one (offload()
        # reads `this.cdump`, BuildingComp.java:1003), so a
        # context-less craft no longer clobbers the frame
        # cursor to 0 on the fallback path.
        self.assertIn('frame.get("dump_neighbour_accepts", [])', separator)
        self.assertIn('frame.get("dump_neighbour_can_dump", [])', separator)
        self.assertIn('source_separator_offload_routing_context_state(offload_neighbour_accepts, offload_neighbour_can_dump, int(frame.get("cdump", 0)))', separator)
        self.assertIn('source_separator_update_tile_advance_state(frame, source_delta, time_scale, craft_time, results, cons_items, item_capacity, routing_context)', separator)
        self.assertIn('if not offload_context.has(inventory.SOURCE_DRILL_INVENTORY_DUMP_CURSOR_KEY):', separator)
        self.assertLess(
            separator.index('source_separator_offload_routing_context_state(offload_neighbour_accepts, offload_neighbour_can_dump, int(frame.get("cdump", 0)))'),
            separator.index('source_separator_update_tile_advance_state(frame, source_delta, time_scale, craft_time, results, cons_items, item_capacity, routing_context)'),
        )
        self.assertLess(
            separator.index('source_separator_update_tile_advance_state(frame, source_delta, time_scale, craft_time, results, cons_items, item_capacity, routing_context)'),
            separator.index('source_separator_timer_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)'),
        )
        # The documented limits now record the offload
        # neighbor routing as live (N2343) with the
        # write-back + shared live fill still deferred; the
        # N2222 advance, the N2281 dump, the N2200 gate, and
        # the N2169 power row are preserved.
        self.assertIn('offload neighbor routing live since N2343', separator)
        self.assertIn('Partial updateTile advance (N2222)', separator)
        self.assertIn('timerDump dump is live since N2281', separator)
        self.assertIn('shouldConsume gate live (N2200)', separator)
        self.assertIn('static func source_separator_power_status_row_state', separator)
        self.assertIn('static func source_separator_should_consume_state', separator)
        self.assertIn('static func source_separator_update_tile_advance_state', separator)
        self.assertIn('static func source_separator_timer_dump_state', separator)
        # The proof's keys drive the pure builder (the
        # neighbors array + cursor from the frame inputs, the
        # empty-inputs fallback shape) and the advance
        # through it (a crafted pick routes to the first
        # accepting neighbour from the saved cursor, falls
        # back to the own store when no neighbour accepts --
        # with the frame cursor preserved -- and still
        # respects itemCapacity) plus the live tick (a placed
        # separator crafts and routes the pick to a neighbour
        # in one tick).
        proof = SEPARATOR_OFFLOAD_ROUTING_PROOF.read_text(encoding='utf-8')
        for key in [
            'routing_context_builds_neighbors',
            'routing_context_empty_neighbors',
            'offload_routes_to_accepting_neighbor',
            'offload_falls_back_without_accepting_neighbor',
            'offload_respects_item_capacity',
            'live_tick_routes_offloaded_item',
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
        self.assertIn('separator_build_state.source_separator_offload_routing_context_state(', proof)
        self.assertIn('separator_build_state.source_separator_update_tile_advance_state(', proof)
        self.assertIn('separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = SEPARATOR_OFFLOAD_ROUTING_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07SeparatorOffloadRoutingProof.gd', scene)
        self.assertIn('C07SeparatorOffloadRoutingProof', scene)

    def test_reference_graph_and_actual_c07_separator_offload_routing(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SeparatorOffloadRoutingProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SEPARATOR_OFFLOAD_ROUTING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'routing_context_builds_neighbors',
            'routing_context_empty_neighbors',
            'offload_routes_to_accepting_neighbor',
            'offload_falls_back_without_accepting_neighbor',
            'offload_respects_item_capacity',
            'live_tick_routes_offloaded_item',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
