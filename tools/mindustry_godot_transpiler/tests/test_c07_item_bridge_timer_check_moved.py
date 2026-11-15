import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceItemBridgeBuildState.gd'
ITEM_BRIDGE_TIMER_CHECK_MOVED_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeTimerCheckMovedProof.gd'
ITEM_BRIDGE_TIMER_CHECK_MOVED_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeTimerCheckMovedProof.tscn'


class C07ItemBridgeTimerCheckMovedTests(unittest.TestCase):
    def test_c07_item_bridge_timer_check_moved_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2321']['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_timer_check_moved_state')
        # N2225 ported the updateTile transport advance
        # (ItemBridgeBuild.updateTile(), ItemBridge.java:
        # 319-348, + updateTransport(), ItemBridge.java:
        # 355-368) in full -- the timeSpeed approachDelta
        # toward (wasMoved ? 1 : 0) at 1/60f (:326), time +=
        # timeSpeed * delta() (:328), the checkIncoming
        # prune (:330), the incoming registration (:339-344),
        # the warmup approach (:345), and updateTransport
        # (:355-368, moved = true on handoff, :361) -- but
        # the timerCheckMoved SNAPSHOT itself deferred (no
        # timer helper in the port): the advance read
        # was_moved/moved from the frame and returned moved
        # but never snapshotted moved into wasMoved, so
        # wasMoved stayed the frame input and the timeSpeed
        # approach read it as-is. N2321 is the snapshot: the
        # frame-local Interval-equivalent pure function
        # (TimerComp.timer, TimerComp.java:10-13, false on an
        # infinite time, else Interval.get, which resets
        # times[id] = Time.time on fire, arc Interval.java:
        # 20-26; Time.time counts TICKS, arc Time.java:69-80)
        # plus the tick wiring -- the frame clock frame[
        # "timer_check_moved_elapsed"] accumulates the tick
        # delta every enabled tick, and when it fires (30f)
        # was_moved takes the old moved and moved resets to
        # false, BEFORE the advance call (Java :320-323 runs
        # before the timeSpeed advance :326 and transport
        # :356). Three new result symbols: fired,
        # timer_elapsed_after, was_moved; moved is SHARED
        # with the N2225 transport symbol (same Java field,
        # same frame key -- the N2315 shared-ownership
        # precedent), so the ledger lists four symbols but
        # the registry grows by three.
        self.assertEqual(
            ledger['N2321']['source_symbols'],
            [
                'source_item_bridge_timer_check_moved_state_result.fired',
                'source_item_bridge_timer_check_moved_state_result.timer_elapsed_after',
                'source_item_bridge_timer_check_moved_state_result.was_moved',
                'source_item_bridge_update_transport_state_result.moved',
            ],
        )
        for name in ledger['N2321']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/TimerComp.java',
                    'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_bridge_timer_check_moved_state_result.fired': 'SourceItemBridgeBuildState.source_item_bridge_timer_check_moved_state',
                    'source_item_bridge_timer_check_moved_state_result.timer_elapsed_after': 'SourceItemBridgeBuildState.source_item_bridge_timer_check_moved_state',
                    'source_item_bridge_timer_check_moved_state_result.was_moved': 'SourceItemBridgeBuildState.source_item_bridge_timer_check_moved_state',
                    'source_item_bridge_update_transport_state_result.moved': 'SourceItemBridgeBuildState.source_item_bridge_update_transport_state',
                }[name])
        self.assertEqual(ledger['N2321']['runtime_proof'], '/root/C07ItemBridgeTimerCheckMovedProof')
        self.assertEqual(
            ledger['N2321']['tests'],
            [
                'test_c07_item_bridge_timer_check_moved_registration',
                'test_all_c07_item_bridge_timer_check_moved_input_evidence_is_exact',
                'test_item_bridge_timer_check_moved_state',
                'test_reference_graph_and_actual_c07_item_bridge_timer_check_moved',
            ],
        )
        self.assertTrue(ledger['N2321']['deferred_exprs'])
        # The snapshot entry is resolved by this slice; the
        # first-fire deviation joins as a new entry. The
        # LiquidBridge inherited-steps entry stays: it
        # mentions the timer snapshot, but it belongs to the
        # LiquidBridge driver, which still does not wire it.
        self.assertFalse(any(entry.startswith('ItemBridge timerCheckMoved / wasMoved snapshot (') for entry in ledger['N2321']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge timerCheckMoved first-fire deviation (') for entry in ledger['N2321']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge inherited updateTile steps (') for entry in ledger['N2321']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge checkAccept facing (') for entry in ledger['N2321']['deferred_exprs']))

    def test_all_c07_item_bridge_timer_check_moved_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2321']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_bridge_timer_check_moved_state_result.fired': 'SourceItemBridgeBuildState.source_item_bridge_timer_check_moved_state',
                    'source_item_bridge_timer_check_moved_state_result.timer_elapsed_after': 'SourceItemBridgeBuildState.source_item_bridge_timer_check_moved_state',
                    'source_item_bridge_timer_check_moved_state_result.was_moved': 'SourceItemBridgeBuildState.source_item_bridge_timer_check_moved_state',
                    'source_item_bridge_update_transport_state_result.moved': 'SourceItemBridgeBuildState.source_item_bridge_update_transport_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The Interval.get / check / Time.time formulas live in
        # Arc, not Mindustry: Interval.java and Time.java under
        # arc-upstream (the N2280 precedent).
        upstream['arc-core/src/arc/util/Interval.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Interval.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/util/Time.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Time.java').read_text(encoding='utf-8')
        for expr in ledger['N2321']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_bridge_timer_check_moved_state(self):
        item_bridge = ITEM_BRIDGE_STATE.read_text(encoding='utf-8')
        # The pure timer-check-moved function is the
        # frame-local Interval-equivalent (TimerComp.timer,
        # TimerComp.java:10-13: `if(Float.isInfinite(time))
        # return false;` / `return timer.get(index, time);`;
        # Interval.get resets times[id] = Time.time on fire,
        # Interval.java:20-26; check compares Time.time -
        # times[id] >= time, Interval.java:28-30; Time.time
        # counts TICKS, Time.java:69-80): elapsed +=
        # source_delta unconditionally (source_delta is the
        # UNSCALED Time.delta in ticks, so the frame clock
        # mirrors the global Time.time); fired = elapsed >=
        # duration (the LITERAL duration -- Java passes a
        # literal 30f, ItemBridge.java:320, with NO timeScale
        # division, the N2290 literal-20 lesson); a
        # non-positive time_scale is a defensive guard (fired
        # false -- the clock still accumulates);
        # timer_elapsed_after resets to 0.0 on fire (a RESET,
        # not a subtraction like the Fracker accumulator).
        # When the timer fires the snapshot runs:
        # was_moved = the OLD moved, moved = false
        # (ItemBridge.java:321-322); when it does not fire
        # both keep their values. The Java call is
        # `if(timer(timerCheckMoved, 30f)){` (ItemBridge.java:
        # 320-323) with `public final int timerCheckMoved =
        # timers ++;` (:25) and `public boolean wasMoved,
        # moved, hadValidLink;` (:202). The snapshot runs
        # BEFORE the timeSpeed advance (:326) and transport
        # (:356), so the driver runs the timer pure BEFORE
        # the N2225 advance call and stamps frame["was_moved"]
        # / frame["moved"] / frame["timer_check_moved_elapsed"]
        # from its result; a moved=true the advance sets this
        # tick (handoff, :361) survives until the next
        # snapshot fire.
        self.assertIn('static func source_item_bridge_timer_check_moved_state', item_bridge)
        self.assertIn('if(timer(timerCheckMoved, 30f)){', item_bridge)
        self.assertIn('wasMoved = moved;', item_bridge)
        self.assertIn('moved = false;', item_bridge)
        self.assertIn('public final int timerCheckMoved = timers ++;', item_bridge)
        self.assertIn('public boolean wasMoved, moved, hadValidLink;', item_bridge)
        self.assertIn('timeSpeed = Mathf.approachDelta(timeSpeed, wasMoved ? 1f : 0f, 1f / 60f);', item_bridge)
        self.assertIn('moved = true;', item_bridge)
        self.assertIn('if(Float.isInfinite(time)) return false;', item_bridge)
        self.assertIn('return timer.get(index, time);', item_bridge)
        self.assertIn('boolean got = check(id, time);', item_bridge)
        self.assertIn('if(got) times[id] = Time.time;', item_bridge)
        self.assertIn('return Time.time - times[id] >= time || Time.time < times[id];', item_bridge)
        self.assertIn('timeRaw += delta;', item_bridge)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', item_bridge)
        self.assertIn('SOURCE_ITEM_BRIDGE_TIMER_CHECK_MOVED_DURATION := 30.0', item_bridge)
        self.assertIn('"fired"', item_bridge)
        self.assertIn('"timer_elapsed_after"', item_bridge)
        self.assertIn('"was_moved"', item_bridge)
        # The threshold is the literal duration -- no
        # timeScale division anywhere in the pure (the N2290
        # lesson: Java passes a literal 30f, unlike the dump
        # timers that divide by timeScale).
        self.assertIn('INF if time_scale <= 0.0 else duration', item_bridge)
        self.assertNotIn('duration / time_scale', item_bridge)
        # The tick wiring: the timer call with the frame clock
        # + snapshot inputs + tick delta + live time scale +
        # 30f duration runs BEFORE the advance call; the
        # snapshot stamps the frame so the advance reads the
        # already-snapshotted values.
        self.assertIn('source_item_bridge_timer_check_moved_state(float(frame.get("timer_check_moved_elapsed", 0.0)), bool(frame.get("was_moved", false)), bool(frame.get("moved", false)), source_delta, time_scale, SOURCE_ITEM_BRIDGE_TIMER_CHECK_MOVED_DURATION)', item_bridge)
        self.assertIn('frame["timer_check_moved_elapsed"] = timer_snapshot["timer_elapsed_after"]', item_bridge)
        self.assertIn('frame["was_moved"] = timer_snapshot["was_moved"]', item_bridge)
        self.assertIn('frame["moved"] = timer_snapshot["moved"]', item_bridge)
        # The snapshot-before-advance order: the timer call
        # precedes the advance call in the tick body.
        self.assertLess(item_bridge.index('source_item_bridge_timer_check_moved_state(float(frame.get("timer_check_moved_elapsed"'), item_bridge.index('source_item_bridge_update_transport_state(frame, source_delta, time_scale'))
        # The N2225-pinned advance call text is UNCHANGED --
        # the snapshot rides the frame, not a new parameter.
        self.assertIn('source_item_bridge_update_transport_state(frame, source_delta, time_scale, SOURCE_ITEM_BRIDGE_TRANSPORT_TIME, SOURCE_ITEM_BRIDGE_ITEM_CAPACITY, bool(frame.get("had_valid_link", false)), this_pos, partner, incoming_valid, item_order)', item_bridge)
        # The documented limits now record the snapshot as
        # live (N2321) with the first-fire deviation noted;
        # the old "still defers (no timer infra)" claim is
        # gone. The N2225 transport advance, the N2288
        # doDump, and the N2188 gate are preserved.
        self.assertIn('timerCheckMoved snapshot live (N2321)', item_bridge)
        self.assertNotIn('still defers (no timer infra)', item_bridge)
        self.assertIn('updateTile transport advance live (N2225)', item_bridge)
        self.assertIn('doDump live (N2288)', item_bridge)
        self.assertIn('shouldConsume gate LIVE (N2188)', item_bridge)
        # The proof's keys drive the pure timer (fire at 30
        # ticks, no fire below the threshold, no fire on a
        # non-positive time_scale, the snapshot copying moved
        # into was_moved and clearing moved on fire) plus the
        # live tick (the snapshot runs before the advance, so
        # timeSpeed advances on the snapshotted was_moved).
        proof = ITEM_BRIDGE_TIMER_CHECK_MOVED_PROOF.read_text(encoding='utf-8')
        for key in [
            'timer_fires_at_thirty_ticks',
            'timer_no_fire_below_threshold',
            'timer_no_fire_when_time_scale_zero',
            'snapshot_copies_moved_to_was_moved',
            'snapshot_clears_moved_on_fire',
            'live_tick_snapshots_before_advance',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The literal-30 threshold pin (the N2290 lesson): at
        # time_scale 2.0 the threshold is still 30, so 29 + 1
        # fires and 9 + 1 does NOT fire early.
        self.assertIn('timer.call(29.0, false, true, 1.0, 2.0, duration)', proof)
        self.assertIn('timer.call(9.0, false, true, 1.0, 2.0, duration)', proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceItemBridgeBuildState.gd")', proof)
        self.assertIn('item_bridge_build_state.source_item_bridge_timer_check_moved_state(', proof)
        self.assertIn('item_bridge_build_state.source_item_bridge_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(ITEM_BRIDGE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = ITEM_BRIDGE_TIMER_CHECK_MOVED_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ItemBridgeTimerCheckMovedProof.gd', scene)
        self.assertIn('C07ItemBridgeTimerCheckMovedProof', scene)

    def test_reference_graph_and_actual_c07_item_bridge_timer_check_moved(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemBridgeTimerCheckMovedProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_BRIDGE_TIMER_CHECK_MOVED_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'timer_fires_at_thirty_ticks',
            'timer_no_fire_below_threshold',
            'timer_no_fire_when_time_scale_zero',
            'snapshot_copies_moved_to_was_moved',
            'snapshot_clears_moved_on_fire',
            'live_tick_snapshots_before_advance',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
