extends Node

const main_scene := preload("res://scenes/Main.tscn")
const item_bridge_build_state := preload("res://src/game/SourceItemBridgeBuildState.gd")
const liquid_bridge_build_state := preload("res://src/game/SourceLiquidBridgeBuildState.gd")
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

	# pack(28, 21) = 28 * 65536 + 21 = 1835029; pack(31, 21) = 2031637;
	# pack(32, 21) = 2097173; pack(31, 25) = 2031641.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# --- Pure findLink (N2199): findLink (ItemBridge.java:167-173,
	# `public Tile findLink(int x, int y){`) returns the lastBuild
	# tile only when the tile exists, lastBuild exists, linkValid
	# holds (checkDouble=true), the lastBuild tile is not this
	# tile, and the lastBuild link is still -1.
	var found_link: Dictionary = item_bridge_build_state.source_item_bridge_find_link_state(28, 21, true, Vector2i(31, 21), true, -1, 12, true, true)
	proof["find_link_finds_unlinked_last_build"] = bool(found_link.get("found", false)) and found_link.get("link_cell", Vector2i.ZERO) == Vector2i(31, 21)

	var linked_last: Dictionary = item_bridge_build_state.source_item_bridge_find_link_state(28, 21, true, Vector2i(31, 21), true, 1835029, 12, true, true)
	var same_tile_last: Dictionary = item_bridge_build_state.source_item_bridge_find_link_state(28, 21, true, Vector2i(28, 21), true, -1, 12, true, true)
	var out_of_range_last: Dictionary = item_bridge_build_state.source_item_bridge_find_link_state(28, 21, true, Vector2i(41, 21), true, -1, 12, true, true)
	var no_last: Dictionary = item_bridge_build_state.source_item_bridge_find_link_state(28, 21, true, Vector2i.ZERO, false, -1, 12, true, true)
	var no_tile: Dictionary = item_bridge_build_state.source_item_bridge_find_link_state(28, 21, false, Vector2i(31, 21), true, -1, 12, true, true)
	proof["find_link_rejects_linked_or_same_tile"] = bool(linked_last.get("found", true)) == false and bool(same_tile_last.get("found", true)) == false and bool(out_of_range_last.get("found", true)) == false and bool(no_last.get("found", true)) == false and bool(no_tile.get("found", true)) == false

	# --- Pure playerPlaced (N2199): playerPlaced (ItemBridge.java:
	# 210-219) configures the found partner with this tile's
	# packed position (`link.build.configure(tile.pos());`) when
	# linkValid holds, this link does not already point there,
	# and the partner is not in proximity -- and always records
	# this build as lastBuild (`lastBuild = this;`).
	var configures: Dictionary = item_bridge_build_state.source_item_bridge_player_placed_state(28, 21, true, -1, Vector2i(31, 21), true, -1, 12, true, true, false)
	proof["player_placed_configures_partner"] = bool(configures.get("configure_other", false)) and configures.get("other_cell", Vector2i.ZERO) == Vector2i(31, 21) and int(configures.get("config_value", 0)) == 1835029 and configures.get("new_last_build_cell", Vector2i.ZERO) == Vector2i(28, 21)

	var adjacent: Dictionary = item_bridge_build_state.source_item_bridge_player_placed_state(28, 21, true, -1, Vector2i(29, 21), true, -1, 12, true, true, true)
	proof["player_placed_skips_adjacent_partner"] = bool(adjacent.get("configure_other", true)) == false and adjacent.get("new_last_build_cell", Vector2i.ZERO) == Vector2i(28, 21)

	var already_linked: Dictionary = item_bridge_build_state.source_item_bridge_player_placed_state(28, 21, true, 2031637, Vector2i(31, 21), true, -1, 12, true, true, false)
	proof["player_placed_skips_when_already_linked"] = bool(already_linked.get("configure_other", true)) == false and already_linked.get("new_last_build_cell", Vector2i.ZERO) == Vector2i(28, 21)

	var no_partner: Dictionary = item_bridge_build_state.source_item_bridge_player_placed_state(28, 21, true, -1, Vector2i.ZERO, false, -1, 12, true, true, false)
	proof["player_placed_updates_last_build_without_partner"] = bool(no_partner.get("configure_other", true)) == false and no_partner.get("new_last_build_cell", Vector2i.ZERO) == Vector2i(28, 21)

	# --- Live placement (N2199): the PortGame player-placed
	# hook is called directly after record_placed_block (the
	# N2197 precedent of calling the driver directly instead of
	# the full player path -- the hook line in
	# place_selected_block_at_world is pinned by the Python
	# test). Bridge A at (28, 21) has no partner yet; bridge B
	# at (31, 21) auto-links A back to itself (A.link becomes
	# pack(31, 21) = 2031637) and becomes the new lastBuild;
	# bridge C at (32, 21) is adjacent to B, so B is NOT
	# configured (proximity), but C still becomes lastBuild.
	var bridge_a_cell := Vector2i(28, 21)
	var bridge_a := Sprite2D.new()
	game.add_child(bridge_a)
	game.call("record_placed_block", bridge_a, blocks_by_id["phase-conveyor"], bridge_a_cell)
	game.call("source_item_bridge_player_placed_dispatch_state", bridge_a, blocks_by_id["phase-conveyor"], bridge_a_cell)
	var last_builds: Dictionary = game.get("source_item_bridge_last_build_by_block")
	var first_last_build: bool = last_builds.get("phase-conveyor", Vector2i.ZERO) == bridge_a_cell

	var bridge_b_cell := Vector2i(31, 21)
	var bridge_b := Sprite2D.new()
	game.add_child(bridge_b)
	game.call("record_placed_block", bridge_b, blocks_by_id["phase-conveyor"], bridge_b_cell)
	game.call("source_item_bridge_player_placed_dispatch_state", bridge_b, blocks_by_id["phase-conveyor"], bridge_b_cell)
	var bridge_a_frame: Dictionary = bridge_a.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	var bridge_b_frame: Dictionary = bridge_b.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	last_builds = game.get("source_item_bridge_last_build_by_block")
	var linked_live: bool = int(bridge_a_frame.get("link", 0)) == 2031637 and last_builds.get("phase-conveyor", Vector2i.ZERO) == bridge_b_cell

	var bridge_c_cell := Vector2i(32, 21)
	var bridge_c := Sprite2D.new()
	game.add_child(bridge_c)
	game.call("record_placed_block", bridge_c, blocks_by_id["phase-conveyor"], bridge_c_cell)
	game.call("source_item_bridge_player_placed_dispatch_state", bridge_c, blocks_by_id["phase-conveyor"], bridge_c_cell)
	bridge_b_frame = bridge_b.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	last_builds = game.get("source_item_bridge_last_build_by_block")
	var adjacent_live: bool = int(bridge_b_frame.get("link", 0)) == -1 and last_builds.get("phase-conveyor", Vector2i.ZERO) == bridge_c_cell
	proof["live_placement_auto_links_and_updates_last_build"] = first_last_build and linked_live and adjacent_live

	# --- Live liquid placement (N2199): LiquidBridge inherits
	# playerPlaced (LiquidBridgeBuild extends ItemBridgeBuild,
	# LiquidBridge.java:19, no override), so conduits auto-link
	# through the same pures -- with their OWN lastBuild entry
	# (per block def: lastBuild is a field on the Block,
	# ItemBridge.java:41-42). Conduit A at (28, 25), conduit B
	# at (31, 25): A.link becomes pack(31, 25) = 2031641 and
	# the phase-conduit lastBuild becomes (31, 25), while the
	# phase-conveyor lastBuild stays (32, 21).
	var conduit_a_cell := Vector2i(28, 25)
	var conduit_a := Sprite2D.new()
	game.add_child(conduit_a)
	game.call("record_placed_block", conduit_a, blocks_by_id["phase-conduit"], conduit_a_cell)
	game.call("source_item_bridge_player_placed_dispatch_state", conduit_a, blocks_by_id["phase-conduit"], conduit_a_cell)

	var conduit_b_cell := Vector2i(31, 25)
	var conduit_b := Sprite2D.new()
	game.add_child(conduit_b)
	game.call("record_placed_block", conduit_b, blocks_by_id["phase-conduit"], conduit_b_cell)
	game.call("source_item_bridge_player_placed_dispatch_state", conduit_b, blocks_by_id["phase-conduit"], conduit_b_cell)
	var conduit_a_frame: Dictionary = conduit_a.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})
	last_builds = game.get("source_item_bridge_last_build_by_block")
	proof["live_liquid_placement_auto_links"] = int(conduit_a_frame.get("link", 0)) == 2031641 and last_builds.get("phase-conduit", Vector2i.ZERO) == conduit_b_cell and last_builds.get("phase-conveyor", Vector2i.ZERO) == bridge_c_cell

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemBridgeAutoLinkProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
