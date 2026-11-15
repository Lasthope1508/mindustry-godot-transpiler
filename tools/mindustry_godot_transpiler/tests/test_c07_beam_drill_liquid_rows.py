import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_LIQUID_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillLiquidRowsProof.gd'
BEAM_DRILL_LIQUID_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillLiquidRowsProof.tscn'


class C07BeamDrillLiquidRowsTests(unittest.TestCase):
    def test_c07_beam_drill_liquid_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2256']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_liquid_consumer_row_state')
        # N2155 proved the beam drill's live power read, N2202
        # its shouldConsume gate and N2195 its updateTile
        # advance -- but the folded efficiency was still the min
        # over the *modeled* consumers (power only): both
        # BeamDrill defs also consume liquid (plasma-bore
        # consumeLiquid(Liquids.hydrogen, 0.25f / 60f).boost(),
        # Blocks.java:3049; large-plasma-bore
        # consumeLiquid(Liquids.hydrogen, 0.5f / 60f),
        # Blocks.java:3064, REQUIRED, plus
        # consumeLiquid(Liquids.nitrogen, 3f / 60f).boost(),
        # Blocks.java:3065), and a beam drill with no liquid ran
        # at full efficiency with a full boost. N2256 is the
        # required + booster ConsumeLiquid rows: the pure row
        # mirrors ConsumeLiquid.efficiency (ConsumeLiquid.java:
        # 42-47), the required row folds into the min efficiency
        # (BuildingComp.java:1969-1976) with the
        # shouldConsumePower stop on a starved non-power row
        # (BuildingComp.java:1972), and the booster row folds
        # into the optional pass (BuildingComp.java:1980-1981),
        # capped by minEfficiency (BuildingComp.java:1986).
        # boost() is optional(true, true) (Consume.java:33-35),
        # so the booster never touches minEfficiency. The
        # second pass removes the consumed liquid for BOTH rows
        # (ConsumeLiquid.update, ConsumeLiquid.java:37-39, only
        # when update && efficiency > 0, BuildingComp.java:1999)
        # -- both rows have update=true (Consume.java:16), so
        # both are second-pass consumers. The advance (N2195)
        # already reads frame optional_efficiency (multiplier =
        # lerp(1, 2.5, optionalEfficiency), BeamDrill.java:246);
        # this slice only adds the rows + fold wiring. Two new
        # result symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2256']['source_symbols'],
            [
                'source_beam_drill_liquid_consumer_row_state_result.row',
                'source_beam_drill_liquid_consumer_row_state_result.has_liquid_row',
            ],
        )
        for name in ledger['N2256']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_beam_drill_liquid_consumer_row_state_result.row': 'core/src/mindustry/world/consumers/ConsumeLiquid.java',
                    'source_beam_drill_liquid_consumer_row_state_result.has_liquid_row': 'core/src/mindustry/entities/comp/BuildingComp.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_liquid_consumer_row_state')
        self.assertEqual(ledger['N2256']['runtime_proof'], '/root/C07BeamDrillLiquidRowsProof')
        self.assertEqual(
            ledger['N2256']['tests'],
            [
                'test_c07_beam_drill_liquid_rows_registration',
                'test_all_c07_beam_drill_liquid_rows_input_evidence_is_exact',
                'test_beam_drill_liquid_consumer_row_state',
                'test_reference_graph_and_actual_c07_beam_drill_liquid_rows',
            ],
        )
        self.assertTrue(ledger['N2256']['deferred_exprs'])
        # This slice resolves the BeamDrill liquid rows
        # deferral and adds one new deferral (live liquid
        # intake); DEFERRED goes 293 - 1 + 1 = 293 entries.
        self.assertEqual(len(ledger['N2256']['deferred_exprs']), 293)
        self.assertFalse(any(entry.startswith('BeamDrill liquid rows (') for entry in ledger['N2256']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill live liquid intake (') for entry in ledger['N2256']['deferred_exprs']))

    def test_all_c07_beam_drill_liquid_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2256']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_liquid_consumer_row_state')
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2256']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_liquid_consumer_row_state(self):
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # The pure liquid row mirrors ConsumeLiquid.efficiency
        # (ConsumeLiquid.java:42-47): ed is edelta times the
        # efficiency scale, ed <= 1e-8 returns 0, otherwise the
        # held liquid over the per-frame demand, capped at 1.
        # In the first pass efficiency is assumed 1f
        # (BuildingComp.java:1965), so edelta is delta() =
        # source_delta * time_scale (BuildingComp.java:1922-1929).
        # ONE pure function serves both the required row and the
        # booster row: the efficiency formula is identical for
        # both, and Java distinguishes them only by which
        # consumer list they join (nonOptionalConsumers,
        # BuildingComp.java:1969, vs optionalConsumers,
        # BuildingComp.java:1980) -- the tick routes by the
        # catalog optional flag.
        self.assertIn('static func source_beam_drill_liquid_consumer_row_state', beam_drill)
        self.assertIn('float ed = build.edelta() * build.efficiencyScale();', beam_drill)
        self.assertIn('if(ed <= 0.00000001f) return 0f;', beam_drill)
        self.assertIn('return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', beam_drill)
        self.assertIn('build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', beam_drill)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', beam_drill)
        self.assertIn('if(update && efficiency > 0){', beam_drill)
        # The row is a non-power row: the fold sets
        # shouldConsumePower=false when a REQUIRED row starves
        # (BuildingComp.java:1972, `if(cons != block.consPower
        # && result <= 0.0000001f){`), and the min fold takes
        # the liquid row when it is below the power row
        # (BuildingComp.java:1969-1976). The booster row folds
        # the optional pass (BuildingComp.java:1980-1981),
        # capped by minEfficiency (BuildingComp.java:1986);
        # boost() is optional(true, true) (Consume.java:33-35).
        self.assertIn('"is_power": false', beam_drill)
        self.assertIn('if(cons != block.consPower && result <= 0.0000001f){', beam_drill)
        self.assertIn('for(var cons : block.optionalConsumers){', beam_drill)
        self.assertIn('optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);', beam_drill)
        self.assertIn('return optional(true, true);', beam_drill)
        # The amounts are per def, from the catalog
        # consumeLiquid rows: plasma-bore hydrogen 0.25f/60f
        # booster (Blocks.java:3049, NO required row),
        # large-plasma-bore hydrogen 0.5f/60f REQUIRED
        # (Blocks.java:3064) + nitrogen 3f/60f booster
        # (Blocks.java:3065). The tick routes each catalog row
        # by its optional flag: required rows append to
        # required_results, booster rows to optional_results.
        self.assertIn('consumeLiquid(Liquids.hydrogen, 0.25f / 60f).boost();', beam_drill)
        self.assertIn('consumeLiquid(Liquids.hydrogen, 0.5f / 60f);', beam_drill)
        self.assertIn('consumeLiquid(Liquids.nitrogen, 3f / 60f).boost();', beam_drill)
        self.assertIn('block.properties.get("consumeLiquid", [])', beam_drill)
        self.assertIn('row.get("optional", false)', beam_drill)
        self.assertIn('optional_results', beam_drill)
        self.assertIn('{"has_liquid_row": false, "row": {}}', beam_drill)
        # The held amount reads through the shared liquid
        # module helper over the frame liquids key, with the
        # Fracker guard (SourceFrackerBuildState.gd:221); the
        # tick syncs the live sprite store into the frame
        # BEFORE the fold (Fracker:361), and the second pass
        # removes the consumed liquid for BOTH rows through the
        # same helper (PayloadLoader cache_sums precedent).
        self.assertIn('source_liquid_module_state.source_get_state', beam_drill)
        self.assertIn('frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})', beam_drill)
        self.assertIn('source_liquid_module_state.source_remove_state', beam_drill)
        self.assertIn('"liquids": {}', beam_drill)
        # The proof's keys drive the pure row (required starved
        # / cap at one) plus the live ticks (booster folds
        # optional only, optional capped by min, both rows fold
        # on the large def, the second pass removes both
        # liquids while running).
        proof = BEAM_DRILL_LIQUID_ROWS_PROOF.read_text(encoding='utf-8')
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
        scene = BEAM_DRILL_LIQUID_ROWS_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BeamDrillLiquidRowsProof.gd', scene)

    def test_reference_graph_and_actual_c07_beam_drill_liquid_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillLiquidRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_LIQUID_ROWS_PROOF ')]
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
