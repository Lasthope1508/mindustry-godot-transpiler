import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ACCELERATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceAcceleratorBuildState.gd'
ACCELERATOR_ITEM_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorItemRowsProof.gd'
ACCELERATOR_ITEM_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorItemRowsProof.tscn'


class C07AcceleratorItemRowsTests(unittest.TestCase):
    def test_c07_accelerator_item_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2267']['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_item_consumer_row_state')
        # N2183 proved the Accelerator family's live power read
        # and N2191 the updateTile advance (heat/statusLerp/
        # time/launchHeat/progress) -- but the folded efficiency
        # was still the power min always: the launch-block item
        # consumer rows, the core-nucleus requirements
        # (copper 8000, lead 8000, silicon 5000, thorium 4000,
        # Blocks.java:3154) registered in init()
        # (`consumeItems(launchBlock.requirements);`,
        # Accelerator.java:91), were never folded, so an
        # accelerator with no stored items charged progress as
        # if fully stocked. N2267 is the required ConsumeItems
        # row: the pure item row (source_accelerator_item_
        # consumer_row_state) mirrors ConsumeItems.efficiency
        # (ConsumeItems.java:51-53, `return build.
        # consumeTriggerValid() || build.items.has(items,
        # multiplier.get(build)) ? 1f : 0f;`) -- BINARY 1/0,
        # not a ratio -- and folds into the REQUIRED first pass
        # (BuildingComp.java:1969-1976), so a starved item row
        # zeroes efficiency and stops the progress advance
        # (Accelerator.java:143). The multiplier is the Consume
        # default 1f (Consume.java:18) and consumeTriggerValid
        # is the base false (BuildingComp.java:764-766), so the
        # row is 1.0 exactly when every stack is held
        # (ItemModule.java:153-157, `has` is every stack
        # `get(item) >= round(amount * multiplier)`). init()
        # also fills the per-item capacities and the item
        # capacity (Accelerator.java:85-90): capacities
        # {copper: 8000, lead: 8000, silicon: 5000, thorium:
        # 4000} and itemCapacity 25000 (the class default 8000,
        # Accelerator.java:76, is overwritten). getMaximumAccepted
        # (Accelerator.java:293-295) adds the launch block's
        # itemCapacity (core-nucleus 13000, Blocks.java:3158)
        # once the core is built, and acceptItem
        # (Accelerator.java:297-299) is held < maximumAccepted.
        # The catalog carries NO consumeItem for
        # interplanetary-accelerator (registered in init, the
        # extractor skips it) and its itemCapacity 10 is the
        # stale Block default -- so the slice uses the Java
        # source as the def constants, not the catalog. Ten new
        # result symbols: the row + presence flag, the
        # capacities + item capacity, the maximum accepted +
        # capacity + core bonus, the accept + held + maximum
        # accepted.
        self.assertEqual(
            ledger['N2267']['source_symbols'],
            [
                'source_accelerator_item_consumer_row_state_result.row',
                'source_accelerator_item_consumer_row_state_result.has_item_row',
                'source_accelerator_capacities_state_result.capacities',
                'source_accelerator_capacities_state_result.item_capacity',
                'source_accelerator_get_maximum_accepted_state_result.maximum_accepted',
                'source_accelerator_get_maximum_accepted_state_result.capacity',
                'source_accelerator_get_maximum_accepted_state_result.core_bonus',
                'source_accelerator_accept_item_state_result.accept',
                'source_accelerator_accept_item_state_result.held',
                'source_accelerator_accept_item_state_result.maximum_accepted',
            ],
        )
        for name in ledger['N2267']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumeItems.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/blocks/campaign/Accelerator.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_accelerator_item_consumer_row_state_result.row': 'SourceAcceleratorBuildState.source_accelerator_item_consumer_row_state',
                    'source_accelerator_item_consumer_row_state_result.has_item_row': 'SourceAcceleratorBuildState.source_accelerator_item_consumer_row_state',
                    'source_accelerator_capacities_state_result.capacities': 'SourceAcceleratorBuildState.source_accelerator_capacities_state',
                    'source_accelerator_capacities_state_result.item_capacity': 'SourceAcceleratorBuildState.source_accelerator_capacities_state',
                    'source_accelerator_get_maximum_accepted_state_result.maximum_accepted': 'SourceAcceleratorBuildState.source_accelerator_get_maximum_accepted_state',
                    'source_accelerator_get_maximum_accepted_state_result.capacity': 'SourceAcceleratorBuildState.source_accelerator_get_maximum_accepted_state',
                    'source_accelerator_get_maximum_accepted_state_result.core_bonus': 'SourceAcceleratorBuildState.source_accelerator_get_maximum_accepted_state',
                    'source_accelerator_accept_item_state_result.accept': 'SourceAcceleratorBuildState.source_accelerator_accept_item_state',
                    'source_accelerator_accept_item_state_result.held': 'SourceAcceleratorBuildState.source_accelerator_accept_item_state',
                    'source_accelerator_accept_item_state_result.maximum_accepted': 'SourceAcceleratorBuildState.source_accelerator_accept_item_state',
                }[name])
        self.assertEqual(ledger['N2267']['runtime_proof'], '/root/C07AcceleratorItemRowsProof')
        self.assertEqual(
            ledger['N2267']['tests'],
            [
                'test_c07_accelerator_item_rows_registration',
                'test_all_c07_accelerator_item_rows_input_evidence_is_exact',
                'test_accelerator_item_rows_row_state',
                'test_reference_graph_and_actual_c07_accelerator_item_rows',
            ],
        )
        self.assertTrue(ledger['N2267']['deferred_exprs'])

    def test_all_c07_accelerator_item_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2267']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_accelerator_item_consumer_row_state_result.row': 'SourceAcceleratorBuildState.source_accelerator_item_consumer_row_state',
                    'source_accelerator_item_consumer_row_state_result.has_item_row': 'SourceAcceleratorBuildState.source_accelerator_item_consumer_row_state',
                    'source_accelerator_capacities_state_result.capacities': 'SourceAcceleratorBuildState.source_accelerator_capacities_state',
                    'source_accelerator_capacities_state_result.item_capacity': 'SourceAcceleratorBuildState.source_accelerator_capacities_state',
                    'source_accelerator_get_maximum_accepted_state_result.maximum_accepted': 'SourceAcceleratorBuildState.source_accelerator_get_maximum_accepted_state',
                    'source_accelerator_get_maximum_accepted_state_result.capacity': 'SourceAcceleratorBuildState.source_accelerator_get_maximum_accepted_state',
                    'source_accelerator_get_maximum_accepted_state_result.core_bonus': 'SourceAcceleratorBuildState.source_accelerator_get_maximum_accepted_state',
                    'source_accelerator_accept_item_state_result.accept': 'SourceAcceleratorBuildState.source_accelerator_accept_item_state',
                    'source_accelerator_accept_item_state_result.held': 'SourceAcceleratorBuildState.source_accelerator_accept_item_state',
                    'source_accelerator_accept_item_state_result.maximum_accepted': 'SourceAcceleratorBuildState.source_accelerator_accept_item_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/blocks/campaign/Accelerator.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2267']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_accelerator_item_rows_row_state(self):
        accelerator = ACCELERATOR_STATE.read_text(encoding='utf-8')
        # The pure item row lives on the accelerator build
        # state: ConsumeItems.efficiency (ConsumeItems.java:
        # 51-53) over the frame items store, counted through
        # the shared drill inventory helper (SourceDrillInventory
        # RuntimeState.item_count, the Separator precedent) --
        # BINARY 1.0/0.0, not a ratio like ConsumeLiquid. The
        # trigger-valid half is the base false (BuildingComp.
        # java:764-766), so the row is 1.0 exactly when every
        # stack is held (ItemModule.java:153-157, each stack
        # `get(item) >= round(amount * multiplier)`); the
        # multiplier is the Consume default 1f (Consume.java:18)
        # and consumeItems registers the launch-block
        # requirements as one ConsumeItems (Block.java:
        # 1175-1176, Accelerator.java:91). The row is NOT power
        # (`"is_power": false`) and folds into the REQUIRED
        # first pass (BuildingComp.java:1969-1976), so a
        # starved row zeroes efficiency (BuildingComp.java:
        # 1985, 1992) and the progress advance follows it
        # (Accelerator.java:143). The capacities mirror init()
        # (Accelerator.java:85-90): per-item capacities from
        # the launch-block requirements plus the summed item
        # capacity 25000. getMaximumAccepted (Accelerator.java:
        # 293-295) is capacities[item] plus the core-nucleus
        # itemCapacity 13000 (Blocks.java:3158) once
        # isCoreBuilt (Accelerator.java:153-154); acceptItem
        # (Accelerator.java:297-299) is held < maximumAccepted.
        # NO removal in this slice: consume() only happens at
        # launch (Accelerator.java:258-291) -- the launch
        # consume waits for the launch slice.
        self.assertIn('static func source_accelerator_item_consumer_row_state', accelerator)
        self.assertIn('static func source_accelerator_capacities_state', accelerator)
        self.assertIn('static func source_accelerator_get_maximum_accepted_state', accelerator)
        self.assertIn('static func source_accelerator_accept_item_state', accelerator)
        self.assertIn('static func _accelerator_item_stacks_for_block', accelerator)
        self.assertIn('return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;', accelerator)
        self.assertIn('public boolean consumeTriggerValid(){', accelerator)
        self.assertIn('if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;', accelerator)
        self.assertIn('return get(item) >= amount;', accelerator)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', accelerator)
        self.assertIn('public ConsumeItems consumeItems(ItemStack... items){', accelerator)
        self.assertIn('return consume(new ConsumeItems(items));', accelerator)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', accelerator)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', accelerator)
        self.assertIn('efficiency = minEfficiency;', accelerator)
        self.assertIn('efficiency = optionalEfficiency = 0f;', accelerator)
        self.assertIn('public boolean shouldConsume(){', accelerator)
        self.assertIn('return enabled;', accelerator)
        self.assertIn('public class Accelerator extends Block{', accelerator)
        self.assertIn('public Block launchBlock = Blocks.coreNucleus;', accelerator)
        self.assertIn('itemCapacity = 8000;', accelerator)
        self.assertIn('itemCapacity = 0;', accelerator)
        self.assertIn('capacities = new int[content.items().size];', accelerator)
        self.assertIn('for(ItemStack stack : launchBlock.requirements){', accelerator)
        self.assertIn('capacities[stack.item.id] = stack.amount;', accelerator)
        self.assertIn('itemCapacity += stack.amount;', accelerator)
        self.assertIn('consumeItems(launchBlock.requirements);', accelerator)
        self.assertIn('public boolean isCoreBuilt(){', accelerator)
        self.assertIn('return progress >= 1f;', accelerator)
        self.assertIn('public int getMaximumAccepted(Item item){', accelerator)
        self.assertIn('return capacities[item.id] + (isCoreBuilt() ? launchBlock.itemCapacity : 0);', accelerator)
        self.assertIn('public boolean acceptItem(Building source, Item item){', accelerator)
        self.assertIn('return items.get(item) < getMaximumAccepted(item);', accelerator)
        self.assertIn('requirements(Category.effect, with(Items.copper, 8000, Items.lead, 8000, Items.silicon, 5000, Items.thorium, 4000));', accelerator)
        self.assertIn('itemCapacity = 13000;', accelerator)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', accelerator)
        # The row shape mirrors the power row (is_power false
        # here); the stacks come from the single def
        # (interplanetary-accelerator, the core-nucleus
        # requirements); the tick folds the row into
        # required_results, the first array of
        # update_consumption_state; the frame carries the
        # Building.items ItemModule (frame["items"], the
        # factory precedent SourceFactoryBuildState.gd:89-101)
        # with no live intake filling it yet (the Separator
        # precedent). The capacities are the four core-nucleus
        # amounts summing to itemCapacity 25000; the core
        # bonus is the core-nucleus itemCapacity 13000.
        self.assertIn('"is_power": false', accelerator)
        self.assertIn('required_results', accelerator)
        self.assertIn('block_id == "interplanetary-accelerator"', accelerator)
        self.assertIn('"copper"', accelerator)
        self.assertIn('"lead"', accelerator)
        self.assertIn('"silicon"', accelerator)
        self.assertIn('"thorium"', accelerator)
        self.assertIn('"items": {}', accelerator)
        self.assertIn('item_count', accelerator)
        self.assertIn('static func source_accelerator_tick_buildings_state', accelerator)
        self.assertIn('25000', accelerator)
        self.assertIn('13000', accelerator)
        # The proof's keys drive the pure row (binary over the
        # four core-nucleus stacks, zero when thorium is one
        # short) plus the capacities (four amounts summing to
        # 25000), the maximum accepted (capacity + 13000 core
        # bonus only when built), the accept boundary (held ==
        # max rejects) and the live tick (the row folds the
        # required min). There is no consume/removal key: the
        # launch consume() stays deferred. The scene file
        # exists and the proof preloads scripts that exist.
        proof = ACCELERATOR_ITEM_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'item_row_binary_core_nucleus_stacks',
            'item_row_zero_missing_thorium',
            'capacities_sum_item_capacity_25000',
            'max_accepted_adds_core_bonus_when_built',
            'accept_item_below_max_only',
            'live_tick_folds_item_row',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertTrue(ACCELERATOR_ITEM_ROWS_PROOF_SCENE.exists())
        self.assertIn('SourceAcceleratorBuildState.gd', proof)
        for preload in re.findall(r'preload\("(res://[^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload[len('res://'):]).is_file(), preload)
        scene = ACCELERATOR_ITEM_ROWS_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07AcceleratorItemRowsProof.gd', scene)

    def test_reference_graph_and_actual_c07_accelerator_item_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07AcceleratorItemRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ACCELERATOR_ITEM_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'item_row_binary_core_nucleus_stacks',
            'item_row_zero_missing_thorium',
            'capacities_sum_item_capacity_25000',
            'max_accepted_adds_core_bonus_when_built',
            'accept_item_below_max_only',
            'live_tick_folds_item_row',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
