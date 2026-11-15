import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_TIMER_DUMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillTimerDumpProof.gd'
BURST_DRILL_TIMER_DUMP_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillTimerDumpProof.tscn'


class C07BurstDrillTimerDumpTests(unittest.TestCase):
    def test_c07_burst_drill_timer_dump_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2282']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_timer_dump_state')
        # N2149 proved the BurstDrill family's live power read,
        # N2203 wired its shouldConsume gate, N2219 its
        # updateTile advance (progress / warmup / timeDrilled /
        # lastDrillSpeed / smoothProgress / invertTime +
        # offload), N2257 its liquid rows -- but the timerDump
        # dump at the TOP of updateTile (BurstDrill.java:83-84,
        # `if(timer(timerDump, dumpTime / timeScale)){ dump(
        # items.has(dominantItem) ? dominantItem : null); }`)
        # was RED-deferred all along (no timer helper in the
        # port, the N2193 precedent), so a burst drill never
        # dumped anything even with a full store. N2282 is the
        # timerDump dump: a frame-local Interval-equivalent
        # (the N2266/N2269/N2273/N2280 precedent) firing at
        # dumpTime / timeScale (5f, Block.java:438, no override
        # in upstream), dumping the dominant item when the store
        # holds it and dump(null) otherwise, through the shared
        # dump_item_state routing (the N2276 precedent). Five
        # new result symbols: the fired flag, the elapsed clock
        # after the tick, the dumped flag, the items, and the
        # cursor after the tick.
        self.assertEqual(
            ledger['N2282']['source_symbols'],
            [
                'source_burst_drill_timer_dump_state_result.fired',
                'source_burst_drill_timer_dump_state_result.elapsed_after',
                'source_burst_drill_timer_dump_state_result.dumped',
                'source_burst_drill_timer_dump_state_result.items_after',
                'source_burst_drill_timer_dump_state_result.cursor_after',
            ],
        )
        for name in ledger['N2282']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BurstDrill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/entities/comp/TimerComp.java',
                    'arc-core/src/arc/util/Interval.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_timer_dump_state')
        self.assertEqual(ledger['N2282']['runtime_proof'], '/root/C07BurstDrillTimerDumpProof')
        self.assertEqual(
            ledger['N2282']['tests'],
            [
                'test_c07_burst_drill_timer_dump_registration',
                'test_all_c07_burst_drill_timer_dump_input_evidence_is_exact',
                'test_burst_drill_timer_dump_state',
                'test_reference_graph_and_actual_c07_burst_drill_timer_dump',
            ],
        )
        self.assertTrue(ledger['N2282']['deferred_exprs'])
        # This slice resolves the timerDump part of the combined
        # BurstDrill updateTile entry (the offload effects +
        # offload neighbor routing stay, under a narrowed
        # entry) and adds three new deferrals: the first-fire
        # deviation, the neighbour live fill, and the neighbour
        # write-back.
        self.assertFalse(any(entry.startswith('BurstDrill updateTile timerDump dump + offload effects + offload neighbor routing') for entry in ledger['N2282']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BurstDrill updateTile offload effects + offload neighbor routing') for entry in ledger['N2282']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BurstDrill timerDump first-fire deviation (') for entry in ledger['N2282']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BurstDrill timerDump neighbour live fill (') for entry in ledger['N2282']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BurstDrill timerDump neighbour write-back (') for entry in ledger['N2282']['deferred_exprs']))

    def test_all_c07_burst_drill_timer_dump_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2282']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_timer_dump_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/BurstDrill.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/Drill.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/TimerComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/type/ItemSeq.java'),
            ('arc-upstream', 'arc-core/src/arc/util/Interval.java'),
            ('arc-upstream', 'arc-core/src/arc/util/Time.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2282']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_timer_dump_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The pure timer dump lives on the burst-drill build
        # state: the timerDump check (BurstDrill.java:83-84)
        # runs at the TOP of updateTile -- after the
        # dominantItem null return (:77-79) and the invertTime
        # decay (:81), BEFORE the drillTime / smoothProgress /
        # gate / offload advance (:87+) -- so the dump drains
        # the store the advance filled LAST tick. dumpTime is 5
        # (Block.java:438, `public int dumpTime = 5;`, NO
        # override in upstream) and timerDump is the per-block
        # timer id (Block.java:436, `protected final int
        # timerDump = timers++;`). The timer is TimerComp.timer
        # (TimerComp.java:10-13): false for an infinite interval,
        # otherwise Interval.get (arc Interval.java:20-26),
        # which resets times[id] = Time.time on fire; check
        # compares Time.time - times[id] >= time (arc
        # Interval.java:28-30), and Time.time counts TICKS (arc
        # Time.java:69-80). The port has no global tick clock
        # at the driver layer, so the elapsed clock is
        # frame-local (the N2266/N2269/N2273/N2280 precedent):
        # elapsed += source_delta unconditionally; fired =
        # elapsed >= 5f / time_scale; elapsed_after RESETS to
        # 0.0 on fire; a non-positive time_scale is the
        # infinite-time branch (never fires). When the timer
        # fires, the dump is dump(dominantItem) if
        # items.has(dominantItem) -- has means amount > 0
        # (ItemSeq.java:79-81, `return values[item.id] > 0;`)
        # -- else dump(null). dump(Item todump)
        # (BuildingComp.java:1072-1113) guards on hasItems /
        # non-empty store / non-empty proximity, scans
        # proximity from the cdump cursor, and hands the first
        # held item an accepting neighbour takes (acceptItem &&
        # canDump) over, removing 1 from the store and
        # advancing the cursor once per neighbour checked
        # (incrementDump, BuildingComp.java:1116-1120, guarded
        # on prox != 0). Keep each Java expr on ONE comment
        # line (the N2148 shootWarmup lesson: a split line
        # fails this test).
        self.assertIn('static func source_burst_drill_timer_dump_state', burst_drill)
        self.assertIn('if(dominantItem == null){', burst_drill)
        self.assertIn('if(timer(timerDump, dumpTime / timeScale)){', burst_drill)
        self.assertIn('dump(items.has(dominantItem) ? dominantItem : null);', burst_drill)
        self.assertIn('public class BurstDrill extends Drill{', burst_drill)
        self.assertIn('public class BurstDrillBuild extends DrillBuild{', burst_drill)
        self.assertIn('protected final int timerDump = timers++;', burst_drill)
        self.assertIn('public int dumpTime = 5;', burst_drill)
        self.assertIn('hasItems = true;', burst_drill)
        self.assertIn('public Item dominantItem;', burst_drill)
        self.assertIn('public int dominantItems;', burst_drill)
        self.assertIn('if(Float.isInfinite(time)) return false;', burst_drill)
        self.assertIn('return timer.get(index, time);', burst_drill)
        self.assertIn('boolean got = check(id, time);', burst_drill)
        self.assertIn('if(got) times[id] = Time.time;', burst_drill)
        self.assertIn('return Time.time - times[id] >= time || Time.time < times[id];', burst_drill)
        self.assertIn('timeRaw += delta;', burst_drill)
        self.assertIn('return values[item.id] > 0;', burst_drill)
        self.assertIn('public boolean dump(){', burst_drill)
        self.assertIn('return dump(null);', burst_drill)
        self.assertIn('public boolean dump(Item todump){', burst_drill)
        self.assertIn('if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;', burst_drill)
        self.assertIn('int dump = this.cdump;', burst_drill)
        self.assertIn('var allItems = content.items();', burst_drill)
        self.assertIn('int itemSize = allItems.size;', burst_drill)
        self.assertIn('if(todump == null){', burst_drill)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', burst_drill)
        self.assertIn('if(!items.has(ii)) continue;', burst_drill)
        self.assertIn('Item item = (Item)itemArray[ii];', burst_drill)
        self.assertIn('if(other.acceptItem(self(), item) && canDump(other, item)){', burst_drill)
        self.assertIn('if(other.acceptItem(self(), todump) && canDump(other, todump)){', burst_drill)
        self.assertIn('other.handleItem(self(), item);', burst_drill)
        self.assertIn('other.handleItem(self(), todump);', burst_drill)
        self.assertIn('items.remove(item, 1);', burst_drill)
        self.assertIn('items.remove(todump, 1);', burst_drill)
        self.assertIn('incrementDump(proximity.size);', burst_drill)
        self.assertIn('public void incrementDump(int prox){', burst_drill)
        self.assertIn('if(prox != 0){', burst_drill)
        self.assertIn('cdump = ((cdump + 1) % prox);', burst_drill)
        self.assertIn('transient int cdump;', burst_drill)
        self.assertIn('public boolean canDump(Building to, Item item){', burst_drill)
        self.assertIn('return Time.delta * timeScale;', burst_drill)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', burst_drill)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', burst_drill)
        # The dump reuses the shared dump routing -- the
        # dump(Item) port SourceBuildingItemDumpState.
        # dump_item_state, which covers BOTH branches (todump
        # null: neighbour-outer / item-inner scan; todump
        # specific: the specific-item scan) -- NOT putItem
        # (game_put_item_state / put_item_state), which is the
        # WRONG shape here (the N2276 lesson: it dumps one
        # SPECIFIC item through game-bound increment callbacks
        # and cannot express dump(null)). The items total
        # reuses the shared drill inventory helper, never a
        # hand-rolled total. dumpTime is a driver constant (5,
        # the Block class default; no def overrides it).
        self.assertIn('source_building_item_dump_state.dump_item_state(', burst_drill)
        self.assertIn('source_drill_inventory_runtime_state.items_total(items)', burst_drill)
        self.assertIn('SOURCE_BURST_DRILL_DUMP_TIME := 5.0', burst_drill)
        self.assertIn('const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")', burst_drill)
        # The frame carries the dump state at the Java field
        # defaults: timer_dump_elapsed 0.0 (a fresh Interval
        # times[id] = 0) and cdump 0 (BuildingComp.java:68);
        # the neighbour acceptItem / canDump arrays are frame
        # inputs (default [] -- no neighbours, the Java
        # proximity.size == 0 outcome) until a live proximity
        # fill lands. The tick wires the dump into the live
        # loop BEFORE the advance (Java order:
        # BurstDrill.java:83-84 runs before :87+), inside the
        # same enabled gate as the advance
        # (BuildingComp.java:2276-2277), with the content item
        # ids in catalog order (game source_item_catalog
        # item_names_by_id, the N2276 precedent) and the
        # dominant item name the advance already resolves.
        self.assertIn('"timer_dump_elapsed": 0.0', burst_drill)
        self.assertIn('"cdump": 0', burst_drill)
        self.assertIn('frame.get("dump_neighbour_accepts", [])', burst_drill)
        self.assertIn('frame.get("dump_neighbour_can_dump", [])', burst_drill)
        self.assertIn('source_item_catalog', burst_drill)
        self.assertIn('item_names_by_id', burst_drill)
        self.assertIn('source_burst_drill_timer_dump_state(frame, source_delta, time_scale, dominant_item_name, content_item_ids, neighbour_accepts, neighbour_can_dump)', burst_drill)
        self.assertIn('frame["timer_dump_elapsed"]', burst_drill)
        self.assertIn('frame["cdump"]', burst_drill)
        self.assertLess(
            burst_drill.index('source_burst_drill_timer_dump_state(frame, source_delta, time_scale, dominant_item_name, content_item_ids, neighbour_accepts, neighbour_can_dump)'),
            burst_drill.index('source_burst_drill_update_tile_advance_state(frame, source_delta, time_scale, block_drill_time, block_boost, drill_multiplier, dominant_item_name, int(block.properties.get("itemCapacity", 10)))'),
        )
        # The documented limits now record the dump as live
        # (timerDump dump, N2282) and the remaining deferrals
        # (the first-fire deviation, the offload effects, the
        # neighbor routing); the N2219 advance, the N2203
        # gate, the N2257 liquid rows, and the N2149 power row
        # are preserved.
        self.assertIn('timerDump dump LIVE (N2282)', burst_drill)
        self.assertIn('updateTile advance LIVE (N2219)', burst_drill)
        self.assertIn('static func source_burst_drill_power_status_row_state', burst_drill)
        self.assertIn('static func source_burst_drill_should_consume_state', burst_drill)
        self.assertIn('static func source_burst_drill_update_tile_advance_state', burst_drill)
        # The proof's keys drive the pure dump (the timer
        # firing at 5 ticks / time_scale, no fire below the
        # threshold or at a zero time_scale, the dominant item
        # preferred when held, the dump(null) fallback when it
        # is not, no dump at all without a dominant item, the
        # cursor advancing per neighbour checked) plus the live
        # tick (a placed eruption-drill dumps its dominant
        # copper when the timer fires).
        proof = BURST_DRILL_TIMER_DUMP_PROOF.read_text(encoding='utf-8')
        for key in [
            'timer_fires_at_five_ticks',
            'timer_no_fire_below_threshold',
            'dump_prefers_dominant_item',
            'dump_falls_back_to_null',
            'no_dump_without_dominant_item',
            'dump_cursor_advances',
            'live_tick_dumps_item',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceBurstDrillBuildState.gd")', proof)
        self.assertTrue(BURST_DRILL_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('burst_drill_build_state.source_burst_drill_timer_dump_state(', proof)
        self.assertIn('burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertIn('write_proof("C07BurstDrillTimerDumpProof"', proof)
        scene = BURST_DRILL_TIMER_DUMP_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BurstDrillTimerDumpProof.gd', scene)
        self.assertIn('[node name="C07BurstDrillTimerDumpProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_burst_drill_timer_dump(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillTimerDumpProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_TIMER_DUMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'timer_fires_at_five_ticks',
            'timer_no_fire_below_threshold',
            'dump_prefers_dominant_item',
            'dump_falls_back_to_null',
            'no_dump_without_dominant_item',
            'dump_cursor_advances',
            'live_tick_dumps_item',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
