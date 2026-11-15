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

	# --- Pure branches (N2246): PayloadDriverBuild.updateTile()
	# (PayloadMassDriver.java:232-342): the no-power return
	# (:232-234), the accepting bail + targetSize + align
	# (:236-248), the shooting bail + payRotation + loadLength
	# advance + moveInPayload intake (:249-270), the fire gate
	# -- enqueue, reload, first-in-queue, partner accepting,
	# both angles within 1f (:272-294) -- and the charge +
	# transfer (:295-342, the payload leaves the self frame the
	# moment it fires). source_delta is Time.delta in ticks (1.0
	# = one tick); chargeTime is the payload-mass-driver def
	# constant 90f (Blocks.java:6622), length 89/8f = 11.125,
	# knockback 5f, rotateSpeed 5f, payloadSpeed 0.7f,
	# payloadRotateSpeed 5f, rot_deg 0.0. Positions are
	# Point2-packed (arc Point2.java:40-42): this tile (3, 5),
	# the partner (3, 10), a shooter (3, 0), another driver
	# (5, 5). World coords are explicit in the pure calls: self
	# (0, 0), the partner (80, 0) due east (angleTo 0), the
	# shooter (80, 0) too. Payloads are minimal dicts carrying
	# "size" (BuildPayload.size() is `return build.block.size *
	# tilesize;`, BuildPayload.java:86-88).
	var this_pos: int = (3 << 16) | 5
	var partner_pos: int = (3 << 16) | 10
	var shooter_pos: int = (3 << 16) | 0
	var other_pos: int = (5 << 16) | 5
	var unlinked: Dictionary = {"exists": false, "pos": -1, "is_payload_mass_driver": false, "same_block": false, "same_team": false, "within_range": false, "payload": null, "state": "idle", "turret_rotation": 90.0, "reload_counter": 0.0, "effect_delay_timer": -1.0, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "last_other": null, "waiting_shooters": [], "x": 0.0, "y": 0.0}
	var linked_idle: Dictionary = {"exists": true, "pos": partner_pos, "is_payload_mass_driver": true, "same_block": true, "same_team": true, "within_range": true, "payload": null, "state": "idle", "turret_rotation": 180.0, "reload_counter": 0.0, "effect_delay_timer": -1.0, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "last_other": null, "waiting_shooters": [], "x": 80.0, "y": 0.0}
	var linked_accepting: Dictionary = {"exists": true, "pos": partner_pos, "is_payload_mass_driver": true, "same_block": true, "same_team": true, "within_range": true, "payload": null, "state": "accepting", "turret_rotation": 180.0, "reload_counter": 0.0, "effect_delay_timer": -1.0, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "last_other": null, "waiting_shooters": [this_pos], "x": 80.0, "y": 0.0}

	# Accepting bails (PayloadMassDriver.java:238-240):
	# `if(currentShooter() == null || payload != null){` /
	# `state = idle;` -- no shooter waiting bails, and a held
	# payload bails even with a shooter waiting. Without power
	# the branches never run (the no-power return, :232-234),
	# so an accepting driver at efficiency 0 stays accepting.
	var no_shooter_frame: Dictionary = {"efficiency": 1.0, "link": -1, "state": "accepting", "payload": null, "rec_payload": null, "target_size": 16.0, "turret_rotation": 90.0, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "pay_vector": Vector2.ZERO, "charge": 0.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": []}
	var no_shooter: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(no_shooter_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, unlinked, {})
	var held_frame: Dictionary = {"efficiency": 1.0, "link": -1, "state": "accepting", "payload": {"size": 16.0}, "rec_payload": null, "target_size": 16.0, "turret_rotation": 90.0, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "pay_vector": Vector2.ZERO, "charge": 0.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [shooter_pos]}
	var held: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(held_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, unlinked, {shooter_pos: {"x": 80.0, "y": 0.0, "payload": {"size": 24.0}}})
	var no_power_frame: Dictionary = {"efficiency": 0.0, "link": -1, "state": "accepting", "payload": null, "rec_payload": null, "target_size": 16.0, "turret_rotation": 90.0, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "pay_vector": Vector2.ZERO, "charge": 0.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": []}
	var no_power: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(no_power_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, unlinked, {})
	proof["accepting_bails_without_shooter"] = str(no_shooter.get("state", "")) == "idle" and str(held.get("state", "")) == "idle" and str(no_power.get("state", "")) == "accepting"

	# Accepting aligns (PayloadMassDriver.java:243-248):
	# targetSize takes the shooter payload size (24), or the
	# recPayload size (32) when recPayload is present; with no
	# shooter payload the targetSize holds at 16. The turret
	# aligns toward the shooter (angleTo (80, 0) is 0, so
	# rotation 90 moves 5 toward it, 90 -> 85) in all three
	# cases, and the state stays accepting.
	var shooter_record: Dictionary = {"x": 80.0, "y": 0.0, "payload": {"size": 24.0}}
	var align_frame: Dictionary = {"efficiency": 1.0, "link": -1, "state": "accepting", "payload": null, "rec_payload": null, "target_size": 16.0, "turret_rotation": 90.0, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "pay_vector": Vector2.ZERO, "charge": 0.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [shooter_pos]}
	var aligned: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(align_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, unlinked, {shooter_pos: shooter_record})
	var rec_frame: Dictionary = {"efficiency": 1.0, "link": -1, "state": "accepting", "payload": null, "rec_payload": {"size": 32.0}, "target_size": 16.0, "turret_rotation": 90.0, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "pay_vector": Vector2.ZERO, "charge": 0.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [shooter_pos]}
	var rec_aligned: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(rec_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, unlinked, {shooter_pos: shooter_record})
	var empty_shooter_record: Dictionary = {"x": 80.0, "y": 0.0, "payload": null}
	var empty_frame: Dictionary = {"efficiency": 1.0, "link": -1, "state": "accepting", "payload": null, "rec_payload": null, "target_size": 16.0, "turret_rotation": 90.0, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "pay_vector": Vector2.ZERO, "charge": 0.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [shooter_pos]}
	var empty_aligned: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(empty_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, unlinked, {shooter_pos: empty_shooter_record})
	proof["accepting_aligns_to_shooter"] = str(aligned.get("state", "")) == "accepting" and is_equal_approx(float(aligned.get("turret_rotation", -1.0)), 85.0) and is_equal_approx(float(aligned.get("target_size", -1.0)), 24.0) and is_equal_approx(float(rec_aligned.get("target_size", -1.0)), 32.0) and is_equal_approx(float(rec_aligned.get("turret_rotation", -1.0)), 85.0) and is_equal_approx(float(empty_aligned.get("target_size", -1.0)), 16.0) and is_equal_approx(float(empty_aligned.get("turret_rotation", -1.0)), 85.0)

	# Shooting bails (PayloadMassDriver.java:251-253):
	# `if(!hasLink || (!waitingShooters.isEmpty() && payload == null)){` /
	# `state = idle;` -- no link bails, and a waiting shooter
	# with no payload held bails. A linked shooting driver with
	# no waiting shooter and no payload stays shooting (the
	# payload arrives later through moveInPayload). The live
	# tick proves the same bail on a placed driver: a shooting
	# payload-mass-driver with no link bails to idle in one
	# tick at half power.
	var no_link_frame: Dictionary = {"efficiency": 1.0, "link": -1, "state": "shooting", "payload": {"size": 16.0}, "rec_payload": null, "target_size": 16.0, "turret_rotation": 0.0, "pay_rotation": 0.0, "pay_length": 11.125, "loaded": true, "pay_vector": Vector2.ZERO, "charge": 0.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": []}
	var no_link: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(no_link_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, unlinked, {})
	var waiter_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "state": "shooting", "payload": null, "rec_payload": null, "target_size": 16.0, "turret_rotation": 0.0, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "pay_vector": Vector2.ZERO, "charge": 0.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [shooter_pos]}
	var waiter: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(waiter_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_idle, {shooter_pos: shooter_record})
	var hold_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "state": "shooting", "payload": null, "rec_payload": null, "target_size": 16.0, "turret_rotation": 0.0, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "pay_vector": Vector2.ZERO, "charge": 0.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": []}
	var hold: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(hold_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_idle, {})
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var payload_mass_driver_cell := Vector2i(28, 21)
	var payload_mass_driver := Sprite2D.new()
	game.add_child(payload_mass_driver)
	game.call("record_placed_block", payload_mass_driver, blocks_by_id["payload-mass-driver"], payload_mass_driver_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	payload_mass_driver_build_state.source_payload_mass_driver_bind_frame_state(payload_mass_driver, blocks_by_id["payload-mass-driver"])
	var payload_mass_driver_frame: Dictionary = payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	payload_mass_driver_frame["power_status"] = 0.5
	payload_mass_driver_frame["state"] = "shooting"
	payload_mass_driver_build_state.source_payload_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	payload_mass_driver_frame = payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	var live_bails: bool = is_equal_approx(float(payload_mass_driver_frame.get("efficiency", -1.0)), 0.5) and str(payload_mass_driver_frame.get("state", "")) == "idle"
	proof["shooting_bails_without_link"] = str(no_link.get("state", "")) == "idle" and str(waiter.get("state", "")) == "idle" and str(hold.get("state", "")) == "shooting" and live_bails

	# Load advance (PayloadMassDriver.java:259-270): a loaded
	# payload advances payLength by payloadSpeed * delta (0.7)
	# toward loadLength = length - reloadCounter * knockback
	# (11.125 at reload 0); at the muzzle payLength clamps to
	# loadLength and the driver enqueues on the link (the
	# partner is idle, so no charge yet). At reloadCounter 1
	# the loadLength shrinks to 6.125 and the turret does not
	# align (the reload gate, :280). Unloaded, moveInPayload()
	# approaches payVector toward ZERO by 0.7 ((1, 0) -> (0.3,
	# 0), not arrived) and rotates payRotation toward rotdeg
	# (90 -> 85); a nearly-centred payVector snaps to ZERO and
	# arrives, so loaded turns true with payLength 0.
	var advance_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "state": "shooting", "payload": {"size": 16.0}, "rec_payload": null, "target_size": 16.0, "turret_rotation": 0.0, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": true, "pay_vector": Vector2.ZERO, "charge": 0.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": []}
	var advanced: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(advance_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_idle, {})
	var muzzle_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "state": "shooting", "payload": {"size": 16.0}, "rec_payload": null, "target_size": 16.0, "turret_rotation": 0.0, "pay_rotation": 0.0, "pay_length": 11.0, "loaded": true, "pay_vector": Vector2.ZERO, "charge": 0.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": []}
	var muzzled: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(muzzle_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_idle, {})
	var reloaded_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "state": "shooting", "payload": {"size": 16.0}, "rec_payload": null, "target_size": 16.0, "turret_rotation": 90.0, "pay_rotation": 90.0, "pay_length": 6.0, "loaded": true, "pay_vector": Vector2.ZERO, "charge": 0.0, "charging": false, "reload_counter": 1.0, "waiting_shooters": []}
	var reloaded: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(reloaded_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_idle, {})
	var move_in_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "state": "shooting", "payload": {"size": 16.0}, "rec_payload": null, "target_size": 16.0, "turret_rotation": 90.0, "pay_rotation": 90.0, "pay_length": 0.0, "loaded": false, "pay_vector": Vector2(1.0, 0.0), "charge": 0.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": []}
	var moved_in: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(move_in_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_idle, {})
	var moved_in_vector: Vector2 = moved_in.get("pay_vector", Vector2(-1.0, -1.0))
	var arrive_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "state": "shooting", "payload": {"size": 16.0}, "rec_payload": null, "target_size": 16.0, "turret_rotation": 0.0, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "pay_vector": Vector2(0.05, 0.0), "charge": 0.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": []}
	var arrived: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(arrive_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_idle, {})
	var arrived_vector: Vector2 = arrived.get("pay_vector", Vector2(-1.0, -1.0))
	proof["load_advances_to_length"] = is_equal_approx(float(advanced.get("pay_length", -1.0)), 0.7) and str(advanced.get("state", "")) == "shooting" and (advanced.get("partner_waiting_shooters", [-1]) as Array) == [] and is_equal_approx(float(muzzled.get("pay_length", -1.0)), 11.125) and (muzzled.get("partner_waiting_shooters", []) as Array) == [this_pos] and is_equal_approx(float(muzzled.get("charge", -1.0)), 0.0) and bool(muzzled.get("fired", true)) == false and is_equal_approx(float(reloaded.get("pay_length", -1.0)), 6.125) and is_equal_approx(float(reloaded.get("turret_rotation", -1.0)), 90.0) and is_equal_approx(float(reloaded.get("charge", -1.0)), 0.0) and is_equal_approx(moved_in_vector.x, 0.3) and is_equal_approx(moved_in_vector.y, 0.0) and is_equal_approx(float(moved_in.get("pay_rotation", -1.0)), 85.0) and bool(moved_in.get("loaded", true)) == false and arrived_vector == Vector2.ZERO and bool(arrived.get("loaded", false)) == true and is_equal_approx(float(arrived.get("pay_length", -1.0)), 0.0)

	# Fire gate (PayloadMassDriver.java:272-294): a driver
	# that is not first in the partner queue registers behind
	# the other driver and holds fire; a partner that is not
	# accepting holds fire (no duplicate registration); a
	# misaligned self rotation (90, moving to 85, still far
	# from target 0) holds fire; a misaligned partner rotation
	# (90 vs target+180 = 180) holds fire. All aligned, first
	# in queue, partner accepting, both reloads 0 -- the gate
	# passes, charge grows by edelta (1.0) and charging turns
	# true, but nothing transfers yet (1 < 90). A reloading
	# driver still enqueues (movedOut precedes the reload gate)
	# but does not align and does not charge.
	var fire_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "state": "shooting", "payload": {"size": 16.0}, "rec_payload": null, "target_size": 16.0, "turret_rotation": 0.0, "pay_rotation": 0.0, "pay_length": 11.125, "loaded": true, "pay_vector": Vector2.ZERO, "charge": 0.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": []}
	var linked_queued: Dictionary = {"exists": true, "pos": partner_pos, "is_payload_mass_driver": true, "same_block": true, "same_team": true, "within_range": true, "payload": null, "state": "accepting", "turret_rotation": 180.0, "reload_counter": 0.0, "effect_delay_timer": -1.0, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "last_other": null, "waiting_shooters": [other_pos], "x": 80.0, "y": 0.0}
	var queued: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(fire_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_queued, {})
	var linked_registered_idle: Dictionary = {"exists": true, "pos": partner_pos, "is_payload_mass_driver": true, "same_block": true, "same_team": true, "within_range": true, "payload": null, "state": "idle", "turret_rotation": 180.0, "reload_counter": 0.0, "effect_delay_timer": -1.0, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "last_other": null, "waiting_shooters": [this_pos], "x": 80.0, "y": 0.0}
	var not_accepting: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(fire_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_registered_idle, {})
	var misaligned_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "state": "shooting", "payload": {"size": 16.0}, "rec_payload": null, "target_size": 16.0, "turret_rotation": 90.0, "pay_rotation": 90.0, "pay_length": 11.125, "loaded": true, "pay_vector": Vector2.ZERO, "charge": 0.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": []}
	var misaligned: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(misaligned_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_accepting, {})
	var linked_misaligned: Dictionary = {"exists": true, "pos": partner_pos, "is_payload_mass_driver": true, "same_block": true, "same_team": true, "within_range": true, "payload": null, "state": "accepting", "turret_rotation": 90.0, "reload_counter": 0.0, "effect_delay_timer": -1.0, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "last_other": null, "waiting_shooters": [this_pos], "x": 80.0, "y": 0.0}
	var partner_misaligned: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(fire_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_misaligned, {})
	var charging: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(fire_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_accepting, {})
	var reloading_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "state": "shooting", "payload": {"size": 16.0}, "rec_payload": null, "target_size": 16.0, "turret_rotation": 90.0, "pay_rotation": 90.0, "pay_length": 8.0, "loaded": true, "pay_vector": Vector2.ZERO, "charge": 0.0, "charging": false, "reload_counter": 0.5, "waiting_shooters": []}
	var reloading: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(reloading_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_accepting, {})
	proof["fire_gate_requires_queue_and_angles"] = (queued.get("partner_waiting_shooters", []) as Array) == [other_pos, this_pos] and is_equal_approx(float(queued.get("charge", -1.0)), 0.0) and bool(queued.get("charging", true)) == false and str(queued.get("state", "")) == "shooting" and (not_accepting.get("partner_waiting_shooters", []) as Array) == [this_pos] and is_equal_approx(float(not_accepting.get("charge", -1.0)), 0.0) and is_equal_approx(float(misaligned.get("turret_rotation", -1.0)), 85.0) and is_equal_approx(float(misaligned.get("charge", -1.0)), 0.0) and str(misaligned.get("state", "")) == "shooting" and is_equal_approx(float(partner_misaligned.get("charge", -1.0)), 0.0) and is_equal_approx(float(charging.get("charge", -1.0)), 1.0) and bool(charging.get("charging", false)) == true and bool(charging.get("fired", true)) == false and str(charging.get("state", "")) == "shooting" and charging.get("payload", null) != null and is_equal_approx(float(charging.get("pay_length", -1.0)), 11.125) and (reloading.get("partner_waiting_shooters", []) as Array) == [this_pos] and is_equal_approx(float(reloading.get("turret_rotation", -1.0)), 90.0) and is_equal_approx(float(reloading.get("charge", -1.0)), 0.0) and is_equal_approx(float(reloading.get("pay_length", -1.0)), 8.625)

	# Transfer (PayloadMassDriver.java:292-326): charge 89.5
	# + edelta 1.0 reaches 90.5 >= chargeTime 90, so the
	# payload transfers -- the self side resets (payload null,
	# payLength 0, loaded false, state idle, reloadCounter 1f)
	# while charge is NOT reset (90.5 stays) and charging stays
	# true; the partner takes the payload, effectDelayTimer
	# 11f (transferEffect.lifetime), payVector (-11.125, 0)
	# (the trns of turretRotation 0 by length), payRotation 0
	# (the shooter turretRotation), payLength 11.125 (length),
	# loaded true, lastOther this driver, and goes idle with
	# this driver removed from its queue. Just below the line
	# (charge 88 -> 89) nothing transfers yet.
	var transfer_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "state": "shooting", "payload": {"size": 16.0}, "rec_payload": null, "target_size": 16.0, "turret_rotation": 0.0, "pay_rotation": 0.0, "pay_length": 11.125, "loaded": true, "pay_vector": Vector2.ZERO, "charge": 89.5, "charging": false, "reload_counter": 0.0, "waiting_shooters": []}
	var transferred: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(transfer_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_accepting, {})
	var transferred_partner_payload: Dictionary = transferred.get("partner_payload", {})
	var transferred_partner_vector: Vector2 = transferred.get("partner_pay_vector", Vector2(-1.0, -1.0))
	var below_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "state": "shooting", "payload": {"size": 16.0}, "rec_payload": null, "target_size": 16.0, "turret_rotation": 0.0, "pay_rotation": 0.0, "pay_length": 11.125, "loaded": true, "pay_vector": Vector2.ZERO, "charge": 88.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": []}
	var below: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(below_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_accepting, {})
	proof["transfer_resets_both_sides"] = bool(transferred.get("fired", false)) == true and transferred.get("payload", {"size": -1.0}) == null and is_equal_approx(float(transferred.get("pay_length", -1.0)), 0.0) and bool(transferred.get("loaded", true)) == false and str(transferred.get("state", "")) == "idle" and is_equal_approx(float(transferred.get("reload_counter", -1.0)), 1.0) and is_equal_approx(float(transferred.get("charge", -1.0)), 90.5) and bool(transferred.get("charging", false)) == true and is_equal_approx(float(transferred_partner_payload.get("size", -1.0)), 16.0) and is_equal_approx(float(transferred.get("partner_effect_delay_timer", -1.0)), 11.0) and is_equal_approx(transferred_partner_vector.x, -11.125) and is_equal_approx(transferred_partner_vector.y, 0.0) and is_equal_approx(float(transferred.get("partner_pay_rotation", -1.0)), 0.0) and is_equal_approx(float(transferred.get("partner_pay_length", -1.0)), 11.125) and bool(transferred.get("partner_loaded", false)) == true and str(transferred.get("partner_state", "")) == "idle" and (transferred.get("partner_waiting_shooters", [-1]) as Array) == [] and int(transferred.get("partner_last_other", -1)) == this_pos and bool(below.get("fired", true)) == false and below.get("payload", null) != null and str(below.get("state", "")) == "shooting" and is_equal_approx(float(below.get("charge", -1.0)), 89.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadMassDriverBranchesProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
