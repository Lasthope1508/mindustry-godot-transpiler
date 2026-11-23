import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WEAPONS_CORE_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsCoreState.gd'
WEAPONS_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsState.gd'
WEAPON_UPDATE_AIM_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WeaponUpdateAimProof.gd'


class C07WeaponUpdateAimTests(unittest.TestCase):
    def test_c07_weapon_update_aim_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2541']['godot_owner'], 'SourceWeaponsCoreState.source_weapon_update_aim_state')
        # update() leg 2 (Weapon.java:313-315, :350-371, :373,
        # bulletRotation :455-457): mount position + rotate
        # block + weapon rotation / bullet position / shoot
        # angle + alwaysShooting. `mount.shoot` /
        # `mount.rotate` / `mount.aimX` / `mount.aimY` come
        # from the autoTarget block (:315-347) as FRAME
        # INPUTS (the N2540 `can` precedent: that block is
        # BLOCKED on the live entity scan, so its outputs
        # are inputs here, not re-ported).
        self.assertEqual(
            ledger['N2541']['source_symbols'],
            [
                'source_weapon_update_aim_state_result.mount_x',
                'source_weapon_update_aim_state_result.mount_y',
                'source_weapon_update_aim_state_result.mount_rotation',
                'source_weapon_update_aim_state_result.mount_target_rotation',
                'source_weapon_update_aim_state_result.weapon_rotation',
                'source_weapon_update_aim_state_result.bullet_x',
                'source_weapon_update_aim_state_result.bullet_y',
                'source_weapon_update_aim_state_result.shoot_angle',
                'source_weapon_update_aim_state_result.mount_shoot',
            ],
        )
        for name in ledger['N2541']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/type/Weapon.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_update_aim_state')
        self.assertEqual(ledger['N2541']['runtime_proof'], '/root/C07WeaponUpdateAimProof')
        self.assertEqual(
            ledger['N2541']['tests'],
            [
                'test_c07_weapon_update_aim_registration',
                'test_all_c07_weapon_update_aim_input_evidence_is_exact',
                'test_weapon_update_aim_state',
                'test_reference_graph_and_actual_c07_weapon_update_aim',
            ],
        )
        self.assertTrue(ledger['N2541']['deferred_exprs'])

    def test_all_c07_weapon_update_aim_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2541']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_update_aim_state')
        slice_sources = {
            'core/src/mindustry/type/Weapon.java',
            'core/src/mindustry/entities/units/WeaponMount.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2541']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_weapon_update_aim_state(self):
        core = WEAPONS_CORE_STATE.read_text(encoding='utf-8')
        facade = WEAPONS_STATE.read_text(encoding='utf-8')
        # update() leg 2 (Weapon.java:313-315, :350-371,
        # :373, bulletRotation :455-457) for the Weapon
        # family as one pure function: mount position,
        # rotate block (moveToward + rotationLimit clamp),
        # !rotate branch, weapon rotation, bullet position,
        # shoot angle via bulletRotation, alwaysShooting.
        # NO driver tick call site (the
        # N2528/N2529/N2530/N2531/N2532/N2533/N2534/N2535/
        # N2536/N2537/N2538/N2539/N2540 precedent): update()
        # has no driver in the port yet, and no caller reads
        # the new function today.
        signature = 'static func source_weapon_update_aim_state(unit_x: float, unit_y: float, unit_rotation: float, weapon_x: float, weapon_y: float, weapon_shoot_x: float, weapon_shoot_y: float, mount_rotation: float, mount_target_rotation: float, mount_aim_x: float, mount_aim_y: float, mount_shoot: bool, mount_rotate: bool, can: bool, rotate: bool, rotate_speed: float, rotation_limit: float, base_rotation: float, always_shooting: bool, source_delta: float) -> Dictionary:'
        self.assertIn(signature, core)
        self.assertIn('mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),', core)
        self.assertIn('mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y);', core)
        self.assertIn('if(rotate && (mount.rotate || mount.shoot) && can){', core)
        self.assertIn('mount.targetRotation = Angles.angle(axisX, axisY, mount.aimX, mount.aimY) - unit.rotation;', core)
        self.assertIn('mount.rotation = Angles.moveToward(mount.rotation, mount.targetRotation, rotateSpeed * Time.delta);', core)
        self.assertIn('if(rotationLimit < 360){', core)
        self.assertIn('float dst = Angles.angleDist(mount.rotation, baseRotation);', core)
        self.assertIn('if(dst > rotationLimit/2f){', core)
        self.assertIn('mount.rotation = Angles.moveToward(mount.rotation, baseRotation, dst - rotationLimit/2f);', core)
        self.assertIn('mount.rotation = baseRotation;', core)
        self.assertIn('mount.targetRotation = unit.angleTo(mount.aimX, mount.aimY);', core)
        self.assertIn('weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),', core)
        self.assertIn('bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY),', core)
        self.assertIn('bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY),', core)
        self.assertIn('shootAngle = bulletRotation(unit, mount, bulletX, bulletY);', core)
        self.assertIn('if(alwaysShooting) mount.shoot = true;', core)
        self.assertIn('return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation;', core)
        self.assertIn('DORMANT', core)
        # The canonical function sits immediately AFTER
        # source_weapon_update_decay_state (the N2540
        # function) and BEFORE set_rotation_state.
        self.assertLess(core.index('static func source_weapon_update_decay_state('), core.index('static func source_weapon_update_aim_state('))
        self.assertLess(core.index('static func source_weapon_update_aim_state('), core.index('static func set_rotation_state('))
        # NO driver tick call site: the definition is the only
        # occurrence of the function name in the core file.
        self.assertEqual(core.count('source_weapon_update_aim_state('), 1)
        # The facade delegates with the same name (the
        # setup_mounts_state precedent): one definition line
        # plus one delegate call line.
        self.assertIn(signature, facade)
        self.assertIn('return source_weapons_core_state.source_weapon_update_aim_state(unit_x, unit_y, unit_rotation, weapon_x, weapon_y, weapon_shoot_x, weapon_shoot_y, mount_rotation, mount_target_rotation, mount_aim_x, mount_aim_y, mount_shoot, mount_rotate, can, rotate, rotate_speed, rotation_limit, base_rotation, always_shooting, source_delta)', facade)
        self.assertEqual(facade.count('source_weapon_update_aim_state('), 2)
        # The proof drives the pure function through the
        # facade on exact legs (unit (100, 100), rotation
        # 90, weapon offsets x 5 / y 0, shoot offsets x 0 /
        # y 3, rotateSpeed 20, rotationLimit 361, base
        # rotation 0, delta 1.0 unless noted):
        # 1 mount_position: mount (105, 100); 2
        # rotate_toward: rotate, aim (115, 100) ->
        # targetRotation -90, rotation 0 -> -20; 3
        # rotation_limit_clamp: limit 40, rotation 50 ->
        # moveToward 30, dst 30 > 20 -> clamp to 20; 4
        # no_rotate_branch: !rotate -> rotation
        # baseRotation 10, targetRotation angleTo 0; 5
        # weapon_rotation: !rotate -> 90 - 90 + 10 = 10; 6
        # bullet_position: !rotate, weaponRotation 10 ->
        # bullet (104.479055, 102.954423); 7
        # shoot_angle_rotate: rotate -> 90 + (-20) = 70; 8
        # shoot_angle_aim: !rotate, shoot (0, 0), aim (115,
        # 100) -> 0 + (90 - 0) + 10 = 100; 9
        # always_shooting: alwaysShooting true, mount.shoot
        # false -> mount_shoot true, and the rotate block
        # still sees the pre-alwaysShooting shoot false
        # (rotation stays 5).
        proof = WEAPON_UPDATE_AIM_PROOF.read_text(encoding='utf-8')
        for key in [
            'mount_position',
            'rotate_toward',
            'rotation_limit_clamp',
            'no_rotate_branch',
            'weapon_rotation',
            'bullet_position',
            'shoot_angle_rotate',
            'shoot_angle_aim',
            'always_shooting',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_weapon_update_aim(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WeaponUpdateAimProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WEAPON_UPDATE_AIM_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'mount_position',
            'rotate_toward',
            'rotation_limit_clamp',
            'no_rotate_branch',
            'weapon_rotation',
            'bullet_position',
            'shoot_angle_rotate',
            'shoot_angle_aim',
            'always_shooting',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
