extends Node

const main_scene := preload("res://scenes/Main.tscn")
const tractor_beam_turret_build_state := preload("res://src/game/SourceTractorBeamTurretBuildState.gd")
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

	# --- Pure power row (N2152): ConsumePower.efficiency is
	# build.power.status (ConsumePower.java:39, `return build.
	# power.status;`), folded by the first pass
	# (BuildingComp.java:1969-1976) into the min efficiency; a
	# missing stamp folds to 1.0 before the first graph update,
	# the assembler fold (UnitAssembler.java:469, `float
	# powerStatus = !enabled ? 0f : power == null ? 1f :
	# power.status;`).
	var half_row: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_power_status_row_state({"power_status": 0.5}, true)
	proof["power_row_half"] = bool(half_row.get("has_power_row", false)) and is_equal_approx(float(half_row.get("row", {}).get("result", -1.0)), 0.5) and bool(half_row.get("row", {}).get("is_power", false))

	var no_consumer: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_power_status_row_state({"power_status": 0.5}, false)
	proof["power_row_absent_without_consumer"] = bool(no_consumer.get("has_power_row", true)) == false

	var null_row: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_power_status_row_state({}, true)
	proof["power_row_null_folds_one"] = bool(null_row.get("has_power_row", false)) and is_equal_approx(float(null_row.get("row", {}).get("result", -1.0)), 1.0) and bool(null_row.get("row", {}).get("is_power", false))

	# --- Live tick: parallax is a TractorBeamTurret with a power
	# consumer (consumePower 3.3f), placed live; the tick driver is
	# called directly (as the N2147/N2148/N2149/N2150 proofs do),
	# not simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is already
	# proven by N2142. The tractor-beam tick models no other
	# consumers, so with a power consumer the first pass holds only
	# the power row.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	proof["parallax_has_power_consumer"] = bool(blocks_by_id["parallax"].properties.has("consumePower"))

	var parallax_cell := Vector2i(28, 20)
	var parallax := Sprite2D.new()
	game.add_child(parallax)
	game.call("record_placed_block", parallax, blocks_by_id["parallax"], parallax_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	tractor_beam_turret_build_state.source_tractor_beam_turret_bind_frame_state(parallax, blocks_by_id["parallax"])
	var parallax_frame: Dictionary = parallax.get_meta(tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, {})

	# Half power: efficiency folds the power min 0.5.
	parallax_frame["power_status"] = 0.5
	tractor_beam_turret_build_state.source_tractor_beam_turret_tick_buildings_state(game, 1.0 / 60.0)
	parallax_frame = parallax.get_meta(tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_min"] = is_equal_approx(float(parallax_frame.get("efficiency", -1.0)), 0.5)

	# No power: efficiency 0.
	parallax_frame["power_status"] = 0.0
	tractor_beam_turret_build_state.source_tractor_beam_turret_tick_buildings_state(game, 1.0 / 60.0)
	parallax_frame = parallax.get_meta(tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, {})
	proof["efficiency_zero_at_no_power"] = is_equal_approx(float(parallax_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TractorBeamTurretPowerStatusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
