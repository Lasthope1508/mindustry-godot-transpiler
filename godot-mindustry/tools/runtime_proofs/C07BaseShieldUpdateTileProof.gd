extends Node

const main_scene := preload("res://scenes/Main.tscn")
const base_shield_build_state := preload("res://src/game/SourceBaseShieldBuildState.gd")
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

	# --- Pure advance (N2236): BaseShieldBuild.updateTile()
	# (BaseShield.java:88-99): the smoothRadius lerpDelta toward
	# radius * efficiency (:89), the rad > 1 engage gate (:93),
	# the Groups.bullet RECTANGLE intersect + bulletConsumer
	# (:27-36, enemy team + absorbable + strict within radius()
	# -- the hit/buildup lines :33-34 are COMMENTED OUT, so
	# absorb is effect-only), and the Units.nearbyEnemies (rad +
	# 10f) + unitConsumer (:38-57, overlapDst = hitSize/2 +
	# radius() - dst; the instakill branch overlapDst > hitSize
	# * 1.5f kills, otherwise vel.setZero + move away overlapDst
	# + 0.01f -- both as PURE RESULTS, never applied to a live
	# bullet or unit). broken/hit are NEVER set live (broken
	# only at the :83 false init and the :167 save read; hit
	# only in the commented-out :33 line), so the advance tracks
	# no broken/hit keys. source_delta is Time.delta in ticks
	# (1.0 = one tick). The building sits at (0, 0) for the pure
	# calls; its team is derelict (0), the enemy team is sharded
	# (1) (Team.java:33-34). The bullet dict contract: x / y,
	# team (missing = own team), absorbable (default true). The
	# unit dict contract: x / y, hit_size (default 0.0). The
	# scan, the absorb check and the repel all run on the SMOOTH
	# radius (radius() = smoothRadius, BaseShield.java:101-103),
	# not the block radius field. Seeding smooth_radius 100 with
	# efficiency 0.5 and radius 200 holds rad at exactly 100.0
	# (target radius * efficiency = 100), so the absorb / repel
	# cases read off round numbers.
	var held_frame := {"efficiency": 0.5, "team_id": 0, "smooth_radius": 100.0}

	# The smooth radius tracks efficiency toward radius *
	# efficiency (BaseShield.java:89, lerpDelta progress 0.05f):
	# from 0 at full efficiency it reaches 10.0 after one tick
	# (200 * 0.05), at half efficiency 5.0, from 100 with no
	# efficiency it decays to 95.0, and the large radius 400
	# reaches 20.0 from 0 at full efficiency. The lerpDelta
	# progress is CLAMPED (Mathf.java:430-432): a 60-tick step
	# jumps all the way to the target (200.0). With rad <= 1
	# the scans never run: smooth 0 at no efficiency absorbs
	# nothing even with an enemy bullet on top of the building,
	# and smooth 0.5 decaying to 0.475 repels nothing even with
	# a unit on top of it.
	var grow: Dictionary = base_shield_build_state.source_base_shield_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "smooth_radius": 0.0}, 1.0, 200.0, 0.0, 0.0, [], [])
	var grow_half: Dictionary = base_shield_build_state.source_base_shield_update_tile_advance_state({"efficiency": 0.5, "team_id": 0, "smooth_radius": 0.0}, 1.0, 200.0, 0.0, 0.0, [], [])
	var decay: Dictionary = base_shield_build_state.source_base_shield_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "smooth_radius": 100.0}, 1.0, 200.0, 0.0, 0.0, [], [])
	var grow_large: Dictionary = base_shield_build_state.source_base_shield_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "smooth_radius": 0.0}, 1.0, 400.0, 0.0, 0.0, [], [])
	var clamp_jump: Dictionary = base_shield_build_state.source_base_shield_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "smooth_radius": 0.0}, 60.0, 200.0, 0.0, 0.0, [], [])
	var gated_bullet: Dictionary = base_shield_build_state.source_base_shield_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "smooth_radius": 0.0}, 1.0, 200.0, 0.0, 0.0, [{"x": 0.0, "y": 0.0, "team": 1, "absorbable": true}], [])
	var gated_unit: Dictionary = base_shield_build_state.source_base_shield_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "smooth_radius": 0.5}, 1.0, 200.0, 0.0, 0.0, [], [{"x": 0.0, "y": 0.0, "hit_size": 20.0}])
	proof["smooth_radius_tracks_efficiency"] = is_equal_approx(float(grow.get("smooth_radius", -1.0)), 10.0) and is_equal_approx(float(grow_half.get("smooth_radius", -1.0)), 5.0) and is_equal_approx(float(decay.get("smooth_radius", -1.0)), 95.0) and is_equal_approx(float(grow_large.get("smooth_radius", -1.0)), 20.0) and is_equal_approx(float(clamp_jump.get("smooth_radius", -1.0)), 200.0) and is_equal_approx(float(gated_bullet.get("smooth_radius", -1.0)), 0.0) and Array(gated_bullet.get("absorbed_bullets", [1])).is_empty() and is_equal_approx(float(gated_unit.get("smooth_radius", -1.0)), 0.475) and Array(gated_unit.get("repelled_units", [1])).is_empty() and Array(gated_unit.get("killed_units", [1])).is_empty()

	# An enemy bullet inside the radius is absorbed (rad 100):
	# at (50, 0) it is in; exactly at the radius (100, 0) it is
	# OUT -- the within is STRICT (Position.java:44-46, dst2 <
	# rad^2); at (150, 0) it is out; a non-absorbable bullet at
	# (50, 0) is not absorbed; a bullet without an absorbable
	# flag defaults to absorbable (BulletType.java:147) and is
	# absorbed at (50, 10).
	var absorb: Dictionary = base_shield_build_state.source_base_shield_update_tile_advance_state(held_frame, 1.0, 200.0, 0.0, 0.0, [{"x": 50.0, "y": 0.0, "team": 1, "absorbable": true}, {"x": 100.0, "y": 0.0, "team": 1, "absorbable": true}, {"x": 150.0, "y": 0.0, "team": 1, "absorbable": true}, {"x": 50.0, "y": 0.0, "team": 1, "absorbable": false}, {"x": 50.0, "y": 10.0, "team": 1}], [])
	var absorbed: Array = absorb.get("absorbed_bullets", [])
	var absorbed_first: Dictionary = absorbed[0] if absorbed.size() > 0 else {}
	var absorbed_second: Dictionary = absorbed[1] if absorbed.size() > 1 else {}
	proof["absorb_blocks_enemy_bullet"] = is_equal_approx(float(absorb.get("smooth_radius", -1.0)), 100.0) and absorbed.size() == 2 and is_equal_approx(float(absorbed_first.get("x", -1.0)), 50.0) and is_equal_approx(float(absorbed_first.get("y", -1.0)), 0.0) and is_equal_approx(float(absorbed_second.get("x", -1.0)), 50.0) and is_equal_approx(float(absorbed_second.get("y", -1.0)), 10.0)

	# A same-team bullet is ignored even inside the radius (rad
	# 100): the same-team bullet at (50, 0) and the bullet
	# without a team at (50, 0) (missing team = own team, never
	# an enemy) are both left alone, while the enemy bullet at
	# (50, 20) in the same call is absorbed -- the filter is the
	# team, not the position.
	var same_team: Dictionary = base_shield_build_state.source_base_shield_update_tile_advance_state(held_frame, 1.0, 200.0, 0.0, 0.0, [{"x": 50.0, "y": 0.0, "team": 0, "absorbable": true}, {"x": 50.0, "y": 0.0, "absorbable": true}, {"x": 50.0, "y": 20.0, "team": 1, "absorbable": true}], [])
	var same_team_absorbed: Array = same_team.get("absorbed_bullets", [])
	var same_team_first: Dictionary = same_team_absorbed[0] if same_team_absorbed.size() > 0 else {}
	proof["absorb_ignores_same_team"] = same_team_absorbed.size() == 1 and is_equal_approx(float(same_team_first.get("x", -1.0)), 50.0) and is_equal_approx(float(same_team_first.get("y", -1.0)), 20.0)

	# An enemy unit overlapping the radius is repelled (rad
	# 100): hitSize 20 at (105, 0) has overlapDst (10 + 100) -
	# 105 = 5, so it is pushed (5.01, 0) -- overlapDst + 0.01f
	# along the direction away from the shield -- and stopped
	# (vel.setZero). HitSize 20 at (50, 0) has overlapDst 60 >
	# hitSize * 1.5 (30), so it is instakilled, not repelled.
	# The boundary is STRICT: hitSize 20 at (80, 0) has
	# overlapDst exactly 30, so it repels (30.01, 0) instead of
	# dying. A unit exactly on the building (hitSize 200 at
	# (0, 0), overlapDst 200 <= 300) repels with a (0, 0)
	# vector -- setLength on a zero vector stays zero
	# (Vec2.java:304-308).
	var repel: Dictionary = base_shield_build_state.source_base_shield_update_tile_advance_state(held_frame, 1.0, 200.0, 0.0, 0.0, [], [{"x": 105.0, "y": 0.0, "hit_size": 20.0}, {"x": 50.0, "y": 0.0, "hit_size": 20.0}, {"x": 80.0, "y": 0.0, "hit_size": 20.0}, {"x": 0.0, "y": 0.0, "hit_size": 200.0}])
	var repelled: Array = repel.get("repelled_units", [])
	var killed: Array = repel.get("killed_units", [])
	var repelled_first: Dictionary = repelled[0] if repelled.size() > 0 else {}
	var repelled_second: Dictionary = repelled[1] if repelled.size() > 1 else {}
	var repelled_third: Dictionary = repelled[2] if repelled.size() > 2 else {}
	var repelled_first_unit: Dictionary = repelled_first.get("unit", {})
	var repelled_second_unit: Dictionary = repelled_second.get("unit", {})
	var killed_first: Dictionary = killed[0] if killed.size() > 0 else {}
	proof["repel_pushes_enemy_unit"] = repelled.size() == 3 and killed.size() == 1 and is_equal_approx(float(repelled_first_unit.get("x", -1.0)), 105.0) and is_equal_approx(float(repelled_first.get("repel_x", -1.0)), 5.01) and is_equal_approx(float(repelled_first.get("repel_y", -1.0)), 0.0) and is_equal_approx(float(repelled_first.get("overlap_dst", -1.0)), 5.0) and bool(repelled_first.get("stopped", false)) and is_equal_approx(float(repelled_second_unit.get("x", -1.0)), 80.0) and is_equal_approx(float(repelled_second.get("repel_x", -1.0)), 30.01) and is_equal_approx(float(repelled_second.get("overlap_dst", -1.0)), 30.0) and is_equal_approx(float(repelled_third.get("repel_x", -1.0)), 0.0) and is_equal_approx(float(repelled_third.get("repel_y", -1.0)), 0.0) and is_equal_approx(float(repelled_third.get("overlap_dst", -1.0)), 200.0) and is_equal_approx(float(killed_first.get("x", -1.0)), 50.0)

	# A unit outside the radius is untouched (rad 100): hitSize
	# 20 at (0, 110) has overlapDst exactly 0 -- not > 0, so no
	# repel and no kill -- and hitSize 20 at (200, 0) is far
	# outside. With rad <= 1 the scans never run either: a unit
	# on top of a collapsed shield (smooth 0, no efficiency) is
	# untouched.
	var outside: Dictionary = base_shield_build_state.source_base_shield_update_tile_advance_state(held_frame, 1.0, 200.0, 0.0, 0.0, [], [{"x": 0.0, "y": 110.0, "hit_size": 20.0}, {"x": 200.0, "y": 0.0, "hit_size": 20.0}])
	var collapsed: Dictionary = base_shield_build_state.source_base_shield_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "smooth_radius": 0.0}, 1.0, 200.0, 0.0, 0.0, [], [{"x": 0.0, "y": 0.0, "hit_size": 20.0}])
	proof["no_repel_outside_radius"] = Array(outside.get("repelled_units", [1])).is_empty() and Array(outside.get("killed_units", [1])).is_empty() and Array(collapsed.get("repelled_units", [1])).is_empty() and Array(collapsed.get("killed_units", [1])).is_empty()

	# --- Live tick: a shield-projector placed live at cell
	# (28, 20) -- building world position (224, 160)
	# (tile.drawx / drawy, BuildingComp.java:124, offset 0 for
	# size 3) -- and a large-shield-projector at cell (32, 20)
	# -- world position (260, 160) (offset 4 for size 4). The
	# tick driver is called directly (as the N2159 proof does),
	# not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. One 1/60s tick is one
	# source tick: at half power the efficiency folds 0.5 and
	# the smooth radius advances 0 -> 5.0 on the
	# shield-projector (target 200 * 0.5 = 100) and 0 -> 10.0
	# on the large-shield-projector (target 400 * 0.5 = 200) --
	# the per-def radius selection. The driver passes EMPTY
	# bullet and enemy-unit lists, so no live absorb/repel
	# happens and all three pure-result lists are empty. A
	# second tick at full power advances 5.0 -> 14.75 and 10.0
	# -> 29.5.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var shield_cell := Vector2i(28, 20)
	var shield := Sprite2D.new()
	game.add_child(shield)
	game.call("record_placed_block", shield, blocks_by_id["shield-projector"], shield_cell)
	# Bind the frames explicitly (the N2149 pattern: the driver
	# binds them on their first tick, but the proof needs the
	# live frame dicts before the tick to stamp power_status and
	# seed the smooth radius on them).
	base_shield_build_state.source_base_shield_bind_frame_state(shield, blocks_by_id["shield-projector"])
	var shield_frame: Dictionary = shield.get_meta(base_shield_build_state.SOURCE_BASE_SHIELD_BUILDING_META_KEY, {})
	var large_cell := Vector2i(32, 20)
	var large_shield := Sprite2D.new()
	game.add_child(large_shield)
	game.call("record_placed_block", large_shield, blocks_by_id["large-shield-projector"], large_cell)
	base_shield_build_state.source_base_shield_bind_frame_state(large_shield, blocks_by_id["large-shield-projector"])
	var large_frame: Dictionary = large_shield.get_meta(base_shield_build_state.SOURCE_BASE_SHIELD_BUILDING_META_KEY, {})

	shield_frame["power_status"] = 0.5
	shield_frame["smooth_radius"] = 0.0
	large_frame["power_status"] = 0.5
	large_frame["smooth_radius"] = 0.0
	base_shield_build_state.source_base_shield_tick_buildings_state(game, 1.0 / 60.0)
	shield_frame = shield.get_meta(base_shield_build_state.SOURCE_BASE_SHIELD_BUILDING_META_KEY, {})
	large_frame = large_shield.get_meta(base_shield_build_state.SOURCE_BASE_SHIELD_BUILDING_META_KEY, {})
	var live_first: bool = is_equal_approx(float(shield_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(shield_frame.get("smooth_radius", -1.0)), 5.0) and Array(shield_frame.get("absorbed_bullets", [1])).is_empty() and Array(shield_frame.get("repelled_units", [1])).is_empty() and Array(shield_frame.get("killed_units", [1])).is_empty() and is_equal_approx(float(large_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(large_frame.get("smooth_radius", -1.0)), 10.0) and Array(large_frame.get("absorbed_bullets", [1])).is_empty() and Array(large_frame.get("repelled_units", [1])).is_empty() and Array(large_frame.get("killed_units", [1])).is_empty()

	shield_frame["power_status"] = 1.0
	large_frame["power_status"] = 1.0
	base_shield_build_state.source_base_shield_tick_buildings_state(game, 1.0 / 60.0)
	shield_frame = shield.get_meta(base_shield_build_state.SOURCE_BASE_SHIELD_BUILDING_META_KEY, {})
	large_frame = large_shield.get_meta(base_shield_build_state.SOURCE_BASE_SHIELD_BUILDING_META_KEY, {})
	proof["live_tick_writes_advance_frame_keys"] = live_first and is_equal_approx(float(shield_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(shield_frame.get("smooth_radius", -1.0)), 14.75) and is_equal_approx(float(large_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(large_frame.get("smooth_radius", -1.0)), 29.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BaseShieldUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
