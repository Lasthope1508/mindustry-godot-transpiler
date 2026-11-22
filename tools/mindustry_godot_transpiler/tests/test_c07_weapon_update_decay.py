import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WEAPONS_CORE_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsCoreState.gd'
WEAPONS_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsState.gd'
WEAPON_UPDATE_DECAY_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WeaponUpdateDecayProof.gd'


class C07WeaponUpdateDecayTests(unittest.TestCase):
    def test_c07_weapon_update_decay_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2540']['godot_owner'], 'SourceWeaponsCoreState.source_weapon_update_decay_state')
        # update() leg 1 (Weapon.java:293-306): reload decay +
        # recoil approach + per-barrel recoils decay +
        # smoothReload lerp + charge gate + warmup approach /
        # lerp. `can` is the bool input for `unit.canShoot()`
        # (Weapon.java:293); `lastReload` (:294) is NOT
        # returned by leg 1 (the side-flip leg :427-432
        # captures the pre-decay reload in a later slice).
        self.assertEqual(
            ledger['N2540']['source_symbols'],
            [
                'source_weapon_update_decay_state_result.reload',
                'source_weapon_update_decay_state_result.recoil',
                'source_weapon_update_decay_state_result.recoils',
                'source_weapon_update_decay_state_result.smooth_reload',
                'source_weapon_update_decay_state_result.charge',
                'source_weapon_update_decay_state_result.warmup',
            ],
        )
        for name in ledger['N2540']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/type/Weapon.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_update_decay_state')
        self.assertEqual(ledger['N2540']['runtime_proof'], '/root/C07WeaponUpdateDecayProof')
        self.assertEqual(
            ledger['N2540']['tests'],
            [
                'test_c07_weapon_update_decay_registration',
                'test_all_c07_weapon_update_decay_input_evidence_is_exact',
                'test_weapon_update_decay_state',
                'test_reference_graph_and_actual_c07_weapon_update_decay',
            ],
        )
        self.assertTrue(ledger['N2540']['deferred_exprs'])

    def test_all_c07_weapon_update_decay_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2540']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_update_decay_state')
        slice_sources = {
            'core/src/mindustry/type/Weapon.java',
            'core/src/mindustry/entities/units/WeaponMount.java',
            'core/src/mindustry/entities/pattern/ShootPattern.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2540']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_weapon_update_decay_state(self):
        core = WEAPONS_CORE_STATE.read_text(encoding='utf-8')
        facade = WEAPONS_STATE.read_text(encoding='utf-8')
        # update() leg 1 (Weapon.java:293-306) for the Weapon
        # family as one pure function: reload decay, recoil
        # approach, per-barrel recoils decay, smoothReload
        # lerp off the UPDATED reload, charge gate, warmup
        # approach / lerp. NO driver tick call site (the
        # N2528/N2529/N2530/N2531/N2532/N2533/N2534/N2535/
        # N2536/N2537/N2538/N2539 precedent): update() has no
        # driver in the port yet, and no caller reads the new
        # function today.
        signature = 'static func source_weapon_update_decay_state(mount_reload: float, mount_recoil: float, mount_recoils: Array, mount_smooth_reload: float, mount_charge: float, mount_charging: bool, mount_shoot: bool, mount_warmup: float, has_continuous_bullet: bool, recoils: int, recoil_time: float, weapon_reload: float, smooth_reload_speed: float, first_shot_delay: float, shoot_warmup_speed: float, linear_warmup: bool, continuous: bool, can: bool, source_delta: float, reload_multiplier: float) -> Dictionary:'
        self.assertIn(signature, core)
        self.assertIn('boolean can = unit.canShoot();', core)
        self.assertIn('mount.reload = Math.max(mount.reload - Time.delta * unit.reloadMultiplier, 0);', core)
        self.assertIn('mount.recoil = Mathf.approachDelta(mount.recoil, 0, unit.reloadMultiplier / recoilTime);', core)
        self.assertIn('if(mount.recoils == null) mount.recoils = new float[recoils];', core)
        self.assertIn('mount.smoothReload = Mathf.lerpDelta(mount.smoothReload, mount.reload / reload, smoothReloadSpeed);', core)
        self.assertIn('mount.charge = mount.charging && shoot.firstShotDelay > 0 ? Mathf.approachDelta(mount.charge, 1, 1 / shoot.firstShotDelay) : 0;', core)
        self.assertIn('float warmupTarget = (can && mount.shoot) || (continuous && mount.bullet != null) || mount.charging ? 1f : 0f;', core)
        self.assertIn('DORMANT', core)
        # The canonical function sits immediately AFTER
        # source_weapon_range_state (the N2539 function)
        # and BEFORE set_rotation_state.
        self.assertLess(core.index('static func source_weapon_range_state('), core.index('static func source_weapon_update_decay_state('))
        self.assertLess(core.index('static func source_weapon_update_decay_state('), core.index('static func set_rotation_state('))
        # NO driver tick call site: the definition is the only
        # occurrence of the function name in the core file.
        self.assertEqual(core.count('source_weapon_update_decay_state('), 1)
        # The facade delegates with the same name (the
        # setup_mounts_state precedent): one definition line
        # plus one delegate call line.
        self.assertIn(signature, facade)
        self.assertIn('return source_weapons_core_state.source_weapon_update_decay_state(mount_reload, mount_recoil, mount_recoils, mount_smooth_reload, mount_charge, mount_charging, mount_shoot, mount_warmup, has_continuous_bullet, recoils, recoil_time, weapon_reload, smooth_reload_speed, first_shot_delay, shoot_warmup_speed, linear_warmup, continuous, can, source_delta, reload_multiplier)', facade)
        self.assertEqual(facade.count('source_weapon_update_decay_state('), 2)
        # The proof drives the pure function through the
        # facade on exact legs (delta 1.0, reloadMultiplier
        # 1.0 unless noted):
        # 1 reload_decay: reload 30.0 -> 29.0; 2 reload_clamp:
        # reload 0.5 -> 0.0; 3 recoil_approach: recoil 1.0,
        # recoilTime 20.0 -> 0.95; 4 recoils_alloc: recoils
        # 2, mount recoils [] -> [0.0, 0.0]; 5 recoils_decay:
        # recoils 2, [0.5, 0.25], recoilTime 10.0 -> [0.4,
        # 0.15]; 6 recoils_ignored: recoils -1 (default),
        # [0.7] -> [0.7] untouched; 7 smooth_reload:
        # smoothReload 0.0, updated reload 29.0 / weapon
        # reload 60.0, speed 0.15 -> 0.0725 (NOT 0.075, which
        # the stale reload 30.0 would give); 8
        # charge_charging: charging, firstShotDelay 30.0 ->
        # 1/30; 9 charge_else_zero: not charging, charge 0.8
        # -> 0.0; 10 warmup_approach: linearWarmup, can +
        # shoot, warmup 0.5, speed 0.1 -> 0.6; 11 warmup_lerp:
        # lerp leg, target 0, warmup 0.8, speed 0.1 -> 0.72.
        proof = WEAPON_UPDATE_DECAY_PROOF.read_text(encoding='utf-8')
        for key in [
            'reload_decay',
            'reload_clamp',
            'recoil_approach',
            'recoils_alloc',
            'recoils_decay',
            'recoils_ignored',
            'smooth_reload',
            'charge_charging',
            'charge_else_zero',
            'warmup_approach',
            'warmup_lerp',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_weapon_update_decay(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WeaponUpdateDecayProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WEAPON_UPDATE_DECAY_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'reload_decay',
            'reload_clamp',
            'recoil_approach',
            'recoils_alloc',
            'recoils_decay',
            'recoils_ignored',
            'smooth_reload',
            'charge_charging',
            'charge_else_zero',
            'warmup_approach',
            'warmup_lerp',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
