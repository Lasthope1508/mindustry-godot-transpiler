import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_ROUTER_STATE = ROOT / 'godot-mindustry/src/game/SourceStackRouterBuildState.gd'
DUCT_ROUTER_HANDLE_STACK_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DuctRouterHandleStackRowsProof.gd'
DUCT_ROUTER_HANDLE_STACK_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DuctRouterHandleStackRowsProof.tscn'


class C07DuctRouterHandleStackRowsTests(unittest.TestCase):
    def test_c07_duct_router_handle_stack_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2458']['godot_owner'], 'SourceStackRouterBuildState.source_duct_router_handle_stack_state')
        # The StackRouter tick is live (N2181 power.status
        # row + N2240 updateTile advance + N2324 target()
        # selection + N2332 acceptItem gate), the draw
        # rows are live (N2433 draw / drawCached / glow /
        # drawSelect / icons), the stats / plan rows are
        # live (N2442 setStats / drawPlanRegion /
        # minimapColor / rotatedOutput) and the config
        # rows are live (N2449 config(Item) /
        # configClear / buildConfiguration /
        # configured) but NOTHING modeled the
        # handleStack / removeStack rows:
        # handleStack sets current (DuctRouter.
        # java:173-177, super adds the stack then
        # current = item) and removeStack clears
        # current (DuctRouter.java:166-171, super
        # removes the clamped amount then current
        # = null iff item == current). StackRouter
        # inherits both from DuctRouter (StackRouter.
        # java:11, `public class StackRouter extends
        # DuctRouter{`) and overrides NEITHER of
        # them. N2458 ports them as ONE pure-only
        # pure (the N2443/N2449 discriminated-
        # action precedent): the action is
        # "handle_stack" / "remove_stack", the item
        # is null or a Dict {name} (the N2433/N2449
        # precedent), and the pure returns the
        # post-action current item + the super
        # removed count + the post-action held
        # count. Three new result symbols.
        self.assertEqual(
            ledger['N2458']['source_symbols'],
            [
                'source_duct_router_handle_stack_state_result.current_after',
                'source_duct_router_handle_stack_state_result.removed_count',
                'source_duct_router_handle_stack_state_result.items_count_after',
            ],
        )
        expected_sources = {
            'source_duct_router_handle_stack_state_result.current_after': 'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'source_duct_router_handle_stack_state_result.removed_count': 'core/src/mindustry/entities/comp/BuildingComp.java',
            'source_duct_router_handle_stack_state_result.items_count_after': 'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        for name in ledger['N2458']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackRouterBuildState.source_duct_router_'))
        self.assertEqual(ledger['N2458']['runtime_proof'], '/root/C07DuctRouterHandleStackRowsProof')
        self.assertEqual(
            ledger['N2458']['tests'],
            [
                'test_c07_duct_router_handle_stack_rows_registration',
                'test_all_c07_duct_router_handle_stack_rows_input_evidence_is_exact',
                'test_duct_router_handle_stack_rows_state',
                'test_reference_graph_and_actual_c07_duct_router_handle_stack_rows',
            ],
        )
        self.assertTrue(ledger['N2458']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #253 (1-based in
        # the merged advances-29 DEFERRED base): the
        # DuctRouter handleStack / removeStack rows
        # entry is REMOVED -- handleStack sets current
        # and removeStack clears it, both live now
        # (handleItem application stays tracked under
        # the N2324/N2332 entries). Net 253 - 1 = 252.
        # The read/write entry STAYS.
        self.assertFalse(any(entry.startswith('DuctRouter handleStack / removeStack rows (') for entry in ledger['N2458']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter read/write rows (') for entry in ledger['N2458']['deferred_exprs']))
        self.assertEqual(len(ledger['N2458']['deferred_exprs']), 252)

    def test_all_c07_duct_router_handle_stack_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2458']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackRouterBuildState.source_duct_router_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/StackRouter.java',
            'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/ItemModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2458']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_duct_router_handle_stack_rows_state(self):
        stack_router = STACK_ROUTER_STATE.read_text(encoding='utf-8')
        # The handleStack / removeStack rows
        # (DuctRouterBuild.removeStack, DuctRouter.
        # java:166-171; handleStack, :173-177):
        # removeStack takes the super return
        # (BuildingComp.removeStack, BuildingComp.
        # java:786-792: `if(items == null) return
        # 0;` then `amount = Math.min(amount,
        # items.get(item));` then `items.remove(
        # item, amount);` then `return amount;`)
        # and clears current iff item == current
        # (DuctRouter.java:168) -- the clear is
        # UNCONDITIONAL on the removed amount: a
        # zero-amount removeStack still clears
        # current when item == current, there is
        # no removed > 0 guard. handleStack runs
        # the super (BuildingComp.handleStack,
        # BuildingComp.java:795-798: `noSleep();`
        # then `items.add(item, amount);`) and
        # sets current = item (DuctRouter.
        # java:175). The add is UNCLAMPED
        # (ItemModule.add just +=, ItemModule.
        # java:234-242, no capacity clamp;
        # ItemModule.remove re-clamps, ItemModule.
        # java:258-263, but the super already
        # clamped). The item is null or a Dict
        # {name} (the N2433/N2449 precedent);
        # current is the same build field the
        # N2324 target pure reads (`public
        # @Nullable Item current;`, DuctRouter.
        # java:80, the frame key "current"); the
        # port compares item NAMES (Java `==` on
        # Item is identity, the N2449 precedent).
        # items_count is items.get(item) before
        # the call (ItemModule.java:209-211) --
        # the pure models the non-null store path
        # (the null-store branch never applies to
        # a placed router: the driver frame always
        # carries an items dict) and noSleep() is
        # not modeled (no sleep state in the
        # driver). handleItem (DuctRouter.
        # java:179-184, current = item + progress
        # = -1f + items.add(item, 1)) is NOT
        # ported here -- progress = -1f belongs
        # to handleItem, NOT handleStack, and
        # handleItem application stays tracked
        # under the N2324/N2332 entries. Pure-only:
        # the tick never calls handleStack /
        # removeStack. Keep each Java expr on ONE
        # comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_duct_router_handle_stack_state', stack_router)
        self.assertIn('public int removeStack(Item item, int amount){', stack_router)
        self.assertIn('int removed = super.removeStack(item, amount);', stack_router)
        self.assertIn('if(item == current) current = null;', stack_router)
        self.assertIn('return removed;', stack_router)
        self.assertIn('public void handleStack(Item item, int amount, Teamc source){', stack_router)
        self.assertIn('super.handleStack(item, amount, source);', stack_router)
        self.assertIn('current = item;', stack_router)
        self.assertIn('public @Nullable Item current;', stack_router)
        self.assertIn('public class StackRouter extends DuctRouter{', stack_router)
        self.assertIn('public class DuctRouterBuild extends Building{', stack_router)
        self.assertIn('if(items == null) return 0;', stack_router)
        self.assertIn('amount = Math.min(amount, items.get(item));', stack_router)
        self.assertIn('noSleep();', stack_router)
        self.assertIn('items.remove(item, amount);', stack_router)
        self.assertIn('return amount;', stack_router)
        self.assertIn('public void handleStack(Item item, int amount, @Nullable Teamc source){', stack_router)
        self.assertIn('items.add(item, amount);', stack_router)
        self.assertIn('public int get(Item item){', stack_router)
        self.assertIn('return items[item.id];', stack_router)
        self.assertIn('public void add(Item item, int amount){', stack_router)
        self.assertIn('items[item] += amount;', stack_router)
        self.assertIn('public void remove(Item item, int amount){', stack_router)
        self.assertIn('amount = Math.min(amount, items[item.id]);', stack_router)
        # The documented limits record the
        # handleStack / removeStack rows as live.
        self.assertIn('HandleStack / removeStack rows live (N2458)', stack_router)
        # The proof's keys drive the pure (the
        # handle_stack set + add, the remove_stack
        # clear + keep-other + clamp + return).
        proof = DUCT_ROUTER_HANDLE_STACK_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'handle_stack_sets_current',
            'handle_stack_adds',
            'remove_stack_clears',
            'remove_stack_keeps_other',
            'remove_stack_clamp',
            'remove_stack_return',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceStackRouterBuildState.gd")', proof)
        self.assertTrue(STACK_ROUTER_STATE.exists())
        self.assertTrue(DUCT_ROUTER_HANDLE_STACK_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07DuctRouterHandleStackRowsProof.gd', DUCT_ROUTER_HANDLE_STACK_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_duct_router_handle_stack_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DuctRouterHandleStackRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DUCT_ROUTER_HANDLE_STACK_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'handle_stack_sets_current',
            'handle_stack_adds',
            'remove_stack_clears',
            'remove_stack_keeps_other',
            'remove_stack_clamp',
            'remove_stack_return',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
