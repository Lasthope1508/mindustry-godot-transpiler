extends Node

const main_scene := preload("res://scenes/Main.tscn")
const impact_reactor_build_state := preload("res://src/game/SourceImpactReactorBuildState.gd")
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

	# --- Pure updateTile advance (N2192):
	# ImpactReactorBuild.updateTile() (ImpactReactor.java:78-101)
	# advances the warmup AFTER updateConsumption
	# (BuildingComp.java:2274/:2277) and only while enabled
	# (BuildingComp.java:2276, `if(enabled ||
	# !block.noUpdateDisabled){`, default false, Block.java:170).
	# While the gate holds (`if(efficiency >= 0.9999f &&
	# power.status >= 0.99f){`, ImpactReactor.java:79) the warmup
	# lerps toward 1 (`warmup = Mathf.lerpDelta(warmup, 1f,
	# warmupSpeed * timeScale);`, ImpactReactor.java:82,
	# warmupSpeed 0.001f class default, ImpactReactor.java:19,
	# NOT overridden by the single impact-reactor def,
	# Blocks.java:2632-2645) and snaps (`if(Mathf.equal(warmup,
	# 1f, 0.001f)){`, ImpactReactor.java:83, with `warmup = 1f;`,
	# ImpactReactor.java:84); otherwise it decays (`warmup =
	# Mathf.lerpDelta(warmup, 0f, 0.01f);`,
	# ImpactReactor.java:95). Either way `totalProgress +=
	# warmup * Time.delta;` (ImpactReactor.java:98) and
	# `productionEfficiency = Mathf.pow(warmup, 5f);`
	# (ImpactReactor.java:100). Mathf.lerpDelta is `return
	# lerp(fromValue, toValue, clamp(progress * Time.delta));`
	# (Mathf.java:430-431); Mathf.equal is `return Math.abs(a -
	# b) <= tolerance;` (Mathf.java:554-555). Time.delta is the
	# frame delta in 60fps ticks, so the pure calls below pass
	# source_delta 1.0 for one tick. DEFERRED, not proven here:
	# the first-production event (`Events.fire(Trigger.
	# impactPower);`, ImpactReactor.java:88) and the consume
	# timer (`if(timer(timerUse, itemDuration / timeScale)){`,
	# ImpactReactor.java:91, with `consume();`,
	# ImpactReactor.java:92).

	# Gate held, warmup 0: one tick lerps 0 toward 1 by
	# clamp(0.001 * 1.0 * 1.0) = 0.001.
	var rise: Dictionary = impact_reactor_build_state.source_impact_reactor_update_tile_advance_state({"efficiency": 1.0, "power_status": 1.0, "warmup": 0.0, "total_progress": 0.0}, 1.0, 1.0)
	proof["warmup_rises_toward_one"] = is_equal_approx(float(rise.get("warmup", -1.0)), 0.001)

	# Gate held, warmup 0.9995: the lerp lands at 0.9995005,
	# within 0.001 of 1, so the snap fires and warmup is 1.
	var snap: Dictionary = impact_reactor_build_state.source_impact_reactor_update_tile_advance_state({"efficiency": 1.0, "power_status": 1.0, "warmup": 0.9995, "total_progress": 0.0}, 1.0, 1.0)
	proof["warmup_snaps_to_one"] = is_equal_approx(float(snap.get("warmup", -1.0)), 1.0)

	# Gate failed (power.status 0.5), warmup 0.5: one tick
	# decays 0.5 toward 0 by clamp(0.01 * 1.0) = 0.495.
	var decay: Dictionary = impact_reactor_build_state.source_impact_reactor_update_tile_advance_state({"efficiency": 1.0, "power_status": 0.5, "warmup": 0.5, "total_progress": 0.0}, 1.0, 1.0)
	proof["warmup_decays_toward_zero"] = is_equal_approx(float(decay.get("warmup", -1.0)), 0.495)

	# Gate held, warmup 0.5, totalProgress 10.0: warmup lands
	# at 0.5005, so totalProgress advances by 0.5005 * 1.0.
	var progress: Dictionary = impact_reactor_build_state.source_impact_reactor_update_tile_advance_state({"efficiency": 1.0, "power_status": 1.0, "warmup": 0.5, "total_progress": 10.0}, 1.0, 1.0)
	proof["total_progress_advances"] = is_equal_approx(float(progress.get("warmup", -1.0)), 0.5005) and is_equal_approx(float(progress.get("total_progress", -1.0)), 10.5005)

	# productionEfficiency is pow(warmup, 5f): the decayed
	# warmup 0.495 gives 0.495^5 = 0.029718439059375, and a
	# fully warm reactor gives 1.0.
	var full: Dictionary = impact_reactor_build_state.source_impact_reactor_update_tile_advance_state({"efficiency": 1.0, "power_status": 1.0, "warmup": 1.0, "total_progress": 0.0}, 1.0, 1.0)
	proof["production_efficiency_pow_five"] = is_equal_approx(float(decay.get("production_efficiency", -1.0)), 0.029718439059375) and is_equal_approx(float(full.get("production_efficiency", -1.0)), 1.0)

	# --- Live tick: the impact reactor is an ImpactReactor build
	# with a static power consumer (impact-reactor,
	# consumePower 25f, Blocks.java:2642), placed live; the tick
	# driver is called directly (as the N2182 proof does), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. At half power the folded
	# efficiency is 0.5 (the N2182 behaviour, kept); at full
	# power the gate holds, efficiency folds 1.0, and one tick
	# (1/60s = 1.0 Time.delta) advances the warmup from 0 to
	# 0.001, totalProgress from 0 to 0.001, and
	# productionEfficiency to pow(0.001, 5).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var impact_reactor_cell := Vector2i(30, 21)
	var impact_reactor := Sprite2D.new()
	game.add_child(impact_reactor)
	game.call("record_placed_block", impact_reactor, blocks_by_id["impact-reactor"], impact_reactor_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	impact_reactor_build_state.source_impact_reactor_bind_frame_state(impact_reactor, blocks_by_id["impact-reactor"])
	var impact_reactor_frame: Dictionary = impact_reactor.get_meta(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_BUILDING_META_KEY, {})

	# N2266: the required blast-compound row folds 0.0 on an
	# empty frame, so seed 1 blast-compound before ticking.
	# The timer needs 140 ticks to fire, so the single seed
	# survives both ticks below.
	impact_reactor_frame["items"] = {"blast-compound": 1}

	# Half power: efficiency folds the power min 0.5, and the
	# gate fails, so the warmup stays 0.
	impact_reactor_frame["power_status"] = 0.5
	impact_reactor_build_state.source_impact_reactor_tick_buildings_state(game, 1.0 / 60.0)
	impact_reactor_frame = impact_reactor.get_meta(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_BUILDING_META_KEY, {})
	var half_power_ok: bool = is_equal_approx(float(impact_reactor_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(impact_reactor_frame.get("warmup", -1.0)), 0.0)

	# Full power: efficiency folds 1.0, the gate holds, and the
	# warmup advances one tick from 0 to 0.001.
	impact_reactor_frame["power_status"] = 1.0
	impact_reactor_build_state.source_impact_reactor_tick_buildings_state(game, 1.0 / 60.0)
	impact_reactor_frame = impact_reactor.get_meta(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_BUILDING_META_KEY, {})
	var full_power_ok: bool = is_equal_approx(float(impact_reactor_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(impact_reactor_frame.get("warmup", -1.0)), 0.001) and is_equal_approx(float(impact_reactor_frame.get("total_progress", -1.0)), 0.001) and is_equal_approx(float(impact_reactor_frame.get("production_efficiency", -1.0)), 0.000000000000001)
	proof["live_tick_keeps_power_row_and_advances"] = half_power_ok and full_power_ok

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ImpactReactorUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
