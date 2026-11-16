import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_LIQUID_ROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerLiquidRowProof.gd'
REPAIR_TOWER_LIQUID_ROW_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerLiquidRowProof.tscn'


class C07RepairTowerLiquidRowTests(unittest.TestCase):
    def test_c07_repair_tower_liquid_row_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2250']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_liquid_consumer_row_state')
        # N2176 proved the repair tower's live power read, N2213
        # the shouldConsume gate (targets.size > 0) and N2227 the
        # updateTile heal advance -- but the folded efficiency
        # was still the min over the power row alone: the
        # repair tower's second consumer, ozone 3f/60f
        # (`consumeLiquid(Liquids.ozone, 3f / 60f);`,
        # Blocks.java:6583), was never folded, so a repair
        # tower with no ozone healed as if fully supplied.
        # N2250 is the required ConsumeLiquid row: the pure
        # liquid row (ConsumeLiquid.efficiency,
        # ConsumeLiquid.java:42-47, `float ed = build.edelta()
        # * build.efficiencyScale();` / `if(ed <= 0.00000001f)
        # return 0f;` / `return Math.min(build.liquids.get(
        # liquid) / (amount * ed * multiplier.get(build)),
        # 1f);`) folds into the first pass
        # (BuildingComp.java:1969-1976) beside the power row,
        # and the second pass removes `amount * edelta() *
        # multiplier` (ConsumeLiquid.java:37-39) when update
        # && efficiency > 0 (BuildingComp.java:1999-2003).
        # The multiplier is the Consume default 1f
        # (Consume.java:18, `public Floatf<Building>
        # multiplier = b -> 1f;`) -- the def sets none. Two
        # new result symbols: the row and its presence flag.
        self.assertEqual(
            ledger['N2250']['source_symbols'],
            [
                'source_repair_tower_liquid_consumer_row_state_result.row',
                'source_repair_tower_liquid_consumer_row_state_result.has_liquid_row',
            ],
        )
        for name in ledger['N2250']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumeLiquid.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_tower_liquid_consumer_row_state_result.row': 'SourceRepairTowerBuildState.source_repair_tower_liquid_consumer_row_state',
                    'source_repair_tower_liquid_consumer_row_state_result.has_liquid_row': 'SourceRepairTowerBuildState.source_repair_tower_liquid_consumer_row_state',
                }[name])
        self.assertEqual(ledger['N2250']['runtime_proof'], '/root/C07RepairTowerLiquidRowProof')
        self.assertEqual(
            ledger['N2250']['tests'],
            [
                'test_c07_repair_tower_liquid_row_registration',
                'test_all_c07_repair_tower_liquid_row_input_evidence_is_exact',
                'test_repair_tower_liquid_consumer_row_state',
                'test_reference_graph_and_actual_c07_repair_tower_liquid_row',
            ],
        )
        self.assertTrue(ledger['N2250']['deferred_exprs'])

    def test_all_c07_repair_tower_liquid_row_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2250']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_repair_tower_liquid_consumer_row_state_result.row': 'SourceRepairTowerBuildState.source_repair_tower_liquid_consumer_row_state',
                    'source_repair_tower_liquid_consumer_row_state_result.has_liquid_row': 'SourceRepairTowerBuildState.source_repair_tower_liquid_consumer_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/units/RepairTower.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2250']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_liquid_consumer_row_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # The pure liquid row lives on the repair-tower build
        # state: ConsumeLiquid.efficiency (ConsumeLiquid.java:
        # 42-47) over the frame liquids store, read through
        # the shared liquid module helper with the Fracker
        # guard (SourceFrackerBuildState.gd:279,
        # `liquids.has("liquids")` + bounds check) -- Java's
        # liquids.get returns 0.0 for a liquid never added.
        # In the first pass efficiency is assumed 1f
        # (BuildingComp.java:1964-1966), so edelta is the
        # source delta times the time scale; the folded
        # efficiency drives the second-pass removal instead
        # (ConsumeLiquid.java:37-39). The row is NOT power
        # (`"is_power": false`), so a starved row also stops
        # power draw (BuildingComp.java:1972-1974, `if(cons !=
        # block.consPower && result <= 0.0000001f){
        # shouldConsumePower = false; }`).
        self.assertIn('static func source_repair_tower_liquid_consumer_row_state', repair_tower)
        self.assertIn('float ed = build.edelta() * build.efficiencyScale();', repair_tower)
        self.assertIn('if(ed <= 0.00000001f) return 0f;', repair_tower)
        self.assertIn('return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', repair_tower)
        self.assertIn('build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', repair_tower)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', repair_tower)
        self.assertIn('consumeLiquid(Liquids.ozone, 3f / 60f);', repair_tower)
        self.assertIn('consumePower(1f);', repair_tower)
        self.assertIn('if(cons != block.consPower && result <= 0.0000001f){', repair_tower)
        self.assertIn('shouldConsumePower = false;', repair_tower)
        self.assertIn('if(update && efficiency > 0){', repair_tower)
        self.assertIn('cons.update(self());', repair_tower)
        self.assertIn('efficiency = minEfficiency;', repair_tower)
        self.assertIn('potentialEfficiency = efficiency;', repair_tower)
        self.assertIn('boolean update = shouldConsume() && productionValid();', repair_tower)
        self.assertIn('return efficiency * delta();', repair_tower)
        self.assertIn('return Time.delta * timeScale;', repair_tower)
        self.assertIn('for(var cons : block.nonOptionalConsumers){', repair_tower)
        self.assertIn('minEfficiency = Math.min(minEfficiency, result);', repair_tower)
        self.assertIn('public class RepairTower extends Block{', repair_tower)
        self.assertIn('public class RepairTowerBuild extends Building implements Ranged{', repair_tower)
        self.assertIn('return targets.size > 0;', repair_tower)
        self.assertIn('target.heal(healAmount * edelta());', repair_tower)
        # The row shape mirrors the power row (is_power false
        # here); the tick syncs the live liquids store into
        # the frame before the fold (the Fracker:327
        # precedent), folds the row into required_results
        # when the block has a liquid consumer, and removes
        # the consumed ozone after the fold through the
        # shared module helper (the SolidPump cache_sums
        # precedent). The def constants are ozone + 3f/60f.
        self.assertIn('"is_power": false', repair_tower)
        self.assertIn('SOURCE_BUILDING_LIQUIDS_META_KEY', repair_tower)
        self.assertIn('source_get_state', repair_tower)
        self.assertIn('source_remove_state', repair_tower)
        self.assertIn('block.properties.has("consumeLiquid")', repair_tower)
        self.assertIn('SOURCE_REPAIR_TOWER_LIQUID', repair_tower)
        self.assertIn('SOURCE_REPAIR_TOWER_LIQUID_AMOUNT', repair_tower)
        self.assertIn('3.0 / 60.0', repair_tower)
        self.assertIn('"liquids": {}', repair_tower)
        self.assertIn('static func source_repair_tower_tick_buildings_state', repair_tower)
        # The proof's keys drive the pure row (starved /
        # capped / zero-edelta / no-liquid) plus the live
        # tick (fold + removal). The scene file exists and
        # the proof preloads a script that exists.
        proof = REPAIR_TOWER_LIQUID_ROW_PROOF.read_text(encoding='utf-8')
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
        self.assertTrue(REPAIR_TOWER_LIQUID_ROW_PROOF_SCENE.exists())
        self.assertIn('SourceRepairTowerBuildState.gd', proof)
        self.assertIn('SourceLiquidModuleState.gd', proof)

    def test_reference_graph_and_actual_c07_repair_tower_liquid_row(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTowerLiquidRowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TOWER_LIQUID_ROW_PROOF ')]
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
