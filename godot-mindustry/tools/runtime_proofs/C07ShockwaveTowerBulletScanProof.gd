extends Node

const main_scene := preload("res://scenes/Main.tscn")
const shockwave_tower_build_state := preload("res://src/game/SourceShockwaveTowerBuildState.gd")
const geometry := preload("res://src/game/SourceBlockGeometry.gd")
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

	# --- Pure live bullet scan (N2327): the Groups.bullet
	# intersect (ShockwaveTower.java:75-79,
	# `Groups.bullet.intersect(x - range, y - range, range *
	# 2, range * 2, b -> {` / `if(b.team != team &&
	# b.type.hittable){` / `targets.add(b); }`) -- the pure
	# filter the N2247 advance fires from. The scan is a
	# RECTANGLE intersect over the range*2 box -- NOT a
	# circle: a bullet at the rect corner (range, range) is
	# IN even though its distance exceeds range. The
	# intersect visits the spatial bullet group
	# (EntityGroup.java:195,
	# `public void intersect(float x, float y, float width,
	# float height, Cons<? super T> out){`, delegating to
	# `tree.intersect(x, y, width, height, out);`,
	# EntityGroup.java:198); the QuadTree admits a bullet
	# whose HITBOX overlaps the query rect (`hitbox(item);`
	# / `if(tmp.overlaps(x, y, width, height)){`,
	# QuadTree.java:190-191) with the STRICT Rect overlap
	# (`return x < rx + rwidth && x + width > rx && y < ry
	# + rheight && y + height > ry;`, Rect.java:274-276).
	# DOCUMENTED DEVIATION (the N2277 precedent): the port
	# tests the bullet CENTER against the rect (INCLUSIVE
	# bounds -- a center exactly on the edge counts)
	# because the candidate dict carries no hitbox. The
	# range is the class `public float range = 110f;`
	# (ShockwaveTower.java:25), overridden by the def
	# `range = 170f;` (Blocks.java:2043); the pure takes it
	# as a parameter and stays def-agnostic. hittable lives
	# on the bullet TYPE (`public boolean hittable = true;`,
	# BulletType.java:143, default true), carried on the
	# candidate dict; the bullet dict contract (the N2212
	# fixture precedent) is x / y / team / hittable /
	# damage (`@Import float x, y, damage, lastX, lastY,
	# time, lifetime;`, BulletComp.java:31). A missing x or
	# y EXCLUDES the candidate; a missing team reads as the
	# tower's own team (the N2236 precedent -- never
	# enemy); a missing hittable reads as true (the
	# BulletType default). All pure calls below use the def
	# range 170f and tower team 1 unless noted.
	var scan := func(candidates: Array, range_value: float, tower_x: float, tower_y: float, tower_team: int) -> Dictionary:
		return shockwave_tower_build_state.source_shockwave_tower_supplied_bullets_state(candidates, range_value, tower_x, tower_y, tower_team)

	var mixed_candidates: Array = [
		{"id": "center", "team": 2, "hittable": true, "damage": 500.0, "x": 10.0, "y": 10.0},
		{"id": "corner", "team": 2, "hittable": true, "damage": 500.0, "x": 170.0, "y": 170.0},
		{"id": "edge", "team": 2, "hittable": true, "damage": 500.0, "x": 170.0, "y": 0.0},
		{"id": "far_corner", "team": 2, "hittable": true, "damage": 500.0, "x": -170.0, "y": -170.0},
		{"id": "default_hittable", "team": 2, "damage": 500.0, "x": 0.0, "y": 0.0},
		{"id": "x_out", "team": 2, "hittable": true, "damage": 500.0, "x": 171.0, "y": 0.0},
		{"id": "y_out", "team": 2, "hittable": true, "damage": 500.0, "x": 0.0, "y": -171.0},
		{"id": "own_team", "team": 1, "hittable": true, "damage": 500.0, "x": 10.0, "y": 10.0},
		{"id": "missing_team", "hittable": true, "damage": 500.0, "x": 10.0, "y": 10.0},
		{"id": "non_hittable", "team": 2, "hittable": false, "damage": 500.0, "x": 10.0, "y": 10.0},
		{"id": "missing_x", "team": 2, "hittable": true, "damage": 500.0, "y": 10.0},
		{"id": "missing_y", "team": 2, "hittable": true, "damage": 500.0, "x": 10.0},
		null,
	]
	var mixed: Dictionary = scan.call(mixed_candidates, 170.0, 0.0, 0.0, 1)
	var mixed_bullets: Array = mixed.get("bullets", [])

	# Enemy + hittable + in rect is admitted, in candidate
	# order: the center bullet, the rect corner (170, 170)
	# -- IN even though its distance (~240) exceeds range
	# 170, the rect-not-circle pin -- the inclusive edge
	# (170, 0), the far corner (-170, -170), and the bullet
	# with no hittable key (default true, BulletType.
	# java:143). Five admitted out of thirteen candidates.
	proof["scan_admits_enemy_hittable_in_rect"] = mixed_bullets.size() == 5 and str(mixed_bullets[0].get("id", "")) == "center" and str(mixed_bullets[1].get("id", "")) == "corner" and str(mixed_bullets[2].get("id", "")) == "edge" and str(mixed_bullets[3].get("id", "")) == "far_corner" and str(mixed_bullets[4].get("id", "")) == "default_hittable" and is_equal_approx(float(mixed_bullets[1].get("x", -1.0)), 170.0) and is_equal_approx(float(mixed_bullets[1].get("y", -1.0)), 170.0)

	# Out of the rect is excluded on either axis: x 171
	# out, y -171 out, both out (171, 171) out -- while the
	# in-rect control stays. The range parameter is
	# honored: a bullet at (150, 0) is in the def range
	# 170f but out of the class range 110f -- the pure
	# stays def-agnostic.
	var rect_cases: Dictionary = scan.call([
		{"id": "x_out", "team": 2, "hittable": true, "damage": 500.0, "x": 171.0, "y": 0.0},
		{"id": "y_out", "team": 2, "hittable": true, "damage": 500.0, "x": 0.0, "y": 171.0},
		{"id": "both_out", "team": 2, "hittable": true, "damage": 500.0, "x": 171.0, "y": 171.0},
		{"id": "control", "team": 2, "hittable": true, "damage": 500.0, "x": 0.0, "y": 0.0},
	], 170.0, 0.0, 0.0, 1)
	var rect_bullets: Array = rect_cases.get("bullets", [])
	var class_range: Dictionary = scan.call([{"id": "mid", "team": 2, "hittable": true, "damage": 500.0, "x": 150.0, "y": 0.0}], 110.0, 0.0, 0.0, 1)
	var def_range: Dictionary = scan.call([{"id": "mid", "team": 2, "hittable": true, "damage": 500.0, "x": 150.0, "y": 0.0}], 170.0, 0.0, 0.0, 1)
	proof["scan_excludes_out_of_rect"] = rect_bullets.size() == 1 and str(rect_bullets[0].get("id", "")) == "control" and (scan.call([{"id": "x_out", "team": 2, "hittable": true, "damage": 500.0, "x": 171.0, "y": 0.0}], 170.0, 0.0, 0.0, 1).get("bullets", [{}]) as Array).is_empty() and (class_range.get("bullets", [{}]) as Array).is_empty() and (def_range.get("bullets", []) as Array).size() == 1

	# Own team is excluded -- including a candidate with
	# no team key (missing team reads as the tower's own
	# team, the N2236 precedent, never enemy) -- while the
	# enemy control stays. Missing x / y excludes too: a
	# candidate with no position is never admitted.
	var team_cases: Dictionary = scan.call([
		{"id": "own", "team": 1, "hittable": true, "damage": 500.0, "x": 10.0, "y": 10.0},
		{"id": "no_team", "hittable": true, "damage": 500.0, "x": 10.0, "y": 10.0},
		{"id": "enemy", "team": 2, "hittable": true, "damage": 500.0, "x": 10.0, "y": 10.0},
	], 170.0, 0.0, 0.0, 1)
	var team_bullets: Array = team_cases.get("bullets", [])
	var missing_pos: Dictionary = scan.call([
		{"id": "no_x", "team": 2, "hittable": true, "damage": 500.0, "y": 10.0},
		{"id": "no_y", "team": 2, "hittable": true, "damage": 500.0, "x": 10.0},
		null,
		{"id": "control", "team": 2, "hittable": true, "damage": 500.0, "x": 10.0, "y": 10.0},
	], 170.0, 0.0, 0.0, 1)
	var missing_pos_bullets: Array = missing_pos.get("bullets", [])
	proof["scan_excludes_own_team"] = team_bullets.size() == 1 and str(team_bullets[0].get("id", "")) == "enemy" and missing_pos_bullets.size() == 1 and str(missing_pos_bullets[0].get("id", "")) == "control"

	# Non-hittable is excluded (hittable lives on the
	# bullet TYPE, BulletType.java:143) while the hittable
	# control stays; a missing hittable key reads as true
	# (the default_hittable entry in the mixed call above).
	var hittable_cases: Dictionary = scan.call([
		{"id": "solid", "team": 2, "hittable": false, "damage": 500.0, "x": 10.0, "y": 10.0},
		{"id": "control", "team": 2, "hittable": true, "damage": 500.0, "x": 10.0, "y": 10.0},
	], 170.0, 0.0, 0.0, 1)
	var hittable_bullets: Array = hittable_cases.get("bullets", [])
	proof["scan_excludes_non_hittable"] = hittable_bullets.size() == 1 and str(hittable_bullets[0].get("id", "")) == "control" and str(mixed_bullets[4].get("id", "")) == "default_hittable"

	# Empty candidates give an empty scan: no bullets in
	# range means no targets.
	var empty: Dictionary = scan.call([], 170.0, 0.0, 0.0, 1)
	var empty_bullets: Array = empty.get("bullets", [-1])
	proof["empty_candidates_empty"] = empty_bullets.is_empty()

	# --- Live tick: a shockwave-tower placed live; the
	# tick driver is called directly (as the N2247 / N2318
	# proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. The
	# tower sits at cell (28, 21), so its world position
	# is (224, 168) (size 3, offset 0: tile.drawx()/drawy(),
	# BuildingComp.java:124) and the def range 170f gives
	# the rect x in [54, 394], y in [-2, 338]. The frame
	# carries three bullet candidates: an enemy hittable
	# bullet on the tower (in rect), an own-team hittable
	# bullet on the tower (excluded by team), and an enemy
	# hittable bullet at x 500 (out of rect). The tower
	# seeds counter 79.0 (one charge short of reload 80,
	# so the N2187 shouldConsume gate stays open and the
	# charge lands at 80.0), heat 0.5 and its clock at 7.0,
	# so one 1.0-tick step fires the timer (7 + 1 = 8):
	# check_ready reaches the advance, the gate passes
	# (potentialEfficiency 1.0, counter 80 >= 80), the scan
	# admits only the enemy in-rect bullet, and the wave
	# FIRES: the counter resets to 0, heat ends at 1 - 1/80
	# = 0.9875, and the single target takes waveDamage
	# min(160, 160 * 20 / 1) = 160 off its 500 damage
	# (340 left, not removed). The clock resets to 0.0.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var tower_cell := Vector2i(28, 21)
	var tower := Sprite2D.new()
	game.add_child(tower)
	game.call("record_placed_block", tower, blocks_by_id["shockwave-tower"], tower_cell)
	# Pin the tower team explicitly (sharded, 1): the tick
	# reads the team from the sprite meta, and the live key
	# below depends on team 1 being own team (the own-team
	# candidate excluded) and team 2 being enemy (admitted).
	tower.set_meta(geometry.SOURCE_BUILD_TEAM_META_KEY, 1)
	shockwave_tower_build_state.source_shockwave_tower_bind_frame_state(tower, blocks_by_id["shockwave-tower"])
	var tower_frame: Dictionary = tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	tower_frame["timer_check_elapsed"] = 7.0
	tower_frame["reload_counter"] = 79.0
	tower_frame["heat"] = 0.5
	tower_frame["power_status"] = 1.0
	tower_frame["bullet_candidates"] = [
		{"id": "enemy_in", "team": 2, "hittable": true, "damage": 500.0, "x": 224.0, "y": 168.0},
		{"id": "own_in", "team": 1, "hittable": true, "damage": 500.0, "x": 224.0, "y": 168.0},
		{"id": "enemy_out", "team": 2, "hittable": true, "damage": 500.0, "x": 500.0, "y": 168.0},
	]

	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	tower_frame = tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	var live_targets: Array = tower_frame.get("targets", [])
	proof["live_tick_passes_scanned_bullets"] = is_equal_approx(float(tower_frame.get("reload_counter", -1.0)), 0.0) and is_equal_approx(float(tower_frame.get("heat", -1.0)), 0.9875) and is_equal_approx(float(tower_frame.get("timer_check_elapsed", -1.0)), 0.0) and live_targets.size() == 1 and str(live_targets[0].get("id", "")) == "enemy_in" and int(live_targets[0].get("team", -1)) == 2 and is_equal_approx(float(live_targets[0].get("damage", -1.0)), 340.0) and bool(live_targets[0].get("removed", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerBulletScanProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
