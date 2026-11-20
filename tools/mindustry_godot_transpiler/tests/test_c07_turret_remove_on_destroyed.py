import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_REMOVE_ON_DESTROYED_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretRemoveOnDestroyedProof.gd'


class C07TurretRemoveOnDestroyedTests(unittest.TestCase):
    def test_c07_turret_remove_on_destroyed_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2350']['godot_owner'], 'SourceTurretBuildState.source_turret_remove_state')
        # TurretBuild.remove() (Turret.java:303-308):
        # `@Override`
        # `public void remove(){`
        # `super.remove();`
        # `if(soundLoop != null){`
        # `soundLoop.stop();`
        # `}`
        # `}`
        # and TurretBuild.onDestroyed() (Turret.java:311-317):
        # `@Override`
        # `public void onDestroyed(){`
        # `super.onDestroyed();`
        # `if(soundLoop != null){`
        # `soundLoop.stop();`
        # `}`
        # `}`
        # on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
        # (Turret.java:277). soundLoop is the TurretBuild field
        # (`public @Nullable SoundLoop soundLoop = (loopSound ==
        # Sounds.none ? null : new SoundLoop(loopSound,
        # loopSoundVolume));`, Turret.java:298) and arrives as
        # the explicit bool has_sound_loop (the minRange
        # has_ammo precedent -- a null check carried as an
        # explicit bool; GDScript has no SoundLoop object
        # here). super.remove()/super.onDestroyed() are the
        # Building base -- deferred, not ported. NO driver
        # line: the engine lifecycle calls remove() /
        # onDestroyed(); no call site is ported here (the
        # shouldTurn/isShooting precedent). NO SoundLoop
        # playback: both functions only return the stopped
        # flag, never real audio. Two new result symbols:
        # one per function.
        self.assertEqual(
            ledger['N2350']['source_symbols'],
            [
                'source_turret_remove_state_result.sound_loop_stopped',
                'source_turret_on_destroyed_state_result.sound_loop_stopped',
            ],
        )
        for name in ledger['N2350']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2350']['runtime_proof'], '/root/C07TurretRemoveOnDestroyedProof')
        self.assertEqual(
            ledger['N2350']['tests'],
            [
                'test_c07_turret_remove_on_destroyed_registration',
                'test_all_c07_turret_remove_on_destroyed_input_evidence_is_exact',
                'test_turret_remove_on_destroyed_state',
                'test_reference_graph_and_actual_c07_turret_remove_on_destroyed',
            ],
        )
        self.assertTrue(ledger['N2350']['deferred_exprs'])

    def test_all_c07_turret_remove_on_destroyed_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2350']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2350']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_remove_on_destroyed_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.remove() (Turret.java:303-308) and
        # TurretBuild.onDestroyed() (Turret.java:311-317) both
        # stop the sound loop when it is non-null, and do
        # nothing when it is null. The null check arrives as
        # the explicit bool has_sound_loop (the minRange
        # has_ammo precedent); the frame carries no tracked
        # key for either lifecycle method (the isShooting
        # :429 precedent). NO driver line: both are pure
        # lifecycle functions, not per-tick writes.
        self.assertIn('static func source_turret_remove_state(frame: Dictionary, has_sound_loop: bool) -> Dictionary:', turret)
        self.assertIn('return {"sound_loop_stopped": has_sound_loop}', turret)
        self.assertIn('static func source_turret_on_destroyed_state(frame: Dictionary, has_sound_loop: bool) -> Dictionary:', turret)
        for expr in [
            'public @Nullable SoundLoop soundLoop = (loopSound == Sounds.none ? null : new SoundLoop(loopSound, loopSoundVolume));',
            '@Override',
            'public void remove(){',
            'super.remove();',
            'if(soundLoop != null){',
            'soundLoop.stop();',
            'public void onDestroyed(){',
            'super.onDestroyed();',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure functions with
        # synthetic frames (no live tick: both are pure
        # lifecycle functions over explicit params): remove
        # stops a live loop / remove is a no-op for a null
        # loop / remove returns only its one key / remove
        # does not mutate its input / onDestroyed stops a
        # live loop / onDestroyed is a no-op for a null loop
        # / onDestroyed returns only its one key /
        # onDestroyed does not mutate its input.
        proof = TURRET_REMOVE_ON_DESTROYED_PROOF.read_text(encoding='utf-8')
        for key in [
            'remove_stops_loop',
            'remove_null_loop_noop',
            'remove_returns_only_one_key',
            'remove_input_unmutated',
            'on_destroyed_stops_loop',
            'on_destroyed_null_loop_noop',
            'on_destroyed_returns_only_one_key',
            'on_destroyed_input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_remove_on_destroyed(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretRemoveOnDestroyedProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_REMOVE_ON_DESTROYED_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'remove_stops_loop',
            'remove_null_loop_noop',
            'remove_returns_only_one_key',
            'remove_input_unmutated',
            'on_destroyed_stops_loop',
            'on_destroyed_null_loop_noop',
            'on_destroyed_returns_only_one_key',
            'on_destroyed_input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
