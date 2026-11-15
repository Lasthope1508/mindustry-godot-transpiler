import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FRACKER_STATE = ROOT / 'godot-mindustry/src/game/SourceFrackerBuildState.gd'
EFFICIENCY_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingEfficiencyState.gd'
LIQUID_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidModuleState.gd'
FRACKER_LIQUID_ROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerLiquidRowProof.gd'
FRACKER_LIQUID_ROW_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerLiquidRowProof.tscn'


class C07FrackerLiquidRowTests(unittest.TestCase):
    def test_c07_fracker_liquid_row_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2255']['godot_owner'], 'SourceFrackerBuildState.source_fracker_liquid_consumer_row_state')
        # N2153 proved the Fracker family's live power read,
        # N2207 proved the shouldConsume gate and N2224 proved
        # the updateTile advance -- but the port folded power
        # only, so an oil-extractor with an empty water store
        # still pumped at full efficiency: the required
        # ConsumeLiquid row (water 0.15f per frame, 9/s,
        # Blocks.java:2978) never joined the first pass.
        # N2255 is the liquid consumer row: the pure row
        # mirrors ConsumeLiquid.efficiency (ConsumeLiquid.
        # java:42-47, ed = edelta * efficiencyScale, 0f when
        # ed <= 1e-8, else min(liquid / (amount * ed *
        # multiplier), 1f)) with the first-pass efficiency
        # assumed 1f (BuildingComp.java:1965), folds into the
        # min efficiency with the power row (BuildingComp.
        # java:1969-1976, the shared fold sets
        # shouldConsumePower=false when a non-power row is
        # <= 1e-7), and the second pass removes amount *
        # edelta * multiplier from the folded efficiency
        # (ConsumeLiquid.java:37-39, only when update &&
        # efficiency > 0, BuildingComp.java:1999-2002). The
        # def sets no multiplier (Block.java:1127-1129
        # consumeLiquid builds a plain ConsumeLiquid, so the
        # default multiplier 1f, Consume.java:18, applies).
        # Two new result symbols: the row and its presence
        # flag (the N2153 power-row shape).
        self.assertEqual(
            ledger['N2255']['source_symbols'],
            [
                'source_fracker_liquid_consumer_row_state_result.row',
                'source_fracker_liquid_consumer_row_state_result.has_liquid_row',
            ],
        )
        for name in ledger['N2255']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumeLiquid.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_liquid_consumer_row_state')
        self.assertEqual(ledger['N2255']['runtime_proof'], '/root/C07FrackerLiquidRowProof')
        self.assertEqual(
            ledger['N2255']['tests'],
            [
                'test_c07_fracker_liquid_row_registration',
                'test_all_c07_fracker_liquid_row_input_evidence_is_exact',
                'test_fracker_liquid_consumer_row_state',
                'test_reference_graph_and_actual_c07_fracker_liquid_row',
            ],
        )
        self.assertTrue(ledger['N2255']['deferred_exprs'])
        # This slice resolves the water half of the N2153
        # Fracker item / liquid rows deferral -- that combined
        # entry is gone -- while the sand item row stays
        # deferred under its own narrower entry (no live
        # intake fills frame["items"] yet), the sand intake
        # entry stays (its cross-reference now points at the
        # new sand-row entry), and the water-attribute /
        # validTiles / boost fraction entry stays.
        self.assertFalse(any(entry.startswith('Fracker item / liquid rows (') for entry in ledger['N2255']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker item consumer row (') for entry in ledger['N2255']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker item intake (') for entry in ledger['N2255']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker water-attribute / validTiles / boost fraction rows (') for entry in ledger['N2255']['deferred_exprs']))

    def test_all_c07_fracker_liquid_row_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2255']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_liquid_consumer_row_state')
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
            'core/src/mindustry/world/blocks/production/Fracker.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2255']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_fracker_liquid_consumer_row_state(self):
        fracker = FRACKER_STATE.read_text(encoding='utf-8')
        # The pure liquid row lives on the Fracker build
        # state: ConsumeLiquid.efficiency (ConsumeLiquid.
        # java:42-47, `float ed = build.edelta() * build.
        # efficiencyScale();` / `if(ed <= 0.00000001f)
        # return 0f;` / `return Math.min(build.liquids.get(
        # liquid) / (amount * ed * multiplier.get(build)),
        # 1f);`) with the first-pass efficiency assumed 1f
        # (BuildingComp.java:1965, `efficiency =
        # optionalEfficiency = 1f;`), so edelta = delta() =
        # Time.delta * timeScale (BuildingComp.java:1922-1929).
        # Keep each Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this test).
        # The def sets no multiplier (Block.java:1127-1129
        # consumeLiquid builds a plain ConsumeLiquid), so the
        # default multiplier 1f (Consume.java:18, `public
        # Floatf<Building> multiplier = b -> 1f;`) applies.
        self.assertIn('static func source_fracker_liquid_consumer_row_state', fracker)
        self.assertIn('float ed = build.edelta() * build.efficiencyScale();', fracker)
        self.assertIn('if(ed <= 0.00000001f) return 0f;', fracker)
        self.assertIn('return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', fracker)
        self.assertIn('build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', fracker)
        self.assertIn('consumeLiquid(Liquids.water, 0.15f);', fracker)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', fracker)
        self.assertIn('efficiency = optionalEfficiency = 1f;', fracker)
        self.assertIn('return Time.delta * timeScale;', fracker)
        self.assertIn('return efficiency * delta();', fracker)
        self.assertIn('if(cons != block.consPower && result <= 0.0000001f){', fracker)
        self.assertIn('shouldConsumePower = false;', fracker)
        self.assertIn('if(update && efficiency > 0){', fracker)
        self.assertIn('for(var cons : block.updateConsumers){', fracker)
        self.assertIn('cons.update(self());', fracker)
        self.assertIn('add(liquid, Math.max(-amount, -liquids[liquid.id]));', fracker)
        # The row shape mirrors the power row (the N2153
        # shape): {"has_liquid_row": bool, "row": {"result":
        # float, "is_power": false}} -- is_power false, so the
        # shared fold sets shouldConsumePower=false when the
        # row is <= 1e-7 (SourceBuildingEfficiencyState.
        # gd:109-117). A def with no liquid consumer
        # contributes no row (the N2253 launch-pad
        # precedent): has_liquid_row false, row {}.
        self.assertIn('"is_power": false', fracker)
        self.assertIn('if not has_liquid_consumer:', fracker)
        self.assertIn('return {"has_liquid_row": false, "row": {}}', fracker)
        self.assertIn('"has_liquid_row": true', fracker)
        # The liquid amount reads through the shared liquid
        # module helper over the frame liquids key, with the
        # N2207 gate guard (frame has "liquids", id in
        # bounds; a liquid never added reads 0.0).
        self.assertIn('source_liquid_module_state.source_get_state(liquids, liquid_id)', fracker)
        self.assertIn('liquids.has("liquids") and liquid_id >= 0 and liquid_id < int(liquids["liquids"].size())', fracker)
        # The def constants: water (Blocks.java:2978) at
        # 0.15f PER FRAME (= 9/s), not /60f.
        self.assertIn('SOURCE_FRACKER_CONSUME_LIQUID := "water"', fracker)
        self.assertIn('SOURCE_FRACKER_CONSUME_LIQUID_AMOUNT := 0.15', fracker)
        # The tick wires the row into the first pass: the
        # frame liquids sync happens BEFORE the fold (the
        # live sprite-meta store is what the row reads), the
        # driver resolves the water id from the catalog with
        # the def constant, gates on the catalog liquid
        # consumer, and appends the row to required_results
        # (the fold takes the min over power + liquid, and
        # sets shouldConsumePower=false when the liquid row
        # is <= 1e-7). The source delta / timeScale are
        # computed once above the consumption block (the
        # liquid row's first pass needs them too) and reused
        # by the N2224 advance below.
        self.assertIn('frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})', fracker)
        self.assertIn('block.properties.has("consumeLiquid")', fracker)
        self.assertIn('source_fracker_liquid_consumer_row_state(frame, has_liquid_consumer, water_liquid_id, SOURCE_FRACKER_CONSUME_LIQUID_AMOUNT, source_delta, time_scale, float(frame.get("efficiency_scale", 1.0)))', fracker)
        self.assertIn('required_results.append(liquid_row.get("row", {}))', fracker)
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
        self.assertIn('source_liquid_module_state.source_remove_state(liquids_store, water_liquid_id, remove_amount, cache_sums)', fracker)
        self.assertIn('SOURCE_FRACKER_CONSUME_LIQUID_AMOUNT * folded_edelta', fracker)
        self.assertIn('float(frame.get("efficiency", 0.0)) * source_delta * time_scale', fracker)
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
        # The documented limits now record the liquid row as
        # live (def + amount + cites) and the remaining
        # deferrals (sand item row, fraction fill); the old
        # "power-only first pass" text is gone. The N2153
        # power row, the N2207 gate and the N2224 advance are
        # preserved.
        self.assertIn('liquid row live (N2255)', fracker)
        self.assertNotIn('power-only first pass', fracker)
        self.assertIn('shouldConsume gate live (N2207)', fracker)
        self.assertIn('updateTile advance live (N2224)', fracker)
        self.assertIn('static func source_fracker_power_status_row_state', fracker)
        self.assertIn('static func source_fracker_should_consume_state', fracker)
        self.assertIn('static func source_fracker_update_tile_advance_state', fracker)
        self.assertIn('static func source_fracker_tick_buildings_state', fracker)
        # The proof's keys drive the pure row (starved folds
        # below one, full caps at one, zero edelta zeroes,
        # no liquid zeroes) plus the live tick (efficiency
        # folds the liquid min, the second pass removes
        # water while running). Static checks: the proof
        # preloads the family state file that exists, and
        # the scene file references the proof script that
        # exists.
        proof = FRACKER_LIQUID_ROW_PROOF.read_text(encoding='utf-8')
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
        self.assertIn('preload("res://src/game/SourceFrackerBuildState.gd")', proof)
        self.assertTrue(FRACKER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = FRACKER_LIQUID_ROW_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07FrackerLiquidRowProof.gd', scene)
        self.assertIn('C07FrackerLiquidRowProof', scene)

    def test_reference_graph_and_actual_c07_fracker_liquid_row(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07FrackerLiquidRowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FRACKER_LIQUID_ROW_PROOF ')]
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
