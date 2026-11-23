import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WEAPONS_CORE_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsCoreState.gd'
WEAPON_COOLDOWN_TIME_DEFAULT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WeaponCooldownTimeDefaultProof.gd'


class C07WeaponCooldownTimeDefaultTests(unittest.TestCase):
    def test_c07_weapon_cooldown_time_default_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2542']['godot_owner'], 'SourceWeaponsCoreState.source_weapon_cooldown_time_defaults_state')
        # Weapon cooldownTime (Weapon.java:89), 1 line, no
        # method owns it: the ticks-to-cool-down divisor of
        # the heat-decay leg (Weapon.java:411). MERGE TRIM:
        # remote N2542 carried the whole heat-decay leg (6
        # exprs + scalar pure function), but local N864
        # already ports that leg (5/6 exprs dedup) -- this
        # slice keeps the number with the one genuinely new
        # expr, the field declaration (N2440 precedent).
        # 1 result symbol.
        self.assertEqual(
            ledger['N2542']['source_symbols'],
            [
                'source_weapon_cooldown_time_defaults_state_result.cooldown_time',
            ],
        )
        for name in ledger['N2542']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/type/Weapon.java')
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2542']['runtime_proof'], '/root/C07WeaponCooldownTimeDefaultProof')
        self.assertEqual(
            ledger['N2542']['tests'],
            [
                'test_c07_weapon_cooldown_time_default_registration',
                'test_all_c07_weapon_cooldown_time_default_input_evidence_is_exact',
                'test_weapon_cooldown_time_defaults_state',
                'test_reference_graph_and_actual_c07_weapon_cooldown_time_default',
            ],
        )
        self.assertTrue(ledger['N2542']['deferred_exprs'])

    def test_all_c07_weapon_cooldown_time_default_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2542']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.' + name.rsplit('_result.', 1)[0])
        upstream = (ROOT / 'mindustry-upstream' / 'core/src/mindustry/type/Weapon.java').read_text(encoding='utf-8')
        for expr in ledger['N2542']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertIn(expr, upstream)

    def test_weapon_cooldown_time_defaults_state(self):
        state = WEAPONS_CORE_STATE.read_text(encoding='utf-8')
        # Weapon cooldownTime (Weapon.java:89, `public float
        # cooldownTime = 20f;`) is the ticks-to-cool-down
        # divisor of the heat-decay leg (Weapon.java:411).
        # The leg itself is owned by N864
        # (SourceWeaponBulletContinuousState.gd:231), which
        # reads cooldownTime from the weapon state with
        # this same default (SourceWeaponDefaults.
        # COOLDOWN_TIME_DEFAULT = 20.0). This func is the
        # slice's live home for the decl (N2440 field-decl
        # precedent). No driver tick line: a def field
        # default, not per-tick state. No inputs: a field
        # default takes no live values (N1206/N2422).
        self.assertIn('static func source_weapon_cooldown_time_defaults_state() -> Dictionary:', state)
        self.assertIn('return {"cooldown_time": 20.0}', state)
        for expr in [
            'public float cooldownTime = 20f;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure function with no
        # inputs (no live tick): the 20.0 default, and the
        # dict carries only its own key.
        proof = WEAPON_COOLDOWN_TIME_DEFAULT_PROOF.read_text(encoding='utf-8')
        for key in [
            'defaults_cooldown_time',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_weapon_cooldown_time_default(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WeaponCooldownTimeDefaultProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WEAPON_COOLDOWN_TIME_DEFAULT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'defaults_cooldown_time',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
