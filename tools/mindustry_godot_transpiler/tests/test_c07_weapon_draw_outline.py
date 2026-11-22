import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WEAPONS_CORE_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsCoreState.gd'
WEAPONS_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsState.gd'
WEAPON_DRAW_OUTLINE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WeaponDrawOutlineProof.gd'


class C07WeaponDrawOutlineTests(unittest.TestCase):
    def test_c07_weapon_draw_outline_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2537']['godot_owner'], 'SourceWeaponsCoreState.source_weapon_draw_outline_state')
        # drawOutline() is the Weapon draw read (Weapon.java:196-213):
        # `public void drawOutline(Unit unit, WeaponMount mount){` /
        # `if(!outlineRegion.found()) return;` /
        # `rotation = unit.rotation - 90,` /
        # `realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,` /
        # `weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),` /
        # `wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),` /
        # `wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);` /
        # `Draw.xscl = -Mathf.sign(flipSprite);` /
        # `Draw.rect(outlineRegion, wx, wy, weaponRotation);`.
        # `outline_found` is a bool param (the guard is first in Java;
        # the draw_team_top_state precedent takes `team_region_found`
        # as its first param and returns `{"visible": false}` when
        # not found). The found branch returns exactly the five
        # keys `visible`, `outline_x`, `outline_y`,
        # `weapon_rotation`, `xscl` (the N2526 precedent -- every
        # return key is a symbol); the intermediates `rotation` /
        # `real_recoil` are NOT return keys -- they are encoded in
        # `outline_x` / `outline_y` / `weapon_rotation`. The slice
        # mirrors into the type shard (java_source Weapon.java
        # contains "/type/"); comp stays 572/475.
        self.assertEqual(
            ledger['N2537']['source_symbols'],
            [
                'source_weapon_draw_outline_state_result.visible',
                'source_weapon_draw_outline_state_result.outline_x',
                'source_weapon_draw_outline_state_result.outline_y',
                'source_weapon_draw_outline_state_result.weapon_rotation',
                'source_weapon_draw_outline_state_result.xscl',
            ],
        )
        for name in ledger['N2537']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/type/Weapon.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_draw_outline_state')
        self.assertEqual(ledger['N2537']['runtime_proof'], '/root/C07WeaponDrawOutlineProof')
        self.assertEqual(
            ledger['N2537']['tests'],
            [
                'test_c07_weapon_draw_outline_registration',
                'test_all_c07_weapon_draw_outline_input_evidence_is_exact',
                'test_weapon_draw_outline_state',
                'test_reference_graph_and_actual_c07_weapon_draw_outline',
            ],
        )
        self.assertTrue(ledger['N2537']['deferred_exprs'])

    def test_all_c07_weapon_draw_outline_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2537']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_draw_outline_state')
        slice_sources = {
            'core/src/mindustry/type/Weapon.java',
            'core/src/mindustry/entities/units/WeaponMount.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2537']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_weapon_draw_outline_state(self):
        core = WEAPONS_CORE_STATE.read_text(encoding='utf-8')
        facade = WEAPONS_STATE.read_text(encoding='utf-8')
        # drawOutline() (Weapon.java:196-213) for the Weapon
        # family as one pure function, in exact Java order:
        # guard first, then rotation / realRecoil /
        # weaponRotation / wx / wy, then xscl. The function
        # returns `{"visible": false}` when the outline
        # region is not found (the draw_team_top_state
        # precedent) and the five draw keys otherwise. NO
        # driver tick call site (the N2528/N2529/N2530/
        # N2531/N2532/N2533/N2534/N2535 precedent):
        # drawOutline() is draw code, rendering is outside
        # the game, and no caller reads it today (its only
        # Java caller is draw() when `top` is true,
        # Weapon.java:227-229, itself draw code).
        signature = 'static func source_weapon_draw_outline_state(outline_found: bool, unit_rotation: float, unit_x: float, unit_y: float, mount_recoil: float, mount_rotation: float, rotate: bool, base_rotation: float, recoil: float, recoil_pow: float, weapon_x: float, weapon_y: float, flip_sprite: bool) -> Dictionary:'
        self.assertIn(signature, core)
        self.assertIn('return {"visible": false}', core)
        self.assertIn('return {"visible": true, "outline_x": wx, "outline_y": wy, "weapon_rotation": weapon_rotation, "xscl": xscl}', core)
        self.assertIn('public void drawOutline(Unit unit, WeaponMount mount){', core)
        self.assertIn('if(!outlineRegion.found()) return;', core)
        self.assertIn('rotation = unit.rotation - 90,', core)
        self.assertIn('realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,', core)
        self.assertIn('weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),', core)
        self.assertIn('wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),', core)
        self.assertIn('wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);', core)
        self.assertIn('Draw.xscl = -Mathf.sign(flipSprite);', core)
        self.assertIn('Draw.rect(outlineRegion, wx, wy, weaponRotation);', core)
        self.assertIn('DORMANT', core)
        # The trns legs reuse the existing port (no scalar
        # trnsx/trnsy port exists): source_angles_trns_vec
        # (SourceMathState.gd:140) computes exactly
        # Angles.trnsx/trnsy(angle, x, y) (arc Angles.java:74-82).
        self.assertIn('source_angles_trns_vec(rotation, weapon_x, weapon_y)', core)
        self.assertIn('source_angles_trns_vec(weapon_rotation, 0.0, -real_recoil)', core)
        # xscl is -Mathf.sign(flipSprite); arc Mathf.sign(boolean)
        # (Mathf.java:203-205) is 1 if true else -1, so xscl is
        # -1.0 when flip_sprite is true, +1.0 otherwise.
        self.assertIn('var xscl: float = -1.0 if flip_sprite else 1.0', core)
        # The canonical function sits immediately AFTER
        # source_weapon_shots_per_sec_state (the N2535 function)
        # and BEFORE set_rotation_state.
        self.assertLess(core.index('static func source_weapon_shots_per_sec_state('), core.index('static func source_weapon_draw_outline_state('))
        self.assertLess(core.index('static func source_weapon_draw_outline_state('), core.index('static func set_rotation_state('))
        # NO driver tick call site: the definition is the only
        # occurrence of the function name in the core file.
        self.assertEqual(core.count('source_weapon_draw_outline_state('), 1)
        # The facade delegates with the same name (the
        # setup_mounts_state precedent): one definition line
        # plus one delegate call line.
        self.assertIn(signature, facade)
        self.assertIn('return source_weapons_core_state.source_weapon_draw_outline_state(outline_found, unit_rotation, unit_x, unit_y, mount_recoil, mount_rotation, rotate, base_rotation, recoil, recoil_pow, weapon_x, weapon_y, flip_sprite)', facade)
        self.assertEqual(facade.count('source_weapon_draw_outline_state('), 2)
        # The proof drives the pure function through the
        # facade on exact legs (all with Java defaults unless
        # noted: unit_rotation 90, unit 0,0, mount_recoil 0,
        # mount_rotation 0, rotate false, base_rotation 0,
        # recoil 1.5, recoil_pow 1.8, weapon x 5, y 0,
        # flip_sprite false, outline_found true):
        # 1 Java defaults -> wx 5.0, wy 0.0, weapon_rotation
        # 0.0, xscl 1.0, visible true; 2 outline not found ->
        # visible false; 3 flip_sprite true -> xscl -1.0;
        # 4 rotate true, mount_rotation 30 -> weapon_rotation
        # 30.0; 5 mount_recoil 1.0 -> realRecoil 1.5, wy -1.5;
        # 6 unit_rotation 180 -> wx 0.0, wy 5.0; 7 rotate
        # false, base_rotation 45 -> weapon_rotation 45.0;
        # 8 fractional unit_rotation 45 -> wx ~3.5355,
        # wy ~-3.5355.
        proof = WEAPON_DRAW_OUTLINE_PROOF.read_text(encoding='utf-8')
        for key in [
            'outline_java_defaults',
            'outline_not_found',
            'outline_flip_sprite',
            'outline_rotate_mount',
            'outline_recoil',
            'outline_unit_rot_180',
            'outline_base_rotation',
            'outline_fractional',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_weapon_draw_outline(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WeaponDrawOutlineProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WEAPON_DRAW_OUTLINE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'outline_java_defaults',
            'outline_not_found',
            'outline_flip_sprite',
            'outline_rotate_mount',
            'outline_recoil',
            'outline_unit_rot_180',
            'outline_base_rotation',
            'outline_fractional',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
