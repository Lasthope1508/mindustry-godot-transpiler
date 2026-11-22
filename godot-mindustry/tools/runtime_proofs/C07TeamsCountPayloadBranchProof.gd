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

	# --- Teams.count() payload branch (N2415):
	# Teams.count (Teams.java:168-179), the payload branch
	# only. The proof calls the pure function with
	# synthetic payload Arrays (no live tick): a
	# UnitPayload unit is counted into its type count,
	# unitCount and the name-keyed counts; non-unit
	# payloads are skipped; nested payload units recurse
	# through the _team_data_count_unit helper; a payload
	# unit of another team is skipped (the single-team
	# frame view, same as the N2383 helper); empty
	# payloads change nothing; the result carries exactly
	# the four expected keys in order. Type ids here:
	# dagger 0, mace 1, fortress 2 (content size 4).

	# A UnitPayload unit is counted: its type count,
	# unitCount and name-keyed count all bump by 1.
	var mace := {"team_id": 1, "type_id": 1, "type_name": "mace"}
	var counted: Dictionary = teams_state.source_teams_count_payload_branch_state([mace], 1, [], 0, 4, {})
	proof["payload_branch_counts_unit_payload_units"] = counted.get("type_counts", []) == [0, 1, 0, 0] and int(counted.get("unit_count", -1)) == 1 and counted.get("team_unit_counts", {}) == {"mace": 1}

	# Non-unit payloads are skipped: a raw Variant and a
	# block payload record (no type_id) add nothing, and
	# the UnitPayload beside them is still counted.
	var mixed: Dictionary = teams_state.source_teams_count_payload_branch_state(["scrap", {"block": "conveyor"}, mace], 1, [], 0, 4, {})
	proof["payload_branch_skips_non_unit_payloads"] = mixed.get("type_counts", []) == [0, 1, 0, 0] and int(mixed.get("unit_count", -1)) == 1 and mixed.get("team_unit_counts", {}) == {"mace": 1}

	# Nested payload units recurse: the dagger carries
	# its own payload_units with a fortress, and both
	# are counted.
	var dagger := {"team_id": 1, "type_id": 0, "type_name": "dagger", "payload_units": [{"team_id": 1, "type_id": 2, "type_name": "fortress"}]}
	var nested: Dictionary = teams_state.source_teams_count_payload_branch_state([dagger], 1, [], 0, 4, {})
	proof["payload_branch_counts_nested_payload_units"] = nested.get("type_counts", []) == [1, 0, 1, 0] and int(nested.get("unit_count", -1)) == 2 and nested.get("team_unit_counts", {}) == {"dagger": 1, "fortress": 1}

	# A payload unit of another team is skipped: the
	# single-team frame view counts only this team's
	# units, exactly as the _team_data_count_unit helper
	# does (N2383).
	var foreign := {"team_id": 2, "type_id": 1, "type_name": "mace"}
	var other_team: Dictionary = teams_state.source_teams_count_payload_branch_state([foreign], 1, [], 0, 4, {})
	proof["payload_branch_skips_other_team_payload_units"] = other_team.get("type_counts", []) == [] and int(other_team.get("unit_count", -1)) == 0 and (other_team.get("team_unit_counts", {}) as Dictionary).is_empty()

	# Empty payloads change nothing.
	var empty: Dictionary = teams_state.source_teams_count_payload_branch_state([], 1, [], 0, 4, {})
	proof["payload_branch_empty_payloads_changes_nothing"] = empty.get("type_counts", []) == [] and int(empty.get("unit_count", -1)) == 0 and (empty.get("team_unit_counts", {}) as Dictionary).is_empty()

	# The result carries exactly the four expected keys
	# in order (the N2141 result shape plus the
	# team_unit_counts view).
	proof["payload_branch_returns_expected_keys"] = counted.keys() == ["source_owner", "type_counts", "unit_count", "team_unit_counts"]

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamsCountPayloadBranchProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
