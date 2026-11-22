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

# Logic.isWaitingWave() (Logic.java:605-607) — whether the wave timer
# is paused due to enemies (javadoc :604):
# return (state.rules.waitEnemies || (state.wave >= state.rules.winWave && state.rules.winWave > 0)) && state.enemies > 0;
# Pure predicate over the frame inputs; `state.enemies` is read as-is
# and never counted here (the count leg lives in Logic.update, a
# later slice). The call-site `if(!isWaitingWave())`
# (Logic.java:577, inside update()) belongs to the update()
# driver-tick slice, not this one.
static func source_game_loop_is_waiting_wave_state(wait_enemies: bool, wave: int, win_wave: int, enemies: int) -> Dictionary:
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_GAME_LOOP_IS_WAITING_WAVE_STATE,
		"waiting": false,
	}
	result["waiting"] = (wait_enemies or (wave >= win_wave and win_wave > 0)) and enemies > 0
	return result

static func ready(game: Object) -> void:
	# Vars.headless (Vars.java:208-209) via DisplayServer
	# (decision 2026-11-17 ~12:56, Option 1): a headless display
	# server means the game runs on a headless server
	# (ServerLauncher.java:45 sets headless = true). Stamped
	# first so every load step below sees the same value the
	# ambient gate (N657) reads through SourceGameHeadlessState.
	game.set("headless", DisplayServer.get_name() == "headless")
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
