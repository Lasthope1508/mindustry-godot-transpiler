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

	# --- Frame defaults (N2197): a new ItemBridgeBuild starts
	# unlinked (`public int link = -1;`, ItemBridge.java:198) with
	# hadValidLink false (`public boolean wasMoved, moved,
	# hadValidLink;`, ItemBridge.java:202).
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
	proof["link_defaults_to_minus_one"] = int(bridge_a_frame.get("link", 0)) == -1 and bool(bridge_a_frame.get("had_valid_link", true)) == false

	# --- Pure configure (N2197): the Point2 handler is RELATIVE
	# (ItemBridge.java:64, `config(Point2.class, (ItemBridgeBuild
	# tile, Point2 i) -> tile.link = Point2.pack(i.x +
	# tile.tileX(), i.y + tile.tileY()));`), the Integer handler
	# is the packed absolute position (ItemBridge.java:66,
	# `config(Integer.class, (ItemBridgeBuild tile, Integer i) ->
	# tile.link = i);`). pack(31, 21) = 31 * 65536 + 21 =
	# 2031637; pack(28, 21) = 28 * 65536 + 21 = 1835029.
	var point2_configured: Dictionary = item_bridge_build_state.source_item_bridge_configure_state(bridge_a_frame, {"x": 3, "y": 0}, 28, 21)
	proof["configure_point2_sets_relative_link"] = int(point2_configured.get("link", 0)) == 2031637

	var integer_configured: Dictionary = item_bridge_build_state.source_item_bridge_configure_state(bridge_a_frame, 12345, 28, 21)
	proof["configure_integer_sets_absolute_link"] = int(integer_configured.get("link", 0)) == 12345

	# --- Pure linkValid (N2197): linkValid (ItemBridge.java:
	# 149-156) needs positionsValid (same row/column within
	# range, ItemBridge.java:157-166) + block match + team match
	# + the double-link check (the partner link must not point
	# back at this tile).
	var valid_link: Dictionary = item_bridge_build_state.source_item_bridge_link_valid_state(28, 21, 31, 21, 12, true, true, -1, 1835029, true, true)
	proof["link_valid_same_row_within_range"] = bool(valid_link.get("had_valid_link", false))

	var double_link: Dictionary = item_bridge_build_state.source_item_bridge_link_valid_state(28, 21, 31, 21, 12, true, true, 1835029, 1835029, true, true)
	var out_of_range_link: Dictionary = item_bridge_build_state.source_item_bridge_link_valid_state(28, 21, 41, 21, 12, true, true, -1, 1835029, true, true)
	var diagonal_link: Dictionary = item_bridge_build_state.source_item_bridge_link_valid_state(28, 21, 29, 22, 12, true, true, -1, 1835029, true, true)
	proof["link_invalid_when_double_or_out_of_range"] = bool(double_link.get("had_valid_link", true)) == false and bool(out_of_range_link.get("had_valid_link", true)) == false and bool(diagonal_link.get("had_valid_link", true)) == false

	# --- Live tick: the second bridge sits in the same row,
	# 3 cells away (within range 12); bridge A links to it via
	# the pure configure, bridge B stays unlinked (link -1) --
	# a partner that points back would fail the double-link
	# check (ItemBridge.java:154). The driver is called directly
	# (as the N2178 proof does), not simulate_factory, so the
	# graph update does not overwrite the stamped power_status
	# -- the write-back itself is already proven by N2142.
	var bridge_b_cell := Vector2i(31, 21)
	var bridge_b := Sprite2D.new()
	game.add_child(bridge_b)
	game.call("record_placed_block", bridge_b, blocks_by_id["phase-conveyor"], bridge_b_cell)
	item_bridge_build_state.source_item_bridge_bind_frame_state(bridge_b, blocks_by_id["phase-conveyor"])
	var bridge_b_frame: Dictionary = bridge_b.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})

	# Full power on both frames: the fold is not what this
	# proof measures -- the link recompute is.
	bridge_a_frame["power_status"] = 1.0
	bridge_b_frame["power_status"] = 1.0
	bridge_a_frame["link"] = int(point2_configured.get("link", -1))
	item_bridge_build_state.source_item_bridge_tick_buildings_state(game, 1.0 / 60.0)
	bridge_a_frame = bridge_a.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	bridge_b_frame = bridge_b.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	var linked_tick: bool = bool(bridge_a_frame.get("had_valid_link", false)) and bool(bridge_b_frame.get("had_valid_link", true)) == false

	# Unlink bridge A: the next tick recomputes had_valid_link
	# back to false -- the key tracks the live link, it is not
	# sticky.
	var unlinked_configured: Dictionary = item_bridge_build_state.source_item_bridge_configure_state(bridge_a_frame, -1, 28, 21)
	bridge_a_frame["link"] = int(unlinked_configured.get("link", -1))
	item_bridge_build_state.source_item_bridge_tick_buildings_state(game, 1.0 / 60.0)
	bridge_a_frame = bridge_a.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	proof["live_tick_recomputes_had_valid_link"] = linked_tick and bool(bridge_a_frame.get("had_valid_link", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemBridgeLinkFrameStateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
