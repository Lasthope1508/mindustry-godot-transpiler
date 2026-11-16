extends Node

const placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const accelerator_build_state := preload("res://src/game/SourceAcceleratorBuildState.gd")
const power_graph_state := preload("res://src/game/SourcePowerGraphState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


class FakePowerGame extends RefCounted:
	var sprites: Dictionary = {}

	func block_sprite_at_cell(cell: Vector2i) -> Variant:
		return sprites.get(cell, null)


func _ready() -> void:
	var proof: Dictionary = {}

	# A proof-local fake game (the N2142 precedent): the take
	# helper only calls block_sprite_at_cell, so a RefCounted
	# carrying proof-made sprites is deterministic and
	# independent of the campaign slice's layout. The
	# accelerator sprite carries the accelerator family frame
	# (source_accelerator_building) with a pending one-shot
	# launch_drain_request; the idle accelerator carries the
	# frame with no request; the turret sprite carries a
	# different family frame; the bare sprite carries none.
	var game := FakePowerGame.new()
	var accelerator_cell := Vector2i(3, 4)
	var accelerator_sprite := Sprite2D.new()
	accelerator_sprite.set_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {"enabled": true, "power_status": 1.0, "battery_stored": 0.0, "launch_drain_request": {"requirement": 1000000.0}})
	game.sprites[accelerator_cell] = accelerator_sprite
	var idle_cell := Vector2i(5, 6)
	var idle_sprite := Sprite2D.new()
	idle_sprite.set_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {"enabled": true, "power_status": 1.0, "battery_stored": 1000000.0})
	game.sprites[idle_cell] = idle_sprite
	var turret_cell := Vector2i(7, 8)
	var turret_sprite := Sprite2D.new()
	turret_sprite.set_meta("source_turret_building", {"enabled": true, "power_status": 1.0})
	game.sprites[turret_cell] = turret_sprite
	var bare_cell := Vector2i(9, 10)
	var bare_sprite := Sprite2D.new()
	game.sprites[bare_cell] = bare_sprite

	# --- the take consumes the one-shot request: it returns
	# the requirement (the powerBufferRequirement Java drains
	# via `power.graph.useBatteries(powerBufferRequirement);`,
	# Accelerator.java:270) and erases the frame key, so a
	# second take finds nothing -- the runtime must never
	# apply the same launch twice. ---
	var taken: Dictionary = placed_power_graph_state.source_accelerator_take_launch_drain_request_for_cell_state(game, accelerator_cell)
	var accelerator_frame: Dictionary = accelerator_sprite.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})
	var taken_again: Dictionary = placed_power_graph_state.source_accelerator_take_launch_drain_request_for_cell_state(game, accelerator_cell)
	proof["launch_drain_request_taken"] = bool(taken.get("found", false)) and str(taken.get("reason", "")) == "live_frame" and is_equal_approx(float(taken.get("requirement", -1.0)), 1000000.0) and not bool(accelerator_frame.has("launch_drain_request")) and not bool(taken_again.get("found", true)) and str(taken_again.get("reason", "")) == "no_request"

	# --- a cell with no sprite has no building: nothing taken. ---
	var take_missing: Dictionary = placed_power_graph_state.source_accelerator_take_launch_drain_request_for_cell_state(game, Vector2i(11, 12))
	proof["launch_drain_request_missing_sprite"] = not bool(take_missing.get("found", true)) and str(take_missing.get("reason", "")) == "no_sprite" and is_equal_approx(float(take_missing.get("requirement", -1.0)), 0.0)

	# --- a non-accelerator building never carries a launch
	# drain request: its own frame is left untouched (no
	# launch_drain_request key added or removed). ---
	var take_turret: Dictionary = placed_power_graph_state.source_accelerator_take_launch_drain_request_for_cell_state(game, turret_cell)
	var turret_frame: Dictionary = turret_sprite.get_meta("source_turret_building", {})
	proof["launch_drain_request_not_accelerator"] = not bool(take_turret.get("found", true)) and str(take_turret.get("reason", "")) == "not_accelerator" and not bool(turret_frame.has("launch_drain_request"))

	# --- a sprite with no family frame (conduit, core) has no
	# accelerator frame to take from. ---
	var take_bare: Dictionary = placed_power_graph_state.source_accelerator_take_launch_drain_request_for_cell_state(game, bare_cell)
	proof["launch_drain_request_no_frame"] = not bool(take_bare.get("found", true)) and str(take_bare.get("reason", "")) == "not_accelerator"

	# --- an accelerator frame with no pending request (no
	# launch this tick) takes nothing -- the runtime skips it. ---
	var take_idle: Dictionary = placed_power_graph_state.source_accelerator_take_launch_drain_request_for_cell_state(game, idle_cell)
	proof["launch_drain_request_no_request"] = not bool(take_idle.get("found", true)) and str(take_idle.get("reason", "")) == "no_request" and is_equal_approx(float(take_idle.get("requirement", -1.0)), 0.0)

	# --- the scaling the runtime applies through the existing
	# use_batteries_state (PowerGraph.java:154-167): two
	# enabled batteries at status 1.0 + 0.5 with equal
	# 1,000,000 capacity store 1,500,000; a launch requirement
	# of 750,000 (50% of stored) drains used 750,000 at
	# percentage 0.5, so BOTH scale by x0.5 (1.0 -> 0.5,
	# 0.5 -> 0.25) -- proportional, not first-battery-first.
	# A disabled battery at full status is untouched even
	# though it carries capacity. ---
	var batteries: Array = [
		{"origin_cell": Vector2i(1, 1), "enabled": true, "power_status": 1.0, "capacity": 1000000.0},
		{"origin_cell": Vector2i(2, 2), "enabled": true, "power_status": 0.5, "capacity": 1000000.0},
		{"origin_cell": Vector2i(3, 3), "enabled": false, "power_status": 1.0, "capacity": 999999.0},
	]
	var drained: Dictionary = power_graph_state.use_batteries_state(batteries, 750000.0)
	var scaled: Array = drained.get("batteries", [])
	proof["launch_drain_scales_batteries_half"] = is_equal_approx(float(drained.get("used", -1.0)), 750000.0) and is_equal_approx(float(drained.get("consumed_power_percentage", -1.0)), 0.5) and scaled.size() == 3 and is_equal_approx(float(scaled[0].get("power_status", -1.0)), 0.5) and is_equal_approx(float(scaled[1].get("power_status", -1.0)), 0.25) and is_equal_approx(float(scaled[2].get("power_status", -1.0)), 1.0)

	# --- the Mathf.equal zero guard (PowerGraph.java:156,
	# `if(Mathf.equal(stored, 0f)) return 0f;`): with no stored
	# power the drain uses nothing, scales nothing, and the
	# percentage stays 0. ---
	var empty_batteries: Array = [
		{"origin_cell": Vector2i(1, 1), "enabled": true, "power_status": 0.0, "capacity": 1000000.0},
	]
	var drained_empty: Dictionary = power_graph_state.use_batteries_state(empty_batteries, 1000000.0)
	var scaled_empty: Array = drained_empty.get("batteries", [])
	proof["launch_drain_zero_stored"] = is_equal_approx(float(drained_empty.get("used", -1.0)), 0.0) and is_equal_approx(float(drained_empty.get("consumed_power_percentage", -1.0)), 0.0) and bool(drained_empty.get("zero_guard_returned", false)) and scaled_empty.size() == 1 and is_equal_approx(float(scaled_empty[0].get("power_status", -1.0)), 0.0)

	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07AcceleratorLaunchDrainProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
