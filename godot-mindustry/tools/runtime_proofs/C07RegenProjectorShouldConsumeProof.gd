extends Node

const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const main_scene := preload("res://scenes/Main.tscn")
const regen_projector_build_state := preload("res://src/game/SourceRegenProjectorBuildState.gd")
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

	# --- Pure shouldConsume gate (N2214):
	# RegenProjectorBuild.shouldConsume()
	# (RegenProjector.java:181-183, `public boolean
	# shouldConsume(){` with `return anyTargets;`,
	# RegenProjector.java:182) -- the gate reads ONLY the
	# anyTargets flag: the projector consumes while a damaged
	# building is in range and stops consuming once nothing in
	# range is damaged. The field is `public boolean
	# anyTargets = false;` (RegenProjector.java:112) on
	# RegenProjectorBuild (`public class
	# RegenProjectorBuild extends Building{`,
	# RegenProjector.java:108). The gate has NO `&& enabled`
	# -- Java returns the bare flag, so the pure gate does NOT
	# read frame["enabled"] at all. The gate reads only the
	# frame["any_targets"] flag, so the proof injects the flag
	# directly -- no indexer query runs here; the targets
	# computation (indexer range query,
	# RegenProjector.java:115-119, + contains damaged,
	# RegenProjector.java:139) is the updateTile advance
	# (RegenProjector.java:122-179) and waits for its own
	# slice.
	var with_targets: Dictionary = regen_projector_build_state.source_regen_projector_should_consume_state({"any_targets": true})
	proof["gate_true_when_any_targets"] = bool(with_targets.get("should_consume", false)) and bool(with_targets.get("any_targets", false))

	var no_targets: Dictionary = regen_projector_build_state.source_regen_projector_should_consume_state({"any_targets": false})
	proof["gate_false_when_no_targets"] = bool(no_targets.get("should_consume", true)) == false and bool(no_targets.get("any_targets", true)) == false

	var disabled_with_targets: Dictionary = regen_projector_build_state.source_regen_projector_should_consume_state({"any_targets": true, "enabled": false})
	var disabled_no_targets: Dictionary = regen_projector_build_state.source_regen_projector_should_consume_state({"any_targets": false, "enabled": false})
	proof["gate_independent_of_enabled"] = bool(disabled_with_targets.get("should_consume", false)) and bool(disabled_no_targets.get("should_consume", true)) == false

	# --- Live tick: the regen-projector is a RegenProjector
	# build with a power consumer (consumePower 1f), placed
	# live; the tick driver is called directly (as the N2147/
	# N2148/N2149/N2150/N2153/N2154/N2155/N2156/N2157/N2158/
	# N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
	# N2168/N2169 proofs do), not simulate_factory, so the
	# graph update does not overwrite the stamped power_status
	# -- the write-back itself is already proven by N2142. The
	# regen-projector tick models no other consumers, so with
	# a power consumer the first pass holds only the power row;
	# when the gate is false updateConsumption forces
	# efficiency to zero (BuildingComp.java:1960 + 1992).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var regen_cell := Vector2i(28, 20)
	var regen := Sprite2D.new()
	game.add_child(regen)
	game.call("record_placed_block", regen, blocks_by_id["regen-projector"], regen_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# any_targets on it).
	regen_projector_build_state.source_regen_projector_bind_frame_state(regen, blocks_by_id["regen-projector"])
	var regen_frame: Dictionary = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	# Supply the later required hydrogen consumer so this fixture isolates the gate/power fold.
	liquid_module_state.source_set_state(regen.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY), int(liquid_catalog["liquid_id_by_name"]["hydrogen"]), 1.0)

	# A freshly bound frame carries the any_targets key
	# defaulting to false (the Java field defaults to false)
	# -- no damaged building in range yet, so the gate reads
	# false and the projector does not consume.
	proof["frame_any_targets_default_false"] = regen_frame.has("any_targets") and bool(regen_frame["any_targets"]) == false

	# No damaged building in range: gate false ->
	# efficiency 0 even at half power.
	regen_frame["any_targets"] = false
	regen_frame["power_status"] = 0.5
	regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)
	regen_frame = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(regen_frame.get("efficiency", -1.0)), 0.0)

	# Damaged building in range: gate true -> efficiency folds
	# the power min 0.5 (the N2160 power fold preserved).
	regen_frame["any_targets"] = true
	regen_frame["power_status"] = 0.5
	regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)
	regen_frame = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(regen_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RegenProjectorShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
