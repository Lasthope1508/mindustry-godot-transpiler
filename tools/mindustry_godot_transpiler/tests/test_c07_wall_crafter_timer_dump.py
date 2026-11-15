import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WALL_CRAFTER_STATE = ROOT / 'godot-mindustry/src/game/SourceWallCrafterBuildState.gd'
WALL_CRAFTER_TIMER_DUMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterTimerDumpProof.gd'
WALL_CRAFTER_TIMER_DUMP_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterTimerDumpProof.tscn'


class C07WallCrafterTimerDumpTests(unittest.TestCase):
    def test_c07_wall_crafter_timer_dump_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2283']['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_timer_dump_state')
        # Advance N2223 ported warmup / eff /
        # lastEfficiency / time / totalTime / offload-to-
        # inventory (WallCrafter.java:193-218) and N2273
        # ported the timerUse booster consume (:207-209),
        # but the timerDump dump (`if(timer(timerDump,
        # dumpTime / timeScale)){ dump(output); }`,
        # WallCrafter.java:220-221, `public int dumpTime =
        # 5;`, Block.java:438, no def overrides it) stayed
        # deferred, so a wall crafter kept its sand forever
        # and never dumped to a neighbour. N2283 is the
        # timerDump dump: the frame-local Interval-
        # equivalent pure function (TimerComp.timer,
        # TimerComp.java:10-13, false on an infinite time,
        # else Interval.get, which resets times[id] =
        # Time.time on fire, Interval.java:20-26; Time.time
        # counts TICKS, Time.java:69-80) plus the tick
        # wiring after the N2223 advance and the N2273
        # timerUse consume (the Java order, :207-209 then
        # :220-221): when the timer fires at 5f/time_scale
        # it dumps 1 sand -- the output item (`public Item
        # output = Items.sand;`, WallCrafter.java:43, set
        # explicitly by both defs, `output = Items.sand;`,
        # Blocks.java:3009/:3023) -- through the shared
        # dump(output) port (SourceBuildingItemDumpState.
        # dump_item_state, BuildingComp.java:1072-1113).
        # Five new result symbols: fired, elapsed_after,
        # dumped, items_after, cursor_after.
        self.assertEqual(
            ledger['N2283']['source_symbols'],
            [
                'source_wall_crafter_timer_dump_state_result.fired',
                'source_wall_crafter_timer_dump_state_result.elapsed_after',
                'source_wall_crafter_timer_dump_state_result.dumped',
                'source_wall_crafter_timer_dump_state_result.items_after',
                'source_wall_crafter_timer_dump_state_result.cursor_after',
            ],
        )
        for name in ledger['N2283']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/TimerComp.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_wall_crafter_timer_dump_state_result.fired': 'SourceWallCrafterBuildState.source_wall_crafter_timer_dump_state',
                    'source_wall_crafter_timer_dump_state_result.elapsed_after': 'SourceWallCrafterBuildState.source_wall_crafter_timer_dump_state',
                    'source_wall_crafter_timer_dump_state_result.dumped': 'SourceWallCrafterBuildState.source_wall_crafter_timer_dump_state',
                    'source_wall_crafter_timer_dump_state_result.items_after': 'SourceWallCrafterBuildState.source_wall_crafter_timer_dump_state',
                    'source_wall_crafter_timer_dump_state_result.cursor_after': 'SourceWallCrafterBuildState.source_wall_crafter_timer_dump_state',
                }[name])
        self.assertEqual(ledger['N2283']['runtime_proof'], '/root/C07WallCrafterTimerDumpProof')
        self.assertEqual(
            ledger['N2283']['tests'],
            [
                'test_c07_wall_crafter_timer_dump_registration',
                'test_all_c07_wall_crafter_timer_dump_input_evidence_is_exact',
                'test_wall_crafter_timer_dump_state',
                'test_reference_graph_and_actual_c07_wall_crafter_timer_dump',
            ],
        )
        self.assertTrue(ledger['N2283']['deferred_exprs'])

    def test_all_c07_wall_crafter_timer_dump_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2283']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_wall_crafter_timer_dump_state_result.fired': 'SourceWallCrafterBuildState.source_wall_crafter_timer_dump_state',
                    'source_wall_crafter_timer_dump_state_result.elapsed_after': 'SourceWallCrafterBuildState.source_wall_crafter_timer_dump_state',
                    'source_wall_crafter_timer_dump_state_result.dumped': 'SourceWallCrafterBuildState.source_wall_crafter_timer_dump_state',
                    'source_wall_crafter_timer_dump_state_result.items_after': 'SourceWallCrafterBuildState.source_wall_crafter_timer_dump_state',
                    'source_wall_crafter_timer_dump_state_result.cursor_after': 'SourceWallCrafterBuildState.source_wall_crafter_timer_dump_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/WallCrafter.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2283']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wall_crafter_timer_dump_state(self):
        wall_crafter = WALL_CRAFTER_STATE.read_text(encoding='utf-8')
        # The pure timer-dump function is the frame-local
        # Interval-equivalent for the timerDump dump
        # (TimerComp.timer, TimerComp.java:10-13:
        # `if(Float.isInfinite(time)) return false;` /
        # `return timer.get(index, time);`; Interval.get
        # resets times[id] = Time.time on fire, Interval.
        # java:20-26; Time.time counts TICKS, Time.java:
        # 69-80): threshold = dumpTime / time_scale (5f /
        # time_scale, `public int dumpTime = 5;`,
        # Block.java:438, no def overrides it, so both defs
        # fire at 5f / timeScale); a non-positive time_scale
        # is the infinite-time branch (fired false); fired
        # = elapsed >= threshold; elapsed_after resets to
        # 0.0 on fire (a RESET, not a subtraction like the
        # Fracker accumulator) -- even when the dump itself
        # fails, because Java resets the Interval on
        # timer() returning true, whatever dump() then
        # does. On fire it dumps 1 output item -- sand
        # (`public Item output = Items.sand;`,
        # WallCrafter.java:43, set explicitly by both defs,
        # `output = Items.sand;`, Blocks.java:3009/:3023)
        # -- through the shared dump(output) port
        # (SourceBuildingItemDumpState.dump_item_state):
        # `public boolean dump(Item todump){`
        # (BuildingComp.java:1072-1113), the todump branch
        # (`if(other.acceptItem(self(), todump) &&
        # canDump(other, todump)){` / `other.handleItem(
        # self(), todump);` / `items.remove(todump, 1);` /
        # `incrementDump(proximity.size);`), with the
        # cursor advancing once per neighbour checked
        # (`cdump = ((cdump + 1) % prox);`,
        # BuildingComp.java:1119). The tick accumulates
        # frame["timer_dump_elapsed"] by the tick delta
        # EVERY tick, unconditionally (mirroring Time.time,
        # which grows even while the gate is closed), and
        # AFTER the N2223 advance and the N2273 timerUse
        # consume (the Java order, :207-209 then :220-221)
        # checks the timer: on fire it dumps and persists
        # the items store and the cdump cursor back into
        # the frame. The two timers (use + dump) are
        # independent frame-local clocks.
        self.assertIn('static func source_wall_crafter_timer_dump_state', wall_crafter)
        self.assertIn('if(timer(timerDump, dumpTime / timeScale)){', wall_crafter)
        self.assertIn('dump(output);', wall_crafter)
        self.assertIn('public int dumpTime = 5;', wall_crafter)
        self.assertIn('protected final int timerDump = timers++;', wall_crafter)
        self.assertIn('public Item output = Items.sand;', wall_crafter)
        self.assertIn('output = Items.sand;', wall_crafter)
        self.assertIn('if(Float.isInfinite(time)) return false;', wall_crafter)
        self.assertIn('return timer.get(index, time);', wall_crafter)
        self.assertIn('public boolean dump(Item todump){', wall_crafter)
        self.assertIn('if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;', wall_crafter)
        self.assertIn('int dump = this.cdump;', wall_crafter)
        self.assertIn('var allItems = content.items();', wall_crafter)
        self.assertIn('int itemSize = allItems.size;', wall_crafter)
        self.assertIn('if(other.acceptItem(self(), todump) && canDump(other, todump)){', wall_crafter)
        self.assertIn('other.handleItem(self(), todump);', wall_crafter)
        self.assertIn('items.remove(todump, 1);', wall_crafter)
        self.assertIn('incrementDump(proximity.size);', wall_crafter)
        self.assertIn('public void incrementDump(int prox){', wall_crafter)
        self.assertIn('if(prox != 0){', wall_crafter)
        self.assertIn('cdump = ((cdump + 1) % prox);', wall_crafter)
        self.assertIn('public boolean canDump(Building to, Item item){', wall_crafter)
        self.assertIn('transient int cdump;', wall_crafter)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', wall_crafter)
        self.assertIn('hasItems = true;', wall_crafter)
        self.assertIn('public class WallCrafter extends Block{', wall_crafter)
        # The tick wiring: unconditional per-tick accumulate
        # of the frame-local dump clock (independent from
        # the timerUse clock); the dump interval const (5f,
        # Block.java:438, no def override); the shared
        # dump_item_state routing with the neighbour
        # acceptItem / canDump arrays as frame inputs
        # (default [] -- no neighbours, the Java
        # proximity.size == 0 outcome); on fire the items
        # store, the elapsed clock and the cdump cursor
        # persist back into the frame. The pure function
        # returns fired / elapsed_after / dumped /
        # items_after / cursor_after.
        self.assertIn('timer_dump_elapsed', wall_crafter)
        self.assertIn('timer_use_elapsed', wall_crafter)
        self.assertIn('SOURCE_WALL_CRAFTER_DUMP_TIME', wall_crafter)
        self.assertIn('dump_item_state', wall_crafter)
        self.assertIn('dump_neighbour_accepts', wall_crafter)
        self.assertIn('dump_neighbour_can_dump', wall_crafter)
        self.assertIn('frame["timer_dump_elapsed"] = dumped["elapsed_after"]', wall_crafter)
        self.assertIn('frame["items"] = dumped["items_after"]', wall_crafter)
        self.assertIn('frame["cdump"] = dumped["cursor_after"]', wall_crafter)
        self.assertIn('"fired"', wall_crafter)
        self.assertIn('"elapsed_after"', wall_crafter)
        self.assertIn('"dumped"', wall_crafter)
        self.assertIn('"items_after"', wall_crafter)
        self.assertIn('"cursor_after"', wall_crafter)
        self.assertIn('static func source_wall_crafter_tick_buildings_state', wall_crafter)
        # The proof's keys drive the pure timer-dump (fire
        # at the 5f/time_scale threshold, no fire below it,
        # no fire on a non-positive time_scale, the dump
        # removing exactly the output item, the cursor
        # advancing, no dump when the output is absent)
        # plus the live tick (the dump firing in the tick
        # after the advance, the two timers independent).
        # The scene file exists and the proof preloads
        # scripts that exist.
        proof = WALL_CRAFTER_TIMER_DUMP_PROOF.read_text(encoding='utf-8')
        for key in [
            'timer_fires_at_five_ticks',
            'timer_no_fire_below_threshold',
            'dump_removes_output_item',
            'dump_cursor_advances',
            'no_dump_when_output_absent',
            'live_tick_dumps_output',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertTrue(WALL_CRAFTER_TIMER_DUMP_PROOF_SCENE.exists())
        self.assertIn('SourceWallCrafterBuildState.gd', proof)

    def test_reference_graph_and_actual_c07_wall_crafter_timer_dump(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WallCrafterTimerDumpProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WALL_CRAFTER_TIMER_DUMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'timer_fires_at_five_ticks',
            'timer_no_fire_below_threshold',
            'dump_removes_output_item',
            'dump_cursor_advances',
            'no_dump_when_output_absent',
            'live_tick_dumps_output',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
