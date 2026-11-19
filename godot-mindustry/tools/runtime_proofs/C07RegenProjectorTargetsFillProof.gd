extends Node

const main_scene := preload("res://scenes/Main.tscn")
const regen_projector_build_state := preload("res://src/game/SourceRegenProjectorBuildState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
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

	# --- Pure scan (N2277): RegenProjectorBuild.updateTargets()
	# (RegenProjector.java:115-119) with the tileChanges trigger
	# (RegenProjector.java:122-125). The projector center is
	# (224.0, 160.0) -- cell (28, 20) at tilesize 8, the size-3
	# offset 0 (Block.java:761) -- and the rect half-side is
	# 112.0 (range 28, Blocks.java:2012, times tilesize 8,
	# Vars.java:135, halved). The rect is a SQUARE
	# (setCentered, arc Rect.java:49-51), never a circle.
	# damaged() is health < maxHealth - 0.001f
	# (HealthComp.java:47-49). tile_changes defaults to 1
	# (World.java:35) against lastChange -2
	# (RegenProjector.java:110), so a fresh frame refreshes.
	var center_x := 224.0
	var center_y := 160.0
	var in_rect_damaged: Dictionary = {"pos": 7, "team_id": 1, "x": 224.0, "y": 160.0, "block_health": 1000.0, "health": 500.0, "heal_suppressed": false}
	var refreshed: Dictionary = regen_projector_build_state.source_regen_projector_update_targets_state({"last_change": -2, "tile_changes": 1, "targets": [], "team_id": 1}, center_x, center_y, [in_rect_damaged])
	var refreshed_targets: Array = refreshed.get("targets", [])
	var default_frame: Dictionary = regen_projector_build_state.source_regen_projector_update_targets_state({"team_id": 1}, center_x, center_y, [in_rect_damaged])
	proof["targets_refresh_on_tile_change"] = bool(refreshed.get("refreshed", false)) and int(refreshed.get("last_change", -99)) == 1 and refreshed_targets.size() == 1 and int(refreshed_targets[0].get("pos", -1)) == 7 and is_equal_approx(float(refreshed_targets[0].get("block_health", -1.0)), 1000.0) and is_equal_approx(float(refreshed_targets[0].get("health", -1.0)), 500.0) and bool(refreshed_targets[0].get("damaged", false)) and bool(refreshed_targets[0].get("heal_suppressed", true)) == false and bool(default_frame.get("refreshed", false)) and int(default_frame.get("last_change", -99)) == 1

	var seeded_target: Dictionary = {"pos": 9, "block_health": 100.0, "health": 50.0, "damaged": true, "heal_suppressed": false}
	var other_candidate: Dictionary = {"pos": 10, "team_id": 1, "x": 224.0, "y": 160.0, "block_health": 100.0, "health": 100.0, "heal_suppressed": false}
	var unchanged: Dictionary = regen_projector_build_state.source_regen_projector_update_targets_state({"last_change": 3, "tile_changes": 3, "targets": [seeded_target], "team_id": 1}, center_x, center_y, [other_candidate])
	var unchanged_targets: Array = unchanged.get("targets", [])
	var empty_unchanged: Dictionary = regen_projector_build_state.source_regen_projector_update_targets_state({"last_change": 1, "tile_changes": 1, "targets": [], "team_id": 1}, center_x, center_y, [in_rect_damaged])
	proof["targets_unchanged_without_tile_change"] = bool(unchanged.get("refreshed", true)) == false and int(unchanged.get("last_change", -99)) == 3 and unchanged_targets.size() == 1 and int(unchanged_targets[0].get("pos", -1)) == 9 and bool(empty_unchanged.get("refreshed", true)) == false and (empty_unchanged.get("targets", [1]) as Array).is_empty()

	var same_team_in: Dictionary = {"pos": 11, "team_id": 1, "x": 224.0, "y": 160.0, "block_health": 100.0, "health": 100.0, "heal_suppressed": false}
	var other_team_in: Dictionary = {"pos": 12, "team_id": 2, "x": 224.0, "y": 160.0, "block_health": 100.0, "health": 50.0, "heal_suppressed": false}
	var same_team_out_x: Dictionary = {"pos": 13, "team_id": 1, "x": 424.0, "y": 160.0, "block_health": 100.0, "health": 50.0, "heal_suppressed": false}
	var same_team_out_y: Dictionary = {"pos": 14, "team_id": 1, "x": 224.0, "y": -40.0, "block_health": 100.0, "health": 50.0, "heal_suppressed": false}
	var filtered: Dictionary = regen_projector_build_state.source_regen_projector_update_targets_state({"last_change": -2, "tile_changes": 1, "targets": [], "team_id": 1}, center_x, center_y, [same_team_in, other_team_in, same_team_out_x, same_team_out_y])
	var filtered_targets: Array = filtered.get("targets", [])
	proof["targets_only_same_team_in_rect"] = bool(filtered.get("refreshed", false)) and filtered_targets.size() == 1 and int(filtered_targets[0].get("pos", -1)) == 11

	var healthy: Dictionary = {"pos": 21, "team_id": 1, "x": 224.0, "y": 160.0, "block_health": 1000.0, "health": 1000.0, "heal_suppressed": false}
	var damaged: Dictionary = {"pos": 22, "team_id": 1, "x": 232.0, "y": 160.0, "block_health": 1000.0, "health": 500.0, "heal_suppressed": false}
	var near_full: Dictionary = {"pos": 23, "team_id": 1, "x": 240.0, "y": 160.0, "block_health": 1000.0, "health": 999.9995, "heal_suppressed": false}
	var just_damaged: Dictionary = {"pos": 24, "team_id": 1, "x": 248.0, "y": 160.0, "block_health": 1000.0, "health": 999.998, "heal_suppressed": false}
	var suppressed: Dictionary = {"pos": 25, "team_id": 1, "x": 256.0, "y": 160.0, "block_health": 1000.0, "health": 500.0, "heal_suppressed": true}
	var flagged: Dictionary = regen_projector_build_state.source_regen_projector_update_targets_state({"last_change": -2, "tile_changes": 1, "targets": [], "team_id": 1}, center_x, center_y, [healthy, damaged, near_full, just_damaged, suppressed])
	var flagged_targets: Array = flagged.get("targets", [])
	var flagged_by_pos: Dictionary = {}
	for entry in flagged_targets:
		flagged_by_pos[int(entry.get("pos", -1))] = entry
	proof["targets_include_damaged_flag"] = flagged_targets.size() == 5 and bool(flagged_by_pos[21].get("damaged", true)) == false and bool(flagged_by_pos[22].get("damaged", false)) and bool(flagged_by_pos[23].get("damaged", true)) == false and bool(flagged_by_pos[24].get("damaged", false)) and bool(flagged_by_pos[25].get("damaged", false)) and bool(flagged_by_pos[25].get("heal_suppressed", false)) and bool(flagged_by_pos[22].get("heal_suppressed", true)) == false

	var corner_in: Dictionary = {"pos": 31, "team_id": 1, "x": 336.0, "y": 272.0, "block_health": 100.0, "health": 100.0, "heal_suppressed": false}
	var inner_corner: Dictionary = {"pos": 32, "team_id": 1, "x": 324.0, "y": 260.0, "block_health": 100.0, "health": 100.0, "heal_suppressed": false}
	var corner_negative: Dictionary = {"pos": 33, "team_id": 1, "x": 112.0, "y": 48.0, "block_health": 100.0, "health": 100.0, "heal_suppressed": false}
	var just_out_x: Dictionary = {"pos": 34, "team_id": 1, "x": 336.5, "y": 160.0, "block_health": 100.0, "health": 100.0, "heal_suppressed": false}
	var just_out_y: Dictionary = {"pos": 35, "team_id": 1, "x": 224.0, "y": 47.0, "block_health": 100.0, "health": 100.0, "heal_suppressed": false}
	var squared: Dictionary = regen_projector_build_state.source_regen_projector_update_targets_state({"last_change": -2, "tile_changes": 1, "targets": [], "team_id": 1}, center_x, center_y, [corner_in, inner_corner, corner_negative, just_out_x, just_out_y])
	var squared_targets: Array = squared.get("targets", [])
	var squared_pos: Array = []
	for entry in squared_targets:
		squared_pos.append(int(entry.get("pos", -1)))
	proof["rect_is_square_not_circle"] = squared_targets.size() == 3 and squared_pos.has(31) and squared_pos.has(32) and squared_pos.has(33)

	# --- Live tick: a regen-projector placed live with a
	# damaged copper-wall neighbor two tiles away (well inside
	# the 14-tile half-side). The tick driver is called directly
	# (as the N2228 proof does), not simulate_factory. The
	# first tick refreshes: last_change -2 vs tile_changes 1
	# (the frame default), so the scan rebuilds targets from
	# the placed buildings -- the neighbor (damaged) and the
	# projector itself (undamaged, Java predicate `b -> true`)
	# -- and the advance then folds any_targets true over them.
	# The second tick changes nothing (no tile change), so the
	# targets array is identical. No power or hydrogen is
	# seeded: this key proves the fill, not the heal.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# Source-backed fixture health instead of the extracted -1 sentinel.
	# Copper-wall: Blocks.java:1708, 80 * wallHealthMultiplier (4).
	blocks_by_id["copper-wall"].properties["health"] = 320

	var regen_cell := Vector2i(28, 20)
	var regen := Sprite2D.new()
	game.add_child(regen)
	game.call("record_placed_block", regen, blocks_by_id["regen-projector"], regen_cell)
	var wall_cell := Vector2i(30, 20)
	var wall := Sprite2D.new()
	game.add_child(wall)
	game.call("record_placed_block", wall, blocks_by_id["copper-wall"], wall_cell)
	var wall_max_health: float = float(wall.get_meta(placed_block_state.SOURCE_BLOCK_MAX_HEALTH_META_KEY, 0.0))
	placed_block_state.damage_sprite(wall, wall_max_health * 0.5)
	regen_projector_build_state.source_regen_projector_bind_frame_state(regen, blocks_by_id["regen-projector"])
	var regen_frame: Dictionary = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})

	var self_pos: int = block_geometry.tile_pos_state(regen_cell.x, regen_cell.y)
	var wall_pos: int = block_geometry.tile_pos_state(wall_cell.x, wall_cell.y)
	regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)
	regen_frame = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var tick1_targets: Array = regen_frame.get("targets", [])
	var tick1_by_pos: Dictionary = {}
	for entry in tick1_targets:
		tick1_by_pos[int(entry.get("pos", -1))] = entry
	var tick1_ok: bool = int(regen_frame.get("last_change", -99)) == 1 and bool(regen_frame.get("any_targets", false)) and tick1_by_pos.has(wall_pos) and tick1_by_pos.has(self_pos) and bool(tick1_by_pos[wall_pos].get("damaged", false)) and bool(tick1_by_pos[self_pos].get("damaged", true)) == false and is_equal_approx(float(tick1_by_pos[wall_pos].get("health", -1.0)), wall_max_health * 0.5) and is_equal_approx(float(tick1_by_pos[wall_pos].get("block_health", -1.0)), wall_max_health)

	regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)
	regen_frame = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var tick2_targets: Array = regen_frame.get("targets", [])
	var tick2_ok: bool = int(regen_frame.get("last_change", -99)) == 1 and bool(regen_frame.get("any_targets", false)) and tick2_targets == tick1_targets
	proof["live_tick_refreshes_targets"] = tick1_ok and tick2_ok

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RegenProjectorTargetsFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
