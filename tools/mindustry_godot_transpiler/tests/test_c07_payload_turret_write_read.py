import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_AMMO_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourcePayloadAmmoTurretBuildPortBridge.gd'
PAYLOAD_AMMO_TURRET_WRITE_READ_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadTurretWriteReadProof.gd'


class C07PayloadTurretWriteReadTests(unittest.TestCase):
    def test_c07_payload_turret_write_read_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2376']['godot_owner'], 'PortGame.source_payload_ammo_turret_build_write_read_state')
        # PayloadTurretBuild.write()+read()
        # (PayloadAmmoTurret.java:179-190):
        # `public void write(Writes write){`
        # `super.write(write);`
        # `payloads.write(write);`
        # `}`
        # `public void read(Reads read, byte revision){`
        # `super.read(read, revision);`
        # `payloads.read(read);`
        # `payloads.removeAll(u -> !ammoTypes.containsKey(u));`
        # `}`
        # on `public class PayloadTurretBuild extends TurretBuild{`
        # (PayloadAmmoTurret.java:94) inside
        # `public class PayloadAmmoTurret extends Turret{`
        # (PayloadAmmoTurret.java:21). This is the
        # PayloadAmmoTurret override: write persists the
        # payloads seq, read restores it and drops every
        # held content whose type is not in ammoTypes
        # (`payloads.removeAll(u ->
        # !ammoTypes.containsKey(u));`). `super.write/read`
        # are callee/context (TurretBuild.write/read already
        # owned by N2322) -- NOT distinguishing exprs.
        # The distinguishing lines are `payloads.write(write);`,
        # `payloads.read(read);` and
        # `payloads.removeAll(u -> !ammoTypes.containsKey(u));`
        # (all three 0-hit in both ledgers at HEAD 76d71f1e).
        # The payloads seq arrives as the explicit
        # payload_contents param and ammoTypes as the
        # explicit ammo_types Dictionary param (content name
        # -> bullet type name); ObjectMap is NOT ported
        # (the N2330 param precedent). Content refs are
        # plain strings here. NO driver line: pure
        # persistence functions, not a per-tick write.
        # Two new result symbols: write_payload_contents,
        # payload_contents.
        self.assertEqual(
            ledger['N2376']['source_symbols'],
            [
                'source_payload_ammo_turret_build_write_read_state_result.write_payload_contents',
                'source_payload_ammo_turret_build_write_read_state_result.payload_contents',
            ],
        )
        for name in ledger['N2376']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2376']['runtime_proof'], '/root/C07PayloadTurretWriteReadProof')
        self.assertEqual(
            ledger['N2376']['tests'],
            [
                'test_c07_payload_turret_write_read_registration',
                'test_all_c07_payload_turret_write_read_input_evidence_is_exact',
                'test_payload_turret_write_read_state',
                'test_reference_graph_and_actual_c07_payload_turret_write_read',
            ],
        )
        self.assertTrue(ledger['N2376']['deferred_exprs'])

    def test_all_c07_payload_turret_write_read_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2376']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2376']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_turret_write_read_state(self):
        bridge = PAYLOAD_AMMO_TURRET_BRIDGE.read_text(encoding='utf-8')
        # PayloadTurretBuild.write()+read()
        # (PayloadAmmoTurret.java:179-190) persists the
        # payloads seq on write and restores it on read,
        # dropping held contents whose type is not in
        # ammoTypes. `super.write/read` are callee/context
        # (N2322 owns TurretBuild.write/read). NO driver
        # line: pure persistence functions, not a per-tick
        # write.
        self.assertIn('static func source_payload_ammo_turret_build_write_read_state(payload_contents: Array, stored_payload_contents: Array, ammo_types: Dictionary) -> Dictionary:', bridge)
        self.assertIn('return {"write_payload_contents": write_payload_contents, "payload_contents": read_payload_contents}', bridge)
        for expr in [
            'public class PayloadAmmoTurret extends Turret{',
            'public class PayloadTurretBuild extends TurretBuild{',
            'public PayloadSeq payloads = new PayloadSeq();',
            '@Override',
            'public void write(Writes write){',
            'super.write(write);',
            'payloads.write(write);',
            'public void read(Reads read, byte revision){',
            'super.read(read, revision);',
            'payloads.read(read);',
            'payloads.removeAll(u -> !ammoTypes.containsKey(u));',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick): write persists
        # the payloads in order / write of empty persists
        # empty / read keeps contents whose type is in
        # ammoTypes / read drops contents whose type is not
        # in ammoTypes / mixed read filters correctly /
        # read of empty stays empty / write then read round
        # trips when every content is an ammo type /
        # inputs are not mutated by the call / the result
        # carries exactly the two keys.
        proof = PAYLOAD_AMMO_TURRET_WRITE_READ_PROOF.read_text(encoding='utf-8')
        for key in [
            'write_persists_payloads',
            'write_empty_persists_empty',
            'read_keeps_ammo_contents',
            'read_removes_non_ammo_contents',
            'read_mixed_filters_correctly',
            'read_empty_stays_empty',
            'write_then_read_round_trips',
            'write_read_inputs_unmutated',
            'write_read_returns_only_two_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_payload_turret_write_read(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadTurretWriteReadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_TURRET_WRITE_READ_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'write_persists_payloads',
            'write_empty_persists_empty',
            'read_keeps_ammo_contents',
            'read_removes_non_ammo_contents',
            'read_mixed_filters_correctly',
            'read_empty_stays_empty',
            'write_then_read_round_trips',
            'write_read_inputs_unmutated',
            'write_read_returns_only_two_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
