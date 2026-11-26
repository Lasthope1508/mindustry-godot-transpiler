import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
ROTATION_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BaseTurretBuildRotationProof.gd'

PROOF_KEYS = [
    'field_33_unit_77_returns_33',
    'field_90_default_returns_90',
    'field_0_returns_0',
    'field_negative_passes_through',
    'field_above_360_passes_through',
    'field_fractional_precision',
    'returns_only_one_key',
    'idempotent_second_call',
]


class C07BaseTurretBuildRotationTests(unittest.TestCase):
    def test_c07_base_turret_build_rotation_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2479']['godot_owner'], 'SourceTurretBuildState.source_base_turret_build_rotation_state')
        # BaseTurretBuild.buildRotation() (BaseTurret.java:129-131):
        #     @Override
        #     public float buildRotation(){
        #         return rotation;
        #     }
        # TRAP 1 (field, not unit): this reads the INHERITED
        # `rotation` FIELD (BaseTurret.java:114, `public float
        # rotation = 90;`, default 90) -- the OPPOSITE of
        # N2477 BuildTurretBuild.buildRotation()
        # (BuildTurret.java:107-110, `return unit.rotation();`).
        # The proof pins the cross-trap: field 33 with a unit
        # at 77 returns 33 here, while N2477 returns 77 for
        # the same pair.
        # TRAP 2: no clamp, no angle normalisation -- a
        # negative rotation or one > 360 passes through whole.
        # NOT BaseTurretBuild.range() (N739, bare `range()`,
        # BaseTurret.java:124-126) -- a different method of
        # the same class; do not confuse the two when
        # grepping bare names.
        # GENERIC-LITERAL NOTE: the body literal `return
        # rotation;` is already an exact_expr of N2233
        # (RepairPointBuild.buildRotation(), line Windows),
        # N1839 and N2223 -- a shared RotBlock literal, NOT
        # a port of THIS method; no slice cites it for
        # BaseTurretBuild, so no twin-register approval is
        # required (main thread confirmed 2026-11-27). The
        # register script records the twin-lite note.
        self.assertEqual(
            ledger['N2479']['java_method'],
            'BaseTurretBuild.buildRotation()',
        )
        self.assertEqual(
            ledger['N2479']['source_symbols'],
            [
                'source_base_turret_build_rotation_state_input.rotation',
                'source_base_turret_build_rotation_state_result.build_rotation',
            ],
        )
        for name in ledger['N2479']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_base_turret_build_rotation_state'))
        self.assertEqual(ledger['N2479']['runtime_proof'], '/root/C07BaseTurretBuildRotationProof')
        self.assertEqual(
            ledger['N2479']['tests'],
            [
                'test_c07_base_turret_build_rotation_registration',
                'test_all_c07_base_turret_build_rotation_input_evidence_is_exact',
                'test_base_turret_build_rotation_state',
                'test_reference_graph_and_actual_c07_base_turret_build_rotation',
            ],
        )
        self.assertTrue(ledger['N2479']['deferred_exprs'])

    def test_all_c07_base_turret_build_rotation_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2479']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_base_turret_build_rotation_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2479']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_base_turret_build_rotation_state(self):
        turret_state = TURRET_STATE.read_text(encoding='utf-8')
        # BaseTurretBuild.buildRotation() (BaseTurret.java:129-131):
        #     return rotation;
        # TRAP: the INHERITED field, not the unit -- field 33
        # with a unit at 77 returns 33 (N2477 returns 77 for
        # the same pair). No clamp, no angle normalisation.
        self.assertIn('static func source_base_turret_build_rotation_state(rotation: float) -> Dictionary:', turret_state)
        self.assertIn('return {"build_rotation": rotation}', turret_state)
        # Function order follows Java order: buildRotation()
        # (:129-131) comes before drawSelect() (:133-135)
        # and status() (:143-145) in BaseTurret.java, so
        # source_base_turret_build_rotation_state comes
        # before source_base_turret_build_draw_select_state
        # and source_base_turret_build_status_state in this
        # file. range() (:124-126) sits before buildRotation()
        # in Java but is N739 (bare `range()`, already ported
        # elsewhere) -- it is not a BaseTurretBuild function
        # in this file, so no order pin against it.
        self.assertLess(
            turret_state.index('static func source_base_turret_build_rotation_state('),
            turret_state.index('static func source_base_turret_build_draw_select_state('),
        )
        self.assertLess(
            turret_state.index('static func source_base_turret_build_rotation_state('),
            turret_state.index('static func source_base_turret_build_status_state('),
        )
        # The proof drives the pure function with synthetic
        # field-rotation values (no live tick, no game state):
        # field 33 with a unit at 77 returns 33 (the cross
        # trap against N2477), the 90 default passes through,
        # 0 returns 0, a negative angle and an angle > 360
        # pass through unclamped, a fractional angle is exact,
        # and a repeated call is identical.
        proof = ROTATION_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_base_turret_build_rotation(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BaseTurretBuildRotationProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BASE_TURRET_BUILD_ROTATION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
