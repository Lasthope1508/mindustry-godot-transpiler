extends RefCounted
class_name SourceGameLoopRuntimeState

const source_input_defaults := preload("res://src/game/SourceInputDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

# GameState.isPaused() (GameState.java:93-95): `return state ==
# State.paused;` (the states are paused, playing, menu,
# GameState.java:119-121; the state is set with GameState.set(State),
# GameState.java:60-62). The port keeps the pause as the game's
# `paused` flag. A null game has no pause state, so it reads unpaused.
static func source_game_loop_paused_state(game: Object) -> Dictionary:
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_GAME_LOOP_PAUSED_STATE,
		"paused": false,
	}
	if game == null:
		return result
	# Object.get() takes at most 1 argument (the GDScript trap: a
	# 2-arg get() only exists on Dictionary); a game without the
	# flag reads null, which is unpaused like the Java default.
	result["paused"] = bool(game.get("paused"))
	return result

static func ready(game: Object) -> void:
	source_input_defaults.ensure_input_map()
	game.call("load_config")
	game.call("load_content_registry")
	game.call("load_textures")
	game.call("bind_nodes")
	game.call("build_block_palette")
	game.call("build_world")
	game.call("build_hud")
	game.call_deferred("apply_world_viewport_fit")

static func process_tick(game: Object, delta: float, time_runtime: Variant) -> void:
	# Logic.update (Logic.java:507): `if(!state.isPaused())` gates the
	# whole game update — the tick, Time.update and every sim run only
	# while unpaused, so a paused game advances nothing at all.
	if bool(source_game_loop_paused_state(game).get("paused", false)):
		return
	if time_runtime != null:
		time_runtime.update(delta)
	var tick_methods := [
		"simulate_block_time_scales",
		"simulate_factory",
		"simulate_mend_projectors",
		"simulate_overdrive_projectors",
		"simulate_turrets",
		"simulate_bullets",
		"simulate_enemy_units",
		"update_camera",
		"update_hud",
	]
	for method_name in tick_methods:
		if method_name == "update_hud":
			game.call(method_name)
		else:
			game.call(method_name, delta)
