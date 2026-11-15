import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REGEN_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceRegenProjectorBuildState.gd'
REGEN_PROJECTOR_SECOND_CONSUMERS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorSecondConsumersProof.gd'
REGEN_PROJECTOR_SECOND_CONSUMERS_PROOF_TSCN = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorSecondConsumersProof.tscn'


class C07RegenProjectorSecondConsumersTests(unittest.TestCase):
    def test_c07_regen_projector_second_consumers_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2260']['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_liquid_consumer_row_state')
        # N2160 wired the regen-projector's live power.status
        # read, N2214 the anyTargets shouldConsume gate and
        # N2228 the updateTile advance -- but the folded
        # efficiency was still the min over the power row only:
        # the regen-projector also consumes hydrogen 1f/60f
        # (Blocks.java:2016, `consumeLiquid(Liquids.hydrogen,
        # 1f / 60f);`), a REQUIRED non-optional consumer, and
        # a phaseFabric booster item (Blocks.java:2017,
        # `consumeItem(Items.phaseFabric).boost();`). A
        # projector with an empty hydrogen store still folded
        # efficiency 1.0 and healed as if fully supplied, and
        # the booster never touched optionalEfficiency.
        # ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47,
        # `float ed = build.edelta() * build.efficiencyScale();`
        # with `if(ed <= 0.00000001f) return 0f;` and `return
        # Math.min(build.liquids.get(liquid) / (amount * ed *
        # multiplier.get(build)), 1f);`) folds into the same
        # first-pass min as the power row
        # (BuildingComp.java:1969-1976), and a starved row
        # stops the power draw (`if(cons != block.consPower &&
        # result <= 0.0000001f){`, BuildingComp.java:1972).
        # ConsumeItems.efficiency (ConsumeItems.java:51-53,
        # `return build.consumeTriggerValid() ||
        # build.items.has(items, multiplier.get(build)) ? 1f :
        # 0f;`) is BINARY 1/0, not a ratio, and the booster
        # (`optional(true, true)`, Consume.java:33-35) folds
        # into the optional pass (BuildingComp.java:1980-1981),
        # capped by minEfficiency (BuildingComp.java:1986).
        # The def sets no multiplier, so the Consume.java:18
        # default (`public Floatf<Building> multiplier = b ->
        # 1f;`) applies to both rows. N2260 is both rows: a
        # pure hydrogen row over the live store, folded by the
        # shared machinery, plus the second-pass removal
        # (`build.liquids.remove(liquid, amount *
        # build.edelta() * multiplier.get(build));`,
        # ConsumeLiquid.java:38, only when `update &&
        # efficiency > 0`, BuildingComp.java:1999), and a pure
        # phaseFabric item row folded into the optional pass,
        # with the consume() removal (ConsumeItems.trigger,
        # ConsumeItems.java:44-48, clamped by
        # ItemModule.remove, ItemModule.java:258-263) wired to
        # the N2228 advance's consumed report. Four new result
        # symbols: both rows and their presence flags.
        self.assertEqual(
            ledger['N2260']['source_symbols'],
            [
                'source_regen_projector_liquid_consumer_row_state_result.row',
                'source_regen_projector_liquid_consumer_row_state_result.has_liquid_row',
                'source_regen_projector_item_consumer_row_state_result.row',
                'source_regen_projector_item_consumer_row_state_result.has_item_row',
            ],
        )
        for name in ledger['N2260']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumeLiquid.java',
                    'core/src/mindustry/world/consumers/ConsumeItems.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_regen_projector_liquid_consumer_row_state_result.row': 'SourceRegenProjectorBuildState.source_regen_projector_liquid_consumer_row_state',
                    'source_regen_projector_liquid_consumer_row_state_result.has_liquid_row': 'SourceRegenProjectorBuildState.source_regen_projector_liquid_consumer_row_state',
                    'source_regen_projector_item_consumer_row_state_result.row': 'SourceRegenProjectorBuildState.source_regen_projector_item_consumer_row_state',
                    'source_regen_projector_item_consumer_row_state_result.has_item_row': 'SourceRegenProjectorBuildState.source_regen_projector_item_consumer_row_state',
                }[name])
        self.assertEqual(ledger['N2260']['runtime_proof'], '/root/C07RegenProjectorSecondConsumersProof')
        self.assertEqual(
            ledger['N2260']['tests'],
            [
                'test_c07_regen_projector_second_consumers_registration',
                'test_all_c07_regen_projector_second_consumers_input_evidence_is_exact',
                'test_regen_projector_second_consumers_row_state',
                'test_reference_graph_and_actual_c07_regen_projector_second_consumers',
            ],
        )
        self.assertTrue(ledger['N2260']['deferred_exprs'])

    def test_all_c07_regen_projector_second_consumers_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2260']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_regen_projector_liquid_consumer_row_state_result.row': 'SourceRegenProjectorBuildState.source_regen_projector_liquid_consumer_row_state',
                    'source_regen_projector_liquid_consumer_row_state_result.has_liquid_row': 'SourceRegenProjectorBuildState.source_regen_projector_liquid_consumer_row_state',
                    'source_regen_projector_item_consumer_row_state_result.row': 'SourceRegenProjectorBuildState.source_regen_projector_item_consumer_row_state',
                    'source_regen_projector_item_consumer_row_state_result.has_item_row': 'SourceRegenProjectorBuildState.source_regen_projector_item_consumer_row_state',
                }[name])
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/consumers/ConsumeLiquid.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/consumers/ConsumeItems.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/consumers/Consume.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/modules/ItemModule.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/defense/RegenProjector.java'),
            ('arc-upstream', 'arc-core/src/arc/util/Time.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2260']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_regen_projector_second_consumers_row_state(self):
        regen_projector = REGEN_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure hydrogen row lives on the regen-projector
        # build state: ConsumeLiquid.efficiency
        # (ConsumeLiquid.java:42-47) over the live hydrogen
        # store, folded by the first pass
        # (BuildingComp.java:1969-1976) into the min
        # efficiency; a starved row stops the power draw
        # (BuildingComp.java:1972-1974). In the first pass
        # efficiency is assumed 1f (BuildingComp.java:1964-1965,
        # `efficiency = optionalEfficiency = 1f;`), so edelta
        # is delta() = Time.delta * timeScale
        # (BuildingComp.java:1922-1929, `return efficiency *
        # delta();` / `return Time.delta * timeScale;`) and
        # ed = source_delta * time_scale * efficiency_scale.
        # The amount comes from the shared liquid module
        # helper (SourceLiquidModuleState.source_get_state)
        # over the frame liquids key, with the Fracker guard
        # (SourceFrackerBuildState.gd:221). The second
        # pass removes amount * edelta * multiplier
        # (ConsumeLiquid.java:38) only when `update &&
        # efficiency > 0` (BuildingComp.java:1999), with
        # edelta from the FOLDED efficiency -- a direct
        # removal after apply_update_consumption_state, not
        # the AdjacentFactory updates-array precedent (that
        # pattern passes generated consumer actor objects;
        # this driver is pure static functions with no actor).
        # The single def consumes hydrogen 1f/60f,
        # `consumeLiquid(Liquids.hydrogen, 1f / 60f);`
        # (Blocks.java:2016); the def sets no multiplier, so
        # the default `public Floatf<Building> multiplier = b
        # -> 1f;` (Consume.java:18) applies.
        self.assertIn('float ed = build.edelta() * build.efficiencyScale();', regen_projector)
        self.assertIn('if(ed <= 0.00000001f) return 0f;', regen_projector)
        self.assertIn('return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', regen_projector)
        self.assertIn('build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', regen_projector)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', regen_projector)
        self.assertIn('consumeLiquid(Liquids.hydrogen, 1f / 60f);', regen_projector)
        self.assertIn('return efficiency * delta();', regen_projector)
        self.assertIn('return Time.delta * timeScale;', regen_projector)
        self.assertIn('if(update && efficiency > 0){', regen_projector)
        self.assertIn('cons.update(self());', regen_projector)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', regen_projector)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', regen_projector)
        self.assertIn('if(cons != block.consPower && result <= 0.0000001f){', regen_projector)
        self.assertIn('source_regen_projector_liquid_consumer_row_state', regen_projector)
        self.assertIn('SOURCE_REGEN_PROJECTOR_LIQUID_AMOUNT', regen_projector)
        self.assertIn('"liquids": {}', regen_projector)
        self.assertIn('frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})', regen_projector)
        self.assertIn('required_results.append(liquid_row.get("row", {}))', regen_projector)
        self.assertIn('source_remove_state', regen_projector)
        self.assertIn('has_liquid_row', regen_projector)
        # The pure phaseFabric item row mirrors
        # ConsumeItems.efficiency (ConsumeItems.java:51-53):
        # BINARY 1.0/0.0 -- 1 when consumeTriggerValid() (base
        # false, BuildingComp.java:764-766) or every stack is
        # held (ItemModule.has, ItemModule.java:153-156, each
        # stack at round(amount * multiplier)), else 0. The
        # booster (`return optional(true, true);`,
        # Consume.java:33-35) folds into the optional pass
        # (BuildingComp.java:1980-1981), capped by the min
        # efficiency (`optionalEfficiency =
        # Math.min(optionalEfficiency, minEfficiency);`,
        # BuildingComp.java:1986). The single def consumes one
        # phaseFabric, `consumeItem(Items.phaseFabric).boost();`
        # (Blocks.java:2017). ConsumeItems has no update
        # override, so the second pass never consumes items;
        # the removal happens only through consume()
        # (BuildingComp.java:1911-1915) when the N2228 advance
        # reports consumed, removing round(1 * 1) = 1
        # phaseFabric clamped to what the frame holds
        # (`build.items.remove(stack.item,
        # Math.round(stack.amount * multiplier.get(build)));`,
        # ConsumeItems.java:44-48; ItemModule.remove clamps,
        # ItemModule.java:258-263). No live intake fills
        # frame["items"] yet -- the row reads the frame as-is,
        # the Separator precedent.
        self.assertIn('return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;', regen_projector)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', regen_projector)
        self.assertIn('return optional(true, true);', regen_projector)
        self.assertIn('consumeItem(Items.phaseFabric).boost();', regen_projector)
        self.assertIn('for(var cons : block.optionalConsumers){', regen_projector)
        self.assertIn('optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);', regen_projector)
        self.assertIn('if((optionalTimer += edelta() * optionalEfficiency) >= optionalUseTime){', regen_projector)
        self.assertIn('source_regen_projector_item_consumer_row_state', regen_projector)
        self.assertIn('"items": {}', regen_projector)
        self.assertIn('optional_results.append(item_row.get("row", {}))', regen_projector)
        self.assertIn('remove_item_state', regen_projector)
        self.assertIn('item_count', regen_projector)
        self.assertIn('has_item_row', regen_projector)
        self.assertIn('"is_power": false', regen_projector)
        # The proof's keys drive the pure rows (starved
        # hydrogen / binary item present / absent) plus the
        # live tick (optional capped by the power min,
        # hydrogen removed while running, phaseFabric removed
        # on the consumed tick). The proof preloads the driver
        # it proves, and its scene loads the proof script.
        proof = REGEN_PROJECTOR_SECOND_CONSUMERS_PROOF.read_text(encoding='utf-8')
        self.assertIn('res://src/game/SourceRegenProjectorBuildState.gd', proof)
        for key in [
            'hydrogen_row_folds_min_when_starved',
            'phase_fabric_row_folds_optional_when_absent',
            'item_row_binary_one_when_present',
            'optional_capped_by_min_efficiency',
            'live_tick_removes_hydrogen_when_running',
            'consumed_tick_removes_phase_fabric',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceRegenProjectorBuildState.gd")', proof)
        self.assertTrue(REGEN_PROJECTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        tscn = REGEN_PROJECTOR_SECOND_CONSUMERS_PROOF_TSCN.read_text(encoding='utf-8')
        self.assertIn('C07RegenProjectorSecondConsumersProof.gd', tscn)
        self.assertIn('C07RegenProjectorSecondConsumersProof', tscn)

    def test_reference_graph_and_actual_c07_regen_projector_second_consumers(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RegenProjectorSecondConsumersProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REGEN_PROJECTOR_SECOND_CONSUMERS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'hydrogen_row_folds_min_when_starved',
            'phase_fabric_row_folds_optional_when_absent',
            'item_row_binary_one_when_present',
            'optional_capped_by_min_efficiency',
            'live_tick_removes_hydrogen_when_running',
            'consumed_tick_removes_phase_fabric',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
