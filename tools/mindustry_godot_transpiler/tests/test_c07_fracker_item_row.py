import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FRACKER_STATE = ROOT / 'godot-mindustry/src/game/SourceFrackerBuildState.gd'
EFFICIENCY_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingEfficiencyState.gd'
INVENTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceDrillInventoryRuntimeState.gd'
FRACKER_ITEM_ROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerItemRowProof.gd'
FRACKER_ITEM_ROW_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerItemRowProof.tscn'


class C07FrackerItemRowTests(unittest.TestCase):
    def test_c07_fracker_item_row_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2268']['godot_owner'], 'SourceFrackerBuildState.source_fracker_item_consumer_row_state')
        # N2153 proved the Fracker family's live power read,
        # N2207 proved the shouldConsume gate, N2224 proved
        # the updateTile advance (which already removes one
        # sand when the accumulator reaches itemUseTime) and
        # N2255 proved the liquid consumer row -- but the port
        # folded power + water only, so an oil-extractor with
        # an empty sand store still pumped at full efficiency:
        # the required ConsumeItems row (sand, Blocks.java:
        # 2976) never joined the first pass. N2268 is the item
        # consumer row: the pure row mirrors ConsumeItems.
        # efficiency (ConsumeItems.java:51-53, binary 1f/0f --
        # consumeTriggerValid base false, BuildingComp.java:
        # 764-766, no Fracker override, so the row is 1f only
        # when items.has holds every stack, ItemModule.java:
        # 153-156, round(amount * multiplier) each), folds
        # into the min efficiency with the power + water rows
        # (BuildingComp.java:1969-1976, the shared fold sets
        # shouldConsumePower=false when a non-power row is
        # <= 1e-7), and adds NO removal: Consume.update is
        # empty (Consume.java:52), the sand is only removed
        # by consume() in the N2224 advance (Fracker.java:
        # 32-35). Two new result symbols: the row and its
        # presence flag (the N2153 power-row shape).
        self.assertEqual(
            ledger['N2268']['source_symbols'],
            [
                'source_fracker_item_consumer_row_state_result.row',
                'source_fracker_item_consumer_row_state_result.has_item_row',
            ],
        )
        for name in ledger['N2268']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumeItems.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_item_consumer_row_state')
        self.assertEqual(ledger['N2268']['runtime_proof'], '/root/C07FrackerItemRowProof')
        self.assertEqual(
            ledger['N2268']['tests'],
            [
                'test_c07_fracker_item_row_registration',
                'test_all_c07_fracker_item_row_input_evidence_is_exact',
                'test_fracker_item_consumer_row_state',
                'test_reference_graph_and_actual_c07_fracker_item_row',
            ],
        )
        self.assertTrue(ledger['N2268']['deferred_exprs'])
        # This slice resolves the sand item row entry -- it is
        # gone -- while the sand intake entry stays (no live
        # intake fills frame["items"] yet; its cross-reference
        # now points at the live N2268 row instead of the
        # removed entry) and the water-attribute / validTiles
        # / boost fraction entry stays.
        self.assertFalse(any(entry.startswith('Fracker item consumer row (') for entry in ledger['N2268']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker item intake (') for entry in ledger['N2268']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker water-attribute / validTiles / boost fraction rows (') for entry in ledger['N2268']['deferred_exprs']))

    def test_all_c07_fracker_item_row_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2268']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_item_consumer_row_state')
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/blocks/production/Fracker.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2268']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_fracker_item_consumer_row_state(self):
        fracker = FRACKER_STATE.read_text(encoding='utf-8')
        # The pure item row lives on the Fracker build state:
        # ConsumeItems.efficiency (ConsumeItems.java:51-53,
        # `return build.consumeTriggerValid() || build.items.
        # has(items, multiplier.get(build)) ? 1f : 0f;`) is
        # BINARY 1/0 -- 1 when the building is burning a
        # trigger consumer or its item module holds every
        # stack, 0 otherwise. consumeTriggerValid() is false
        # at the base (BuildingComp.java:764-766) and no
        # Fracker build overrides it (only ConsumeGenerator
        # does, ConsumeGenerator.java:152), so the trigger
        # term is always false here. items.has (ItemModule.
        # java:153-156) requires EVERY stack to hold
        # round(amount * multiplier), with has(item, amount)
        # = get(item) >= amount (ItemModule.java:126-128).
        # Keep each Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this test).
        # The def sets no multiplier (consumeItem builds a
        # plain ConsumeItems, Block.java:1171-1172), so the
        # default multiplier 1f (Consume.java:18, `public
        # Floatf<Building> multiplier = b -> 1f;`) applies.
        self.assertIn('static func source_fracker_item_consumer_row_state', fracker)
        self.assertIn('return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;', fracker)
        self.assertIn('if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;', fracker)
        self.assertIn('return get(item) >= amount;', fracker)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', fracker)
        self.assertIn('consumeItem(Items.sand);', fracker)
        self.assertIn('return consumeItem(item, 1);', fracker)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', fracker)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', fracker)
        self.assertIn('if(cons != block.consPower && result <= 0.0000001f){', fracker)
        self.assertIn('shouldConsumePower = false;', fracker)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', fracker)
        self.assertIn('public void update(Building build){}', fracker)
        # The row shape mirrors the power row (the N2153
        # shape): {"has_item_row": bool, "row": {"result":
        # float, "is_power": false}} -- is_power false, so the
        # shared fold sets shouldConsumePower=false when the
        # row is <= 1e-7 (SourceBuildingEfficiencyState.
        # gd:109-117). A def with no item consumer
        # contributes no row: has_item_row false, row {}.
        # Unlike the WallCrafter row (N2264) there is no
        # item_valid output: Fracker has no itemValid read
        # (WallCrafter.java:191 belongs to WallCrafter only).
        self.assertIn('"is_power": false', fracker)
        self.assertIn('if not has_item_consumer:', fracker)
        self.assertIn('return {"has_item_row": false, "row": {}}', fracker)
        self.assertIn('"has_item_row": true', fracker)
        self.assertNotIn('"item_valid"', fracker)
        # The held sand reads through the shared inventory
        # helper over the frame items key (a Dictionary keyed
        # by item name, default {} for a frame bound before
        # this slice; an unknown item reads 0, the same
        # outcome as Java's id-out-of-range branch).
        self.assertIn('inventory.item_count(items, item_name)', fracker)
        # The def constant: sand (Blocks.java:2976), one
        # stack of 1 (Block.java:1167-1168).
        self.assertIn('SOURCE_FRACKER_CONSUME_ITEM := "sand"', fracker)
        # The tick wires the row into the first pass: the
        # driver reads the stacks from the catalog consumeItem
        # rows ([{"item": "sand", "amount": 1}] for the
        # oil-extractor -- the catalog DOES carry consumeItem
        # for fracker, the brief's "catalog has no consumeItem"
        # claim is wrong, verified in content_registry.json),
        # gates on the catalog item consumer, and appends the
        # row to required_results AFTER the liquid row (the
        # fold takes the min over power + water + sand, and
        # sets shouldConsumePower=false when the item row is
        # <= 1e-7).
        self.assertIn('block.properties.has("consumeItem")', fracker)
        self.assertIn('block.properties.get("consumeItem", [])', fracker)
        self.assertIn('source_fracker_item_consumer_row_state(frame, has_item_consumer, item_stacks)', fracker)
        self.assertIn('required_results.append(item_row.get("row", {}))', fracker)
        self.assertLess(fracker.index('required_results.append(liquid_row.get("row", {}))'), fracker.index('required_results.append(item_row.get("row", {}))'))
        # NO removal in this slice: the tick adds no second
        # pass for items (Consume.update is empty,
        # Consume.java:52) -- the only sand removal stays the
        # N2224 advance, and the advance itself is untouched.
        self.assertIn('static func source_fracker_update_tile_advance_state', fracker)
        self.assertIn('inventory.remove_item_state(items, SOURCE_FRACKER_CONSUME_ITEM, 1)', fracker)
        self.assertEqual(fracker.count('remove_item_state'), 1)
        # The shared fold (already live, SourceBuilding
        # EfficiencyState): a non-power row <= 1e-7 stops
        # power draw, and the fold takes the min over the
        # required rows.
        efficiency = EFFICIENCY_STATE.read_text(encoding='utf-8')
        self.assertIn('if not bool(consumer.get("is_power", false)) and result <= 0.0000001:', efficiency)
        self.assertIn('min_efficiency = min(min_efficiency, result)', efficiency)
        # The shared inventory helper exists: item_count reads
        # the held count for an item id (0 when absent).
        inventory = INVENTORY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func item_count(items: Dictionary, item_id: String) -> int:', inventory)
        # The documented limits now record the item row as
        # live (def + cites) and the remaining deferrals (no
        # live intake fills frame["items"] yet, fraction
        # fill); the old "power-only first pass" text is gone.
        # The N2153 power row, the N2207 gate, the N2224
        # advance and the N2255 liquid row are preserved.
        self.assertIn('item row live (N2268)', fracker)
        self.assertIn('liquid row live (N2255)', fracker)
        self.assertNotIn('power-only first pass', fracker)
        self.assertIn('shouldConsume gate live (N2207)', fracker)
        self.assertIn('updateTile advance live (N2224)', fracker)
        self.assertIn('static func source_fracker_power_status_row_state', fracker)
        self.assertIn('static func source_fracker_should_consume_state', fracker)
        self.assertIn('static func source_fracker_liquid_consumer_row_state', fracker)
        self.assertIn('static func source_fracker_tick_buildings_state', fracker)
        # The proof's keys drive the pure row (binary 1 with
        # sand, 0 without, folds the required min, blocks
        # power when starved) plus the live tick (efficiency
        # folds the sand min) and the untouched N2224 advance
        # (removal still consumes one sand at itemUseTime).
        # Static checks: the proof preloads point at files
        # that exist, and the scene file references the proof
        # script that exists.
        proof = FRACKER_ITEM_ROW_PROOF.read_text(encoding='utf-8')
        for key in [
            'item_row_binary_sand',
            'item_row_zero_no_sand',
            'item_row_folds_required_min',
            'sand_row_blocks_power_when_starved',
            'advance_removal_unchanged',
            'live_tick_folds_sand_row',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        for line in proof.splitlines():
            if 'preload("res://' in line:
                res_path = line.split('preload("res://', 1)[1].split('"', 1)[0]
                with self.subTest(preload=res_path):
                    self.assertTrue((ROOT / 'godot-mindustry' / res_path).is_file(), res_path)
        self.assertIn('preload("res://src/game/SourceFrackerBuildState.gd")', proof)
        self.assertTrue(FRACKER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = FRACKER_ITEM_ROW_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07FrackerItemRowProof.gd', scene)
        self.assertIn('C07FrackerItemRowProof', scene)

    def test_reference_graph_and_actual_c07_fracker_item_row(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07FrackerItemRowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FRACKER_ITEM_ROW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'item_row_binary_sand',
            'item_row_zero_no_sand',
            'item_row_folds_required_min',
            'sand_row_blocks_power_when_starved',
            'advance_removal_unchanged',
            'live_tick_folds_sand_row',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
