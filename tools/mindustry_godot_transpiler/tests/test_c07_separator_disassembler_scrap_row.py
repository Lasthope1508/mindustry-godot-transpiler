import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
EFFICIENCY_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingEfficiencyState.gd'
INVENTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceDrillInventoryRuntimeState.gd'
SEPARATOR_SCRAP_ROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorDisassemblerScrapRowProof.gd'
SEPARATOR_SCRAP_ROW_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorDisassemblerScrapRowProof.tscn'


class C07SeparatorDisassemblerScrapRowTests(unittest.TestCase):
    def test_c07_separator_disassembler_scrap_row_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2349']['godot_owner'], 'SourceSeparatorBuildState.source_separator_disassembler_scrap_row_state')
        # N2169 proved the separator's live power read, N2200
        # its shouldConsume gate, N2222 its updateTile advance
        # (which already removes one scrap via consume() when
        # a disassembler craft completes) and N2252 its liquid
        # slag row -- but the port folded power + liquid only,
        # so a disassembler with an empty scrap store still
        # crafted at full efficiency: the required ConsumeItems
        # row (scrap, Blocks.java:1263) never joined the first
        # pass. N2349 is the item consumer row: the pure row
        # mirrors ConsumeItems.efficiency (ConsumeItems.java:
        # 51-53, binary 1f/0f -- consumeTriggerValid base
        # false, BuildingComp.java:764-766, no Separator /
        # GenericCrafter override, so the row is 1f only when
        # items.has holds every stack, ItemModule.java:
        # 153-156, round(amount * multiplier) each), folds
        # into the min efficiency with the power + liquid rows
        # (BuildingComp.java:1969-1976, the shared fold sets
        # shouldConsumePower=false when a non-power row is
        # <= 1e-7), and adds NO removal: Consume.update is
        # empty (Consume.java:52), the scrap is only removed
        # by consume() in the N2222 advance (Separator.java:
        # 158). The row applies to the disassembler def ONLY:
        # the separator def has no consumeItem (Blocks.java:
        # 1231-1246). Two new result symbols: the row and its
        # presence flag (the N2153 power-row shape).
        self.assertEqual(
            ledger['N2349']['source_symbols'],
            [
                'source_separator_disassembler_scrap_row_state_result.row',
                'source_separator_disassembler_scrap_row_state_result.has_item_row',
            ],
        )
        for name in ledger['N2349']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_separator_disassembler_scrap_row_state_result.row': 'core/src/mindustry/world/consumers/ConsumeItems.java',
                    'source_separator_disassembler_scrap_row_state_result.has_item_row': 'core/src/mindustry/entities/comp/BuildingComp.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], 'SourceSeparatorBuildState.source_separator_disassembler_scrap_row_state')
        self.assertEqual(ledger['N2349']['runtime_proof'], '/root/C07SeparatorDisassemblerScrapRowProof')
        self.assertEqual(
            ledger['N2349']['tests'],
            [
                'test_c07_separator_disassembler_scrap_row_registration',
                'test_all_c07_separator_disassembler_scrap_row_input_evidence_is_exact',
                'test_separator_disassembler_scrap_row_state',
                'test_reference_graph_and_actual_c07_separator_disassembler_scrap_row',
            ],
        )
        self.assertTrue(ledger['N2349']['deferred_exprs'])
        # This slice resolves the disassembler scrap item row
        # entry (334 - 1 = 333, no new deferral): the intake
        # gap stays on the Separator items intake entry, and
        # the disassembler variant verification entry stays.
        self.assertEqual(len(ledger['N2349']['deferred_exprs']), 333)
        self.assertFalse(any(entry.startswith('Disassembler scrap item efficiency row (') for entry in ledger['N2349']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator items intake rows (') for entry in ledger['N2349']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator disassembler variant (') for entry in ledger['N2349']['deferred_exprs']))

    def test_all_c07_separator_disassembler_scrap_row_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2349']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceSeparatorBuildState.source_separator_disassembler_scrap_row_state')
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/blocks/production/Separator.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2349']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_separator_disassembler_scrap_row_state(self):
        separator = SEPARATOR_STATE.read_text(encoding='utf-8')
        # The pure item row lives on the Separator build state:
        # ConsumeItems.efficiency (ConsumeItems.java:51-53,
        # `return build.consumeTriggerValid() || build.items.
        # has(items, multiplier.get(build)) ? 1f : 0f;`) is
        # BINARY 1/0 -- 1 when the building is burning a
        # trigger consumer or its item module holds every
        # stack, 0 otherwise. consumeTriggerValid() is false
        # at the base (BuildingComp.java:764-766) and no
        # Separator build overrides it (only ConsumeGenerator
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
        self.assertIn('static func source_separator_disassembler_scrap_row_state', separator)
        self.assertIn('return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;', separator)
        self.assertIn('if(stack.item.id >= items.length || !has(stack.item, Math.round(stack.amount * multiplier))) return false;', separator)
        self.assertIn('return get(item) >= amount;', separator)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', separator)
        self.assertIn('consumeItem(Items.scrap);', separator)
        self.assertIn('return consumeItem(item, 1);', separator)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', separator)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', separator)
        self.assertIn('if(cons != block.consPower && result <= 0.0000001f){', separator)
        self.assertIn('shouldConsumePower = false;', separator)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', separator)
        self.assertIn('public void update(Building build){}', separator)
        # The row shape mirrors the power row (the N2153
        # shape): {"has_item_row": bool, "row": {"result":
        # float, "is_power": false}} -- is_power false, so the
        # shared fold sets shouldConsumePower=false when the
        # row is <= 1e-7 (SourceBuildingEfficiencyState.
        # gd:109-117). A def with no item consumer
        # contributes no row: has_item_row false, row {} --
        # the separator def has no consumeItem, so only the
        # disassembler def folds this row.
        self.assertIn('"is_power": false', separator)
        self.assertIn('if not has_item_consumer:', separator)
        self.assertIn('return {"has_item_row": false, "row": {}}', separator)
        self.assertIn('"has_item_row": true', separator)
        # The held scrap reads through the shared inventory
        # helper over the frame items key (a Dictionary keyed
        # by item name, default {} for a frame bound before
        # this slice; an unknown item reads 0, the same
        # outcome as Java's id-out-of-range branch).
        self.assertIn('inventory.item_count(items, item_name)', separator)
        # The tick wires the row into the first pass: the
        # driver reads the stacks from the catalog consumeItem
        # rows ([{"item": "scrap", "amount": 1}] for the
        # disassembler -- the catalog DOES carry consumeItem
        # for disassembler and none for separator, verified
        # in content_registry.json), gates on the catalog item
        # consumer, and appends the row to required_results
        # AFTER the liquid row (the fold takes the min over
        # power + liquid + scrap, and sets
        # shouldConsumePower=false when the item row is
        # <= 1e-7).
        self.assertIn('block.properties.has("consumeItem")', separator)
        self.assertIn('block.properties.get("consumeItem", [])', separator)
        self.assertIn('source_separator_disassembler_scrap_row_state(frame, has_item_consumer, item_stacks)', separator)
        self.assertIn('required_results.append(item_row.get("row", {}))', separator)
        self.assertLess(separator.index('required_results.append(liquid_row.get("row", {}))'), separator.index('required_results.append(item_row.get("row", {}))'))
        # NO removal in this slice: the tick adds no second
        # pass for items (Consume.update is empty,
        # Consume.java:52) -- the only scrap removal stays
        # the N2222 advance consume(), and the advance itself
        # is untouched (its remove_item_state call count is
        # unchanged: one call in the advance plus one comment
        # mention in its docstring).
        self.assertIn('static func source_separator_update_tile_advance_state', separator)
        self.assertIn('inventory.remove_item_state(items, str(cons_dict.get("item", "")), int(cons_dict.get("amount", 1)))', separator)
        self.assertEqual(separator.count('remove_item_state'), 2)
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
        # live intake fills frame["items"] yet); the old
        # "disassembler with no scrap still folds as if the
        # item row were 1.0" text is gone. The N2169 power
        # row, the N2200 gate, the N2222 advance, the N2252
        # liquid row and the N2343 offload routing are
        # preserved.
        self.assertIn('item row live (N2349)', separator)
        self.assertIn('liquid row live (N2252)', separator)
        self.assertNotIn('still folds as if the item row were 1.0', separator)
        self.assertIn('shouldConsume gate live (N2200)', separator)
        self.assertIn('updateTile advance (N2222)', separator)
        self.assertIn('static func source_separator_power_status_row_state', separator)
        self.assertIn('static func source_separator_should_consume_state', separator)
        self.assertIn('static func source_separator_liquid_consumer_row_state', separator)
        self.assertIn('static func source_separator_tick_buildings_state', separator)
        # The proof's keys drive the pure row (binary 1 with
        # scrap, 0 without, folds the required min) plus the
        # live tick (efficiency folds the scrap min, the
        # starved row blocks power) and the untouched N2222
        # advance (removal still consumes one scrap at craft).
        # Static checks: the proof preloads point at files
        # that exist, and the scene file references the proof
        # script that exists.
        proof = SEPARATOR_SCRAP_ROW_PROOF.read_text(encoding='utf-8')
        for key in [
            'item_row_binary_scrap',
            'item_row_zero_no_scrap',
            'item_row_folds_required_min',
            'advance_removal_unchanged',
            'live_tick_folds_scrap_row',
            'scrap_row_blocks_power_when_starved',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        for line in proof.splitlines():
            if 'preload("res://' in line:
                res_path = line.split('preload("res://', 1)[1].split('"', 1)[0]
                with self.subTest(preload=res_path):
                    self.assertTrue((ROOT / 'godot-mindustry' / res_path).is_file(), res_path)
        self.assertIn('preload("res://src/game/SourceSeparatorBuildState.gd")', proof)
        self.assertTrue(SEPARATOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = SEPARATOR_SCRAP_ROW_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07SeparatorDisassemblerScrapRowProof.gd', scene)
        self.assertIn('C07SeparatorDisassemblerScrapRowProof', scene)

    def test_reference_graph_and_actual_c07_separator_disassembler_scrap_row(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SeparatorDisassemblerScrapRowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SEPARATOR_DISASSEMBLER_SCRAP_ROW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'item_row_binary_scrap',
            'item_row_zero_no_scrap',
            'item_row_folds_required_min',
            'advance_removal_unchanged',
            'live_tick_folds_scrap_row',
            'scrap_row_blocks_power_when_starved',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
