import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONTINUOUS_TURRET_DEFAULTS = ROOT / 'godot-mindustry/src/game/SourceContinuousTurretDefaults.gd'
DEFAULT_CTOR_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ContinuousTurretDefaultConstructorProof.gd'


class C07ContinuousTurretDefaultConstructorTests(unittest.TestCase):
    def test_c07_continuous_turret_default_constructor_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2407']['godot_owner'], 'SourceContinuousTurretDefaults.source_continuous_turret_default_constructor_state')
        # ContinuousTurret(String name) (ContinuousTurret.java:20-25), one
        # ctor slice (batch 27 slot 2): the 2 literal field defaults
        # only. `super(name);` and `envEnabled |= Env.space;` are
        # already exact_exprs of N2185 -- neither is re-registered
        # here. One GD function on the NEW
        # SourceContinuousTurretDefaults.gd (the ContinuousTurret
        # def-defaults file, NOT
        # SourceContinuousTurretBuildPortBridge.gd, which is the
        # ContinuousTurretBuild file); the Turret ctor batch 25
        # precedent (owner `source_turret_default_constructor_state`
        # on SourceTurretDefaults.gd) and the BaseTurret ctor batch
        # 26 precedent (SourceBaseTurretDefaults.gd).
        # `coolantMultiplier = 1f;` also appears in the
        # LaserTurret() and TractorBeamTurret() ctors -- the
        # register records java_method `ContinuousTurret(String
        # name)` so this slice owns only the ContinuousTurret
        # leg. The defaults are frame data only (one float
        # literal + one bool literal); no Draw is ported.
        self.assertEqual(
            ledger['N2407']['java_method'],
            'ContinuousTurret(String name)',
        )
        self.assertEqual(
            ledger['N2407']['source_symbols'],
            [
                'source_continuous_turret_default_constructor_state_result.coolant_multiplier',
                'source_continuous_turret_default_constructor_state_result.display_ammo_multiplier',
                'source_continuous_turret_default_constructor_state_result.continuous_turret_defaults',
            ],
        )
        for name in ledger['N2407']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceContinuousTurretDefaults.source_continuous_turret_default_constructor_state'))
        self.assertEqual(ledger['N2407']['runtime_proof'], '/root/C07ContinuousTurretDefaultConstructorProof')
        self.assertEqual(
            ledger['N2407']['tests'],
            [
                'test_c07_continuous_turret_default_constructor_registration',
                'test_all_c07_continuous_turret_default_constructor_input_evidence_is_exact',
                'test_continuous_turret_default_constructor_state',
                'test_reference_graph_and_actual_c07_continuous_turret_default_constructor',
            ],
        )
        self.assertTrue(ledger['N2407']['deferred_exprs'])

    def test_all_c07_continuous_turret_default_constructor_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2407']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceContinuousTurretDefaults.source_continuous_turret_default_constructor_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2407']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_continuous_turret_default_constructor_state(self):
        defaults = CONTINUOUS_TURRET_DEFAULTS.read_text(encoding='utf-8')
        # ContinuousTurret(String name) (ContinuousTurret.java:20-25):
        # the ctor assigns 2 literal field defaults on the
        # ContinuousTurret def; the 2 other lines are owned
        # by N2185 (see the registration test) and are NOT
        # re-registered.
        self.assertIn('static func source_continuous_turret_default_constructor_state(continuous_turret_defaults: Dictionary) -> Dictionary:', defaults)
        for expr in [
            'coolantMultiplier = 1f;',
            'displayAmmoMultiplier = false;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, defaults)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick, no render): one
        # call returns both ctor defaults, writes them
        # into the def frame, preserves unrelated frame
        # keys, overwrites stale frame values, and is
        # idempotent on a second call.
        proof = DEFAULT_CTOR_PROOF.read_text(encoding='utf-8')
        for key in [
            'ctor_defaults_both',
            'ctor_returns_only_three_keys',
            'ctor_writes_frame',
            'ctor_preserves_existing_frame_keys',
            'ctor_overwrites_stale_frame_values',
            'ctor_coolant_one_float',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_continuous_turret_default_constructor(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ContinuousTurretDefaultConstructorProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_CONTINUOUS_TURRET_DEFAULT_CONSTRUCTOR_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ctor_defaults_both',
            'ctor_returns_only_three_keys',
            'ctor_writes_frame',
            'ctor_preserves_existing_frame_keys',
            'ctor_overwrites_stale_frame_values',
            'ctor_coolant_one_float',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
