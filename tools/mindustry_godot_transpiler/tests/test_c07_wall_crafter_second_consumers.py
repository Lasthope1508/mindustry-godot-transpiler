import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WALL_CRAFTER_STATE = ROOT / 'godot-mindustry/src/game/SourceWallCrafterBuildState.gd'
WALL_CRAFTER_SECOND_CONSUMERS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterSecondConsumersProof.gd'
WALL_CRAFTER_SECOND_CONSUMERS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterSecondConsumersProof.tscn'


class C07WallCrafterSecondConsumersTests(unittest.TestCase):
    def test_c07_wall_crafter_second_consumers_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2264']['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_liquid_consumer_row_state')
        # N2170 proved the wall crafter's live power read, N2201
        # its shouldConsume gate and N2223 its updateTile advance
        # -- but the folded efficiency was still the min over the
        # *modeled* consumers (power only): the large-cliff-crusher
        # also consumes liquid hydrogen (consumeLiquid(
        # Liquids.hydrogen, 1f / 60f), Blocks.java:3028) as a
        # REQUIRED row (NOT .boost(), so hasLiquidBooster stays
        # false, WallCrafter.java:106) plus a graphite item booster
        # (itemConsumer = consumeItem(Items.graphite).boost(),
        # Blocks.java:3030), and a large crusher with no hydrogen
        # ran at full efficiency while its itemValid stayed the
        # frame default false. N2264 is both rows: the pure
        # hydrogen row mirrors ConsumeLiquid.efficiency
        # (ConsumeLiquid.java:42-47) and folds into the min
        # efficiency (BuildingComp.java:1969-1976) with the
        # shouldConsumePower stop on a starved non-power row
        # (BuildingComp.java:1972) and the second-pass removal
        # (ConsumeLiquid.update, ConsumeLiquid.java:37-39, only
        # when update && efficiency > 0, BuildingComp.java:1999);
        # the pure graphite row mirrors ConsumeItems.efficiency
        # (ConsumeItems.java:51-53, BINARY 1/0) and folds into
        # the OPTIONAL pass only (BuildingComp.java:1980-1981,
        # capped by minEfficiency at :1986), while frame
        # item_valid is stamped live from it for the N2223
        # advance (WallCrafter.java:191). No graphite removal:
        # Consume.update is empty (Consume.java:52), so the
        # second pass never removes items -- the graphite is
        # only removed by consume() on the timer gate
        # (WallCrafter.java:207-209), which waits for the
        # timer-infra slice. The cliff-crusher has neither row
        # (power only, Blocks.java:3004). Five new result
        # symbols: the liquid row + its presence flag, the item
        # row + its presence flag + item_valid.
        self.assertEqual(
            ledger['N2264']['source_symbols'],
            [
                'source_wall_crafter_liquid_consumer_row_state_result.row',
                'source_wall_crafter_liquid_consumer_row_state_result.has_liquid_row',
                'source_wall_crafter_item_consumer_row_state_result.row',
                'source_wall_crafter_item_consumer_row_state_result.has_item_row',
                'source_wall_crafter_item_consumer_row_state_result.item_valid',
            ],
        )
        for name in ledger['N2264']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_wall_crafter_liquid_consumer_row_state_result.row': 'core/src/mindustry/world/consumers/ConsumeLiquid.java',
                    'source_wall_crafter_liquid_consumer_row_state_result.has_liquid_row': 'core/src/mindustry/entities/comp/BuildingComp.java',
                    'source_wall_crafter_item_consumer_row_state_result.row': 'core/src/mindustry/world/consumers/ConsumeItems.java',
                    'source_wall_crafter_item_consumer_row_state_result.has_item_row': 'core/src/mindustry/entities/comp/BuildingComp.java',
                    'source_wall_crafter_item_consumer_row_state_result.item_valid': 'core/src/mindustry/world/blocks/production/WallCrafter.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], {
                    'source_wall_crafter_liquid_consumer_row_state_result.row': 'SourceWallCrafterBuildState.source_wall_crafter_liquid_consumer_row_state',
                    'source_wall_crafter_liquid_consumer_row_state_result.has_liquid_row': 'SourceWallCrafterBuildState.source_wall_crafter_liquid_consumer_row_state',
                    'source_wall_crafter_item_consumer_row_state_result.row': 'SourceWallCrafterBuildState.source_wall_crafter_item_consumer_row_state',
                    'source_wall_crafter_item_consumer_row_state_result.has_item_row': 'SourceWallCrafterBuildState.source_wall_crafter_item_consumer_row_state',
                    'source_wall_crafter_item_consumer_row_state_result.item_valid': 'SourceWallCrafterBuildState.source_wall_crafter_item_consumer_row_state',
                }[name])
        self.assertEqual(ledger['N2264']['runtime_proof'], '/root/C07WallCrafterSecondConsumersProof')
        self.assertEqual(
            ledger['N2264']['tests'],
            [
                'test_c07_wall_crafter_second_consumers_registration',
                'test_all_c07_wall_crafter_second_consumers_input_evidence_is_exact',
                'test_wall_crafter_second_consumers_row_state',
                'test_reference_graph_and_actual_c07_wall_crafter_second_consumers',
            ],
        )
        self.assertTrue(ledger['N2264']['deferred_exprs'])
        # This slice resolves the WallCrafter liquid + item
        # booster row deferrals, so both entries are gone from
        # DEFERRED, and the updateTile live-fill entry is
        # trimmed (item_valid is live now); nothing new defers.
        # DEFERRED goes 293 - 2 = 291 entries.
        self.assertEqual(len(ledger['N2264']['deferred_exprs']), 291)
        self.assertFalse(any(entry.startswith('WallCrafter liquid booster row (') for entry in ledger['N2264']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('WallCrafter item booster row (') for entry in ledger['N2264']['deferred_exprs']))
        self.assertTrue(any('item_valid (live since N2264' in entry for entry in ledger['N2264']['deferred_exprs']))

    def test_all_c07_wall_crafter_second_consumers_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2264']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_wall_crafter_liquid_consumer_row_state_result.row': 'SourceWallCrafterBuildState.source_wall_crafter_liquid_consumer_row_state',
                    'source_wall_crafter_liquid_consumer_row_state_result.has_liquid_row': 'SourceWallCrafterBuildState.source_wall_crafter_liquid_consumer_row_state',
                    'source_wall_crafter_item_consumer_row_state_result.row': 'SourceWallCrafterBuildState.source_wall_crafter_item_consumer_row_state',
                    'source_wall_crafter_item_consumer_row_state_result.has_item_row': 'SourceWallCrafterBuildState.source_wall_crafter_item_consumer_row_state',
                    'source_wall_crafter_item_consumer_row_state_result.item_valid': 'SourceWallCrafterBuildState.source_wall_crafter_item_consumer_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/production/WallCrafter.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/modules/ItemModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2264']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wall_crafter_second_consumers_row_state(self):
        wall_crafter = WALL_CRAFTER_STATE.read_text(encoding='utf-8')
        # The pure hydrogen row mirrors ConsumeLiquid.efficiency
        # (ConsumeLiquid.java:42-47): ed is edelta times the
        # efficiency scale, ed <= 1e-8 returns 0, otherwise the
        # held liquid over the per-frame demand, capped at 1.
        # In the first pass efficiency is assumed 1f
        # (BuildingComp.java:1965), so edelta is delta() =
        # source_delta * time_scale (BuildingComp.java:1922-1929).
        self.assertIn('static func source_wall_crafter_liquid_consumer_row_state', wall_crafter)
        self.assertIn('float ed = build.edelta() * build.efficiencyScale();', wall_crafter)
        self.assertIn('if(ed <= 0.00000001f) return 0f;', wall_crafter)
        self.assertIn('return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', wall_crafter)
        self.assertIn('build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', wall_crafter)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', wall_crafter)
        self.assertIn('if(update && efficiency > 0){', wall_crafter)
        # The pure graphite row mirrors ConsumeItems.efficiency
        # (ConsumeItems.java:51-53): BINARY 1/0 -- 1 when the
        # trigger is valid (base false, BuildingComp.java:
        # 764-766, no WallCrafter override) or every stack is
        # held (ItemModule.java:153-156, round(amount *
        # multiplier) each, has = get >= amount, :126-128).
        # The booster is optional(true, true) (Consume.java:
        # 33-35, boost()), so it folds the optional pass only
        # (BuildingComp.java:1980-1981), capped by
        # minEfficiency (:1986) -- it never lowers the folded
        # efficiency itself.
        self.assertIn('static func source_wall_crafter_item_consumer_row_state', wall_crafter)
        self.assertIn('return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;', wall_crafter)
        self.assertIn('for(var cons : block.optionalConsumers){', wall_crafter)
        self.assertIn('optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);', wall_crafter)
        self.assertIn('boolean itemValid = itemConsumer != null && itemConsumer.efficiency(this) > 0;', wall_crafter)
        # The hydrogen row is a non-power REQUIRED row: the fold
        # sets shouldConsumePower=false when it starves
        # (BuildingComp.java:1972, `if(cons != block.consPower
        # && result <= 0.0000001f){`), and the min fold takes
        # the hydrogen row when it is below the power row
        # (BuildingComp.java:1969-1976). Both rows are
        # non-power rows; the graphite row reaches the optional
        # pass, never the required one.
        self.assertIn('"is_power": false', wall_crafter)
        self.assertIn('if(cons != block.consPower && result <= 0.0000001f){', wall_crafter)
        self.assertIn('optional_consumer_results', wall_crafter)
        # The rows are large-cliff-crusher only: hydrogen 1f/60f
        # REQUIRED (Blocks.java:3028, NOT .boost(), so
        # hasLiquidBooster stays false, WallCrafter.java:106)
        # and graphite boost (Blocks.java:3030). The assigned
        # itemConsumer is captured by the catalog as
        # boosterItem, not a consumeItem row (the N2115
        # precedent), so the driver reads it through the
        # block-metadata helper. The cliff-crusher has neither
        # row (power only, Blocks.java:3004).
        self.assertIn('consumeLiquid(Liquids.hydrogen, 1f / 60f);', wall_crafter)
        self.assertIn('itemConsumer = consumeItem(Items.graphite).boost();', wall_crafter)
        self.assertIn('hasLiquidBooster = findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) != null;', wall_crafter)
        self.assertIn('block.properties.get("consumeLiquid", [])', wall_crafter)
        self.assertIn('block_booster_item(block)', wall_crafter)
        self.assertIn('{"has_liquid_row": false, "row": {}}', wall_crafter)
        self.assertIn('{"has_item_row": false, "row": {}, "item_valid": false}', wall_crafter)
        # The held hydrogen reads through the shared liquid
        # module helper over the frame liquids key, with the
        # Fracker guard (SourceFrackerBuildState.gd:221); the
        # tick syncs the live sprite store into the frame
        # BEFORE the fold (Fracker:623), and the second pass
        # removes the consumed hydrogen through the same helper
        # (PayloadLoader cache_sums precedent). The graphite
        # count reads through the shared inventory helper over
        # the frame items key, and frame item_valid is stamped
        # live from the item row BEFORE the advance (N2223
        # reads the key). No graphite removal: Consume.update
        # is empty (Consume.java:52), so the second pass never
        # removes items -- the timer-gated consume()
        # (WallCrafter.java:207-209) waits for its own slice.
        self.assertIn('source_liquid_module_state.source_get_state', wall_crafter)
        self.assertIn('frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})', wall_crafter)
        self.assertIn('source_liquid_module_state.source_remove_state', wall_crafter)
        self.assertIn('"liquids": {}', wall_crafter)
        self.assertIn('inventory.item_count', wall_crafter)
        self.assertIn('frame["item_valid"] = bool(item_row.get("item_valid", false))', wall_crafter)
        self.assertIn('public void update(Building build){}', wall_crafter)
        # The proof's keys drive the pure rows (item binary 1
        # when present, no rows on the cliff-crusher) plus the
        # live tick (hydrogen folds the min when starved and
        # stops power draw at zero, graphite folds optional
        # only, item_valid stamps live, the second pass removes
        # hydrogen while running).
        proof = WALL_CRAFTER_SECOND_CONSUMERS_PROOF.read_text(encoding='utf-8')
        for key in [
            'hydrogen_row_folds_min_when_starved',
            'graphite_row_folds_optional_when_absent',
            'item_row_binary_one_when_present',
            'cliff_crusher_has_no_rows',
            'item_valid_stamped_live',
            'live_tick_removes_hydrogen_when_running',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads must point at files that exist
        # (the N2185 lesson: an unrun proof scene fails
        # silently on a bad preload).
        for line in proof.splitlines():
            if 'preload("res://' in line:
                res_path = line.split('preload("res://', 1)[1].split('"', 1)[0]
                with self.subTest(preload=res_path):
                    self.assertTrue((ROOT / 'godot-mindustry' / res_path).is_file(), res_path)
        scene = WALL_CRAFTER_SECOND_CONSUMERS_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07WallCrafterSecondConsumersProof.gd', scene)

    def test_reference_graph_and_actual_c07_wall_crafter_second_consumers(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WallCrafterSecondConsumersProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WALL_CRAFTER_SECOND_CONSUMERS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'hydrogen_row_folds_min_when_starved',
            'graphite_row_folds_optional_when_absent',
            'item_row_binary_one_when_present',
            'cliff_crusher_has_no_rows',
            'item_valid_stamped_live',
            'live_tick_removes_hydrogen_when_running',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
