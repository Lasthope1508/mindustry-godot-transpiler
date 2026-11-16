extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
const unit_assembler_module_build_state := preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
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

	# --- Pure (a) -- moduleFits (N2358): moduleFits
	# (UnitAssembler.java:338-351) is geometry only (NO
	# tier term): the spawn from getUnitSpawn()
	# (UnitAssembler.java:332-336, len = tilesize *
	# (areaSize + size)/2f along the ASSEMBLER rotation),
	# the Tile.relativeTo float direction check
	# (Tile.java:103-113) against the MODULE rotation,
	# and the Chebyshev dst against tilesize * areaSize /
	# 2f - tilesize/2f through Mathf.equal (arc
	# Mathf.java:544-546). tilesize is 8 (Vars.java:135).
	# All three assembler defs are size 5 with areaSize
	# 13 (Blocks.java:6521-6564), so the spawn len is
	# 8 * (13 + 5) / 2 = 72 and the dst target is
	# 8 * 13 / 2 - 8 / 2 = 48.
	var tilesize: float = source_world_defaults.TILESIZE
	var assembler_east: Dictionary = {"x": 0.0, "y": 0.0, "size": 5, "rotation": 0, "area_size": 13}
	var side_module: Dictionary = {"x": 0.0, "y": 48.0, "size": 5, "rotation": 0}
	var side: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_fits_state(side_module, assembler_east, tilesize)
	proof["fits_side_module"] = bool(side.get("fits", false)) and side.get("spawn", Vector2.ZERO) == Vector2(72.0, 0.0) and float(side.get("dx", -1.0)) == 24.0 and float(side.get("dy", -1.0)) == 48.0 and float(side.get("dst", -1.0)) == 48.0 and float(side.get("target", -1.0)) == 48.0 and int(side.get("relative_to", -9)) == 0

	var assembler_north: Dictionary = {"x": 0.0, "y": 0.0, "size": 5, "rotation": 1, "area_size": 13}
	var west_module: Dictionary = {"x": -48.0, "y": 0.0, "size": 5, "rotation": 1}
	var rotated: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_fits_state(west_module, assembler_north, tilesize)
	proof["fits_rotated_assembler"] = bool(rotated.get("fits", false)) and rotated.get("spawn", Vector2.ZERO) == Vector2(0.0, 72.0) and float(rotated.get("dst", -1.0)) == 48.0 and int(rotated.get("relative_to", -9)) == 1

	# The module rotation (3, south) differs from the
	# assembler rotation (0, east): the spawn follows
	# the ASSEMBLER rotation (72, 0) while the reach and
	# the relativeTo check follow the MODULE rotation.
	var south_module: Dictionary = {"x": 72.0, "y": 72.0, "size": 5, "rotation": 3}
	var differs: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_fits_state(south_module, assembler_east, tilesize)
	proof["fits_module_rotation_differs"] = bool(differs.get("fits", false)) and differs.get("spawn", Vector2.ZERO) == Vector2(72.0, 0.0) and float(differs.get("dx", -1.0)) == 72.0 and float(differs.get("dy", -1.0)) == 48.0 and float(differs.get("dst", -1.0)) == 48.0 and int(differs.get("relative_to", -9)) == 3

	# The class-default areaSize 11 (UnitAssembler.java:45)
	# when the candidate carries no area_size: the spawn
	# len is 8 * (11 + 5) / 2 = 64 and the target is
	# 8 * 11 / 2 - 8 / 2 = 40.
	var assembler_default_area: Dictionary = {"x": 0.0, "y": 0.0, "size": 5, "rotation": 0}
	var default_module: Dictionary = {"x": 0.0, "y": 40.0, "size": 5, "rotation": 0}
	var defaulted: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_fits_state(default_module, assembler_default_area, tilesize)
	proof["fits_default_area_size"] = bool(defaulted.get("fits", false)) and defaulted.get("spawn", Vector2.ZERO) == Vector2(64.0, 0.0) and float(defaulted.get("target", -1.0)) == 40.0 and float(defaulted.get("dst", -1.0)) == 40.0

	var wrong_direction_module: Dictionary = {"x": 0.0, "y": 48.0, "size": 5, "rotation": 2}
	var wrong_direction: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_fits_state(wrong_direction_module, assembler_east, tilesize)
	proof["no_fit_wrong_direction"] = not bool(wrong_direction.get("fits", true)) and int(wrong_direction.get("relative_to", -9)) == 0

	var wrong_distance_module: Dictionary = {"x": 0.0, "y": 56.0, "size": 5, "rotation": 0}
	var wrong_distance: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_fits_state(wrong_distance_module, assembler_east, tilesize)
	proof["no_fit_wrong_distance"] = not bool(wrong_distance.get("fits", true)) and int(wrong_distance.get("relative_to", -9)) == 0 and float(wrong_distance.get("dst", -1.0)) == 56.0

	# A module ON the spawn: relativeTo returns -1 (the
	# within-1px branch, Tile.java:103-113), which never
	# equals the module rotation.
	var on_spawn_module: Dictionary = {"x": 72.0, "y": 0.0, "size": 5, "rotation": 0}
	var on_spawn: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_fits_state(on_spawn_module, assembler_east, tilesize)
	proof["no_fit_module_on_spawn"] = not bool(on_spawn.get("fits", true)) and int(on_spawn.get("relative_to", -9)) == -1

	# --- Pure (b) -- getLink discovery (N2358): the
	# FIRST fit in list order (Java Seq.find,
	# UnitAssemblerModule.java:65-69), returned as the
	# N2351 link format {"block", "cell": Vector2i}.
	var far_candidate: Dictionary = {"block": "mech-assembler", "cell": Vector2i(25, 25), "rotation": 0, "size": 5, "area_size": 13, "x": 200.0, "y": 200.0}
	var near_candidate: Dictionary = {"block": "tank-assembler", "cell": Vector2i(0, 0), "rotation": 0, "size": 5, "area_size": 13, "x": 0.0, "y": 0.0}
	var second_fit_candidate: Dictionary = {"block": "ship-assembler", "cell": Vector2i(0, 12), "rotation": 0, "size": 5, "area_size": 13, "x": 0.0, "y": 96.0}
	var first_fit: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_get_link_state(side_module, [far_candidate, near_candidate, second_fit_candidate], tilesize)
	var first_fit_link: Variant = first_fit.get("link", null)
	proof["discovery_first_fit"] = first_fit_link is Dictionary and str((first_fit_link as Dictionary).get("block", "")) == "tank-assembler" and (first_fit_link as Dictionary).get("cell") == Vector2i(0, 0) and int(first_fit.get("candidate_index", -9)) == 1 and int(first_fit.get("checked", -1)) == 2

	var no_fit: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_get_link_state(side_module, [far_candidate], tilesize)
	proof["discovery_no_fit_null"] = no_fit.get("link", {}) == null and int(no_fit.get("candidate_index", -9)) == -1 and int(no_fit.get("checked", -1)) == 1

	# Malformed entries skip (a non-dict entry and a
	# dict without a cell cannot form the N2351 link
	# format) and do not count toward checked.
	var malformed: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_get_link_state(side_module, [42, {"block": "tank-assembler"}, near_candidate], tilesize)
	var malformed_link: Variant = malformed.get("link", null)
	proof["discovery_skips_malformed"] = malformed_link is Dictionary and str((malformed_link as Dictionary).get("block", "")) == "tank-assembler" and int(malformed.get("candidate_index", -9)) == 2 and int(malformed.get("checked", -1)) == 1

	var empty: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_get_link_state(side_module, [], tilesize)
	proof["discovery_empty_list_null"] = empty.get("link", {}) == null and int(empty.get("candidate_index", -9)) == -1 and int(empty.get("checked", -1)) == 0

	# --- Live tick: a placed tank-assembler plus three
	# placed basic-assembler-modules (the N2351 proof
	# layout). The assembler sits at cell (28, 20) --
	# world (224, 160) -- rotation 0, so its spawn is
	# (296, 160) and the dst target is 48. Module one
	# sits at cell (28, 26) -- world (224, 208) --
	# rotation 0 with the assembler in its candidate
	# list: relativeTo is 0 and the Chebyshev dst is 48,
	# so the discovery links it and the N2351 wiring adds
	# its tier to the assembler frame ([1], current_tier
	# 1). Module two sits at cell (10, 10) -- world (80,
	# 80) -- with the same candidate: the dst is 192, so
	# it links nothing. Module three sits at cell (20,
	# 10) with a seeded block-only link_candidate and NO
	# link_candidates input: the tick keeps the seeded
	# candidate (the defined pre-fill behavior), the link
	# refreshes to it, and the N2351 wiring skips it (no
	# cell). The module tick driver is called directly
	# (as the N2248 proof does), not simulate_factory, so
	# the graph update does not overwrite the stamped
	# power_status.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var live_assembler_cell := Vector2i(28, 20)
	var live_assembler := Sprite2D.new()
	game.add_child(live_assembler)
	game.call("record_placed_block", live_assembler, blocks_by_id["tank-assembler"], live_assembler_cell)
	unit_factory_build_state.source_unit_factory_bind_frame_state(live_assembler, blocks_by_id["tank-assembler"])
	var live_candidate: Dictionary = {"block": "tank-assembler", "cell": live_assembler_cell, "rotation": 0, "size": 5, "area_size": 13, "x": float(live_assembler_cell.x) * tilesize, "y": float(live_assembler_cell.y) * tilesize}

	var module_one_cell := Vector2i(28, 26)
	var module_one := Sprite2D.new()
	game.add_child(module_one)
	game.call("record_placed_block", module_one, blocks_by_id["basic-assembler-module"], module_one_cell)
	unit_assembler_module_build_state.source_unit_assembler_module_bind_frame_state(module_one, blocks_by_id["basic-assembler-module"])
	var module_one_frame: Dictionary = module_one.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	module_one_frame["link_candidates"] = [live_candidate]
	module_one_frame["power_status"] = 1.0

	var module_two_cell := Vector2i(10, 10)
	var module_two := Sprite2D.new()
	game.add_child(module_two)
	game.call("record_placed_block", module_two, blocks_by_id["basic-assembler-module"], module_two_cell)
	unit_assembler_module_build_state.source_unit_assembler_module_bind_frame_state(module_two, blocks_by_id["basic-assembler-module"])
	var module_two_frame: Dictionary = module_two.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	module_two_frame["link_candidates"] = [live_candidate]
	module_two_frame["power_status"] = 1.0

	var module_three_cell := Vector2i(20, 10)
	var module_three := Sprite2D.new()
	game.add_child(module_three)
	game.call("record_placed_block", module_three, blocks_by_id["basic-assembler-module"], module_three_cell)
	unit_assembler_module_build_state.source_unit_assembler_module_bind_frame_state(module_three, blocks_by_id["basic-assembler-module"])
	var module_three_frame: Dictionary = module_three.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	module_three_frame["link_candidate"] = {"block": "tank-assembler"}
	module_three_frame["power_status"] = 1.0

	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	var live_assembler_frame: Dictionary = live_assembler.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	module_one_frame = module_one.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	var module_one_link: Variant = module_one_frame.get("link", null)
	proof["live_tick_discovery_links"] = module_one_link is Dictionary and str((module_one_link as Dictionary).get("block", "")) == "tank-assembler" and (module_one_link as Dictionary).get("cell") == live_assembler_cell and Array(live_assembler_frame.get("modules", [])) == [1] and int(live_assembler_frame.get("current_tier", -1)) == 1

	module_two_frame = module_two.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["live_tick_no_fit_null"] = module_two_frame.get("link", {}) == null and Array(live_assembler_frame.get("modules", [])) == [1]

	module_three_frame = module_three.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	var module_three_link: Variant = module_three_frame.get("link", null)
	proof["live_tick_no_candidates_keeps_seed"] = module_three_link is Dictionary and str((module_three_link as Dictionary).get("block", "")) == "tank-assembler" and not (module_three_link as Dictionary).has("cell") and Array(live_assembler_frame.get("modules", [])) == [1]

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitAssemblerModuleGetLinkDiscoveryProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
