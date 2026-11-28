import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WAVE_SPAWN_STATE = ROOT / 'godot-mindustry/src/game/SourceWaveSpawnRuntimeState.gd'
TO_STRING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SpawnGroupToStringProof.gd'

PROOF_KEYS = [
    'to_string_full_group',
    'to_string_never_scaling_scientific',
    'to_string_null_effect_and_items',
    'to_string_whole_float_keeps_point',
    'to_string_zero_scaling_signs',
    'to_string_omits_shield_fields',
    'to_string_small_scaling_notation',
    'to_string_returns_only_one_key',
]


class C07SpawnGroupToStringTests(unittest.TestCase):
    def test_c07_spawn_group_to_string_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2492']['godot_owner'], 'SourceWaveSpawnRuntimeState.source_spawn_group_to_string_state')
        # SpawnGroup.toString() (SpawnGroup.java:159-170):
        #     public String toString(){
        #         return "SpawnGroup{" +
        #         "type=" + type +
        #         ", end=" + end +
        #         ", begin=" + begin +
        #         ", spacing=" + spacing +
        #         ", max=" + max +
        #         ", unitScaling=" + unitScaling +
        #         ", unitAmount=" + unitAmount +
        #         ", effect=" + effect +
        #         ", items=" + items +
        #         '}';
        #     }
        # A mechanical concatenation of exactly the 9
        # fields type, end, begin, spacing, max,
        # unitScaling, unitAmount, effect, items, in
        # Java order. shields (:38) and shieldScaling
        # (:40) are NOT printed -- they appear in
        # equals/hashCode only, so the GD function must
        # not add them. type/effect print by content
        # name (the N2457 name model: MappableContent
        # .toString() is `return name;`, StatusEffect
        # .toString() returns localizedName -- the GD
        # input is the print string itself), a null
        # reference prints "null", items prints via
        # ItemStack.toString() (`item + ": " + amount`,
        # ItemStack.java:82-84) from the N2457
        # {"item", "amount"} Dictionary model, and
        # unitScaling prints with Java Float.toString
        # semantics (float32 narrowing, shortest
        # round-trip digits, plain notation on
        # [1e-3, 1e7), scientific outside it).
        self.assertEqual(
            ledger['N2492']['java_method'],
            'SpawnGroup.toString()',
        )
        self.assertEqual(
            ledger['N2492']['source_symbols'],
            [
                'source_spawn_group_to_string_state_input.type_name',
                'source_spawn_group_to_string_state_input.end',
                'source_spawn_group_to_string_state_input.begin',
                'source_spawn_group_to_string_state_input.spacing',
                'source_spawn_group_to_string_state_input.max',
                'source_spawn_group_to_string_state_input.unit_scaling',
                'source_spawn_group_to_string_state_input.unit_amount',
                'source_spawn_group_to_string_state_input.effect_name',
                'source_spawn_group_to_string_state_input.items',
                'source_spawn_group_to_string_state_result.to_string',
            ],
        )
        for name in ledger['N2492']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/game/SpawnGroup.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnRuntimeState.source_spawn_group_to_string_state'))
        self.assertEqual(ledger['N2492']['runtime_proof'], '/root/C07SpawnGroupToStringProof')
        self.assertEqual(
            ledger['N2492']['tests'],
            [
                'test_c07_spawn_group_to_string_registration',
                'test_all_c07_spawn_group_to_string_input_evidence_is_exact',
                'test_spawn_group_to_string_state',
                'test_reference_graph_and_actual_c07_spawn_group_to_string',
            ],
        )
        self.assertTrue(ledger['N2492']['deferred_exprs'])

    def test_all_c07_spawn_group_to_string_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2492']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceWaveSpawnRuntimeState.source_spawn_group_to_string_state'))
        slice_sources = {
            'core/src/mindustry/game/SpawnGroup.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2492']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_spawn_group_to_string_state(self):
        wave_spawn = WAVE_SPAWN_STATE.read_text(encoding='utf-8')
        # SpawnGroup.toString() (SpawnGroup.java:159-170)
        # concatenates exactly 9 fields in Java order and
        # returns the String; the SSOT contract return_type
        # only accepts Dictionary or void, so the string is
        # returned in the one-key {"to_string": ...}
        # envelope (the N2365 envelope precedent, also used
        # by the BlockPlan/TeamData toString slices).
        # shields/shieldScaling are NOT printed (they are
        # in equals/hashCode only).
        self.assertIn('static func source_spawn_group_to_string_state(type_name: Variant, end: int, begin: int, spacing: int, max: int, unit_scaling: float, unit_amount: int, effect_name: Variant, items: Variant) -> Dictionary:', wave_spawn)
        self.assertIn('return {"to_string": "SpawnGroup{" +', wave_spawn)
        self.assertNotIn('"shields="', wave_spawn)
        self.assertNotIn('"shieldScaling="', wave_spawn)
        # Function order follows Java order: toString()
        # (SpawnGroup.java:159-170) comes before
        # equals(Object) (:181-190), so
        # source_spawn_group_to_string_state sits right
        # before source_spawn_group_equals_state in this
        # file.
        self.assertLess(
            wave_spawn.index('static func source_spawn_group_to_string_state('),
            wave_spawn.index('static func source_spawn_group_equals_state('),
        )
        # The proof drives the pure function with synthetic
        # inputs (no live tick, no game state): a full
        # group renders the exact Java string, the never
        # scaling (float32 of Integer.MAX_VALUE) renders
        # scientific, null type/effect/items render
        # "null", whole floats keep ".0", +0.0/-0.0 keep
        # their signs, no shield fields appear, small
        # floats switch notation at the Java 1e-3
        # boundary, and exactly one result key.
        proof = TO_STRING_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_spawn_group_to_string(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SpawnGroupToStringProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SPAWN_GROUP_TO_STRING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
