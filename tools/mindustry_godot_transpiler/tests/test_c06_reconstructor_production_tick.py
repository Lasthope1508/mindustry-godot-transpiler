import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitFactoryBuildState.gd'
PRODUCTION_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C06ReconstructorProductionProof.gd'


class C06ReconstructorProductionTickTests(unittest.TestCase):
    def test_c06_reconstructor_production_tick_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2138']['godot_owner'], 'SourceUnitFactoryBuildState.source_reconstructor_production_tick_state')
        # The production tick is the Reconstructor half of the live
        # production wiring: progress/time advance plus the upgrade
        # call (ReconstructorBuild.updateTile(), Reconstructor.java:317-356).
        # Six new result symbols, one per returned value the tick
        # driver writes back into the frame.
        self.assertEqual(
            ledger['N2138']['source_symbols'],
            [
                'source_reconstructor_production_tick_state_result.progress',
                'source_reconstructor_production_tick_state_result.time',
                'source_reconstructor_production_tick_state_result.speed_scl',
                'source_reconstructor_production_tick_state_result.completed',
                'source_reconstructor_production_tick_state_result.constructing',
                'source_reconstructor_production_tick_state_result.payload_unit',
            ],
        )
        for name in ledger['N2138']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['godot_owner'], 'SourceUnitFactoryBuildState.source_reconstructor_production_tick_state')
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/Reconstructor.java')
        self.assertEqual(ledger['N2138']['runtime_proof'], '/root/C06ReconstructorProductionProof')
        self.assertEqual(
            ledger['N2138']['tests'],
            [
                'test_c06_reconstructor_production_tick_registration',
                'test_all_c06_reconstructor_production_tick_input_evidence_is_exact',
                'test_reconstructor_production_tick_state',
                'test_reference_graph_and_actual_c06_reconstructor_production_tick',
            ],
        )
        self.assertTrue(ledger['N2138']['deferred_exprs'])

    def test_all_c06_reconstructor_production_tick_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2138']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitFactoryBuildState.source_reconstructor_production_tick_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/Reconstructor.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/game/Rules.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2138']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_reconstructor_production_tick_state(self):
        state = FACTORY_STATE.read_text(encoding='utf-8')
        tick = state.split('static func source_unit_factory_tick_buildings_state')[1].split('static func source_unit_factory_plan_requirements_state')[0]
        # The pure production tick advances progress/time and fires
        # the upgrade call for a reconstructor frame; the live tick
        # driver calls it every tick and writes the returned values
        # back into the frame.
        self.assertIn('static func source_reconstructor_production_tick_state', state)
        self.assertIn('source_reconstructor_production_tick_state(', tick)
        self.assertIn('progress += edelta() * state.rules.unitBuildSpeed(team);', state)
        self.assertIn('payload.unit = upgrade(payload.unit.type).create(payload.unit.team());', state)
        self.assertNotIn('Reconstructor and UnitAssembler keep the consumption-only', state)
        # The production proof's keys drive the pure tick on a bound
        # additive-reconstructor frame (dagger -> mace, 600 ticks).
        proof = PRODUCTION_PROOF.read_text(encoding='utf-8')
        for key in [
            'reconstructor_progress_advances',
            'reconstructor_time_advances',
            'reconstructor_no_payload_no_progress',
            'reconstructor_not_in_position_no_progress',
            'reconstructor_completes_upgrade',
            'reconstructor_no_upgrade_moves_out',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c06_reconstructor_production_tick(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06ReconstructorProductionProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_RECONSTRUCTOR_PRODUCTION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'reconstructor_progress_advances',
            'reconstructor_time_advances',
            'reconstructor_no_payload_no_progress',
            'reconstructor_not_in_position_no_progress',
            'reconstructor_completes_upgrade',
            'reconstructor_no_upgrade_moves_out',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
