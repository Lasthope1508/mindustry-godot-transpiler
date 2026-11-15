import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
IMPACT_REACTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceImpactReactorBuildState.gd'
IMPACT_REACTOR_LIQUID_ROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorLiquidRowProof.gd'
IMPACT_REACTOR_LIQUID_ROW_PROOF_TSCN = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorLiquidRowProof.tscn'


class C07ImpactReactorLiquidRowTests(unittest.TestCase):
    def test_c07_impact_reactor_liquid_row_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2254']['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_liquid_consumer_row_state')
        # N2182 wired the impact reactor's live power.status
        # read and N2192 advanced the warmup -- but the folded
        # efficiency was still the min over the power row only:
        # the reactor also consumes cryofluid 0.25f per frame
        # (Blocks.java:2644, `consumeLiquid(Liquids.cryofluid,
        # 0.25f);`), a REQUIRED non-optional consumer, so a
        # reactor with an empty cryofluid store still folded
        # efficiency 1.0 and warmed up as if fully supplied.
        # ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47,
        # `float ed = build.edelta() * build.efficiencyScale();`
        # with `if(ed <= 0.00000001f) return 0f;` and `return
        # Math.min(build.liquids.get(liquid) / (amount * ed *
        # multiplier.get(build)), 1f);`) folds into the same
        # first-pass min as the power row
        # (BuildingComp.java:1969-1976), and a starved row
        # stops the power draw (`if(cons != block.consPower &&
        # result <= 0.0000001f){`, BuildingComp.java:1972).
        # The amount is 0.25f PER FRAME (= 15/s, display
        # amount * 60f), not /60f, and the def sets no
        # multiplier, so the Consume.java:18 default
        # (`public Floatf<Building> multiplier = b -> 1f;`)
        # applies. N2254 is the liquid row: a pure row over
        # the live cryofluid store, folded by the shared
        # machinery, plus the second-pass removal
        # (`build.liquids.remove(liquid, amount *
        # build.edelta() * multiplier.get(build));`,
        # ConsumeLiquid.java:38, only when `update &&
        # efficiency > 0`, BuildingComp.java:1999). The item
        # row (blast-compound, Blocks.java:2643, burned on
        # the timer, ImpactReactor.java:91-92) is NOT this
        # slice -- it stays deferred. Two new result symbols:
        # the row and its presence flag.
        self.assertEqual(
            ledger['N2254']['source_symbols'],
            [
                'source_impact_reactor_liquid_consumer_row_state_result.row',
                'source_impact_reactor_liquid_consumer_row_state_result.has_liquid_row',
            ],
        )
        for name in ledger['N2254']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumeLiquid.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_impact_reactor_liquid_consumer_row_state_result.row': 'SourceImpactReactorBuildState.source_impact_reactor_liquid_consumer_row_state',
                    'source_impact_reactor_liquid_consumer_row_state_result.has_liquid_row': 'SourceImpactReactorBuildState.source_impact_reactor_liquid_consumer_row_state',
                }[name])
        self.assertEqual(ledger['N2254']['runtime_proof'], '/root/C07ImpactReactorLiquidRowProof')
        self.assertEqual(
            ledger['N2254']['tests'],
            [
                'test_c07_impact_reactor_liquid_row_registration',
                'test_all_c07_impact_reactor_liquid_row_input_evidence_is_exact',
                'test_impact_reactor_liquid_consumer_row_state',
                'test_reference_graph_and_actual_c07_impact_reactor_liquid_row',
            ],
        )
        self.assertTrue(ledger['N2254']['deferred_exprs'])

    def test_all_c07_impact_reactor_liquid_row_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2254']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_impact_reactor_liquid_consumer_row_state_result.row': 'SourceImpactReactorBuildState.source_impact_reactor_liquid_consumer_row_state',
                    'source_impact_reactor_liquid_consumer_row_state_result.has_liquid_row': 'SourceImpactReactorBuildState.source_impact_reactor_liquid_consumer_row_state',
                }[name])
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/consumers/ConsumeLiquid.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/consumers/Consume.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/power/ImpactReactor.java'),
            ('arc-upstream', 'arc-core/src/arc/util/Time.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2254']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_impact_reactor_liquid_consumer_row_state(self):
        impact_reactor = IMPACT_REACTOR_STATE.read_text(encoding='utf-8')
        # The pure liquid row lives on the impact-reactor build
        # state: ConsumeLiquid.efficiency
        # (ConsumeLiquid.java:42-47) over the live cryofluid
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
        # The single def consumes cryofluid 0.25f PER FRAME
        # (= 15/s), `consumeLiquid(Liquids.cryofluid,
        # 0.25f);` (Blocks.java:2644); the def sets no
        # multiplier, so the default `public Floatf<Building>
        # multiplier = b -> 1f;` (Consume.java:18) applies.
        # The item row (blast-compound, Blocks.java:2643,
        # burned on the timer, ImpactReactor.java:91-92,
        # `if(timer(timerUse, itemDuration / timeScale)){`
        # with `consume();`) is NOT this slice -- it stays
        # deferred, and the docstring says so.
        self.assertIn('float ed = build.edelta() * build.efficiencyScale();', impact_reactor)
        self.assertIn('if(ed <= 0.00000001f) return 0f;', impact_reactor)
        self.assertIn('return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', impact_reactor)
        self.assertIn('build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', impact_reactor)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', impact_reactor)
        self.assertIn('consumeLiquid(Liquids.cryofluid, 0.25f);', impact_reactor)
        self.assertIn('consumeItem(Items.blastCompound);', impact_reactor)
        self.assertIn('return efficiency * delta();', impact_reactor)
        self.assertIn('return Time.delta * timeScale;', impact_reactor)
        self.assertIn('if(update && efficiency > 0){', impact_reactor)
        self.assertIn('cons.update(self());', impact_reactor)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', impact_reactor)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', impact_reactor)
        self.assertIn('if(cons != block.consPower && result <= 0.0000001f){', impact_reactor)
        self.assertIn('if(timer(timerUse, itemDuration / timeScale)){', impact_reactor)
        self.assertIn('source_impact_reactor_liquid_consumer_row_state', impact_reactor)
        self.assertIn('SOURCE_IMPACT_REACTOR_LIQUID_AMOUNT', impact_reactor)
        self.assertIn('"liquids": {}', impact_reactor)
        self.assertIn('frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})', impact_reactor)
        self.assertIn('required_results.append(liquid_row.get("row", {}))', impact_reactor)
        self.assertIn('source_remove_state', impact_reactor)
        self.assertIn('"is_power": false', impact_reactor)
        self.assertIn('has_liquid_row', impact_reactor)
        # The proof's keys drive the pure row (starved / full /
        # zero-edelta / no-liquid) plus the live tick (the
        # fold follows the liquid min below the power row, and
        # the second pass removes liquid while running). The
        # proof preloads the driver it proves, and its scene
        # loads the proof script.
        proof = IMPACT_REACTOR_LIQUID_ROW_PROOF.read_text(encoding='utf-8')
        self.assertIn('res://src/game/SourceImpactReactorBuildState.gd', proof)
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
        tscn = IMPACT_REACTOR_LIQUID_ROW_PROOF_TSCN.read_text(encoding='utf-8')
        self.assertIn('C07ImpactReactorLiquidRowProof.gd', tscn)

    def test_reference_graph_and_actual_c07_impact_reactor_liquid_row(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ImpactReactorLiquidRowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_IMPACT_REACTOR_LIQUID_ROW_PROOF ')]
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
