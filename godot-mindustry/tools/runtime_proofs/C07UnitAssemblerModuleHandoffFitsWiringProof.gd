extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_assembler_module_build_state := preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")
const unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
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

	# --- Live tick: the handoff-gate moduleFits wiring
	# (N2370): Java evaluates moduleFits LIVE in the gate
	# (UnitAssemblerModule.java:138, the full gate
	# `if(moveInPayload() && link != null &&
	# link.moduleFits(block, x, y, rotation) &&
	# !link.wasOccupied && link.acceptPayload(this, payload)
	# && efficiency > 0){`), against the link assembler
	# object (UnitAssembler.java:338-351, geometry only).
	# The tick computes the fits verdict for the CURRENT
	# link BEFORE the N2248 advance and stamps
	# frame["module_fits"] with it -- the CURRENT link is
	# the link the advance WILL read (the post-discovery
	# link_candidate on a refresh, else the frame link),
	# and the assembler descriptor comes from
	# frame["link_candidates"] by cell (the N2358
	# discovery format). The stamp runs ONLY when
	# frame["link_candidates"] is supplied: a tick with
	# no candidate list keeps the seeded module_fits (the
	# N2248/N2314 fixture shape), while a supplied list
	# with no matching descriptor stamps false (the safe
	# no-assembler default). One module is ticked
	# sequentially (the N2308 proof pattern), the frame
	# reset between cases; the held payload arrives
	# (pay_vector ZERO, so moveInPayload returns true on
	# the first tick) and the link verdict is true in
	# every case (router offered, assembler empty, plan
	# router 5 -- 0 stored of 5). The layout mirrors the
	# N2358 proof: the assembler sits at cell (28, 20) --
	# world (224, 160) -- rotation 0, size 5, area_size
	# 13, so its spawn is (296, 160) and the dst target
	# is 48; the module sits at cell (28, 26) -- world
	# (224, 208) -- rotation 0, so relativeTo is 0 and
	# the Chebyshev dst is 48: the assembler FITS this
	# module. A far assembler at cell (10, 10) -- world
	# (80, 80) -- does NOT fit it (relativeTo 3, not the
	# module rotation 0).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var tilesize := 8.0
	var live_assembler_cell := Vector2i(28, 20)
	var live_assembler := Sprite2D.new()
	game.add_child(live_assembler)
	game.call("record_placed_block", live_assembler, blocks_by_id["tank-assembler"], live_assembler_cell)
	unit_factory_build_state.source_unit_factory_bind_frame_state(live_assembler, blocks_by_id["tank-assembler"])
	var live_candidate: Dictionary = {"block": "tank-assembler", "cell": live_assembler_cell, "rotation": 0, "size": 5, "area_size": 13, "x": float(live_assembler_cell.x) * tilesize, "y": float(live_assembler_cell.y) * tilesize}
	var far_cell := Vector2i(10, 10)
	var far_candidate: Dictionary = {"block": "tank-assembler", "cell": far_cell, "rotation": 0, "size": 5, "area_size": 13, "x": float(far_cell.x) * tilesize, "y": float(far_cell.y) * tilesize}

	var unit_assembler_module_cell := Vector2i(28, 26)
	var unit_assembler_module := Sprite2D.new()
	game.add_child(unit_assembler_module)
	game.call("record_placed_block", unit_assembler_module, blocks_by_id["basic-assembler-module"], unit_assembler_module_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to seed the payload + link
	# candidate + predicates + offer on it).
	unit_assembler_module_build_state.source_unit_assembler_module_bind_frame_state(unit_assembler_module, blocks_by_id["basic-assembler-module"])
	var unit_assembler_module_frame: Dictionary = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})

	var block_only_link := {"block": "tank-assembler"}
	var accepting_assembler := {"has_payload": false, "payload_content_equals": false, "blocks": {}}
	var router_plan := [{"item": "router", "amount": 5}]

	unit_assembler_module_frame["power_status"] = 1.0
	unit_assembler_module_frame["was_occupied"] = false
	unit_assembler_module_frame["offered_payload"] = {"content_item": "router"}
	unit_assembler_module_frame["assembler"] = accepting_assembler
	unit_assembler_module_frame["plan_requirements"] = router_plan
	unit_assembler_module_frame["unit_cost"] = 1.0

	# Tick 1: no candidates and no module_fits seed -- the
	# stamp never runs, so the frame keeps no module_fits
	# key at all and the gate reads the false default:
	# the handoff is blocked even though the payload
	# arrived, the link refreshed, the link verdict is
	# true and power is full.
	unit_assembler_module_frame["payload"] = {"block": "conveyor"}
	unit_assembler_module_frame["pay_vector"] = Vector2.ZERO
	unit_assembler_module_frame["pay_rotation"] = 0.0
	unit_assembler_module_frame["link_candidate"] = block_only_link
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["no_candidates_unseeded_stays_false"] = not unit_assembler_module_frame.has("module_fits") and bool(unit_assembler_module_frame.get("module_fits", false)) == false and unit_assembler_module_frame.get("link", null) == block_only_link and bool(unit_assembler_module_frame.get("link_refreshed", false)) and bool(unit_assembler_module_frame.get("accept_payload", false)) and bool(unit_assembler_module_frame.get("moved_in", false)) and bool(unit_assembler_module_frame.get("handed_off", true)) == false and unit_assembler_module_frame.get("payload", null) != null

	# Tick 2: no candidates but module_fits seeded true
	# (the N2248/N2314 fixture shape) -- the stamp still
	# never runs, so the seed is preserved and the
	# handoff fires.
	unit_assembler_module_frame["payload"] = {"block": "conveyor"}
	unit_assembler_module_frame["pay_vector"] = Vector2.ZERO
	unit_assembler_module_frame["pay_rotation"] = 0.0
	unit_assembler_module_frame["last_change"] = -2
	unit_assembler_module_frame["link_candidate"] = block_only_link
	unit_assembler_module_frame["module_fits"] = true
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["no_candidates_seeded_true_preserved"] = bool(unit_assembler_module_frame.get("module_fits", false)) and unit_assembler_module_frame.get("link", null) == block_only_link and bool(unit_assembler_module_frame.get("moved_in", false)) and bool(unit_assembler_module_frame.get("handed_off", false)) and unit_assembler_module_frame.get("payload", {"block": "conveyor"}) == null

	# Tick 3: candidates supplied, refresh path -- the
	# discovery links the fitting assembler and the stamp
	# reads the fits verdict true, so the handoff fires
	# and the N2351 wiring adds the tier to the assembler
	# frame ([1], current_tier 1).
	unit_assembler_module_frame["payload"] = {"block": "conveyor"}
	unit_assembler_module_frame["pay_vector"] = Vector2.ZERO
	unit_assembler_module_frame["pay_rotation"] = 0.0
	unit_assembler_module_frame["last_change"] = -2
	unit_assembler_module_frame["link_candidates"] = [live_candidate]
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	var live_assembler_frame: Dictionary = live_assembler.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	var tick_three_link: Variant = unit_assembler_module_frame.get("link", null)
	proof["handoff_fires_when_link_fits"] = bool(unit_assembler_module_frame.get("module_fits", false)) and tick_three_link is Dictionary and (tick_three_link as Dictionary).get("cell") == live_assembler_cell and bool(unit_assembler_module_frame.get("link_refreshed", false)) and bool(unit_assembler_module_frame.get("moved_in", false)) and bool(unit_assembler_module_frame.get("handed_off", false)) and unit_assembler_module_frame.get("payload", {"block": "conveyor"}) == null and Array(live_assembler_frame.get("modules", [])) == [1] and int(live_assembler_frame.get("current_tier", -1)) == 1

	# Tick 4: candidates supplied, no-refresh path -- the
	# current link is seeded to the far assembler (which
	# does not fit this module) and last_change already
	# equals tile_changes, so the link stays and the stamp
	# reads the fits verdict false: the handoff is
	# blocked and the payload stays held. (The discovery
	# finds no fit and fills link_candidate null, but no
	# refresh means the frame link is untouched.)
	unit_assembler_module_frame["payload"] = {"block": "conveyor"}
	unit_assembler_module_frame["pay_vector"] = Vector2.ZERO
	unit_assembler_module_frame["pay_rotation"] = 0.0
	unit_assembler_module_frame["link"] = {"block": "tank-assembler", "cell": far_cell}
	unit_assembler_module_frame["last_change"] = 1
	unit_assembler_module_frame["link_candidates"] = [far_candidate]
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	var tick_four_link: Variant = unit_assembler_module_frame.get("link", null)
	proof["handoff_blocked_when_link_does_not_fit"] = bool(unit_assembler_module_frame.get("module_fits", true)) == false and tick_four_link is Dictionary and (tick_four_link as Dictionary).get("cell") == far_cell and bool(unit_assembler_module_frame.get("link_refreshed", true)) == false and bool(unit_assembler_module_frame.get("moved_in", false)) and bool(unit_assembler_module_frame.get("handed_off", true)) == false and unit_assembler_module_frame.get("payload", null) != null

	# Tick 5: candidates supplied but no descriptor
	# matches the link cell -- the current link points at
	# a cell (99, 99) no candidate carries, so the stamp
	# falls back to false and the handoff is blocked even
	# though a stale module_fits=true seed would have let
	# it fire. (The discovery DOES fit the live assembler
	# and fills link_candidate with it, but no refresh
	# means the frame link -- and the stamp's effective
	# link -- stays the unmatched one.)
	unit_assembler_module_frame["payload"] = {"block": "conveyor"}
	unit_assembler_module_frame["pay_vector"] = Vector2.ZERO
	unit_assembler_module_frame["pay_rotation"] = 0.0
	unit_assembler_module_frame["link"] = {"block": "tank-assembler", "cell": Vector2i(99, 99)}
	unit_assembler_module_frame["last_change"] = 1
	unit_assembler_module_frame["link_candidates"] = [live_candidate]
	unit_assembler_module_frame["module_fits"] = true
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	var tick_five_link: Variant = unit_assembler_module_frame.get("link", null)
	proof["candidates_without_matching_descriptor_stays_false"] = bool(unit_assembler_module_frame.get("module_fits", true)) == false and tick_five_link is Dictionary and (tick_five_link as Dictionary).get("cell") == Vector2i(99, 99) and bool(unit_assembler_module_frame.get("moved_in", false)) and bool(unit_assembler_module_frame.get("handed_off", true)) == false and unit_assembler_module_frame.get("payload", null) != null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitAssemblerModuleHandoffFitsWiringProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
