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

	# --- Pure item row (N2263): ConsumeItems.efficiency is
	# BINARY 1/0 (ConsumeItems.java:51-53, `return build.
	# consumeTriggerValid() || build.items.has(items,
	# multiplier.get(build)) ? 1f : 0f;`), 1.0 exactly when
	# every stack is held (ItemModule.java:153-156); the
	# trigger-valid half is the base false (BuildingComp.
	# java:764-766) and the multiplier is the Consume default
	# 1f (Consume.java:18). Mender stacks silicon 1
	# (Blocks.java:1929), mend-projector stacks phaseFabric 1
	# (Blocks.java:1941).
	var mender_stacks: Array = [{"item": "silicon", "amount": 1}]
	var mender_full: Dictionary = mend_projector_build_state.source_mend_projector_item_consumer_row_state({"items": {"silicon": 1}}, mender_stacks)
	var mender_empty: Dictionary = mend_projector_build_state.source_mend_projector_item_consumer_row_state({"items": {}}, mender_stacks)
	proof["mender_row_binary_silicon"] = bool(mender_full.get("has_item_row", false)) and is_equal_approx(float(mender_full.get("row", {}).get("result", -1.0)), 1.0) and bool(mender_full.get("row", {}).get("is_power", true)) == false and bool(mender_empty.get("has_item_row", false)) and is_equal_approx(float(mender_empty.get("row", {}).get("result", -1.0)), 0.0)

	var projector_stacks: Array = [{"item": "phase-fabric", "amount": 1}]
	var projector_full: Dictionary = mend_projector_build_state.source_mend_projector_item_consumer_row_state({"items": {"phase-fabric": 1}}, projector_stacks)
	var projector_empty: Dictionary = mend_projector_build_state.source_mend_projector_item_consumer_row_state({"items": {}}, projector_stacks)
	proof["mend_projector_row_binary_phase_fabric"] = bool(projector_full.get("has_item_row", false)) and is_equal_approx(float(projector_full.get("row", {}).get("result", -1.0)), 1.0) and bool(projector_full.get("row", {}).get("is_power", true)) == false and bool(projector_empty.get("has_item_row", false)) and is_equal_approx(float(projector_empty.get("row", {}).get("result", -1.0)), 0.0)

	# --- phaseHeat lerps toward the folded optionalEfficiency
	# (MendProjector.java:100, `phaseHeat = Mathf.lerpDelta(
	# phaseHeat, optionalEfficiency, 0.1f);`): the N2193
	# advance already reads frame optional_efficiency; this
	# slice only supplies the real value, so the pure advance
	# with optional 1.0 lifts phaseHeat off 0 and with
	# optional 0.0 pulls it back down (time_delta 1.0, so the
	# 0.1f lerp progress moves a full tenth of the gap).
	var heat_up: Dictionary = mend_projector_build_state.source_mend_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 1.0, "phase_heat": 0.0, "heat": 0.0, "charge": 0.0, "smooth_efficiency": 0.0}, 200.0, 1.0)
	var heat_down: Dictionary = mend_projector_build_state.source_mend_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.0, "phase_heat": 0.5, "heat": 0.0, "charge": 0.0, "smooth_efficiency": 0.0}, 200.0, 1.0)
	proof["phase_heat_lerps_toward_optional"] = is_equal_approx(float(heat_up.get("phase_heat", -1.0)), 0.1) and is_equal_approx(float(heat_down.get("phase_heat", -1.0)), 0.45)

	# --- Live tick: the mender is a MendProjector with a power
	# consumer (consumePower 0.3f) and a silicon booster row,
	# placed live; the tick driver is called directly (as the
	# N2147/N2148/N2149/N2150/N2153/N2154/N2155 proofs do),
	# not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The booster row folds
	# into the OPTIONAL pass only (BuildingComp.java:
	# 1980-1981), capped by the min (BuildingComp.java:1986).
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
	# frame dict before the tick to stamp power_status and
	# items on it).
	mend_projector_build_state.source_mend_projector_bind_frame_state(projector, blocks_by_id["mender"])
	var projector_frame: Dictionary = projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})

	# Full power, silicon present: optionalEfficiency folds 1.0.
	projector_frame["power_status"] = 1.0
	projector_frame["items"] = {"silicon": 1}
	mend_projector_build_state.source_mend_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})
	proof["live_tick_folds_booster_row"] = is_equal_approx(float(projector_frame.get("optional_efficiency", -1.0)), 1.0) and is_equal_approx(float(projector_frame.get("efficiency", -1.0)), 1.0)

	# Full power, no silicon: the booster row folds optional 0
	# while the power min -- and efficiency -- stays 1.0.
	projector_frame["power_status"] = 1.0
	projector_frame["items"] = {}
	mend_projector_build_state.source_mend_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})
	proof["booster_row_folds_optional_only"] = is_equal_approx(float(projector_frame.get("optional_efficiency", -1.0)), 0.0) and is_equal_approx(float(projector_frame.get("efficiency", -1.0)), 1.0)

	# Half power, silicon present: optional is capped by the
	# min efficiency 0.5 (BuildingComp.java:1986).
	projector_frame["power_status"] = 0.5
	projector_frame["items"] = {"silicon": 1}
	mend_projector_build_state.source_mend_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})
	proof["optional_capped_by_min_efficiency"] = is_equal_approx(float(projector_frame.get("optional_efficiency", -1.0)), 0.5) and is_equal_approx(float(projector_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MendProjectorBoosterItemsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
