import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
CAN_CONTROL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretCanControlProof.gd'

PROOF_KEYS = [
    'can_control_is_true',
    'player_controllable_false_still_true',
    'player_controllable_true_still_true',
    'parent_can_control_differs_when_false',
    'parent_can_control_matches_when_true',
    'returns_only_one_key',
    'idempotent_second_call',
    'constant_across_repeated_calls',
]


class C07BuildTurretCanControlTests(unittest.TestCase):
    def test_c07_build_turret_can_control_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2480']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_can_control_state')
        # BuildTurretBuild.canControl() (BuildTurret.java:103-105):
        #     return true;
        # on `public class BuildTurretBuild extends
        # BaseTurretBuild implements ControlBlock, RotBlock{`
        # (BuildTurret.java:92). The build tower is ALWAYS
        # controllable -- ControlBlock with no gate -- so the
        # method returns the constant true and reads NO
        # state: no unit, no player, no logic, no block
        # field. TRAP: this is NOT TurretBuild.canControl()
        # (N2297, Turret.java:376-378, `return
        # playerControllable;` -- the block-level field
        # `public boolean playerControllable = true;`,
        # Turret.java:97, which a def can set false): a
        # block with playerControllable = false still
        # returns true here and false in N2297. TRAP: this
        # is NOT TurretBuild.controlled() (N2324/N2523,
        # `return unit.isPlayer();`) -- canControl is about
        # the block being controllable, controlled is about
        # who holds it now. Zero params: canControl() takes
        # no state (the N2422 zero-param contract precedent
        # -- result schema only, no input schema).
        self.assertEqual(
            ledger['N2480']['java_method'],
            'BuildTurretBuild.canControl()',
        )
        self.assertEqual(
            ledger['N2480']['source_symbols'],
            [
                'source_build_turret_can_control_state_result.can_control',
            ],
        )
        for name in ledger['N2480']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/BuildTurret.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_can_control_state'))
        self.assertEqual(ledger['N2480']['runtime_proof'], '/root/C07BuildTurretCanControlProof')
        self.assertEqual(
            ledger['N2480']['tests'],
            [
                'test_c07_build_turret_can_control_registration',
                'test_all_c07_build_turret_can_control_input_evidence_is_exact',
                'test_build_turret_can_control_state',
                'test_reference_graph_and_actual_c07_build_turret_can_control',
            ],
        )
        self.assertTrue(ledger['N2480']['deferred_exprs'])

    def test_all_c07_build_turret_can_control_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2480']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_can_control_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2480']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_can_control_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # BuildTurretBuild.canControl() (BuildTurret.java:103-105):
        #     return true;
        # TRAP: a port returning `player_controllable`
        # (the TurretBuild.canControl() body, N2297) is wrong
        # -- this method ignores the block field entirely.
        # TRAP: a port returning `unit.isPlayer()` (the
        # controlled() body, N2324/N2523) is wrong -- this
        # is about being controllable, not who holds it.
        self.assertIn('static func source_build_turret_can_control_state() -> Dictionary:', build_turret)
        self.assertIn('return {"can_control": true}', build_turret)
        # Function order follows Java order: canControl()
        # (:103-105) comes before buildRotation() (:107-110,
        # N2477, source_build_turret_build_rotation_state),
        # which comes before updateTile() (:121-139, N2184,
        # source_build_turret_power_status_row_state), so the
        # new function sits before both of those in this file.
        self.assertLess(
            build_turret.index('static func source_build_turret_can_control_state('),
            build_turret.index('static func source_build_turret_build_rotation_state('),
        )
        self.assertLess(
            build_turret.index('static func source_build_turret_can_control_state('),
            build_turret.index('static func source_build_turret_power_status_row_state('),
        )
        # The proof drives the pure function with no inputs
        # (no live tick, no game state): the key trap case is
        # a block with playerControllable = false -- the
        # result must still be true, while the parent
        # TurretBuild.canControl() (N2297) returns false for
        # the same input; both return true when
        # playerControllable is true; the result has exactly
        # one key; a second call with no input gives the same
        # output; and repeated calls stay constant.
        proof = CAN_CONTROL_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_build_turret_can_control(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretCanControlProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_CAN_CONTROL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
