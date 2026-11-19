extends Node

const main_scene := preload("res://scenes/Main.tscn")
const regen_projector_build_state := preload("res://src/game/SourceRegenProjectorBuildState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
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

	# --- Pure narrow (N2338): the updateTargets hitbox +
	# privileged refinement chained AFTER the N2277 rect scan
	# (BlockIndexer.java:364-380). Java's eachBlock intersects
	# the team buildingTree quadtree with the rect: the
	# QuadTree tests each building's HITBOX against the rect
	# (QuadTree.java:190-191) with Rect.overlaps STRICT
	# (Rect.java:274-276), so a building whose hitbox
	# straddles the rect edge counts but one merely TOUCHING
	# the edge does not; privileged blocks are excluded
	# (BlockIndexer.java:372). The projector center is
	# (224.0, 160.0) -- cell (28, 20) at tilesize 8, the size-3
	# offset 0 (Block.java:761) -- and the rect half-side is
	# 112.0 (range 28, Blocks.java:2012, times tilesize 8,
	# Vars.java:135, halved). The pure calls below chain
	# through the real N2277 scan, exactly like the tick
	# does: scan first, then narrow on the scanned targets
	# plus the same raw candidates.
	var center_x := 224.0
	var center_y := 160.0
	var fresh_frame: Dictionary = {"last_change": -2, "tile_changes": 1, "targets": [], "team_id": 1}
	var in_rect_damaged: Dictionary = {"pos": 7, "team_id": 1, "x": 224.0, "y": 160.0, "hit_size": 8.0, "block_health": 1000.0, "health": 500.0, "heal_suppressed": false}
	var straddler_size3: Dictionary = {"pos": 8, "team_id": 1, "x": 344.0, "y": 160.0, "hit_size": 24.0, "block_health": 1000.0, "health": 500.0, "heal_suppressed": false}
	var straddler_size2: Dictionary = {"pos": 9, "team_id": 1, "x": 340.0, "y": 160.0, "hit_size": 16.0, "block_health": 100.0, "health": 100.0, "heal_suppressed": false}
	var straddler_y: Dictionary = {"pos": 11, "team_id": 1, "x": 224.0, "y": 276.0, "hit_size": 16.0, "block_health": 100.0, "health": 100.0, "heal_suppressed": false}
	var far_out: Dictionary = {"pos": 10, "team_id": 1, "x": 360.0, "y": 160.0, "hit_size": 16.0, "block_health": 100.0, "health": 50.0, "heal_suppressed": false}
	var scanned: Dictionary = regen_projector_build_state.source_regen_projector_update_targets_state(fresh_frame, center_x, center_y, [in_rect_damaged, straddler_size3, straddler_size2, straddler_y, far_out])
	var narrowed: Dictionary = regen_projector_build_state.source_regen_projector_update_targets_narrow_state(scanned.get("targets", []), [in_rect_damaged, straddler_size3, straddler_size2, straddler_y, far_out], 1, center_x, center_y)
	var narrowed_targets: Array = narrowed.get("targets", [])
	var narrowed_by_pos: Dictionary = {}
	for entry in narrowed_targets:
		narrowed_by_pos[int(entry.get("pos", -1))] = entry
	# The size-3 straddler's center is dx 120 > 112 (the
	# N2277 rect drops it) but its hitbox [332, 356] overlaps
	# the rect edge 336 (120 < 112 + 12); the size-2
	# straddlers are dx/dy 116 < 112 + 8. The far building is
	# dx 136 > 112 + 8 and stays out. Straddler entries are
	# rebuilt in the N2277 format (damaged with the 0.001f
	# epsilon, HealthComp.java:47-49).
	proof["narrow_admits_hitbox_straddler"] = narrowed_targets.size() == 4 and narrowed_by_pos.has(7) and narrowed_by_pos.has(8) and narrowed_by_pos.has(9) and narrowed_by_pos.has(11) and not narrowed_by_pos.has(10) and bool(narrowed_by_pos[8].get("damaged", false)) and bool(narrowed_by_pos[9].get("damaged", true)) == false and is_equal_approx(float(narrowed_by_pos[8].get("health", -1.0)), 500.0) and is_equal_approx(float(narrowed_by_pos[8].get("block_health", -1.0)), 1000.0)

	# STRICT overlap (Rect.java:274-276): a hitbox edge
	# exactly ON the rect edge does NOT overlap. The
	# x-touching candidate is dx 120 == 112 + 8 and the
	# y-touching one is dy 120 == 112 + 8; both are OUT,
	# while the just-inside ones (dx/dy 119 < 120) are IN.
	var touch_x: Dictionary = {"pos": 21, "team_id": 1, "x": 344.0, "y": 160.0, "hit_size": 16.0, "block_health": 100.0, "health": 100.0, "heal_suppressed": false}
	var touch_y: Dictionary = {"pos": 22, "team_id": 1, "x": 224.0, "y": 40.0, "hit_size": 16.0, "block_health": 100.0, "health": 100.0, "heal_suppressed": false}
	var inside_x: Dictionary = {"pos": 23, "team_id": 1, "x": 343.0, "y": 160.0, "hit_size": 16.0, "block_health": 100.0, "health": 100.0, "heal_suppressed": false}
	var inside_y: Dictionary = {"pos": 24, "team_id": 1, "x": 224.0, "y": 41.0, "hit_size": 16.0, "block_health": 100.0, "health": 100.0, "heal_suppressed": false}
	var edge_scanned: Dictionary = regen_projector_build_state.source_regen_projector_update_targets_state(fresh_frame, center_x, center_y, [touch_x, touch_y, inside_x, inside_y])
	var edge_narrowed: Dictionary = regen_projector_build_state.source_regen_projector_update_targets_narrow_state(edge_scanned.get("targets", []), [touch_x, touch_y, inside_x, inside_y], 1, center_x, center_y)
	var edge_targets: Array = edge_narrowed.get("targets", [])
	var edge_by_pos: Dictionary = {}
	for entry in edge_targets:
		edge_by_pos[int(entry.get("pos", -1))] = entry
	proof["narrow_excludes_at_exact_hitbox_edge"] = edge_targets.size() == 2 and edge_by_pos.has(23) and edge_by_pos.has(24) and not edge_by_pos.has(21) and not edge_by_pos.has(22)

	# Privileged blocks are excluded (BlockIndexer.java:372)
	# -- both a privileged rect member (the N2277 scan
	# admits it, it models no privileged flag) and a
	# privileged straddler. An explicit privileged=false
	# and a missing privileged key (default false,
	# Block.java:148) are both admitted.
	var privileged_in_rect: Dictionary = {"pos": 31, "team_id": 1, "x": 224.0, "y": 160.0, "hit_size": 8.0, "privileged": true, "block_health": 100.0, "health": 50.0, "heal_suppressed": false}
	var privileged_straddler: Dictionary = {"pos": 32, "team_id": 1, "x": 344.0, "y": 160.0, "hit_size": 24.0, "privileged": true, "block_health": 100.0, "health": 50.0, "heal_suppressed": false}
	var plain_straddler: Dictionary = {"pos": 33, "team_id": 1, "x": 340.0, "y": 160.0, "hit_size": 16.0, "privileged": false, "block_health": 100.0, "health": 100.0, "heal_suppressed": false}
	var default_straddler: Dictionary = {"pos": 34, "team_id": 1, "x": 340.0, "y": 168.0, "hit_size": 16.0, "block_health": 100.0, "health": 100.0, "heal_suppressed": false}
	var priv_scanned: Dictionary = regen_projector_build_state.source_regen_projector_update_targets_state(fresh_frame, center_x, center_y, [privileged_in_rect, privileged_straddler, plain_straddler, default_straddler])
	var priv_narrowed: Dictionary = regen_projector_build_state.source_regen_projector_update_targets_narrow_state(priv_scanned.get("targets", []), [privileged_in_rect, privileged_straddler, plain_straddler, default_straddler], 1, center_x, center_y)
	var priv_targets: Array = priv_narrowed.get("targets", [])
	var priv_by_pos: Dictionary = {}
	for entry in priv_targets:
		priv_by_pos[int(entry.get("pos", -1))] = entry
	proof["narrow_excludes_privileged"] = priv_targets.size() == 2 and priv_by_pos.has(33) and priv_by_pos.has(34) and not priv_by_pos.has(31) and not priv_by_pos.has(32)

	# The narrow never rewrites a rect member: kept entries
	# ride through untouched (pos 41 keeps heal_suppressed
	# true and damaged true; pos 42 has NO matching
	# candidate and is kept -- privileged defaults false).
	# Straddler entries are rebuilt in the N2277 format with
	# the damaged epsilon (999.998 < 1000 - 0.001 is damaged,
	# 999.9995 is not). A missing hit_size defaults to 0.0
	# (the N2335/N2226 precedent): the pos-45 candidate at
	# dx 116 with no hit_size is OUT, which only the 0.0
	# default gives (116 >= 112 + 0). Missing x or y, a
	# non-Dictionary entry, and an other-team straddler are
	# all excluded from admission. An in-rect candidate
	# missing from the rect list is admitted by pass 2
	# (its hitbox overlaps the rect -- Java admits it too).
	var rect_entry_kept: Dictionary = {"pos": 41, "block_health": 1000.0, "health": 500.0, "damaged": true, "heal_suppressed": true}
	var rect_entry_orphan: Dictionary = {"pos": 42, "block_health": 100.0, "health": 100.0, "damaged": false, "heal_suppressed": false}
	var intact_candidates: Array = [
		{"pos": 41, "team_id": 1, "x": 224.0, "y": 160.0, "hit_size": 8.0, "privileged": false, "block_health": 1000.0, "health": 500.0, "heal_suppressed": true},
		{"pos": 43, "team_id": 1, "x": 344.0, "y": 160.0, "hit_size": 24.0, "block_health": 1000.0, "health": 999.998, "heal_suppressed": false},
		{"pos": 44, "team_id": 1, "x": 340.0, "y": 168.0, "hit_size": 16.0, "block_health": 1000.0, "health": 999.9995, "heal_suppressed": false},
		{"pos": 45, "team_id": 1, "x": 340.0, "y": 152.0, "block_health": 100.0, "health": 50.0, "heal_suppressed": false},
		{"pos": 46, "team_id": 1, "y": 160.0, "hit_size": 16.0, "block_health": 100.0, "health": 50.0, "heal_suppressed": false},
		{"pos": 47, "team_id": 1, "x": 340.0, "hit_size": 16.0, "block_health": 100.0, "health": 50.0, "heal_suppressed": false},
		{"pos": 48, "team_id": 2, "x": 340.0, "y": 160.0, "hit_size": 16.0, "block_health": 100.0, "health": 50.0, "heal_suppressed": false},
		{"pos": 49, "team_id": 1, "x": 224.0, "y": 160.0, "hit_size": 8.0, "block_health": 200.0, "health": 100.0, "heal_suppressed": false},
		"not-a-dict",
	]
	var intact_narrowed: Dictionary = regen_projector_build_state.source_regen_projector_update_targets_narrow_state([rect_entry_kept, rect_entry_orphan, "not-a-dict"], intact_candidates, 1, center_x, center_y)
	var intact_targets: Array = intact_narrowed.get("targets", [])
	var intact_by_pos: Dictionary = {}
	for entry in intact_targets:
		intact_by_pos[int(entry.get("pos", -1))] = entry
	proof["narrow_keeps_rect_entries_intact"] = intact_targets.size() == 5 and int(intact_targets[0].get("pos", -1)) == 41 and bool(intact_targets[0].get("damaged", false)) and bool(intact_targets[0].get("heal_suppressed", false)) and is_equal_approx(float(intact_targets[0].get("health", -1.0)), 500.0) and int(intact_targets[1].get("pos", -1)) == 42 and bool(intact_by_pos[43].get("damaged", false)) and bool(intact_by_pos[44].get("damaged", true)) == false and is_equal_approx(float(intact_by_pos[44].get("health", -1.0)), 999.9995) and intact_by_pos.has(49) and bool(intact_by_pos[49].get("damaged", false)) and not intact_by_pos.has(45) and not intact_by_pos.has(46) and not intact_by_pos.has(47) and not intact_by_pos.has(48)

	# --- Live tick: a regen-projector placed live with a
	# damaged graphite-press (size 2) fourteen tiles away at
	# cell (42, 20) -- its center (340, 160) is dx 116 > 112,
	# OUTSIDE the N2277 rect, but its 16-wide hitbox [332,
	# 348] overlaps the rect edge 336, so the narrow admits
	# it (the differentiator vs N2277). A damaged copper-wall
	# two tiles away (30, 20) is the in-rect control and a
	# damaged copper-wall at (44, 20) is the far control
	# (center 352, dx 128 > 112 + 4, stays out). The tick
	# driver is called directly (as the N2228/N2277/N2325
	# proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status. Hydrogen
	# 1.0 is seeded on the sprite liquids meta (the N2325
	# pattern -- the required hydrogen row, Blocks.java:2016,
	# would fold efficiency 0 unseeded, the N2331 lesson)
	# and any_targets is seeded true (the N2214 pattern: the
	# gate reads the frame flag before the advance
	# recomputes it), so the first tick runs at efficiency
	# 1.0. The first tick refreshes (last_change -2 vs
	# tile_changes 1): the frame targets hold the projector
	# itself, the in-rect wall and the straddling press --
	# but not the far wall. The second tick changes nothing.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var hydrogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("hydrogen", -1))
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# Source-backed fixture health instead of the extracted -1 sentinel.
	# Copper-wall: Blocks.java:1708, 80 * wallHealthMultiplier (4).
	blocks_by_id["copper-wall"].properties["health"] = 320
	# Graphite-press: size 2, copper/lead healthScaling 0; Block.init: 2 * 2 * 40.
	blocks_by_id["graphite-press"].properties["health"] = 160

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
	var press_cell := Vector2i(42, 20)
	var press := Sprite2D.new()
	game.add_child(press)
	game.call("record_placed_block", press, blocks_by_id["graphite-press"], press_cell)
	var press_max_health: float = float(press.get_meta(placed_block_state.SOURCE_BLOCK_MAX_HEALTH_META_KEY, 0.0))
	placed_block_state.damage_sprite(press, press_max_health * 0.5)
	var far_cell := Vector2i(44, 20)
	var far_wall := Sprite2D.new()
	game.add_child(far_wall)
	game.call("record_placed_block", far_wall, blocks_by_id["copper-wall"], far_cell)
	var far_max_health: float = float(far_wall.get_meta(placed_block_state.SOURCE_BLOCK_MAX_HEALTH_META_KEY, 0.0))
	placed_block_state.damage_sprite(far_wall, far_max_health * 0.5)
	regen_projector_build_state.source_regen_projector_bind_frame_state(regen, blocks_by_id["regen-projector"])
	var regen_frame: Dictionary = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var regen_liquids: Dictionary = regen.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(regen_liquids, hydrogen_id, 1.0)
	regen_frame["any_targets"] = true
	regen_frame["power_status"] = 1.0

	var self_pos: int = block_geometry.tile_pos_state(regen_cell.x, regen_cell.y)
	var wall_pos: int = block_geometry.tile_pos_state(wall_cell.x, wall_cell.y)
	var press_pos: int = block_geometry.tile_pos_state(press_cell.x, press_cell.y)
	var far_pos: int = block_geometry.tile_pos_state(far_cell.x, far_cell.y)
	regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)
	regen_frame = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var tick1_targets: Array = regen_frame.get("targets", [])
	var tick1_by_pos: Dictionary = {}
	for entry in tick1_targets:
		tick1_by_pos[int(entry.get("pos", -1))] = entry
	var tick1_ok: bool = int(regen_frame.get("last_change", -99)) == 1 and is_equal_approx(float(regen_frame.get("efficiency", -1.0)), 1.0) and bool(regen_frame.get("any_targets", false)) and tick1_by_pos.has(self_pos) and tick1_by_pos.has(wall_pos) and tick1_by_pos.has(press_pos) and not tick1_by_pos.has(far_pos) and bool(tick1_by_pos[press_pos].get("damaged", false)) and bool(tick1_by_pos[wall_pos].get("damaged", false)) and bool(tick1_by_pos[self_pos].get("damaged", true)) == false and is_equal_approx(float(tick1_by_pos[press_pos].get("health", -1.0)), press_max_health * 0.5) and is_equal_approx(float(tick1_by_pos[press_pos].get("block_health", -1.0)), press_max_health)

	regen_frame["power_status"] = 1.0
	regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)
	regen_frame = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var tick2_targets: Array = regen_frame.get("targets", [])
	var tick2_ok: bool = int(regen_frame.get("last_change", -99)) == 1 and bool(regen_frame.get("any_targets", false)) and tick2_targets == tick1_targets
	proof["live_tick_passes_narrowed_targets"] = tick1_ok and tick2_ok

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RegenProjectorTargetsNarrowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
