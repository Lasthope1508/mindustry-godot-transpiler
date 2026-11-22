import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONTINUOUS_LIQUID_TURRET_BUILD = ROOT / 'godot-mindustry/src/game/SourceContinuousLiquidTurretBuildState.gd'
DEFAULT_CTOR_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ContinuousLiquidTurretDefaultConstructorProof.gd'


class C07ContinuousLiquidTurretDefaultConstructorTests(unittest.TestCase):
    def test_c07_continuous_liquid_turret_default_constructor_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2413']['godot_owner'], 'SourceContinuousLiquidTurretBuildState.source_continuous_liquid_turret_default_constructor_state')
        # ContinuousLiquidTurret(String name)
        # (ContinuousLiquidTurret.java:17-24), one ctor
        # slice (batch 29 slot 3): the 1 distinguishing
        # field default only. `super(name);` is already
        # the exact_expr of N2185, `hasLiquids = true;`
        # of N927/N2000/N2179/N2182/N2209, and
        # `shootSound = Sounds.none;` / `smokeEffect =
        # Fx.none;` / `shootEffect = Fx.none;` of N2406
        # (LiquidTurret ctor) -- none is re-registered
        # here. One GD function on
        # SourceContinuousLiquidTurretBuildState.gd (the
        # ContinuousLiquidTurret def-defaults file, NOT a
        # new file -- main-thread decision batch 29, N2406
        # precedent). The default is frame data only (one
        # Sound param); no Draw is ported, and the
        # ambient-sound driver (N2304, HELD) is untouched.
        self.assertEqual(
            ledger['N2413']['java_method'],
            'ContinuousLiquidTurret(String name)',
        )
        self.assertEqual(
            ledger['N2413']['source_symbols'],
            [
                'source_continuous_liquid_turret_default_constructor_state_result.loop_sound',
                'source_continuous_liquid_turret_default_constructor_state_result.continuous_liquid_turret_defaults',
            ],
        )
        for name in ledger['N2413']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceContinuousLiquidTurretBuildState.source_continuous_liquid_turret_default_constructor_state'))
        self.assertEqual(ledger['N2413']['runtime_proof'], '/root/C07ContinuousLiquidTurretDefaultConstructorProof')
        self.assertEqual(
            ledger['N2413']['tests'],
            [
                'test_c07_continuous_liquid_turret_default_constructor_registration',
                'test_all_c07_continuous_liquid_turret_default_constructor_input_evidence_is_exact',
                'test_continuous_liquid_turret_default_constructor_state',
                'test_reference_graph_and_actual_c07_continuous_liquid_turret_default_constructor',
            ],
        )
        self.assertTrue(ledger['N2413']['deferred_exprs'])

    def test_all_c07_continuous_liquid_turret_default_constructor_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2413']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceContinuousLiquidTurretBuildState.source_continuous_liquid_turret_default_constructor_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2413']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_continuous_liquid_turret_default_constructor_state(self):
        defaults = CONTINUOUS_LIQUID_TURRET_BUILD.read_text(encoding='utf-8')
        # ContinuousLiquidTurret(String name)
        # (ContinuousLiquidTurret.java:17-24): the ctor
        # assigns 1 distinguishing field default on the
        # ContinuousLiquidTurret def; the 5 other lines
        # are owned elsewhere (see the registration test)
        # and are NOT re-registered.
        self.assertIn('static func source_continuous_liquid_turret_default_constructor_state(continuous_liquid_turret_defaults: Dictionary, loop_sound: Variant) -> Dictionary:', defaults)
        for expr in [
            'loopSound = Sounds.loopMineBeam;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, defaults)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick, no render): one
        # call returns the ctor default, writes it into
        # the def frame, preserves unrelated frame keys,
        # overwrites a stale frame value, and is
        # idempotent on a second call.
        proof = DEFAULT_CTOR_PROOF.read_text(encoding='utf-8')
        for key in [
            'ctor_defaults_loop_sound',
            'ctor_returns_only_two_keys',
            'ctor_writes_frame',
            'ctor_preserves_existing_frame_keys',
            'ctor_overwrites_stale_frame_values',
            'ctor_loop_sound_passthrough',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_continuous_liquid_turret_default_constructor(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ContinuousLiquidTurretDefaultConstructorProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_CONTINUOUS_LIQUID_TURRET_DEFAULT_CONSTRUCTOR_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ctor_defaults_loop_sound',
            'ctor_returns_only_two_keys',
            'ctor_writes_frame',
            'ctor_preserves_existing_frame_keys',
            'ctor_overwrites_stale_frame_values',
            'ctor_loop_sound_passthrough',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
