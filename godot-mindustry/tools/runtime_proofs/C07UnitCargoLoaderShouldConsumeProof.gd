extends Node

const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const main_scene := preload("res://scenes/Main.tscn")
const unit_cargo_loader_build_state := preload("res://src/game/SourceUnitCargoLoaderBuildState.gd")
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

	# --- Pure shouldConsume gate (N2211):
	# UnitTransportSourceBuild.shouldConsume()
	# (UnitCargoLoader.java:141-143, `public boolean
	# shouldConsume(){` with `return unit == null;`,
	# UnitCargoLoader.java:142) -- the gate is INVERTED: the
	# loader consumes while NO unit is held (still building
	# one) and stops consuming once a unit waits to be loaded.
	# The field is `public @Nullable Unit unit;`
	# (UnitCargoLoader.java:89) on UnitTransportSourceBuild
	# (`public class UnitTransportSourceBuild extends Building
	# implements UnitTetherBlock{`, UnitCargoLoader.java:84).
	# The gate has NO `&& enabled` -- Java returns the bare
	# null check, so the pure gate does NOT read
	# frame["enabled"] at all. The gate reads only the
	# null-ness of frame["unit"], so the present-unit fixture
	# below is a minimal test-only Dictionary -- no real Unit
	# is built; the port has no unit store / readUnitId state
	# on the building frame yet (the unit spawn / readUnitId
	# fill is the updateTile advance, UnitCargoLoader.java:
	# 92-125, and waits for its own slice).
	var no_unit: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_should_consume_state({"unit": null})
	proof["gate_true_when_unit_null"] = bool(no_unit.get("should_consume", false)) and bool(no_unit.get("has_unit", true)) == false

	var has_unit: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_should_consume_state({"unit": {"type": "dart"}})
	proof["gate_false_when_unit_present"] = bool(has_unit.get("should_consume", true)) == false and bool(has_unit.get("has_unit", false))

	var disabled_no_unit: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_should_consume_state({"unit": null, "enabled": false})
	var disabled_has_unit: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_should_consume_state({"unit": {"type": "dart"}, "enabled": false})
	proof["gate_independent_of_enabled"] = bool(disabled_no_unit.get("should_consume", false)) and bool(disabled_has_unit.get("should_consume", true)) == false

	# --- Live tick: the unit-cargo-loader is a UnitCargoLoader
	# build with a power consumer (consumePower 8f/60f), placed
	# live; the tick driver is called directly (as the N2147/
	# N2148/N2149/N2150/N2153/N2154/N2155/N2156/N2157/N2158/
	# N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
	# N2168/N2169 proofs do), not simulate_factory, so the
	# graph update does not overwrite the stamped power_status
	# -- the write-back itself is already proven by N2142. The
	# unit-cargo-loader tick models no other consumers, so with
	# a power consumer the first pass holds only the power row;
	# when the gate is false updateConsumption forces
	# efficiency to zero (BuildingComp.java:1960 + 1992).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var unit_cargo_loader_cell := Vector2i(28, 20)
	var unit_cargo_loader := Sprite2D.new()
	game.add_child(unit_cargo_loader)
	game.call("record_placed_block", unit_cargo_loader, blocks_by_id["unit-cargo-loader"], unit_cargo_loader_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the unit on it).
	unit_cargo_loader_build_state.source_unit_cargo_loader_bind_frame_state(unit_cargo_loader, blocks_by_id["unit-cargo-loader"])
	var unit_cargo_loader_frame: Dictionary = unit_cargo_loader.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	# Supply the later required nitrogen consumer so this fixture isolates the gate/power fold.
	liquid_module_state.source_set_state(unit_cargo_loader.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY), int(liquid_catalog["liquid_id_by_name"]["nitrogen"]), 1.0)

	# A freshly bound frame carries the unit key defaulting to
	# null (the Java field is nullable) -- no unit yet, so the
	# gate reads true and the loader consumes.
	proof["frame_unit_default_null"] = unit_cargo_loader_frame.has("unit") and unit_cargo_loader_frame["unit"] == null

	# Unit present (waiting to be loaded): gate false ->
	# efficiency 0 even at half power.
	unit_cargo_loader_frame["unit"] = {"type": "dart"}
	unit_cargo_loader_frame["power_status"] = 0.5
	unit_cargo_loader_build_state.source_unit_cargo_loader_tick_buildings_state(game, 1.0 / 60.0)
	unit_cargo_loader_frame = unit_cargo_loader.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(unit_cargo_loader_frame.get("efficiency", -1.0)), 0.0)

	# No unit (still building): gate true -> efficiency folds
	# the power min 0.5 (the N2165 power fold preserved).
	unit_cargo_loader_frame["unit"] = null
	unit_cargo_loader_frame["power_status"] = 0.5
	unit_cargo_loader_build_state.source_unit_cargo_loader_tick_buildings_state(game, 1.0 / 60.0)
	unit_cargo_loader_frame = unit_cargo_loader.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(unit_cargo_loader_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitCargoLoaderShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
