import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LASER_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceLaserTurretBuildPortBridge.gd'
LASER_TURRET_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaserTurretShouldConsumeProof.gd'


class C07LaserTurretShouldConsumeTests(unittest.TestCase):
    def test_c07_laser_turret_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2360']['godot_owner'], 'PortGame.source_laser_turret_build_should_consume_state')
        # LaserTurretBuild.shouldConsume() (LaserTurret.java:53-58):
        # `@Override`
        # `public boolean shouldConsume(){`
        # `//still consumes power when bullet is around`
        # `if(bullets.any() || isActive()) return true;`
        # `return isShooting;`
        # `}`
        # on `public class LaserTurretBuild extends PowerTurretBuild{`
        # (LaserTurret.java:44) inside
        # `public class LaserTurret extends PowerTurret{`.
        # This is the LaserTurret override: it still consumes
        # power while a bullet is around (bullets.any()) or
        # while it is active (isActive(), N2328); otherwise it
        # consumes only while shooting (isShooting, N2343).
        # The other shouldConsume overrides own their own
        # bodies and are NOT touched here -- TurretBuild base
        # (N2291), ContinuousLiquidTurretBuild (N1225),
        # TractorBeamBuild (N1235), DrillBuild (N2338),
        # BurstDrillBuild (N2295). NO driver line: a pure
        # predicate the power graph reads, not a per-tick
        # write. One new result symbol: should_consume. The
        # bullets seq is NOT ported: its emptiness arrives as
        # the explicit has_bullets param (the N2330 param
        # precedent); isActive()/isShooting arrive as explicit
        # params (owned at N2328/N2343, not re-ported here).
        self.assertEqual(
            ledger['N2360']['source_symbols'],
            [
                'source_laser_turret_build_should_consume_state_result.should_consume',
            ],
        )
        for name in ledger['N2360']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2360']['runtime_proof'], '/root/C07LaserTurretShouldConsumeProof')
        self.assertEqual(
            ledger['N2360']['tests'],
            [
                'test_c07_laser_turret_should_consume_registration',
                'test_all_c07_laser_turret_should_consume_input_evidence_is_exact',
                'test_laser_turret_should_consume_state',
                'test_reference_graph_and_actual_c07_laser_turret_should_consume',
            ],
        )
        self.assertTrue(ledger['N2360']['deferred_exprs'])

    def test_all_c07_laser_turret_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2360']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2360']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_laser_turret_should_consume_state(self):
        bridge = LASER_TURRET_BRIDGE.read_text(encoding='utf-8')
        # LaserTurretBuild.shouldConsume()
        # (LaserTurret.java:53-58) still consumes power while
        # a bullet is around or while active, and otherwise
        # only while shooting. The bullets seq / isActive() /
        # isShooting arrive as explicit params; there is no
        # dict frame input, so every input is a scalar and
        # there is no input-unmutated key for this slice
        # (unlike the frame-taking Turret accessors). NO
        # driver line: a pure predicate, not a per-tick write.
        self.assertIn('static func source_laser_turret_build_should_consume_state(has_bullets: bool, is_active: bool, is_shooting: bool) -> Dictionary:', bridge)
        self.assertIn('return {"should_consume": should_consume}', bridge)
        for expr in [
            'public class LaserTurret extends PowerTurret{',
            'public class LaserTurretBuild extends PowerTurretBuild{',
            '@Override',
            'public boolean shouldConsume(){',
            '//still consumes power when bullet is around',
            'if(bullets.any() || isActive()) return true;',
            'return isShooting;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with
        # synthetic scalar inputs (no live tick): bullets
        # around consumes / active consumes / shooting
        # consumes / idle consumes nothing / each result
        # carries only its one key.
        proof = LASER_TURRET_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'should_consume_bullets_around',
            'should_consume_active',
            'should_consume_shooting',
            'should_consume_idle',
            'should_consume_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_laser_turret_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaserTurretShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LASER_TURRET_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'should_consume_bullets_around',
            'should_consume_active',
            'should_consume_shooting',
            'should_consume_idle',
            'should_consume_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
