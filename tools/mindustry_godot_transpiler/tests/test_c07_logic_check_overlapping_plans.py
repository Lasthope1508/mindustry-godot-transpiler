import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
GAME_LOOP_STATE = ROOT / 'godot-mindustry/src/game/SourceGameLoopRuntimeState.gd'
CHECK_OVERLAPPING_PLANS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LogicCheckOverlappingPlansProof.gd'

PROOF_KEYS = [
    'check_overlapping_plans_no_overlap',
    'check_overlapping_plans_one_overlap',
    'check_overlapping_plans_mixed',
]


class C07LogicCheckOverlappingPlansTests(unittest.TestCase):
    def test_c07_logic_check_overlapping_plans_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2441']['godot_owner'], 'SourceGameLoopRuntimeState.source_game_loop_check_overlapping_plans_state')
        # Logic.checkOverlappingPlans() (Logic.java:255-266):
        # the 8 body exprs :256-:263 -- plans whose block
        # bounds overlap the tile block's bounds are marked
        # removed and dropped from the team plans. :256
        # `TeamData data = team.data();` is a TWIN-REGISTER:
        # already owned by local N2430
        # (Teams.updateTeamStats(), a different method/owner)
        # -- same literal under a new owner, precedent batch
        # 37 slot 1 + N2194-N2200. The call-sites
        # `checkOverlappingPlans(event.team, event.tile);`
        # (Logic.java:55) and `checkOverlappingPlans(e.build.team,
        # e.build.tile);` (Logic.java:65) are NOT registered
        # here -- they belong to the 16 handler ctor slices,
        # waiting on the bus decision. Tmp.r1 / Tmp.r2 are
        # shared temp rects and are NOT ported -- bounds
        # arrive as data (tile["bounds"] + plan["bounds"]).
        self.assertEqual(
            ledger['N2441']['java_method'],
            'Logic.checkOverlappingPlans()',
        )
        self.assertEqual(
            ledger['N2441']['exact_exprs'],
            [
                'TeamData data = team.data();',
                'Iterator<BlockPlan> it = data.plans.iterator();',
                'var bounds = tile.block().bounds(tile.x, tile.y, Tmp.r1);',
                'while(it.hasNext()){',
                'BlockPlan b = it.next();',
                'if(bounds.overlaps(b.block.bounds(b.x, b.y, Tmp.r2))){',
                'b.removed = true;',
                'it.remove();',
            ],
        )
        self.assertEqual(
            ledger['N2441']['source_symbols'],
            [
                'source_game_loop_check_overlapping_plans_state_result.removed_plans',
                'source_game_loop_check_overlapping_plans_state_result.kept_plans',
            ],
        )
        for name in ledger['N2441']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/core/Logic.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameLoopRuntimeState.source_game_loop_check_overlapping_plans_state'))
        self.assertEqual(ledger['N2441']['runtime_proof'], '/root/C07LogicCheckOverlappingPlansProof')
        self.assertEqual(
            ledger['N2441']['tests'],
            [
                'test_c07_logic_check_overlapping_plans_registration',
                'test_all_c07_logic_check_overlapping_plans_input_evidence_is_exact',
                'test_logic_check_overlapping_plans_state',
                'test_reference_graph_and_actual_c07_logic_check_overlapping_plans',
            ],
        )
        self.assertTrue(ledger['N2441']['deferred_exprs'])

    def test_all_c07_logic_check_overlapping_plans_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2441']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceGameLoopRuntimeState.source_game_loop_check_overlapping_plans_state'))
        slice_sources = {
            'core/src/mindustry/core/Logic.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2441']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_logic_check_overlapping_plans_state(self):
        state = GAME_LOOP_STATE.read_text(encoding='utf-8')
        # The GD function is new (N2441): a pure transform
        # over the frame inputs, returning the `removed_plans`
        # / `kept_plans` envelope. The exact Java exprs are
        # quoted verbatim on their own comment lines inside
        # source_game_loop_check_overlapping_plans_state (the
        # N2378 precedent: never split an exact expr across
        # lines).
        self.assertIn('static func source_game_loop_check_overlapping_plans_state(team_data: Dictionary, tile: Dictionary) -> Dictionary:', state)
        for expr in [
            'TeamData data = team.data();',
            'Iterator<BlockPlan> it = data.plans.iterator();',
            'var bounds = tile.block().bounds(tile.x, tile.y, Tmp.r1);',
            'while(it.hasNext()){',
            'BlockPlan b = it.next();',
            'if(bounds.overlaps(b.block.bounds(b.x, b.y, Tmp.r2))){',
            'b.removed = true;',
            'it.remove();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        self.assertIn('"removed_plans":', state)
        self.assertIn('"kept_plans":', state)
        self.assertIn('PORT_GAME_SOURCE_GAME_LOOP_CHECK_OVERLAPPING_PLANS_STATE', state)
        # The proof's keys pin the transform: no overlap ->
        # nothing removed; one overlap -> removed and marked;
        # mixed plans -> only the overlapping ones removed.
        proof = CHECK_OVERLAPPING_PLANS_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_logic_check_overlapping_plans(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LogicCheckOverlappingPlansProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LOGIC_CHECK_OVERLAPPING_PLANS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
