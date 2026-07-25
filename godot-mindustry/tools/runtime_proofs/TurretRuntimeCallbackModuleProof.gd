extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceTurretRuntimeState := preload("res://src/game/SourceTurretRuntimeState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var callbacks := SourceTurretRuntimeState.default_callbacks_state(game)
	var expected_callbacks := {
		"lifetime_seconds": Callable(game, "source_bullet_lifetime_seconds"),
		"world_speed": Callable(game, "source_bullet_world_speed"),
		"dimensions": Callable(game, "source_bullet_dimensions"),
		"hit_size": Callable(game, "source_bullet_hit_size"),
		"damage": Callable(game, "source_bullet_damage"),
		"ammo_multiplier": Callable(game, "source_bullet_ammo_multiplier"),
		"reload_multiplier": Callable(game, "source_bullet_reload_multiplier"),
		"range_change": Callable(game, "source_bullet_range_change"),
	}
	var selected_turret: Variant = game.selected_playable_turret()
	var lifetime_wrapper := game.selected_turret_ammo_lifetime_seconds()
	var lifetime_module := SourceTurretRuntimeState.selected_ammo_lifetime_seconds(selected_turret, callbacks.get("lifetime_seconds", Callable()))
	var world_speed_wrapper := game.selected_turret_ammo_world_speed()
	var world_speed_module := SourceTurretRuntimeState.selected_ammo_world_speed(selected_turret, callbacks.get("world_speed", Callable()))
	var dimensions_wrapper := game.selected_turret_ammo_dimensions()
	var dimensions_module := SourceTurretRuntimeState.selected_ammo_dimensions(selected_turret, callbacks.get("dimensions", Callable()))
	var hit_size_wrapper := game.selected_turret_ammo_hit_size()
	var hit_size_module := SourceTurretRuntimeState.selected_ammo_hit_size(selected_turret, callbacks.get("hit_size", Callable()))
	var damage_wrapper := game.selected_turret_ammo_damage()
	var damage_module := SourceTurretRuntimeState.selected_ammo_damage(selected_turret, callbacks.get("damage", Callable()))
	var ammo_multiplier_wrapper := game.selected_turret_ammo_multiplier()
	var ammo_multiplier_module := SourceTurretRuntimeState.selected_ammo_multiplier(selected_turret, callbacks.get("ammo_multiplier", Callable()))
	var reload_multiplier_wrapper := game.selected_turret_ammo_reload_multiplier()
	var reload_multiplier_module := SourceTurretRuntimeState.selected_ammo_reload_multiplier(selected_turret, callbacks.get("reload_multiplier", Callable()))
	var range_change_wrapper := game.selected_turret_ammo_range_change()
	var range_change_module := SourceTurretRuntimeState.selected_ammo_range_change(selected_turret, callbacks.get("range_change", Callable()))
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceTurretRuntimeState",
		"selected_turret_ready": selected_turret != null,
		"lifetime_matches": lifetime_wrapper == lifetime_module,
		"world_speed_matches": world_speed_wrapper == world_speed_module,
		"dimensions_matches": dimensions_wrapper == dimensions_module,
		"hit_size_matches": hit_size_wrapper == hit_size_module,
		"damage_matches": damage_wrapper == damage_module,
		"ammo_multiplier_matches": ammo_multiplier_wrapper == ammo_multiplier_module,
		"reload_multiplier_matches": reload_multiplier_wrapper == reload_multiplier_module,
		"range_change_matches": range_change_wrapper == range_change_module,
		"default_callbacks_match": callbacks == expected_callbacks,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["module_matches"] = proof["lifetime_matches"] and proof["world_speed_matches"] and proof["dimensions_matches"] and proof["hit_size_matches"] and proof["damage_matches"] and proof["ammo_multiplier_matches"] and proof["reload_multiplier_matches"] and proof["range_change_matches"]
	print("TURRET_RUNTIME_CALLBACK_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
