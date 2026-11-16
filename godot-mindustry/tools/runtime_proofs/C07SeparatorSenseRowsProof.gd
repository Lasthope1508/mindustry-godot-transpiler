extends Node

const main_scene := preload("res://scenes/Main.tscn")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
const building_sense_state := preload("res://src/game/SourceBuildingSenseState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# --- Sense rows (N2388): SeparatorBuild.sense()
	# (Separator.java:169-172). `public double
	# sense(LAccess sensor){` + `if(sensor ==
	# LAccess.progress) return progress;` + `return
	# super.sense(sensor);`. progress is the frame value
	# the N2222 advance tracks (`public float progress;`,
	# :76, advanced by `progress += getProgressIncrease(
	# craftTime);`, :134) -- and Java returns it AS-IS,
	# with NO clamp (unlike the MendProjector, which
	# clamps charge / reload to [0, 1]). super.sense is
	# the BuildingComp switch (BuildingComp.java:2094-
	# 2123, `return switch(sensor){`), already modeled
	# by the port (SourceBuildingSenseState), so the pure
	# takes the caller's super.sense result as
	# super_value; null is the default branch (`default
	# -> Float.NaN; //gets converted to null in logic`).
	# canDump (`return !consumesItem(item);`,
	# Separator.java:175-177) does NOT land here:
	# consumesItem is Block.itemFilter[item.id]
	# (Block.java:774-776) and no Separator itemFilter
	# is modeled, so canDump stays deferred. Pure-only:
	# the tick never calls sense -- sense is called by
	# logic, and the logic call site waits for a
	# logic-executor slice.

	# --- Progress zero: progress 0.0 reads 0.0, and the
	# dispatch flag is true.
	var zero: Dictionary = separator_build_state.source_separator_sense_state("progress", 0.0)
	proof["sense_progress_zero"] = bool(zero.get("is_progress", false)) and is_equal_approx(float(zero.get("value", -1.0)), 0.0)

	# --- Progress partial: progress 0.5 reads 0.5
	# as-is -- the frame value, untouched.
	var partial: Dictionary = separator_build_state.source_separator_sense_state("progress", 0.5)
	var partial_small: Dictionary = separator_build_state.source_separator_sense_state("progress", 0.25)
	proof["sense_progress_partial"] = is_equal_approx(float(partial.get("value", -1.0)), 0.5) and is_equal_approx(float(partial_small.get("value", -1.0)), 0.25)

	# --- Progress unclamped: Java returns progress
	# as-is with NO clamp, so a progress past 1.0 reads
	# 1.5 (not 1.0) and a negative progress reads -0.25
	# (not 0.0) -- the no-clamp evidence that separates
	# this sense row from the MendProjector clamp.
	var over: Dictionary = separator_build_state.source_separator_sense_state("progress", 1.5)
	var under: Dictionary = separator_build_state.source_separator_sense_state("progress", -0.25)
	proof["sense_progress_unclamped"] = is_equal_approx(float(over.get("value", -1.0)), 1.5) and is_equal_approx(float(under.get("value", -1.0)), -0.25)

	# --- Super sensor: a non-progress sensor returns
	# the caller-supplied super.sense result, not the
	# progress value. health 80.0 (via the modeled
	# BuildingComp health case, `case health ->
	# health;`) and efficiency 0.75 (via `case
	# efficiency -> efficiency;`) both pass through
	# untouched, with the dispatch flag false -- even
	# though the progress value would be 0.5.
	var health_super: Dictionary = building_sense_state.sense_health_process_state(80.0, 100.0, 0.75, 1.0, 0.0, 8.0, false, 0.0)
	var health_sensed: Dictionary = separator_build_state.source_separator_sense_state("health", 0.5, health_super.get("health"))
	var efficiency_sensed: Dictionary = separator_build_state.source_separator_sense_state("efficiency", 0.5, health_super.get("efficiency"))
	proof["sense_super_sensor"] = not bool(health_sensed.get("is_progress", true)) and is_equal_approx(float(health_sensed.get("value", -1.0)), 80.0) and not bool(efficiency_sensed.get("is_progress", true)) and is_equal_approx(float(efficiency_sensed.get("value", -1.0)), 0.75)

	# --- Super default: an unknown sensor with no
	# super value returns null -- the super switch's
	# default branch (`default -> Float.NaN; //gets
	# converted to null in logic`). The default
	# super_value is null, so the caller passes nothing.
	var unknown_sensed: Dictionary = separator_build_state.source_separator_sense_state("not_a_sensor", 0.5)
	var unknown_explicit: Dictionary = separator_build_state.source_separator_sense_state("progress2", 0.5, null)
	proof["sense_super_default"] = not bool(unknown_sensed.get("is_progress", true)) and unknown_sensed.get("value", 0.0) == null and not bool(unknown_explicit.get("is_progress", true)) and unknown_explicit.get("value", 0.0) == null

	# --- Live frame values: a placed separator's frame
	# progress feeds the progress value. The separator
	# has a power consumer (consumePower 1.1f) and a
	# slag consumer (consumeLiquid slag 4f/60f), placed
	# live; the tick driver is called directly (the
	# N2281 proof pattern), not simulate_factory, so
	# the graph update does not overwrite the stamped
	# power_status. One 1/60s tick is one source tick:
	# efficiency folds the power min 1.0 (slag-full, so
	# the liquid row folds 1.0 too), the advance moves
	# progress 1/35 from the stamped 0.5 (progress <
	# 1f, no craft), so the live progress is 0.5 + 1/35
	# and the sensed progress reads it as-is -- the
	# sense pure reads live frame state, it just never
	# runs inside the tick.
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var slag_id: int = int(liquid_id_by_name.get("slag", -1))
	var separator_cell := Vector2i(28, 21)
	var separator := Sprite2D.new()
	game.add_child(separator)
	game.call("record_placed_block", separator, blocks_by_id["separator"], separator_cell)
	separator_build_state.source_separator_bind_frame_state(separator, blocks_by_id["separator"])
	var separator_frame: Dictionary = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var separator_liquids: Dictionary = separator.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(separator_liquids, slag_id, 1.0)
	separator_frame["progress"] = 0.5
	separator_frame["power_status"] = 1.0
	separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)
	separator_frame = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var live: Dictionary = separator_build_state.source_separator_sense_state("progress", float(separator_frame.get("progress", -1.0)))
	proof["sense_live_frame_values"] = is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(separator_frame.get("progress", -1.0)), 0.5 + 1.0 / 35.0) and is_equal_approx(float(live.get("value", -1.0)), 0.5 + 1.0 / 35.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SeparatorSenseRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
