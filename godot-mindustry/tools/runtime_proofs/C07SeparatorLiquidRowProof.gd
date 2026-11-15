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

	# --- Pure liquid row (N2252): ConsumeLiquid.efficiency
	# (ConsumeLiquid.java:45-51, `float ed = build.edelta() *
	# build.efficiencyScale();` / `if(ed <= 0.00000001f) return
	# 0f;` / `return Math.min(build.liquids.get(liquid) /
	# (amount * ed * multiplier.get(build)), 1f);`), folded by
	# the first pass (BuildingComp.java:1969-1976) into the min
	# efficiency; a starved non-power row also stops power draw
	# (BuildingComp.java:1972). In the first pass efficiency is
	# assumed 1f (BuildingComp.java:1965), so edelta is delta()
	# = source_delta * time_scale. The separator amount is
	# 4f/60f per frame (Blocks.java:1244); the disassembler
	# 0.12f per frame (Blocks.java:1264) is a catalog read, and
	# the disassembler def waits for its own verification slice.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var slag_id: int = int(liquid_id_by_name.get("slag", -1))
	var content_liquid_ids: Array = liquid_catalog.get("content_liquid_ids", [])
	var separator_amount: float = 4.0 / 60.0

	# Starved: half the per-frame demand -> row 0.5, non-power.
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(starved_liquids, slag_id, 0.5 * separator_amount)
	var starved_row: Dictionary = separator_build_state.source_separator_liquid_consumer_row_state({"liquids": starved_liquids}, true, slag_id, separator_amount, 1.0, 1.0, 1.0)
	proof["row_folds_below_one_when_starved"] = bool(starved_row.get("has_liquid_row", false)) and is_equal_approx(float(starved_row.get("row", {}).get("result", -1.0)), 0.5) and not bool(starved_row.get("row", {}).get("is_power", true))

	# Full: plenty of slag -> row caps at 1.
	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, slag_id, 10.0)
	var full_row: Dictionary = separator_build_state.source_separator_liquid_consumer_row_state({"liquids": full_liquids}, true, slag_id, separator_amount, 1.0, 1.0, 1.0)
	proof["row_caps_at_one_when_full"] = bool(full_row.get("has_liquid_row", false)) and is_equal_approx(float(full_row.get("row", {}).get("result", -1.0)), 1.0) and not bool(full_row.get("row", {}).get("is_power", true))

	# edelta zero: source_delta 0 -> ed 0 -> row 0.
	var zero_row: Dictionary = separator_build_state.source_separator_liquid_consumer_row_state({"liquids": full_liquids}, true, slag_id, separator_amount, 0.0, 1.0, 1.0)
	proof["row_zeroes_when_edelta_zero"] = bool(zero_row.get("has_liquid_row", false)) and is_equal_approx(float(zero_row.get("row", {}).get("result", -1.0)), 0.0) and not bool(zero_row.get("row", {}).get("is_power", true))

	# No liquid store at all -> held amount 0 -> row 0.
	var no_liquid_row: Dictionary = separator_build_state.source_separator_liquid_consumer_row_state({}, true, slag_id, separator_amount, 1.0, 1.0, 1.0)
	proof["row_zeroes_without_liquid"] = bool(no_liquid_row.get("has_liquid_row", false)) and is_equal_approx(float(no_liquid_row.get("row", {}).get("result", -1.0)), 0.0) and not bool(no_liquid_row.get("row", {}).get("is_power", true))

	# --- Live tick: the separator is a Separator build with a
	# power consumer (consumePower 1.1f) and a slag consumer
	# (consumeLiquid slag 4f/60f), placed live; the tick driver
	# is called directly (as the N2147/N2148/N2149/N2150/N2153/
	# N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/N2162/
	# N2163/N2164/N2165/N2166/N2167/N2168 proofs do), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The slag amounts are set on the
	# sprite liquids meta store (the live LiquidModule), which
	# the driver syncs into the frame each tick before the fold
	# (the Fracker proof precedent).
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
	var separator_liquids: Dictionary = separator.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(separator_liquids, slag_id, 0.5 * separator_amount)

	# Half the per-frame slag, full power: efficiency folds the
	# liquid min 0.5 (below the power row 1.0). The second pass
	# then removes amount * folded edelta = (4/60) * 0.5, which
	# is exactly the held slag, so the store empties -- the
	# fold key reads efficiency before that matters.
	separator_frame["power_status"] = 1.0
	separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)
	separator_frame = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	proof["live_tick_folds_liquid_row"] = is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 0.5)

	# A second separator, slag-full at full power: efficiency 1,
	# so the second pass removes exactly one frame's demand
	# (4/60) from the held 1.0 of slag.
	var remover_cell := Vector2i(20, 10)
	var remover := Sprite2D.new()
	game.add_child(remover)
	game.call("record_placed_block", remover, blocks_by_id["separator"], remover_cell)
	separator_build_state.source_separator_bind_frame_state(remover, blocks_by_id["separator"])
	var remover_frame: Dictionary = remover.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var remover_liquids: Dictionary = remover.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(remover_liquids, slag_id, 1.0)
	remover_frame["power_status"] = 1.0
	separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)
	remover_liquids = remover.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	proof["live_tick_removes_liquid_when_running"] = is_equal_approx(float(liquid_module_state.source_get_state(remover_liquids, slag_id).get("amount", -1.0)), 1.0 - separator_amount)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SeparatorLiquidRowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
