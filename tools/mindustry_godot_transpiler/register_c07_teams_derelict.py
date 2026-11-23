"""Register TeamData derelict lifecycle group (N2395).

TeamData.destroyToDerelict()+timeDestroy()+scheduleDerelict()+
finishScheduleDerelict()
(Teams.java:328-360 + :362-394 + :396-409 + :411-414,
`var builds = new Seq<Building>();` /
`if(buildingTree != null){` /
`buildingTree.getObjects(builds);` /
`if(b.block.privileged) continue;` /
`scheduleDerelict(b);` /
`finishScheduleDerelict();` /
`units.each(u -> Time.run(Mathf.random(0f, 60f * 5f), () -> {` /
`if(u.team == team){` /
`buildingTree.intersect(x - range, y - range, range * 2f, range * 2f, builds);` /
`if(!build.block.privileged && build.within(x, y, range) && !cores.contains(c -> c.within(build, range))){` /
`var sector = state.getSector();` /
`if(sector != null){` /
`for(var entry : sector.planet.sectorCaptureReplacements){` /
`if(indexer.isBlockPresent(entry.key)){` /
`Geometry.circle(World.toTile(x), World.toTile(y), world.width(), world.height(), Mathf.round(range / tilesize), (tx, ty) -> {` /
`Tile t = world.rawTile(tx, ty);` /
`Block result = sector.planet.sectorCaptureReplacements.get(t.floor());` /
`t.setFloor(result.asFloor());` /
`derelictBuffer.add(build.pos());` /
`if(build.getPayload() instanceof UnitPayload){` /
`Call.destroyPayload(build);` /
`if(Mathf.chance(0.2)){` /
`Time.run(Mathf.random(0f, 60f * 6f), build::kill);` /
`build.addPlan(false, true);` /
`derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));` /
`derelictBuffer.clear();`) is one grouped slice: four methods
of one derelict lifecycle on TeamData -- two public methods
calling the two private ones (scheduleDerelict is only called
from these two, finishScheduleDerelict likewise) -- main-thread
decision 2026-11-21 (the N2380 seven-method / N2374
five-accessor group precedent). Four GD functions on
SourceTeamsRuntimeState.gd, one ledger entry, one owner per
function (the N2380 multi-function precedent; the N2378
lesson: a contract owner must be an actual GD function, so
the group label `source_team_data_derelict_state` is NOT
registered as an owner -- the ledger godot_owner is the first
function owner, `source_team_data_destroy_to_derelict_state`).

Callees -- NOT re-registered as distinguishing exprs:
- `plans.clear();` -- already the exact_expr of N1143; the
  clear IS implemented here (the passed plans Array is
  cleared in place) but the expr is cited as evidence only.
- `b.kill();` / `u.kill();` -- generic; the kills arrive as
  kill_build / kill_unit Callable params.
- `Call.destroyPayload` / `Call.setTeams` -- network calls,
  not ported; they arrive as destroy_payload / set_teams
  Callable params and are recorded in the frame, never sent
  as packets.
- `Time.run` -- not ported; it arrives as a time_run Callable
  recording delay+action. `Mathf.chance` / `Mathf.random`
  arrive as explicit chance_roll / delay params.
- `buildingTree` (QuadTree), `state.getSector()`,
  `sector.planet.sectorCaptureReplacements`,
  `Geometry.circle`, `world.rawTile`, `t.setFloor` -- not
  ported; the tree objects / sector replacements / circle
  tiles arrive as explicit Array/Dictionary params, and the
  per-build `within` / `cores.contains` checks arrive as
  precomputed flags on the records.
- `derelictBuffer` (the static IntSeq, Teams.java:271) --
  arrives as an in/out Array param, never kept as static
  GD state outside the frame.

Four new result-symbol groups (25 symbols). One slice source:
Teams.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_closest_core_tree import DEFERRED as N2392_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamsDerelictProof'
DESTROY_OWNER = 'SourceTeamsRuntimeState.source_team_data_destroy_to_derelict_state'
TIME_DESTROY_OWNER = 'SourceTeamsRuntimeState.source_team_data_time_destroy_state'
SCHEDULE_OWNER = 'SourceTeamsRuntimeState.source_team_data_schedule_derelict_state'
FINISH_OWNER = 'SourceTeamsRuntimeState.source_team_data_finish_schedule_derelict_state'
TESTS = ['test_c07_teams_derelict_registration', 'test_all_c07_teams_derelict_input_evidence_is_exact', 'test_teams_derelict_state', 'test_reference_graph_and_actual_c07_teams_derelict']
# The 1 slice source the N2395 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
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
]

# DEFERRED is carried from the N2392 register script via import --
# never retyped. All N2392 entries are carried verbatim (the
# Game chain, the B/C notes, the unitTree QuadTree model, the
# Team.all / Groups frame notes, and N2392's own Windows proof
# debt -- none of them is resolved by this slice). One entry is
# added: N2395's Windows proof debt.
DEFERRED = list(N2392_DEFERRED) + [
    'TeamData.destroyToDerelict()+timeDestroy()+scheduleDerelict()+finishScheduleDerelict() Windows Godot proof -- debt in GOAL.md section 5, same as N2392: the N2395 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    schedule_inputs = {
        'build_pos': a('int', 'derelictBuffer.add(build.pos());', 'The build position (Teams.java:398, `derelictBuffer.add(build.pos());`): `build.pos()` arrives as the build_pos int param (Building is not ported) -- the pos buffered into derelictBuffer and passed to destroyPayload / the delayed kill / addPlan.'),
        'has_unit_payload': a('bool', 'if(build.getPayload() instanceof UnitPayload){', 'Whether the build carries a unit payload (Teams.java:400, `if(build.getPayload() instanceof UnitPayload){`): `build.getPayload() instanceof UnitPayload` arrives as the has_unit_payload bool (UnitPayload is not ported) -- only then is Call.destroyPayload called.'),
        'derelict_buffer': a('Array', 'derelictBuffer.add(build.pos());', 'The derelict buffer (Teams.java:398, `derelictBuffer.add(build.pos());`): the static IntSeq derelictBuffer (Teams.java:271) as an in/out Array param -- the pos is appended in place, the same live Array the caller keeps.'),
        'destroy_payload': a('Callable', 'Call.destroyPayload(build);', 'The payload destroy call (Teams.java:401, `Call.destroyPayload(build);`): Call is a network API, not ported -- it arrives as a Callable param (build_pos) and the call is recorded in the frame, no packet is ever sent.'),
        'chance_roll': a('float', 'if(Mathf.chance(0.2)){', 'The chance roll (Teams.java:403, `if(Mathf.chance(0.2)){`): the sampled `Mathf.chance(0.2)` roll as an explicit float param (0.0-1.0) -- the delayed kill is scheduled only when the roll is below 0.2, exactly as the Java chance check.'),
        'random_delay': a('float', 'Time.run(Mathf.random(0f, 60f * 6f), build::kill);', 'The kill delay (Teams.java:404, `Time.run(Mathf.random(0f, 60f * 6f), build::kill);`): the sampled `Mathf.random(0f, 60f * 6f)` delay as an explicit float param -- recorded with the delayed kill action, never waited on.'),
        'time_run': a('Callable', 'Time.run(Mathf.random(0f, 60f * 6f), build::kill);', 'The delayed-run hook (Teams.java:404, `Time.run(Mathf.random(0f, 60f * 6f), build::kill);`): Time.run is not ported -- it arrives as a Callable param (delay, action) recording the delay + the kill action; the kill only runs when the recorded action is executed.'),
        'kill_build': a('Callable', 'Time.run(Mathf.random(0f, 60f * 6f), build::kill);', 'The build kill (Teams.java:404, `Time.run(Mathf.random(0f, 60f * 6f), build::kill);`): `build::kill` arrives as a Callable param (build_pos) -- `b.kill();` is generic, not registered; the kill is wrapped in the recorded Time.run action.'),
        'add_plan': a('Callable', 'build.addPlan(false, true);', 'The plan add (Teams.java:406, `build.addPlan(false, true);`): Building.addPlan is not ported -- it arrives as a Callable param (build_pos, false, true) and the call is recorded in the frame.'),
    }
    schedule_outputs = {
        'derelict_buffer': a('Array', 'derelictBuffer.add(build.pos());', 'The derelict buffer after (Teams.java:398, `derelictBuffer.add(build.pos());`): the same in/out Array, now with the build pos appended.'),
        'destroy_payload_calls': a('Array', 'Call.destroyPayload(build);', 'The destroyPayload calls (Teams.java:401, `Call.destroyPayload(build);`): the build positions Call.destroyPayload was called with -- empty when the build has no unit payload.'),
        'scheduled_kill': a('Variant', 'Time.run(Mathf.random(0f, 60f * 6f), build::kill);', 'The scheduled kill (Teams.java:404, `Time.run(Mathf.random(0f, 60f * 6f), build::kill);`): {"delay": float, "build_pos": int} when the chance roll was below 0.2, else null.'),
        'add_plan_calls': a('Array', 'build.addPlan(false, true);', 'The addPlan calls (Teams.java:406, `build.addPlan(false, true);`): the build positions addPlan(false, true) was called with -- always the one build.'),
    }
    finish_inputs = {
        'derelict_buffer': a('Array', 'derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));', 'The derelict buffer (Teams.java:412, `derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));`): the static IntSeq derelictBuffer (Teams.java:271) as an in/out Array param -- flushed in chunks of 1000, then cleared.'),
        'set_teams': a('Callable', 'derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));', 'The setTeams call (Teams.java:412, `derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));`): Call is a network API, not ported -- it arrives as a Callable param (values, "derelict") and every chunk call is recorded in the frame, no packet is ever sent.'),
    }
    finish_outputs = {
        'derelict_buffer': a('Array', 'derelictBuffer.clear();', 'The derelict buffer after (Teams.java:413, `derelictBuffer.clear();`): always the emptied Array -- the flush clears it.'),
        'set_teams_calls': a('Array', 'derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));', 'The setTeams calls (Teams.java:412, `derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));`): one {"values": [...], "team": "derelict"} entry per chunk of at most 1000 positions, in buffer order.'),
    }
    destroy_inputs = {
        'building_tree_objects': a('Variant', 'buildingTree.getObjects(builds);', 'The tree objects (Teams.java:333, `buildingTree.getObjects(builds);`): buildingTree is the @Nullable QuadTree<Building> (Teams.java:294), not ported -- its objects arrive as a Variant param (null when the tree is null, else the Array of build records {"pos": int, "privileged": bool, "is_core": bool, "has_unit_payload": bool}).'),
        'plans': a('Array', 'plans.clear();', 'The plans queue (Teams.java:336, `plans.clear();`): the plans Queue<BlockPlan> (Teams.java:287) as an in/out Array param -- `plans.clear();` is already the exact_expr of N1143, so the clear is implemented here (cleared in place) but the expr is evidence only, not re-registered.'),
        'units': a('Array', 'units.each(u -> Time.run(Mathf.random(0f, 60f * 5f), () -> {', 'The team units (Teams.java:355, `units.each(u -> Time.run(Mathf.random(0f, 60f * 5f), () -> {`): the units Seq as an Array of records {"team_id": int, ...} -- each unit gets one delayed kill action.'),
        'team_id': a('int', 'if(u.team == team){', 'The team id (Teams.java:357, `if(u.team == team){`): the TeamData team as an int id -- the delayed action compares each unit team_id against it when the action runs.'),
        'derelict_buffer': a('Array', 'finishScheduleDerelict();', 'The derelict buffer (Teams.java:353, `finishScheduleDerelict();`): the static IntSeq derelictBuffer (Teams.java:271) as an in/out Array param -- filled by the scheduleDerelict calls, flushed and cleared by the finish callee.'),
        'unit_delays': a('Array', 'units.each(u -> Time.run(Mathf.random(0f, 60f * 5f), () -> {', 'The per-unit delays (Teams.java:355, `units.each(u -> Time.run(Mathf.random(0f, 60f * 5f), () -> {`): the sampled `Mathf.random(0f, 60f * 5f)` delay per unit as an Array of floats in unit order -- a missing entry defaults to 0.0.'),
        'chance_rolls': a('Array', 'if(Mathf.chance(0.2)){', 'The per-schedule chance rolls (Teams.java:403, `if(Mathf.chance(0.2)){`): the sampled `Mathf.chance(0.2)` rolls for the scheduleDerelict calls, in schedule order -- a missing entry defaults to 0.0 (kill scheduled).'),
        'kill_delays': a('Array', 'Time.run(Mathf.random(0f, 60f * 6f), build::kill);', 'The per-schedule kill delays (Teams.java:404, `Time.run(Mathf.random(0f, 60f * 6f), build::kill);`): the sampled `Mathf.random(0f, 60f * 6f)` delays for the scheduleDerelict calls, in schedule order -- a missing entry defaults to 0.0.'),
        'destroy_payload': a('Callable', 'Call.destroyPayload(build);', 'The payload destroy call (Teams.java:401, `Call.destroyPayload(build);`): forwarded to the scheduleDerelict callee -- Call is a network API, not ported.'),
        'time_run': a('Callable', 'units.each(u -> Time.run(Mathf.random(0f, 60f * 5f), () -> {', 'The delayed-run hook (Teams.java:355, `units.each(u -> Time.run(Mathf.random(0f, 60f * 5f), () -> {`): Time.run is not ported -- it arrives as a Callable param (delay, action) recording delay+action, shared by the scheduleDerelict callee and the per-unit actions.'),
        'kill_build': a('Callable', 'if(b instanceof CoreBuild){', 'The build kill (Teams.java:346, `if(b instanceof CoreBuild){`): `b.kill();` is generic, not registered -- cores are killed at once via this Callable param (build_pos), and the same Callable is wrapped in the delayed scheduleDerelict actions.'),
        'kill_unit': a('Callable', 'if(u.team == team){', 'The unit kill (Teams.java:357, `if(u.team == team){`): `u.kill();` is generic, not registered -- the delayed per-unit action calls this Callable param (unit record) only when the unit team still matches.'),
        'add_plan': a('Callable', 'build.addPlan(false, true);', 'The plan add (Teams.java:406, `build.addPlan(false, true);`): forwarded to the scheduleDerelict callee -- Building.addPlan is not ported.'),
        'set_teams': a('Callable', 'derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));', 'The setTeams call (Teams.java:412, `derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));`): forwarded to the finishScheduleDerelict callee -- Call is a network API, not ported.'),
    }
    destroy_outputs = {
        'builds': a('Array', 'var builds = new Seq<Building>();', 'The builds (Teams.java:330, `var builds = new Seq<Building>();`): all objects from the building tree (empty when the tree is null) -- the full list the loop iterated, including privileged and core builds.'),
        'plans': a('Array', 'plans.clear();', 'The plans after (Teams.java:336, `plans.clear();`): the same in/out Array, cleared -- `plans.clear();` is N1143 evidence, the clear is implemented here.'),
        'derelict_buffer': a('Array', 'finishScheduleDerelict();', 'The derelict buffer after (Teams.java:353, `finishScheduleDerelict();`): always the emptied Array -- the finish callee flushes it in chunks and clears it.'),
        'killed_cores': a('Array', 'if(b instanceof CoreBuild){', 'The killed cores (Teams.java:346, `if(b instanceof CoreBuild){`): the positions of the CoreBuild builds killed at once -- privileged builds are never in here.'),
        'destroy_payload_calls': a('Array', 'Call.destroyPayload(build);', 'The destroyPayload calls (Teams.java:401, `Call.destroyPayload(build);`): the build positions Call.destroyPayload was called with, aggregated over the scheduleDerelict calls.'),
        'scheduled_kills': a('Array', 'Time.run(Mathf.random(0f, 60f * 6f), build::kill);', 'The scheduled kills (Teams.java:404, `Time.run(Mathf.random(0f, 60f * 6f), build::kill);`): the {"delay": float, "build_pos": int} entries from the scheduleDerelict calls whose chance roll was below 0.2.'),
        'add_plan_calls': a('Array', 'build.addPlan(false, true);', 'The addPlan calls (Teams.java:406, `build.addPlan(false, true);`): the build positions addPlan(false, true) was called with, aggregated over the scheduleDerelict calls.'),
        'set_teams_calls': a('Array', 'derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));', 'The setTeams calls (Teams.java:412, `derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));`): the {"values": [...], "team": "derelict"} entries from the finish callee.'),
        'scheduled_unit_kills': a('Array', 'units.each(u -> Time.run(Mathf.random(0f, 60f * 5f), () -> {', 'The scheduled unit kills (Teams.java:355, `units.each(u -> Time.run(Mathf.random(0f, 60f * 5f), () -> {`): one {"delay": float, "unit": record} entry per unit, in unit order -- the action kills the unit only if its team still matches when run.'),
    }
    time_destroy_inputs = {
        'x': a('float', 'public void timeDestroy(float x, float y, float range){', 'The x asking (Teams.java:362, `public void timeDestroy(float x, float y, float range){`): the destroy centre x, passed to the tree intersect and the sector circle.'),
        'y': a('float', 'public void timeDestroy(float x, float y, float range){', 'The y asking (Teams.java:362, `public void timeDestroy(float x, float y, float range){`): the destroy centre y, passed to the tree intersect and the sector circle.'),
        'range': a('float', 'public void timeDestroy(float x, float y, float range){', 'The range (Teams.java:362, `public void timeDestroy(float x, float y, float range){`): the destroy radius -- the intersect rect, the within checks, and the circle radius all derive from it.'),
        'building_tree_objects': a('Variant', 'buildingTree.intersect(x - range, y - range, range * 2f, range * 2f, builds);', 'The intersected objects (Teams.java:365, `buildingTree.intersect(x - range, y - range, range * 2f, range * 2f, builds);`): the @Nullable QuadTree<Building> (Teams.java:294) is not ported -- the intersected objects arrive as a Variant param (null when the tree is null, else the Array of build records {"pos": int, "privileged": bool, "within_range": bool, "near_core": bool, "has_unit_payload": bool}); the `x - range, y - range, range * 2f, range * 2f` rect is the QuadTree job, precomputed by the caller.'),
        'derelict_buffer': a('Array', 'finishScheduleDerelict();', 'The derelict buffer (Teams.java:373, `finishScheduleDerelict();`): the static IntSeq derelictBuffer (Teams.java:271) as an in/out Array param -- filled by the scheduleDerelict calls, flushed and cleared by the finish callee.'),
        'chance_rolls': a('Array', 'if(Mathf.chance(0.2)){', 'The per-schedule chance rolls (Teams.java:403, `if(Mathf.chance(0.2)){`): the sampled `Mathf.chance(0.2)` rolls for the scheduleDerelict calls, in schedule order -- a missing entry defaults to 0.0 (kill scheduled).'),
        'kill_delays': a('Array', 'Time.run(Mathf.random(0f, 60f * 6f), build::kill);', 'The per-schedule kill delays (Teams.java:404, `Time.run(Mathf.random(0f, 60f * 6f), build::kill);`): the sampled `Mathf.random(0f, 60f * 6f)` delays for the scheduleDerelict calls, in schedule order -- a missing entry defaults to 0.0.'),
        'sector': a('Variant', 'var sector = state.getSector();', 'The sector (Teams.java:376, `var sector = state.getSector();`): `state.getSector()` arrives as a Variant param (null when there is no sector, else a Dictionary {"replacements": Dictionary floor_key -> result, "present_keys": Array}) -- `sector.planet.sectorCaptureReplacements` is the "replacements" Dictionary, `indexer.isBlockPresent(entry.key)` arrives as the precomputed "present_keys" Array.'),
        'circle_tiles': a('Array', 'Geometry.circle(World.toTile(x), World.toTile(y), world.width(), world.height(), Mathf.round(range / tilesize), (tx, ty) -> {', 'The circle tiles (Teams.java:385, `Geometry.circle(World.toTile(x), World.toTile(y), world.width(), world.height(), Mathf.round(range / tilesize), (tx, ty) -> {`): Geometry.circle is an engine API, not ported -- the iterated tiles arrive as an Array of records {"tx": int, "ty": int, "floor": Variant, "near_core": bool}; `world.rawTile(tx, ty)` is the tile record itself, `cores.contains(c -> c.within(t, range))` is its precomputed "near_core" flag.'),
        'tilesize': a('float', 'Geometry.circle(World.toTile(x), World.toTile(y), world.width(), world.height(), Mathf.round(range / tilesize), (tx, ty) -> {', 'The tile size (Teams.java:385, `Geometry.circle(World.toTile(x), World.toTile(y), world.width(), world.height(), Mathf.round(range / tilesize), (tx, ty) -> {`): the world tilesize -- the circle radius in tiles is `Mathf.round(range / tilesize)`, computed here only when a replacement is present.'),
        'destroy_payload': a('Callable', 'Call.destroyPayload(build);', 'The payload destroy call (Teams.java:401, `Call.destroyPayload(build);`): forwarded to the scheduleDerelict callee -- Call is a network API, not ported.'),
        'time_run': a('Callable', 'Time.run(Mathf.random(0f, 60f * 6f), build::kill);', 'The delayed-run hook (Teams.java:404, `Time.run(Mathf.random(0f, 60f * 6f), build::kill);`): forwarded to the scheduleDerelict callee -- Time.run is not ported.'),
        'kill_build': a('Callable', 'Time.run(Mathf.random(0f, 60f * 6f), build::kill);', 'The build kill (Teams.java:404, `Time.run(Mathf.random(0f, 60f * 6f), build::kill);`): forwarded to the scheduleDerelict callee -- `build::kill` arrives as a Callable param (build_pos).'),
        'add_plan': a('Callable', 'build.addPlan(false, true);', 'The plan add (Teams.java:406, `build.addPlan(false, true);`): forwarded to the scheduleDerelict callee -- Building.addPlan is not ported.'),
        'set_teams': a('Callable', 'derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));', 'The setTeams call (Teams.java:412, `derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));`): forwarded to the finishScheduleDerelict callee -- Call is a network API, not ported.'),
        'set_floor': a('Callable', 't.setFloor(result.asFloor());', 'The floor set (Teams.java:389, `t.setFloor(result.asFloor());`): Tile.setFloor is not ported -- it arrives as a Callable param (tile, result) and every call is recorded in the frame.'),
    }
    time_destroy_outputs = {
        'builds': a('Array', 'var builds = new Seq<Building>();', 'The builds (Teams.java:363, `var builds = new Seq<Building>();`): all objects from the tree intersect (empty when the tree is null) -- the full list the loop iterated.'),
        'derelict_buffer': a('Array', 'finishScheduleDerelict();', 'The derelict buffer after (Teams.java:373, `finishScheduleDerelict();`): always the emptied Array -- the finish callee flushes it in chunks and clears it.'),
        'destroy_payload_calls': a('Array', 'Call.destroyPayload(build);', 'The destroyPayload calls (Teams.java:401, `Call.destroyPayload(build);`): the build positions Call.destroyPayload was called with, aggregated over the scheduleDerelict calls.'),
        'scheduled_kills': a('Array', 'Time.run(Mathf.random(0f, 60f * 6f), build::kill);', 'The scheduled kills (Teams.java:404, `Time.run(Mathf.random(0f, 60f * 6f), build::kill);`): the {"delay": float, "build_pos": int} entries from the scheduleDerelict calls whose chance roll was below 0.2.'),
        'add_plan_calls': a('Array', 'build.addPlan(false, true);', 'The addPlan calls (Teams.java:406, `build.addPlan(false, true);`): the build positions addPlan(false, true) was called with, aggregated over the scheduleDerelict calls.'),
        'set_teams_calls': a('Array', 'derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));', 'The setTeams calls (Teams.java:412, `derelictBuffer.chunked(1000, values -> Call.setTeams(values, Team.derelict));`): the {"values": [...], "team": "derelict"} entries from the finish callee.'),
        'has_sector': a('bool', 'if(sector != null){', 'Whether a sector exists (Teams.java:377, `if(sector != null){`): true when the sector param is non-null.'),
        'any_replacement_present': a('bool', 'if(indexer.isBlockPresent(entry.key)){', 'Whether a replacement is present (Teams.java:380, `if(indexer.isBlockPresent(entry.key)){`): true when any sectorCaptureReplacements key is in the present_keys Array.'),
        'circle_radius_tiles': a('int', 'Geometry.circle(World.toTile(x), World.toTile(y), world.width(), world.height(), Mathf.round(range / tilesize), (tx, ty) -> {', 'The circle radius in tiles (Teams.java:385, `Geometry.circle(World.toTile(x), World.toTile(y), world.width(), world.height(), Mathf.round(range / tilesize), (tx, ty) -> {`): `Mathf.round(range / tilesize)`, computed only when a replacement is present, else 0.'),
        'floor_changes': a('Array', 't.setFloor(result.asFloor());', 'The floor changes (Teams.java:389, `t.setFloor(result.asFloor());`): one {"tx": int, "ty": int, "floor": result} entry per tile whose floor was replaced -- only tiles with a replacement result and no core nearby.'),
    }
    return ((destroy_inputs, destroy_outputs), (time_destroy_inputs, time_destroy_outputs), (schedule_inputs, schedule_outputs), (finish_inputs, finish_outputs))


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for pair in inputs_outputs:
        for keys in pair:
            total += len(keys)
            for field, meta in keys.items():
                source = meta['java_source']
                text = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
                if meta['java_expr'] not in text:
                    missing.append('%s: %s' % (field, meta['java_expr']))
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    pairs = definitions()

    entries = [
        ('N2395', DESTROY_OWNER, 'source_team_data_destroy_to_derelict_state', TEAMS, 'mindustry.game.Teams', 'TeamData.destroyToDerelict()', pairs[0][0], pairs[0][1], True, 'Dictionary'),
        ('N2395', TIME_DESTROY_OWNER, 'source_team_data_time_destroy_state', TEAMS, 'mindustry.game.Teams', 'TeamData.timeDestroy()', pairs[1][0], pairs[1][1], True, 'Dictionary'),
        ('N2395', SCHEDULE_OWNER, 'source_team_data_schedule_derelict_state', TEAMS, 'mindustry.game.Teams', 'TeamData.scheduleDerelict()', pairs[2][0], pairs[2][1], True, 'Dictionary'),
        ('N2395', FINISH_OWNER, 'source_team_data_finish_schedule_derelict_state', TEAMS, 'mindustry.game.Teams', 'TeamData.finishScheduleDerelict()', pairs[3][0], pairs[3][1], True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TeamData derelict lifecycle state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TeamData derelict lifecycle state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: destroy outputs; timeDestroy
    # outputs; schedule outputs; finish outputs.
    by_slice['N2395'] = [
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
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2395', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams', java_method='TeamData.destroyToDerelict()/TeamData.timeDestroy()/TeamData.scheduleDerelict()/TeamData.finishScheduleDerelict()', godot_owner=DESTROY_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2395'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {definition[1] for definition in entries}
    for name, module in modules.items():
        if module.get('canonical_module') == 'api_contracts':
            selected = source_ssot.build_extension_shard(GODOT, name)[module['root_key']]
            if new_owners.intersection(selected):
                optional = module.setdefault('optional_mirror_fields', [])
                if 'return_type' not in optional:
                    optional.append('return_type')
    source_ssot.write_registered_json(GODOT, 'module_manifest', manifest)
    for canonical in ['slice_ledger', 'api_contracts', 'state_schema', 'registry', 'audit_report', 'module_manifest']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    if '--verify' in sys.argv:
        sys.exit(verify())
    main()
