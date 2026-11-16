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

	# A proof-local fake game (the N2142 precedent): the stamp
	# only calls block_sprite_at_cell, so a RefCounted carrying
	# proof-made sprites is deterministic and independent of the
	# campaign slice's layout. The accelerator sprite carries
	# the accelerator family frame
	# (source_accelerator_building); the turret sprite carries
	# a different family frame; the bare sprite carries none.
	var game := FakePowerGame.new()
	var accelerator_cell := Vector2i(3, 4)
	var accelerator_sprite := Sprite2D.new()
	accelerator_sprite.set_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {"enabled": true, "power_status": 1.0, "battery_stored": 0.0})
	game.sprites[accelerator_cell] = accelerator_sprite
	var turret_cell := Vector2i(5, 6)
	var turret_sprite := Sprite2D.new()
	turret_sprite.set_meta("source_turret_building", {"enabled": true, "power_status": 1.0})
	game.sprites[turret_cell] = turret_sprite
	var bare_cell := Vector2i(7, 8)
	var bare_sprite := Sprite2D.new()
	game.sprites[bare_cell] = bare_sprite

	# --- the stamp writes the getBatteryStored total on the
	# accelerator frame (PowerGraph.java:118-127, the
	# enabled-battery total the canLaunch gate reads,
	# Accelerator.java:239-240), overwriting the stale 0.0
	# default a live accelerator read before this slice. ---
	var stamped: Dictionary = placed_power_graph_state.source_accelerator_set_battery_stored_for_cell_state(game, accelerator_cell, 750000.0)
	var accelerator_frame: Dictionary = accelerator_sprite.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})
	proof["accelerator_set_stamps_frame"] = bool(stamped.get("stored", false)) and str(stamped.get("reason", "")) == "live_frame" and is_equal_approx(float(accelerator_frame.get("battery_stored", -1.0)), 750000.0)

	# --- a cell with no sprite has no building: nothing stored. ---
	var set_missing: Dictionary = placed_power_graph_state.source_accelerator_set_battery_stored_for_cell_state(game, Vector2i(9, 9), 750000.0)
	proof["accelerator_set_missing_sprite"] = not bool(set_missing.get("stored", true)) and str(set_missing.get("reason", "")) == "no_sprite"

	# --- a non-accelerator building is never stamped: the
	# stored total is meaningless for it, and its own frame is
	# left untouched (no battery_stored key added). ---
	var set_turret: Dictionary = placed_power_graph_state.source_accelerator_set_battery_stored_for_cell_state(game, turret_cell, 750000.0)
	var turret_frame: Dictionary = turret_sprite.get_meta("source_turret_building", {})
	proof["accelerator_set_not_accelerator"] = not bool(set_turret.get("stored", true)) and str(set_turret.get("reason", "")) == "not_accelerator" and not bool(turret_frame.has("battery_stored"))

	# --- a sprite with no family frame (conduit, core) has no
	# accelerator frame to stamp. ---
	var set_bare: Dictionary = placed_power_graph_state.source_accelerator_set_battery_stored_for_cell_state(game, bare_cell, 750000.0)
	proof["accelerator_set_no_frame"] = not bool(set_bare.get("stored", true)) and str(set_bare.get("reason", "")) == "not_accelerator"

	# --- a second stamp overwrites the first: the frame tracks
	# the live total tick by tick, it never accumulates. ---
	var restamped: Dictionary = placed_power_graph_state.source_accelerator_set_battery_stored_for_cell_state(game, accelerator_cell, 1000000.0)
	accelerator_frame = accelerator_sprite.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})
	proof["accelerator_set_overwrites_stale"] = bool(restamped.get("stored", false)) and is_equal_approx(float(accelerator_frame.get("battery_stored", -1.0)), 1000000.0)

	# --- the total the wiring feeds the stamp is
	# getBatteryStored itself (PowerGraph.java:118-127):
	# enabled batteries only, status * capacity summed -- a
	# half-full 1,000,000-capacity battery plus a full
	# 500,000-capacity one store 1,000,000, and a disabled
	# battery contributes nothing even at full status. ---
	var batteries: Array = [
		{"enabled": true, "power_status": 0.5, "capacity": 1000000.0},
		{"enabled": true, "power_status": 1.0, "capacity": 500000.0},
		{"enabled": false, "power_status": 1.0, "capacity": 999999.0},
	]
	var battery_total: Dictionary = power_graph_state.battery_state(batteries)
	proof["battery_stored_total_from_batteries"] = is_equal_approx(float(battery_total.get("stored", -1.0)), 1000000.0)

	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07AcceleratorBatteryStampProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
