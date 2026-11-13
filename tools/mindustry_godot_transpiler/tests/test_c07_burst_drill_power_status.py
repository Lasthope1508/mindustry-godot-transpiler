import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillPowerStatusProof.gd'


class C07BurstDrillPowerStatusTests(unittest.TestCase):
    def test_c07_burst_drill_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2149']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick (SourcePlacedPowerGraphState
        # SOURCE_CONSUMER_FRAME_META_KEYS includes
        # "source_drill_building", the DrillBuild frame BurstDrill
        # inherits), and N2147 proved the pure power-row pattern on
        # the base-Drill driver -- but the drill tick driver only
        # ticks blocks whose implementation is the base Drill class
        # (SourceDrillConsumptionRuntimeState.gd, `block.
        # implementation != drill.SOURCE_DRILL_GENERATED_CLASS.
        # get_file().get_basename()`), so the BurstDrill blocks
        # (eruption-drill consumePower 6f, impact-drill consumePower
        # 160f/60f) never tick at all and would run as if
        # power.status were 1.0. N2149 is the BurstDrill family's
        # live read: a new BurstDrill driver with a pure power row
        # over the stamped frame value, folded by the shared
        # machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) and the burst-drill speed
        # (BurstDrill.java:94) follows it. Two new result symbols:
        # the row and its presence flag.
        self.assertEqual(
            ledger['N2149']['source_symbols'],
            [
                'source_burst_drill_power_status_row_state_result.row',
                'source_burst_drill_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2149']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_burst_drill_power_status_row_state_result.row': 'SourceBurstDrillBuildState.source_burst_drill_power_status_row_state',
                    'source_burst_drill_power_status_row_state_result.has_power_row': 'SourceBurstDrillBuildState.source_burst_drill_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2149']['runtime_proof'], '/root/C07BurstDrillPowerStatusProof')
        self.assertEqual(
            ledger['N2149']['tests'],
            [
                'test_c07_burst_drill_power_status_registration',
                'test_all_c07_burst_drill_power_status_input_evidence_is_exact',
                'test_burst_drill_power_status_row_state',
                'test_reference_graph_and_actual_c07_burst_drill_power_status',
            ],
        )
        self.assertTrue(ledger['N2149']['deferred_exprs'])

    def test_all_c07_burst_drill_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2149']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_burst_drill_power_status_row_state_result.row': 'SourceBurstDrillBuildState.source_burst_drill_power_status_row_state',
                    'source_burst_drill_power_status_row_state_result.has_power_row': 'SourceBurstDrillBuildState.source_burst_drill_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2149']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_power_status_row_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the BurstDrill build state:
        # the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_burst_drill_power_status_row_state', burst_drill)
        self.assertIn('return build.power.status;', burst_drill)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', burst_drill)
        # The tick driver folds the row into the first pass when the
        # block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); both burst drills
        # also have liquid rows, so hasConsumers is already true and
        # no driver change is needed there -- the pure function's
        # comment quotes the line to record that (Block.java:1449,
        # `hasConsumers = consumers.length > 0;`). The burst-drill
        # speed follows the folded efficiency (BurstDrill.java:94,
        # `float speed = Mathf.lerp(1f, liquidBoostIntensity,
        # optionalEfficiency) * efficiency;`).
        self.assertIn('"is_power": true', burst_drill)
        self.assertIn('block.properties.has("consumePower")', burst_drill)
        self.assertIn('hasConsumers = consumers.length > 0;', burst_drill)
        self.assertIn('float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;', burst_drill)
        self.assertIn('static func source_burst_drill_tick_buildings_state', burst_drill)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no progress keys: the
        # burst-drill tick advances no progress/timeDrilled yet
        # (BurstDrill.java:70-125 waits for its own slice), so the
        # speed fold (BurstDrill.java:94) is what the efficiency
        # keys prove.
        proof = BURST_DRILL_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'eruption_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_burst_drill_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'eruption_has_power_consumer',
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
