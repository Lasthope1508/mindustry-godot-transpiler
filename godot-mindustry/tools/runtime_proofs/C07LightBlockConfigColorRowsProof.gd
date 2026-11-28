extends Node

const main_scene := preload("res://scenes/Main.tscn")
const light_block_build_state := preload("res://src/game/SourceLightBlockBuildState.gd")
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

	# --- Config / color rows (N2443): LightBlock
	# config(Integer) (LightBlock.java:35), configured
	# (:72-76), control (:78-88), sense (:90-94),
	# buildConfiguration (:109-115),
	# onConfigureBuildTapped (:117-127) and config()
	# (:132-133). config(Integer) is `tile.color =
	# value`; configured is super + the minimap update
	# when !headless; control is `color =
	# Tmp.c1.fromDouble(p1).rgba8888();` for
	# LAccess.color + the minimap update when
	# !headless, then super; sense is `Tmp.c1.set(
	# color).toDoubleBits()` for LAccess.color, else
	# super.sense; buildConfiguration is the pencil
	# button 40f opening the picker at alpha 0.5f;
	# onConfigureBuildTapped deselects + returns false
	# on a self tap, returns true otherwise; config()
	# returns color. The sense value is arc's
	# double-bits encoding (`return Double.
	# longBitsToDouble(Color.rgba8888(r, g, b, a) &
	# 0x00000000_ffffffffL);`, Color.java:166-168): a
	# double denormal whose raw bits are the rgba8888
	# int zero-extended, exactly float(rgba) * 2^-1074
	# (the float32 set(int)->rgba8888() round-trip is
	# EXACT for every channel 0-255). The pure
	# zero-extends the Java signed 32-bit color int
	# (`color & 0xffffffff`) because GDScript ints are
	# 64-bit. The denormal is verified by dividing
	# back (value / 5e-324 == float(unsigned), exact)
	# -- is_equal_approx must NOT be used here, its
	# epsilon would swallow any denormal difference.
	# The control color is the caller-supplied raw low
	# 32 bits of p1 (GDScript has no double bitcast;
	# the logic executor owns the bitcast). The
	# minimap update has NO color-changed condition:
	# Java calls configured / the minimap update
	# unconditionally (BuildingComp.java:1429,
	# InputHandler.java:706-728), so a configure with
	# the SAME color still updates the minimap when
	# !headless.
	var fixture_color := 0xFFAA3300
	var accent_color := 0xFFD37FFF

	# --- Sense color double-bits: sense("color",
	# 0xFFAA3300) returns the denormal whose raw bits
	# are the color int -- value / 5e-324 recovers the
	# unsigned int exactly, and the value is positive
	# (a denormal, not zero). The default accent color
	# 0xffd37fff (Pal.accent, Pal.java:79) round-trips
	# the same way. A Java-negative color (-1, the
	# signed int for 0xffffffff) zero-extends to
	# 4294967295. Color 0 senses exactly 0.0.
	var ulp_bytes := PackedByteArray()
	ulp_bytes.resize(8)
	ulp_bytes.encode_s64(0, 1)
	var double_min_denormal: float = ulp_bytes.decode_double(0)
	var sensed: Dictionary = light_block_build_state.source_light_block_sense_color_state("color", fixture_color)
	var sensed_accent: Dictionary = light_block_build_state.source_light_block_sense_color_state("color", accent_color)
	var sensed_negative: Dictionary = light_block_build_state.source_light_block_sense_color_state("color", -1)
	var sensed_zero: Dictionary = light_block_build_state.source_light_block_sense_color_state("color", 0)
	proof["sense_color_double_bits"] = bool(sensed.get("delegated", true)) == false and float(sensed.get("value", -1.0)) > 0.0 and float(sensed.get("value", -1.0)) / double_min_denormal == float(fixture_color) and float(sensed_accent.get("value", -1.0)) / double_min_denormal == float(accent_color) and float(sensed_negative.get("value", -1.0)) / double_min_denormal == 4294967295.0 and float(sensed_zero.get("value", -1.0)) == 0.0

	# --- Sense delegate: any sensor other than color
	# falls through to the caller-supplied super.sense
	# value (the N2437 super_value precedent) with
	# delegated true -- "health" with 42.5 passes 42.5
	# through, "x" with null passes null through (the
	# super default branch).
	var sensed_health: Dictionary = light_block_build_state.source_light_block_sense_color_state("health", fixture_color, 42.5)
	var sensed_x: Dictionary = light_block_build_state.source_light_block_sense_color_state("x", fixture_color, null)
	proof["sense_delegate"] = bool(sensed_health.get("delegated", false)) == true and float(sensed_health.get("value", -1.0)) == 42.5 and bool(sensed_x.get("delegated", false)) == true and sensed_x.get("value", -1.0) == null

	# --- Configure set: the "configure" action applies
	# the config(Integer) handler (color = the Integer
	# value) and config() returns the post-action
	# color; the minimap updates when !headless, and
	# NOT when headless. A configure with the SAME
	# color still updates the minimap (Java-exact: no
	# equality check in the configured chain). The
	# "none" action leaves the color untouched and
	# updates nothing. The picker CALL record carries
	# the pencil icon, the 40f button size and the
	# 0.5f picker alpha (NOT the 0.6f draw alpha).
	var configured: Dictionary = light_block_build_state.source_light_block_config_color_state(fixture_color, "configure", 0x11223344, false, false)
	var configured_same: Dictionary = light_block_build_state.source_light_block_config_color_state(0x11223344, "configure", 0x11223344, false, false)
	var configured_headless: Dictionary = light_block_build_state.source_light_block_config_color_state(fixture_color, "configure", 0x11223344, false, true)
	var untouched: Dictionary = light_block_build_state.source_light_block_config_color_state(fixture_color, "none", null, false, false)
	var picker_call: Dictionary = configured.get("picker_call", {})
	proof["configure_set"] = int(configured.get("color", -1)) == 0x11223344 and int(configured.get("config_value", -1)) == 0x11223344 and bool(configured.get("minimap_updated", false)) == true and bool(configured_same.get("minimap_updated", false)) == true and bool(configured_headless.get("minimap_updated", true)) == false and int(untouched.get("color", -1)) == fixture_color and bool(untouched.get("minimap_updated", true)) == false and picker_call.get("icon", "") == "pencil" and is_equal_approx(float(picker_call.get("size", -1.0)), 40.0) and is_equal_approx(float(picker_call.get("color_a", -1.0)), 0.5)

	# --- Control bits: the "control" action applies
	# the LAccess.color control (color = the
	# caller-supplied raw low 32 bits of p1) and
	# config() returns the post-action color; the
	# minimap updates when !headless, and NOT when
	# headless. A control with the Java-negative bits
	# -1 stores the signed int -1 (0xffffffff
	# unsigned), and sensing that color recovers
	# 4294967295.0 -- the control -> sense round-trip.
	var controlled: Dictionary = light_block_build_state.source_light_block_config_color_state(fixture_color, "control", 0xAABBCCDD, false, false)
	var controlled_headless: Dictionary = light_block_build_state.source_light_block_config_color_state(fixture_color, "control", 0xAABBCCDD, false, true)
	var controlled_negative: Dictionary = light_block_build_state.source_light_block_config_color_state(fixture_color, "control", -1, false, false)
	var sensed_controlled: Dictionary = light_block_build_state.source_light_block_sense_color_state("color", int(controlled_negative.get("color", 0)))
	proof["control_bits"] = int(controlled.get("color", -1)) == 0xAABBCCDD and int(controlled.get("config_value", -1)) == 0xAABBCCDD and bool(controlled.get("minimap_updated", false)) == true and bool(controlled_headless.get("minimap_updated", true)) == false and int(controlled_negative.get("color", 0)) == -1 and float(sensed_controlled.get("value", -1.0)) / double_min_denormal == 4294967295.0

	# --- Tapped self/other: onConfigureBuildTapped
	# deselects + returns false on a self tap, and
	# returns true (no deselect) on any other tap.
	var tapped_self: Dictionary = light_block_build_state.source_light_block_config_color_state(fixture_color, "none", null, true, false)
	var tapped_other: Dictionary = light_block_build_state.source_light_block_config_color_state(fixture_color, "none", null, false, false)
	var self_result: Dictionary = tapped_self.get("tapped_result", {})
	var other_result: Dictionary = tapped_other.get("tapped_result", {})
	proof["tapped_self_other"] = bool(self_result.get("deselect", false)) == true and bool(self_result.get("return_value", true)) == false and bool(other_result.get("deselect", true)) == false and bool(other_result.get("return_value", false)) == true

	# --- Minimap color | 0xff: a color set through the
	# config pure flows into the N2439 draw-place
	# pure's minimapColor fold -- 0xFFAA3300 ->
	# 0xFFAA33FF, 0x11223300 -> 0x112233FF ("make sure
	# A is 255", LightBlock.java:64).
	var minimap_configured: Dictionary = light_block_build_state.source_light_block_config_color_state(fixture_color, "configure", 0xFFAA3300, false, false)
	var minimap_placed: Dictionary = light_block_build_state.source_light_block_draw_place_state(10, 20, 1, true, 140.0, 0.0, minimap_configured.get("config_value", null))
	var minimap_placed2: Dictionary = light_block_build_state.source_light_block_draw_place_state(10, 20, 1, true, 140.0, 0.0, 0x11223300)
	proof["minimap_color_or_ff"] = int(minimap_placed.get("minimap_color", -1)) == 0xFFAA33FF and int(minimap_placed2.get("minimap_color", -1)) == 0x112233FF

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LightBlockConfigColorRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
