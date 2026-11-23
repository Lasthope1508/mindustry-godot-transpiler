extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bridge := preload("res://src/game/SourcePayloadAmmoTurretBuildPortBridge.gd")
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

	# --- PayloadTurret limitRange()+limitRange(float)+setStats() (N2384):
	# PayloadTurret limitRange()+limitRange(float)+setStats()
	# (PayloadAmmoTurret.java:40-42/:45-49/:51-56) groups three
	# class methods: limitRange(float) rewrites every ammo bullet
	# lifetime to (range + margin) / speed over a copy of the ammo
	# map (`entry.value.lifetime = (range + margin) / entry.value.speed;`);
	# limitRange() delegates with margin 1f (`limitRange(1f);`);
	# setStats drops the itemCapacity row
	# (`stats.remove(Stat.itemCapacity);`) and adds the ammo row
	# (`stats.add(Stat.ammo, StatValues.ammo(ammoTypes, true));`).
	# `super.setStats();` is callee/context. The proof calls the
	# three pure functions with synthetic inputs (no live tick).
	# NO driver tick line of its own: limitRange is a def-time
	# setup call, setStats is a UI spec.

	# limitRange rewrites lifetimes to (range + margin) / speed:
	# range 80, margin 1 -> copper speed 2 gets 40.5, lead speed 4
	# gets 20.25.
	var entries: Array = [
		{"content": "copper", "lifetime": 0.0, "speed": 2.0},
		{"content": "lead", "lifetime": 0.0, "speed": 4.0},
	]
	var limited: Dictionary = bridge.source_payload_ammo_turret_limit_range_state(entries, 80.0, 1.0)
	var limited_entries: Array = limited.get("ammo_entries", [])
	proof["limit_range_sets_lifetime"] = limited_entries.size() == 2 and (limited_entries[0] as Dictionary).get("lifetime", -1.0) == 40.5 and (limited_entries[1] as Dictionary).get("lifetime", -1.0) == 20.25

	# The no-arg form delegates with margin 1f: same lifetimes
	# as limitRange(range 80, margin 1).
	var defaulted: Dictionary = bridge.source_payload_ammo_turret_limit_range_default_state(entries, 80.0)
	var defaulted_entries: Array = defaulted.get("ammo_entries", [])
	proof["limit_range_default_margin_one"] = defaulted_entries.size() == 2 and (defaulted_entries[0] as Dictionary).get("lifetime", -1.0) == 40.5 and (defaulted_entries[1] as Dictionary).get("lifetime", -1.0) == 20.25

	# Other fields are kept: content names and speeds survive
	# the rewrite, in order.
	proof["limit_range_keeps_other_fields"] = (limited_entries[0] as Dictionary).get("content", "") == "copper" and (limited_entries[0] as Dictionary).get("speed", -1.0) == 2.0 and (limited_entries[1] as Dictionary).get("content", "") == "lead" and (limited_entries[1] as Dictionary).get("speed", -1.0) == 4.0

	# Inputs are read, never written: the entries are unchanged
	# after both calls (the Java copy means the original bullets
	# are never touched).
	var entries_before: Array = entries.duplicate(true)
	bridge.source_payload_ammo_turret_limit_range_state(entries, 80.0, 1.0)
	bridge.source_payload_ammo_turret_limit_range_default_state(entries, 80.0)
	proof["limit_range_inputs_unmutated"] = entries == entries_before

	# The limitRange result carries EXACTLY the one key.
	proof["limit_range_returns_only_one_key"] = limited.size() == 1

	# limitRange of empty ammo entries returns empty.
	var limited_empty: Dictionary = bridge.source_payload_ammo_turret_limit_range_state([], 80.0, 1.0)
	proof["limit_range_empty_returns_empty"] = (limited_empty.get("ammo_entries", ["not-empty"]) as Array).is_empty()

	# setStats removes the itemCapacity row and keeps the rest.
	var stats_in: Array = [{"stat": "itemCapacity"}, {"stat": "health"}]
	var updated: Dictionary = bridge.source_payload_ammo_turret_set_stats_state(stats_in, ["copper", "lead"])
	var updated_stats: Array = updated.get("stats", [])
	proof["set_stats_removes_item_capacity"] = updated_stats.size() == 2 and not updated_stats.any(func(row): return (row as Dictionary).get("stat", "") == "itemCapacity") and (updated_stats[0] as Dictionary).get("stat", "") == "health"

	# setStats adds the ammo row with the ammo types list and
	# the showUnit flag (StatValues.ammo(ammoTypes, true)).
	var ammo_row: Dictionary = updated_stats[1] as Dictionary
	proof["set_stats_adds_ammo_row"] = ammo_row.get("stat", "") == "ammo" and ammo_row.get("ammo_types", []) == ["copper", "lead"] and ammo_row.get("show_unit", false) == true

	# Inputs are read, never written: the stats rows and the
	# ammo types list are unchanged after the call.
	var stats_before: Array = stats_in.duplicate(true)
	var ammo_before: Array = ["copper", "lead"]
	bridge.source_payload_ammo_turret_set_stats_state(stats_in, ammo_before)
	proof["set_stats_inputs_unmutated"] = stats_in == stats_before and ammo_before == ["copper", "lead"]

	# The setStats result carries EXACTLY the one key.
	proof["set_stats_returns_only_one_key"] = updated.size() == 1

	# setStats of empty stats still adds the ammo row.
	var updated_empty: Dictionary = bridge.source_payload_ammo_turret_set_stats_state([], ["copper"])
	var empty_stats: Array = updated_empty.get("stats", [])
	proof["set_stats_empty_stats_adds_ammo"] = empty_stats.size() == 1 and (empty_stats[0] as Dictionary).get("stat", "") == "ammo"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadTurretLimitRangeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
