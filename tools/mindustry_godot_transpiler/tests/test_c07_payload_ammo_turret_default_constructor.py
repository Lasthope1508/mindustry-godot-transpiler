import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_AMMO_TURRET_BUILD = ROOT / 'godot-mindustry/src/game/SourcePayloadAmmoTurretBuildPortBridge.gd'
DEFAULT_CTOR_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadAmmoTurretDefaultConstructorProof.gd'


class C07PayloadAmmoTurretDefaultConstructorTests(unittest.TestCase):
    def test_c07_payload_ammo_turret_default_constructor_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2416']['godot_owner'], 'PortGame.source_payload_ammo_turret_default_constructor_state')
        # PayloadAmmoTurret(String name)
        # (PayloadAmmoTurret.java:26-33), one ctor
        # slice (batch 30 slot 3): the 1 distinguishing
        # field default only. `super(name);` is already
        # the exact_expr of N2185 and `acceptsPayload =
        # true;` of N2168 -- neither is re-registered
        # here. One GD function on
        # SourcePayloadAmmoTurretBuildPortBridge.gd (the
        # PayloadAmmoTurret file, NOT a new file -- main
        # decision batch 30, N2406/N2413 ctor precedent).
        # The owner is PortGame.* (this file is a
        # PortBridge -- N2358/N2384/N2396 precedent), NOT
        # the file class name. The default is frame data
        # only (one int param); no Draw is ported.
        self.assertEqual(
            ledger['N2416']['java_method'],
            'PayloadAmmoTurret(String name)',
        )
        self.assertEqual(
            ledger['N2416']['source_symbols'],
            [
                'source_payload_ammo_turret_default_constructor_state_result.max_ammo',
                'source_payload_ammo_turret_default_constructor_state_result.payload_ammo_turret_defaults',
            ],
        )
        for name in ledger['N2416']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('PortGame.source_payload_ammo_turret_default_constructor_state'))
        self.assertEqual(ledger['N2416']['runtime_proof'], '/root/C07PayloadAmmoTurretDefaultConstructorProof')
        self.assertEqual(
            ledger['N2416']['tests'],
            [
                'test_c07_payload_ammo_turret_default_constructor_registration',
                'test_all_c07_payload_ammo_turret_default_constructor_input_evidence_is_exact',
                'test_payload_ammo_turret_default_constructor_state',
                'test_reference_graph_and_actual_c07_payload_ammo_turret_default_constructor',
            ],
        )
        self.assertTrue(ledger['N2416']['deferred_exprs'])

    def test_all_c07_payload_ammo_turret_default_constructor_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2416']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('PortGame.source_payload_ammo_turret_default_constructor_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2416']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_ammo_turret_default_constructor_state(self):
        defaults = PAYLOAD_AMMO_TURRET_BUILD.read_text(encoding='utf-8')
        # PayloadAmmoTurret(String name)
        # (PayloadAmmoTurret.java:26-33): the ctor assigns
        # 1 distinguishing field default on the
        # PayloadAmmoTurret def; the 2 other lines are
        # owned elsewhere (see the registration test) and
        # are NOT re-registered.
        self.assertIn('static func source_payload_ammo_turret_default_constructor_state(payload_ammo_turret_defaults: Dictionary, max_ammo: int) -> Dictionary:', defaults)
        for expr in [
            'maxAmmo = 3;',
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
            'ctor_defaults_max_ammo',
            'ctor_returns_only_two_keys',
            'ctor_writes_frame',
            'ctor_preserves_existing_frame_keys',
            'ctor_overwrites_stale_frame_values',
            'ctor_max_ammo_passthrough',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_payload_ammo_turret_default_constructor(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadAmmoTurretDefaultConstructorProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_AMMO_TURRET_DEFAULT_CONSTRUCTOR_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ctor_defaults_max_ammo',
            'ctor_returns_only_two_keys',
            'ctor_writes_frame',
            'ctor_preserves_existing_frame_keys',
            'ctor_overwrites_stale_frame_values',
            'ctor_max_ammo_passthrough',
            'ctor_idempotent_second_call',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
