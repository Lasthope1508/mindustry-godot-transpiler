extends Node

const main_scene := preload("res://scenes/Main.tscn")
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

	# --- Link / findLink / linkValid rows (N2463):
	# The LiquidBridge tick is live (N2198
	# shouldConsume gate + N2275 updateTransport
	# advance + N2287 doDump + N2379 dump neighbour
	# write-back + N2412 dodump neighbour live
	# fill) but NOTHING modeled the link/findLink
	# /linkValid rows as LiquidBridge-driver
	# pures: linkValid() (ItemBridge.java:145-155),
	# positionsValid() (:157-165), findLink()
	# (:167-173), config(Point2) (:64, the
	# RELATIVE point2 packed against the tile) /
	# config(Integer) (:66, the absolute packed
	# int) and config() (:500-501, the relative
	# Point2) -- all INHERITED (LiquidBridge
	# overrides NOTHING here: LiquidBridge.java
	# is 33 lines, overriding only updateTransport
	# / doDump). The link is a PACKED INT (not a
	# Vector2i): pack(x, y) = (((short)x) << 16) |
	# (((short)y) & 0xFFFF) and unpack(pos) =
	# Point2((short)(pos >>> 16), (short)(pos &
	# 0xFFFF)) (arc Point2.java:35-42) -- so
	# unpack(-1) is Point2(-1, -1) and a cleared
	# link reads config_value (-1 - tx, -1 - ty).
	# linkValid is the 3-arg Java exactly: the
	# null/positions guard first, then the block
	# clause ((other.block == tile.block &&
	# tile.block == this) || (!(tile.block
	# instanceof ItemBridge) && other.block ==
	# this)), the team clause (other.team ==
	# tile.team || tile.block != this) and the
	# checkDouble gate (!checkDouble ||
	# other.link != tile.pos()). The block clause
	# has FOUR distinct predicates, so the pure
	# takes a 10th param, tile_is_item_bridge
	# (the instanceof term): a phase-conveyor
	# tile (an ItemBridge, not this def) against
	# a bridge-conduit other is INVALID in Java
	# (linked(), ItemBridge.java:465, calls
	# linkValid(source.tile, tile) across defs).
	# positionsValid is caller-supplied (same x
	# -> |dy| <= range; same y -> |dx| <= range;
	# else false) because range VARIES per def
	# (bridge-conduit 4, phase-conduit 12,
	# Blocks.java:2379/2388). findLink returns
	# lastBuild.tile iff the tile exists, a
	# lastBuild exists, linkValid holds,
	# lastBuild.tile != tile and lastBuild.link
	# == -1. ItemBridge.config() has NO null
	# check (unlike MassDriver.config()), so
	# config_value null on a null tile is a
	# documented fallback. Pure-only: the tick
	# keeps recomputing had_valid_link through
	# N2197's pure linkValid and the
	# placement-time auto-link driver (N2199) is
	# untouched -- NOT rewired.
	var tile: Dictionary = {"x": 10, "y": 20}
	var link_here: int = (10 << 16) | 20
	var link_small: int = (5 << 16) | 7

	# --- Link valid true: every predicate true
	# is valid -- and each single failing term
	# (missing tile, missing other, wrong block,
	# wrong team) makes it invalid. The cross-def
	# case pins the 10th param: a phase-conveyor
	# tile (an ItemBridge, not this def) against
	# a bridge-conduit other is INVALID even
	# though the other IS this def. The
	# non-bridge-tile case pins the second
	# disjunct: a tile that is NOT a bridge at
	# all links to a bridge of this def, and the
	# team clause passes through the tile.block
	# != this escape even with teams_match false.
	var valid: Dictionary = liquid_bridge_build_state.source_liquid_bridge_link_valid_state(true, true, true, true, true, true, true, true, true, false)
	var no_tile: Dictionary = liquid_bridge_build_state.source_liquid_bridge_link_valid_state(false, true, true, true, true, true, true, true, true, false)
	var no_other: Dictionary = liquid_bridge_build_state.source_liquid_bridge_link_valid_state(true, false, true, true, true, true, true, true, true, false)
	var wrong_block: Dictionary = liquid_bridge_build_state.source_liquid_bridge_link_valid_state(true, true, true, false, true, true, true, true, true, false)
	var wrong_team: Dictionary = liquid_bridge_build_state.source_liquid_bridge_link_valid_state(true, true, true, true, true, true, true, false, true, false)
	var cross_def: Dictionary = liquid_bridge_build_state.source_liquid_bridge_link_valid_state(true, true, true, false, false, true, true, true, true, false)
	var non_bridge_tile: Dictionary = liquid_bridge_build_state.source_liquid_bridge_link_valid_state(true, true, true, false, false, false, true, false, true, false)
	proof["link_valid_true"] = bool(valid.get("link_valid", false)) == true and bool(no_tile.get("link_valid", true)) == false and bool(no_other.get("link_valid", true)) == false and bool(wrong_block.get("link_valid", true)) == false and bool(wrong_team.get("link_valid", true)) == false and bool(cross_def.get("link_valid", true)) == false and bool(non_bridge_tile.get("link_valid", false)) == true

	# --- Link valid positions: the
	# positionsValid verdict is caller-supplied
	# (same x -> |dy| <= range; same y -> |dx|
	# <= range; else false, ItemBridge.
	# java:157-165) -- invalid positions are
	# invalid even with every other verdict
	# true, valid positions pass. Range varies
	# per def (bridge-conduit 4, phase-conduit
	# 12), so the caller computes the verdict
	# against its own def range and the pure
	# takes it as input.
	var bad_positions: Dictionary = liquid_bridge_build_state.source_liquid_bridge_link_valid_state(true, true, false, true, true, true, true, true, true, false)
	var good_positions: Dictionary = liquid_bridge_build_state.source_liquid_bridge_link_valid_state(true, true, true, true, true, true, true, true, true, false)
	proof["link_valid_positions"] = bool(bad_positions.get("link_valid", true)) == false and bool(good_positions.get("link_valid", false)) == true

	# --- Link valid double: the checkDouble
	# gate (ItemBridge.java:154, `(!checkDouble
	# || ((ItemBridgeBuild)other.build).link !=
	# tile.pos())`). With check_double true, an
	# other link already pointing back at this
	# tile is invalid; with the other link
	# elsewhere it is valid. With check_double
	# false (checkIncoming, ItemBridge.java:310,
	# `linkValid(tile, other, false)`), the
	# double link does NOT block.
	var double_blocked: Dictionary = liquid_bridge_build_state.source_liquid_bridge_link_valid_state(true, true, true, true, true, true, true, true, true, true)
	var double_ok: Dictionary = liquid_bridge_build_state.source_liquid_bridge_link_valid_state(true, true, true, true, true, true, true, true, true, false)
	var no_double_check: Dictionary = liquid_bridge_build_state.source_liquid_bridge_link_valid_state(true, true, true, true, true, true, true, true, false, true)
	proof["link_valid_double"] = bool(double_blocked.get("link_valid", true)) == false and bool(double_ok.get("link_valid", false)) == true and bool(no_double_check.get("link_valid", false)) == true

	# --- Find link found: the lastBuild tile
	# (12, 20) is found when the tile exists, a
	# lastBuild exists, linkValid holds and the
	# lastBuild link is still -1. A failing
	# linkValid verdict, a missing lastBuild, or
	# a missing tile all find nothing.
	var last_build: Dictionary = {"tile": {"x": 12, "y": 20}, "link": -1}
	var found: Dictionary = liquid_bridge_build_state.source_liquid_bridge_find_link_state(tile, last_build, true)
	var not_valid: Dictionary = liquid_bridge_build_state.source_liquid_bridge_find_link_state(tile, last_build, false)
	var no_last_build: Dictionary = liquid_bridge_build_state.source_liquid_bridge_find_link_state(tile, null, true)
	var no_tile_find: Dictionary = liquid_bridge_build_state.source_liquid_bridge_find_link_state(null, last_build, true)
	proof["find_link_found"] = found.get("found_tile", {}) == {"x": 12, "y": 20} and not_valid.get("found_tile", {}) == null and no_last_build.get("found_tile", {}) == null and no_tile_find.get("found_tile", {}) == null

	# --- Find link last build: the lastBuild-side
	# guards (ItemBridge.java:169). A lastBuild
	# tile that IS this tile finds nothing
	# (`lastBuild.tile != tile`), a lastBuild
	# whose link is already set finds nothing
	# (`lastBuild.link == -1`), and a lastBuild
	# record with no tile dict finds nothing.
	var same_tile_build: Dictionary = {"tile": {"x": 10, "y": 20}, "link": -1}
	var linked_build: Dictionary = {"tile": {"x": 12, "y": 20}, "link": link_small}
	var no_tile_build: Dictionary = {"link": -1}
	var same_tile: Dictionary = liquid_bridge_build_state.source_liquid_bridge_find_link_state(tile, same_tile_build, true)
	var already_linked: Dictionary = liquid_bridge_build_state.source_liquid_bridge_find_link_state(tile, linked_build, true)
	var no_tile_dict: Dictionary = liquid_bridge_build_state.source_liquid_bridge_find_link_state(tile, no_tile_build, true)
	proof["find_link_last_build"] = same_tile.get("found_tile", {}) == null and already_linked.get("found_tile", {}) == null and no_tile_dict.get("found_tile", {}) == null

	# --- Config point2 relative: the "point2"
	# action packs the RELATIVE point against
	# the tile (point + tile, ItemBridge.
	# java:64) -- point (3, -2) at tile (10, 20)
	# links pack(13, 18) -- and config() reads
	# the relative point back (unpack(link) -
	# tile). A "point2" action with a null tile
	# has NO defined Java outcome (the handler
	# dereferences tile.tileX()), so the pure
	# leaves the link untouched and config_value
	# is null. The "integer" action takes the
	# absolute packed int as-is (ItemBridge.
	# java:66) -- pack(5, 7) at tile (10, 20)
	# reads config_value (-5, -13). "clear"
	# sets link -1 and reads config_value
	# (-1 - tx, -1 - ty) = (-11, -21) because
	# unpack(-1) is (-1, -1). "none" leaves the
	# link untouched. An unknown action matches
	# no handler and leaves the link untouched.
	# config_value is null whenever tile is null,
	# for every action (the documented fallback
	# -- ItemBridge.config() has no null check).
	var relative: Dictionary = liquid_bridge_build_state.source_liquid_bridge_config_state("point2", {"x": 3, "y": -2}, tile, -1)
	var null_tile_point2: Dictionary = liquid_bridge_build_state.source_liquid_bridge_config_state("point2", {"x": 3, "y": -2}, null, link_here)
	var absolute: Dictionary = liquid_bridge_build_state.source_liquid_bridge_config_state("integer", link_small, tile, -1)
	var cleared: Dictionary = liquid_bridge_build_state.source_liquid_bridge_config_state("clear", null, tile, link_here)
	var untouched: Dictionary = liquid_bridge_build_state.source_liquid_bridge_config_state("none", null, tile, link_here)
	var null_tile_integer: Dictionary = liquid_bridge_build_state.source_liquid_bridge_config_state("integer", link_small, null, -1)
	var unknown_action: Dictionary = liquid_bridge_build_state.source_liquid_bridge_config_state("bogus", null, tile, link_here)
	proof["config_point2_relative"] = int(relative.get("link", 0)) == ((13 << 16) | 18) and relative.get("config_value", {}) == {"x": 3, "y": -2} and int(null_tile_point2.get("link", 0)) == link_here and null_tile_point2.get("config_value", {}) == null and int(absolute.get("link", 0)) == link_small and absolute.get("config_value", {}) == {"x": -5, "y": -13} and int(cleared.get("link", 0)) == -1 and cleared.get("config_value", {}) == {"x": -11, "y": -21} and int(untouched.get("link", 0)) == link_here and untouched.get("config_value", {}) == {"x": 0, "y": 0} and int(null_tile_integer.get("link", 0)) == link_small and null_tile_integer.get("config_value", {}) == null and int(unknown_action.get("link", 0)) == link_here

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LiquidBridgeLinkRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
