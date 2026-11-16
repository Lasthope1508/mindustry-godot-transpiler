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

	# --- Check-accept rows (N2467): ItemBridge.
	# checkAccept() (ItemBridge.java:441-462) is
	# the facing gate acceptItem (:424-426) and
	# acceptLiquid (:434-439) consult for a
	# non-linked source: tile == null or
	# linked(source) accepts outright, a valid
	# link accepts when the link direction
	# differs from the source facing direction
	# (rel != rel2), anything else refuses.
	# linked(source) (:464-466) means the source
	# is an ItemBridgeBuild, linkValid from the
	# source tile to this tile holds, and the
	# source link points back at this build.
	# relativeTo is BuildingComp.relativeTo(Tile)
	# via Tile.absoluteRelativeTo (0 east, 1
	# north, 2 west, 3 south, -1 same tile), so
	# the link direction is a real direction even
	# at range -- NOT Tile.relativeTo, which
	# returns -1 for the non-adjacent link.
	# rel2 is -1 when the facing edge is null
	# (Edges.getFacingEdge returns null only when
	# the source has no tile). The commented-out
	# incoming loop (:450-456) is NOT ported.
	#
	# Fixture: the bridge tile is (10, 20) with
	# its link 3 tiles east, so rel is 0 (east).
	# A conveyor feeding from the west has its
	# facing edge west of the bridge, rel2 2; a
	# conveyor feeding from the link direction
	# (east) has rel2 0 and is refused.

	# --- Tile null: a missing tile accepts
	# outright, even on a facing match and even
	# with an invalid link -- the `if(tile ==
	# null || linked(source)) return true;`
	# shortcut runs before the linkValid gate.
	var null_tile_mismatch: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(true, false, true, 0, 2)
	var null_tile_match: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(true, false, true, 0, 0)
	var null_tile_invalid: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(true, false, false, 0, 0)
	proof["accept_tile_null"] = bool(null_tile_mismatch.get("accepts", false)) and bool(null_tile_match.get("accepts", false)) and bool(null_tile_invalid.get("accepts", false))

	# --- Linked: a linked source accepts
	# outright, even on a facing match and even
	# with an invalid link -- the transport path
	# takes this shortcut (ItemBridge.java:
	# 464-466), so acceptItem there is the
	# capacity gate only.
	var linked_mismatch: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(false, true, true, 0, 2)
	var linked_match: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(false, true, true, 0, 0)
	var linked_invalid: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(false, true, false, 0, 0)
	proof["accept_linked"] = bool(linked_mismatch.get("accepts", false)) and bool(linked_match.get("accepts", false)) and bool(linked_invalid.get("accepts", false))

	# --- Facing mismatch: with a valid link, a
	# source whose facing direction differs from
	# the link direction is accepted. Link east
	# (rel 0), source facing west (rel2 2) or
	# north (rel2 1) or south (rel2 3) all accept;
	# a north link (rel 1) with a west-facing
	# source (rel2 2) accepts too.
	var mismatch_west: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(false, false, true, 0, 2)
	var mismatch_north: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(false, false, true, 0, 1)
	var mismatch_south: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(false, false, true, 0, 3)
	var mismatch_north_link: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(false, false, true, 1, 2)
	proof["accept_facing_mismatch"] = bool(mismatch_west.get("accepts", false)) and bool(mismatch_north.get("accepts", false)) and bool(mismatch_south.get("accepts", false)) and bool(mismatch_north_link.get("accepts", false))

	# --- Facing match: with a valid link, a
	# source feeding from the link direction is
	# refused -- rel == rel2, and the commented-
	# out incoming loop grants no exemption. Link
	# east (rel 0) with an east-facing source
	# (rel2 0) refuses; a west link (rel 2) with
	# a west-facing source (rel2 2) refuses too.
	var match_east: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(false, false, true, 0, 0)
	var match_west: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(false, false, true, 2, 2)
	proof["accept_facing_match"] = not bool(match_east.get("accepts", true)) and not bool(match_west.get("accepts", true))

	# --- No facing: a null facing edge reads
	# rel2 -1, which differs from any real link
	# direction, so the source is accepted. The
	# -1 == -1 boundary refuses: rel -1 (the link
	# tile is this tile) equals rel2 -1, so rel
	# != rel2 is false -- unreachable live, since
	# linkValid fails for a self link, but it
	# pins the comparison exactly.
	var no_facing_east: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(false, false, true, 0, -1)
	var no_facing_north: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(false, false, true, 1, -1)
	var no_facing_boundary: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(false, false, true, -1, -1)
	proof["accept_no_facing"] = bool(no_facing_east.get("accepts", false)) and bool(no_facing_north.get("accepts", false)) and not bool(no_facing_boundary.get("accepts", true))

	# --- Link invalid: without a valid link, a
	# non-linked source with a tile is refused
	# regardless of the facing -- the `return
	# false;` after the linkValid gate. A facing
	# mismatch, a facing match, and a null facing
	# all refuse.
	var invalid_mismatch: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(false, false, false, 0, 2)
	var invalid_match: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(false, false, false, 0, 0)
	var invalid_no_facing: Dictionary = item_bridge_build_state.source_item_bridge_check_accept_state(false, false, false, 0, -1)
	proof["accept_link_invalid"] = not bool(invalid_mismatch.get("accepts", true)) and not bool(invalid_match.get("accepts", true)) and not bool(invalid_no_facing.get("accepts", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemBridgeCheckAcceptRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
