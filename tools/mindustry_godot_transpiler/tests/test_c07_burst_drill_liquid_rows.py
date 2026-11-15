import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_LIQUID_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillLiquidRowsProof.gd'
BURST_DRILL_LIQUID_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillLiquidRowsProof.tscn'


class C07BurstDrillLiquidRowsTests(unittest.TestCase):
    def test_c07_burst_drill_liquid_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2257']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_liquid_consumer_row_state')
        # N2149 proved the burst drill's live power read, N2203
        # its shouldConsume gate and N2219 its updateTile advance
        # -- but the folded efficiency was still the min over the
        # *modeled* consumers (power only): both BurstDrill defs
        # also consume liquids (impact-drill
        # consumeLiquid(Liquids.water, 10f/60f), Blocks.java:3089,
        # REQUIRED, + consumeLiquid(Liquids.ozone, 3f / 60f)
        # .boost(), Blocks.java:3090; eruption-drill
        # consumeLiquid(Liquids.hydrogen, 4f / 60f),
        # Blocks.java:3119, REQUIRED, + consumeLiquid(Liquids
        # .cyanogen, 0.75f / 60f).boost(), Blocks.java:3120),
        # and a burst drill with no liquid ran at full efficiency
        # with no booster at all. N2257 is the required +
        # booster ConsumeLiquid rows: the pure row mirrors
        # ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47,
        # `float ed = build.edelta() * build.efficiencyScale();`
        # / `if(ed <= 0.00000001f) return 0f;` / `return Math.min
        # (build.liquids.get(liquid) / (amount * ed * multiplier
        # .get(build)), 1f);`), the required row folds into the
        # min efficiency (BuildingComp.java:1969-1976) with the
        # shouldConsumePower stop on a starved non-power row
        # (BuildingComp.java:1972), the booster row folds into
        # the optional pass (BuildingComp.java:1980-1981, capped
        # by the min, BuildingComp.java:1986), and the second
        # pass removes the consumed liquid for both rows
        # (ConsumeLiquid.update, ConsumeLiquid.java:37-39, only
        # when update && efficiency > 0, BuildingComp.java:1999).
        # The required/booster split is a routing decision, not
        # a formula decision: Java's ConsumeLiquid.efficiency is
        # identical for both, and Block.java:1446-1447 splits the
        # consumers by the `optional` flag, so the driver routes
        # on the catalog row's optional flag. The amounts are
        # per def, read from the catalog consumeLiquid rows; the
        # multiplier is the 1f default (Consume.java:18) --
        # neither def sets one. Two new result symbols: the row
        # and its presence flag.
        self.assertEqual(
            ledger['N2257']['source_symbols'],
            [
                'source_burst_drill_liquid_consumer_row_state_result.row',
                'source_burst_drill_liquid_consumer_row_state_result.has_liquid_row',
            ],
        )
        for name in ledger['N2257']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_burst_drill_liquid_consumer_row_state_result.row': 'core/src/mindustry/world/consumers/ConsumeLiquid.java',
                    'source_burst_drill_liquid_consumer_row_state_result.has_liquid_row': 'core/src/mindustry/entities/comp/BuildingComp.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_liquid_consumer_row_state')
        self.assertEqual(ledger['N2257']['runtime_proof'], '/root/C07BurstDrillLiquidRowsProof')
        self.assertEqual(
            ledger['N2257']['tests'],
            [
                'test_c07_burst_drill_liquid_rows_registration',
                'test_all_c07_burst_drill_liquid_rows_input_evidence_is_exact',
                'test_burst_drill_liquid_consumer_row_state',
                'test_reference_graph_and_actual_c07_burst_drill_liquid_rows',
            ],
        )
        self.assertTrue(ledger['N2257']['deferred_exprs'])
        # This slice resolves the BurstDrill liquid rows
        # deferral, so that entry is gone from DEFERRED; nothing
        # new defers. DEFERRED goes 293 - 1 = 292 entries.
        self.assertEqual(len(ledger['N2257']['deferred_exprs']), 292)
        self.assertFalse(any(entry.startswith('BurstDrill liquid rows (') for entry in ledger['N2257']['deferred_exprs']))

    def test_all_c07_burst_drill_liquid_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2257']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_liquid_consumer_row_state')
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2257']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_liquid_consumer_row_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The pure liquid row mirrors ConsumeLiquid.efficiency
        # (ConsumeLiquid.java:42-47): ed is edelta times the
        # efficiency scale, ed <= 1e-8 returns 0, otherwise the
        # held liquid over the per-frame demand, capped at 1.
        # In the first pass efficiency is assumed 1f
        # (BuildingComp.java:1965), so edelta is delta() =
        # source_delta * time_scale (BuildingComp.java:1922-1929).
        # The same formula serves the required row and the
        # booster row: Java's ConsumeLiquid.efficiency does not
        # branch on the booster flag, and the split is routing
        # (Block.java:1446-1447 selects on `optional`).
        self.assertIn('static func source_burst_drill_liquid_consumer_row_state', burst_drill)
        self.assertIn('float ed = build.edelta() * build.efficiencyScale();', burst_drill)
        self.assertIn('if(ed <= 0.00000001f) return 0f;', burst_drill)
        self.assertIn('return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', burst_drill)
        self.assertIn('build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', burst_drill)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', burst_drill)
        self.assertIn('if(update && efficiency > 0){', burst_drill)
        # The row is a non-power row: the fold sets
        # shouldConsumePower=false when a required row starves
        # (BuildingComp.java:1972, `if(cons != block.consPower
        # && result <= 0.0000001f){`), and the min fold takes
        # the liquid row when it is below the power row
        # (BuildingComp.java:1969-1976).
        self.assertIn('"is_power": false', burst_drill)
        self.assertIn('if(cons != block.consPower && result <= 0.0000001f){', burst_drill)
        # The booster row folds into the optional pass, not the
        # min (BuildingComp.java:1980-1981), and the optional
        # efficiency is capped by the min (BuildingComp.java:
        # 1986). boost() is optional(true, true) (Consume.java:
        # 33-35). The driver routes on the catalog row's
        # optional flag and passes the booster rows as the
        # machinery's second array.
        self.assertIn('for(var cons : block.optionalConsumers){', burst_drill)
        self.assertIn('optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);', burst_drill)
        self.assertIn('return optional(true, true);', burst_drill)
        self.assertIn('optional_consumer_results.append(', burst_drill)
        # The amounts are per def, from the catalog consumeLiquid
        # rows: impact-drill water 10f/60f REQUIRED (Blocks.java:
        # 3089) + ozone 3f/60f booster (Blocks.java:3090);
        # eruption-drill hydrogen 4f/60f REQUIRED (Blocks.java:
        # 3119) + cyanogen 0.75f/60f booster (Blocks.java:3120).
        # A def with no liquid row contributes no row
        # (has_liquid_row=false, the LaunchPad precedent).
        self.assertIn('consumeLiquid(Liquids.water, 10f/60f);', burst_drill)
        self.assertIn('consumeLiquid(Liquids.ozone, 3f / 60f).boost();', burst_drill)
        self.assertIn('consumeLiquid(Liquids.hydrogen, 4f / 60f);', burst_drill)
        self.assertIn('consumeLiquid(Liquids.cyanogen, 0.75f / 60f).boost();', burst_drill)
        self.assertIn('block.properties.get("consumeLiquid", [])', burst_drill)
        self.assertIn('{"has_liquid_row": false, "row": {}}', burst_drill)
        # The held amount reads through the shared liquid
        # module helper over the frame liquids key, with the
        # Fracker guard (SourceFrackerBuildState.gd:151); the
        # tick syncs the live sprite store into the frame
        # BEFORE the fold (SourceFrackerBuildState.gd:361), and
        # the second pass removes the consumed liquid through
        # the same helper (PayloadLoader cache_sums precedent).
        self.assertIn('source_liquid_module_state.source_get_state', burst_drill)
        self.assertIn('frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})', burst_drill)
        self.assertIn('source_liquid_module_state.source_remove_state', burst_drill)
        self.assertIn('"liquids": {}', burst_drill)
        # The proof's keys drive the pure row (required starved
        # / booster starved / cap at one) plus the live tick
        # (the fold takes both rows, the optional cap, and the
        # second pass removes both liquids while running).
        proof = BURST_DRILL_LIQUID_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'required_row_folds_min_when_starved',
            'booster_row_folds_optional_when_starved',
            'optional_capped_by_min_efficiency',
            'row_caps_at_one_when_full',
            'live_tick_folds_both_rows',
            'live_tick_removes_liquid_when_running',
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
        scene = BURST_DRILL_LIQUID_ROWS_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BurstDrillLiquidRowsProof.gd', scene)

    def test_reference_graph_and_actual_c07_burst_drill_liquid_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillLiquidRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_LIQUID_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'required_row_folds_min_when_starved',
            'booster_row_folds_optional_when_starved',
            'optional_capped_by_min_efficiency',
            'row_caps_at_one_when_full',
            'live_tick_folds_both_rows',
            'live_tick_removes_liquid_when_running',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
