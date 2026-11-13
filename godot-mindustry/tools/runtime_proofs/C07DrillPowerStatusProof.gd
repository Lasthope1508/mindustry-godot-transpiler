extends Node

const main_scene := preload("res://scenes/Main.tscn")
const drill_build_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const placed_state := preload("res://src/game/SourcePlacedBlockState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	# --- Pure power row (N2147): ConsumePower.efficiency is
	# build.power.status (ConsumePower.java:39, `return build.
	# power.status;`), folded by the first pass
	# (BuildingComp.java:1969-1976) into the min efficiency; a
	# missing stamp folds to 1.0 before the first graph update,
	# the assembler fold (UnitAssembler.java:469, `float
	# powerStatus = !enabled ? 0f : power == null ? 1f :
	# power.status;`).
	var half_row: Dictionary = drill_build_state.source_drill_power_status_row_state({"power_status": 0.5}, true)
	proof["power_row_half"] = bool(half_row.get("has_power_row", false)) and is_equal_approx(float(half_row.get("row", {}).get("result", -1.0)), 0.5) and bool(half_row.get("row", {}).get("is_power", false))

	var no_consumer: Dictionary = drill_build_state.source_drill_power_status_row_state({"power_status": 0.5}, false)
	proof["power_row_absent_without_consumer"] = bool(no_consumer.get("has_power_row", true)) == false

	var null_row: Dictionary = drill_build_state.source_drill_power_status_row_state({}, true)
	proof["power_row_null_folds_one"] = bool(null_row.get("has_power_row", false)) and is_equal_approx(float(null_row.get("row", {}).get("result", -1.0)), 1.0) and bool(null_row.get("row", {}).get("is_power", false))

	# --- Live tick: the laser-drill is a base Drill with a power
	# consumer (consumePower 1.1), placed live on copper ore so
	# should_consume is true; the tick driver is called directly
	# (as the N2146 proof does), not simulate_factory, so the
	# graph update does not overwrite the stamped power_status --
	# the write-back itself is already proven by N2142. The
	# laser-drill's water booster is optional, so with no water
	# the first pass holds only the power row.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	proof["laser_has_power_consumer"] = bool(blocks_by_id["laser-drill"].properties.has("consumePower"))

	var laser_cell := Vector2i(28, 20)
	var laser := Sprite2D.new()
	game.add_child(laser)
	var terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
	for occupied in game.call("occupied_cells", laser_cell, blocks_by_id["laser-drill"]):
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, catalog.get_by_id("ore-copper"), false)
	game.call("record_placed_block", laser, blocks_by_id["laser-drill"], laser_cell)
	# Bind the frame + dominant item from the ore under the
	# footprint: the overlay mutation binds proximity only when a
	# sprite is already on the cell, and the overlays were set
	# before placement, so bind explicitly here.
	drill_build_state.source_on_proximity_update_state(game, laser, blocks_by_id["laser-drill"])
	var laser_frame: Dictionary = laser.get_meta(drill_build_state.SOURCE_DRILL_BUILDING_META_KEY, {})

	# Half power: efficiency folds the power min 0.5.
	laser_frame["power_status"] = 0.5
	drill_build_state.source_tick_state(game, 1.0 / 60.0)
	laser_frame = laser.get_meta(drill_build_state.SOURCE_DRILL_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_min"] = is_equal_approx(float(laser_frame.get("efficiency", -1.0)), 0.5)

	# No power: efficiency 0.
	laser_frame["power_status"] = 0.0
	drill_build_state.source_tick_state(game, 1.0 / 60.0)
	laser_frame = laser.get_meta(drill_build_state.SOURCE_DRILL_BUILDING_META_KEY, {})
	proof["efficiency_zero_at_no_power"] = is_equal_approx(float(laser_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillPowerStatusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
