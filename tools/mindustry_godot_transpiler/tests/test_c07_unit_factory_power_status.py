import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitFactoryBuildState.gd'
UNIT_FACTORY_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitFactoryPowerStatusProof.gd'


class C07UnitFactoryPowerStatusTests(unittest.TestCase):
    def test_c07_unit_factory_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2167']['godot_owner'], 'SourceUnitFactoryBuildState.source_unit_factory_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166 proved the pure
        # power-row pattern on the factory, adjacent-factory,
        # drill, turret, burst-drill, solid-pump, point-defense,
        # tractor-beam, fracker, mechanical-pump, beam-drill,
        # mend-projector, overdrive-projector, force-projector,
        # base-shield, regen-projector, constructor,
        # payload-loader, payload-unloader, payload-mass-driver,
        # unit-cargo-loader and payload-deconstructor
        # drivers -- but the unit-factory driver
        # (SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state)
        # never folds a power row: the comment says the power
        # consumer stays the power graph's domain (N2080/N2107) and
        # is not bound here, so ground/air/naval-factory
        # (consumePower 1.2f, Blocks.java:6276), additive-reconstructor
        # (consumePower 3f, Blocks.java:6306) and tank-assembler
        # (consumePower 2.5f, Blocks.java:6532) would produce as
        # if power.status were 1.0. N2167 is the unit-factory
        # family's live read: a pure power row over the stamped
        # frame value, folded by the shared machinery into the min
        # efficiency (BuildingComp.java:1969-1976,
        # ConsumePower.efficiency is build.power.status) and the
        # production ticks (N2137/N2138/N2139) already read
        # frame["efficiency"], so the progress advance
        # (UnitFactory.java:400, `progress += edelta() *
        # Vars.state.rules.unitBuildSpeed(team);`) follows it.
        # The family frame key ("source_unit_factory_building")
        # is ALREADY in SOURCE_CONSUMER_FRAME_META_KEYS, so the
        # N2142 stamp already reaches the frame -- no new key.
        # The shouldConsume gate is already live (N2124
        # source_unit_factory_should_consume_state -- the per-class
        # bodies UnitFactory.java:446-449, Reconstructor.java:368-370,
        # UnitAssembler.java:389-392), so the row folds under the
        # live gate, not the MendProjector-suppression precedent.
        # Two new result symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2167']['source_symbols'],
            [
                'source_unit_factory_power_status_row_state_result.row',
                'source_unit_factory_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2167']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_unit_factory_power_status_row_state_result.row': 'SourceUnitFactoryBuildState.source_unit_factory_power_status_row_state',
                    'source_unit_factory_power_status_row_state_result.has_power_row': 'SourceUnitFactoryBuildState.source_unit_factory_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2167']['runtime_proof'], '/root/C07UnitFactoryPowerStatusProof')
        self.assertEqual(
            ledger['N2167']['tests'],
            [
                'test_c07_unit_factory_power_status_registration',
                'test_all_c07_unit_factory_power_status_input_evidence_is_exact',
                'test_unit_factory_power_status_row_state',
                'test_reference_graph_and_actual_c07_unit_factory_power_status',
            ],
        )
        self.assertTrue(ledger['N2167']['deferred_exprs'])

    def test_all_c07_unit_factory_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2167']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_unit_factory_power_status_row_state_result.row': 'SourceUnitFactoryBuildState.source_unit_factory_power_status_row_state',
                    'source_unit_factory_power_status_row_state_result.has_power_row': 'SourceUnitFactoryBuildState.source_unit_factory_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/units/UnitFactory.java',
            'core/src/mindustry/world/blocks/units/Reconstructor.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2167']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_factory_power_status_row_state(self):
        unit_factory = UNIT_FACTORY_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the unit-factory
        # build state: the live frame value is
        # ConsumePower.efficiency (ConsumePower.java:39, `return
        # build.power.status;`), folded by the first pass
        # (BuildingComp.java:1969-1976) into the min efficiency;
        # a missing stamp folds to 1.0 before the first graph
        # update, the assembler fold (UnitAssembler.java:469,
        # `float powerStatus = !enabled ? 0f : power == null ?
        # 1f : power.status;`).
        self.assertIn('static func source_unit_factory_power_status_row_state', unit_factory)
        self.assertIn('return build.power.status;', unit_factory)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', unit_factory)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the
        # ground-factory (1.2f) power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The production ticks follow the
        # folded efficiency (UnitFactory.java:400, `progress +=
        # edelta() * Vars.state.rules.unitBuildSpeed(team);`,
        # keep on ONE comment line, the N2148 shootWarmup
        # lesson: a split line fails this test), with the
        # per-class shouldConsume bodies already live (N2124:
        # UnitFactory.java:446-449, Reconstructor.java:368-370,
        # UnitAssembler.java:389-392; default
        # BuildingComp.java:755, `public boolean shouldConsume(){`).
        # The family covers UnitFactory, Reconstructor and
        # UnitAssembler (UnitFactory.java:36, `public class
        # UnitFactory extends UnitBlock{`; Reconstructor.java:35,
        # `public class Reconstructor extends UnitBlock{`;
        # UnitAssembler.java:41, `public class UnitAssembler
        # extends PayloadBlock{`).
        self.assertIn('"is_power": true', unit_factory)
        self.assertIn('block.properties.has("consumePower")', unit_factory)
        self.assertIn('hasConsumers = consumers.length > 0;', unit_factory)
        self.assertIn('progress += edelta() * Vars.state.rules.unitBuildSpeed(team);', unit_factory)
        self.assertIn('public boolean shouldConsume(){', unit_factory)
        self.assertIn('public class UnitFactory extends UnitBlock{', unit_factory)
        self.assertIn('public class Reconstructor extends UnitBlock{', unit_factory)
        self.assertIn('public class UnitAssembler extends PayloadBlock{', unit_factory)
        self.assertIn('consumePower(1.2f);', unit_factory)
        self.assertIn('consumePower(3f);', unit_factory)
        self.assertIn('consumePower(2.5f);', unit_factory)
        self.assertIn('static func source_unit_factory_tick_buildings_state', unit_factory)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no progress / plan /
        # payload / drone keys: the production ticks (N2137/N2138/
        # N2139) already advance progress from frame["efficiency"],
        # so the progress advance (UnitFactory.java:400) is what
        # the efficiency keys prove.
        proof = UNIT_FACTORY_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'unit_factory_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_unit_factory_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitFactoryPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_FACTORY_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'unit_factory_has_power_consumer',
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
