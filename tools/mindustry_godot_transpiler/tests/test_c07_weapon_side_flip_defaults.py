import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WEAPONS_CORE_STATE = ROOT / 'godot-mindustry/src/game/SourceWeaponsCoreState.gd'
WEAPON_SIDE_FLIP_DEFAULTS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WeaponSideFlipDefaultsProof.gd'


class C07WeaponSideFlipDefaultsTests(unittest.TestCase):
    def test_c07_weapon_side_flip_defaults_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2543']['godot_owner'], 'SourceWeaponsCoreState.source_weapon_side_flip_defaults_state')
        # Weapon side-flip field defaults (Weapon.java:125/:43/:41,
        # WeaponMount.java:40) + the leg comment (:418). MERGE
        # TRIM: remote N2543 carried the whole side-flip leg (11
        # exprs + scalar pure function), but local N856 already
        # ports the flip body and N870 owns `lastReload` (5/11
        # exprs dedup) -- this slice keeps the number with the
        # 5 genuinely new exprs, the comment + 4 field decls
        # (N2440 precedent, N2542 trim precedent). 4 result
        # symbols.
        self.assertEqual(
            ledger['N2543']['source_symbols'],
            [
                'source_weapon_side_flip_defaults_state_result.other_side',
                'source_weapon_side_flip_defaults_state_result.alternate',
                'source_weapon_side_flip_defaults_state_result.flip_sprite',
                'source_weapon_side_flip_defaults_state_result.side',
            ],
        )
        for name in ledger['N2543']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(symbols['source_weapon_side_flip_defaults_state_result.side']['java_source'], 'core/src/mindustry/entities/units/WeaponMount.java')
        for name in ledger['N2543']['source_symbols'][:3]:
            with self.subTest(symbol=name):
                self.assertEqual(symbols[name]['java_source'], 'core/src/mindustry/type/Weapon.java')
        self.assertEqual(ledger['N2543']['runtime_proof'], '/root/C07WeaponSideFlipDefaultsProof')
        self.assertEqual(
            ledger['N2543']['tests'],
            [
                'test_c07_weapon_side_flip_defaults_registration',
                'test_all_c07_weapon_side_flip_defaults_input_evidence_is_exact',
                'test_weapon_side_flip_defaults_state',
                'test_reference_graph_and_actual_c07_weapon_side_flip_defaults',
            ],
        )
        self.assertTrue(ledger['N2543']['deferred_exprs'])

    def test_all_c07_weapon_side_flip_defaults_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2543']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceWeaponsCoreState.' + name.rsplit('_result.', 1)[0])
        upstream = {}
        for source in ['core/src/mindustry/type/Weapon.java', 'core/src/mindustry/entities/units/WeaponMount.java']:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2543']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()))

    def test_weapon_side_flip_defaults_state(self):
        state = WEAPONS_CORE_STATE.read_text(encoding='utf-8')
        # Weapon side-flip field defaults: `otherSide = -1`
        # (Weapon.java:125), `alternate = true` (:43),
        # `flipSprite = false` (:41), `side` (WeaponMount.java:40,
        # Java boolean default false). The leg itself is owned
        # by N856 (flip body) + N870 (`lastReload`); `reload = 1`
        # is already claimed by N2534 + N2535. This func is the
        # slice's live home for the decls (N2440 field-decl
        # precedent, N2542 trim precedent). No driver tick line:
        # a def field default, not per-tick state. No inputs: a
        # field default takes no live values (N1206/N2422).
        self.assertIn('static func source_weapon_side_flip_defaults_state() -> Dictionary:', state)
        self.assertIn('return {"other_side": -1, "alternate": true, "flip_sprite": false, "side": false}', state)
        for expr in [
            '//flip weapon shoot side for alternating weapons',
            'public int otherSide = -1;',
            'public boolean alternate = true;',
            'public boolean flipSprite = false;',
            'public boolean side;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure function with no
        # inputs (no live tick): the 4 defaults, and the dict
        # carries only its own keys.
        proof = WEAPON_SIDE_FLIP_DEFAULTS_PROOF.read_text(encoding='utf-8')
        for key in [
            'defaults_other_side',
            'defaults_alternate',
            'defaults_flip_sprite',
            'defaults_side',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_weapon_side_flip_defaults(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WeaponSideFlipDefaultsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WEAPON_SIDE_FLIP_DEFAULTS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'defaults_other_side',
            'defaults_alternate',
            'defaults_flip_sprite',
            'defaults_side',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
