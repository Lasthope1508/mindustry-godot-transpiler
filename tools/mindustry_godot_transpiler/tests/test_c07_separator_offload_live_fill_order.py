import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
SEPARATOR_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/production/Separator.java'


class C07SeparatorOffloadLiveFillOrderTests(unittest.TestCase):
    def test_separator_offload_live_fill_order_pins(self):
        separator = SEPARATOR_STATE.read_text(encoding='utf-8')
        # N2413: the offload one-tick lag fix. Before this
        # slice the tick built the offload routing context
        # (:972) and ran the updateTile advance (:973)
        # BEFORE the N2402 live fill (:1045) bound the
        # neighbour arrays, so the offload read the PREVIOUS
        # tick's live-filled arrays. Java order is offload
        # (:160-161) before dump (:165-166)
        # (Separator.java) -- the offload SHOULD see the
        # current tick's proximity, like the timerDump dump
        # already does. The fix hoists the content_item_ids
        # binding + the N2402 fill block (incl. the
        # supplied-arrays-win guard) to BEFORE the
        # routing-context build, so the offload routing
        # context reads the CURRENT tick's live-filled
        # arrays. The fill still runs exactly once per tick
        # (its definition plus the one tick call site) --
        # never twice -- and the timerDump reads below still
        # read the same frame keys afterwards.
        # Judgment call (documented in the driver comment):
        # the offload routing uses the fill's FIRST-held-item
        # accepts (the same approximation the timerDump dump
        # uses -- the fill answers for the first held item
        # in content order). Per-item routing for the PICKED
        # item (Java's offload(item) checks acceptItem for
        # the picked item specifically) waits for the
        # per-item dump routing slice -- not invented here.
        fill_call = 'source_separator_dump_neighbour_live_fill_state(game, cell, int(block.properties.get("size", 1)), frame, content_item_ids)'
        routing_call = 'source_separator_offload_routing_context_state(offload_neighbour_accepts, offload_neighbour_can_dump, int(frame.get("cdump", 0)))'
        content_binding = 'var content_item_ids: Array = source_content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])'
        advance_call = 'source_separator_update_tile_advance_state(frame, source_delta, time_scale, craft_time, results, cons_items, item_capacity, routing_context)'
        timer_dump_read = 'var neighbour_accepts: Array = frame.get("dump_neighbour_accepts", [])'
        self.assertIn(fill_call, separator)
        self.assertIn(routing_call, separator)
        self.assertIn(content_binding, separator)
        # The fill runs exactly once per tick (definition +
        # one call site) -- the hoist moves it, it does not
        # duplicate it.
        self.assertEqual(separator.count('source_separator_dump_neighbour_live_fill_state('), 2)
        self.assertEqual(separator.count(content_binding), 1)
        # Order pins: content_item_ids is bound before both
        # the fill and the routing-context build, and the
        # fill runs BEFORE the routing-context build, which
        # runs before the advance.
        self.assertLess(separator.index(content_binding), separator.index(fill_call))
        self.assertLess(separator.index(content_binding), separator.index(routing_call))
        self.assertLess(separator.index(fill_call), separator.index(routing_call))
        self.assertLess(separator.index(routing_call), separator.index(advance_call))
        # The fill's frame writes land before the routing
        # context reads the frame arrays, so the offload
        # sees the CURRENT tick's live-filled arrays.
        self.assertLess(
            separator.index('frame["dump_neighbour_accepts"] = filled.get("dump_neighbour_accepts", [])'),
            separator.index('var offload_neighbour_accepts: Array = frame.get("dump_neighbour_accepts", [])'),
        )
        self.assertLess(
            separator.index('frame["dump_neighbour_can_dump"] = filled.get("dump_neighbour_can_dump", [])'),
            separator.index('var offload_neighbour_can_dump: Array = frame.get("dump_neighbour_can_dump", [])'),
        )
        # The supplied-arrays-win guard moves with the fill
        # (the N2381 precedent -- the N2281/N2343/N2361
        # proofs seed the arrays by hand, so a fill there
        # would overwrite the seed), and a previously
        # live-filled frame still refreshes every tick.
        self.assertIn('has_supplied_dump_neighbour_arrays', separator)
        self.assertIn('frame["dump_neighbour_live"] = true', separator)
        self.assertIn('bool(frame.get("dump_neighbour_live", false))', separator)
        self.assertLess(separator.index('has_supplied_dump_neighbour_arrays'), separator.index(routing_call))
        # The timerDump reads still come after the fill (the
        # N2402 pin still holds under the new order).
        self.assertLess(separator.index(fill_call), separator.index(timer_dump_read))
        self.assertLess(
            separator.index('frame["dump_neighbour_accepts"] = filled.get("dump_neighbour_accepts", [])'),
            separator.index(timer_dump_read),
        )
        # The driver comment no longer describes the lag as
        # live -- it describes the new order.
        self.assertIn('live fill lands BEFORE the advance (N2413)', separator)
        self.assertNotIn('the live fill lands AFTER the advance (N2402)', separator)
        # Scope pins, by Java line number: the offload at
        # Separator.java:160-161 precedes the dump at
        # :165-166.
        separator_lines = SEPARATOR_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(separator_lines[159].strip(), 'if(item != null && items.get(item) < itemCapacity){')
        self.assertEqual(separator_lines[160].strip(), 'offload(item);')
        self.assertEqual(separator_lines[164].strip(), 'if(timer(timerDump, dumpTime / timeScale)){')
        self.assertEqual(separator_lines[165].strip(), 'dump();')


if __name__ == '__main__':
    unittest.main()
