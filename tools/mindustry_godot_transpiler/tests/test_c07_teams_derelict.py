import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TEAMS_STATE = ROOT / 'godot-mindustry/src/game/SourceTeamsRuntimeState.gd'
DERELICT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TeamsDerelictProof.gd'


class C07TeamsDerelictTests(unittest.TestCase):
    def test_c07_teams_derelict_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2395']['godot_owner'], 'SourceTeamsRuntimeState.source_team_data_destroy_to_derelict_state')
        # TeamData.destroyToDerelict()+timeDestroy()+
        # scheduleDerelict()+finishScheduleDerelict()
        # (Teams.java:328-360 + :362-394 + :396-409 + :411-414),
        # one grouped slice (main-thread decision 2026-11-21,
        # the N2380 seven-method / N2374 five-accessor group
        # precedent): four methods of one derelict lifecycle --
        # two public methods calling the two private ones
        # (scheduleDerelict is only called from these two,
        # finishScheduleDerelict likewise). Four GD functions,
        # one ledger entry, one owner per function (the N2380
        # multi-function precedent; the N2378 lesson: a
        # contract owner must be an actual GD function, so the
        # group label `source_team_data_derelict_state` is NOT
        # an owner -- the ledger godot_owner is the first
        # function owner,
        # `source_team_data_destroy_to_derelict_state`).
        # `plans.clear();` is already the exact_expr of N1143
        # -- the clear behavior IS implemented here (the
        # passed plans Array is cleared in place) but the
        # expr is cited as evidence only, not re-registered.
        # `b.kill();` / `u.kill();` are generic -- not
        # registered; the kills arrive as kill_build /
        # kill_unit Callable params. `Call.destroyPayload` /
        # `Call.setTeams` are network calls -- they arrive as
        # destroy_payload / set_teams Callable params and are
        # recorded in the frame, never sent as packets.
        # `Time.run` arrives as a time_run Callable recording
        # delay+action; `Mathf.chance` / `Mathf.random` arrive
        # as explicit chance_roll / delay params. The
        # QuadTree / sector / Geometry.circle / world tile
        # lookups arrive as explicit Array/Dictionary params.
        self.assertEqual(
            ledger['N2395']['java_method'],
            'TeamData.destroyToDerelict()/TeamData.timeDestroy()/TeamData.scheduleDerelict()/TeamData.finishScheduleDerelict()',
        )
        self.assertEqual(
            ledger['N2395']['source_symbols'],
            [
                'source_team_data_destroy_to_derelict_state_result.builds',
                'source_team_data_destroy_to_derelict_state_result.plans',
                'source_team_data_destroy_to_derelict_state_result.derelict_buffer',
                'source_team_data_destroy_to_derelict_state_result.killed_cores',
                'source_team_data_destroy_to_derelict_state_result.destroy_payload_calls',
                'source_team_data_destroy_to_derelict_state_result.scheduled_kills',
                'source_team_data_destroy_to_derelict_state_result.add_plan_calls',
                'source_team_data_destroy_to_derelict_state_result.set_teams_calls',
                'source_team_data_destroy_to_derelict_state_result.scheduled_unit_kills',
                'source_team_data_time_destroy_state_result.builds',
                'source_team_data_time_destroy_state_result.derelict_buffer',
                'source_team_data_time_destroy_state_result.destroy_payload_calls',
                'source_team_data_time_destroy_state_result.scheduled_kills',
                'source_team_data_time_destroy_state_result.add_plan_calls',
                'source_team_data_time_destroy_state_result.set_teams_calls',
                'source_team_data_time_destroy_state_result.has_sector',
                'source_team_data_time_destroy_state_result.any_replacement_present',
                'source_team_data_time_destroy_state_result.circle_radius_tiles',
                'source_team_data_time_destroy_state_result.floor_changes',
                'source_team_data_schedule_derelict_state_result.derelict_buffer',
                'source_team_data_schedule_derelict_state_result.destroy_payload_calls',
                'source_team_data_schedule_derelict_state_result.scheduled_kill',
                'source_team_data_schedule_derelict_state_result.add_plan_calls',
                'source_team_data_finish_schedule_derelict_state_result.derelict_buffer',
                'source_team_data_finish_schedule_derelict_state_result.set_teams_calls',
            ],
        )
        for name in ledger['N2395']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/game/Teams.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team'))
        self.assertEqual(ledger['N2395']['runtime_proof'], '/root/C07TeamsDerelictProof')
        self.assertEqual(
            ledger['N2395']['tests'],
            [
                'test_c07_teams_derelict_registration',
                'test_all_c07_teams_derelict_input_evidence_is_exact',
                'test_teams_derelict_state',
                'test_reference_graph_and_actual_c07_teams_derelict',
            ],
        )
        self.assertTrue(ledger['N2395']['deferred_exprs'])

    def test_all_c07_teams_derelict_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2395']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTeamsRuntimeState.source_team'))
        slice_sources = {
            'core/src/mindustry/game/Teams.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2395']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_teams_derelict_state(self):
        teams = TEAMS_STATE.read_text(encoding='utf-8')
        # TeamData.destroyToDerelict()+timeDestroy()+
        # scheduleDerelict()+finishScheduleDerelict()
        # (Teams.java:328-360 + :362-394 + :396-409 +
        # :411-414): destroyToDerelict kills cores at once,
        # schedules the rest, flushes the buffer and
        # schedules a delayed kill per unit (same-team only);
        # timeDestroy schedules in-range buildings and, when
        # a sector with a present replacement exists, swaps
        # floors in a circle; scheduleDerelict buffers the
        # pos, destroys a unit payload, maybe schedules a
        # delayed kill (chance 0.2), and adds a plan;
        # finishScheduleDerelict flushes the buffer in
        # chunks of 1000 via Call.setTeams then clears it.
        self.assertIn('static func source_team_data_destroy_to_derelict_state(building_tree_objects: Variant, plans: Array, units: Array, team_id: int, derelict_buffer: Array, unit_delays: Array, chance_rolls: Array, kill_delays: Array, destroy_payload: Callable, time_run: Callable, kill_build: Callable, kill_unit: Callable, add_plan: Callable, set_teams: Callable) -> Dictionary:', teams)
        self.assertIn('static func source_team_data_time_destroy_state(x: float, y: float, range: float, building_tree_objects: Variant, derelict_buffer: Array, chance_rolls: Array, kill_delays: Array, sector: Variant, circle_tiles: Array, tilesize: float, destroy_payload: Callable, time_run: Callable, kill_build: Callable, add_plan: Callable, set_teams: Callable, set_floor: Callable) -> Dictionary:', teams)
        self.assertIn('static func source_team_data_schedule_derelict_state(build_pos: int, has_unit_payload: bool, derelict_buffer: Array, destroy_payload: Callable, chance_roll: float, random_delay: float, time_run: Callable, kill_build: Callable, add_plan: Callable) -> Dictionary:', teams)
        self.assertIn('static func source_team_data_finish_schedule_derelict_state(derelict_buffer: Array, set_teams: Callable) -> Dictionary:', teams)
        for expr in [
            'var builds = new Seq<Building>();',
            'if(buildingTree != null){',
            'buildingTree.getObjects(builds);',
            'if(b.block.privileged) continue;',
            'scheduleDerelict(b);',
            'finishScheduleDerelict();',
            'units.each(u -> Time.run(Mathf.random(0f, 60f * 5f), () -> {',
            'if(u.team == team){',
            'buildingTree.intersect(x - range, y - range, range * 2f, range * 2f, builds);',
            'if(!build.block.privileged && build.within(x, y, range) && !cores.contains(c -> c.within(build, range))){',
            'var sector = state.getSector();',
            'if(sector != null){',
            'for(var entry : sector.planet.sectorCaptureReplacements){',
            'if(indexer.isBlockPresent(entry.key)){',
            'Geometry.circle(World.toTile(x), World.toTile(y), world.width(), world.height(), Mathf.round(range / tilesize), (tx, ty) -> {',
            'Tile t = world.rawTile(tx, ty);',
            'Block result = sector.planet.sectorCaptureReplacements.get(t.floor());',
            't.setFloor(result.asFloor());',
            'derelictBuffer.add(build.pos());',
            'if(build.getPayload() instanceof UnitPayload){',
            'Call.destroyPayload(build);',
            'if(Mathf.chance(0.2)){',
            'Time.run(Mathf.random(0f, 60f * 6f), build::kill);',
            'build.addPlan(false, true);',
            'derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));',
            'derelictBuffer.clear();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, teams)
        # The proof's keys drive the four pure functions with
        # synthetic inputs (no live tick, no packets, no real
        # kills): scheduleDerelict buffers the pos / calls
        # destroyPayload only with a unit payload / schedules
        # the delayed kill only below chance 0.2 (and the
        # recorded action really kills when run) / calls
        # addPlan; finishScheduleDerelict chunks 1000 at a
        # time and clears; destroyToDerelict kills cores,
        # skips privileged builds, clears plans, empties the
        # buffer, and schedules a per-unit delayed kill whose
        # action kills same-team units only; timeDestroy
        # schedules in-range non-core buildings only and
        # swaps floors only with a sector and a present
        # replacement, never for near-core tiles.
        proof = DERELICT_PROOF.read_text(encoding='utf-8')
        for key in [
            'schedule_buffers_pos',
            'schedule_destroy_payload_when_unit_payload',
            'schedule_no_destroy_payload_without_unit_payload',
            'schedule_kill_scheduled_when_chance_below',
            'schedule_no_kill_when_chance_above',
            'schedule_add_plan_called',
            'schedule_returns_only_four_keys',
            'finish_chunks_and_clears',
            'finish_empty_buffer_no_calls',
            'finish_returns_only_two_keys',
            'destroy_kills_cores_skips_privileged',
            'destroy_clears_plans_and_buffer',
            'destroy_units_scheduled_both_branches',
            'destroy_returns_only_nine_keys',
            'time_destroy_schedules_in_range_only',
            'time_destroy_sector_floor_replaced',
            'time_destroy_no_sector_no_floor_change',
            'time_destroy_returns_only_ten_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_teams_derelict(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TeamsDerelictProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TEAMS_DERELICT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'schedule_buffers_pos',
            'schedule_destroy_payload_when_unit_payload',
            'schedule_no_destroy_payload_without_unit_payload',
            'schedule_kill_scheduled_when_chance_below',
            'schedule_no_kill_when_chance_above',
            'schedule_add_plan_called',
            'schedule_returns_only_four_keys',
            'finish_chunks_and_clears',
            'finish_empty_buffer_no_calls',
            'finish_returns_only_two_keys',
            'destroy_kills_cores_skips_privileged',
            'destroy_clears_plans_and_buffer',
            'destroy_units_scheduled_both_branches',
            'destroy_returns_only_nine_keys',
            'time_destroy_schedules_in_range_only',
            'time_destroy_sector_floor_replaced',
            'time_destroy_no_sector_no_floor_change',
            'time_destroy_returns_only_ten_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
