import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_AMMO_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourcePayloadAmmoTurretBuildPortBridge.gd'
PAYLOAD_AMMO_TURRET_USE_AMMO_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadAmmoTurretUseAmmoProof.gd'


class C07PayloadAmmoTurretUseAmmoTests(unittest.TestCase):
    def test_c07_payload_ammo_turret_use_ammo_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2363']['godot_owner'], 'PortGame.source_payload_ammo_turret_build_use_ammo_state')
        # PayloadTurretBuild.useAmmo()
        # (PayloadAmmoTurret.java:122-131):
        # `public BulletType useAmmo(){`
        # `for(var content : ammoKeys){`
        # `if(payloads.contains(content)){`
        # `payloads.remove(content);`
        # `return ammoTypes.get(content);`
        # `}`
        # `}`
        # `return null;`
        # `}`
        # on `public class PayloadTurretBuild extends TurretBuild{`
        # (PayloadAmmoTurret.java:94) inside
        # `public class PayloadAmmoTurret extends Turret{`
        # (PayloadAmmoTurret.java:21). This is the
        # PayloadAmmoTurret override: it consumes (removes)
        # the first ammo key (in ammoKeys order) whose content
        # is currently held in the payloads seq and returns
        # that content's BulletType from ammoTypes, or null
        # when none matches. The distinguishing pair against
        # peekAmmo/currentAmmo in the same class is
        # `payloads.remove(content);` +
        # `return ammoTypes.get(content);` -- peekAmmo returns
        # the same BulletType WITHOUT removing, currentAmmo
        # returns the content itself WITHOUT removing. The
        # payloads.remove mutation is modeled as param in/out:
        # the function duplicates payload_contents, removes
        # the consumed content from the copy, and returns the
        # updated list as payload_contents in the result --
        # the input arrays are never mutated. ammoTypes
        # (ObjectMap) arrives as an explicit Dictionary param
        # mapping content name to bullet type name. NO driver
        # line: a pure function the shoot path calls
        # (TurretBuild.shoot :772 / bullet :814), not a
        # per-tick write; the caller wiring waits for its own
        # slice. Two new result symbols: used_ammo and the
        # updated payload_contents. The other useAmmo-adjacent
        # methods own their own bodies and are NOT touched
        # here -- hasAmmo/acceptPayload/handlePayload are a
        # separate group (NOT approved), peekAmmo and
        # getAmmoContent wait for their own slices.
        self.assertEqual(
            ledger['N2363']['source_symbols'],
            [
                'source_payload_ammo_turret_build_use_ammo_state_result.used_ammo',
                'source_payload_ammo_turret_build_use_ammo_state_result.payload_contents',
            ],
        )
        for name in ledger['N2363']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2363']['runtime_proof'], '/root/C07PayloadAmmoTurretUseAmmoProof')
        self.assertEqual(
            ledger['N2363']['tests'],
            [
                'test_c07_payload_ammo_turret_use_ammo_registration',
                'test_all_c07_payload_ammo_turret_use_ammo_input_evidence_is_exact',
                'test_payload_ammo_turret_use_ammo_state',
                'test_reference_graph_and_actual_c07_payload_ammo_turret_use_ammo',
            ],
        )
        self.assertTrue(ledger['N2363']['deferred_exprs'])

    def test_all_c07_payload_ammo_turret_use_ammo_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2363']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2363']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_ammo_turret_use_ammo_state(self):
        bridge = PAYLOAD_AMMO_TURRET_BRIDGE.read_text(encoding='utf-8')
        # PayloadTurretBuild.useAmmo()
        # (PayloadAmmoTurret.java:122-131) consumes the first
        # ammo key in ammoKeys order whose content is held in
        # payloads: it removes that content from the payloads
        # seq and returns its BulletType from ammoTypes, or
        # null when none matches. The remove is modeled as
        # param in/out -- the result carries the updated
        # payload_contents list and the input arrays are
        # never mutated. NO driver line: a pure function the
        # shoot path calls, not a per-tick write.
        self.assertIn('static func source_payload_ammo_turret_build_use_ammo_state(ammo_keys: Array, payload_contents: Array, ammo_types: Dictionary) -> Dictionary:', bridge)
        self.assertIn('return {"used_ammo": used_ammo, "payload_contents": remaining_contents}', bridge)
        for expr in [
            'public class PayloadAmmoTurret extends Turret{',
            'public class PayloadTurretBuild extends TurretBuild{',
            'public PayloadSeq payloads = new PayloadSeq();',
            'ammoKeys = ammoTypes.keys().toSeq().toArray(UnlockableContent.class);',
            'public BulletType useAmmo(){',
            'for(var content : ammoKeys){',
            'if(payloads.contains(content)){',
            'payloads.remove(content);',
            'return ammoTypes.get(content);',
            'return null;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick): first match in
        # ammoKeys order / order beats payload order / empty
        # payloads returns null / no match returns null /
        # only the first matched content is removed / a
        # second call on the returned list consumes the next
        # match / inputs are not mutated by the call / the
        # result carries exactly the two keys.
        proof = PAYLOAD_AMMO_TURRET_USE_AMMO_PROOF.read_text(encoding='utf-8')
        for key in [
            'use_ammo_first_match',
            'use_ammo_order_matters',
            'use_ammo_none_null',
            'use_ammo_no_match_null',
            'use_ammo_removes_only_first_match',
            'use_ammo_second_call_consumes_next',
            'use_ammo_input_unmutated',
            'use_ammo_returns_only_two_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_payload_ammo_turret_use_ammo(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadAmmoTurretUseAmmoProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_AMMO_TURRET_USE_AMMO_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'use_ammo_first_match',
            'use_ammo_order_matters',
            'use_ammo_none_null',
            'use_ammo_no_match_null',
            'use_ammo_removes_only_first_match',
            'use_ammo_second_call_consumes_next',
            'use_ammo_input_unmutated',
            'use_ammo_returns_only_two_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
