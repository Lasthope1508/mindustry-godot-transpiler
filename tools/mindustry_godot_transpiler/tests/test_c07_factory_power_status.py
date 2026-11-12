import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryBuildState.gd'
FACTORY_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FactoryPowerStatusProof.gd'


class C07FactoryPowerStatusTests(unittest.TestCase):
    def test_c07_factory_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2145']['godot_owner'], 'SourceFactoryBuildState.source_factory_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, but only the unit-factory driver
        # reads frame["power_status"] so far: the GenericCrafter
        # tick driver builds its first-pass rows from the bound
        # actors with is_power false and never adds a power row --
        # "the power consumer stays the power graph's domain
        # (N2080/N2107) and is not bound here" -- so a factory
        # with no power still runs at full efficiency and its
        # progress climbs by getProgressIncrease(craftTime)
        # (GenericCrafter.java:238) as if power.status were 1.0.
        # N2145 is the factory family's live read: a pure power
        # row over the stamped frame value, appended to the tick
        # driver's first pass when the block has a power consumer,
        # so the shared machinery folds it into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status). Two new result symbols: the row and
        # its presence flag.
        self.assertEqual(
            ledger['N2145']['source_symbols'],
            [
                'source_factory_power_status_row_state_result.row',
                'source_factory_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2145']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_factory_power_status_row_state_result.row': 'SourceFactoryBuildState.source_factory_power_status_row_state',
                    'source_factory_power_status_row_state_result.has_power_row': 'SourceFactoryBuildState.source_factory_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2145']['runtime_proof'], '/root/C07FactoryPowerStatusProof')
        self.assertEqual(
            ledger['N2145']['tests'],
            [
                'test_c07_factory_power_status_registration',
                'test_all_c07_factory_power_status_input_evidence_is_exact',
                'test_factory_power_status_row_state',
                'test_reference_graph_and_actual_c07_factory_power_status',
            ],
        )
        self.assertTrue(ledger['N2145']['deferred_exprs'])

    def test_all_c07_factory_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2145']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_factory_power_status_row_state_result.row': 'SourceFactoryBuildState.source_factory_power_status_row_state',
                    'source_factory_power_status_row_state_result.has_power_row': 'SourceFactoryBuildState.source_factory_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/production/GenericCrafter.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2145']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_factory_power_status_row_state(self):
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the factory build state: the
        # live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_factory_power_status_row_state', factory)
        self.assertIn('return build.power.status;', factory)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', factory)
        # The tick driver appends the row to the first pass when the
        # block has a power consumer (the drill driver's gate,
        # block.properties.has("consumePower")), and counts the
        # power consumer toward hasConsumers (Block.java:1449,
        # `hasConsumers = consumers.length > 0;`) so a power-only
        # factory does not take the early return.
        self.assertIn('"is_power": true', factory)
        self.assertIn('block.properties.has("consumePower")', factory)
        self.assertIn('hasConsumers = consumers.length > 0;', factory)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, progress stops at zero power and halves at half
        # power) directly.
        proof = FACTORY_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'smelter_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'progress_zero_at_no_power',
            'progress_half_at_half_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_factory_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07FactoryPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FACTORY_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'smelter_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'progress_zero_at_no_power',
            'progress_half_at_half_power',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
