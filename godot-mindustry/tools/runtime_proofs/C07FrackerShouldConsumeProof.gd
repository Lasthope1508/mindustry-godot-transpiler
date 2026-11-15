extends Node

const main_scene := preload("res://scenes/Main.tscn")
const fracker_build_state := preload("res://src/game/SourceFrackerBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	# The liquid catalog resolves the result liquid's id
	# (the factory precedent): the pure gate takes the
	# catalog id, the driver resolves it from
	# liquid_id_by_name with the def constant "oil".
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var oil_id: int = int(liquid_catalog["liquid_id_by_name"].get("oil", -1))
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))
	var content_liquid_ids: Array = liquid_catalog["content_liquid_ids"]

	# --- Pure gate (N2207): FrackerBuild does NOT override
	# shouldConsume (Fracker.java has no shouldConsume at
	# all; Fracker extends SolidPump, Fracker.java:7, and
	# FrackerBuild extends SolidPumpBuild, Fracker.java:26),
	# so it inherits SolidPumpBuild.shouldConsume verbatim
	# (SolidPump.java:117, `public boolean shouldConsume(){`
	# with `return liquids.get(result) < liquidCapacity -
	# 0.01f;`, SolidPump.java:118) -- and unlike the
	# Separator/Drill gates this one has NO `&& enabled`:
	# Java returns the bare capacity comparison, so the pure
	# gate must NOT read enabled at all. The result liquid
	# is oil for the only Fracker def (the class default is
	# water, `public Liquid result = Liquids.water;`,
	# SolidPump.java:22, overridden by the def, `result =
	# Liquids.oil;`, Blocks.java:2966) and the capacity is
	# the def constant 40f (`liquidCapacity = 40f;`,
	# Blocks.java:2971; the class default is -1f, `public
	# float liquidCapacity = -1f;`, Block.java:77).
	var below_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(below_liquids, oil_id, 39.0)
	var below_gate: Dictionary = fracker_build_state.source_fracker_should_consume_state({"liquids": below_liquids}, oil_id, fracker_build_state.SOURCE_FRACKER_LIQUID_CAPACITY)
	proof["gate_true_below_capacity"] = bool(below_gate.get("should_consume", false)) and is_equal_approx(float(below_gate.get("result_amount", -1.0)), 39.0)

	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, oil_id, 40.0)
	var full_gate: Dictionary = fracker_build_state.source_fracker_should_consume_state({"liquids": full_liquids}, oil_id, fracker_build_state.SOURCE_FRACKER_LIQUID_CAPACITY)
	proof["gate_false_at_capacity"] = bool(full_gate.get("should_consume", true)) == false and is_equal_approx(float(full_gate.get("result_amount", -1.0)), 40.0)

	# The gate ignores enabled entirely: a disabled fracker
	# with room still gates true, and a disabled fracker at
	# capacity still gates false -- the pure gate has no
	# enabled term (the driver runs the machinery only when
	# enabled, so the live path still respects disabled).
	var disabled_room_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	var disabled_room_gate: Dictionary = fracker_build_state.source_fracker_should_consume_state({"liquids": disabled_room_liquids, "enabled": false}, oil_id, fracker_build_state.SOURCE_FRACKER_LIQUID_CAPACITY)
	var disabled_full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(disabled_full_liquids, oil_id, 40.0)
	var disabled_full_gate: Dictionary = fracker_build_state.source_fracker_should_consume_state({"liquids": disabled_full_liquids, "enabled": false}, oil_id, fracker_build_state.SOURCE_FRACKER_LIQUID_CAPACITY)
	proof["gate_ignores_enabled"] = bool(disabled_room_gate.get("should_consume", false)) and bool(disabled_full_gate.get("should_consume", true)) == false

	# The def constants: the gate reads the RESULT liquid
	# (oil), not water -- a store full of water with no oil
	# still gates true -- and the capacity is 40f with the
	# -0.01f epsilon: oil at exactly 39.99 == capacity -
	# 0.01f already gates false. The literal 40.0 pins the
	# def value independently of the driver's constant,
	# which is itself checked against the literal.
	var water_full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(water_full_liquids, water_id, 40.0)
	var water_full_gate: Dictionary = fracker_build_state.source_fracker_should_consume_state({"liquids": water_full_liquids}, oil_id, 40.0)
	var epsilon_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(epsilon_liquids, oil_id, 39.99)
	var epsilon_gate: Dictionary = fracker_build_state.source_fracker_should_consume_state({"liquids": epsilon_liquids}, oil_id, 40.0)
	proof["def_constant_oil_capacity_forty"] = bool(water_full_gate.get("should_consume", false)) and bool(epsilon_gate.get("should_consume", true)) == false and is_equal_approx(float(fracker_build_state.SOURCE_FRACKER_LIQUID_CAPACITY), 40.0) and str(fracker_build_state.SOURCE_FRACKER_RESULT_LIQUID) == "oil"

	# --- Live tick: two oil-extractors placed live; the tick
	# driver is called directly (as the N2153 proof does), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. Extractor A (empty oil store,
	# half power) keeps the N2153 fold: efficiency folds the
	# power min 0.5. Extractor B (oil at capacity 40, full
	# power) folds efficiency 0 -- the N2153 gap (efficiency
	# 1.0 vs Java 0.0) is closed. The oil amounts are set on
	# the sprite liquids meta store (the live LiquidModule),
	# which the driver syncs into the frame each tick.
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var extractor_a_cell := Vector2i(28, 20)
	var extractor_a := Sprite2D.new()
	game.add_child(extractor_a)
	game.call("record_placed_block", extractor_a, blocks_by_id["oil-extractor"], extractor_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	fracker_build_state.source_fracker_bind_frame_state(extractor_a, blocks_by_id["oil-extractor"])
	var extractor_a_frame: Dictionary = extractor_a.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})

	var extractor_b_cell := Vector2i(20, 10)
	var extractor_b := Sprite2D.new()
	game.add_child(extractor_b)
	game.call("record_placed_block", extractor_b, blocks_by_id["oil-extractor"], extractor_b_cell)
	fracker_build_state.source_fracker_bind_frame_state(extractor_b, blocks_by_id["oil-extractor"])
	var extractor_b_frame: Dictionary = extractor_b.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	var extractor_b_liquids: Dictionary = extractor_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_b_liquids, oil_id, 40.0)

	extractor_a_frame["power_status"] = 0.5
	extractor_b_frame["power_status"] = 1.0
	fracker_build_state.source_fracker_tick_buildings_state(game, 1.0 / 60.0)
	extractor_a_frame = extractor_a.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	extractor_b_frame = extractor_b.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(extractor_a_frame.get("efficiency", -1.0)), 0.5)
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(extractor_b_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07FrackerShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
