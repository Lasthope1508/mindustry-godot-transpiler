import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_AMMO_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourcePayloadAmmoTurretBuildPortBridge.gd'
PAYLOAD_AMMO_TURRET_GET_AMMO_CONTENT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadAmmoTurretGetAmmoContentProof.gd'


class C07PayloadAmmoTurretGetAmmoContentTests(unittest.TestCase):
    def test_c07_payload_ammo_turret_get_ammo_content_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2368']['godot_owner'], 'PortGame.source_payload_ammo_turret_build_get_ammo_content_state')
        # PayloadTurretBuild.getAmmoContent()
        # (PayloadAmmoTurret.java:148-157):
        # `public UnlockableContent getAmmoContent(){`
        # `if(!payloads.isEmpty()){`
        # `for(var content : ammoKeys){`
        # `if(payloads.contains(content)){`
        # `return content;`
        # `}`
        # `}`
        # `}`
        # `return null;`
        # `}`
        # on `public class PayloadTurretBuild extends TurretBuild{`
        # (PayloadAmmoTurret.java:94) inside
        # `public class PayloadAmmoTurret extends Turret{`
        # (PayloadAmmoTurret.java:21). This is the
        # PayloadAmmoTurret override: it returns the first
        # ammo key (in ammoKeys order) whose content is
        # currently held in the payloads seq, or null when
        # none matches -- but ONLY when the payloads seq is
        # non-empty (`if(!payloads.isEmpty()){` guard). The
        # distinguishing line against currentAmmo (N2358) in
        # the same class is exactly that guard: currentAmmo
        # scans unconditionally, getAmmoContent scans only
        # inside the non-empty guard -- same returned value,
        # different body, NO dedup. Against useAmmo (N2363):
        # getAmmoContent does NOT remove (`payloads.remove`
        # is absent) and does NOT return a BulletType
        # (`return ammoTypes.get(content);` is absent) -- it
        # returns the content itself. The payloads.contains
        # lookup is NOT ported: the payload contents arrive
        # as the explicit payload_contents param and ammoKeys
        # as the explicit ammo_keys param (the N2330 param
        # precedent). Content refs are plain strings here
        # (content names); the result is the matching name
        # or null. NO driver line: a pure accessor the HUD /
        # ammo display caller reads, not a per-tick write.
        # One new result symbol: ammo_content. The other
        # getAmmoContent-adjacent methods own their own
        # bodies and are NOT touched here -- peekAmmo waits
        # for its own slice, getAmmoFraction is a separate
        # method below getAmmoContent.
        self.assertEqual(
            ledger['N2368']['source_symbols'],
            [
                'source_payload_ammo_turret_build_get_ammo_content_state_result.ammo_content',
            ],
        )
        for name in ledger['N2368']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2368']['runtime_proof'], '/root/C07PayloadAmmoTurretGetAmmoContentProof')
        self.assertEqual(
            ledger['N2368']['tests'],
            [
                'test_c07_payload_ammo_turret_get_ammo_content_registration',
                'test_all_c07_payload_ammo_turret_get_ammo_content_input_evidence_is_exact',
                'test_payload_ammo_turret_get_ammo_content_state',
                'test_reference_graph_and_actual_c07_payload_ammo_turret_get_ammo_content',
            ],
        )
        self.assertTrue(ledger['N2368']['deferred_exprs'])

    def test_all_c07_payload_ammo_turret_get_ammo_content_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2368']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2368']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_ammo_turret_get_ammo_content_state(self):
        bridge = PAYLOAD_AMMO_TURRET_BRIDGE.read_text(encoding='utf-8')
        # PayloadTurretBuild.getAmmoContent()
        # (PayloadAmmoTurret.java:148-157) returns the first
        # ammo key in ammoKeys order whose content is held
        # in payloads, but only when payloads is non-empty
        # (`if(!payloads.isEmpty()){` guard); null when
        # payloads is empty or no key matches. It does NOT
        # remove the content and does NOT return a BulletType
        # -- it returns the content itself. NO driver line:
        # a pure accessor, not a per-tick write.
        self.assertIn('static func source_payload_ammo_turret_build_get_ammo_content_state(ammo_keys: Array, payload_contents: Array) -> Dictionary:', bridge)
        self.assertIn('return {"ammo_content": ammo_content}', bridge)
        for expr in [
            'public class PayloadAmmoTurret extends Turret{',
            'public class PayloadTurretBuild extends TurretBuild{',
            'public PayloadSeq payloads = new PayloadSeq();',
            'ammoKeys = ammoTypes.keys().toSeq().toArray(UnlockableContent.class);',
            'public UnlockableContent getAmmoContent(){',
            'if(!payloads.isEmpty()){',
            'for(var content : ammoKeys){',
            'if(payloads.contains(content)){',
            'return content;',
            'return null;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick): first match in
        # ammoKeys order / order beats payload order / the
        # empty guard returns null / no match returns null /
        # calling twice gives the same result (nothing is
        # removed, unlike useAmmo) / duplicate held content
        # still returns the first match / inputs are not
        # mutated by the call / the result carries exactly
        # the one key.
        proof = PAYLOAD_AMMO_TURRET_GET_AMMO_CONTENT_PROOF.read_text(encoding='utf-8')
        for key in [
            'get_ammo_content_first_match',
            'get_ammo_content_order_matters',
            'get_ammo_content_empty_guard_null',
            'get_ammo_content_no_match_null',
            'get_ammo_content_no_remove',
            'get_ammo_content_duplicate_held',
            'get_ammo_content_input_unmutated',
            'get_ammo_content_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_payload_ammo_turret_get_ammo_content(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadAmmoTurretGetAmmoContentProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_AMMO_TURRET_GET_AMMO_CONTENT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'get_ammo_content_first_match',
            'get_ammo_content_order_matters',
            'get_ammo_content_empty_guard_null',
            'get_ammo_content_no_match_null',
            'get_ammo_content_no_remove',
            'get_ammo_content_duplicate_held',
            'get_ammo_content_input_unmutated',
            'get_ammo_content_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
