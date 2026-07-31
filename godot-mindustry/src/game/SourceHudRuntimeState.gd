extends RefCounted
class_name SourceHudRuntimeState

const source_selected_build_state := preload("res://src/game/SourceSelectedBuildState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_HUD_TITLE := "Mindustry Godot slice"
const SOURCE_HUD_TEXT_FORMAT := "%s\nLoaded content objects: %d items / %d liquids / %d blocks / %d units\nGenerated Java classes: %d\nAll generated script instances: %d / %d\nLoaded generated scripts: %d (%s)\nInstanced generated scripts: %d (%s)\nBuild: %s cost %s (%s)\n%s in core: %d\nTotal produced: %d\nWave: %d enemies: %d bullets: %d core health: %d\n%s"

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"requirements_text": Callable(game, "requirements_text"),
	}


static func hud_text_state(game: Object, requirements_text_fn: Callable) -> Dictionary:
	var content_counts: Dictionary = _dict_field(game, "content_counts")
	var loaded_generated_class_names: Array = _array_field(game, "loaded_generated_class_names")
	var loaded_generated_instance_names: Array = _array_field(game, "loaded_generated_instance_names")
	var generated_class_count := int(game.get("generated_class_count"))
	var all_generated_instance_count := int(_dict_field(game, "all_generated_instances").size())
	var selected = source_selected_build_state.selected_build(_array_field(game, "build_palette"), int(game.get("selected_build_index")))
	var selected_name: String = selected.display_name() if selected else "None"
	var selected_cost: String = str(requirements_text_fn.call(selected)) if selected and requirements_text_fn.is_valid() else "none"
	var selected_implementation_name: String = source_selected_build_state.implementation_name(selected) if selected else "none"
	var input_summary: Dictionary = game.call("source_input_runtime_summary_state")
	var control_hint := str(_dict_field(_dict_field(input_summary, "runtime_summary"), "control_profile").get("hud_hint", ""))
	var text := SOURCE_HUD_TEXT_FORMAT % [
		SOURCE_HUD_TITLE,
		int(content_counts.get("items", 0)),
		int(content_counts.get("liquids", 0)),
		int(content_counts.get("blocks", 0)),
		int(content_counts.get("units", 0)),
		generated_class_count,
		all_generated_instance_count,
		generated_class_count,
		loaded_generated_class_names.size(),
		_join_values(loaded_generated_class_names),
		loaded_generated_instance_names.size(),
		_join_values(loaded_generated_instance_names),
		selected_name,
		selected_cost,
		selected_implementation_name,
		str(game.call("playable_core_item_name")),
		int(game.get("core_inventory")),
		int(game.get("produced_total")),
		int(game.get("wave_index")),
		int(_array_field(game, "enemy_units").size()),
		int(_array_field(game, "bullets").size()),
		int(game.get("core_health")),
		control_hint,
	]
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_UPDATE_HUD,
		"text": text,
		"content_counts": content_counts,
		"generated_class_count": generated_class_count,
		"all_generated_instance_count": all_generated_instance_count,
		"loaded_generated_class_names": loaded_generated_class_names,
		"loaded_generated_instance_names": loaded_generated_instance_names,
	}


static func hud_text(game: Object, requirements_text_fn: Callable) -> String:
	return str(hud_text_state(game, requirements_text_fn).get("text", ""))

static func game_hud_text(game: Object) -> String:
	var callbacks := default_callbacks_state(game)
	return hud_text(game, callbacks.get("requirements_text", Callable()))


static func _dict_field(source: Variant, key: String) -> Dictionary:
	var value = source.get(key) if source is Object else source.get(key, {})
	return value if value is Dictionary else {}


static func _array_field(source: Variant, key: String) -> Array:
	var value = source.get(key) if source is Object else source.get(key, [])
	return value if value is Array else []


static func _join_values(values: Array) -> String:
	var parts := PackedStringArray()
	for value in values:
		parts.append(str(value))
	return ", ".join(parts)
