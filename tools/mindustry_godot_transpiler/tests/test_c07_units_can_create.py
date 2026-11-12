import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNITS_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitRuntimeState.gd'
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitFactoryBuildState.gd'
CAN_CREATE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitsCanCreateProof.gd'


class C07UnitsCanCreateTests(unittest.TestCase):
    def test_c07_units_can_create_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2140']['godot_owner'], 'SourceUnitRuntimeState.source_units_can_create_state')
        # Units.canCreate is the C07 entry slice: the first live
        # unit-count evaluation. getCap and countType already have
        # port-bridge pure functions (PortGame.source_unit_cap_state,
        # PortGame.source_unit_count_state); this slice composes
        # them with type.useUnitCap and type.isBanned() into the
        # one canCreate predicate (Units.java:115-117) and wires
        # the assembler should_consume branch and the production
        # tick driver to call it instead of reading
        # frame["can_create"] (default true). Four new result
        # symbols, one per value the predicate returns or derives.
        self.assertEqual(
            ledger['N2140']['source_symbols'],
            [
                'source_units_can_create_state_result.can_create',
                'source_units_can_create_state_result.unit_cap',
                'source_units_can_create_state_result.count_type',
                'source_units_can_create_state_result.is_banned',
            ],
        )
        for name in ledger['N2140']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['godot_owner'], 'SourceUnitRuntimeState.source_units_can_create_state')
                self.assertEqual(symbol['java_source'], {
                    'source_units_can_create_state_result.can_create': 'core/src/mindustry/entities/Units.java',
                    'source_units_can_create_state_result.unit_cap': 'core/src/mindustry/entities/Units.java',
                    'source_units_can_create_state_result.count_type': 'core/src/mindustry/game/Teams.java',
                    'source_units_can_create_state_result.is_banned': 'core/src/mindustry/game/Rules.java',
                }[name])
        self.assertEqual(ledger['N2140']['runtime_proof'], '/root/C07UnitsCanCreateProof')
        self.assertEqual(
            ledger['N2140']['tests'],
            [
                'test_c07_units_can_create_registration',
                'test_all_c07_units_can_create_input_evidence_is_exact',
                'test_units_can_create_state',
                'test_reference_graph_and_actual_c07_units_can_create',
            ],
        )
        self.assertTrue(ledger['N2140']['deferred_exprs'])

    def test_all_c07_units_can_create_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2140']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitRuntimeState.source_units_can_create_state')
        slice_sources = {
            'core/src/mindustry/entities/Units.java',
            'core/src/mindustry/game/Teams.java',
            'core/src/mindustry/type/UnitType.java',
            'core/src/mindustry/game/Rules.java',
            'core/src/mindustry/game/Team.java',
            'core/src/mindustry/core/GameState.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2140']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_units_can_create_state(self):
        state = UNITS_STATE.read_text(encoding='utf-8')
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        # The pure canCreate predicate composes the already-ported
        # cap/count bridges with useUnitCap and isBanned; the
        # assembler should_consume branch and the production tick
        # driver call it instead of the permissive frame default.
        self.assertIn('static func source_units_can_create_state', state)
        self.assertIn('return !type.useUnitCap || (team.data().countType(type) < getCap(team) && !type.isBanned());', state)
        self.assertIn('return Math.max(0, state.rules.unitCapVariable ? state.rules.unitCap + team.data().unitCap : state.rules.unitCap);', state)
        self.assertIn('source_units_can_create_state(', factory)
        self.assertNotIn('needs live per-type unit counts and the unit cap', factory)
        # The canCreate proof's keys drive the pure predicate on
        # bound frames (mace plan, cap 10, counts around the cap).
        proof = CAN_CREATE_PROOF.read_text(encoding='utf-8')
        for key in [
            'can_create_under_cap',
            'can_create_at_cap',
            'can_create_no_cap_type',
            'can_create_banned_unit',
            'can_create_uncapped_wave_team',
            'can_create_variable_cap',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_units_can_create(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitsCanCreateProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNITS_CAN_CREATE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'can_create_under_cap',
            'can_create_at_cap',
            'can_create_no_cap_type',
            'can_create_banned_unit',
            'can_create_uncapped_wave_team',
            'can_create_variable_cap',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
