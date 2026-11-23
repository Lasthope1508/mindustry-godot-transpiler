import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BOOSTER_AMOUNT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillSetStatsBoosterAmountProof.gd'

PROOF_KEYS = [
    'booster_amount_impact',
    'booster_amount_eruption',
    'booster_amount_class_default',
    'booster_amount_zero',
    'booster_amount_distinct_from_intensity',
    'booster_amount_absent_intensity_one',
    'booster_amount_absent_no_consumer',
]


class C07DrillSetStatsBoosterAmountTests(unittest.TestCase):
    def test_c07_drill_set_stats_booster_amount_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2434']['godot_owner'], 'SourceBurstDrillBuildState.source_drill_set_stats_state')
        # Drill.setStats() (Drill.java:175-191): the `:187`
        # line `consBase.amount,` -- the speedBoosters
        # amount arg, the per-frame liquid amount
        # (`public float amount;`,
        # ConsumeLiquidBase.java:8) -- was never registered
        # as an expr. N2332 registered the call opener
        # (:186) and the squared-intensity tail (:188) and
        # used the amount only as the `booster_amount`
        # param value of the already-live func
        # source_drill_set_stats_state, which returns it as
        # `booster_row["amount"]`. This slice extends that
        # func -- it adds no new owner, no new contract
        # and no new schema (the N2427 / N2430
        # registration-only precedent). Main-thread
        # decision: a mid-call arg line IS registrable
        # when it was never registered under any form --
        # NOT the TractorBeam :165 case (batch 35 §4c),
        # where N1239 had already registered all 4 call
        # fragments including the args. NOT the BurstDrill
        # override line (BurstDrill.java:65, PLAIN
        # intensity, N2309): this is Drill.java:187,
        # SQUARED intensity on the next line.
        self.assertEqual(
            ledger['N2434']['java_method'],
            'Drill.setStats()',
        )
        self.assertEqual(
            ledger['N2434']['exact_exprs'],
            [
                'consBase.amount,',
            ],
        )
        self.assertEqual(
            ledger['N2434']['source_symbols'],
            [
                'source_drill_set_stats_state_result.drill_tier_row',
                'source_drill_set_stats_state_result.drill_speed_row',
                'source_drill_set_stats_state_result.booster_row_removed',
                'source_drill_set_stats_state_result.booster_row',
            ],
        )
        for name in ledger['N2434']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceBurstDrillBuildState.source_drill_set_stats_state'))
        self.assertEqual(ledger['N2434']['runtime_proof'], '/root/C07DrillSetStatsBoosterAmountProof')
        self.assertEqual(
            ledger['N2434']['tests'],
            [
                'test_c07_drill_set_stats_booster_amount_registration',
                'test_all_c07_drill_set_stats_booster_amount_input_evidence_is_exact',
                'test_drill_set_stats_booster_amount_state',
                'test_reference_graph_and_actual_c07_drill_set_stats_booster_amount',
            ],
        )
        self.assertTrue(ledger['N2434']['deferred_exprs'])

    def test_all_c07_drill_set_stats_booster_amount_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2434']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceBurstDrillBuildState.source_drill_set_stats_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2434']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_set_stats_booster_amount_state(self):
        state = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # The GD function already exists (N2332); N2434
        # registers the 1 leftover arg line it already
        # implements -- `consBase.amount,` (:187) is quoted
        # verbatim on its own comment line inside
        # source_drill_set_stats_state (the N2378
        # precedent: never split an exact expr across
        # lines), and the func returns it as
        # `booster_row["amount"] = booster_amount`.
        self.assertIn('static func source_drill_set_stats_state(frame: Dictionary, drill_time: float, hardness_drill_multiplier: float, size: int, tier: int, drill_multipliers: Dictionary, blocked_items: Variant, liquid_boost_intensity: float, booster_consumer_found: bool, booster_amount: float, booster_consumes: bool) -> Dictionary:', state)
        for expr in [
            'consBase.amount,',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        self.assertIn('"amount": booster_amount', state)
        # The proof's keys drive the amount arg: impact
        # 3f/60f and eruption 0.75f/60f per-def amounts,
        # the class-default 0.05, a zero amount flowing
        # through, the amount slot distinct from the
        # squared intensity, and no row (no amount to pin)
        # when the guard does not run.
        proof = BOOSTER_AMOUNT_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_drill_set_stats_booster_amount(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DrillSetStatsBoosterAmountProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DRILL_SET_STATS_BOOSTER_AMOUNT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
