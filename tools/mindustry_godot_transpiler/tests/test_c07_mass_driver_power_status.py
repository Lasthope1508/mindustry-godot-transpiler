import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourceMassDriverBuildState.gd'
MASS_DRIVER_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverPowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07MassDriverPowerStatusTests(unittest.TestCase):
    def test_c07_mass_driver_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2171']['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
        # N2168/N2169/N2170 proved the pure power-row pattern on the
        # factory, adjacent-factory, drill, turret, burst-drill,
        # solid-pump, point-defense, tractor-beam, fracker,
        # mechanical-pump, beam-drill, mend-projector,
        # overdrive-projector, force-projector, base-shield,
        # regen-projector, constructor, payload-loader,
        # payload-unloader, payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor, unit-assembler-module, separator
        # and wall-crafter drivers -- but the MassDriver
        # (mass-driver, consumePower 1.75f, Blocks.java:2173) has NO
        # driver at all: it extends Block (MassDriver.java:27), not
        # a factory or crafter, so no existing driver matches it,
        # and its updateTile no-power skip (MassDriver.java:169,
        # `if(efficiency <= 0f){`) gates on efficiency, so a mass
        # driver with no power would keep rotating and firing as if
        # power.status were 1.0. N2171 is the mass driver's live
        # read: a pure power row over the stamped frame value,
        # folded by the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) in its own driver, wired into
        # simulate_factory like the wall-crafter driver (N2170).
        # MassDriverBuild has no shouldConsume override, so the
        # BuildingComp default (BuildingComp.java:755-757, `return
        # enabled;`) applies. Two new result symbols: the row and
        # its presence flag.
        self.assertEqual(
            ledger['N2171']['source_symbols'],
            [
                'source_mass_driver_power_status_row_state_result.row',
                'source_mass_driver_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2171']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_mass_driver_power_status_row_state_result.row': 'SourceMassDriverBuildState.source_mass_driver_power_status_row_state',
                    'source_mass_driver_power_status_row_state_result.has_power_row': 'SourceMassDriverBuildState.source_mass_driver_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2171']['runtime_proof'], '/root/C07MassDriverPowerStatusProof')
        self.assertEqual(
            ledger['N2171']['tests'],
            [
                'test_c07_mass_driver_power_status_registration',
                'test_all_c07_mass_driver_power_status_input_evidence_is_exact',
                'test_mass_driver_power_status_row_state',
                'test_reference_graph_and_actual_c07_mass_driver_power_status',
            ],
        )
        self.assertTrue(ledger['N2171']['deferred_exprs'])

    def test_all_c07_mass_driver_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2171']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_mass_driver_power_status_row_state_result.row': 'SourceMassDriverBuildState.source_mass_driver_power_status_row_state',
                    'source_mass_driver_power_status_row_state_result.has_power_row': 'SourceMassDriverBuildState.source_mass_driver_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/distribution/MassDriver.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2171']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mass_driver_power_status_row_state(self):
        mass_driver = MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new mass driver build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled ?
        # 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_mass_driver_power_status_row_state', mass_driver)
        self.assertIn('return build.power.status;', mass_driver)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', mass_driver)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the mass-driver
        # (1.75f) power consumer counts toward hasConsumers
        # (Block.java:1449, `hasConsumers = consumers.length > 0;`).
        # The mass driver's updateTile no-power skip gates on
        # efficiency (MassDriver.java:169, keep on ONE comment line,
        # the N2148 shootWarmup lesson: a split line fails this
        # test), its rotation align scales by efficiency
        # (MassDriver.java:181, `rotation = Angles.moveToward(
        # rotation, angleTo(currentShooter()), rotateSpeed *
        # efficiency);`) and its reload counter drains regardless
        # of state (MassDriver.java:143, `reloadCounter = Mathf.
        # clamp(reloadCounter - edelta() / reload);`).
        # MassDriverBuild has no shouldConsume override, so the
        # BuildingComp default applies (BuildingComp.java:755,
        # `public boolean shouldConsume(){`; BuildingComp.java:756,
        # `return enabled;`). The mass driver is its own family
        # (MassDriver.java:27, `public class MassDriver extends
        # Block{`; MassDriverBuild, MassDriver.java:115, `public
        # class MassDriverBuild extends Building implements
        # RotBlock{`). There is no large-mass-driver def in this
        # upstream version (no largeMassDriver in Blocks.java), so
        # the single mass-driver def is the whole family.
        self.assertIn('"is_power": true', mass_driver)
        self.assertIn('block.properties.has("consumePower")', mass_driver)
        self.assertIn('hasConsumers = consumers.length > 0;', mass_driver)
        self.assertIn('if(efficiency <= 0f){', mass_driver)
        self.assertIn('rotation = Angles.moveToward(rotation, angleTo(currentShooter()), rotateSpeed * efficiency);', mass_driver)
        self.assertIn('reloadCounter = Mathf.clamp(reloadCounter - edelta() / reload);', mass_driver)
        self.assertIn('public boolean shouldConsume(){', mass_driver)
        self.assertIn('return enabled;', mass_driver)
        self.assertIn('public class MassDriver extends Block{', mass_driver)
        self.assertIn('public class MassDriverBuild extends Building implements RotBlock{', mass_driver)
        self.assertIn('consumePower(1.75f);', mass_driver)
        self.assertIn('static func source_mass_driver_tick_buildings_state', mass_driver)
        # The mass driver needs its own frame key in N2142's
        # SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp
        # reaches its frame, and its driver must be wired into
        # simulate_factory (the wall-crafter precedent, N2170).
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_mass_driver_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_mass_driver_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no link/state/reload/
        # fire keys: the updateTile advance (MassDriver.java:
        # 133-221) waits for its own slice, so the no-power skip
        # (MassDriver.java:169) is what the efficiency keys prove.
        proof = MASS_DRIVER_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'mass_driver_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_mass_driver_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MassDriverPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MASS_DRIVER_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'mass_driver_has_power_consumer',
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
