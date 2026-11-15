extends Node

const main_scene := preload("res://scenes/Main.tscn")
const item_bridge_build_state := preload("res://src/game/SourceItemBridgeBuildState.gd")
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

	# --- Pure advance (N2225): ItemBridgeBuild.updateTile()
	# (ItemBridge.java:319-348) + updateTransport()
	# (ItemBridge.java:355-368): the timeSpeed approachDelta
	# toward (wasMoved ? 1 : 0) at 1/60f (ItemBridge.java:326),
	# time += timeSpeed * delta() (ItemBridge.java:328), the
	# checkIncoming prune (ItemBridge.java:305-317), the
	# incoming registration on the partner frame
	# (ItemBridge.java:339-344), the warmup approachDelta toward
	# efficiency at 1/30f (ItemBridge.java:345), and
	# updateTransport (ItemBridge.java:355-368). source_delta is
	# Time.delta in ticks (1.0 = one tick); transportTime is the
	# def constant 2f (Blocks.java:2119) and itemCapacity 10
	# (ItemBridge.java:49). Positions are Point2-packed
	# (arc Point2.java:40-42): this tile (3, 5), the partner
	# (3, 10), a live incoming bridge (3, 0), a dead one (5, 5).
	var this_pos: int = (3 << 16) | 5
	var partner_pos: int = (3 << 16) | 10
	var live_pos: int = (3 << 16) | 0
	var dead_pos: int = (5 << 16) | 5
	var item_order: Array = ["copper", "lead"]

	# transportCounter += edelta() (ItemBridge.java:356), with
	# edelta() = efficiency * Time.delta * timeScale
	# (BuildingComp.java:1927-1929): at efficiency 0.5 one tick
	# charges 0.5, at timeScale 2.0 it charges 1.0, and at
	# efficiency 0 it charges nothing. timeSpeed approaches
	# (wasMoved ? 1 : 0) at 1/60f by RAW Time.delta
	# (Mathf.java:420-422): with wasMoved true one tick moves
	# it 0 -> 1/60 and time -8 -> -8 + 1/60; with wasMoved
	# false it stays 0 and time stays at the -8f default
	# (ItemBridge.java:201).
	var charge_frame: Dictionary = {"efficiency": 0.5, "link": partner_pos, "transport_counter": 0.0, "warmup": 0.0, "time": -8.0, "time_speed": 0.0, "was_moved": false, "moved": false, "incoming": [], "items": {}, "take_rotation": 0}
	var partner_empty: Dictionary = {"exists": true, "pos": partner_pos, "items": {}, "incoming": []}
	var charged: Dictionary = item_bridge_build_state.source_item_bridge_update_transport_state(charge_frame, 1.0, 1.0, 2.0, 10, true, this_pos, partner_empty, {}, item_order)
	var charged_scaled: Dictionary = item_bridge_build_state.source_item_bridge_update_transport_state(charge_frame, 1.0, 2.0, 2.0, 10, true, this_pos, partner_empty, {}, item_order)
	var unpowered_frame: Dictionary = {"efficiency": 0.0, "link": partner_pos, "transport_counter": 0.0, "warmup": 0.0, "time": -8.0, "time_speed": 0.0, "was_moved": false, "moved": false, "incoming": [], "items": {}, "take_rotation": 0}
	var unpowered: Dictionary = item_bridge_build_state.source_item_bridge_update_transport_state(unpowered_frame, 1.0, 1.0, 2.0, 10, true, this_pos, partner_empty, {}, item_order)
	var moved_frame: Dictionary = {"efficiency": 0.5, "link": partner_pos, "transport_counter": 0.0, "warmup": 0.0, "time": -8.0, "time_speed": 0.0, "was_moved": true, "moved": false, "incoming": [], "items": {}, "take_rotation": 0}
	var moved_tick: Dictionary = item_bridge_build_state.source_item_bridge_update_transport_state(moved_frame, 1.0, 1.0, 2.0, 10, true, this_pos, partner_empty, {}, item_order)
	proof["transport_counter_charges_with_edelta"] = is_equal_approx(float(charged.get("transport_counter", -1.0)), 0.5) and is_equal_approx(float(charged_scaled.get("transport_counter", -1.0)), 1.0) and is_equal_approx(float(unpowered.get("transport_counter", -1.0)), 0.0) and is_equal_approx(float(charged.get("time_speed", -1.0)), 0.0) and is_equal_approx(float(charged.get("time", -1.0)), -8.0) and is_equal_approx(float(moved_tick.get("time_speed", -1.0)), 1.0 / 60.0) and is_equal_approx(float(moved_tick.get("time", -1.0)), -8.0 + 1.0 / 60.0)

	# The handoff fires at transportTime (ItemBridge.java:357-361):
	# counter 1.5 + edelta 1.0 = 2.5 hands one copper to the
	# partner (acceptItem is the capacity gate -- the linked()
	# shortcut, ItemBridge.java:464-466, is true when
	# hadValidLink holds), leaves 0.5, and sets moved; the take
	# rotation advances 0 -> 1. With counter 3.5 the while loop
	# hands TWO coppers in one tick (4.5 - 2 - 2 = 0.5).
	var handoff_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "transport_counter": 1.5, "warmup": 0.0, "time": -8.0, "time_speed": 0.0, "was_moved": false, "moved": false, "incoming": [], "items": {"copper": 2}, "take_rotation": 0}
	var handed: Dictionary = item_bridge_build_state.source_item_bridge_update_transport_state(handoff_frame, 1.0, 1.0, 2.0, 10, true, this_pos, partner_empty, {}, item_order)
	var handed_items: Dictionary = handed.get("items", {})
	var handed_partner_items: Dictionary = handed.get("partner_items", {})
	var double_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "transport_counter": 3.5, "warmup": 0.0, "time": -8.0, "time_speed": 0.0, "was_moved": false, "moved": false, "incoming": [], "items": {"copper": 3}, "take_rotation": 0}
	var doubled: Dictionary = item_bridge_build_state.source_item_bridge_update_transport_state(double_frame, 1.0, 1.0, 2.0, 10, true, this_pos, partner_empty, {}, item_order)
	var doubled_items: Dictionary = doubled.get("items", {})
	var doubled_partner_items: Dictionary = doubled.get("partner_items", {})
	proof["handoff_at_transport_time"] = is_equal_approx(float(handed.get("transport_counter", -1.0)), 0.5) and bool(handed.get("moved", false)) == true and int(handed_items.get("copper", -1)) == 1 and int(handed_partner_items.get("copper", -1)) == 1 and int(handed.get("take_rotation", -1)) == 1 and is_equal_approx(float(doubled.get("transport_counter", -1.0)), 0.5) and int(doubled_items.get("copper", -1)) == 1 and int(doubled_partner_items.get("copper", -1)) == 2

	# A rejected item comes back (ItemBridge.java:362-364):
	# the partner is full (10/10), so the taken copper returns
	# via items.add(item, 1), moved stays false -- but the
	# counter is STILL spent (the decrement is unconditional,
	# ItemBridge.java:366) and the take rotation still advanced.
	# With no items at all the take is null and the counter is
	# spent the same way.
	var full_partner: Dictionary = {"exists": true, "pos": partner_pos, "items": {"copper": 10}, "incoming": []}
	var reject_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "transport_counter": 1.5, "warmup": 0.0, "time": -8.0, "time_speed": 0.0, "was_moved": false, "moved": false, "incoming": [], "items": {"copper": 2}, "take_rotation": 0}
	var rejected: Dictionary = item_bridge_build_state.source_item_bridge_update_transport_state(reject_frame, 1.0, 1.0, 2.0, 10, true, this_pos, full_partner, {}, item_order)
	var rejected_items: Dictionary = rejected.get("items", {})
	var rejected_partner_items: Dictionary = rejected.get("partner_items", {})
	var empty_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "transport_counter": 1.5, "warmup": 0.0, "time": -8.0, "time_speed": 0.0, "was_moved": false, "moved": false, "incoming": [], "items": {}, "take_rotation": 0}
	var emptied: Dictionary = item_bridge_build_state.source_item_bridge_update_transport_state(empty_frame, 1.0, 1.0, 2.0, 10, true, this_pos, partner_empty, {}, item_order)
	proof["item_returns_when_partner_rejects"] = is_equal_approx(float(rejected.get("transport_counter", -1.0)), 0.5) and bool(rejected.get("moved", true)) == false and int(rejected_items.get("copper", -1)) == 2 and int(rejected_partner_items.get("copper", -1)) == 10 and int(rejected.get("take_rotation", -1)) == 1 and is_equal_approx(float(emptied.get("transport_counter", -1.0)), 0.5) and bool(emptied.get("moved", true)) == false

	# warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f)
	# (ItemBridge.java:345): one tick from 0 toward 0.6 rises
	# exactly 1/30, and 60 ticks reach 0.6 exactly (approach
	# clamps at the target after 18 ticks). With efficiency 0
	# a warm bridge cools 1.0 -> 1 - 1/30.
	var warmup_frame: Dictionary = {"efficiency": 0.6, "link": partner_pos, "transport_counter": 0.0, "warmup": 0.0, "time": -8.0, "time_speed": 0.0, "was_moved": false, "moved": false, "incoming": [], "items": {}, "take_rotation": 0}
	var warmup_first: Dictionary = item_bridge_build_state.source_item_bridge_update_transport_state(warmup_frame, 1.0, 1.0, 2.0, 10, true, this_pos, partner_empty, {}, item_order)
	for iteration in range(60):
		var advanced: Dictionary = item_bridge_build_state.source_item_bridge_update_transport_state(warmup_frame, 1.0, 1.0, 2.0, 10, true, this_pos, partner_empty, {}, item_order)
		warmup_frame["warmup"] = advanced["warmup"]
		warmup_frame["transport_counter"] = advanced["transport_counter"]
	var cooling_frame: Dictionary = {"efficiency": 0.0, "link": partner_pos, "transport_counter": 0.0, "warmup": 1.0, "time": -8.0, "time_speed": 0.0, "was_moved": false, "moved": false, "incoming": [], "items": {}, "take_rotation": 0}
	var cooled: Dictionary = item_bridge_build_state.source_item_bridge_update_transport_state(cooling_frame, 1.0, 1.0, 2.0, 10, true, this_pos, partner_empty, {}, item_order)
	proof["warmup_approaches_efficiency_when_linked"] = is_equal_approx(float(warmup_first.get("warmup", -1.0)), 1.0 / 30.0) and is_equal_approx(float(warmup_frame.get("warmup", -1.0)), 0.6) and is_equal_approx(float(cooled.get("warmup", -1.0)), 1.0 - 1.0 / 30.0)

	# Without a valid link (ItemBridge.java:335-337): warmup is
	# 0f, the transport counter is NOT charged (updateTransport
	# never runs), the items stay put -- but time still
	# advances (the timeSpeed / time steps run before the
	# branch, ItemBridge.java:326-328).
	var unlinked_frame: Dictionary = {"efficiency": 1.0, "link": -1, "transport_counter": 1.5, "warmup": 0.8, "time": -8.0, "time_speed": 0.0, "was_moved": true, "moved": false, "incoming": [], "items": {"copper": 2}, "take_rotation": 0}
	var unlinked: Dictionary = item_bridge_build_state.source_item_bridge_update_transport_state(unlinked_frame, 1.0, 1.0, 2.0, 10, false, this_pos, {"exists": false, "pos": -1, "items": {}, "incoming": []}, {}, item_order)
	var unlinked_items: Dictionary = unlinked.get("items", {})
	proof["warmup_zero_when_unlinked"] = is_equal_approx(float(unlinked.get("warmup", -1.0)), 0.0) and is_equal_approx(float(unlinked.get("transport_counter", -1.0)), 1.5) and int(unlinked_items.get("copper", -1)) == 2 and bool(unlinked.get("moved", true)) == false and is_equal_approx(float(unlinked.get("time", -1.0)), -8.0 + 1.0 / 60.0)

	# checkIncoming prunes dead links (ItemBridge.java:305-317)
	# and the live registration lands on the partner frame
	# (ItemBridge.java:339-344): the dead entry drops, the live
	# entry stays, this tile's position is added to the partner
	# incoming once (no duplicate on re-registration), and an
	# entry with no validity record prunes (a missing tile is
	# never valid).
	var incoming_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "transport_counter": 0.0, "warmup": 0.0, "time": -8.0, "time_speed": 0.0, "was_moved": false, "moved": false, "incoming": [live_pos, dead_pos], "items": {}, "take_rotation": 0}
	var pruned: Dictionary = item_bridge_build_state.source_item_bridge_update_transport_state(incoming_frame, 1.0, 1.0, 2.0, 10, true, this_pos, partner_empty, {live_pos: true, dead_pos: false}, item_order)
	var registered_partner: Dictionary = {"exists": true, "pos": partner_pos, "items": {}, "incoming": [this_pos]}
	var re_registered: Dictionary = item_bridge_build_state.source_item_bridge_update_transport_state(incoming_frame, 1.0, 1.0, 2.0, 10, true, this_pos, registered_partner, {live_pos: true, dead_pos: false}, item_order)
	var ghost_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "transport_counter": 0.0, "warmup": 0.0, "time": -8.0, "time_speed": 0.0, "was_moved": false, "moved": false, "incoming": [0], "items": {}, "take_rotation": 0}
	var ghosted: Dictionary = item_bridge_build_state.source_item_bridge_update_transport_state(ghost_frame, 1.0, 1.0, 2.0, 10, true, this_pos, partner_empty, {}, item_order)
	proof["incoming_prunes_dead_links"] = (pruned.get("incoming", []) as Array) == [live_pos] and (pruned.get("partner_incoming", []) as Array) == [this_pos] and (re_registered.get("partner_incoming", []) as Array) == [this_pos] and (ghosted.get("incoming", []) as Array) == []

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemBridgeTransportProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
