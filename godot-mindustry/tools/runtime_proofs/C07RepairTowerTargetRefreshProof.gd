extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_tower_build_state := preload("res://src/game/SourceRepairTowerBuildState.gd")
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

	# --- Pure target refresh (N2190): the refresh block
	# (RepairTower.java:59, `if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){`) clears the targets (`targets.clear();`), resets the timer (`refresh = 0f;`) and re-queries the nearby damaged units (`Units.nearby(team, x, y, range, u -> {` / `if(u.damaged()){` / `targets.add(u);`); the interval is the class constant (`static final float refreshInterval = 6f;`, RepairTower.java:19). The gate reads the potentialEfficiency stamped by THIS tick's updateConsumption (BuildingComp.java:1989, `potentialEfficiency = efficiency;`), and the query itself is NOT this slice -- the pure function consumes the observed count from the `nearby_damaged_units` frame key, it does not produce it. RED decisions pinned here: absent `refresh` -> 0.0 (Java inits the timer randomly, `public float refresh = Mathf.random(refreshInterval);`, RepairTower.java:47 -- the port takes the deterministic 0.0 start, no `randf` in the pure function); absent `potential_efficiency` -> 0.0 (Java field default, BuildingComp.java:89, `transient float potentialEfficiency;`); absent `nearby_damaged_units` at expiry -> the timer refreshes but `targets_count` is NOT stamped (the N2188 `has_target` precedent).
	var gate_closed: Dictionary = repair_tower_build_state.source_repair_tower_refresh_targets_state({"potential_efficiency": 0.0, "refresh": 2.5}, 1.0)
	proof["refresh_gate_closed_at_zero_efficiency"] = bool(gate_closed.get("refreshed", true)) == false and is_equal_approx(float(gate_closed.get("refresh", -1.0)), 2.5) and bool(gate_closed.get("has_targets_count", true)) == false

	var accumulating: Dictionary = repair_tower_build_state.source_repair_tower_refresh_targets_state({"potential_efficiency": 1.0, "refresh": 2.0}, 1.0)
	proof["refresh_accumulates_below_interval"] = bool(accumulating.get("refreshed", true)) == false and is_equal_approx(float(accumulating.get("refresh", -1.0)), 3.0)

	var crossing: Dictionary = repair_tower_build_state.source_repair_tower_refresh_targets_state({"potential_efficiency": 1.0, "refresh": 5.5, "nearby_damaged_units": 3}, 1.0)
	proof["refresh_crosses_interval_resets_and_stamps_count"] = bool(crossing.get("refreshed", false)) and is_equal_approx(float(crossing.get("refresh", -1.0)), 0.0) and int(crossing.get("targets_count", -1)) == 3 and bool(crossing.get("has_targets_count", false))

	var no_observation: Dictionary = repair_tower_build_state.source_repair_tower_refresh_targets_state({"potential_efficiency": 1.0, "refresh": 5.5}, 1.0)
	proof["refresh_expiry_without_observation_leaves_count_unstamped"] = bool(no_observation.get("refreshed", false)) and is_equal_approx(float(no_observation.get("refresh", -1.0)), 0.0) and bool(no_observation.get("has_targets_count", true)) == false and no_observation.get("targets_count", null) == null

	# --- Live tick: the repair tower is a RepairTower build
	# with a static power consumer (unit-repair-tower,
	# consumePower 1f, Blocks.java:6582), placed live; the tick
	# driver is called directly (as the N2176 proof does), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The driver calls the refresh
	# AFTER apply_update_consumption_state (the Java order,
	# BuildingComp.java:2274 updateConsumption() before :2277
	# updateTile()), so the first live tick advances the timer
	# by one delta once the same-tick consumption stamp exists;
	# the pure no-advance case (absent potential_efficiency)
	# is covered by refresh_gate_closed_at_zero_efficiency.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var repair_tower_cell := Vector2i(28, 21)
	var repair_tower := Sprite2D.new()
	game.add_child(repair_tower)
	game.call("record_placed_block", repair_tower, blocks_by_id["unit-repair-tower"], repair_tower_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	repair_tower_build_state.source_repair_tower_bind_frame_state(repair_tower, blocks_by_id["unit-repair-tower"])
	var repair_tower_frame: Dictionary = repair_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})

	# Full power: 60 ticks of 1/60s accumulate exactly 1.0s of
	# refresh, well below the 6.0s interval, so no refresh fires.
	repair_tower_frame["power_status"] = 1.0
	for iteration in range(60):
		repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)
	repair_tower_frame = repair_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	proof["live_refresh_accumulates_at_full_power"] = is_equal_approx(float(repair_tower_frame.get("refresh", -1.0)), 1.0)

	# No power: potential_efficiency 0, the timer freezes.
	repair_tower_frame["power_status"] = 0.0
	for iteration in range(60):
		repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)
	repair_tower_frame = repair_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	proof["live_refresh_frozen_at_no_power"] = is_equal_approx(float(repair_tower_frame.get("refresh", -1.0)), 1.0)

	# First tick: a freshly bound tower frame carries no
	# accumulated refresh (absent folds to 0.0) and no stamped
	# count -- the deterministic 0.0 start (Java inits the
	# timer randomly, `public float refresh = Mathf.random(refreshInterval);`, RepairTower.java:47); the first refresh fires only after exactly 6s of powered operation. The first driver tick itself advances the timer by one delta once the same-tick consumption stamp exists (the Java order above), which live_refresh_accumulates_at_full_power covers.
	var fresh_cell := Vector2i(30, 21)
	var fresh_tower := Sprite2D.new()
	game.add_child(fresh_tower)
	game.call("record_placed_block", fresh_tower, blocks_by_id["unit-repair-tower"], fresh_cell)
	repair_tower_build_state.source_repair_tower_bind_frame_state(fresh_tower, blocks_by_id["unit-repair-tower"])
	var fresh_frame: Dictionary = fresh_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	proof["live_first_tick_no_advance"] = is_equal_approx(float(fresh_frame.get("refresh", 0.0)), 0.0) and not fresh_frame.has("targets_count")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTowerTargetRefreshProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
