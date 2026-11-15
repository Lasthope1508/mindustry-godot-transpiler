extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_tower_build_state := preload("res://src/game/SourceRepairTowerBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")


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

	# --- Pure live scan (N2306): the Units.nearby refill
	# (RepairTower.java:62-66, `Units.nearby(team, x, y,
	# range, u -> {` / `if(u.damaged()){` /
	# `targets.add(u); }`) -- the pure filter the N2227
	# advance refills from at refresh. The range predicate
	# is NOT a plain distance <= range: Units.nearby
	# (Units.java:445-451) admits a unit when
	# `unit.within(x, y, radius + unit.hitSize/2f)`, and
	# within is a STRICT dst2 < (radius + hitSize/2)^2
	# (Position.java:44-46, `return Mathf.dst2(getX(),
	# getY(), x, y) < dst*dst;`) -- so a unit exactly at
	# range + hitSize/2 is OUT, and a unit with a body
	# counts its half hitSize. Damaged is `return health <
	# maxHealth - 0.001f;` (HealthComp.java:47-49). The
	# range is the def 100f (Blocks.java:6579; the class
	# default is 80f, RepairTower.java:21). A candidate
	# dict carries health / max_health plus distance (the
	# CENTER distance) or x / y (world position); a
	# missing health, max_health, or distance-or-x/y key
	# EXCLUDES the candidate, while a missing hit_size
	# reads as 0.0 (a point unit). All pure calls below
	# use the def range 100f unless noted.
	var mixed_candidates: Array = [
		{"type": "dart", "health": 50.0, "max_health": 100.0, "distance": 50.0},
		{"type": "flare", "health": 100.0, "max_health": 100.0, "distance": 50.0},
		{"type": "horizon", "health": 10.0, "max_health": 100.0, "distance": 150.0},
		{"type": "mega", "health": 10.0, "max_health": 100.0, "distance": 100.0, "hit_size": 2.0},
		{"type": "oct", "health": 10.0, "max_health": 100.0, "distance": 100.0},
		{"type": "alpha", "health": 99.9995, "max_health": 100.0, "distance": 10.0},
		{"type": "beta", "health": 99.998, "max_health": 100.0, "distance": 10.0},
	]
	var mixed: Dictionary = repair_tower_build_state.source_repair_tower_supplied_damaged_state(mixed_candidates, 100.0)
	var mixed_supplied: Array = mixed.get("supplied_damaged", [])

	# The x/y form measures from the tower position
	# params: a tower at (100, 100) sees the unit at
	# (160, 180) exactly at range 100 (60-80-100 triangle)
	# -- STRICTLY out -- while (160, 179) is inside and
	# (100, 100) is on top of the tower.
	var positioned_candidates: Array = [
		{"type": "dart", "health": 50.0, "max_health": 100.0, "x": 160.0, "y": 180.0},
		{"type": "flare", "health": 50.0, "max_health": 100.0, "x": 160.0, "y": 179.0},
		{"type": "horizon", "health": 50.0, "max_health": 100.0, "x": 100.0, "y": 100.0},
	]
	var positioned: Dictionary = repair_tower_build_state.source_repair_tower_supplied_damaged_state(positioned_candidates, 100.0, 100.0, 100.0)
	var positioned_supplied: Array = positioned.get("supplied_damaged", [])

	# The range parameter is honored: a damaged unit at
	# distance 90 is out of the class range 80f but in the
	# def range 100f -- the pure stays def-agnostic.
	var class_range: Dictionary = repair_tower_build_state.source_repair_tower_supplied_damaged_state([{"type": "dart", "health": 50.0, "max_health": 100.0, "distance": 90.0}], 80.0)
	var def_range: Dictionary = repair_tower_build_state.source_repair_tower_supplied_damaged_state([{"type": "dart", "health": 50.0, "max_health": 100.0, "distance": 90.0}], 100.0)
	proof["damaged_in_range_supplied"] = mixed_supplied.size() == 3 and str(mixed_supplied[0].get("type", "")) == "dart" and str(mixed_supplied[1].get("type", "")) == "mega" and str(mixed_supplied[2].get("type", "")) == "beta" and int(mixed.get("damaged_count", -1)) == 3 and int(mixed.get("candidate_count", -1)) == 7 and positioned_supplied.size() == 2 and str(positioned_supplied[0].get("type", "")) == "flare" and str(positioned_supplied[1].get("type", "")) == "horizon" and int(positioned.get("damaged_count", -1)) == 2 and int(def_range.get("damaged_count", -1)) == 1

	# Healthy units are excluded: the full-health flare
	# and the alpha at 99.9995 (above the maxHealth -
	# 0.001f line, 99.999) count as healthy, while the beta
	# at 99.998 counts as damaged. Missing health data
	# excludes without the healthy bucket: the dart with
	# no health key, the horizon with no max_health key,
	# and the null entry are all out, and the healthy
	# count stays 0.
	var missing_candidates: Array = [
		{"type": "dart", "distance": 10.0},
		{"type": "flare", "health": 50.0, "max_health": 100.0},
		{"type": "horizon", "health": 50.0, "distance": 10.0},
		null,
		{"type": "mega", "health": 50.0, "max_health": 100.0, "distance": 10.0},
	]
	var missing: Dictionary = repair_tower_build_state.source_repair_tower_supplied_damaged_state(missing_candidates, 100.0)
	var missing_supplied: Array = missing.get("supplied_damaged", [])
	proof["healthy_excluded"] = int(mixed.get("healthy_excluded_count", -1)) == 2 and int(missing.get("healthy_excluded_count", -1)) == 0 and int(missing.get("damaged_count", -1)) == 1 and missing_supplied.size() == 1 and str(missing_supplied[0].get("type", "")) == "mega" and int(missing.get("candidate_count", -1)) == 5

	# Out-of-range units are excluded: the horizon at 150
	# and the oct at exactly 100 with no hitSize (the
	# STRICT boundary -- 100^2 < 100^2 is false) count as
	# out of range, while the mega at exactly 100 WITH
	# hitSize 2 counts as in range (reach 101). The
	# positioned dart at exactly 100 via x/y is out the
	# same way, and the class-range scan excludes the unit
	# at 90. Missing distance data excludes without the
	# out-of-range bucket (the flare with no distance key
	# in the missing case above).
	proof["out_of_range_excluded"] = int(mixed.get("out_of_range_count", -1)) == 2 and int(positioned.get("out_of_range_count", -1)) == 1 and int(class_range.get("out_of_range_count", -1)) == 1 and int(class_range.get("damaged_count", -1)) == 0 and int(missing.get("out_of_range_count", -1)) == 0

	# Empty candidates give an empty refill: no units in
	# range means no targets, all counts zero.
	var empty: Dictionary = repair_tower_build_state.source_repair_tower_supplied_damaged_state([], 100.0)
	var empty_supplied: Array = empty.get("supplied_damaged", [-1])
	proof["empty_candidates_empty"] = empty_supplied.is_empty() and int(empty.get("damaged_count", -1)) == 0 and int(empty.get("candidate_count", -1)) == 0 and int(empty.get("healthy_excluded_count", -1)) == 0 and int(empty.get("out_of_range_count", -1)) == 0

	# --- Live tick: a repair tower placed live; the tick
	# driver is called directly (as the N2227/N2250 proofs
	# do), not simulate_factory, so the graph update does
	# not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. The
	# frame carries the unit candidates (the N2226 frame
	# input): one damaged dart in range, one healthy flare
	# in range. Refresh sits at 5.0 with full power and
	# full ozone (0.1, the N2250 Tower B fill -- without
	# ozone the liquid row would fold potentialEfficiency
	# to 0 and the refresh would never fire), so one
	# 1/60s tick fires the refresh: the targets clear and
	# refill from the scan -- the dart lands, the flare
	# does not -- and the scan result is stamped onto
	# frame["supplied_damaged"]. Efficiency reads 0.0:
	# the gate read the EMPTY pre-refresh targets at fold
	# time (Java-exact -- updateConsumption runs before
	# updateTile, BuildingComp.java:2274), while
	# potentialEfficiency keeps the folded min 1.0
	# (BuildingComp.java:1989, assigned before the
	# !update zeroing).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var ozone_id: int = int(liquid_catalog["liquid_id_by_name"].get("ozone", -1))
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var repair_tower_cell := Vector2i(28, 20)
	var repair_tower := Sprite2D.new()
	game.add_child(repair_tower)
	game.call("record_placed_block", repair_tower, blocks_by_id["unit-repair-tower"], repair_tower_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the candidates on it).
	repair_tower_build_state.source_repair_tower_bind_frame_state(repair_tower, blocks_by_id["unit-repair-tower"])
	var repair_tower_frame: Dictionary = repair_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	var repair_tower_liquids: Dictionary = repair_tower.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(repair_tower_liquids, ozone_id, 0.1)

	repair_tower_frame["targets"] = []
	repair_tower_frame["refresh"] = 5.0
	repair_tower_frame["power_status"] = 1.0
	repair_tower_frame["unit_candidates"] = [
		{"type": "dart", "health": 50.0, "max_health": 100.0, "distance": 50.0},
		{"type": "flare", "health": 100.0, "max_health": 100.0, "distance": 50.0},
	]
	repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)
	repair_tower_frame = repair_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	var live_targets: Array = repair_tower_frame.get("targets", [])
	var live_supplied: Array = repair_tower_frame.get("supplied_damaged", [])
	proof["live_tick_refills_targets"] = is_equal_approx(float(repair_tower_frame.get("refresh", -1.0)), 0.0) and live_targets.size() == 1 and str(live_targets[0].get("type", "")) == "dart" and live_supplied.size() == 1 and str(live_supplied[0].get("type", "")) == "dart" and is_equal_approx(float(repair_tower_frame.get("potential_efficiency", -1.0)), 1.0) and is_equal_approx(float(repair_tower_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(repair_tower_frame.get("total_progress", -1.0)), 1.0 / 120.0)

	# The N2213 gate opens once the refill lands: the pure
	# gate reads the refilled frame targets (one dart), so
	# should_consume is true -- the tower consumes from the
	# next tick on.
	var gate: Dictionary = repair_tower_build_state.source_repair_tower_should_consume_state(repair_tower_frame)
	proof["gate_opens_with_target"] = bool(gate.get("should_consume", false)) == true and int(gate.get("target_count", -1)) == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTowerLiveScanProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
