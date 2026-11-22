import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIQUID_TURRET_BUILD = ROOT / 'godot-mindustry/src/game/SourceLiquidTurretBuildState.gd'
DEFAULT_CTOR_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidTurretDefaultConstructorProof.gd'


class C07LiquidTurretDefaultConstructorTests(unittest.TestCase):
    def test_c07_liquid_turret_default_constructor_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2406']['godot_owner'], 'SourceLiquidTurretBuildState.source_liquid_turret_default_constructor_state')
        # LiquidTurret(String name) (LiquidTurret.java:22-29), one ctor
        # slice (batch 27 slot 1): the 4 literal field
        # defaults only. `super(name);` is already the
        # exact_expr of N2185, `hasLiquids = true;` of
        # N927/N2000/N2179/N2182/N2209 -- none is
        # re-registered here. One GD function on
        # SourceLiquidTurretBuildState.gd (the LiquidTurret
        # def-defaults file, NOT a new file -- the
        # LiquidTurret def lives in the BuildState file,
        # unlike BaseTurret which got its own defaults
        # file at N2405). The defaults are frame data
        # only (two Sound params + two Effect params);
        # no Draw is ported, and the ambient-sound driver
        # (N2304, HELD) is untouched.
        self.assertEqual(
            ledger['N2406']['java_method'],
            'LiquidTurret(String name)',
        )
        self.assertEqual(
            ledger['N2406']['source_symbols'],
            [
                'source_liquid_turret_default_constructor_state_result.loop_sound',
                'source_liquid_turret_default_constructor_state_result.shoot_sound',
                'source_liquid_turret_default_constructor_state_result.smoke_effect',
                'source_liquid_turret_default_constructor_state_result.shoot_effect',
                'source_liquid_turret_default_constructor_state_result.liquid_turret_defaults',
            ],
        )
        for name in ledger['N2406']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceLiquidTurretBuildState.source_liquid_turret_default_constructor_state'))
        self.assertEqual(ledger['N2406']['runtime_proof'], '/root/C07LiquidTurretDefaultConstructorProof')
        self.assertEqual(
            ledger['N2406']['tests'],
            [
                'test_c07_liquid_turret_default_constructor_registration',
                'test_all_c07_liquid_turret_default_constructor_input_evidence_is_exact',
                'test_liquid_turret_default_constructor_state',
                'test_reference_graph_and_actual_c07_liquid_turret_default_constructor',
            ],
        )
        self.assertTrue(ledger['N2406']['deferred_exprs'])

    def test_all_c07_liquid_turret_default_constructor_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2406']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceLiquidTurretBuildState.source_liquid_turret_default_constructor_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2406']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_liquid_turret_default_constructor_state(self):
        defaults = LIQUID_TURRET_BUILD.read_text(encoding='utf-8')
        # LiquidTurret(String name) (LiquidTurret.java:22-29): the
        # ctor assigns 4 field defaults on the LiquidTurret
        # def; the 2 other lines are owned elsewhere (see
        # the registration test) and are NOT re-registered.
        self.assertIn('static func source_liquid_turret_default_constructor_state(liquid_turret_defaults: Dictionary, loop_sound: Variant, shoot_sound: Variant, smoke_effect: Variant, shoot_effect: Variant) -> Dictionary:', defaults)
        for expr in [
            'loopSound = Sounds.loopSpray;',
            'shootSound = Sounds.none;',
            'smokeEffect = Fx.none;',
            'shootEffect = Fx.none;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, defaults)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick, no render): one
        # call returns all 4 ctor defaults, writes them
        # into the def frame, preserves unrelated frame
        # keys, overwrites stale frame values, and is
        # idempotent on a second call.
        proof = DEFAULT_CTOR_PROOF.read_text(encoding='utf-8')
        for key in [
            'ctor_defaults_all_four',
            'ctor_returns_only_five_keys',
            'ctor_writes_frame',
            'ctor_preserves_existing_frame_keys',
            'ctor_overwrites_stale_frame_values',
            'ctor_sounds_passthrough',
            'ctor_effects_passthrough',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_liquid_turret_default_constructor(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LiquidTurretDefaultConstructorProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIQUID_TURRET_DEFAULT_CONSTRUCTOR_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ctor_defaults_all_four',
            'ctor_returns_only_five_keys',
            'ctor_writes_frame',
            'ctor_preserves_existing_frame_keys',
            'ctor_overwrites_stale_frame_values',
            'ctor_sounds_passthrough',
            'ctor_effects_passthrough',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
