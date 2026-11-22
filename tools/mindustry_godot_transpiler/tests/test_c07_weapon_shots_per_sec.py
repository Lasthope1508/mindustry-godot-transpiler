import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WEAPONS_CORE_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsCoreState.gd'
WEAPONS_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsState.gd'
WEAPON_SPS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WeaponShotsPerSecProof.gd'


class C07WeaponShotsPerSecTests(unittest.TestCase):
    def test_c07_weapon_shots_per_sec_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2535']['godot_owner'], 'SourceWeaponsCoreState.source_weapon_shots_per_sec_state')
        # shotsPerSec() is the Weapon read (Weapon.java:192-194):
        # `public float shotsPerSec(){` /
        # `return shoot.shots * 60f / reload;`.
        # `reload` is a float param (Weapon.java:75,
        # `public float reload = 1;` --
        # `RELOAD_DEFAULT := 1.0` already in
        # SourceWeaponDefaults.gd). `shoot_shots` is an int
        # param (ShootPattern.java:9, `public int shots = 1;`
        # -- `SHOTS_DEFAULT := 1` already in
        # SourceShootPatternDefaults.gd). shotsPerSec() has
        # NO cache (no `cachedDps` / `dpsEstimate` field in
        # Weapon.java -- unlike BulletType `cachedDps` and
        # UnitType `dpsEstimate`): it recomputes on every
        # call, so there is NO `cached_shots_per_sec`
        # return key and NO `branch` key -- the single
        # return key is `shots_per_sec` (the N2526
        # precedent -- every return key is a symbol).
        # shotsPerSec() has NO `reload == 0` guard (only
        # `addStats()` Weapon.java:180 guards `reload > 0`
        # for display): the faithful port does not add one
        # -- Java float / 0 is Infinity, not a throw. The
        # slice mirrors into the type shard (java_source
        # Weapon.java contains "/type/"); comp stays
        # 572/475.
        self.assertEqual(
            ledger['N2535']['source_symbols'],
            [
                'source_weapon_shots_per_sec_state_result.shots_per_sec',
            ],
        )
        for name in ledger['N2535']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/type/Weapon.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_shots_per_sec_state')
        self.assertEqual(ledger['N2535']['runtime_proof'], '/root/C07WeaponShotsPerSecProof')
        self.assertEqual(
            ledger['N2535']['tests'],
            [
                'test_c07_weapon_shots_per_sec_registration',
                'test_all_c07_weapon_shots_per_sec_input_evidence_is_exact',
                'test_weapon_shots_per_sec_state',
                'test_reference_graph_and_actual_c07_weapon_shots_per_sec',
            ],
        )
        self.assertTrue(ledger['N2535']['deferred_exprs'])

    def test_all_c07_weapon_shots_per_sec_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2535']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_shots_per_sec_state')
        slice_sources = {
            'core/src/mindustry/type/Weapon.java',
            'core/src/mindustry/entities/pattern/ShootPattern.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2535']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_weapon_shots_per_sec_state(self):
        core = WEAPONS_CORE_STATE.read_text(encoding='utf-8')
        facade = WEAPONS_STATE.read_text(encoding='utf-8')
        # shotsPerSec() (Weapon.java:192-194) for the Weapon
        # family as one pure function, in exact Java order:
        # `return shoot.shots * 60f / reload;` -- no cache
        # branch, no guard. The function returns exactly
        # the one key `shots_per_sec`. NO driver tick call
        # site (the N2528/N2529/N2530/N2531/N2532/N2533/
        # N2534 precedent): shotsPerSec() is a
        # read/estimate, not per-tick, and no caller reads
        # it today (no Java caller outside Weapon itself;
        # C11 HUD / stats display reads `shots_per_sec`
        # in a later slice).
        self.assertIn('static func source_weapon_shots_per_sec_state(reload: float, shoot_shots: int) -> Dictionary:', core)
        self.assertIn('return {"shots_per_sec": float(shoot_shots) * 60.0 / reload}', core)
        self.assertIn('public float shotsPerSec(){', core)
        self.assertIn('return shoot.shots * 60f / reload;', core)
        self.assertIn('public float reload = 1;', core)
        self.assertIn('public ShootPattern shoot = new ShootPattern();', core)
        self.assertIn('public int shots = 1;', core)
        self.assertIn('DORMANT', core)
        # The canonical function sits immediately AFTER
        # source_weapon_dps_state (the N2534 function) and
        # BEFORE set_rotation_state.
        self.assertLess(core.index('static func source_weapon_dps_state('), core.index('static func source_weapon_shots_per_sec_state('))
        self.assertLess(core.index('static func source_weapon_shots_per_sec_state('), core.index('static func set_rotation_state('))
        # NO driver tick call site: the definition is the only
        # occurrence of the function name in the core file.
        self.assertEqual(core.count('source_weapon_shots_per_sec_state('), 1)
        # The facade delegates with the same name (the
        # setup_mounts_state precedent): one definition line
        # plus one delegate call line.
        self.assertIn('static func source_weapon_shots_per_sec_state(reload: float, shoot_shots: int) -> Dictionary:', facade)
        self.assertIn('return source_weapons_core_state.source_weapon_shots_per_sec_state(reload, shoot_shots)', facade)
        self.assertEqual(facade.count('source_weapon_shots_per_sec_state('), 2)
        # The proof drives the pure function through the
        # facade on exact legs (reload / shots ->
        # shots_per_sec): 1 Java defaults (1 / 1 -> 60.0);
        # 2 reload 2.0 (2 / 1 -> 30.0); 3 fractional
        # reload 0.5 (0.5 / 1 -> 120.0); 4 shots 3 (1 / 3
        # -> 180.0); 5 shots 0 -> 0.0; 6 reload 60.0 (60 /
        # 1 -> 1.0); 7 fractional reload 1.5, shots 2
        # (1.5 / 2 -> 80.0); 8 large (0.5 / 2 -> 240.0).
        proof = WEAPON_SPS_PROOF.read_text(encoding='utf-8')
        for key in [
            'sps_java_defaults',
            'sps_reload_2',
            'sps_reload_fractional',
            'sps_shots_3',
            'sps_shots_zero',
            'sps_reload_60',
            'sps_fractional',
            'sps_large',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_weapon_shots_per_sec(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WeaponShotsPerSecProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WEAPON_SHOTS_PER_SEC_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sps_java_defaults',
            'sps_reload_2',
            'sps_reload_fractional',
            'sps_shots_3',
            'sps_shots_zero',
            'sps_reload_60',
            'sps_fractional',
            'sps_large',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
