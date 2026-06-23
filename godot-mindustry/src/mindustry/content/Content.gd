extends RefCounted
class_name MindustryContent

var id := ""
var field := ""
var content_type := ""
var implementation := ""
var properties: Dictionary = {}
var texture_path := ""

func _init(data: Dictionary = {}, type_name: String = "") -> void:
	id = str(data.get("id", ""))
	field = str(data.get("field", ""))
	content_type = type_name
	implementation = str(data.get("implementation", ""))
	properties = data.get("properties", {}).duplicate(true)
	texture_path = str(data.get("texture", ""))

func get_property_value(name: String, default_value = null):
	return properties.get(name, default_value)

func has_texture() -> bool:
	return not texture_path.is_empty()

func display_name() -> String:
	return id.replace("-", " ").capitalize()

func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"field": field,
		"content_type": content_type,
		"implementation": implementation,
		"properties": properties.duplicate(true),
		"texture": texture_path,
	}
