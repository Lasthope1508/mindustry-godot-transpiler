import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PLACED_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'
ACCELERATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceAcceleratorBuildState.gd'
LAUNCH_DRAIN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorLaunchDrainProof.gd'
LAUNCH_DRAIN_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorLaunchDrainProof.tscn'


class C07AcceleratorLaunchDrainTests(unittest.TestCase):
    def test_c07_accelerator_launch_drain_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2354']['godot_owner'], 'SourcePlacedPowerGraphState.source_accelerator_take_launch_drain_request_for_cell_state')
        # The N2271 launch drains the frame battery total only
        # (new stored = stored - min(stored, requirement),
        # PowerGraph.java:154-167) and the N2342 stamp
        # overwrites frame battery_stored next tick, so the
        # drain was effectively refunded per battery: no
        # battery's stored power_status ever moved. N2354 is
        # the wiring that closes the loop -- NOT a new scaling
        # pure: the per-battery scaling already exists
        # Java-exact as SourcePowerGraphState.
        # use_batteries_state (SourcePowerGraphBatteryDistributionState.gd:107-143:
        # Mathf.equal zero guard, used = min(stored, needed),
        # percentage = min(1, needed / stored), enabled
        # batteries only, `battery.power.status *=
        # (1f-consumedPowerPercentage);`), already
        # SSOT-registered (power_graph_use_batteries.*), so a
        # second pure would be a synonym. What was missing:
        # (1) the driver writes a one-shot
        # frame["launch_drain_request"] = {requirement} on a
        # successful launch; (2) the runtime graph update
        # takes pending requests and applies the existing
        # use_batteries_state to the post-update batteries,
        # writing the scaled statuses back through the
        # existing battery setter -- before the N2342 stamp
        # recomputes the total, so the stamp reads the
        # drained total (no refund). The one new pure is the
        # take helper (the N2342 stamp precedent): it reads
        # AND clears the one-shot request from an accelerator
        # frame. Three new result symbols: requirement +
        # found + reason.
        self.assertEqual(
            ledger['N2354']['source_symbols'],
            [
                'source_accelerator_take_launch_drain_request_for_cell_state_result.requirement',
                'source_accelerator_take_launch_drain_request_for_cell_state_result.found',
                'source_accelerator_take_launch_drain_request_for_cell_state_result.reason',
            ],
        )
        for name in ledger['N2354']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_accelerator_take_launch_drain_request_for_cell_state_result.requirement': 'core/src/mindustry/world/blocks/power/PowerGraph.java',
                    'source_accelerator_take_launch_drain_request_for_cell_state_result.found': 'core/src/mindustry/world/blocks/campaign/Accelerator.java',
                    'source_accelerator_take_launch_drain_request_for_cell_state_result.reason': 'core/src/mindustry/world/blocks/power/PowerGraph.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], 'SourcePlacedPowerGraphState.source_accelerator_take_launch_drain_request_for_cell_state')
        self.assertEqual(ledger['N2354']['runtime_proof'], '/root/C07AcceleratorLaunchDrainProof')
        self.assertEqual(
            ledger['N2354']['tests'],
            [
                'test_c07_accelerator_launch_drain_registration',
                'test_all_c07_accelerator_launch_drain_input_evidence_is_exact',
                'test_accelerator_launch_drain_state',
                'test_reference_graph_and_actual_c07_accelerator_launch_drain',
            ],
        )
        self.assertTrue(ledger['N2354']['deferred_exprs'])
        # DEFERRED #326 is RESOLVED by this slice: the
        # launch-drain per-battery scaling is live (driver
        # request + runtime apply through the existing
        # use_batteries_state). Base 326 - 1 + 0 new = 325.
        self.assertFalse(any(entry.startswith('Accelerator launch-drain per-battery scaling (') for entry in ledger['N2354']['deferred_exprs']))
        self.assertEqual(len(ledger['N2354']['deferred_exprs']), 325)

    def test_all_c07_accelerator_launch_drain_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2354']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePlacedPowerGraphState.source_accelerator_take_launch_drain_request_for_cell_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/power/PowerGraph.java',
            'core/src/mindustry/world/blocks/campaign/Accelerator.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2354']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_accelerator_launch_drain_state(self):
        placed = PLACED_STATE.read_text(encoding='utf-8')
        runtime = FACTORY_RUNTIME.read_text(encoding='utf-8')
        accelerator = ACCELERATOR_STATE.read_text(encoding='utf-8')
        # The take helper lives on the placed graph state,
        # parallel to the N2342 stamp: it reads the one-shot
        # frame["launch_drain_request"] from an accelerator
        # frame ONLY (the source_accelerator_building meta
        # key), erases the key (one-shot consume -- the
        # runtime must never apply the same launch twice) and
        # writes the frame back with set_meta. A missing
        # sprite, a non-accelerator frame, a sprite with no
        # frame, or an accelerator frame with no pending
        # request all return found false with requirement 0.
        self.assertIn('static func source_accelerator_take_launch_drain_request_for_cell_state(game: Object, cell: Vector2i) -> Dictionary:', placed)
        self.assertIn('SOURCE_ACCELERATOR_BUILDING_META_KEY', placed)
        self.assertIn('frame["launch_drain_request"]', placed)
        self.assertIn('frame.erase("launch_drain_request")', placed)
        self.assertIn('"no_request"', placed)
        self.assertIn('public float useBatteries(float needed){', placed)
        self.assertIn('battery.power.status *= (1f-consumedPowerPercentage);', placed)
        self.assertIn('"requirement"', placed)
        self.assertIn('"found"', placed)
        # The driver writes the drain request on a successful
        # launch only (inside the canLaunch gate branch, next
        # to the N2271 frame writes): Java calls
        # useBatteries(powerBufferRequirement) inside the
        # `if(canLaunch()){` branch (Accelerator.java:264,
        # 270), so a failed gate leaves no request. The
        # requirement is the single-def 1,000,000f constant,
        # the same value the launch transition drains the
        # frame total by.
        self.assertIn('frame["launch_drain_request"] = {"requirement": SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT}', accelerator)
        self.assertIn('power.graph.useBatteries(powerBufferRequirement);', accelerator)
        self.assertIn('live since N2354', accelerator)
        # The runtime applies pending requests in the graph
        # update (SourceFactoryRuntimeState.gd,
        # source_factory_update_power_graph_state): it takes
        # each grouped consumer cell's request, drains the
        # post-update batteries through the EXISTING
        # use_batteries_state (no new scaling pure -- the
        # brief's proposed pure already exists Java-exact),
        # and copies the scaled statuses back into the
        # battery list in place, so the write-back loop below
        # stores them on the battery sprites and the N2342
        # stamp further below reads the drained total. On the
        # cheat branch the distribute state is empty, so the
        # top-level batteries are the source instead and the
        # scaled statuses are written back explicitly (the
        # loop below only covers updated_batteries).
        self.assertIn('source_accelerator_take_launch_drain_request_for_cell_state(game, consumer.get("origin_cell"))', runtime)
        self.assertIn('source_power_graph_state.use_batteries_state(drain_batteries, float(request.get("requirement", 0.0)))', runtime)
        self.assertIn('drain_batteries', runtime)
        self.assertIn('drain_is_cheat_branch', runtime)
        self.assertIn('source_battery_set_power_status_for_cell_state(game, battery.get("origin_cell"), float(battery.get("power_status", 0.0)))', runtime)
        # The drain block runs BEFORE the N2342 stamp call, so
        # the stamp recomputes its total from the drained
        # batteries (no refund). The graph update runs BEFORE
        # the driver ticks in simulate_factory, so a launch
        # at tick T drains at tick T+1 -- a documented 1-tick
        # delay, pinned here by the comment, not by a fake
        # same-tick claim.
        self.assertLess(runtime.index('use_batteries_state(drain_batteries'), runtime.index('source_accelerator_set_battery_stored_for_cell_state(game, consumer.get("origin_cell"), battery_stored)'))
        self.assertIn('1-tick delay', runtime)
        # The proof's keys drive the take helper (taken +
        # cleared, missing sprite, non-accelerator, no frame,
        # no pending request) and the scaling the runtime
        # applies (two batteries, 1.0 + 0.5 at equal capacity,
        # requirement 50% of the stored total: both scale by
        # x0.5, used + percentage pinned, disabled battery
        # untouched; stored == 0 drains nothing). The scene
        # file exists and the proof preloads scripts that
        # exist.
        proof = LAUNCH_DRAIN_PROOF.read_text(encoding='utf-8')
        for key in [
            'launch_drain_request_taken',
            'launch_drain_request_missing_sprite',
            'launch_drain_request_not_accelerator',
            'launch_drain_request_no_frame',
            'launch_drain_request_no_request',
            'launch_drain_scales_batteries_half',
            'launch_drain_zero_stored',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertTrue(LAUNCH_DRAIN_PROOF_SCENE.exists())
        self.assertIn('SourcePlacedPowerGraphState.gd', proof)
        self.assertIn('SourceAcceleratorBuildState.gd', proof)
        self.assertIn('SourcePowerGraphState.gd', proof)
        for preload in re.findall(r'preload\("(res://[^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload[len('res://'):]).is_file(), preload)
        scene = LAUNCH_DRAIN_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07AcceleratorLaunchDrainProof.gd', scene)

    def test_reference_graph_and_actual_c07_accelerator_launch_drain(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07AcceleratorLaunchDrainProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ACCELERATOR_LAUNCH_DRAIN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'launch_drain_request_taken',
            'launch_drain_request_missing_sprite',
            'launch_drain_request_not_accelerator',
            'launch_drain_request_no_frame',
            'launch_drain_request_no_request',
            'launch_drain_scales_batteries_half',
            'launch_drain_zero_stored',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
