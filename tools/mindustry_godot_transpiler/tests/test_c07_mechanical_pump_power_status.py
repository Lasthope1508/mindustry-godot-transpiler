import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MECHANICAL_PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceMechanicalPumpBuildState.gd'
MECHANICAL_PUMP_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MechanicalPumpPowerStatusProof.gd'


class C07MechanicalPumpPowerStatusTests(unittest.TestCase):
    def test_c07_mechanical_pump_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2154']['godot_owner'], 'SourceMechanicalPumpBuildState.source_mechanical_pump_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153 proved the pure power-row
        # pattern on the factory, adjacent-factory, drill, turret,
        # burst-drill, solid-pump, point-defense, tractor-beam and
        # fracker drivers -- but the pump runtime
        # (SourcePumpRuntimeState.gd) ticks only the scenario
        # mechanical pump at PUMP_POS with efficiency hardcoded 1.0
        # ("consumes no power"), and placed rotary-pump
        # (consumePower 0.3f) / impulse-pump (consumePower 1.3f)
        # have NO placed-buildings driver at all, so they would
        # pump as if power.status were 1.0. N2154 is the Pump
        # family's live read: a new mechanical-pump driver with a
        # pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) and the pump accumulator fold
        # (Pump.java:162) follows it. The scenario mechanical-pump
        # (no consumePower, Blocks.java:2298-2302) is naturally
        # excluded by the driver gate
        # (block.properties.has("consumePower")). Two new result
        # symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2154']['source_symbols'],
            [
                'source_mechanical_pump_power_status_row_state_result.row',
                'source_mechanical_pump_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2154']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_mechanical_pump_power_status_row_state_result.row': 'SourceMechanicalPumpBuildState.source_mechanical_pump_power_status_row_state',
                    'source_mechanical_pump_power_status_row_state_result.has_power_row': 'SourceMechanicalPumpBuildState.source_mechanical_pump_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2154']['runtime_proof'], '/root/C07MechanicalPumpPowerStatusProof')
        self.assertEqual(
            ledger['N2154']['tests'],
            [
                'test_c07_mechanical_pump_power_status_registration',
                'test_all_c07_mechanical_pump_power_status_input_evidence_is_exact',
                'test_mechanical_pump_power_status_row_state',
                'test_reference_graph_and_actual_c07_mechanical_pump_power_status',
            ],
        )
        self.assertTrue(ledger['N2154']['deferred_exprs'])

    def test_all_c07_mechanical_pump_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2154']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_mechanical_pump_power_status_row_state_result.row': 'SourceMechanicalPumpBuildState.source_mechanical_pump_power_status_row_state',
                    'source_mechanical_pump_power_status_row_state_result.has_power_row': 'SourceMechanicalPumpBuildState.source_mechanical_pump_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/production/Pump.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2154']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mechanical_pump_power_status_row_state(self):
        pump = MECHANICAL_PUMP_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the mechanical-pump build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_mechanical_pump_power_status_row_state', pump)
        self.assertIn('return build.power.status;', pump)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', pump)
        # The tick driver folds the row into the first pass when the
        # block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the rotary-pump
        # (0.3f) and impulse-pump (1.3f) power consumers count
        # toward hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The pump accumulator follows
        # the folded efficiency (Pump.java:161, `if(efficiency > 0
        # && liquidDrop != null){` -- keep on ONE comment line,
        # the N2148 shootWarmup lesson: a split line fails this
        # test), and the maxPump fold (Pump.java:162, `float
        # maxPump = Math.min(liquidCapacity - liquids.get(
        # liquidDrop), amount * pumpAmount * edelta());`).
        self.assertIn('"is_power": true', pump)
        self.assertIn('block.properties.has("consumePower")', pump)
        self.assertIn('hasConsumers = consumers.length > 0;', pump)
        self.assertIn('if(efficiency > 0 && liquidDrop != null){', pump)
        self.assertIn('float maxPump = Math.min(liquidCapacity - liquids.get(liquidDrop), amount * pumpAmount * edelta());', pump)
        self.assertIn('static func source_mechanical_pump_tick_buildings_state', pump)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no progress keys: the
        # pump tick advances no maxPump / liquids.add / warmup /
        # totalProgress yet (Pump.java:161-176 wait for their own
        # slices), so the maxPump fold (Pump.java:162) is what the
        # efficiency keys prove.
        proof = MECHANICAL_PUMP_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'rotary_pump_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_mechanical_pump_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MechanicalPumpPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MECHANICAL_PUMP_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'rotary_pump_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
