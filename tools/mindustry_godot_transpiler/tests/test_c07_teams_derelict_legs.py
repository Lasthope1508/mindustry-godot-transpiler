import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
DERELICT_LEGS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamsDerelictLegsProof.gd'


class C07TeamsDerelictLegsTests(unittest.TestCase):
    def test_c07_teams_derelict_legs_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2427']['godot_owner'], 'SourceTeamsRuntimeState.source_team_data_destroy_to_derelict_state')
        # TeamData.destroyToDerelict() (Teams.java:328-360) +
        # TeamData.timeDestroy() (Teams.java:362-394): the 8
        # leftover legs N2395 did not register -- the two
        # `for` loops, the CoreBuild branch + core kill, the
        # per-unit delayed kill, the timeDestroy loop, the
        # scheduleDerelict(build) call, the `if(any){` gate
        # and the result/non-core floor gate. The GD functions
        # already exist (N2395): this slice extends them -- it
        # adds no new owner, no new contract and no new
        # schema (the N2425 precedent: a leg-slice in an
        # already-owned method). `scheduleDerelict(build);`
        # (:370, variable `build`) is NOT the same expr as
        # `scheduleDerelict(b);` (:347, variable `b`, already
        # owned at N2395) -- the two are registered
        # separately. `plans.clear();` (:335) stays N1143
        # evidence only; `active()` stays N2074/N2075.
        self.assertEqual(
            ledger['N2427']['java_method'],
            'TeamData.destroyToDerelict()/TeamData.timeDestroy()',
        )
        self.assertEqual(
            ledger['N2427']['exact_exprs'],
            [
                'for(var b : builds){',
                'if(b instanceof CoreBuild){',
                'b.kill();',
                'u.kill();',
                'for(var build : builds){',
                'scheduleDerelict(build);',
                'if(any){',
                'if(result != null && !cores.contains(c -> c.within(t, range))){',
            ],
        )
        self.assertEqual(
            ledger['N2427']['source_symbols'],
            [
                'source_team_data_destroy_to_derelict_state_result.builds',
                'source_team_data_destroy_to_derelict_state_result.killed_cores',
                'source_team_data_destroy_to_derelict_state_result.scheduled_unit_kills',
                'source_team_data_time_destroy_state_result.builds',
                'source_team_data_time_destroy_state_result.scheduled_kills',
                'source_team_data_time_destroy_state_result.any_replacement_present',
                'source_team_data_time_destroy_state_result.floor_changes',
            ],
        )
        for name in ledger['N2427']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team'))
        self.assertEqual(ledger['N2427']['runtime_proof'], '/root/C07TeamsDerelictLegsProof')
        self.assertEqual(
            ledger['N2427']['tests'],
            [
                'test_c07_teams_derelict_legs_registration',
                'test_all_c07_teams_derelict_legs_input_evidence_is_exact',
                'test_teams_derelict_legs_state',
                'test_reference_graph_and_actual_c07_teams_derelict_legs',
            ],
        )
        self.assertTrue(ledger['N2427']['deferred_exprs'])

    def test_all_c07_teams_derelict_legs_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2427']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team'))
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2427']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_derelict_legs_state(self):
        state = TEAMS_STATE.read_text(encoding='utf-8')
        # The two GD functions already exist (N2395); N2427
        # registers the 8 leftover legs they already
        # implement -- the destroy loop over builds, the
        # CoreBuild branch killing cores at once, the
        # per-unit delayed kill (same-team only when the
        # recorded action runs), the timeDestroy loop, the
        # scheduleDerelict(build) call, the `if(any){` gate
        # opening the circle, and the result/non-core floor
        # gate. Each leg is quoted verbatim on its own
        # comment line (the N2378 precedent: never split an
        # exact expr across lines).
        self.assertIn('static func source_team_data_destroy_to_derelict_state(building_tree_objects: Variant, plans: Array, units: Array, team_id: int, derelict_buffer: Array, unit_delays: Array, chance_rolls: Array, kill_delays: Array, destroy_payload: Callable, time_run: Callable, kill_build: Callable, kill_unit: Callable, add_plan: Callable, set_teams: Callable) -> Dictionary:', state)
        self.assertIn('static func source_team_data_time_destroy_state(x: float, y: float, range: float, building_tree_objects: Variant, derelict_buffer: Array, chance_rolls: Array, kill_delays: Array, sector: Variant, circle_tiles: Array, tilesize: float, destroy_payload: Callable, time_run: Callable, kill_build: Callable, add_plan: Callable, set_teams: Callable, set_floor: Callable) -> Dictionary:', state)
        for expr in [
            'for(var b : builds){',
            'if(b instanceof CoreBuild){',
            'b.kill();',
            'u.kill();',
            'for(var build : builds){',
            'scheduleDerelict(build);',
            'if(any){',
            'if(result != null && !cores.contains(c -> c.within(t, range))){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive one leg each: the destroy
        # loop visits every build, the CoreBuild branch is
        # taken only for cores, the core kill really calls
        # kill_build, the per-unit kill runs only for a unit
        # still on the team (a unit that switched teams by
        # the time the action runs is spared), the
        # timeDestroy loop visits every build, the
        # qualifying build goes through scheduleDerelict,
        # the `if(any){` gate opens the circle only when a
        # replacement is present, and the floor gate changes
        # a floor only when the replacement result is
        # non-null and no core is nearby.
        proof = DERELICT_LEGS_PROOF.read_text(encoding='utf-8')
        for key in [
            'for_b_builds_iterates_all',
            'core_branch_taken',
            'core_kill_called',
            'unit_kill_executes_same_team_only',
            'for_build_builds_iterates_all',
            'schedule_derelict_build_called',
            'any_gate_opens_circle',
            'result_and_no_core_gate',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_derelict_legs(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamsDerelictLegsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAMS_DERELICT_LEGS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'for_b_builds_iterates_all',
            'core_branch_taken',
            'core_kill_called',
            'unit_kill_executes_same_team_only',
            'for_build_builds_iterates_all',
            'schedule_derelict_build_called',
            'any_gate_opens_circle',
            'result_and_no_core_gate',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
