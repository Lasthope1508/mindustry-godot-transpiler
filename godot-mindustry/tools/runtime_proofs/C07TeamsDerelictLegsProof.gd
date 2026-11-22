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

	# --- TeamData destroyToDerelict/timeDestroy leftover legs
	# (N2427): the 8 exprs N2395 did not register --
	# `for(var b : builds){` (Teams.java:340),
	# `if(b instanceof CoreBuild){` (:343),
	# `b.kill();` (:344),
	# `u.kill();` (:356, in the units.each Time.run lambda),
	# `for(var build : builds){` (:368),
	# `scheduleDerelict(build);` (:370),
	# `if(any){` (:384), and
	# `if(result != null && !cores.contains(c -> c.within(t, range))){`
	# (:388). The two GD functions already exist (N2395);
	# the proof calls them with synthetic inputs (no live
	# tick, no packets, no real kills) and drives one key
	# per leg. `scheduleDerelict(build);` (:370, variable
	# `build`) is NOT `scheduleDerelict(b);` (:347,
	# variable `b`, N2395). Call.destroyPayload /
	# Call.setTeams arrive as Callables recording their
	# calls; Time.run arrives as a Callable recording
	# delay+action (the proof executes the recorded unit
	# actions to check both branches of the team check);
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

	# destroyToDerelict: the `for(var b : builds){` loop
	# (:340) visits every build; the `if(b instanceof
	# CoreBuild){` branch (:343) is taken only for cores;
	# `b.kill();` (:344) really calls kill_build at once;
	# the per-unit `u.kill();` (:356) runs only when the
	# recorded action executes for a unit still on the
	# team -- a unit that switched teams by the time the
	# action runs is spared, exactly as the Java comment
	# says ("ensure unit hasn't switched teams").
	var destroy_builds: Array = [
		{"pos": 20, "privileged": true, "is_core": true, "has_unit_payload": false},
		{"pos": 21, "privileged": false, "is_core": true, "has_unit_payload": false},
		{"pos": 22, "privileged": false, "is_core": false, "has_unit_payload": false},
		{"pos": 23, "privileged": false, "is_core": false, "has_unit_payload": false},
	]
	var destroy_plans: Array = ["plan-a"]
	var destroy_units: Array = [
		{"team_id": 5, "ref": "u-same"},
		{"team_id": 6, "ref": "u-switched"},
	]
	var destroy_buffer: Array = []
	var time_runs_before: int = time_runs.size()
	var destroyed: Dictionary = teams_state.source_team_data_destroy_to_derelict_state(destroy_builds, destroy_plans, destroy_units, 5, destroy_buffer, [3.0, 4.0], [0.1, 0.5], [15.0, 17.0], destroy_payload, time_run, kill_build, kill_unit, add_plan, set_teams)
	proof["for_b_builds_iterates_all"] = (destroyed.get("builds", []) as Array).size() == 4
	proof["core_branch_taken"] = destroyed.get("killed_cores", []) == [21] and (destroyed.get("scheduled_kills", []) as Array) == [{"delay": 15.0, "build_pos": 22}] and add_plan_calls == [[22, false, true], [23, false, true]]
	proof["core_kill_called"] = killed_builds == [21]
	# time_runs order after destroy: the pos-22 scheduled
	# kill action first, then one action per unit.
	var unit_action_same: Callable = time_runs[time_runs_before + 1].get("action", Callable())
	var unit_action_switched: Callable = time_runs[time_runs_before + 2].get("action", Callable())
	# The switched unit changes teams before its delayed
	# action runs: the lambda reads the live team_id from
	# the shared unit record, so it must be spared.
	(destroy_units[1] as Dictionary)["team_id"] = 9
	unit_action_same.call()
	unit_action_switched.call()
	proof["unit_kill_executes_same_team_only"] = killed_units == [{"team_id": 5, "ref": "u-same"}] and (destroyed.get("scheduled_unit_kills", []) as Array).size() == 2

	# timeDestroy: the `for(var build : builds){` loop
	# (:368) visits every build; the qualifying build
	# goes through `scheduleDerelict(build);` (:370);
	# the `if(any){` gate (:384) opens the circle only
	# when a replacement key is present; the
	# `if(result != null && !cores.contains(...)){` gate
	# (:388) changes a floor only when the replacement
	# result is non-null AND no core is nearby.
	var time_builds: Array = [
		{"pos": 30, "privileged": true, "within_range": true, "near_core": false, "has_unit_payload": false},
		{"pos": 31, "privileged": false, "within_range": false, "near_core": false, "has_unit_payload": false},
		{"pos": 32, "privileged": false, "within_range": true, "near_core": true, "has_unit_payload": false},
		{"pos": 33, "privileged": false, "within_range": true, "near_core": false, "has_unit_payload": false},
	]
	var sector: Dictionary = {"replacements": {"sand": "rock", "dirt": "grass"}, "present_keys": ["sand"]}
	var circle_tiles: Array = [
		{"tx": 5, "ty": 5, "floor": "sand", "near_core": false},
		{"tx": 6, "ty": 6, "floor": "dirt", "near_core": false},
		{"tx": 7, "ty": 7, "floor": "sand", "near_core": true},
		{"tx": 8, "ty": 8, "floor": "water", "near_core": false},
	]
	var time_buffer: Array = []
	var time_destroyed: Dictionary = teams_state.source_team_data_time_destroy_state(0.0, 0.0, 80.0, time_builds, time_buffer, [0.1], [9.0], sector, circle_tiles, 8.0, destroy_payload, time_run, kill_build, add_plan, set_teams, set_floor)
	proof["for_build_builds_iterates_all"] = (time_destroyed.get("builds", []) as Array).size() == 4
	proof["schedule_derelict_build_called"] = (time_destroyed.get("scheduled_kills", []) as Array) == [{"delay": 9.0, "build_pos": 33}] and (time_destroyed.get("set_teams_calls", []) as Array) == [{"values": [33], "team": "derelict"}]
	proof["any_gate_opens_circle"] = time_destroyed.get("any_replacement_present", false) == true and time_destroyed.get("circle_radius_tiles", -1) == 10
	proof["result_and_no_core_gate"] = (time_destroyed.get("floor_changes", []) as Array) == [{"tx": 5, "ty": 5, "floor": "rock"}, {"tx": 6, "ty": 6, "floor": "grass"}] and floor_calls.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamsDerelictLegsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
