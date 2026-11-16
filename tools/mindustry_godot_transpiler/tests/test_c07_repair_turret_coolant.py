import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_COOLANT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretCoolantProof.gd'
REPAIR_TURRET_COOLANT_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretCoolantProof.tscn'


class C07RepairTurretCoolantTests(unittest.TestCase):
    def test_c07_repair_turret_coolant_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2259']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_coolant_row_state')
        # N2174 proved the repair turret's live power read, N2212
        # the shouldConsume gate (target != null && enabled) and
        # N2226 the updateTile heal advance -- but the folded
        # optionalEfficiency was still 1.0 always: the repair
        # turret's optional consumer, ConsumeCoolant 0.16f
        # (`consume(new ConsumeCoolant(coolantUse)).optional(
        # true, true);`, RepairTurret.java:86, with `coolantUse
        # = 0.16f;`, Blocks.java:6405), was never folded, so a
        # repair turret with no coolant healed as if fully
        # boosted and the advance multiplier sat hardcoded at
        # 1.0. N2259 is the optional ConsumeCoolant row: the
        # pure coolant row (ConsumeLiquidFilter.efficiency,
        # ConsumeLiquidFilter.java:50-55, `float ed = build.
        # edelta();` / `if(ed <= 0.00000001f) return 0f;` /
        # `return liq != null ? Math.min(build.liquids.get(
        # liq) / (amount * ed * multiplier.get(build)), 1f) :
        # 0f;`) folds into the OPTIONAL pass
        # (BuildingComp.java:1979-1981), and the second pass
        # removes `amount * edelta() * multiplier`
        # (ConsumeLiquidFilter.java:42-47) when update &&
        # efficiency > 0 (BuildingComp.java:1999-2000). The
        # multiplier is the Consume default 1f (Consume.java:18,
        # `public Floatf<Building> multiplier = b -> 1f;`) --
        # the def sets none. The filter is `liquid.coolant &&
        # (allowLiquid && !liquid.gas || allowGas &&
        # liquid.gas) && liquid.temperature <= maxTemp &&
        # liquid.flammability < maxFlammability`
        # (ConsumeCoolant.java:12), so with the Liquid.java
        # defaults only water + cryofluid pass. The heal
        # multiplier is live too: `multiplier = 1f +
        # liquids.current().heatCapacity * coolantMultiplier *
        # optionalEfficiency;` (RepairTurret.java:190,
        # coolantMultiplier 1.6f, Blocks.java:6406), read from
        # the CURRENT liquid's heatCapacity and the FOLDED
        # optionalEfficiency. repair-point has no coolant
        # consumer at all (acceptCoolant=false, RepairTurret.
        # java:39) -- no row, multiplier 1.0. Three new result
        # symbols: the row, its presence flag, and the liquid
        # getConsumed picked.
        self.assertEqual(
            ledger['N2259']['source_symbols'],
            [
                'source_repair_turret_coolant_row_state_result.row',
                'source_repair_turret_coolant_row_state_result.has_coolant_row',
                'source_repair_turret_coolant_row_state_result.consumed_liquid',
            ],
        )
        for name in ledger['N2259']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_turret_coolant_row_state_result.row': 'SourceRepairTurretBuildState.source_repair_turret_coolant_row_state',
                    'source_repair_turret_coolant_row_state_result.has_coolant_row': 'SourceRepairTurretBuildState.source_repair_turret_coolant_row_state',
                    'source_repair_turret_coolant_row_state_result.consumed_liquid': 'SourceRepairTurretBuildState.source_repair_turret_coolant_row_state',
                }[name])
        self.assertEqual(ledger['N2259']['runtime_proof'], '/root/C07RepairTurretCoolantProof')
        self.assertEqual(
            ledger['N2259']['tests'],
            [
                'test_c07_repair_turret_coolant_registration',
                'test_all_c07_repair_turret_coolant_input_evidence_is_exact',
                'test_repair_turret_coolant_row_state',
                'test_reference_graph_and_actual_c07_repair_turret_coolant',
            ],
        )
        self.assertTrue(ledger['N2259']['deferred_exprs'])

    def test_all_c07_repair_turret_coolant_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2259']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_turret_coolant_row_state_result.row': 'SourceRepairTurretBuildState.source_repair_turret_coolant_row_state',
                    'source_repair_turret_coolant_row_state_result.has_coolant_row': 'SourceRepairTurretBuildState.source_repair_turret_coolant_row_state',
                    'source_repair_turret_coolant_row_state_result.consumed_liquid': 'SourceRepairTurretBuildState.source_repair_turret_coolant_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeCoolant.java',
            'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/type/Liquid.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2259']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_coolant_row_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The pure coolant row lives on the repair-turret build
        # state: ConsumeLiquidFilter.efficiency
        # (ConsumeLiquidFilter.java:50-55) over the frame
        # liquids store, read through the shared liquid module
        # helper with the Fracker guard (SourceFrackerBuildState.
        # gd:141-142, `liquids.has("liquids")` + bounds check)
        # -- Java's liquids.get returns 0.0 for a liquid never
        # added. Unlike ConsumeLiquid.efficiency, the filter
        # efficiency does NOT multiply by efficiencyScale
        # (`float ed = build.edelta();`, ConsumeLiquidFilter.
        # java:52). In the first pass efficiency is assumed 1f
        # (BuildingComp.java:1964-1966), so edelta is the
        # source delta times the time scale; the folded
        # efficiency drives the second-pass removal instead
        # (ConsumeLiquidFilter.java:42-47). The row is NOT
        # power (`"is_power": false`) and folds into the
        # OPTIONAL pass (BuildingComp.java:1979-1981), so a
        # starved coolant row lowers optionalEfficiency, never
        # the min efficiency -- and it does NOT stop power draw
        # (the shouldConsumePower cut at BuildingComp.java:
        # 1972-1974 only runs over the non-optional pass).
        self.assertIn('static func source_repair_turret_coolant_row_state', repair_turret)
        self.assertIn('static func source_repair_turret_coolant_filter_state', repair_turret)
        self.assertIn('static func source_repair_turret_coolant_consumed_state', repair_turret)
        self.assertIn('static func source_repair_turret_coolant_multiplier_state', repair_turret)
        self.assertIn('float ed = build.edelta();', repair_turret)
        self.assertIn('if(ed <= 0.00000001f) return 0f;', repair_turret)
        self.assertIn('return liq != null ? Math.min(build.liquids.get(liq) / (amount * ed * multiplier.get(build)), 1f) : 0f;', repair_turret)
        self.assertIn('build.liquids.remove(liq, amount * build.edelta() * multiplier.get(build));', repair_turret)
        self.assertIn('if(filter.get(build.liquids.current()) && build.liquids.currentAmount() > 0){', repair_turret)
        self.assertIn('return build.liquids.current();', repair_turret)
        self.assertIn('if(filter.get(liq) && build.liquids.get(liq) > 0){', repair_turret)
        self.assertIn('this.filter = liquid -> liquid.coolant && (this.allowLiquid && !liquid.gas || this.allowGas && liquid.gas) && liquid.temperature <= maxTemp && liquid.flammability < maxFlammability;', repair_turret)
        self.assertIn('public float maxTemp = 0.5f, maxFlammability = 0.1f;', repair_turret)
        self.assertIn('public boolean allowLiquid = true, allowGas = false;', repair_turret)
        self.assertIn('this(amount, true, false);', repair_turret)
        self.assertIn('consume(new ConsumeCoolant(coolantUse)).optional(true, true);', repair_turret)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', repair_turret)
        self.assertIn('return optional(true, true);', repair_turret)
        self.assertIn('coolantUse = 0.16f;', repair_turret)
        self.assertIn('coolantMultiplier = 1.6f;', repair_turret)
        self.assertIn('acceptCoolant = true;', repair_turret)
        self.assertIn('public boolean acceptCoolant = false;', repair_turret)
        self.assertIn('public float coolantUse = 0.5f;', repair_turret)
        self.assertIn('public float coolantMultiplier = 1f;', repair_turret)
        self.assertIn('public boolean gas = false;', repair_turret)
        self.assertIn('public float flammability;', repair_turret)
        self.assertIn('public float temperature = 0.5f;', repair_turret)
        self.assertIn('public float heatCapacity = 0.5f;', repair_turret)
        self.assertIn('public boolean coolant = true;', repair_turret)
        self.assertIn('multiplier = 1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency;', repair_turret)
        self.assertIn('for(var cons : block.optionalConsumers){', repair_turret)
        self.assertIn('optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));', repair_turret)
        self.assertIn('optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);', repair_turret)
        self.assertIn('if(update && efficiency > 0){', repair_turret)
        self.assertIn('cons.update(self());', repair_turret)
        self.assertIn('efficiency = minEfficiency;', repair_turret)
        self.assertIn('boolean update = shouldConsume() && productionValid();', repair_turret)
        self.assertIn('return efficiency * delta();', repair_turret)
        self.assertIn('return Time.delta * timeScale;', repair_turret)
        self.assertIn('public class RepairTurret extends Block{', repair_turret)
        self.assertIn('public class RepairPointBuild extends Building implements Ranged, RotBlock{', repair_turret)
        self.assertIn('return target != null && enabled;', repair_turret)
        self.assertIn('target.heal(repairSpeed * strength * edelta() * multiplier);', repair_turret)
        # The row shape mirrors the power row (is_power false
        # here); the tick syncs the live liquids store into
        # the frame before the fold (the Fracker:623
        # precedent), folds the row into optional_results
        # when the block is the repair-turret (acceptCoolant;
        # repair-point appends no row), and removes the
        # consumed coolant after the fold through the shared
        # module helper. The advance reads the live coolant
        # multiplier from frame["coolant_multiplier"] (the
        # N2226 test pins the advance call text, so no new
        # parameter). The def constants are 0.16f + 1.6f.
        self.assertIn('"is_power": false', repair_turret)
        self.assertIn('SOURCE_BUILDING_LIQUIDS_META_KEY', repair_turret)
        self.assertIn('source_get_state', repair_turret)
        self.assertIn('source_remove_state', repair_turret)
        self.assertIn('liquid_props_by_id', repair_turret)
        self.assertIn('optional_results', repair_turret)
        self.assertIn('block_id == "repair-turret"', repair_turret)
        self.assertIn('frame["coolant_multiplier"]', repair_turret)
        self.assertIn('frame.get("optional_efficiency", 0.0)', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_COOLANT_AMOUNT := 0.16', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_COOLANT_MULTIPLIER := 1.6', repair_turret)
        self.assertIn('"liquids": {}', repair_turret)
        self.assertIn('static func source_repair_turret_tick_buildings_state', repair_turret)
        # The proof's keys drive the pure row (optional fold
        # + getConsumed preference + zero without coolant)
        # plus the filter (water/cryofluid pass, everything
        # else rejects), the multiplier (current heat
        # capacity), the repair-point no-row case, and the
        # live tick (fold + removal). The scene file exists
        # and the proof preloads scripts that exist.
        proof = REPAIR_TURRET_COOLANT_PROOF.read_text(encoding='utf-8')
        for key in [
            'coolant_row_folds_optional_when_present',
            'filter_rejects_non_coolant',
            'multiplier_uses_current_heat_capacity',
            'repair_point_has_no_coolant_row',
            'live_tick_folds_coolant_row',
            'live_tick_removes_coolant_when_running',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertTrue(REPAIR_TURRET_COOLANT_PROOF_SCENE.exists())
        self.assertIn('SourceRepairTurretBuildState.gd', proof)
        self.assertIn('SourceLiquidModuleState.gd', proof)

    def test_reference_graph_and_actual_c07_repair_turret_coolant(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretCoolantProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_COOLANT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'coolant_row_folds_optional_when_present',
            'filter_rejects_non_coolant',
            'multiplier_uses_current_heat_capacity',
            'repair_point_has_no_coolant_row',
            'live_tick_folds_coolant_row',
            'live_tick_removes_coolant_when_running',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
