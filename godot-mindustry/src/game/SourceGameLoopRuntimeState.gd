extends RefCounted
class_name SourceGameLoopRuntimeState

const source_input_defaults := preload("res://src/game/SourceInputDefaults.gd")

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
