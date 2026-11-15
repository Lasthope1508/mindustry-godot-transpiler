extends Node

const main_scene := preload("res://scenes/Main.tscn")
const liquid_bridge_build_state := preload("res://src/game/SourceLiquidBridgeBuildState.gd")
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

	# --- Pure advance (N2275): LiquidBridgeBuild.updateTransport()
	# (LiquidBridge.java:22-26) over the inherited
	# ItemBridgeBuild.updateTile() (ItemBridge.java:319-348):
	# the warmup approachDelta toward efficiency at 1/30f when
	# linked (ItemBridge.java:345) and warmup = 0f when
	# unlinked (ItemBridge.java:337), the warmup >= 0.25f gate
	# (LiquidBridge.java:23), and moveLiquid
	# (BuildingComp.java:938-978): the pressure-scaled flow,
	# the acceptLiquid gate (the ItemBridge override,
	# ItemBridge.java:434-439), and moved |= flow > 0.05f
	# (LiquidBridge.java:24). source_delta is Time.delta in
	# ticks (1.0 = one tick); liquidCapacity is the def
	# constant 100f (Blocks.java:2395) and liquidPressure the
	# Block default 1f (Block.java:79). Liquid stores are
	# module states (amounts array by liquid id + current id,
	# LiquidModule.java:24/81-83): liquid 0 is the moved
	# liquid, liquid 1 the partner's other liquid.
	var empty_partner: Dictionary = {"exists": true, "team_matches": true, "has_liquids": true, "liquid_capacity": 100.0, "liquids": {"liquids": [0.0], "current": 0, "flow": null}}

	# warmup = Mathf.approachDelta(warmup, efficiency, 1f / 30f)
	# (ItemBridge.java:345): one tick from 0 toward 0.6 rises
	# exactly 1/30, and 60 ticks reach 0.6 exactly (approach
	# clamps at the target after 18 ticks). With efficiency 0
	# a warm bridge cools 1.0 -> 1 - 1/30. No liquid moves in
	# any of these ticks -- the stores are empty.
	var warmup_frame: Dictionary = {"efficiency": 0.6, "warmup": 0.0, "moved": false}
	var warmup_first: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(warmup_frame, 1.0, 100.0, 1.0, true, {"liquids": [0.0], "current": 0, "flow": null}, empty_partner)
	for iteration in range(60):
		var advanced: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(warmup_frame, 1.0, 100.0, 1.0, true, {"liquids": [0.0], "current": 0, "flow": null}, empty_partner)
		warmup_frame["warmup"] = advanced["warmup"]
	var cooling_frame: Dictionary = {"efficiency": 0.0, "warmup": 1.0, "moved": false}
	var cooled: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(cooling_frame, 1.0, 100.0, 1.0, true, {"liquids": [0.0], "current": 0, "flow": null}, empty_partner)
	proof["warmup_approaches_efficiency"] = is_equal_approx(float(warmup_first.get("warmup", -1.0)), 1.0 / 30.0) and is_equal_approx(float(warmup_frame.get("warmup", -1.0)), 0.6) and is_equal_approx(float(cooled.get("warmup", -1.0)), 1.0 - 1.0 / 30.0) and is_equal_approx(float(warmup_first.get("flow", -1.0)), 0.0)

	# The warmup gate (LiquidBridge.java:23): below 0.25f no
	# liquid moves, even with a full store and a linked
	# partner -- warmup 0.2 toward efficiency 0.2 stays 0.2,
	# and 0.24 toward 0.24 stays 0.24. The approach runs
	# BEFORE the gate (ItemBridge.java:345-346): warmup 0.24
	# toward efficiency 1.0 crosses to 0.24 + 1/30 in one tick
	# and the transfer fires in that same tick.
	var blocked_frame: Dictionary = {"efficiency": 0.2, "warmup": 0.2, "moved": false}
	var blocked: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(blocked_frame, 1.0, 100.0, 1.0, true, {"liquids": [50.0], "current": 0, "flow": null}, empty_partner)
	var blocked_amounts: Array = (blocked.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var edge_frame: Dictionary = {"efficiency": 0.24, "warmup": 0.24, "moved": false}
	var edged: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(edge_frame, 1.0, 100.0, 1.0, true, {"liquids": [50.0], "current": 0, "flow": null}, empty_partner)
	var crossing_frame: Dictionary = {"efficiency": 1.0, "warmup": 0.24, "moved": false}
	var crossed: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(crossing_frame, 1.0, 100.0, 1.0, true, {"liquids": [50.0], "current": 0, "flow": null}, empty_partner)
	var crossed_amounts: Array = (crossed.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var crossed_partner_amounts: Array = (crossed.get("partner_liquids_after", {}) as Dictionary).get("liquids", [])
	proof["transport_blocked_below_warmup_quarter"] = is_equal_approx(float(blocked.get("flow", -1.0)), 0.0) and is_equal_approx(float(blocked_amounts[0]), 50.0) and bool(blocked.get("moved", true)) == false and is_equal_approx(float(edged.get("flow", -1.0)), 0.0) and is_equal_approx(float(crossed.get("warmup", -1.0)), 0.24 + 1.0 / 30.0) and is_equal_approx(float(crossed.get("flow", -1.0)), 50.0) and is_equal_approx(float(crossed_amounts[0]), 0.0) and is_equal_approx(float(crossed_partner_amounts[0]), 50.0) and bool(crossed.get("moved", false)) == true

	# moveLiquid (BuildingComp.java:938-978): flow =
	# min(clamp(fract - ofract) * capacity, have), capped by
	# the partner room. 80 vs 20 at pressure 1.0 flows 60
	# (fract 0.8, ofract 0.2); the same stores at pressure
	# 0.5 flow 20 (fract 0.4); 10 vs 0 flows 10, capped by
	# what the bridge holds; 90 vs 50 at pressure 2.0 flows
	# 50, capped by the partner room (fract 1.8 clamps the
	# difference to 1.0, so the raw flow would be 90).
	var warm_frame: Dictionary = {"efficiency": 1.0, "warmup": 1.0, "moved": false}
	var partner_twenty: Dictionary = {"exists": true, "team_matches": true, "has_liquids": true, "liquid_capacity": 100.0, "liquids": {"liquids": [20.0], "current": 0, "flow": null}}
	var transferred: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(warm_frame, 1.0, 100.0, 1.0, true, {"liquids": [80.0], "current": 0, "flow": null}, partner_twenty)
	var transferred_amounts: Array = (transferred.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var transferred_partner_amounts: Array = (transferred.get("partner_liquids_after", {}) as Dictionary).get("liquids", [])
	var pressured: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(warm_frame, 1.0, 100.0, 0.5, true, {"liquids": [80.0], "current": 0, "flow": null}, partner_twenty)
	var pressured_amounts: Array = (pressured.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var pressured_partner_amounts: Array = (pressured.get("partner_liquids_after", {}) as Dictionary).get("liquids", [])
	var capped: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(warm_frame, 1.0, 100.0, 1.0, true, {"liquids": [10.0], "current": 0, "flow": null}, empty_partner)
	var capped_amounts: Array = (capped.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var capped_partner_amounts: Array = (capped.get("partner_liquids_after", {}) as Dictionary).get("liquids", [])
	var partner_fifty: Dictionary = {"exists": true, "team_matches": true, "has_liquids": true, "liquid_capacity": 100.0, "liquids": {"liquids": [50.0], "current": 0, "flow": null}}
	var room_capped: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(warm_frame, 1.0, 100.0, 2.0, true, {"liquids": [90.0], "current": 0, "flow": null}, partner_fifty)
	var room_amounts: Array = (room_capped.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var room_partner_amounts: Array = (room_capped.get("partner_liquids_after", {}) as Dictionary).get("liquids", [])
	proof["move_liquid_transfers_by_pressure"] = is_equal_approx(float(transferred.get("flow", -1.0)), 60.0) and is_equal_approx(float(transferred_amounts[0]), 20.0) and is_equal_approx(float(transferred_partner_amounts[0]), 80.0) and is_equal_approx(float(pressured.get("flow", -1.0)), 20.0) and is_equal_approx(float(pressured_amounts[0]), 60.0) and is_equal_approx(float(pressured_partner_amounts[0]), 40.0) and is_equal_approx(float(capped.get("flow", -1.0)), 10.0) and is_equal_approx(float(capped_amounts[0]), 0.0) and is_equal_approx(float(capped_partner_amounts[0]), 10.0) and is_equal_approx(float(room_capped.get("flow", -1.0)), 50.0) and is_equal_approx(float(room_amounts[0]), 40.0) and is_equal_approx(float(room_partner_amounts[0]), 100.0)

	# moved |= moveLiquid(...) > 0.05f (LiquidBridge.java:24):
	# a 60-unit flow sets moved; a 0.04-unit flow still
	# transfers but leaves moved false; exactly 0.05 does
	# NOT set it (strictly greater); and a moved flag from
	# an earlier tick sticks through a dry tick.
	var tiny: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(warm_frame, 1.0, 100.0, 1.0, true, {"liquids": [0.04], "current": 0, "flow": null}, empty_partner)
	var tiny_amounts: Array = (tiny.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var tiny_partner_amounts: Array = (tiny.get("partner_liquids_after", {}) as Dictionary).get("liquids", [])
	var boundary: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(warm_frame, 1.0, 100.0, 1.0, true, {"liquids": [0.05], "current": 0, "flow": null}, empty_partner)
	var sticky_frame: Dictionary = {"efficiency": 1.0, "warmup": 1.0, "moved": true}
	var sticky: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(sticky_frame, 1.0, 100.0, 1.0, true, {"liquids": [0.0], "current": 0, "flow": null}, empty_partner)
	proof["moved_set_when_flow_above_threshold"] = bool(transferred.get("moved", false)) == true and is_equal_approx(float(tiny.get("flow", -1.0)), 0.04) and is_equal_approx(float(tiny_amounts[0]), 0.0) and is_equal_approx(float(tiny_partner_amounts[0]), 0.04) and bool(tiny.get("moved", true)) == false and is_equal_approx(float(boundary.get("flow", -1.0)), 0.05) and bool(boundary.get("moved", true)) == false and bool(sticky.get("moved", false)) == true

	# No transfer when the partner cannot take it: a full
	# partner (100/100, ofract above fract and no room), a
	# partner on another team, an empty self store, a partner
	# without liquids, and a missing partner all flow 0.
	# acceptLiquid (ItemBridge.java:434-439) rejects a partner
	# whose current liquid is a DIFFERENT liquid held at
	# 50 (>= 0.2f) -- but accepts the same partner when its
	# other liquid is nearly empty (0.1 < 0.2f), and the
	# transfer then sets the partner current to the moved
	# liquid (add sets current, LiquidModule.java:110-112).
	var partner_full: Dictionary = {"exists": true, "team_matches": true, "has_liquids": true, "liquid_capacity": 100.0, "liquids": {"liquids": [100.0], "current": 0, "flow": null}}
	var full: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(warm_frame, 1.0, 100.0, 1.0, true, {"liquids": [50.0], "current": 0, "flow": null}, partner_full)
	var full_amounts: Array = (full.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var enemy_partner: Dictionary = {"exists": true, "team_matches": false, "has_liquids": true, "liquid_capacity": 100.0, "liquids": {"liquids": [0.0], "current": 0, "flow": null}}
	var enemy: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(warm_frame, 1.0, 100.0, 1.0, true, {"liquids": [50.0], "current": 0, "flow": null}, enemy_partner)
	var dry: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(warm_frame, 1.0, 100.0, 1.0, true, {"liquids": [0.0], "current": 0, "flow": null}, empty_partner)
	var dry_partner: Dictionary = {"exists": true, "team_matches": true, "has_liquids": false, "liquid_capacity": 100.0, "liquids": {"liquids": [0.0], "current": 0, "flow": null}}
	var no_liquids: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(warm_frame, 1.0, 100.0, 1.0, true, {"liquids": [50.0], "current": 0, "flow": null}, dry_partner)
	var ghost_partner: Dictionary = {"exists": false, "team_matches": false, "has_liquids": false, "liquid_capacity": 100.0, "liquids": {}}
	var ghosted: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(warm_frame, 1.0, 100.0, 1.0, true, {"liquids": [50.0], "current": 0, "flow": null}, ghost_partner)
	var other_liquid_partner: Dictionary = {"exists": true, "team_matches": true, "has_liquids": true, "liquid_capacity": 100.0, "liquids": {"liquids": [0.0, 50.0], "current": 1, "flow": null}}
	var rejected: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(warm_frame, 1.0, 100.0, 1.0, true, {"liquids": [50.0, 0.0], "current": 0, "flow": null}, other_liquid_partner)
	var rejected_amounts: Array = (rejected.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var trace_partner: Dictionary = {"exists": true, "team_matches": true, "has_liquids": true, "liquid_capacity": 100.0, "liquids": {"liquids": [0.0, 0.1], "current": 1, "flow": null}}
	var traced: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(warm_frame, 1.0, 100.0, 1.0, true, {"liquids": [50.0, 0.0], "current": 0, "flow": null}, trace_partner)
	var traced_partner: Dictionary = traced.get("partner_liquids_after", {})
	var traced_partner_amounts: Array = traced_partner.get("liquids", [])
	proof["no_transfer_when_partner_full"] = is_equal_approx(float(full.get("flow", -1.0)), 0.0) and is_equal_approx(float(full_amounts[0]), 50.0) and bool(full.get("moved", true)) == false and is_equal_approx(float(enemy.get("flow", -1.0)), 0.0) and is_equal_approx(float(dry.get("flow", -1.0)), 0.0) and is_equal_approx(float(no_liquids.get("flow", -1.0)), 0.0) and is_equal_approx(float(ghosted.get("flow", -1.0)), 0.0) and is_equal_approx(float(rejected.get("flow", -1.0)), 0.0) and is_equal_approx(float(rejected_amounts[0]), 50.0) and is_equal_approx(float(traced.get("flow", -1.0)), 50.0) and is_equal_approx(float(traced_partner_amounts[0]), 50.0) and int(traced_partner.get("current", -1)) == 0

	# Without a valid link (ItemBridge.java:335-337): warmup
	# is 0f and nothing moves, even with a full store and a
	# present partner -- doDump would run here in Java, but
	# it defers (LiquidBridge.java:29-31).
	var unlinked_frame: Dictionary = {"efficiency": 1.0, "warmup": 0.8, "moved": false}
	var unlinked: Dictionary = liquid_bridge_build_state.source_liquid_bridge_update_transport_state(unlinked_frame, 1.0, 100.0, 1.0, false, {"liquids": [50.0], "current": 0, "flow": null}, empty_partner)
	var unlinked_amounts: Array = (unlinked.get("liquids_after", {}) as Dictionary).get("liquids", [])
	proof["warmup_zero_when_unlinked"] = is_equal_approx(float(unlinked.get("warmup", -1.0)), 0.0) and is_equal_approx(float(unlinked.get("flow", -1.0)), 0.0) and is_equal_approx(float(unlinked_amounts[0]), 50.0) and bool(unlinked.get("moved", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LiquidBridgeUpdateTransportProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
