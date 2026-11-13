import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOLID_PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceSolidPumpBuildState.gd'
SOLID_PUMP_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SolidPumpPowerStatusProof.gd'


class C07SolidPumpPowerStatusTests(unittest.TestCase):
    def test_c07_solid_pump_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2150']['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2147/N2148/N2149 proved the
        # pure power-row pattern on the drill, turret and burst-drill
        # drivers -- but the pump runtime
        # (SourcePumpRuntimeState.gd) ticks only the scenario
        # mechanical pump at PUMP_POS with efficiency hardcoded 1.0
        # ("consumes no power", `source_pump_update_state`), so the
        # water-extractor (SolidPump, consumePower 1.5f) never ticks
        # at all and would run as if power.status were 1.0. N2150
        # is the SolidPump family's live read: a new SolidPump
        # driver with a pure power row over the stamped frame value,
        # folded by the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) and the solid-pump speed
        # (SolidPump.java:121) follows it. Two new result symbols:
        # the row and its presence flag.
        self.assertEqual(
            ledger['N2150']['source_symbols'],
            [
                'source_solid_pump_power_status_row_state_result.row',
                'source_solid_pump_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2150']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_solid_pump_power_status_row_state_result.row': 'SourceSolidPumpBuildState.source_solid_pump_power_status_row_state',
                    'source_solid_pump_power_status_row_state_result.has_power_row': 'SourceSolidPumpBuildState.source_solid_pump_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2150']['runtime_proof'], '/root/C07SolidPumpPowerStatusProof')
        self.assertEqual(
            ledger['N2150']['tests'],
            [
                'test_c07_solid_pump_power_status_registration',
                'test_all_c07_solid_pump_power_status_input_evidence_is_exact',
                'test_solid_pump_power_status_row_state',
                'test_reference_graph_and_actual_c07_solid_pump_power_status',
            ],
        )
        self.assertTrue(ledger['N2150']['deferred_exprs'])

    def test_all_c07_solid_pump_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2150']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_solid_pump_power_status_row_state_result.row': 'SourceSolidPumpBuildState.source_solid_pump_power_status_row_state',
                    'source_solid_pump_power_status_row_state_result.has_power_row': 'SourceSolidPumpBuildState.source_solid_pump_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/production/SolidPump.java',
            'core/src/mindustry/world/blocks/production/Pump.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2150']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_solid_pump_power_status_row_state(self):
        solid_pump = SOLID_PUMP_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the SolidPump build state:
        # the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_solid_pump_power_status_row_state', solid_pump)
        self.assertIn('return build.power.status;', solid_pump)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', solid_pump)
        # The tick driver folds the row into the first pass when the
        # block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the water-extractor
        # is the only SolidPump and its power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The solid-pump speed follows the
        # folded efficiency (SolidPump.java:121, `float maxPump =
        # Math.min(liquidCapacity - typeLiquid(), pumpAmount *
        # delta() * fraction * efficiency);` -- keep on ONE comment
        # line, the N2148 shootWarmup lesson: a split line fails
        # this test).
        self.assertIn('"is_power": true', solid_pump)
        self.assertIn('block.properties.has("consumePower")', solid_pump)
        self.assertIn('hasConsumers = consumers.length > 0;', solid_pump)
        self.assertIn('float maxPump = Math.min(liquidCapacity - typeLiquid(), pumpAmount * delta() * fraction * efficiency);', solid_pump)
        self.assertIn('static func source_solid_pump_tick_buildings_state', solid_pump)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no progress keys: the
        # solid-pump tick advances no warmup/pumpTime yet
        # (SolidPump.java:118-133 waits for its own slice), so the
        # speed fold (SolidPump.java:121) is what the efficiency
        # keys prove.
        proof = SOLID_PUMP_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'water_extractor_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_solid_pump_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SolidPumpPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOLID_PUMP_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'water_extractor_has_power_consumer',
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
