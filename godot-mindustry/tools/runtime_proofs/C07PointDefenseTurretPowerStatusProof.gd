extends Node

const main_scene := preload("res://scenes/Main.tscn")
const point_defense_turret_build_state := preload("res://src/game/SourcePointDefenseTurretBuildState.gd")
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

	# --- Pure power row (N2151): ConsumePower.efficiency is
	# build.power.status (ConsumePower.java:39, `return build.
	# power.status;`), folded by the first pass
	# (BuildingComp.java:1969-1976) into the min efficiency; a
	# missing stamp folds to 1.0 before the first graph update,
	# the assembler fold (UnitAssembler.java:469, `float
	# powerStatus = !enabled ? 0f : power == null ? 1f :
	# power.status;`).
	var half_row: Dictionary = point_defense_turret_build_state.source_point_defense_turret_power_status_row_state({"power_status": 0.5}, true)
	proof["power_row_half"] = bool(half_row.get("has_power_row", false)) and is_equal_approx(float(half_row.get("row", {}).get("result", -1.0)), 0.5) and bool(half_row.get("row", {}).get("is_power", false))

	var no_consumer: Dictionary = point_defense_turret_build_state.source_point_defense_turret_power_status_row_state({"power_status": 0.5}, false)
	proof["power_row_absent_without_consumer"] = bool(no_consumer.get("has_power_row", true)) == false

	var null_row: Dictionary = point_defense_turret_build_state.source_point_defense_turret_power_status_row_state({}, true)
	proof["power_row_null_folds_one"] = bool(null_row.get("has_power_row", false)) and is_equal_approx(float(null_row.get("row", {}).get("result", -1.0)), 1.0) and bool(null_row.get("row", {}).get("is_power", false))

	# --- Live tick: segment is a PointDefenseTurret with a power
	# consumer (consumePower 8f), placed live; the tick driver is
	# called directly (as the N2147/N2148/N2149/N2150 proofs do),
	# not simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is already
	# proven by N2142. The point-defense tick models no other
	# consumers, so with a power consumer the first pass holds only
	# the power row.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	proof["segment_has_power_consumer"] = bool(blocks_by_id["segment"].properties.has("consumePower"))

	var segment_cell := Vector2i(28, 20)
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["segment"], segment_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	point_defense_turret_build_state.source_point_defense_turret_bind_frame_state(segment, blocks_by_id["segment"])
	var segment_frame: Dictionary = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})

	# One wiring tick first: the driver stamps team_id onto
	# the frame, so the proof can seed a live enemy target
	# (team_id + 1). Since N2241 the consumption branch gates
	# on shouldConsume() (`enabled && target != null`,
	# PointDefenseTurret.java:105-107): with no live target
	# the segment consumes nothing and efficiency folds to 0,
	# exactly like Java with no target in range
	# (BuildingComp.java:1947). The stamped target survives
	# the ticks below -- the driver only re-acquires when the
	# frame carries observed_bullets (the N2190 finding), and
	# this frame carries none -- so should_consume stays true
	# and efficiency folds the power min again.
	segment_frame["power_status"] = 1.0
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	segment_frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var segment_team: int = int(segment_frame.get("team_id", 1))
	segment_frame["target"] = {"id": 1, "team": segment_team + 1, "hittable": true, "has_type": true, "damage": 100.0, "x": segment.position.x + 10.0, "y": segment.position.y}

	# Half power: efficiency folds the power min 0.5.
	segment_frame["power_status"] = 0.5
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	segment_frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_min"] = is_equal_approx(float(segment_frame.get("efficiency", -1.0)), 0.5)

	# No power: efficiency 0.
	segment_frame["power_status"] = 0.0
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	segment_frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	proof["efficiency_zero_at_no_power"] = is_equal_approx(float(segment_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PointDefenseTurretPowerStatusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
