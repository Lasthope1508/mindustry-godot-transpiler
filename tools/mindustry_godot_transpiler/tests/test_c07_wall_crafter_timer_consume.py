import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WALL_CRAFTER_STATE = ROOT / 'godot-mindustry/src/game/SourceWallCrafterBuildState.gd'
WALL_CRAFTER_TIMER_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterTimerConsumeProof.gd'
WALL_CRAFTER_TIMER_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterTimerConsumeProof.tscn'


class C07WallCrafterTimerConsumeTests(unittest.TestCase):
    def test_c07_wall_crafter_timer_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2273']['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_timer_use_state')
        # N2264 folded the graphite booster row (large-cliff-
        # crusher `itemConsumer = consumeItem(Items.graphite).
        # boost();`, Blocks.java:3030) into the optional pass,
        # but nothing ever consumed it: the timer-gated
        # consume() (`if(itemValid && eff * efficiency > 0 &&
        # timer(timerUse, boostItemUseTime / timeScale)){`,
        # WallCrafter.java:207-209, `public float
        # boostItemUseTime = 120f;`, WallCrafter.java:45,
        # overridden to `boostItemUseTime = 60f / 0.75f;` =
        # 80f by the large def, Blocks.java:3032) stayed
        # deferred, so a large-cliff-crusher kept its
        # graphite forever. N2273 is the timer-gated
        # consume: the frame-local Interval-equivalent pure
        # function (TimerComp.timer, TimerComp.java:10-13,
        # false on an infinite time, else Interval.get,
        # which resets times[id] = Time.time on fire,
        # Interval.java:20-26; Time.time counts TICKS,
        # Time.java:69-80) plus the tick wiring after the
        # N2223 advance: when item_valid holds and eff *
        # efficiency is positive (eff read from the advance
        # return dict, the advance itself untouched) and the
        # timer fires at the per-def boostItemUseTime,
        # consume() removes 1 graphite (ConsumeItems.trigger,
        # ConsumeItems.java:44-48, clamped by ItemModule.
        # remove, ItemModule.java:258-263) and the elapsed
        # clock resets to 0.0. The cliff-crusher has no
        # booster item, so its timer never fires consume
        # (itemValid is always false). Three new result
        # symbols: fired, elapsed_after, threshold.
        self.assertEqual(
            ledger['N2273']['source_symbols'],
            [
                'source_wall_crafter_timer_use_state_result.fired',
                'source_wall_crafter_timer_use_state_result.elapsed_after',
                'source_wall_crafter_timer_use_state_result.threshold',
            ],
        )
        for name in ledger['N2273']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/TimerComp.java',
                    'core/src/mindustry/world/blocks/production/WallCrafter.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_wall_crafter_timer_use_state_result.fired': 'SourceWallCrafterBuildState.source_wall_crafter_timer_use_state',
                    'source_wall_crafter_timer_use_state_result.elapsed_after': 'SourceWallCrafterBuildState.source_wall_crafter_timer_use_state',
                    'source_wall_crafter_timer_use_state_result.threshold': 'SourceWallCrafterBuildState.source_wall_crafter_timer_use_state',
                }[name])
        self.assertEqual(ledger['N2273']['runtime_proof'], '/root/C07WallCrafterTimerConsumeProof')
        self.assertEqual(
            ledger['N2273']['tests'],
            [
                'test_c07_wall_crafter_timer_consume_registration',
                'test_all_c07_wall_crafter_timer_consume_input_evidence_is_exact',
                'test_wall_crafter_timer_consume_state',
                'test_reference_graph_and_actual_c07_wall_crafter_timer_consume',
            ],
        )
        self.assertTrue(ledger['N2273']['deferred_exprs'])

    def test_all_c07_wall_crafter_timer_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2273']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_wall_crafter_timer_use_state_result.fired': 'SourceWallCrafterBuildState.source_wall_crafter_timer_use_state',
                    'source_wall_crafter_timer_use_state_result.elapsed_after': 'SourceWallCrafterBuildState.source_wall_crafter_timer_use_state',
                    'source_wall_crafter_timer_use_state_result.threshold': 'SourceWallCrafterBuildState.source_wall_crafter_timer_use_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/WallCrafter.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2273']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wall_crafter_timer_consume_state(self):
        wall_crafter = WALL_CRAFTER_STATE.read_text(encoding='utf-8')
        # The pure timer-use function is the frame-local
        # Interval-equivalent (TimerComp.timer, TimerComp.
        # java:10-13: `if(Float.isInfinite(time)) return
        # false;` / `return timer.get(index, time);`; Interval.
        # get resets times[id] = Time.time on fire, Interval.
        # java:20-26; Time.time counts TICKS, Time.java:69-80):
        # threshold = duration / time_scale; a non-positive
        # time_scale is the infinite-time branch (fired
        # false); fired = elapsed >= threshold; elapsed_after
        # resets to 0.0 on fire (a RESET, not a subtraction
        # like the Fracker accumulator). The tick accumulates
        # frame["timer_use_elapsed"] by the tick delta EVERY
        # tick, unconditionally (mirroring Time.time, which
        # grows even while the gate is closed -- so the timer
        # fires at once when the gate reopens), and AFTER the
        # N2223 advance checks `if(itemValid && eff *
        # efficiency > 0 && timer(timerUse, boostItemUseTime
        # / timeScale)){` (WallCrafter.java:207-209,
        # `public float boostItemUseTime = 120f;`,
        # WallCrafter.java:45; the large def overrides it to
        # `boostItemUseTime = 60f / 0.75f;` = 80f,
        # Blocks.java:3032): consume() removes 1 graphite
        # (large def only, `itemConsumer = consumeItem(Items.
        # graphite).boost();`, Blocks.java:3030; consumeItem
        # (item) is a stack of 1, Block.java:1167-1168;
        # ConsumeItems.trigger, ConsumeItems.java:44-48,
        # clamped by ItemModule.remove, ItemModule.java:
        # 258-263) and resets the elapsed clock to 0.0. The
        # cliff-crusher has no booster item, so nothing is
        # removed for it. Java order is consume (:207-209)
        # BEFORE lastEfficiency/offload (:211-215), but
        # consume only removes 1 graphite (booster) -- it
        # does not affect the offload (output item) or this
        # tick's eff (which uses the pre-tick item_valid) --
        # so the post-advance check is order-equivalent for
        # this tick. No row is added: the fold is live since
        # N2264. The advance function is untouched: eff is
        # read from its return dict.
        self.assertIn('static func source_wall_crafter_timer_use_state', wall_crafter)
        self.assertIn('if(itemValid && eff * efficiency > 0 && timer(timerUse, boostItemUseTime / timeScale)){', wall_crafter)
        self.assertIn('public float boostItemUseTime = 120f;', wall_crafter)
        self.assertIn('boostItemUseTime = 60f / 0.75f;', wall_crafter)
        self.assertIn('boolean itemValid = itemConsumer != null && itemConsumer.efficiency(this) > 0;', wall_crafter)
        self.assertIn('if(Float.isInfinite(time)) return false;', wall_crafter)
        self.assertIn('return timer.get(index, time);', wall_crafter)
        self.assertIn('itemConsumer = consumeItem(Items.graphite).boost();', wall_crafter)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', wall_crafter)
        self.assertIn('amount = Math.min(amount, items[item.id]);', wall_crafter)
        self.assertIn('for(Consume cons : block.consumers){', wall_crafter)
        self.assertIn('cons.trigger(self());', wall_crafter)
        self.assertIn('public ConsumeItems consumeItem(Item item){', wall_crafter)
        self.assertIn('return consumeItem(item, 1);', wall_crafter)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', wall_crafter)
        self.assertIn('public class WallCrafter extends Block{', wall_crafter)
        # The tick wiring: unconditional per-tick accumulate
        # of the frame-local clock; the per-def duration
        # (class default 120f, large def 60f/0.75f = 80f);
        # eff read from the advance return dict (the advance
        # itself untouched); DIRECT removal through the
        # shared inventory helper (clamped to the held count)
        # of the N2264 booster item (graphite on the large
        # def, none on the cliff-crusher); the elapsed reset
        # to 0.0 on fire. The pure function returns fired /
        # elapsed_after / threshold.
        self.assertIn('timer_use_elapsed', wall_crafter)
        self.assertIn('frame["timer_use_elapsed"] = 0.0', wall_crafter)
        self.assertIn('SOURCE_WALL_CRAFTER_BOOST_ITEM_USE_TIME_DEFAULT', wall_crafter)
        self.assertIn('60.0 / 0.75', wall_crafter)
        self.assertIn('_wall_crafter_boost_item_use_time_for_block', wall_crafter)
        self.assertIn('advanced.get("eff", 0.0)', wall_crafter)
        self.assertIn('remove_item_state', wall_crafter)
        self.assertIn('"fired"', wall_crafter)
        self.assertIn('"elapsed_after"', wall_crafter)
        self.assertIn('"threshold"', wall_crafter)
        self.assertIn('static func source_wall_crafter_tick_buildings_state', wall_crafter)
        # The proof's keys drive the pure timer (fire at the
        # per-def boostItemUseTime threshold, no fire below
        # it, no fire on a non-positive time_scale) plus the
        # live tick (the item_valid + positive eff gate, the
        # graphite removal on the large def, no removal on
        # the cliff-crusher, the elapsed reset). The scene
        # file exists and the proof preloads scripts that
        # exist.
        proof = WALL_CRAFTER_TIMER_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'timer_fires_at_use_time',
            'timer_no_fire_below_threshold',
            'timer_requires_item_valid_and_positive_eff',
            'timer_consume_removes_graphite',
            'timer_no_item_for_cliff_crusher',
            'timer_no_fire_when_time_scale_zero',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertTrue(WALL_CRAFTER_TIMER_CONSUME_PROOF_SCENE.exists())
        self.assertIn('SourceWallCrafterBuildState.gd', proof)

    def test_reference_graph_and_actual_c07_wall_crafter_timer_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WallCrafterTimerConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WALL_CRAFTER_TIMER_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'timer_fires_at_use_time',
            'timer_no_fire_below_threshold',
            'timer_requires_item_valid_and_positive_eff',
            'timer_consume_removes_graphite',
            'timer_no_item_for_cliff_crusher',
            'timer_no_fire_when_time_scale_zero',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
