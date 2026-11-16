import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ACCELERATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceAcceleratorBuildState.gd'
ACCELERATOR_BATTERY_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorBatteryProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07AcceleratorBatteryTests(unittest.TestCase):
    def test_c07_accelerator_battery_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2218']['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_battery_state')
        # N2183 folded the CONSUMER-side read (power.status ->
        # efficiency) and deferred the BATTERY side: canLaunch
        # needs BOTH efficiency > 0f AND a full battery
        # (Accelerator.java:239-240, `power.graph.
        # getBatteryStored() >= powerBufferRequirement-0.00001f`,
        # powerBufferRequirement 1,000,000f, Blocks.java:6826),
        # and the powerBufferRequirement bar shows stored over
        # requirement (Accelerator.java:105-109, `() -> b.power.
        # graph.getBatteryStored() / powerBufferRequirement`).
        # The graph already computes the stored total
        # (runtime_state returns battery_stored; update_state
        # returns last_power_stored on both branches; the battery
        # distribution state sums battery.power.status * capacity
        # over enabled batteries, PowerGraph.java:123-132) -- but
        # no live tick frame stamps it: the graph update writes
        # frame["power_status"] back each tick (N2142) and never
        # writes frame["battery_stored"]. N2218 is the
        # accelerator's live battery read: the graph-update stamp
        # (the N2142 write-back pattern, extended to
        # battery_stored) + a pure battery read over the stamped
        # frame value + a driver tick line that stamps
        # battery_stored / battery_fraction / can_launch_battery
        # on the accelerator frame. The launch itself
        # (buildConfiguration consume() / useBatteries /
        # progress reset, Accelerator.java:258-291) waits for its
        # own slice, so this slice never drains stored power.
        # Three new result symbols: the stored total, the bar
        # fraction, and the canLaunch battery half-gate.
        self.assertEqual(
            ledger['N2218']['source_symbols'],
            [
                'source_accelerator_battery_state_result.battery_stored',
                'source_accelerator_battery_state_result.battery_fraction',
                'source_accelerator_battery_state_result.can_launch_battery',
            ],
        )
        for name in ledger['N2218']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/power/PowerGraph.java',
                    'core/src/mindustry/world/blocks/campaign/Accelerator.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_accelerator_battery_state_result.battery_stored': 'SourceAcceleratorBuildState.source_accelerator_battery_state',
                    'source_accelerator_battery_state_result.battery_fraction': 'SourceAcceleratorBuildState.source_accelerator_battery_state',
                    'source_accelerator_battery_state_result.can_launch_battery': 'SourceAcceleratorBuildState.source_accelerator_battery_state',
                }[name])
        self.assertEqual(ledger['N2218']['runtime_proof'], '/root/C07AcceleratorBattery')
        self.assertEqual(
            ledger['N2218']['tests'],
            [
                'test_c07_accelerator_battery_registration',
                'test_all_c07_accelerator_battery_input_evidence_is_exact',
                'test_accelerator_battery_state',
                'test_reference_graph_and_actual_c07_accelerator_battery',
            ],
        )
        self.assertTrue(ledger['N2218']['deferred_exprs'])

    def test_all_c07_accelerator_battery_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2218']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_accelerator_battery_state_result.battery_stored': 'SourceAcceleratorBuildState.source_accelerator_battery_state',
                    'source_accelerator_battery_state_result.battery_fraction': 'SourceAcceleratorBuildState.source_accelerator_battery_state',
                    'source_accelerator_battery_state_result.can_launch_battery': 'SourceAcceleratorBuildState.source_accelerator_battery_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/Accelerator.java',
            'core/src/mindustry/world/blocks/power/PowerGraph.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/modules/PowerModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2218']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_accelerator_battery_state(self):
        accelerator = ACCELERATOR_STATE.read_text(encoding='utf-8')
        # The pure battery read lives on the accelerator build
        # state: getBatteryStored (PowerGraph.java:123-132,
        # `public float getBatteryStored(){` with `float
        # totalAccumulator = 0f;` and `totalAccumulator +=
        # battery.power.status * battery.block.consPower.capacity;`
        # and `return totalAccumulator;`) sums the enabled
        # batteries' stored power, and Java records it each
        # update as lastPowerStored (PowerGraph.java update,
        # `lastPowerStored = getBatteryStored();`) before the
        # deficit/surplus branches use or charge the batteries --
        # so the stamped total is the graph's stored power as the
        # building reads it after the graph update. The canLaunch
        # battery half-gate (Accelerator.java:239, `public boolean
        # canLaunch(){` with Accelerator.java:240, `power.graph.
        # getBatteryStored() >= powerBufferRequirement-0.00001f`)
        # needs the stored total at the 1,000,000f requirement
        # (Blocks.java:6826, `powerBufferRequirement =
        # 1_000_000f;`), and the powerBufferRequirement bar
        # (Accelerator.java:105, `if(powerBufferRequirement >
        # 0f){` with Accelerator.java:106, `addBar(
        # "powerBufferRequirement", b -> new Bar(`) shows the
        # fraction (Accelerator.java:109, `() -> b.power.graph.
        # getBatteryStored() / powerBufferRequirement`). A frame
        # with no stamp reads 0.0 before the first graph update,
        # so the gate is false and the fraction is 0.0 until the
        # graph stamps the live total -- the same null-fold shape
        # as the N2183 power row. The launch itself consumes the
        # battery (Accelerator.java:270, `power.graph.
        # useBatteries(powerBufferRequirement);` with
        # PowerGraph.java:162, `public float useBatteries(float
        # needed){` and PowerGraph.java:163, `float stored =
        # getBatteryStored();`) -- the launch waits for its own
        # slice, so this read never drains stored power; the
        # drawSelect warning (Accelerator.java:265-268, `if(power.
        # graph.getBatteryStored() < powerBufferRequirement &&
        # !launching){`) is presentation and waits for its own
        # slice, but the gate value it compares is what this
        # slice stamps as can_launch_battery. The single def
        # carries `powerBufferRequirement = 1_000_000f;`
        # (Blocks.java:6826) against `consumePower(10f);`
        # (Blocks.java:6829).
        self.assertIn('public float getBatteryStored(){', accelerator)
        self.assertIn('float totalAccumulator = 0f;', accelerator)
        self.assertIn('totalAccumulator += battery.power.status * battery.block.consPower.capacity;', accelerator)
        self.assertIn('return totalAccumulator;', accelerator)
        self.assertIn('lastPowerStored = getBatteryStored();', accelerator)
        self.assertIn('power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f', accelerator)
        self.assertIn('() -> b.power.graph.getBatteryStored() / powerBufferRequirement', accelerator)
        self.assertIn('powerBufferRequirement = 1_000_000f;', accelerator)
        self.assertIn('public float useBatteries(float needed){', accelerator)
        self.assertIn('float stored = getBatteryStored();', accelerator)
        self.assertIn('power.graph.useBatteries(powerBufferRequirement);', accelerator)
        self.assertIn('SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT', accelerator)
        self.assertIn('static func source_accelerator_battery_state(frame: Dictionary, power_buffer_requirement: float) -> Dictionary:', accelerator)
        self.assertIn('stored >= power_buffer_requirement - 0.00001', accelerator)
        self.assertIn('stored / power_buffer_requirement', accelerator)
        self.assertIn('source_accelerator_battery_state(frame, SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT)', accelerator)
        self.assertIn('frame["battery_stored"]', accelerator)
        self.assertIn('frame["battery_fraction"]', accelerator)
        self.assertIn('frame["can_launch_battery"]', accelerator)
        # The graph-update stamp (N2142 write-back pattern,
        # extended to battery_stored): the placed graph state
        # writes the stored total onto each consumer frame, and
        # the factory runtime stamps it from the post-distribution
        # batteries (the used/charged statuses) with the
        # last_power_stored fallback on the cheat branch, where
        # the distribute state is empty and the stored total is
        # unchanged.
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_consumer_set_battery_stored_for_cell_state(game: Object, cell: Vector2i, stored: float) -> Dictionary:', placed_power_graph)
        self.assertIn('frame["battery_stored"] = stored', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_consumer_set_battery_stored_for_cell_state(game, consumer.get("origin_cell"), battery_stored_total)', factory_runtime)
        self.assertIn('battery_stored_total', factory_runtime)
        self.assertIn('update.get("last_power_stored", 0.0)', factory_runtime)
        # The proof's keys drive the pure read (half / full /
        # epsilon gate / below gate / absent-defaults-zero) plus
        # the live driver tick (the driver stamps the gate and
        # the fraction from a pre-stamped frame value). There are
        # no launch / drain keys: the launch
        # (Accelerator.java:258-291) and useBatteries
        # (Accelerator.java:270) wait for their own slice, so the
        # proof never spends the buffer; the graph-update stamp
        # itself is covered by the state test above plus the
        # battery binding tests, not by a live graph-update key.
        proof = ACCELERATOR_BATTERY_PROOF.read_text(encoding='utf-8')
        for key in [
            'battery_half',
            'battery_full',
            'battery_gate_epsilon',
            'battery_gate_below',
            'battery_absent_defaults_zero',
            'battery_live_tick_stamps_gate',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_accelerator_battery(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07AcceleratorBatteryProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ACCELERATOR_BATTERY_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'battery_half',
            'battery_full',
            'battery_gate_epsilon',
            'battery_gate_below',
            'battery_absent_defaults_zero',
            'battery_live_tick_stamps_gate',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
