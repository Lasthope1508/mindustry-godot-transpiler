import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WEAPONS_CORE_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsCoreState.gd'
WEAPONS_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsState.gd'
WEAPON_UPDATE_SIDE_FLIP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WeaponUpdateSideFlipProof.gd'


class C07WeaponUpdateSideFlipTests(unittest.TestCase):
    def test_c07_weapon_update_side_flip_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2543']['godot_owner'], 'SourceWeaponsCoreState.source_weapon_update_side_flip_state')
        # update() leg 4 (Weapon.java:418-423): the
        # side-flip for alternating weapons. `was_flipped`
        # is mount.side BEFORE the flip (Weapon.java:419)
        # and is read by the shoot gate (:435) in a later
        # slice; it is returned unchanged when the guard
        # fails.
        self.assertEqual(
            ledger['N2543']['source_symbols'],
            [
                'source_weapon_update_side_flip_state_result.mount_side',
                'source_weapon_update_side_flip_state_result.other_side_side',
                'source_weapon_update_side_flip_state_result.was_flipped',
            ],
        )
        for name in ledger['N2543']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/type/Weapon.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_update_side_flip_state')
        self.assertEqual(ledger['N2543']['runtime_proof'], '/root/C07WeaponUpdateSideFlipProof')
        self.assertEqual(
            ledger['N2543']['tests'],
            [
                'test_c07_weapon_update_side_flip_registration',
                'test_all_c07_weapon_update_side_flip_input_evidence_is_exact',
                'test_weapon_update_side_flip_state',
                'test_reference_graph_and_actual_c07_weapon_update_side_flip',
            ],
        )
        self.assertTrue(ledger['N2543']['deferred_exprs'])

    def test_all_c07_weapon_update_side_flip_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2543']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_update_side_flip_state')
        slice_sources = {
            'core/src/mindustry/type/Weapon.java',
            'core/src/mindustry/entities/units/WeaponMount.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2543']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_weapon_update_side_flip_state(self):
        core = WEAPONS_CORE_STATE.read_text(encoding='utf-8')
        facade = WEAPONS_STATE.read_text(encoding='utf-8')
        # update() leg 4 (Weapon.java:418-423) for the
        # Weapon family as one pure function: flip both
        # mounts' sides when the 6-conjunct guard passes
        # (otherSide >= 0, alternate, mount.side ==
        # flipSprite, otherSide < mounts.length,
        # mount.reload <= reload / 2, lastReload >
        # reload / 2); `last_reload` is the pre-decay
        # reload (Weapon.java:294, a separate frame
        # input -- leg 1 N2540 only returns the
        # post-decay reload). `was_flipped` is mount.side
        # BEFORE the flip (Weapon.java:419).
        # NO driver tick call site (the
        # N2528/N2529/N2530/N2531/N2532/N2533/N2534/N2535/
        # N2536/N2537/N2538/N2539/N2540/N2541/N2542 precedent):
        # update() has no driver in the port yet, and no
        # caller reads the new function today.
        signature = 'static func source_weapon_update_side_flip_state(other_side: int, alternate: bool, mount_side: bool, flip_sprite: bool, other_mount_side: bool, mounts_count: int, mount_reload: float, weapon_reload: float, last_reload: float) -> Dictionary:'
        self.assertIn(signature, core)
        self.assertIn('public int otherSide = -1;', core)
        self.assertIn('public boolean alternate = true;', core)
        self.assertIn('public boolean flipSprite = false;', core)
        self.assertIn('//flip weapon shoot side for alternating weapons', core)
        self.assertIn('boolean wasFlipped = mount.side;', core)
        self.assertIn('if(otherSide >= 0 && alternate && mount.side == flipSprite && otherSide < unit.mounts.length && mount.reload <= reload / 2f && lastReload > reload / 2f){', core)
        self.assertIn('unit.mounts[otherSide].side = !unit.mounts[otherSide].side;', core)
        self.assertIn('mount.side = !mount.side;', core)
        self.assertIn('DORMANT', core)
        # The canonical function sits immediately AFTER
        # source_weapon_update_heat_state (the N2542
        # function) and BEFORE set_rotation_state.
        self.assertLess(core.index('static func source_weapon_update_heat_state('), core.index('static func source_weapon_update_side_flip_state('))
        self.assertLess(core.index('static func source_weapon_update_side_flip_state('), core.index('static func set_rotation_state('))
        # NO driver tick call site: the definition is the only
        # occurrence of the function name in the core file.
        self.assertEqual(core.count('source_weapon_update_side_flip_state('), 1)
        # The facade delegates with the same name (the
        # setup_mounts_state precedent): one definition line
        # plus one delegate call line.
        self.assertIn(signature, facade)
        self.assertIn('return source_weapons_core_state.source_weapon_update_side_flip_state(other_side, alternate, mount_side, flip_sprite, other_mount_side, mounts_count, mount_reload, weapon_reload, last_reload)', facade)
        self.assertEqual(facade.count('source_weapon_update_side_flip_state('), 2)
        # The proof drives the pure function through the
        # facade on exact legs (defaults: otherSide 1,
        # alternate true, mount_side false, flip_sprite
        # false, other_mount_side false, mounts_count 2,
        # mount_reload 10.0, weapon_reload 60.0 (half
        # 30.0), last_reload 40.0):
        # 1 flip: guard passes -> both sides flip false
        # -> true, was_flipped false; 2
        # no_flip_reload_not_crossed: mount_reload 40.0,
        # last_reload 50.0, both above half -> no flip; 3
        # no_flip_last_reload_at_half: mount_reload 30.0,
        # last_reload 30.0 == half, strict > fails -> no
        # flip; 4 no_flip_side_mismatch: mount_side true,
        # flip_sprite false -> no flip, was_flipped true;
        # 5 no_flip_other_side_negative: other_side -1 ->
        # no flip; 6 no_flip_other_side_out_of_range:
        # other_side 2, mounts_count 2 -> no flip; 7
        # no_flip_alternate_false: alternate false -> no
        # flip.
        proof = WEAPON_UPDATE_SIDE_FLIP_PROOF.read_text(encoding='utf-8')
        for key in [
            'flip',
            'no_flip_reload_not_crossed',
            'no_flip_last_reload_at_half',
            'no_flip_side_mismatch',
            'no_flip_other_side_negative',
            'no_flip_other_side_out_of_range',
            'no_flip_alternate_false',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_weapon_update_side_flip(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WeaponUpdateSideFlipProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WEAPON_UPDATE_SIDE_FLIP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'flip',
            'no_flip_reload_not_crossed',
            'no_flip_last_reload_at_half',
            'no_flip_side_mismatch',
            'no_flip_other_side_negative',
            'no_flip_other_side_out_of_range',
            'no_flip_alternate_false',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
