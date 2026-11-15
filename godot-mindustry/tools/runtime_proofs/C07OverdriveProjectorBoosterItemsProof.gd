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

	# --- Pure item rows (N2262): ConsumeItems.efficiency is
	# BINARY 1/0 (ConsumeItems.java:51-53, `return build.
	# consumeTriggerValid() || build.items.has(items,
	# multiplier.get(build)) ? 1f : 0f;`) -- every stack held
	# at round(amount * multiplier) (ItemModule.java:152-157),
	# or 0. The per-def stacks come from the catalog
	# consumeItem property: overdrive-projector 1 phaseFabric,
	# optional booster (Blocks.java:1948); overdrive-dome 1
	# phaseFabric + 1 silicon, REQUIRED (Blocks.java:1961).
	var projector_stacks: Array = [{"item": "phase-fabric", "amount": 1, "optional": true, "booster": true}]
	var dome_stacks: Array = [{"item": "phase-fabric", "amount": 1}, {"item": "silicon", "amount": 1}]

	# The dome needs BOTH stacks: phaseFabric alone folds 0,
	# both held folds 1, and the row is required (not
	# optional) in both cases.
	var dome_half: Dictionary = overdrive_projector_build_state.source_overdrive_projector_item_consumer_row_state({"items": {"phase-fabric": 1}}, dome_stacks)
	var dome_full: Dictionary = overdrive_projector_build_state.source_overdrive_projector_item_consumer_row_state({"items": {"phase-fabric": 1, "silicon": 1}}, dome_stacks)
	proof["dome_row_needs_both_stacks"] = bool(dome_half.get("has_item_row", false)) and is_equal_approx(float(dome_half.get("row", {}).get("result", -1.0)), 0.0) and bool(dome_half.get("is_optional", true)) == false and bool(dome_full.get("has_item_row", false)) and is_equal_approx(float(dome_full.get("row", {}).get("result", -1.0)), 1.0) and bool(dome_full.get("is_optional", true)) == false

	# The projector row is binary and optional: absent folds
	# 0, present folds 1, both with the optional flag set.
	var projector_absent: Dictionary = overdrive_projector_build_state.source_overdrive_projector_item_consumer_row_state({"items": {}}, projector_stacks)
	var projector_present: Dictionary = overdrive_projector_build_state.source_overdrive_projector_item_consumer_row_state({"items": {"phase-fabric": 1}}, projector_stacks)
	var projector_row_binary: bool = bool(projector_absent.get("has_item_row", false)) and is_equal_approx(float(projector_absent.get("row", {}).get("result", -1.0)), 0.0) and bool(projector_absent.get("is_optional", false)) and bool(projector_present.get("has_item_row", false)) and is_equal_approx(float(projector_present.get("row", {}).get("result", -1.0)), 1.0) and bool(projector_present.get("is_optional", false))

	# --- Live ticks: the overdrive-projector (consumePower
	# 3.50f, phaseFabric booster) and the overdrive-dome
	# (consumePower 10f, phaseFabric + silicon required) are
	# placed live; the tick driver is called directly (as the
	# N2147/N2148/N2149/N2150/N2153/N2154/N2155/N2156 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var projector_cell := Vector2i(28, 20)
	var projector := Sprite2D.new()
	game.add_child(projector)
	game.call("record_placed_block", projector, blocks_by_id["overdrive-projector"], projector_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and
	# items on it).
	overdrive_projector_build_state.source_overdrive_projector_bind_frame_state(projector, blocks_by_id["overdrive-projector"])
	var projector_frame: Dictionary = projector.get_meta(overdrive_projector_build_state.SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY, {})

	var dome_cell := Vector2i(33, 20)
	var dome := Sprite2D.new()
	game.add_child(dome)
	game.call("record_placed_block", dome, blocks_by_id["overdrive-dome"], dome_cell)
	overdrive_projector_build_state.source_overdrive_projector_bind_frame_state(dome, blocks_by_id["overdrive-dome"])
	var dome_frame: Dictionary = dome.get_meta(overdrive_projector_build_state.SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY, {})

	# Both starved at full power: the projector's booster row
	# folds the OPTIONAL pass only, so efficiency stays 1.0
	# while optionalEfficiency drops to 0; the dome's required
	# row folds the min, so efficiency drops to 0 and power
	# stops (shouldConsumePower false).
	projector_frame["power_status"] = 1.0
	projector_frame["items"] = {}
	dome_frame["power_status"] = 1.0
	dome_frame["items"] = {}
	overdrive_projector_build_state.source_overdrive_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(overdrive_projector_build_state.SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY, {})
	dome_frame = dome.get_meta(overdrive_projector_build_state.SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY, {})
	proof["projector_row_folds_optional_when_absent"] = projector_row_binary and is_equal_approx(float(projector_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(projector_frame.get("optional_efficiency", -1.0)), 0.0)
	proof["dome_row_folds_min_when_starved"] = is_equal_approx(float(dome_frame.get("efficiency", -1.0)), 0.0)
	proof["dome_row_stops_power_when_starved"] = bool(dome_frame.get("should_consume_power", true)) == false

	# Projector consume(): 2 phaseFabric held, useProgress one
	# tick short of useTime 400f -- the tick crosses useTime,
	# reports use_ready, and removes exactly 1 phaseFabric.
	projector_frame["power_status"] = 1.0
	projector_frame["items"] = {"phase-fabric": 2}
	projector_frame["use_progress"] = 399.0
	dome_frame["power_status"] = 1.0
	dome_frame["items"] = {}
	overdrive_projector_build_state.source_overdrive_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(overdrive_projector_build_state.SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY, {})
	var projector_items: Dictionary = projector_frame.get("items", {})
	proof["use_ready_removes_projector_stack"] = int(projector_items.get("phase-fabric", -1)) == 1 and is_equal_approx(float(projector_frame.get("use_progress", -1.0)), 0.0)

	# Dome consume(): 2 phaseFabric + 3 silicon held,
	# useProgress one tick short of useTime 300f -- the tick
	# crosses useTime and removes 1 of EACH stack. The dome
	# needs both stacks held for efficiency > 0 (the required
	# row), which is what lets useProgress advance at all.
	dome_frame["power_status"] = 1.0
	dome_frame["items"] = {"phase-fabric": 2, "silicon": 3}
	dome_frame["use_progress"] = 299.0
	projector_frame["power_status"] = 1.0
	overdrive_projector_build_state.source_overdrive_projector_tick_buildings_state(game, 1.0 / 60.0)
	dome_frame = dome.get_meta(overdrive_projector_build_state.SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY, {})
	var dome_items: Dictionary = dome_frame.get("items", {})
	proof["use_ready_removes_dome_stacks"] = int(dome_items.get("phase-fabric", -1)) == 1 and int(dome_items.get("silicon", -1)) == 2 and is_equal_approx(float(dome_frame.get("use_progress", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07OverdriveProjectorBoosterItemsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
