extends Node

const main_scene := preload("res://scenes/Main.tscn")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
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

	# --- Pure advance (N2222): SeparatorBuild.updateTile()
	# (Separator.java:130-167): totalProgress += warmup *
	# delta() (:131); while efficiency > 0, progress +=
	# getProgressIncrease(craftTime) (:134, BuildingComp
	# :1203-1205 `return 1f / baseTime * edelta();`) and
	# warmup lerpDelta toward 1f at 0.02f (:135), else warmup
	# lerpDelta toward 0f (:137); at progress >= 1f (:140)
	# progress wraps (:141), the weighted random pick runs
	# through Arc Mathf.randomSeed(seed++, 0, sum - 1) (:145)
	# over the def results, consume() triggers the consumers
	# (:158), and the picked item offloads when the held count
	# fits itemCapacity (:160-161). source_delta is Time.delta
	# in ticks (1.0 = one tick). The def data is passed
	# explicitly, the way the driver reads it: separator
	# craftTime 35f (Blocks.java:1240) with copper 5 / lead 3 /
	# graphite 2 / titanium 2 (Blocks.java:1233-1239),
	# disassembler craftTime 15f (Blocks.java:1258) with sand 2
	# / graphite 1 / titanium 1 / thorium 1
	# (Blocks.java:1251-1257).
	var separator_results: Array = [{"item": "copper", "amount": 5}, {"item": "lead", "amount": 3}, {"item": "graphite", "amount": 2}, {"item": "titanium", "amount": 2}]
	var disassembler_results: Array = [{"item": "sand", "amount": 2}, {"item": "graphite", "amount": 1}, {"item": "titanium", "amount": 1}, {"item": "thorium", "amount": 1}]

	# progress += 1/craftTime * edelta(): one tick at full
	# efficiency is 1/35, and a doubled timeScale doubles it.
	var progress_frame: Dictionary = {"efficiency": 1.0, "progress": 0.0, "warmup": 0.0, "total_progress": 0.0, "seed": 0, "items": {}}
	var progressed: Dictionary = separator_build_state.source_separator_update_tile_advance_state(progress_frame, 1.0, 1.0, 35.0, separator_results, [], 10)
	var progressed_scaled: Dictionary = separator_build_state.source_separator_update_tile_advance_state(progress_frame, 1.0, 2.0, 35.0, separator_results, [], 10)
	proof["progress_advances_when_efficient"] = is_equal_approx(float(progressed.get("progress", -1.0)), 1.0 / 35.0) and is_equal_approx(float(progressed_scaled.get("progress", -1.0)), 2.0 / 35.0) and bool(progressed.get("crafted", true)) == false

	# warmup lerpDelta toward 1f at 0.02f: one tick from 0 is
	# 0.02, 300 ticks pass 0.99; without efficiency it decays
	# (one tick from 1.0 is 0.98).
	var warmup_frame: Dictionary = {"efficiency": 1.0, "progress": 0.0, "warmup": 0.0, "total_progress": 0.0, "seed": 0, "items": {}}
	var warmed_once: Dictionary = separator_build_state.source_separator_update_tile_advance_state(warmup_frame, 1.0, 1.0, 35.0, separator_results, [], 10)
	for iteration in range(300):
		var advanced: Dictionary = separator_build_state.source_separator_update_tile_advance_state(warmup_frame, 1.0, 1.0, 35.0, separator_results, [], 10)
		warmup_frame["warmup"] = advanced["warmup"]
		warmup_frame["progress"] = advanced["progress"]
	var decay_frame: Dictionary = {"efficiency": 0.0, "progress": 0.0, "warmup": 1.0, "total_progress": 0.0, "seed": 0, "items": {}}
	var decayed: Dictionary = separator_build_state.source_separator_update_tile_advance_state(decay_frame, 1.0, 1.0, 35.0, separator_results, [], 10)
	proof["warmup_approaches_one_when_efficient"] = is_equal_approx(float(warmed_once.get("warmup", -1.0)), 0.02) and float(warmup_frame.get("warmup", 0.0)) > 0.99 and is_equal_approx(float(decayed.get("warmup", -1.0)), 0.98)

	# totalProgress += warmup * delta(): warmup 0.5 over one
	# tick is 0.5, warmup 0 is 0.
	var total_frame: Dictionary = {"efficiency": 1.0, "progress": 0.0, "warmup": 0.5, "total_progress": 0.0, "seed": 0, "items": {}}
	var total_advanced: Dictionary = separator_build_state.source_separator_update_tile_advance_state(total_frame, 1.0, 1.0, 35.0, separator_results, [], 10)
	var total_cold: Dictionary = separator_build_state.source_separator_update_tile_advance_state({"efficiency": 1.0, "progress": 0.0, "warmup": 0.0, "total_progress": 0.0, "seed": 0, "items": {}}, 1.0, 1.0, 35.0, separator_results, [], 10)
	proof["total_progress_advances_with_warmup"] = is_equal_approx(float(total_advanced.get("total_progress", -1.0)), 0.5) and is_equal_approx(float(total_cold.get("total_progress", -1.0)), 0.0)

	# Craft completion on the disassembler: progress 0.99 +
	# 1/15 crosses 1f, so progress wraps to 0.99 + 1/15 - 1,
	# the seed increments (3 -> 4), consume() removes 1 scrap,
	# and the pick draws thorium: seed 3 over the disassembler
	# sum 5 (max 4, a power of two, so the Arc discard path
	# runs) gives index 4, the thorium window [4, 5). The
	# picked thorium offloads into the building's own items
	# (no neighbors yet), and totalProgress gains warmup *
	# delta() = 1.0.
	var craft_frame: Dictionary = {"efficiency": 1.0, "progress": 0.99, "warmup": 1.0, "total_progress": 0.0, "seed": 3, "items": {"scrap": 5}}
	var crafted: Dictionary = separator_build_state.source_separator_update_tile_advance_state(craft_frame, 1.0, 1.0, 15.0, disassembler_results, [{"item": "scrap", "amount": 1}], 20)
	var crafted_items: Dictionary = crafted.get("items", {})
	proof["craft_completes_at_progress_one"] = bool(crafted.get("crafted", false)) and is_equal_approx(float(crafted.get("progress", -1.0)), 0.99 + 1.0 / 15.0 - 1.0) and int(crafted.get("seed", -1)) == 4 and str(crafted.get("picked_item", "")) == "thorium" and int(crafted_items.get("scrap", -1)) == 4 and int(crafted_items.get("thorium", -1)) == 1 and is_equal_approx(float(crafted.get("total_progress", -1.0)), 1.0)

	# The weighted pick + offload on the separator: seed 1
	# over sum 12 gives index 11, the titanium window [10,
	# 12), so titanium offloads into the building's own items
	# and the seed increments (1 -> 2). A frame with no seed
	# key defaults to seed 0, which gives index 4, the copper
	# window [0, 5). When the picked item already fills
	# itemCapacity the offload is skipped (the item stays at
	# 10) but the craft still completes and the seed still
	# increments.
	var pick_frame: Dictionary = {"efficiency": 1.0, "progress": 0.99, "warmup": 0.0, "total_progress": 0.0, "seed": 1, "items": {}}
	var picked: Dictionary = separator_build_state.source_separator_update_tile_advance_state(pick_frame, 1.0, 1.0, 35.0, separator_results, [], 10)
	var picked_items: Dictionary = picked.get("items", {})
	var default_seed_frame: Dictionary = {"efficiency": 1.0, "progress": 0.99, "warmup": 0.0, "total_progress": 0.0, "items": {}}
	var default_picked: Dictionary = separator_build_state.source_separator_update_tile_advance_state(default_seed_frame, 1.0, 1.0, 35.0, separator_results, [], 10)
	var default_items: Dictionary = default_picked.get("items", {})
	var full_frame: Dictionary = {"efficiency": 1.0, "progress": 0.99, "warmup": 0.0, "total_progress": 0.0, "seed": 1, "items": {"titanium": 10}}
	var full_picked: Dictionary = separator_build_state.source_separator_update_tile_advance_state(full_frame, 1.0, 1.0, 35.0, separator_results, [], 10)
	var full_items: Dictionary = full_picked.get("items", {})
	proof["offload_picks_weighted_result"] = str(picked.get("picked_item", "")) == "titanium" and int(picked_items.get("titanium", -1)) == 1 and int(picked.get("seed", -1)) == 2 and str(default_picked.get("picked_item", "")) == "copper" and int(default_items.get("copper", -1)) == 1 and int(default_picked.get("seed", -1)) == 1 and bool(full_picked.get("crafted", false)) and str(full_picked.get("picked_item", "")) == "titanium" and int(full_items.get("titanium", -1)) == 10 and int(full_picked.get("seed", -1)) == 2

	# --- Live tick: the separator is a Separator build with a
	# power consumer (consumePower 1.1f) and a slag consumer
	# (consumeLiquid slag 4f/60f, the N2252 liquid row -- the
	# row folds into the first pass beside the power row, so
	# an empty slag store would fold efficiency to 0), placed
	# live; the tick driver is called directly (as the N2147/
	# N2148/N2149/N2150/N2153/N2154/N2155/N2156/N2157/N2158/
	# N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
	# N2168/N2169/N2200 proofs do), not simulate_factory, so
	# the graph update does not overwrite the stamped
	# power_status -- the write-back itself is already proven
	# by N2142. One 1/60s tick is one source tick: efficiency
	# folds the power min 0.5 (slag-full, so the liquid row
	# folds 1.0 -- the slag is seeded 1.0 on the sprite
	# liquids meta store, the N2281 pattern, and one tick
	# consumes only ~(4/60) x edelta ~= 0.033), progress rises
	# 0.5/35, warmup lerps to 0.02, totalProgress stays 0
	# (warmup was 0), and the fresh frame is seeded from its
	# tile position like created(): Point2.pack(28, 21) =
	# 1835029, and Mathf.randomSeed(1835029, 0,
	# Integer.MAX_VALUE - 1) = 1943898491 (the Arc Rand
	# reference value).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var slag_id: int = int(liquid_id_by_name.get("slag", -1))
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var separator_cell := Vector2i(28, 21)
	var separator := Sprite2D.new()
	game.add_child(separator)
	game.call("record_placed_block", separator, blocks_by_id["separator"], separator_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	separator_build_state.source_separator_bind_frame_state(separator, blocks_by_id["separator"])
	var separator_frame: Dictionary = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	# Slag-full (N2312 fix for the N2252 liquid row): the
	# slag is set on the sprite liquids meta store (the live
	# LiquidModule), which the driver syncs into the frame
	# each tick before the fold (the N2281/N2252 precedent).
	var separator_liquids: Dictionary = separator.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(separator_liquids, slag_id, 1.0)

	# Half power: efficiency folds the power min 0.5, and the
	# advance moves progress / warmup with it.
	separator_frame["power_status"] = 0.5
	separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)
	separator_frame = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	proof["live_tick_advances_progress_and_warmup"] = is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(separator_frame.get("progress", -1.0)), 0.5 / 35.0) and is_equal_approx(float(separator_frame.get("warmup", -1.0)), 0.02) and is_equal_approx(float(separator_frame.get("total_progress", -1.0)), 0.0) and int(separator_frame.get("seed", -1)) == 1943898491

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SeparatorUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
