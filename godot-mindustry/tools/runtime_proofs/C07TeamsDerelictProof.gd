extends Node

const main_scene := preload("res://scenes/Main.tscn")
const teams_state := preload("res://src/game/SourceTeamsRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- TeamData derelict lifecycle group (N2395):
	# TeamData.destroyToDerelict()+timeDestroy()+
	# scheduleDerelict()+finishScheduleDerelict()
	# (Teams.java:328-360 + :362-394 + :396-409 + :411-414).
	# One grouped slice (main-thread decision 2026-11-21, the
	# N2380 seven-method / N2374 five-accessor group
	# precedent): four methods of one derelict lifecycle --
	# two public methods calling the two private ones. The
	# proof calls the four pure functions with synthetic
	# inputs (no live tick, no packets, no real kills).
	# Call.destroyPayload / Call.setTeams arrive as
	# Callables recording their calls; Time.run arrives as
	# a Callable recording delay+action (the proof executes
	# the recorded actions to check both branches);
	# Mathf.chance / Mathf.random arrive as explicit
	# chance_roll / delay params; the QuadTree / sector /
	# Geometry.circle / world tile lookups arrive as
	# explicit Array/Dictionary params; derelictBuffer is
	# an in/out Array param, never static GD state.

	var destroy_payload_calls: Array = []
	var destroy_payload := func(build_pos: int) -> void:
		destroy_payload_calls.append(build_pos)
	var time_runs: Array = []
	var time_run := func(delay: float, action: Callable) -> void:
		time_runs.append({"delay": delay, "action": action})
	var killed_builds: Array = []
	var kill_build := func(build_pos: int) -> void:
		killed_builds.append(build_pos)
	var killed_units: Array = []
	var kill_unit := func(unit: Dictionary) -> void:
		killed_units.append(unit)
	var add_plan_calls: Array = []
	var add_plan := func(build_pos: int, first: bool, second: bool) -> void:
		add_plan_calls.append([build_pos, first, second])
	var set_teams_calls: Array = []
	var set_teams := func(values: Array, team: String) -> void:
		set_teams_calls.append({"values": values, "team": team})
	var floor_calls: Array = []
	var set_floor := func(tile: Dictionary, result: Variant) -> void:
		floor_calls.append({"tile": tile, "floor": result})

	# scheduleDerelict buffers the pos, destroys a unit
	# payload, schedules a delayed kill only below chance
	# 0.2 (and the recorded action really kills when run),
	# and adds a plan.
	var schedule_buffer: Array = []
	var scheduled: Dictionary = teams_state.source_team_data_schedule_derelict_state(42, true, schedule_buffer, destroy_payload, 0.1, 12.0, time_run, kill_build, add_plan)
	proof["schedule_buffers_pos"] = schedule_buffer == [42] and scheduled.get("derelict_buffer", []) == [42]
	proof["schedule_destroy_payload_when_unit_payload"] = destroy_payload_calls == [42]
	proof["schedule_kill_scheduled_when_chance_below"] = scheduled.get("scheduled_kill", {}) == {"delay": 12.0, "build_pos": 42} and time_runs.size() == 1 and float(time_runs[0].get("delay", -1.0)) == 12.0
	(time_runs[0].get("action", Callable()) as Callable).call()
	proof["schedule_kill_scheduled_when_chance_below"] = proof["schedule_kill_scheduled_when_chance_below"] and killed_builds == [42]
	proof["schedule_add_plan_called"] = add_plan_calls == [[42, false, true]]
	proof["schedule_returns_only_four_keys"] = scheduled.size() == 4
	var destroy_payload_before: int = destroy_payload_calls.size()
	var time_runs_before: int = time_runs.size()
	var schedule_buffer_2: Array = []
	var scheduled_2: Dictionary = teams_state.source_team_data_schedule_derelict_state(7, false, schedule_buffer_2, destroy_payload, 0.5, 3.0, time_run, kill_build, add_plan)
	proof["schedule_no_destroy_payload_without_unit_payload"] = destroy_payload_calls.size() == destroy_payload_before and scheduled_2.get("destroy_payload_calls", [99]) == []
	proof["schedule_no_kill_when_chance_above"] = scheduled_2.get("scheduled_kill", "not-null") == null and time_runs.size() == time_runs_before

	# finishScheduleDerelict flushes the buffer in chunks
	# of 1000 via setTeams, then clears it; an empty
	# buffer sends nothing.
	var finish_buffer: Array = []
	for i in range(2500):
		finish_buffer.append(i)
	var set_teams_before: int = set_teams_calls.size()
	var finished: Dictionary = teams_state.source_team_data_finish_schedule_derelict_state(finish_buffer, set_teams)
	proof["finish_chunks_and_clears"] = set_teams_calls.size() == set_teams_before + 3 and (set_teams_calls[set_teams_before].get("values", []) as Array).size() == 1000 and (set_teams_calls[set_teams_before + 1].get("values", []) as Array).size() == 1000 and (set_teams_calls[set_teams_before + 2].get("values", []) as Array).size() == 500 and set_teams_calls[set_teams_before + 2].get("team", "") == "derelict" and finish_buffer.is_empty() and (finished.get("derelict_buffer", [1]) as Array).is_empty()
	proof["finish_returns_only_two_keys"] = finished.size() == 2
	var finish_empty: Dictionary = teams_state.source_team_data_finish_schedule_derelict_state([], set_teams)
	proof["finish_empty_buffer_no_calls"] = set_teams_calls.size() == set_teams_before + 3 and (finish_empty.get("set_teams_calls", [1]) as Array).is_empty()

	# destroyToDerelict kills cores at once, skips
	# privileged builds, schedules the rest, clears plans,
	# empties the buffer, and schedules a delayed kill per
	# unit whose action kills same-team units only.
	var destroy_builds: Array = [
		{"pos": 1, "privileged": true, "is_core": false, "has_unit_payload": false},
		{"pos": 2, "privileged": false, "is_core": true, "has_unit_payload": false},
		{"pos": 3, "privileged": false, "is_core": false, "has_unit_payload": true},
		{"pos": 4, "privileged": false, "is_core": false, "has_unit_payload": false},
	]
	var destroy_plans: Array = ["plan-a", "plan-b"]
	var destroy_units: Array = [
		{"team_id": 1, "ref": "u-same"},
		{"team_id": 2, "ref": "u-other"},
	]
	var destroy_buffer: Array = []
	var killed_builds_before: int = killed_builds.size()
	var destroy_payload_before_2: int = destroy_payload_calls.size()
	var add_plan_before: int = add_plan_calls.size()
	var set_teams_before_2: int = set_teams_calls.size()
	var time_runs_before_2: int = time_runs.size()
	var destroyed: Dictionary = teams_state.source_team_data_destroy_to_derelict_state(destroy_builds, destroy_plans, destroy_units, 1, destroy_buffer, [5.0, 7.0], [0.1, 0.5], [11.0, 13.0], destroy_payload, time_run, kill_build, kill_unit, add_plan, set_teams)
	proof["destroy_kills_cores_skips_privileged"] = killed_builds.slice(killed_builds_before) == [2] and destroy_payload_calls.slice(destroy_payload_before_2) == [3] and destroyed.get("scheduled_kills", []) == [{"delay": 11.0, "build_pos": 3}] and add_plan_calls.slice(add_plan_before) == [[3, false, true], [4, false, true]] and (destroyed.get("set_teams_calls", []) as Array) == [{"values": [3, 4], "team": "derelict"}]
	proof["destroy_clears_plans_and_buffer"] = destroy_plans.is_empty() and destroy_buffer.is_empty() and (destroyed.get("plans", [1]) as Array).is_empty() and (destroyed.get("derelict_buffer", [1]) as Array).is_empty()
	# time_runs order after destroy: the pos-3 scheduled
	# kill action first, then one action per unit.
	var unit_action_same: Callable = time_runs[time_runs_before_2 + 1].get("action", Callable())
	var unit_action_other: Callable = time_runs[time_runs_before_2 + 2].get("action", Callable())
	unit_action_same.call()
	unit_action_other.call()
	proof["destroy_units_scheduled_both_branches"] = (destroyed.get("scheduled_unit_kills", []) as Array).size() == 2 and float((destroyed.get("scheduled_unit_kills", []) as Array)[0].get("delay", -1.0)) == 5.0 and float((destroyed.get("scheduled_unit_kills", []) as Array)[1].get("delay", -1.0)) == 7.0 and killed_units == [{"team_id": 1, "ref": "u-same"}]
	proof["destroy_returns_only_nine_keys"] = destroyed.size() == 9

	# timeDestroy schedules in-range non-core buildings
	# only, and swaps floors only with a sector and a
	# present replacement, never for near-core tiles.
	var time_builds: Array = [
		{"pos": 10, "privileged": true, "within_range": true, "near_core": false, "has_unit_payload": false},
		{"pos": 11, "privileged": false, "within_range": false, "near_core": false, "has_unit_payload": false},
		{"pos": 12, "privileged": false, "within_range": true, "near_core": true, "has_unit_payload": false},
		{"pos": 13, "privileged": false, "within_range": true, "near_core": false, "has_unit_payload": false},
	]
	var sector: Dictionary = {"replacements": {"grass": "sand", "rock": "dirt"}, "present_keys": ["rock"]}
	var circle_tiles: Array = [
		{"tx": 1, "ty": 1, "floor": "grass", "near_core": false},
		{"tx": 2, "ty": 2, "floor": "rock", "near_core": false},
		{"tx": 3, "ty": 3, "floor": "grass", "near_core": true},
		{"tx": 4, "ty": 4, "floor": "water", "near_core": false},
	]
	var time_buffer: Array = []
	var set_teams_before_3: int = set_teams_calls.size()
	var time_destroyed: Dictionary = teams_state.source_team_data_time_destroy_state(0.0, 0.0, 80.0, time_builds, time_buffer, [0.1], [9.0], sector, circle_tiles, 8.0, destroy_payload, time_run, kill_build, add_plan, set_teams, set_floor)
	proof["time_destroy_schedules_in_range_only"] = (time_destroyed.get("set_teams_calls", []) as Array) == [{"values": [13], "team": "derelict"}] and (time_destroyed.get("add_plan_calls", []) as Array) == [13] and (time_destroyed.get("scheduled_kills", []) as Array) == [{"delay": 9.0, "build_pos": 13}] and (time_destroyed.get("builds", []) as Array).size() == 4
	proof["time_destroy_sector_floor_replaced"] = time_destroyed.get("has_sector", false) == true and time_destroyed.get("any_replacement_present", false) == true and time_destroyed.get("circle_radius_tiles", -1) == 10 and (time_destroyed.get("floor_changes", []) as Array) == [{"tx": 1, "ty": 1, "floor": "sand"}, {"tx": 2, "ty": 2, "floor": "dirt"}] and floor_calls.size() == 2
	proof["time_destroy_returns_only_ten_keys"] = time_destroyed.size() == 10
	var time_buffer_2: Array = []
	var time_destroyed_2: Dictionary = teams_state.source_team_data_time_destroy_state(0.0, 0.0, 80.0, [], time_buffer_2, [], [], null, [], 8.0, destroy_payload, time_run, kill_build, add_plan, set_teams, set_floor)
	proof["time_destroy_no_sector_no_floor_change"] = time_destroyed_2.get("has_sector", true) == false and time_destroyed_2.get("any_replacement_present", true) == false and (time_destroyed_2.get("floor_changes", [1]) as Array).is_empty() and time_destroyed_2.get("circle_radius_tiles", -1) == 0 and (time_destroyed_2.get("set_teams_calls", [1]) as Array).is_empty()

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamsDerelictProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
