extends Node
class_name SkinRegistry

var overrides: Dictionary = {}

func set_skin(logical_path: String, replacement_path: String) -> void:
	overrides[logical_path] = replacement_path

func resolve(logical_path: String) -> String:
	return overrides.get(logical_path, logical_path)
