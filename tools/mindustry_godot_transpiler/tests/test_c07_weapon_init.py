import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WEAPONS_CORE_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsCoreState.gd'
WEAPONS_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsState.gd'
WEAPON_INIT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WeaponInitProof.gd'


class C07WeaponInitTests(unittest.TestCase):
    def test_c07_weapon_init_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2544']['godot_owner'], 'SourceWeaponsCoreState.source_weapon_init_state')
        # init() (Weapon.java:561-566): always-continuous
        # weapons imply continuous fire. `continuous` is
        # the resulting hold-bullet flag, returned on every
        # call (the N2526 precedent -- every return key is
        # a symbol).
        self.assertEqual(
            ledger['N2544']['source_symbols'],
            [
                'source_weapon_init_state_result.continuous',
            ],
        )
        for name in ledger['N2544']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/type/Weapon.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_init_state')
        self.assertEqual(ledger['N2544']['runtime_proof'], '/root/C07WeaponInitProof')
        self.assertEqual(
            ledger['N2544']['tests'],
            [
                'test_c07_weapon_init_registration',
                'test_all_c07_weapon_init_input_evidence_is_exact',
                'test_weapon_init_state',
                'test_reference_graph_and_actual_c07_weapon_init',
            ],
        )
        self.assertTrue(ledger['N2544']['deferred_exprs'])

    def test_all_c07_weapon_init_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2544']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.source_weapon_init_state')
        slice_sources = {
            'core/src/mindustry/type/Weapon.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2544']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_weapon_init_state(self):
        core = WEAPONS_CORE_STATE.read_text(encoding='utf-8')
        facade = WEAPONS_STATE.read_text(encoding='utf-8')
        # init() (Weapon.java:561-566) for the Weapon family
        # as one pure function: `continuous = true` when
        # `alwaysContinuous`, otherwise the current
        # `continuous` value is kept unchanged.
        # NO driver tick call site (the
        # N2528/N2529/N2530/N2531/N2532/N2533/N2534/N2535/
        # N2536/N2537/N2538/N2539/N2540/N2541/N2542/N2543 precedent):
        # init() has no driver in the port yet, and no
        # caller reads the new function today.
        signature = 'static func source_weapon_init_state(always_continuous: bool, continuous: bool) -> Dictionary:'
        self.assertIn(signature, core)
        self.assertIn('@CallSuper', core)
        self.assertIn('public void init(){', core)
        self.assertIn('if(alwaysContinuous){', core)
        self.assertIn('continuous = true;', core)
        self.assertIn('public boolean continuous;', core)
        self.assertIn('public boolean alwaysContinuous;', core)
        self.assertIn('DORMANT', core)
        # The canonical function sits immediately AFTER
        # source_weapon_update_side_flip_state (the N2543
        # function) and BEFORE set_rotation_state.
        self.assertLess(core.index('static func source_weapon_update_side_flip_state('), core.index('static func source_weapon_init_state('))
        self.assertLess(core.index('static func source_weapon_init_state('), core.index('static func set_rotation_state('))
        # NO driver tick call site: the definition is the only
        # occurrence of the function name in the core file.
        self.assertEqual(core.count('source_weapon_init_state('), 1)
        # The facade delegates with the same name (the
        # setup_mounts_state precedent): one definition line
        # plus one delegate call line.
        self.assertIn(signature, facade)
        self.assertIn('return source_weapons_core_state.source_weapon_init_state(always_continuous, continuous)', facade)
        self.assertEqual(facade.count('source_weapon_init_state('), 2)
        # The proof drives the pure function through the
        # facade on exact legs (defaults:
        # always_continuous false, continuous false):
        # 1 sets_continuous: (true, false) -> true; 2
        # keeps_continuous_true: (true, true) -> true; 3
        # keeps_continuous_false: (false, false) -> false; 4
        # keeps_continuous_true_when_not_always: (false,
        # true) -> true.
        proof = WEAPON_INIT_PROOF.read_text(encoding='utf-8')
        for key in [
            'sets_continuous',
            'keeps_continuous_true',
            'keeps_continuous_false',
            'keeps_continuous_true_when_not_always',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_weapon_init(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WeaponInitProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WEAPON_INIT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'sets_continuous',
            'keeps_continuous_true',
            'keeps_continuous_false',
            'keeps_continuous_true_when_not_always',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
