extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mend_projector_build_state := preload("res://src/game/SourceMendProjectorBuildState.gd")
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

	# --- Pure updateTile advance (N2193): MendBuild.updateTile()
	# (MendProjector.java:94-120) -- the smoothEfficiency /
	# heat lerps (0.08f), the charge advance
	# (`charge += heat * delta();`), the phaseHeat lerp (0.1f
	# toward optionalEfficiency), and the charge reset
	# (`charge = 0f;`) inside the `charge >= reload` branch,
	# which sits BEFORE the indexer scan. The lerps use the
	# UNSCALED Time.delta (Arc Mathf.java:430-432, `return
	# lerp(fromValue, toValue, clamp(progress *
	# Time.delta));`); only the charge advance uses the
	# SCALED delta() (`return Time.delta * timeScale;`,
	# BuildingComp.java:1922-1924). All pure calls below use
	# time_delta 1.0 (one tick at 60fps) and the mender
	# reload 200f (Blocks.java:1923) unless noted.
	var smooth_frame: Dictionary = mend_projector_build_state.source_mend_projector_update_tile_advance_state({"smooth_efficiency": 0.0, "efficiency": 0.5}, 200.0, 1.0)
	proof["smooth_efficiency_lerps_to_efficiency"] = is_equal_approx(float(smooth_frame.get("smooth_efficiency", -1.0)), 0.04)

	var heat_powered: Dictionary = mend_projector_build_state.source_mend_projector_update_tile_advance_state({"heat": 0.0, "efficiency": 0.5}, 200.0, 1.0)
	var heat_suppressed: Dictionary = mend_projector_build_state.source_mend_projector_update_tile_advance_state({"heat": 1.0, "efficiency": 0.5}, 200.0, 1.0, 1.0, false)
	var heat_unpowered: Dictionary = mend_projector_build_state.source_mend_projector_update_tile_advance_state({"heat": 1.0, "efficiency": 0.0}, 200.0, 1.0)
	proof["heat_lerps_by_efficiency_and_can_heal"] = is_equal_approx(float(heat_powered.get("heat", -1.0)), 0.08) and is_equal_approx(float(heat_suppressed.get("heat", -1.0)), 0.92) and is_equal_approx(float(heat_unpowered.get("heat", -1.0)), 0.92)

	var charge_frame: Dictionary = mend_projector_build_state.source_mend_projector_update_tile_advance_state({"heat": 1.0, "charge": 10.0, "efficiency": 1.0}, 200.0, 1.0)
	var charge_scaled: Dictionary = mend_projector_build_state.source_mend_projector_update_tile_advance_state({"heat": 1.0, "charge": 10.0, "efficiency": 1.0}, 200.0, 1.0, 2.0)
	proof["charge_advances_by_heat_delta"] = is_equal_approx(float(charge_frame.get("charge", -1.0)), 11.0) and is_equal_approx(float(charge_scaled.get("charge", -1.0)), 12.0)

	var reset_frame: Dictionary = mend_projector_build_state.source_mend_projector_update_tile_advance_state({"heat": 1.0, "charge": 199.5, "efficiency": 1.0}, 200.0, 1.0)
	var no_reset_suppressed: Dictionary = mend_projector_build_state.source_mend_projector_update_tile_advance_state({"heat": 1.0, "charge": 199.5, "efficiency": 1.0}, 200.0, 1.0, 1.0, false)
	proof["charge_resets_at_reload"] = is_equal_approx(float(reset_frame.get("charge", -1.0)), 0.0) and float(no_reset_suppressed.get("charge", -1.0)) > 199.5

	var phase_frame: Dictionary = mend_projector_build_state.source_mend_projector_update_tile_advance_state({"phase_heat": 0.0, "optional_efficiency": 0.5}, 200.0, 1.0)
	var phase_zero: Dictionary = mend_projector_build_state.source_mend_projector_update_tile_advance_state({"phase_heat": 1.0, "optional_efficiency": 0.0}, 200.0, 1.0)
	proof["phase_heat_lerps_to_optional_efficiency"] = is_equal_approx(float(phase_frame.get("phase_heat", -1.0)), 0.05) and is_equal_approx(float(phase_zero.get("phase_heat", -1.0)), 0.9)

	# --- Live tick: the mender is a MendProjector with a power
	# consumer (consumePower 0.3f), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/N2150/
	# N2153/N2154/N2155/N2156 proofs do), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. Half power:
	# efficiency folds the power min 0.5 (the N2156
	# power.status behaviour, preserved), and the live advance
	# follows it: smoothEfficiency 0 -> 0.04 toward 0.5, heat
	# 0 -> 0.08 toward 1, charge 0 -> 0.08 by the new heat.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var projector_cell := Vector2i(28, 20)
	var projector := Sprite2D.new()
	game.add_child(projector)
	game.call("record_placed_block", projector, blocks_by_id["mender"], projector_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	mend_projector_build_state.source_mend_projector_bind_frame_state(projector, blocks_by_id["mender"])
	var projector_frame: Dictionary = projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})

	projector_frame["power_status"] = 0.5
	mend_projector_build_state.source_mend_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_min"] = is_equal_approx(float(projector_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(projector_frame.get("smooth_efficiency", -1.0)), 0.04) and is_equal_approx(float(projector_frame.get("charge", -1.0)), 0.08)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MendProjectorUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
