extends Node

const main_scene := preload("res://scenes/Main.tscn")
const overdrive_projector_build_state := preload("res://src/game/SourceOverdriveProjectorBuildState.gd")
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

	# --- Pure updateTile advance (N2194): OverdriveBuild.updateTile()
	# (OverdriveProjector.java:97-120). The lerps are Arc's lerpDelta
	# (Mathf.java:430-432, `return lerp(fromValue, toValue,
	# clamp(progress * Time.delta));`); source_delta is Time.delta
	# in ticks (seconds * 60, game_source_delta), so one tick at
	# source_delta 1.0 moves smoothEfficiency 8% toward efficiency
	# and heat 8% toward 1-or-0.
	var half_advance: Dictionary = overdrive_projector_build_state.source_overdrive_projector_update_tile_advance_state({"efficiency": 0.5, "optional_efficiency": 0.5, "smooth_efficiency": 0.0, "heat": 0.0, "charge": 0.0, "phase_heat": 0.0, "use_progress": 0.0}, 1.0, 1.0, true, 60.0, 400.0)
	var half_advanced: Dictionary = half_advance.get("advanced", {})
	var dark_advance: Dictionary = overdrive_projector_build_state.source_overdrive_projector_update_tile_advance_state({"efficiency": 0.0, "optional_efficiency": 0.0, "smooth_efficiency": 0.5, "heat": 1.0, "charge": 0.0, "phase_heat": 0.0, "use_progress": 0.0}, 1.0, 1.0, true, 60.0, 400.0)
	var dark_advanced: Dictionary = dark_advance.get("advanced", {})
	proof["smooth_efficiency_heat_lerp_toward_efficiency"] = is_equal_approx(float(half_advanced.get("smooth_efficiency", -1.0)), 0.04) and is_equal_approx(float(half_advanced.get("heat", -1.0)), 0.08) and is_equal_approx(float(dark_advanced.get("smooth_efficiency", -1.0)), 0.46) and is_equal_approx(float(dark_advanced.get("heat", -1.0)), 0.92)

	# --- Charge advances on raw Time.delta (NOT delta(): `charge +=
	# heat * Time.delta;`, OverdriveProjector.java:100 -- unlike
	# MendProjector's `charge += heat * delta();`), so timeScale
	# never scales the charge; at reload the charge resets to 0
	# BEFORE the indexer scan (OverdriveProjector.java:111-112),
	# so the reset does not depend on finding a target. The boost
	# application itself (OverdriveProjector.java:113) is
	# deferred: the proof asserts only the reset, never a boosted
	# target.
	var charge_advance: Dictionary = overdrive_projector_build_state.source_overdrive_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 1.0, "smooth_efficiency": 0.0, "heat": 0.0, "charge": 10.0, "phase_heat": 0.0, "use_progress": 0.0}, 1.0, 2.0, true, 60.0, 400.0)
	var charge_advanced: Dictionary = charge_advance.get("advanced", {})
	var charge_reset: Dictionary = overdrive_projector_build_state.source_overdrive_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 1.0, "smooth_efficiency": 0.0, "heat": 1.0, "charge": 59.5, "phase_heat": 0.0, "use_progress": 0.0}, 1.0, 1.0, true, 60.0, 400.0)
	var charge_reset_advanced: Dictionary = charge_reset.get("advanced", {})
	proof["charge_advances_and_resets_at_reload"] = is_equal_approx(float(charge_advanced.get("charge", -1.0)), 10.08) and bool(charge_advance.get("charge_ready", true)) == false and is_equal_approx(float(charge_reset_advanced.get("charge", -1.0)), 0.0) and bool(charge_reset.get("charge_ready", false))

	# --- phaseHeat lerps toward optionalEfficiency when hasBoost
	# (OverdriveProjector.java:102-104).
	var phase_advance: Dictionary = overdrive_projector_build_state.source_overdrive_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 1.0, "smooth_efficiency": 0.0, "heat": 0.0, "charge": 0.0, "phase_heat": 0.0, "use_progress": 0.0}, 1.0, 1.0, true, 60.0, 400.0)
	var phase_advanced: Dictionary = phase_advance.get("advanced", {})
	var phase_partial: Dictionary = overdrive_projector_build_state.source_overdrive_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 1.0, "smooth_efficiency": 0.0, "heat": 0.0, "charge": 0.0, "phase_heat": 0.5, "use_progress": 0.0}, 1.0, 1.0, true, 60.0, 400.0)
	var phase_partial_advanced: Dictionary = phase_partial.get("advanced", {})
	proof["phase_heat_lerps_when_has_boost"] = is_equal_approx(float(phase_advanced.get("phase_heat", -1.0)), 0.1) and is_equal_approx(float(phase_partial_advanced.get("phase_heat", -1.0)), 0.55)

	# --- phaseHeat does NOT move when hasBoost is false: the
	# overdrive-dome sets hasBoost = false (Blocks.java:1960),
	# useTime 300f (Blocks.java:1958), while the overdrive-
	# projector keeps hasBoost true and useTime 400f -- per-def
	# catalog values, read through
	# SourceOverdriveProjectorState's accessors.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var dome_advance: Dictionary = overdrive_projector_build_state.source_overdrive_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 1.0, "smooth_efficiency": 0.0, "heat": 0.0, "charge": 0.0, "phase_heat": 0.3, "use_progress": 0.0}, 1.0, 1.0, false, 60.0, 300.0)
	var dome_advanced: Dictionary = dome_advance.get("advanced", {})
	proof["phase_heat_frozen_without_boost"] = is_equal_approx(float(dome_advanced.get("phase_heat", -1.0)), 0.3) and bool(blocks_by_id["overdrive-dome"].properties.get("hasBoost", true)) == false and is_equal_approx(float(blocks_by_id["overdrive-dome"].properties.get("useTime", -1.0)), 300.0) and bool(blocks_by_id["overdrive-projector"].properties.get("hasBoost", false)) and is_equal_approx(float(blocks_by_id["overdrive-projector"].properties.get("useTime", -1.0)), 400.0)

	# --- useProgress advances on delta() = Time.delta * timeScale
	# (BuildingComp.java:1922-1924) only when efficiency > 0, and
	# wraps at useTime (OverdriveProjector.java:116-120); the wrap
	# is unconditional arithmetic in the branch -- consume()
	# returns void, so nothing gates it on consume's outcome --
	# while the consume() item side effect itself is deferred.
	var use_advance: Dictionary = overdrive_projector_build_state.source_overdrive_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 1.0, "smooth_efficiency": 0.0, "heat": 0.0, "charge": 0.0, "phase_heat": 0.0, "use_progress": 10.0}, 1.0, 2.0, true, 60.0, 400.0)
	var use_advanced: Dictionary = use_advance.get("advanced", {})
	var use_wrap: Dictionary = overdrive_projector_build_state.source_overdrive_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 1.0, "smooth_efficiency": 0.0, "heat": 0.0, "charge": 0.0, "phase_heat": 0.0, "use_progress": 399.0}, 1.0, 1.0, true, 60.0, 400.0)
	var use_wrap_advanced: Dictionary = use_wrap.get("advanced", {})
	var use_dark: Dictionary = overdrive_projector_build_state.source_overdrive_projector_update_tile_advance_state({"efficiency": 0.0, "optional_efficiency": 0.0, "smooth_efficiency": 0.0, "heat": 0.0, "charge": 0.0, "phase_heat": 0.0, "use_progress": 10.0}, 1.0, 1.0, true, 60.0, 400.0)
	var use_dark_advanced: Dictionary = use_dark.get("advanced", {})
	proof["use_progress_advances_and_wraps"] = is_equal_approx(float(use_advanced.get("use_progress", -1.0)), 12.0) and bool(use_advance.get("use_ready", true)) == false and is_equal_approx(float(use_wrap_advanced.get("use_progress", -1.0)), 0.0) and bool(use_wrap.get("use_ready", false)) and is_equal_approx(float(use_dark_advanced.get("use_progress", -1.0)), 10.0)

	# --- Live tick: the overdrive-projector is an OverdriveProjector with a power
	# consumer (consumePower 3.50f), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/N2150/
	# N2153/N2154/N2155/N2156/N2157 proofs do), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. Half power:
	# efficiency folds the power min 0.5 (the N2157 behaviour,
	# preserved), and the frame advances one tick from its bound
	# zeros: smoothEfficiency 0.04, heat 0.08, charge 0.08,
	# phaseHeat 0.05 (optionalEfficiency folds to the min 0.5),
	# useProgress 1.0.
	var projector_cell := Vector2i(28, 20)
	var projector := Sprite2D.new()
	game.add_child(projector)
	game.call("record_placed_block", projector, blocks_by_id["overdrive-projector"], projector_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	overdrive_projector_build_state.source_overdrive_projector_bind_frame_state(projector, blocks_by_id["overdrive-projector"])
	var projector_frame: Dictionary = projector.get_meta(overdrive_projector_build_state.SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY, {})

	# Phase-fabric fuels the later optional row required by this boosted scenario.
	projector_frame["items"] = {"phase-fabric": 1}
	projector_frame["power_status"] = 0.5
	overdrive_projector_build_state.source_overdrive_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(overdrive_projector_build_state.SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY, {})
	proof["live_tick_advances_frame_and_preserves_power"] = is_equal_approx(float(projector_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(projector_frame.get("smooth_efficiency", -1.0)), 0.04) and is_equal_approx(float(projector_frame.get("heat", -1.0)), 0.08) and is_equal_approx(float(projector_frame.get("charge", -1.0)), 0.08) and is_equal_approx(float(projector_frame.get("phase_heat", -1.0)), 0.05) and is_equal_approx(float(projector_frame.get("use_progress", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07OverdriveProjectorUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
