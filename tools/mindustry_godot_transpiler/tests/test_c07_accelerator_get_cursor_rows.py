import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ACCELERATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceAcceleratorBuildState.gd'
ACCELERATOR_GET_CURSOR_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorGetCursorRowsProof.gd'
ACCELERATOR_GET_CURSOR_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorGetCursorRowsProof.tscn'


class C07AcceleratorGetCursorRowsTests(unittest.TestCase):
    def test_c07_accelerator_get_cursor_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2452']['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_get_cursor_state')
        # The Accelerator tick is live (N2191 advance +
        # N2271 launch + N2342 battery stamp + N2354 launch
        # drain + N2373 draw rows + N2422 bar rows) but
        # NOTHING modeled getCursor(): Accelerator.
        # getCursor() (Accelerator.java:244-245) returns
        # canLaunch() ? SystemCursor.hand : super.
        # getCursor(), and the super branch is BuildingComp.
        # getCursor() (BuildingComp.java:1683-1684):
        # block.configurable && interactable(player.team())
        # ? SystemCursor.hand : SystemCursor.arrow. N2271
        # modeled only the tick-state half of canLaunch()
        # (efficiency / battery / progress / launching) --
        # the environment half (isValid() / !net.client() /
        # state.isCampaign(), Accelerator.java:240) was
        # explicitly NOT modeled, so getCursor stayed
        # deferred (DEFERRED #251). N2452 ports getCursor
        # as ONE pure-only cursor pure (the N2422 bar
        # precedent: the pure returns the cursor as data,
        # it never sets a cursor for real, and it never
        # runs in the tick): the pure takes the
        # caller-supplied gate_can_launch -- the output of
        # the EXISTING pure source_accelerator_can_launch_
        # state, which already covers efficiency / battery
        # / progress / launching -- plus the three
        # environment inputs (is_valid, is_client,
        # is_campaign) and the two super-branch inputs
        # (configurable, interactable), and returns the
        # full can_launch conjunction + the cursor
        # ("hand" when can_launch; else "hand" iff
        # configurable && interactable; else "arrow").
        # Verify-first finding: Accelerator DOES set
        # configurable = true in its constructor
        # (Accelerator.java:77), so the super-hand branch
        # is live for this def whenever the building is
        # interactable. Two new result symbols: the full
        # can_launch gate and the cursor.
        self.assertEqual(
            ledger['N2452']['source_symbols'],
            [
                'source_accelerator_get_cursor_state_result.can_launch',
                'source_accelerator_get_cursor_state_result.cursor',
            ],
        )
        for name in ledger['N2452']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/campaign/Accelerator.java')
                self.assertEqual(symbol['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_get_cursor_state')
        self.assertEqual(ledger['N2452']['runtime_proof'], '/root/C07AcceleratorGetCursorRowsProof')
        self.assertEqual(
            ledger['N2452']['tests'],
            [
                'test_c07_accelerator_get_cursor_rows_registration',
                'test_all_c07_accelerator_get_cursor_rows_input_evidence_is_exact',
                'test_accelerator_get_cursor_rows_state',
                'test_reference_graph_and_actual_c07_accelerator_get_cursor_rows',
            ],
        )
        self.assertTrue(ledger['N2452']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #251 (1-based in
        # DEFERRED-after-advances-28.py): the Accelerator
        # getCursor rows entry is REMOVED -- getCursor is
        # live now, so nothing of the entry remains. The
        # gate is NOT recomputed here: gate_can_launch is
        # the caller-supplied output of the N2271 pure,
        # so no new deferral is added for it. Net 258 - 1
        # = 257.
        self.assertFalse(any(entry.startswith('Accelerator getCursor rows (') for entry in ledger['N2452']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator launch rows (') for entry in ledger['N2452']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator progress / isCoreBuilt rows (') for entry in ledger['N2452']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator shouldConsume gate') for entry in ledger['N2452']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator launch animator rows (') for entry in ledger['N2452']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator per-def stat rows (') for entry in ledger['N2452']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator launchTime / cloudSeed rows (') for entry in ledger['N2452']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator launching flag transitions (') for entry in ledger['N2452']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator disabled-efficiency rows (') for entry in ledger['N2452']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator frame items intake (') for entry in ledger['N2452']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator draw launching-branch rows (') for entry in ledger['N2452']['deferred_exprs']))
        self.assertEqual(len(ledger['N2452']['deferred_exprs']), 257)

    def test_all_c07_accelerator_get_cursor_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2452']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_get_cursor_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/Accelerator.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/net/Net.java',
            'core/src/mindustry/core/GameState.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2452']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_accelerator_get_cursor_rows_state(self):
        accelerator = ACCELERATOR_STATE.read_text(encoding='utf-8')
        # getCursor() (Accelerator.java:244-245):
        # `public Cursor getCursor(){` /
        # `return canLaunch() ? SystemCursor.hand :
        # super.getCursor();` -- the hand cursor when the
        # launch gate passes, else the BuildingComp super
        # branch (BuildingComp.java:1683-1684):
        # `public Cursor getCursor(){` /
        # `return block.configurable &&
        # interactable(player.team()) ? SystemCursor.hand :
        # SystemCursor.arrow;`. canLaunch()
        # (Accelerator.java:239-240) is the conjunction of
        # the environment half -- isValid()
        # (`public boolean isValid(){`, BuildingComp.java:
        # 2030, `return tile.build == self() && !dead();`),
        # !net.client() (`public boolean client(){`,
        # Net.java:404) and state.isCampaign()
        # (`public boolean isCampaign(){`, GameState.java:
        # 73) -- and the tick-state half (efficiency > 0f,
        # battery >= requirement - 0.00001f, progress >=
        # 1f, !launching), which the EXISTING N2271 pure
        # source_accelerator_can_launch_state already
        # evaluates. The new pure takes that gate output
        # as the caller-supplied gate_can_launch and does
        # NOT recompute it. The super branch reads
        # block.configurable -- Accelerator sets
        # `configurable = true;` in its constructor
        # (Accelerator.java:77, verified first for this
        # slice) -- and interactable(player.team())
        # (`public boolean interactable(Team team){`,
        # BuildingComp.java:595, `return state.teams.
        # canInteract(team, team());`). The cursor tokens
        # are the SystemCursor names ("hand" / "arrow"),
        # carried as strings, never resolved to a Godot
        # cursor object (the N2373 color-token precedent).
        # Keep each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this test).
        self.assertIn('static func source_accelerator_get_cursor_state(gate_can_launch: bool, is_valid: bool, is_client: bool, is_campaign: bool, configurable: bool, interactable: bool) -> Dictionary:', accelerator)
        self.assertIn('public Cursor getCursor(){', accelerator)
        self.assertIn('return canLaunch() ? SystemCursor.hand : super.getCursor();', accelerator)
        self.assertIn('public boolean canLaunch(){', accelerator)
        self.assertIn('return isValid() && !net.client() && state.isCampaign() && efficiency > 0f && power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f && progress >= 1f && !launching;', accelerator)
        self.assertIn('return block.configurable && interactable(player.team()) ? SystemCursor.hand : SystemCursor.arrow;', accelerator)
        self.assertIn('configurable = true;', accelerator)
        self.assertIn('public boolean interactable(Team team){', accelerator)
        self.assertIn('return state.teams.canInteract(team, team());', accelerator)
        self.assertIn('public boolean isValid(){', accelerator)
        self.assertIn('return tile.build == self() && !dead();', accelerator)
        self.assertIn('public boolean client(){', accelerator)
        self.assertIn('public boolean isCampaign(){', accelerator)
        self.assertIn('"can_launch"', accelerator)
        self.assertIn('"cursor"', accelerator)
        # The documented limits record the getCursor rows
        # as live (the old "still deferred" getCursor text
        # is gone).
        self.assertIn('getCursor rows live (N2452)', accelerator)
        self.assertNotIn('getCursor (:242-244, canLaunch environment half)', accelerator)
        # The proof's keys drive the cursor pure (the
        # launch hand when the full gate passes, the
        # super hand when the gate fails but the block is
        # configurable + interactable, the arrow when
        # neither branch fires, and one failing
        # environment input each: invalid, client, not
        # campaign).
        proof = ACCELERATOR_GET_CURSOR_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'cursor_hand_launch',
            'cursor_super_hand',
            'cursor_arrow',
            'env_invalid',
            'env_client',
            'env_not_campaign',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check every preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceAcceleratorBuildState.gd")', proof)
        for preload in re.findall(r'preload\("(res://[^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload[len('res://'):]).is_file(), preload)
        self.assertTrue(ACCELERATOR_GET_CURSOR_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07AcceleratorGetCursorRowsProof.gd', ACCELERATOR_GET_CURSOR_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_accelerator_get_cursor_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07AcceleratorGetCursorRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ACCELERATOR_GET_CURSOR_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'cursor_hand_launch',
            'cursor_super_hand',
            'cursor_arrow',
            'env_invalid',
            'env_client',
            'env_not_campaign',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
