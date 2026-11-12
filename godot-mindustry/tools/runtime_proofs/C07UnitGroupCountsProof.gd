extends Node

const main_scene := preload("res://scenes/Main.tscn")
const teams_runtime_state := preload("res://src/game/SourceTeamsRuntimeState.gd")
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

	# Type ids are the caller's integer ids (the catalog exposes
	# name-string ids only): dagger 2, mace 1, crawler 4; the
	# content unit count is 5 in every key below.

	# --- TeamData.updateCount (Teams.java:429-436): add grows a
	# null/empty typeCounts to the content unit count, clamps
	# both counts at 0, and reads the updated per-type count
	# back through countType (Teams.java:442-444).
	var add_grows: Dictionary = teams_runtime_state.source_team_data_update_count_state([], 2, 1, 0, 5)
	proof["update_count_add_grows"] = add_grows.get("type_counts", []) == [0, 0, 1, 0, 0] and int(add_grows.get("unit_count", -1)) == 1 and int(add_grows.get("count_type", -1)) == 1

	# --- add to an existing slot (Teams.java:435): [0,3,0] +1
	# on type 1 -> [0,4,0], unitCount 3 -> 4.
	var add_existing: Dictionary = teams_runtime_state.source_team_data_update_count_state([0, 3, 0], 1, 1, 3, 5)
	proof["update_count_add_existing"] = add_existing.get("type_counts", []) == [0, 4, 0] and int(add_existing.get("unit_count", -1)) == 4 and int(add_existing.get("count_type", -1)) == 4

	# --- remove clamps at 0 (Teams.java:431, 435): [0,1] -1 on
	# type 1 -> [0,0], unitCount 0; and -1 on [0,0] stays [0,0].
	var remove_once: Dictionary = teams_runtime_state.source_team_data_update_count_state([0, 1], 1, -1, 1, 5)
	var remove_clamped: Dictionary = teams_runtime_state.source_team_data_update_count_state([0, 0], 1, -1, 0, 5)
	proof["update_count_remove_clamps_zero"] = remove_once.get("type_counts", []) == [0, 0] and int(remove_once.get("unit_count", -1)) == 0 and remove_clamped.get("type_counts", []) == [0, 0] and int(remove_clamped.get("unit_count", -1)) == 0

	# --- grow a short array (Teams.java:432-433): [1] +1 on
	# type 3 with content size 5 -> [1,0,0,1,0] (Arrays.copyOf
	# grows to the full content unit count, not to type_id+1),
	# unitCount 1.
	var grows_array: Dictionary = teams_runtime_state.source_team_data_update_count_state([1], 3, 1, 0, 5)
	proof["update_count_grows_array"] = grows_array.get("type_counts", []) == [1, 0, 0, 1, 0] and int(grows_array.get("unit_count", -1)) == 1

	# --- countType on null counts (Teams.java:442-444): empty
	# counts, type 0, amount 0 -> zeroed to the content size,
	# countType 0.
	var null_counts: Dictionary = teams_runtime_state.source_team_data_update_count_state([], 0, 0, 0, 5)
	proof["count_type_null_counts"] = null_counts.get("type_counts", []) == [0, 0, 0, 0, 0] and int(null_counts.get("count_type", -1)) == 0

	# --- Teams.updateTeamStats (Teams.java:182-245) for one
	# team: reset (data.unitCount = 0, typeCounts filled 0)
	# then recount every live unit of the team (count(unit));
	# a unit of another team is excluded.
	var team_units: Array = [
		{"team_id": 1, "type_id": 2, "type_name": "dagger", "payload_units": []},
		{"team_id": 1, "type_id": 2, "type_name": "dagger", "payload_units": []},
		{"team_id": 1, "type_id": 1, "type_name": "mace", "payload_units": []},
		{"team_id": 2, "type_id": 2, "type_name": "dagger", "payload_units": []},
	]
	var team_stats: Dictionary = teams_runtime_state.source_team_data_update_team_stats_state(team_units, 1, 5)
	var team_counts: Dictionary = team_stats.get("team_unit_counts", {})
	proof["update_team_stats_counts_units"] = int(team_stats.get("unit_count", -1)) == 3 and int(team_counts.get("dagger", -1)) == 2 and int(team_counts.get("mace", -1)) == 1

	# --- payload recursion (Teams.count, Teams.java:168-179):
	# a dagger carrying a crawler counts both.
	var payload_units: Array = [
		{"team_id": 1, "type_id": 2, "type_name": "dagger", "payload_units": [{"team_id": 1, "type_id": 4, "type_name": "crawler", "payload_units": []}]},
	]
	var payload_stats: Dictionary = teams_runtime_state.source_team_data_update_team_stats_state(payload_units, 1, 5)
	var payload_counts: Dictionary = payload_stats.get("team_unit_counts", {})
	proof["update_team_stats_payload_recursion"] = int(payload_stats.get("unit_count", -1)) == 2 and int(payload_counts.get("dagger", -1)) == 1 and int(payload_counts.get("crawler", -1)) == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitGroupCountsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
