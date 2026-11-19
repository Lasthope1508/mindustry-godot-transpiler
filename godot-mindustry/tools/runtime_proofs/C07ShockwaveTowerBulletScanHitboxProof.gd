extends Node

const main_scene := preload("res://scenes/Main.tscn")
const shockwave_tower_build_state := preload("res://src/game/SourceShockwaveTowerBuildState.gd")
const geometry := preload("res://src/game/SourceBlockGeometry.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	# The liquid catalog resolves the consumed liquid's id
	# (the N2331 precedent): the live tick below seeds
	# cyanogen into the sprite liquids store, or the
	# required N2331 row folds efficiency 0 and the tower
	# never charges or fires.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var cyanogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("cyanogen", -1))

	# --- Pure hitbox refinement (N2340): Groups.bullet.
	# intersect is a QuadTree HITBOX overlap query
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
	# A bullet's hitbox is its type hitSize (`public float
	# hitSize = 4;`, BulletType.java:43, set onto the
	# bullet at spawn, `bullet.hitSize = hitSize;`,
	# BulletType.java:970), a hitSize-sided square centered
	# on the bullet (`rect.setCentered(x, y, hitSize,
	# hitSize);`, HitboxComp.java:67). The N2327 rect pure
	# tests the bullet CENTER against the INCLUSIVE rect,
	# so this refinement chains AFTER it (the N2335
	# pattern) and filters hitbox overlap ONLY -- it does
	# not re-filter team / hittable. A missing hit_size
	# reads as the BulletType default 4.0. All pure calls
	# below use the def range 170f and the tower at (0, 0)
	# unless noted, so the query rect is [-170, 170] on
	# both axes.
	var refine := func(candidates: Array, range_value: float, tower_x: float, tower_y: float) -> Dictionary:
		return shockwave_tower_build_state.source_shockwave_tower_supplied_bullets_hitbox_state(candidates, range_value, tower_x, tower_y)

	# A straddling hitbox is admitted even with its center
	# OUTSIDE the rect: (172, 0) with hit_size 8 spans
	# [168, 176] on x, overlapping [-170, 170] strictly;
	# (-175, 0) with hit_size 12 spans [-181, -169],
	# overlapping too. A hitbox exactly TOUCHING the edge
	# is NOT admitted -- (174, 0) with hit_size 8 spans
	# [170, 178], touching at 170 with no strict overlap
	# -- and a far bullet (200, 0) with hit_size 8 is out.
	# The in-rect control stays. Three admitted, in
	# candidate order: the two straddlers, then the
	# control.
	var straddle_cases: Dictionary = refine.call([
		{"id": "straddle_x", "team": 2, "hittable": true, "damage": 500.0, "x": 172.0, "y": 0.0, "hit_size": 8.0},
		{"id": "straddle_neg", "team": 2, "hittable": true, "damage": 500.0, "x": -175.0, "y": 0.0, "hit_size": 12.0},
		{"id": "touching", "team": 2, "hittable": true, "damage": 500.0, "x": 174.0, "y": 0.0, "hit_size": 8.0},
		{"id": "far", "team": 2, "hittable": true, "damage": 500.0, "x": 200.0, "y": 0.0, "hit_size": 8.0},
		{"id": "control", "team": 2, "hittable": true, "damage": 500.0, "x": 0.0, "y": 0.0, "hit_size": 4.0},
	], 170.0, 0.0, 0.0)
	var straddle_bullets: Array = straddle_cases.get("bullets", [])
	proof["refine_admits_straddling_hitbox"] = straddle_bullets.size() == 3 and str(straddle_bullets[0].get("id", "")) == "straddle_x" and str(straddle_bullets[1].get("id", "")) == "straddle_neg" and str(straddle_bullets[2].get("id", "")) == "control"

	# A center exactly on the edge with a real hitbox is
	# admitted -- the hitbox extends inside the rect: the
	# edge (170, 0) with hit_size 4 spans [168, 172], the
	# corner (170, 170) with hit_size 4 spans [168, 172]
	# on both axes, and the far edge (0, -170) with
	# hit_size 4 spans [-172, -168] on y. A bullet at
	# (175, 175) with hit_size 4 spans [173, 177] on both
	# axes -- clear of the rect -- and is dropped.
	var edge_cases: Dictionary = refine.call([
		{"id": "edge", "team": 2, "hittable": true, "damage": 500.0, "x": 170.0, "y": 0.0, "hit_size": 4.0},
		{"id": "corner", "team": 2, "hittable": true, "damage": 500.0, "x": 170.0, "y": 170.0, "hit_size": 4.0},
		{"id": "edge_y", "team": 2, "hittable": true, "damage": 500.0, "x": 0.0, "y": -170.0, "hit_size": 4.0},
		{"id": "far_corner", "team": 2, "hittable": true, "damage": 500.0, "x": 175.0, "y": 175.0, "hit_size": 4.0},
	], 170.0, 0.0, 0.0)
	var edge_bullets: Array = edge_cases.get("bullets", [])
	proof["refine_admits_edge_hitbox"] = edge_bullets.size() == 3 and str(edge_bullets[0].get("id", "")) == "edge" and str(edge_bullets[1].get("id", "")) == "corner" and str(edge_bullets[2].get("id", "")) == "edge_y"

	# The STRICT boundary: a degenerate hitSize-0 hitbox
	# is a POINT, and a point exactly on the rect edge or
	# corner does NOT strictly overlap -- (170, 0),
	# (170, 170) and (-170, 0) with hit_size 0 are all
	# dropped, even though the N2327 rect pure admits
	# their centers (inclusive bounds). A hitSize-0 point
	# strictly INSIDE the rect -- (0, 0) -- is admitted.
	# Only the center bullet survives.
	var degenerate_cases: Dictionary = refine.call([
		{"id": "edge_zero", "team": 2, "hittable": true, "damage": 500.0, "x": 170.0, "y": 0.0, "hit_size": 0.0},
		{"id": "corner_zero", "team": 2, "hittable": true, "damage": 500.0, "x": 170.0, "y": 170.0, "hit_size": 0.0},
		{"id": "edge_neg_zero", "team": 2, "hittable": true, "damage": 500.0, "x": -170.0, "y": 0.0, "hit_size": 0.0},
		{"id": "center_zero", "team": 2, "hittable": true, "damage": 500.0, "x": 0.0, "y": 0.0, "hit_size": 0.0},
	], 170.0, 0.0, 0.0)
	var degenerate_bullets: Array = degenerate_cases.get("bullets", [])
	proof["refine_drops_degenerate_edge_hitbox"] = degenerate_bullets.size() == 1 and str(degenerate_bullets[0].get("id", "")) == "center_zero"

	# A missing hit_size reads as the BulletType default
	# 4.0 (`public float hitSize = 4;`, BulletType.
	# java:43): the edge bullet (170, 0) with no hit_size
	# key is admitted like the explicit hit_size 4.0
	# case, and the straddler (171, 0) with no hit_size
	# key spans [169, 173] under the default and is
	# admitted -- while the same edge center with an
	# EXPLICIT hit_size 0.0 is dropped (the contrast case
	# above pins the default, not a zero).
	var default_cases: Dictionary = refine.call([
		{"id": "edge_no_size", "team": 2, "hittable": true, "damage": 500.0, "x": 170.0, "y": 0.0},
		{"id": "straddle_no_size", "team": 2, "hittable": true, "damage": 500.0, "x": 171.0, "y": 0.0},
		{"id": "edge_zero", "team": 2, "hittable": true, "damage": 500.0, "x": 170.0, "y": 0.0, "hit_size": 0.0},
	], 170.0, 0.0, 0.0)
	var default_bullets: Array = default_cases.get("bullets", [])
	proof["refine_defaults_missing_hit_size"] = default_bullets.size() == 2 and str(default_bullets[0].get("id", "")) == "edge_no_size" and str(default_bullets[1].get("id", "")) == "straddle_no_size"

	# Empty candidates give an empty refinement; a
	# non-Dictionary entry and entries with a missing x
	# or y are excluded the same way (the N2327
	# precedent), while the in-rect control stays.
	var empty: Dictionary = refine.call([], 170.0, 0.0, 0.0)
	var empty_bullets: Array = empty.get("bullets", [-1])
	var malformed: Dictionary = refine.call([
		null,
		{"id": "no_x", "team": 2, "hittable": true, "damage": 500.0, "y": 10.0, "hit_size": 4.0},
		{"id": "no_y", "team": 2, "hittable": true, "damage": 500.0, "x": 10.0, "hit_size": 4.0},
		{"id": "control", "team": 2, "hittable": true, "damage": 500.0, "x": 10.0, "y": 10.0, "hit_size": 4.0},
	], 170.0, 0.0, 0.0)
	var malformed_bullets: Array = malformed.get("bullets", [])
	proof["refine_empty_stays_empty"] = empty_bullets.is_empty() and malformed_bullets.size() == 1 and str(malformed_bullets[0].get("id", "")) == "control"

	# --- Live tick: a shockwave-tower placed live; the
	# tick driver is called directly (as the N2247 / N2318
	# / N2327 proofs do), not simulate_factory, so the
	# graph update does not overwrite the stamped
	# power_status -- the write-back itself is already
	# proven by N2142. The tower sits at cell (28, 21), so
	# its world position is (224, 168) (size 3, offset 0:
	# tile.drawx()/drawy(), BuildingComp.java:124) and the
	# def range 170f gives the rect x in [54, 394], y in
	# [-2, 338]. The frame carries five bullet candidates:
	# a hitSize-0 enemy bullet at the tower center
	# (admitted by both the rect and the refinement -- a
	# point strictly inside overlaps), a hitSize-0 enemy
	# bullet exactly on the rect edge x 394 (admitted by
	# the N2327 inclusive rect, DROPPED by the refinement
	# -- the strict boundary -- the discriminator vs N2327),
	# a hitSize-4 enemy bullet on the same edge (admitted
	# by both -- its hitbox spans [392, 396]), an
	# own-team bullet on the tower (excluded by team), and
	# an enemy bullet at x 500 (out of rect). The tower
	# seeds counter 79.0 (one charge short of reload 80,
	# so the N2187 shouldConsume gate stays open and the
	# charge lands at 80.0), heat 0.5 and its clock at 7.0,
	# so one 1.0-tick step fires the timer (7 + 1 = 8):
	# check_ready reaches the advance, the gate passes
	# (potentialEfficiency 1.0, counter 80 >= 80), the
	# refined list holds the center + edge-four bullets,
	# and the wave FIRES: the counter resets to 0, heat
	# ends at 1 - 1/80 = 0.9875, and the two targets take
	# waveDamage min(160, 160 * 20 / 2) = 160 off their
	# 500 damage (340 left, not removed). The clock resets
	# to 0.0. Cyanogen is seeded at 10.0 on the sprite
	# liquids store (the N2331 pattern -- the required
	# cyanogen row folds efficiency 0 without it, so the
	# tower would never charge or fire).
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
	placed_block_state.source_initialize_building_liquids_state(tower, true, catalog)
	var tower_liquids: Dictionary = tower.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(tower_liquids, cyanogen_id, 10.0)
	tower_frame["timer_check_elapsed"] = 7.0
	tower_frame["reload_counter"] = 79.0
	tower_frame["heat"] = 0.5
	tower_frame["power_status"] = 1.0
	tower_frame["bullet_candidates"] = [
		{"id": "center_zero", "team": 2, "hittable": true, "damage": 500.0, "x": 224.0, "y": 168.0, "hit_size": 0.0},
		{"id": "edge_zero", "team": 2, "hittable": true, "damage": 500.0, "x": 394.0, "y": 168.0, "hit_size": 0.0},
		{"id": "edge_four", "team": 2, "hittable": true, "damage": 500.0, "x": 394.0, "y": 168.0, "hit_size": 4.0},
		{"id": "own_in", "team": 1, "hittable": true, "damage": 500.0, "x": 224.0, "y": 168.0, "hit_size": 4.0},
		{"id": "far_out", "team": 2, "hittable": true, "damage": 500.0, "x": 500.0, "y": 168.0, "hit_size": 4.0},
	]

	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	tower_frame = tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	var live_targets: Array = tower_frame.get("targets", [])
	proof["live_tick_passes_refined_bullets"] = is_equal_approx(float(tower_frame.get("reload_counter", -1.0)), 0.0) and is_equal_approx(float(tower_frame.get("heat", -1.0)), 0.9875) and is_equal_approx(float(tower_frame.get("timer_check_elapsed", -1.0)), 0.0) and live_targets.size() == 2 and str(live_targets[0].get("id", "")) == "center_zero" and str(live_targets[1].get("id", "")) == "edge_four" and int(live_targets[0].get("team", -1)) == 2 and is_equal_approx(float(live_targets[0].get("damage", -1.0)), 340.0) and is_equal_approx(float(live_targets[1].get("damage", -1.0)), 340.0) and bool(live_targets[0].get("removed", true)) == false and bool(live_targets[1].get("removed", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerBulletScanHitboxProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
