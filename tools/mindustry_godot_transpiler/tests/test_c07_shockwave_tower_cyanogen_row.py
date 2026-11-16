import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
EFFICIENCY_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingEfficiencyState.gd'
LIQUID_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidModuleState.gd'
SHOCKWAVE_TOWER_CYANOGEN_ROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerCyanogenRowProof.gd'
SHOCKWAVE_TOWER_CYANOGEN_ROW_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerCyanogenRowProof.tscn'


class C07ShockwaveTowerCyanogenRowTests(unittest.TestCase):
    def test_c07_shockwave_tower_cyanogen_row_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2331']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_liquid_consumer_row_state')
        # N2177 proved the ShockwaveTower family's live power
        # read, N2187 the shouldConsume gate, N2247 the
        # updateTile advance, N2318 the timerCheck cadence and
        # N2327 the live bullet scan -- but the port folded
        # power only, so a shockwave tower with an empty
        # cyanogen store still charged at full efficiency: the
        # required ConsumeLiquids row (cyanogen 1.5f/60f per
        # frame = 0.025, Blocks.java:2041) never joined the
        # first pass. N2331 is the liquid consumer row: the
        # pure row mirrors ConsumeLiquids.efficiency
        # (ConsumeLiquids.java:52-60, ed = edelta *
        # efficiencyScale, 0f when ed <= 1e-8, else the min
        # over the stacks of held / (amount * ed * mult),
        # starting from 1f -- the single-stack def collapses
        # to min(cyanogen / (0.025 * ed * mult), 1f)) with
        # the first-pass efficiency assumed 1f
        # (BuildingComp.java:1965), folds into the min
        # efficiency with the power row (BuildingComp.
        # java:1969-1976, the shared fold sets
        # shouldConsumePower=false when a non-power row is
        # <= 1e-7), and the second pass removes amount *
        # edelta * multiplier from the folded efficiency
        # (ConsumeLiquids.update, ConsumeLiquids.java:44-49,
        # only when update && efficiency > 0, BuildingComp.
        # java:1999-2002). ConsumeLiquids extends Consume
        # DIRECTLY (ConsumeLiquids.java:11) -- it is NOT a
        # ConsumeLiquidBase, so no ConsumeLiquid pattern is
        # reused blindly; the def sets no multiplier (Block.
        # java:1131-1132 consumeLiquids builds a plain
        # ConsumeLiquids, so the default multiplier 1f,
        # Consume.java:18, applies) and no .boost(), so the
        # row is REQUIRED. Two new result symbols: the row
        # and its presence flag (the N2255 Fracker shape).
        self.assertEqual(
            ledger['N2331']['source_symbols'],
            [
                'source_shockwave_tower_liquid_consumer_row_state_result.row',
                'source_shockwave_tower_liquid_consumer_row_state_result.has_liquid_row',
            ],
        )
        for name in ledger['N2331']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumeLiquids.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_liquid_consumer_row_state')
        self.assertEqual(ledger['N2331']['runtime_proof'], '/root/C07ShockwaveTowerCyanogenRowProof')
        self.assertEqual(
            ledger['N2331']['tests'],
            [
                'test_c07_shockwave_tower_cyanogen_row_registration',
                'test_all_c07_shockwave_tower_cyanogen_row_input_evidence_is_exact',
                'test_shockwave_tower_liquid_consumer_row_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_cyanogen_row',
            ],
        )
        self.assertTrue(ledger['N2331']['deferred_exprs'])
        # The cyanogen row is live now, so the liquid-row
        # entry is gone; the sense/warmup, draw and live
        # bullet-query entries stay; four new deferrals
        # joined at N2331: the live cyanogen intake, the
        # catalog consumeLiquids capture, the old-proof
        # cyanogen seeding (N2177/N2187/N2318/N2327 live
        # keys go stale without it) and the ConsumeLiquids
        # build/display rows.
        self.assertFalse(any(entry.startswith('ShockwaveTower liquid consumer row (') for entry in ledger['N2331']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower sense / warmup rows (') for entry in ledger['N2331']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower live cyanogen intake (') for entry in ledger['N2331']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower catalog consumeLiquids capture (') for entry in ledger['N2331']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower old-proof cyanogen seeding (') for entry in ledger['N2331']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower ConsumeLiquids build/display rows (') for entry in ledger['N2331']['deferred_exprs']))

    def test_all_c07_shockwave_tower_cyanogen_row_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2331']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_liquid_consumer_row_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/world/consumers/ConsumeLiquids.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2331']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_liquid_consumer_row_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The pure liquid row lives on the ShockwaveTower
        # build state: ConsumeLiquids.efficiency
        # (ConsumeLiquids.java:52-60, `float ed = build.
        # edelta() * build.efficiencyScale();` / `if(ed <=
        # 0.00000001f) return 0f;` / `float min = 1f;` /
        # `min = Math.min(build.liquids.get(stack.liquid) /
        # (stack.amount * ed * mult), min);` / `return min;`)
        # with the first-pass efficiency assumed 1f
        # (BuildingComp.java:1965, `efficiency =
        # optionalEfficiency = 1f;`), so edelta = delta() =
        # Time.delta * timeScale (BuildingComp.java:1922-1929).
        # Keep each Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this test).
        # ConsumeLiquids extends Consume DIRECTLY
        # (ConsumeLiquids.java:11, `public class
        # ConsumeLiquids extends Consume{`) -- NOT
        # ConsumeLiquidBase -- and the single-stack def
        # collapses the min loop to min(cyanogen / (0.025 *
        # ed * mult), 1f). The def sets no multiplier
        # (Block.java:1131-1132 consumeLiquids builds a plain
        # ConsumeLiquids), so the default multiplier 1f
        # (Consume.java:18, `public Floatf<Building>
        # multiplier = b -> 1f;`) applies. The def calls no
        # .boost(), so the row is REQUIRED (non-optional).
        self.assertIn('static func source_shockwave_tower_liquid_consumer_row_state', shockwave_tower)
        self.assertIn('public class ConsumeLiquids extends Consume{', shockwave_tower)
        self.assertIn('float ed = build.edelta() * build.efficiencyScale();', shockwave_tower)
        self.assertIn('if(ed <= 0.00000001f) return 0f;', shockwave_tower)
        self.assertIn('float min = 1f;', shockwave_tower)
        self.assertIn('min = Math.min(build.liquids.get(stack.liquid) / (stack.amount * ed * mult), min);', shockwave_tower)
        self.assertIn('build.liquids.remove(stack.liquid, stack.amount * build.edelta() * mult);', shockwave_tower)
        self.assertIn('consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));', shockwave_tower)
        self.assertIn('public ConsumeLiquids consumeLiquids(LiquidStack... stacks){', shockwave_tower)
        self.assertIn('return consume(new ConsumeLiquids(stacks));', shockwave_tower)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', shockwave_tower)
        self.assertIn('efficiency = optionalEfficiency = 1f;', shockwave_tower)
        self.assertIn('return Time.delta * timeScale;', shockwave_tower)
        self.assertIn('return efficiency * delta();', shockwave_tower)
        self.assertIn('if(cons != block.consPower && result <= 0.0000001f){', shockwave_tower)
        self.assertIn('shouldConsumePower = false;', shockwave_tower)
        self.assertIn('if(update && efficiency > 0){', shockwave_tower)
        self.assertIn('for(var cons : block.updateConsumers){', shockwave_tower)
        self.assertIn('cons.update(self());', shockwave_tower)
        self.assertIn('add(liquid, Math.max(-amount, -liquids[liquid.id]));', shockwave_tower)
        # The row shape mirrors the power row (the N2153
        # shape): {"has_liquid_row": bool, "row": {"result":
        # float, "is_power": false}} -- is_power false, so the
        # shared fold sets shouldConsumePower=false when the
        # row is <= 1e-7 (SourceBuildingEfficiencyState.
        # gd:109-117). A def with no liquid consumer
        # contributes no row (the N2253 launch-pad
        # precedent): has_liquid_row false, row {}.
        self.assertIn('"is_power": false', shockwave_tower)
        self.assertIn('if not has_liquid_consumer:', shockwave_tower)
        self.assertIn('return {"has_liquid_row": false, "row": {}}', shockwave_tower)
        self.assertIn('"has_liquid_row": true', shockwave_tower)
        # The liquid amount reads through the shared liquid
        # module helper over the frame liquids key, with the
        # Fracker gate guard (frame has "liquids", id in
        # bounds -- SourceFrackerBuildState.gd:279, the guard
        # inside source_fracker_liquid_consumer_row_state;
        # the brief's :221 cite is a docstring comment line,
        # verified by grep; a liquid never added reads 0.0).
        self.assertIn('source_liquid_module_state.source_get_state(liquids, liquid_id)', shockwave_tower)
        self.assertIn('liquids.has("liquids") and liquid_id >= 0 and liquid_id < int(liquids["liquids"].size())', shockwave_tower)
        # The def constants: cyanogen (Blocks.java:2041) at
        # 1.5f/60f = 0.025 per frame.
        self.assertIn('SOURCE_SHOCKWAVE_TOWER_CYANOGEN_LIQUID := "cyanogen"', shockwave_tower)
        self.assertIn('SOURCE_SHOCKWAVE_TOWER_CYANOGEN_AMOUNT := 1.5 / 60.0', shockwave_tower)
        # The tick wires the row into the first pass: the
        # frame liquids sync happens BEFORE the fold (the
        # live sprite-meta store is what the row reads), with
        # a lazy init when the sprite lacks a store -- PortGame
        # never initializes one for shockwave-tower (its
        # record_placed_block only binds liquid consumers for
        # blocks with a catalog consumeLiquid property, and
        # the catalog carries no consumeLiquids property for
        # shockwave-tower), so the tick initializes it itself
        # (the LiquidBridge precedent). The driver resolves
        # the cyanogen id from the catalog with the def
        # constant, folds the row with the def amount (the
        # single def always has the row -- the RegenProjector
        # N2260 precedent -- so has_liquid_consumer is the
        # true literal, not a catalog gate), and appends the
        # row to required_results (the fold takes the min
        # over power + cyanogen, and sets
        # shouldConsumePower=false when the liquid row is
        # <= 1e-7).
        self.assertIn('frame["liquids"] = liquids_store', shockwave_tower)
        self.assertIn('source_initialize_building_liquids_state(sprite, true, catalog)', shockwave_tower)
        self.assertIn('source_shockwave_tower_liquid_consumer_row_state(frame, true, cyanogen_liquid_id, SOURCE_SHOCKWAVE_TOWER_CYANOGEN_AMOUNT, tick_source_delta, tick_time_scale, float(frame.get("efficiency_scale", 1.0)))', shockwave_tower)
        self.assertIn('required_results.append(liquid_row.get("row", {}))', shockwave_tower)
        # The second pass is a DIRECT removal after
        # apply_update_consumption_state, not the
        # AdjacentFactory updates array: that precedent
        # passes bound RuntimeConsumer actors with
        # update(self_state) methods (N2115/N2116), and this
        # driver is pure-function based with no consumer
        # actors. The removal runs only when update &&
        # efficiency > 0 (BuildingComp.java:1999), with
        # edelta from the FOLDED efficiency (not the
        # first-pass 1f assumption), through the shared
        # liquid module helper (the PayloadLoader
        # source_remove_state precedent), which clamps
        # exactly like Java's LiquidModule.remove
        # (LiquidModule.java:125-128).
        self.assertIn('source_liquid_module_state.source_remove_state(liquids_store, cyanogen_liquid_id, remove_amount, cache_sums)', shockwave_tower)
        self.assertIn('SOURCE_SHOCKWAVE_TOWER_CYANOGEN_AMOUNT * folded_edelta', shockwave_tower)
        self.assertIn('float(frame.get("efficiency", 0.0)) * tick_source_delta * tick_time_scale', shockwave_tower)
        # The shared fold (already live, SourceBuilding
        # EfficiencyState): a non-power row <= 1e-7 stops
        # power draw, and the fold takes the min over the
        # required rows.
        efficiency = EFFICIENCY_STATE.read_text(encoding='utf-8')
        self.assertIn('if not bool(consumer.get("is_power", false)) and result <= 0.0000001:', efficiency)
        self.assertIn('min_efficiency = min(min_efficiency, result)', efficiency)
        # The shared liquid module helper exists: get reads
        # the indexed amount, remove clamps to the held
        # amount (the port of LiquidModule.remove).
        liquid_module = LIQUID_MODULE_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_get_state(self_state: Dictionary, liquid_id: int) -> Dictionary:', liquid_module)
        self.assertIn('static func source_remove_state(self_state: Dictionary, liquid_id: int, amount: float, cache_sums: Array) -> Dictionary:', liquid_module)
        # The documented limits now record the cyanogen row
        # as live (N2331) and the remaining deferral is the
        # live bullet query, not the liquid row; the old
        # "power-only first pass" text is gone. The N2187
        # gate, the N2247 advance, the N2318 cadence and the
        # N2327 scan are preserved.
        self.assertIn('cyanogen row live (N2331)', shockwave_tower)
        self.assertNotIn('power-only first pass', shockwave_tower)
        self.assertIn('shouldConsume gate live (N2187)', shockwave_tower)
        self.assertIn('updateTile advance live (N2247)', shockwave_tower)
        self.assertIn('timerCheck cadence live (N2318)', shockwave_tower)
        self.assertIn('live bullet scan is live (N2327)', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_power_status_row_state', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_should_consume_state', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_update_tile_advance_state', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_timer_check_state', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_supplied_bullets_state', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_tick_buildings_state', shockwave_tower)
        # The N2318-pinned timer call is UNCHANGED (the
        # liquid row computes its own tick delta / time
        # scale locals; it does not rewrite the timer call).
        self.assertIn('source_shockwave_tower_timer_check_state(float(frame.get("timer_check_elapsed", 0.0)), source_placed_block_state.game_source_delta(game, seconds), source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game)), SOURCE_SHOCKWAVE_TOWER_CHECK_INTERVAL)', shockwave_tower)
        # The proof's keys drive the pure row (starved folds
        # the cyanogen ratio, zero cyanogen zeroes, full caps
        # at one) plus the live tick (efficiency folds the
        # liquid min, the second pass removes cyanogen while
        # running) and the power row (unchanged). Static
        # checks: the proof preloads the family state file
        # that exists, and the scene file references the
        # proof script that exists.
        proof = SHOCKWAVE_TOWER_CYANOGEN_ROW_PROOF.read_text(encoding='utf-8')
        for key in [
            'row_folds_cyanogen_amount',
            'row_zero_when_starved',
            'row_full_when_satisfied',
            'live_tick_folds_liquid_row',
            'second_pass_removes_cyanogen',
            'power_row_unchanged',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceShockwaveTowerBuildState.gd")', proof)
        self.assertIn('shockwave_tower_build_state.source_shockwave_tower_liquid_consumer_row_state(', proof)
        self.assertIn('shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(SHOCKWAVE_TOWER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = SHOCKWAVE_TOWER_CYANOGEN_ROW_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ShockwaveTowerCyanogenRowProof.gd', scene)
        self.assertIn('C07ShockwaveTowerCyanogenRowProof', scene)

    def test_reference_graph_and_actual_c07_shockwave_tower_cyanogen_row(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerCyanogenRowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_CYANOGEN_ROW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'row_folds_cyanogen_amount',
            'row_zero_when_starved',
            'row_full_when_satisfied',
            'live_tick_folds_liquid_row',
            'second_pass_removes_cyanogen',
            'power_row_unchanged',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
