import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_DEFAULTS = ROOT / 'godot-mindustry/src/game/SourceTurretDefaults.gd'
DEFAULT_CTOR_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretDefaultConstructorProof.gd'


class C07TurretDefaultConstructorTests(unittest.TestCase):
    def test_c07_turret_default_constructor_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2400']['godot_owner'], 'SourceTurretDefaults.source_turret_default_constructor_state')
        # Turret(String name) (Turret.java:157-171), one ctor
        # slice (batch 25 slot 1): the 10 literal field
        # defaults only. `super(name);` is already the
        # exact_expr of N2185, `liquidCapacity = 20f;` of
        # N2085/N2089/N2091, `rotate = true;` of
        # N2091/N2180/N2181 -- none is re-registered here.
        # One GD function on SourceTurretDefaults.gd (the
        # Turret def-defaults file, NOT
        # SourceTurretBuildState.gd, which is the
        # TurretBuild file); the Teams ctor batch 24
        # precedent (owner
        # `source_teams_default_constructor_state`). The
        # defaults are frame data only (bool/int/float
        # literals); no Draw is ported.
        self.assertEqual(
            ledger['N2400']['java_method'],
            'Turret(String name)',
        )
        self.assertEqual(
            ledger['N2400']['source_symbols'],
            [
                'source_turret_default_constructor_state_result.outlined_icon',
                'source_turret_default_constructor_state_result.draw_liquid_light',
                'source_turret_default_constructor_state_result.sync',
                'source_turret_default_constructor_state_result.quick_rotate',
                'source_turret_default_constructor_state_result.draw_arrow',
                'source_turret_default_constructor_state_result.ignore_line_rotation',
                'source_turret_default_constructor_state_result.rotate_draw_editor',
                'source_turret_default_constructor_state_result.visual_rotation_offset',
                'source_turret_default_constructor_state_result.region_rotated_1',
                'source_turret_default_constructor_state_result.region_rotated_2',
                'source_turret_default_constructor_state_result.turret_defaults',
            ],
        )
        for name in ledger['N2400']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretDefaults.source_turret_default_constructor_state'))
        self.assertEqual(ledger['N2400']['runtime_proof'], '/root/C07TurretDefaultConstructorProof')
        self.assertEqual(
            ledger['N2400']['tests'],
            [
                'test_c07_turret_default_constructor_registration',
                'test_all_c07_turret_default_constructor_input_evidence_is_exact',
                'test_turret_default_constructor_state',
                'test_reference_graph_and_actual_c07_turret_default_constructor',
            ],
        )
        self.assertTrue(ledger['N2400']['deferred_exprs'])

    def test_all_c07_turret_default_constructor_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2400']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretDefaults.source_turret_default_constructor_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2400']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_default_constructor_state(self):
        defaults = TURRET_DEFAULTS.read_text(encoding='utf-8')
        # Turret(String name) (Turret.java:157-171): the ctor
        # assigns 10 literal field defaults on the Turret
        # def; the 3 other lines are owned elsewhere (see the
        # registration test) and are NOT re-registered.
        self.assertIn('static func source_turret_default_constructor_state(turret_defaults: Dictionary) -> Dictionary:', defaults)
        for expr in [
            'outlinedIcon = 1;',
            'drawLiquidLight = false;',
            'sync = true;',
            'quickRotate = false;',
            'drawArrow = false;',
            'ignoreLineRotation = true;',
            'rotateDrawEditor = false;',
            'visualRotationOffset = -90f;',
            'regionRotated1 = 1;',
            'regionRotated2 = 2;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, defaults)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick, no render): one
        # call returns all 10 ctor literals, writes them
        # into the def frame, preserves unrelated frame
        # keys, overwrites stale frame values, and is
        # idempotent on a second call.
        proof = DEFAULT_CTOR_PROOF.read_text(encoding='utf-8')
        for key in [
            'ctor_defaults_all_ten',
            'ctor_returns_only_eleven_keys',
            'ctor_writes_frame',
            'ctor_preserves_existing_frame_keys',
            'ctor_overwrites_stale_frame_values',
            'ctor_bool_defaults',
            'ctor_visual_rotation_offset_negative_ninety',
            'ctor_region_rotated_pair',
            'ctor_outlined_icon_one',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_default_constructor(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretDefaultConstructorProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_DEFAULT_CONSTRUCTOR_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ctor_defaults_all_ten',
            'ctor_returns_only_eleven_keys',
            'ctor_writes_frame',
            'ctor_preserves_existing_frame_keys',
            'ctor_overwrites_stale_frame_values',
            'ctor_bool_defaults',
            'ctor_visual_rotation_offset_negative_ninety',
            'ctor_region_rotated_pair',
            'ctor_outlined_icon_one',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
