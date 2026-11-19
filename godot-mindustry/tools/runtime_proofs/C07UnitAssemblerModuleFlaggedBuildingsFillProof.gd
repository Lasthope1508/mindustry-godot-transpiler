extends Node

const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
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

	# --- The flagged-candidates pure (N2381): getLink
	# (UnitAssemblerModule.java:65-69) scans
	# Vars.indexer.getFlagged(team, BlockFlag.
	# unitAssembler) team-wide; the flag is set
	# class-wide by the UnitAssembler constructor
	# (UnitAssembler.java:66, `flags = EnumSet.of(
	# BlockFlag.unitAssembler);`), so the pure keeps
	# same-team UnitAssembler builds and emits N2358
	# descriptors ({"block", "cell", "rotation",
	# "size", "area_size", "x", "y"} -- x/y are the
	# assembler world coords, cell the origin cell),
	# in input order (the placed_blocks insertion
	# order, matching Java's append-on-index order,
	# BlockIndexer.java:599). tilesize is 8
	# (Vars.java:135).
	var tilesize: float = source_world_defaults.TILESIZE
	var same_team_tank: Dictionary = {"block": "tank-assembler", "cell": Vector2i(28, 20), "team_id": 1, "rotation": 0, "size": 5, "area_size": 13, "x": 224.0, "y": 160.0, "implementation": "UnitAssembler"}
	var enemy_ship: Dictionary = {"block": "ship-assembler", "cell": Vector2i(5, 5), "team_id": 2, "rotation": 0, "size": 5, "area_size": 13, "x": 40.0, "y": 40.0, "implementation": "UnitAssembler"}
	var same_team_module: Dictionary = {"block": "basic-assembler-module", "cell": Vector2i(6, 6), "team_id": 1, "rotation": 0, "size": 5, "area_size": 13, "x": 48.0, "y": 48.0, "implementation": "UnitAssemblerModule"}
	var same_team_mech: Dictionary = {"block": "mech-assembler", "cell": Vector2i(40, 40), "team_id": 1, "rotation": 1, "size": 5, "area_size": 13, "x": 320.0, "y": 320.0, "implementation": "UnitAssembler"}
	var scanned: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_flagged_candidates_state([same_team_tank, enemy_ship, same_team_module, same_team_mech], 1)
	var scanned_candidates: Array = scanned.get("candidates", [])
	proof["scan_same_team_assemblers_only"] = scanned_candidates.size() == 2 and int(scanned.get("checked", -1)) == 4 and int(scanned.get("matched", -1)) == 2 and str((scanned_candidates[0] as Dictionary).get("block", "")) == "tank-assembler" and str((scanned_candidates[1] as Dictionary).get("block", "")) == "mech-assembler"
	proof["scan_preserves_input_order"] = (scanned_candidates[0] as Dictionary).get("cell") == Vector2i(28, 20) and (scanned_candidates[1] as Dictionary).get("cell") == Vector2i(40, 40)

	# The descriptor carries all seven N2358 keys
	# with the tick-gathered values (the mech
	# descriptor keeps its rotation 1).
	var first_descriptor: Dictionary = scanned_candidates[0]
	var second_descriptor: Dictionary = scanned_candidates[1]
	proof["scan_descriptor_format"] = first_descriptor.has("block") and first_descriptor.has("cell") and first_descriptor.has("rotation") and first_descriptor.has("size") and first_descriptor.has("area_size") and first_descriptor.has("x") and first_descriptor.has("y") and str(first_descriptor.get("block", "")) == "tank-assembler" and first_descriptor.get("cell") == Vector2i(28, 20) and int(first_descriptor.get("rotation", -1)) == 0 and int(first_descriptor.get("size", -1)) == 5 and int(first_descriptor.get("area_size", -1)) == 13 and float(first_descriptor.get("x", -1.0)) == 224.0 and float(first_descriptor.get("y", -1.0)) == 160.0 and int(second_descriptor.get("rotation", -1)) == 1

	# A building without area_size falls back to the
	# UnitAssembler class default 11
	# (UnitAssembler.java:45, the N2358 precedent).
	var no_area_building: Dictionary = {"block": "tank-assembler", "cell": Vector2i(1, 1), "team_id": 1, "rotation": 0, "size": 5, "x": 8.0, "y": 8.0, "implementation": "UnitAssembler"}
	var defaulted: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_flagged_candidates_state([no_area_building], 1)
	var defaulted_candidates: Array = defaulted.get("candidates", [])
	proof["scan_default_area_size"] = defaulted_candidates.size() == 1 and int((defaulted_candidates[0] as Dictionary).get("area_size", -1)) == 11 and int(defaulted.get("checked", -1)) == 1 and int(defaulted.get("matched", -1)) == 1

	# Malformed entries skip (a non-dict entry and a
	# dict without a cell cannot form the N2351 link
	# format) and do not count toward checked.
	var malformed: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_flagged_candidates_state([42, {"block": "tank-assembler"}, same_team_tank], 1)
	var malformed_candidates: Array = malformed.get("candidates", [])
	proof["scan_skips_malformed"] = malformed_candidates.size() == 1 and str((malformed_candidates[0] as Dictionary).get("block", "")) == "tank-assembler" and int(malformed.get("checked", -1)) == 1 and int(malformed.get("matched", -1)) == 1

	var empty: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_flagged_candidates_state([], 1)
	proof["scan_empty_list"] = Array(empty.get("candidates", [1])) == [] and int(empty.get("checked", -1)) == 0 and int(empty.get("matched", -1)) == 0

	# --- Live tick: the N2358 layout. The tank
	# assembler sits at cell (28, 20) -- world (224,
	# 160) -- rotation 0, so its spawn is (296, 160)
	# and the dst target is 48. The fitting module
	# sits at cell (28, 26) -- world (224, 208) --
	# rotation 0: relativeTo is 0 and the Chebyshev
	# dst is 48, so the live-filled candidates link
	# it and the N2351 wiring adds its tier to the
	# assembler frame ([1], current_tier 1). The mech
	# assembler at (40, 40) is a second descriptor
	# that does not fit the module. The lonely module
	# at (5, 5) ticks BEFORE any assembler is placed
	# (link null, no candidates), then ticks again
	# with both assemblers live and still links
	# nothing (too far from both spawns). An enemy
	# ship-assembler (team 2) never enters the
	# same-team list. The module tick driver is called
	# directly (as the N2248 proof does), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var lonely_cell := Vector2i(5, 5)
	var lonely_module := Sprite2D.new()
	game.add_child(lonely_module)
	game.call("record_placed_block", lonely_module, blocks_by_id["basic-assembler-module"], lonely_cell)
	unit_assembler_module_build_state.source_unit_assembler_module_bind_frame_state(lonely_module, blocks_by_id["basic-assembler-module"])
	var lonely_frame: Dictionary = lonely_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	lonely_frame["power_status"] = 1.0

	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	lonely_frame = lonely_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["live_tick_no_assembler_null"] = lonely_frame.get("link", {}) == null and Array(lonely_frame.get("link_candidates", [])) == [] and not bool(lonely_frame.get("link_candidates_live", false))

	var live_assembler_cell := Vector2i(28, 20)
	var live_assembler := Sprite2D.new()
	game.add_child(live_assembler)
	game.call("record_placed_block", live_assembler, blocks_by_id["tank-assembler"], live_assembler_cell)
	unit_factory_build_state.source_unit_factory_bind_frame_state(live_assembler, blocks_by_id["tank-assembler"])

	var mech_cell := Vector2i(40, 40)
	var mech_assembler := Sprite2D.new()
	game.add_child(mech_assembler)
	game.call("record_placed_block", mech_assembler, blocks_by_id["mech-assembler"], mech_cell)
	# Out-of-world fixture placement uses legacy initialization: set its intended sharded team explicitly.
	mech_assembler.set_meta(block_geometry.SOURCE_BUILD_TEAM_META_KEY, 1)
	unit_factory_build_state.source_unit_factory_bind_frame_state(mech_assembler, blocks_by_id["mech-assembler"])

	# The enemy assembler is placed on team 2 (the
	# record_placed_block team_id parameter, plus the
	# team meta set directly so the tick's team read
	# is deterministic whatever the binding path did).
	var enemy_cell := Vector2i(50, 20)
	var enemy_assembler := Sprite2D.new()
	game.add_child(enemy_assembler)
	game.call("record_placed_block", enemy_assembler, blocks_by_id["ship-assembler"], enemy_cell, 2)
	enemy_assembler.set_meta("team_id", 2)
	unit_factory_build_state.source_unit_factory_bind_frame_state(enemy_assembler, blocks_by_id["ship-assembler"])

	var fit_cell := Vector2i(28, 26)
	var fit_module := Sprite2D.new()
	game.add_child(fit_module)
	game.call("record_placed_block", fit_module, blocks_by_id["basic-assembler-module"], fit_cell)
	unit_assembler_module_build_state.source_unit_assembler_module_bind_frame_state(fit_module, blocks_by_id["basic-assembler-module"])
	var fit_frame: Dictionary = fit_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	fit_frame["power_status"] = 1.0

	# Supplied candidates WIN: this module seeds its
	# own candidate list (a far mech-assembler that
	# does not fit it), so the live fill must leave
	# the list untouched even with two live assemblers
	# placed.
	var supplied_cell := Vector2i(20, 10)
	var supplied_module := Sprite2D.new()
	game.add_child(supplied_module)
	game.call("record_placed_block", supplied_module, blocks_by_id["basic-assembler-module"], supplied_cell)
	unit_assembler_module_build_state.source_unit_assembler_module_bind_frame_state(supplied_module, blocks_by_id["basic-assembler-module"])
	var supplied_frame: Dictionary = supplied_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	var far_candidate: Dictionary = {"block": "mech-assembler", "cell": Vector2i(25, 25), "rotation": 0, "size": 5, "area_size": 13, "x": 200.0, "y": 200.0}
	supplied_frame["link_candidates"] = [far_candidate]
	supplied_frame["power_status"] = 1.0

	# A seeded link_candidate is kept too (the N2358
	# module-three behavior): this module seeds a
	# block-only candidate and no candidate list, so
	# the fill must not run and the link refreshes to
	# the seed.
	var seeded_cell := Vector2i(20, 20)
	var seeded_module := Sprite2D.new()
	game.add_child(seeded_module)
	game.call("record_placed_block", seeded_module, blocks_by_id["basic-assembler-module"], seeded_cell)
	unit_assembler_module_build_state.source_unit_assembler_module_bind_frame_state(seeded_module, blocks_by_id["basic-assembler-module"])
	var seeded_frame: Dictionary = seeded_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	seeded_frame["link_candidate"] = {"block": "tank-assembler"}
	seeded_frame["power_status"] = 1.0

	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	var live_assembler_frame: Dictionary = live_assembler.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	fit_frame = fit_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	var fit_candidates: Array = fit_frame.get("link_candidates", [])
	proof["live_tick_fills_two_candidates"] = fit_candidates.size() == 2 and bool(fit_frame.get("link_candidates_live", false)) and str((fit_candidates[0] as Dictionary).get("block", "")) == "tank-assembler" and (fit_candidates[0] as Dictionary).get("cell") == live_assembler_cell and str((fit_candidates[1] as Dictionary).get("block", "")) == "mech-assembler" and (fit_candidates[1] as Dictionary).get("cell") == mech_cell and float((fit_candidates[0] as Dictionary).get("x", -1.0)) == float(live_assembler_cell.x) * tilesize and float((fit_candidates[0] as Dictionary).get("y", -1.0)) == float(live_assembler_cell.y) * tilesize and int((fit_candidates[0] as Dictionary).get("area_size", -1)) == 13
	var fit_link: Variant = fit_frame.get("link", null)
	proof["live_tick_discovery_links_fit"] = fit_link is Dictionary and str((fit_link as Dictionary).get("block", "")) == "tank-assembler" and (fit_link as Dictionary).get("cell") == live_assembler_cell and Array(live_assembler_frame.get("modules", [])) == [1] and int(live_assembler_frame.get("current_tier", -1)) == 1

	lonely_frame = lonely_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["live_tick_no_fit_null"] = lonely_frame.get("link", {}) == null and Array(lonely_frame.get("link_candidates", [])).size() == 2 and bool(lonely_frame.get("link_candidates_live", false))

	supplied_frame = supplied_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	var supplied_candidates: Array = supplied_frame.get("link_candidates", [])
	proof["live_tick_supplied_candidates_win"] = supplied_candidates.size() == 1 and (supplied_candidates[0] as Dictionary).get("cell") == Vector2i(25, 25) and not bool(supplied_frame.get("link_candidates_live", false)) and supplied_frame.get("link", {}) == null

	seeded_frame = seeded_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	var seeded_link: Variant = seeded_frame.get("link", null)
	proof["live_tick_seeded_candidate_kept"] = seeded_link is Dictionary and str((seeded_link as Dictionary).get("block", "")) == "tank-assembler" and not (seeded_link as Dictionary).has("cell") and not seeded_frame.has("link_candidates") and not bool(seeded_frame.get("link_candidates_live", false))

	# A later-placed assembler joins on refresh: the
	# live-filled frame re-scans every tick (the
	# link_candidates_live marker), so the third
	# assembler appears without any re-seed, and the
	# link still points at the fitting tank.
	var third_cell := Vector2i(60, 60)
	var third_assembler := Sprite2D.new()
	game.add_child(third_assembler)
	game.call("record_placed_block", third_assembler, blocks_by_id["ship-assembler"], third_cell)
	# Out-of-world fixture placement uses legacy initialization: set its intended sharded team explicitly.
	third_assembler.set_meta(block_geometry.SOURCE_BUILD_TEAM_META_KEY, 1)
	unit_factory_build_state.source_unit_factory_bind_frame_state(third_assembler, blocks_by_id["ship-assembler"])
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	fit_frame = fit_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	var refreshed_candidates: Array = fit_frame.get("link_candidates", [])
	var refreshed_link: Variant = fit_frame.get("link", null)
	proof["live_tick_refresh_adds_assembler"] = refreshed_candidates.size() == 3 and str((refreshed_candidates[2] as Dictionary).get("block", "")) == "ship-assembler" and (refreshed_candidates[2] as Dictionary).get("cell") == third_cell and refreshed_link is Dictionary and str((refreshed_link as Dictionary).get("block", "")) == "tank-assembler" and (refreshed_link as Dictionary).get("cell") == live_assembler_cell

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitAssemblerModuleFlaggedBuildingsFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
