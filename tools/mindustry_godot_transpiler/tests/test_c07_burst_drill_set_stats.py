import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_SET_STATS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillSetStatsProof.gd'


class C07BurstDrillSetStatsTests(unittest.TestCase):
    def test_c07_burst_drill_set_stats_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2309']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_set_stats_state')
        # BurstDrill.setStats() (BurstDrill.java:58-68,
        # `public void setStats(){`) calls the Drill super
        # (`super.setStats();` -- :59, NOT this slice) and,
        # only when `liquidBoostIntensity != 1` and a booster
        # consumer is found (`if(liquidBoostIntensity != 1
        # && findConsumer(f -> f instanceof ConsumeLiquidBase
        # && f.booster) instanceof ConsumeLiquidBase
        # consBase){` -- :61), removes the booster row
        # (`stats.remove(Stat.booster);` -- :62) and re-adds
        # it with the PLAIN intensity (`StatValues.
        # speedBoosters("{0}" + StatUnit.timesSpeed.
        # localized(), consBase.amount,
        # liquidBoostIntensity, false, consBase::consumes)`
        # -- :64-65). The super's own booster row uses the
        # SQUARED intensity (`liquidBoostIntensity *
        # liquidBoostIntensity`, Drill.java:188), so the
        # override's remove-then-add is what makes the
        # displayed speed the plain intensity, not the
        # square (the N2224 RepairTurret setStats precedent
        # for the speedBoosters row model). findConsumer is
        # NOT ported here: the caller passes the found
        # consumer as explicit inputs (the N1688/N1753
        # findConsumer precedent). There is NO driver tick
        # line: setStats is a block-level stat-display read,
        # not a per-tick write (the N2224 / N2246 setStats
        # lifecycle precedent). Two new result symbols:
        # booster_row_removed, booster_row. Two defs share
        # the function (impact-drill, Blocks.java:3070,
        # liquidBoostIntensity 1.75f; eruption-drill,
        # Blocks.java:3093, liquidBoostIntensity 2f); they
        # differ only in the per-def intensity and booster
        # amount the caller passes.
        self.assertEqual(
            ledger['N2309']['source_symbols'],
            [
                'source_burst_drill_set_stats_state_result.booster_row_removed',
                'source_burst_drill_set_stats_state_result.booster_row',
            ],
        )
        for name in ledger['N2309']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BurstDrill.java',
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/world/meta/StatValues.java',
                    'core/src/mindustry/world/meta/StatUnit.java',
                    'core/src/mindustry/world/consumers/ConsumeLiquidBase.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/world/consumers/Consume.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2309']['runtime_proof'], '/root/C07BurstDrillSetStatsProof')
        self.assertEqual(
            ledger['N2309']['tests'],
            [
                'test_c07_burst_drill_set_stats_registration',
                'test_all_c07_burst_drill_set_stats_input_evidence_is_exact',
                'test_burst_drill_set_stats_state',
                'test_reference_graph_and_actual_c07_burst_drill_set_stats',
            ],
        )
        self.assertTrue(ledger['N2309']['deferred_exprs'])

    def test_all_c07_burst_drill_set_stats_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2309']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/meta/StatValues.java',
            'core/src/mindustry/world/meta/StatUnit.java',
            'core/src/mindustry/world/consumers/ConsumeLiquidBase.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/consumers/Consume.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2309']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_set_stats_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # BurstDrill.setStats() (BurstDrill.java:58-68,
        # `public void setStats(){`): `super.setStats();`
        # (:59) is Drill.setStats, NOT this slice. Only when
        # `liquidBoostIntensity != 1` and a booster consumer
        # is found (`if(liquidBoostIntensity != 1 &&
        # findConsumer(f -> f instanceof ConsumeLiquidBase &&
        # f.booster) instanceof ConsumeLiquidBase consBase){`
        # -- :61) does the override remove the booster row
        # (`stats.remove(Stat.booster);` -- :62) and re-add
        # it (`stats.add(Stat.booster,` -- :63 -- with
        # `StatValues.speedBoosters("{0}" + StatUnit.
        # timesSpeed.localized(),` -- :64 -- and
        # `consBase.amount, liquidBoostIntensity, false,
        # consBase::consumes)` -- :65). The speedBoosters
        # speed param is the PLAIN intensity here, while the
        # Drill super passes the SQUARED intensity
        # (`liquidBoostIntensity * liquidBoostIntensity,
        # false, consBase::consumes)`, Drill.java:188) --
        # the remove-then-add is what pins the displayed
        # speed to the plain intensity. The unit format is
        # "{0} x speed": StatUnit.timesSpeed.localized()
        # reads bundle key "unit.timesspeed", English value
        # "x speed". There is NO driver tick line: setStats
        # is a block-level stat-display read, not a per-tick
        # write (the N2224 / N2246 setStats lifecycle
        # precedent).
        self.assertIn('static func source_burst_drill_set_stats_state(frame: Dictionary, liquid_boost_intensity: float, booster_consumer_found: bool, booster_amount: float, booster_consumes: bool) -> Dictionary:', burst_drill)
        self.assertIn('return {"booster_row_removed": booster_row_removed, "booster_row": booster_row}', burst_drill)
        for expr in [
            'public void setStats(){',
            'super.setStats();',
            'if(liquidBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){',
            'stats.remove(Stat.booster);',
            'stats.add(Stat.booster,',
            'StatValues.speedBoosters("{0}" + StatUnit.timesSpeed.localized(),',
            'consBase.amount, liquidBoostIntensity, false, consBase::consumes)',
            'public class BurstDrill extends Drill{',
            'public static StatValue speedBoosters(String unit, float amount, float speed, boolean strength, Boolf<Liquid> filter){',
            'timesSpeed = new StatUnit("timesSpeed", false),',
            'public float liquidBoostIntensity = 1.6f;',
            'liquidBoostIntensity = 1.75f;',
            'liquidBoostIntensity = 2f;',
            'consumeLiquid(Liquids.ozone, 3f / 60f).boost();',
            'consumeLiquid(Liquids.cyanogen, 0.75f / 60f).boost();',
            'liquidBoostIntensity * liquidBoostIntensity, false, consBase::consumes)',
            'public abstract boolean consumes(Liquid liquid);',
            'public <T extends Consume> T findConsumer(Boolf<Consume> filter){',
            'public boolean booster;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # The proof's keys drive the pure function directly
        # with the per-def intensities and booster amounts:
        # impact-drill (1.75f, ozone 3f/60f, Blocks.java:3084,
        # :3090) and eruption-drill (2f, cyanogen 0.75f/60f,
        # Blocks.java:3115, :3120). The intensity == 1 branch
        # and the no-consumer branch both pin "no row".
        proof = BURST_DRILL_SET_STATS_PROOF.read_text(encoding='utf-8')
        for key in [
            'set_stats_booster_impact_drill',
            'set_stats_booster_eruption_drill',
            'set_stats_booster_absent_intensity_one',
            'set_stats_booster_absent_no_consumer',
            'set_stats_booster_removed_before_add',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_burst_drill_set_stats(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillSetStatsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_SET_STATS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'set_stats_booster_impact_drill',
            'set_stats_booster_eruption_drill',
            'set_stats_booster_absent_intensity_one',
            'set_stats_booster_absent_no_consumer',
            'set_stats_booster_removed_before_add',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
