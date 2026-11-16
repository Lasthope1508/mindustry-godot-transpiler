import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
SEPARATOR_LIQUID_ROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorLiquidRowProof.gd'
SEPARATOR_LIQUID_ROW_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorLiquidRowProof.tscn'


class C07SeparatorLiquidRowTests(unittest.TestCase):
    def test_c07_separator_liquid_row_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2252']['godot_owner'], 'SourceSeparatorBuildState.source_separator_liquid_consumer_row_state')
        # N2169 proved the separator's live power read, N2200 its
        # shouldConsume gate and N2222 its updateTile advance --
        # but the folded efficiency was still the min over the
        # *modeled* consumers (power only): both Separator defs
        # also consume liquid slag (separator
        # consumeLiquid(Liquids.slag, 4f / 60f), Blocks.java:1244;
        # disassembler consumeLiquid(Liquids.slag, 0.12f),
        # Blocks.java:1264 -- 0.12f PER FRAME, 7.2/s, not /60f),
        # and a separator with no slag ran at full efficiency.
        # N2252 is the required ConsumeLiquid row: the pure row
        # mirrors ConsumeLiquid.efficiency (ConsumeLiquid.java:
        # 42-47, `float ed = build.edelta() * build.
        # efficiencyScale();` / `if(ed <= 0.00000001f) return 0f;`
        # / `return Math.min(build.liquids.get(liquid) / (amount
        # * ed * multiplier.get(build)), 1f);`), folded by the
        # shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976) with the
        # shouldConsumePower stop on a starved non-power row
        # (BuildingComp.java:1972), and the second pass removes
        # the consumed slag (ConsumeLiquid.update,
        # ConsumeLiquid.java:37-39, `build.liquids.remove(liquid,
        # amount * build.edelta() * multiplier.get(build));`,
        # only when update && efficiency > 0,
        # BuildingComp.java:1999). The amount is per def, read
        # from the catalog consumeLiquid row (separator 4f/60f,
        # disassembler 0.12f); the multiplier is the 1f default
        # (Consume.java:18) -- neither def sets one. Two new
        # result symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2252']['source_symbols'],
            [
                'source_separator_liquid_consumer_row_state_result.row',
                'source_separator_liquid_consumer_row_state_result.has_liquid_row',
            ],
        )
        for name in ledger['N2252']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_separator_liquid_consumer_row_state_result.row': 'core/src/mindustry/world/consumers/ConsumeLiquid.java',
                    'source_separator_liquid_consumer_row_state_result.has_liquid_row': 'core/src/mindustry/entities/comp/BuildingComp.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], 'SourceSeparatorBuildState.source_separator_liquid_consumer_row_state')
        self.assertEqual(ledger['N2252']['runtime_proof'], '/root/C07SeparatorLiquidRowProof')
        self.assertEqual(
            ledger['N2252']['tests'],
            [
                'test_c07_separator_liquid_row_registration',
                'test_all_c07_separator_liquid_row_input_evidence_is_exact',
                'test_separator_liquid_consumer_row_state',
                'test_reference_graph_and_actual_c07_separator_liquid_row',
            ],
        )
        self.assertTrue(ledger['N2252']['deferred_exprs'])
        # This slice resolves the Separator liquid consumer row
        # deferral, so that entry is gone from DEFERRED; nothing
        # new defers. DEFERRED goes 294 - 1 = 293 entries.
        self.assertEqual(len(ledger['N2252']['deferred_exprs']), 293)
        self.assertFalse(any(entry.startswith('Separator liquid consumer row (') for entry in ledger['N2252']['deferred_exprs']))

    def test_all_c07_separator_liquid_row_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2252']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceSeparatorBuildState.source_separator_liquid_consumer_row_state')
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/production/Separator.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2252']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_separator_liquid_consumer_row_state(self):
        separator = SEPARATOR_STATE.read_text(encoding='utf-8')
        # The pure liquid row mirrors ConsumeLiquid.efficiency
        # (ConsumeLiquid.java:42-47): ed is edelta times the
        # efficiency scale, ed <= 1e-8 returns 0, otherwise the
        # held liquid over the per-frame demand, capped at 1.
        # In the first pass efficiency is assumed 1f
        # (BuildingComp.java:1965), so edelta is delta() =
        # source_delta * time_scale (BuildingComp.java:1922-1929).
        self.assertIn('static func source_separator_liquid_consumer_row_state', separator)
        self.assertIn('float ed = build.edelta() * build.efficiencyScale();', separator)
        self.assertIn('if(ed <= 0.00000001f) return 0f;', separator)
        self.assertIn('return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', separator)
        self.assertIn('build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', separator)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', separator)
        self.assertIn('if(update && efficiency > 0){', separator)
        # The row is a non-power row: the fold sets
        # shouldConsumePower=false when it starves
        # (BuildingComp.java:1972, `if(cons != block.consPower
        # && result <= 0.0000001f){`), and the min fold takes
        # the liquid row when it is below the power row
        # (BuildingComp.java:1969-1976).
        self.assertIn('"is_power": false', separator)
        self.assertIn('if(cons != block.consPower && result <= 0.0000001f){', separator)
        # The amount is per def, from the catalog consumeLiquid
        # row: separator slag 4f/60f (Blocks.java:1244),
        # disassembler slag 0.12f per frame (Blocks.java:1264).
        # A def with no slag row contributes no row
        # (has_liquid_row=false, the LaunchPad precedent).
        self.assertIn('consumeLiquid(Liquids.slag, 4f / 60f);', separator)
        self.assertIn('consumeLiquid(Liquids.slag, 0.12f);', separator)
        self.assertIn('block.properties.get("consumeLiquid", [])', separator)
        self.assertIn('{"has_liquid_row": false, "row": {}}', separator)
        # The held amount reads through the shared liquid
        # module helper over the frame liquids key, with the
        # Fracker guard (SourceFrackerBuildState.gd:279); the
        # tick syncs the live sprite store into the frame
        # BEFORE the fold (Fracker:327), and the second pass
        # removes the consumed slag through the same helper
        # (PayloadLoader cache_sums precedent).
        self.assertIn('source_liquid_module_state.source_get_state', separator)
        self.assertIn('frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})', separator)
        self.assertIn('source_liquid_module_state.source_remove_state', separator)
        self.assertIn('"liquids": {}', separator)
        # The proof's keys drive the pure row (starved / full /
        # edelta-zero / no-liquid) plus the live tick (the fold
        # takes the liquid min, the second pass removes slag
        # while running). There is no disassembler-amount key:
        # the per-def amount is a catalog read, and the
        # disassembler def waits for its own verification slice.
        proof = SEPARATOR_LIQUID_ROW_PROOF.read_text(encoding='utf-8')
        for key in [
            'row_folds_below_one_when_starved',
            'row_caps_at_one_when_full',
            'row_zeroes_when_edelta_zero',
            'row_zeroes_without_liquid',
            'live_tick_folds_liquid_row',
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
        scene = SEPARATOR_LIQUID_ROW_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07SeparatorLiquidRowProof.gd', scene)

    def test_reference_graph_and_actual_c07_separator_liquid_row(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SeparatorLiquidRowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SEPARATOR_LIQUID_ROW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'row_folds_below_one_when_starved',
            'row_caps_at_one_when_full',
            'row_zeroes_when_edelta_zero',
            'row_zeroes_without_liquid',
            'live_tick_folds_liquid_row',
            'live_tick_removes_liquid_when_running',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
