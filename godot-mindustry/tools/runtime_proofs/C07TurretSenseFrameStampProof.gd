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

	# --- Turret sense frame stamp (N2520): the live tick stamps
	# the sense inputs it can supply into the frame, so the
	# N2519-wired dispatch `source_building_comp_sense_state`
	# stops reporting handled:false for them when a live turret
	# ticks (BuildingComp.sense() is `public double sense(LAccess
	# sensor){`, BuildingComp.java:2093-2126). The tick is
	# TurretBuild.updateTile() (`public void updateTile(){`,
	# Turret.java:490). The stamp writes exactly six keys:
	# `health` is the live health passed in (`case health ->
	# health;`, BuildingComp.java:2101); `is_dead` is `health
	# <= 0.0` (the kill trigger `if(health <= 0f && !dead()){`,
	# :2170, sets `dead = true;` in killed(), :2243 -- the
	# port-consistent reading, SourceBuildingDamageState.gd:40
	# `"was_dead": current_health <= 0.0`); `tile_build_is_self`
	# is the constant true (the tick only iterates live placed
	# buildings, so `tile.build == self()` holds -- the first
	# conjunct of `isValid()`, `return tile.build == self() &&
	# !dead();`, :2031); `is_control_block` is the constant true
	# (every turret build implements ControlBlock, `public class
	# TurretBuild extends ReloadTurretBuild implements
	# ControlBlock{`, Turret.java:277); `unit_sense_value` is
	# passed in (the tick passes 0.0 today -- the proxy unit has
	# no player controller attached, so every camera* leg reads
	# 0: `case cameraX, cameraY, cameraWidth, cameraHeight ->
	# this instanceof ControlBlock c ? c.unit().sense(sensor) :
	# 0;`, :2122, delegating to `case cameraX -> controller
	# instanceof Player player ? World.conv(player.con == null ?
	# Core.camera.position.x : player.con.viewX) : 0;`,
	# UnitComp.java:283-286). It does NOT touch the other six
	# wiring keys, so the dispatch keeps handled:false for
	# totalItems / powerNet* exactly as N2519 left them. The
	# proof calls the stamp directly with synthetic health,
	# then the dispatch, end to end. Duo catalog values unless
	# noted: solid true, size 1, maxHealth 250, range 160,
	# itemCapacity 10, hasLiquids false, no consumePower,
	# timeScale 1.0, not player-controlled, payloadCount 0.

	var sharded := Color.html("ffd37f")

	# Live duo at full health: the stamp writes health 250.0
	# and is_dead false, so the dead leg reads 0.0
	# (`!isValid() ? 1 : 0`, `isValid()` is `tile.build ==
	# self() && !dead()`, BuildingComp.java:2031) and the
	# health leg reads 250.0.
	var full_frame: Dictionary = turret_build_state.source_turret_sense_frame_stamp_state({}, 250.0, 0.0)
	var dead_full: Dictionary = turret_build_state.source_building_comp_sense_state(full_frame, "dead", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_full_health_dead_num"] = bool(dead_full.get("handled", false)) and is_equal_approx(float(dead_full.get("sense_value", 1.0)), 0.0) and not bool(dead_full.get("sense_value_is_nan", true))
	var health_full: Dictionary = turret_build_state.source_building_comp_sense_state(full_frame, "health", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_full_health_health_num"] = bool(health_full.get("handled", false)) and is_equal_approx(float(health_full.get("sense_value", 0.0)), 250.0) and not bool(health_full.get("sense_value_is_nan", true))

	# Damaged duo: health 120.0 still reads dead 0.0 and
	# health 120.0 (only health <= 0.0 is dead).
	var damaged_frame: Dictionary = turret_build_state.source_turret_sense_frame_stamp_state({}, 120.0, 0.0)
	var dead_damaged: Dictionary = turret_build_state.source_building_comp_sense_state(damaged_frame, "dead", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_damaged_dead_num"] = bool(dead_damaged.get("handled", false)) and is_equal_approx(float(dead_damaged.get("sense_value", 1.0)), 0.0) and not bool(dead_damaged.get("sense_value_is_nan", true))
	var health_damaged: Dictionary = turret_build_state.source_building_comp_sense_state(damaged_frame, "health", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_damaged_health_num"] = bool(health_damaged.get("handled", false)) and is_equal_approx(float(health_damaged.get("sense_value", 0.0)), 120.0) and not bool(health_damaged.get("sense_value_is_nan", true))

	# Killed duo: health 0.0 reads dead 1.0 and health 0.0
	# (the kill trigger `if(health <= 0f && !dead()){`,
	# BuildingComp.java:2170).
	var killed_frame: Dictionary = turret_build_state.source_turret_sense_frame_stamp_state({}, 0.0, 0.0)
	var dead_killed: Dictionary = turret_build_state.source_building_comp_sense_state(killed_frame, "dead", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_killed_dead_num"] = bool(dead_killed.get("handled", false)) and is_equal_approx(float(dead_killed.get("sense_value", 0.0)), 1.0) and not bool(dead_killed.get("sense_value_is_nan", true))
	var health_killed: Dictionary = turret_build_state.source_building_comp_sense_state(killed_frame, "health", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_killed_health_num"] = bool(health_killed.get("handled", false)) and is_equal_approx(float(health_killed.get("sense_value", 1.0)), 0.0) and not bool(health_killed.get("sense_value_is_nan", true))

	# CameraX on a control block with no player controller:
	# the tick passes unit_sense_value 0.0, so the leg reads
	# 0.0 handled:true (not the absent-key fallback).
	var camera_x: Dictionary = turret_build_state.source_building_comp_sense_state(full_frame, "cameraX", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_camera_x_no_controller_num"] = bool(camera_x.get("handled", false)) and is_equal_approx(float(camera_x.get("sense_value", 1.0)), 0.0) and not bool(camera_x.get("sense_value_is_nan", true))

	# TotalItems still handled:false: the stamp does not write
	# the items keys (inventory not tracked), so the N2519
	# absent-key fallback is preserved.
	var total_items: Dictionary = turret_build_state.source_building_comp_sense_state(full_frame, "totalItems", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_total_items_absent_fallback"] = not bool(total_items.get("handled", true)) and total_items.get("sense_value", 0.0) == null and bool(total_items.get("sense_value_is_nan", false))

	# PowerNetIn still handled:false with power present: the
	# stamp does not write the graph keys (graph last-values
	# not tracked), so the N2519 absent-key fallback is
	# preserved.
	var power_net_in: Dictionary = turret_build_state.source_building_comp_sense_state(full_frame, "powerNetIn", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["stamp_power_net_in_absent_fallback"] = not bool(power_net_in.get("handled", true)) and power_net_in.get("sense_value", 0.0) == null and bool(power_net_in.get("sense_value_is_nan", false))

	# The has_power=false fold stays FIRST and unchanged:
	# powerNetIn with no power module reads 0.0 handled:true.
	var power_net_in_no_power: Dictionary = turret_build_state.source_building_comp_sense_state(full_frame, "powerNetIn", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["stamp_power_net_in_no_power_num"] = bool(power_net_in_no_power.get("handled", false)) and is_equal_approx(float(power_net_in_no_power.get("sense_value", 1.0)), 0.0) and not bool(power_net_in_no_power.get("sense_value_is_nan", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretSenseFrameStampProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
