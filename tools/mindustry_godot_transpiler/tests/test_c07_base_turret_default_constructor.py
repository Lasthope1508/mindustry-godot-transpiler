import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE_TURRET_DEFAULTS = ROOT / 'godot-mindustry/src/game/SourceBaseTurretDefaults.gd'
DEFAULT_CTOR_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BaseTurretDefaultConstructorProof.gd'


class C07BaseTurretDefaultConstructorTests(unittest.TestCase):
    def test_c07_base_turret_default_constructor_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2405']['godot_owner'], 'SourceBaseTurretDefaults.source_base_turret_default_constructor_state')
        # BaseTurret(String name) (BaseTurret.java:36-46), one ctor
        # slice (batch 26 slot 3): the 4 literal field
        # defaults only. `super(name);` is already the
        # exact_expr of N2185, `update = true;` of 22
        # slices, `solid = true;` of 11 slices,
        # `group = BlockGroup.turrets;` of N2184 -- none
        # is re-registered here. One GD function on the
        # NEW SourceBaseTurretDefaults.gd (the BaseTurret
        # def-defaults file, NOT SourceTurretBuildState.gd,
        # which is the TurretBuild file); the Turret ctor
        # batch 25 precedent (owner
        # `source_turret_default_constructor_state` on
        # SourceTurretDefaults.gd). The defaults are frame
        # data only (bool/float literals + one enum param);
        # no Draw is ported.
        self.assertEqual(
            ledger['N2405']['java_method'],
            'BaseTurret(String name)',
        )
        self.assertEqual(
            ledger['N2405']['source_symbols'],
            [
                'source_base_turret_default_constructor_state_result.outline_icon',
                'source_base_turret_default_constructor_state_result.attacks',
                'source_base_turret_default_constructor_state_result.priority',
                'source_base_turret_default_constructor_state_result.flags',
                'source_base_turret_default_constructor_state_result.base_turret_defaults',
            ],
        )
        for name in ledger['N2405']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/world/meta/BlockFlag.java',
                    'core/src/mindustry/entities/TargetPriority.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceBaseTurretDefaults.source_base_turret_default_constructor_state'))
        self.assertEqual(ledger['N2405']['runtime_proof'], '/root/C07BaseTurretDefaultConstructorProof')
        self.assertEqual(
            ledger['N2405']['tests'],
            [
                'test_c07_base_turret_default_constructor_registration',
                'test_all_c07_base_turret_default_constructor_input_evidence_is_exact',
                'test_base_turret_default_constructor_state',
                'test_reference_graph_and_actual_c07_base_turret_default_constructor',
            ],
        )
        self.assertTrue(ledger['N2405']['deferred_exprs'])

    def test_all_c07_base_turret_default_constructor_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2405']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceBaseTurretDefaults.source_base_turret_default_constructor_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/meta/BlockFlag.java',
            'core/src/mindustry/entities/TargetPriority.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2405']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_base_turret_default_constructor_state(self):
        defaults = BASE_TURRET_DEFAULTS.read_text(encoding='utf-8')
        # BaseTurret(String name) (BaseTurret.java:36-46): the
        # ctor assigns 4 literal field defaults on the
        # BaseTurret def; the 3 other lines are owned
        # elsewhere (see the registration test) and are NOT
        # re-registered.
        self.assertIn('static func source_base_turret_default_constructor_state(base_turret_defaults: Dictionary, block_flags: Variant) -> Dictionary:', defaults)
        for expr in [
            'outlineIcon = true;',
            'attacks = true;',
            'priority = TargetPriority.turret;',
            'flags = EnumSet.of(BlockFlag.turret);',
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
            'ctor_priority_one_float',
            'ctor_flags_passthrough',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_base_turret_default_constructor(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BaseTurretDefaultConstructorProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BASE_TURRET_DEFAULT_CONSTRUCTOR_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ctor_defaults_all_four',
            'ctor_returns_only_five_keys',
            'ctor_writes_frame',
            'ctor_preserves_existing_frame_keys',
            'ctor_overwrites_stale_frame_values',
            'ctor_priority_one_float',
            'ctor_flags_passthrough',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
