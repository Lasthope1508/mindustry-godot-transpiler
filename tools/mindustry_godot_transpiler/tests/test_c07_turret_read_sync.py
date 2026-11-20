import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_READ_SYNC_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretReadSyncProof.gd'


class C07TurretReadSyncTests(unittest.TestCase):
    def test_c07_turret_read_sync_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2353']['godot_owner'], 'SourceTurretBuildState.source_turret_read_sync_state')
        # TurretBuild.readSync() (Turret.java:853-861):
        # `@Override`
        # `public void readSync(Reads read, byte revision){`
        # `//maintain rotation and reload when syncing so clients don't see turrets snapping around`
        # `float oldRot = rotation, oldReload = reloadCounter;`
        # `readAll(read, revision);`
        # `rotation = oldRot;`
        # `reloadCounter = oldReload;`
        # `}`
        # on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
        # (Turret.java:277). The sync preserves the aim
        # rotation and the reload counter across the sync
        # read, so clients do not see turrets snapping
        # around. readAll(read, revision) is the Building
        # base call (BuildingComp.java:283-286,
        # `public void readAll(Reads read, byte revision){`
        # / `readBase(read);` / `read(read, revision);`): the
        # payload it applies arrives as the already-parsed
        # dict read_data -- Building.readAll itself is NOT
        # ported here (the N2330 param precedent). The
        # rotation preserved here is the RotComp float aim
        # angle (`@SyncField(false) @SyncLocal float
        # rotation;`, RotComp.java:8), NOT the Building int
        # rotation 0-3 (`transient int rotation;`,
        # BuildingComp.java:69) -- the two are shadowed
        # (Turret.java:543-544, the N2322 precedent). The
        # reload counter is the ReloadTurretBuild field
        # (`public float reloadCounter;`,
        # ReloadTurret.java:26), default 0.0. revision is
        # passed through to readAll and the Turret override
        # never branches on it (the N2322 read() guard
        # `if(revision >= 1){` belongs to read(), not to
        # readSync()). NO driver tick line: the engine net
        # sync calls readSync(); no call site is ported here
        # (the shouldTurn/isShooting precedent). The
        # `readAll(read, revision);` call line is shared
        # text with N1776 (BuildingComp.readSync, a
        # different class and method) -- callee evidence,
        # not ownership of TurretBuild.readSync(). Three new
        # result symbols: rotation, reload_counter,
        # read_applied.
        self.assertEqual(
            ledger['N2353']['source_symbols'],
            [
                'source_turret_read_sync_state_result.rotation',
                'source_turret_read_sync_state_result.reload_counter',
                'source_turret_read_sync_state_result.read_applied',
            ],
        )
        for name in ledger['N2353']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_read_sync_state')
        self.assertEqual(ledger['N2353']['runtime_proof'], '/root/C07TurretReadSyncProof')
        self.assertEqual(
            ledger['N2353']['tests'],
            [
                'test_c07_turret_read_sync_registration',
                'test_all_c07_turret_read_sync_input_evidence_is_exact',
                'test_turret_read_sync_state',
                'test_reference_graph_and_actual_c07_turret_read_sync',
            ],
        )
        self.assertTrue(ledger['N2353']['deferred_exprs'])

    def test_all_c07_turret_read_sync_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2353']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_read_sync_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
            'core/src/mindustry/entities/comp/RotComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2353']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_read_sync_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.readSync() (Turret.java:853-861) snapshots
        # the aim rotation and the reload counter, applies the
        # sync payload via readAll, then restores both values:
        # `float oldRot = rotation, oldReload = reloadCounter;`
        # / `readAll(read, revision);` / `rotation = oldRot;`
        # / `reloadCounter = oldReload;`. The rotation is the
        # RotComp float aim angle, not the Building int
        # rotation 0-3. revision is passed through to readAll
        # and never branched on here. There is NO driver tick
        # line: the engine net sync calls readSync().
        self.assertIn('static func source_turret_read_sync_state(frame: Dictionary, read_data: Dictionary, revision: int) -> Dictionary:', turret)
        self.assertIn('var old_rotation: float = float(frame.get("rotation", 0.0))', turret)
        self.assertIn('var old_reload_counter: float = float(frame.get("reload_counter", 0.0))', turret)
        self.assertIn('return {"rotation": old_rotation, "reload_counter": old_reload_counter, "read_applied": read_applied}', turret)
        for expr in [
            'public void readSync(Reads read, byte revision){',
            '//maintain rotation and reload when syncing so clients don\'t see turrets snapping around',
            'float oldRot = rotation, oldReload = reloadCounter;',
            'readAll(read, revision);',
            'rotation = oldRot;',
            'reloadCounter = oldReload;',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'public float reloadCounter;',
            '@SyncField(false) @SyncLocal float rotation;',
            'transient int rotation;',
            'public void readAll(Reads read, byte revision){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function with
        # synthetic frames and parsed sync payloads (no live
        # tick, no net stream: the payload arrives already
        # parsed as read_data): rotation preserved even when
        # the payload carries a different rotation / reload
        # preserved even when the payload carries a different
        # reload counter / a non-empty payload is reported
        # applied / an empty payload is reported not applied
        # / empty frame + empty payload gives the Java field
        # defaults 0.0 / 0.0 / the frame and the payload are
        # not mutated by the call.
        proof = TURRET_READ_SYNC_PROOF.read_text(encoding='utf-8')
        for key in [
            'rotation_preserved',
            'reload_preserved',
            'read_applied',
            'read_empty_not_applied',
            'defaults_zero',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_read_sync(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretReadSyncProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_READ_SYNC_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'rotation_preserved',
            'reload_preserved',
            'read_applied',
            'read_empty_not_applied',
            'defaults_zero',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
