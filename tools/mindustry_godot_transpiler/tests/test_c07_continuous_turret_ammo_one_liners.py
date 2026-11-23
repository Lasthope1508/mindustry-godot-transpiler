import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONTINUOUS_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceContinuousTurretBuildPortBridge.gd'
CONTINUOUS_TURRET_AMMO_ONE_LINERS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ContinuousTurretAmmoOneLinersProof.gd'


class C07ContinuousTurretAmmoOneLinersTests(unittest.TestCase):
    def test_c07_continuous_turret_ammo_one_liners_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2421']['godot_owner'], 'PortGame.source_continuous_turret_build_ammo_one_liners_state')
        # ContinuousTurretBuild.useAmmo() (ContinuousTurret.
        # java:54-57), .shouldConsume() (:65-67), .peekAmmo()
        # (:70-72) and .activeSoundVolume() (:171-173) are
        # four one-line pure functions on the
        # SourceContinuousTurretBuildPortBridge.gd, grouped
        # in one slice (grouping approved by the main
        # thread; N2330/N2367/N2381/N2384/N2386/N2389
        # precedent). One slice entry, one owner, one pure
        # function, ONE contract (the N2418 precedent:
        # LaserTurret activeSoundVolume + shouldActiveSound
        # share one owner/function for the same reason --
        # the constant activeSoundVolume takes no inputs,
        # so it cannot own a schema alone: the SSOT
        # validator rejects an input schema with empty
        # keys). useAmmo/peekAmmo return shootType (the
        # ContinuousTurret block field, :15, default
        # Bullets.placeholder) as an explicit Variant
        # param (the N2330 param precedent; the twin
        # N1170/N1172 PowerTurretBuild useAmmo/peekAmmo
        # take the same Variant shape); shouldConsume
        # returns isShooting (the TurretBuild field,
        # Turret.java:292) as an explicit bool param;
        # activeSoundVolume is the constant 1f.
        # `return shootType;` is twin-registered here
        # (N1170/N1172 own it in PowerTurretBuild, both
        # ledgers) and `return isShooting;` is
        # twin-registered here (N2343 TurretBuild
        # .isShooting + N2360 LaserTurretBuild
        # .shouldConsume, local) -- the main thread
        # approved this third twin registration
        # (N1199/N1223, N2389, N2418 precedent) because
        # all four java_methods are 0-hit in both
        # ledgers. hasAmmo() (:60-62) is NOT in this
        # slice -- already owned by N2389. NO driver
        # line: one pure function the setup/tick reads,
        # not per-tick writes. Four new result symbols:
        # use_ammo, should_consume, peek_ammo,
        # active_sound_volume.
        self.assertEqual(
            ledger['N2421']['java_method'],
            'ContinuousTurretBuild.useAmmo(); ContinuousTurretBuild.shouldConsume(); ContinuousTurretBuild.peekAmmo(); ContinuousTurretBuild.activeSoundVolume()',
        )
        self.assertEqual(
            ledger['N2421']['source_symbols'],
            [
                'source_continuous_turret_build_ammo_one_liners_state_result.use_ammo',
                'source_continuous_turret_build_ammo_one_liners_state_result.should_consume',
                'source_continuous_turret_build_ammo_one_liners_state_result.peek_ammo',
                'source_continuous_turret_build_ammo_one_liners_state_result.active_sound_volume',
            ],
        )
        for name in ledger['N2421']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2421']['runtime_proof'], '/root/C07ContinuousTurretAmmoOneLinersProof')
        self.assertEqual(
            ledger['N2421']['tests'],
            [
                'test_c07_continuous_turret_ammo_one_liners_registration',
                'test_all_c07_continuous_turret_ammo_one_liners_input_evidence_is_exact',
                'test_continuous_turret_ammo_one_liners_state',
                'test_reference_graph_and_actual_c07_continuous_turret_ammo_one_liners',
            ],
        )
        self.assertTrue(ledger['N2421']['deferred_exprs'])

    def test_all_c07_continuous_turret_ammo_one_liners_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2421']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2421']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_continuous_turret_ammo_one_liners_state(self):
        bridge = CONTINUOUS_TURRET_BRIDGE.read_text(encoding='utf-8')
        # ContinuousTurretBuild.useAmmo()
        # (ContinuousTurret.java:54-57): the shoot type
        # arrives as an explicit Variant param (the
        # N2330 param precedent). ContinuousTurretBuild
        # .shouldConsume() (:65-67): isShooting as an
        # explicit bool param. ContinuousTurretBuild
        # .peekAmmo() (:70-72): same shoot type param
        # as useAmmo. ContinuousTurretBuild
        # .activeSoundVolume() (:171-173): the constant
        # 1f. One pure function returns all four keys
        # (the N2418 precedent). NO driver line.
        self.assertIn('static func source_continuous_turret_build_ammo_one_liners_state(shoot_type: Variant, is_shooting: bool) -> Dictionary:', bridge)
        self.assertIn('return {"use_ammo": use_ammo, "should_consume": should_consume, "peek_ammo": peek_ammo, "active_sound_volume": active_sound_volume}', bridge)
        for expr in [
            'public class ContinuousTurretBuild extends TurretBuild{',
            'public BulletType shootType = Bullets.placeholder;',
            'public BulletType useAmmo(){',
            '//nothing used directly',
            'return shootType;',
            'public boolean shouldConsume(){',
            'return isShooting;',
            'public BulletType peekAmmo(){',
            'public float activeSoundVolume(){',
            'return 1f;',
            '@Override',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the one pure function
        # with synthetic inputs (no live tick): useAmmo /
        # peekAmmo return the shoot type (and null when
        # there is none) / shouldConsume follows
        # isShooting both ways / activeSoundVolume is
        # always 1f / each result carries only its
        # expected key.
        proof = CONTINUOUS_TURRET_AMMO_ONE_LINERS_PROOF.read_text(encoding='utf-8')
        for key in [
            'use_ammo_returns_shoot_type',
            'use_ammo_returns_null_when_no_type',
            'should_consume_true_when_shooting',
            'should_consume_false_when_not_shooting',
            'peek_ammo_returns_shoot_type',
            'peek_ammo_returns_null_when_no_type',
            'active_sound_volume_is_one',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_continuous_turret_ammo_one_liners(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ContinuousTurretAmmoOneLinersProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_CONTINUOUS_TURRET_AMMO_ONE_LINERS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'use_ammo_returns_shoot_type',
            'use_ammo_returns_null_when_no_type',
            'should_consume_true_when_shooting',
            'should_consume_false_when_not_shooting',
            'peek_ammo_returns_shoot_type',
            'peek_ammo_returns_null_when_no_type',
            'active_sound_volume_is_one',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
