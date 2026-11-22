import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceDrillRuntimeState.gd'
SORT_OPENER_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillCountOreSortOpenerProof.gd'

PROOF_KEYS = [
    'sort_orders_by_priority',
    'sort_orders_by_amount',
    'sort_orders_by_id_tie',
    'sort_single_item_unchanged',
    'sort_empty_stays_empty',
]


class C07DrillCountOreSortOpenerTests(unittest.TestCase):
    def test_c07_drill_count_ore_sort_opener_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2433']['godot_owner'], 'SourceDrillRuntimeState.source_count_ore_state')
        # Drill.countOre() (Drill.java:196-230): the 1 line
        # N2010 + N2302 did not register --
        # `itemArray.sort((item1, item2) -> {` (:215, the
        # opener of the 3-tier sort comparator). The GD
        # function already exists (N2010): this slice
        # extends it -- it adds no new owner, no new
        # contract and no new schema (the N2425
        # findEnemy-leg precedent; same shape as N2427 /
        # N2430). The comparator BODY stays owned at
        # N2010 + N2302 (`int type = Boolean.compare(...)`
        # / `int amounts = Integer.compare(...)` /
        # `return Integer.compare(item1.id, item2.id);` /
        # guards `if(type != 0) return type;` /
        # `if(amounts != 0) return amounts;`) and
        # `if(itemArray.size == 0){` stays owned at N2302
        # local, `returnItem = itemArray.peek();` at
        # N2010 + N2302 -- only the opener line is
        # registered here.
        self.assertEqual(
            ledger['N2433']['java_method'],
            'Drill.countOre(Tile tile)',
        )
        self.assertEqual(
            ledger['N2433']['exact_exprs'],
            [
                'itemArray.sort((item1, item2) -> {',
            ],
        )
        self.assertEqual(
            ledger['N2433']['source_symbols'],
            [
                'source_drill_count_ore_result.returnItem',
                'source_drill_count_ore_result.returnCount',
                'source_drill_count_ore_result.oreCount',
                'source_drill_count_ore_result.itemArray',
            ],
        )
        for name in ledger['N2433']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceDrillRuntimeState.source_count_ore_state'))
        self.assertEqual(ledger['N2433']['runtime_proof'], '/root/C07DrillCountOreSortOpenerProof')
        self.assertEqual(
            ledger['N2433']['tests'],
            [
                'test_c07_drill_count_ore_sort_opener_registration',
                'test_all_c07_drill_count_ore_sort_opener_input_evidence_is_exact',
                'test_drill_count_ore_sort_opener_state',
                'test_reference_graph_and_actual_c07_drill_count_ore_sort_opener',
            ],
        )
        self.assertTrue(ledger['N2433']['deferred_exprs'])

    def test_all_c07_drill_count_ore_sort_opener_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2433']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceDrillRuntimeState.source_count_ore_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2433']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_count_ore_sort_opener_state(self):
        state = DRILL_STATE.read_text(encoding='utf-8')
        # The GD function already exists (N2010); N2433
        # registers the sort opener it already implements
        # -- `itemArray.sort((item1, item2) -> {`
        # (Drill.java:215) is the call whose comparator
        # (lowPriority -> oreCount -> id, ascending;
        # peek selects the last) lives in
        # `item_array.sort_custom(...)`. The opener is
        # quoted verbatim on its own comment line (the
        # N2378 precedent: never split an exact expr
        # across lines).
        self.assertIn('static func source_count_ore_state(linked_tiles: Array, tier: int, blocked_items: Variant) -> Dictionary:', state)
        for expr in [
            'itemArray.sort((item1, item2) -> {',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the sort call itself: the
        # opener reorders itemArray (input order differs
        # from output order) on each comparator tier --
        # priority, then amount, then numeric id -- and
        # the call is a no-op on empty / single-item input.
        proof = SORT_OPENER_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_drill_count_ore_sort_opener(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DrillCountOreSortOpenerProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DRILL_COUNT_ORE_SORT_OPENER_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
