import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WEAPONS_CORE_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsCoreState.gd'
WEAPONS_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsState.gd'
WEAPON_DPS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WeaponDpsProof.gd'


class C07WeaponDpsTests(unittest.TestCase):
    def test_c07_weapon_dps_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2534']['godot_owner'], 'SourceWeaponsCoreState.source_weapon_dps_state')
        # dps() is the Weapon read (Weapon.java:188-190):
        # `public float dps(){` /
        # `return (bullet.estimateDPS() / reload) * shoot.shots * 60f;`.
        # `bullet.estimateDPS()` is already ported (N2529,
        # `source_bullet_type_estimate_dps_state`, 13 params),
        # so it arrives as the float param
        # `bullet_estimate_dps` instead of being called
        # directly -- calling N2529 from inside the new
        # function would force all 13 bullet params into the
        # Weapon signature (the N2528/N2529/N2533 param-driven
        # precedent: N2528 took `peek_ammo_dps`, N2529 took
        # `spawn_unit_dps` / `despawn_unit_dps`, N2533 took
        # `weapons_dps_sum`). `reload` is a float param
        # (Weapon.java:75, `public float reload = 1;` --
        # `RELOAD_DEFAULT := 1.0` already in
        # SourceWeaponDefaults.gd). `shoot_shots` is an int
        # param (ShootPattern.java:9, `public int shots = 1;`
        # -- `SHOTS_DEFAULT := 1` already in
        # SourceShootPatternDefaults.gd). dps() has NO cache
        # (no `cachedDps` / `dpsEstimate` field in Weapon.java
        # -- unlike BulletType `cachedDps` and UnitType
        # `dpsEstimate`): it recomputes on every call, so
        # there is NO `cached_dps` return key and NO `branch`
        # key -- the single return key is `dps` (the N2526
        # precedent -- every return key is a symbol). dps()
        # has NO `reload == 0` guard (only `addStats()`
        # Weapon.java:180 guards `reload > 0` for display):
        # the faithful port does not add one -- Java float /
        # 0 is Infinity, not a throw. The slice mirrors into
        # the type shard (java_source Weapon.java contains
        # "/type/"); comp stays 572/475.
        self.assertEqual(
            ledger['N2534']['source_symbols'],
            [
                'source_weapon_dps_state_result.dps',
            ],
        )
        for name in ledger['N2534']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/type/Weapon.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_dps_state')
        self.assertEqual(ledger['N2534']['runtime_proof'], '/root/C07WeaponDpsProof')
        self.assertEqual(
            ledger['N2534']['tests'],
            [
                'test_c07_weapon_dps_registration',
                'test_all_c07_weapon_dps_input_evidence_is_exact',
                'test_weapon_dps_state',
                'test_reference_graph_and_actual_c07_weapon_dps',
            ],
        )
        self.assertTrue(ledger['N2534']['deferred_exprs'])

    def test_all_c07_weapon_dps_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2534']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_dps_state')
        slice_sources = {
            'core/src/mindustry/type/Weapon.java',
            'core/src/mindustry/entities/pattern/ShootPattern.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2534']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_weapon_dps_state(self):
        core = WEAPONS_CORE_STATE.read_text(encoding='utf-8')
        facade = WEAPONS_STATE.read_text(encoding='utf-8')
        # dps() (Weapon.java:188-190) for the Weapon family
        # as one pure function, in exact Java order:
        # `return (bullet.estimateDPS() / reload) *
        # shoot.shots * 60f;` -- no cache branch, no guard.
        # The function returns exactly the one key `dps`. NO
        # driver tick call site (the N2528/N2529/N2530/N2531/
        # N2532/N2533 precedent): dps() is a read/estimate,
        # not per-tick, and no caller reads it today (N2533
        # still takes `weapons_dps_sum` as a float param;
        # wiring N2533 -> N2534 is a separate consumer slice;
        # C11 HUD / stats display reads `dps` in a later
        # slice). The only callers in Java today are
        # `UnitType.estimateDps()` via
        # `weapons.sumf(Weapon::dps)` (UnitType.java:1136)
        # and `addStats()` (Weapon.java:180-182, an inline
        # display formula, not a dps() call).
        self.assertIn('static func source_weapon_dps_state(bullet_estimate_dps: float, reload: float, shoot_shots: int) -> Dictionary:', core)
        self.assertIn('return {"dps": (bullet_estimate_dps / reload) * float(shoot_shots) * 60.0}', core)
        self.assertIn('public float dps(){', core)
        self.assertIn('return (bullet.estimateDPS() / reload) * shoot.shots * 60f;', core)
        self.assertIn('public float reload = 1;', core)
        self.assertIn('public ShootPattern shoot = new ShootPattern();', core)
        self.assertIn('public int shots = 1;', core)
        self.assertIn('DORMANT', core)
        # The canonical function sits immediately AFTER
        # setup_mounts_state (the first function in the core
        # file) and BEFORE set_rotation_state.
        self.assertLess(core.index('static func setup_mounts_state('), core.index('static func source_weapon_dps_state('))
        self.assertLess(core.index('static func source_weapon_dps_state('), core.index('static func set_rotation_state('))
        # NO driver tick call site: the definition is the only
        # occurrence of the function name in the core file.
        self.assertEqual(core.count('source_weapon_dps_state('), 1)
        # The facade delegates with the same name (the
        # setup_mounts_state precedent): one definition line
        # plus one delegate call line.
        self.assertIn('static func source_weapon_dps_state(bullet_estimate_dps: float, reload: float, shoot_shots: int) -> Dictionary:', facade)
        self.assertIn('return source_weapons_core_state.source_weapon_dps_state(bullet_estimate_dps, reload, shoot_shots)', facade)
        self.assertEqual(facade.count('source_weapon_dps_state('), 2)
        # The proof drives the pure function through the
        # facade on exact legs (bullet dps / reload / shots ->
        # dps): 1 Java defaults (1.0 / 1 / 1 -> 60.0); 2
        # reload 2.0 (1.0 / 2 / 1 -> 30.0); 3 fractional
        # reload 0.5 (1.0 / 0.5 / 1 -> 120.0); 4 shots 3 (1.0
        # / 1 / 3 -> 180.0); 5 shots 0 -> 0.0; 6 bullet dps
        # 0.0 -> 0.0; 7 fractional bullet dps 37.5 (37.5 / 1 /
        # 1 -> 2250.0 -- the * 60f factor applies, so this is
        # NOT 37.5); 8 large (120.0 / 0.5 / 2 -> 28800.0).
        proof = WEAPON_DPS_PROOF.read_text(encoding='utf-8')
        for key in [
            'dps_java_defaults',
            'dps_reload_2',
            'dps_reload_fractional',
            'dps_shots_3',
            'dps_shots_zero',
            'dps_bullet_zero',
            'dps_bullet_fractional',
            'dps_large',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_weapon_dps(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WeaponDpsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WEAPON_DPS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'dps_java_defaults',
            'dps_reload_2',
            'dps_reload_fractional',
            'dps_shots_3',
            'dps_shots_zero',
            'dps_bullet_zero',
            'dps_bullet_fractional',
            'dps_large',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
