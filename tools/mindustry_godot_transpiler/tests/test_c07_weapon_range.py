import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WEAPONS_CORE_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsCoreState.gd'
WEAPONS_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsState.gd'
WEAPON_RANGE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WeaponRangeProof.gd'


class C07WeaponRangeTests(unittest.TestCase):
    def test_c07_weapon_range_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2539']['godot_owner'], 'SourceWeaponsCoreState.source_weapon_range_state')
        # range() is the Weapon range read (Weapon.java:288-290):
        # `public float range(){` / `return bullet.range;` /
        # `}`. `bullet` is the weapon bullet type
        # (`public BulletType bullet = Bullets.placeholder;`,
        # Weapon.java:33); `bullet.range` is the BulletType
        # range field (`public float range = 0f;`,
        # BulletType.java:161), computed by calculateRange()
        # at init (BulletType.java:854) and afterPatch
        # (BulletType.java:402) -- calculateRange() itself is
        # already ported (SourceBulletTypeInitRangeState.gd),
        # so this slice takes the catalog `bullet.range` as
        # its one input and returns it unchanged. The slice
        # mirrors into the type shard (java_source Weapon.java
        # contains "/type/"); comp stays 572/475.
        self.assertEqual(
            ledger['N2539']['source_symbols'],
            [
                'source_weapon_range_state_result.range',
            ],
        )
        for name in ledger['N2539']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/type/Weapon.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_range_state')
        self.assertEqual(ledger['N2539']['runtime_proof'], '/root/C07WeaponRangeProof')
        self.assertEqual(
            ledger['N2539']['tests'],
            [
                'test_c07_weapon_range_registration',
                'test_all_c07_weapon_range_input_evidence_is_exact',
                'test_weapon_range_state',
                'test_reference_graph_and_actual_c07_weapon_range',
            ],
        )
        self.assertTrue(ledger['N2539']['deferred_exprs'])

    def test_all_c07_weapon_range_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2539']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_range_state')
        slice_sources = {
            'core/src/mindustry/type/Weapon.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2539']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_weapon_range_state(self):
        core = WEAPONS_CORE_STATE.read_text(encoding='utf-8')
        facade = WEAPONS_STATE.read_text(encoding='utf-8')
        # range() (Weapon.java:288-290) for the Weapon family
        # as one pure function: it returns `bullet.range`
        # unchanged. NO driver tick call site (the N2528/N2529/
        # N2530/N2531/N2532/N2533/N2534/N2535/N2536/N2537/
        # N2538 precedent): range() is a catalog read, and no
        # caller reads it today (UnitType.init range/maxRange
        # and Weapon.update shootLength are consumer slices
        # later).
        signature = 'static func source_weapon_range_state(bullet_range: float) -> Dictionary:'
        self.assertIn(signature, core)
        self.assertIn('return {"range": bullet_range}', core)
        self.assertIn('public float range(){', core)
        self.assertIn('return bullet.range;', core)
        self.assertIn('DORMANT', core)
        # The canonical function sits immediately AFTER
        # source_weapon_draw_state (the N2538 function)
        # and BEFORE set_rotation_state.
        self.assertLess(core.index('static func source_weapon_draw_state('), core.index('static func source_weapon_range_state('))
        self.assertLess(core.index('static func source_weapon_range_state('), core.index('static func set_rotation_state('))
        # NO driver tick call site: the definition is the only
        # occurrence of the function name in the core file.
        self.assertEqual(core.count('source_weapon_range_state('), 1)
        # The facade delegates with the same name (the
        # setup_mounts_state precedent): one definition line
        # plus one delegate call line.
        self.assertIn(signature, facade)
        self.assertIn('return source_weapons_core_state.source_weapon_range_state(bullet_range)', facade)
        self.assertEqual(facade.count('source_weapon_range_state('), 2)
        # The proof drives the pure function through the
        # facade on exact legs (bullet_range is the catalog
        # BulletType.range value):
        # 1 zero -> range 0.0 (BulletType.range field default,
        # BulletType.java:161); 2 placeholder 150.0 -> range
        # 150.0 (Bullets.placeholder is BasicBulletType(2.5f,
        # 9, "ohno") with lifetime 60f, so calculateRange()
        # gives speed * lifetime = 2.5 * 60 = 150, drag 0f,
        # maxRange -1f); 3 fractional 37.5 -> range 37.5;
        # 4 large 1000.0 -> range 1000.0.
        proof = WEAPON_RANGE_PROOF.read_text(encoding='utf-8')
        for key in [
            'range_zero',
            'range_placeholder',
            'range_fractional',
            'range_large',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_weapon_range(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WeaponRangeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WEAPON_RANGE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'range_zero',
            'range_placeholder',
            'range_fractional',
            'range_large',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
