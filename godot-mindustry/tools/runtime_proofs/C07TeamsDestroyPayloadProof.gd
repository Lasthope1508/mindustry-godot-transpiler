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

	# --- Teams.destroyPayload() (N2402):
	# Teams.destroyPayload (Teams.java:483-488). One slice
	# (main-thread decision 2026-11-22, batch 25 slot 3:
	# @Remote static IS in C07 scope here -- the body is
	# pure deterministic logic, the @Remote annotation is
	# transport metadata only, recorded in the register
	# note, never as a distinguishing expr). The proof
	# calls the pure function with synthetic inputs (no
	# live tick, no packets): the happy path dumps the
	# payload and kills its unit, a null build does
	# nothing, a non-unit payload is never taken, and a
	# taken payload that is not a record is never dumped
	# or killed; the frame records the destroyed payload,
	# the dumped payloads and the killed units.
	# `build.getPayload()` / `build.takePayload()` arrive
	# as the take_payload Callable plus the
	# has_unit_payload bool; `unit.dump()` /
	# `unit.unit.killed()` arrive as frame-writing
	# Callables; no packet is ever sent.

	# The happy path dumps the payload and kills its unit:
	# the build carries a UnitPayload holding unit "u7".
	var build: Dictionary = {"pos": 42}
	var payload: Dictionary = {"unit": "u7"}
	var dumped: Array = []
	var killed: Array = []
	var taken: Array = []
	var take_payload := func(_b: Variant) -> Variant:
		taken.append(_b)
		return payload
	var dump_payload := func(p: Variant) -> void:
		dumped.append(p)
	var kill_unit := func(u: Variant) -> void:
		killed.append(u)
	var done: Dictionary = teams_state.source_teams_destroy_payload_state(build, true, take_payload, dump_payload, kill_unit)
	proof["destroy_payload_dumps_and_kills_unit_payload"] = (done.get("destroyed_payload", null) as Dictionary) == payload and done.get("dumped_payloads", []) == [payload] and done.get("killed_units", []) == ["u7"] and taken == [build] and dumped == [payload] and killed == ["u7"]
	proof["destroy_payload_returns_only_three_keys"] = done.size() == 3

	# A null build does nothing: take is never called.
	var taken_null: Array = []
	var take_null := func(_b: Variant) -> Variant:
		taken_null.append(_b)
		return payload
	var dumped_null: Array = []
	var killed_null: Array = []
	var skipped_null: Dictionary = teams_state.source_teams_destroy_payload_state(null, true, take_null, func(p: Variant) -> void: dumped_null.append(p), func(u: Variant) -> void: killed_null.append(u))
	proof["destroy_payload_skips_null_build"] = skipped_null.get("destroyed_payload", "set") == null and skipped_null.get("dumped_payloads", ["x"]) == [] and skipped_null.get("killed_units", ["x"]) == [] and taken_null == [] and dumped_null == [] and killed_null == []

	# A non-unit payload is never taken: take is not
	# called, nothing is dumped or killed.
	var taken_plain: Array = []
	var take_plain := func(_b: Variant) -> Variant:
		taken_plain.append(_b)
		return payload
	var dumped_plain: Array = []
	var killed_plain: Array = []
	var skipped_plain: Dictionary = teams_state.source_teams_destroy_payload_state(build, false, take_plain, func(p: Variant) -> void: dumped_plain.append(p), func(u: Variant) -> void: killed_plain.append(u))
	proof["destroy_payload_skips_non_unit_payload"] = skipped_plain.get("destroyed_payload", "set") == null and skipped_plain.get("dumped_payloads", ["x"]) == [] and skipped_plain.get("killed_units", ["x"]) == [] and taken_plain == [] and dumped_plain == [] and killed_plain == []

	# A taken payload that is not a record is never dumped
	# or killed: the takePayload() instanceof check fails.
	var dumped_str: Array = []
	var killed_str: Array = []
	var take_str := func(_b: Variant) -> Variant:
		return "not-a-payload-record"
	var skipped_str: Dictionary = teams_state.source_teams_destroy_payload_state(build, true, take_str, func(p: Variant) -> void: dumped_str.append(p), func(u: Variant) -> void: killed_str.append(u))
	proof["destroy_payload_skips_non_dict_payload"] = skipped_str.get("destroyed_payload", "set") == null and skipped_str.get("dumped_payloads", ["x"]) == [] and skipped_str.get("killed_units", ["x"]) == [] and dumped_str == [] and killed_str == []

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamsDestroyPayloadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
