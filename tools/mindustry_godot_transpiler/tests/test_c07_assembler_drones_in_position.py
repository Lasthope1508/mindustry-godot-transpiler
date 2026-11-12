import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitFactoryBuildState.gd'
OWNER_REGISTRY = ROOT / 'godot-mindustry/src/game/SourceRuntimeOwnerUnitBuildingRegistry.gd'
DRONES_IN_POSITION_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AssemblerDronesInPositionProof.gd'


class C07AssemblerDronesInPositionTests(unittest.TestCase):
    def test_c07_assembler_drones_in_position_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2144']['godot_owner'], 'SourceUnitFactoryBuildState.source_assembler_drones_in_position_state')
        # N2139 wired the assembler production tick and its pure
        # function takes in_position_count as an input, but the
        # tick driver reads it from frame.get(
        # "drones_in_position", 0) -- the frame never stamps a
        # live value, so eff is 0 and no progress advances (the
        # driver comment at SourceUnitFactoryBuildState.gd:821-826
        # says so outright). N2144 is that live count: the
        # AssemblerAI-only drone list counted through
        # inPosition() (UnitAssembler.java:516 `float eff =
        # (units.count(u -> ((AssemblerAI)u.controller()).
        # inPosition()) / (float)dronesCreated);`), exposed as
        # one pure count over the frame's units list so the
        # driver stamps frame["drones_in_position"] before the
        # tick call: one new result symbol, the count the tick
        # divides by dronesCreated.
        self.assertEqual(
            ledger['N2144']['source_symbols'],
            [
                'source_assembler_drones_in_position_state_result.drones_in_position',
            ],
        )
        for name in ledger['N2144']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/UnitAssembler.java',
                    'core/src/mindustry/ai/types/AssemblerAI.java',
                    'core/src/mindustry/content/UnitTypes.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceUnitFactoryBuildState.source_assembler_drones_in_position_state')
        self.assertEqual(ledger['N2144']['runtime_proof'], '/root/C07AssemblerDronesInPositionProof')
        self.assertEqual(
            ledger['N2144']['tests'],
            [
                'test_c07_assembler_drones_in_position_registration',
                'test_all_c07_assembler_drones_in_position_input_evidence_is_exact',
                'test_assembler_drones_in_position_state',
                'test_reference_graph_and_actual_c07_assembler_drones_in_position',
            ],
        )
        self.assertTrue(ledger['N2144']['deferred_exprs'])

    def test_all_c07_assembler_drones_in_position_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2144']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitFactoryBuildState.source_assembler_drones_in_position_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/ai/types/AssemblerAI.java',
            'core/src/mindustry/content/UnitTypes.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2144']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_assembler_drones_in_position_state(self):
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        owner_registry = OWNER_REGISTRY.read_text(encoding='utf-8')
        # The pure count lives on the unit-factory build state,
        # following the has_upgrade / plan-requirements pattern
        # (units: Array, null-safe): it counts the frame's units
        # entries that are assembly drones in position -- the
        # drone type is UnitTypes.assemblyDrone
        # (UnitAssembler.java:47) named "assembly-drone"
        # (UnitTypes.java:4595), and in_position is the recorded
        # AssemblerAI.inPosition() flag (AssemblerAI.java:
        # `unit.within(targetPos, 10f) && Angles.within(
        # unit.rotation, targetAngle, 15f)`). The tick driver
        # stamps frame["drones_in_position"] from it before the
        # tick call instead of reading the 0 default.
        self.assertIn('static func source_assembler_drones_in_position_state', factory)
        self.assertIn('float eff = (units.count(u -> ((AssemblerAI)u.controller()).inPosition()) / (float)dronesCreated);', factory)
        self.assertIn('source_assembler_drones_in_position_state(frame.get("units", []))', factory)
        self.assertIn('PORT_GAME_SOURCE_ASSEMBLER_DRONES_IN_POSITION_STATE', owner_registry)
        # The proof's keys drive the count's empty / partial /
        # filtered paths and the tick's eff fold (2 of 4 drones
        # in position -> eff 0.5, progress advances; 0 in
        # position -> eff 0, no progress).
        proof = DRONES_IN_POSITION_PROOF.read_text(encoding='utf-8')
        for key in [
            'count_empty_0',
            'count_two_of_four',
            'count_ignores_other_types',
            'count_ignores_not_in_position',
            'tick_eff_half',
            'tick_no_progress_zero_drones',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_assembler_drones_in_position(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07AssemblerDronesInPositionProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ASSEMBLER_DRONES_IN_POSITION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'count_empty_0',
            'count_two_of_four',
            'count_ignores_other_types',
            'count_ignores_not_in_position',
            'tick_eff_half',
            'tick_no_progress_zero_drones',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
