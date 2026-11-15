extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_mass_driver_build_state := preload("res://src/game/SourcePayloadMassDriverBuildState.gd")
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

	# --- Pure advance part 1 (N2245): PayloadDriverBuild.updateTile()
	# (PayloadMassDriver.java:155-234): super.updateTile() (:156,
	# noted), the link lookup + linkValid (:157-158, :466-468),
	# the charge discharge when not charging (:161-164), the
	# curSize lerp + targetSize (:166-171), the effectDelayTimer
	# countdown + reloadCounter = 1f reset (:173-183, STATE
	# only), the charging reset (:184), the link pos refresh
	# (:186-188), the reloadCounter decay regardless of state
	# (:191-192), the currentShooter cleanup (:194-205), the
	# idle -> accepting / shooting switch (:208-215), the dump
	# when idle or accepting (:218-229), and the no-power return
	# (:232-234) that gates the N2246 branches. source_delta is
	# Time.delta in ticks (1.0 = one tick); reload is the def
	# constant 130f (Blocks.java:6621/6633, beating the class
	# 30f), grabWidth 8f, payloadSpeed 0.7f, payloadRotateSpeed
	# 5f, size 3, tilesize 8, rotdeg 0 (facing east, so the
	# moveOut dest is trns(0, 12) = (12, 0)). Positions are
	# Point2-packed (arc Point2.java:40-42): this tile (3, 5),
	# the partner (3, 10), a shooter (3, 0), another driver
	# (5, 5). The payload fixture is a Dictionary carrying
	# "size" in world units (BuildPayload.size() is
	# build.block.size * tilesize, BuildPayload.java:86-88):
	# {"size": 24.0} is a size-3 block.
	var this_pos: int = (3 << 16) | 5
	var partner_pos: int = (3 << 16) | 10
	var shooter_pos: int = (3 << 16) | 0
	var other_pos: int = (5 << 16) | 5
	var unlinked: Dictionary = {"exists": false, "pos": -1, "is_payload_mass_driver": false, "same_block": false, "same_team": false, "within_range": false}

	# charge -= Time.delta * 10f (PayloadMassDriver.java:162),
	# "discharge when charging isn't happening": at charge 50
	# one tick discharges to 40; a near-empty charge clamps at
	# 0 (5 - 10 would go negative); while charging is true the
	# charge holds (50 stays 50 -- the flag is read BEFORE the
	# :184 reset) and charging comes out false either way.
	var discharge_frame: Dictionary = {"efficiency": 1.0, "link": -1, "charge": 50.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [], "state": "idle", "pay_length": 0.0, "pay_rotation": 0.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": null}
	var discharged: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(discharge_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {})
	var clamp_frame: Dictionary = {"efficiency": 1.0, "link": -1, "charge": 5.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [], "state": "idle", "pay_length": 0.0, "pay_rotation": 0.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": null}
	var clamped: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(clamp_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {})
	var charging_frame: Dictionary = {"efficiency": 1.0, "link": -1, "charge": 50.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": true, "reload_counter": 0.0, "waiting_shooters": [], "state": "idle", "pay_length": 0.0, "pay_rotation": 0.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": null}
	var held: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(charging_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {})
	proof["charge_discharges_when_idle"] = is_equal_approx(float(discharged.get("charge", -1.0)), 40.0) and bool(discharged.get("charging", true)) == false and is_equal_approx(float(clamped.get("charge", -1.0)), 0.0) and is_equal_approx(float(held.get("charge", -1.0)), 50.0) and bool(held.get("charging", true)) == false

	# reloadCounter -= edelta() / reload (PayloadMassDriver.
	# java:191), "reload regardless of state": at efficiency
	# 0.5 one tick drains 0.5 / 130 (1.0 -> 0.9961538); a
	# near-empty counter clamps at 0 (0.001 - 1/130 would go
	# negative); at efficiency 0 edelta is 0 and the counter
	# holds; a shooting driver still decays (and part 1 leaves
	# its state alone -- the branches are N2246). The effect
	# timer crossing (:173-179) resets the counter to 1f first
	# (timer 0.5 -> -0.5 with a lastOther: 1.0 - 1/130 =
	# 0.9923077 after the same tick's decay), but only with a
	# lastOther (without one: 0.3 - 1/130 = 0.2923077).
	var decay_frame: Dictionary = {"efficiency": 0.5, "link": -1, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 1.0, "waiting_shooters": [], "state": "idle", "pay_length": 0.0, "pay_rotation": 0.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": null}
	var decayed: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(decay_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {})
	var reload_clamp_frame: Dictionary = {"efficiency": 1.0, "link": -1, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 0.001, "waiting_shooters": [], "state": "idle", "pay_length": 0.0, "pay_rotation": 0.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": null}
	var reload_clamped: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(reload_clamp_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {})
	var zero_frame: Dictionary = {"efficiency": 0.0, "link": -1, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 1.0, "waiting_shooters": [], "state": "idle", "pay_length": 0.0, "pay_rotation": 0.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": null}
	var zeroed: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(zero_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {})
	var shooting_frame: Dictionary = {"efficiency": 0.5, "link": -1, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 1.0, "waiting_shooters": [], "state": "shooting", "pay_length": 0.0, "pay_rotation": 0.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": null}
	var shooting_decayed: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(shooting_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {})
	var crossing_frame: Dictionary = {"efficiency": 1.0, "link": -1, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": 0.5, "charging": false, "reload_counter": 0.3, "waiting_shooters": [], "state": "idle", "pay_length": 0.0, "pay_rotation": 0.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": shooter_pos, "turret_rotation": 90.0, "payload": null}
	var crossed: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(crossing_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {})
	var no_other_frame: Dictionary = {"efficiency": 1.0, "link": -1, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": 0.5, "charging": false, "reload_counter": 0.3, "waiting_shooters": [], "state": "idle", "pay_length": 0.0, "pay_rotation": 0.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": null}
	var no_other: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(no_other_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {})
	proof["reload_counter_decays"] = is_equal_approx(float(decayed.get("reload_counter", -1.0)), 0.9961538) and str(decayed.get("state", "")) == "idle" and is_equal_approx(float(reload_clamped.get("reload_counter", -1.0)), 0.0) and is_equal_approx(float(zeroed.get("reload_counter", -1.0)), 1.0) and is_equal_approx(float(shooting_decayed.get("reload_counter", -1.0)), 0.9961538) and str(shooting_decayed.get("state", "")) == "shooting" and is_equal_approx(float(crossed.get("reload_counter", -1.0)), 0.9923077) and is_equal_approx(float(crossed.get("effect_delay_timer", -1.0)), -0.5) and is_equal_approx(float(no_other.get("reload_counter", -1.0)), 0.2923077)

	# Idle accepts a waiting shooter (PayloadMassDriver.java:
	# 210-211): waiting non-empty with no payload switches to
	# accepting and the waiter stays queued. An invalid shooter
	# (efficiency 0) is cleaned first (PayloadMassDriver.java:
	# 197-204) and idle holds with an empty list. A driver
	# holding a payload stays idle with the shooter still
	# waiting -- and its targetSize follows payload.size()
	# (24.0 for the size-3 fixture) while curSize still lerps
	# toward the pre-reset 16.0 (PayloadMassDriver.java:166-170).
	var shooter_record: Dictionary = {"is_payload_mass_driver": true, "is_valid": true, "efficiency": 1.0, "same_block": true, "link_equals_self": true, "within_range": true}
	var accept_frame: Dictionary = {"efficiency": 1.0, "link": -1, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [shooter_pos], "state": "idle", "pay_length": 0.0, "pay_rotation": 0.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": null}
	var accepted: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(accept_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {shooter_pos: shooter_record})
	var dead_record: Dictionary = {"is_payload_mass_driver": true, "is_valid": true, "efficiency": 0.0, "same_block": true, "link_equals_self": true, "within_range": true}
	var invalid_frame: Dictionary = {"efficiency": 1.0, "link": -1, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [shooter_pos], "state": "idle", "pay_length": 0.0, "pay_rotation": 0.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": null}
	var invalidated: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(invalid_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {shooter_pos: dead_record})
	var held_payload_frame: Dictionary = {"efficiency": 1.0, "link": -1, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [shooter_pos], "state": "idle", "pay_length": 0.0, "pay_rotation": 0.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": {"size": 24.0}}
	var held_payload: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(held_payload_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {shooter_pos: shooter_record})
	proof["state_switches_to_accepting"] = str(accepted.get("state", "")) == "accepting" and (accepted.get("waiting_shooters", []) as Array) == [shooter_pos] and str(invalidated.get("state", "")) == "idle" and (invalidated.get("waiting_shooters", []) as Array) == [] and str(held_payload.get("state", "")) == "idle" and (held_payload.get("waiting_shooters", []) as Array) == [shooter_pos] and is_equal_approx(float(held_payload.get("target_size", -1.0)), 24.0) and is_equal_approx(float(held_payload.get("cur_size", -1.0)), 16.0)

	# Idle shoots with a valid link (PayloadMassDriver.java:
	# 212-213): the link pos refreshes to the partner pos and
	# the state switches to shooting. Unlinked, idle holds.
	# A partner of the OTHER def (same_block false -- the two
	# defs are different blocks, linkValid :466-468) is not a
	# valid link: idle holds and the stale link is NOT
	# refreshed.
	var linked_valid: Dictionary = {"exists": true, "pos": partner_pos, "is_payload_mass_driver": true, "same_block": true, "same_team": true, "within_range": true}
	var shoot_frame: Dictionary = {"efficiency": 1.0, "link": other_pos, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [], "state": "idle", "pay_length": 0.0, "pay_rotation": 0.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": null}
	var shooting: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(shoot_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, linked_valid, {})
	var linked_other_def: Dictionary = {"exists": true, "pos": partner_pos, "is_payload_mass_driver": true, "same_block": false, "same_team": true, "within_range": true}
	var other_def: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(shoot_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, linked_other_def, {})
	var no_link_frame: Dictionary = {"efficiency": 1.0, "link": -1, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [], "state": "idle", "pay_length": 0.0, "pay_rotation": 0.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": null}
	var no_link: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(no_link_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {})
	proof["state_switches_to_shooting"] = str(shooting.get("state", "")) == "shooting" and int(shooting.get("link", -99)) == partner_pos and str(other_def.get("state", "")) == "idle" and int(other_def.get("link", -99)) == other_pos and str(no_link.get("state", "")) == "idle" and int(no_link.get("link", -99)) == -1

	# Dump when idle (PayloadMassDriver.java:218-229): a loaded
	# payload unloads payLength 0.5 -> 0.5 - 0.7 = -0.2 (NOT
	# clamped at 0 -- Java only flips loaded), loaded goes
	# false, payVector zeroes, and payRotation moves toward
	# turretRotation + 180 (260 -> 265 toward 270). Unloaded
	# with the timer expired, moveOutPayload runs in pure
	# form (PayloadBlock.java:204-207): payVector approaches
	# the dest (12, 0) by 0.7 -> (0.7, 0) and payRotation moves
	# toward rotdeg (90 -> 85 toward 0). While the timer is
	# still running (5.0 -> 4.0) no moveOut happens.
	var unload_frame: Dictionary = {"efficiency": 1.0, "link": -1, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [], "state": "idle", "pay_length": 0.5, "pay_rotation": 260.0, "pay_vector": {"x": 3.0, "y": 4.0}, "loaded": true, "last_other": -1, "turret_rotation": 90.0, "payload": {"size": 24.0}}
	var unloaded: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(unload_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {})
	var unloaded_vector: Dictionary = unloaded.get("pay_vector", {})
	var move_out_frame: Dictionary = {"efficiency": 1.0, "link": -1, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [], "state": "idle", "pay_length": 0.0, "pay_rotation": 90.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": {"size": 24.0}}
	var moved_out: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(move_out_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {})
	var moved_vector: Dictionary = moved_out.get("pay_vector", {})
	var timer_frame: Dictionary = {"efficiency": 1.0, "link": -1, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": 5.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [], "state": "idle", "pay_length": 0.0, "pay_rotation": 90.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": {"size": 24.0}}
	var timer_held: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(timer_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {})
	var timer_vector: Dictionary = timer_held.get("pay_vector", {})
	proof["dump_unloads_when_idle"] = bool(unloaded.get("loaded", true)) == false and is_equal_approx(float(unloaded.get("pay_length", -99.0)), -0.2) and is_equal_approx(float(unloaded_vector.get("x", -1.0)), 0.0) and is_equal_approx(float(unloaded_vector.get("y", -1.0)), 0.0) and is_equal_approx(float(unloaded.get("pay_rotation", -1.0)), 265.0) and is_equal_approx(float(moved_vector.get("x", -1.0)), 0.7) and is_equal_approx(float(moved_vector.get("y", -1.0)), 0.0) and is_equal_approx(float(moved_out.get("pay_rotation", -1.0)), 85.0) and is_equal_approx(float(timer_held.get("effect_delay_timer", -1.0)), 4.0) and is_equal_approx(float(timer_vector.get("x", -1.0)), 0.0) and is_equal_approx(float(timer_held.get("pay_rotation", -1.0)), 90.0)

	# --- No power (PayloadMassDriver.java:232-234): the return
	# gates the accepting/shooting branches BELOW it (N2246),
	# but part 1 already ran -- at efficiency 0 the charge
	# still discharges (raw Time.delta), the state still
	# switches to accepting, and only the edelta reload decay
	# stalls (the counter holds at 1.0).
	var no_power_frame: Dictionary = {"efficiency": 0.0, "link": -1, "charge": 50.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 1.0, "waiting_shooters": [shooter_pos], "state": "idle", "pay_length": 0.0, "pay_rotation": 0.0, "pay_vector": {"x": 0.0, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": null}
	var no_power: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(no_power_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {shooter_pos: shooter_record})
	var no_power_pure_ok: bool = is_equal_approx(float(no_power.get("charge", -1.0)), 40.0) and str(no_power.get("state", "")) == "accepting" and is_equal_approx(float(no_power.get("reload_counter", -1.0)), 1.0)

	# --- Live tick: the payload-mass-driver is a
	# PayloadMassDriver build with a power consumer
	# (consumePower 0.5f), placed live; the tick driver is
	# called directly (as the N2147/N2148/N2149/N2150/N2153/
	# N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/N2162/
	# N2163/N2164 proofs do), not simulate_factory, so the
	# graph update does not overwrite the stamped power_status
	# -- the write-back itself is already proven by N2142.
	# Half power: efficiency folds the power min 0.5, so one
	# tick (source_delta 1.0) drains the reload counter 1.0 ->
	# 1.0 - 0.5/130 = 0.9961538 and discharges the charge
	# 50 -> 40, and the frame carries the advance keys (link
	# -1, state idle, empty waiting_shooters, charging false,
	# loaded false, payVector (0, 0), turretRotation 90,
	# payload null). No power: efficiency 0, the counter
	# holds at 0.9961538 while the charge keeps discharging
	# to 30 -- part 1 runs, the branches below the :232
	# return do not.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var payload_mass_driver_cell := Vector2i(28, 22)
	var payload_mass_driver := Sprite2D.new()
	game.add_child(payload_mass_driver)
	game.call("record_placed_block", payload_mass_driver, blocks_by_id["payload-mass-driver"], payload_mass_driver_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	payload_mass_driver_build_state.source_payload_mass_driver_bind_frame_state(payload_mass_driver, blocks_by_id["payload-mass-driver"])
	var payload_mass_driver_frame: Dictionary = payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	payload_mass_driver_frame["power_status"] = 0.5
	payload_mass_driver_frame["reload_counter"] = 1.0
	payload_mass_driver_frame["charge"] = 50.0
	payload_mass_driver_build_state.source_payload_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	payload_mass_driver_frame = payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	var live_vector: Dictionary = payload_mass_driver_frame.get("pay_vector", {})
	var half_tick_ok: bool = is_equal_approx(float(payload_mass_driver_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(payload_mass_driver_frame.get("reload_counter", -1.0)), 0.9961538) and is_equal_approx(float(payload_mass_driver_frame.get("charge", -1.0)), 40.0) and int(payload_mass_driver_frame.get("link", 0)) == -1 and str(payload_mass_driver_frame.get("state", "")) == "idle" and (payload_mass_driver_frame.get("waiting_shooters", [-1]) as Array) == [] and bool(payload_mass_driver_frame.get("charging", true)) == false and bool(payload_mass_driver_frame.get("loaded", true)) == false and is_equal_approx(float(live_vector.get("x", -1.0)), 0.0) and is_equal_approx(float(live_vector.get("y", -1.0)), 0.0) and is_equal_approx(float(payload_mass_driver_frame.get("turret_rotation", -1.0)), 90.0) and payload_mass_driver_frame.get("payload", {"x": 1}) == null
	payload_mass_driver_frame["power_status"] = 0.0
	payload_mass_driver_build_state.source_payload_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	payload_mass_driver_frame = payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	proof["no_power_skips_branches"] = no_power_pure_ok and half_tick_ok and is_equal_approx(float(payload_mass_driver_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(payload_mass_driver_frame.get("reload_counter", -1.0)), 0.9961538) and is_equal_approx(float(payload_mass_driver_frame.get("charge", -1.0)), 30.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadMassDriverUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
