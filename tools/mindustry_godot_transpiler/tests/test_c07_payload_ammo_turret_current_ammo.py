import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_AMMO_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourcePayloadAmmoTurretBuildPortBridge.gd'
PAYLOAD_AMMO_TURRET_CURRENT_AMMO_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadAmmoTurretCurrentAmmoProof.gd'


class C07PayloadAmmoTurretCurrentAmmoTests(unittest.TestCase):
    def test_c07_payload_ammo_turret_current_ammo_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2358']['godot_owner'], 'PortGame.source_payload_ammo_turret_build_current_ammo_state')
        # PayloadTurretBuild.currentAmmo()
        # (PayloadAmmoTurret.java:97-105):
        # `public UnlockableContent currentAmmo(){`
        # `for(var content : ammoKeys){`
        # `if(payloads.contains(content)){`
        # `return content;`
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
        # none matches. The other currentAmmo-adjacent
        # methods own their own bodies and are NOT touched
        # here -- hasAmmo/acceptPayload/handlePayload are a
        # separate group (draft batch 11 §4a, NOT approved),
        # getAmmoFraction is owned by N1181 (1 expr). NO
        # driver line: a pure accessor the HUD caller
        # reads, not a per-tick write. One new result
        # symbol: current_ammo. The payloads.contains
        # lookup is NOT ported: the payload contents arrive
        # as the explicit payload_contents param (the N2330
        # param precedent); ammoKeys arrives as the explicit
        # ammo_keys param.
        self.assertEqual(
            ledger['N2358']['source_symbols'],
            [
                'source_payload_ammo_turret_build_current_ammo_state_result.current_ammo',
            ],
        )
        for name in ledger['N2358']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2358']['runtime_proof'], '/root/C07PayloadAmmoTurretCurrentAmmoProof')
        self.assertEqual(
            ledger['N2358']['tests'],
            [
                'test_c07_payload_ammo_turret_current_ammo_registration',
                'test_all_c07_payload_ammo_turret_current_ammo_input_evidence_is_exact',
                'test_payload_ammo_turret_current_ammo_state',
                'test_reference_graph_and_actual_c07_payload_ammo_turret_current_ammo',
            ],
        )
        self.assertTrue(ledger['N2358']['deferred_exprs'])

    def test_all_c07_payload_ammo_turret_current_ammo_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2358']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2358']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_ammo_turret_current_ammo_state(self):
        bridge = PAYLOAD_AMMO_TURRET_BRIDGE.read_text(encoding='utf-8')
        # PayloadTurretBuild.currentAmmo()
        # (PayloadAmmoTurret.java:97-105) returns the first
        # ammo key in ammoKeys order whose content is held in
        # payloads, or null when none matches. The payloads
        # lookup arrives as explicit params; there is no dict
        # frame input, so every input is an explicit array and
        # there is no frame-based input-unmutated shape (the
        # proof still checks both arrays are unchanged after
        # the call). NO driver line: a pure accessor, not a
        # per-tick write.
        self.assertIn('static func source_payload_ammo_turret_build_current_ammo_state(ammo_keys: Array, payload_contents: Array) -> Dictionary:', bridge)
        self.assertIn('return {"current_ammo": current_ammo}', bridge)
        for expr in [
            'public class PayloadAmmoTurret extends Turret{',
            'public class PayloadTurretBuild extends TurretBuild{',
            'public PayloadSeq payloads = new PayloadSeq();',
            'ammoKeys = ammoTypes.keys().toSeq().toArray(UnlockableContent.class);',
            'public UnlockableContent currentAmmo(){',
            'for(var content : ammoKeys){',
            'if(payloads.contains(content)){',
            'return content;',
            'return null;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with
        # synthetic array inputs (no live tick): first match
        # in ammoKeys order / order beats payload order /
        # empty payloads returns null / no match returns
        # null / inputs are not mutated by the call.
        proof = PAYLOAD_AMMO_TURRET_CURRENT_AMMO_PROOF.read_text(encoding='utf-8')
        for key in [
            'current_ammo_first_match',
            'current_ammo_order_matters',
            'current_ammo_none_null',
            'current_ammo_no_match_null',
            'current_ammo_input_unmutated',
            'current_ammo_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_payload_ammo_turret_current_ammo(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadAmmoTurretCurrentAmmoProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_AMMO_TURRET_CURRENT_AMMO_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'current_ammo_first_match',
            'current_ammo_order_matters',
            'current_ammo_none_null',
            'current_ammo_no_match_null',
            'current_ammo_input_unmutated',
            'current_ammo_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
