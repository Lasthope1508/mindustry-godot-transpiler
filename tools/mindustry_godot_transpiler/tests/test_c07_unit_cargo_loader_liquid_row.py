import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_CARGO_LOADER_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitCargoLoaderBuildState.gd'
UNIT_CARGO_LOADER_LIQUID_ROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderLiquidRowProof.gd'
UNIT_CARGO_LOADER_LIQUID_ROW_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderLiquidRowProof.tscn'


class C07UnitCargoLoaderLiquidRowTests(unittest.TestCase):
    def test_c07_unit_cargo_loader_liquid_row_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2249']['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_liquid_consumer_row_state')
        # N2165 proved the unit-cargo-loader family's live power
        # read, N2211 the shouldConsume gate (return unit ==
        # null, INVERTED, no enabled term) and N2234 the
        # updateTile advance -- but the folded efficiency was
        # still the min over the *modeled* consumers (power
        # only): the def also consumes liquid nitrogen 10f/60f
        # (`consumeLiquid(Liquids.nitrogen, 10f / 60f);`,
        # Blocks.java:2279), the SECOND consumer, and Java folds
        # it in the same first pass (BuildingComp.java:1969-1976,
        # `for(var cons : block.nonOptionalConsumers){` /
        # `minEfficiency = Math.min(minEfficiency, result);`),
        # with a starved liquid row switching off power draw
        # (`if(cons != block.consPower && result <=
        # 0.0000001f){`, BuildingComp.java:1972). N2249 is the
        # required ConsumeLiquid row: a pure row mirroring
        # ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47,
        # `float ed = build.edelta() *
        # build.efficiencyScale();` / `if(ed <= 0.00000001f)
        # return 0f;` / the min-capped ratio), folded into the
        # first pass alongside the power row, with the
        # second-pass removal (ConsumeLiquid.java:37-39,
        # `build.liquids.remove(liquid, amount * build.edelta()
        # * multiplier.get(build));`, only when `update &&
        # efficiency > 0`, BuildingComp.java:1999) wired as a
        # direct removal after apply_update_consumption_state
        # (the AdjacentFactory updates-actor precedent does not
        # fit: this driver has no RuntimeConsumer actor
        # infrastructure). Two new result symbols: the row and
        # its presence flag.
        self.assertEqual(
            ledger['N2249']['source_symbols'],
            [
                'source_unit_cargo_loader_liquid_consumer_row_state_result.row',
                'source_unit_cargo_loader_liquid_consumer_row_state_result.has_liquid_row',
            ],
        )
        for name in ledger['N2249']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumeLiquid.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_liquid_consumer_row_state')
        self.assertEqual(ledger['N2249']['runtime_proof'], '/root/C07UnitCargoLoaderLiquidRowProof')
        self.assertEqual(
            ledger['N2249']['tests'],
            [
                'test_c07_unit_cargo_loader_liquid_row_registration',
                'test_all_c07_unit_cargo_loader_liquid_row_input_evidence_is_exact',
                'test_unit_cargo_loader_liquid_row_state',
                'test_reference_graph_and_actual_c07_unit_cargo_loader_liquid_row',
            ],
        )
        self.assertTrue(ledger['N2249']['deferred_exprs'])
        # This slice resolves the N2165 liquid consumer row
        # deferral, so the liquid row entry is gone from
        # DEFERRED -- and the build/display rows of the same
        # consumer take its place (presentation/stats, not tick
        # state). The other UnitCargoLoader deferrals stay:
        # canPlaceOn, bars, draw, read/write.
        self.assertFalse(any(entry.startswith('UnitCargoLoader liquid consumer row (') for entry in ledger['N2249']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader liquid consumer build/display rows (') for entry in ledger['N2249']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader canPlaceOn / Units.canCreate rows (') for entry in ledger['N2249']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader bar rows (') for entry in ledger['N2249']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader draw rows (') for entry in ledger['N2249']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader read/write rows (') for entry in ledger['N2249']['deferred_exprs']))

    def test_all_c07_unit_cargo_loader_liquid_row_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2249']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_liquid_consumer_row_state')
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/units/UnitCargoLoader.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2249']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_cargo_loader_liquid_row_state(self):
        unit_cargo_loader = UNIT_CARGO_LOADER_STATE.read_text(encoding='utf-8')
        # The pure liquid row lives on the unit-cargo-loader
        # build state: ConsumeLiquid.efficiency
        # (ConsumeLiquid.java:42-47, `float ed = build.edelta()
        # * build.efficiencyScale();` / `if(ed <= 0.00000001f)
        # return 0f;` / `return Math.min(build.liquids.get(
        # liquid) / (amount * ed * multiplier.get(build)),
        # 1f);`). In the first pass efficiency is assumed 1f
        # (BuildingComp.java:1964, `//assume efficiency is 1
        # for the calculations below`), so edelta() = delta()
        # = source_delta * time_scale (BuildingComp.java:
        # 1922-1929, `return Time.delta * timeScale;` /
        # `return efficiency * delta();`). The multiplier
        # defaults to 1f (Consume.java:18, `public
        # Floatf<Building> multiplier = b -> 1f;`) and the def
        # does NOT override it (Blocks.java:2270-2283 has no
        # multiplier call). The liquid amount reads through
        # the shared liquid module helper
        # (SourceLiquidModuleState.source_get_state) over the
        # frame liquids key, with the Fracker guard
        # (liquids.has("liquids") + bounds check); Java's
        # liquids.get returns 0.0 for a liquid never added
        # (LiquidModule.java:102-104, `return
        # liquids[liquid.id];`). Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a split
        # line fails this test). Cite corrections (all
        # verified by grep at this pin -- the scope brief
        # drifts on the ConsumeLiquid lines): update is :37-39
        # (not :40-43), efficiency is :42-47 (not :45-51).
        self.assertIn('static func source_unit_cargo_loader_liquid_consumer_row_state', unit_cargo_loader)
        self.assertIn('float ed = build.edelta() * build.efficiencyScale();', unit_cargo_loader)
        self.assertIn('if(ed <= 0.00000001f) return 0f;', unit_cargo_loader)
        self.assertIn('return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', unit_cargo_loader)
        self.assertIn('build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', unit_cargo_loader)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', unit_cargo_loader)
        self.assertIn('consumeLiquid(Liquids.nitrogen, 10f / 60f);', unit_cargo_loader)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', unit_cargo_loader)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', unit_cargo_loader)
        self.assertIn('if(cons != block.consPower && result <= 0.0000001f){', unit_cargo_loader)
        self.assertIn('if(update && efficiency > 0){', unit_cargo_loader)
        self.assertIn('boolean update = shouldConsume() && productionValid();', unit_cargo_loader)
        self.assertIn('return Time.delta * timeScale;', unit_cargo_loader)
        self.assertIn('return efficiency * delta();', unit_cargo_loader)
        self.assertIn('hasConsumers = consumers.length > 0;', unit_cargo_loader)
        self.assertIn('return liquids[liquid.id];', unit_cargo_loader)
        self.assertIn('add(liquid, Math.max(-amount, -liquids[liquid.id]));', unit_cargo_loader)
        self.assertIn('public class UnitCargoLoader extends Block{', unit_cargo_loader)
        self.assertIn('return unit == null;', unit_cargo_loader)
        # The row shape mirrors the power row: {"has_liquid_row":
        # bool, "row": {"result": float, "is_power": false}} --
        # is_power false so the shared fold sets
        # shouldConsumePower=false when the liquid row starves
        # (SourceBuildingEfficiencyState.gd:109-117). The def
        # values are driver constants (single def --
        # unit-cargo-loader): nitrogen at 10f/60f per frame
        # (Blocks.java:2279).
        self.assertIn('"is_power": false', unit_cargo_loader)
        self.assertIn('SOURCE_UNIT_CARGO_LOADER_CONSUMED_LIQUID := "nitrogen"', unit_cargo_loader)
        self.assertIn('SOURCE_UNIT_CARGO_LOADER_LIQUID_AMOUNT := 10.0 / 60.0', unit_cargo_loader)
        # The driver wires the row into the live tick: the frame
        # liquids sync from the sprite meta BEFORE the fold (the
        # Fracker:327 precedent), the liquid row appends to
        # required_results when the block has a consumeLiquid
        # property, the machinery gate widens to (power or
        # liquid) because hasConsumers counts ALL consumers
        # (Block.java:1449), and the second-pass removal runs
        # after apply_update_consumption_state under the same
        # guard as Java (`update && efficiency > 0`,
        # BuildingComp.java:1999) with edelta from the FOLDED
        # efficiency -- through the shared
        # source_remove_state (the PayloadLoader cache_sums
        # precedent), which caps removal so the store never
        # goes negative (LiquidModule.java:125-128).
        self.assertIn('block.properties.has("consumeLiquid")', unit_cargo_loader)
        self.assertIn('SOURCE_BUILDING_LIQUIDS_META_KEY', unit_cargo_loader)
        self.assertIn('source_get_state(liquids, liquid_id)', unit_cargo_loader)
        self.assertIn('source_remove_state(', unit_cargo_loader)
        self.assertIn('cache_sums', unit_cargo_loader)
        self.assertIn('source_unit_cargo_loader_liquid_consumer_row_state(frame, has_liquid_consumer, nitrogen_id, SOURCE_UNIT_CARGO_LOADER_LIQUID_AMOUNT, source_delta, time_scale', unit_cargo_loader)
        # The fresh frame binds the liquids key (the Fracker
        # precedent); the tick syncs the live store into it
        # every tick.
        self.assertIn('"liquids": {}', unit_cargo_loader)
        # The documented limits now record the liquid row as
        # live (N2249) and the remaining deferrals (build/
        # display rows, canPlaceOn, bars, draw, read/write);
        # the shouldConsume gate stays live (N2211), the
        # updateTile advance stays live (N2234) and the N2165
        # power row is preserved.
        self.assertIn('liquid row live (N2249)', unit_cargo_loader)
        self.assertNotIn('the liquid row waits for its own slice', unit_cargo_loader)
        self.assertNotIn('the liquid consumer row waits for its own slice', unit_cargo_loader)
        self.assertIn('shouldConsume gate live (N2211)', unit_cargo_loader)
        self.assertIn('updateTile advance live (N2234)', unit_cargo_loader)
        self.assertIn('static func source_unit_cargo_loader_power_status_row_state', unit_cargo_loader)
        self.assertIn('static func source_unit_cargo_loader_should_consume_state', unit_cargo_loader)
        self.assertIn('static func source_unit_cargo_loader_update_tile_advance_state', unit_cargo_loader)
        # The proof's keys drive the pure row (starved folds
        # below one, full caps at one, zero edelta zeroes, no
        # liquid zeroes) plus the live tick (the fold follows
        # the liquid min below the power row, and a running
        # tick removes nitrogen at amount * folded edelta).
        proof = UNIT_CARGO_LOADER_LIQUID_ROW_PROOF.read_text(encoding='utf-8')
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
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceUnitCargoLoaderBuildState.gd")', proof)
        self.assertTrue(UNIT_CARGO_LOADER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = UNIT_CARGO_LOADER_LIQUID_ROW_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07UnitCargoLoaderLiquidRowProof.gd', scene)
        self.assertIn('C07UnitCargoLoaderLiquidRowProof', scene)

    def test_reference_graph_and_actual_c07_unit_cargo_loader_liquid_row(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitCargoLoaderLiquidRowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_CARGO_LOADER_LIQUID_ROW_PROOF ')]
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
