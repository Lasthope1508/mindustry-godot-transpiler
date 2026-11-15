extends Node

const main_scene := preload("res://scenes/Main.tscn")
const wall_crafter_build_state := preload("res://src/game/SourceWallCrafterBuildState.gd")
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

	# --- Pure gate (N2201): WallCrafterBuild overrides
	# shouldConsume (WallCrafter.java:226, `public boolean
	# shouldConsume(){` with `return items.get(output) <
	# itemCapacity;`, WallCrafter.java:227), so the default
	# (BuildingComp.java:755, `return enabled;`) does NOT apply
	# here -- and unlike the Separator/Drill gates this one has
	# NO `&& enabled`: Java returns the bare capacity
	# comparison, so the pure gate must NOT read enabled at
	# all. The output item is sand for both defs (the Java
	# field default, `public Item output = Items.sand;`,
	# WallCrafter.java:43, set explicitly by both defs,
	# Blocks.java:3009/:3024) and the capacity is 10 for the
	# cliff-crusher (the Java field default, `public int
	# itemCapacity = 10;`, Block.java:75) and 20 for the
	# large-cliff-crusher (Blocks.java:3031).
	var below_gate: Dictionary = wall_crafter_build_state.source_wall_crafter_should_consume_state({"items": {"sand": 9}}, "sand", 10)
	proof["gate_true_below_capacity"] = bool(below_gate.get("should_consume", false)) and int(below_gate.get("output_count", -1)) == 9

	var full_gate: Dictionary = wall_crafter_build_state.source_wall_crafter_should_consume_state({"items": {"sand": 10}}, "sand", 10)
	proof["gate_false_at_capacity"] = bool(full_gate.get("should_consume", true)) == false and int(full_gate.get("output_count", -1)) == 10

	# The gate ignores enabled entirely: a disabled wall
	# crafter with room still gates true, and a disabled wall
	# crafter at capacity still gates false -- the pure gate
	# has no enabled term (the driver runs the machinery only
	# when enabled, so the live path still respects disabled).
	var disabled_room_gate: Dictionary = wall_crafter_build_state.source_wall_crafter_should_consume_state({"items": {"sand": 0}, "enabled": false}, "sand", 10)
	var disabled_full_gate: Dictionary = wall_crafter_build_state.source_wall_crafter_should_consume_state({"items": {"sand": 10}, "enabled": false}, "sand", 10)
	proof["gate_ignores_enabled"] = bool(disabled_room_gate.get("should_consume", false)) and bool(disabled_full_gate.get("should_consume", true)) == false

	# --- Live tick: three wall crafters placed live; the tick
	# driver is called directly (as the N2170 proof does), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. Crusher A (cliff-crusher, empty
	# store, half power) keeps the N2170 fold: efficiency folds
	# the power min 0.5. Crusher B (cliff-crusher, sand at
	# capacity 10, full power) folds efficiency 0 -- the N2170
	# gap (efficiency 1.0 vs Java 0.0) is closed. Crusher C
	# (large-cliff-crusher, sand 15, full power) folds
	# efficiency 1.0: 15 < 20 is below the LARGE def's
	# capacity, where the cliff-crusher's 10 would already be
	# full -- the per-def capacity comes from the catalog.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var crusher_a_cell := Vector2i(28, 21)
	var crusher_a := Sprite2D.new()
	game.add_child(crusher_a)
	game.call("record_placed_block", crusher_a, blocks_by_id["cliff-crusher"], crusher_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and
	# items on it).
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(crusher_a, blocks_by_id["cliff-crusher"])
	var crusher_a_frame: Dictionary = crusher_a.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})

	var crusher_b_cell := Vector2i(20, 10)
	var crusher_b := Sprite2D.new()
	game.add_child(crusher_b)
	game.call("record_placed_block", crusher_b, blocks_by_id["cliff-crusher"], crusher_b_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(crusher_b, blocks_by_id["cliff-crusher"])
	var crusher_b_frame: Dictionary = crusher_b.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})

	var crusher_c_cell := Vector2i(10, 10)
	var crusher_c := Sprite2D.new()
	game.add_child(crusher_c)
	game.call("record_placed_block", crusher_c, blocks_by_id["large-cliff-crusher"], crusher_c_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(crusher_c, blocks_by_id["large-cliff-crusher"])
	var crusher_c_frame: Dictionary = crusher_c.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})

	crusher_a_frame["items"] = {}
	crusher_a_frame["power_status"] = 0.5
	crusher_b_frame["items"] = {"sand": 10}
	crusher_b_frame["power_status"] = 1.0
	crusher_c_frame["items"] = {"sand": 15}
	crusher_c_frame["power_status"] = 1.0
	wall_crafter_build_state.source_wall_crafter_tick_buildings_state(game, 1.0 / 60.0)
	crusher_a_frame = crusher_a.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	crusher_b_frame = crusher_b.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	crusher_c_frame = crusher_c.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(crusher_a_frame.get("efficiency", -1.0)), 0.5)
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(crusher_b_frame.get("efficiency", -1.0)), 0.0)
	proof["large_def_capacity_twenty"] = is_equal_approx(float(crusher_c_frame.get("efficiency", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WallCrafterShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
