import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONTINUOUS_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceContinuousTurretBuildPortBridge.gd'
CONTINUOUS_TURRET_ESTIMATE_DPS_HAS_AMMO_SHOULD_ACTIVE_SOUND_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ContinuousTurretEstimateDpsHasAmmoShouldActiveSoundProof.gd'


class C07ContinuousTurretEstimateDpsHasAmmoShouldActiveSoundTests(unittest.TestCase):
    def test_c07_continuous_turret_estimate_dps_has_ammo_should_active_sound_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2389']['godot_owner'], 'PortGame.source_continuous_turret_build_estimate_dps_state')
        # ContinuousTurretBuild.estimateDps()+hasAmmo()+
        # shouldActiveSound() gộp (ContinuousTurret.java:43-46
        # + :60-62 + :166-168): estimateDps returns 0f
        # without ammo, else shootType.damage * 60f over
        # the ContinuousBulletType damageInterval (5f
        # default); hasAmmo is canConsume(); shouldActive
        # Sound is bullets.any(). The three methods share
        # one concern (ContinuousTurretBuild ammo/sound
        # state) and each carries only one distinguishing
        # expr, so they are one slice (grouping approved
        # by the main thread; N2330/N2367/N2381/N2384/
        # N2386 precedent). The three distinguishing
        # exprs are `return shootType.damage * 60f /
        # (shootType instanceof ContinuousBulletType c ?
        # c.damageInterval : 5f);`, `return canConsume
        # ();` and `return bullets.any();` (0 hits in
        # both ledgers at probe time). `return bullets
        # .any();` is registered HERE -- LaserTurretBuild
        # .shouldActiveSound (LaserTurret.java:152-154,
        # byte-identical) is DEAD, never scoped again
        # (main-thread allocation, draft batch 21 §2.2).
        # The shared line `if(!hasAmmo()) return 0f;`
        # is evidence only (already owned by N2301),
        # never the sole distinguishing expr. NO driver
        # line: three pure functions the setup/tick
        # reads, not per-tick writes. Three new result
        # symbols: estimate_dps, has_ammo,
        # should_active_sound.
        self.assertEqual(
            ledger['N2389']['java_method'],
            'ContinuousTurretBuild.estimateDps(); ContinuousTurretBuild.hasAmmo(); ContinuousTurretBuild.shouldActiveSound()',
        )
        self.assertEqual(
            ledger['N2389']['source_symbols'],
            [
                'source_continuous_turret_build_estimate_dps_state_result.estimate_dps',
                'source_continuous_turret_build_has_ammo_state_result.has_ammo',
                'source_continuous_turret_build_should_active_sound_state_result.should_active_sound',
            ],
        )
        for name in ledger['N2389']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2389']['runtime_proof'], '/root/C07ContinuousTurretEstimateDpsHasAmmoShouldActiveSoundProof')
        self.assertEqual(
            ledger['N2389']['tests'],
            [
                'test_c07_continuous_turret_estimate_dps_has_ammo_should_active_sound_registration',
                'test_all_c07_continuous_turret_estimate_dps_has_ammo_should_active_sound_input_evidence_is_exact',
                'test_continuous_turret_estimate_dps_has_ammo_should_active_sound_state',
                'test_reference_graph_and_actual_c07_continuous_turret_estimate_dps_has_ammo_should_active_sound',
            ],
        )
        self.assertTrue(ledger['N2389']['deferred_exprs'])

    def test_all_c07_continuous_turret_estimate_dps_has_ammo_should_active_sound_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2389']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2389']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_continuous_turret_estimate_dps_has_ammo_should_active_sound_state(self):
        bridge = CONTINUOUS_TURRET_BRIDGE.read_text(encoding='utf-8')
        # ContinuousTurretBuild.estimateDps()
        # (ContinuousTurret.java:43-46): 0f without ammo,
        # else shootType.damage * 60f over the
        # ContinuousBulletType damageInterval (5f when the
        # shoot type is not a ContinuousBulletType).
        # ContinuousTurretBuild.hasAmmo()
        # (ContinuousTurret.java:60-62): canConsume() as
        # an explicit bool param. ContinuousTurretBuild
        # .shouldActiveSound() (ContinuousTurret.java:
        # 166-168): bullets.any() -- the bullets Seq
        # arrives as an explicit Array (the N2330 param
        # precedent); arc Seq.any() is size > 0, so the
        # port reads not bullets.is_empty(). hasAmmo
        # inside estimateDps is the callee of this very
        # slice, passed as a bool param, never re-ported.
        # NO driver line.
        self.assertIn('static func source_continuous_turret_build_estimate_dps_state(has_ammo: bool, shoot_type_damage: float, is_continuous_bullet_type: bool, damage_interval: float) -> Dictionary:', bridge)
        self.assertIn('static func source_continuous_turret_build_has_ammo_state(can_consume: bool) -> Dictionary:', bridge)
        self.assertIn('static func source_continuous_turret_build_should_active_sound_state(bullets: Array) -> Dictionary:', bridge)
        self.assertIn('return {"estimate_dps": estimate_dps}', bridge)
        self.assertIn('return {"has_ammo": has_ammo}', bridge)
        self.assertIn('return {"should_active_sound": should_active_sound}', bridge)
        for expr in [
            'public float estimateDps(){',
            'if(!hasAmmo()) return 0f;',
            'return shootType.damage * 60f / (shootType instanceof ContinuousBulletType c ? c.damageInterval : 5f);',
            'public boolean hasAmmo(){',
            'return canConsume();',
            'public boolean shouldActiveSound(){',
            'return bullets.any();',
            '@Override',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure functions with
        # synthetic inputs (no live tick): estimateDps is
        # 0 without ammo / uses the damageInterval for a
        # ContinuousBulletType / defaults to 5f otherwise
        # / hasAmmo follows canConsume both ways /
        # shouldActiveSound follows bullets emptiness /
        # each result carries only its expected key / the
        # bullets input is never mutated.
        proof = CONTINUOUS_TURRET_ESTIMATE_DPS_HAS_AMMO_SHOULD_ACTIVE_SOUND_PROOF.read_text(encoding='utf-8')
        for key in [
            'estimate_dps_zero_without_ammo',
            'estimate_dps_uses_damage_interval',
            'estimate_dps_defaults_interval_five',
            'has_ammo_true_when_can_consume',
            'has_ammo_false_when_cannot_consume',
            'should_active_sound_true_when_bullets',
            'should_active_sound_false_when_empty',
            'bullets_input_unmutated',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_continuous_turret_estimate_dps_has_ammo_should_active_sound(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ContinuousTurretEstimateDpsHasAmmoShouldActiveSoundProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_CONTINUOUS_TURRET_ESTIMATE_DPS_HAS_AMMO_SHOULD_ACTIVE_SOUND_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'estimate_dps_zero_without_ammo',
            'estimate_dps_uses_damage_interval',
            'estimate_dps_defaults_interval_five',
            'has_ammo_true_when_can_consume',
            'has_ammo_false_when_cannot_consume',
            'should_active_sound_true_when_bullets',
            'should_active_sound_false_when_empty',
            'bullets_input_unmutated',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
