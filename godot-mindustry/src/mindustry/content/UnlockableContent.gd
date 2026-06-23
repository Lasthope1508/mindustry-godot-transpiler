extends "res://src/mindustry/content/Content.gd"
class_name MindustryUnlockableContent

var always_unlocked := false
var hidden := false

func _init(data: Dictionary = {}, type_name: String = "") -> void:
	super(data, type_name)
	always_unlocked = bool(properties.get("alwaysUnlocked", false))
	hidden = bool(properties.get("hidden", false))

func is_visible_in_database() -> bool:
	return not hidden
