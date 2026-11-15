extends Node

const main_scene := preload("res://scenes/Main.tscn")
const solid_pump_build_state := preload("res://src/game/SourceSolidPumpBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	var liquid_catalog: Dictionary = content_registry_runtime_state.source_liquid_catalog_state(game.get("content_catalog"))
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))
	var oil_id: int = int(liquid_catalog["liquid_id_by_name"].get("oil", -1))

	# --- Pure gate (N2206): SolidPumpBuild overrides
	# shouldConsume (SolidPump.java:117, `public boolean
	# shouldConsume(){` with `return liquids.get(result) <
	# liquidCapacity - 0.01f;`, SolidPump.java:118), so the
	# default (BuildingComp.java:755, `return enabled;`) does
	# NOT apply here -- and unlike the Pump gate this one has
	# NO `&& enabled`: Java returns the bare capacity
	# comparison, so the pure gate must NOT read enabled at
	# all. The result liquid is water (the Java field default,
	# `public Liquid result = Liquids.water;`,
	# SolidPump.java:22, set explicitly by the def, `result =
	# Liquids.water;`, Blocks.java:2922) and the capacity is
	# the def constant 40f (`liquidCapacity = 40f;`,
	# Blocks.java:2925) -- the catalog carries neither
	# property for the water-extractor. The amounts below are
	# set through the shared liquid module helper
	# (SourceLiquidModuleState.source_set_state) over a fresh
	# module state, the same store the driver reads.
	var below_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(below_liquids, water_id, 39.0)
	var below_gate: Dictionary = solid_pump_build_state.source_solid_pump_should_consume_state({"liquids": below_liquids}, water_id, 40.0)
	proof["gate_true_below_capacity"] = bool(below_gate.get("should_consume", false)) and is_equal_approx(float(below_gate.get("result_amount", -1.0)), 39.0)

	var full_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(full_liquids, water_id, 40.0)
	var full_gate: Dictionary = solid_pump_build_state.source_solid_pump_should_consume_state({"liquids": full_liquids}, water_id, 40.0)
	proof["gate_false_at_capacity"] = bool(full_gate.get("should_consume", true)) == false and is_equal_approx(float(full_gate.get("result_amount", -1.0)), 40.0)

	# The gate ignores enabled entirely: a disabled solid
	# pump with room still gates true, and a disabled solid
	# pump at capacity still gates false -- the pure gate
	# has no enabled term (the driver runs the machinery only
	# when enabled, so the live path still respects disabled).
	var disabled_room_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(disabled_room_liquids, water_id, 0.0)
	var disabled_room_gate: Dictionary = solid_pump_build_state.source_solid_pump_should_consume_state({"liquids": disabled_room_liquids, "enabled": false}, water_id, 40.0)
	var disabled_full_gate: Dictionary = solid_pump_build_state.source_solid_pump_should_consume_state({"liquids": full_liquids, "enabled": false}, water_id, 40.0)
	proof["gate_ignores_enabled"] = bool(disabled_room_gate.get("should_consume", false)) and bool(disabled_full_gate.get("should_consume", true)) == false

	# --- Live tick: three water-extractors placed live; the
	# tick driver is called directly (as the N2150 proof does),
	# not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. Extractor A (empty
	# store, half power) keeps the N2150 fold: efficiency folds
	# the power min 0.5. Extractor B (water at capacity 40,
	# full power) folds efficiency 0 -- the N2150 gap
	# (efficiency 1.0 vs Java 0.0) is closed. Extractor C (oil
	# at 40, water at 39.5, full power) folds efficiency 1.0:
	# the gate reads the RESULT liquid (water), not the full
	# oil store, and 39.5 < 40 - 0.01 is below the def
	# capacity -- the def constant (result water / capacity
	# 40f) drives the live gate.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var extractor_a_cell := Vector2i(28, 20)
	var extractor_a := Sprite2D.new()
	game.add_child(extractor_a)
	game.call("record_placed_block", extractor_a, blocks_by_id["water-extractor"], extractor_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	solid_pump_build_state.source_solid_pump_bind_frame_state(extractor_a, blocks_by_id["water-extractor"])
	var extractor_a_frame: Dictionary = extractor_a.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})

	var extractor_b_cell := Vector2i(20, 10)
	var extractor_b := Sprite2D.new()
	game.add_child(extractor_b)
	game.call("record_placed_block", extractor_b, blocks_by_id["water-extractor"], extractor_b_cell)
	solid_pump_build_state.source_solid_pump_bind_frame_state(extractor_b, blocks_by_id["water-extractor"])
	var extractor_b_frame: Dictionary = extractor_b.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})

	var extractor_c_cell := Vector2i(10, 10)
	var extractor_c := Sprite2D.new()
	game.add_child(extractor_c)
	game.call("record_placed_block", extractor_c, blocks_by_id["water-extractor"], extractor_c_cell)
	solid_pump_build_state.source_solid_pump_bind_frame_state(extractor_c, blocks_by_id["water-extractor"])
	var extractor_c_frame: Dictionary = extractor_c.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})

	# Initialize the liquids meta explicitly (record_placed_block
	# already does this for hasLiquids blocks, but the proof
	# re-initializes to a known-empty store), then set the
	# amounts through the shared module helper. The driver
	# refreshes frame["liquids"] from this meta each tick.
	placed_block_state.source_initialize_building_liquids_state(extractor_a, true, game.get("content_catalog"))
	placed_block_state.source_initialize_building_liquids_state(extractor_b, true, game.get("content_catalog"))
	placed_block_state.source_initialize_building_liquids_state(extractor_c, true, game.get("content_catalog"))
	var extractor_b_liquids: Dictionary = extractor_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_b_liquids, water_id, 40.0)
	var extractor_c_liquids: Dictionary = extractor_c.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_c_liquids, oil_id, 40.0)
	liquid_module_state.source_set_state(extractor_c_liquids, water_id, 39.5)

	extractor_a_frame["power_status"] = 0.5
	extractor_b_frame["power_status"] = 1.0
	extractor_c_frame["power_status"] = 1.0
	solid_pump_build_state.source_solid_pump_tick_buildings_state(game, 1.0 / 60.0)
	extractor_a_frame = extractor_a.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})
	extractor_b_frame = extractor_b.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})
	extractor_c_frame = extractor_c.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(extractor_a_frame.get("efficiency", -1.0)), 0.5)
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(extractor_b_frame.get("efficiency", -1.0)), 0.0)
	proof["def_constant_water_capacity_forty"] = is_equal_approx(float(extractor_c_frame.get("efficiency", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SolidPumpShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
