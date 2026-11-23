import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WEAPONS_CORE_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsCoreState.gd'
WEAPONS_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsState.gd'
WEAPON_UPDATE_HEAT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WeaponUpdateHeatProof.gd'


class C07WeaponUpdateHeatTests(unittest.TestCase):
    def test_c07_weapon_update_heat_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2542']['godot_owner'], 'SourceWeaponsCoreState.source_weapon_update_heat_state')
        # update() leg 3 (Weapon.java:376, :409-415): the
        # else-branch heat decay when NOT (continuous &&
        # mount.bullet != null). The `mount.sound.update`
        # line (:413-415) is audio -- SKIP (the N2541
        # activeSound skip precedent).
        self.assertEqual(
            ledger['N2542']['source_symbols'],
            [
                'source_weapon_update_heat_state_result.heat',
            ],
        )
        for name in ledger['N2542']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/type/Weapon.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_update_heat_state')
        self.assertEqual(ledger['N2542']['runtime_proof'], '/root/C07WeaponUpdateHeatProof')
        self.assertEqual(
            ledger['N2542']['tests'],
            [
                'test_c07_weapon_update_heat_registration',
                'test_all_c07_weapon_update_heat_input_evidence_is_exact',
                'test_weapon_update_heat_state',
                'test_reference_graph_and_actual_c07_weapon_update_heat',
            ],
        )
        self.assertTrue(ledger['N2542']['deferred_exprs'])

    def test_all_c07_weapon_update_heat_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2542']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_update_heat_state')
        slice_sources = {
            'core/src/mindustry/type/Weapon.java',
            'core/src/mindustry/entities/units/WeaponMount.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2542']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_weapon_update_heat_state(self):
        core = WEAPONS_CORE_STATE.read_text(encoding='utf-8')
        facade = WEAPONS_STATE.read_text(encoding='utf-8')
        # update() leg 3 (Weapon.java:376, :409-415) for the
        # Weapon family as one pure function: heat decay in
        # the else-branch when NOT (continuous &&
        # mount.bullet != null), clamped at 0. The
        # `mount.sound.update(bulletX, bulletY, false)` line
        # (:413-415) is audio -- SKIP (the N2541
        # activeSound skip precedent).
        # NO driver tick call site (the
        # N2528/N2529/N2530/N2531/N2532/N2533/N2534/N2535/
        # N2536/N2537/N2538/N2539/N2540/N2541 precedent):
        # update() has no driver in the port yet, and no
        # caller reads the new function today.
        signature = 'static func source_weapon_update_heat_state(mount_heat: float, source_delta: float, reload_multiplier: float, cooldown_time: float, continuous: bool, has_continuous_bullet: bool) -> Dictionary:'
        self.assertIn(signature, core)
        self.assertIn('public float cooldownTime = 20f;', core)
        self.assertIn('if(continuous && mount.bullet != null){', core)
        self.assertIn('//heat decreases when not firing', core)
        self.assertIn('mount.heat = Math.max(mount.heat - Time.delta * unit.reloadMultiplier / cooldownTime, 0);', core)
        self.assertIn('DORMANT', core)
        # The canonical function sits immediately AFTER
        # source_weapon_update_aim_state (the N2541
        # function) and BEFORE set_rotation_state.
        self.assertLess(core.index('static func source_weapon_update_aim_state('), core.index('static func source_weapon_update_heat_state('))
        self.assertLess(core.index('static func source_weapon_update_heat_state('), core.index('static func set_rotation_state('))
        # NO driver tick call site: the definition is the only
        # occurrence of the function name in the core file.
        self.assertEqual(core.count('source_weapon_update_heat_state('), 1)
        # The facade delegates with the same name (the
        # setup_mounts_state precedent): one definition line
        # plus one delegate call line.
        self.assertIn(signature, facade)
        self.assertIn('return source_weapons_core_state.source_weapon_update_heat_state(mount_heat, source_delta, reload_multiplier, cooldown_time, continuous, has_continuous_bullet)', facade)
        self.assertEqual(facade.count('source_weapon_update_heat_state('), 2)
        # The proof drives the pure function through the
        # facade on exact legs (heat, delta 1.0,
        # reloadMultiplier 1.0, cooldownTime 20.0 unless
        # noted; continuous false, bullet absent unless
        # noted):
        # 1 decay: heat 0.5 -> 0.5 - 1*1/20 = 0.45; 2
        # clamp_zero: heat 0.01 -> 0.01 - 0.05 = -0.04 ->
        # 0; 3 no_decay_continuous_bullet: continuous true,
        # bullet present, heat 0.8 -> 0.8 (else-branch does
        # NOT run); 4 cooldown_time_respected: heat 0.6,
        # cooldown 10 -> 0.6 - 1/10 = 0.5; 5
        # heat_zero_unchanged: heat 0 -> max(0 - 0.05, 0)
        # = 0; 6 reload_multiplier_scales: heat 0.5,
        # multiplier 2.0 -> 0.5 - 2/20 = 0.4.
        proof = WEAPON_UPDATE_HEAT_PROOF.read_text(encoding='utf-8')
        for key in [
            'decay',
            'clamp_zero',
            'no_decay_continuous_bullet',
            'cooldown_time_respected',
            'heat_zero_unchanged',
            'reload_multiplier_scales',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_weapon_update_heat(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WeaponUpdateHeatProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WEAPON_UPDATE_HEAT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'decay',
            'clamp_zero',
            'no_decay_continuous_bullet',
            'cooldown_time_respected',
            'heat_zero_unchanged',
            'reload_multiplier_scales',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
