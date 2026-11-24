import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SPAWN_STATE = ROOT / 'godot-mindustry/src/game/SourceWaveSpawnRuntimeState.gd'
EQUALS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SpawnGroupEqualsProof.gd'

PROOF_KEYS = [
    'identical_fields_true',
    'same_dict_true',
    'null_and_wrong_type_false',
    'uncompared_fields_ignored',
    'nan_scaling_equal',
    'negative_zero_shields_not_equal',
    'single_field_diff_false',
    'items_mismatch_false',
]


class C07SpawnGroupEqualsTests(unittest.TestCase):
    def test_c07_spawn_group_equals_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2457']['godot_owner'], 'SourceWaveSpawnRuntimeState.source_spawn_group_equals_state')
        # SpawnGroup.equals(Object) (SpawnGroup.java:181-190): the
        # 5 distinct body exprs only -- the signature
        # `public boolean equals(Object o){` (:182) and the 4
        # lines of the return statement (:186-189). The comparison
        # covers end, begin, spacing, max, unitScaling, shields,
        # shieldScaling, unitAmount, type, effect and items ONLY:
        # spawn (:44), payloads (:46) and team (:52) are
        # deliberately NOT compared, so two groups differing only
        # in those fields are still equal. The three floats use
        # Java Float.compare semantics (NaN == NaN, -0.0f <
        # 0.0f); GD's `==` gets both wrong, so GD compares
        # floats through a _float_compare helper. Structs.eq
        # (arc Structs.java:12-14) delegates to ItemStack.equals
        # (ItemStack.java:77-79): same item identity + same
        # amount. hashCode() (:192-195) is NOT part of this slice.
        self.assertEqual(
            ledger['N2457']['java_method'],
            'SpawnGroup.equals(Object)',
        )
        self.assertEqual(
            ledger['N2457']['source_symbols'],
            [
                'source_spawn_group_equals_state_result.equals',
            ],
        )
        for name in ledger['N2457']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/SpawnGroup.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnRuntimeState.source_spawn_group_equals_state'))
        self.assertEqual(ledger['N2457']['runtime_proof'], '/root/C07SpawnGroupEqualsProof')
        self.assertEqual(
            ledger['N2457']['tests'],
            [
                'test_c07_spawn_group_equals_registration',
                'test_all_c07_spawn_group_equals_input_evidence_is_exact',
                'test_spawn_group_equals_state',
                'test_reference_graph_and_actual_c07_spawn_group_equals',
            ],
        )
        self.assertTrue(ledger['N2457']['deferred_exprs'])

    def test_all_c07_spawn_group_equals_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2457']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnRuntimeState.source_spawn_group_equals_state'))
        slice_sources = {
            'core/src/mindustry/game/SpawnGroup.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2457']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_spawn_group_equals_state(self):
        spawn_state = SPAWN_STATE.read_text(encoding='utf-8')
        # SpawnGroup.equals(Object) (SpawnGroup.java:181-190): the
        # 5 distinct body exprs only. GD takes the group as a
        # Dictionary plus the other object as a Variant (option (A)
        # data-driven, precedent N2453/N2455/N2456); it does not
        # build SpawnGroup objects itself. The identity shortcut
        # (:183, `this == o`) is deliberately NOT modelled:
        # GDScript has no reference-identity operator for
        # Dictionary, and Dictionary `==` is deep value equality
        # -- wrong here twice over (verified on Godot 4.6.2):
        # `==` against a non-Dictionary other is an invalid
        # operation, and `{"x": 0.0} == {"x": -0.0}` is true, so
        # a `==` shortcut would short-circuit the -0.0 trap.
        # The shortcut is unobservable: the field comparison
        # returns true for a group compared with itself. The
        # three floats go through _float_compare, which
        # reproduces Float.compare: NaN == NaN, -0.0f < 0.0f,
        # otherwise numeric -- GD `==` alone would fail both traps.
        self.assertIn('static func source_spawn_group_equals_state(group: Dictionary, other: Variant) -> Dictionary:', spawn_state)
        self.assertIn('return {"equals": _spawn_group_fields_equal(group, other_group)}', spawn_state)
        self.assertIn('static func _float_compare(a: float, b: float) -> int:', spawn_state)
        self.assertIn('static func _item_stacks_equal(a: Variant, b: Variant) -> bool:', spawn_state)
        # The proof drives the pure function with synthetic group
        # dicts (no live tick, no wave state): identical dicts
        # are equal (and the result has exactly 1 key), the same
        # dict is equal to itself, null / wrong-typed others are
        # not equal, groups differing only in spawn/payloads/team
        # are still equal, NaN unitScaling equals NaN, 0.0
        # shields do NOT equal -0.0 shields, one differing field
        # makes groups unequal, and differing items make groups
        # unequal.
        proof = EQUALS_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_spawn_group_equals(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SpawnGroupEqualsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SPAWN_GROUP_EQUALS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
