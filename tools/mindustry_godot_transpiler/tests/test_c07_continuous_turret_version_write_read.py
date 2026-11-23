import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONTINUOUS_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceContinuousTurretBuildPortBridge.gd'
CONTINUOUS_TURRET_VERSION_WRITE_READ_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ContinuousTurretVersionWriteReadProof.gd'


class C07ContinuousTurretVersionWriteReadTests(unittest.TestCase):
    def test_c07_continuous_turret_version_write_read_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2375']['godot_owner'], 'PortGame.source_continuous_turret_build_version_write_read_state')
        # ContinuousTurretBuild.version()
        # (ContinuousTurret.java:176-178):
        # `public byte version(){`
        # `return 3;`
        # `}`
        # ContinuousTurretBuild.write()
        # (ContinuousTurret.java:181-185):
        # `public void write(Writes write){`
        # `super.write(write);`
        # `write.f(lastLength);`
        # `}`
        # ContinuousTurretBuild.read()
        # (ContinuousTurret.java:188-194):
        # `public void read(Reads read, byte revision){`
        # `super.read(read, revision);`
        # `if(revision >= 3){`
        # `lastLength = read.f();`
        # `}`
        # `}`
        # on `public class ContinuousTurretBuild extends TurretBuild{`
        # (ContinuousTurret.java:38) inside
        # `public class ContinuousTurret extends Turret{`. The
        # three methods are one persistence record (the N2322
        # TurretBuild / N2286 DrillBuild merged-slice
        # precedent): version() stamps the save revision, write()
        # persists the single own field lastLength, read()
        # restores it only at revision >= 3. The name `version`
        # shares text with 7 other-class slices (N1187/N745/
        # N923/N1885/N2217/N2286/N2322) -- registered under
        # this java_method with the class prefix, and
        # `super.write(write);` / `super.read(read, revision);`
        # each EXACT-hit 9 slices -- they are callee/context
        # only, NOT distinguishing exprs (the super layer is
        # TurretBuild.write/read, owned by N2322). Three new
        # result symbols: version, write_last_length,
        # last_length. lastLength is the ContinuousTurretBuild
        # field (ContinuousTurret.java:40, `public float
        # lastLength = size * 4f;`); the save revision 3 is
        # the gate for `if(revision >= 3)`.
        self.assertEqual(
            ledger['N2375']['source_symbols'],
            [
                'source_continuous_turret_build_version_write_read_state_result.version',
                'source_continuous_turret_build_version_write_read_state_result.write_last_length',
                'source_continuous_turret_build_version_write_read_state_result.last_length',
            ],
        )
        for name in ledger['N2375']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2375']['runtime_proof'], '/root/C07ContinuousTurretVersionWriteReadProof')
        self.assertEqual(
            ledger['N2375']['tests'],
            [
                'test_c07_continuous_turret_version_write_read_registration',
                'test_all_c07_continuous_turret_version_write_read_input_evidence_is_exact',
                'test_continuous_turret_version_write_read_state',
                'test_reference_graph_and_actual_c07_continuous_turret_version_write_read',
            ],
        )
        self.assertTrue(ledger['N2375']['deferred_exprs'])

    def test_all_c07_continuous_turret_version_write_read_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2375']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2375']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_continuous_turret_version_write_read_state(self):
        bridge = CONTINUOUS_TURRET_BRIDGE.read_text(encoding='utf-8')
        # ContinuousTurretBuild.version() returns 3
        # (`public byte version(){ return 3; }`,
        # ContinuousTurret.java:176-178); write() persists the
        # single own field lastLength (`write.f(lastLength);`,
        # :184, inside `public void write(Writes write){` /
        # `super.write(write);`, :181-183); read() restores it
        # only at revision >= 3 (`if(revision >= 3){
        # lastLength = read.f(); }`, :191-193, inside `public
        # void read(Reads read, byte revision){` /
        # `super.read(read, revision);`, :188-190). The super
        # layer is TurretBuild.write/read (N2322), a callee,
        # not re-ported here. The port has no save/load
        # stream, so the value read.f() would return arrives
        # as the explicit stored_last_length param (the N2330
        # param precedent); a revision below 3 leaves
        # lastLength where it already is. NO driver tick line:
        # persistence is not a per-tick call.
        self.assertIn('static func source_continuous_turret_build_version_write_read_state(last_length: float, revision: int, stored_last_length: float) -> Dictionary:', bridge)
        self.assertIn('return {"version": version, "write_last_length": write_last_length, "last_length": read_last_length}', bridge)
        for expr in [
            'public class ContinuousTurret extends Turret{',
            'public class ContinuousTurretBuild extends TurretBuild{',
            '@Override',
            'public byte version(){',
            'return 3;',
            'public void write(Writes write){',
            'write.f(lastLength);',
            'public void read(Reads read, byte revision){',
            'if(revision >= 3){',
            'lastLength = read.f();',
            'public float lastLength = size * 4f;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with
        # synthetic scalar inputs (no live tick): version is
        # always 3 / write persists lastLength whatever the
        # revision / read restores the stored value at
        # revision 3 and above / read keeps the current value
        # below revision 3 / write then read round-trips /
        # each result carries only its three keys.
        proof = CONTINUOUS_TURRET_VERSION_WRITE_READ_PROOF.read_text(encoding='utf-8')
        for key in [
            'version_returns_three',
            'write_persists_last_length',
            'write_ignores_revision',
            'read_restores_at_revision_three',
            'read_restores_above_revision_three',
            'read_keeps_current_below_revision_three',
            'read_keeps_current_at_revision_zero',
            'write_then_read_round_trips',
            'version_matches_revision_gate',
            'returns_only_three_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_continuous_turret_version_write_read(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ContinuousTurretVersionWriteReadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_CONTINUOUS_TURRET_VERSION_WRITE_READ_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'version_returns_three',
            'write_persists_last_length',
            'write_ignores_revision',
            'read_restores_at_revision_three',
            'read_restores_above_revision_three',
            'read_keeps_current_below_revision_three',
            'read_keeps_current_at_revision_zero',
            'write_then_read_round_trips',
            'version_matches_revision_gate',
            'returns_only_three_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
