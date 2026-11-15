extends Node

const main_scene := preload("res://scenes/Main.tscn")
const item_bridge_build_state := preload("res://src/game/SourceItemBridgeBuildState.gd")
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

	# --- Pure gate (N2188): ItemBridgeBuild.shouldConsume()
	# (ItemBridge.java:495, `public boolean shouldConsume(){`
	# with `return hadValidLink && enabled;`,
	# ItemBridge.java:496) -- the bridge consumes only while
	# its link is valid AND it is enabled. The override
	# INCLUDES the enabled check -- unlike the LaunchPad
	# (N2186) and ShockwaveTower (N2187) overrides -- so the
	# pure function reads both frame keys: had_valid_link
	# (ItemBridge.java:202, `public boolean wasMoved, moved,
	# hadValidLink;`, recomputed every tick by the N2197
	# driver, ItemBridge.java:332-333) and enabled
	# (BuildingComp.java:77, `transient boolean enabled =
	# true;`). A missing link validity reads false (fresh
	# build, unlinked); a missing enabled reads true (the
	# Java field default).
	var open_gate: Dictionary = item_bridge_build_state.source_item_bridge_should_consume_state({"had_valid_link": true, "enabled": true})
	proof["gate_open_with_valid_link"] = bool(open_gate.get("should_consume", false)) and bool(open_gate.get("had_valid_link", false))

	var unlinked_gate: Dictionary = item_bridge_build_state.source_item_bridge_should_consume_state({"had_valid_link": false, "enabled": true})
	proof["gate_closed_when_unlinked"] = bool(unlinked_gate.get("should_consume", true)) == false and bool(unlinked_gate.get("had_valid_link", true)) == false

	var disabled_gate: Dictionary = item_bridge_build_state.source_item_bridge_should_consume_state({"had_valid_link": true, "enabled": false})
	proof["gate_closed_when_disabled"] = bool(disabled_gate.get("should_consume", true)) == false and bool(disabled_gate.get("had_valid_link", false))

	# --- Live tick: the second bridge sits in the same row,
	# 3 cells away (within range 12); bridge A links to it via
	# the N2197 pure configure (Point2 relative {x: 3, y: 0}
	# from (28, 21) packs to pack(31, 21) = 31 * 65536 + 21 =
	# 2031637), bridge B stays unlinked (link -1) -- a partner
	# that points back would fail the double-link check
	# (ItemBridge.java:154). The driver is called directly
	# (as the N2178/N2197 proofs do), not simulate_factory,
	# so the graph update does not overwrite the stamped
	# power_status -- the write-back itself is already proven
	# by N2142. The gate reads the PREVIOUS tick's
	# had_valid_link: the N2197 recompute runs AFTER the
	# consumption fold -- updateConsumption runs before
	# updateTile (BuildingComp.java:2274-2277) -- so a freshly
	# linked bridge consumes from the next tick. That is
	# Java, not a bug.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var bridge_a_cell := Vector2i(28, 21)
	var bridge_a := Sprite2D.new()
	game.add_child(bridge_a)
	game.call("record_placed_block", bridge_a, blocks_by_id["phase-conveyor"], bridge_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to configure the link on it).
	item_bridge_build_state.source_item_bridge_bind_frame_state(bridge_a, blocks_by_id["phase-conveyor"])
	var bridge_a_frame: Dictionary = bridge_a.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})

	var bridge_b_cell := Vector2i(31, 21)
	var bridge_b := Sprite2D.new()
	game.add_child(bridge_b)
	game.call("record_placed_block", bridge_b, blocks_by_id["phase-conveyor"], bridge_b_cell)
	item_bridge_build_state.source_item_bridge_bind_frame_state(bridge_b, blocks_by_id["phase-conveyor"])
	var bridge_b_frame: Dictionary = bridge_b.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})

	# Full power on both frames; bridge A links to bridge B.
	bridge_a_frame["power_status"] = 1.0
	bridge_b_frame["power_status"] = 1.0
	var point2_configured: Dictionary = item_bridge_build_state.source_item_bridge_configure_state(bridge_a_frame, {"x": 3, "y": 0}, 28, 21)
	bridge_a_frame["link"] = int(point2_configured.get("link", -1))

	# Tick 1: bridge A's gate reads the stale had_valid_link
	# (false -- the link was configured after the last tick),
	# so its efficiency folds to 0 even though the link is
	# valid; the recompute after the fold then sets
	# had_valid_link true. Bridge B never had a link, so its
	# gate stays closed and its efficiency folds to 0 too.
	item_bridge_build_state.source_item_bridge_tick_buildings_state(game, 1.0 / 60.0)
	bridge_a_frame = bridge_a.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	bridge_b_frame = bridge_b.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	proof["gate_reads_previous_tick_link"] = is_equal_approx(float(bridge_a_frame.get("efficiency", -1.0)), 0.0) and bool(bridge_a_frame.get("had_valid_link", false))
	proof["efficiency_zero_when_gate_closed"] = is_equal_approx(float(bridge_b_frame.get("efficiency", -1.0)), 0.0) and bool(bridge_b_frame.get("had_valid_link", true)) == false

	# Tick 2: bridge A's gate is now open (had_valid_link true
	# from the tick-1 recompute), so the old N2178 behavior is
	# kept -- half power folds efficiency to 0.5.
	bridge_a_frame["power_status"] = 0.5
	item_bridge_build_state.source_item_bridge_tick_buildings_state(game, 1.0 / 60.0)
	bridge_a_frame = bridge_a.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	proof["efficiency_kept_when_gate_open"] = is_equal_approx(float(bridge_a_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemBridgeShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
