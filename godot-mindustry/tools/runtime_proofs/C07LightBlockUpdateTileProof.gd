extends Node

const main_scene := preload("res://scenes/Main.tscn")
const light_block_build_state := preload("res://src/game/SourceLightBlockBuildState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
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

	# --- Pure smoothTime advance (N2189/N2241, unification):
	# LightBuild.updateTile()
	# does exactly one thing (LightBlock.java:104-106, `smoothTime
	# = Mathf.lerpDelta(smoothTime, timeScale, 0.1f);`), with
	# lerpDelta the Arc delta-corrected lerp (Mathf.java:430-432,
	# `return lerp(fromValue, toValue, clamp(progress *
	# Time.delta));`); Time.delta is the frame delta in 60fps
	# ticks (Time.java:26), so one tick at 60fps is source_delta
	# 1.0. smoothTime starts at 1f (LightBlock.java:69), and
	# drawLight clamps it (LightBlock.java:127-128, `Drawf.light
	# (x, y, lightRadius * Math.min(smoothTime, 2f), Tmp.c1.set
	# (color), brightness * efficiency);`) -- the pure advance
	# returns both the advanced smooth_time and the
	# light_radius_scale min(smooth_time, 2f).
	var one_step: Dictionary = light_block_build_state.source_light_block_smooth_time_state(1.0, 2.0, 1.0)
	proof["smooth_time_lerp_delta_step"] = is_equal_approx(float(one_step.get("smooth_time", -1.0)), 1.1) and is_equal_approx(float(one_step.get("light_radius_scale", -1.0)), 1.1)

	var held: Dictionary = light_block_build_state.source_light_block_smooth_time_state(1.0, 1.0, 1.0)
	proof["smooth_time_holds_at_time_scale"] = is_equal_approx(float(held.get("smooth_time", -1.0)), 1.0) and is_equal_approx(float(held.get("light_radius_scale", -1.0)), 1.0)

	var decayed: Dictionary = light_block_build_state.source_light_block_smooth_time_state(2.0, 1.0, 1.0)
	proof["smooth_time_decays_when_time_scale_drops"] = is_equal_approx(float(decayed.get("smooth_time", -1.0)), 1.9)

	var converged := 1.0
	for iteration in range(60):
		converged = float(light_block_build_state.source_light_block_smooth_time_state(converged, 2.0, 1.0).get("smooth_time", -1.0))
	proof["smooth_time_converges_after_ticks"] = converged > 1.99 and converged <= 2.0

	var clamped: Dictionary = light_block_build_state.source_light_block_smooth_time_state(3.0, 3.0, 1.0)
	var unclamped: Dictionary = light_block_build_state.source_light_block_smooth_time_state(1.5, 1.5, 1.0)
	proof["light_radius_clamps_at_two"] = is_equal_approx(float(clamped.get("light_radius_scale", -1.0)), 2.0) and is_equal_approx(float(unclamped.get("light_radius_scale", -1.0)), 1.5)

	# --- Live tick: the illuminator is a LightBlock build
	# with a static power consumer (illuminator,
	# consumePower 0.05f, Blocks.java:6767), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/
	# N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169/N2170/N2171/
	# N2172/N2173/N2174/N2175/N2176/N2177/N2178/N2179/N2180/N2181/
	# N2182/N2183/N2184/N2185 proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. The bound
	# frame carries the Java initial smoothTime 1f
	# (LightBlock.java:69) -- NOT 0f: the scope brief's "0f"
	# guess is corrected by grep at RED, so the frame-defaults
	# key checks 1.0. The driver advances smooth_time every tick
	# toward the live sprite time_scale (BuildingComp.java:98,
	# default 1f), converting its seconds argument to Time.delta
	# ticks (seconds * 60, the N2093 pump / conveyor precedent)
	# -- so one 1/60s tick with time_scale 2.0 moves smooth_time
	# from 1.0 to 1.1. The updateTile gate (BuildingComp.java:2276)
	# always runs for a LightBlock (noUpdateDisabled defaults
	# false, Block.java:170), so the advance is unconditional.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var light_block_cell := Vector2i(30, 21)
	var light_block := Sprite2D.new()
	game.add_child(light_block)
	game.call("record_placed_block", light_block, blocks_by_id["illuminator"], light_block_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	light_block_build_state.source_light_block_bind_frame_state(light_block, blocks_by_id["illuminator"])
	var light_block_frame: Dictionary = light_block.get_meta(light_block_build_state.SOURCE_LIGHT_BLOCK_BUILDING_META_KEY, {})

	proof["frame_defaults_to_java_initial"] = light_block_frame.has("smooth_time") and is_equal_approx(float(light_block_frame.get("smooth_time", -1.0)), 1.0)

	# Raise the live time_scale to 2.0 and tick once at 1/60s:
	# smooth_time advances 1.0 -> 1.1, and the N2185 power.status
	# fold is unchanged (efficiency 0.5 from the stamped
	# power_status). This key carries no drawLight / color /
	# config claim -- drawLight presentation
	# (LightBlock.java:127-128) and the color config
	# (LightBlock.java:35, 72-94, 109-127) wait for their own
	# slices.
	light_block.set_meta(placed_block_state.SOURCE_BLOCK_TIME_SCALE_META_KEY, 2.0)
	light_block_frame["power_status"] = 0.5
	light_block_build_state.source_light_block_tick_buildings_state(game, 1.0 / 60.0)
	light_block_frame = light_block.get_meta(light_block_build_state.SOURCE_LIGHT_BLOCK_BUILDING_META_KEY, {})
	proof["live_tick_writes_advance_frame_keys"] = is_equal_approx(float(light_block_frame.get("smooth_time", -1.0)), 1.1) and is_equal_approx(float(light_block_frame.get("efficiency", -1.0)), 0.5)

	# The N2185 power.status behavior is unchanged: the pure row
	# still reads the stamped frame value, and the same live tick
	# still folds the power min into the efficiency. This key
	# carries no drawLight / color / config claim -- drawLight
	# presentation (LightBlock.java:127-128) and the color config
	# (LightBlock.java:35, 72-94, 109-127) wait for their own
	# slices; the radius clamp is what the light_radius_scale
	# key proves.
	var half_row: Dictionary = light_block_build_state.source_light_block_power_status_row_state({"power_status": 0.5}, true)
	proof["power_status_row_unchanged"] = bool(half_row.get("has_power_row", false)) and is_equal_approx(float(half_row.get("row", {}).get("result", -1.0)), 0.5) and bool(half_row.get("row", {}).get("is_power", false)) and is_equal_approx(float(light_block_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LightBlockUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
