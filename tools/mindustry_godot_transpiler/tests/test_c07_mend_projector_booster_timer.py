import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MEND_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceMendProjectorBuildState.gd'
MEND_PROJECTOR_BOOSTER_TIMER_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorBoosterTimerProof.gd'
MEND_PROJECTOR_BOOSTER_TIMER_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorBoosterTimerProof.tscn'


class C07MendProjectorBoosterTimerTests(unittest.TestCase):
    def test_c07_mend_projector_booster_timer_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2269']['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_timer_use_state')
        # N2263 folded the booster item rows (mender silicon,
        # mend-projector phaseFabric) into the optional pass,
        # but nothing ever consumed them: the timer-gated
        # consume() (`if(optionalEfficiency > 0 && timer(
        # timerUse, useTime / timeScale) && canHeal){`,
        # MendProjector.java:102, `public float useTime =
        # 400f;`, MendProjector.java:31) stayed deferred, so a
        # mend projector kept its booster item forever and
        # optionalEfficiency never dropped. N2269 is the
        # timer-gated consume: the frame-local Interval-
        # equivalent pure function (TimerComp.timer,
        # TimerComp.java:10-13, false on an infinite time,
        # else Interval.get, which resets times[id] =
        # Time.time on fire, Interval.java:20-26; Time.time
        # counts TICKS, Time.java:69-80) plus the tick wiring
        # between the advance and the heal scan (Java order,
        # MendProjector.java:102-104 before :106+): when the
        # folded optionalEfficiency is positive and the timer
        # fires and canHeal holds (`boolean canHeal =
        # !checkSuppression();`, MendProjector.java:94; the
        # driver keeps the documented can_heal=true default,
        # suppression untracked, the N2184 precedent),
        # consume() removes 1 booster item per def
        # (ConsumeItems.trigger, ConsumeItems.java:44-48,
        # clamped by ItemModule.remove, ItemModule.java:
        # 258-263) and the elapsed clock resets to 0. Three
        # new result symbols: fired, elapsed_after, threshold.
        self.assertEqual(
            ledger['N2269']['source_symbols'],
            [
                'source_mend_projector_timer_use_state_result.fired',
                'source_mend_projector_timer_use_state_result.elapsed_after',
                'source_mend_projector_timer_use_state_result.threshold',
            ],
        )
        for name in ledger['N2269']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/TimerComp.java',
                    'core/src/mindustry/world/blocks/defense/MendProjector.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_mend_projector_timer_use_state_result.fired': 'SourceMendProjectorBuildState.source_mend_projector_timer_use_state',
                    'source_mend_projector_timer_use_state_result.elapsed_after': 'SourceMendProjectorBuildState.source_mend_projector_timer_use_state',
                    'source_mend_projector_timer_use_state_result.threshold': 'SourceMendProjectorBuildState.source_mend_projector_timer_use_state',
                }[name])
        self.assertEqual(ledger['N2269']['runtime_proof'], '/root/C07MendProjectorBoosterTimerProof')
        self.assertEqual(
            ledger['N2269']['tests'],
            [
                'test_c07_mend_projector_booster_timer_registration',
                'test_all_c07_mend_projector_booster_timer_input_evidence_is_exact',
                'test_mend_projector_booster_timer_state',
                'test_reference_graph_and_actual_c07_mend_projector_booster_timer',
            ],
        )
        self.assertTrue(ledger['N2269']['deferred_exprs'])

    def test_all_c07_mend_projector_booster_timer_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2269']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_mend_projector_timer_use_state_result.fired': 'SourceMendProjectorBuildState.source_mend_projector_timer_use_state',
                    'source_mend_projector_timer_use_state_result.elapsed_after': 'SourceMendProjectorBuildState.source_mend_projector_timer_use_state',
                    'source_mend_projector_timer_use_state_result.threshold': 'SourceMendProjectorBuildState.source_mend_projector_timer_use_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/MendProjector.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2269']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mend_projector_booster_timer_state(self):
        mend_projector = MEND_PROJECTOR_STATE.read_text(encoding='utf-8')
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
        # fires at once when the gate reopens), and between
        # the advance and the heal scan (Java order,
        # MendProjector.java:102-104 before :106+) checks
        # `if(optionalEfficiency > 0 && timer(timerUse,
        # useTime / timeScale) && canHeal){` (MendProjector.
        # java:102, `public float useTime = 400f;`,
        # MendProjector.java:31, no def overrides it):
        # consume() removes 1 booster item per def (mender
        # silicon, mend-projector phaseFabric, Blocks.java:
        # 1929/1941; consumeItem(item) is a stack of 1,
        # Block.java:1167-1168; ConsumeItems.trigger,
        # ConsumeItems.java:44-48, clamped by ItemModule.
        # remove, ItemModule.java:258-263) and resets the
        # elapsed clock to 0.0. canHeal keeps the documented
        # default true (suppression untracked, the N2184
        # precedent). No row is added: the fold is live since
        # N2263. The advance and heal scan functions are
        # untouched.
        self.assertIn('static func source_mend_projector_timer_use_state', mend_projector)
        self.assertIn('if(optionalEfficiency > 0 && timer(timerUse, useTime / timeScale) && canHeal){', mend_projector)
        self.assertIn('public float useTime = 400f;', mend_projector)
        self.assertIn('boolean canHeal = !checkSuppression();', mend_projector)
        self.assertIn('if(Float.isInfinite(time)) return false;', mend_projector)
        self.assertIn('return timer.get(index, time);', mend_projector)
        self.assertIn('consumeItem(Items.silicon).boost();', mend_projector)
        self.assertIn('consumeItem(Items.phaseFabric).boost();', mend_projector)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', mend_projector)
        self.assertIn('amount = Math.min(amount, items[item.id]);', mend_projector)
        self.assertIn('for(Consume cons : block.consumers){', mend_projector)
        self.assertIn('cons.trigger(self());', mend_projector)
        self.assertIn('public ConsumeItems consumeItem(Item item){', mend_projector)
        self.assertIn('return consumeItem(item, 1);', mend_projector)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', mend_projector)
        # The tick wiring: unconditional per-tick accumulate
        # of the frame-local clock; the 400f useTime duration;
        # the optional-efficiency gate read from the frame;
        # DIRECT removal through the shared inventory helper
        # (clamped to the held count) over the N2263 per-def
        # stacks; the elapsed reset to 0.0 on fire. The pure
        # function returns fired / elapsed_after / threshold.
        self.assertIn('timer_use_elapsed', mend_projector)
        self.assertIn('frame["timer_use_elapsed"] = 0.0', mend_projector)
        self.assertIn('400.0', mend_projector)
        self.assertIn('float(frame.get("optional_efficiency", 0.0)) > 0.0', mend_projector)
        self.assertIn('remove_item_state', mend_projector)
        self.assertIn('_mend_projector_booster_stacks_for_block(block_id)', mend_projector)
        self.assertIn('"fired"', mend_projector)
        self.assertIn('"elapsed_after"', mend_projector)
        self.assertIn('"threshold"', mend_projector)
        self.assertIn('static func source_mend_projector_tick_buildings_state', mend_projector)
        # The proof's keys drive the pure timer (fire at the
        # 400/timeScale threshold, no fire below it, no fire
        # on a non-positive time_scale) plus the live tick
        # (the optional gate, the per-def removal, the
        # elapsed reset). The scene file exists and the proof
        # preloads scripts that exist.
        proof = MEND_PROJECTOR_BOOSTER_TIMER_PROOF.read_text(encoding='utf-8')
        for key in [
            'timer_fires_at_use_time',
            'timer_no_fire_below_threshold',
            'timer_requires_positive_optional',
            'timer_consume_removes_booster_item',
            'timer_uses_per_def_stack',
            'timer_no_fire_when_time_scale_zero',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertTrue(MEND_PROJECTOR_BOOSTER_TIMER_PROOF_SCENE.exists())
        self.assertIn('SourceMendProjectorBuildState.gd', proof)

    def test_reference_graph_and_actual_c07_mend_projector_booster_timer(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MendProjectorBoosterTimerProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MEND_PROJECTOR_BOOSTER_TIMER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'timer_fires_at_use_time',
            'timer_no_fire_below_threshold',
            'timer_requires_positive_optional',
            'timer_consume_removes_booster_item',
            'timer_uses_per_def_stack',
            'timer_no_fire_when_time_scale_zero',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
