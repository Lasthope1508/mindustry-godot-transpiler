import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_ASSEMBLER_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitAssemblerModuleBuildState.gd'
UNIT_ASSEMBLER_MODULE_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModulePowerStatusProof.gd'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07UnitAssemblerModulePowerStatusTests(unittest.TestCase):
    def test_c07_unit_assembler_module_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2168']['godot_owner'], 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2145/N2146/N2147/N2148/
        # N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/
        # N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167
        # proved the pure power-row pattern on the factory,
        # adjacent-factory, drill, turret, burst-drill, solid-pump,
        # point-defense, tractor-beam, fracker, mechanical-pump,
        # beam-drill, mend-projector, overdrive-projector,
        # force-projector, base-shield, regen-projector,
        # constructor, payload-loader, payload-unloader,
        # payload-mass-driver, unit-cargo-loader,
        # payload-deconstructor and unit-factory drivers -- but
        # the UnitAssemblerModule (basic-assembler-module,
        # consumePower 3.5f, Blocks.java:6568) has NO driver at
        # all: it extends PayloadBlock
        # (UnitAssemblerModule.java:18), not UnitAssembler, so
        # the unit-factory driver never matches it, and its
        # updateTile payload forward (UnitAssemblerModule.java:138)
        # gates on efficiency > 0, so a module with no power
        # would forward payloads as if power.status were 1.0.
        # N2168 is the module's live read: a pure power row over
        # the stamped frame value, folded by the shared machinery
        # into the min efficiency (BuildingComp.java:1969-1976,
        # ConsumePower.efficiency is build.power.status) in its
        # own driver, wired into simulate_factory like the
        # payload-deconstructor driver (N2166). The module has
        # no shouldConsume override, so the BuildingComp default
        # (BuildingComp.java:755) applies and the row folds under
        # it. Two new result symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2168']['source_symbols'],
            [
                'source_unit_assembler_module_power_status_row_state_result.row',
                'source_unit_assembler_module_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2168']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_unit_assembler_module_power_status_row_state_result.row': 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_power_status_row_state',
                    'source_unit_assembler_module_power_status_row_state_result.has_power_row': 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2168']['runtime_proof'], '/root/C07UnitAssemblerModulePowerStatusProof')
        self.assertEqual(
            ledger['N2168']['tests'],
            [
                'test_c07_unit_assembler_module_power_status_registration',
                'test_all_c07_unit_assembler_module_power_status_input_evidence_is_exact',
                'test_unit_assembler_module_power_status_row_state',
                'test_reference_graph_and_actual_c07_unit_assembler_module_power_status',
            ],
        )
        self.assertTrue(ledger['N2168']['deferred_exprs'])

    def test_all_c07_unit_assembler_module_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2168']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_unit_assembler_module_power_status_row_state_result.row': 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_power_status_row_state',
                    'source_unit_assembler_module_power_status_row_state_result.has_power_row': 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2168']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_assembler_module_power_status_row_state(self):
        unit_assembler_module = UNIT_ASSEMBLER_MODULE_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the new unit-assembler-module
        # build state: the live frame value is
        # ConsumePower.efficiency (ConsumePower.java:39, `return
        # build.power.status;`), folded by the first pass
        # (BuildingComp.java:1969-1976) into the min efficiency;
        # a missing stamp folds to 1.0 before the first graph
        # update, the assembler fold (UnitAssembler.java:469,
        # `float powerStatus = !enabled ? 0f : power == null ?
        # 1f : power.status;`).
        self.assertIn('static func source_unit_assembler_module_power_status_row_state', unit_assembler_module)
        self.assertIn('return build.power.status;', unit_assembler_module)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', unit_assembler_module)
        # The tick driver folds the row into the first pass when
        # the block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); the
        # basic-assembler-module (3.5f) power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The module's updateTile forward
        # gates on efficiency > 0 (UnitAssemblerModule.java:138,
        # keep on ONE comment line, the N2148 shootWarmup
        # lesson: a split line fails this test), and the module
        # has no shouldConsume override, so the default
        # (BuildingComp.java:755, `public boolean shouldConsume(){`)
        # applies. The module is its own family
        # (UnitAssemblerModule.java:18, `public class
        # UnitAssemblerModule extends PayloadBlock{`; tier 1,
        # UnitAssemblerModule.java:22, `public int tier = 1;`).
        self.assertIn('"is_power": true', unit_assembler_module)
        self.assertIn('block.properties.has("consumePower")', unit_assembler_module)
        self.assertIn('hasConsumers = consumers.length > 0;', unit_assembler_module)
        self.assertIn('if(moveInPayload() && link != null && link.moduleFits(block, x, y, rotation) && !link.wasOccupied && link.acceptPayload(this, payload) && efficiency > 0){', unit_assembler_module)
        self.assertIn('public boolean shouldConsume(){', unit_assembler_module)
        self.assertIn('public class UnitAssemblerModule extends PayloadBlock{', unit_assembler_module)
        self.assertIn('public int tier = 1;', unit_assembler_module)
        self.assertIn('public class UnitAssemblerModuleBuild extends PayloadBlockBuild<Payload>{', unit_assembler_module)
        self.assertIn('link = getLink(team, tile.x, tile.y, rotation);', unit_assembler_module)
        self.assertIn('acceptsPayload = true;', unit_assembler_module)
        self.assertIn('consumePower(3.5f);', unit_assembler_module)
        self.assertIn('static func source_unit_assembler_module_tick_buildings_state', unit_assembler_module)
        # The module needs its own frame key in N2142's
        # SOURCE_CONSUMER_FRAME_META_KEYS so the graph stamp
        # reaches its frame, and its driver must be wired into
        # simulate_factory (the payload-deconstructor precedent,
        # N2166).
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_unit_assembler_module_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_unit_assembler_module_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no link / payload /
        # tier keys: the updateTile forward (UnitAssemblerModule.java:129-141)
        # waits for its own slice, so the efficiency > 0 gate
        # (UnitAssemblerModule.java:138) is what the efficiency
        # keys prove.
        proof = UNIT_ASSEMBLER_MODULE_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'unit_assembler_module_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_unit_assembler_module_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitAssemblerModulePowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_ASSEMBLER_MODULE_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'unit_assembler_module_has_power_consumer',
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
