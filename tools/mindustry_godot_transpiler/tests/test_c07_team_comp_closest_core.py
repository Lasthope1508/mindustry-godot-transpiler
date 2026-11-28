import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RULES_STATE = ROOT / 'godot-mindustry/src/game/SourceRulesRuntimeState.gd'
CLOSEST_CORE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamCompClosestCoreProof.gd'

PROOF_KEYS = [
    'closest_core_passthrough',
    'closest_core_null_passthrough',
    'closest_core_precomputed_input',
    'closest_core_ignores_position',
    'closest_core_distinct_cores',
    'closest_core_matches_callee_result',
    'closest_core_idempotent',
    'closest_core_returns_only_one_key',
]


class C07TeamCompClosestCoreTests(unittest.TestCase):
    def test_c07_team_comp_closest_core_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2489']['godot_owner'], 'SourceRulesRuntimeState.source_team_comp_closest_core_state')
        # TeamComp.closestCore() (TeamComp.java:31-34):
        #     @Nullable
        #     public CoreBuild closestCore(){
        #         return state.teams.closestCore(x, y, team);
        #     }
        # A pure delegate: the callee Teams.closestCore
        # (Teams.java:56-58) is already ported (N2392), so
        # its result arrives as the precomputed
        # closest_core input (the precomputed-input
        # precedent: N2477 buildRotation, N2488
        # coloredName) -- the delegate never re-runs the
        # Geometry.findClosest search. The @Nullable
        # return passes through: null when no core is
        # near, exactly as the callee returns it. The
        # `x` / `y` / `team` of the call are the entity's
        # own @Import fields (TeamComp.java:13, 15), so
        # they arrive as evidence inputs (team by id,
        # the N2099 cheating precedent).
        self.assertEqual(
            ledger['N2489']['java_method'],
            'TeamComp.closestCore()',
        )
        self.assertEqual(
            ledger['N2489']['source_symbols'],
            [
                'source_team_comp_closest_core_state_input.x',
                'source_team_comp_closest_core_state_input.y',
                'source_team_comp_closest_core_state_input.team_id',
                'source_team_comp_closest_core_state_input.closest_core',
                'source_team_comp_closest_core_state_result.closest_core',
            ],
        )
        for name in ledger['N2489']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/entities/comp/TeamComp.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_team_comp_closest_core_state'))
        self.assertEqual(ledger['N2489']['runtime_proof'], '/root/C07TeamCompClosestCoreProof')
        self.assertEqual(
            ledger['N2489']['tests'],
            [
                'test_c07_team_comp_closest_core_registration',
                'test_all_c07_team_comp_closest_core_input_evidence_is_exact',
                'test_team_comp_closest_core_state',
                'test_reference_graph_and_actual_c07_team_comp_closest_core',
            ],
        )
        self.assertTrue(ledger['N2489']['deferred_exprs'])

    def test_all_c07_team_comp_closest_core_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2489']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceRulesRuntimeState.source_team_comp_closest_core_state'))
        slice_sources = {
            'core/src/mindustry/entities/comp/TeamComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2489']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_team_comp_closest_core_state(self):
        rules = RULES_STATE.read_text(encoding='utf-8')
        # TeamComp.closestCore() (TeamComp.java:31-34) is a
        # pure delegate: `return
        # state.teams.closestCore(x, y, team);` -- the
        # callee result arrives precomputed, so the GD
        # function passes it through whole. Null passes
        # through too (the @Nullable return): no default
        # core, no empty-dict fallback, no guard.
        self.assertIn('static func source_team_comp_closest_core_state(x: float, y: float, team_id: int, closest_core: Variant) -> Dictionary:', rules)
        self.assertIn('return {"closest_core": closest_core}', rules)
        # Function order follows Java order: cheating()
        # (TeamComp.java:17-19) comes before closestCore()
        # (:31-34), so source_team_comp_closest_core_state
        # sits after source_team_cheating_state in this
        # file (inFogTo :21-23 and core() :27-29 are
        # unported, so cheating is the nearest ported
        # neighbour above it).
        self.assertLess(
            rules.index('static func source_team_cheating_state('),
            rules.index('static func source_team_comp_closest_core_state('),
        )
        # The proof drives the pure function with synthetic
        # inputs (no live tick, no game state): a core dict
        # passes through verbatim, null passes through,
        # the precomputed value is used untouched, the
        # result does not depend on x/y/team, distinct
        # cores stay distinct, the value matches what the
        # N2392 callee returns for the same core,
        # idempotence, and exactly one result key.
        proof = CLOSEST_CORE_PROOF.read_text(encoding='utf-8')
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_team_comp_closest_core(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamCompClosestCoreProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAM_COMP_CLOSEST_CORE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in PROOF_KEYS:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
