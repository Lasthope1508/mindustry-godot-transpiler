extends Node

const main_scene := preload("res://scenes/Main.tscn")
const shockwave_tower_build_state := preload("res://src/game/SourceShockwaveTowerBuildState.gd")
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

	# --- Pure bullet scan (N2195): ShockwaveTowerBuild.updateTile
	# clears its targets and scans the bullet groups inside the
	# range box (ShockwaveTower.java:74, `targets.clear();` with
	# :75, `Groups.bullet.intersect(x - range, y - range, range *
	# 2, range * 2, b -> {` and :76, `if(b.team != team &&
	# b.type.hittable){` and :77, `targets.add(b);`) over the
	# target list (ShockwaveTower.java:68, `public Seq<Bullet>
	# targets = new Seq<>();`). The scan is what N2194's fire
	# gate reads as the observed `targets_count`
	# (ShockwaveTower.java:81, `if(targets.size > 0){`). The port
	# has no live bullet query, so the pure function consumes an
	# observed bullet list (`observed_bullets`, an array of dicts
	# with team/hittable/x/y, world coords) and counts the enemy
	# hittable bullets inside the range box (x +/- range, y +/-
	# range, range 170f per-def, Blocks.java:2043, overriding the
	# class default 110f, ShockwaveTower.java:25). The tower's
	# world position comes from the frame's `x`/`y` keys and its
	# team from `team_id`. The range box is a point-in-box test
	# against the Java intersect rect -- the port models no bullet
	# hitSize, so the rect overlap is approximated by the bullet
	# point. Absent `observed_bullets` (or absent `x`/`y`/
	# `team_id`) means "no observation yet": the function returns
	# targets_count null and has_targets_count false, and the
	# driver stamps nothing (the N2190 precedent) -- never a
	# fabricated 0. A present-but-empty list IS an observation and
	# stamps 0. No randomness is involved, so the scene seeds no
	# RNG.
	# The pure keys share one tower (world 0, 0, team 1) and one
	# base bullet set: enemy hittable at (100, 0), (-170, 0) and
	# (0, 170) -- the last two on the box edge, still inside --
	# plus enemy hittable at (150, 150), inside the 170 box but
	# OUTSIDE the 170 circle (sqrt(150^2 + 150^2) ~= 212), which
	# pins the box shape against a circle test.
	var base_bullets: Array = [
		{"team": 2, "hittable": true, "x": 100.0, "y": 0.0},
		{"team": 2, "hittable": true, "x": -170.0, "y": 0.0},
		{"team": 2, "hittable": true, "x": 0.0, "y": 170.0},
		{"team": 2, "hittable": true, "x": 150.0, "y": 150.0},
	]

	# Counts enemy hittable bullets in range: all four base
	# bullets count -- targets_count 4, has_targets_count true.
	var counted: Dictionary = shockwave_tower_build_state.source_shockwave_tower_bullet_scan_state({"x": 0.0, "y": 0.0, "team_id": 1, "observed_bullets": base_bullets})
	proof["counts_enemy_hittable_in_range"] = bool(counted.get("has_targets_count", false)) == true and int(counted.get("targets_count", -1)) == 4

	# Excludes same-team bullets: the base set plus a same-team
	# (team 1) hittable bullet at the tower itself -- still 4.
	var same_team_bullets: Array = base_bullets.duplicate()
	same_team_bullets.append({"team": 1, "hittable": true, "x": 0.0, "y": 0.0})
	var same_team: Dictionary = shockwave_tower_build_state.source_shockwave_tower_bullet_scan_state({"x": 0.0, "y": 0.0, "team_id": 1, "observed_bullets": same_team_bullets})
	proof["excludes_same_team_bullets"] = bool(same_team.get("has_targets_count", false)) == true and int(same_team.get("targets_count", -1)) == 4

	# Excludes non-hittable bullets: the base set plus an enemy
	# (team 2) non-hittable bullet at the tower itself -- still 4.
	var non_hittable_bullets: Array = base_bullets.duplicate()
	non_hittable_bullets.append({"team": 2, "hittable": false, "x": 0.0, "y": 0.0})
	var non_hittable: Dictionary = shockwave_tower_build_state.source_shockwave_tower_bullet_scan_state({"x": 0.0, "y": 0.0, "team_id": 1, "observed_bullets": non_hittable_bullets})
	proof["excludes_non_hittable_bullets"] = bool(non_hittable.get("has_targets_count", false)) == true and int(non_hittable.get("targets_count", -1)) == 4

	# Excludes bullets outside the range box: the base set plus
	# enemy hittable bullets at (171, 0), (0, -171) and (171,
	# 171) -- each one unit past one box edge -- still 4.
	var outside_bullets: Array = base_bullets.duplicate()
	outside_bullets.append({"team": 2, "hittable": true, "x": 171.0, "y": 0.0})
	outside_bullets.append({"team": 2, "hittable": true, "x": 0.0, "y": -171.0})
	outside_bullets.append({"team": 2, "hittable": true, "x": 171.0, "y": 171.0})
	var outside: Dictionary = shockwave_tower_build_state.source_shockwave_tower_bullet_scan_state({"x": 0.0, "y": 0.0, "team_id": 1, "observed_bullets": outside_bullets})
	proof["excludes_bullets_outside_range_box"] = bool(outside.get("has_targets_count", false)) == true and int(outside.get("targets_count", -1)) == 4

	# Absent observed_bullets stamps nothing: the frame carries
	# x/y/team_id but NO observed_bullets key at all -- targets_count
	# is null and has_targets_count is false, so the driver stamps
	# nothing and N2194 keeps reading absent as no fire.
	var absent: Dictionary = shockwave_tower_build_state.source_shockwave_tower_bullet_scan_state({"x": 0.0, "y": 0.0, "team_id": 1})
	proof["absent_observed_bullets_stamps_nothing"] = bool(absent.get("has_targets_count", true)) == false and absent.get("targets_count", -1) == null

	# --- Live tick: the shockwave tower is a ShockwaveTower build
	# with a static power consumer (shockwave-tower,
	# consumePower 100f / 60f, Blocks.java:2042), placed live; the tick
	# driver is called directly (as the N2177/N2191/N2192/N2193/N2194
	# proofs do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back itself
	# is already proven by N2142. The driver calls the scan AFTER
	# the N2192 charge and BEFORE the N2194 fire (the Java order,
	# the scan :74-79 runs inside the fire gate before the
	# targets.size check :81), deriving the tower world position
	# from the placement cell (cell (28, 21), size 3, tilesize 8,
	# offset 0 -- world (224, 168)) and stamping
	# frame["targets_count"] only when the scan reports an
	# observation. The tower team is 1 (record_placed_block
	# default, SOURCE_TEAM_SHARDED_ID).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var shockwave_tower_cell := Vector2i(28, 21)
	var shockwave_tower := Sprite2D.new()
	game.add_child(shockwave_tower)
	game.call("record_placed_block", shockwave_tower, blocks_by_id["shockwave-tower"], shockwave_tower_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	shockwave_tower_build_state.source_shockwave_tower_bind_frame_state(shockwave_tower, blocks_by_id["shockwave-tower"])
	var shockwave_tower_frame: Dictionary = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})

	# Live driver stamps targets_count: observed_bullets stamped
	# on the frame before the tick (the observed-only input, like
	# N2194's targets_count=3) -- one enemy hittable bullet in
	# range at (324, 168) (tower world (224, 168) + 100), one
	# same-team hittable bullet at the tower, one enemy
	# non-hittable bullet at the tower, one enemy hittable
	# bullet out of range at (395, 168) (+171) -- so the driver
	# stamps targets_count 1. The reload counter is preset to
	# 80.0 (per-def reload, Blocks.java:2044) so the N2200 timer
	# check is due on the fresh frame and the scan runs (Java
	# :74-79 live inside the :73 if, so the scan runs only on a
	# due timer tick); the N2194 fire fires this tick (PE 1.0,
	# counter at reload, targets 1) but the fire does not touch
	# the stamped targets_count.
	shockwave_tower_frame["observed_bullets"] = [
		{"team": 2, "hittable": true, "x": 324.0, "y": 168.0},
		{"team": 1, "hittable": true, "x": 224.0, "y": 168.0},
		{"team": 2, "hittable": false, "x": 224.0, "y": 168.0},
		{"team": 2, "hittable": true, "x": 395.0, "y": 168.0},
	]
	shockwave_tower_frame["power_status"] = 1.0
	shockwave_tower_frame["enabled"] = true
	shockwave_tower_frame["reload_counter"] = 80.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	proof["live_driver_stamps_targets_count"] = int(shockwave_tower_frame.get("targets_count", -1)) == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerBulletScanProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
