import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_GET_DRILL_TIME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillGetDrillTimeProof.gd'

PROOF_KEYS = [
    'multiplier_one_returns_drill_time',
    'multiplier_two_halves',
    'unknown_item_default_one_returns_drill_time',
    'multiplier_zero_is_inf',
    'negative_multiplier_passes_through',
    'large_plasma_bore_def',
    'returns_only_one_key',
    'idempotent_second_call',
]


class C07BeamDrillGetDrillTimeTests(unittest.TestCase):
    def test_c07_beam_drill_get_drill_time_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2478']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_get_drill_time_state')
        # BeamDrill.getDrillTime() (BeamDrill.java:216-218):
        #     public float getDrillTime(Item item){
        #         return drillTime / drillMultipliers.get(item, 1f);
        #     }
        # drillTime is the BeamDrill field (`public float
        # drillTime = 200f;`, BeamDrill.java:39) -- NOT
        # Drill's `public float drillTime = 300;`
        # (Drill.java:36): BeamDrill extends Block, not
        # Drill. drillMultipliers is (`public
        # ObjectFloatMap<Item> drillMultipliers = new
        # ObjectFloatMap<>();`, BeamDrill.java:47) and a
        # missing item defaults to 1f. Per-def drillTime:
        # plasma-bore 160f, large-plasma-bore 100f
        # (Blocks.java:3042/3055); neither def puts any
        # multiplier, so in practice every item drills at
        # the default 1f. TRAPS: multiplier 0 gives
        # Infinity (Java float division, no exception);
        # a negative multiplier passes through (no clamp);
        # drillTime is an input, NOT hardcoded 200f.
        # TWIN-REGISTER (main-thread approval 2026-11-26):
        # the same body was already ported per-class for
        # BurstDrill (N2344, owner
        # SourceBurstDrillBuildState.source_burst_drill_get_drill_time_state)
        # and Drill (N690/N1367, owner
        # PortGame.source_drill_delay); the body literal
        # is also an exact_expr of N2294 (evidence only).
        # No beam_drill_get_drill_time symbol existed
        # before this slice (registry 0-hit), so this
        # adds a real new GD function -- NOT a duplicate
        # like TeamData.active(). Precedent: N2474/N2477,
        # N2421, N2389, N2418.
        self.assertEqual(
            ledger['N2478']['java_method'],
            'BeamDrill.getDrillTime(Item)',
        )
        self.assertEqual(
            ledger['N2478']['source_symbols'],
            [
                'source_beam_drill_get_drill_time_state_input.drill_time',
                'source_beam_drill_get_drill_time_state_input.drill_multiplier',
                'source_beam_drill_get_drill_time_state_result.drill_time',
            ],
        )
        for name in ledger['N2478']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BeamDrill.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_get_drill_time_state')
        self.assertEqual(ledger['N2478']['runtime_proof'], '/root/C07BeamDrillGetDrillTimeProof')
        self.assertEqual(
            ledger['N2478']['tests'],
            [
                'test_c07_beam_drill_get_drill_time_registration',
                'test_all_c07_beam_drill_get_drill_time_input_evidence_is_exact',
                'test_beam_drill_get_drill_time_state',
                'test_reference_graph_and_actual_c07_beam_drill_get_drill_time',
            ],
        )
        self.assertTrue(ledger['N2478']['deferred_exprs'])

    def test_all_c07_beam_drill_get_drill_time_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2478']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_get_drill_time_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2478']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_get_drill_time_state(self):
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # BeamDrill.getDrillTime() (BeamDrill.java:216-218):
        #     return drillTime / drillMultipliers.get(item, 1f);
        # The multiplier arrives PRE-RESOLVED (the caller
        # applies `drillMultipliers.get(item, 1f)`, default
        # 1f, at the call boundary -- a null item resolves
        # to 1.0 there, so this pure function never sees a
        # null key and never guesses Arc ObjectFloatMap
        # null-key semantics). TRAPS: multiplier 0 gives
        # inf (float division, no exception), a negative
        # multiplier passes through (no clamp), drillTime
        # is a per-def input (class default 200f,
        # plasma-bore 160f, large-plasma-bore 100f),
        # NOT hardcoded.
        self.assertIn('static func source_beam_drill_get_drill_time_state(drill_time: float, drill_multiplier: float) -> Dictionary:', beam_drill)
        self.assertIn('return {"drill_time": drill_time / drill_multiplier}', beam_drill)
        # Function order follows Java order: canPlaceOn()
        # (:198-214) comes before getDrillTime() (:216-218),
        # which comes before BeamDrillBuild.drawSelect()
        # (:231-235), so source_beam_drill_can_place_on_state
        # comes before source_beam_drill_get_drill_time_state
        # which comes before
        # source_beam_drill_draw_select_state.
        self.assertLess(
            beam_drill.index('static func source_beam_drill_can_place_on_state('),
            beam_drill.index('static func source_beam_drill_get_drill_time_state('),
        )
        self.assertLess(
            beam_drill.index('static func source_beam_drill_get_drill_time_state('),
            beam_drill.index('static func source_beam_drill_draw_select_state('),
        )
        # The proof drives the pure function directly with
        # the per-def drill times and pre-resolved
        # multipliers: class default 200f / 1 = 200, 200 /
        # 2 = 100, plasma-bore 160f / 1 (unknown item,
        # default) = 160, 200 / 0 = inf, 200 / -2 = -100,
        # large-plasma-bore 100f / 2 = 50; one key only;
        # idempotent.
        proof = BEAM_DRILL_GET_DRILL_TIME_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_beam_drill_get_drill_time(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillGetDrillTimeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_GET_DRILL_TIME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
