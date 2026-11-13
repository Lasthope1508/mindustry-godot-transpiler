import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ADJACENT_FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceAdjacentFactoryBuildState.gd'
ADJACENT_FACTORY_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AdjacentFactoryPowerStatusProof.gd'


class C07AdjacentFactoryPowerStatusTests(unittest.TestCase):
    def test_c07_adjacent_factory_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2146']['godot_owner'], 'SourceAdjacentFactoryBuildState.source_adjacent_factory_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick (SourcePlacedPowerGraphState
        # SOURCE_CONSUMER_FRAME_META_KEYS includes
        # "source_adjacent_factory_building"), and N2145 proved the
        # pattern on the GenericCrafter driver -- but the
        # adjacent-family tick driver still builds its first-pass
        # rows from the bound actors with is_power false and never
        # adds a power row -- "the power consumer stays the power
        # graph's domain (N2080/N2107) and is not bound here" -- so
        # a separator with no power still runs at full efficiency
        # and its progress would climb by
        # getProgressIncrease(craftTime) (Separator.java:142) as if
        # power.status were 1.0. N2146 is the adjacent family's live
        # read: a pure power row over the stamped frame value,
        # appended to the tick driver's first pass when the block
        # has a power consumer, so the shared machinery folds it
        # into the min efficiency (BuildingComp.java:1969-1976,
        # ConsumePower.efficiency is build.power.status). Two new
        # result symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2146']['source_symbols'],
            [
                'source_adjacent_factory_power_status_row_state_result.row',
                'source_adjacent_factory_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2146']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_adjacent_factory_power_status_row_state_result.row': 'SourceAdjacentFactoryBuildState.source_adjacent_factory_power_status_row_state',
                    'source_adjacent_factory_power_status_row_state_result.has_power_row': 'SourceAdjacentFactoryBuildState.source_adjacent_factory_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2146']['runtime_proof'], '/root/C07AdjacentFactoryPowerStatusProof')
        self.assertEqual(
            ledger['N2146']['tests'],
            [
                'test_c07_adjacent_factory_power_status_registration',
                'test_all_c07_adjacent_factory_power_status_input_evidence_is_exact',
                'test_adjacent_factory_power_status_row_state',
                'test_reference_graph_and_actual_c07_adjacent_factory_power_status',
            ],
        )
        self.assertTrue(ledger['N2146']['deferred_exprs'])

    def test_all_c07_adjacent_factory_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2146']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_adjacent_factory_power_status_row_state_result.row': 'SourceAdjacentFactoryBuildState.source_adjacent_factory_power_status_row_state',
                    'source_adjacent_factory_power_status_row_state_result.has_power_row': 'SourceAdjacentFactoryBuildState.source_adjacent_factory_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/production/Separator.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2146']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_adjacent_factory_power_status_row_state(self):
        adjacent = ADJACENT_FACTORY_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the adjacent-factory build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_adjacent_factory_power_status_row_state', adjacent)
        self.assertIn('return build.power.status;', adjacent)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', adjacent)
        # The tick driver appends the row to the first pass when the
        # block has a power consumer (the drill driver's gate,
        # block.properties.has("consumePower")); unlike the factory
        # driver, _has_consumers_state already counts the power
        # consumer toward hasConsumers (Block.java:1449,
        # `hasConsumers = consumers.length > 0;`), so no driver
        # change is needed there -- the pure function's comment
        # quotes the line to record that.
        self.assertIn('"is_power": true', adjacent)
        self.assertIn('block.properties.has("consumePower")', adjacent)
        self.assertIn('hasConsumers = consumers.length > 0;', adjacent)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no progress keys: the
        # adjacent driver does not advance progress yet
        # (Separator.java:142 `progress +=
        # getProgressIncrease(craftTime);` gated on efficiency > 0
        # is unwired) -- that is its own slice.
        proof = ADJACENT_FACTORY_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'separator_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_adjacent_factory_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07AdjacentFactoryPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ADJACENT_FACTORY_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'separator_has_power_consumer',
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
