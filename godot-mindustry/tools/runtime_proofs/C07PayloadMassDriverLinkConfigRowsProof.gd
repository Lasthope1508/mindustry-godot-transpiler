extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_mass_driver_build_state := preload("res://src/game/SourcePayloadMassDriverBuildState.gd")
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

	# --- Link / config rows (N2460):
	# PayloadMassDriver config Point2
	# (PayloadMassDriver.java:70, relative point
	# + tile, packed) + config Integer (:71,
	# absolute packed int),
	# onConfigureBuildTapped (:443-460,
	# self-tap / unlink / link / fall through),
	# linkValid (:466-468, link != -1 +
	# looked-up PayloadDriverBuild + block ==
	# block + team == team + within(range))
	# and config() (:471-474, null tile ->
	# null, else unpack minus tile). The
	# DEFERRED entry cited :64-65 and :321-350
	# -- BOTH WRONG: :64-65 are the constructor
	# flags (the handlers are :70-71) and
	# :321-350 are sense() / updatePayload() /
	# draw(). The link is a PACKED INT
	# (`public int link = -1;`, :133), packed
	# by arc Point2.pack (Point2.java:40-42).
	# The tap gate is `other.block instanceof
	# PayloadMassDriver` -- NOT `other.block ==
	# block` (MassDriver.java:274), so a small
	# driver links to a large one. The tap
	# return means "should deselect"
	# (BuildingComp.java:1690), so handled
	# INVERTS it: true exactly when a configure
	# ran. config() has NO -1 special case:
	# unpack(-1) is (-1, -1) (arc
	# Point2.java:35-37). PMD registers NO
	# configClear: "clear" is configure(-1)
	# through the Integer handler. Pure-only:
	# the tick never calls config /
	# onConfigureBuildTapped / linkValid.
	# Packed literals: pack(10, 20) = 655380,
	# pack(12, 17) = 786449, pack(30, 40) =
	# 1966120, pack(0, 0) = 0.

	# --- Link valid true: a set link with all
	# five conjuncts true validates -- and the
	# packed origin (0, 0) is a valid link too,
	# since only -1 means unlinked.
	var valid: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_link_valid_state(655380, true, true, true, true)
	var valid_origin: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_link_valid_state(0, true, true, true, true)
	proof["link_valid_true"] = bool(valid.get("link_valid", false)) == true and bool(valid_origin.get("link_valid", false)) == true

	# --- Link valid minus one: link == -1 is
	# invalid even when every other conjunct
	# holds, and a lookup that finds no
	# PayloadDriverBuild is invalid too.
	var minus_one: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_link_valid_state(-1, true, true, true, true)
	var not_pmd: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_link_valid_state(655380, false, true, true, true)
	proof["link_valid_minus_one"] = bool(minus_one.get("link_valid", true)) == false and bool(not_pmd.get("link_valid", true)) == false

	# --- Link valid range: each remaining
	# conjunct fails closed -- out of range, a
	# block mismatch, and a team mismatch each
	# invalidate a set link on their own.
	var out_of_range: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_link_valid_state(655380, true, true, true, false)
	var block_mismatch: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_link_valid_state(655380, true, false, true, true)
	var team_mismatch: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_link_valid_state(655380, true, true, false, true)
	proof["link_valid_range"] = bool(out_of_range.get("link_valid", true)) == false and bool(block_mismatch.get("link_valid", true)) == false and bool(team_mismatch.get("link_valid", true)) == false

	# --- Config Point2 relative: the Point2
	# config is RELATIVE -- point (2, -3) from
	# tile (10, 20) packs to (12, 17) =
	# 786449, and config() reads the relative
	# point back. The Integer action takes the
	# absolute packed int as-is (pack(30, 40) =
	# 1966120 reads back relative (20, 20)),
	# and "none" leaves the link untouched.
	var point2: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_config_state("point2", {"x": 2, "y": -3}, 10, 20, -1)
	var integer: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_config_state("integer", 1966120, 10, 20, -1)
	var none: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_config_state("none", null, 10, 20, 655380)
	proof["config_point2_relative"] = int(point2.get("link", 0)) == 786449 and point2.get("config_value", {}) == {"x": 2, "y": -3} and int(integer.get("link", 0)) == 1966120 and integer.get("config_value", {}) == {"x": 20, "y": 20} and int(none.get("link", 0)) == 655380 and none.get("config_value", {}) == {"x": 0, "y": 0}

	# --- Config clear: "clear" sets -1
	# (configure(-1) through the Integer
	# handler -- PMD registers NO configClear)
	# and config() reads unpack(-1) = (-1, -1)
	# minus the tile, Java-exact with no -1
	# special case: (-11, -21) from tile (10,
	# 20). A null tile reads config() null and
	# a Point2 with a null tile leaves the link
	# untouched (the Java handler dereferences
	# tile.tileX()/tileY()).
	var cleared: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_config_state("clear", null, 10, 20, 655380)
	var cleared_empty: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_config_state("clear", null, 10, 20, -1)
	var null_tile: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_config_state("none", null, null, null, 655380)
	var point2_null_tile: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_config_state("point2", {"x": 2, "y": 2}, null, null, 655380)
	proof["config_clear"] = int(cleared.get("link", 0)) == -1 and cleared.get("config_value", {}) == {"x": -11, "y": -21} and int(cleared_empty.get("link", 0)) == -1 and cleared_empty.get("config_value", {}) == {"x": -11, "y": -21} and null_tile.get("config_value", {}) == null and int(null_tile.get("link", 0)) == 655380 and int(point2_null_tile.get("link", 0)) == 655380 and point2_null_tile.get("config_value", {}) == null

	# --- Tapped link: tapping a valid partner
	# links to its packed pos (dst <= range --
	# the 700.0 boundary links too), a self-tap
	# always unlinks and deselects only when
	# already unlinked, tapping the linked
	# partner unlinks, and an out-of-range /
	# wrong-team / non-PMD tap falls through
	# (handled false, link untouched).
	var linked: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_configure_tapped_state(false, -1, 1966120, true, 500.0, 700.0, true)
	var linked_boundary: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_configure_tapped_state(false, -1, 1966120, true, 700.0, 700.0, true)
	var self_linked: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_configure_tapped_state(true, 655380, 655380, true, 0.0, 700.0, true)
	var self_unlinked: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_configure_tapped_state(true, -1, 655380, true, 0.0, 700.0, true)
	var unlinked: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_configure_tapped_state(false, 1966120, 1966120, true, 500.0, 700.0, true)
	var too_far: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_configure_tapped_state(false, -1, 1966120, true, 800.0, 700.0, true)
	var wrong_team: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_configure_tapped_state(false, -1, 1966120, true, 500.0, 700.0, false)
	var not_pmd_tap: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_configure_tapped_state(false, -1, 1966120, false, 500.0, 700.0, true)
	proof["tapped_link"] = int(linked.get("link_after", 0)) == 1966120 and bool(linked.get("deselect_called", true)) == false and bool(linked.get("handled", false)) == true and int(linked_boundary.get("link_after", 0)) == 1966120 and bool(linked_boundary.get("handled", false)) == true and int(self_linked.get("link_after", 0)) == -1 and bool(self_linked.get("deselect_called", true)) == false and bool(self_linked.get("handled", false)) == true and int(self_unlinked.get("link_after", 0)) == -1 and bool(self_unlinked.get("deselect_called", false)) == true and bool(self_unlinked.get("handled", false)) == true and int(unlinked.get("link_after", 0)) == -1 and bool(unlinked.get("deselect_called", true)) == false and bool(unlinked.get("handled", false)) == true and int(too_far.get("link_after", 0)) == -1 and bool(too_far.get("handled", true)) == false and int(wrong_team.get("link_after", 0)) == -1 and bool(wrong_team.get("handled", true)) == false and int(not_pmd_tap.get("link_after", 0)) == -1 and bool(not_pmd_tap.get("handled", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadMassDriverLinkConfigRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
