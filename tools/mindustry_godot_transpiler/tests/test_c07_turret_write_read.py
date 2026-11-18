import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_WRITE_READ_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretWriteReadProof.gd'


class C07TurretWriteReadTests(unittest.TestCase):
    def test_c07_turret_write_read_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2276']['godot_owner'], 'SourceTurretBuildState.source_turret_write_state')
        # TurretBuild persists exactly TWO fields, its reload
        # counter and its aim rotation (`write.f(reloadCounter);` /
        # `write.f(rotation);`, Turret.java:833-834, inside
        # `public void write(Writes write){` /
        # `super.write(write);`, Turret.java:831-832), and
        # restores them only for saves at revision >= 1
        # (`if(revision >= 1){ reloadCounter = read.f();
        # rotation = read.f(); }`, Turret.java:841-844, inside
        # `public void read(Reads read, byte revision){` /
        # `super.read(read, revision);`, Turret.java:838-839).
        # version() returns 1 (`public byte version(){ return
        # 1; }`, Turret.java:848-850); the BuildingComp base
        # returns 0 (BuildingComp.java:669-671). RED decisions
        # (resolved at RED, recorded in the register
        # docstring): (1) Three pure functions -- write reads
        # both values from the frame (the N2217 RepairTurret
        # precedent: write takes the frame only), read takes
        # the two stored values + revision and applies them
        # only at revision >= 1, version returns the constant
        # 1. (2) The frame "rotation" key is the RotComp
        # float aim angle (`@SyncField(false) @SyncLocal float
        # rotation;`, RotComp.java:8), NOT the Building int
        # rotation 0-3 (`transient int rotation;`,
        # BuildingComp.java:69) that sense() takes as an
        # explicit int param -- the two are shadowed
        # (Turret.java:543-544). (3) Defaults are the Java
        # field defaults: reloadCounter 0.0 (`public float
        # reloadCounter;`, ReloadTurret.java:26) and rotation
        # 0.0 (RotComp float, no explicit init -- contrast
        # RepairTurret's 90.0). (4) super.write/read are empty
        # BuildingComp bodies ("overriden by subclasses!") --
        # only the marker is recorded. (5) readSync() is its
        # own slice, not included here. (6) NO driver tick
        # line: persistence is not a per-tick call, and the
        # port has no save/load stream to call these functions
        # yet. (7) Java write.f is a 32-bit float while
        # GDScript float is 64-bit -- the pure functions add
        # NO rounding epsilon; the proof round-trips
        # float32-safe values exactly and checks the inexact
        # value 0.1 with is_equal_approx. Five new result
        # symbols: write.reload_counter, write.rotation,
        # read.reload_counter, read.rotation, version.version.
        self.assertEqual(
            ledger['N2276']['source_symbols'],
            [
                'source_turret_write_state_result.reload_counter',
                'source_turret_write_state_result.rotation',
                'source_turret_read_state_result.reload_counter',
                'source_turret_read_state_result.rotation',
                'source_turret_version_state_result.version',
            ],
        )
        for name in ledger['N2276']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2276']['runtime_proof'], '/root/C07TurretWriteReadProof')
        self.assertEqual(
            ledger['N2276']['tests'],
            [
                'test_c07_turret_write_read_registration',
                'test_all_c07_turret_write_read_input_evidence_is_exact',
                'test_turret_write_read_state',
                'test_reference_graph_and_actual_c07_turret_write_read',
            ],
        )
        self.assertTrue(ledger['N2276']['deferred_exprs'])

    def test_all_c07_turret_write_read_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2276']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
            'core/src/mindustry/entities/comp/RotComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2276']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_write_read_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild persists exactly TWO fields, its reload
        # counter and its aim rotation: `public void write(
        # Writes write){` / `super.write(write);` /
        # `write.f(reloadCounter);` / `write.f(rotation);`
        # (Turret.java:831-834), and restores them only at
        # revision >= 1: `public void read(Reads read, byte
        # revision){` / `super.read(read, revision);` /
        # `if(revision >= 1){` / `reloadCounter = read.f();`
        # / `rotation = read.f();` (Turret.java:838-844).
        # version() returns 1: `public byte version(){` /
        # `return 1;` (Turret.java:848-850). The rotation
        # persisted here is the RotComp float aim angle, not
        # the Building int rotation 0-3. super.write/read are
        # empty BuildingComp bodies. readSync() is its own
        # slice. There is NO driver tick line: persistence is
        # not a per-tick call, and the port has no save/load
        # stream to call these functions yet.
        self.assertIn('static func source_turret_write_state(frame: Dictionary) -> Dictionary:', turret)
        self.assertIn('return {"reload_counter": float(frame.get("reload_counter", 0.0)), "rotation": float(frame.get("rotation", 0.0))}', turret)
        self.assertIn('static func source_turret_read_state(frame: Dictionary, stored_reload_counter: float, stored_rotation: float, revision: int) -> Dictionary:', turret)
        self.assertIn('if revision >= 1:', turret)
        self.assertIn('reload_counter = stored_reload_counter', turret)
        self.assertIn('rotation = stored_rotation', turret)
        self.assertIn('return {"reload_counter": reload_counter, "rotation": rotation}', turret)
        self.assertIn('static func source_turret_version_state(frame: Dictionary) -> Dictionary:', turret)
        self.assertIn('return {"version": 1}', turret)
        for expr in [
            'public void write(Writes write){',
            'super.write(write);',
            'write.f(reloadCounter);',
            'write.f(rotation);',
            'public void read(Reads read, byte revision){',
            'super.read(read, revision);',
            'if(revision >= 1){',
            'reloadCounter = read.f();',
            'rotation = read.f();',
            'public byte version(){',
            'return 1;',
            'public float reloadCounter;',
            '@SyncField(false) @SyncLocal float rotation;',
            'transient int rotation;',
            '//sync underlying rotation; 0-3 rotation is a shadowed field',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'public class ReloadTurret extends BaseTurret{',
            'public class ReloadTurretBuild extends BaseTurretBuild{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure functions with
        # synthetic frames (no live tick, no save file: the
        # persisted values are two floats): write 0.0/0.0
        # (the Java field defaults) / write 12.5/135.0
        # round-trips through read at revision 1 / write
        # returns only the two keys / read returns only the
        # two keys / read at revision 0 keeps the frame's
        # current values and ignores the stored values / read
        # at revision 1 applies the stored values / version
        # returns 1 / the inexact float32 value 0.1
        # round-trips within float32 tolerance.
        proof = TURRET_WRITE_READ_PROOF.read_text(encoding='utf-8')
        for key in [
            'write_defaults_zero',
            'write_round_trips',
            'write_returns_only_two_keys',
            'read_returns_only_two_keys',
            'read_ignores_old_revision',
            'read_applies_at_revision_one',
            'version_returns_one',
            'round_trip_inexact_float32_value',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_write_read(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretWriteReadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_WRITE_READ_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'write_defaults_zero',
            'write_round_trips',
            'write_returns_only_two_keys',
            'read_returns_only_two_keys',
            'read_ignores_old_revision',
            'read_applies_at_revision_one',
            'version_returns_one',
            'round_trip_inexact_float32_value',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
