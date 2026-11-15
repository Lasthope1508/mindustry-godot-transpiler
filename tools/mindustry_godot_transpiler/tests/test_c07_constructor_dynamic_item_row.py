import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceConstructorBuildState.gd'
CONSTRUCTOR_DYNAMIC_ITEM_ROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ConstructorDynamicItemRowProof.gd'
CONSTRUCTOR_DYNAMIC_ITEM_ROW_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ConstructorDynamicItemRowProof.tscn'


class C07ConstructorDynamicItemRowTests(unittest.TestCase):
    def test_c07_constructor_dynamic_item_row_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2265']['godot_owner'], 'SourceConstructorBuildState.source_constructor_dynamic_item_consumer_row_state')
        # N2161 proved the constructor's live power read and
        # N2216 its shouldConsume gate (enabled && recipe !=
        # null) -- but the folded efficiency was still the min
        # over the *modeled* consumers (power only): the
        # constructor also consumes the recipe's requirements
        # through a ConsumeItemDynamic (BlockProducer.java:39,
        # `consume(new ConsumeItemDynamic((BlockProducerBuild
        # e) -> {`), whose stacks are the recipe block's
        # requirements with each amount ceiled against the
        # build-cost multiplier
        # (`clone[i].amount = Mathf.ceil(block.requirements[i].
        # amount * state.rules.buildCostMultiplier);`,
        # BlockProducer.java:49), or ItemStack.empty when the
        # recipe is null (BlockProducer.java:53, `return
        # ItemStack.empty;`), so a constructor with no items
        # ran at full efficiency. N2265 is the dynamic row:
        # the pure stacks function (ceil per requirement),
        # the pure BINARY row (ConsumeItemDynamic.java:60-62,
        # `return build.consumeTriggerValid() ||
        # build.items.has(items.get(build),
        # multiplier.get(build)) ? 1f : 0f;`, 1 when every
        # stack is held at round(amount * multiplier), 0
        # otherwise, 1 on empty stacks) folded into the first
        # pass (BuildingComp.java:1969-1976), plus the pure
        # trigger (ConsumeItemDynamic.java:53-57, remove
        # round(amount * multiplier) per stack, clamped to
        # the held count, ItemModule.java:258-263) -- tested
        # pure, NOT wired live yet, because consume() only
        # fires when the progress advance completes
        # (BlockProducer.java:115-116, `if(progress >=
        # recipe.buildTime){` / `consume();`) and the advance
        # waits for its own slice. Four new result symbols:
        # the stacks, the row + its presence flag, and the
        # trigger's items dict.
        self.assertEqual(
            ledger['N2265']['source_symbols'],
            [
                'source_constructor_dynamic_item_stacks_state_result.stacks',
                'source_constructor_dynamic_item_consumer_row_state_result.row',
                'source_constructor_dynamic_item_consumer_row_state_result.has_item_row',
                'source_constructor_dynamic_item_trigger_state_result.items',
            ],
        )
        for name in ledger['N2265']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_constructor_dynamic_item_stacks_state_result.stacks': 'core/src/mindustry/world/blocks/payloads/BlockProducer.java',
                    'source_constructor_dynamic_item_consumer_row_state_result.row': 'core/src/mindustry/world/consumers/ConsumeItemDynamic.java',
                    'source_constructor_dynamic_item_consumer_row_state_result.has_item_row': 'core/src/mindustry/entities/comp/BuildingComp.java',
                    'source_constructor_dynamic_item_trigger_state_result.items': 'core/src/mindustry/world/consumers/ConsumeItemDynamic.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], {
                    'source_constructor_dynamic_item_stacks_state_result.stacks': 'SourceConstructorBuildState.source_constructor_dynamic_item_stacks_state',
                    'source_constructor_dynamic_item_consumer_row_state_result.row': 'SourceConstructorBuildState.source_constructor_dynamic_item_consumer_row_state',
                    'source_constructor_dynamic_item_consumer_row_state_result.has_item_row': 'SourceConstructorBuildState.source_constructor_dynamic_item_consumer_row_state',
                    'source_constructor_dynamic_item_trigger_state_result.items': 'SourceConstructorBuildState.source_constructor_dynamic_item_trigger_state',
                }[name])
        self.assertEqual(ledger['N2265']['runtime_proof'], '/root/C07ConstructorDynamicItemRowProof')
        self.assertEqual(
            ledger['N2265']['tests'],
            [
                'test_c07_constructor_dynamic_item_row_registration',
                'test_all_c07_constructor_dynamic_item_row_input_evidence_is_exact',
                'test_constructor_dynamic_item_row_state',
                'test_reference_graph_and_actual_c07_constructor_dynamic_item_row',
            ],
        )
        self.assertTrue(ledger['N2265']['deferred_exprs'])
        # This slice resolves the BlockProducer dynamic item
        # consumer row deferral and adds two new ones (the
        # trigger live wiring, which waits for the advance
        # slice, and the constructor frame items intake, which
        # no live fill feeds yet). DEFERRED goes 291 - 1 + 2
        # = 292 entries.
        self.assertEqual(len(ledger['N2265']['deferred_exprs']), 292)
        self.assertFalse(any(entry.startswith('BlockProducer dynamic item consumer rows (') for entry in ledger['N2265']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BlockProducer dynamic item trigger live wiring (') for entry in ledger['N2265']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Constructor frame items intake (') for entry in ledger['N2265']['deferred_exprs']))

    def test_all_c07_constructor_dynamic_item_row_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2265']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_constructor_dynamic_item_stacks_state_result.stacks': 'SourceConstructorBuildState.source_constructor_dynamic_item_stacks_state',
                    'source_constructor_dynamic_item_consumer_row_state_result.row': 'SourceConstructorBuildState.source_constructor_dynamic_item_consumer_row_state',
                    'source_constructor_dynamic_item_consumer_row_state_result.has_item_row': 'SourceConstructorBuildState.source_constructor_dynamic_item_consumer_row_state',
                    'source_constructor_dynamic_item_trigger_state_result.items': 'SourceConstructorBuildState.source_constructor_dynamic_item_trigger_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeItemDynamic.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/payloads/BlockProducer.java',
            'core/src/mindustry/world/blocks/payloads/Constructor.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/game/Rules.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2265']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_constructor_dynamic_item_row_state(self):
        constructor = CONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The pure stacks function clones the recipe block's
        # requirements with each amount ceiled against the
        # build-cost multiplier (BlockProducer.java:49,
        # `clone[i].amount = Mathf.ceil(block.requirements[i].
        # amount * state.rules.buildCostMultiplier);`); a null
        # recipe yields ItemStack.empty (BlockProducer.java:53,
        # `return ItemStack.empty;`), so empty requirements
        # yield an empty stacks array. The multiplier default
        # is 1f (Rules.java:115, `public float
        # buildCostMultiplier = 1f;`).
        self.assertIn('static func source_constructor_dynamic_item_stacks_state', constructor)
        self.assertIn('clone[i].amount = Mathf.ceil(block.requirements[i].amount * state.rules.buildCostMultiplier);', constructor)
        self.assertIn('return ItemStack.empty;', constructor)
        self.assertIn('public float buildCostMultiplier = 1f;', constructor)
        self.assertIn('ceil(', constructor)
        # The pure row mirrors ConsumeItemDynamic.efficiency
        # (ConsumeItemDynamic.java:60-62, `return
        # build.consumeTriggerValid() || build.items.has(
        # items.get(build), multiplier.get(build)) ? 1f :
        # 0f;`): BINARY 1/0 -- 1 when the building is burning
        # a trigger consumer or its item module holds every
        # stack, 0 otherwise. consumeTriggerValid() is false
        # at the base (BuildingComp.java:764-766, `public
        # boolean consumeTriggerValid(){` with `return
        # false;`) and no Constructor/BlockProducer build
        # overrides it, so the trigger term is always false
        # here. items.has (ItemModule.java:153-156) requires
        # EVERY stack to hold round(amount * multiplier),
        # with has(item, amount) = get(item) >= amount
        # (ItemModule.java:126-128, `return get(item) >=
        # amount;`); an empty stacks array holds trivially
        # (the loop never runs), so a null recipe folds 1.0.
        # The multiplier defaults to 1f (Consume.java:18,
        # `public Floatf<Building> multiplier = b -> 1f;`).
        self.assertIn('static func source_constructor_dynamic_item_consumer_row_state', constructor)
        self.assertIn('return build.consumeTriggerValid() || build.items.has(items.get(build), multiplier.get(build)) ? 1f : 0f;', constructor)
        self.assertIn('public boolean consumeTriggerValid(){', constructor)
        self.assertIn('if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;', constructor)
        self.assertIn('return get(item) >= amount;', constructor)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', constructor)
        self.assertIn('"is_power": false', constructor)
        self.assertIn('inventory.item_count', constructor)
        # The pure trigger mirrors ConsumeItemDynamic.trigger
        # (ConsumeItemDynamic.java:53-57, `build.items.remove(
        # stack.item, Math.round(stack.amount *
        # multiplier.get(build)));`): remove round(amount *
        # multiplier) per stack, clamped to the held count
        # (ItemModule.java:258-263, `amount = Math.min(amount,
        # items[item.id]);`) through the shared inventory
        # helper. It is tested pure and NOT wired live yet:
        # consume() only fires when the progress advance
        # completes (BlockProducer.java:115-116, `if(progress
        # >= recipe.buildTime){` / `consume();`).
        self.assertIn('static func source_constructor_dynamic_item_trigger_state', constructor)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', constructor)
        self.assertIn('amount = Math.min(amount, items[item.id]);', constructor)
        self.assertIn('inventory.remove_item_state', constructor)
        self.assertIn('if(progress >= recipe.buildTime){', constructor)
        # The tick driver folds the row into the first pass:
        # the recipe block id resolves through the catalog,
        # whose requirements arrive as [{amount, item}]
        # kebab-case; the build-cost multiplier reads the live
        # rules state with the 1.0 default (the port
        # rules_state carries no buildCostMultiplier key yet);
        # the row appends to required_results beside the power
        # row (the first pass folds the min,
        # BuildingComp.java:1969-1976, `for(var cons :
        # block.nonOptionalConsumers){` /
        # `minEfficiency = Math.min(minEfficiency, result);`)
        # and never touches the optional pass.
        self.assertIn('static func source_constructor_tick_buildings_state', constructor)
        self.assertIn('source_constructor_dynamic_item_stacks_state(', constructor)
        self.assertIn('source_constructor_dynamic_item_consumer_row_state(', constructor)
        self.assertIn('blocks_by_id[recipe_id]', constructor)
        self.assertIn('buildCostMultiplier', constructor)
        self.assertIn('required_results.append', constructor)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', constructor)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', constructor)
        # The frame carries an items dict now (default {} for
        # a frame bound before this slice); no live intake
        # fills it yet, so the row reads the frame as-is.
        self.assertIn('"items": {}', constructor)
        # The proof's keys drive the pure stacks (ceil),
        # the pure row (binary full / zero missing / one on
        # empty recipe), the pure trigger (rounded removal),
        # plus the live tick (efficiency folds the dynamic
        # row). There are no progress / heat / recipe keys:
        # the advance waits for its own slice.
        proof = CONSTRUCTOR_DYNAMIC_ITEM_ROW_PROOF.read_text(encoding='utf-8')
        for key in [
            'dynamic_row_binary_full_stacks',
            'dynamic_row_zero_missing_stack',
            'dynamic_row_one_empty_recipe',
            'dynamic_stacks_ceil_cost_multiplier',
            'trigger_removes_rounded_amounts',
            'live_tick_folds_dynamic_row',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceConstructorBuildState.gd")', proof)
        self.assertIn('constructor_build_state.source_constructor_dynamic_item_consumer_row_state(', proof)
        self.assertIn('constructor_build_state.source_constructor_dynamic_item_stacks_state(', proof)
        self.assertIn('constructor_build_state.source_constructor_dynamic_item_trigger_state(', proof)
        scene = CONSTRUCTOR_DYNAMIC_ITEM_ROW_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ConstructorDynamicItemRowProof.gd', scene)
        self.assertIn('C07ConstructorDynamicItemRowProof', scene)

    def test_reference_graph_and_actual_c07_constructor_dynamic_item_row(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ConstructorDynamicItemRowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_CONSTRUCTOR_DYNAMIC_ITEM_ROW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'dynamic_row_binary_full_stacks',
            'dynamic_row_zero_missing_stack',
            'dynamic_row_one_empty_recipe',
            'dynamic_stacks_ceil_cost_multiplier',
            'trigger_removes_rounded_amounts',
            'live_tick_folds_dynamic_row',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
