import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
BUILD_ROTATION_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretBuildRotationProof.gd'

PROOF_KEYS = [
    'unit_45_field_90_returns_45',
    'unit_0_returns_0',
    'unit_90_returns_90',
    'unit_negative_passes_through',
    'unit_above_360_passes_through',
    'unit_fractional_precision',
    'returns_only_one_key',
    'idempotent_second_call',
]


class C07BuildTurretBuildRotationTests(unittest.TestCase):
    def test_c07_build_turret_build_rotation_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2477']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_build_rotation_state')
        # BuildTurretBuild.buildRotation() (BuildTurret.java:107-110):
        #     return unit.rotation();
        # unit is the BuildTurretBuild field (BuildTurret.java:93,
        # `public BlockUnitc unit = (BlockUnitc)unitType.create(team);`),
        # initialised to rotation 90f in the instance block
        # (:98-100, `unit.rotation(90f);`). TRAP: this reads the
        # UNIT's rotation, NOT the inherited `rotation` field of
        # BaseTurretBuild (BaseTurret.java:129-131, `return
        # rotation;` -- a DIFFERENT method, backup B, not this
        # slice): updateTile (:121) assigns the field from the
        # unit every tick (`rotation = unit.rotation();`), so
        # between ticks the two can differ, and a port that
        # reads the field is wrong. TRAP: no clamp, no
        # normalisation -- a negative angle or an angle > 360
        # passes through whole (Java has no Math.min/max or
        # angle wrap here). Near names already ported:
        # RepairPointBuild.buildRotation (N2233, Windows line,
        # same RotBlock interface, a different class that DOES
        # read its field) and the RotBlock generic evidence in
        # child-block slices -- neither is this method.
        self.assertEqual(
            ledger['N2477']['java_method'],
            'BuildTurretBuild.buildRotation()',
        )
        self.assertEqual(
            ledger['N2477']['source_symbols'],
            [
                'source_build_turret_build_rotation_state_input.unit_rotation',
                'source_build_turret_build_rotation_state_result.build_rotation',
            ],
        )
        for name in ledger['N2477']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/BuildTurret.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_build_rotation_state'))
        self.assertEqual(ledger['N2477']['runtime_proof'], '/root/C07BuildTurretBuildRotationProof')
        self.assertEqual(
            ledger['N2477']['tests'],
            [
                'test_c07_build_turret_build_rotation_registration',
                'test_all_c07_build_turret_build_rotation_input_evidence_is_exact',
                'test_build_turret_build_rotation_state',
                'test_reference_graph_and_actual_c07_build_turret_build_rotation',
            ],
        )
        self.assertTrue(ledger['N2477']['deferred_exprs'])

    def test_all_c07_build_turret_build_rotation_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2477']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_build_rotation_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2477']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_build_rotation_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # BuildTurretBuild.buildRotation() (BuildTurret.java:107-110):
        #     return unit.rotation();
        # TRAP: read the UNIT's rotation, not the inherited
        # `rotation` field -- a port returning `rotation`
        # (the BaseTurretBuild field) is wrong. TRAP: no
        # clamp/normalisation -- negative and > 360 angles
        # pass through whole.
        self.assertIn('static func source_build_turret_build_rotation_state(unit_rotation: float) -> Dictionary:', build_turret)
        self.assertIn('return {"build_rotation": unit_rotation}', build_turret)
        # Function order follows Java order: canControl()
        # (:103-105, unported) and buildRotation() (:107-110)
        # come before updateTile() (:121-139), whose GD owner
        # is source_build_turret_power_status_row_state
        # (N2184), which comes before shouldConsume()
        # (:229-230, source_build_turret_should_consume_state),
        # so the new function sits before both of those in
        # this file.
        self.assertLess(
            build_turret.index('static func source_build_turret_build_rotation_state('),
            build_turret.index('static func source_build_turret_power_status_row_state('),
        )
        self.assertLess(
            build_turret.index('static func source_build_turret_build_rotation_state('),
            build_turret.index('static func source_build_turret_should_consume_state('),
        )
        # The proof drives the pure function with synthetic
        # unit-rotation values (no live tick, no game state):
        # the key trap case is a unit at 45 degrees while
        # the inherited field sits at its 90-degree default
        # -- the result must be 45, not 90; 0 -> 0.0,
        # 90 -> 90, a negative angle passes through, an
        # angle > 360 passes through, 33.75 stays exact,
        # the result has exactly one key, and a second call
        # with the same input gives the same output.
        proof = BUILD_ROTATION_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_build_turret_build_rotation(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretBuildRotationProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_BUILD_ROTATION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
