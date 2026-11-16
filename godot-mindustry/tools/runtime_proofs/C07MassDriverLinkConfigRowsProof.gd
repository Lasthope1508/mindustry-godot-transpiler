extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mass_driver_build_state := preload("res://src/game/SourceMassDriverBuildState.gd")
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

	# --- Link / config rows (N2461):
	# The MassDriver tick is live (N2237 updateTile
	# advance + N2294 dumpAccumulate + N2336
	# acceptItem gate + N2392 sense + N2396 draw
	# rows + N2406 dump neighbour live fill) but
	# NOTHING modeled the link/config rows:
	# linkValid() (MassDriver.java:346-349),
	# config(Point2) (:58, the RELATIVE point2
	# packed against the tile) / config(Integer)
	# (:59, the absolute packed int), config()
	# (:352-355, the relative Point2, null when
	# tile == null) and onConfigureBuildTapped
	# (:266-282, self / unlink / link / reject).
	# The link is a PACKED INT (not a Vector2i):
	# pack(x, y) = (((short)x) << 16) |
	# (((short)y) & 0xFFFF) and unpack(pos) =
	# Point2((short)(pos >>> 16), (short)(pos &
	# 0xFFFF)) (arc Point2.java:35-42) -- so
	# unpack(-1) is Point2(-1, -1) and a cleared
	# link reads config_value (-1 - tx, -1 - ty).
	# linkValid is link != -1 AND the linked
	# build is a MassDriverBuild of the same
	# block + team + within(range) -- within is
	# STRICT dst2 < range*range (Position.
	# java:44-46, pixels, range 440f). The tap
	# range check is other.dst(tile) <= range
	# INCLUSIVE -- NOT within's strict < -- so
	# the boundary dst == range LINKS on tap
	# but FAILS linkValid's within. The pure
	# names the key `handled` = NOT the Java
	# return (Java returns false = handled,
	# don't propagate). Pure-only: the tick
	# never calls linkValid / config /
	# onConfigureBuildTapped through these
	# pures -- the config-UI / input-handler
	# call sites wait for their own slices.
	var tile: Dictionary = {"x": 10, "y": 20}
	var link_here: int = (10 << 16) | 20
	var link_far: int = (12 << 16) | 20
	var link_small: int = (5 << 16) | 7

	# --- Link valid true: link != -1 with the
	# linked build a same-block, same-team mass
	# driver within range is valid -- and each
	# single failing term (not a mass driver,
	# wrong block, wrong team) makes it invalid.
	var valid: Dictionary = mass_driver_build_state.source_mass_driver_link_valid_state(link_here, true, true, true, true)
	var not_driver: Dictionary = mass_driver_build_state.source_mass_driver_link_valid_state(link_here, false, true, true, true)
	var wrong_block: Dictionary = mass_driver_build_state.source_mass_driver_link_valid_state(link_here, true, false, true, true)
	var wrong_team: Dictionary = mass_driver_build_state.source_mass_driver_link_valid_state(link_here, true, true, false, true)
	proof["link_valid_true"] = bool(valid.get("link_valid", false)) == true and bool(not_driver.get("link_valid", true)) == false and bool(wrong_block.get("link_valid", true)) == false and bool(wrong_team.get("link_valid", true)) == false

	# --- Link valid minus one: link == -1 is
	# invalid BEFORE any lookup -- even with
	# every other verdict true (Java returns
	# false on the `if(link == -1)` guard,
	# MassDriver.java:347).
	var minus_one: Dictionary = mass_driver_build_state.source_mass_driver_link_valid_state(-1, true, true, true, true)
	proof["link_valid_minus_one"] = bool(minus_one.get("link_valid", true)) == false

	# --- Link valid range: the within_range
	# verdict is caller-supplied (STRICT dst2 <
	# range*range, Position.java:44-46) -- out
	# of range is invalid, in range is valid,
	# everything else held true.
	var out_of_range: Dictionary = mass_driver_build_state.source_mass_driver_link_valid_state(link_here, true, true, true, false)
	var in_range: Dictionary = mass_driver_build_state.source_mass_driver_link_valid_state(link_here, true, true, true, true)
	proof["link_valid_range"] = bool(out_of_range.get("link_valid", true)) == false and bool(in_range.get("link_valid", false)) == true

	# --- Config point2 relative: the "point2"
	# action packs the RELATIVE point against
	# the tile (point + tile, MassDriver.
	# java:58) -- point (3, -2) at tile (10, 20)
	# links pack(13, 18) -- and config() reads
	# the relative point back (unpack(link) -
	# tile). A "point2" action with a null tile
	# has NO defined Java outcome (the handler
	# dereferences tile.tileX()), so the pure
	# leaves the link untouched and config_value
	# is null per config() (:352-355).
	var relative: Dictionary = mass_driver_build_state.source_mass_driver_config_state("point2", {"x": 3, "y": -2}, tile, -1)
	var null_tile_point2: Dictionary = mass_driver_build_state.source_mass_driver_config_state("point2", {"x": 3, "y": -2}, null, link_here)
	proof["config_point2_relative"] = int(relative.get("link", 0)) == ((13 << 16) | 18) and relative.get("config_value", {}) == {"x": 3, "y": -2} and int(null_tile_point2.get("link", 0)) == link_here and null_tile_point2.get("config_value", {}) == null

	# --- Config integer: the "integer" action
	# takes the absolute packed int as-is
	# (MassDriver.java:59) -- pack(5, 7) at tile
	# (10, 20) reads config_value (-5, -13).
	# "clear" sets link -1 and reads config_value
	# (-1 - tx, -1 - ty) = (-11, -21) because
	# unpack(-1) is (-1, -1). "none" leaves the
	# link untouched. config_value is null
	# whenever tile is null, for every action.
	var absolute: Dictionary = mass_driver_build_state.source_mass_driver_config_state("integer", link_small, tile, -1)
	var cleared: Dictionary = mass_driver_build_state.source_mass_driver_config_state("clear", null, tile, link_here)
	var untouched: Dictionary = mass_driver_build_state.source_mass_driver_config_state("none", null, tile, link_here)
	var null_tile_integer: Dictionary = mass_driver_build_state.source_mass_driver_config_state("integer", link_small, null, -1)
	proof["config_integer"] = int(absolute.get("link", 0)) == link_small and absolute.get("config_value", {}) == {"x": -5, "y": -13} and int(cleared.get("link", 0)) == -1 and cleared.get("config_value", {}) == {"x": -11, "y": -21} and int(untouched.get("link", 0)) == link_here and untouched.get("config_value", {}) == {"x": 0, "y": 0} and int(null_tile_integer.get("link", 0)) == link_small and null_tile_integer.get("config_value", {}) == null

	# --- Tapped link: all four
	# onConfigureBuildTapped branches
	# (MassDriver.java:266-282). Self with link
	# -1 deselects + unlinks; self with a link
	# unlinks WITHOUT deselecting (only the
	# deselect is conditional -- configure(-1)
	# always runs). Tapping the linked target
	# unlinks without deselecting. Tapping a
	# valid other (same block + team, dst <=
	# range INCLUSIVE -- the boundary dst ==
	# range LINKS) links to it. Tapping an
	# invalid other (wrong team, wrong block,
	# out of range) leaves the link untouched
	# and is NOT handled (Java returns true =
	# propagate).
	var self_unlinked: Dictionary = mass_driver_build_state.source_mass_driver_configure_tapped_state(true, -1, link_far, true, 0.0, 440.0, true)
	var self_linked: Dictionary = mass_driver_build_state.source_mass_driver_configure_tapped_state(true, link_here, link_far, true, 0.0, 440.0, true)
	var tap_linked: Dictionary = mass_driver_build_state.source_mass_driver_configure_tapped_state(false, link_far, link_far, true, 100.0, 440.0, true)
	var tap_valid: Dictionary = mass_driver_build_state.source_mass_driver_configure_tapped_state(false, -1, link_far, true, 100.0, 440.0, true)
	var tap_boundary: Dictionary = mass_driver_build_state.source_mass_driver_configure_tapped_state(false, -1, link_far, true, 440.0, 440.0, true)
	var tap_wrong_team: Dictionary = mass_driver_build_state.source_mass_driver_configure_tapped_state(false, -1, link_far, true, 100.0, 440.0, false)
	var tap_wrong_block: Dictionary = mass_driver_build_state.source_mass_driver_configure_tapped_state(false, -1, link_far, false, 100.0, 440.0, true)
	var tap_out_of_range: Dictionary = mass_driver_build_state.source_mass_driver_configure_tapped_state(false, -1, link_far, true, 441.0, 440.0, true)
	proof["tapped_link"] = int(self_unlinked.get("link_after", 0)) == -1 and bool(self_unlinked.get("deselect_called", false)) == true and bool(self_unlinked.get("handled", false)) == true and int(self_linked.get("link_after", 0)) == -1 and bool(self_linked.get("deselect_called", true)) == false and bool(self_linked.get("handled", false)) == true and int(tap_linked.get("link_after", 0)) == -1 and bool(tap_linked.get("deselect_called", true)) == false and bool(tap_linked.get("handled", false)) == true and int(tap_valid.get("link_after", 0)) == link_far and bool(tap_valid.get("handled", false)) == true and int(tap_boundary.get("link_after", 0)) == link_far and bool(tap_boundary.get("handled", false)) == true and int(tap_wrong_team.get("link_after", 0)) == -1 and bool(tap_wrong_team.get("handled", true)) == false and int(tap_wrong_block.get("link_after", 0)) == -1 and bool(tap_wrong_block.get("handled", true)) == false and int(tap_out_of_range.get("link_after", 0)) == -1 and bool(tap_out_of_range.get("handled", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MassDriverLinkConfigRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
