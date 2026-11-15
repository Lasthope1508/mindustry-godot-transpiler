extends Node

const main_scene := preload("res://scenes/Main.tscn")
const beam_drill_build_state := preload("res://src/game/SourceBeamDrillBuildState.gd")
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

	# --- Pure liquid row (N2256): ConsumeLiquid.efficiency
	# (ConsumeLiquid.java:42-47, `float ed = build.edelta() *
	# build.efficiencyScale();` / `if(ed <= 0.00000001f) return
	# 0f;` / `return Math.min(build.liquids.get(liquid) /
	# (amount * ed * multiplier.get(build)), 1f);`). ONE pure
	# function serves both the required row and the booster
	# row: the efficiency formula is identical for both, and
	# Java distinguishes them only by which consumer list they
	# join -- the required row folds the first pass
	# (BuildingComp.java:1969-1976) with the
	# shouldConsumePower stop on a starved non-power row
	# (BuildingComp.java:1972), the booster row folds the
	# optional pass (BuildingComp.java:1980-1981), capped by
	# minEfficiency (BuildingComp.java:1986); boost() is
	# optional(true, true) (Consume.java:33-35). In the first
	# pass efficiency is assumed 1f (BuildingComp.java:1965),
	# so edelta is delta() = source_delta * time_scale. The
	# amounts are per def (plasma-bore hydrogen 0.25f/60f
	# booster, Blocks.java:3049; large-plasma-bore hydrogen
	# 0.5f/60f REQUIRED, Blocks.java:3064, + nitrogen 3f/60f
	# booster, Blocks.java:3065).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var hydrogen_id: int = int(liquid_id_by_name.get("hydrogen", -1))
	var nitrogen_id: int = int(liquid_id_by_name.get("nitrogen", -1))
	var content_liquid_ids: Array = liquid_catalog.get("content_liquid_ids", [])
	var plasma_hydrogen_amount: float = 0.25 / 60.0
	var large_hydrogen_amount: float = 0.5 / 60.0
	var large_nitrogen_amount: float = 3.0 / 60.0

	# Required row, starved: half the per-frame demand ->
	# row 0.5, non-power.
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(starved_liquids, hydrogen_id, 0.5 * large_hydrogen_amount)
	var starved_row: Dictionary = beam_drill_build_state.source_beam_drill_liquid_consumer_row_state({"liquids": starved_liquids}, true, hydrogen_id, large_hydrogen_amount, 1.0, 1.0, 1.0)
	proof["required_row_folds_min_when_starved"] = bool(starved_row.get("has_liquid_row", false)) and is_equal_approx(float(starved_row.get("row", {}).get("result", -1.0)), 0.5) and not bool(starved_row.get("row", {}).get("is_power", true))

	# Full: plenty of hydrogen -> row caps at 1.
	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, hydrogen_id, 10.0)
	var full_row: Dictionary = beam_drill_build_state.source_beam_drill_liquid_consumer_row_state({"liquids": full_liquids}, true, hydrogen_id, large_hydrogen_amount, 1.0, 1.0, 1.0)
	proof["row_caps_at_one_when_full"] = bool(full_row.get("has_liquid_row", false)) and is_equal_approx(float(full_row.get("row", {}).get("result", -1.0)), 1.0) and not bool(full_row.get("row", {}).get("is_power", true))

	# --- Live ticks: the beam drills are placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/N2150/
	# N2153/N2154/N2155 proofs do), not simulate_factory, so
	# the graph update does not overwrite the stamped
	# power_status -- the write-back itself is already proven
	# by N2142. The liquid amounts are set on the sprite
	# liquids meta store (the live LiquidModule), which the
	# driver syncs into the frame each tick before the fold
	# (the Fracker proof precedent). Each key gets its own
	# drill: one tick call re-ticks every placed drill, so a
	# key is read right after its drill's first tick, before
	# later ticks deplete its store. N2202: the shouldConsume
	# gate reads facing_amount from the frame
	# (BeamDrill.java:270-272, `facingAmount > 0`); the freshly
	# bound frame defaults it to 0, so seed one facing wall or
	# the gate closes and the efficiency fold reads 0 instead
	# of the liquid min.
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# Plasma-bore, hydrogen at half the per-frame demand, full
	# power: the booster row folds optional 0.5 and does NOT
	# touch the min -- efficiency stays 1.0 (the plasma-bore
	# has NO required liquid row).
	var plasma_cell := Vector2i(28, 20)
	var plasma := Sprite2D.new()
	game.add_child(plasma)
	game.call("record_placed_block", plasma, blocks_by_id["plasma-bore"], plasma_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	beam_drill_build_state.source_beam_drill_bind_frame_state(plasma, blocks_by_id["plasma-bore"])
	var plasma_frame: Dictionary = plasma.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	var plasma_liquids: Dictionary = plasma.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(plasma_liquids, hydrogen_id, 0.5 * plasma_hydrogen_amount)
	plasma_frame["power_status"] = 1.0
	plasma_frame["facing_amount"] = 1
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	plasma_frame = plasma.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	proof["booster_row_folds_optional_when_starved"] = is_equal_approx(float(plasma_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(plasma_frame.get("optional_efficiency", -1.0)), 0.5)

	# Large-plasma-bore, hydrogen at half demand, nitrogen
	# full, full power: the required row folds the min 0.5,
	# and the optional efficiency is CAPPED by that min even
	# though the booster row itself reads 1.0.
	var cap_cell := Vector2i(22, 20)
	var cap_drill := Sprite2D.new()
	game.add_child(cap_drill)
	game.call("record_placed_block", cap_drill, blocks_by_id["large-plasma-bore"], cap_cell)
	beam_drill_build_state.source_beam_drill_bind_frame_state(cap_drill, blocks_by_id["large-plasma-bore"])
	var cap_frame: Dictionary = cap_drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	var cap_liquids: Dictionary = cap_drill.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(cap_liquids, hydrogen_id, 0.5 * large_hydrogen_amount)
	liquid_module_state.source_set_state(cap_liquids, nitrogen_id, 10.0)
	cap_frame["power_status"] = 1.0
	cap_frame["facing_amount"] = 1
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	cap_frame = cap_drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	proof["optional_capped_by_min_efficiency"] = is_equal_approx(float(cap_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(cap_frame.get("optional_efficiency", -1.0)), 0.5)

	# Large-plasma-bore, BOTH liquids at half demand, full
	# power: the required row folds the min 0.5 and the booster
	# row folds the optional 0.5.
	var both_cell := Vector2i(16, 20)
	var both_drill := Sprite2D.new()
	game.add_child(both_drill)
	game.call("record_placed_block", both_drill, blocks_by_id["large-plasma-bore"], both_cell)
	beam_drill_build_state.source_beam_drill_bind_frame_state(both_drill, blocks_by_id["large-plasma-bore"])
	var both_frame: Dictionary = both_drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	var both_liquids: Dictionary = both_drill.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(both_liquids, hydrogen_id, 0.5 * large_hydrogen_amount)
	liquid_module_state.source_set_state(both_liquids, nitrogen_id, 0.5 * large_nitrogen_amount)
	both_frame["power_status"] = 1.0
	both_frame["facing_amount"] = 1
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	both_frame = both_drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	proof["live_tick_folds_both_rows"] = is_equal_approx(float(both_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(both_frame.get("optional_efficiency", -1.0)), 0.5)

	# A fourth large-plasma-bore, both liquids full at full
	# power: efficiency 1, so the second pass removes exactly
	# one frame's demand of EACH liquid (0.5/60 hydrogen,
	# 3/60 nitrogen) from the held 1.0.
	var remover_cell := Vector2i(10, 20)
	var remover := Sprite2D.new()
	game.add_child(remover)
	game.call("record_placed_block", remover, blocks_by_id["large-plasma-bore"], remover_cell)
	beam_drill_build_state.source_beam_drill_bind_frame_state(remover, blocks_by_id["large-plasma-bore"])
	var remover_frame: Dictionary = remover.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	var remover_liquids: Dictionary = remover.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(remover_liquids, hydrogen_id, 1.0)
	liquid_module_state.source_set_state(remover_liquids, nitrogen_id, 1.0)
	remover_frame["power_status"] = 1.0
	remover_frame["facing_amount"] = 1
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	remover_liquids = remover.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	proof["live_tick_removes_liquid_when_running"] = is_equal_approx(float(liquid_module_state.source_get_state(remover_liquids, hydrogen_id).get("amount", -1.0)), 1.0 - large_hydrogen_amount) and is_equal_approx(float(liquid_module_state.source_get_state(remover_liquids, nitrogen_id).get("amount", -1.0)), 1.0 - large_nitrogen_amount)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillLiquidRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
