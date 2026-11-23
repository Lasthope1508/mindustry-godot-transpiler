extends Node

const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_game_headless_state := preload("res://src/game/SourceGameHeadlessState.gd")
const source_game_loop_runtime_state := preload("res://src/game/SourceGameLoopRuntimeState.gd")
const source_building_time_state := preload("res://src/game/SourceBuildingTimeState.gd")


class FakeHeadlessGame:
	extends Node
	var headless := false
	var calls: Array = []
	func load_config() -> void:
		calls.append(["load_config"])
	func load_content_registry() -> void:
		calls.append(["load_content_registry"])
	func load_textures() -> void:
		calls.append(["load_textures"])
	func bind_nodes() -> void:
		calls.append(["bind_nodes"])
	func build_block_palette() -> void:
		calls.append(["build_block_palette"])
	func build_world() -> void:
		calls.append(["build_world"])
	func build_hud() -> void:
		calls.append(["build_hud"])
	func apply_world_viewport_fit() -> void:
		calls.append(["apply_world_viewport_fit"])


func _ready() -> void:
	var game := FakeHeadlessGame.new()
	add_child(game)

	# Vars.headless (Vars.java:208-209): `public static boolean
	# headless;` -- a static boolean, default false. The port
	# derives it from the display server (decision 2026-11-17
	# ~12:56, Option 1): `DisplayServer.get_name() ==
	# "headless"`, stamped by SourceGameLoopRuntimeState.ready().
	# The ambient gate (N657) already takes this value as its
	# headless_mode input (BuildingComp.java:2270-2271); this
	# slice only supplies the input, it builds no second gate.
	# There is no driver tick line key: the RepairTurret driver
	# (B, N2260) waits for A to land and its accessor interface
	# to be fixed. There is no SoundControl mixer key: the
	# updateLoops aggregate (C, N2243) waits for B.
	var headless_default_false: bool = not bool(game.get("headless"))
	var null_game_headless_false: bool = not bool(source_game_headless_state.source_game_headless_state(null).get("headless", false))
	var bare := Node.new()
	add_child(bare)
	var missing_property_headless_false: bool = not bool(source_game_headless_state.source_game_headless_state(bare).get("headless", false))

	source_game_loop_runtime_state.ready(game)
	await get_tree().process_frame

	var headless_after_ready_matches_display_server: bool = bool(game.get("headless")) == (DisplayServer.get_name() == "headless")
	var accessor_matches_game_property: bool = bool(source_game_headless_state.source_game_headless_state(game).get("headless", false)) == bool(game.get("headless"))
	var gate_suppressed_when_headless: bool = not bool(source_building_time_state.update_ambient_sound_gate_state(true, "beamHeal", "none", true, 1.0, 1.0).get("loop_called", true))
	var gate_loops_when_not_headless: bool = bool(source_building_time_state.update_ambient_sound_gate_state(false, "beamHeal", "none", true, 1.0, 1.0).get("loop_called", false))
	var gate_loop_suppressed_when_headless: bool = gate_suppressed_when_headless and gate_loops_when_not_headless

	var proof := {
		"module": "SourceGameHeadlessState",
		"headless_default_false": headless_default_false,
		"null_game_headless_false": null_game_headless_false,
		"missing_property_headless_false": missing_property_headless_false,
		"headless_after_ready_matches_display_server": headless_after_ready_matches_display_server,
		"accessor_matches_game_property": accessor_matches_game_property,
		"gate_loop_suppressed_when_headless": gate_loop_suppressed_when_headless,
	}
	proof["matches"] = proof["headless_default_false"] and proof["null_game_headless_false"] and proof["missing_property_headless_false"] and proof["headless_after_ready_matches_display_server"] and proof["accessor_matches_game_property"] and proof["gate_loop_suppressed_when_headless"]
	proof_state.write_proof("C07GameHeadlessProof", proof)
	await get_tree().process_frame
	get_tree().quit(proof_state.exit_code(proof))
