import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
DRILL_SET_STATS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillSetStatsProof.gd'


class C07DrillSetStatsTests(unittest.TestCase):
    def test_c07_drill_set_stats_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2280']['godot_owner'], 'SourceBurstDrillBuildState.source_drill_set_stats_state')
        # Drill.setStats() (Drill.java:175-191, `public void
        # setStats(){`) calls the Block super
        # (`super.setStats();`, :176 -- Block.setStats is
        # owned by N1696 at PortGame, NOT this slice), adds
        # the drillTier row (`stats.add(Stat.drillTier,
        # StatValues.drillables(drillTime,
        # hardnessDrillMultiplier, size * size,
        # drillMultipliers, ...));`, :178-179), adds the
        # drillSpeed row (`stats.add(Stat.drillSpeed, 60f /
        # drillTime * size * size, StatUnit.itemsSecond);`,
        # :181), and, only when `liquidBoostIntensity != 1`
        # and a booster consumer is found (:183), removes
        # the booster row (:184) and re-adds it with the
        # SQUARED intensity (`liquidBoostIntensity *
        # liquidBoostIntensity, false, consBase::consumes)`,
        # :188) -- the TRAP vs N2266, whose BurstDrill
        # override row uses the PLAIN intensity
        # (BurstDrill.java:65). This slice CLOSES the
        # super-leg deferred entry N2266 carried. Four new
        # result symbols: drill_tier_row, drill_speed_row,
        # booster_row_removed, booster_row. There is NO
        # driver tick line: setStats is a stat-display
        # read, not a per-tick write (the N2224 / N2246
        # setStats lifecycle precedent).
        self.assertEqual(
            ledger['N2280']['source_symbols'],
            [
                'source_drill_set_stats_state_result.drill_tier_row',
                'source_drill_set_stats_state_result.drill_speed_row',
                'source_drill_set_stats_state_result.booster_row_removed',
                'source_drill_set_stats_state_result.booster_row',
            ],
        )
        for name in ledger['N2280']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/world/meta/StatValues.java',
                    'core/src/mindustry/world/meta/StatUnit.java',
                    'core/src/mindustry/world/consumers/ConsumeLiquidBase.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/world/consumers/Consume.java',
                    'core/src/mindustry/world/meta/Stat.java',
                    'core/assets/bundles/bundle.properties',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2280']['runtime_proof'], '/root/C07DrillSetStatsProof')
        self.assertEqual(
            ledger['N2280']['tests'],
            [
                'test_c07_drill_set_stats_registration',
                'test_all_c07_drill_set_stats_input_evidence_is_exact',
                'test_drill_set_stats_state',
                'test_reference_graph_and_actual_c07_drill_set_stats',
            ],
        )
        self.assertTrue(ledger['N2280']['deferred_exprs'])

    def test_all_c07_drill_set_stats_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2280']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/meta/StatValues.java',
            'core/src/mindustry/world/meta/StatUnit.java',
            'core/src/mindustry/world/consumers/ConsumeLiquidBase.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/world/meta/Stat.java',
            'core/assets/bundles/bundle.properties',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2280']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_set_stats_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # Drill.setStats() (Drill.java:175-191, `public void
        # setStats(){`) adds the drillTier row (the
        # StatValues.drillables call, :178-179, with
        # `drillTime`, `hardnessDrillMultiplier`, `size *
        # size`, `drillMultipliers` and the floor filter
        # `f.itemDrop.hardness <= tier && (blockedItems ==
        # null || !blockedItems.contains(f.itemDrop)) &&
        # (indexer.isBlockPresent(f) || state.isMenu())`),
        # the drillSpeed row (`60f / drillTime * size *
        # size`, `StatUnit.itemsSecond`, :181), and the
        # booster row with the SQUARED intensity
        # (`liquidBoostIntensity * liquidBoostIntensity`,
        # :188) when the guard (:183) runs. `super.setStats();`
        # (:176) is Block.setStats, owned by N1696 at
        # PortGame, NOT this slice. The classes are `public
        # class Drill extends Block{` (Drill.java:27).
        # Per-def values: class defaults `public float
        # hardnessDrillMultiplier = 50f;` (:28), `public
        # int tier;` (:34), `public float drillTime = 300;`
        # (:36), `public float liquidBoostIntensity = 1.6f;`
        # (:38); impact-drill `drillTime = 60f * 12f;`
        # (Blocks.java:3072, 720f), `size = 4;`, `tier = 6;`,
        # `liquidBoostIntensity = 1.75f;`, ozone booster
        # `3f / 60f`; eruption-drill `drillTime = 281.25f;`,
        # `size = 5;`, `tier = 7;`,
        # `liquidBoostIntensity = 2f;`, cyanogen booster
        # `0.75f / 60f`. There is NO driver tick line:
        # setStats is a stat-display read (the N2224 /
        # N2246 precedent).
        self.assertIn('static func source_drill_set_stats_state(frame: Dictionary, drill_time: float, hardness_drill_multiplier: float, size: int, tier: int, drill_multipliers: Dictionary, blocked_items: Variant, liquid_boost_intensity: float, booster_consumer_found: bool, booster_amount: float, booster_consumes: bool) -> Dictionary:', burst_drill)
        self.assertIn('return {"drill_tier_row": drill_tier_row, "drill_speed_row": drill_speed_row, "booster_row_removed": booster_row_removed, "booster_row": booster_row}', burst_drill)
        for expr in [
            'public void setStats(){',
            'super.setStats();',
            'stats.add(Stat.drillTier, StatValues.drillables(drillTime, hardnessDrillMultiplier, size * size, drillMultipliers, b -> b instanceof Floor f && !f.wallOre && f.itemDrop != null &&',
            'f.itemDrop.hardness <= tier && (blockedItems == null || !blockedItems.contains(f.itemDrop)) && (indexer.isBlockPresent(f) || state.isMenu())));',
            'stats.add(Stat.drillSpeed, 60f / drillTime * size * size, StatUnit.itemsSecond);',
            'if(liquidBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){',
            'stats.remove(Stat.booster);',
            'liquidBoostIntensity * liquidBoostIntensity, false, consBase::consumes)',
            'public class Drill extends Block{',
            'public float hardnessDrillMultiplier = 50f;',
            'public int tier;',
            'public float drillTime = 300;',
            'public float liquidBoostIntensity = 1.6f;',
            'drillTime = 60f * 12f;',
            'drillTime = 281.25f;',
            'tier = 6;',
            'tier = 7;',
            'liquidBoostIntensity = 1.75f;',
            'liquidBoostIntensity = 2f;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # The proof's keys drive the pure function directly
        # with per-def params: the drillTier row pins the
        # drillables args per def, the drillSpeed row pins
        # 60/drillTime*size^2 (0.2 class default, 1.333...
        # impact, 5.333... eruption), and the booster row
        # pins the SQUARED intensity (3.0625 impact,
        # 4.0 eruption) vs null when the guard does not run.
        proof = DRILL_SET_STATS_PROOF.read_text(encoding='utf-8')
        for key in [
            'drill_tier_row_impact',
            'drill_tier_row_eruption',
            'drill_speed_class_default',
            'drill_speed_impact',
            'drill_speed_eruption',
            'booster_row_squared_impact',
            'booster_row_squared_eruption',
            'booster_row_absent_intensity_one',
            'booster_row_absent_no_consumer',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_drill_set_stats(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DrillSetStatsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DRILL_SET_STATS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'drill_tier_row_impact',
            'drill_tier_row_eruption',
            'drill_speed_class_default',
            'drill_speed_impact',
            'drill_speed_eruption',
            'booster_row_squared_impact',
            'booster_row_squared_eruption',
            'booster_row_absent_intensity_one',
            'booster_row_absent_no_consumer',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
