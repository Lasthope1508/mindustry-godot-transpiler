import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_AMMO_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourcePayloadAmmoTurretBuildPortBridge.gd'
PAYLOAD_TURRET_GET_AMMO_FRACTION_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadTurretGetAmmoFractionProof.gd'


class C07PayloadTurretGetAmmoFractionTests(unittest.TestCase):
    def test_c07_payload_turret_get_ammo_fraction_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2487']['godot_owner'], 'PortGame.source_payload_ammo_turret_build_get_ammo_fraction_state')
        # PayloadTurretBuild.getAmmoFraction()
        # (PayloadAmmoTurret.java:159-162):
        # `@Override`
        # `public float getAmmoFraction(){`
        # `return (float)totalAmmo / maxAmmo;`
        # `}`
        # on `public class PayloadTurretBuild extends TurretBuild{`
        # (PayloadAmmoTurret.java:94) inside
        # `public class PayloadAmmoTurret extends Turret{`
        # (PayloadAmmoTurret.java:21). This is the
        # PayloadAmmoTurret override: it returns the precomputed
        # totalAmmo (refreshed by updateTile, N2381) over
        # maxAmmo (3, the PayloadAmmoTurret ctor default,
        # PayloadAmmoTurret.java:29) as a float fraction. The
        # body is the SAME expression as ItemTurretBuild
        # .getAmmoFraction() (N1181) -- a GENERIC LITERAL
        # (the N2479 precedent), NOT a twin-register: same
        # body, different class, no shared owner. The
        # displayBars lambda (N2381, PayloadAmmoTurret
        # .java:174) repeats the same arithmetic inside a Bar
        # spec -- it is a DIFFERENT method and is NOT touched
        # here. NO divide-by-zero guard: upstream has none
        # (Java float division by zero yields Infinity -- the
        # N1181 deferred precedent). NO driver line: a pure
        # accessor the HUD caller reads, not a per-tick write.
        # One new result symbol: ammo_fraction. totalAmmo is
        # a precomputed input (the N1181 precedent).
        self.assertEqual(
            ledger['N2487']['source_symbols'],
            [
                'source_payload_ammo_turret_build_get_ammo_fraction_state_result.ammo_fraction',
            ],
        )
        for name in ledger['N2487']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2487']['runtime_proof'], '/root/C07PayloadTurretGetAmmoFractionProof')
        self.assertEqual(
            ledger['N2487']['tests'],
            [
                'test_c07_payload_turret_get_ammo_fraction_registration',
                'test_all_c07_payload_turret_get_ammo_fraction_input_evidence_is_exact',
                'test_payload_turret_get_ammo_fraction_state',
                'test_reference_graph_and_actual_c07_payload_turret_get_ammo_fraction',
            ],
        )
        self.assertTrue(ledger['N2487']['deferred_exprs'])

    def test_all_c07_payload_turret_get_ammo_fraction_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2487']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2487']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_turret_get_ammo_fraction_state(self):
        bridge = PAYLOAD_AMMO_TURRET_BRIDGE.read_text(encoding='utf-8')
        # PayloadTurretBuild.getAmmoFraction()
        # (PayloadAmmoTurret.java:159-162) returns
        # (float)totalAmmo / maxAmmo -- the precomputed
        # totalAmmo over the ctor default maxAmmo 3. No
        # guard: a zero maxAmmo divides by zero exactly
        # like Java float division (Infinity). No clamp:
        # a totalAmmo above maxAmmo passes through above
        # 1.0. NO driver line: a pure accessor, not a
        # per-tick write. Java order: getAmmoFraction
        # (:159) sits right after getAmmoContent (:148),
        # so the GD function sits right after
        # source_payload_ammo_turret_build_get_ammo_content_state.
        self.assertIn('static func source_payload_ammo_turret_build_get_ammo_fraction_state(total_ammo: float, max_ammo: float) -> Dictionary:', bridge)
        self.assertIn('return {"ammo_fraction": ammo_fraction}', bridge)
        self.assertLess(
            bridge.index('static func source_payload_ammo_turret_build_get_ammo_content_state('),
            bridge.index('static func source_payload_ammo_turret_build_get_ammo_fraction_state('),
        )
        for expr in [
            'public class PayloadAmmoTurret extends Turret{',
            'public class PayloadTurretBuild extends TurretBuild{',
            '@Override',
            'public float getAmmoFraction(){',
            'return (float)totalAmmo / maxAmmo;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with
        # synthetic scalar inputs (no live tick): full ammo
        # is 1.0 / partial ammo is one third / empty is
        # 0.0 / overfull is NOT clamped above 1.0 / zero
        # maxAmmo divides to Infinity with no guard /
        # matches the displayBars lambda (N2381) for the
        # same inputs / calling twice gives the same result
        # / the result carries exactly the one key.
        proof = PAYLOAD_TURRET_GET_AMMO_FRACTION_PROOF.read_text(encoding='utf-8')
        for key in [
            'ammo_fraction_full',
            'ammo_fraction_partial',
            'ammo_fraction_empty',
            'ammo_fraction_overfull_unclamped',
            'ammo_fraction_zero_max_ammo_infinity',
            'ammo_fraction_matches_display_bars_lambda',
            'ammo_fraction_idempotent',
            'ammo_fraction_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_payload_turret_get_ammo_fraction(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadTurretGetAmmoFractionProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_TURRET_GET_AMMO_FRACTION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ammo_fraction_full',
            'ammo_fraction_partial',
            'ammo_fraction_empty',
            'ammo_fraction_overfull_unclamped',
            'ammo_fraction_zero_max_ammo_infinity',
            'ammo_fraction_matches_display_bars_lambda',
            'ammo_fraction_idempotent',
            'ammo_fraction_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
