import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_OZONE_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerOzoneConsumeProof.gd'


class C07RepairTowerOzoneConsumeTests(unittest.TestCase):
    def test_c07_repair_tower_ozone_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2229']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_ozone_row_state')
        # N2228 did the heal advance (RepairTower.java:69-85) and
        # N2153 the power row; this slice is the ozone liquid
        # consumer (`consumeLiquid(Liquids.ozone, 3f / 60f);`,
        # Blocks.java:6583): the ConsumeLiquid.efficiency fold
        # (ConsumeLiquid.java:42-48) into the first pass plus the
        # ConsumeLiquid.update drain (ConsumeLiquid.java:37-38)
        # in the second pass (BuildingComp.java:1969-1976 /
        # 1997-2000). Two pure functions on
        # SourceRepairTowerBuildState.gd: the row function, whose
        # row appends to required_results beside the power row
        # before update_consumption_state, and the consume
        # function, whose drain runs after
        # apply_update_consumption_state and before the refresh /
        # heal (Java runs updateConsumption() before
        # updateTile(), BuildingComp.java:2274/2277). Four new
        # result symbols: has_ozone_row + row + ozone_drained +
        # liquids.
        self.assertEqual(
            ledger['N2229']['source_symbols'],
            [
                'source_repair_tower_ozone_row_state_result.has_ozone_row',
                'source_repair_tower_ozone_row_state_result.row',
                'source_repair_tower_ozone_consume_state_result.ozone_drained',
                'source_repair_tower_ozone_consume_state_result.liquids',
            ],
        )
        owners = {
            'source_repair_tower_ozone_row_state_result.has_ozone_row': 'SourceRepairTowerBuildState.source_repair_tower_ozone_row_state',
            'source_repair_tower_ozone_row_state_result.row': 'SourceRepairTowerBuildState.source_repair_tower_ozone_row_state',
            'source_repair_tower_ozone_consume_state_result.ozone_drained': 'SourceRepairTowerBuildState.source_repair_tower_ozone_consume_state',
            'source_repair_tower_ozone_consume_state_result.liquids': 'SourceRepairTowerBuildState.source_repair_tower_ozone_consume_state',
        }
        for name in ledger['N2229']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTower.java',
                    'core/src/mindustry/world/consumers/ConsumeLiquid.java',
                    'core/src/mindustry/world/consumers/Consume.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/modules/LiquidModule.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], owners[name])
        self.assertEqual(ledger['N2229']['runtime_proof'], '/root/C07RepairTowerOzoneConsumeProof')
        self.assertEqual(
            ledger['N2229']['tests'],
            [
                'test_c07_repair_tower_ozone_consume_registration',
                'test_all_c07_repair_tower_ozone_consume_input_evidence_is_exact',
                'test_repair_tower_ozone_consume_state',
                'test_reference_graph_and_actual_c07_repair_tower_ozone_consume',
            ],
        )
        self.assertTrue(ledger['N2229']['deferred_exprs'])

    def test_all_c07_repair_tower_ozone_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        owners = {
            'source_repair_tower_ozone_row_state_result.has_ozone_row': 'SourceRepairTowerBuildState.source_repair_tower_ozone_row_state',
            'source_repair_tower_ozone_row_state_result.row': 'SourceRepairTowerBuildState.source_repair_tower_ozone_row_state',
            'source_repair_tower_ozone_consume_state_result.ozone_drained': 'SourceRepairTowerBuildState.source_repair_tower_ozone_consume_state',
            'source_repair_tower_ozone_consume_state_result.liquids': 'SourceRepairTowerBuildState.source_repair_tower_ozone_consume_state',
        }
        for name in ledger['N2229']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], owners[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2229']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_ozone_consume_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # The ozone consumer (ConsumeLiquid.java:42-48 /
        # 37-38, per-def `consumeLiquid(Liquids.ozone, 3f /
        # 60f);`, Blocks.java:6583, amount 0.05f/tick): the row
        # folds `float ed = build.edelta() *
        # build.efficiencyScale();` (:43) with the first-pass
        # efficiency assumed 1 (`efficiency =
        # optionalEfficiency = 1f;`, BuildingComp.java:1966,
        # `//assume efficiency is 1 for the calculations
        # below`, :1967), so ed = 1.0 * delta *
        # efficiency_scale (efficiencyScale() defaults 1f,
        # BuildingComp.java:1940-1942); the guard `if(ed <=
        # 0.00000001f) return 0f;` (:44) is
        # CONSUME_EFFICIENCY_EPSILON (SourceConsumerDefaults.gd:4);
        # the fold is `return Math.min(build.liquids.get(liquid)
        # / (amount * ed * multiplier.get(build)), 1f);` (:47)
        # with the multiplier default 1f (`public Floatf<Building>
        # multiplier = b -> 1f;`, Consume.java:18). The row goes
        # through the generic helper
        # SourceConsumeLiquidState.efficiency_state (the N2007
        # drill precedent -- it mirrors ConsumeLiquid.efficiency
        # exactly, including the epsilon guard and the cap at 1);
        # RED decision: the drain does NOT use the generic
        # update_state, because that helper takes a numeric
        # liquid_id the frame never carries (the frame keys
        # liquids by slug, "ozone"), so the drain inlines the 3
        # lines like the N2187 cryofluid precedent. The drain is
        # `build.liquids.remove(liquid, amount *
        # build.edelta() * multiplier.get(build));` (:38) with
        # edelta = efficiency * delta (BuildingComp.java:1927-1928,
        # `return efficiency * delta();`), i.e. 0.05 * folded
        # efficiency * delta per tick, clamped at the stock
        # (`//cap to prevent negative removal`,
        # LiquidModule.java:125-127, `add(liquid,
        # Math.max(-amount, -liquids[liquid.id]));`), and runs
        # only in the second pass (`if(update && efficiency >
        # 0){` / `for(var cons : block.updateConsumers){` /
        # `cons.update(self());`, BuildingComp.java:1997-2000;
        # `public boolean update = true;`, Consume.java:16, so
        # ConsumeLiquid is in updateConsumers). RED decision
        # (the N2191 absent-observation precedent, settled):
        # absent key "ozone" in frame["liquids"] means NO
        # observation, NOT an empty tank -- has_ozone_row false,
        # the power-only fold is kept (folding absent to 0
        # would zero efficiency for every live tower), drain 0
        # and the dict unchanged; a present {"ozone": 0.0}
        # (observed empty tank) folds to result 0.0. A non-power
        # row <= 1e-7 clears should_consume_power (`if(cons !=
        # block.consPower && result <= 0.0000001f){` /
        # `shouldConsumePower = false;`, BuildingComp.java:1972-1974,
        # mirrored by
        # update_consumption_non_optional_pass_state). delta is
        # the driver seconds (the N2228 precedent -- no separate
        # time_scale, unlike N2187; timeScale != 1 stays
        # deferred). The driver calls the row before
        # update_consumption_state and the consume after
        # apply_update_consumption_state, before the refresh /
        # heal (Java: updateConsumption() :2274 runs before
        # updateTile() :2277).
        self.assertIn('static func source_repair_tower_ozone_row_state(frame: Dictionary, delta: float) -> Dictionary:', repair_tower)
        self.assertIn('var liquids: Variant = frame.get("liquids", null)', repair_tower)
        self.assertIn('if not (liquids is Dictionary) or not liquids.has("ozone"):', repair_tower)
        self.assertIn('return {"has_ozone_row": false, "row": {}}', repair_tower)
        self.assertIn('var stock: float = float(liquids.get("ozone", 0.0))', repair_tower)
        self.assertIn('var efficiency_scale: float = float(frame.get("efficiency_scale", 1.0))', repair_tower)
        self.assertIn('var result: float = float(SourceConsumeLiquidState.efficiency_state(stock, 0.05, delta, efficiency_scale, 1.0).get("efficiency", 0.0))', repair_tower)
        self.assertIn('return {"has_ozone_row": true, "row": {"result": result, "is_power": false}}', repair_tower)
        self.assertIn('static func source_repair_tower_ozone_consume_state(frame: Dictionary, delta: float) -> Dictionary:', repair_tower)
        self.assertIn('var efficiency: float = float(frame.get("efficiency", 1.0))', repair_tower)
        self.assertIn('var enabled: bool = bool(frame.get("enabled", true))', repair_tower)
        self.assertIn('var liquids_raw: Variant = frame.get("liquids", {})', repair_tower)
        self.assertIn('var liquids: Dictionary = liquids_raw.duplicate() if liquids_raw is Dictionary else {}', repair_tower)
        self.assertIn('var ozone_drained: float = 0.0', repair_tower)
        self.assertIn('if enabled and efficiency > 0.0 and liquids.has("ozone"):', repair_tower)
        self.assertIn('var drain: float = 0.05 * efficiency * delta', repair_tower)
        self.assertIn('var tank: float = float(liquids.get("ozone", 0.0))', repair_tower)
        self.assertIn('ozone_drained = minf(drain, tank)', repair_tower)
        self.assertIn('liquids["ozone"] = tank - ozone_drained', repair_tower)
        self.assertIn('return {"ozone_drained": ozone_drained, "liquids": liquids}', repair_tower)
        self.assertIn('var ozone_row: Dictionary = source_repair_tower_ozone_row_state(frame, seconds)', repair_tower)
        self.assertIn('if bool(ozone_row.get("has_ozone_row", false)):', repair_tower)
        self.assertIn('required_results.append(ozone_row.get("row", {}))', repair_tower)
        self.assertIn('if not (frame.get("liquids") is Dictionary):', repair_tower)
        self.assertIn('var ozone_consume: Dictionary = source_repair_tower_ozone_consume_state(frame, seconds)', repair_tower)
        self.assertIn('frame["ozone_drained"] = ozone_consume.get("ozone_drained", 0.0)', repair_tower)
        self.assertIn('frame["liquids"] = ozone_consume.get("liquids", {})', repair_tower)
        for expr in [
            'consumeLiquid(Liquids.ozone, 3f / 60f);',
            'build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));',
            'float ed = build.edelta() * build.efficiencyScale();',
            'if(ed <= 0.00000001f) return 0f;',
            'return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);',
            'public boolean update = true;',
            'public Floatf<Building> multiplier = b -> 1f;',
            'efficiency = optionalEfficiency = 1f;',
            'if(cons != block.consPower && result <= 0.0000001f){',
            'minEfficiency = Math.min(minEfficiency, result);',
            'if(update && efficiency > 0){',
            'return efficiency * delta();',
            '//cap to prevent negative removal',
            'add(liquid, Math.max(-amount, -liquids[liquid.id]));',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_tower)
        # The proof's keys drive the two pure functions
        # directly with synthetic frames (the N2187 precedent
        # -- the driver tick lines land with GREEN): full stock
        # folds to 1.0 / partial stock caps the fold / absent
        # ozone keeps the power-only fold / drain per tick while
        # efficiency is positive / no drain at zero efficiency /
        # drain clamps at the stock / an observed empty tank
        # clears should_consume_power. Per-def amount 0.05f
        # (Blocks.java:6583); delta 1/60 is one tick, so one
        # tick at efficiency 1.0 drains 0.05 * 1.0 * (1/60) =
        # 0.0008333 and a 0.0004 stock folds to 0.48.
        proof = REPAIR_TOWER_OZONE_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'ozone_row_full_stock_efficiency_one',
            'ozone_row_partial_stock_caps_efficiency',
            'ozone_row_absent_preserves_power_only',
            'ozone_drains_per_tick_while_efficiency_positive',
            'no_drain_when_efficiency_zero',
            'drain_clamps_at_stock',
            'ozone_empty_clears_should_consume_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_tower_ozone_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTowerOzoneConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TOWER_OZONE_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ozone_row_full_stock_efficiency_one',
            'ozone_row_partial_stock_caps_efficiency',
            'ozone_row_absent_preserves_power_only',
            'ozone_drains_per_tick_while_efficiency_positive',
            'no_drain_when_efficiency_zero',
            'drain_clamps_at_stock',
            'ozone_empty_clears_should_consume_power',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
