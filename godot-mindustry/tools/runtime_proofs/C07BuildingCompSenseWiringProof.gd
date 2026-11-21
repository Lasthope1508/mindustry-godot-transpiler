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

	# --- BuildingComp.sense() wiring (N2519): connect the 8
	# already-ported legs into the dispatch
	# `source_building_comp_sense_state`
	# (BuildingComp.java:2093-2126). N2284 ported the dispatch
	# with 23 handled legs and left dead / health / totalItems
	# / camera* / powerNet* deferred (handled:false + NaN).
	# N2511 ported `dead` (`case dead -> !isValid() ? 1 : 0;`,
	# :2098), N2512 `health` (`case health -> health;`,
	# :2101), N2513 `totalItems` (`case totalItems -> items
	# == null ? 0 : items.total();`, :2107), N2514
	# `powerNetIn` (`case powerNetIn -> power == null ? 0 :
	# power.graph.getLastScaledPowerIn() * 60;`, :2114),
	# N2515 `powerNetOut` (`case powerNetOut -> power ==
	# null ? 0 : power.graph.getLastScaledPowerOut() * 60;`,
	# :2115), N2516 `powerNetStored` (`case powerNetStored
	# -> power == null ? 0 : power.graph.getLastPowerStored();`,
	# :2116), N2517 `powerNetCapacity` (`case powerNetCapacity
	# -> power == null ? 0 : power.graph.getLastCapacity();`,
	# :2117), N2518 camera* (`case cameraX, cameraY,
	# cameraWidth, cameraHeight -> this instanceof
	# ControlBlock c ? c.unit().sense(sensor) : 0;`, :2122)
	# -- each as its own pure function living beside the
	# dispatch. This slice wires all eight legs into the
	# dispatch. The signature is UNCHANGED (24 params stay
	# 24, the N2235 precedent): the leg inputs arrive as 11
	# frame keys (`tile_build_is_self`, `is_dead`, `health`,
	# `items_is_null`, `items_total`,
	# `last_scaled_power_in`, `last_scaled_power_out`,
	# `last_power_stored`, `last_capacity`,
	# `is_control_block`, `unit_sense_value` -- plus the
	# existing `has_power` param as `power_is_null =
	# not has_power`). An absent key keeps the OLD behavior
	# exactly (handled:false + NaN, the N2284 deferred
	# state); presence is checked with `frame.has(key)`, NOT
	# with a default value, so a present key carrying 0 /
	# false is live input, not absence. A present key
	# delegates to the leg function and returns its result
	# VERBATIM (same 3-key wire shape; the dispatch never
	# re-derives the value -- the leg function IS the Java
	# case). Branch placement mirrors Java switch order:
	# dead after `color` (before `solid`); health after
	# `team` (before `maxHealth`); totalItems after
	# `rotation` (before `totalLiquids`); powerNet* replaces
	# the `has_power == true` fallthrough inside the existing
	# powerNet branch (the `has_power == false` -> 0.0 fold
	# stays FIRST and unchanged); camera* after `size`
	# (before the final default return). There is no driver
	# tick line: wiring the dispatch is a pure composition
	# step (the N2206/N2208/N2223/N2283/N2284/N2506-N2518
	# precedent); the proof calls the dispatch directly with
	# synthetic frames. Duo catalog values unless noted:
	# solid true, size 1, maxHealth 250, range 160,
	# itemCapacity 10, hasLiquids false, no consumePower,
	# timeScale 1.0, not player-controlled, payloadCount 0.

	var sharded := Color.html("ffd37f")

	# Dead wired: tile self + alive reads 0.0
	# (`!isValid() ? 1 : 0`, `isValid()` is `tile.build ==
	# self() && !dead()`, BuildingComp.java:2031).
	var dead_alive: Dictionary = turret_build_state.source_building_comp_sense_state({"tile_build_is_self": true, "is_dead": false}, "dead", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["wiring_dead_alive_num"] = bool(dead_alive.get("handled", false)) and is_equal_approx(float(dead_alive.get("sense_value", 1.0)), 0.0) and not bool(dead_alive.get("sense_value_is_nan", true))

	# Dead wired: tile self + dead reads 1.0.
	var dead_dead: Dictionary = turret_build_state.source_building_comp_sense_state({"tile_build_is_self": true, "is_dead": true}, "dead", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["wiring_dead_dead_num"] = bool(dead_dead.get("handled", false)) and is_equal_approx(float(dead_dead.get("sense_value", 0.0)), 1.0) and not bool(dead_dead.get("sense_value_is_nan", true))

	# Dead wired: tile not self reads 1.0 (the first
	# `isValid()` conjunct fails, so the value is 1.0 even
	# though `is_dead` is false).
	var dead_not_self: Dictionary = turret_build_state.source_building_comp_sense_state({"tile_build_is_self": false, "is_dead": false}, "dead", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["wiring_dead_not_self_num"] = bool(dead_not_self.get("handled", false)) and is_equal_approx(float(dead_not_self.get("sense_value", 0.0)), 1.0) and not bool(dead_not_self.get("sense_value_is_nan", true))

	# Health wired: 250.0 reads back 250.0.
	var health: Dictionary = turret_build_state.source_building_comp_sense_state({"health": 250.0}, "health", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["wiring_health_num"] = bool(health.get("handled", false)) and is_equal_approx(float(health.get("sense_value", 0.0)), 250.0) and not bool(health.get("sense_value_is_nan", true))

	# TotalItems wired: items present, total 7 reads 7.0.
	var total_items: Dictionary = turret_build_state.source_building_comp_sense_state({"items_is_null": false, "items_total": 7}, "totalItems", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["wiring_total_items_num"] = bool(total_items.get("handled", false)) and is_equal_approx(float(total_items.get("sense_value", 0.0)), 7.0) and not bool(total_items.get("sense_value_is_nan", true))

	# TotalItems wired: items null reads 0.0.
	var total_items_null: Dictionary = turret_build_state.source_building_comp_sense_state({"items_is_null": true, "items_total": 0}, "totalItems", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["wiring_total_items_null_num"] = bool(total_items_null.get("handled", false)) and is_equal_approx(float(total_items_null.get("sense_value", 1.0)), 0.0) and not bool(total_items_null.get("sense_value_is_nan", true))

	# PowerNetIn wired: has_power + last_scaled_power_in
	# 2.5 reads 2.5 * 60 = 150.0.
	var power_net_in: Dictionary = turret_build_state.source_building_comp_sense_state({"last_scaled_power_in": 2.5}, "powerNetIn", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["wiring_power_net_in_num"] = bool(power_net_in.get("handled", false)) and is_equal_approx(float(power_net_in.get("sense_value", 0.0)), 150.0) and not bool(power_net_in.get("sense_value_is_nan", true))

	# PowerNetOut wired: has_power + last_scaled_power_out
	# 1.0 reads 1.0 * 60 = 60.0.
	var power_net_out: Dictionary = turret_build_state.source_building_comp_sense_state({"last_scaled_power_out": 1.0}, "powerNetOut", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["wiring_power_net_out_num"] = bool(power_net_out.get("handled", false)) and is_equal_approx(float(power_net_out.get("sense_value", 0.0)), 60.0) and not bool(power_net_out.get("sense_value_is_nan", true))

	# PowerNetStored wired: has_power + last_power_stored
	# 500.0 reads 500.0 (NO `* 60` -- an absolute amount).
	var power_net_stored: Dictionary = turret_build_state.source_building_comp_sense_state({"last_power_stored": 500.0}, "powerNetStored", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["wiring_power_net_stored_num"] = bool(power_net_stored.get("handled", false)) and is_equal_approx(float(power_net_stored.get("sense_value", 0.0)), 500.0) and not bool(power_net_stored.get("sense_value_is_nan", true))

	# PowerNetCapacity wired: has_power + last_capacity
	# 1000.0 reads 1000.0 (NO `* 60` -- an absolute amount).
	var power_net_capacity: Dictionary = turret_build_state.source_building_comp_sense_state({"last_capacity": 1000.0}, "powerNetCapacity", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["wiring_power_net_capacity_num"] = bool(power_net_capacity.get("handled", false)) and is_equal_approx(float(power_net_capacity.get("sense_value", 0.0)), 1000.0) and not bool(power_net_capacity.get("sense_value_is_nan", true))

	# CameraX wired: a control block passes the unit sense
	# value through (12.5 reads back 12.5).
	var camera_x: Dictionary = turret_build_state.source_building_comp_sense_state({"is_control_block": true, "unit_sense_value": 12.5}, "cameraX", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["wiring_camera_x_num"] = bool(camera_x.get("handled", false)) and is_equal_approx(float(camera_x.get("sense_value", 0.0)), 12.5) and not bool(camera_x.get("sense_value_is_nan", true))

	# CameraY not a control block reads 0.0 (any sensor --
	# the unit value is ignored when the gate fails).
	var camera_y_not_control: Dictionary = turret_build_state.source_building_comp_sense_state({"is_control_block": false, "unit_sense_value": 12.5}, "cameraY", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["wiring_camera_y_not_control_num"] = bool(camera_y_not_control.get("handled", false)) and is_equal_approx(float(camera_y_not_control.get("sense_value", 1.0)), 0.0) and not bool(camera_y_not_control.get("sense_value_is_nan", true))

	# Absent-key fallback: dead with no frame keys keeps the
	# N2284 behavior (handled:false + NaN).
	var dead_absent: Dictionary = turret_build_state.source_building_comp_sense_state({}, "dead", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["wiring_dead_absent_fallback"] = not bool(dead_absent.get("handled", true)) and dead_absent.get("sense_value", 0.0) == null and bool(dead_absent.get("sense_value_is_nan", false))

	# Absent-key fallback: powerNetIn with power present but
	# no graph key keeps the N2284 behavior (handled:false +
	# NaN).
	var power_net_in_absent: Dictionary = turret_build_state.source_building_comp_sense_state({}, "powerNetIn", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["wiring_power_net_in_absent_fallback"] = not bool(power_net_in_absent.get("handled", true)) and power_net_in_absent.get("sense_value", 0.0) == null and bool(power_net_in_absent.get("sense_value_is_nan", false))

	# The has_power=false fold stays FIRST and unchanged:
	# powerNetIn with no power module reads 0.0 handled:true.
	var power_net_in_no_power: Dictionary = turret_build_state.source_building_comp_sense_state({}, "powerNetIn", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["wiring_power_net_in_no_power_num"] = bool(power_net_in_no_power.get("handled", false)) and is_equal_approx(float(power_net_in_no_power.get("sense_value", 1.0)), 0.0) and not bool(power_net_in_no_power.get("sense_value_is_nan", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildingCompSenseWiringProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
