import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
SEPARATOR_TIMER_DUMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorTimerDumpProof.gd'
SEPARATOR_TIMER_DUMP_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorTimerDumpProof.tscn'


class C07SeparatorTimerDumpTests(unittest.TestCase):
    def test_c07_separator_timer_dump_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2281']['godot_owner'], 'SourceSeparatorBuildState.source_separator_timer_dump_state')
        # N2222 gave the separator its updateTile advance
        # (progress / warmup / totalProgress / seed / consume()
        # / the offload random result pick, Separator.java:
        # 130-167) -- but the timerDump dump at the END of
        # updateTile (`if(timer(timerDump, dumpTime /
        # timeScale)){ dump(); }`, Separator.java:165-166) was
        # RED-deferred all along: dumpTime 5 (Block.java:438,
        # no override in upstream), timerDump = timers++
        # (Block.java:436), and dump() = dump(null)
        # (BuildingComp.java:1064-1066), the neighbour-outer /
        # item-inner scan (BuildingComp.java:1072-1113) that
        # hands the first held item an accepting neighbour
        # takes (acceptItem && canDump), removing 1 from the
        # store and advancing the cdump cursor once per
        # neighbour checked. N2281 is the dump: the pure
        # timer-dump function is the frame-local
        # Interval-equivalent (TimerComp.timer, TimerComp.
        # java:10-13, false on an infinite time, else
        # Interval.get, which resets times[id] = Time.time on
        # fire, arc Interval.java:20-26; check compares
        # Time.time - times[id] >= time, arc Interval.java:
        # 28-30; Time.time counts TICKS, arc Time.java:69-80)
        # -- elapsed += source_delta unconditionally, fired =
        # elapsed >= 5f / time_scale, a non-positive time_scale
        # is the infinite-time branch (fired false),
        # elapsed_after resets to 0.0 on fire -- plus the dump
        # itself through the shared dump_item_state routing
        # (the N2276 precedent; game_put_item_state cannot
        # express dump(null)). The tick wires the dump AFTER
        # the advance in the same tick (Java order: the timer
        # check sits after the progress/offload block,
        # Separator.java:140-163), so the dump sees the store
        # the advance just offloaded into, and the dump shares
        # the frame cdump with the offload (Java uses the same
        # `this.cdump` for both). Five new result symbols: the
        # fired flag, the elapsed clock after the tick, the
        # dumped flag, the items, and the cursor after the tick.
        self.assertEqual(
            ledger['N2281']['source_symbols'],
            [
                'source_separator_timer_dump_state_result.fired',
                'source_separator_timer_dump_state_result.elapsed_after',
                'source_separator_timer_dump_state_result.dumped',
                'source_separator_timer_dump_state_result.items_after',
                'source_separator_timer_dump_state_result.cursor_after',
            ],
        )
        for name in ledger['N2281']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/TimerComp.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSeparatorBuildState.source_separator_timer_dump_state')
        self.assertEqual(ledger['N2281']['runtime_proof'], '/root/C07SeparatorTimerDumpProof')
        self.assertEqual(
            ledger['N2281']['tests'],
            [
                'test_c07_separator_timer_dump_registration',
                'test_all_c07_separator_timer_dump_input_evidence_is_exact',
                'test_separator_timer_dump_state',
                'test_reference_graph_and_actual_c07_separator_timer_dump',
            ],
        )
        self.assertTrue(ledger['N2281']['deferred_exprs'])
        # This slice resolves the Separator timerDump dump
        # deferral and adds three new ones: the first-fire
        # deviation (the frame-local clock delays the first
        # fire by a full 5-tick interval), the dump neighbour
        # live fill (the accept/canDump arrays are frame
        # inputs, default []), and the dump neighbour
        # write-back (the dumped item leaves the separator
        # without landing in any neighbour store). The offload
        # neighbor routing entry stays: the offload still
        # takes the no-neighbour fallback.
        self.assertFalse(any(entry.startswith('Separator timerDump dump (') for entry in ledger['N2281']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator timerDump first-fire deviation (') for entry in ledger['N2281']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator timerDump dump neighbour live fill (') for entry in ledger['N2281']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator timerDump dump neighbour write-back (') for entry in ledger['N2281']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator offload neighbor routing (') for entry in ledger['N2281']['deferred_exprs']))

    def test_all_c07_separator_timer_dump_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2281']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceSeparatorBuildState.source_separator_timer_dump_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/Separator.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/TimerComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('arc-upstream', 'arc-core/src/arc/util/Interval.java'),
            ('arc-upstream', 'arc-core/src/arc/util/Time.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2281']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_separator_timer_dump_state(self):
        separator = SEPARATOR_STATE.read_text(encoding='utf-8')
        # The pure timer-dump function is the frame-local
        # Interval-equivalent (TimerComp.timer, TimerComp.
        # java:10-13: `if(Float.isInfinite(time)) return
        # false;` / `return timer.get(index, time);`; Interval.
        # get resets times[id] = Time.time on fire, Interval.
        # java:20-26; check compares Time.time - times[id] >=
        # time, Interval.java:28-30; Time.time counts TICKS,
        # Time.java:69-80): elapsed += source_delta
        # unconditionally; fired = elapsed >= dumpTime /
        # time_scale with dumpTime 5 (Block.java:438, no
        # override in upstream); a non-positive time_scale is
        # the infinite-time branch (fired false); elapsed_after
        # resets to 0.0 on fire (a RESET, not a subtraction
        # like the Fracker accumulator). When the timer fires
        # the dump runs dump(null) (BuildingComp.java:
        # 1072-1113): neighbours outer, content items inner --
        # for each neighbour from the cdump cursor, the first
        # held item in content order an accepting neighbour
        # takes is handed over, 1 leaves the store, and the
        # cursor advances once per neighbour checked
        # (incrementDump, BuildingComp.java:1116-1120, guarded
        # on prox != 0). Keep each Java expr on ONE comment
        # line (the N2148 shootWarmup lesson: a split line
        # fails this test). The separator has items
        # (`hasItems = true;`, Separator.java:31), so the
        # hasItems guard always passes. First-fire deviation:
        # Java fires (nearly) immediately after placement (the
        # global Time.time is already large vs a fresh
        # Interval times[id] = 0); the frame-local clock
        # delays the first fire by a full interval (5 ticks).
        self.assertIn('static func source_separator_timer_dump_state', separator)
        self.assertIn('if(timer(timerDump, dumpTime / timeScale)){', separator)
        self.assertIn('dump();', separator)
        self.assertIn('hasItems = true;', separator)
        self.assertIn('protected final int timerDump = timers++;', separator)
        self.assertIn('public int dumpTime = 5;', separator)
        self.assertIn('public boolean timer(int index, float time){', separator)
        self.assertIn('if(Float.isInfinite(time)) return false;', separator)
        self.assertIn('return timer.get(index, time);', separator)
        self.assertIn('boolean got = check(id, time);', separator)
        self.assertIn('if(got) times[id] = Time.time;', separator)
        self.assertIn('return Time.time - times[id] >= time || Time.time < times[id];', separator)
        self.assertIn('timeRaw += delta;', separator)
        self.assertIn('public boolean dump(){', separator)
        self.assertIn('return dump(null);', separator)
        self.assertIn('public boolean dump(Item todump){', separator)
        self.assertIn('if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;', separator)
        self.assertIn('int dump = this.cdump;', separator)
        self.assertIn('var allItems = content.items();', separator)
        self.assertIn('int itemSize = allItems.size;', separator)
        self.assertIn('if(todump == null){', separator)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', separator)
        self.assertIn('if(!items.has(ii)) continue;', separator)
        self.assertIn('Item item = (Item)itemArray[ii];', separator)
        self.assertIn('if(other.acceptItem(self(), item) && canDump(other, item)){', separator)
        self.assertIn('other.handleItem(self(), item);', separator)
        self.assertIn('items.remove(item, 1);', separator)
        self.assertIn('incrementDump(proximity.size);', separator)
        self.assertIn('public void incrementDump(int prox){', separator)
        self.assertIn('if(prox != 0){', separator)
        self.assertIn('cdump = ((cdump + 1) % prox);', separator)
        self.assertIn('transient int cdump;', separator)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', separator)
        self.assertIn('public boolean canDump(Building to, Item item){', separator)
        # The dump reuses the shared dump routing -- the
        # dump(null) port SourceBuildingItemDumpState.
        # dump_item_state (the putItem gate
        # game_put_item_state is the WRONG shape here: it dumps
        # one SPECIFIC item and needs a game object for its
        # increment callbacks, while the timer block calls
        # dump(), whose shared port is dump_item_state) --
        # and the drill inventory totals helper, never a
        # hand-rolled total. dumpTime is a driver constant (5,
        # the Block default; no def overrides it).
        self.assertIn('source_building_item_dump_state.dump_item_state(', separator)
        self.assertIn('inventory.items_total(items)', separator)
        self.assertIn('SOURCE_SEPARATOR_DUMP_TIME := 5.0', separator)
        self.assertIn('const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")', separator)
        # The frame carries the timer clock at the Java field
        # default (timer_dump_elapsed 0.0, the fresh Interval
        # times[id] = 0) and the shared cdump cursor (0,
        # BuildingComp.java:68); the neighbour acceptItem /
        # canDump arrays are frame inputs (default [] -- no
        # neighbours, the Java proximity.size == 0 outcome)
        # until a live proximity fill lands. The tick wires the
        # dump into the live loop AFTER the progress advance
        # (Java order: Separator.java:165-166 runs after
        # :140-163), inside the same enabled gate as the
        # advance (BuildingComp.java:2276-2277), with the
        # content item ids in catalog order (game
        # source_item_catalog item_names_by_id, the factory
        # precedent) and the source delta / timeScale the
        # advance already reads.
        self.assertIn('frame.get("timer_dump_elapsed", 0.0)', separator)
        self.assertIn('frame.get("dump_neighbour_accepts", [])', separator)
        self.assertIn('frame.get("dump_neighbour_can_dump", [])', separator)
        self.assertIn('source_item_catalog', separator)
        self.assertIn('item_names_by_id', separator)
        self.assertIn('source_separator_timer_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)', separator)
        self.assertIn('frame["timer_dump_elapsed"]', separator)
        self.assertIn('frame["cdump"]', separator)
        self.assertLess(
            separator.index('source_separator_update_tile_advance_state(frame, source_delta, time_scale, craft_time, results, cons_items, item_capacity)'),
            separator.index('source_separator_timer_dump_state(frame, source_delta, time_scale, content_item_ids, neighbour_accepts, neighbour_can_dump)'),
        )
        # The documented limits now record the dump as live
        # (timerDump dumpTime 5 + dump(null)) and the
        # remaining deferrals (the offload neighbor routing,
        # the dump neighbour live fill + write-back, the
        # first-fire deviation); the N2222 advance, the N2200
        # gate, and the N2169 power row are preserved.
        self.assertIn('timerDump dump is live since N2281', separator)
        self.assertIn('Partial updateTile advance (N2222)', separator)
        self.assertIn('shouldConsume gate live (N2200)', separator)
        self.assertIn('static func source_separator_power_status_row_state', separator)
        self.assertIn('static func source_separator_should_consume_state', separator)
        self.assertIn('static func source_separator_update_tile_advance_state', separator)
        # The proof's keys drive the pure timer-dump (the
        # timer firing at 5 ticks, no fire below the
        # threshold, the dump removing the first held item in
        # content order, the cursor advancing per neighbour
        # checked, no dump when the store is empty -- the
        # timer still fires and resets) plus the live tick (a
        # placed separator dumps 1 item in one tick at a full
        # clock, after the advance).
        proof = SEPARATOR_TIMER_DUMP_PROOF.read_text(encoding='utf-8')
        for key in [
            'timer_fires_at_five_ticks',
            'timer_no_fire_below_threshold',
            'dump_removes_item_from_store',
            'dump_cursor_advances',
            'no_dump_when_items_empty',
            'live_tick_dumps_item',
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
        scene = SEPARATOR_TIMER_DUMP_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07SeparatorTimerDumpProof.gd', scene)
        self.assertIn('C07SeparatorTimerDumpProof', scene)

    def test_reference_graph_and_actual_c07_separator_timer_dump(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SeparatorTimerDumpProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SEPARATOR_TIMER_DUMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'timer_fires_at_five_ticks',
            'timer_no_fire_below_threshold',
            'dump_removes_item_from_store',
            'dump_cursor_advances',
            'no_dump_when_items_empty',
            'live_tick_dumps_item',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
