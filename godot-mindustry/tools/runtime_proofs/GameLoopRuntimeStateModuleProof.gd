extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_game_loop_runtime_state := preload("res://src/game/SourceGameLoopRuntimeState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

class FakeTimeRuntime:
	extends RefCounted
	var updates: Array = []
	func update(delta: float) -> void:
		updates.append(delta)

class FakeLoopGame:
	extends Node
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
	func simulate_block_time_scales(delta: float) -> void:
		calls.append(["simulate_block_time_scales", delta])
	func simulate_factory(delta: float) -> void:
		calls.append(["simulate_factory", delta])
	func simulate_mend_projectors(delta: float) -> void:
		calls.append(["simulate_mend_projectors", delta])
	func simulate_overdrive_projectors(delta: float) -> void:
		calls.append(["simulate_overdrive_projectors", delta])
	func simulate_turrets(delta: float) -> void:
		calls.append(["simulate_turrets", delta])
	func simulate_bullets(delta: float) -> void:
		calls.append(["simulate_bullets", delta])
	func simulate_enemy_units(delta: float) -> void:
		calls.append(["simulate_enemy_units", delta])
	func update_camera(delta: float) -> void:
		calls.append(["update_camera", delta])
	func update_hud() -> void:
		calls.append(["update_hud"])

func _ready() -> void:
	var game := FakeLoopGame.new()
	add_child(game)
	var time_runtime := FakeTimeRuntime.new()
	source_game_loop_runtime_state.ready(game)
	await get_tree().process_frame
	source_game_loop_runtime_state.process_tick(game, 0.5, time_runtime)
	var expected_calls_no_viewport := [
		["load_config"],
		["load_content_registry"],
		["load_textures"],
		["bind_nodes"],
		["build_block_palette"],
		["build_world"],
		["build_hud"],
		["simulate_block_time_scales", 0.5],
		["simulate_factory", 0.5],
		["simulate_mend_projectors", 0.5],
		["simulate_overdrive_projectors", 0.5],
		["simulate_turrets", 0.5],
		["simulate_bullets", 0.5],
		["simulate_enemy_units", 0.5],
		["update_camera", 0.5],
		["update_hud"],
	]
	var filtered_calls: Array = []
	for call_entry in game.calls:
		if call_entry == ["apply_world_viewport_fit"]:
			continue
		filtered_calls.append(call_entry)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceGameLoopRuntimeState",
		"ready_order_matches": game.calls.slice(0, 7) == expected_calls_no_viewport.slice(0, 7),
		"tick_order_matches": filtered_calls == expected_calls_no_viewport,
		"viewport_fit_deferred_matches": game.calls.has(["apply_world_viewport_fit"]),
		"time_runtime_updated": time_runtime.updates == [0.5],
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["ready_order_matches"] and proof["tick_order_matches"] and proof["viewport_fit_deferred_matches"] and proof["time_runtime_updated"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("GAME_LOOP_RUNTIME_STATE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/GameLoopRuntimeStateModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
