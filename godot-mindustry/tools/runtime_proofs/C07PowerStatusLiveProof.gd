extends Node

const placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const battery_distribution_state := preload("res://src/game/SourcePowerGraphBatteryDistributionState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


class FakePowerGame extends RefCounted:
	var sprites: Dictionary = {}

	func block_sprite_at_cell(cell: Vector2i) -> Variant:
		return sprites.get(cell, null)


func _ready() -> void:
	var proof: Dictionary = {}

	# A proof-local fake game: the set/read pair only calls
	# block_sprite_at_cell, so a RefCounted carrying proof-made
	# sprites is deterministic and independent of the campaign
	# slice's layout. The framed sprite carries a unit-factory
	# family frame (source_unit_factory_building); the bare sprite
	# carries no family frame.
	var game := FakePowerGame.new()
	var frame_cell := Vector2i(3, 4)
	var frame_sprite := Sprite2D.new()
	frame_sprite.set_meta("source_unit_factory_building", {"enabled": true, "power_status": 0.0})
	game.sprites[frame_cell] = frame_sprite
	var bare_cell := Vector2i(5, 6)
	var bare_sprite := Sprite2D.new()
	game.sprites[bare_cell] = bare_sprite

	# --- the set stores the status on the building's family frame
	# and the read returns it (PowerGraph.java:203
	# `consumer.power.status = coverage;`, ConsumePower.java:39
	# `return build.power.status;`). ---
	var written: Dictionary = placed_power_graph_state.source_consumer_set_power_status_for_cell_state(game, frame_cell, 0.5)
	var read_back: Dictionary = placed_power_graph_state.source_consumer_power_status_for_cell_state(game, frame_cell)
	proof["consumer_set_read_roundtrip"] = bool(written.get("stored", false)) and bool(read_back.get("found", false)) and is_equal_approx(float(read_back.get("status", -1.0)), 0.5)

	# --- a cell with no sprite has no building: found false, the
	# PowerModule field default 0.0 (PowerModule.java:13 `public
	# float status = 0.0f;`). ---
	var read_missing: Dictionary = placed_power_graph_state.source_consumer_power_status_for_cell_state(game, Vector2i(9, 9))
	proof["consumer_read_missing_sprite"] = not bool(read_missing.get("found", true)) and is_equal_approx(float(read_missing.get("status", -1.0)), 0.0)

	# --- a sprite with no family frame (conduit, core) has no
	# tick frame to read: found false, status 0.0. ---
	var read_no_frame: Dictionary = placed_power_graph_state.source_consumer_power_status_for_cell_state(game, bare_cell)
	proof["consumer_read_no_frame"] = not bool(read_no_frame.get("found", true)) and is_equal_approx(float(read_no_frame.get("status", -1.0)), 0.0)

	# --- a set on a sprite with no family frame stores nothing. ---
	var set_no_frame: Dictionary = placed_power_graph_state.source_consumer_set_power_status_for_cell_state(game, bare_cell, 0.5)
	proof["consumer_set_no_frame"] = not bool(set_no_frame.get("stored", true))

	# --- distributePower coverage half (PowerGraph.java:184-215):
	# one unbuffered consumer (shouldConsumePower true,
	# power_status 0.0, delta 1.0), needed 10.0, produced 5.0,
	# charged false, last stored 0.0 -> coverage 0.5, consumer
	# power_status 0.5. ---
	var half_consumers: Array = [
		{
			"shouldConsumePower": true,
			"buffered": false,
			"usage": 10.0,
			"capacity": 0.0,
			"power_status": 0.0,
			"requested_power": 10.0,
			"delta": 1.0,
		},
	]
	var half: Dictionary = battery_distribution_state.distribute_power_state(half_consumers, 10.0, 5.0, false, 0.0)
	var half_updated: Array = half.get("consumers", [])
	proof["distribute_coverage_half"] = is_equal_approx(float(half.get("coverage", -1.0)), 0.5) and half_updated.size() == 1 and is_equal_approx(float(half_updated[0].get("power_status", -1.0)), 0.5)

	# --- coverage full: same consumer, needed 0.0, produced 5.0
	# -> coverage 1.0, status 1.0. ---
	var full: Dictionary = battery_distribution_state.distribute_power_state(half_consumers, 0.0, 5.0, false, 0.0)
	var full_updated: Array = full.get("consumers", [])
	proof["distribute_coverage_full"] = is_equal_approx(float(full.get("coverage", -1.0)), 1.0) and full_updated.size() == 1 and is_equal_approx(float(full_updated[0].get("power_status", -1.0)), 1.0)

	# --- buffered accumulate (PowerGraph.java:199-201): buffered
	# consumer (capacity 100.0, power_status 0.2, requested_power
	# 10.0, delta 1.0), needed 10.0, produced 5.0 -> coverage 0.5,
	# status clamp(0.2 + 10*0.5*1/100) = 0.25. ---
	var buffered_consumers: Array = [
		{
			"shouldConsumePower": true,
			"buffered": true,
			"usage": 0.0,
			"capacity": 100.0,
			"power_status": 0.2,
			"requested_power": 10.0,
			"delta": 1.0,
		},
	]
	var buffered: Dictionary = battery_distribution_state.distribute_power_state(buffered_consumers, 10.0, 5.0, false, 0.0)
	var buffered_updated: Array = buffered.get("consumers", [])
	proof["distribute_buffered_accumulates"] = is_equal_approx(float(buffered.get("coverage", -1.0)), 0.5) and buffered_updated.size() == 1 and is_equal_approx(float(buffered_updated[0].get("power_status", -1.0)), 0.25)

	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PowerStatusLiveProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
