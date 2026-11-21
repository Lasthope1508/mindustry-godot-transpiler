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

	# --- Teams.updateActive()+Teams() (N2399):
	# Teams.updateActive (Teams.java:135-141) /
	# Teams() (Teams.java:34-36). One grouped slice
	# (main-thread decision 2026-11-22, batch 24 slot 3:
	# KEEP updateActive+ctor, do NOT switch to
	# destroyPayload -- destroyPayload is a @Remote static,
	# its C07 scope is undecided, decided separately in a
	# later batch). The proof calls the two pure functions
	# with synthetic inputs (no live tick, no packets):
	# the ctor seeds active with crux on a fresh state;
	# updateActive adds an active team once, skips a team
	# already active or an inactive team, creates a missing
	# team entry without adding it, refreshes the enemies
	# map on add, and keeps the wave team active through
	# updateEnemies; the frame records the active list
	# before and after. `data.active()` /
	# `active.contains(data)` / `active.add(data)` /
	# `updateEnemies()` are N2074/N2075-owned -- the file's
	# _teams_active / _teams_update_enemies helpers ARE
	# those callees, called as evidence only, never
	# re-registered.

	# The ctor seeds the active list with crux on a fresh
	# state, creating the crux TeamData entry.
	var ctor_state: Dictionary = {"teams": {}, "active": [], "rules": {}}
	var ctor: Dictionary = teams_state.source_teams_default_constructor_state(ctor_state, 2)
	proof["ctor_seeds_crux_active"] = ctor.get("active", []) == [2] and (ctor.get("team_data", {}) as Dictionary) == {"cores": [], "buildings": [], "units": [], "core_enemies": []} and (ctor_state.get("teams", {}) as Dictionary).has(2)
	proof["ctor_returns_only_three_keys"] = ctor.size() == 3

	# updateActive adds an active team once: team 1 has a
	# core, so it is active, and it is not in the list yet.
	var add_state: Dictionary = {"teams": {1: {"cores": ["c1"], "buildings": [], "units": [], "core_enemies": []}}, "active": [], "rules": {}}
	var added: Dictionary = teams_state.source_teams_update_active_state(add_state, 1)
	proof["update_active_adds_active_team"] = added.get("active_changed", false) == true and added.get("active", []) == [1] and (added.get("enemies_by_team", {}) as Dictionary) == {1: []}
	proof["update_active_returns_only_four_keys"] = added.size() == 4

	# updateActive skips a team already in the active list.
	var skip_state: Dictionary = {"teams": {1: {"cores": ["c1"], "buildings": [], "units": [], "core_enemies": []}}, "active": [1], "rules": {}}
	var skipped: Dictionary = teams_state.source_teams_update_active_state(skip_state, 1)
	proof["update_active_skips_already_active"] = skipped.get("active_changed", true) == false and skipped.get("active", []) == [1]

	# updateActive skips an inactive team: no cores, no
	# buildings, no units, not the wave team.
	var inactive_state: Dictionary = {"teams": {3: {"cores": [], "buildings": [], "units": [], "core_enemies": []}}, "active": [], "rules": {}}
	var inactive: Dictionary = teams_state.source_teams_update_active_state(inactive_state, 3)
	proof["update_active_skips_inactive_team"] = inactive.get("active_changed", true) == false and inactive.get("active", []) == []

	# updateActive creates a missing team entry (the get()
	# inside the group) without adding it -- a fresh entry
	# is inactive.
	var missing_state: Dictionary = {"teams": {}, "active": [], "rules": {}}
	var missing: Dictionary = teams_state.source_teams_update_active_state(missing_state, 5)
	proof["update_active_creates_missing_team"] = missing.get("active_changed", true) == false and missing.get("active", []) == [] and (missing_state.get("teams", {}) as Dictionary).has(5)

	# updateActive refreshes the enemies map on add: team 2
	# joins team 1, each sees the other as its only enemy.
	var enemies_state: Dictionary = {"teams": {1: {"cores": ["c1"], "buildings": [], "units": [], "core_enemies": []}, 2: {"cores": ["c2"], "buildings": [], "units": [], "core_enemies": []}}, "active": [1], "rules": {}}
	var enemies: Dictionary = teams_state.source_teams_update_active_state(enemies_state, 2)
	proof["update_active_updates_enemies"] = enemies.get("active", []) == [1, 2] and (enemies.get("enemies_by_team", {}) as Dictionary) == {1: [2], 2: [1]}

	# updateActive keeps the wave team active through
	# updateEnemies: adding team 1 also pulls wave team 6
	# into the active list.
	var wave_state: Dictionary = {"teams": {1: {"cores": ["c1"], "buildings": [], "units": [], "core_enemies": []}}, "active": [], "rules": {"waves": true, "wave_team": 6}}
	var waved: Dictionary = teams_state.source_teams_update_active_state(wave_state, 1)
	proof["update_active_enemies_keeps_wave_team_active"] = waved.get("active", []) == [1, 6] and (waved.get("enemies_by_team", {}) as Dictionary) == {1: [6], 6: [1]}

	# The frame records the active list before and after:
	# ctor seeds [crux], then updateActive registers
	# sharded next to it.
	var frame_state: Dictionary = {"teams": {}, "active": [], "rules": {}}
	var framed_ctor: Dictionary = teams_state.source_teams_default_constructor_state(frame_state, 2)
	var active_before: Array = (framed_ctor.get("active", []) as Array).duplicate()
	(frame_state.get("teams", {}) as Dictionary)[1] = {"cores": ["c1"], "buildings": [], "units": [], "core_enemies": []}
	var framed: Dictionary = teams_state.source_teams_update_active_state(frame_state, 1)
	proof["update_active_frame_active_before_after"] = active_before == [2] and framed.get("active", []) == [2, 1] and framed.get("active_changed", false) == true

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamsUpdateActiveProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
