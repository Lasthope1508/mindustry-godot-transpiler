import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LASER_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceLaserTurretBuildPortBridge.gd'
LASER_TURRET_ACTIVE_SOUND_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaserTurretActiveSoundVolumeProof.gd'


class C07LaserTurretActiveSoundVolumeTests(unittest.TestCase):
    def test_c07_laser_turret_active_sound_volume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2418']['godot_owner'], 'PortGame.source_laser_turret_build_active_sound_state')
        # LaserTurretBuild.activeSoundVolume()
        # (LaserTurret.java:147-149):
        # `@Override`
        # `public float activeSoundVolume(){`
        # `return 1f;`
        # `}`
        # and LaserTurretBuild.shouldActiveSound()
        # (LaserTurret.java:152-154):
        # `@Override`
        # `public boolean shouldActiveSound(){`
        # `return bullets.any();`
        # `}`
        # on `public class LaserTurretBuild extends PowerTurretBuild{`
        # (LaserTurret.java:44) inside
        # `public class LaserTurret extends PowerTurret{`.
        # MERGED slice (the N2346/N2389 precedent): ONE pure
        # function, ONE owner, covering BOTH methods -- the
        # volume is a constant 1f and the sound gate is
        # bullets.any(); both are read by the same updateTile
        # soundLoop call, and both take the same bullets-any()
        # state. bullets is `public Seq<BulletEntry> bullets
        # = new Seq<>();` (LaserTurret.java:45): the seq
        # itself is NOT ported -- its emptiness arrives as
        # the explicit has_bullets param (the N2330 param
        # precedent). NO driver line: pure read accessors the
        # tick reads, not per-tick writes. Two new result
        # symbols: active_sound_volume + should_active_sound.
        self.assertEqual(
            ledger['N2418']['source_symbols'],
            [
                'source_laser_turret_build_active_sound_state_result.active_sound_volume',
                'source_laser_turret_build_active_sound_state_result.should_active_sound',
            ],
        )
        for name in ledger['N2418']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2418']['runtime_proof'], '/root/C07LaserTurretActiveSoundVolumeProof')
        self.assertEqual(
            ledger['N2418']['tests'],
            [
                'test_c07_laser_turret_active_sound_volume_registration',
                'test_all_c07_laser_turret_active_sound_volume_input_evidence_is_exact',
                'test_laser_turret_active_sound_volume_state',
                'test_reference_graph_and_actual_c07_laser_turret_active_sound_volume',
            ],
        )
        self.assertTrue(ledger['N2418']['deferred_exprs'])

    def test_all_c07_laser_turret_active_sound_volume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2418']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2418']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_laser_turret_active_sound_volume_state(self):
        bridge = LASER_TURRET_BRIDGE.read_text(encoding='utf-8')
        # LaserTurretBuild.activeSoundVolume()
        # (LaserTurret.java:147-149) always returns 1f, and
        # LaserTurretBuild.shouldActiveSound()
        # (LaserTurret.java:152-154) returns bullets.any().
        # The bullets seq arrives as the explicit
        # has_bullets param; there is no dict frame input,
        # so every input is a scalar and there is no
        # input-unmutated key for this slice (unlike the
        # frame-taking Turret accessors). NO driver line:
        # pure read accessors, not per-tick writes.
        self.assertIn('static func source_laser_turret_build_active_sound_state(has_bullets: bool) -> Dictionary:', bridge)
        self.assertIn('return {"active_sound_volume": active_sound_volume, "should_active_sound": should_active_sound}', bridge)
        for expr in [
            'public class LaserTurret extends PowerTurret{',
            'public class LaserTurretBuild extends PowerTurretBuild{',
            '@Override',
            'public float activeSoundVolume(){',
            'return 1f;',
            'public boolean shouldActiveSound(){',
            'return bullets.any();',
            'public Seq<BulletEntry> bullets = new Seq<>();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with
        # synthetic scalar inputs (no live tick): volume is
        # always 1f / sound plays while bullets are around /
        # silent with no bullets / each result carries only
        # its two keys.
        proof = LASER_TURRET_ACTIVE_SOUND_PROOF.read_text(encoding='utf-8')
        for key in [
            'active_sound_volume_is_one',
            'should_active_sound_bullets_around',
            'should_active_sound_no_bullets',
            'active_sound_returns_only_two_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_laser_turret_active_sound_volume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaserTurretActiveSoundVolumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LASER_TURRET_ACTIVE_SOUND_VOLUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'active_sound_volume_is_one',
            'should_active_sound_bullets_around',
            'should_active_sound_no_bullets',
            'active_sound_returns_only_two_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
