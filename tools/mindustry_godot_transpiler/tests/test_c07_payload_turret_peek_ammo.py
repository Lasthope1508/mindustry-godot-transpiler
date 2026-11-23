import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_AMMO_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourcePayloadAmmoTurretBuildPortBridge.gd'
PAYLOAD_AMMO_TURRET_PEEK_AMMO_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadTurretPeekAmmoProof.gd'


class C07PayloadTurretPeekAmmoTests(unittest.TestCase):
    def test_c07_payload_turret_peek_ammo_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2371']['godot_owner'], 'PortGame.source_payload_turret_build_peek_ammo_state')
        # PayloadTurretBuild.peekAmmo()
        # (PayloadAmmoTurret.java:133-140):
        # `public BulletType peekAmmo(){`
        # `for(var content : ammoKeys){`
        # `if(payloads.contains(content)){`
        # `return ammoTypes.get(content);`
        # `}`
        # `}`
        # `return null;`
        # `}`
        # on `public class PayloadTurretBuild extends TurretBuild{`
        # (PayloadAmmoTurret.java:94) inside
        # `public class PayloadAmmoTurret extends Turret{`
        # (PayloadAmmoTurret.java:21). This is the
        # PayloadAmmoTurret override: it returns the BulletType
        # of the first ammo key (in ammoKeys order) whose
        # content is currently held in the payloads seq, or
        # null when none matches -- WITHOUT removing the
        # content (unlike useAmmo N2363, which consumes it).
        # The distinguishing line against useAmmo (N2363) in
        # the same class is the ABSENCE of
        # `payloads.remove(content);`: peekAmmo returns the
        # same BulletType useAmmo returns, but leaves the
        # payloads seq untouched. Against getAmmoContent
        # (N2368): peekAmmo returns a BulletType through
        # `return ammoTypes.get(content);`, not the content
        # itself. The shared loop/guard lines
        # `for(var content : ammoKeys){` and
        # `if(payloads.contains(content)){` are text-shared
        # with N2358/N2363/N2368 (same class, different
        # methods) -- the N632-N639 vs N1078-N1085 precedent
        # allows the same text under its own java_method.
        # The payloads.contains lookup is NOT ported: the
        # payload contents arrive as the explicit
        # payload_contents param and ammoKeys as the explicit
        # ammo_keys param (the N2330 param precedent);
        # ammoTypes arrives as the explicit ammo_types
        # Dictionary param (content name -> bullet type name).
        # Content refs and bullet types are plain strings
        # here; the result is the bullet type name or null.
        # NO driver line: a pure function the shoot path
        # calls, not a per-tick write.
        # One new result symbol: peeked_ammo.
        self.assertEqual(
            ledger['N2371']['source_symbols'],
            [
                'source_payload_turret_build_peek_ammo_state_result.peeked_ammo',
            ],
        )
        for name in ledger['N2371']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2371']['runtime_proof'], '/root/C07PayloadTurretPeekAmmoProof')
        self.assertEqual(
            ledger['N2371']['tests'],
            [
                'test_c07_payload_turret_peek_ammo_registration',
                'test_all_c07_payload_turret_peek_ammo_input_evidence_is_exact',
                'test_payload_turret_peek_ammo_state',
                'test_reference_graph_and_actual_c07_payload_turret_peek_ammo',
            ],
        )
        self.assertTrue(ledger['N2371']['deferred_exprs'])

    def test_all_c07_payload_turret_peek_ammo_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2371']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2371']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_turret_peek_ammo_state(self):
        bridge = PAYLOAD_AMMO_TURRET_BRIDGE.read_text(encoding='utf-8')
        # PayloadTurretBuild.peekAmmo()
        # (PayloadAmmoTurret.java:133-140) returns the
        # BulletType of the first ammo key in ammoKeys order
        # whose content is held in payloads, or null when
        # none matches -- WITHOUT removing the content
        # (unlike useAmmo). It returns a BulletType via
        # ammoTypes, not the content itself (unlike
        # getAmmoContent). NO driver line: a pure function,
        # not a per-tick write.
        self.assertIn('static func source_payload_turret_build_peek_ammo_state(ammo_keys: Array, payload_contents: Array, ammo_types: Dictionary) -> Dictionary:', bridge)
        self.assertIn('return {"peeked_ammo": peeked_ammo}', bridge)
        for expr in [
            'public class PayloadAmmoTurret extends Turret{',
            'public class PayloadTurretBuild extends TurretBuild{',
            'public PayloadSeq payloads = new PayloadSeq();',
            'ammoKeys = ammoTypes.keys().toSeq().toArray(UnlockableContent.class);',
            'public BulletType peekAmmo(){',
            'for(var content : ammoKeys){',
            'if(payloads.contains(content)){',
            'return ammoTypes.get(content);',
            'return null;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick): first match in
        # ammoKeys order / order beats payload order / empty
        # payloads returns null / no match returns null /
        # calling twice gives the same result (nothing is
        # removed, unlike useAmmo) / duplicate held content
        # still returns the first match / held content with
        # no ammoTypes entry returns null / inputs are not
        # mutated by the call / the result carries exactly
        # the one key.
        proof = PAYLOAD_AMMO_TURRET_PEEK_AMMO_PROOF.read_text(encoding='utf-8')
        for key in [
            'peek_ammo_first_match',
            'peek_ammo_order_matters',
            'peek_ammo_none_null',
            'peek_ammo_no_match_null',
            'peek_ammo_no_remove',
            'peek_ammo_duplicate_held',
            'peek_ammo_missing_type_null',
            'peek_ammo_input_unmutated',
            'peek_ammo_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_payload_turret_peek_ammo(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadTurretPeekAmmoProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_TURRET_PEEK_AMMO_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'peek_ammo_first_match',
            'peek_ammo_order_matters',
            'peek_ammo_none_null',
            'peek_ammo_no_match_null',
            'peek_ammo_no_remove',
            'peek_ammo_duplicate_held',
            'peek_ammo_missing_type_null',
            'peek_ammo_input_unmutated',
            'peek_ammo_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
