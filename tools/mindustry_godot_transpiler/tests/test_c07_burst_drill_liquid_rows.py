import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_LIQUID_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillLiquidRowsProof.gd'


class C07BurstDrillLiquidRowsTests(unittest.TestCase):
    def test_c07_burst_drill_liquid_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2296']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_liquid_rows_state')
        # The BurstDrill liquid rows are the two ConsumeLiquid
        # rows each def carries (Blocks.java:3089-3090 impact,
        # :3119-3120 eruption): one required liquid and one
        # booster liquid (.boost() makes it optional, Consume.
        # java:33-35, `public Consume boost(){` with `return
        # optional(true, true);`). BuildingComp.updateConsumption
        # (BuildingComp.java:1943-2004) folds the required row
        # into the first pass (BuildingComp.java:1969-1977,
        # `for(var cons : block.nonOptionalConsumers){` /
        # `minEfficiency = Math.min(minEfficiency, result);`)
        # and the booster row into the optional pass
        # (BuildingComp.java:1980-1982, `for(var cons : block.
        # optionalConsumers){` /
        # `optionalEfficiency = Math.min(optionalEfficiency,
        # cons.efficiency(self()));`), then assigns
        # `efficiency = minEfficiency;` /
        # `optionalEfficiency = Math.min(optionalEfficiency,
        # minEfficiency);` (BuildingComp.java:1985-1986) and
        # runs the second pass (`if(update && efficiency > 0){`
        # / `for(var cons : block.updateConsumers){`,
        # BuildingComp.java:1999-2000). Each row's efficiency
        # is ConsumeLiquid.efficiency (ConsumeLiquid.java:42-46,
        # `float ed = build.edelta() * build.efficiencyScale();`
        # / `if(ed <= 0.00000001f) return 0f;` /
        # `return Math.min(build.liquids.get(liquid) / (amount *
        # ed * multiplier.get(build)), 1f);`) with edelta()
        # (BuildingComp.java:1928, `return efficiency *
        # delta();`) and the default cost multiplier
        # (Consume.java:18, `public Floatf<Building> multiplier
        # = b -> 1f;` -- nothing overrides it for burst
        # drills), and each row's removal is ConsumeLiquid.
        # update (ConsumeLiquid.java:37-38,
        # `build.liquids.remove(liquid, amount * build.edelta()
        # * multiplier.get(build));`). The booster row is what
        # feeds the speed fold (BurstDrill.java:94, `float
        # speed = Mathf.lerp(1f, liquidBoostIntensity,
        # optionalEfficiency) * efficiency;`): without the
        # booster liquid the drill runs at base speed. The
        # per-def rows are impact-drill water 10f/60f required
        # (Blocks.java:3089, `consumeLiquid(Liquids.water,
        # 10f/60f);`) + ozone 3f/60f booster (Blocks.java:3090,
        # `consumeLiquid(Liquids.ozone, 3f / 60f).boost();`)
        # and eruption-drill hydrogen 4f/60f required
        # (Blocks.java:3119, `consumeLiquid(Liquids.hydrogen,
        # 4f / 60f);`) + cyanogen 0.75f/60f booster
        # (Blocks.java:3120, `consumeLiquid(Liquids.cyanogen,
        # 0.75f / 60f).boost();`). N2296 closes the rows with
        # one pure function over the frame (`efficiency`,
        # `efficiency_scale`, `required_liquid_stored`,
        # `booster_liquid_stored`) plus the per-def
        # required_amount and booster_amount parameters,
        # following the N2256 per-def-param precedent, and one
        # driver line that folds the rows into the consumption
        # call when the frame carries liquid observations.
        # Nine new result symbols: edelta, ed,
        # required_efficiency, booster_efficiency,
        # required_remove_amount, booster_remove_amount,
        # required_row, optional_row, has_liquids.
        self.assertEqual(
            ledger['N2296']['source_symbols'],
            [
                'source_burst_drill_liquid_rows_state_result.edelta',
                'source_burst_drill_liquid_rows_state_result.ed',
                'source_burst_drill_liquid_rows_state_result.required_efficiency',
                'source_burst_drill_liquid_rows_state_result.booster_efficiency',
                'source_burst_drill_liquid_rows_state_result.required_remove_amount',
                'source_burst_drill_liquid_rows_state_result.booster_remove_amount',
                'source_burst_drill_liquid_rows_state_result.required_row',
                'source_burst_drill_liquid_rows_state_result.optional_row',
                'source_burst_drill_liquid_rows_state_result.has_liquids',
            ],
        )
        for name in ledger['N2296']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BurstDrill.java',
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/world/consumers/ConsumeLiquid.java',
                    'core/src/mindustry/world/consumers/ConsumeLiquidBase.java',
                    'core/src/mindustry/world/consumers/Consume.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2296']['runtime_proof'], '/root/C07BurstDrillLiquidRowsProof')
        self.assertEqual(
            ledger['N2296']['tests'],
            [
                'test_c07_burst_drill_liquid_rows_registration',
                'test_all_c07_burst_drill_liquid_rows_input_evidence_is_exact',
                'test_burst_drill_liquid_rows_state',
                'test_reference_graph_and_actual_c07_burst_drill_liquid_rows',
            ],
        )
        self.assertTrue(ledger['N2296']['deferred_exprs'])

    def test_all_c07_burst_drill_liquid_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2296']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                source = symbol['java_source']
                upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / source).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/consumers/ConsumeLiquidBase.java',
            'core/src/mindustry/world/consumers/Consume.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2296']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_liquid_rows_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The pure liquid-rows function lives on the
        # burst-drill build state next to the N2149 power row
        # and the N2256 updateTile advance: it reads the
        # frame's folded efficiency and scale and the two
        # stored liquid amounts, derives edelta and ed, and
        # returns the two row efficiencies, the two removal
        # amounts and the two driver rows. The frame carries
        # `efficiency` (float, absent defaults to 0.0 --
        # `transient float efficiency;`,
        # BuildingComp.java:85), `efficiency_scale` (float,
        # absent defaults to 1.0 -- `public float
        # efficiencyScale(){` with `return 1f;`,
        # BuildingComp.java:1939-1941), `required_liquid_stored`
        # and `booster_liquid_stored` (floats, absent default
        # to 0.0 -- a fresh LiquidModule holds 0 of every
        # liquid). delta() is Time.delta * timeScale
        # (BuildingComp.java:1922-1923, `public float delta(){`
        # with `return Time.delta * timeScale;` -- timeScale
        # is 1 by default and the port passes the raw tick
        # seconds, the N2190 driver convention). edelta() is
        # efficiency * delta() (BuildingComp.java:1928,
        # `return efficiency * delta();`). The per-def amounts
        # are explicit params (the N2212 / N2248 per-def-param
        # precedent): impact-drill water 10f/60f
        # (Blocks.java:3089) + ozone 3f/60f booster
        # (Blocks.java:3090); eruption-drill hydrogen 4f/60f
        # (Blocks.java:3119) + cyanogen 0.75f/60f booster
        # (Blocks.java:3120). The cost multiplier is 1f
        # (Consume.java:18, `public Floatf<Building>
        # multiplier = b -> 1f;` -- nothing overrides it for
        # burst drills), so the removal is amount * edelta.
        # The driver folds the rows only when the frame
        # carries liquid observations (the BuildTurret
        # precedent): a frame with no stored-amount keys keeps
        # the power-only fold instead of zeroing efficiency
        # for every live burst drill.
        self.assertIn('static func source_burst_drill_liquid_rows_state(frame: Dictionary, delta: float, required_amount: float, booster_amount: float) -> Dictionary:', burst_drill)
        # The row cases, pinned as the pure function's
        # decision structure: the frame reads; edelta is
        # efficiency times delta; both efficiencies go
        # through the port's ConsumeLiquid efficiency_state
        # helper; both removals are amount times edelta
        # times the unit cost multiplier; the required row
        # carries is_power false; the optional row carries
        # the booster efficiency; has_liquids is true
        # (ConsumeLiquidBase.apply sets block.hasLiquids).
        self.assertIn('float(frame.get("efficiency", 0.0))', burst_drill)
        self.assertIn('float(frame.get("efficiency_scale", 1.0))', burst_drill)
        self.assertIn('float(frame.get("required_liquid_stored", 0.0))', burst_drill)
        self.assertIn('float(frame.get("booster_liquid_stored", 0.0))', burst_drill)
        with self.subTest(case='edelta is efficiency times delta'):
            self.assertIn('var edelta: float = efficiency * delta', burst_drill)
        with self.subTest(case='required efficiency goes through the ConsumeLiquid helper'):
            self.assertIn('source_consume_liquid_state.efficiency_state(required_liquid_stored, required_amount, edelta, efficiency_scale, cost_multiplier)', burst_drill)
        with self.subTest(case='booster efficiency goes through the ConsumeLiquid helper'):
            self.assertIn('source_consume_liquid_state.efficiency_state(booster_liquid_stored, booster_amount, edelta, efficiency_scale, cost_multiplier)', burst_drill)
        with self.subTest(case='removals are amount times edelta times the unit cost multiplier'):
            self.assertIn('var required_remove_amount: float = required_amount * edelta * cost_multiplier', burst_drill)
            self.assertIn('var booster_remove_amount: float = booster_amount * edelta * cost_multiplier', burst_drill)
        with self.subTest(case='required row carries the required efficiency and is not power'):
            self.assertIn('var required_row := {"result": required_efficiency, "is_power": false}', burst_drill)
        with self.subTest(case='optional row carries the booster efficiency'):
            self.assertIn('var optional_row := {"result": booster_efficiency}', burst_drill)
        with self.subTest(case='has_liquids is true'):
            self.assertIn('var has_liquids := true', burst_drill)
        with self.subTest(case='all nine keys are returned'):
            self.assertIn('return {"edelta": edelta, "ed": ed, "required_efficiency": required_efficiency, "booster_efficiency": booster_efficiency, "required_remove_amount": required_remove_amount, "booster_remove_amount": booster_remove_amount, "required_row": required_row, "optional_row": optional_row, "has_liquids": has_liquids}', burst_drill)
        for expr in [
            'float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;',
            'public float liquidBoostIntensity = 1.6f;',
            'liquidBoostIntensity = 1.75f;',
            'liquidBoostIntensity = 2f;',
            'consumeLiquid(Liquids.water, 10f/60f);',
            'consumeLiquid(Liquids.ozone, 3f / 60f).boost();',
            'consumeLiquid(Liquids.hydrogen, 4f / 60f);',
            'consumeLiquid(Liquids.cyanogen, 0.75f / 60f).boost();',
            'public float amount;',
            'block.hasLiquids = true;',
            'public boolean optional;',
            'public boolean booster;',
            'public Floatf<Building> multiplier = b -> 1f;',
            'public Consume boost(){',
            'return optional(true, true);',
            'block.liquidFilter[liquid.id] = true;',
            'build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));',
            'float ed = build.edelta() * build.efficiencyScale();',
            'if(ed <= 0.00000001f) return 0f;',
            'return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);',
            'stats.add(booster ? Stat.booster : Stat.input, liquid, amount * 60f, true);',
            'return liquid == this.liquid;',
            'public float delta(){',
            'return Time.delta * timeScale;',
            'public float edelta(){',
            'return efficiency * delta();',
            'public float efficiencyScale(){',
            'transient float efficiency;',
            'transient float optionalEfficiency;',
            'for(var cons : block.nonOptionalConsumers){',
            'minEfficiency = Math.min(minEfficiency, result);',
            'for(var cons : block.optionalConsumers){',
            'optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));',
            'efficiency = minEfficiency;',
            'optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);',
            'potentialEfficiency = efficiency;',
            'if(update && efficiency > 0){',
            'for(var cons : block.updateConsumers){',
            'public @NoPatch boolean hasLiquids;',
            'hasConsumers = consumers.length > 0;',
            'if(liquidBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){',
            'public void updateTile(){',
            'public class BurstDrill extends Drill{',
            'public class BurstDrillBuild extends DrillBuild{',
            'public class DrillBuild extends Building{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # The driver folds the rows into the consumption call
        # only when the frame carries liquid observations: it
        # binds the block's liquid consumers through the
        # generic N2003 binding, splits the required row from
        # the booster row on the booster flag, and appends the
        # pure function's rows to the required and optional
        # result lists. A frame with no stored-amount keys
        # keeps the power-only fold.
        driver_start = burst_drill.index('static func source_burst_drill_tick_buildings_state')
        driver_text = burst_drill[driver_start:]
        with self.subTest(case='driver binds the block liquid consumers through the generic binding'):
            self.assertIn('source_consume_liquid_state.source_bind_liquid_consumers_state(block, catalog)', driver_text)
        with self.subTest(case='driver splits required from booster on the booster flag'):
            self.assertIn('bool(row.get("booster", false))', driver_text)
        with self.subTest(case='driver calls the pure rows function with the tick seconds'):
            self.assertIn('source_burst_drill_liquid_rows_state(frame, seconds, required_amount, booster_amount)', driver_text)
        with self.subTest(case='driver appends the required row to the required results'):
            self.assertIn('required_results.append(liquid_rows.get("required_row", {}))', driver_text)
        with self.subTest(case='driver appends the optional row to the optional results'):
            self.assertIn('optional_results.append(liquid_rows.get("optional_row", {}))', driver_text)
        with self.subTest(case='driver folds only with liquid observations present'):
            self.assertIn('if frame.has("required_liquid_stored") and frame.has("booster_liquid_stored") and block.properties.has("consumeLiquid"):', driver_text)
        with self.subTest(case='consumption call takes the folded result lists'):
            self.assertIn('required_results, optional_results, [], frame)', driver_text)
        # The proof's keys drive the pure liquid rows
        # (required full / required partial / booster partial
        # / no liquid / edelta zero guard / remove amounts /
        # eruption def amounts / rows shape / overstock cap).
        # There is no removal-application key: the actual
        # liquids.remove call waits for the driver slice that
        # owns the liquids module, and the remove_amount
        # results are the observable signal that slice will
        # consume. There is no setStats booster-display key:
        # the stats booster row waits for its own slice.
        proof = BURST_DRILL_LIQUID_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'liquid_rows_required_efficiency_full',
            'liquid_rows_required_efficiency_partial',
            'liquid_rows_booster_efficiency_partial',
            'liquid_rows_no_liquid_zero_efficiency',
            'liquid_rows_edelta_zero_guard',
            'liquid_rows_remove_amounts',
            'liquid_rows_eruption_def_amounts',
            'liquid_rows_rows_shape',
            'liquid_rows_overstock_caps_at_one',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

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
            'liquid_rows_required_efficiency_full',
            'liquid_rows_required_efficiency_partial',
            'liquid_rows_booster_efficiency_partial',
            'liquid_rows_no_liquid_zero_efficiency',
            'liquid_rows_edelta_zero_guard',
            'liquid_rows_remove_amounts',
            'liquid_rows_eruption_def_amounts',
            'liquid_rows_rows_shape',
            'liquid_rows_overstock_caps_at_one',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
