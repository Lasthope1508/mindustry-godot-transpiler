extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- Turret power-graph last-values stamp (N2522): the live
	# tick stamps the graph snapshot into the frame, so the
	# N2519-wired dispatch `source_building_comp_sense_state`
	# stops reporting handled:false for the powerNet* legs when
	# a live turret ticks (BuildingComp.sense() is `public double
	# sense(LAccess sensor){`, BuildingComp.java:2093-2126).
	# The tick is TurretBuild.updateTile() (`public void
	# updateTile(){`, Turret.java:490). The stamp copies the
	# owner's snapshot (the
	# `source_factory_update_power_graph_state` return, whose
	# `update` is the `update_state` output — PowerGraph.update()
	# is `public void update(){`, PowerGraph.java:216-260) into
	# exactly four keys:
	# - `last_scaled_power_in` from `update["balance_state"]`
	# (`lastScaledPowerIn = (powerProduced + energyDelta) /
	# Time.delta;`, PowerGraph.java:233; `case powerNetIn ->
	# power == null ? 0 : power.graph.getLastScaledPowerIn() *
	# 60;`, BuildingComp.java:2113);
	# - `last_scaled_power_out` from `update["balance_state"]`
	# (`lastScaledPowerOut = powerNeeded / Time.delta;`,
	# PowerGraph.java:234; `case powerNetOut -> power == null ?
	# 0 : power.graph.getLastScaledPowerOut() * 60;`,
	# BuildingComp.java:2114);
	# - `last_capacity` from `update["balance_state"]`
	# (`lastCapacity = getTotalBatteryCapacity();`,
	# PowerGraph.java:235; `case powerNetCapacity -> power ==
	# null ? 0 : power.graph.getLastCapacity();`,
	# BuildingComp.java:2116);
	# - `last_power_stored` from `update["last_power_stored"]`
	# (top-level on BOTH branches, `lastPowerStored =
	# getBatteryStored();`, PowerGraph.java:236; `case
	# powerNetStored -> power == null ? 0 : power.graph.
	# getLastPowerStored();`, BuildingComp.java:2115).
	# A key is stamped ONLY when present: on the cheat branch
	# `balance_state` is `{}` (Java returns before :233-236,
	# PowerGraph.java:217-224, so the fields keep their previous
	# values) and the stamp leaves the scaled/capacity keys
	# untouched; an empty `{}` update stamps NOTHING, so the
	# dispatch keeps handled:false for powerNet* (the N2519
	# absent-key fallback). The stamp does NOT recompute any
	# formula (it lives once in `update_balance_state`,
	# SourcePowerGraphBalanceState.gd:116-119) and does NOT call
	# the graph update. The proof calls the stamp directly with
	# synthetic graph updates, then the dispatch, end to end.
	# Duo catalog values unless noted: solid true, size 1,
	# maxHealth 250, range 160, itemCapacity 10, hasLiquids
	# false, no consumePower, timeScale 1.0, not
	# player-controlled, payloadCount 0. The dispatch reads
	# powerNet* with has_power=true (a power module is present,
	# so the legs read the stamped graph values, not the 0.0
	# null-power fold).

	var sharded := Color.html("ffd37f")
	var full_update: Dictionary = {"update": {"balance_state": {"last_scaled_power_in": 2.0, "last_scaled_power_out": 1.5, "last_capacity": 1000.0}, "last_power_stored": 250.0}}

	# Full update: powerNetIn 120.0 (= 2.0 * 60),
	# powerNetOut 90.0 (= 1.5 * 60), powerNetStored 250.0,
	# powerNetCapacity 1000.0, all handled:true.
	var graph_frame: Dictionary = turret_build_state.source_turret_power_graph_last_values_stamp_state({}, full_update)
	var power_net_in: Dictionary = turret_build_state.source_building_comp_sense_state(graph_frame, "powerNetIn", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["stamp_graph_power_net_in_num"] = bool(power_net_in.get("handled", false)) and is_equal_approx(float(power_net_in.get("sense_value", 0.0)), 120.0) and not bool(power_net_in.get("sense_value_is_nan", true))
	var power_net_out: Dictionary = turret_build_state.source_building_comp_sense_state(graph_frame, "powerNetOut", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["stamp_graph_power_net_out_num"] = bool(power_net_out.get("handled", false)) and is_equal_approx(float(power_net_out.get("sense_value", 0.0)), 90.0) and not bool(power_net_out.get("sense_value_is_nan", true))
	var power_net_stored: Dictionary = turret_build_state.source_building_comp_sense_state(graph_frame, "powerNetStored", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["stamp_graph_power_net_stored_num"] = bool(power_net_stored.get("handled", false)) and is_equal_approx(float(power_net_stored.get("sense_value", 0.0)), 250.0) and not bool(power_net_stored.get("sense_value_is_nan", true))
	var power_net_capacity: Dictionary = turret_build_state.source_building_comp_sense_state(graph_frame, "powerNetCapacity", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["stamp_graph_power_net_capacity_num"] = bool(power_net_capacity.get("handled", false)) and is_equal_approx(float(power_net_capacity.get("sense_value", 0.0)), 1000.0) and not bool(power_net_capacity.get("sense_value_is_nan", true))

	# Cheat-branch update: `balance_state` is `{}` (Java
	# returns before :233-236), so the scaled/capacity keys
	# keep the previous tick's values (powerNetIn still
	# 120.0); `last_power_stored` IS present on the cheat
	# branch in the port owner, so stored updates to 300.0.
	var cheat_update: Dictionary = {"update": {"balance_state": {}, "last_power_stored": 300.0}}
	var cheat_frame: Dictionary = turret_build_state.source_turret_power_graph_last_values_stamp_state(graph_frame, cheat_update)
	var power_net_in_cheat: Dictionary = turret_build_state.source_building_comp_sense_state(cheat_frame, "powerNetIn", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["stamp_graph_cheat_keeps_scaled_num"] = bool(power_net_in_cheat.get("handled", false)) and is_equal_approx(float(power_net_in_cheat.get("sense_value", 0.0)), 120.0) and not bool(power_net_in_cheat.get("sense_value_is_nan", true))
	var power_net_stored_cheat: Dictionary = turret_build_state.source_building_comp_sense_state(cheat_frame, "powerNetStored", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["stamp_graph_cheat_updates_stored_num"] = bool(power_net_stored_cheat.get("handled", false)) and is_equal_approx(float(power_net_stored_cheat.get("sense_value", 0.0)), 300.0) and not bool(power_net_stored_cheat.get("sense_value_is_nan", true))

	# Empty update: the stamp writes nothing, so powerNetIn
	# stays handled:false (the N2519 absent-key fallback).
	var empty_frame: Dictionary = turret_build_state.source_turret_power_graph_last_values_stamp_state({}, {})
	var power_net_in_empty: Dictionary = turret_build_state.source_building_comp_sense_state(empty_frame, "powerNetIn", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["stamp_graph_empty_update_keeps_absent_num"] = not bool(power_net_in_empty.get("handled", true)) and power_net_in_empty.get("sense_value", 0.0) == null and bool(power_net_in_empty.get("sense_value_is_nan", false))

	# The sense stamp (N2520), the ammo-items stamp (N2521)
	# and the graph stamp compose on one frame: health 250.0,
	# dead 0.0, totalItems 0.0 and powerNetIn 120.0 all read
	# handled:true from the same frame.
	var composed_frame: Dictionary = turret_build_state.source_turret_sense_frame_stamp_state({}, 250.0, 0.0)
	composed_frame = turret_build_state.source_turret_ammo_items_stamp_state(composed_frame, true)
	composed_frame = turret_build_state.source_turret_power_graph_last_values_stamp_state(composed_frame, full_update)
	var health_composed: Dictionary = turret_build_state.source_building_comp_sense_state(composed_frame, "health", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	var dead_composed: Dictionary = turret_build_state.source_building_comp_sense_state(composed_frame, "dead", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	var total_items_composed: Dictionary = turret_build_state.source_building_comp_sense_state(composed_frame, "totalItems", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	var power_net_in_composed: Dictionary = turret_build_state.source_building_comp_sense_state(composed_frame, "powerNetIn", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["stamp_graph_composed_num"] = bool(health_composed.get("handled", false)) and is_equal_approx(float(health_composed.get("sense_value", 0.0)), 250.0) and bool(dead_composed.get("handled", false)) and is_equal_approx(float(dead_composed.get("sense_value", 1.0)), 0.0) and bool(total_items_composed.get("handled", false)) and is_equal_approx(float(total_items_composed.get("sense_value", 1.0)), 0.0) and bool(power_net_in_composed.get("handled", false)) and is_equal_approx(float(power_net_in_composed.get("sense_value", 0.0)), 120.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretPowerGraphLastValuesStampProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
