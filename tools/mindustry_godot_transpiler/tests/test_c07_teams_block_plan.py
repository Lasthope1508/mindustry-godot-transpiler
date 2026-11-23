import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
BLOCK_PLAN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamsBlockPlanProof.gd'


class C07TeamsBlockPlanTests(unittest.TestCase):
    def test_c07_teams_block_plan_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2409']['godot_owner'], 'SourceTeamsRuntimeState.source_teams_block_plan_state')
        # Teams.BlockPlan ctor (Teams.java:497-503), one slice
        # (main-thread decision 2026-11-22, batch 28 slot 2:
        # 3 exprs is enough -- the N2407 2-expr precedent).
        # The ctor is a plain data-class constructor: it
        # stores x/y (narrowed to short), rotation, block
        # and config in the new record. `this.rotation =
        # rotation;` is owned N1770 and `this.block = block;`
        # is owned N1771 -- evidence only, never
        # re-registered. The mutable `removed` field is
        # outside the ctor and is NOT part of this slice.
        self.assertEqual(
            ledger['N2409']['java_method'],
            'BlockPlan(int x, int y, short rotation, Block block, Object config)',
        )
        self.assertEqual(
            ledger['N2409']['source_symbols'],
            [
                'source_teams_block_plan_state_result.x',
                'source_teams_block_plan_state_result.y',
                'source_teams_block_plan_state_result.rotation',
                'source_teams_block_plan_state_result.block',
                'source_teams_block_plan_state_result.config',
            ],
        )
        for name in ledger['N2409']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_'))
        self.assertEqual(ledger['N2409']['runtime_proof'], '/root/C07TeamsBlockPlanProof')
        self.assertEqual(
            ledger['N2409']['tests'],
            [
                'test_c07_teams_block_plan_registration',
                'test_all_c07_teams_block_plan_input_evidence_is_exact',
                'test_teams_block_plan_state',
                'test_reference_graph_and_actual_c07_teams_block_plan',
            ],
        )
        self.assertTrue(ledger['N2409']['deferred_exprs'])

    def test_all_c07_teams_block_plan_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2409']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_teams_'))
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2409']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_block_plan_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # Teams.BlockPlan ctor (Teams.java:497-503): stores
        # x/y narrowed to short, rotation, block and config
        # in the new record; `removed` is a mutable field
        # outside the ctor and is not part of the record.
        self.assertIn('static func source_teams_block_plan_state(x: int, y: int, rotation: int, block: Variant, config: Variant) -> Dictionary:', teams)
        for expr in [
            'this.x = (short)x;',
            'this.y = (short)y;',
            'this.config = config;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof's keys drive the pure function with
        # synthetic inputs (no live tick): the happy path
        # stores x/y/config, rotation and block pass
        # through, x/y are narrowed to 16-bit signed
        # (70000 -> 4464, -1 stays -1), null block/config
        # pass through, and the record has exactly five keys.
        proof = BLOCK_PLAN_PROOF.read_text(encoding='utf-8')
        for key in [
            'block_plan_ctor_sets_x_y_config',
            'block_plan_ctor_keeps_rotation_and_block',
            'block_plan_ctor_narrows_xy_to_short',
            'block_plan_ctor_accepts_null_block_and_config',
            'block_plan_ctor_returns_only_five_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_block_plan(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamsBlockPlanProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAMS_BLOCK_PLAN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'block_plan_ctor_sets_x_y_config',
            'block_plan_ctor_keeps_rotation_and_block',
            'block_plan_ctor_narrows_xy_to_short',
            'block_plan_ctor_accepts_null_block_and_config',
            'block_plan_ctor_returns_only_five_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
