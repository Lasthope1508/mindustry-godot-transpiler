import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitFactoryBuildState.gd'
CHECK_TIER_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C06UnitAssemblerCheckTierProof.gd'


class C06UnitAssemblerCheckTierTests(unittest.TestCase):
    def test_c06_unit_assembler_check_tier_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2133']['godot_owner'], 'SourceUnitFactoryBuildState.source_unit_factory_assembler_check_tier_state')
        # checkTier is the assembler tier climb from the module tiers
        # (UnitAssembler.java:363-377): sort the modules by tier, climb
        # while each module is the current max or one above it, stop at
        # the first gap, and store the result in currentTier.
        self.assertEqual(
            ledger['N2133']['source_symbols'],
            [
                'source_unit_factory_assembler_check_tier_state_input.frame',
                'source_unit_factory_assembler_check_tier_state_result.current_tier',
                'source_unit_factory_assembler_check_tier_state_result.module_tiers',
                'source_unit_factory_assembler_check_tier_state_result.tier_gap',
            ],
        )
        for name in ledger['N2133']['source_symbols']:
            with self.subTest(symbol=name):
                self.assertEqual(symbols[name]['godot_owner'], 'SourceUnitFactoryBuildState.source_unit_factory_assembler_check_tier_state')
                self.assertEqual(symbols[name]['java_source'], 'core/src/mindustry/world/blocks/units/UnitAssembler.java')
        self.assertEqual(ledger['N2133']['runtime_proof'], '/root/C06UnitAssemblerCheckTierProof')
        self.assertEqual(
            ledger['N2133']['tests'],
            [
                'test_c06_unit_assembler_check_tier_registration',
                'test_all_c06_unit_assembler_check_tier_input_evidence_is_exact',
                'test_assembler_check_tier_reads_module_tiers',
                'test_reference_graph_and_actual_c06_unit_assembler_check_tier',
            ],
        )
        self.assertTrue(ledger['N2133']['deferred_exprs'])

    def test_all_c06_unit_assembler_check_tier_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2133']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitFactoryBuildState.source_unit_factory_assembler_check_tier_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2133']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_assembler_check_tier_reads_module_tiers(self):
        factory = UNIT_FACTORY_STATE.read_text(encoding='utf-8')
        # The checkTier function exists and follows the Java climb
        # (UnitAssembler.java:363-377): sort by tier, climb while each
        # module is max or max + 1, stop at the first gap.
        self.assertIn('static func source_unit_factory_assembler_check_tier_state(frame: Dictionary) -> Dictionary:', factory)
        gate = factory.split('static func source_unit_factory_should_consume_state')[1].split('static func source_unit_factory_tick_buildings_state')[0]
        # The assembler branch derives the plan tier from the module
        # tiers when the frame carries them (Java calls checkTier()
        # from updateModules/removeModule, UnitAssembler.java:355/360,
        # so the tier only changes on a module event); a frame without
        # a modules list keeps its stored current_tier, so the N2124
        # proof frames are unaffected.
        self.assertIn('source_unit_factory_assembler_check_tier_state(frame)', gate)
        self.assertIn('frame.has("modules")', gate)
        # The new proof scene covers the climb: empty, single, sequential,
        # gap, unsorted input, duplicate tier, gap after two.
        proof = CHECK_TIER_PROOF.read_text(encoding='utf-8')
        for key in [
            'check_tier_no_modules_zero',
            'check_tier_single_tier_one',
            'check_tier_sequential_one_two',
            'check_tier_gap_stops_climb',
            'check_tier_unsorted_input_sorted',
            'check_tier_duplicate_tier',
            'check_tier_gap_after_two',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c06_unit_assembler_check_tier(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06UnitAssemblerCheckTierProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_UNIT_ASSEMBLER_CHECK_TIER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'check_tier_no_modules_zero',
            'check_tier_single_tier_one',
            'check_tier_sequential_one_two',
            'check_tier_gap_stops_climb',
            'check_tier_unsorted_input_sorted',
            'check_tier_duplicate_tier',
            'check_tier_gap_after_two',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
