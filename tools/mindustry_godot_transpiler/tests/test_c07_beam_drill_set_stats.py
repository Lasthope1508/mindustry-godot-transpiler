import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_SET_STATS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillSetStatsProof.gd'


class C07BeamDrillSetStatsTests(unittest.TestCase):
    def test_c07_beam_drill_set_stats_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2388']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_set_stats_state')
        # BeamDrill.setStats() (BeamDrill.java:119-137, `public
        # void setStats(){`) is the BeamDrill stat display: the
        # drillTier row (StatValues.drillables with the
        # Floor/StaticWall filter legs), the drillSpeed row
        # (60f / drillTime * size, NOT size * size -- the
        # Drill.java:181 trap, which squares the size), and
        # the booster row REPLACED with the PLAIN
        # optionalBoostIntensity (NOT squared -- the
        # Drill.java:188 trap, whose super row uses the
        # squared liquidBoostIntensity) when
        # optionalBoostIntensity != 1 and a booster consumer
        # is found. One pure function on the existing
        # SourceBeamDrillBuildState.gd (the N2332 Drill
        # setStats precedent): it returns the computed stat
        # rows and does NOT touch real Stats / StatValues
        # rendering. NO driver tick line: setStats is stat
        # display, not per-tick state. The 7 distinguishing
        # exprs are the 0-hit lines re-probed at base
        # c71d1adf in both ledgers (7/9 candidates 0-hit).
        # The 2 HIT exprs (`StatValues.speedBoosters("{0}"
        # + StatUnit.timesSpeed.localized(),` [N2309,
        # N2332]; `super.setStats();` 19 slices) are
        # evidence/context only, NOT distinguishing exprs,
        # and are NOT in EXACT_EXPRS. findConsumer arrives
        # as the already-found result
        # (booster_consumer_found / booster_amount /
        # booster_consumes, the N1688/N1753 precedent);
        # the two drillables filter legs arrive as the
        # explicit drillables_filter Callable (the N2379
        # world_tile precedent); Stats / StatValues /
        # Floor / StaticWall / ConsumeLiquidBase are NOT
        # ported here. Four new result symbols:
        # drill_tier_row, drill_speed_row,
        # booster_row_replaced, booster_row.
        self.assertEqual(
            ledger['N2388']['source_symbols'],
            [
                'source_beam_drill_set_stats_state_result.drill_tier_row',
                'source_beam_drill_set_stats_state_result.drill_speed_row',
                'source_beam_drill_set_stats_state_result.booster_row_replaced',
                'source_beam_drill_set_stats_state_result.booster_row',
            ],
        )
        for name in ledger['N2388']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BeamDrill.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/world/meta/StatValues.java',
                    'core/src/mindustry/world/meta/StatUnit.java',
                    'core/src/mindustry/world/meta/Stat.java',
                    'core/src/mindustry/world/consumers/ConsumeLiquidBase.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/world/consumers/Consume.java',
                    'core/assets/bundles/bundle.properties',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2388']['runtime_proof'], '/root/C07BeamDrillSetStatsProof')
        self.assertEqual(
            ledger['N2388']['tests'],
            [
                'test_c07_beam_drill_set_stats_registration',
                'test_all_c07_beam_drill_set_stats_input_evidence_is_exact',
                'test_beam_drill_set_stats_state',
                'test_reference_graph_and_actual_c07_beam_drill_set_stats',
            ],
        )
        self.assertTrue(ledger['N2388']['deferred_exprs'])

    def test_all_c07_beam_drill_set_stats_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2388']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/meta/StatValues.java',
            'core/src/mindustry/world/meta/StatUnit.java',
            'core/src/mindustry/world/meta/Stat.java',
            'core/src/mindustry/world/consumers/ConsumeLiquidBase.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/assets/bundles/bundle.properties',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2388']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_set_stats_state(self):
        state = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # BeamDrill.setStats() (BeamDrill.java:119-137)
        # returns the computed stat rows: the drillTier row
        # pins the StatValues.drillables call args (drillTime,
        # 0f drillMultiplier, size -- NOT size * size --,
        # drillMultipliers, tier, blockedItems, the filter
        # Callable), the drillSpeed row is the computed value
        # 60f / drillTime * size with unit "items/second",
        # and the booster row is the speedBoosters row with
        # the PLAIN optionalBoostIntensity (or null when the
        # guard fails) plus whether stats.replace ran. The
        # per-ore drillables table renders at display time,
        # NOT this slice (the N2332 precedent). NO driver
        # tick line: setStats is stat display.
        self.assertIn('static func source_beam_drill_set_stats_state(frame: Dictionary, drill_time: float, size: int, tier: int, drill_multipliers: Dictionary, blocked_items: Variant, optional_boost_intensity: float, booster_consumer_found: bool, booster_amount: float, booster_consumes: bool, drillables_filter: Callable) -> Dictionary:', state)
        self.assertIn('return {"drill_tier_row": drill_tier_row, "drill_speed_row": drill_speed_row, "booster_row_replaced": booster_row_replaced, "booster_row": booster_row}', state)
        for expr in [
            'stats.add(Stat.drillTier, StatValues.drillables(drillTime, 0f, size, drillMultipliers, b ->',
            '(b instanceof Floor f && f.wallOre && f.itemDrop != null && f.itemDrop.hardness <= tier && (blockedItems == null || !blockedItems.contains(f.itemDrop))) ||',
            '(b instanceof StaticWall w && w.itemDrop != null && w.itemDrop.hardness <= tier && (blockedItems == null || !blockedItems.contains(w.itemDrop)))',
            'stats.add(Stat.drillSpeed, 60f / drillTime * size, StatUnit.itemsSecond);',
            'if(optionalBoostIntensity != 1 && findConsumer(f -> f instanceof ConsumeLiquidBase && f.booster) instanceof ConsumeLiquidBase consBase){',
            'stats.replace(Stat.booster,',
            'consBase.amount, optionalBoostIntensity, false, consBase::consumes)',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure function with
        # per-def params (no live tick): plasma-bore
        # drillTier row args / drillSpeed formula + unit /
        # the Floor + StaticWall filter legs / the blocked
        # item / the tier gate / the booster row present
        # with the PLAIN intensity / the booster row absent
        # when intensity is 1 / the booster row absent
        # when no consumer is found / the four-key shape.
        proof = BEAM_DRILL_SET_STATS_PROOF.read_text(encoding='utf-8')
        for key in [
            'drill_tier_row_args',
            'drill_speed_formula',
            'drill_speed_unit',
            'filter_floor_leg',
            'filter_static_wall_leg',
            'filter_blocked_item',
            'filter_tier_gate',
            'booster_row_present',
            'booster_row_plain_intensity',
            'booster_row_absent_intensity_one',
            'booster_row_absent_no_consumer',
            'returns_only_four_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_beam_drill_set_stats(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillSetStatsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_SET_STATS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'drill_tier_row_args',
            'drill_speed_formula',
            'drill_speed_unit',
            'filter_floor_leg',
            'filter_static_wall_leg',
            'filter_blocked_item',
            'filter_tier_gate',
            'booster_row_present',
            'booster_row_plain_intensity',
            'booster_row_absent_intensity_one',
            'booster_row_absent_no_consumer',
            'returns_only_four_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
