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

	# --- BuildingComp sense() LAccess dispatch (N2284):
	# `public double sense(LAccess sensor){ return
	# switch(sensor){ case x -> World.conv(x); case y ->
	# World.conv(y); case color ->
	# Color.toDoubleBits(team.color.r, team.color.g,
	# team.color.b, 1f); case dead -> !isValid() ? 1 : 0;
	# case solid -> block.solid || checkSolid() ? 1 : 0;
	# case team -> team.id; case health -> health; case
	# maxHealth -> maxHealth; case efficiency ->
	# efficiency; case timescale -> timeScale; case range
	# -> this instanceof Ranged r ? r.range() / tilesize
	# : 0; case rotation -> rotation; case totalItems ->
	# items == null ? 0 : items.total(); case
	# totalLiquids -> liquids == null ? 0 :
	# liquids.currentAmount(); case totalPower -> power
	# == null || block.consPower == null ? 0 :
	# power.status * (block.consPower.buffered ?
	# block.consPower.capacity : 1f); case itemCapacity
	# -> block.hasItems ? block.itemCapacity : 0; case
	# liquidCapacity -> block.hasLiquids ?
	# block.liquidCapacity : 0; case powerCapacity ->
	# block.consPower != null ? block.consPower.capacity
	# : 0f; case powerNetIn -> power == null ? 0 :
	# power.graph.getLastScaledPowerIn() * 60; case
	# powerNetOut -> power == null ? 0 :
	# power.graph.getLastScaledPowerOut() * 60; case
	# powerNetStored -> power == null ? 0 :
	# power.graph.getLastPowerStored(); case
	# powerNetCapacity -> power == null ? 0 :
	# power.graph.getLastCapacity(); case enabled ->
	# enabled ? 1 : 0; case controlled -> this instanceof
	# ControlBlock c && c.isControlled() ?
	# GlobalVars.ctrlPlayer : 0; case payloadCount ->
	# (getPayloads() != null ? getPayloads().total() : 0)
	# + (getPayload() != null ? 1 : 0); case size ->
	# block.size; case cameraX, cameraY, cameraWidth,
	# cameraHeight -> this instanceof ControlBlock c ?
	# c.unit().sense(sensor) : 0; default -> Float.NaN;
	# }; }`
	# (BuildingComp.java:2093-2126). 23 of the 30 sensors
	# are implemented here; dead / health / totalItems /
	# cameraX / cameraY / cameraWidth / cameraHeight stay
	# deferred and report handled=false + NaN, as do the
	# powerNet* legs when power is present (the graph is
	# not live in the frame). There is no driver tick line:
	# sense is a logic read, not a tick write (the
	# N2206/N2208/N2223/N2283 precedent); the proof calls
	# the pure function directly with synthetic frames.
	# Duo values unless noted: team sharded
	# (Pal.accent, `accent = Color.valueOf("ffd37f"),`),
	# solid true, size 1, maxHealth 250, range 160,
	# itemCapacity 10, hasLiquids false, no consumePower,
	# no power module, timeScale 1.0, not player-controlled,
	# payloadCount 0. The color ground truths are the arc
	# toDoubleBits doubles, verified bit-exact with Python
	# struct: sharded bits 0xFFD37FFF ->
	# 2.120554921e-314, derelict bits 0x4D4E58FF ->
	# 6.407933715e-315.

	var frame: Dictionary = {"team_id": 1, "efficiency": 0.75, "rotation": 135.0, "enabled": true, "power_status": 0.5}
	var sharded := Color.html("ffd37f")
	var derelict := Color.html("4d4e58")

	# X converted through World.conv (80 world px / 8 = 10 tiles).
	var x_result: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "x", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_x_converted"] = bool(x_result.get("handled", false)) and is_equal_approx(float(x_result.get("sense_value", 0.0)), 10.0) and not bool(x_result.get("sense_value_is_nan", true))

	# Y converted through World.conv (24 world px / 8 = 3 tiles).
	var y_result: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "y", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_y_converted"] = bool(y_result.get("handled", false)) and is_equal_approx(float(y_result.get("sense_value", 0.0)), 3.0) and not bool(y_result.get("sense_value_is_nan", true))

	# Color through arc toDoubleBits for sharded (bits 0xFFD37FFF).
	var color_sharded: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "color", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_color_sharded"] = bool(color_sharded.get("handled", false)) and is_equal_approx(float(color_sharded.get("sense_value", 0.0)), 2.120554921e-314) and not bool(color_sharded.get("sense_value_is_nan", true))

	# Color through arc toDoubleBits for derelict (bits 0x4D4E58FF).
	var color_derelict: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "color", 8.0, 80.0, 24.0, derelict.r, derelict.g, derelict.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_color_derelict"] = bool(color_derelict.get("handled", false)) and is_equal_approx(float(color_derelict.get("sense_value", 0.0)), 6.407933715e-315) and not bool(color_derelict.get("sense_value_is_nan", true))

	# Solid true for duo (1.0).
	var solid_true: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "solid", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_solid_true"] = bool(solid_true.get("handled", false)) and is_equal_approx(float(solid_true.get("sense_value", 0.0)), 1.0) and not bool(solid_true.get("sense_value_is_nan", true))

	# Solid false for a non-solid block (0.0).
	var solid_false: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "solid", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, false, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_solid_false"] = bool(solid_false.get("handled", false)) and is_equal_approx(float(solid_false.get("sense_value", 0.0)), 0.0) and not bool(solid_false.get("sense_value_is_nan", true))

	# Team read live from the frame (team_id 1 -> 1.0).
	var team_live: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "team", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_team_live"] = bool(team_live.get("handled", false)) and is_equal_approx(float(team_live.get("sense_value", 0.0)), 1.0) and not bool(team_live.get("sense_value_is_nan", true))

	# MaxHealth at the duo catalog value (250 -> 250.0).
	var max_health: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "maxHealth", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_max_health_duo"] = bool(max_health.get("handled", false)) and is_equal_approx(float(max_health.get("sense_value", 0.0)), 250.0) and not bool(max_health.get("sense_value_is_nan", true))

	# Efficiency read live from the frame (0.75 -> 0.75).
	var efficiency: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "efficiency", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_efficiency_live"] = bool(efficiency.get("handled", false)) and is_equal_approx(float(efficiency.get("sense_value", 0.0)), 0.75) and not bool(efficiency.get("sense_value_is_nan", true))

	# Timescale at the default (1.0 -> 1.0).
	var timescale: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "timescale", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_timescale_default"] = bool(timescale.get("handled", false)) and is_equal_approx(float(timescale.get("sense_value", 0.0)), 1.0) and not bool(timescale.get("sense_value_is_nan", true))

	# Range for duo (160 px / 8 = 20 tiles).
	var range_duo: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "range", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_range_duo"] = bool(range_duo.get("handled", false)) and is_equal_approx(float(range_duo.get("sense_value", 0.0)), 20.0) and not bool(range_duo.get("sense_value_is_nan", true))

	# Range with graphite ammo (160 + 16 = 176 px / 8 = 22 tiles).
	var range_graphite: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "range", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 176.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_range_graphite"] = bool(range_graphite.get("handled", false)) and is_equal_approx(float(range_graphite.get("sense_value", 0.0)), 22.0) and not bool(range_graphite.get("sense_value_is_nan", true))

	# Rotation read live from the frame (135.0 -> 135.0).
	var rotation: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "rotation", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_rotation_live"] = bool(rotation.get("handled", false)) and is_equal_approx(float(rotation.get("sense_value", 0.0)), 135.0) and not bool(rotation.get("sense_value_is_nan", true))

	# TotalLiquids for duo (hasLiquids false -> 0.0).
	var total_liquids_none: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "totalLiquids", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_total_liquids_none"] = bool(total_liquids_none.get("handled", false)) and is_equal_approx(float(total_liquids_none.get("sense_value", 0.0)), 0.0) and not bool(total_liquids_none.get("sense_value_is_nan", true))

	# TotalLiquids live for a liquid block (5.5 -> 5.5).
	var total_liquids_live: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "totalLiquids", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, true, 10.0, 5.5, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_total_liquids_live"] = bool(total_liquids_live.get("handled", false)) and is_equal_approx(float(total_liquids_live.get("sense_value", 0.0)), 5.5) and not bool(total_liquids_live.get("sense_value_is_nan", true))

	# TotalPower for duo (no consumePower -> 0.0).
	var total_power_none: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "totalPower", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_total_power_no_consumer"] = bool(total_power_none.get("handled", false)) and is_equal_approx(float(total_power_none.get("sense_value", 0.0)), 0.0) and not bool(total_power_none.get("sense_value_is_nan", true))

	# TotalPower buffered (power_status 0.5 * capacity 100 -> 50.0).
	var total_power_buffered: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "totalPower", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, true, 100.0, true, true, 1.0, false, 0)
	proof["sense_total_power_buffered"] = bool(total_power_buffered.get("handled", false)) and is_equal_approx(float(total_power_buffered.get("sense_value", 0.0)), 50.0) and not bool(total_power_buffered.get("sense_value_is_nan", true))

	# TotalPower unbuffered (power_status 0.5 * 1 -> 0.5).
	var total_power_unbuffered: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "totalPower", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, true, 100.0, false, true, 1.0, false, 0)
	proof["sense_total_power_unbuffered"] = bool(total_power_unbuffered.get("handled", false)) and is_equal_approx(float(total_power_unbuffered.get("sense_value", 0.0)), 0.5) and not bool(total_power_unbuffered.get("sense_value_is_nan", true))

	# ItemCapacity for duo (hasItems true, 10 -> 10.0).
	var item_capacity_duo: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "itemCapacity", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_item_capacity_duo"] = bool(item_capacity_duo.get("handled", false)) and is_equal_approx(float(item_capacity_duo.get("sense_value", 0.0)), 10.0) and not bool(item_capacity_duo.get("sense_value_is_nan", true))

	# ItemCapacity without items (hasItems false -> 0.0).
	var item_capacity_none: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "itemCapacity", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, false, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_item_capacity_no_items"] = bool(item_capacity_none.get("handled", false)) and is_equal_approx(float(item_capacity_none.get("sense_value", 0.0)), 0.0) and not bool(item_capacity_none.get("sense_value_is_nan", true))

	# LiquidCapacity for duo (hasLiquids false -> 0.0).
	var liquid_capacity_none: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "liquidCapacity", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_liquid_capacity_none"] = bool(liquid_capacity_none.get("handled", false)) and is_equal_approx(float(liquid_capacity_none.get("sense_value", 0.0)), 0.0) and not bool(liquid_capacity_none.get("sense_value_is_nan", true))

	# LiquidCapacity live for a liquid block (10.0 -> 10.0).
	var liquid_capacity_live: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "liquidCapacity", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, true, 10.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_liquid_capacity_live"] = bool(liquid_capacity_live.get("handled", false)) and is_equal_approx(float(liquid_capacity_live.get("sense_value", 0.0)), 10.0) and not bool(liquid_capacity_live.get("sense_value_is_nan", true))

	# PowerCapacity for duo (no consumePower -> 0.0).
	var power_capacity_none: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "powerCapacity", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_power_capacity_no_consumer"] = bool(power_capacity_none.get("handled", false)) and is_equal_approx(float(power_capacity_none.get("sense_value", 0.0)), 0.0) and not bool(power_capacity_none.get("sense_value_is_nan", true))

	# PowerCapacity live (has_cons_power true, 100 -> 100.0).
	var power_capacity_live: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "powerCapacity", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, true, 100.0, false, false, 1.0, false, 0)
	proof["sense_power_capacity_live"] = bool(power_capacity_live.get("handled", false)) and is_equal_approx(float(power_capacity_live.get("sense_value", 0.0)), 100.0) and not bool(power_capacity_live.get("sense_value_is_nan", true))

	# PowerNetIn with no power module (0.0).
	var power_net_in_none: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "powerNetIn", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_power_net_in_no_power"] = bool(power_net_in_none.get("handled", false)) and is_equal_approx(float(power_net_in_none.get("sense_value", 0.0)), 0.0) and not bool(power_net_in_none.get("sense_value_is_nan", true))

	# PowerNetOut with no power module (0.0).
	var power_net_out_none: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "powerNetOut", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_power_net_out_no_power"] = bool(power_net_out_none.get("handled", false)) and is_equal_approx(float(power_net_out_none.get("sense_value", 0.0)), 0.0) and not bool(power_net_out_none.get("sense_value_is_nan", true))

	# PowerNetStored with no power module (0.0).
	var power_net_stored_none: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "powerNetStored", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_power_net_stored_no_power"] = bool(power_net_stored_none.get("handled", false)) and is_equal_approx(float(power_net_stored_none.get("sense_value", 0.0)), 0.0) and not bool(power_net_stored_none.get("sense_value_is_nan", true))

	# PowerNetCapacity with no power module (0.0).
	var power_net_capacity_none: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "powerNetCapacity", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_power_net_capacity_no_power"] = bool(power_net_capacity_none.get("handled", false)) and is_equal_approx(float(power_net_capacity_none.get("sense_value", 0.0)), 0.0) and not bool(power_net_capacity_none.get("sense_value_is_nan", true))

	# PowerNetIn with power present is deferred (handled false, NaN).
	var power_net_in_deferred: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "powerNetIn", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, true, 1.0, false, 0)
	proof["sense_power_net_in_deferred"] = not bool(power_net_in_deferred.get("handled", true)) and power_net_in_deferred.get("sense_value", 0.0) == null and bool(power_net_in_deferred.get("sense_value_is_nan", false))

	# Enabled true (1.0).
	var enabled_true: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "enabled", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_enabled_true"] = bool(enabled_true.get("handled", false)) and is_equal_approx(float(enabled_true.get("sense_value", 0.0)), 1.0) and not bool(enabled_true.get("sense_value_is_nan", true))

	# Enabled false (0.0).
	var enabled_false: Dictionary = turret_build_state.source_building_comp_sense_state({"team_id": 1, "efficiency": 0.75, "rotation": 135.0, "enabled": false, "power_status": 0.5}, "enabled", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_enabled_false"] = bool(enabled_false.get("handled", false)) and is_equal_approx(float(enabled_false.get("sense_value", 0.0)), 0.0) and not bool(enabled_false.get("sense_value_is_nan", true))

	# Controlled while no player controls the block (0.0).
	var controlled_false: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "controlled", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_controlled_false"] = bool(controlled_false.get("handled", false)) and is_equal_approx(float(controlled_false.get("sense_value", 0.0)), 0.0) and not bool(controlled_false.get("sense_value_is_nan", true))

	# Controlled by a player (GlobalVars.ctrlPlayer = 2 -> 2.0).
	var controlled_player: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "controlled", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, true, 0)
	proof["sense_controlled_player"] = bool(controlled_player.get("handled", false)) and is_equal_approx(float(controlled_player.get("sense_value", 0.0)), 2.0) and not bool(controlled_player.get("sense_value_is_nan", true))

	# PayloadCount for duo (0 -> 0.0).
	var payload_none: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "payloadCount", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_payload_count_none"] = bool(payload_none.get("handled", false)) and is_equal_approx(float(payload_none.get("sense_value", 0.0)), 0.0) and not bool(payload_none.get("sense_value_is_nan", true))

	# Size for duo (1 -> 1.0).
	var size_duo: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "size", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_size_duo"] = bool(size_duo.get("handled", false)) and is_equal_approx(float(size_duo.get("sense_value", 0.0)), 1.0) and not bool(size_duo.get("sense_value_is_nan", true))

	# Deferred sensors report handled=false + NaN.
	var dead_result: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "dead", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_unhandled_dead"] = not bool(dead_result.get("handled", true)) and dead_result.get("sense_value", 0.0) == null and bool(dead_result.get("sense_value_is_nan", false))
	var health_result: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "health", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_unhandled_health"] = not bool(health_result.get("handled", true)) and health_result.get("sense_value", 0.0) == null and bool(health_result.get("sense_value_is_nan", false))
	var total_items_result: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "totalItems", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_unhandled_total_items"] = not bool(total_items_result.get("handled", true)) and total_items_result.get("sense_value", 0.0) == null and bool(total_items_result.get("sense_value_is_nan", false))
	var camera_x_result: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "cameraX", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_unhandled_camera_x"] = not bool(camera_x_result.get("handled", true)) and camera_x_result.get("sense_value", 0.0) == null and bool(camera_x_result.get("sense_value_is_nan", false))

	# An unknown sensor falls through to the default (handled false, NaN).
	var unknown_result: Dictionary = turret_build_state.source_building_comp_sense_state(frame, "heat", 8.0, 80.0, 24.0, sharded.r, sharded.g, sharded.b, true, 1, 250.0, 160.0, true, 10, false, -1.0, 0.0, false, 0.0, false, false, 1.0, false, 0)
	proof["sense_unknown_sensor"] = not bool(unknown_result.get("handled", true)) and unknown_result.get("sense_value", 0.0) == null and bool(unknown_result.get("sense_value_is_nan", false))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildingCompSenseProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
