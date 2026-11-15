extends Node

const main_scene := preload("res://scenes/Main.tscn")
const wall_crafter_build_state := preload("res://src/game/SourceWallCrafterBuildState.gd")
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

	# --- Pure rows (N2264): the hydrogen row mirrors
	# ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47,
	# `float ed = build.edelta() * build.efficiencyScale();` /
	# `if(ed <= 0.00000001f) return 0f;` / `return Math.min(
	# build.liquids.get(liquid) / (amount * ed *
	# multiplier.get(build)), 1f);`), folded by the first pass
	# (BuildingComp.java:1969-1976) into the min efficiency; a
	# starved non-power row also stops power draw
	# (BuildingComp.java:1972). The graphite row mirrors
	# ConsumeItems.efficiency (ConsumeItems.java:51-53,
	# `return build.consumeTriggerValid() || build.items.has(
	# items, multiplier.get(build)) ? 1f : 0f;`): BINARY 1/0.
	# In the first pass efficiency is assumed 1f
	# (BuildingComp.java:1965), so edelta is delta() =
	# source_delta * time_scale. The large-cliff-crusher
	# amount is 1f/60f per frame (Blocks.java:3028); the
	# cliff-crusher has neither row (power only,
	# Blocks.java:3004).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var hydrogen_id: int = int(liquid_id_by_name.get("hydrogen", -1))
	var content_liquid_ids: Array = liquid_catalog.get("content_liquid_ids", [])
	var large_amount: float = 1.0 / 60.0
	var graphite_stacks: Array = [{"item": "graphite", "amount": 1}]

	# Starved hydrogen: half the per-frame demand -> row 0.5,
	# non-power. The live fold of the same starvation is
	# checked below (efficiency 0.5, then 0.0 + no power draw
	# at zero hydrogen).
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(starved_liquids, hydrogen_id, 0.5 * large_amount)
	var starved_row: Dictionary = wall_crafter_build_state.source_wall_crafter_liquid_consumer_row_state({"liquids": starved_liquids}, true, hydrogen_id, large_amount, 1.0, 1.0, 1.0)
	var starved_pure: bool = bool(starved_row.get("has_liquid_row", false)) and is_equal_approx(float(starved_row.get("row", {}).get("result", -1.0)), 0.5) and not bool(starved_row.get("row", {}).get("is_power", true))

	# No graphite: the binary item row is 0, item_valid false.
	# The live fold of the same absence is checked below
	# (efficiency stays 1.0, optionalEfficiency drops to 0).
	var absent_row: Dictionary = wall_crafter_build_state.source_wall_crafter_item_consumer_row_state({"items": {}}, true, graphite_stacks)
	var absent_pure: bool = bool(absent_row.get("has_item_row", false)) and is_equal_approx(float(absent_row.get("row", {}).get("result", -1.0)), 0.0) and not bool(absent_row.get("row", {}).get("is_power", true)) and bool(absent_row.get("item_valid", true)) == false

	# One graphite: row 1.0, item_valid true. Five graphite:
	# still 1.0 -- the row is binary, not a ratio.
	var one_row: Dictionary = wall_crafter_build_state.source_wall_crafter_item_consumer_row_state({"items": {"graphite": 1}}, true, graphite_stacks)
	var five_row: Dictionary = wall_crafter_build_state.source_wall_crafter_item_consumer_row_state({"items": {"graphite": 5}}, true, graphite_stacks)
	proof["item_row_binary_one_when_present"] = bool(one_row.get("has_item_row", false)) and is_equal_approx(float(one_row.get("row", {}).get("result", -1.0)), 1.0) and bool(one_row.get("item_valid", false)) and is_equal_approx(float(five_row.get("row", {}).get("result", -1.0)), 1.0) and bool(five_row.get("item_valid", false))

	# The cliff-crusher has neither row: both presence flags
	# false, item_valid false.
	var no_liquid_row: Dictionary = wall_crafter_build_state.source_wall_crafter_liquid_consumer_row_state({}, false, hydrogen_id, large_amount, 1.0, 1.0, 1.0)
	var no_item_row: Dictionary = wall_crafter_build_state.source_wall_crafter_item_consumer_row_state({}, false, [])
	proof["cliff_crusher_has_no_rows"] = bool(no_liquid_row.get("has_liquid_row", true)) == false and bool(no_item_row.get("has_item_row", true)) == false and bool(no_item_row.get("item_valid", true)) == false

	# --- Live tick: large-cliff-crushers and a cliff-crusher
	# placed live; the tick driver is called directly (as the
	# N2170/N2201/N2223 proofs do), not simulate_factory, so
	# the graph update does not overwrite the stamped
	# power_status -- the write-back itself is already proven
	# by N2142. The hydrogen amounts are set on the sprite
	# liquids meta store (the live LiquidModule), which the
	# driver syncs into the frame each tick before the fold
	# (the Fracker proof precedent); the graphite is set on
	# the frame items dict directly (no live intake fills it
	# yet, so the proof seeds it like the N2223 proof seeds
	# efficiency_factor).
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# A1: half the per-frame hydrogen, full power, graphite
	# present -- efficiency folds the hydrogen min 0.5 (below
	# the power row 1.0). The second pass then removes amount
	# * folded edelta = (1/60) * 0.5, which is exactly the
	# held hydrogen, so the store empties -- the fold key
	# reads efficiency before that matters.
	var starved_cell := Vector2i(28, 21)
	var starved_crusher := Sprite2D.new()
	game.add_child(starved_crusher)
	game.call("record_placed_block", starved_crusher, blocks_by_id["large-cliff-crusher"], starved_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and
	# items on it).
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(starved_crusher, blocks_by_id["large-cliff-crusher"])
	var starved_frame: Dictionary = starved_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	var starved_store: Dictionary = starved_crusher.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(starved_store, hydrogen_id, 0.5 * large_amount)
	starved_frame["items"] = {"graphite": 1}
	starved_frame["power_status"] = 1.0

	# A2: zero hydrogen, full power, graphite present --
	# efficiency folds 0.0 and the starved non-power row stops
	# power draw (BuildingComp.java:1972, result <= 1e-7).
	var dry_cell := Vector2i(22, 21)
	var dry_crusher := Sprite2D.new()
	game.add_child(dry_crusher)
	game.call("record_placed_block", dry_crusher, blocks_by_id["large-cliff-crusher"], dry_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(dry_crusher, blocks_by_id["large-cliff-crusher"])
	var dry_frame: Dictionary = dry_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	dry_frame["items"] = {"graphite": 1}
	dry_frame["power_status"] = 1.0

	wall_crafter_build_state.source_wall_crafter_tick_buildings_state(game, 1.0 / 60.0)
	starved_frame = starved_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	dry_frame = dry_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	proof["hydrogen_row_folds_min_when_starved"] = starved_pure and is_equal_approx(float(starved_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(dry_frame.get("efficiency", -1.0)), 0.0) and bool(dry_frame.get("should_consume_power", true)) == false

	# B: hydrogen-full at full power, NO graphite -- the
	# graphite row folds the optional pass only, so efficiency
	# stays 1.0 while optionalEfficiency drops to 0.0.
	var no_graphite_cell := Vector2i(16, 21)
	var no_graphite_crusher := Sprite2D.new()
	game.add_child(no_graphite_crusher)
	game.call("record_placed_block", no_graphite_crusher, blocks_by_id["large-cliff-crusher"], no_graphite_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(no_graphite_crusher, blocks_by_id["large-cliff-crusher"])
	var no_graphite_frame: Dictionary = no_graphite_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	var no_graphite_store: Dictionary = no_graphite_crusher.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(no_graphite_store, hydrogen_id, 1.0)
	no_graphite_frame["items"] = {}
	no_graphite_frame["power_status"] = 1.0
	wall_crafter_build_state.source_wall_crafter_tick_buildings_state(game, 1.0 / 60.0)
	no_graphite_frame = no_graphite_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	proof["graphite_row_folds_optional_when_absent"] = absent_pure and is_equal_approx(float(no_graphite_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(no_graphite_frame.get("optional_efficiency", -1.0)), 0.0)

	# C: large crusher with graphite -- item_valid stamps live
	# true. D: cliff-crusher -- no item row, item_valid stamps
	# false.
	var valid_cell := Vector2i(28, 15)
	var valid_crusher := Sprite2D.new()
	game.add_child(valid_crusher)
	game.call("record_placed_block", valid_crusher, blocks_by_id["large-cliff-crusher"], valid_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(valid_crusher, blocks_by_id["large-cliff-crusher"])
	var valid_frame: Dictionary = valid_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	var valid_store: Dictionary = valid_crusher.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(valid_store, hydrogen_id, 1.0)
	valid_frame["items"] = {"graphite": 1}
	valid_frame["power_status"] = 1.0

	var cliff_cell := Vector2i(22, 15)
	var cliff_crusher := Sprite2D.new()
	game.add_child(cliff_crusher)
	game.call("record_placed_block", cliff_crusher, blocks_by_id["cliff-crusher"], cliff_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(cliff_crusher, blocks_by_id["cliff-crusher"])
	var cliff_frame: Dictionary = cliff_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	cliff_frame["items"] = {}
	cliff_frame["power_status"] = 1.0
	wall_crafter_build_state.source_wall_crafter_tick_buildings_state(game, 1.0 / 60.0)
	valid_frame = valid_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	cliff_frame = cliff_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	proof["item_valid_stamped_live"] = bool(valid_frame.get("item_valid", false)) and bool(cliff_frame.get("item_valid", true)) == false

	# E: a fresh large crusher, hydrogen-full at full power
	# with graphite -- efficiency 1, so the second pass
	# removes exactly one frame's demand (1/60) from the held
	# 1.0 of hydrogen. No graphite is removed: Consume.update
	# is empty (Consume.java:52), and the timer-gated
	# consume() (WallCrafter.java:207-209) waits for its own
	# slice.
	var remover_cell := Vector2i(16, 15)
	var remover := Sprite2D.new()
	game.add_child(remover)
	game.call("record_placed_block", remover, blocks_by_id["large-cliff-crusher"], remover_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(remover, blocks_by_id["large-cliff-crusher"])
	var remover_frame: Dictionary = remover.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	var remover_store: Dictionary = remover.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(remover_store, hydrogen_id, 1.0)
	remover_frame["items"] = {"graphite": 1}
	remover_frame["power_status"] = 1.0
	wall_crafter_build_state.source_wall_crafter_tick_buildings_state(game, 1.0 / 60.0)
	remover_frame = remover.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	remover_store = remover.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	proof["live_tick_removes_hydrogen_when_running"] = is_equal_approx(float(remover_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(liquid_module_state.source_get_state(remover_store, hydrogen_id).get("amount", -1.0)), 1.0 - large_amount) and int(remover_frame.get("items", {}).get("graphite", -1)) == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WallCrafterSecondConsumersProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
