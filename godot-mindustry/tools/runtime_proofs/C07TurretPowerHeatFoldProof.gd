extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- Turret PowerTurret heat fold (N2270): N2265 added the pure
	# fold function (source_turret_efficiency_multiplier_state,
	# Turret.java:674-679) plus one driver tick in the duo branch
	# with the class defaults (-1.0 / 3.0, guard off) -- but the
	# fold never ran for the two defs that actually need it:
	# afflict and malign are PowerTurrets whose consumption branch
	# is the generic power-consumer branch of
	# source_turret_tick_buildings_state, and the catalog never
	# captured their per-block heatRequirement /
	# maxHeatEfficiency overrides, so the driver had no values to
	# fold with. The fold itself (Turret.java:675-677):
	# `if(heatRequirement > 0){`
	# `efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);`
	# runs inside updateEfficiencyMultiplier(), which
	# updateConsumption() calls (BuildingComp.java:1949 cheating
	# path / :1996 normal path) BEFORE updateTile() (:2274-2278),
	# so it reads the PREVIOUS tick's heatReq. Only afflict
	# (PowerTurret, `heatRequirement = 20f;`, Blocks.java:5122)
	# and malign (PowerTurret, `heatRequirement = 144f;`,
	# Blocks.java:6240) set a positive requirement among turrets
	# -- and both override the cap: `maxHeatEfficiency = 1f;`
	# (Blocks.java:5123 / :6241), NOT the class default 3f
	# (Turret.java:55). A full-heat afflict folds to 1.0x, never
	# 3.0x -- the N2265 proof's cap-3.0 keys used the class
	# default, not the defs' own cap. The live calculateHeat
	# proximity scan still waits for its own slice (live entity
	# scan, BLOCKED, N2263), so frame["heat_req"] stays at its
	# field default 0.0 and a non-cheating afflict / malign with
	# no heat folds to 0 -- the faithful no-heater behavior.

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var afflict_block = blocks_by_id["afflict"]
	var malign_block = blocks_by_id["malign"]

	# --- Catalog capture (Blocks.java:5122-5123, 6240-6241): the
	# block initializer's own heatRequirement / maxHeatEfficiency
	# assignments, else the class defaults (Turret.java:53/:55).
	proof["catalog_afflict_20_1"] = is_equal_approx(float(afflict_block.properties.get("heatRequirement", -1.0)), 20.0) and is_equal_approx(float(afflict_block.properties.get("maxHeatEfficiency", -1.0)), 1.0)
	proof["catalog_malign_144_1"] = is_equal_approx(float(malign_block.properties.get("heatRequirement", -1.0)), 144.0) and is_equal_approx(float(malign_block.properties.get("maxHeatEfficiency", -1.0)), 1.0)

	# --- Pure read (N2270): the class defaults when the catalog
	# carries no override, the per-block values otherwise.
	var default_read: Dictionary = turret_build_state.source_turret_heat_requirement_state(MindustryBlock.new({}))
	proof["read_default_neg1_3"] = is_equal_approx(float(default_read.get("heat_requirement", 0.0)), -1.0) and is_equal_approx(float(default_read.get("max_heat_efficiency", 0.0)), 3.0)
	var afflict_read: Dictionary = turret_build_state.source_turret_heat_requirement_state(afflict_block)
	proof["read_afflict_20_1"] = is_equal_approx(float(afflict_read.get("heat_requirement", 0.0)), 20.0) and is_equal_approx(float(afflict_read.get("max_heat_efficiency", 0.0)), 1.0)
	var malign_read: Dictionary = turret_build_state.source_turret_heat_requirement_state(malign_block)
	proof["read_malign_144_1"] = is_equal_approx(float(malign_read.get("heat_requirement", 0.0)), 144.0) and is_equal_approx(float(malign_read.get("max_heat_efficiency", 0.0)), 1.0)
	var null_read: Dictionary = turret_build_state.source_turret_heat_requirement_state(null)
	proof["read_default_neg1_3"] = bool(proof["read_default_neg1_3"]) and is_equal_approx(float(null_read.get("heat_requirement", 0.0)), -1.0) and is_equal_approx(float(null_read.get("max_heat_efficiency", 0.0)), 3.0)

	# --- Fold with the defs' own cap 1.0 (never the class default
	# 3.0): full heat on afflict folds to 1.0x, half heat halves,
	# full heat on malign folds to 1.0x, half heat halves 0.8 to
	# 0.4, no heat folds a non-cheating team to 0, a cheating
	# team floors the ratio at 1.0 (capped at 1.0).
	var afflict_full: Dictionary = turret_build_state.source_turret_efficiency_multiplier_state(1.0, float(afflict_read.get("heat_requirement", -1.0)), 20.0, false, float(afflict_read.get("max_heat_efficiency", 3.0)))
	proof["fold_afflict_full_heat_1"] = is_equal_approx(float(afflict_full.get("efficiency", -1.0)), 1.0)
	var afflict_half: Dictionary = turret_build_state.source_turret_efficiency_multiplier_state(1.0, float(afflict_read.get("heat_requirement", -1.0)), 10.0, false, float(afflict_read.get("max_heat_efficiency", 3.0)))
	proof["fold_afflict_half_heat"] = is_equal_approx(float(afflict_half.get("efficiency", -1.0)), 0.5)
	var malign_full: Dictionary = turret_build_state.source_turret_efficiency_multiplier_state(1.0, float(malign_read.get("heat_requirement", -1.0)), 144.0, false, float(malign_read.get("max_heat_efficiency", 3.0)))
	proof["fold_malign_full_heat_1"] = is_equal_approx(float(malign_full.get("efficiency", -1.0)), 1.0)
	var malign_half: Dictionary = turret_build_state.source_turret_efficiency_multiplier_state(0.8, float(malign_read.get("heat_requirement", -1.0)), 72.0, false, float(malign_read.get("max_heat_efficiency", 3.0)))
	proof["fold_malign_partial"] = is_equal_approx(float(malign_half.get("efficiency", -1.0)), 0.4)
	var afflict_no_heat: Dictionary = turret_build_state.source_turret_efficiency_multiplier_state(1.0, float(afflict_read.get("heat_requirement", -1.0)), 0.0, false, float(afflict_read.get("max_heat_efficiency", 3.0)))
	proof["fold_afflict_no_heat_zero"] = is_equal_approx(float(afflict_no_heat.get("efficiency", -1.0)), 0.0)
	var afflict_cheating: Dictionary = turret_build_state.source_turret_efficiency_multiplier_state(1.0, float(afflict_read.get("heat_requirement", -1.0)), 0.0, true, float(afflict_read.get("max_heat_efficiency", 3.0)))
	proof["fold_afflict_cheating_floor_one"] = is_equal_approx(float(afflict_cheating.get("efficiency", -1.0)), 1.0)

	# One afflict segment, live on the driver: the generic
	# power-consumer consumption branch reads the catalog
	# requirement / cap and folds with the previous tick's
	# frame heat_req -- 0.0 with no heater (the live
	# calculateHeat scan waits for its own slice, N2263), so a
	# non-cheating afflict folds to 0 -- the faithful
	# no-heater behavior, stamped live on the frame.
	var cell := Vector2i(20, 20)
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["afflict"], cell)
	segment.position = game.source_block_sprite_base_position(blocks_by_id["afflict"], cell)
	turret_build_state.source_turret_bind_frame_state(segment, blocks_by_id["afflict"])

	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	var frame: Dictionary = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	proof["fold_afflict_live"] = frame.has("efficiency") and is_equal_approx(float(frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretPowerHeatFoldProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
